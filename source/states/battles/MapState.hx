package states.battles;

import flixel.FlxObject;
import flixel.addons.effects.FlxClothSprite;
import bitdecay.flixel.debug.DebugDraw;
import flixel.math.FlxRect;
import flixel.util.FlxSpriteUtil;
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

class MapState extends EncounterBaseState {

	private static var handXAccel = 80;

	var mapPaper:FlxClothSprite;
	var pins:Array<FlxSprite>;

	var hand:FlxSprite;

	var mapClothWidth = 10;
	var mapClothHeight = 8;

	public function new() {
		super();
	}

	override function create() {
		super.create();

		dialog = new CharacterDialog(CharacterIndex.ALARM_CLOCK, "I can show you the world! A hand drawn, pixely splendor!");
		FmodManager.PlaySong(FmodSongs.Battle);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();

			new FlxTimer().start(.05, (t) -> {
				acceptInput = true;
			});
		};

		dialog.textGroup.tagCallback = handleTagCallback;

		mapPaper = new FlxClothSprite(0, 0, AssetPaths.crappot__png);
		mapPaper.screenCenter();
		mapPaper.pinnedSide = FlxObject.NONE;
		mapPaper.setMesh(mapClothWidth, mapClothHeight, 0, 0,
			[
				0,
				mapClothWidth-1,
				mapClothWidth * (mapClothHeight - 1),
				mapClothWidth * mapClothHeight - 1
			]);
		mapPaper.iterations = 8;
		mapPaper.maxVelocity.set(0, 20);
		mapPaper.meshVelocity.y = 20;

		pins = [];
		for (i in 0...4) {
			var pin = new FlxSprite(AssetPaths.mapPin__png);
			pins.push(pin);
		}

		pins[0].setPositionMidpoint(mapPaper.x, mapPaper.y);
		pins[1].setPositionMidpoint(mapPaper.x + mapPaper.width, mapPaper.y);
		pins[1].flipX = true;
		pins[2].setPositionMidpoint(mapPaper.x, mapPaper.y + mapPaper.height);
		pins[3].setPositionMidpoint(mapPaper.x + mapPaper.width, mapPaper.y + mapPaper.height);
		pins[3].flipX = true;

		hand = new FlxSprite();
		hand.makeGraphic(10, 10, FlxColor.LIME);
		hand.screenCenter();

		battleGroup.add(mapPaper);
		for (pin in pins) {
			battleGroup.add(pin);
		}

		battleGroup.add(hand);
		battleGroup.add(dialog);
	}

	function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialog.setExpression(tag.parsedOptions.val);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!acceptInput) {
			return;
		}

		if (SimpleController.just_pressed(A)) {
			pluck();
		}
		if (SimpleController.pressed(LEFT)) {
			hand.x -= handXAccel * elapsed;
		}
		if (SimpleController.pressed(RIGHT)) {
			hand.x += handXAccel * elapsed;
		}
		if (SimpleController.pressed(UP)) {
			hand.y -= handXAccel * elapsed;
		}
		if (SimpleController.pressed(DOWN)) {
			hand.y += handXAccel * elapsed;
		}

		if (!FlxMath.inBounds(hand.x, 0, FlxG.width - hand.width)) {
			hand.velocity.x = 0;
			hand.x = FlxMath.bound(hand.x, 0, FlxG.width - hand.width);
		}

		if (!FlxMath.inBounds(hand.y, 0, FlxG.height - hand.height)) {
			hand.velocity.y = 0;
			hand.y = FlxMath.bound(hand.y, 0, FlxG.height - hand.height);
		}

		for (p in pins) {
			if (p.alive && p.y > FlxG.height) {
				p.kill();
			}
		}

		var allPinsPlucked = true;
		for (p in pins) {
			if (p.alive) {
				allPinsPlucked = false;
			}
		}

		if (allPinsPlucked) {
			acceptInput = false;
			success = true;
			dialog.revive();
			dialog.loadDialogLine("It's dark... so very dark.");
			dialog.textGroup.finishCallback = () -> {
				dialog.kill();

				new FlxTimer().start(1, (t) -> {
					transitionOut();
				});
			};
		}
	}

	function pluck() {
		// TODO: Animate pluck
		hand.velocity.set();
		for (i in 0...pins.length) {
			var pin = pins[i];
			if (pin.alive && FlxG.overlap(hand, pin)) {
				// TODO SFX: Plucked a pin
				pin.velocity.set(30 * (pin.flipX ? 1 : -1), -60);
				pin.acceleration.set(0, 500);
				switch(i) {
					case 0:
						mapPaper.points[0].pinned = false;
					case 1:
						mapPaper.points[mapClothWidth-1].pinned = false;
					case 2:
						mapPaper.points[mapClothWidth * (mapClothHeight - 1)].pinned = false;
					case 3:
						mapPaper.points[mapClothWidth * mapClothHeight - 1].pinned = false;
				}
			} else {
				// TODO SFX: Plucked nothing
			}
		}
	}

	function checkSuccess():Bool {
		return false;
	}
}
