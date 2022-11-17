package entities.interact;

class InteractableFactory {
	public static var defeated = new Map<String, Bool>();

	public static function make(data:Entity_Interactable):Interactable {
		var index:InteractIndex = data.f_Type.getIndex();
		if (defeated.exists(data.f_Key)) {
			return null;
		}

		switch(index) {
			case ALARM_CLOCK:
				return new AlarmClock(data);
			case POT_RUBBER:
				return new PotRubber(data);
			case POT_NORMAL:
				return new PotNormal(data);
			default:
				throw 'unknown interactable entity ${data.f_Type.getName()}';
		}
	}
}