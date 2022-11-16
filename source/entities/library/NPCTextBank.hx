package entities.library;

import encounters.CharacterIndex;

class NPCTextBank {
	// In theory this is a map that holds characters as the key
	//    the value is a map of quest ID's (effectively just some progression ID) to the things they should
	//    say at that point in the game. We'll have to talk about how we want to orgainize this
	public static var all:Map<CharacterIndex, Map<String, Array<String>>> = [
		LONK => [
			"intro_0" => [
				"<cb val=happy />I see you're awake - Today is the big day!<page/>" +
				"By<cb val=neutral /> the end of the week, you'll be an adventurer just like I used to be.<page/>" +
				"I used to <cb val=mad /><shake>destroy</shake><cb val=neutral /> pottery. Today, I'd love to teach you the ancient art.<page/>" +
				"<cb val=happy />You see that <color id=keyItem>rubber pot</color> over there? Attack it swiftly. Aim for the <color id=hint>weak points</color>.<page/>",
				"<cb val=mad /><shake>Obliterate it!</shake>",
				"<cb val=neutral/>Keep trying until you've proven you can break it"
			],
			"intro_1" => [
				"Well done, Boy! You're ready to begin preparations. I need you to collect my <color id=keyItem>compass</color> from Cludd's house on the " +
				"north side of town.",
				"Come back here once you have my <color id=keyItem>compass</color>"
			]
		],
		WOMAN => [
			"intro_1" => [
				"Cludd? He lives up North.<page/>Why do you want to go to his house? I always found it a little creepy.<page/>A <color rgb=0x0000FF>compass</color>? Cludd has had the only one in this town for decades. Quite an uncommon device."
			]
		]
	];
}