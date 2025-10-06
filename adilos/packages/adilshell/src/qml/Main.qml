import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import AdilShell

ApplicationWindow {
    id: root
    width: 1080
    height: 2400
    visible: true
    title: qsTr("AdilOS")

    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        padding: 24

        Label {
            text: qsTr("AdilOS Home")
            font.pixelSize: 36
        }

        QuickToggles {
            Layout.fillWidth: true
        }

        AIPalette {
            Layout.fillWidth: true
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Label {
                    text: qsTr("Apps")
                    font.bold: true
                }

                Repeater {
                    model: ["AdilBrowser", "FairStore", "Settings", "Terminal"]
                    delegate: Button {
                        text: modelData
                        Layout.fillWidth: true
                        onClicked: console.log("Launching", text)
                    }
                }
            }
        }
    }
}
