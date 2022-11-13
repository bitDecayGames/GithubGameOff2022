package entities.npcs;

import com.bitdecay.lucidtext.parse.TagLocation;
import flixel.math.FlxMath;
import quest.GlobalQuestState;
import entities.library.NPCTextBank;
import states.PlayState;

class Lonk extends NPC {
	public function new(data:Entity_NPC) {
		super(data);
	}

	override function interact() {
		super.interact();

		var allText = NPCTextBank.all[charIndex];
		var questText = allText[GlobalQuestState.getCurrentQuestKey()];
		if (questText == null) {
			// if we didn't have text specific to this subtask, check for general quest text
			questText = allText[GlobalQuestState.currentQuest];
		}
		if (questText != null) {
			chatIndex = Math.round(FlxMath.bound(chatIndex, 0, questText.length-1));
			dialogBox.loadDialogLine(questText[chatIndex++]);
		}
		PlayState.ME.openDialog(dialogBox);
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);

		// TODO: We will need to add more checks around this so we make sure we are only advancing the correct quest
		//   Could we do this via values inside the callback? such as `complete_intro` instead of a generic `questDone`
		//   value?
		if (tag.tag == "cb" && tag.parsedOptions.val == "complete_intro") {
			PlayState.ME.transitionSignal.add(bumpQuest);
		}
	}

	function bumpQuest(name:String) {
		PlayState.ME.transitionSignal.remove(bumpQuest);
		GlobalQuestState.currentQuest = COMPASS_FETCH;
	}
}