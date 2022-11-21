package states;

import states.battles.ChestBattle;
import states.battles.GateState;
import encounters.CharacterDialog;
import flixel.FlxState;
import states.battles.PotBattleState;

using states.FlxStateExt;

class TestEncounterState extends FlxState {
	override public function create():Void {
		super.create();

		// openSubState(new PotBattleState(new CharacterDialog(POT, "POT")));
		openSubState(new ChestBattle());
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
