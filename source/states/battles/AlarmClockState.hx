package states.battles;

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

class AlarmClockState extends EncounterBaseState {
	// midpoints can only be this far apart and still count as hitting the clock
	private static var requiredAccuracyPixels = 21;
	private static var restSeconds = 0.655;
	private static var finishYOffset = 11;
	private static var handHoverY = 30;
	private static var handXAccel = 80;

	var clockMoveTimeMin = 0.2;
	var clockMoveTimeMax = 0.65;
	var moveTimeModifier = 1.0;

	var playerMoved:Bool = false;

	var helperArrowLeft:FlxSprite;
	var helperArrowRight:FlxSprite;

	var clock:FlxSprite;
	var clockTween:FlxTween = null;
	var clockTweenCount = 0;
	var restModifier = 0.0;

	var fightOver = false;

	var firstSwipe = true;
	var secondSwipe = false;
	var handSwiping = false;
	var hand:FlxSprite;
	var handTween:FlxTween = null;

	// var dialog:CharacterDialog;
	var fightGroup:FlxGroup;
	var finalBattle = false;

	public function new(foe:CharacterDialog, ?finalBattle:Bool = false) {
		super();
		dialog = foe;
		this.finalBattle = finalBattle;
	}

	override function create() {
		super.create();

		if (finalBattle) {
			FmodManager.PlaySong(FmodSongs.Lonk);
			firstSwipe = false;
			secondSwipe = false;
		} else {
			new FlxTimer().start(1.75, (t) -> {
				FmodManager.PlaySong(FmodSongs.BattleWithAlarm);
			});
		}

		fightGroup = new FlxGroup();

		clock = new FlxSprite();
		clock.scrollFactor.set();
		switch dialog.characterIndex {
			case LONK:
				clock.loadGraphic(AssetPaths.headsmash__png, true, 30, 30);
				restSeconds *= 0.66;
				moveTimeModifier *= .75;
			default:
				clock.loadGraphic(AssetPaths.clockLarge__png, true, 30, 30);
		}
		clock.animation.add('blink', [0,1], 2);
		clock.animation.add('broken', [2]);
		clock.animation.play('blink');
		clock.screenCenter();
		if (finalBattle) {
			startClockTween(false, true);
		}


		hand = new FlxSprite();
		hand.scrollFactor.set();
		hand.loadGraphic(AssetPaths.crappyHand__png);
		hand.screenCenter(X);
		hand.y = handHoverY;

		helperArrowLeft = new FlxSprite(hand.x-60, hand.y-58);
		helperArrowLeft.angle = 90;
		helperArrowLeft.loadGraphic(AssetPaths.arrow_pointing__png, true, 16, 48);
		helperArrowLeft.animation.add("default", [0,1,2,3,4,5,6,7,8,9], 10);
		helperArrowLeft.animation.play("default");
		helperArrowLeft.visible = false;

		helperArrowRight = new FlxSprite(hand.x+15, hand.y-58);
		helperArrowRight.angle = 270;
		helperArrowRight.loadGraphic(AssetPaths.arrow_pointing__png, true, 16, 48);
		helperArrowRight.animation.add("default", [0,1,2,3,4,5,6,7,8,9], 10);
		helperArrowRight.animation.play("default");
		helperArrowRight.visible = false;

		// make sure hand is over the clock
		fightGroup.add(clock);
		fightGroup.add(hand);
		
		if (!finalBattle) {
			fightGroup.add(helperArrowLeft);
			fightGroup.add(helperArrowRight);
		}

		battleGroup.add(fightGroup);
		battleGroup.add(dialog);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();

			new FlxTimer().start(.05, (t) -> {
				acceptInput = true;
			});
		};

