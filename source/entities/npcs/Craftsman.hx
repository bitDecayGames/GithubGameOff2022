package entities.npcs;

import entities.interact.InteractableFactory;
import com.bitdecay.lucidtext.parse.TagLocation;
import quest.GlobalQuestState;
import states.PlayState;

class Craftsman extends NPC {
	public function new(data:Entity_NPC) {
		super(data);
		width = getHitbox().width;
		height = getHitbox().height+4;
	}

	override function interact() {
		super.interact();
		if (InteractableFactory.defeated.exists("brindle_pot")) {
			// override whatever text with this angry message
			dialogBox.loadDialogLine("<cb val=mad/>Why would you go around breaking other people's things? Get out of my shop.");
		}
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);

		if (tag.tag == "cb") {

		}
	}

	function handleEvent(e:String) {
		if (e == "") {

		}
	}
}