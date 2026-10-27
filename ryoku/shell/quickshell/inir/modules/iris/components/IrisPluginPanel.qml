pragma ComponentBehavior: Bound
import QtQuick
import Ryoku.PluginKit
import shell.services as Ryoku

// A Ryoku bar plugin's panel (entryPoints.panel) at full density, wherever Shima shows it: the card its Island
// glyph opens, a Control Center block, or the Island's home page. It reads the glyph's registered pluginApi when
// there is one, so both share a service; placed where no glyph runs, it starts the plugin's service itself.
Item {
    id: root
    property string pluginId: ""
    property real s: 1
    property bool active: true

    readonly property var entry: Ryoku.GlyphPlugins.entryFor(root.pluginId)
    readonly property var manifest: root.entry?.manifest ?? ({})
    readonly property string panelRel: String(root.manifest.entryPoints?.panel ?? "")
    readonly property string versionQuery: root.entry?.version ? "?v=" + encodeURIComponent(root.entry.version) : ""
    readonly property var glyphApi: Ryoku.GlyphPlugins.apis[root.pluginId] ?? null
    readonly property var api: root.glyphApi ?? ownHost.api

    implicitHeight: panel.item?.implicitHeight ?? 0

    IrisPluginHost {
        id: ownHost
        // only while no glyph runs the plugin, so its service never starts twice
        pluginId: root.glyphApi ? "" : root.pluginId
        register: false
    }

    PluginObjectSlot {
        id: panel
        fill: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: item ? item.implicitHeight : 0
        source: root.entry && root.panelRel.length > 0 && Ryoku.GlyphPlugins.isShown(root.pluginId)
            ? "file://" + root.entry.dir + "/" + root.panelRel + root.versionQuery : ""
        configure: c => {
            c.pluginApi = Qt.binding(() => root.api)
            if ("density" in c) c.density = "full"
            if ("s" in c) c.s = Qt.binding(() => root.s)
            if ("widthBudget" in c) c.widthBudget = Qt.binding(() => root.width)
            if ("active" in c) c.active = Qt.binding(() => root.active)
        }
    }
}
