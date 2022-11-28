package states;

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
		
		dialog = new CharacterDialog(LONK, "Now that you've collected everything I need, I'll be taking it and going on my own adventure!<page/>
		What's wrong?<pause t=0.5/>
		 <cb val=mad/>You thought this was all for you?<page/> 
		<cb val=happy/>Dear child<speed mod=.2>...</speed><page/>
		<cb val=neutral/>You were never fit for adventure.<pause t=0.5/> You are too small.<pause t=0.25/> Too weak.<page/>
		<cb val=neutral/>Now give everything to me before I get impatient<speed mod=.05>...</speed><page/>
		No?<page/>
		<cb val=happy/>Ok then.<page/>
		<cb val=mad/><bigger><shake>I will take it!</shake></bigger>");
		dialog.textGroup.finishCallback = dialogFinished;
		dialog.textGroup.tagCallback = handleTagCallback;
		add(dialog);
	}

	function dialogFinished() {
		dialog.kill();
		nextPhase();
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
			}
		};
	}

	function nextPhase() {
		battleDialog.revive();

		phaseIndex++;
		switch phaseIndex {
			case 1:
				battleDialog.loadDialogLine("Give me the <color id=keyItem>map</color> and the <color id=keyItem>compass</color>.");
				openBattle(new PotBattleState(battleDialog, LONK, true));
			case 2:
				battleDialog.loadDialogLine("This is <shake>MY ADVENTURE</shake>.");
				openBattle(new AlarmClockState(battleDialog, LONK));
			case 3:
				// TODO: Done, roll credits
			default:
		}
	}

	public function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {

			if (false) {

			} else {
				dialog.setExpression(tag.parsedOptions.val);
			}
		}
	}
}