package entities;

import flixel.FlxG;
import quest.GlobalQuestState;

class KeyYayOrNay implements YayOrNay {
	var myKey:Enum_Keys;

	public function new(key:Enum_Keys) {
		myKey = key;
	}

	public function CheckDoor(d:Door):Bool {
		switch(myKey) {
			case Enum_Keys.Handyman:
				return GlobalQuestState.HAS_KEY_TO_HANDYMAN;
			case Enum_Keys.Cludd_frontdoor:
				// only once they've come out of his door is it unlocked
				return GlobalQuestState.HAS_USED_CLUDDS_DOOR;
			default:
				FlxG.log.warn('unknown key check for key $myKey');
				return false;
		}
	}

	public function Why():String {
		switch(myKey) {
			case Enum_Keys.Handyman:
				return "The door is locked";
			case Enum_Keys.Cludd_frontdoor:
				return "This is Cludd's house, but the door is locked.<page/>There must be another way inside.";
			default:
				return "The door is locked";
		}
	}
}