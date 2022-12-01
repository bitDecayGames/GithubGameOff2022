package entities.interact;

import openfl.net.URLRequest;
import flixel.FlxSprite;
import quest.GlobalQuestState;
import states.PlayState;

class Gameboy extends GenericInteractable {
	static var interactedWith = false;

	public function new(data:Entity_Interactable) {
		super(data);
	}

	// override function interact() {
	// 	if (interactedWith) {
	// 		// take them to the link!
	// 		openfl.Lib.getURL(new URLRequest("https://bitdecaygames.itch.io/odd-verdure"));
	// 		return;
	// 	}
	// 	super.interact();
	// 	interactedWith = true;
	// }
}