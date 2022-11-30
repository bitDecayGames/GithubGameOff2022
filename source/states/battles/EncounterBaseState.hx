package states.battles;

import quest.GlobalQuestState;
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

	public var dialog:CharacterDialog;

	// put everything into this group, and the trasition will handle it nicely
	var battleGroup:FlxGroup = new FlxGroup();
	var transition:FlxSprite;
	var bgImg:FlxSprite;

	var restoreCamFilters:Array<BitmapFilter>;

	public var onTransInDone:()->Void;
	public var onTransOutDone:()->Void;

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
	public function transitionIn() {
		var duration = 1.0;
		if (GlobalQuestState.currentQuest == Enum_QuestName.End_game){
			duration = 3.25;
		}
		if (dialog.characterIndex == LONK) {
			duration = 0.1;
		}

		battleGroup.visible = false;
		battleGroup.active = false;

		// we do two separate tweens
		FlxTween.tween(PlayState.ME.dialogCamera, {alpha: 0}, duration);
		FlxTween.tween(transition, { alpha: 1 }, duration, {
			onComplete: (t) -> {
				battleGroup.visible = true;

				if (GlobalQuestState.currentQuest == Enum_QuestName.End_game){
					battleGroup.active = true;
					FlxTween.tween(transition, { alpha: 0}, 1, {
						onComplete: (t) -> {
							battleGroup.active = true;
							if (onTransInDone != null) {
								onTransInDone();
							}
						}
					});
				} else {
					FlxTween.tween(transition, { alpha: 0}, duration, {
						onComplete: (t) -> {
							battleGroup.active = true;
							if (onTransInDone != null) {
								onTransInDone();
							}
						}
					});
				}
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
			if (restoreCamFilters == null) {
				restoreCamFilters = [];
			}
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

	public function transitionOut() {
		var duration = 1.0;
		if (dialog.characterIndex == LONK) {
			duration = 0.1;
		}
		complete = true;
		if (dialog.characterIndex != LONK) {
			FmodManager.StopSong();
		}
		FlxTween.tween(transition, { alpha: 1 }, duration, {
			onComplete: (t) -> {
				battleGroup.visible = false;
				battleGroup.active = false;
				FlxTween.tween(PlayState.ME.dialogCamera, {alpha: 1}, duration);
				FlxTween.tween(transition, { alpha: 0}, duration, {
					onComplete: (t) -> {
						close();
						if (onTransOutDone != null) {
							onTransOutDone();
						}
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

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function destroy() {
		if (dialog.characterIndex == LONK) {
			// keep our dialog from being destroyed
			battleGroup.remove(dialog);
		}
		super.destroy();
	}
}