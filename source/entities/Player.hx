package entities;

import flixel.util.FlxTimer;
import quest.GlobalQuestState;
import bitdecay.flixel.debug.DebugDraw;
import flixel.math.FlxRect;
import constants.Characters;
import flixel.math.FlxVector;
import flixel.FlxObject;
import states.PlayState;
import flixel.FlxG;
import flixel.math.FlxPoint;
import input.SimpleController;
import input.InputCalcuator;
import flixel.FlxSprite;
import entities.interact.Interactable;

using extension.CardinalExt;

class Player extends FlxSprite {
	public static inline var SLEEP = 'sleep_down';
	public static inline var STARTLED = 'startled_down';
	public static inline var ITEM_GET = 'itemget_down';

	public var lockControls:Bool = false;
	public var isInteracting = false;

	public var speed:Float = 60;
	var playerNum = 0;

	public var persistentDirectionInfluence = FlxVector.get();
	public var oneFrameDirectionInfluence = FlxVector.get();

	var interactionBox:FlxObject;

	public var worldClip:FlxRect = null;

	var tmp:FlxPoint = FlxPoint.get();
	var foot1:FlxPoint = FlxPoint.get();
	var foot2:FlxPoint = FlxPoint.get();

	public function new(X:Float, Y:Float) {

		if (GlobalQuestState.SPEEDY_DEBUG){
			speed = 120;
		}

		// Because we change the hitbox to 14x14 instead of 16x16, we create the sprite
		// with a 1-pixel offset so it's aligned correctly with the map's 16x16 tiles
		// NOTE: This _should_ just need to be 1, however, it looks proper with 2 pixels instead.
		super(X + 3, Y + 2);
		loadGraphic(AssetPaths.player__png, true, 26, 34);
		setSize(12, 14);
		offset.set(8, 14);


		addAnimation(Characters.IDLE_ANIM, [ 0 ], 8);
		addAnimation(Characters.RUN_ANIM, [ for (i in 1...7) i ], 8);
		animation.add(SLEEP, [24,25,26] , 8);
		animation.add(STARTLED, [27] , 8);
		animation.add(ITEM_GET, [33]);

		addAnimationCallback();

		// give us a starting point
		animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');

		interactionBox = new FlxObject(0, 0, 10, 10);

		PlayState.ME.eventSignal.add(handleEvent);
	}

	function handleEvent(e:String) {
		if (e == "compassCollected") {
			lockControls = true;
			animation.play(ITEM_GET);
			// TODO SFX: item gotted jingle
			FmodManager.PlaySoundOneShot(FmodSFX.PotRebound);
		}
		if (e == "compassDropped") {
			lockControls = true;
			animation.play(STARTLED);
			// TODO SFX: compass dropped / crash
			FmodManager.PlaySoundOneShot(FmodSFX.AlarmBreak);

			new FlxTimer().start(2, (t) -> {
				lockControls = false;
				updateAnimations(true);
			});
		}
	}

	override function destroy() {
		super.destroy();
	}

	function addAnimationCallback():Void {
		animation.callback = (name, frameNumber, frameIndex) -> {
			if (StringTools.contains(name, '${Characters.RUN_ANIM}')) {
				updateFeetPositions(name);

				if (!StringTools.contains(name, 'left')) {
					if (frameNumber == 2){
						playStepSound(getTerrainIndex(foot1));
					} else if (frameNumber == 5) {
						playStepSound(getTerrainIndex(foot2));
					}
				} else {
					if (frameNumber == 2){
						playStepSound(getTerrainIndex(foot1));
					} else if (frameNumber == 5) {
						playStepSound(getTerrainIndex(foot2));
					}
				}
			}
		}
	}

	function updateFeetPositions(animationName:String) {
		if (StringTools.contains(animationName, 'up') || StringTools.contains(animationName, 'down')){
			getMidpoint(foot1).addPoint(CardinalExt.fromFacing(facing).asVector().rotateByDegrees(270).scale(5)).addPoint(new FlxPoint(0,4));
			getMidpoint(foot2).addPoint(CardinalExt.fromFacing(facing).asVector().rotateByDegrees(90).scale(5)).addPoint(new FlxPoint(0,4));
		} else if (StringTools.contains(animationName, 'right')){
			getMidpoint(foot1).addPoint(CardinalExt.fromFacing(facing).asVector().rotateByDegrees(270).scale(-5));
			getMidpoint(foot2).addPoint(CardinalExt.fromFacing(facing).asVector().rotateByDegrees(90).scale(7));
		} else {
			getMidpoint(foot1).addPoint(CardinalExt.fromFacing(facing).asVector().rotateByDegrees(270).scale(7));
			getMidpoint(foot2).addPoint(CardinalExt.fromFacing(facing).asVector().rotateByDegrees(90).scale(-5));
		}
	}

