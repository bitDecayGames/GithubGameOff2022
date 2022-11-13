package entities.npcs;

import quest.GlobalQuestState;
import flixel.FlxG;
import characters.BasicPot;
import encounters.CharacterIndex;

class NPCFactory {
	public static function make(data:Entity_NPC):NPC {
		var index:CharacterIndex = data.f_character.getIndex();
		if (!data.f_show_for_quests.contains(GlobalQuestState.currentQuest) &&
				!data.f_show_for_quests.contains(GlobalQuestState.getCurrentQuestKey())) {
			FlxG.log.notice('npc "${data.f_character.getName()}" will not spawn for quest ${GlobalQuestState.getCurrentQuestKey()}');
			return null;
		}
		switch(index) {
			case LONK:
				return new Lonk(data);
			default:
				throw 'unknown npc entity ${data.f_character.getName()}';
		}
	}
}