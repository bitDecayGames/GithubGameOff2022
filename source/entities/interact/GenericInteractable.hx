package entities.interact;

import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class GenericInteractable extends Interactable {
	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE, data.f_Description);
		// these are just interaction boxes and don't need to render anything. The art is part of the level
		visible = false;
		immovable = true;
	}
}