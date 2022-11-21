package entities.misc;

import states.PlayState;
import quest.GlobalQuestState;
import flixel.FlxSprite;

class House extends FlxSprite {
	var eData:Entity_House;

	public function new(data:Entity_House) {
		// TODO: Put a filler for when a thing isn't found
		var asset = AssetPaths.crappot__png;
		var yOffset = 0;
		switch(data.f_HouseID) {
			case "Lonk":
				asset = GlobalQuestState.HAS_COMPASS ? AssetPaths.lonkBurned__png : AssetPaths.lonk__png;
				yOffset = 16;
			case "house_cludd":
				asset = AssetPaths.cludds__png;
				yOffset = 16;
			case "cluddsBasement":
				asset = AssetPaths.cluddsBasement__png;
			default:
		}
		super(asset);
		eData = data;
		setPosition(data.pixelX - width/2, data.pixelY - height + yOffset);
		height = height - yOffset;
	}

	public function getDoors():Array<Door> {
		var matches = PlayState.ME.level.l_Entities.all_Door.filter((d) -> {
			for (doorRef in eData.f_Doors) {
				if (doorRef.entityIid == d.iid) {
					return true;
				}
			}
			return false;
		});

		if (eData.f_HouseID == "Lonk" && GlobalQuestState.HAS_COMPASS) {
			return [];
		} else {
			return matches.map((doorEntityData) -> new Door(doorEntityData));
		}
	}
}