package encounters;

import input.SimpleController;
import com.bitdecay.lucidtext.parse.TagLocation;
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

		var portrait = new FlxSprite(textGroup.bounds.x + 5, textGroup.bounds.top + (textGroup.bounds.bottom - textGroup.bounds.top) / 2 - 25);
		portrait.scrollFactor.set();
		portrait.loadGraphic(profileAsset, true, 50, 50);
		portrait.animation.frameIndex = 0;

		textGroup.tagCallback = (tag:TagLocation) -> {
			if (tag.tag == "cb") {
				if (tag.parsedOptions.val == "camred") {
					portrait.animation.frameIndex = 1;
				} else if (tag.parsedOptions.val == "camgrey") {
					portrait.animation.frameIndex = 0;
				}
			}
		};

		add(textGroup);
		add(portrait);
	}

	public function loadDialogLine(text:String) {
		textGroup.loadText(text);
	}
}