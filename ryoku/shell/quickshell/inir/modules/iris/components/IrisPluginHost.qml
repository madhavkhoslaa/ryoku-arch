pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Ryoku.PluginKit
import shell.services as Ryoku

// One running Ryoku bar plugin: its service/Main.qml and the pluginApi handle docs/plugins.md promises, for the
// Island's glyph or a panel placed where no glyph is. A registered host is the one a card reads, so a glyph and the
// card it opens share one service; a panel's own host stays unregistered and only runs when no glyph does.
Item {
    id: root
    property string pluginId: ""
    property bool register: true
    signal panelRequested()

    readonly property var entry: Ryoku.GlyphPlugins.entryFor(root.pluginId)
    readonly property bool shown: root.pluginId.length > 0 && Ryoku.GlyphPlugins.isShown(root.pluginId)
    readonly property string versionQuery: root.entry && root.entry.version ? "?v=" + encodeURIComponent(root.entry.version) : ""

    width: 0
    height: 0

    property var api: QtObject {
        readonly property var mainInstance: service.item
        readonly property var pluginSettings: (root.entry && root.entry.placement && root.entry.placement.settings)
            ? root.entry.placement.settings : ({})
        readonly property string pluginDir: root.entry ? root.entry.dir : ""
        readonly property string stateDir: Ryoku.GlyphPlugins.stateDir(root.pluginId)
        readonly property bool panelOpen: false
        readonly property bool hasPanel: Ryoku.GlyphPlugins.hasPanel(root.pluginId)
        function saveSetting(key, value) { Ryoku.GlyphPlugins.saveSetting(root.pluginId, key, value) }
        function saveSettings() {}
        function openPanel() { if (hasPanel) root.panelRequested() }
        function closePanel() { if (hasPanel) root.panelRequested() }
        function togglePanel() { if (hasPanel) root.panelRequested() }
    }
    Component.onCompleted: {
        if (root.pluginId.length === 0) return
        Quickshell.execDetached(["mkdir", "-p", root.api.stateDir])
        if (root.register) Ryoku.GlyphPlugins.registerApi(root.pluginId, root.api)
    }
    Component.onDestruction: if (root.register) Ryoku.GlyphPlugins.unregisterApi(root.pluginId, root.api)

    PluginObjectSlot {
        id: service
        source: root.shown && root.entry ? "file://" + root.entry.dir + "/service/Main.qml" + root.versionQuery : ""
        configure: svc => { svc.pluginApi = root.api }
    }
}
