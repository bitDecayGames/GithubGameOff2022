package entities.npcs;

import com.bitdecay.lucidtext.parse.TagLocation;
import flixel.math.FlxMath;
import quest.GlobalQuestState;
import entities.library.NPCTextBank;
import states.PlayState;

class Lonk extends NPC {
	var lastQuest:String = "";

	public function new(data:Entity_NPC) {
		super(data);

		PlayState.ME.eventSignal.add(handleEvent);
	}

	override function interact() {
		super.interact();

		// TODO: Do we want to add this to the super method so all NPCs benefit?
		if (lastQuest != GlobalQuestState.getCurrentQuestKey()) {
			lastQuest = GlobalQuestState.getCurrentQuestKey();
			chatIndex = 0;
		}

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