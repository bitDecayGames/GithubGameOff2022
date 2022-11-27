package entities.library;

import encounters.CharacterIndex;

class NPCTextBank {
	// In theory this is a map that holds characters as the key
	//    the value is a map of quest ID's (effectively just some progression ID) to the things they should
	//    say at that point in the game. We'll have to talk about how we want to orgainize this
	public static var all:Map<CharacterIndex, Map<String, Array<String>>> = [
		LONK => [
			'${Enum_QuestName.Wake_up}_0' => [
				"Are you going to leave that alarm clock beeping all day?<cb val=turn_off_clock />"
			],
			'${Enum_QuestName.Wake_up}_1' => [
				"Go turn off your alarm..."
			],
			'${Enum_QuestName.Intro}_2' => [
				"<cb val=happy />Today is the big day!<page/>" +
				"By<cb val=neutral /> the end of the week, you'll be an adventurer just like I used to be.<page/>" +
				"I used to <cb val=mad /><shake>destroy</shake><cb val=neutral /> pottery. Today, I'd love to teach you the ancient art.<page/>" +
				"<cb val=happy />You see that <color id=keyItem>rubber pot</color> over there? Attack it swiftly. Aim for the <color id=hint>weak points</color>.<page/><cb val=informed_of_rubber_pot />",
			],
			'${Enum_QuestName.Intro}_3' => [
				"<cb val=mad /><shake>Obliterate it!</shake>",
				"<cb val=neutral/>Keep trying until you've proven you can break it"
			],
			'${Enum_QuestName.Intro}_4' => [
				"<cb val=happy />Well done, Boy! You're ready to begin preparations. I need you to collect my <color id=keyItem>compass</color> from Cludd's house on the " +
				"north side of town.<cb val=informed_of_compass />"
			],
			'${Enum_QuestName.Intro}_5' => [
				"Come back here once you have my <color id=keyItem>compass</color>"
			],
			'${Enum_QuestName.Find_lonk}' => [
				"<cb val=happy/>Excellent! You actually managed to stea... I mean FIND the <color id=keyItem>compass</color>!<page/>Good, good. Next, we need to get the map you will use for your adventure.<page/>Go to Brindle's house near the middle of town. Here's a key to get inside. You will find the map in there somewhere.<cb val=findMap/>"
			],
			'${Enum_QuestName.Get_map}' => [
				"Please go get the map!"
			],
			'${Enum_QuestName.Return_map}' => [
				"I'm guessing Brindle wasn't home? I'm surprised you were able to get the <color id=keyItem>map</color> so quickly!"
			]
		],
		WOMAN => [
			'${Enum_QuestName.Wake_up}' => [
				"You shouldn't even know I exist yet!"
			],
			'${Enum_QuestName.Intro}' => [
				"I'm just hanging out. I love chatting with people. Feel free to talk if you have questions."
			],
			'${Enum_QuestName.Intro}_5' => [
				"Cludd? He lives up North.<page/>Why do you want to go to his house? I always found it a little creepy.<page/>A <color id=keyItem>compass</color>? Cludd has had the only one in this town for decades. Quite an uncommon device."
			],
			'${Enum_QuestName.Find_lonk}' => [
				"I'm surprised Cludd let you borrow his <color id=keyItem>compass</color>!  <speed mod=.2>...</speed>Why is it pointing <color id=hint>West</color> -- aren't they supposed to point North?",
				"<cb val=sad/>Oh, the house? I heard the crash, too, and came out here to find this mess. Hard to say what happened.",
				"<cb val=neutral/>Honestly, why is that compass pointing <color id=hint>West</color>?"
			],
			'${Enum_QuestName.Find_lonk}_2' => [
				"<cb val=neutral/>A locked gate? If Cludd knows anything, he probably took notes. That man can't remember to wake up half the time."
			],
			'${Enum_QuestName.Get_map}' => [
				"A <color id=keyItem>map</color>? Brindle keeps one in his shop somewhere, but it's mostly so he knows where he needs to mail things for his long distance customers.",
				"I'd guess the <color id=keyItem>map</color> is in the back somewhere. I've never seen it personally."
			]
		],
		CLUDD => [
			'${Enum_QuestName.Wake_up}' => [
				"ZzzzZzzzZzzz"
			],
			'${Enum_QuestName.Intro}' => [
				"ZzzzZzzzZzzz"
			],
			'${Enum_QuestName.Get_map}' => [
				"ZzzzZzzzZzzz"
			],
			'${Enum_QuestName.Return_map}' => [
				"ZzzzZzzzZzzz"
			],
			'${Enum_QuestName.Find_lonk}' => [
				"ZzzzZzzzZzzz"
			],
			'${Enum_QuestName.Return_map}' => [
				"ZzzzZzzzZzzz"
			]
		],
		CRAFTSMAN => [
			'${Enum_QuestName.Wake_up}' => ["Hi"],
			'${Enum_QuestName.Intro}' => ["Hi"],
			'${Enum_QuestName.Get_map}' => [
				"How'd you get in here? Who gave you that key?"
			],
			'${Enum_QuestName.Return_map}' => [
				"Can I help you? I have the finest wares in the land -- Tell your friends!"
			],
		]
	];
}