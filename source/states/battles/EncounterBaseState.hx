package states.battles;

import com.bitdecay.lucidtext.TypeOptions;
import flixel.math.FlxRect;
import flixel.FlxG;
import input.SimpleController;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import com.bitdecay.lucidtext.TypingGroup;

class EncounterBaseState extends FlxSubState {
	public function new() {
		super();

		// camera = new FlxCamera();
		// FlxG.cameras.add(camera);

		camera.bgColor = FlxColor.GRAY;

		// var battleMenuBG = new FlxSliceSprite(
		// 	AssetPaths.battleMenuSlice__png,
		// 	FlxRect.get(4, 4, 7, 8), FlxG.width * .8,
		// 	FlxG.height * .25);
		// battleMenuBG.scrollFactor.set();
		// battleMenuBG.setPosition(0, FlxG.height * .7);
		// battleMenuBG.screenCenter(FlxAxes.X);
		// add(battleMenuBG);

		var textTest = new TypingGroup(
			FlxRect.get(FlxG.width * 0.1, FlxG.height * .7, FlxG.width * .8, FlxG.height * .25),
			"Welcome to the thunder dome. A pot stands <bigger>before</bigger> you. It <wave height=2>gazes</wave> <speed mod=0.1>deeeeply</speed> into your soul, as if to ask you to join it. Do you yield, <shake dist=1><rainbow>MORTAL?</rainbow></shake>",
			new TypeOptions(AssetPaths.battleMenuSlice__png, [4, 4, 7, 8], 4, 10)
		);
		for (m in textTest.members) {
			m.scrollFactor.set();
		}
		add(textTest);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (SimpleController.just_pressed(A)) {
			FlxG.switchState(PlayState.ME);
		}
	}
}