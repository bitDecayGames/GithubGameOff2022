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
				"By the end of the week, you'll be an adventurer just like I used to be.<page/>" +
				"I used to <cb val=mad /><shake>destroy</shake><cb val=happy /> pottery. Today, I'd love to teach you the ancient art.",
				"I haven't been programmed to tell you what to do yet... so can you just go outside for a minute?<cb val=questDone/>"
			],
			"compassFetch" => [
				"<cb val=happy />I knew you couldn't resist coming out here to talk to me again"
			]
		],
		WOMAN => [
			"quest" => [
				"Your grandfather Lonk is an interesting man.<page/>I<cb val=sad /> feel like he's lost touch with the people of this town."
			]
		]
	];
}