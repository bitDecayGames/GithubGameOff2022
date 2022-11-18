package states.battles;

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

class GateState extends EncounterBaseState {

	var lockBody:FlxSprite;
	var combo1:FlxSprite;
	var combo2:FlxSprite;
	var combo3:FlxSprite;

	var cursor:FlxSprite;

	public function new() {
		super();
	}

	override function create() {
		super.create();

		dialog = new CharacterDialog(CharacterIndex.ALARM_CLOCK, "With 1000 possible combinations, I highly doubt you'll be able to unlock me.");
		FmodManager.PlaySong(FmodSongs.Battle);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();

			new FlxTimer().start(.05, (t) -> {
				acceptInput = true;
			});
		};

		dialog.textGroup.tagCallback = handleTagCallback;


		lockBody = new FlxSprite();
		lockBody.makeGraphic(100, 100, FlxColor.ORANGE);
		lockBody.screenCenter();

		combo1 = new FlxSprite();
		combo1.makeGraphic(20, 40, FlxColor.RED);
		combo1.setPosition(lockBody.x + 15, lockBody.y + 50);

		combo2 = new FlxSprite();
		combo2.makeGraphic(20, 40, FlxColor.RED);
		combo2.setPosition(combo1.x + 25, combo1.y);

		combo3 = new FlxSprite();
		combo3.makeGraphic(20, 40, FlxColor.RED);
		combo3.setPosition(combo2.x + 25, combo1.y);

		cursor = new FlxSprite();
		cursor.makeGraphic(24, 44, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawLine(cursor, 1, 1, 1, 44);
		FlxSpriteUtil.drawLine(cursor, 1, 1, 1, 44);
		FlxSpriteUtil.drawLine(cursor, 1, 1, 1, 44);

		battleGroup.add(lockBody);
		battleGroup.add(combo1);
		battleGroup.add(combo2);
		battleGroup.add(combo3);

		battleGroup.add(dialog);
	}

	function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialog.setExpression(tag.parsedOptions.val);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	function checkSuccess():Bool {
		return false;
	}
}