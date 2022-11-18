package entities.npcs;

import com.bitdecay.lucidtext.parse.TagLocation;
import quest.GlobalQuestState;
import states.PlayState;

class Lonk extends NPC {
	public function new(data:Entity_NPC) {
		super(data);

		PlayState.ME.eventSignal.add(handleEvent);
	}

	override function interact() {
		super.interact();
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);

		// // TODO: We will need to add more checks around this so we make sure we are only advancing the correct quest
		// //   Could we do this via values inside the callback? such as `complete_intro` instead of a generic `questDone`
		// //   value?
		// if (tag.tag == "cb" && tag.parsedOptions.val == "complete_intro") {
		// 	PlayState.ME.transitionSignal.add(bumpQuest);
		// }
	}

	// function bumpQuest(name:String) {
	// 	PlayState.ME.transitionSignal.remove(bumpQuest);
	// 	GlobalQuestState.currentQuest = COMPASS_FETCH;
	// }

	function handleEvent(e:String) {
		if (e == "rubberPotDefeated" && GlobalQuestState.getCurrentQuestKey() == "intro_0") {
			GlobalQuestState.subQuest++;
		}
	}

	override function destroy() {
		super.destroy();
		PlayState.ME.eventSignal.remove(handleEvent);
	}
}