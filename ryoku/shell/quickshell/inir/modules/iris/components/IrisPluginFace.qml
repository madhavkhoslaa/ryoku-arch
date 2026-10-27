pragma ComponentBehavior: Bound
import QtQuick
import Ryoku.PluginKit

// A Ryoku bar plugin's mark on the Island: its content/Widget.qml at glyph density over a registered IrisPluginHost,
// with the host properties docs/plugins.md promises a bar host sets. The piece's own grip takes the tap and opens the
// plugin's card, so the plugin's togglePanel() asks the Island for the same card through `panelRequested`.
Item {
    id: root
    property string pluginId: ""
    property real budget: 0
    property real s: 1
    property var targetScreen: null
    signal panelRequested()

    implicitWidth: host.shown && content.item ? content.item.implicitWidth : 0
    implicitHeight: host.shown && content.item ? content.item.implicitHeight : 0

    IrisPluginHost {
        id: host
        pluginId: root.pluginId
        onPanelRequested: root.panelRequested()
    }

    PluginObjectSlot {
        id: content
        // the kit slot is 0x0 by design; size it to the plugin's own report
        width: content.item ? content.item.implicitWidth : 0
        height: content.item ? content.item.implicitHeight : 0
        anchors.centerIn: parent
        source: host.shown && host.entry ? "file://" + host.entry.dir + "/content/Widget.qml" + host.versionQuery : ""
        configure: item => {
            item.pluginApi = host.api
            item.density = "glyph"
            item.widthBudget = Qt.binding(() => root.budget)
            item.active = true
            // in the documented contract, but a plugin written against QS Bar alone may not declare them
            if ("s" in item) item.s = Qt.binding(() => root.s)
            if ("screen" in item) item.screen = Qt.binding(() => root.targetScreen)
        }
    }
}
