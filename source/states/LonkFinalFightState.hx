package states;

import flixel.FlxG;
import states.battles.ChestBattle;
import com.bitdecay.lucidtext.parse.TagLocation;
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

	var phaseIndex = 0;

	var fightEnded = false;

	override function create() {
		super.create();


		// var test = new FlxSprite();
		// test.makeGraphic(32, 32, FlxColor.BROWN);
		// test.screenCenter();
		// add(test);

		battleDialog = new CharacterDialog(LONK, "");
		#if skip_to_fight
		nextPhase();
		#end

		dialog = new CharacterDialog(LONK, "");
		dialog.textGroup.finishCallback = dialogFinished;
		dialog.textGroup.tagCallback = handleTagCallback;
		dialog.kill();
		add(dialog);

		nextPhase();
	}

	function dialogFinished() {
		dialog.kill();

		if (fightEnded) {
			// transition to whatever the ending is
			FlxG.switchState(new CreditsState());
		} else {
			nextPhase();
		}
	}

	function openBattle(phase:EncounterBaseState) {
		openSubState(phase);
		phase.closeCallback = () -> {
			if (phase.success) {
				// we seem to need to delay the next phase slightly for it to
				// open correctly
				new FlxTimer().start(0.1, (t) -> {
					nextPhase();
				});
			} else {
				FlxG.switchState(new PlayState("House_Lonk_1"));
			}
		};
	}

	function nextPhase() {
		battleDialog.revive();

		phaseIndex++;
		switch phaseIndex {
			case 1:
				battleDialog.loadDialogLine("Give me the <color id=keyItem>map</color> and the <color id=keyItem>compass</color>.");
				openBattle(new PotBattleState(battleDialog, true));
			case 2:
				battleDialog.loadDialogLine("This is <shake>MY ADVENTURE</shake>.");
				openBattle(new AlarmClockState(battleDialog, true));
			case 3:
				battleDialog.loadDialogLine("TEXT NEEDED HERE!");
				openBattle(new ChestBattle(battleDialog, true));
			case 4:
				fightEnded = true;
				dialog.revive();
				dialog.loadDialogLine("I can't believe this 'yatta yatta'. I am slain.");
			default:
		}
	}

	public function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {

			if (false) {
				// handle other callbacks if we want them
			} else {
				dialog.setExpression(tag.parsedOptions.val);
			}
		}
	}
}