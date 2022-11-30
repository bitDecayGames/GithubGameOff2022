package entities.interact;

import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
import com.bitdecay.lucidtext.parse.TagLocation;
import encounters.CharacterIndex;
import encounters.CharacterDialog;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Interactable extends FlxSprite {
	var dialogBox:CharacterDialog;
	var text:Array<String> = [];
	var textIndex = -1;

	public function new(X:Float, Y:Float, charIndex:CharacterIndex, defaultText:String = "") {
		super(X, Y);
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.YELLOW);
		text.push(defaultText);
		immovable = true;

		dialogBox = new CharacterDialog(charIndex, "");
		dialogBox.textGroup.tagCallback = handleTagCallback;

		dialogBox.textGroup.finishCallback = dialogFinished;
	}

	public function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {
			// only handle the emotions we know we support
			if (['happy', 'mad', 'neutral', 'sad'].contains(tag.parsedOptions.val)) {
				dialogBox.setExpression(tag.parsedOptions.val);
			}
		}
	}

	function dialogFinished() {
		PlayState.ME.closeDialog(dialogBox);
		dialogBox.resetLastLine();
	}


	public function interact() {
		if (text.length > 0) {
			textIndex = FlxMath.maxAdd(textIndex, 1, text.length - 1, 0);
			if (!FlxStringUtil.isNullOrEmpty(text[textIndex])) {
				dialogBox.loadDialogLine(text[textIndex]);
				PlayState.ME.openDialog(dialogBox);
			}
		}
	}
}