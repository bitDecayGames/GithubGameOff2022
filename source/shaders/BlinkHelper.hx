package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

// TODO Make different blink types
enum BlinkType {
	BLIP;
	HALF;
}

class BlinkHelper {
    public static function Blink(sprite:FlxSprite, ?blinkSpeed:Float = .1, ?blinkCount:Int = 3, ?blinkCallback:(blinkCount:Int) -> Void, ?existingShader:FlxShader) {
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
			if (blinkCount == realBlinkCount-1 && existingShader != null) {
				sprite.shader = existingShader;
			}
		}, realBlinkCount);
    }
}