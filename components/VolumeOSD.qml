import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Pipewire

PanelWindow {
    id: osd

    screen: Quickshell.screens.find(s => s.name === "HDMI-A-3")

    // بالاترین لایه، حتی روی بازی فول‌اسکرین
    WlrLayershell.layer: WlrLayer.Overlay

    // هیچ فضایی رزرو نکنه، پس پنجره‌ها/بازی‌ها جابه‌جا نمی‌شن
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    anchors {
        top: true
    }

    property real barHeight: 30

    margins {
        top: 8 + barHeight + 8
    }

    // عرض از بیرون ست میشه، دقیقاً هم‌اندازه‌ی بار ساعت
    implicitWidth: 260
    implicitHeight: 64

    visible: false

    property var activeNode: null
    property real volume: activeNode?.audio?.volume ?? 0
    property bool muted: activeNode?.audio?.muted ?? false
    property bool isAppStream: activeNode ? !activeNode.isSink : false
    property string appIconName: activeNode?.properties?.["application.icon-name"] ?? ""

    
    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.audio)
    }

    Instantiator {
        model: Pipewire.nodes
        delegate: Connections {
            required property var modelData
            target: modelData.audio ?? null

            function onVolumeChanged() { osd.trigger(modelData) }
            function onMutedChanged() { osd.trigger(modelData) }
        }
    }

    function trigger(node) {
        activeNode = node
        visible = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: osd.visible = false
    }

    Rectangle {
        anchors.fill: parent
        color: "#2f2d2e"
        radius: 24

        Row {
            anchors.centerIn: parent
            spacing: 14

            Image {
                visible: !osd.isAppStream
                source: osd.muted ? "../assets/icons/volume-mute.png" : "../assets/icons/volume.png"
                width: 22
                height: 22
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }

            IconImage {
                id: appIcon
                visible: osd.isAppStream
                source: osd.appIconName !== "" ? Quickshell.iconPath(osd.appIconName, "") : ""
                implicitSize: 22
                anchors.verticalCenter: parent.verticalCenter

                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("آیکون پیدا نشد برای:", osd.appIconName)
                    }
                }
            }

            Rectangle {
                id: track
                width: 130
                height: 6
                radius: 3
                color: "#4a4746"
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: track.width * (osd.muted ? 0 : osd.volume)
                    height: parent.height
                    radius: 3
                    color: "#dad7cd"

                    Behavior on width {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }
                }
            }

            Text {
                text: Math.round((osd.muted ? 0 : osd.volume) * 100) + "%"
                color: "#dad7cd"
                font.family: "Figtree"
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                width: 42
            }
        }
    }
}