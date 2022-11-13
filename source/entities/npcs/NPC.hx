package entities.npcs;

import quest.Quest;
import entities.library.NPCTextBank;
import flixel.FlxObject;
import bitdecay.flixel.spacial.Cardinal;
import constants.Characters;
import states.PlayState;
import flixel.FlxG;
import com.bitdecay.lucidtext.parse.TagLocation;
import encounters.CharacterDialog;
import encounters.CharacterIndex;
import entities.interact.Interactable;

using extension.CardinalExt;

class NPC extends Interactable {
	var charIndex:CharacterIndex;
	var dialogBox:CharacterDialog;
	var chatIndex = 0;

	public function new(data:Entity_NPC) {
		super(data.cx * Constants.TILE_SIZE, data.cy * Constants.TILE_SIZE);
		charIndex = data.f_character.getIndex();
		loadGraphic(charIndex.getAssetPackage(), true, 26, 34);
		setSize(16, 16);
		offset.set(5, 17);

		facing = FlxObject.DOWN;

		addAnimation(Characters.IDLE_ANIM, [ 0 ], 8);
		addAnimation(Characters.RUN_ANIM, [ for (i in 1...7) i ], 8);

		// give us a starting point
		animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');

		dialogBox = new CharacterDialog(data.f_character.getIndex(), "");
		dialogBox.textGroup.tagCallback = handleTagCallback;

		dialogBox.textGroup.finishCallback = dialogFinished;
	}

	public function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialogBox.setExpression(tag.parsedOptions.val);
		}
	}

	// override this to actually do stuff besides turning to face the player
	override function interact() {
		facing = Cardinal.closest(PlayState.ME.player.getMidpoint().subtractPoint(getMidpoint())).asFacing();
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