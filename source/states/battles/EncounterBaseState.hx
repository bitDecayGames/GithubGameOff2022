package states.battles;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSubState;

class EncounterBaseState extends FlxSubState {

	// put everything into this group, and the trasition will handle it nicely
	var battleGroup:FlxGroup = new FlxGroup();
	var transition:FlxSprite;
	// var dialogTest:CharacterDialog;

	public function new() {
		super();
	}

	override function create() {
		super.create();

		camera.bgColor = FlxColor.GRAY;

		var bgImg = new FlxSprite();
		bgImg.makeGraphic(1,1, FlxColor.BLACK);
		bgImg.scrollFactor.set();
		// oversize this a bit to allow for camera shake without artifacts at the edges
		bgImg.scale.set(FlxG.width * 1.25, FlxG.height * 1.25);
		bgImg.updateHitbox();
		bgImg.screenCenter();
		battleGroup.add(bgImg);

		// dialogTest = new CharacterDialog(AssetPaths.crappot__png, "It is a pot.");
		// dialogTest.textGroup.finishCallback = dialogComplete;

		// battleGroup.add(dialogTest);

		battleGroup.visible = false;
		battleGroup.active = false;

		transition = new FlxSprite();
		transition.makeGraphic(1,1, FlxColor.BLUE);
		transition.alpha = 0;
		transition.scrollFactor.set();
		transition.scale.set(FlxG.width, FlxG.height);
		transition.updateHitbox();
		transition.screenCenter();

		add(battleGroup);
		add(transition);

		FlxTween.tween(transition, { alpha: 1 }, {
			onComplete: (t) -> {
				battleGroup.visible = true;
				FlxTween.tween(transition, { alpha: 0}, {
					onComplete: (t) -> {
						battleGroup.active = true;
					}
				});
			}
		});
	}

	// var lines: [
	// 	"hello, I might repeat myself!",
	// 	"hello, I might repeat myself!",
	// 	"hello, I might repeat myself!",
	// 	"Who now, how many times you gunna make me say that?"
	// ];

	// var dialogIndex = 0;
	// function dialogComplete() {
	// 	switch(dialogIndex) {
	// 		case 0:
	// 			dialogTest.loadDialogLine( "Welcome to the thunder dome. A pot stands before you. It <wave height=2>gazes</wave> <speed mod=0.1>deeeeply</speed> into your soul, as if to ask you to join it. You hear a quiet whisper, \"Do you yield, <cb val=camred /><shake dist=1><rainbow>MORTAL?</rainbow></shake><pause/>\"<cb val=camgrey />");
	// 		case 1:
	// 			close();
	// 		default:
	// 			trace('no dialog past this point');
	// 		dialogIndex++;
	// 	}
	// }

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}