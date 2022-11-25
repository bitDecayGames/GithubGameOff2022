package entities.misc;

import entities.interact.Interactable;

class Boulder extends Interactable {
	public function new(data:Entity_Interactable) {
		super(data.pixelX-16, data.pixelY+3, NONE);
		loadGraphic(AssetPaths.boulder__png);
		setSize(32, 14);
		offset.set(0, 16);
	}
}