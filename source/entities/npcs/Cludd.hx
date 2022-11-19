package entities.npcs;

import com.bitdecay.lucidtext.parse.TagLocation;

class Cludd extends NPC {
	public function new(data:Entity_NPC) {
		super(data);
	}

	override public function handleTagCallback(tag:TagLocation) {
		super.handleTagCallback(tag);
	}
}