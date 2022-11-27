package encounters;

import input.SimpleController;
import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import com.bitdecay.lucidtext.TypingGroup;
import com.bitdecay.lucidtext.TypeOptions;
import flixel.group.FlxGroup;

@:access(com.bitdecay.lucidtext.TypingGroup)
class CharacterDialog extends FlxGroup {
	private static var expressionsAsset = AssetPaths.NPCexpressions__png;

	public var characterIndex:CharacterIndex;

	var internalRowIndex:Int;

	public var textGroup:TypingGroup;
	public var portrait:FlxSprite;
	public var options:TypeOptions;

	public var faster = false;

	// for cleaner input handling
	public var skipOneUpdate = false;

	var portraitMargins:Array<Float> = [5, 5, 60, 5];
	var noPortraitMargins:Array<Float> = [5, 5, 5, 5];

	public function new(expressionIndex:CharacterIndex, initialText:String) {
		super();

		characterIndex = expressionIndex;

		options = new TypeOptions(AssetPaths.battleMenuSlice__png, [4, 4, 7, 8], expressionIndex != NONE ? portraitMargins : noPortraitMargins, 10);
		options.checkPageConfirm = (delta) -> {
			if (SimpleController.just_pressed(A)) {
				// we don't want their press to go to the next page to also start fast-forwarding the next page
				skipOneUpdate = true;
				return true;
			}

			return false;
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
		textGroup.letterCallback = () -> {
			FmodManager.PlaySoundOneShot(FmodSFX.TypeWriterSingleStroke);
		};
		textGroup.pageCallback = () -> {
			skipOneUpdate = true;
			faster = false;
			textGroup.options.modOps.speedMultiplier = 1;
		}

		add(textGroup);

		if (expressionIndex != NONE) {
			portrait = new FlxSprite(textGroup.bounds.x + 5, textGroup.bounds.top + (textGroup.bounds.bottom - textGroup.bounds.top) / 2 - 25);
			portrait.scrollFactor.set();
			portrait.loadGraphic(expressionsAsset, true, 50, 50);
			var rowLength = Std.int(portrait.graphic.width / 50);
			internalRowIndex = expressionIndex * rowLength;
			portrait.animation.frameIndex = internalRowIndex;
			add(portrait);
		}
	}

	public function setExpression(e:Expression) {
		if (portrait == null) {
			return;
		}
		portrait.animation.frameIndex = internalRowIndex + e.asIndex();
	}

	public function loadDialogLine(text:String) {
		textGroup.loadText(text);
		skipOneUpdate = true;
	}

	public function resetLastLine() {
		// TODO: Obviously not efficient, but works for now
		textGroup.loadText(textGroup.rawText);
		skipOneUpdate = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (skipOneUpdate) {
			skipOneUpdate = false;
			return;
		}

		if (SimpleController.just_pressed(A) && !faster) {
			faster = true;
			textGroup.options.modOps.speedMultiplier = 3;
		}

		if (!SimpleController.pressed(A) && faster) {
			faster = false;
			textGroup.options.modOps.speedMultiplier = 1;
		}
	}
}