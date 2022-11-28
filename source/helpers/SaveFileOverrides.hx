package helpers;

import states.PlayState;
import quest.GlobalQuestState;

class SaveFileOverrides {
    public static function checkForSaveFileOverrides() {

        #if FIGHT_POT_HOME
		GlobalQuestState.currentQuest = Enum_QuestName.Intro;
		GlobalQuestState.subQuest = 4;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = false;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
        PlayState.ME.loadLevel("House_Lonk_1");
		#end

        #if LOOK_FOR_COMPASS_HOME
		GlobalQuestState.currentQuest = Enum_QuestName.Intro;
		GlobalQuestState.subQuest = 4;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
        PlayState.ME.loadLevel("House_Lonk_1");
		#end

		#if LOOK_FOR_COMPASS_CLUDD
		GlobalQuestState.currentQuest = Enum_QuestName.Intro;
		GlobalQuestState.subQuest = 4;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
        PlayState.ME.loadLevel("House_Cludd_Main");
		#end

		#if FIND_LONK_TOWN_MAIN
		GlobalQuestState.currentQuest = Enum_QuestName.Find_lonk;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.LONK_HOUSE_COLLAPSED = true;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
        PlayState.ME.loadLevel("Town_main");
		#end

		#if HAVE_COMPASS_CLUDD
		GlobalQuestState.currentQuest = Enum_QuestName.Find_lonk;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
        PlayState.ME.loadLevel("House_Cludd_Basement");
		#end

		#if HAVE_COMPASS_LONK
		GlobalQuestState.currentQuest = Enum_QuestName.Find_lonk;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
        PlayState.ME.loadLevel("House_Lonk_1");
		#end

		#if HAVE_COMPASS_HOME2
		GlobalQuestState.currentQuest = Enum_QuestName.Get_map;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
        PlayState.ME.loadLevel("House_Lonk_1");
		#end

		#if GO_UNLOCK_GATE_TOWN_MAIN
		GlobalQuestState.currentQuest = Enum_QuestName.Get_map;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
        GlobalQuestState.LONK_HOUSE_COLLAPSED = true;
        PlayState.ME.loadLevel("Town_main");
		#end

		#if GO_TO_HANDYMAN_TOWN_MAIN
		GlobalQuestState.currentQuest = Enum_QuestName.Get_map;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
		GlobalQuestState.HAS_KEY_TO_HANDYMAN = true;
        PlayState.ME.loadLevel("Town_main");
		#end

		#if GO_TO_HANDYMAN_BRINDLE_POT_ROOM
		GlobalQuestState.currentQuest = Enum_QuestName.Get_map;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
		GlobalQuestState.HAS_KEY_TO_HANDYMAN = true;
        PlayState.ME.loadLevel("House_map_spare");
		#end

		#if HAVE_MAP_LONK_HOUSE
		GlobalQuestState.currentQuest = Enum_QuestName.Return_map;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
		GlobalQuestState.HAS_KEY_TO_HANDYMAN = true;
		GlobalQuestState.HAS_MAP = true;
        PlayState.ME.loadLevel("House_Lonk_1");
		#end
    }
}