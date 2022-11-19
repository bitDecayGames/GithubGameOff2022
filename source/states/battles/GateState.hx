package states.battles;

import bitdecay.flixel.debug.DebugDraw;
import flixel.math.FlxRect;
import flixel.util.FlxSpriteUtil;
import com.bitdecay.lucidtext.parse.TagLocation;
import quest.GlobalQuestState;
import flixel.math.FlxMath;
import encounters.CharacterIndex;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

#if encounter_debug
import bitdecay.flixel.debug.DebugDraw;
#end

import encounters.CharacterDialog;
import input.SimpleController;

using zero.flixel.extensions.FlxPointExt;

class GateState extends EncounterBaseState {

	var lockBody:FlxSprite;
	var lockLatch:FlxSprite;
	var combo1:Combo;
	var combo2:Combo;
	var combo3:Combo;

	var comboRollers = new Array<Combo>();

	var comboIndex = 0;
	var selectedCombo:Combo;
	var cursor:FlxSprite;

	public function new() {
		super();
	}

	override function create() {
		super.create();

		dialog = new CharacterDialog(CharacterIndex.ALARM_CLOCK, "With 1000 possible combinations, I highly doubt you'll be able to unlock me.");
		FmodManager.PlaySong(FmodSongs.Battle);

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();

			new FlxTimer().start(.05, (t) -> {
				acceptInput = true;
			});
		};

		dialog.textGroup.tagCallback = handleTagCallback;


		lockBody = new FlxSprite();
		lockBody.makeGraphic(100, 100, FlxColor.ORANGE);
		lockBody.screenCenter();

		lockLatch = new FlxSprite();
		lockLatch.makeGraphic(75, 100, FlxColor.YELLOW);
		lockLatch.setPosition(lockBody.x + 12, lockBody.y - 50);

		// load our desired combo into the lock rollers here
		combo1 = new Combo(lockBody, 0, 5);
		combo2 = new Combo(lockBody, 1, 0);
		combo3 = new Combo(lockBody, 2, 9);
		comboRollers.push(combo1);
		comboRollers.push(combo2);
		comboRollers.push(combo3);

		cursor = new FlxSprite();
		cursor.y = lockBody.y + 50;
		cursor.makeGraphic(24, 44, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawLine(cursor, 0, 0, 0, 44);
		FlxSpriteUtil.drawLine(cursor, 0, 0, 24, 0);
		FlxSpriteUtil.drawLine(cursor, 24, 0, 24, 44);
		FlxSpriteUtil.drawLine(cursor, 0, 44, 24, 44);

		battleGroup.add(lockLatch);
		battleGroup.add(lockBody);
		battleGroup.add(combo1);
		battleGroup.add(combo2);
		battleGroup.add(combo3);
		battleGroup.add(cursor);

		battleGroup.add(dialog);
	}

	function handleTagCallback(tag:TagLocation) {
		if (tag.tag == "cb") {
			dialog.setExpression(tag.parsedOptions.val);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!acceptInput) {
			return;
		}

		if (SimpleController.just_pressed(LEFT)) {
			comboIndex--;
		} else if (SimpleController.just_pressed(RIGHT)) {
			comboIndex++;
		}

		comboIndex = FlxMath.wrap(comboIndex, 0, 2);

		switch(comboIndex) {
			case 0:
				selectedCombo = combo1;
			case 1:
				selectedCombo = combo2;
			case 2:
				selectedCombo = combo3;
		}

		cursor.x = selectedCombo.x - 1;

		if (SimpleController.just_pressed(UP)) {
			selectedCombo.currentNum--;
		} else if (SimpleController.just_pressed(DOWN)) {
			selectedCombo.currentNum++;
		}

		if (SimpleController.just_pressed(A)) {
			attemptOpen();
		}
	}

	function attemptOpen() {
		acceptInput = false;

		for (roller in comboRollers) {
			if (roller.currentNum != roller.magicNumber) {
				doFail();
				return;
			}
		}

		doSuccess();
	}

	var failCount = 0;

	function doFail() {
		failCount++;
		var rattleY = lockLatch.y-5;
		FlxTween.tween(lockLatch, {y: rattleY}, 0.1, {
			// ease: FlxEase.
			type: FlxTweenType.PINGPONG,
			onComplete: (t) -> {
				// 6 is 3 cycles of open->close
				if (t.executions == 6) {
					t.cancel();

					if (failCount >= 3) {
						dialog.loadDialogLine('Only Cludd has the genius to unlock me! You will never get past me!');
							dialog.textGroup.finishCallback = () -> {
								transitionOut();
							};
							dialog.revive();
					} else {
						acceptInput = true;
					}
				}
			}
		});
	}

	function doSuccess() {
		success = true;
		var unlockY = lockLatch.y-50;
		FlxTween.tween(lockLatch, {y: unlockY}, 1, {
			ease: FlxEase.sineInOut,
			onComplete: (t) -> {
				if (PlayState.ME != null) {
					PlayState.ME.eventSignal.dispatch("gate_unlocked");
				}
				transitionOut();
			}
		});
	}

	function checkSuccess():Bool {
		return false;
	}
}

class Combo extends FlxSprite {
	public var index = 0;
	var lastNum = -1;
	public var currentNum = 0;
	public var digitHeight = 16;
	public var baseY:Float = 0;
	public var magicNumber = 0;

	public function new(relativeTo:FlxSprite, index:Int, magic:Int){
		baseY = relativeTo.y + 50;
		magicNumber = magic;
		super(relativeTo.x + 15 + (5 + 20)*index, baseY, AssetPaths.lockRoller__png);
		this.index = index;
		updateClip();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (currentNum != lastNum) {
			currentNum = FlxMath.wrap(currentNum, 0, 9);
			updateClip();
			lastNum = currentNum;

			if (currentNum == magicNumber) {
				// TODO: SFX, have audio cue instead of camera shake
				camera.shake();
			}
		}
		// DebugDraw.ME.drawWorldRect(clipRect.x + x - offset.x, clipRect.y + y - offset.y, clipRect.width, clipRect.height);
	}

	function updateClip() {
		// our zero is actually on the 3rd tile, so our scroll needs to be based on that position
		var zeroY = 41 - 22; // we want the 41st pixel to be in the middle of our 44 pixel high window
		y = baseY - zeroY - currentNum * 16;
		clipRect = FlxRect.get(0, zeroY + currentNum * 16, width, 44);
	}
}