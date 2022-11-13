package states.battles;

import flixel.math.FlxMath;
import encounters.CharacterIndex;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import encounters.CharacterDialog;
import input.SimpleController;

using zero.flixel.extensions.FlxPointExt;

class AlarmClockState extends EncounterBaseState {
	var clock:FlxSprite;
	var clockTween:FlxTween = null;

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
		clock.makeGraphic(30, 30, FlxColor.RED);
		clock.screenCenter();
		startClockTween();

		hand = new FlxSprite();
		hand.scrollFactor.set();
		hand.makeGraphic(50, 30, FlxColor.BLUE);
		hand.screenCenter(X);
		hand.y = handHoverY;

		// make sure hand is over the clock
		fightGroup.add(clock);
		fightGroup.add(hand);

		battleGroup.add(fightGroup);
		fightGroup.active = false;
		battleGroup.add(dialog);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();
			fightGroup.active = true;

			new FlxTimer().start(1, (t) -> {
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


		if (hand.overlaps(clock)) {
			FmodManager.SetEventParameterOnSong("AlarmOff", 1);
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
			transitionOut();
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
	function startClockTween() {
		var nextX = FlxG.random.int(0, Math.round(FlxG.width - clock.width));
		clockTween = FlxTween.linearMotion(clock, clock.x, clock.y, nextX, clock.y,
			FlxG.random.float(clockMoveTimeMin, clockMoveTimeMax),
			{
				ease: FlxEase.quadInOut,
				onComplete: (t) -> {
					new FlxTimer().start(0.25, (timer) -> {
						startClockTween();
					});
				}
			});
	}

	function startSwipe() {
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