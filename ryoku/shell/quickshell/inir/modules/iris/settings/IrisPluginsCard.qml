pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import inir.services
import inir.modules.common
import inir.modules.common.widgets
import inir.modules.iris.components
import inir.modules.iris.pieces
import inir.modules.iris.style
import shell.services as Ryoku

// Settings › Plugins: every installed Ryoku bar plugin (manifest host topbarGlyph) and where Shima shows it, picked
// from one dropdown: off, the Island as a piece that opens its panel as a card, the Island's home page, Control
// Center, or a side panel. Placing one turns it on for the bar host if it was off. Its own settings stay in Ryoku
// Hub › Add-ons. Official plugins (manifest "official": true) come first, under Plugins; the rest sit under
// Community plugins.
ColumnLayout {
    id: card

    readonly property real d: IrisStyle.density
    readonly property var plugins: Ryoku.GlyphPlugins.barCapable
    // the same split QS Bar Settings makes: a manifest marked "official": true is the team's
    function official(p: var): bool { return p?.manifest?.official === true }
    readonly property var groups: [
        { title: "Plugins", list: card.plugins.filter(p => card.official(p)) },
        { title: "Community plugins", list: card.plugins.filter(p => !card.official(p)) }
    ].filter(group => group.list.length > 0)
    readonly property var places: [
        { value: "bar", label: "Island", glyph: "pill", panel: false },
        { value: "home", label: "Home page", glyph: "home", panel: true },
        { value: "controls", label: "Control Center", glyph: "toggle_on", panel: true },
        { value: "left", label: "Left panel", glyph: "dock_to_left", panel: true },
        { value: "right", label: "Right panel", glyph: "dock_to_right", panel: true }
    ]

    Layout.fillWidth: true
    spacing: 8 * card.d

    function enable(pluginId: string, on: bool): void {
        if (on && !Ryoku.GlyphPlugins.isShown(pluginId)) Ryoku.GlyphPlugins.setShown(pluginId, true)
        IrisPieces.setPluginEnabled(pluginId, on)
    }

    Rectangle {
        Layout.fillWidth: true
        visible: Ryoku.GlyphPlugins.loaded && card.plugins.length === 0
        implicitHeight: Math.round(84 * card.d)
        radius: IrisStyle.radiusTile
        color: IrisStyle.readingCard
        IrisText {
            anchors.fill: parent
            anchors.margins: 18 * card.d
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            text: Translation.tr("No bar plugins installed. Any plugin made for the bar can ride the Island; find them in Ryostore.")
            color: IrisStyle.muted
            font.pixelSize: IrisStyle.typeLabel
        }
    }

    Repeater {
        model: card.groups
        delegate: ColumnLayout {
            id: group
            required property var modelData
            required property int index
            Layout.fillWidth: true
            Layout.topMargin: group.index > 0 ? 10 * card.d : 0
            spacing: 8 * card.d

            IrisText {
                Layout.fillWidth: true
                Layout.leftMargin: 4 * card.d
                text: Translation.tr(group.modelData.title)
                color: IrisStyle.muted
                font.pixelSize: IrisStyle.typeMeta
                font.weight: IrisStyle.weight(Font.DemiBold)
            }

            Repeater {
                model: group.modelData.list
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    readonly property string pluginId: String(row.modelData.id)
                    readonly property bool shown: Ryoku.GlyphPlugins.isShown(row.pluginId)
                    readonly property bool hasPanel: Ryoku.GlyphPlugins.hasPanel(row.pluginId)
                    readonly property string where: {
                        void Config.revision
                        return IrisPieces.pluginPlace(row.pluginId)
                    }
                    readonly property bool enabled: {
                        void Config.revision
                        return IrisPieces.pluginEnabled(row.pluginId)
                    }
                    readonly property bool placed: row.enabled
                    // a place that shows the panel needs a plugin that ships one
                    readonly property var positions: card.places.filter(p => !p.panel || row.hasPanel)
                    readonly property var position: row.positions.find(p => p.value === row.where) ?? row.positions[0]
                    property bool open: false

                    Layout.fillWidth: true
                    implicitHeight: rowColumn.implicitHeight + 28 * card.d
                    radius: IrisStyle.radiusTile
                    color: row.placed && row.shown ? IrisStyle.tintFill(IrisStyle.identity.sky) : IrisStyle.readingCard
                    clip: true
                    Behavior on color { ColorAnimation { duration: IrisStyle.duration(220); easing.type: IrisStyle.feedbackEasing } }
                    Behavior on implicitHeight { NumberAnimation { duration: IrisStyle.morphDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: IrisStyle.morphCurve } }

                    ColumnLayout {
                        id: rowColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14 * card.d
                        anchors.leftMargin: 18 * card.d
                        anchors.rightMargin: 18 * card.d
                        spacing: 12 * card.d

                        // the header: tap it to show or hide this plugin's settings
                        MouseArea {
                            Layout.fillWidth: true
                            implicitHeight: header.implicitHeight
                            cursorShape: Qt.PointingHandCursor
                            Accessible.role: Accessible.Button
                            Accessible.name: String(row.modelData.manifest?.name ?? row.pluginId)
                            onClicked: row.open = !row.open

                            RowLayout {
                                id: header
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 14 * card.d
                                IrisSquircle {
                                    implicitWidth: Math.round(26 * card.d)
                                    implicitHeight: implicitWidth
                                    tint: IrisStyle.identity.sky
                                    glyph: "extension"
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2 * card.d
                                    IrisText {
                                        Layout.fillWidth: true
                                        text: String(row.modelData.manifest?.name ?? row.pluginId)
                                        elide: Text.ElideRight
                                        font.pixelSize: IrisStyle.typeLabel
                                        font.weight: IrisStyle.weight(row.open ? Font.DemiBold : Font.Medium)
                                    }
                                    IrisText {
                                        Layout.fillWidth: true
                                        text: row.placed && !row.shown ? Translation.tr("Placed, but turned off in Add-ons")
                                            : String(row.modelData.manifest?.description ?? "")
                                        elide: Text.ElideRight
                                        color: IrisStyle.muted
                                        font.pixelSize: IrisStyle.typeMeta
                                    }
                                }
                                IrisSwitch {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: Translation.tr("Show %1").arg(String(row.modelData.manifest?.name ?? row.pluginId))
                                    on: row.enabled && row.shown
                                    onToggled: card.enable(row.pluginId, !(row.enabled && row.shown))
                                }
                            }
                        }

                        // this plugin's settings; position for now, more to come
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: row.open
                            spacing: 10 * card.d

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 1
                                color: IrisStyle.hairline
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14 * card.d
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2 * card.d
                                    IrisText {
                                        Layout.fillWidth: true
                                        text: Translation.tr("Position")
                                        font.pixelSize: IrisStyle.typeLabel
                                        font.weight: IrisStyle.weight(Font.Medium)
                                    }
                                    IrisText {
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        text: row.hasPanel
                                            ? Translation.tr("On the Island it opens its panel as a card; anywhere else its panel sits in place.")
                                            : Translation.tr("It has no panel, so it can only ride the Island.")
                                        color: IrisStyle.muted
                                        font.pixelSize: IrisStyle.typeMeta
                                    }
                                }
                                IrisDropdown {
                                    Layout.alignment: Qt.AlignVCenter
                                    options: row.positions
                                    value: row.position ? row.position.value : "off"
                                    onPicked: value => IrisPieces.setPluginPlace(row.pluginId, value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
