package quest;

class GlobalQuestState {
	public static var SPEEDY_DEBUG = #if speedy_debug true #else false #end;

	// Top level quest tracker
	public static var currentQuest(default, set):QuestIndex = WAKE_UP;
	public static var subQuest:Int = 0;

	// FLAGS OUT THE WAZOO
	public static var DEFEATED_ALARM_CLOCK = false;
	public static var WOKEN_FIRST_TIME = false;
	public static var TALKED_TO_LONK_FIRST_TIME = false;
	public static var DEFEATED_RUBBER_POT = false;
	public static var HAS_COMPASS = false;


	public static function getCurrentQuestKey():String {
		return '${GlobalQuestState.currentQuest}_${GlobalQuestState.subQuest}';
	}

	// misc flags to help us know when to transition quests
	public static var leftHouseFirstTime = false;
	public static var hasCompass = false;

	static function set_currentQuest(value:QuestIndex):QuestIndex {
		if (currentQuest != value) {
			subQuest = 0;
		}
		return currentQuest = value;
	}
}