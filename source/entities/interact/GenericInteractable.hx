package entities.interact;

import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class GenericInteractable extends Interactable {

	var text:String;

	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE);
		text = data.f_Description;
		// loadGraphic(AssetPaths.chest__png, true, 16, 16);
		// animation.add('closed', [0]);
		// animation.add('opened', [1], 2);
		// animation.add('open', [0, 1], 2, false);
		// animation.add('close', [1, 0], 2, false);
		// setSize(16, 16);

		// these are just interaction boxes and don't need to render anything. The art is part of the level
		visible = false;
		immovable = true;
	}

	override function interact() {
		dialogBox.loadDialogLine(text);
		PlayState.ME.openDialog(dialogBox);
	}
}