package helpers;

import states.PlayState;
import quest.GlobalQuestState;

class SaveFileOverrides {
    public static function checkForSaveFileOverrides() {
        
        #if LOOK_FOR_COMPASS_HOME
		GlobalQuestState.currentQuest = INTRO;
		GlobalQuestState.subQuest = 4;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
        PlayState.ME.loadLevel("House_Lonk_1");
		#end

		#if LOOK_FOR_COMPASS_CLUDD
		GlobalQuestState.currentQuest = INTRO;
		GlobalQuestState.subQuest = 4;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
        PlayState.ME.loadLevel("House_Cludd_Main");
		#end

		#if HAVE_COMPASS_CLUDD
		GlobalQuestState.currentQuest = GET_MAP;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
        PlayState.ME.loadLevel("House_Cludd_Basement");
		#end

		#if HAVE_COMPASS_HOME2
		GlobalQuestState.currentQuest = GET_MAP;
		GlobalQuestState.subQuest = 0;
		GlobalQuestState.DEFEATED_ALARM_CLOCK = true;
		GlobalQuestState.DEFEATED_RUBBER_POT = true;
		GlobalQuestState.TALKED_TO_LONK_FIRST_TIME = true;
		GlobalQuestState.WOKEN_FIRST_TIME = true;
		GlobalQuestState.leftHouseFirstTime = true;
		GlobalQuestState.HAS_COMPASS = true;
        PlayState.ME.loadLevel("House_Lonk_1");
		#end
    }
}