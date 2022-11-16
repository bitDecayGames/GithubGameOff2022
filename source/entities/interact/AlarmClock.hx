package entities.interact;

import quest.GlobalQuestState;
import states.PlayState;
import states.battles.AlarmClockState;

class AlarmClock extends Interactable {
	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, ALARM_CLOCK);
		loadGraphic(AssetPaths.clock__png, true, 16, 16);
		animation.add('steady', [0]);
		animation.add('blink', [0,1], 2);
		animation.add('broken', [1], 2);
		if (GlobalQuestState.DEFEATED_ALARM_CLOCK) {
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
		if (GlobalQuestState.DEFEATED_ALARM_CLOCK) {
			dialogBox.loadDialogLine("<cb val=happy/>ZZZZZZZZZZZZ");
			PlayState.ME.openDialog(dialogBox);
			return;
		}

		FmodManager.StopSongImmediately();
		FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
		var substate = new AlarmClockState();
		substate.closeCallback = () -> {
			if (substate.success) {
				animation.play('broken');
			}
		};
		PlayState.ME.startEncounter(substate);
	}
}