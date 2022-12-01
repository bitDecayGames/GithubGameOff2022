package entities.misc;

import entities.interact.GenericInteractable;

class ClockPile extends GenericInteractable {
	public function new(data:Entity_Interactable) {
		super(data);
		visible = true;
		loadGraphic(AssetPaths.clockPile__png);
		setSize(32, 32);
	}
}