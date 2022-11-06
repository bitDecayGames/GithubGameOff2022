package states.battles;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import input.SimpleController;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using zero.flixel.extensions.FlxPointExt;

class PotBattleState extends EncounterBaseState {
	var ring:FlxSprite;

	var acceptInput = false;
	var cursor:FlxSprite;
	var cursorAngle = 0.0;

	// spin speed in degrees per second
	var spinSpeed = 0.0;
	var maxSpinSpeed = 180.0;

	var attackLimit = 5;

	var attackGroup = new FlxGroup();

	public function new() {
		super();
	}

	override function create() {
		super.create();

		ring = new FlxSprite();
		ring.scrollFactor.set();
		ring.makeGraphic(100, 100, FlxColor.TRANSPARENT);
		// can't figure out how to just draw a circle outline... so just draw a black circle on top of the white circle
		FlxSpriteUtil.drawCircle(ring, -1, -1, -1, FlxColor.WHITE);
		FlxSpriteUtil.drawCircle(ring, -1, -1, 49, FlxColor.BLACK);

		ring.screenCenter();
		battleGroup.add(ring);

		randomizeAimPoints(4);

		var potSprite = new FlxSprite();
		potSprite.scrollFactor.set();
		potSprite.makeGraphic(75, 75, FlxColor.RED);
		potSprite.screenCenter();
		// battleGroup.add(potSprite);

		cursor = new FlxSprite();
		cursor.scrollFactor.set();
		cursor.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		// can't figure out how to just draw a circle outline... so just draw a black circle on top of the white circle
		FlxSpriteUtil.drawCircle(cursor, -1, -1, -1, FlxColor.RED);

		var point = ring.getGraphicMidpoint().place_on_circumference(0, ring.width/2);
		cursor.setPositionMidpoint(point.x, point.y);
		point.put();

		// make sure our attacks are under our cursor
		battleGroup.add(attackGroup);
		battleGroup.add(cursor);

		new FlxTimer().start(1, (t) -> {
			acceptInput = true;
			FlxTween.tween(this, { spinSpeed: maxSpinSpeed }, { ease: FlxEase.sineIn });
		});
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

			battleGroup.add(aim);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		cursorAngle += spinSpeed * elapsed;
		cursorAngle = cursorAngle % 360;
		var point = ring.getGraphicMidpoint().place_on_circumference(cursorAngle, ring.width/2);
		cursor.setPositionMidpoint(point.x, point.y);
		point.put();

		if (acceptInput && SimpleController.just_pressed(A) && attackGroup.length < attackLimit) {
			createAttack();
		}
	}

	function createAttack() {
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
}