	function getTerrainIndex(footPosition:FlxPoint):Enum_GroundType {
		if (PlayState.ME.level.l_Ground.hasAnyTileAt(Std.int(footPosition.x/16), Std.int(footPosition.y/16))) {
			// This is trash, but haven't found a better way to do it yet
			var stack = PlayState.ME.level.l_Ground.getTileStackAt(Std.int(footPosition.x/16), Std.int(footPosition.y/16));
			for (stackTile in stack) {
				if (PlayState.ME.level.l_Ground.tileset.hasTag(stackTile.tileId, Carpet)) {
					return Carpet;
				}
				if (PlayState.ME.level.l_Ground.tileset.hasTag(stackTile.tileId, Cobble)) {
					return Cobble;
				}
				if (PlayState.ME.level.l_Ground.tileset.hasTag(stackTile.tileId, Grass)) {
					return Grass;
				}
				if (PlayState.ME.level.l_Ground.tileset.hasTag(stackTile.tileId, Dirt)) {
					return Dirt;
				}
				if (PlayState.ME.level.l_Ground.tileset.hasTag(stackTile.tileId, Wood)) {
					return Wood;
				}
			}
		}
		return Dirt;
	}

	function playStepSound(type:Enum_GroundType){
		switch(type) {
			case Carpet:
				// TODO SFX: Carpet
			case Cobble:
				// TODO SFX: Cobble
			case Grass:
				FmodManager.PlaySoundOneShot(FmodSFX.FootstepGrass);
			case Dirt:
				FmodManager.PlaySoundOneShot(FmodSFX.FootstepStone);
			case Wood:
				FmodManager.PlaySoundOneShot(FmodSFX.FootstepWood);
		};
	}

	// frames are assumed to be in the down direction
	function addAnimation(baseName:String, frames:Array<Int>, rowLength:Int) {
		animation.add('${baseName}_${Characters.DOWN}', frames, Characters.BASE_FRAMERATE );

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
		if (worldClip != null) {
			clipRect = FlxRect.get(worldClip.x - x + offset.x, worldClip.y - y + offset.y, worldClip.width, worldClip.height);
			DebugDraw.ME.drawWorldRect(worldClip.x, worldClip.y, worldClip.width, worldClip.height);
			// DebugDraw.ME.drawWorldRect(clipRect.x + x, clipRect.y + y, clipRect.width, clipRect.height, 0xFFFFFF);
		} else if (clipRect != null) {
			clipRect = null;
		}

		#if footstep_debug
		DebugDraw.ME.drawWorldRect(foot1.x-1, foot1.y-1, 2, 2, 0xFFFFFF);
		DebugDraw.ME.drawWorldRect(foot2.x-1, foot2.y-1, 2, 2, 0xFFFFFF);
		#end

		if (!lockControls && PlayState.ME.playerActive) {
			// Only check input direction if the game wants us to move
			var inputDir = InputCalcuator.getInputCardinal(playerNum);
			if (inputDir != NONE) {
				inputDir.asCleanVector(velocity).scale(speed);
				switch (inputDir) {
					case NW | N | NE:
						facing = FlxObject.UP;
					case SW | S | SE:
						facing = FlxObject.DOWN;
					case W:
						facing = FlxObject.LEFT;
					case E:
						facing = FlxObject.RIGHT;
					default:
						facing = FlxObject.UP;
				}
			} else {
				velocity.set();
			}
		} else {
			velocity.set();
		}

		// do the influence outside of the other check to allow us to do some sort of cutscenes and such
		velocity.copyFrom(oneFrameDirectionInfluence.addPoint(persistentDirectionInfluence).normalize().scale(speed).addPoint(velocity).normalize().scale(speed));
		oneFrameDirectionInfluence.set();

		super.update(delta);

		CardinalExt.fromFacing(facing).asVector(tmp).scale(Constants.TILE_SIZE).add(x, y).add(width/2, height/2);
		interactionBox.setPositionMidpoint(tmp.x, tmp.y);
		interactionBox.last.set(interactionBox.x, interactionBox.y);

		if (PlayState.ME.playerActive && SimpleController.just_pressed(Button.A, playerNum)) {
			// This seems wrong... not sure why, but it overlaps erroneously when the interaction box is to the right,
			// or below the interactable
			trace("attempting to interact");
			isInteracting = false;
			FlxG.overlap(PlayState.ME.interactables, interactionBox, playerInteracts);
		}

		updateAnimations();
		FlxG.watch.addQuick("player anim: ", animation.curAnim.name);
	}

	function updateAnimations(force:Bool = false) {
		if (!force) {
			if (animation.curAnim.name == SLEEP || animation.curAnim.name == STARTLED || animation.curAnim.name == ITEM_GET) {
				return;
			}
		}

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
			var dir = animation.curAnim.name.split('_')[1];
			animation.play('${Characters.IDLE_ANIM}_$dir');
		}

		FlxG.watch.addQuick('player set anim: ', animation.curAnim.name);
	}

	function playerInteracts(i:Interactable, other:FlxObject) {
		if (isInteracting) {
			// TODO: This is triggering twice for some reason
			// I guess this is a known issue
			return;
		}
		i.interact();
		isInteracting = true;
	}

	#if FLX_DEBUG
	override function drawDebug() {
		super.drawDebug();
		interactionBox.drawDebug();
	}
	#end
}
