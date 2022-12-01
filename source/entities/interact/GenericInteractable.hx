package entities.interact;

import flixel.util.FlxStringUtil;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class GenericInteractable extends Interactable {
	public var data:Entity_Interactable;

	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE, data.f_Description);
		// these are just interaction boxes and don't need to render anything. The art is part of the level
		visible = false;
		immovable = true;

		this.data = data;

		for (desc in data.f_MultiDescript) {
			text.push(desc);
		}

		if (!FlxStringUtil.isNullOrEmpty(data.f_Key)) {
			if (InteractableFactory.multiTextIndex.exists(data.f_Key)) {
				textIndex = InteractableFactory.multiTextIndex.get(data.f_Key);
			} else {
				InteractableFactory.multiTextIndex.set(data.f_Key, -1);
			}
		}
	}

	override function interact() {
		super.interact();

		if (!FlxStringUtil.isNullOrEmpty(data.f_Key)) {
			if (InteractableFactory.multiTextIndex.exists(data.f_Key)) {
				InteractableFactory.multiTextIndex.set(data.f_Key, textIndex);
			}
		}
	}
}