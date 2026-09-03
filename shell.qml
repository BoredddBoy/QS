import QtQuick
import Quickshell
import qs.components

ShellRoot {

  Clock {
    id: clock
  }

  Spotify {
    id: spotify
  }

  PanelWindow {
    screen: Quickshell.screens.find(s => s.name === "HDMI-A-3")

    anchors {
      top: true
    }

    margins {
      top: 8
      left: 8
      right: 8
    }

    implicitHeight: 33
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
        
        source: "assets/mediaIcon.png"

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
  } 
}