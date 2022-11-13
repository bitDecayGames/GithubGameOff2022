package states.battles;

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

import encounters.CharacterDialog;
import input.SimpleController;

using zero.flixel.extensions.FlxPointExt;

class AlarmClockState extends EncounterBaseState {
	// midpoints can only be this far apart and still count as hitting the clock
	private static var requiredAccuracyPixels = 10;
	private static var restSeconds = 0.5;
	private static var finishYOffset = 11;

	var clock:FlxSprite;
	var clockTween:FlxTween = null;

	var fightOver = false;

	var firstSwipe = true;
	var handSwiping = false;
	var handHoverY = 30;
	var hand:FlxSprite;
	var handXAccel = 20;
	var handTween:FlxTween = null;

	var dialog:CharacterDialog;
	var fightGroup:FlxGroup;

	// TODO The clock should stay still at the beginning and always dodge your first attempt, then go into the normal game

	public function new() {
		super();
		dialog = new CharacterDialog(CharacterIndex.ALARM_CLOCK, "<speed mod=10>BEEP<pause t=1 /> BEEP<pause t=1 /> BEEP<pause t=1 /> BEEP<page/>BEEP<pause t=1 /> BEEP<pause t=1 /> BEEP<pause t=1 /> BEEP</speed>");
	}

	override function create() {
		super.create();


		new FlxTimer().start(1.75, (t) -> {
			FmodManager.PlaySong(FmodSongs.BattleWithAlarm);
		});

		fightGroup = new FlxGroup();

		clock = new FlxSprite();
		clock.scrollFactor.set();
		// clock.makeGraphic(30, 30, FlxColor.RED);
		clock.loadGraphic(AssetPaths.clockLarge__png, true, 30, 30);
		clock.animation.add('blink', [0,1], 2);
		clock.animation.play('blink');
		clock.screenCenter();

		hand = new FlxSprite();
		hand.scrollFactor.set();
		hand.loadGraphic(AssetPaths.crappyHand__png);
		hand.screenCenter(X);
		hand.y = handHoverY;

		// make sure hand is over the clock
		fightGroup.add(clock);
		fightGroup.add(hand);

		battleGroup.add(fightGroup);
		// fightGroup.active = false;
		battleGroup.add(dialog);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();
			// fightGroup.active = true;

			new FlxTimer().start(.05, (t) -> {
				acceptInput = true;
			});
		};
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!acceptInput) {
			return;
		}

		if (!handSwiping) {
			if (SimpleController.just_pressed(A)) {
				FmodManager.PlaySoundOneShot(FmodSFX.AlarmSwing);
				startSwipe();
			} else if (SimpleController.pressed(LEFT)) {
				hand.velocity.x -= handXAccel * elapsed;
			} else if (SimpleController.pressed(RIGHT)) {
				hand.velocity.x += handXAccel * elapsed;
			} else {
				hand.velocity.x *= 0.95;
			}
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


			new FlxTimer().start(2, (t) -> {
				FmodManager.StopSong();
			});

			new FlxTimer().start(.1, (t) -> {
				FmodManager.PlaySoundOneShot(FmodSFX.AlarmBreak);
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
			new FlxTimer().start(2, (t) -> {
				dialog.revive();
				dialog.loadDialogLine("....You win this time...<page/>I will see you tomorrow...");
				dialog.textGroup.finishCallback = () -> {
					dialog.kill();

					new FlxTimer().start(1, (t) -> {
						transitionOut();
					});
				};
			});

			GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		}

		if (checkSuccess()) {
			// TODO: success end sequence start
			// transitionOut();
		} else {
			// failure
			// acceptInput = false;
			// transitionOut();
		}
	}

	var clockMoveTimeMin = 0.2;
	var clockMoveTimeMax = 0.7;
	function startClockTween(edge:Bool = false) {
		if (fightOver) {
			// fight is over, no more moving
			return;
		}
		var nextX = FlxG.random.int(0, Math.round(FlxG.width - clock.width));
		var moveTime = FlxG.random.float(clockMoveTimeMin, clockMoveTimeMax);
		if (edge) {
			nextX = FlxG.random.bool() ? 0 : Math.round(FlxG.width - clock.width);
			moveTime = clockMoveTimeMin;
		}
		clockTween = FlxTween.linearMotion(clock, clock.x, clock.y, nextX, clock.y,
			moveTime,
			{
				ease: FlxEase.quadInOut,
				onComplete: (t) -> {
					if (edge) {
						acceptInput = false;
						dialog.revive();
						dialog.loadDialogLine("You'll have to be faster than that!");
						dialog.textGroup.finishCallback = () -> {
							dialog.kill();

							// make sure our dialog acceptance doesn't also force a swipe
							new FlxTimer().start(.05, (t) -> {
								acceptInput = true;
							});
						};
						new FlxTimer().start(restSeconds, (timer) -> {
							startClockTween();
						});
					}
					else {
						// if you take out this var (even though it's unused) it errors
						var test = new FlxTimer().start(restSeconds, (timer) -> {
							startClockTween();
						});
					}
				}
			});
	}

	function startSwipe() {
		if (firstSwipe) {
			startClockTween(true);
			firstSwipe = false;
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