package entities.misc;

import flixel.FlxSprite;

class House extends FlxSprite {
	public function new(data:Entity_House) {
		// TODO: Put a filler for when a thing isn't found
		var asset = AssetPaths.crappot__png;
		switch(data.f_HouseID) {
			case "Lonk":
				asset = AssetPaths.lonk__png;
			default:
		}
		super(asset);
		setPosition(data.pixelX - width/2, data.pixelY - height + 16);
		height = height - 16;

		// TODO: these numbers likely need to be adjusted per house once we get more of them
	}
}