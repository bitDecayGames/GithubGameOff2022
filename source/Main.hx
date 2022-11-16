package;

import ui.font.TextColors;
import flixel.math.FlxPoint;
import com.bitdecay.lucidtext.TextGroup;
import com.bitdecay.lucidtext.effect.EffectRegistry;
import flixel.system.debug.log.LogStyle;
import haxe.Timer;
import audio.FmodPlugin;
import achievements.Achievements;
import helpers.Storage;
import states.SplashScreenState;
import misc.Macros;
import states.MainMenuState;
import flixel.FlxState;
import config.Configure;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import misc.FlxTextFactory;
import openfl.display.Sprite;
#if play
import states.PlayState;
#elseif pot_battle
import states.battles.PotBattleState;
#end

class Main extends Sprite {
	public function new() {
		super();
		Configure.initAnalytics(false);

		Storage.load();
		Achievements.initAchievements();

		configureTextEffects();

		var startingState:Class<FlxState> = SplashScreenState;
		#if play
		startingState = PlayState;
		#elseif pot_battle
		startingState = PotBattleState;
		#else
		if (Macros.isDefined("SKIP_SPLASH")) {
			startingState = MainMenuState;
		}
		#end
		addChild(new FlxGame(256, 244, startingState, 1, 60, 60, true, false));

		FlxG.stage.quality = flash.display.StageQuality.LOW;

		FlxG.fixedTimestep = false;

		// Disable flixel volume controls as we don't use them because of FMOD
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;

		// Don't use the flixel cursor
		FlxG.mouse.useSystemCursor = true;

		#if debug
		FlxG.autoPause = false;
		#end

		// Set up basic transitions. To override these see `transOut` and `transIn` on any FlxTransitionable states
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.35);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.35);

		FlxTextFactory.defaultFont = AssetPaths.Brain_Slab_8__ttf;

		FlxG.plugins.add(new FmodPlugin());

		configureLogging();
	}

	private function configureTextEffects() {
		TextGroup.defaultScrollFactor = FlxPoint.get();
		EffectRegistry.registerDefault("scrub", { height: 3 });
		EffectRegistry.registerDefault("shake", { dist: 1 });
		TextColors.init();
	}

	private function configureLogging() {
		#if FLX_DEBUG
		LogStyle.WARNING.openConsole = true;
		LogStyle.WARNING.callbackFunction = () -> {
			// Make sure we open the logger if a log triggered
			FlxG.game.debugger.log.visible = true;
		};

		LogStyle.ERROR.openConsole = true;
		LogStyle.ERROR.callbackFunction = () -> {
			// Make sure we open the logger if a log triggered
			FlxG.vcr.pause();
			FlxG.game.debugger.log.visible = true;
		};
		#end
	}
}
