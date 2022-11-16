package ui.font;

import com.bitdecay.lucidtext.effect.builtin.Color;

enum abstract TextColors(String) to String from String {
	var KEY_ITEM = "keyItem";
	var HINT = "hint";

	public static function init() {
		Color.registerColor(KEY_ITEM, 0x5555AA);
		Color.registerColor(HINT, 0x337755);
	}
}