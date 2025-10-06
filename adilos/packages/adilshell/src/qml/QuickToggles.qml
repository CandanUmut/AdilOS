import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    spacing: 12

    function toggle(name, enabled) {
        console.log("Toggle", name, enabled)
    }

    Repeater {
        model: [
            { label: "Wi-Fi", icon: "network-wireless", setting: "wifi" },
            { label: "Bluetooth", icon: "bluetooth", setting: "bt" },
            { label: "Airplane", icon: "airplane-mode", setting: "airplane" },
            { label: "Child", icon: "security-high", setting: "child" }
        ]

        delegate: Button {
            id: toggleButton
            text: modelData.label
            checkable: true
            icon.name: modelData.icon
            onToggled: toggle(modelData.setting, checked)
        }
    }
}
