package entities.interact;

import quest.GlobalQuestState;
import encounters.CharacterDialog;
import states.battles.PotBattleState;
import states.PlayState;

class PotNormal extends Interactable {
	var data:Entity_Interactable;

	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, POT);
		this.data = data;
		loadGraphic(AssetPaths.interiorDecorations__png, true, 16, 16);
		animation.frameIndex = 2;
		immovable = true;
	}

	override function interact() {
		FmodManager.StopSongImmediately();
		FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
		var substate = new PotBattleState(new CharacterDialog(POT, "I am but a pot. Please be gentle."));
		PlayState.ME.startEncounter(substate);
		substate.closeCallback = () -> {
			if (substate.success && data.f_Key == "compass") {
				InteractableFactory.defeated.set(data.f_Key, true);
				// TODO: How to not respawn this if they come back
				kill();
				// PlayState.ME.eventSignal.dispatch('compassCollected');
				// TODO: rejoice in your new compass!
				// Should he drop the compass after holding it above his head? Causing it to only point west
				// This would be a nice seque into our next quest
				GlobalQuestState.HAS_COMPASS = true;
				GlobalQuestState.currentQuest = FIND_LONK;
			}
		};
	}
}