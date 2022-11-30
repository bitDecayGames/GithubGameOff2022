package states.battles;

import flixel.util.FlxStringUtil;
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
	private static var heightAccuracyScalar = 0.25;
	private static var handHoverY = 175;

	var latch:FlxSprite;
	// the 'hinge' is 19px tall for the default image
	var openLatchOffset = 19;

	var fightOver = false;

	var handSwiping = false;
	var hand:FlxSprite;
	var handTween:FlxTween = null;
	var handTweenX:FlxTween = null;

	var handSwipeTimeToEdgeToEdge:Float = 1.0;

	// var dialog:CharacterDialog;
	var fightGroup:FlxGroup;

	var flashOverlay:FlxSprite;
	var isFinalBattle = false;
	var isEndingSequence = false;

	public function new(foe:CharacterDialog, ?finalBattle:Bool = false, ?endingSequence:Bool) {
		super();
		dialog = foe;
		isFinalBattle = finalBattle;
		isEndingSequence = endingSequence;
	}

	override function create() {
		super.create();

		if (isFinalBattle && !isEndingSequence) {
			FmodManager.PlaySong(FmodSongs.Lonk);
		} else if (!isFinalBattle) {
			new FlxTimer().start(1.75, (t) -> {
				FmodManager.PlaySong(FmodSongs.Battle);
			});
		}

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
		switch dialog.characterIndex {
			case LONK:
				latch.loadGraphic(AssetPaths.uppercut__png, true, 30, 30);
				latch.animation.add('closed', [0]);
				latch.animation.add('open', [1,2], 5);
				openLatchOffset = 0;
			default:
				latch.loadGraphic(AssetPaths.chestLatch__png, true, 75, 100);
				latch.animation.add('closed', [0]);
				latch.animation.add('open', [1]);
		}
		latch.animation.play('closed');
		latch.scrollFactor.set();
		latch.screenCenter();
		latch.y = 50;
		latch.setSize(30, 30);
		latch.centerOffsets(true);

		hand = new FlxSprite();
		hand.scrollFactor.set();
		hand.loadRotatedGraphic(AssetPaths.crappyHand__png, 4);
		hand.angle = 90;
		hand.screenCenter(X);
		hand.x += hand.width/4;
		hand.y = handHoverY;

		if (dialog.characterIndex == LONK) {
			hand.setSize(30, 30);
			hand.centerOffsets();
		}

		// make sure hand is over the latch
		fightGroup.add(latch);
		fightGroup.add(hand);

		fightGroup.add(flashOverlay);

		battleGroup.add(fightGroup);
		battleGroup.add(dialog);

		if (FlxStringUtil.isNullOrEmpty(dialog.textGroup.rawText)) {
			begin();
		} else {
			dialog.textGroup.finishCallback = () -> {
				begin();
			};
		}
	}

	function begin() {
		dialog.kill();
		new FlxTimer().start(.05, (t) -> {
			acceptInput = true;
		});

		// TODO: move speed? Do we want random? Do we want pauses?
		// start by moving over to the side
		if (!isEndingSequence){
			handTweenX = FlxTween.tween(hand, {x: FlxG.width - hand.width}, handSwipeTimeToEdgeToEdge / 2, {
				ease: FlxEase.sineOut,
				onComplete: (t) -> {
					// then just slide back and forth
					handTweenX = FlxTween.tween(hand, {x: 0}, handSwipeTimeToEdgeToEdge, {
						type: FlxTweenType.PINGPONG,
						ease: FlxEase.sineInOut,
					});
				}
			});
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		#if encounter_debug
		var handMid = hand.getMidpoint();
		DebugDraw.ME.drawCameraLine(handMid.x - requiredAccuracyPixels, hand.y, handMid.x + requiredAccuracyPixels, hand.y);
		var latchMid = latch.getMidpoint();
		DebugDraw.ME.drawCameraLine(latchMid.x, latchMid.y - 10, latchMid.x, latchMid.y + 10);
		#end

		if (!acceptInput) {
			return;
		}

		if (!handSwiping) {
			if (SimpleController.just_pressed(A)) {
				if (!isEndingSequence) {
					FmodManager.PlaySoundOneShot(FmodSFX.AlarmSwing);
				}
				startSwipe();
			}
		}

		if (!FlxMath.inBounds(hand.x, 0, FlxG.width - hand.width)) {
			hand.velocity.x = 0;
			hand.x = FlxMath.bound(hand.x, 0, FlxG.width - hand.width);
		}


		if (hand.overlaps(latch)) {
			if (Math.abs(latch.getMidpoint().x - hand.getMidpoint().x) > requiredAccuracyPixels) {
				return;
			}
			if (Math.abs(hand.y - (latch.y + latch.height)) > requiredAccuracyPixels * heightAccuracyScalar) {
				return;
			}
			fightOver = true;

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
			if (!isEndingSequence) {
				FmodManager.PlaySoundOneShot(FmodSFX.ChestBattleOpenInitialImpact);
				FlxG.camera.shake(0.01, 0.25);
			}
			new FlxTimer().start(0.50, (t) -> {
				FlxTween.tween(flashOverlay, {alpha: 1}, 0.25);
				if(!isFinalBattle){
					FmodManager.PlaySoundOneShot(FmodSFX.ChestBattleOpen4);
				} else if (isEndingSequence){
					GlobalQuestState.currentQuest = Enum_QuestName.Final_morning;
					FlxG.switchState(new PlayState('House_Lonk_room_boy'));
				} else {
					FmodManager.PlaySoundOneShot(FmodSFX.AlarmClockHit);
				}
				FmodManager.SetEventParameterOnSong("ChestLowPass", 1);
				FlxTween.tween(hand, {y: latch.y}, 0.75, {
					ease: FlxEase.quartIn,
					onComplete: (t) -> {
						latch.animation.play('open');
						latch.y -= latch.frameHeight - openLatchOffset;

						FlxTween.tween(flashOverlay, {alpha: 0}, 1);
						FlxTween.tween(hand, {y: -hand.height-10}, 0.75);
						success = true;
						dialog.revive();
						switch dialog.characterIndex {
							case LONK:
								dialog.loadDialogLine("This<pause/> isn't<pause/> possible<slower>...</slower>");
							default:
								dialog.loadDialogLine("UUGUGHHHHH");
						}
						dialog.textGroup.finishCallback = () -> {
							dialog.kill();
							FmodManager.SetEventParameterOnSong("ChestLowPass", 0);
							new FlxTimer().start(1, (t) -> {
								transitionOut();
							});
						};
					}
				});
			});
		}
	}

	function startSwipe() {
		if (!isEndingSequence){
			handSwiping = true;
			handTween = FlxTween.tween(hand, {y: -hand.height-10}, 0.3, {
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
		} else {
			handSwiping = true;
			handTween = FlxTween.tween(hand, {y: latch.y+latch.height-1}, 2, {
				ease: FlxEase.quintIn
			});

			new FlxTimer().start(1.5, (t) -> {
				FlxTween.tween(flashOverlay, {alpha: 1}, 0.475, {
					ease: FlxEase.quadIn
				});
			});
		}
	}

	function checkSuccess():Bool {
		return false;
	}
}