package entities;

import flixel.FlxG;
import quest.GlobalQuestState;
import quest.KeyIndex;

class KeyYayOrNay implements YayOrNay {
	var myKey:KeyIndex;

	public function new(key:KeyIndex) {
		myKey = key;
	}

	public function CheckDoor(d:Door):Bool {
		switch(myKey) {
			case(HANDYMAN):
				return GlobalQuestState.HAS_KEY_TO_HANDYMAN;
			default:
				FlxG.log.warn('unknown key check for key $myKey');
				return false;
		}
	}

	public function Why():String {
		return "The door is locked";
	}
}