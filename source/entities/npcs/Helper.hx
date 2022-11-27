package entities.npcs;

import flixel.util.FlxTimer;
import flixel.FlxG;
import com.bitdecay.lucidtext.parse.TagLocation;
import flixel.math.FlxMath;
import quest.GlobalQuestState;
import entities.library.NPCTextBank;
import states.PlayState;
import flixel.FlxCamera.FlxCameraFollowStyle;


class Helper extends NPC {
	public function new(data:Entity_NPC) {
		super(data);
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);

		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "panToLonkHouse") {
				for (house in PlayState.ME.houses) {
					if (house.eData.f_HouseID == "Lonk") {
						FlxG.camera.follow(house, FlxCameraFollowStyle.LOCKON, 0.05);
					}
				}
			}
			if (tag.parsedOptions.val == "panToPlayer") {
				FlxG.camera.follow(PlayState.ME.player, FlxCameraFollowStyle.TOPDOWN_TIGHT, 0.05);
				new FlxTimer().start(2, (t) -> {
					FlxG.camera.followLerp = 100; // this will get auto-capped at the default for us;
				});
			}
			if (tag.parsedOptions.val == "lonk_ok") {
				FmodManager.StopSong();
			}
			if (tag.parsedOptions.val == "exploreWest") {
				GlobalQuestState.subQuest = 2;
			}
		}
	}
	

	override function dialogFinished() {
		super.dialogFinished();
		if (GlobalQuestState.currentQuest == Enum_QuestName.Find_lonk){
			FmodManager.PlaySong(FmodSongs.AwakenSofterC);
		}
	}
}