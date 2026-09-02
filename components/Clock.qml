import QtQuick
import Quickshell

Item {
  id: clock

  SystemClock {
    id: systemClock
    precision: SystemClock.Seconds
  }

  property alias date: systemClock.date
}
