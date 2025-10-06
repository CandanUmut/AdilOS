import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

GroupBox {
    title: qsTr("AI Palette")
    Layout.fillWidth: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        TextArea {
            id: promptArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            placeholderText: qsTr("Ask Hope, the on-device assistant...")
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: qsTr("Send")
                onClicked: aiRequest()
            }

            Button {
                text: qsTr("Voice")
                onClicked: console.log("Trigger ASR")
            }
        }

        Label {
            id: responseLabel
            text: ""
            wrapMode: Text.WordWrap
        }
    }

    function aiRequest() {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    responseLabel.text = xhr.responseText
                } else {
                    responseLabel.text = qsTr("AI request failed")
                }
            }
        }
        xhr.open("POST", "http://127.0.0.1:13100/generate")
        xhr.send(JSON.stringify({ prompt: promptArea.text }))
    }
}
