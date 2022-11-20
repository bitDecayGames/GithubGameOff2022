package entities.interact;

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

		if (!GlobalQuestState.DEFEATED_ALARM_CLOCK){
			helperArrow = new FlxSprite(x, y-56);
			helperArrow.loadGraphic(AssetPaths.arrow_pointing__png, true, 16, 48);
			helperArrow.animation.add("default", [0,1,2,3,4,5,6,7,8,9], 10);
			helperArrow.animation.play("default");
			PlayState.ME.uiHelpers.add(helperArrow);
		}
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

		if (helperArrow != null){
			helperArrow.kill();
		}
	}
}