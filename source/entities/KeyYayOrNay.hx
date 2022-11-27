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
				// Player can never get into cludd's front door
				return false;
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
				return "There is no knob... It's just painted to look like a doorknob. Strange.<page/>This is definitely Cludd's house, there must be another way in.";
			default:
				return "The door is locked";
		}
	}
}