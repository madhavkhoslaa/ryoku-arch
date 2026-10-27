pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import inir.services
import inir.modules.common
import inir.modules.common.widgets
import inir.modules.iris.style

// One value from a short list, as a button that names the current pick and opens the list under itself. Options
// are { value, label, glyph }; `picked` reports the value tapped and the caller writes it.
Item {
    id: root
    property var options: []
    property string value: ""
    signal picked(string value)

    readonly property real d: IrisStyle.density
    readonly property var current: root.options.find(option => option.value === root.value) ?? root.options[0] ?? null

    implicitWidth: Math.max(Math.round(170 * root.d), button.implicitWidth)
    implicitHeight: button.implicitHeight

    IrisButton {
        id: button
        anchors.fill: parent
        implicitHeight: Math.round(34 * root.d)
        implicitWidth: row.implicitWidth + Math.round(24 * root.d)
        buttonRadius: IrisStyle.radiusRow
        selected: menu.opened
        Accessible.role: Accessible.ComboBox
        Accessible.name: root.current ? Translation.tr(root.current.label) : ""
        onClicked: menu.opened ? menu.close() : menu.open()

        RowLayout {
            id: row
            anchors.fill: parent
            anchors.leftMargin: Math.round(12 * root.d)
            anchors.rightMargin: Math.round(8 * root.d)
            spacing: Math.round(8 * root.d)
            MaterialSymbol {
                visible: String(root.current?.glyph ?? "").length > 0
                text: String(root.current?.glyph ?? "")
                iconSize: Math.round(16 * root.d)
                fill: 1
                color: IrisStyle.text
            }
            IrisText {
                Layout.fillWidth: true
                text: root.current ? Translation.tr(root.current.label) : ""
                elide: Text.ElideRight
                font.pixelSize: IrisStyle.typeLabel
                font.weight: IrisStyle.weight(Font.Medium)
            }
            MaterialSymbol {
                text: menu.opened ? "expand_less" : "expand_more"
                iconSize: Math.round(18 * root.d)
                color: IrisStyle.muted
            }
        }
    }

    Popup {
        id: menu
        y: root.height + Math.round(4 * root.d)
        width: root.width
        padding: Math.round(4 * root.d)
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        background: Rectangle {
            radius: IrisStyle.radiusCard
            color: IrisStyle.bodySurface
            border.width: 1
            border.color: IrisStyle.hairline
        }
        contentItem: Column {
            spacing: Math.round(2 * root.d)
            Repeater {
                model: root.options
                delegate: MouseArea {
                    id: option
                    required property var modelData
                    readonly property bool chosen: option.modelData.value === root.value
                    width: menu.availableWidth
                    height: Math.round(32 * root.d)
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    Accessible.role: Accessible.MenuItem
                    Accessible.name: Translation.tr(option.modelData.label)
                    onClicked: {
                        menu.close()
                        if (!option.chosen) root.picked(option.modelData.value)
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: IrisStyle.radiusRow
                        color: option.containsMouse ? IrisStyle.fillHover : option.chosen ? IrisStyle.fillQuiet : "transparent"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Math.round(10 * root.d)
                        anchors.rightMargin: Math.round(10 * root.d)
                        spacing: Math.round(8 * root.d)
                        MaterialSymbol {
                            visible: String(option.modelData.glyph ?? "").length > 0
                            text: String(option.modelData.glyph ?? "")
                            iconSize: Math.round(16 * root.d)
                            fill: 1
                            color: option.chosen ? IrisStyle.accent : IrisStyle.text
                        }
                        IrisText {
                            Layout.fillWidth: true
                            text: Translation.tr(option.modelData.label)
                            elide: Text.ElideRight
                            font.pixelSize: IrisStyle.typeLabel
                            font.weight: option.chosen ? IrisStyle.weight(Font.DemiBold) : IrisStyle.weight(Font.Normal)
                        }
                        MaterialSymbol {
                            visible: option.chosen
                            text: "check"
                            iconSize: Math.round(16 * root.d)
                            color: IrisStyle.accent
                        }
                    }
                }
            }
        }
    }
}
