package entities.interact;

import states.battles.ChestBattle;
import com.bitdecay.lucidtext.parse.TagLocation;
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
			var substate = new ChestBattle();
			PlayState.ME.startEncounter(substate);
			substate.closeCallback = () -> {
				if (substate.success) {
					FmodManager.PlaySoundOneShot(FmodSFX.ChestOpen);
					new FlxTimer().start(2, (t) -> {
						animation.play("open");
						opened = true;
						dialogBox.loadDialogLine("A <color id=keyItem>compass</color> sits alone inside the chest.<page/> <cb val=compassGet/><pause t=2.5/>It is glorious!<page/> <cb val=compassDrop/><pause t=2/>Oops.<pause t=1/> It is probably fine.<page/>...<page/>No, it's broken");
						PlayState.ME.openDialog(dialogBox);
						InteractableFactory.collected.set(contentKey, true);
						GlobalQuestState.HAS_COMPASS = true;
					});
				}
			};
		} else {
			dialogBox.loadDialogLine("It is empty.");
			PlayState.ME.openDialog(dialogBox);
		}
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "compassGet") {
				PlayState.ME.eventSignal.dispatch('compassCollected');
			}

			if (tag.parsedOptions.val == "compassDrop") {
				PlayState.ME.eventSignal.dispatch('compassDropped');
			}
		}
	}
}