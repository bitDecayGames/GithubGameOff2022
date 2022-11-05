package entities;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class NPC extends FlxSprite {
	public function new(data:Entity_NPC) {
		super(data.cx * Constants.TILE_SIZE, data.cy * Constants.TILE_SIZE);
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.LIME);
	}

	public function interact() {
		
	}
}