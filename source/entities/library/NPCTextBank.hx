package entities.library;

import encounters.CharacterIndex;

class NPCTextBank {
	// In theory this is a map that holds characters as the key
	//    the value is a map of quest ID's (effectively just some progression ID) to the things they should
	//    say at that point in the game. We'll have to talk about how we want to orgainize this
	public static var all:Map<CharacterIndex, Map<String, Array<String>>> = [
		LONK => [
			"wake_up_0" => [
				"Are you going to leave that alarm clock beeping all day?<cb val=turn_off_clock />"
			],
			"wake_up_1" => [
				"Go turn off your alarm..."
			],
			"intro_2" => [
				"<cb val=happy />Today is the big day!<page/>" +
				"By<cb val=neutral /> the end of the week, you'll be an adventurer just like I used to be.<page/>" +
				"I used to <cb val=mad /><shake>destroy</shake><cb val=neutral /> pottery. Today, I'd love to teach you the ancient art.<page/>" +
				"<cb val=happy />You see that <color id=keyItem>rubber pot</color> over there? Attack it swiftly. Aim for the <color id=hint>weak points</color>.<page/><cb val=informed_of_rubber_pot />",
			],
			"intro_3" => [
				"<cb val=mad /><shake>Obliterate it!</shake>",
				"<cb val=neutral/>Keep trying until you've proven you can break it"
			],
			"intro_4" => [
				"<cb val=happy />Well done, Boy! You're ready to begin preparations. I need you to collect my <color id=keyItem>compass</color> from Cludd's house on the " +
				"north side of town.<cb val=informed_of_compass />"
			],
			"intro_5" => [
				"Come back here once you have my <color id=keyItem>compass</color>"
			],

			"getMap_0" => [
				"<cb val=happy/>Excellent! You actually managed to stea... I mean FIND it!<page/>Good, good. Next, we need to get the map you will use for your adventure. Go to Brindle's house near the middle of town. It has the two flasks next to it. In there, you will find the map."
			]
		],
		WOMAN => [
			"intro_1" => [
				"Cludd? He lives up North.<page/>Why do you want to go to his house? I always found it a little creepy.<page/>A <color id=keyItem>compass</color>? Cludd has had the only one in this town for decades. Quite an uncommon device."
			],
			"findLonk_0" => [
				"I'm surprised Cludd let you borrow his <color id=keyItem>compass</color>!  <speed mod=.2>...</speed>Why is it pointing West -- aren't they supposed to point North?",
				"<cb val=sad/>Oh, the house? I heard the crash, too, and came out here to find this mess. Hard to say what happened."
			]
		],
		CLUDD => [
			"intro" => [
				"ZzzzZzzzZzzz"
			]
		],
		CRAFTSMAN => [
			"wake_up" => ["Hi"],
			"intro" => ["Hi"],
			"findLonk" => ["Hi"],
		]
	];
}