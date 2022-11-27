package entities.interact;

import flixel.FlxG;
import flixel.FlxObject;
import states.battles.GateState;
import states.battles.ChestBattle;
import com.bitdecay.lucidtext.parse.TagLocation;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class Gate extends Interactable {

	var opened = false;
	var contentKey:String;

	public function new(data:Entity_Interactable) {
		super(data.pixelX-16, data.pixelY-16, NONE);
		contentKey = data.f_Key;
		loadGraphic(AssetPaths.gateSprite__png, true, 48, 48);
		animation.add('closed', [0]);
		animation.add('opened', [1]);
		immovable = true;

		// TODO: Check global state to see if this chest was opened already
		if (InteractableFactory.collected.exists(contentKey)) {
			animation.play('opened');
			opened = true;
			allowCollisions = FlxObject.NONE;
		}
	}

	override function interact() {
		if (!GlobalQuestState.LONK_HOUSE_COLLAPSED) {
			dialogBox.loadDialogLine('It is a fancy locked gate, but to what?');
			PlayState.ME.openDialog(dialogBox);
		} else {
			if (!GlobalQuestState.HAS_INTERACTED_WITH_GATE) {
				GlobalQuestState.HAS_INTERACTED_WITH_GATE = true;
				if (GlobalQuestState.currentQuest == Find_lonk) {
					GlobalQuestState.subQuest = 3;
				} else {
					FlxG.log.warn('somehow interacted with gate on quest ${GlobalQuestState.currentQuest}');
				}
			}

			if (!opened) {
				var substate = new GateState();
				FmodManager.StopSongImmediately();
				FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
				PlayState.ME.startEncounter(substate);
				substate.closeCallback = () -> {
					if (substate.success) {
						InteractableFactory.collected.set(contentKey, true);
						FmodManager.PlaySoundOneShot(FmodSFX.GateOpen);
						animation.play('opened');
						opened = true;
						allowCollisions = FlxObject.NONE;
					}
				};
			} else {
				// do not interact if it is already opened
			}
		}
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
		if (tag.tag == "cb") {
		}
	}
}