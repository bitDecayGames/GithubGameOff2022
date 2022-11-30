package entities.npcs;

import flixel.FlxObject;
import constants.Characters;
import encounters.CharacterDialog;
import states.battles.EncounterBaseState;
import flixel.tweens.FlxTween;
import states.LonkFinalFightState;
import flixel.FlxG;
import flixel.util.FlxTimer;
import com.bitdecay.lucidtext.parse.TagLocation;
import quest.GlobalQuestState;
import states.PlayState;

class Lonk extends NPC {

	var triggerEnding = false;

	var finalDoor:Door = null;

	public function new(data:Entity_NPC) {
		super(data);
		if (GlobalQuestState.currentQuest == Enum_QuestName.End_game) {
			facing = FlxObject.RIGHT;
		}
		PlayState.ME.eventSignal.add(handleEvent);

		if (GlobalQuestState.currentQuest == Enum_QuestName.End_game) {
			new FlxTimer().start(1, (t) -> {
				dialogBox.loadDialogLine("<cb val=happy />Don't fall back too far!<page/>I<cb val=mad /> am just getting started");
				PlayState.ME.openDialog(dialogBox);
			});
		}
	}

	override function interact() {
		super.interact();
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);

		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "turn_off_clock" && GlobalQuestState.getCurrentQuestKey() == Enum_QuestName.Final_morning.subQuestKey(0)) {
				GlobalQuestState.subQuest++;
			}
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
			if (tag.parsedOptions.val == "triggerEnding") {
				triggerEnding = true;
			}
			if (tag.parsedOptions.val == "stopMusic") {
				FmodManager.StopSong();
			}
			if (tag.parsedOptions.val == "startMusic") {
				FmodManager.PlaySong(FmodSongs.BeforeTheEnd);
			}
			if (tag.parsedOptions.val == "startEndgame") {
				GlobalQuestState.currentQuest = Enum_QuestName.End_game;
			}
			if (tag.parsedOptions.val == "battleTime") {
			}
			if (tag.parsedOptions.val == "goToSchool") {
				GlobalQuestState.subQuest++;
			}
			if (tag.parsedOptions.val == "bumpSubQuest") {
				GlobalQuestState.subQuest++;
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

	override function dialogFinished() {
		super.dialogFinished();

		if (triggerEnding) {
			FmodManager.StopSongImmediately();
			FmodManager.PlaySoundOneShot(FmodSFX.LonkLaugh3);
			PlayState.ME.playerInTransition = true;
			new FlxTimer().start(0.01, (t) -> {
				var transition = new EncounterBaseState();
				transition.dialog = new CharacterDialog(NONE, "");
				transition.onTransInDone = () -> FlxG.switchState(new LonkFinalFightState());
				FlxG.state.openSubState(transition);
			});
		}

		if (PlayState.ME.triggerFinalFade) {
			// after we say to have a nice day, we force the player through the door
			PlayState.ME.playerActive = true;
			PlayState.ME.playerTouchDoor(finalDoor, PlayState.ME.player);
		}
	}

	override function CheckDoor(d:Door):Bool {
		if (GlobalQuestState.SPEEDY_DEBUG) {
			return true;
		}

		if (GlobalQuestState.currentQuest == Enum_QuestName.Final_morning) {
			finalDoor = d;
			if (!PlayState.ME.triggerFinalFade) {
				return false;
			} else {
				return true;
			}
		}

		if (GlobalQuestState.currentQuest == Enum_QuestName.Wake_up || GlobalQuestState.currentQuest == Enum_QuestName.End_game) {
			return false;
		} else if (GlobalQuestState.currentQuest == Enum_QuestName.Intro) {
			if (GlobalQuestState.subQuest < 5) {
				return false;
			}
		}

		return true;
	}

	override function Why():String {
		updateFacing(PlayState.ME.player);
		if (GlobalQuestState.currentQuest == Enum_QuestName.Final_morning) {
			if (GlobalQuestState.subQuest == 0) {
				dialogBox.loadDialogLine("At least come say hello to me!");
			} else {
				dialogBox.loadDialogLine("Have a good day!");
				// updateFacing(PlayState.ME.player);
				PlayState.ME.triggerFinalFade = true;
				PlayState.ME.lonk = this;
			}

		} else if (GlobalQuestState.currentQuest == Enum_QuestName.End_game) {
			dialogBox.loadDialogLine("We have unfinished business. Come here and finish what you started.");
		} else {
			dialogBox.loadDialogLine("Hold on there little buddy");
		}
		PlayState.ME.openDialog(dialogBox);
		return "";
	}
}