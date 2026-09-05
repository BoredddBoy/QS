pragma Singleton
import QtQuick

QtObject {
    // رنگ‌های پایه (همونایی که همین الان توی بار داری)
    readonly property color background: "#2f2d2e"
    readonly property color backgroundAlt: "#4C4C47"       // پس‌زمینه‌ی پیش‌فرض مربع‌ها
    readonly property color text: "#dad7cd"   // متن/آیکون پیش‌فرض (حالت خنثی)

    // رنگ اختصاصی هر ورک‌اسپیس
    readonly property var accents: ({
        "yellow": "#F8C630",
        "green": "#9DC90A",
        "blue": "#197BBD",
        "pink": "#EE4266"   
    })

    readonly property var workspaceColors: ({
        "music": "yellow",
        "chat": "pink"   
    })

    function accentFor(name) {
        const colorName = workspaceColors[name]
        return accents[colorName] ?? text
    }
}