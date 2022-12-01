package states;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import entities.npcs.Lonk;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSubState;

class FinalTransition extends FlxSubState {
	var transition:FlxSprite;
	var bgImg:FlxSprite;

	var lonk:Lonk;
	var eyes:FlxSprite;

	public function new(lonk:Lonk) {
		super();
		this.lonk = lonk;
	}

	override function create() {
		super.create();

		var bgImg = new FlxSprite();
		bgImg.makeGraphic(1,1, FlxColor.BLACK);
		bgImg.scrollFactor.set();
		// oversize this a bit to allow for camera shake without artifacts at the edges
		bgImg.scale.set(FlxG.width * 1.25, FlxG.height * 1.25);
		bgImg.updateHitbox();
		bgImg.screenCenter();

		transition = new FlxSprite();
		transition.makeGraphic(1,1, FlxColor.BLACK);
		transition.alpha = 0;
		transition.scrollFactor.set();
		transition.scale.set(FlxG.width, FlxG.height);
		transition.updateHitbox();
		transition.screenCenter();
		add(transition);

		eyes = new FlxSprite();
		eyes.loadGraphic(AssetPaths.red_eyes__png, true, 26, 34);
		eyes.setSize(16, 16);
		eyes.offset.set(5, 17);

		eyes.animation.frameIndex = 0;
		eyes.setPosition(lonk.x, lonk.y - 1);
		eyes.alpha = 0;

		FlxTween.tween(eyes, {y: eyes.y + 2}, 0.5, {
			type: FlxTweenType.PINGPONG,
			ease: FlxEase.sineInOut,
		});

		add(eyes);

		transitionIn();
	}

	// gives us access to the camera's internal filter list so we can restore it later
	@:access(flixel.FlxCamera)
	public function transitionIn() {
		var duration = 1.0;

		new FlxTimer().start(.75, (t) -> {
			FlxTween.tween(transition, { alpha: 1 }, duration, {
				onComplete: (t) -> {
					FmodManager.PlaySoundOneShot(FmodSFX.LonkFinalCutaway);
					new FlxTimer().start(4, (t) -> {
						// TODO: Play eye animation for anime-esque disappearance, then when done, go to credits
						FlxTween.tween(eyes, { alpha: 0 }, 0.1, {
							onComplete: (t) -> {
								FlxG.switchState(new CreditsState());
							}
						});
					});
				}
			});

			FlxTween.tween(eyes, { alpha: 1 }, duration * 3, {
				onComplete: (t) -> {
					// FlxTween.tween(eyes, {y: eyes.y + 2}, 0.5, {
					// 	type: FlxTweenType.PINGPONG,
					// 	ease: FlxEase.sineInOut,
					// });
				}
			});

			FmodManager.PlaySoundOneShot(FmodSFX.PotRingSpawn);
		});

		new FlxTimer().start(0, (t) -> {
			lonk.animation.play('becomeEvil');
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		lonk.update(elapsed);
	}
}