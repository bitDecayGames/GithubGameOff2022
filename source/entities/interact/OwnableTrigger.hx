package entities.interact;

import flixel.util.FlxStringUtil;
import flixel.FlxObject;
import states.PlayState;

class OwnableTrigger extends GenericInteractable {
	static var interactedWith = false;

	public var owner:Interactable;

	public var data:Entity_Interactable;

	var triggerKey:String;

	public function new(data:Entity_Interactable) {
		super(data);
		this.data = data;
		allowCollisions = FlxObject.NONE;
		triggerKey = data.f_Key;
	}

	override function interact() {
		// can't interact directly with this thing
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (!FlxStringUtil.isNullOrEmpty(triggerKey)) {
			if (InteractableFactory.collected.exists(triggerKey)) {
				kill();
			}
		}

		if (owner != null && PlayState.ME.player.overlaps(this)) {
			if (!FlxStringUtil.isNullOrEmpty(triggerKey)) {
				InteractableFactory.collected.set(triggerKey, true);
			}
			owner.interact();
			// TODO: is this bad
			kill();
		}
	}
}