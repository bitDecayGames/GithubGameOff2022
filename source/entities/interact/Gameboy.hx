package entities.interact;

import entities.particles.ItemIndex;
import com.bitdecay.lucidtext.parse.TagLocation;
import openfl.net.URLRequest;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class Gameboy extends GenericInteractable {
	static var interactedWith = false;

	public function new(data:Entity_Interactable) {
		super(data);
		visible = true;
		loadGraphic(AssetPaths.interiorDecorations__png, true, 16, 16);
		animation.frameIndex = 19;
	}

	override function interact() {
		// if (interactedWith) {
		// 	// take them to the link!
		// 	openfl.Lib.getURL(new URLRequest("https://bitdecaygames.itch.io/odd-verdure"));
		// 	return;
		// }
		// interactedWith = true;
		super.interact();
	}

	override function dialogFinished() {
		super.dialogFinished();

		if (alive) {
			InteractableFactory.defeated.set(data.f_Key, true);
			InteractableFactory.collected.set(data.f_Key, true);
			dialogBox.loadDialogLine("I'll just take this with me and find some batteries. <cb val=gameboyGet/><pause t=2/> <cb val=restoreControl/>");
			PlayState.ME.openDialog(dialogBox);
		}
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "gameboyGet") {
				PlayState.ME.eventSignal.dispatch('gameboyCollected');
				kill();
			}

			if (tag.parsedOptions.val == "restoreControl") {
				PlayState.ME.eventSignal.dispatch("restoreControl");
			}
		}
	}
}