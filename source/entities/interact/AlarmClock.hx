package entities.interact;

import encounters.CharacterIndex;
import encounters.CharacterDialog;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;
import states.battles.AlarmClockState;

class AlarmClock extends Interactable {

	var helperArrow:FlxSprite;

	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, ALARM_CLOCK);
		loadGraphic(AssetPaths.clock__png, true, 16, 16);
		animation.add('steady', [0]);
		animation.add('blink', [0,1], 2);
		animation.add('broken', [2]);
		if (GlobalQuestState.currentQuest == Enum_QuestName.Final_morning) {
			// XXX: special handling for final morning
			if (GlobalQuestState.FINAL_MORNING_TURNED_OFF_ALARM) {
				animation.play('steady');
			} else {
				animation.play('blink');
			}
		} else if (GlobalQuestState.DEFEATED_ALARM_CLOCK) {
			animation.play('broken');
		} else {
			animation.play('steady');
		}
		immovable = true;

		PlayState.ME.eventSignal.addOnce((s) -> {
			if (s == "alarmStart") {
				animation.play('blink');
			}
		});
	}

	override function interact() {
		if (GlobalQuestState.currentQuest == Enum_QuestName.Final_morning) {
			FmodManager.PlaySoundOneShot(FmodSFX.AlarmClickFinal);
			GlobalQuestState.FINAL_MORNING_TURNED_OFF_ALARM = true;
			GlobalQuestState.subQuest = 2;
			animation.play('steady');
			FmodManager.StopSongImmediately();
			return;
		}


		if (GlobalQuestState.DEFEATED_ALARM_CLOCK) {
			dialogBox.loadDialogLine("<cb val=happy/>ZZZZZZZZZZZZ");
			PlayState.ME.openDialog(dialogBox);
			return;
		}

		FmodManager.StopSongImmediately();
		FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
		var substate = new AlarmClockState(new CharacterDialog(
			CharacterIndex.ALARM_CLOCK,
			"<speed mod=100>BEEP<pause t=0.65 /> BEEP<pause t=0.65 /> BEEP<pause t=0.65 /> BEEP<pause t=0.65 /> BEEP<pause t=0.65 /> BEEP<pause t=0.65 />"));
		substate.closeCallback = () -> {
			if (substate.success) {
				animation.play('broken');
			}
		};
		PlayState.ME.startEncounter(substate);

		if (helperArrow != null){
			helperArrow.kill();
		}
	}
}