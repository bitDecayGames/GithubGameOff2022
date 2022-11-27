package states;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import states.battles.EncounterBaseState;
import states.battles.AlarmClockState;
import states.battles.PotBattleState;
import encounters.CharacterDialog;
import flixel.FlxState;

class LonkFinalFightState extends FlxState {
	var dialog:CharacterDialog;
	var battleDialog:CharacterDialog;

	override function create() {
		super.create();

		var test = new FlxSprite();
		test.makeGraphic(32, 32, FlxColor.BROWN);
		test.screenCenter();
		add(test);

		dialog = new CharacterDialog(LONK, "Now that you've collected everything I need. " +
		"I'll be taking that and going on my own adventure!<page/>PREPARE THYSELF");
		dialog.textGroup.finishCallback = dialogFinished;
		add(dialog);

		battleDialog = new CharacterDialog(LONK, "");
	}

	function dialogFinished() {
		dialog.kill();
		nextPhase();
	}

	function updateBattleText() {
		battleDialog.revive();
		battleDialog.loadDialogLine("Give me the <color id=keyItem>map</color> and the <color id=keyItem>compass</color>.");
		// battleDialog.loadDialogLine("<cb val=mad/>This has been my adventure the whole time.");
	}

	function openBattle(phase:EncounterBaseState) {
		openSubState(phase);
		phase.closeCallback = () -> {
			if (phase.success) {
				// we seem to need to delay the next phase slightly for it to
				// open correctly
				new FlxTimer().start(3, (t) -> {
					nextPhase();
				});
			}
		};
	}

	function nextPhase() {
		updateBattleText();
		openBattle(new PotBattleState(battleDialog, LONK));
	}
}