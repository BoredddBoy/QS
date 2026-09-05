import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var trayItem: null
    property alias menuHandle: opener.menu
    property int itemWidth: 160
    property real menuWidth: itemWidth

    visible: trayItem !== null
    grabFocus: true   // با کلیک بیرون از منو بسته میشه

    implicitWidth: column.width
    implicitHeight: column.height

    color: "transparent"

    QsMenuOpener {
        id: opener
        menu: root.trayItem ? root.trayItem.menu : null
    }

    Rectangle {
        anchors.fill: parent
        color: "#2f2d2e"
        radius: 16
    }

    Column {
        id: column
        padding: 6
        spacing: 2

        Repeater {
            model: opener.children

            delegate: Item {
                required property var modelData
                width: root.menuWidth
                height: modelData.isSeparator ? 9 : 28

                Rectangle {
                    visible: modelData.isSeparator
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: 1
                    color: "#555"

                }

                Text {
                    id: checkMark
                    visible: !modelData.isSeparator && modelData.buttonType !== QsMenuButtonType.None
                    text: modelData.checkState === Qt.Checked
                        ? (modelData.buttonType === QsMenuButtonType.RadioButton ? "●" : "✓")
                        : (modelData.buttonType === QsMenuButtonType.RadioButton ? "○" : "x")
                    color: "#dad7cd"
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    font.pixelSize: 13
                }

                Text {
                    id: label
                    visible: !modelData.isSeparator
                    text: modelData.text
                    color: modelData.enabled ? "#dad7cd" : "#777"
                    anchors.verticalCenter: parent.verticalCenter
                    x: checkMark.visible ? 30 : 12
                    font.pixelSize: 14
                    font.family: "Figtree"
                    font.bold: true

                    onImplicitWidthChanged: {
                        const needed = implicitWidth + (checkMark.visible ? 46 : 28)
                        if (needed > root.menuWidth) root.menuWidth = needed
                    }
                }

                MouseArea {
                    visible: !modelData.isSeparator
                    anchors.fill: parent
                    enabled: modelData.enabled
                    hoverEnabled: true
                    onClicked: {
                        modelData.triggered()
                        root.trayItem = null   // منو رو ببند
                    }
                    onEntered: parent.opacity = 0.7
                    onExited: parent.opacity = 1
                }
            }
        }
    }

    onVisibleChanged: {
    if (visible) menuWidth = itemWidth
    if (!visible) trayItem = null
    }
}