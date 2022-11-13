package quest;

// import encounters.CharacterIndex;
// import entities.NPC;
// import config.Validator;

// typedef QuestState = {
// 	var index:Int;
// 	var name:String;
// 	var step:QuestStep;
// }

// typedef QuestStep = {
// 	var num:Int;
// 	var reqs:Requirements;
// }

// typedef Requirements = {
// 	var talk:Null<Array<String>>;
// }

// class Quest {
// 	public static var ME(get, null):Quest;

// 	private static var currentQuest = {index: -1, name: "", step: null};

// 	public static function get_ME():Quest {
// 		if (ME == null) {
// 			ME = new Quest();
// 		}

// 		return ME;
// 	}

// 	private function new() {
// 		incrementCurrentQuestState();
// 	}

// 	public function getQuestState():QuestState {
// 		return currentQuest;
// 	}

// 	// Increment current quest state by looking at the json file then return the incremented quest state
// 	public function incrementCurrentQuestState():QuestState {
// 		currentQuest = getNextQuestState();
// 		return getQuestState();
// 	}

// 	private function getNextQuestState():QuestState {
// 		var questList = Validator.load("assets/data/quest_list.json");

// 		function getNextStep(currentStep:Int, steps:Array<Int>):Int {
// 			for (step in steps) {
// 				if (currentStep + 1 == step) {
// 					return step;
// 				}
// 			}
// 			throw "getNextStep(): CurrentStep has exceeded input steps. Something TERRIBLE has happened!";
// 		}

// 		for (i in 0...questList.quests.length) {
// 			if (currentQuest.index + 1 == i) {
// 				return {
// 					index: i,
// 					name: questList.quests[i].name,
// 					step: getNextStep(currentQuest.step.num, questList.quests[i].steps)
// 				}
// 			}
// 		}
// 		throw "getNextQuestState(): CurrentQuestNumber has exceeded questList quests. Something TERRIBLE has happened!!";
// 	}
// }
