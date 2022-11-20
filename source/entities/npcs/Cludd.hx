package entities.npcs;

import states.PlayState;
import com.bitdecay.lucidtext.parse.TagLocation;

class Cludd extends NPC {
	public function new(data:Entity_NPC) {
		super(data);
	}

	override public function interact() {
		// intentionall not calling super here as we don't want to update facing
		updateQuestText();
		PlayState.ME.openDialog(dialogBox);
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
	}
}