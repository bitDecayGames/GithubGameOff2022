package shaders;

import flixel.util.FlxTimer;
import flixel.FlxSprite;

// TODO Make different blink types
enum BlinkType {
	BLIP;
	HALF;
}

class BlinkHelper {
    public static function Blink(sprite:FlxSprite, ?blinkSpeed:Float = .1, ?blinkCount:Int = 3) {
        var realBlinkSpeed = blinkSpeed/2;
        var realBlinkCount = blinkCount*2;
		var blinkShader = new Whiten();
		var isShaderActive:Bool = false;
		blinkShader.isShaderActive.value = [isShaderActive];
		sprite.shader = blinkShader;

		new FlxTimer().start(realBlinkSpeed, (t) -> {
			isShaderActive = !isShaderActive;
			blinkShader.isShaderActive.value = [isShaderActive];
		}, realBlinkCount);
    }
}