		dialog.textGroup.tagCallback = handleTagCallback;
	}

	function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialog.setExpression(tag.parsedOptions.val);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		#if encounter_debug
		var handMid = hand.getMidpoint();
		DebugDraw.ME.drawCameraLine(handMid.x - requiredAccuracyPixels, hand.y + hand.height, handMid.x + requiredAccuracyPixels, hand.y + hand.height);
		var clockMid = clock.getMidpoint();
		DebugDraw.ME.drawCameraLine(clockMid.x, clockMid.y - 10, clockMid.x, clockMid.y + 10);
		#end

		if (!acceptInput) {
			return;
		}

		if (!handSwiping) {
			if (SimpleController.just_pressed(A)) {
				FmodManager.PlaySoundOneShot(FmodSFX.AlarmSwing);
				startSwipe();
			} else if (SimpleController.pressed(LEFT) && !firstSwipe) {
				playerMoved = true;
				hand.velocity.x -= handXAccel * elapsed;
			} else if (SimpleController.pressed(RIGHT) && !firstSwipe) {
				playerMoved = true;
				hand.velocity.x += handXAccel * elapsed;
			} else {
				hand.velocity.x *= 0.95;
			}
		}

		if (playerMoved && helperArrowLeft.alive) {
			helperArrowLeft.kill();
			helperArrowRight.kill();
		}

		if (!FlxMath.inBounds(hand.x, 0, FlxG.width - hand.width)) {
			hand.velocity.x = 0;
			hand.x = FlxMath.bound(hand.x, 0, FlxG.width - hand.width);
		}


		if (hand.overlaps(clock) && Math.abs(clock.getMidpoint().x - hand.getMidpoint().x) <= requiredAccuracyPixels) {
			// only count if they hand hits the top of the clock
			fightOver = true;
			hand.y = clock.y - hand.height + finishYOffset;
			FmodManager.SetEventParameterOnSong("AlarmOff", 1);
			FmodManager.PlaySoundOneShot(FmodSFX.AlarmClockHit);
			camera.shake(0.01, 0.25);
			camera.flash(FlxColor.WHITE, 0.5);


			if (!finalBattle) {
				new FlxTimer().start(2, (t) -> {
					FmodManager.StopSong();
				});
			}

			new FlxTimer().start(.1, (t) -> {
				if(!finalBattle){
					FmodManager.PlaySoundOneShot(FmodSFX.AlarmBreak);
				}
				clock.animation.play('broken');
			});

			acceptInput = false;
			hand.velocity.set();
			if (clockTween != null) {
				if (!clockTween.finished) {
					clockTween.cancel();
				}
				clockTween = null;
			}
			if (handTween != null) {
				if (!handTween.finished) {
					handTween.cancel();
				}
				handTween = null;
			}

			var delay = 2.0;
			if(finalBattle){
				delay = 0.5;
			}
			new FlxTimer().start(delay, (t) -> {
				success = true;
				dialog.revive();
				switch dialog.characterIndex {
					case LONK:
						dialog.loadDialogLine("<cb val=mad /><shake>HOW?!</shake>");
					default:
						dialog.loadDialogLine("<cb val=sad />....You win this time...<page/>I will see you tomorrow...");
				}
				dialog.textGroup.finishCallback = () -> {
					dialog.kill();

					new FlxTimer().start(1, (t) -> {
						transitionOut();
					});
				};
			});

			if(!finalBattle){
				GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
				GlobalQuestState.currentQuest = Enum_QuestName.Intro;
				GlobalQuestState.subQuest = 2; // starting here to make editing the old structure easier
			}
		}
	}

	function startClockTween(edge:Bool = false, repeat:Bool = false) {
		if (fightOver) {
			// fight is over, no more moving
			return;
		}
		var nextX = FlxG.random.int(0, Math.round(FlxG.width - clock.width));
		var moveTime = FlxG.random.float(clockMoveTimeMin, clockMoveTimeMax);
		if (edge) {
			nextX = FlxG.random.bool() ? 0 : Math.round(FlxG.width - clock.width);

			if (secondSwipe) {
				if (clock.x < FlxG.width / 2) {
					nextX = Math.round(FlxG.width - clock.width);
				} else {
					nextX = 0;
				}
				moveTime = clockMoveTimeMin;

			}

			moveTime = clockMoveTimeMin;
		}

		clockTweenCount++;
		restModifier = Math.round(clockTweenCount / 5) * 0.1;
		var mockPlayer = firstSwipe;
		var shouldRepeat = repeat;
		clockTween = FlxTween.linearMotion(clock, clock.x, clock.y, nextX, clock.y,
			moveTime,
			{
				ease: FlxEase.quadInOut,
				onComplete: (t) -> {
					if (mockPlayer) {
						acceptInput = false;
						dialog.revive();
						switch dialog.characterIndex {
							case LONK:
								dialog.loadDialogLine("<cb val=happy/>You're as slow as ever.<pause t=2> <cb val=mad/>Give me what is rightfully mine.");
							default:
								dialog.loadDialogLine("<cb val=mad/>You'll have to be faster than that! Come and get me!");
						}
						dialog.textGroup.finishCallback = () -> {
							dialog.kill();

							// make sure our dialog acceptance doesn't also force a swipe
							new FlxTimer().start(.05, (t) -> {
								acceptInput = true;
								helperArrowLeft.visible = true;
								helperArrowRight.visible = true;
							});
						};
						// new FlxTimer().start(restSeconds + restModifier, (timer) -> {
						// 	startClockTween();
						// });
					} else if (shouldRepeat) {
						// if you take out this var (even though it's unused) it errors
						var test = new FlxTimer().start(restSeconds + restModifier, (timer) -> {
							startClockTween(false, true);
						});
					}
				}
			});
	}

	function startSwipe() {
		if (firstSwipe) {
			startClockTween(true, false);
			firstSwipe = false;
			secondSwipe = true;
		} else if (secondSwipe) {
			startClockTween(true, true);
			secondSwipe = false;
		}
		// hand.velocity.set();
		handSwiping = true;
		handTween = FlxTween.linearMotion(hand, hand.x, hand.y, hand.x, FlxG.height, 0.3, {
			ease: FlxEase.cubeIn,
			onComplete: (t) -> {
				new FlxTimer().start(0.3, (t) -> {
					handTween = FlxTween.linearMotion(hand, hand.x, -hand.height, hand.x, handHoverY, 0.3, {
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