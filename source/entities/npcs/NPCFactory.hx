package entities.npcs;

import quest.GlobalQuestState;
import flixel.FlxG;
import characters.BasicPot;
import encounters.CharacterIndex;

class NPCFactory {
	public static function make(data:Entity_NPC):NPC {
		var index:CharacterIndex = data.f_character.getIndex();
		// empty `show_for_quests` implies that NPC should always spawn
		if (data.f_show_for_quests.length > 0 && !data.f_show_for_quests.contains(GlobalQuestState.currentQuest.getName()) &&
				!data.f_show_for_quests.contains(GlobalQuestState.getCurrentQuestKey())) {
			FlxG.log.notice('npc "${data.f_character.getName()}" will not spawn for quest ${GlobalQuestState.getCurrentQuestKey()}');
			return null;
		}
		if (data.f_hide_for_quests.contains(GlobalQuestState.currentQuest.getName()) ||
				data.f_hide_for_quests.contains(GlobalQuestState.getCurrentQuestKey())) {
			FlxG.log.notice('npc "${data.f_character.getName()}" explicitly hidden for quest ${GlobalQuestState.getCurrentQuestKey()}');
			return null;
		}
		switch(index) {
			case LONK:
				return new Lonk(data);
			case WOMAN:
				return new Helper(data);
			case CLUDD:
				return new Cludd(data);
			case CRAFTSMAN:
				return new Craftsman(data);
			default:
				throw 'unknown npc entity ${data.f_character.getName()}';
		}
	}
}