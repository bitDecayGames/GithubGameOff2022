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

	var mapPaper:FlxSprite;
	var pins:Array<FlxSprite>;

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

		mapPaper = new FlxClothSprite(0, 0, AssetPaths.crappot__png, 10, 10, FlxObject.NONE);
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

		if (SimpleController.just_pressed(LEFT)) {
		} else if (SimpleController.just_pressed(RIGHT)) {
		}
	}

	function checkSuccess():Bool {
		return false;
	}
}
