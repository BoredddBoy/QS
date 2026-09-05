import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Item {
  id: spotify
  
  property var player: Mpris.players.values.find(
    player => player.dbusName === "org.mpris.MediaPlayer2.spotify"
  )

  property bool playing: player ? player.isPlaying : fulse
  property string title: player ? player.trackTitle : ""
  property string artist: player ? player.trackArtist : ""
  property string artUrl: player ? player.trackArtUrl : ""
}
