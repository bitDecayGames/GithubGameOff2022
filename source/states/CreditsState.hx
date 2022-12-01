package states;

import shaders.Greyen;
import entities.particles.ItemParticle;
import entities.interact.InteractableFactory;
import quest.GlobalQuestState;
import helpers.Analytics;
import com.bitdecay.analytics.Bitlytics;
import flixel.util.FlxTimer;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxBitmapText;
import config.Configure;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.UiHelpers;
import misc.FlxTextFactory;

using states.FlxStateExt;

class CreditsState extends FlxUIState {
	var _allCreditElements:Array<FlxSprite>;

	var _btnMainMenu:FlxButton;

	var _txtCreditsTitle:FlxBitmapText;
	var _txtThankYou:FlxBitmapText;
	var forPlaying:FlxBitmapText;
	var collectables:FlxBitmapText;
	var _txtRole:Array<FlxBitmapText>;
	var _txtCreator:Array<FlxBitmapText>;

	// Quick appearance variables
	private var backgroundColor = FlxColor.BLACK;

	static inline var entryLeftMargin = 10;
	static inline var entryRightMargin = 10;
	static inline var entryVerticalSpacing = 25;

	var scrollSpeedSecondsPerScreen = 6.0;
	var fastForwardScaler = 3.0;

	var initialScrollDelay = 0.5;

	var toolingImages = [
		AssetPaths.FLStudioLogo__png,
		AssetPaths.FmodLogoWhite__png,
		AssetPaths.HaxeFlixelLogo__png,
		AssetPaths.pyxel_edit__png
	];

	override public function create():Void {
		super.create();
		bgColor = backgroundColor;
		camera.pixelPerfectRender = true;

		Analytics.reportWin();

		new FlxTimer().start(3, (t) -> {
			FmodManager.PlaySong(FmodSongs.AwakenLullabyEnding);
		});

		// Credits

		_allCreditElements = new Array<FlxSprite>();

		_txtCreditsTitle = FlxTextFactory.make("Green Fleece", FlxG.width / 4, FlxG.height / 2, 40, FlxTextAlign.CENTER);
		center(_txtCreditsTitle);
		add(_txtCreditsTitle);

		_txtRole = new Array<FlxBitmapText>();
		_txtCreator = new Array<FlxBitmapText>();

		_allCreditElements.push(_txtCreditsTitle);

		for (entry in Configure.getCredits()) {
			AddSectionToCreditsTextArrays(entry.sectionName, entry.names, _txtRole, _txtCreator);
		}

		var creditsVerticalOffset = FlxG.height;

		for (flxText in _txtRole) {
			flxText.setPosition(entryLeftMargin, creditsVerticalOffset);
			creditsVerticalOffset += entryVerticalSpacing;
		}

		creditsVerticalOffset = FlxG.height + entryVerticalSpacing;

		for (flxText in _txtCreator) {
			flxText.setPosition(FlxG.width - flxText.width - entryRightMargin, creditsVerticalOffset);
			creditsVerticalOffset += entryVerticalSpacing;
		}

		for (toolImg in toolingImages) {
			var display = new FlxSprite();
			display.loadGraphic(toolImg);
			// scale them to be about 1/4 of the height of the screen
			var scale = (FlxG.height / 4) / display.height;
			if (display.width * scale > FlxG.width) {
				// in case that's too wide, adjust accordingly
				scale = FlxG.width / display.width;
			}
			display.scale.set(scale, scale);
			display.updateHitbox();
			display.setPosition(0, creditsVerticalOffset);
			center(display);
			add(display);
			creditsVerticalOffset += Math.ceil(display.height) + entryVerticalSpacing;
			_allCreditElements.push(display);
		}

		_txtThankYou = FlxTextFactory.make("Thank you", FlxG.width / 2, creditsVerticalOffset + FlxG.height / 2, 24, FlxTextAlign.CENTER);
		_txtThankYou.alignment = FlxTextAlign.CENTER;
		center(_txtThankYou);
		add(_txtThankYou);
		_allCreditElements.push(_txtThankYou);
		creditsVerticalOffset += Math.ceil(_txtThankYou.height) + 2;

		forPlaying = FlxTextFactory.make("for playing!", FlxG.width / 2, creditsVerticalOffset + FlxG.height / 2, 24, FlxTextAlign.CENTER);
		forPlaying.alignment = FlxTextAlign.CENTER;
		center(forPlaying);
		add(forPlaying);
		_allCreditElements.push(forPlaying);

		var collectablesFound = 0;
		var donutFound = false;
		var gameboyFound = false;
		var coughdropFound = false;

		var donutImage = new ItemParticle(FlxG.width / 2 - 30, creditsVerticalOffset + FlxG.height / 2 + 60, DONUT);
		if (InteractableFactory.collected.exists("donut")){
			collectablesFound++;
			donutFound = true;
		} else {
			var greyShader = new Greyen();
			donutImage.shader = greyShader;
		}
		_allCreditElements.push(donutImage);
		add(donutImage);

		var gameboyImage = new ItemParticle(FlxG.width / 2, creditsVerticalOffset + FlxG.height / 2 + 60, GAMEBOY);
		if (InteractableFactory.collected.exists("gameboy_console")){
			collectablesFound++;
			gameboyFound = true;
		} else {
			var greyShader = new Greyen();
			gameboyImage.shader = greyShader;
		}
		_allCreditElements.push(gameboyImage);
		add(gameboyImage);
		
		var coughdropImage = new ItemParticle(FlxG.width / 2 + 30, creditsVerticalOffset + FlxG.height / 2 + 60, COUGH_DROP);
		if (InteractableFactory.collected.exists("coughdrop")){
			collectablesFound++;
			coughdropFound = true;
		} else {
			var greyShader = new Greyen();
			coughdropImage.shader = greyShader;
		}
		_allCreditElements.push(coughdropImage);
		add(coughdropImage);
		

		collectables = FlxTextFactory.make("Collectables found: " + collectablesFound + "/3", FlxG.width / 2, creditsVerticalOffset + FlxG.height / 2 + 40, 10, FlxTextAlign.CENTER);
		collectables.alignment = FlxTextAlign.CENTER;
		center(collectables);
		add(collectables);
		_allCreditElements.push(collectables);

		// we want them to start off the bottom and come onto the screen
		for (e in _allCreditElements) {
			e.y += FlxG.height;
		}
	}

