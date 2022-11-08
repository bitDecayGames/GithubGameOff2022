package entities;

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

class Player extends FlxSprite {
	var speed:Float = 60;
	var playerNum = 0;

	public var directionInfluence = FlxVector.get();

	var interactionBox:FlxObject;

	var tmp:FlxPoint = FlxPoint.get();

	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic(AssetPaths.player__png, true, 26, 34);
		setSize(16, 16);
		offset.set(5, 12);


		addAnimation(Characters.IDLE_ANIM, [ 0 ], 8);
		addAnimation(Characters.RUN_ANIM, [ for (i in 1...7) i ], 8);

		// give us a starting point
		animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');


		interactionBox = new FlxObject(0, 0, 10, 10);
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
		if (PlayState.ME.playerActive) {
			// Only check input direction if the game wants us to move
			var inputDir = InputCalcuator.getInputCardinal(playerNum);
			if (inputDir != NONE) {
				inputDir.asVector(velocity).scale(speed);
				facing = inputDir.asFacing();
			} else {
				velocity.set();
			}
		} else {
			velocity.set();
		}

		// do the influence outside of the other check to allow us to do some sort of cutscenes and such
		velocity.copyFrom(directionInfluence.normalize().scale(speed).addPoint(velocity).normalize().scale(speed));
		directionInfluence.set();

		super.update(delta);

		CardinalExt.fromFacing(facing).asVector(tmp).scale(Constants.TILE_SIZE).add(x, y).add(width/2, height/2);
		interactionBox.setPositionMidpoint(tmp.x, tmp.y);

		if (PlayState.ME.playerActive && SimpleController.just_pressed(Button.A, playerNum)) {
			// This seems wrong... not sure why, but it overlaps erroneously when the interaction box is to the right,
			// or below the interactable
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
