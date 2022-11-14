package states.battles;

import particles.Slash;
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

class PotBattleState extends EncounterBaseState {
	var ring:FlxSprite;

	var cursor:FlxSprite;
	var cursorAngle = 0.0;

	// spin speed in degrees per second
	var spinSpeed = 0.0;
	var maxSpinSpeed = 180.0;

	var attackLimit = 5;

	var weakPointsGroup = new FlxTypedGroup<FlxSprite>();
	var attackGroup = new FlxTypedGroup<FlxSprite>();

	var dialog:CharacterDialog;
	var fightGroup:FlxGroup;

	public function new(foe:CharacterDialog) {
		super();
		dialog = foe;
	}

	override function create() {
		super.create();

		fightGroup = new FlxGroup();

		ring = new FlxSprite(AssetPaths.ring__png);
		ring.scrollFactor.set();

		ring.screenCenter();
		ring.alpha = 0;

		randomizeAimPoints(4);

		var potSprite = new FlxSprite(AssetPaths.battlePot__png);
		potSprite.scrollFactor.set();
		potSprite.screenCenter();
		potSprite.y -= 9;
		battleGroup.add(potSprite);

		cursor = new FlxSprite();
		cursor.scrollFactor.set();
		cursor.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		// can't figure out how to just draw a circle outline... so just draw a black circle on top of the white circle
		FlxSpriteUtil.drawCircle(cursor, -1, -1, -1, FlxColor.RED);
		cursor.alpha = 0;

		cursorAngle = FlxG.random.float(0, 279);
		var point = ring.getGraphicMidpoint().place_on_circumference(cursorAngle, ring.width/2);
		cursor.setPositionMidpoint(point.x, point.y);
		point.put();

		// make sure our attacks are under our cursor
		fightGroup.add(ring);
		fightGroup.add(weakPointsGroup);
		fightGroup.add(attackGroup);
		fightGroup.add(cursor);

		battleGroup.add(fightGroup);
		fightGroup.active = false;
		battleGroup.add(dialog);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();
			fightGroup.active = true;

			new FlxTimer().start(0.5, (t) -> {
				// TODO: SFX guide ring fades in
				FlxTween.tween(ring, { alpha: 1 }, 0.5, {
					onComplete: (t) -> {
						var delay = 0.0;
						weakPointsGroup.forEach((wp) -> {
							// TODO: SFX single weakpoint fades in
							new FlxTimer().start(delay, (t) -> {
								FlxTween.tween(wp, { alpha: 1}, 0.5);
							});
							delay += .35;
						});
						new FlxTimer().start(delay, (t) -> {
							// TODO: SFX attack cursor fades in
							FlxTween.tween(cursor, { alpha: 1}, 0.5, {
								onComplete: (t) -> {
									acceptInput = true;
									FlxTween.tween(this, { spinSpeed: maxSpinSpeed }, { ease: FlxEase.sineIn });
								}
							});
						});
					}
				});
			});
		};
	}

	var placed:Array<Int> = [];
	function randomizeAimPoints(num:Int) {
		for (i in 0...num) {
			var placement = FlxG.random.int(0, 17, placed);
			placed.push(placement);
			var point = ring.getGraphicMidpoint().place_on_circumference(placement * 20, ring.width/2);
			var aim = new FlxSprite();
			aim.scrollFactor.set();
			aim.makeGraphic(10, 10, FlxColor.TRANSPARENT);
			FlxSpriteUtil.drawCircle(aim, -1, -1, -1, FlxColor.PINK);

			aim.setPositionMidpoint(point.x, point.y);
			point.put();

			aim.alpha = 0;

			weakPointsGroup.add(aim);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		cursorAngle += spinSpeed * elapsed;
		cursorAngle = cursorAngle % 360;
		var point = ring.getGraphicMidpoint().place_on_circumference(cursorAngle, ring.width/2);
		cursor.setPositionMidpoint(point.x, point.y);
		point.put();

		if (!acceptInput) {
			return;
		}

		if (complete) {
			return;
		}

		if (SimpleController.just_pressed(A) && attackGroup.length < attackLimit) {
			createAttack();
		}

		if (checkSuccess()) {
			// TODO: success end sequence start
			complete = true;
			animateAttacks();
		} else if (attackGroup.length == attackLimit) {
			// failure
			// TODO: SFX failure begins. cursor slows rotation
			acceptInput = false;
			new FlxTimer().start(1, (t) -> {
				FlxTween.tween(this, { spinSpeed: 0 }, 2,
					{
						ease: FlxEase.sineOut,
						onComplete: (t) -> {
							dialog.loadDialogLine('Your puny arms are <bigger>too weak</bigger> to defeat me.');
							dialog.textGroup.finishCallback = () -> {
								transitionOut();
							};
							dialog.revive();
						}
					});
			});
		}
	}

	function createAttack() {
		// TODO:SFX attack aimed at pot
		FlxG.camera.shake(0.02, 0.1);
		var point = ring.getGraphicMidpoint().place_on_circumference(cursorAngle, ring.width/2);
		var attack = new FlxSprite();
		attack.scrollFactor.set();
		// Different size to keep a unique image
		attack.makeGraphic(11, 11, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawCircle(attack, -1, -1, -1, FlxColor.BLUE);

		attack.setPositionMidpoint(point.x, point.y);
		point.put();

		attackGroup.add(attack);
	}

	function checkSuccess():Bool {
		var success = true;
		weakPointsGroup.forEach((weakness) -> {
			if (!FlxG.overlap(weakness, attackGroup)) {
				// found one that doesn't align
				trace(FlxG.worldBounds);
				success = false;
			}
		});

		return success;
	}

	function animateAttacks() {
		FlxTween.tween(this, { spinSpeed: 0 }, 1,
		{
			ease: FlxEase.sineOut,
			onComplete: (t) -> {
				var delay = 0.0;
				attackGroup.forEach((a) -> {
					if (a.overlaps(weakPointsGroup)) {
						new FlxTimer().start(delay, (t) -> {
							// TODO: SFX pot attack hits pot. will happen 'n' times
							FlxG.camera.shake(0.02, 0.1);
							camera.flash(0.05);
							var particle = new Slash(a.x, a.y);
							particle.scale.set(FlxG.random.float(1, 5), FlxG.random.float(1, 5));
							particle.scrollFactor.set();
							particle.flipX = FlxG.random.bool();
							particle.flipY = FlxG.random.bool();
							add(particle);
						});
						delay += .35;
					}
				});

				new FlxTimer().start(delay, (t) -> {
					transitionOut();
				});
			}
		});
	}
}