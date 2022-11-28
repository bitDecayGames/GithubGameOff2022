package entities.interact;

import shaders.BlinkHelper;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import encounters.CharacterDialog;
import states.battles.PotBattleState;
import states.PlayState;

class PotRubber extends Interactable {

	var helperArrow:FlxSprite;

	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE);
		loadGraphic(AssetPaths.interiorDecorations__png, true, 16, 16);
		animation.frameIndex = 2;
		immovable = true;

		PlayState.ME.eventSignal.add(handleEvent);


		if (GlobalQuestState.TALKED_TO_LONK_FIRST_TIME && !GlobalQuestState.DEFEATED_RUBBER_POT) {
			spawnHelperArrow();
		}
	}

	override function interact() {
		if (!GlobalQuestState.TALKED_TO_LONK_FIRST_TIME) {
			// if you haven't talked to Lonk, then this is just a pot!
			dialogBox.loadDialogLine("It is a pot with an odd texture");
			PlayState.ME.openDialog(dialogBox);
		} else {
			FmodManager.StopSongImmediately();
			FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
			var substate = new PotBattleState(new CharacterDialog(RUBBERPOT, "Take your best shot"));
			PlayState.ME.startEncounter(substate);
			substate.closeCallback = () -> {
				if (substate.success) {
					PlayState.ME.eventSignal.dispatch('rubberPotDefeated');
					GlobalQuestState.DEFEATED_RUBBER_POT = true;
					BlinkHelper.Blink(this, 0.2, 5);
				}
			};
		}

		if (helperArrow != null){
			helperArrow.kill();
		}
	}

	function handleEvent(data:String) {
		if (data == "informed_of_rubber_pot_event"){
			spawnHelperArrow();
			PlayState.ME.eventSignal.remove(handleEvent);
		}
	}

	function spawnHelperArrow() {
		helperArrow = new FlxSprite(x, y-56);
		helperArrow.loadGraphic(AssetPaths.arrow_pointing__png, true, 16, 48);
		helperArrow.animation.add("default", [0,1,2,3,4,5,6,7,8,9], 10);
		helperArrow.animation.play("default");
		PlayState.ME.uiHelpers.add(helperArrow);
	}
}