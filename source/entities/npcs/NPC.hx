package entities.npcs;

import flixel.util.FlxStringUtil;
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
import entities.interact.OwnableTrigger;

using extension.CardinalExt;

typedef ChatProgress = {
	var lastQuest:String;
	var chatIndex:Int;
}

class NPC extends Interactable implements YayOrNay {
	private static var npcProgressTracker = new Map<CharacterIndex, ChatProgress>();

	public var manualAnimations = false;

	var charIndex:CharacterIndex;

	// This just tracks the last quest we were on. If the quest changes, this will help us know to reset
	// the chatIndex. The setters will keep the static map up-to-date
	var lastQuest(default, set):String = "";
	var chatIndex(default, set) = 0;

	var data:Entity_NPC;

	public function new(data:Entity_NPC) {
		super(data.pixelX, data.pixelY, data.f_character.getIndex());
		this.data = data;
		charIndex = data.f_character.getIndex();
		loadGraphic(charIndex.getAssetPackage(), true, 26, 34);
		setSize(16, 16);
		offset.set(5, 17);

		switch(data.f_Direction) {
			case UP:
				facing = FlxObject.UP;
			case DOWN:
				facing = FlxObject.DOWN;
			case LEFT:
				facing = FlxObject.LEFT;
			case RIGHT:
				facing = FlxObject.RIGHT;
		}

		addAnimation(Characters.IDLE_ANIM, [ 0 ], 8);
		addAnimation(Characters.RUN_ANIM, [ for (i in 1...7) i ], 8);

		// give us a starting point
		animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');

		if (!npcProgressTracker.exists(charIndex)) {
			npcProgressTracker.set(charIndex, {
				lastQuest: "",
				chatIndex: 0,
			});
		}

		lastQuest = npcProgressTracker.get(charIndex).lastQuest;
		chatIndex = npcProgressTracker.get(charIndex).chatIndex;
	}

	public function UpdateOwnership() {
		for (owned in data.f_Owns) {
			PlayState.ME.interactables.forEachAlive((s) -> {
				if (s is OwnableTrigger) {
					var ot = cast(s, OwnableTrigger);
					if (owned.entityIid == ot.data.iid) {
						ot.owner = this;
					}
				}
			});
		}
	}

	override function interact() {
		super.interact();
		updateFacing(PlayState.ME.player);
		updateQuestText();

		// TODO: Do we want to have subclasses actually call this so that they can get the above functionality
		// and perhaps be able to do something different besides just opening the dialog?
		PlayState.ME.openDialog(dialogBox);
	}

	function updateFacing(lookAt:FlxObject) {
		var xDiff = x - lookAt.x;
		var yDiff = y - lookAt.y;
		if (Math.abs(xDiff) > Math.abs(yDiff)) {
			if (xDiff > 0) {
				facing = FlxObject.LEFT;
			} else {
				facing = FlxObject.RIGHT;
			}
		} else {
			if (yDiff > 0) {
				facing = FlxObject.UP;
			} else {
				facing = FlxObject.DOWN;
			}
		}
	}

	function updateQuestText() {
		if (lastQuest != GlobalQuestState.getCurrentQuestKey()) {
			lastQuest = GlobalQuestState.getCurrentQuestKey();
			chatIndex = 0;
		}

		var allText = NPCTextBank.all[charIndex];
		var questText = allText[GlobalQuestState.getCurrentQuestKey()];
		if (questText == null) {
			// if we didn't have text specific to this subtask, check for general quest text
			questText = allText[GlobalQuestState.currentQuest.getName()];
		}
		if (questText != null) {
			chatIndex = Math.round(FlxMath.bound(chatIndex, 0, questText.length-1));
			var textLine = questText[chatIndex++];
			if (FlxStringUtil.isNullOrEmpty(textLine)) {
				FlxG.log.warn('text line was empty for ${GlobalQuestState.getCurrentQuestKey()}');
				textLine = "I have nothing to say. Devs forgot to give me text here.";
			}
			dialogBox.loadDialogLine(textLine);
		}
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
		if (!manualAnimations) {
			updateAnimations();
		}
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

	function set_chatIndex(value) {
		npcProgressTracker.get(charIndex).chatIndex = value;
		return chatIndex = value;
	}

	function set_lastQuest(value:String):String {
		npcProgressTracker.get(charIndex).lastQuest = value;
		return lastQuest = value;
	}

	public function CheckDoor(d:Door):Bool {
		return false;
	}

	public function Why():String {
		return "";
	}
}