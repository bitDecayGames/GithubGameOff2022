package states.battles;

import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import encounters.CharacterDialog;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSubState;

class EncounterBaseState extends FlxSubState {
	// just a helper to toggle if player input should be accepted or not
	var acceptInput = false;

	// a flag to know if we succeeded the encounter or not
	public var success = false;

	// a flag to let us know when the state is done in regards to user input
	public var complete = false;

	var dialog:CharacterDialog;

	// put everything into this group, and the trasition will handle it nicely
	var battleGroup:FlxGroup = new FlxGroup();
	var transition:FlxSprite;

	var restoreCamFilters:Array<BitmapFilter>;

	public function new() {
		super();
	}

	override function create() {
		super.create();

		var bgImg = new FlxSprite();
		bgImg.makeGraphic(1,1, FlxColor.BLACK);
		bgImg.scrollFactor.set();
		// oversize this a bit to allow for camera shake without artifacts at the edges
		bgImg.scale.set(FlxG.width * 1.25, FlxG.height * 1.25);
		bgImg.updateHitbox();
		bgImg.screenCenter();
		battleGroup.add(bgImg);

		transition = new FlxSprite();
		transition.makeGraphic(1,1, FlxColor.BLACK);
		transition.alpha = 0;
		transition.scrollFactor.set();
		transition.scale.set(FlxG.width, FlxG.height);
		transition.updateHitbox();
		transition.screenCenter();

		add(battleGroup);
		add(transition);

		transitionIn();
	}

	// gives us access to the camera's internal filter list so we can restore it later
	@:access(flixel.FlxCamera)
	public function transitionIn(onDone:()->Void = null) {
		battleGroup.visible = false;
		battleGroup.active = false;

		var duration = 1.0;

		// we do two separate tweens
		FlxTween.tween(transition, { alpha: 1 }, duration, {
			onComplete: (t) -> {
				battleGroup.visible = true;
				FlxTween.tween(transition, { alpha: 0}, {
					onComplete: (t) -> {
						battleGroup.active = true;
						if (onDone != null) onDone();
					}
				});
				FlxTween.num(15, 0, duration, {}, function(v) {
					if (PlayState.ME != null) {
						PlayState.ME.mosaicShaderManager.setStrength(v, v);
					}
				}).onComplete = (t) -> {
					// after transition is done, remove all filters
					camera.setFilters([]);
				};
			}
		});
		// for start of transition, preserve any existing filters the game has active
		if (PlayState.ME != null) {
			restoreCamFilters = PlayState.ME.camera._filters;
			var transitionFilters = restoreCamFilters.copy();
			transitionFilters.push(PlayState.ME.mosaicFilter);
			// start with our filter in addition to whatever the game had going
			PlayState.ME.camera.setFilters(transitionFilters);
		}
		FlxTween.num(0, 15, duration, {}, function(v) {
			if (PlayState.ME != null) {
				PlayState.ME.mosaicShaderManager.setStrength(v, v);
			}
		}).onComplete = (t) -> {
			if (PlayState.ME != null) {
				// once we fully 'fade out', just use our mosaic filter
				PlayState.ME.camera.setFilters([PlayState.ME.mosaicFilter]);
			}
		};
	}

	public function transitionOut(onDone:()->Void = null) {
		complete = true;
		var duration = 1.0;
		FmodManager.StopSong();
		FlxTween.tween(transition, { alpha: 1 }, duration, {
			onComplete: (t) -> {
				battleGroup.visible = false;
				battleGroup.active = false;
				FlxTween.tween(transition, { alpha: 0}, {
					onComplete: (t) -> {
						close();
						if (onDone != null) onDone();
					}
				});

				if (PlayState.ME != null) {
					var transitionFilters = restoreCamFilters.copy();
					transitionFilters.push(PlayState.ME.mosaicFilter);
					// Then use both filters as come back to the game
					PlayState.ME.camera.setFilters(transitionFilters);
				}
				FlxTween.num(15, 0, duration, {}, function(v) {
					if (PlayState.ME != null) {
						PlayState.ME.mosaicShaderManager.setStrength(v, v);
					}
				}).onComplete = (t) -> {
					if (PlayState.ME != null) {
						// then finally restore the filters as they were before this encounter
						PlayState.ME.camera.setFilters(restoreCamFilters);
					}
				};
			}
		});
		if (PlayState.ME != null) {
			// start with just our mosaicfilter
			PlayState.ME.camera.setFilters([PlayState.ME.mosaicFilter]);
			FlxTween.num(0, 15, duration, {}, function(v) {
				PlayState.ME.mosaicShaderManager.setStrength(v, v);
			});
		}
	}

	// var lines: [
	// 	"hello, I might repeat myself!",
	// 	"hello, I might repeat myself!",
	// 	"hello, I might repeat myself!",
	// 	"Who now, how many times you gunna make me say that?"
	// ];

	// var dialogIndex = 0;
	// function dialogComplete() {
	// 	switch(dialogIndex) {
	// 		case 0:
	// 			dialogTest.loadDialogLine( "Welcome to the thunder dome. A pot stands before you. It <wave height=2>gazes</wave> <speed mod=0.1>deeeeply</speed> into your soul, as if to ask you to join it. You hear a quiet whisper, \"Do you yield, <cb val=camred /><shake dist=1><rainbow>MORTAL?</rainbow></shake><pause/>\"<cb val=camgrey />");
	// 		case 1:
	// 			close();
	// 		default:
	// 			trace('no dialog past this point');
	// 		dialogIndex++;
	// 	}
	// }

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}