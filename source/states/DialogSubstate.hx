package states;

import encounters.CharacterDialog;
import flixel.FlxSubState;

class DialogSubstate extends FlxSubState {
	var dialog:CharacterDialog;

	public function new(dialog:CharacterDialog) {
		super();
		this.dialog = dialog;
	}

	override function create() {
		super.create();

	}
}