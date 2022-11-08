package entities.library;

import encounters.CharacterIndex;

class NPCTextBank {
	// In theory this is a map that holds characters as the key
	//    the value is a map of quest ID's (effectively just some progression ID) to the things they should
	//    say at that point in the game. We'll have to talk about how we want to orgainize this
	public static var all:Map<CharacterIndex, Map<String, Array<String>>> = [
		LONK => [
			"quest" => [
				"<cb val=happy />Hello there, boy.<page/>What<cb val=mad /> do you want?<page/>Just<cb val=sad /> kidding, I'm just old and <scrub>bored.</scrub>"
			]
		],
		WOMAN => [
			"quest" => [
				"Do you know that old man over there?<page/>He<cb val=sad /> keeps staring at me...",
				"Ask him to leave"
			]
		]
	];
}