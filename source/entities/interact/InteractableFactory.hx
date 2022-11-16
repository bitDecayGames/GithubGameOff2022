package entities.interact;

class InteractableFactory {
	public static function make(data:Entity_Interactable):Interactable {
		var index:InteractIndex = data.f_Type.getIndex();
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