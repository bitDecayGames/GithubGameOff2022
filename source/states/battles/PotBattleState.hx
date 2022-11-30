package states.battles;

import flixel.util.FlxStringUtil;
import flixel.input.keyboard.FlxKey;
import shaders.Redden;
import quest.GlobalQuestState;
import shaders.BlinkHelper;
import encounters.CharacterIndex;
import com.bitdecay.lucidtext.parse.TagLocation;
import particles.Slash;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import encounters.CharacterDialog;
import input.SimpleController;


using zero.flixel.extensions.FlxPointExt;

class PotBattleState extends EncounterBaseState {
	var potSprite:FlxSprite;
	var potOffsetY = 9;
	var ring:FlxSprite;
	var cursor:FlxSprite;
	var cursorAngle = 0.0;

	var potY = 0.0;

	// spin speed in degrees per second
	var spinSpeed = 0.0;
	var maxSpinSpeed = 180.0;

	var attackLimit = 5;

	var weakPointsGroup = new FlxTypedGroup<FlxSprite>();
	var attackGroup = new FlxTypedGroup<FlxSprite>();

	var fightGroup:FlxGroup;

	var isFinalBattle:Bool;
	var isFinalPhase:Bool;
	var isFinalPhaseHarder:Bool;

	public function new(foe:CharacterDialog, ?finalBattle:Bool = false, ?finalPhase:Bool = false, ?finalPhaseHarder:Bool = false) {
		super(finalBattle);
		dialog = foe;
		dialog.textGroup.tagCallback = potTagHandle;
		isFinalBattle = finalBattle;
		isFinalPhase = finalPhase;
		isFinalPhaseHarder = finalPhaseHarder;
	}

	override function create() {
		super.create();

		if (isFinalBattle) {
			FmodManager.PlaySong(FmodSongs.Lonk);
		} else {
			new FlxTimer().start(1.75, (t) -> {
				FmodManager.PlaySong(FmodSongs.Battle);
			});
		}

		if (isFinalPhaseHarder) {
			FmodManager.SetEventParameterOnSong("LowPassLonk", 1);
		}

		fightGroup = new FlxGroup();

		ring = new FlxSprite(AssetPaths.ring__png);
		ring.scrollFactor.set();

		ring.screenCenter();
		ring.alpha = 0;

		potSprite = new FlxSprite();
		switch dialog.characterIndex {
			case LONK:
				potSprite.loadGraphic(AssetPaths.bodypunch__png, true, 80, 120);
				potSprite.animation.add('good', [0]);
				potSprite.animation.add('bad', [1]);
				potOffsetY = 30;
				if (isFinalPhaseHarder) {
					potSprite.animation.add('good', [2]);
					randomizeAimPoints(1);
					attackLimit = 100;
					maxSpinSpeed = 100;
				}
				else if (isFinalPhase) {
					randomizeAimPoints(8);
					attackLimit = 9;
					maxSpinSpeed = 270;
				}
				else if (isFinalBattle) {
					randomizeAimPoints(6);
					attackLimit = 7;
					maxSpinSpeed = 270;
				}
			case RUBBERPOT:
				randomizeAimPoints(4);
				potSprite.loadGraphic(AssetPaths.battlePot__png, true, 80, 80);
				potSprite.animation.add('good', [0]);
				potSprite.animation.add('bad', [0]);
			default:
				randomizeAimPoints(5);
				potSprite.loadGraphic(AssetPaths.battlePot2__png, true, 80, 80);
				potSprite.animation.add('good', [0]);
				potSprite.animation.add('bad', [1]);
		}

		if (isFinalPhase && !isFinalPhaseHarder) {
			var reddenShader = new Redden();
			potSprite.shader = reddenShader;
		}

		potSprite.animation.play('good');

		potSprite.scrollFactor.set();
		potSprite.screenCenter();
		potSprite.y -= potOffsetY;
		potY = potSprite.y;
		battleGroup.add(potSprite);

		cursor = new FlxSprite();
		cursor.scrollFactor.set();
		cursor.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		// can't figure out how to just draw a circle outline... so just draw a black circle on top of the white circle
		FlxSpriteUtil.drawCircle(cursor, -1, -1, -1, FlxColor.RED);
		cursor.alpha = 0;

		cursorAngle = FlxG.random.float(0, 279);
		var point = ring.getGraphicMidpoint().place_on_circumference(cursorAngle, ring.width/2);
		cursor.setPositionMidpoint(point.x, point.y);
		point.put();

		// make sure our attacks are under our cursor
		fightGroup.add(ring);
		fightGroup.add(weakPointsGroup);
		fightGroup.add(attackGroup);
		fightGroup.add(cursor);

		battleGroup.add(fightGroup);
		fightGroup.active = false;
		battleGroup.add(dialog);

		if (FlxStringUtil.isNullOrEmpty(dialog.textGroup.rawText)) {
			begin();
		} else {
			dialog.textGroup.finishCallback = () -> {
				begin();
			};
		}
	}

