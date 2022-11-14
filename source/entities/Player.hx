package entities;

import js.html.Console;
import flixel.util.FlxColor;
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
import extension.CardinalExt;
import entities.interact.Interactable;

using extension.CardinalExt;

class Player extends FlxSprite {
	public var lockControls:Bool = false;

	public var speed:Float = 60;
	var playerNum = 0;

	public var persistentDirectionInfluence = FlxVector.get();
	public var oneFrameDirectionInfluence = FlxVector.get();

	var interactionBox:FlxObject;

	public var worldClip:FlxRect = null;

	var tmp:FlxPoint = FlxPoint.get();

	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic(AssetPaths.player__png, true, 26, 34);
		setSize(16, 16);
		offset.set(5, 12);


		addAnimation(Characters.IDLE_ANIM, [ 0 ], 8);
		addAnimation(Characters.RUN_ANIM, [ for (i in 1...7) i ], 8);

		addAnimationCallback();

		// give us a starting point
		animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');


		interactionBox = new FlxObject(0, 0, 10, 10);
	}

	public static inline var GRASS = 1;
	public static inline var BRICK = 2;
	public static inline var DIRT = 3;

	function addAnimationCallback():Void {
		animation.callback = (name, frameNumber, frameIndex) -> {
			if (StringTools.contains(name, '${Characters.RUN_ANIM}')) {

				// var footPosition1 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(4).rotateByDegrees(270));
				// var footPosition2 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(4).rotateByDegrees(90));

				var feetPosition = getFeetPosition(name);
				var recSize = 5;
				DebugDraw.ME.drawWorldRect(feetPosition[0].x-recSize/2, feetPosition[0].y-recSize/2, recSize, recSize);
				DebugDraw.ME.drawWorldRect(feetPosition[1].x-recSize/2, feetPosition[1].y-recSize/2, recSize, recSize);

				if (!StringTools.contains(name, 'left')) {
					if (frameNumber == 2){
						playStepSound(getTerrainIndex(feetPosition[0]));
					} else if (frameNumber == 5) {
						playStepSound(getTerrainIndex(feetPosition[1]));
					}
				} else {
					if (frameNumber == 2){
						playStepSound(getTerrainIndex(feetPosition[1]));
					} else if (frameNumber == 5) {
						playStepSound(getTerrainIndex(feetPosition[0]));
					}
				}
			}
		}
	}

	function getFeetPosition(animationName:String):Array<FlxPoint> {

		var footPosition1:FlxPoint;
		var footPosition2:FlxPoint;

		if (StringTools.contains(animationName, 'up') || StringTools.contains(animationName, 'down')){
			footPosition1 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(4).rotateByDegrees(270)).addPoint(new FlxPoint(0,4));
			footPosition2 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(4).rotateByDegrees(90)).addPoint(new FlxPoint(0,4));
		} else if (StringTools.contains(animationName, 'right')){
			footPosition1 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(-5).rotateByDegrees(270));
			footPosition2 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(7).rotateByDegrees(90));
		} else {
			footPosition1 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(7).rotateByDegrees(270));
			footPosition2 = getMidpoint().addPoint(CardinalExt.fromFacing(facing).asVector().scale(-5).rotateByDegrees(90));
		}

		return [footPosition1, footPosition2];
	}

	function getTerrainIndex(footPosition:FlxPoint):Int {
		return PlayState.ME.level.l_Terrain.getInt(Std.int(footPosition.x/16), Std.int(footPosition.y/16));
	}

	function playStepSound(terrainIndex:Int){
		switch(terrainIndex) {
			case GRASS:
				FmodManager.PlaySoundOneShot(FmodSFX.FootstepGrass);
			case DIRT:
				FmodManager.PlaySoundOneShot(FmodSFX.FootstepWood);
			case BRICK:
				FmodManager.PlaySoundOneShot(FmodSFX.FootstepStone);
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

		if(lockControls){
			return;
		}

		if (worldClip != null) {
			clipRect = FlxRect.get(worldClip.x - x + offset.x, worldClip.y - y + offset.y, worldClip.width, worldClip.height);
			DebugDraw.ME.drawWorldRect(worldClip.x, worldClip.y, worldClip.width, worldClip.height);
			// DebugDraw.ME.drawWorldRect(clipRect.x + x, clipRect.y + y, clipRect.width, clipRect.height, 0xFFFFFF);
		} else if (clipRect != null) {
			clipRect = null;
		}

		if (PlayState.ME.playerActive) {
			// Only check input direction if the game wants us to move
			var inputDir = InputCalcuator.getInputCardinal(playerNum);
			if (inputDir != NONE) {
				inputDir.asCleanVector(velocity).scale(speed);
				facing = inputDir.asFacing();
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

		if (PlayState.ME.playerActive && SimpleController.just_pressed(Button.A, playerNum)) {
			// This seems wrong... not sure why, but it overlaps erroneously when the interaction box is to the right,
			// or below the interactable
			trace("attempting to interact");
			FlxG.overlap(PlayState.ME.interactables, interactionBox, playerInteracts);
		}

		updateAnimations();
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
			var dir = animation.curAnim.name.split('_')[1];
			animation.play('${Characters.IDLE_ANIM}_$dir');
		}

		FlxG.watch.addQuick('player set anim: ', animation.curAnim.name);
	}

	function playerInteracts(i:Interactable, other:FlxObject) {
		// TODO: This is triggering twice for some reason
		i.interact();
	}

	#if FLX_DEBUG
	override function drawDebug() {
		super.drawDebug();
		interactionBox.drawDebug();
	}
	#end
}
