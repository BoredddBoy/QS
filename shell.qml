//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.components

ShellRoot {

  Clock {
    id: clock
  }

  Spotify {
    id: spotify
  }

  TrayMenu {
        id: trayMenu
        anchor.window: panel
        anchor.rect.x: systemTray.mapToItem(null, systemTray.width, 0).x - width
        anchor.rect.y: systemTray.mapToItem(null, 0, systemTray.height).y + 8
    }

  PanelWindow { //Monitor HDMI-A-3
    id: panel
    screen: Quickshell.screens.find(s => s.name === "HDMI-A-3")

    color: "transparent"

    anchors {
      top: true
    }

    margins {
      top: 8
      left: 8
      right: 8
    }

    implicitHeight: 30
    implicitWidth: 1900

    Item { // Center Bar

      id: bar

      anchors.centerIn: parent

      width: spotify.playing ? clockText.width + mediaIcon.width + songText.width + 48 : 102

      height: parent.height

      Rectangle {
        color: "#2f2d2e"
        anchors.fill: parent
        radius: 24
      }

      Text {
          id: clockText

          text: Qt.formatDateTime(clock.date, "hh:mm")

          color: "#dad7cd"

          font.family: "Figtree"
          font.pixelSize: 24
          font.bold: true

          x: spotify.playing ? 16 : (parent.width - width) / 2

          anchors.verticalCenter: parent.verticalCenter
      }

      Image {
        id: mediaIcon 

        visible: spotify.playing
        
        source: "assets/icons/music-playing.png"

        width: 22
        height: 22

        fillMode: Image.PreserveAspectFit

        x: clockText.x + clockText.width + 8

        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
      id: songText
      visible: spotify.playing

      anchors.verticalCenter: parent.verticalCenter

      x: mediaIcon.x + mediaIcon.width + 8

      text: spotify.title
      
      color: "#DAD7CD"

      font.family: "Figtree"
      font.pixelSize: 20
      font.bold: true
      }
    }

    Item { // System Tray
      id: systemTray
      
      anchors {
        right: parent.right

      }

      height: parent.height
      width: trayRow.width + 30

      Rectangle {
        color: "#2f2d2e"
        anchors.fill: parent

        radius: 24

        Row {
          id: trayRow

          anchors.centerIn: parent

          layoutDirection: Qt.RightToLeft
          spacing: 8
          
          Repeater {
            model: SystemTray.items

            delegate: Item {
              required property var modelData

              width: 20
              height: 20

              Image {
                anchors.fill: parent

                source: modelData.icon

                fillMode: Image.PreserveAspectFit

              }

              MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                  if (mouse.button === Qt.LeftButton) {
                    modelData.activate()
                  }

                  if (mouse.button === Qt.RightButton) {
                    if (modelData.menu) {
                      const pos = mapToItem(null, mouse.x, mouse.y)
                      trayMenu.trayItem = modelData
                    } else {
                     modelData.secondaryActivate()
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  } 

  PanelWindow { // Monitor DP-2
    screen: Quickshell.screens.find(s => s.name === "DP-2")

    anchors {
      top: true
    }

    margins {
      top: 5
      left: 5
      right: 5
    }

    color: "transparent"

    implicitHeight: 33
    implicitWidth: 1340

    Item {
      anchors.centerIn: parent

      width: workspaceIndicator.width > 0 ? workspaceIndicator.width + 20 : 0
      height: parent.height

      Rectangle {
        color: "#2f2d2e"
        anchors.fill: parent
        radius: 24
      }

      Row {
        id: workspaceIndicator
        anchors.centerIn: parent
        spacing: 6

        property var workspaceIcons: ({
          "music": "assets/icons/music.png",
          "chat": "assets/icons/chat.png"
        })

        Repeater {
          model: Hyprland.workspaces

          delegate: Rectangle {
            required property var modelData
            property color accent: Colors.accentFor(modelData.name)

            visible: modelData.monitor && modelData.monitor.name === "DP-2"

            width: 24
            height: 24
            radius: 24
            color: modelData.active ? accent : Colors.background
            border.color: accent
            border.width: modelData.active ? 0 : 1

            Image {
                id: icon
                anchors.centerIn: parent
                width: 16
                height: 16
                fillMode: Image.PreserveAspectFit
                source: workspaceIndicator.workspaceIcons[modelData.name] ?? ""
                visible: false
            }

            ColorOverlay {
                anchors.fill: icon
                source: icon
                color: modelData.active ? Colors.background : accent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
            }
          }
        }
      }
    }
  }
}