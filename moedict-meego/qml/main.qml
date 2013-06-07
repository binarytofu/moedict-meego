import QtQuick 1.1
import com.nokia.meego 1.0

BaseWindow {
    id: appWindow

    property variant database: AppDatabase {}
    property variant settings: AppSettings {}
    property variant updater:  AppUpdater {}
    property variant history: AppHistory {}
    property bool dictionaryEnabled: true

    Component.onCompleted: {
        database.load()
        settings.load()
        history.load()
        updater.version = appWindow.settings.getDefault("dict.version", 0)
        if (updater.version <= 0) {
            aboutTab.checked = true
            dictionaryEnabled = false
        } else {
            var last = history.get(0)
            if (last != undefined) __showEntry(last)
            else __showEntry("成長")
        }
    }

    function __showEntry(title) { dictPage.showEntry(title) }

    contentItem: Flickable {
        id: contentArea
        anchors.fill: parent
        contentWidth: (interactive) ? width * 2 : width * 3
        contentHeight: height
        boundsBehavior: Flickable.StopAtBounds

        Row {
            height: parent.height

            // Common API for Pages
            property alias itemHeight: contentArea.height
            property alias itemWidth: contentArea.width
            function window() {
                return appWindow
            }

            // Page items
            DictPage { id: dictPage }
            HistoryPage { id: historyPage }
            AboutPage { id: aboutPage }
        }

        property int __lastX: 0
        onMovementStarted: {
            __lastX = contentX
        }
        onMovementEnded: {
            var delta = (contentX - __lastX)
            if (delta > 0)
                historyTab.checked = true
            else if (delta < 0)
                dictTab.checked = true
        }
    }

    toolBarTools: ToolBarLayout {

        ToolIcon {
            platformIconId: "toolbar-previous"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if (history.canGoBack) history.back()
                else Qt.quit()
            }
        }

        ButtonRow {
            TabButton {
                id: dictTab
                iconSource: "image://theme/icon-m-toolbar-list" + (enabled ? "": "-dimmed")
                checked: true
                enabled: dictionaryEnabled
            }
            TabButton {
                id: historyTab
                iconSource: "image://theme/icon-m-toolbar-history" + (enabled ? "": "-dimmed")
                enabled: dictionaryEnabled
            }
            TabButton {
                id: aboutTab
                iconSource: "image://theme/icon-m-toolbar-update"
            }
        }

        ToolIcon {
            platformIconId: "toolbar-next"
            anchors.verticalCenter: parent.verticalCenter
            visible: !inPortrait
            enabled: history.canGoForward
            onClicked: history.forward()
        }
    }

    state: "dict"
    states: [
        State {
            name: "dict"
            when: dictTab.checked
            PropertyChanges { target: contentArea; contentX: dictPage.x; interactive: true }
        },
        State {
            name: "history"
            when: historyTab.checked
            PropertyChanges { target: contentArea; contentX: historyPage.x; interactive: true }
        },
        State {
            name: "about"
            when: aboutTab.checked
            PropertyChanges { target: contentArea; contentX: aboutPage.x; interactive: false }
        }
    ]
    transitions: [
        Transition {
            to: "*"
            NumberAnimation {
                target: contentArea; property: "contentX"; duration: 200
                easing.type: Easing.OutCubic
            }
        }
    ]
}
