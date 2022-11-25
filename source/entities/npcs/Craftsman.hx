package entities.npcs;

import quest.QuestIndex;
import com.bitdecay.lucidtext.parse.TagLocation;
import quest.GlobalQuestState;
import states.PlayState;

class Craftsman extends NPC {
	public function new(data:Entity_NPC) {
		super(data);
	}

	override function interact() {
		super.interact();
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