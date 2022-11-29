package quest;

class GlobalQuestState {
	public static var SPEEDY_DEBUG = #if speedy_debug true #else false #end;

	// Top level quest tracker
	public static var currentQuest(default, set):Enum_QuestName = Enum_QuestName.Wake_up;
	public static var subQuest:Int = 0;

	// FLAGS OUT THE WAZOO
	public static var DEFEATED_ALARM_CLOCK = false;
	public static var WOKEN_FIRST_TIME = false;
	public static var TALKED_TO_LONK_FIRST_TIME = false;
	public static var DEFEATED_RUBBER_POT = false;
	public static var HAS_COMPASS = false;
	public static var LONK_HOUSE_COLLAPSED = false;
	public static var HAS_KEY_TO_HANDYMAN = false;
	public static var HAS_MAP = false;
	public static var HAS_INTERACTED_WITH_GATE = false;

	public static var FINAL_MORNING_TURNED_OFF_ALARM = false;


	public static function getCurrentQuestKey():String {
		return '${GlobalQuestState.currentQuest.getName()}_${GlobalQuestState.subQuest}';
	}

	// misc flags to help us know when to transition quests
	public static var leftHouseFirstTime = false;
	public static var hasCompass = false;

	static function set_currentQuest(value:Enum_QuestName):Enum_QuestName {
		if (currentQuest != value) {
			subQuest = 0;
		}
		return currentQuest = value;
	}
}