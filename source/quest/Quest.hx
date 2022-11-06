package source.helpers;

typedef QuestState = {
	var number:Int;
	var step:String;
}

class Quest {
	private static var currentQuestNumber:Int = 0;
	private static var currentQuestStep:String = 'a';

	public function new() {
		incrementCurrentQuestState();
	}

	public function getQuestState():QuestState {
		return {
			number: currentQuestNumber,
			step: currentQuestStep
		}
	}

	// Increment current quest state by looking at the json file then return the incremented quest state
	public function incrementCurrentQuestState():QuestState {
		var nextQuestState = getNextQuestState();
		currentQuestNumber = nextQuestState.number;
		currentQuestStep = nextQuestState.step;
		return getQuestState();
	}

	private function getNextQuestState():QuestState {
		// Query json file
		return {
			number: 0,
			step: 'a'
		}
	}
}
