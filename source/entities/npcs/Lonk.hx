package entities.npcs;

import flixel.util.FlxTimer;
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

		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "turn_off_clock" && GlobalQuestState.getCurrentQuestKey() == Enum_QuestName.Wake_up.subQuestKey(0)) {
				GlobalQuestState.subQuest++;
			}
			if (tag.parsedOptions.val == "informed_of_rubber_pot") {
				GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
				PlayState.ME.eventSignal.dispatch('informed_of_rubber_pot_event');
				GlobalQuestState.subQuest++;
			}

			if (tag.parsedOptions.val == "informed_of_compass" && GlobalQuestState.getCurrentQuestKey() == Enum_QuestName.Intro.subQuestKey(4)) {
				GlobalQuestState.subQuest++;
			}

			if (tag.parsedOptions.val == "findMap" && GlobalQuestState.currentQuest != Enum_QuestName.Get_map) {
				GlobalQuestState.currentQuest = Enum_QuestName.Get_map;
				GlobalQuestState.HAS_KEY_TO_HANDYMAN = true;
			}

			if (tag.parsedOptions.val == "keyCollected") {
				PlayState.ME.eventSignal.dispatch('keyCollected');
			}

			if (tag.parsedOptions.val == "restoreControl") {
				PlayState.ME.eventSignal.dispatch("restoreControl");
			}
			if (tag.parsedOptions.val == "faceme") {
				PlayState.ME.player.updateFacingToLookAt(this);
			}
		}
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
		if (e == "rubberPotDefeated" && GlobalQuestState.getCurrentQuestKey() == Enum_QuestName.Intro.subQuestKey(3)) {
			GlobalQuestState.subQuest++;
		}
	}

	override function CheckDoor(d:Door):Bool {
		// This needs more checks if we are to use it in a lot of places
		if (!GlobalQuestState.TALKED_TO_LONK_FIRST_TIME && !GlobalQuestState.SPEEDY_DEBUG) {
			updateFacing(PlayState.ME.player);
			dialogBox.loadDialogLine("Hold on there little buddy");
			PlayState.ME.openDialog(dialogBox);
			return false;
		} else {
			return true;
		}
	}

	override function Why():String {
		// Our check door code handles this
		return "";
	}
}