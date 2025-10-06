import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 800
    height: 1200
    title: qsTr("AdilNotes")

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        padding: 16

        TextArea {
            id: input
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            placeholderText: qsTr("Dictate or type your note...")
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Button {
                text: qsTr("Add Note")
                onClicked: {
                    notesModel.add_note(input.text)
                    input.text = ""
                }
            }
            Button {
                text: qsTr("Voice")
                onClicked: console.log("Trigger voice capture via AdilAI")
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: notesModel.notes
            delegate: Frame {
                width: parent.width
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 4
                    Label {
                        text: modelData
                        wrapMode: Text.WordWrap
                    }
                    Button {
                        text: qsTr("Delete")
                        onClicked: notesModel.remove_note(index)
                    }
                }
            }
        }
    }
}
