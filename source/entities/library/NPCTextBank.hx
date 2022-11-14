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
				"I used to <cb val=mad /><shake>destroy</shake><cb val=neutral /> pottery. Today, I'd love to teach you the ancient art.",
				"<cb val=happy />You see that <color rgb=0x00FF00>rubber pot</color> over there? Attack it swiftly. Aim for the weak points.",
				"<cb val=mad /><shake>Obliterate it!</shake>",
				"<cb val=neutral/>Keep trying until you've proven you can break it"
			],
			"intro_1" => [
				"Well done, Boy! You're ready to begin preparations. I need you to collect my <color rgb=0x0000FF>compass</color> from <INSERT NAME>'s house on the " +
				"north side of town.",
				"Come back here once you have my <color rgb=0x0000FF>compass</color>"
			]
		],
		WOMAN => [
			"quest" => [
				"Your grandfather Lonk is an interesting man.<page/>I<cb val=sad /> feel like he's lost touch with the people of this town."
			]
		]
	];
}