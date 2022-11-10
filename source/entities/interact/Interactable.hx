package entities.interact;

import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Interactable extends FlxSprite {
	public function new(X:Float, Y:Float) {
		super(X, Y);
		makeGraphic(Constants.TILE_SIZE, Constants.TILE_SIZE, FlxColor.YELLOW);
		immovable = true;
	}

	public function interact() {
		// TODO: will need to subclass this to have each thing do its own interaction
		// PlayState.ME.startEncounter(<SUB STATE>);
	}
}