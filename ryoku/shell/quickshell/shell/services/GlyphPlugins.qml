pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Community bar plugins (manifest host topbarGlyph) for the bar styles that
// host them outside QS Bar. One discovery shared by every surface and monitor:
// discover.sh --all, re-run on a plugins.json change or a Store transaction. A
// plugin shows when its placement has it enabled on the bar host, the rule QS
// Bar follows, so one placement drives whichever bar style is live.
Singleton {
    id: root

    // every installed plugin, enabled or not (raw discover.sh --all rows)
    property var all: []
    property bool loaded: false
    // installed plugins whose manifest lists topbarGlyph
    readonly property var barCapable: root.all.filter(p => root.manifestHostsBar(p))

    readonly property string _shellDir: Quickshell.env("RYOKU_SHELL_DIR")
    readonly property string _configHome: Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
    readonly property string _stateHome: Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
    readonly property string _script: (_shellDir && _shellDir.length > 0)
        ? _shellDir + "/quickshell/plugins/discover.sh"
        : _configHome + "/quickshell/plugins/discover.sh"
    readonly property string _placeTool: (_shellDir && _shellDir.length > 0)
        ? _shellDir + "/quickshell/plugins/ryoku-plugins-place"
        : "ryoku-plugins-place"

    function reload() {
        discoverProc.running = false;
        discoverProc.running = true;
    }

    function manifestHostsBar(p) {
        const hosts = p && p.manifest ? p.manifest.hosts : null;
        return Array.isArray(hosts) && hosts.indexOf("topbarGlyph") >= 0;
    }

    function entryFor(id) {
        return root.all.find(p => p && p.id === id) || null;
    }

    function name(id) {
        const p = root.entryFor(id);
        return p && p.manifest && p.manifest.name ? String(p.manifest.name) : String(id);
    }

    function isShown(id) {
        const p = root.entryFor(id);
        return !!p && root.manifestHostsBar(p) && !!p.placement
            && p.placement.enabled === true && p.placement.host === "topbarGlyph";
    }

    function hasPanel(id) {
        const p = root.entryFor(id);
        return !!(p && p.manifest && p.manifest.entryPoints && p.manifest.entryPoints.panel);
    }

    // manifest panel.width, clamped to the range docs/plugins.md promises
    function panelWidth(id) {
        const p = root.entryFor(id);
        const w = p && p.manifest && p.manifest.panel ? Number(p.manifest.panel.width) : NaN;
        return isFinite(w) ? Math.max(240, Math.min(520, Math.round(w))) : 320;
    }

    function stateDir(id) {
        return root._stateHome + "/ryoku/plugins/" + id;
    }

    // the placement tool is the only writer of plugins.json; one write at a
    // time, in order, so a host change lands before the enable that needs it
    property var _placeQueue: []
    function _place(args) {
        root._placeQueue.push([root._placeTool].concat(args));
        root._nextPlace();
    }
    function _nextPlace() {
        if (placeProc.running || root._placeQueue.length === 0) return;
        placeProc.command = root._placeQueue.shift();
        placeProc.running = true;
    }

    function saveSetting(id, key, value) {
        const obj = {};
        obj[String(key)] = value;
        root._place([id, "settings", JSON.stringify(obj)]);
    }

    function setShown(id, on) {
        if (on) root._place([id, "host", "topbarGlyph"]);
        root._place([id, "enabled", on ? "true" : "false"]);
    }

    // { [pluginId]: pluginApi } of the live glyphs, so a panel reads the same
    // service instance its glyph does
    property var apis: ({})

    function registerApi(id, api) {
        const next = Object.assign({}, root.apis);
        next[id] = api;
        root.apis = next;
    }

    function unregisterApi(id, api) {
        if (root.apis[id] !== api) return;
        const next = Object.assign({}, root.apis);
        delete next[id];
        root.apis = next;
    }

    Process {
        id: placeProc
        onExited: root._nextPlace()
    }

    Process {
        id: discoverProc
        command: ["bash", root._script, "--all"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let list = [];
                try { list = JSON.parse(this.text || "[]"); } catch (e) { list = []; }
                root.all = Array.isArray(list) ? list : [];
                root.loaded = true;
            }
        }
    }

    FileView {
        path: root._configHome + "/ryoku/plugins.json"
        watchChanges: true
        printErrors: false
        onFileChanged: root.reload()
    }

    // a Store install or remove bumps the revision
    FileView {
        path: root._stateHome + "/ryoku/store/revision.json"
        watchChanges: true
        atomicWrites: true
        printErrors: false
        onFileChanged: root.reload()
    }
}
