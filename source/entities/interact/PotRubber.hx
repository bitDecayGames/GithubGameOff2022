package entities.interact;

import encounters.CharacterDialog;
import encounters.CharacterIndex;
import states.battles.PotBattleState;
import quest.GlobalQuestState;
import states.PlayState;
import states.battles.AlarmClockState;

class PotRubber extends Interactable {
	public function new(X:Float, Y:Float) {
		super(X, Y, ALARM_CLOCK);
		loadGraphic(AssetPaths.interiorDecorations__png, true, 16, 16);
		animation.frameIndex = 2;
		immovable = true;
	}

	override function interact() {
		FmodManager.StopSongImmediately();
		FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
		var substate = new PotBattleState(new CharacterDialog(POT, "Take your best shot"));
		PlayState.ME.startEncounter(substate);
	}
}