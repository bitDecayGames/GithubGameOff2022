package shaders;

import flixel.util.FlxTimer;
import flixel.FlxSprite;

// TODO Make different blink types
enum BlinkType {
	BLIP;
	HALF;
}

class BlinkHelper {
    public static function Blink(sprite:FlxSprite, ?blinkSpeed:Float = .1, ?blinkCount:Int = 3, ?blinkCallback:(blinkCount:Int) -> Void) {
        var realBlinkSpeed = blinkSpeed/2;
        var realBlinkCount = blinkCount*2;
		var blinkShader = new Whiten();
		var isShaderActive:Bool = false;
		blinkShader.isShaderActive.value = [isShaderActive];
		sprite.shader = blinkShader;

		var blinkCount = 0;
		new FlxTimer().start(realBlinkSpeed, (t) -> {
			isShaderActive = !isShaderActive;
			if(isShaderActive){
				blinkCount++;
				if (blinkCallback != null){
					blinkCallback(blinkCount);
				}
			}
			blinkShader.isShaderActive.value = [isShaderActive];
		}, realBlinkCount);
    }
}