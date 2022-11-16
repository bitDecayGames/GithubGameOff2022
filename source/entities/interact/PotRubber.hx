package entities.interact;

import encounters.CharacterDialog;
import states.battles.PotBattleState;
import states.PlayState;

class PotRubber extends Interactable {
	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, POT);
		loadGraphic(AssetPaths.interiorDecorations__png, true, 16, 16);
		animation.frameIndex = 2;
		immovable = true;
	}

	override function interact() {
		FmodManager.StopSongImmediately();
		FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
		var substate = new PotBattleState(new CharacterDialog(POT, "Take your best shot"), RUBBERPOT);
		PlayState.ME.startEncounter(substate);
		substate.closeCallback = () -> {
			if (substate.success) {
				PlayState.ME.eventSignal.dispatch('rubberPotDefeated');
			}
		};
	}
}