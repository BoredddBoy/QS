//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire 
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

  VolumeOSD {
    id: volumeOsd
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

    property alias clockBarWidth: bar.width

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

      function findSpotifyNode() {
        const nodes = Pipewire.nodes.values
        for (let i = 0; i < nodes.length; i++) {
          const node = nodes[i]
          const appName = node.properties ? node.properties["application.name"] : ""
          if (node.audio && appName && appName.toLowerCase().includes("spotify")) {
            return node
          }
        }
        return null
      }

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

      MouseArea {
        anchors.fill: parent
        enabled: spotify.playing
        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
          const node = bar.findSpotifyNode()
          console.log("spotifyNode:", node ? node.name : "null")

          if (!node || !node.ready || !node.audio) {
            console.log("node not ready or not found, bailing out")
            return
          }

          const step = 0.05
          let vol = node.audio.volume

          if (wheel.angleDelta.y > 0) {
            vol = Math.min(1.0, vol + step)
          } else {
            vol = Math.max(0.0, vol - step)
          }

          node.audio.muted = false
          node.audio.volume = vol

          wheel.accepted = true
        }
      }
    }

    Item { // System Tray
      id: systemTray
      
      anchors {
        right: parent.right

      }

      height: parent.height
      width: trayRow.width > 0 ? trayRow.width + 20 : 0

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

    Item { // Workspace Indicator
      anchors.left: parent

      width: workspaceIndicatorHDMI.width > 0 ? workspaceIndicatorHDMI.width + 20 : 0
      height: parent.height

      Rectangle {
        color: "#2f2d2e"
        anchors.fill: parent
        radius: 24
      }

      Row {
        id: workspaceIndicatorHDMI
        anchors.centerIn: parent
        spacing: 6

        property var workspaceIcons: ({
          "home": "assets/icons/home.png",
          "code": "assets/icons/code.png",
          "design": "assets/icons/design.png",
          "game": "assets/icons/game.png",
          "launcher": "assets/icons/launcher.png",
          "media": "assets/icons/media.png",
          "settings": "assets/icons/settings.png",
          "network-settings": "assets/icons/network-settings.png",

          "1": "assets/icons/1.png",
          "2": "assets/icons/2.png",
          "3": "assets/icons/3.png",
          "4": "assets/icons/4.png"


        })

        Repeater {
          model: Hyprland.workspaces

          delegate: Rectangle {
            required property var modelData
            property color accent: Colors.accentFor(modelData.name)

            visible: modelData.monitor && modelData.monitor.name === "HDMI-A-3"

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
                source: workspaceIndicatorHDMI.workspaceIcons[modelData.name] ?? ""
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

      width: workspaceIndicatorDP.width > 0 ? workspaceIndicatorDP.width + 20 : 0
      height: parent.height

      Rectangle {
        color: "#2f2d2e"
        anchors.fill: parent
        radius: 24
      }

      Row {
        id: workspaceIndicatorDP
        anchors.centerIn: parent
        spacing: 6

        property var workspaceIcons: ({
          "music": "assets/icons/music.png",
          "chat": "assets/icons/chat.png",
          "stream": "assets/icons/stream.png",
          "settings": "assets/icons/settings.png",
          "network-settings": "assets/icons/network-settings.png",
          "resolveViewer": "assets/icons/resolveViewer.png",

          "1": "assets/icons/1.png",
          "2": "assets/icons/2.png",
          "3": "assets/icons/3.png",
          "4": "assets/icons/4.png"
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
                source: workspaceIndicatorDP.workspaceIcons[modelData.name] ?? ""
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