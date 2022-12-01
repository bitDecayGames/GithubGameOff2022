package entities.interact;

import entities.particles.ItemIndex;
import com.bitdecay.lucidtext.parse.TagLocation;
import openfl.net.URLRequest;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class Donut extends GenericInteractable {
	static var interactedWith = false;

	public function new(data:Entity_Interactable) {
		super(data);
		visible = true;
		loadGraphic(AssetPaths.items__png, true, 16, 16);
		animation.frameIndex = ItemIndex.DONUT;
	}

	override function interact() {
		super.interact();
	}

	override function dialogFinished() {
		super.dialogFinished();

		if (alive) {
			InteractableFactory.collected.set(data.f_Key, true);
			InteractableFactory.defeated.set(data.f_Key, true);
			dialogBox.loadDialogLine("Free energy! <cb val=donutGet/><pause t=2/> <cb val=restoreControl/>");
			PlayState.ME.openDialog(dialogBox);
		}
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "donutGet") {
				PlayState.ME.eventSignal.dispatch('donutCollected');
				kill();
			}

			if (tag.parsedOptions.val == "restoreControl") {
				PlayState.ME.eventSignal.dispatch("restoreControl");
			}
		}
	}
}