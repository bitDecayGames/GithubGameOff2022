package states.battles;

import flixel.FlxBasic.FlxType;
import com.bitdecay.lucidtext.parse.TagLocation;
import quest.GlobalQuestState;
import flixel.math.FlxMath;
import encounters.CharacterIndex;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

#if encounter_debug
import bitdecay.flixel.debug.DebugDraw;
#end

import encounters.CharacterDialog;
import input.SimpleController;

using zero.flixel.extensions.FlxPointExt;

class ChestBattle extends EncounterBaseState {
	// midpoints can only be this far apart and still count as hitting the latch
	private static var requiredAccuracyPixels = 20;
	private static var handHoverY = 175;

	var latch:FlxSprite;

	var fightOver = false;

	var handSwiping = false;
	var hand:FlxSprite;
	var handTween:FlxTween = null;
	var handTweenX:FlxTween = null;

	// var dialog:CharacterDialog;
	var fightGroup:FlxGroup;

	var flashOverlay:FlxSprite;

	override function create() {
		super.create();

		dialog = new CharacterDialog(CharacterIndex.NONE, "A loosely latched chest sits before you.");
		FmodManager.PlaySong(FmodSongs.Battle);

		fightGroup = new FlxGroup();

		flashOverlay = new FlxSprite();
		flashOverlay.makeGraphic(1, 1, FlxColor.WHITE);
		flashOverlay.scrollFactor.set();
		// oversize this a bit to allow for camera shake without artifacts at the edges
		flashOverlay.scale.set(FlxG.width * 1.25, FlxG.height * 1.25);
		flashOverlay.updateHitbox();
		flashOverlay.screenCenter();
		flashOverlay.alpha = 0;

		latch = new FlxSprite();
		latch.scrollFactor.set();
		latch.makeGraphic(75, 100, FlxColor.GREEN);
		// latch.loadGraphic(AssetPaths.latchLarge__png, true, 30, 30);
		// latch.animation.add('blink', [0,1], 2);
		// latch.animation.play('blink');
		latch.screenCenter();
		latch.y = 50;
		latch.setSize(30, 30);
		latch.centerOffsets(true);

		hand = new FlxSprite();
		hand.scrollFactor.set();
		hand.loadRotatedGraphic(AssetPaths.crappyHand__png, 4);
		hand.angle = 90;
		hand.screenCenter(X);
		hand.y = handHoverY;

		// make sure hand is over the latch
		fightGroup.add(latch);
		fightGroup.add(hand);

		fightGroup.add(flashOverlay);

		battleGroup.add(fightGroup);
		battleGroup.add(dialog);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();

			new FlxTimer().start(.05, (t) -> {
				acceptInput = true;
			});

			// TODO: move speed? Do we want random? Do we want pauses?
			// start by moving over to the side
			handTweenX = FlxTween.tween(hand, {x: FlxG.width - hand.width}, 0.5, {
				ease: FlxEase.sineOut,
				onComplete: (t) -> {
					// then just slide back and forth
					handTweenX = FlxTween.tween(hand, {x: 0}, {
						type: FlxTweenType.PINGPONG,
						ease: FlxEase.sineInOut,
					});
				}
			});
		};
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		#if encounter_debug
		var handMid = hand.getMidpoint();
		DebugDraw.ME.drawCameraLine(handMid.x - requiredAccuracyPixels, hand.y + hand.height, handMid.x + requiredAccuracyPixels, hand.y + hand.height);
		var latchMid = latch.getMidpoint();
		DebugDraw.ME.drawCameraLine(latchMid.x, latchMid.y - 10, latchMid.x, latchMid.y + 10);
		#end

		if (!acceptInput) {
			return;
		}

		if (!handSwiping) {
			if (SimpleController.just_pressed(A)) {
				FmodManager.PlaySoundOneShot(FmodSFX.AlarmSwing);
				startSwipe();
			}
		}

		if (!FlxMath.inBounds(hand.x, 0, FlxG.width - hand.width)) {
			hand.velocity.x = 0;
			hand.x = FlxMath.bound(hand.x, 0, FlxG.width - hand.width);
		}


		if (hand.overlaps(latch) && Math.abs(latch.getMidpoint().x - hand.getMidpoint().x) <= requiredAccuracyPixels) {
			fightOver = true;
			// camera.flash(FlxColor.WHITE, 0.5);

		// 	new FlxTimer().start(2, (t) -> {
		// 		FmodManager.StopSong();
		// 	});

		// 	new FlxTimer().start(.1, (t) -> {
		// 		FmodManager.PlaySoundOneShot(FmodSFX.AlarmBreak);
		// 	});

			acceptInput = false;
			if (handTween != null) {
				if (!handTween.finished) {
					handTween.cancel();
				}
				handTween = null;
			}
			if (handTweenX != null) {
				if (!handTweenX.finished) {
					handTweenX.cancel();
				}
				handTweenX = null;
			}

			hand.y = latch.y + latch.height;
			FlxTween.tween(flashOverlay, {alpha: 1}, 0.75);
			FlxTween.tween(hand, {y: latch.y}, 0.75, {
				ease: FlxEase.quartIn,
				onComplete: (t) -> {
					FlxTween.tween(flashOverlay, {alpha: 0}, 1);
					FlxTween.tween(hand, {y: -hand.height}, 0.75);
					success = true;
					dialog.revive();
					dialog.loadDialogLine("The latch flies open.");
					dialog.textGroup.finishCallback = () -> {
						dialog.kill();

						new FlxTimer().start(1, (t) -> {
							transitionOut();
						});
					};
				}
			});
		}
	}

	function startSwipe() {
		handSwiping = true;
		handTween = FlxTween.tween(hand, {y: -hand.height}, 0.3, {
			ease: FlxEase.cubeIn,
			onComplete: (t) -> {
				new FlxTimer().start(0.3, (t) -> {
					hand.y = FlxG.height;
					handTween = FlxTween.tween(hand, {y: handHoverY}, 0.3, {
						ease: FlxEase.sineOut,
						onComplete: (t) -> {
							handSwiping = false;
						}
					});
				});
			}
		});
	}

	function checkSuccess():Bool {
		return false;
	}
}