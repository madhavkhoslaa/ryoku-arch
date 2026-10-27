import QtQuick
import Ryoku.PluginKit.Singletons as Kit

// While Shima is the live bar, a Ryoku plugin draws with Shima's shape and type: its glyph on the Island and its
// panel in a card take the same corners, faces, ink and hairlines as every other piece and card, through the kit's
// HostTheme. Every other bar style leaves it unset, and each Binding restores it when Shima goes away.
QtObject {
    id: root

    property list<QtObject> bindings: [
        Binding { target: Kit.HostTheme; property: "radius"; value: IrisStyle.radiusRow },
        Binding { target: Kit.HostTheme; property: "font"; value: IrisStyle.fontMain },
        Binding { target: Kit.HostTheme; property: "display"; value: IrisStyle.fontTitle },
        Binding { target: Kit.HostTheme; property: "accent"; value: IrisStyle.accent },
        Binding { target: Kit.HostTheme; property: "bright"; value: IrisStyle.text },
        Binding { target: Kit.HostTheme; property: "dim"; value: IrisStyle.muted },
        Binding { target: Kit.HostTheme; property: "border"; value: IrisStyle.hairline },
        Binding { target: Kit.HostTheme; property: "hair"; value: IrisStyle.hairline },
        Binding { target: Kit.HostTheme; property: "tileBg"; value: IrisStyle.fillQuiet }
    ]
}
