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
				"By<cb val=neutral /> the end of the week, we'll be ready for adventure just like the old days!<page/>" +
				"I used to <shake>destroy</shake> pottery. Today, I'd love to teach you the ancient art.<page/>" +
				"<cb val=happy />You see that <color id=keyItem>rubber pot</color> over there? Attack it swiftly. Aim for the <color id=hint>weak points</color>.<page/><cb val=informed_of_rubber_pot />",
			],
			'${Enum_QuestName.Intro}_3' => [
				"<cb val=mad /><shake>Obliterate it!</shake>",
				"<cb val=neutral/>Keep trying until you've proven you can defeat it."
			],
			'${Enum_QuestName.Intro}_4' => [
				"<cb val=happy />Well done, Boy! You're ready to begin preparations. I need you to collect my <color id=keyItem>compass</color> from Cludd's house on the " +
				"<color id=hint>North</color> side of town.<cb val=informed_of_compass />"
			],
			'${Enum_QuestName.Intro}_5' => [
				"Come back here once you have my <color id=keyItem>compass</color>."
			],
			'${Enum_QuestName.Find_lonk}' => [
				"<cb val=neutral/>I see you've found the new house! The old one...<pause t=1/> was due for replacement, we'll say.<pause t=1/> The payout should cover this place nicely.<page/>" +
				"Conveniently, I moved all of our stuff here before the 'accident' occurred. Anyways<speed mod=0.1>...</speed><page/>" +
				"Oh <cb val=happy/>yeah, the <color id=keyItem>compass</color>! You actually managed to stea... I mean FIND it!<page/>Good<cb val=neutral/>, good. Next, we need to get the <color id=keyItem>map</color> for the adventure.<page/>" +
				"Go to Brindle's shop near the middle of town. <page/>" +
				"Here's a <color id=keyItem>key</color> to get inside.<pause t=1/> <cb val=keyCollected/> <pause/> <page/>" +
				"You<cb val=restoreControl/><cb val=faceme/> will find the <color id=keyItem>map</color> in there somewhere.<cb val=findMap/>"
			],
			'${Enum_QuestName.Get_map}' => [
				"Please go get the <color id=keyItem>map</color>!"
			],
			'${Enum_QuestName.Return_map}' => [
				#if speedy_debug
				"<cb val=startEndgame/>TIME TO DIE<cb val=triggerEnding/><cb val=bumpSubQuest/>"
				#else
				"<cb val=startEndgame/>I'm guessing Brindle wasn't at his shop? I'm surprised you were able to get the <color id=keyItem>map</color> so quickly!<page/>" +
				"Now that you've collected everything I need, I'll be taking it and going on my own adventure!<cb val=stopMusic/><pause t=2/> <page/>
				What's wrong?<pause t=0.5/>
				 <cb val=mad/><cb val=startMusic/>You thought this was all for you?<page/>
				<cb val=happy/>Dear child<speed mod=.2>...</speed><page/>
				<cb val=neutral/>You were never fit for adventure.<pause t=0.5/> You are too small.<pause t=0.25/> Too weak.<page/>
				<cb val=neutral/>Now give everything to me before I get impatient<speed mod=.05>...</speed><page/>
				No?<page/>
				<cb val=happy/>Ok then<page/>
				<cb val=mad/><bigger><shake>I will take it!</shake></bigger> <cb val=triggerEnding/><cb val=bumpSubQuest/>"
				#end
			],
			'${Enum_QuestName.End_game}' => [
				"<cb val=mad/>MORE<cb val=triggerEnding/><cb val=mad/>"
			],
			'${Enum_QuestName.Final_morning}_0' => [
				"Are you going to leave that alarm clock beeping all day?<cb val=turn_off_clock />"
			],
			'${Enum_QuestName.Final_morning}_1' => [
				"Go turn off your alarm..."
			],
			'${Enum_QuestName.Final_morning}_2' => [
				"<cb val=happy/>Good Morning! Dreaming of adventure again? I could hear you tossing and turning all night.<page/>" +
				"There will be plenty of time for that when you're older. For now, you have to go to school.<cb val=goToSchool/>"
			]
		],
		WOMAN => [
			'${Enum_QuestName.Wake_up}' => [
				"You shouldn't even know I exist yet!"
			],
			'${Enum_QuestName.Intro}' => [
				"I'm just hanging out. I love talking with people. Feel free to chat with me if you have questions."
			],
			'${Enum_QuestName.Intro}_5' => [
				"I'm just hanging out. I love talking with people. Feel free to chat with me if you have questions.<page/>Cludd? " +
				"He lives up <color id=hint>North</color>.<page/>Why do you want to go to his house? I always found it a little creepy.<page/>A <color id=keyItem>compass</color>? " +
				"Cludd has had the only one in this town for decades. I'm sure he'd be happy to show it to you."
			],
			'${Enum_QuestName.Find_lonk}' => [
				"<cb val=sad/>I heard the crash and came out here to find this mess. <cb val=panToLonkHouse/><pause t=3/>Hard<cb val=panToPlayer/> to say what happened.<page/>" +
				"I saw your grandpa leaving right before the collapse.<page/>I think he's OK.<cb val=lonk_ok/><page/>But I don't know where he went.<page/>" +
				"<cb val=neutral/>Is that Cludd's <color id=keyItem>compass</color>? I'm surprised he let you borrow it!<page/><speed mod=.2>...</speed>Why is it pointing <color id=hint>West</color> -- aren't they supposed to point North?<cb val=exploreWest/>"
			],
			'${Enum_QuestName.Find_lonk}_2' => [
				"<cb val=neutral/>Honestly, why is that compass pointing <color id=hint>West</color>?"
			],
			'${Enum_QuestName.Find_lonk}_3' => [
				"<cb val=neutral/>A locked gate? If Cludd knows anything, he probably took <color id=hint>notes</color>. That man can't remember to get out of bed half of the time."
			],
			'${Enum_QuestName.Get_map}' => [
				"A <color id=keyItem>map</color>? Brindle keeps one in his shop somewhere, but it's mostly so he knows where he needs to mail things for his long distance customers.",
				"I'd guess the <color id=keyItem>map</color> is in the <color id=hint>back</color> somewhere, but I've never seen it personally."
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
				"Can I help you? I would appreciate it if you left."
			],
		]
	];
}