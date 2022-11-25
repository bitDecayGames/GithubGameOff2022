package entities.interact;

import states.battles.MapState;
import flixel.FlxObject;
import states.battles.GateState;
import quest.QuestIndex;
import states.battles.ChestBattle;
import com.bitdecay.lucidtext.parse.TagLocation;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class MapInteractable extends Interactable {

	var opened = false;
	var contentKey:String;

	public function new(data:Entity_Interactable) {
		super(data.pixelX-8, data.pixelY, NONE);
		contentKey = data.f_Key;
		loadGraphic(AssetPaths.mapHanging__png, true, 32, 32);
		animation.add('present', [0]);
		animation.add('taken', [1]);
		immovable = true;
		allowCollisions = FlxObject.NONE;

		// TODO: Check global state to see if this map was already taken
		if (InteractableFactory.collected.exists(contentKey)) {
			animation.play('taken');
			opened = true;
		}
	}

	override function interact() {
		if (!opened) {
			var substate = new MapState();
			FmodManager.StopSongImmediately();
			FmodManager.PlaySoundOneShot(FmodSFX.BattleStart);
			PlayState.ME.startEncounter(substate);
			substate.closeCallback = () -> {
				if (substate.success) {
					InteractableFactory.collected.set(contentKey, true);
					animation.play('taken');
					opened = true;
				}
			};
		} else {
			dialogBox.loadDialogLine("It's just an empty frame with some holes poked in the corkboard");
			PlayState.ME.openDialog(dialogBox);
		}
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
		if (tag.tag == "cb") {
		}
	}
}