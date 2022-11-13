package entities.interact;

import flixel.util.FlxColor;
import states.PlayState;
import states.battles.AlarmClockState;

class AlarmClock extends Interactable {
	public function new(X:Float, Y:Float) {
		super(X, Y);
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.YELLOW);
		immovable = true;
	}

	override function interact() {
		FmodManager.StopSongImmediately();
		FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
		PlayState.ME.startEncounter(new AlarmClockState());
	}
}