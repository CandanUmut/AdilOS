import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine

ApplicationWindow {
    visible: true
    width: 1080
    height: 2400
    title: qsTr("AdilBrowser")

    property var blocklist: loadBlocklist()

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 8
            ToolButton {
                text: "←"
                onClicked: webView.goBack()
            }
            ToolButton {
                text: "→"
                onClicked: webView.goForward()
            }
            TextField {
                id: urlField
                Layout.fillWidth: true
                placeholderText: qsTr("Search or enter address")
                onAccepted: loadUrl(text)
            }
            ToolButton {
                text: qsTr("Go")
                onClicked: loadUrl(urlField.text)
            }
        }
    }

    WebEngineView {
        id: webView
        anchors.fill: parent
        profile: WebEngineProfile {
            id: adilProfile
            httpUserAgent: "AdilBrowser/1.0"
            storageName: "AdilBrowser"
            offTheRecord: false
            userScripts: [
                WebEngineScript {
                    name: "tracker-blocker"
                    worldId: WebEngineScript.MainWorld
                    injectionPoint: WebEngineScript.DocumentCreation
                    sourceCode: Qt.binding(function() {
                        return "const blocked = " + JSON.stringify(blocklist) + ";\n" +
                               "const origFetch = window.fetch;\n" +
                               "window.fetch = function() {\n" +
                               "  const url = arguments[0];\n" +
                               "  if (blocked.some(pattern => url.includes(pattern))) {\n" +
                               "    console.warn('Blocked tracker', url);\n" +
                               "    return Promise.reject('Blocked by AdilBrowser');\n" +
                               "  }\n" +
                               "  return origFetch.apply(this, arguments);\n" +
                               "};\n";
                    })
                }
            ]
        }
        url: "https://www.ecosia.org"
    }

    function loadBlocklist() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "qrc:/AdilBrowser/resources/tracker-blocklist.txt", false)
        xhr.send()
        if (xhr.status === 200)
            return xhr.responseText.split('\n').filter(function(line) { return line.length > 0 && line[0] !== '#'; })
        return []
    }

    function loadUrl(text) {
        if (!text)
            return
        var finalUrl = text
        if (!text.startsWith("http")) {
            finalUrl = "https://www.ecosia.org/search?q=" + encodeURIComponent(text)
        }
        webView.url = finalUrl
    }
}
