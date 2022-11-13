package entities.interact;

import com.bitdecay.lucidtext.parse.TagLocation;
import encounters.CharacterIndex;
import encounters.CharacterDialog;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Interactable extends FlxSprite {
	var dialogBox:CharacterDialog;

	public function new(X:Float, Y:Float, charIndex:CharacterIndex) {
		super(X, Y);
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.YELLOW);
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
		// TODO: will need to subclass this to have each thing do its own interaction
		// PlayState.ME.startEncounter(<SUB STATE>);
	}
}