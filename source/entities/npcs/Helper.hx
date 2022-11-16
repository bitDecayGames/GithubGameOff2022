package entities.npcs;

import com.bitdecay.lucidtext.parse.TagLocation;
import flixel.math.FlxMath;
import quest.GlobalQuestState;
import entities.library.NPCTextBank;
import states.PlayState;

class Helper extends NPC {
	public function new(data:Entity_NPC) {
		super(data);
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
	}
}