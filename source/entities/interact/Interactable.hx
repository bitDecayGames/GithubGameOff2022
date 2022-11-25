package entities.interact;

import flixel.util.FlxStringUtil;
import com.bitdecay.lucidtext.parse.TagLocation;
import encounters.CharacterIndex;
import encounters.CharacterDialog;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Interactable extends FlxSprite {
	var dialogBox:CharacterDialog;
	var text:String;

	public function new(X:Float, Y:Float, charIndex:CharacterIndex, defaultText:String = "") {
		super(X, Y);
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.YELLOW);
		text = defaultText;
		immovable = true;

		dialogBox = new CharacterDialog(charIndex, "");
		dialogBox.textGroup.tagCallback = handleTagCallback;

		dialogBox.textGroup.finishCallback = dialogFinished;
	}

	public function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialogBox.setExpression(tag.parsedOptions.val);
		}
	}

	function dialogFinished() {
		PlayState.ME.closeDialog(dialogBox);
		dialogBox.resetLastLine();
	}


	public function interact() {
		if (!FlxStringUtil.isNullOrEmpty(text)) {
			dialogBox.loadDialogLine(text);
			PlayState.ME.openDialog(dialogBox);
		}
	}
}