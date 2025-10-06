#!/usr/bin/env python3
import json
import pathlib

from typing import List

from PySide6.QtCore import QObject, Slot, Signal, Property, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

DATA_PATH = pathlib.Path.home() / ".local/share/adilnotes/notes.json"
DATA_PATH.parent.mkdir(parents=True, exist_ok=True)


def load_notes() -> List[str]:
    if DATA_PATH.exists():
        return json.loads(DATA_PATH.read_text())
    return []


def save_notes(notes: List[str]):
    DATA_PATH.write_text(json.dumps(notes, indent=2))


class NotesModel(QObject):
    notesChanged = Signal()

    def __init__(self):
        super().__init__()
        self._notes = load_notes()

    @Property(list, notify=notesChanged)
    def notes(self):
        return self._notes

    @Slot(str)
    def add_note(self, text: str):
        self._notes.append(text)
        save_notes(self._notes)
        self.notesChanged.emit()

    @Slot(int)
    def remove_note(self, index: int):
        if 0 <= index < len(self._notes):
            self._notes.pop(index)
            save_notes(self._notes)
            self.notesChanged.emit()


def main():
    app = QGuiApplication()
    engine = QQmlApplicationEngine()
    model = NotesModel()
    engine.rootContext().setContextProperty("notesModel", model)
    engine.load(QUrl.fromLocalFile(str(pathlib.Path(__file__).parent / "qml" / "Main.qml")))
    if not engine.rootObjects():
        raise SystemExit(1)
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
