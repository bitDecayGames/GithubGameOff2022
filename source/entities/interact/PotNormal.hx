package entities.interact;

import flixel.util.FlxTimer;
import shaders.BlinkHelper;
import quest.GlobalQuestState;
import encounters.CharacterDialog;
import states.battles.PotBattleState;
import states.PlayState;

class PotNormal extends Interactable {
	var data:Entity_Interactable;

	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE);
		this.data = data;
		loadGraphic(AssetPaths.interiorDecorations__png, true, 16, 16);
		animation.frameIndex = 2;
		immovable = true;
	}

	override function interact() {
		FmodManager.StopSongImmediately();
		FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
		var substate = new PotBattleState(new CharacterDialog(NONE, "It is a basic, uninteresting pot"));
		PlayState.ME.startEncounter(substate);
		substate.closeCallback = () -> {
			if (substate.success) {
				// if (data.f_Key == "compass") {
				// 	// PlayState.ME.eventSignal.dispatch('compassCollected');
				// 	// TODO: rejoice in your new compass!
				// 	// Should he drop the compass after holding it above his head? Causing it to only point west
				// 	// This would be a nice seque into our next quest
				// 	GlobalQuestState.HAS_COMPASS = true;
				// 	GlobalQuestState.currentQuest = Enum_QuestName.Find_lonk;
				// }

				InteractableFactory.defeated.set(data.f_Key, true);
				var blinkTiming = 0.2;
				var blinkCount = 5;
				BlinkHelper.Blink(this, blinkTiming, blinkCount);
				new FlxTimer().start(blinkTiming * blinkCount, (t) -> {
					kill();
				});
			}
		};
	}
}