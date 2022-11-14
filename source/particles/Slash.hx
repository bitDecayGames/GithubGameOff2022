package particles;

import flixel.FlxSprite;

class Slash extends FlxSprite {
	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic(AssetPaths.slash_particle__png, true, 16, 16);
		animation.add('slash', [0,1,2,3,4], 20, false);
		animation.play('slash');
	}
}