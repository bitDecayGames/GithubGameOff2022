package entities.particles;

import flixel.FlxSprite;

class ItemParticle extends FlxSprite {
	public function new(X:Float, Y:Float, item:ItemIndex) {
		super(X - 8, Y - 8);
		loadGraphic(AssetPaths.items__png, true, 16, 16);
		animation.frameIndex = item;
	}
}