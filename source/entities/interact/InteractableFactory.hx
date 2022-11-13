package entities.interact;

import characters.BasicPot;
import encounters.CharacterIndex;

class InteractableFactory {
	public static function make(data:Entity_Interactable):Interactable {
		var index:InteractIndex = data.f_Type.getIndex();
		switch(index) {
			case ALARM_CLOCK:
				return new AlarmClock(data.cx * Constants.TILE_SIZE, data.cy * Constants.TILE_SIZE);
			case POT_RUBBER:
				//TODO spawn right thing
				return new AlarmClock(data.cx * Constants.TILE_SIZE, data.cy * Constants.TILE_SIZE);
			default:
				throw 'unknown interactable entity ${data.f_Type.getName()}';
		}
	}
}