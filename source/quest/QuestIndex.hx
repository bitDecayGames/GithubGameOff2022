package quest;

enum abstract QuestIndex(String) to String from String {
	var WAKE_UP = "wake_up";
	var INTRO = "intro";
	var FIND_LONK = "findLonk";

	public function GetFlavorText():String {
		return switch(this){
			case WAKE_UP:
				return switch(GlobalQuestState.subQuest) {
					case 0:
						" ";
					case 1:
						"Turn off alarm";
					default:
						"Unknown subquest";
				}
			case INTRO:
				return switch(GlobalQuestState.subQuest) {
					case 2: // Alarm turned off
						" ";
					case 3: // Talked to Lonk 
						"Fight the training pot";
					case 4: // Fought the pot
						" ";
					case 5: // Talked to Lonk after fighting the pot
						"Get compass from Cludd's";
					default:
						"Unknown subquest";
				}
			case FIND_LONK:
				return switch(GlobalQuestState.subQuest) {
					case 0: // Bring the compass back to Lonk
						"return the compass";
					default:
						"Unknown subquest";
				}
			default:
				"Unknown quest";
		}
	}
}