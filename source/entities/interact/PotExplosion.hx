package entities.interact;

import flixel.FlxSprite;

class PotExplosion extends FlxSprite {
	public function new(X:Float, Y:Float) {
		super(X-8, Y-24);
		loadGraphic(AssetPaths.explosion__png, true, 32, 48);
		animation.add('explode', [ for (i in 0...9) i], 10, false);
        animation.finishCallback = (n) -> {
            kill();
        }
        animation.play('explode');
        FmodManager.PlaySoundOneShot(FmodSFX.PotExplode);
	}
}