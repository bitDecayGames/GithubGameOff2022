package entities.npcs;

import flixel.math.FlxMath;
import entities.library.NPCTextBank;
import quest.GlobalQuestState;
import flixel.FlxObject;
import bitdecay.flixel.spacial.Cardinal;
import constants.Characters;
import states.PlayState;
import flixel.FlxG;
import encounters.CharacterIndex;
import entities.interact.Interactable;

using extension.CardinalExt;

class NPC extends Interactable {
	var charIndex:CharacterIndex;
	var chatIndex = 0;

	// This just tracks the last quest we were on. If the quest changes, this will help us know to reset
	// the chatIndex
	var lastQuest:String = "";

	public function new(data:Entity_NPC) {
		super(data.cx * Constants.TILE_SIZE, data.cy * Constants.TILE_SIZE, data.f_character.getIndex());
		charIndex = data.f_character.getIndex();
		loadGraphic(charIndex.getAssetPackage(), true, 26, 34);
		setSize(16, 16);
		offset.set(5, 17);

		facing = FlxObject.DOWN;

		addAnimation(Characters.IDLE_ANIM, [ 0 ], 8);
		addAnimation(Characters.RUN_ANIM, [ for (i in 1...7) i ], 8);

		// give us a starting point
		animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');
	}

	override function interact() {
		super.interact();
		facing = Cardinal.closest(PlayState.ME.player.getMidpoint().subtractPoint(getMidpoint())).asFacing();

		if (lastQuest != GlobalQuestState.getCurrentQuestKey()) {
			lastQuest = GlobalQuestState.getCurrentQuestKey();
			chatIndex = 0;
		}

		var allText = NPCTextBank.all[charIndex];
		var questText = allText[GlobalQuestState.getCurrentQuestKey()];
		if (questText == null) {
			// if we didn't have text specific to this subtask, check for general quest text
			questText = allText[GlobalQuestState.currentQuest];
		}
		if (questText != null) {
			chatIndex = Math.round(FlxMath.bound(chatIndex, 0, questText.length-1));
			dialogBox.loadDialogLine(questText[chatIndex++]);
		}

		// TODO: Do we want to have subclasses actually call this so that they can get the above functionality
		// and perhaps be able to do something different besides just opening the dialog?
		PlayState.ME.openDialog(dialogBox);
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