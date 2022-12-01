package states;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import config.Configure;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import haxefmod.flixel.FmodFlxUtilities;

using states.FlxStateExt;

class SplashScreenState extends FlxState {
	public static inline var PLAY_ANIMATION = "play";

	var index = 0;
	var splashImages:Array<FlxSprite> = [];

	var timer = 0.0;
	var tweenTime = 1.4;
	var splashDuration = 2.5;

	var currentTween:FlxTween = null;
	var splashesOver:Bool = false;
	var fadingOut:Bool = false;

	override public function create():Void {
		super.create();

		FmodManager.PlaySong(FmodSongs.AwakenLullaby);

		// List splash screen image paths here
		loadSplashImages([
			new SplashImage(AssetPaths.bitdecaygamesinverted__png),
			new SplashImage(AssetPaths.ld_logo__png),
			new SplashImage(AssetPaths.titleScreen__png)
		]);

		timer = splashDuration;
		currentTween = getFadeIn(index);
	}

	// A function that returns if the current splash should be skipped or not
	// Customize this to check whatever we want (controller, mouse, etc)
	private function checkForSkip():Bool {
		var skip = false;
		if (Configure.config.menus.keyboardNavigation) {
			skip = skip || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER;
		}
		if (Configure.config.menus.controllerNavigation) {
			var gamepad = FlxG.gamepads.lastActive;
			if (gamepad != null) {
				skip = skip || gamepad.justPressed.A;
			}
		}
		return skip || FlxG.mouse.justPressed;
	}

	private function loadSplashImages(splashes:Array<SplashImage>) {
		for (i in 0...splashes.length) {
			var s = splashes[i];
			s.y = -(FlxG.height * splashes.length) + (i * FlxG.height);
			add(s);
			s.alpha = 1;
			splashImages.push(s);
		}
		camera.scroll.y = -FlxG.height * (splashes.length + 1);
	}

	override public function update(elapsed:Float):Void {
		FlxG.watch.addQuick('cam scroll:', camera.scroll);
		super.update(elapsed);
		timer -= elapsed;
		if (timer < 0) {
			nextSplash();
		}
	}

	private function getFadeIn(index:Int):VarTween {
		var fadeInTween:VarTween = null;
		if (index >= splashImages.length) {
			fadeInTween = FlxTween.tween(camera.scroll, {y: 0}, tweenTime, {
				ease: FlxEase.quadInOut
			});
		} else {
			var splash = splashImages[index];
			fadeInTween = FlxTween.tween(camera.scroll, {y: splash.y}, tweenTime, {
				ease: FlxEase.quadInOut
			});
			if (splash.animation.getByName(PLAY_ANIMATION) != null) {
				fadeInTween.onComplete = (t) -> splash.animation.play(PLAY_ANIMATION);
				splash.animation.callback = (name, frameNumber, frameIndex) -> {
					// Can add sfx or other things here
				};
			}
		}

		fadeInTween.onComplete = (t) -> {
			timer = index < splashImages.length ? splashDuration : 1;
		}

		fadeInTween.onStart = (t) -> {
			fadingOut = false;
		};
		return fadeInTween;
	}

	public function nextSplash() {
		timer = 1000; // just do this to hold us over for now
		if (splashesOver) {
			// nothing more to do
			return;
		}

		if (currentTween != null && !currentTween.finished) {
			currentTween.cancel();
		}

		fadingOut = true;
		index += 1;
		if (index <= splashImages.length) {
			getFadeIn(index);
		} else {
			splashesOver = true;
			FmodFlxUtilities.TransitionToState(new PlayState());
		}
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}

class SplashImage extends FlxSprite {
	public function new(gfx:FlxGraphicAsset, width:Int = 0, height:Int = 0, startFrame:Int = 0, endFrame:Int = -1, rate:Int = 10) {
		super(gfx);
		var animated = width != 0 && height != 0;
		loadGraphic(gfx, animated, width, height);
		animation.add(SplashScreenState.PLAY_ANIMATION, [for (i in startFrame...endFrame) i], rate, false);

		if (animated) {
			scale.set(FlxG.width / width, FlxG.height / height);
		} else {
			scale.set(FlxG.width / frameWidth, FlxG.height / frameHeight);
		}

		updateHitbox();
	}
}