	private function AddSectionToCreditsTextArrays(role:String, creators:Array<String>, finalRoleArray:Array<FlxBitmapText>, finalCreatorsArray:Array<FlxBitmapText>) {
		var roleText = FlxTextFactory.make(role, 0, 0, 15);
		add(roleText);
		finalRoleArray.push(roleText);
		_allCreditElements.push(roleText);

		if (finalCreatorsArray.length != 0) {
			finalCreatorsArray.push(new FlxBitmapText());
		}

		for (creator in creators) {
			// Make an offset entry for the roles array
			finalRoleArray.push(new FlxBitmapText());

			var creatorText = FlxTextFactory.make(creator, 0, 0, 15, FlxTextAlign.RIGHT);
			add(creatorText);
			finalCreatorsArray.push(creatorText);
			_allCreditElements.push(creatorText);
		}

		// put some padding under to space out the next section
		finalRoleArray.push(new FlxBitmapText());
		finalCreatorsArray.push(new FlxBitmapText());
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (initialScrollDelay > 0) {
			initialScrollDelay -= elapsed;
			return;
		}

		// Stop scrolling when "Thank You" text is in the center of the screen
		if (forPlaying.y < FlxG.height / 2) {
			return;
		}

		var scrollMod = FlxG.height / scrollSpeedSecondsPerScreen * elapsed;
		if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed) {
			scrollMod *= fastForwardScaler;
		}

		for (element in _allCreditElements) {
			element.y -= scrollMod;
		}
	}

	private function center(o:FlxObject) {
		o.x = (FlxG.width - o.width) / 2;
	}

	function clickMainMenu():Void {
		FmodFlxUtilities.TransitionToState(new MainMenuState());
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
