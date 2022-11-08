package entities;

import flixel.FlxObject;
import bitdecay.flixel.spacial.Cardinal;
import extension.CardinalExt;
import constants.Characters;
import states.PlayState;
import flixel.FlxG;
import com.bitdecay.lucidtext.parse.TagLocation;
import encounters.CharacterDialog;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import encounters.CharacterIndex;

using extension.CardinalExt;

class NPC extends Interactable {
	var dialogBox:CharacterDialog;

	public function new(data:Entity_NPC) {
		super(data.cx * Constants.TILE_SIZE, data.cy * Constants.TILE_SIZE);
		var charIndex:CharacterIndex = data.f_character.getIndex();
		loadGraphic(charIndex.getAssetPackage(), true, 26, 34);
		setSize(16, 16);
		offset.set(5, 12);

		facing = FlxObject.DOWN;

		addAnimation(Characters.IDLE_ANIM, [ 0 ], 8);
		addAnimation(Characters.RUN_ANIM, [ for (i in 1...7) i ], 8);

		// give us a starting point
		animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');

		dialogBox = new CharacterDialog(data.f_character.getIndex(), "<cb val=happy />Hello there, boy.<page/>What<cb val=mad /> do you want?<page/>Just<cb val=sad /> kidding, I'm just old and <scrub>bored.</scrub>");
		dialogBox.textGroup.tagCallback = updateFacialExpression;

		dialogBox.textGroup.finishCallback = dialogFinished;
	}

	public function updateFacialExpression(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialogBox.setExpression(tag.parsedOptions.val);
		}
	}

	override function interact() {
		facing = Cardinal.closest(PlayState.ME.player.getMidpoint().subtractPoint(getMidpoint())).asFacing();
		PlayState.ME.openDialog(dialogBox);
	}

	function dialogFinished() {
		PlayState.ME.closeDialog(dialogBox);
		dialogBox.resetLastLine();
	}

	function addAnimation(baseName:String, frames:Array<Int>, rowLength:Int) {
		animation.add('${baseName}_${Characters.DOWN}', frames, Characters.BASE_FRAMERATE);

		frames = frames.copy();
		for (i in 0...frames.length) {
			frames[i] += rowLength;
		}
		animation.add('${baseName}_${Characters.RIGHT}', frames, Characters.BASE_FRAMERATE);
		animation.add('${baseName}_${Characters.LEFT}', frames, Characters.BASE_FRAMERATE, true, true);

		frames = frames.copy();
		for (i in 0...frames.length) {
			frames[i] += rowLength;
		}
		animation.add('${baseName}_${Characters.UP}', frames, Characters.BASE_FRAMERATE);
	}

	override public function update(delta:Float) {
		super.update(delta);
		updateAnimations();
	}

	function updateAnimations() {
		// we are using 1 here due to weird "nearly zero" errors (likely from rotation of the cardinal vector)
		if (Math.abs(velocity.y) > 1) {
			if (velocity.y < -1) {
				animation.play('${Characters.RUN_ANIM}_${Characters.UP}');
			} else if (velocity.y > 1) {
				animation.play('${Characters.RUN_ANIM}_${Characters.DOWN}');
			}
		} else {
			if (velocity.x < -1) {
				animation.play('${Characters.RUN_ANIM}_${Characters.LEFT}');
			} else if (velocity.x > 1) {
				animation.play('${Characters.RUN_ANIM}_${Characters.RIGHT}');
			}
		}

		if (velocity.x == 0 && velocity.y == 0) {
			// var dir = animation.curAnim.name.split('_')[1];
			animation.play('${Characters.IDLE_ANIM}_${CardinalExt.fromFacing(facing).asUDLR()}');
		}

		FlxG.watch.addQuick('player set anim: ', animation.curAnim.name);
	}
}