#!/usr/bin/env python3
import json
import pathlib
import subprocess
from dataclasses import dataclass
from typing import List

from PySide6.QtCore import QObject, Slot, Signal, Property, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

BASE_DIR = pathlib.Path(__file__).resolve().parent
MANIFESTS_DIR = BASE_DIR.parent / "manifests" / "examples"

@dataclass
class AppManifest:
    name: str
    description: str
    flatpak: str
    permissions: List[str]
    signature: str
    categories: List[str]


def load_manifests():
    apps = []
    for manifest_path in MANIFESTS_DIR.glob("*.yml"):
        data = json.loads(manifest_path.read_text())
        apps.append(AppManifest(
            name=data.get("name", manifest_path.stem),
            description=data.get("description", ""),
            flatpak=data.get("flatpak", ""),
            permissions=data.get("permissions", []),
            signature=data.get("signature", ""),
            categories=data.get("categories", []),
        ))
    return apps


class StoreModel(QObject):
    appsChanged = Signal()

    def __init__(self):
        super().__init__()
        self._apps = load_manifests()
        self._child_mode = pathlib.Path("/etc/adilos/childmode.enabled").exists()

    @Property(list, notify=appsChanged)
    def apps(self):
        if not self._child_mode:
            return [app.__dict__ for app in self._apps]
        allowed_categories = {"education", "productivity", "utilities"}
        filtered = [app for app in self._apps if allowed_categories.intersection(app.categories)]
        return [app.__dict__ for app in filtered]

    @Slot(str, result=bool)
    def install_flatpak(self, ref: str) -> bool:
        try:
            subprocess.check_call(["flatpak", "install", "--assumeyes", ref])
            return True
        except subprocess.CalledProcessError:
            return False

    @Slot(str, result=bool)
    def install_apk(self, path: str) -> bool:
        try:
            subprocess.check_call(["systemctl", "--user", "start", "waydroid-session.service"])
            subprocess.check_call(["waydroid", "app", "install", path])
            return True
        except subprocess.CalledProcessError:
            return False


def main():
    app = QGuiApplication()
    engine = QQmlApplicationEngine()
    model = StoreModel()
    engine.rootContext().setContextProperty("storeModel", model)
    engine.load(QUrl.fromLocalFile(str(BASE_DIR / "qml" / "Main.qml")))
    if not engine.rootObjects():
        raise SystemExit(1)
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
