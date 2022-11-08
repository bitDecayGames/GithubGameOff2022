package quest;

import config.Validator;

typedef QuestState = {
	var number:Int;
	var step:Int;
}

class Quest {
	private static var currentQuest = {number: 0, step: 0};

	public function new() {
		incrementCurrentQuestState();
	}

	public function getQuestState():QuestState {
		return currentQuest;
	}

	// Increment current quest state by looking at the json file then return the incremented quest state
	public function incrementCurrentQuestState():QuestState {
		currentQuest = getNextQuestState();
		return getQuestState();
	}

	private function getNextQuestState():QuestState {
		var questList = Validator.load("assets/data/quest_list.json");

		function getNextStep(currentStep:Int, steps:Array<Int>):Int {
			for (step in steps) {
				if (currentStep + 1 == step) {
					return step;
				}
			}
			throw "getNextStep(): CurrentStep has exceeded input steps. Something TERRIBLE has happened!";
		}

		for (quest in questList.quests) {
			if (currentQuest.number + 1 == quest.number) {
				return {
					number: quest.number,
					step: getNextStep(currentQuest.step, quest.steps)
				}
			}
		}
		throw "getNextQuestState(): CurrentQuestNumber has exceeded questList quests. Something TERRIBLE has happened!!";
	}
}
