package misc;

import flixel.text.FlxBitmapText;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * A factory to help create FlxText objects in a consistent mannor
 */
class FlxTextFactory {
	/**
	 * Default size for anything this factory creates
	 */
	public static var defaultSize:Int = 8;

	/**
	 * Default font for anything this factory creates
	 */
	public static var defaultFont:String = FlxAssets.FONT_DEFAULT;

	/**
	 * Default color for anything this factory creates
	 */
	public static var defaultColor:Int = FlxColor.WHITE;

	/**
	 * Default alignment for anything this factory creates
	 */
	public static var defaultAlign:FlxTextAlign = FlxTextAlign.LEFT;

	/**
	 * Creats a FlxText object with the project defaults
	 *
	 * @param text  The text to display
	 * @param x     The X position of the new FlxText
	 * @param y     The Y position of the new FlxText
	 * @param size  `Optional` The font size if something other than default is desired
	 * @param align `Optional` The font alignment
	**/
	public static function make(text:String, ?x:Float, ?y:Float, ?size:Int, ?align:Null<FlxTextAlign>, ?color:Int):FlxBitmapText {
		var txt = new FlxBitmapText();
		txt.text = text;
		txt.setPosition(x, y);

		if (align != null) {
			txt.alignment = align;
		}

		if (size > 0) {
			var scale = 1.0 * size / txt.height;
			txt.scale.set(scale, scale);
		}
		txt.updateHitbox();

		// txt.setFormat(defaultFont, size == null ? defaultSize : size, color == null ? defaultColor : color, align == null ? defaultAlign : align);
		return txt;
	}
}
