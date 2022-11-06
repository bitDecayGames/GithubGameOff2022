package encounters;

import input.SimpleController;
import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import com.bitdecay.lucidtext.TypingGroup;
import com.bitdecay.lucidtext.TypeOptions;
import flixel.group.FlxGroup;

class CharacterDialog extends FlxGroup {
	public var textGroup:TypingGroup;
	public var portrait:FlxSprite;
	public var options:TypeOptions;

	public function new(profileAsset:String, initialText:String) {
		super();

		options = new TypeOptions(AssetPaths.battleMenuSlice__png, [4, 4, 7, 8], [5, 5, 60, 5], 10);
		options.checkPageConfirm = (delta) -> {
			return SimpleController.just_pressed(A);
		};
		options.nextIconMaker = () -> {
			var nextIcon = new FlxSprite();
			nextIcon.scrollFactor.set();
			nextIcon.loadGraphic(AssetPaths.crap_nexticon__png, true, 10, 10);
			nextIcon.animation.add('spin', [0,1,2,3], 8);
			nextIcon.animation.play('spin');
			return nextIcon;
		}

		textGroup = new TypingGroup(
			FlxRect.get(FlxG.width * 0.1, FlxG.height * .7, FlxG.width * .8, FlxG.height * .25),
			initialText,
			options
		);
		textGroup.scrollFactor.set();

		portrait = new FlxSprite(textGroup.bounds.x + 5, textGroup.bounds.top + (textGroup.bounds.bottom - textGroup.bounds.top) / 2 - 25);
		portrait.scrollFactor.set();
		portrait.loadGraphic(profileAsset, true, 50, 50);
		portrait.animation.frameIndex = 0;

		add(textGroup);
		add(portrait);
	}

	public function loadDialogLine(text:String) {
		textGroup.loadText(text);
	}
	public function resetLastLine() {
		// TODO: Obviously not efficient, but works for now
		textGroup.loadText(textGroup.rawText);
		textGroup.update(0.001);
	}
}