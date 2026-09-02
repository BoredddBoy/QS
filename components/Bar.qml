import QtQuick
import Quickshell
import qs.components

PanelWindow {
  id: bar

  anchors {
    top: true
  }

  margins {
    top: 8

  }
  
  implicitHeight: 33
  implicitWidth: spotify.playing ? clockText.width + mediaIcon.width + songText.width + 48 : 102
  
  color: "transparent"

  Rectangle {
    anchors.fill: parent

    color: "#2F2D2E"

    radius: 24
    
    Clock {
      id: clock
    }
    
    Spotify {
      id: spotify
    }

    Text {
      id: clockText 

      text: Qt.formatDateTime(clock.date, "hh:mm")
      
      color: "#DAD7CD"

      font.family: "Figtree"
      font.pixelSize: 24
      font.bold: true

      x: spotify.playing ? 16 : (parent.width - width) / 2

      anchors.verticalCenter: parent.verticalCenter

    }
    
    Image {
      id: mediaIcon 

      visible: spotify.playing
      
      source: "../assets/mediaIcon.png"

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
