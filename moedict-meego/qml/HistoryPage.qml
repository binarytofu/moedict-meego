import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "ext" as External

Item {
    id: page
    width: parent.itemWidth
    height: parent.itemHeight

    AppViewHeader {
        id: header
        text: "歷程紀錄"

        SheetButton {
            anchors.right: parent.paddingItem.right
            anchors.verticalCenter: parent.paddingItem.verticalCenter
            platformStyle.inverted: true
            text: "清除"
            onClicked: appWindow.history.clear()
        }
    }

    ListView {
        id: historyList
        anchors {
            top: header.bottom
            left: parent.left; leftMargin: UiConstants.DefaultMargin
            right: parent.right; rightMargin: UiConstants.DefaultMargin
            bottom: parent.bottom
        }

        delegate: Component {
            ListItem {
                title: model.title
                //subtitle
                onClicked: appWindow.history.navigate(title)
            }
        }

        section.delegate: Component {
            SectionHeader {
                text: section
            }
        }

        section.criteria: ViewSection.FullString
        section.property: "day"
        model: appWindow.history.model
    }

    External.FastScroll {
        listView: historyList
    }
}
