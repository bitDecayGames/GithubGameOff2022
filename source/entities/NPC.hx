package entities;

import states.PlayState;
import flixel.FlxG;
import com.bitdecay.lucidtext.parse.TagLocation;
import encounters.CharacterDialog;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class NPC extends Interactable {
	var dialogBox:CharacterDialog;

	public function new(data:Entity_NPC) {
		super(data.cx * Constants.TILE_SIZE, data.cy * Constants.TILE_SIZE);
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.LIME);

		// the mad tag is slightly delayed while I figure out some bugs with how tag callbacks are handled
		dialogBox = new CharacterDialog(LONK, "<cb val=happy />Hello there, boy.<page/>What<cb val=mad /> do you want?<page/>Just<cb val=sad /> kidding, I'm just old and <scrub>bored.</scrub>");
		dialogBox.textGroup.tagCallback = updateFacialExpression;

		dialogBox.textGroup.finishCallback = dialogFinished;
	}

	public function updateFacialExpression(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialogBox.setExpression(tag.parsedOptions.val);
		}
	}

	override function interact() {
		PlayState.ME.openDialog(dialogBox);
	}

	function dialogFinished() {
		PlayState.ME.closeDialog(dialogBox);
		dialogBox.resetLastLine();
	}
}