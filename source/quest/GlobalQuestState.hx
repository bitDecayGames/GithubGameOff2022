package quest;

class GlobalQuestState {
	// Top level quest tracker
	public static var currentQuest:QuestIndex = INTRO;
	public static var subQuest:Int = 0;

	// FLAGS OUT THE WAZOO
	public static var DEFEATED_ALARM_CLOCK = false;


	public static function getCurrentQuestKey():String {
		return '${GlobalQuestState.currentQuest}_${GlobalQuestState.subQuest}';
	}

	// misc flags to help us know when to transition quests
	public static var hasCompass = false;
}