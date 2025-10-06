import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 900
    height: 1600
    title: qsTr("FairStore")

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        padding: 16

        Label {
            text: qsTr("Curated privacy-first applications")
            wrapMode: Text.WordWrap
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: storeModel.apps
            delegate: Frame {
                width: parent.width
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 4
                    Label { text: modelData.name; font.bold: true }
                    Label { text: modelData.description; wrapMode: Text.WordWrap }
                    Label { text: qsTr("Permissions: ") + modelData.permissions.join(", ") }
                    RowLayout {
                        spacing: 8
                        Button {
                            text: qsTr("Install Flatpak")
                            onClicked: storeModel.install_flatpak(modelData.flatpak)
                        }
                        Button {
                            text: qsTr("Install APK")
                            enabled: modelData.apk !== undefined
                            onClicked: storeModel.install_apk(modelData.apk)
                        }
                    }
                }
            }
        }
    }
}
