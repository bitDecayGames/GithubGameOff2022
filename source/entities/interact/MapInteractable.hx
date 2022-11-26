package entities.interact;

import states.battles.MapState;
import flixel.FlxObject;
import states.battles.GateState;
import states.battles.ChestBattle;
import com.bitdecay.lucidtext.parse.TagLocation;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class MapInteractable extends Interactable {

	var opened = false;
	var contentKey:String;

	public function new(data:Entity_Interactable) {
		super(data.pixelX-8, data.pixelY, NONE);
		contentKey = data.f_Key;
		loadGraphic(AssetPaths.mapHanging__png, true, 32, 32);
		animation.add('present', [0]);
		animation.add('taken', [1]);
		immovable = true;

		height = 24;

		// TODO: Check global state to see if this map was already taken
		if (GlobalQuestState.HAS_MAP) {
			animation.play('taken');
			opened = true;
		}
	}

	override function interact() {
		if (!opened) {
			var substate = new MapState();
			FmodManager.StopSongImmediately();
			FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
			PlayState.ME.startEncounter(substate);
			substate.closeCallback = () -> {
				if (substate.success) {
					opened = true;
					animation.play('taken');
					PlayState.ME.eventSignal.dispatch('lockControls');
					// TODO SFX: Proper map roll-up SFX
					FmodManager.PlaySoundOneShot(FmodSFX.ChestOpen);
					new FlxTimer().start(2, (t) -> {
						opened = true;
						dialogBox.loadDialogLine("A wrinkly old <color id=keyItem>map</color> has fallen to the floor.<page/> <cb val=mapCollected/><pause t=2.5/>It is glorious!<cb val=restoreControl/><page/>");
						PlayState.ME.openDialog(dialogBox);
						GlobalQuestState.HAS_MAP = true;
						InteractableFactory.collected.set(contentKey, true);
						GlobalQuestState.HAS_MAP = true;
						GlobalQuestState.currentQuest = Enum_QuestName.Return_map;
					});
				}
			};
		} else {
			dialogBox.loadDialogLine("It's just an empty frame with some holes poked in the corkboard");
			PlayState.ME.openDialog(dialogBox);
		}
	}

	var awaitingUnlockControls = false;
	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "mapCollected") {
				awaitingUnlockControls = true;
				PlayState.ME.eventSignal.dispatch('mapCollected');
			}

			if (tag.parsedOptions.val == "restoreControl") {
				PlayState.ME.eventSignal.dispatch("restoreControl");
			}
		}
	}

	override function dialogFinished() {
		super.dialogFinished();
		if (awaitingUnlockControls) {
			awaitingUnlockControls = false;
			PlayState.ME.eventSignal.dispatch("restoreControl");
		}
	}
}