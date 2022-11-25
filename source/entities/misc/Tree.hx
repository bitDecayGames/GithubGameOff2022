package entities.misc;

import entities.interact.Interactable;

class Tree extends Interactable {
	public function new(data:Entity_Interactable) {
		// All these numbers were pulled from looking at the image directly
		super(data.pixelX-16, data.pixelY-6, NONE);
		loadGraphic(AssetPaths.trees__png);
		setSize(32, 14);
		offset.set(16, 60);
	}
}