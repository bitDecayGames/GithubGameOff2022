package quest;

class QuestNameExt {
	public static function GetFlavorText(questName:Enum_QuestName) {
		return switch(questName){
			case Enum_QuestName.Wake_up:
				return switch(GlobalQuestState.subQuest) {
					case 0:
						" ";
					case 1:
						buildFlavorText("Turn off alarm");
					default:
						"Unknown subquest";
				}
			case Enum_QuestName.Intro:
				return switch(GlobalQuestState.subQuest) {
					case 2: // Alarm turned off
						" ";
					case 3: // Talked to Lonk
						buildFlavorText("Fight the training pot");
					case 4: // Fought the pot
						" ";
					case 5: // Talked to Lonk after fighting the pot
						buildFlavorText("Get compass from Cludd's");
					default:
						"Unknown subquest";
				}
			case Enum_QuestName.Find_lonk:
				return switch(GlobalQuestState.subQuest) {
					case 0: // Bring the compass back to Lonk
						buildFlavorText("Return the compass");
					case 1: // Investigate Lonk's house (after collapse)
						buildFlavorText("Check on home");
					case 2:
						buildFlavorText("Explore West");
					default:
						buildFlavorText("Unknown subquest");
				}
			case Enum_QuestName.Get_map:
				return switch(GlobalQuestState.subQuest) {
					case 0: // Bring the compass back to Lonk
						buildFlavorText("Find the map");
					default:
						buildFlavorText("Unknown subquest");
				}
			case Enum_QuestName.Return_map:
				return switch(GlobalQuestState.subQuest){
					default:
						buildFlavorText("Return the map");
				}
			default:
				"Unknown quest";
		}
	}

	private static function buildFlavorText(flavorText:String) {
		return "Task: "+flavorText;
	}

	public static function subQuestKey(questName:Enum_QuestName, subQuestNum:Int):String {
		return '${questName.getName()}_$subQuestNum';
	}
}
