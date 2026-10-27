pragma Singleton
import QtQuick
import Quickshell

// The bar style hosting plugins on its own surface (Shima's Island) sets these
// while it is the live bar, so a plugin's glyph and panel take that style's
// corners, faces and ink through Theme. An unset value (empty, transparent or
// -1) leaves Theme's own default. Only a host writes here; a plugin reads Theme,
// and `ryoku plugin validate` blocks plugin code that names HostTheme (R4).
Singleton {
    property int radius: -1
    property string font: ""
    property string display: ""
    property color accent: "transparent"
    property color bright: "transparent"
    property color dim: "transparent"
    property color border: "transparent"
    property color hair: "transparent"
    property color tileBg: "transparent"

    function pick(value, fallback) { return value.a > 0 ? value : fallback }
}
