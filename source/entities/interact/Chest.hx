package entities.interact;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class Chest extends Interactable {

	var opened = false;
	var contentKey:String;

	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE);
		contentKey = data.f_Key;
		loadGraphic(AssetPaths.chest__png, true, 16, 16);
		animation.add('closed', [0]);
		animation.add('opened', [1], 2);
		animation.add('open', [0, 1], 2, false);
		animation.add('close', [1, 0], 2, false);
		immovable = true;

		// TODO: Check global state to see if this chest was opened already
		if (InteractableFactory.collected.exists(contentKey)) {
			animation.play('opened');
			opened = true;
		}
	}

	override function interact() {
		if (!opened) {
			// TODO SFX: chest open sound. Does this depend on the item inside?
			// TODO: Encounter code?
			animation.play("open");
			opened = true;
			dialogBox.loadDialogLine("A <color id=keyItem>compass</color> sits alone inside the chest.");
			PlayState.ME.openDialog(dialogBox);
			InteractableFactory.collected.set(contentKey, true);
			GlobalQuestState.HAS_COMPASS = true;
			PlayState.ME.eventSignal.dispatch('compassCollected');
		} else {
			dialogBox.loadDialogLine("It is empty.");
			PlayState.ME.openDialog(dialogBox);
		}
	}
}