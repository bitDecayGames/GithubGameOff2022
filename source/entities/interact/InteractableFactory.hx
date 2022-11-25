package entities.interact;

class InteractableFactory {
	public static var defeated = new Map<String, Bool>();
	public static var collected = new Map<String, Bool>();

	public static function make(data:Entity_Interactable):Interactable {
		var index:InteractIndex = data.f_Type.getIndex();
		if (defeated.exists(data.f_Key)) {
			return null;
		}

		switch(index) {
			case LOAD_TILE:
				return new GenericInteractable(data);
			case ALARM_CLOCK:
				return new AlarmClock(data);
			case POT_RUBBER:
				return new PotRubber(data);
			case POT_NORMAL:
				return new PotNormal(data);
			case CHEST:
				return new Chest(data);
			case GATE:
				return new Gate(data);
			case MAP:
				return new MapInteractable(data);
			default:
				return new Chest(data);
				// throw 'unknown interactable entity ${data.f_Type.getName()}';
		}
	}
}