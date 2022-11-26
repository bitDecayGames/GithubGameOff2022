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
		GlobalQuestState.HAS_INTERACTED_WITH_GATE = true;
		dialog = new CharacterDialog(CharacterIndex.ALARM_CLOCK, "With 1000 possible combinations, I highly doubt you'll be able to unlock me.");


		new FlxTimer().start(1.75, (t) -> {
			FmodManager.PlaySong(FmodSongs.Battle);
		});

		dialog.textGroup.finishCallback = () -> {
			dialog.kill();

			new FlxTimer().start(.05, (t) -> {
				acceptInput = true;
			});
		};

		dialog.textGroup.tagCallback = handleTagCallback;


		lockBody = new FlxSprite(AssetPaths.lockBody__png);
		lockBody.screenCenter();
		lockBody.scrollFactor.set();

		lockLatch = new FlxSprite(AssetPaths.lockClasp__png);
		lockLatch.setPosition(lockBody.x + 6, lockBody.y - 41); // 70 in open position
		lockLatch.scrollFactor.set();

		// load our desired combo into the lock rollers here
		combo1 = new Combo(lockBody, 0, 5);
		combo2 = new Combo(lockBody, 1, 0);
		combo3 = new Combo(lockBody, 2, 9);
		comboRollers.push(combo1);
		comboRollers.push(combo2);
		comboRollers.push(combo3);

		cursor = new FlxSprite(AssetPaths.tumblerSelector__png);
		cursor.x = combo1.x - 4;
		cursor.y = lockBody.y + 17;
		cursor.scrollFactor.set();

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
			FmodManager.PlaySoundOneShot(FmodSFX.PadlockSelect);
		} else if (SimpleController.just_pressed(RIGHT)) {
			comboIndex++;
			FmodManager.PlaySoundOneShot(FmodSFX.PadlockSelect);
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

		cursor.x = selectedCombo.x - 4;

		if (SimpleController.just_pressed(UP)) {
			selectedCombo.currentNum--;
			FmodManager.PlaySoundOneShot(FmodSFX.PadlockUp2);
		} else if (SimpleController.just_pressed(DOWN)) {
			selectedCombo.currentNum++;
			FmodManager.PlaySoundOneShot(FmodSFX.PadlockDown2);
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
		FmodManager.PlaySoundOneShot(FmodSFX.PadlockFailTone);
		new FlxTimer().start(0.5, (t) -> {
			var rattleY = lockLatch.y-2;
			FlxTween.tween(lockLatch, {y: rattleY}, 0.1, {
				// ease: FlxEase.
				type: FlxTweenType.PINGPONG,
				onComplete: (t) -> {
					// 6 is 3 cycles of open->close
					if (t.executions % 2 == 0){
						FmodManager.PlaySoundOneShot(FmodSFX.PadlockFailDown);
					} else {
						FmodManager.PlaySoundOneShot(FmodSFX.PadlockFailUp);
					}
					if (t.executions == 6) {
						t.cancel();

						if (failCount >= 3) {
							dialog.loadDialogLine('Only Cludd has the genius to unlock me! However, he is a forgetful man.');
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
		});
	}

	function doSuccess() {
		success = true;
		FmodManager.PlaySoundOneShot(FmodSFX.PadlockSuccessMetal);
		FlxTween.tween(lockLatch, {y: lockLatch.y+5}, 0.1, {
			onComplete: (t) -> {
				var unlockY = lockBody.y-70;
				new FlxTimer().start(0.6, (t) -> {
					FmodManager.PlaySoundOneShot(FmodSFX.PadlockSuccessTone);
				});
				FlxTween.tween(lockLatch, {y: unlockY}, 0.4, {
					ease: FlxEase.sineInOut,
					onComplete: (t) -> {
						if (PlayState.ME != null) {
							PlayState.ME.eventSignal.dispatch("gate_unlocked");
						}
						new FlxTimer().start(1, (t) -> {
							transitionOut();
						});
					}
				});
			}
		});
	}

	function checkSuccess():Bool {
		return false;
	}
}

class Combo extends FlxSprite {
	public var index = 0;
	var lastNum = 0;
	public var currentNum = 0;
	public var digitHeight = 16;
	public var baseY:Float = 0;
	public var magicNumber = 0;

	// our zero is actually on the 3rd tile, so our scroll needs to be based on that position
	var zeroY = 41 - 18; // we want the 41st pixel to be in the middle of our 35 pixel high window

	var clipTmp = FlxRect.get();

	var rollerTween:FlxTween;

	public function new(relativeTo:FlxSprite, index:Int, magic:Int){
		baseY = relativeTo.y + 22;
		magicNumber = magic;
		super(relativeTo.x + 6 + (7 + 20)*index, baseY, AssetPaths.lockRoller__png);
		this.index = index;
		updateDigit(true);
		// Do this to force our clip rect to render immediately
		update(0.01);
		scrollFactor.set();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (currentNum != lastNum) {
			updateDigit();
			lastNum = currentNum;
		}

		updateClipRect();

		#if encounter_debug
		DebugDraw.ME.drawWorldRect(clipRect.x + x - offset.x, clipRect.y + y - offset.y, clipRect.width, clipRect.height);
		#end
	}

	function updateClipRect() {
		// TODO: Not sure why this 23 is the sauce, but I was tired of thinking
		clipTmp.set(0, zeroY + (baseY - y) - 23, width, 35);
		clipRect = clipTmp;
	}

	function updateDigit(instant:Bool = false) {
		if (rollerTween != null && !rollerTween.finished) {
			rollerTween.cancel();
		}

		var nextY = baseY - zeroY - currentNum * 16;
		if (instant) {
			y = baseY - zeroY - currentNum * 16;
		} else {
			rollerTween = FlxTween.tween(this, {y: nextY}, 0.1, {
				onComplete: (t) -> {
					// this makes sure we are locked nicely to our bounding sprite
					currentNum = FlxMath.wrap(currentNum, 0, 9);
					y = baseY - zeroY - currentNum * 16;
				}
			});
		}
	}
}