	function begin() {
		dialog.kill();
			fightGroup.active = true;

			new FlxTimer().start(0.5, (t) -> {
				FlxTween.tween(ring, { alpha: 1 }, 0.5, {
					onStart: (t) -> {FmodManager.PlaySoundOneShot(FmodSFX.PotRingSpawn);},
					onComplete: (t) -> {
						var delay = 0.0;
						weakPointsGroup.forEach((wp) -> {
							new FlxTimer().start(delay, (t) -> {
								FmodManager.PlaySoundOneShot(FmodSFX.PotTargetSpawn);
								FlxTween.tween(wp, { alpha: 1}, 0.5);
							});
							delay += .35;
						});
						// give a solid delay between the weak points and the player cursor
						delay += .5;
						new FlxTimer().start(delay, (t) -> {
							FmodManager.PlaySoundOneShot(FmodSFX.PotPlayerCursorSpawn3);
							FlxTween.tween(cursor, { alpha: 1}, 0.5, {
								onComplete: (t) -> {
									acceptInput = true;
									FlxTween.tween(this, { spinSpeed: maxSpinSpeed }, { ease: FlxEase.sineIn });
								}
							});
						});
					}
				});
			});
	}

	var placed:Array<Int> = [];
	function randomizeAimPoints(num:Int) {
		for (i in 0...num) {
			var placement = FlxG.random.int(0, 17, placed);
			placed.push(placement);
			var point = ring.getGraphicMidpoint().place_on_circumference(placement * 20, ring.width/2);
			var aim = new FlxSprite();
			aim.scrollFactor.set();
			aim.makeGraphic(10, 10, FlxColor.TRANSPARENT);
			FlxSpriteUtil.drawCircle(aim, -1, -1, -1, (isFinalBattle ? FlxColor.WHITE : FlxColor.PINK));

			aim.setPositionMidpoint(point.x, point.y);
			point.put();

			aim.alpha = 0;

			weakPointsGroup.add(aim);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		FmodManager.Update();

		cursorAngle += spinSpeed * elapsed;
		cursorAngle = cursorAngle % 360;
		var point = ring.getGraphicMidpoint().place_on_circumference(cursorAngle, ring.width/2);
		cursor.setPositionMidpoint(point.x, point.y);
		point.put();

		if(FlxG.keys.justPressed.P){
			success = true;
			transitionOut();
		}

		if (!acceptInput) {
			return;
		}

		if (complete) {
			return;
		}

		if (SimpleController.just_pressed(A) && attackGroup.length < attackLimit) {
			createAttack();
		}

		if (checkSuccess()) {
			// TODO: success end sequence start
			complete = true;
			success = true;
			animateAttacks();
			finishFight();
		} else if (attackGroup.length == attackLimit) {
			// failure
			// TODO: SFX failure begins. cursor slows rotation
			acceptInput = false;
			complete = true;
			success = false;
			new FlxTimer().start(1, (t) -> {
				FlxTween.tween(this, { spinSpeed: 0 }, 2,
					{
						ease: FlxEase.sineOut,
						onComplete: (t) -> {
							switch dialog.characterIndex {
								case RUBBERPOT:
									dialog.loadDialogLine('Your puny arms are <bigger>too weak</bigger> to defeat me.');
								case LONK:
									dialog.loadDialogLine('<cb val=mad/>Pathetic');
								default:
									dialog.loadDialogLine('The pot seems unscathed');
							}
							dialog.textGroup.finishCallback = () -> {
								transitionOut();
							};
							dialog.revive();
						}
					});
			});
		}
	}

	function createAttack() {
		FmodManager.PlaySoundOneShot(FmodSFX.PotPlayerAttemptStrike);
		FlxG.camera.shake(0.02, 0.1);
		var point = ring.getGraphicMidpoint().place_on_circumference(cursorAngle, ring.width/2);
		var attack = new FlxSprite();
		attack.scrollFactor.set();
		// Different size to keep a unique image
		attack.makeGraphic(11, 11, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawCircle(attack, -1, -1, -1, FlxColor.BLUE);

		attack.setPositionMidpoint(point.x, point.y);
		// copy our position into our last so that collisions work nicely on first frame of existence
		attack.getPosition(attack.last);
		point.put();

		attackGroup.add(attack);
	}

	function checkSuccess():Bool {
		var success = true;
		// use this loop if we notice it feeling bad.
		// weakPointsGroup.forEach((weakness) -> {
		// 	if (!FlxG.overlap(weakness, attackGroup)) {
		// 		success = false;
		// 	}
		// });

		// this new loop uses pixel perfect, which should be more accurate to the circles
		weakPointsGroup.forEach((weakness) -> {
			var atLeastOneHit = false;
			for (attack in attackGroup) {
				if (FlxG.pixelPerfectOverlap(weakness, attack)) {
					atLeastOneHit = true;
					break;
				}
			}
			if (!atLeastOneHit) {
				success = false;
			}
		});

		return success;
	}

	function animateAttacks() {
		var attackTweens = new Array<()->Void>();

		var delay = 0.0;
		attackGroup.forEach((a) -> {
			var hits = new Array<FlxSprite>();
			// if this starts rendering weird, just use this loop instead
			// var overlap = FlxG.overlap(a, weakPointsGroup, (attack, point) -> {
			// 	hits.push(point);
			// });

			// this is the new loop that uses pixel perfect
			var overlap = false;
			for (point in weakPointsGroup) {
				if (FlxG.pixelPerfectOverlap(a, point)) {
					hits.push(point);
					overlap = true;
				}
			}

			if (overlap) {
				var localDelay = delay;
				delay += .35;
				attackTweens.push(() -> {
					var t = new FlxTimer().start(localDelay, (t) -> {
						FmodManager.PlaySoundOneShot(FmodSFX.PotPlayerStrikeFinal);
						BlinkHelper.Blink(potSprite, .1, 1, potSprite.shader);
						FlxG.camera.shake(0.02, 0.1);
						// camera.flash(0.05);
						var particle = new Slash(a.x, a.y);
						particle.scale.set(FlxG.random.float(1, 5), FlxG.random.float(1, 5));
						particle.scrollFactor.set();
						particle.flipX = FlxG.random.bool();
						particle.flipY = FlxG.random.bool();
						add(particle);

						a.kill();

						for (h in hits) {
							// FlxTween.tween(h, {alpha: 0}, 0.2);
							h.kill();
						}
					});
				});
			} else {
				attackTweens.push(() -> {
					// FlxTween.tween(a, {alpha: 0}, 0.2);
					a.kill();
				});
			}
		});
		FlxTween.tween(ring, {alpha: 0}, 1);
		FlxTween.tween(cursor, {alpha: 0}, 1);
		FlxTween.tween(this, { spinSpeed: 0 }, 1,
		{
			ease: FlxEase.sineOut,
			onComplete: (t) -> {
				for (at in attackTweens) {
					at();
				}
			}
		});
	}

	function potTagHandle(tag:TagLocation) {
		if (tag.tag == "cb") {
			if (tag.parsedOptions.val == "repair") {
				FlxTween.tween(potSprite, { y: potY }, 0.5, {ease: FlxEase.quadOut});
				FlxTween.tween(potSprite, { "scale.x": 1, "scale.y": 1 }, 0.5, {
					ease: FlxEase.bounceOut,
				});
				FmodManager.PlaySoundOneShot(FmodSFX.PotRebound3);
			} else {
				// only handle the emotions we know we support
				if (['happy', 'mad', 'neutral', 'sad'].contains(tag.parsedOptions.val)) {
					dialog.setExpression(tag.parsedOptions.val);
				}
			}
		}
	}

	function finishFight() {
		if (dialog.characterIndex == RUBBERPOT) {
			new FlxTimer().start(3, (t) -> {
				FmodManager.PlaySoundOneShot(FmodSFX.PotDestroy);

				FlxTween.tween(potSprite, { y: potY + 20 }, 1);
				FlxTween.tween(potSprite, { "scale.x": 1.4, "scale.y": 0.5 }, 1, {
					ease: FlxEase.bounceInOut,
				});
			});
			new FlxTimer().start(4.5, (t) -> {
				dialog.loadDialogLine('<speed mod=0.3>I....    I.....<page/></speed>I<cb val=repair/> am ok, actually. I am made of rubber after all!');
				dialog.textGroup.finishCallback = () -> {
					transitionOut();
				};
				dialog.revive();
			});
		} else {
			new FlxTimer().start(3, (t) -> {
				FmodManager.PlaySoundOneShot(FmodSFX.PotDestroy);
				potSprite.animation.play('bad');
				if (isFinalPhaseHarder){
					FmodManager.StopSongImmediately();
				}
			});
			new FlxTimer().start(4.5, (t) -> {
				// TODO: This should be gotten from somewhere else.
				switch dialog.characterIndex {
					case LONK:
						if (!isFinalPhase) {
							dialog.loadDialogLine('<cb val=mad /><bigger><fade>OOF...</fade></bigger>');
						} else {
							dialog.loadDialogLine('<cb val=mad />......');
						}
					default:
						dialog.loadDialogLine('<cb val=sad/>I have shattered into countless pieces. It would be impossible to put me back together.');
				}
				dialog.textGroup.finishCallback = () -> {
					transitionOut();
				};
				dialog.revive();
			});
		}

	}
}