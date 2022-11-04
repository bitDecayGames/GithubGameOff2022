package entities;

import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxObject;
import states.PlayState;
import flixel.FlxG;
import flixel.math.FlxPoint;
import bitdecay.flixel.debug.DebugDraw;
import input.SimpleController;
import input.InputCalcuator;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import extension.CardinalExt;

class Player extends FlxSprite {
	var speed:Float = 30;
	var playerNum = 0;

	var interactionBox:FlxObject;

	var tmp:FlxPoint = FlxPoint.get();

	public function new(X:Float, Y:Float) {
		super(X, Y);
		makeGraphic(16, 16, FlxColor.WHITE);
		color = FlxColor.BLUE;

		interactionBox = new FlxObject(0, 0, 10, 10);
	}

	override public function update(delta:Float) {
		var inputDir = InputCalcuator.getInputCardinal(playerNum);
		if (inputDir != NONE) {
			inputDir.asVector(velocity).scale(speed);
			facing = inputDir.asFacing();
		} else {
			velocity.set();
		}


		super.update(delta);

		CardinalExt.fromFacing(facing).asVector(tmp).scale(Constants.TILE_SIZE).add(x, y).add(width/2, height/2);
		interactionBox.setPositionMidpoint(tmp.x, tmp.y);

		if (SimpleController.just_pressed(Button.A, playerNum)) {
			// This seems wrong... not sure why, but it overlaps erroneously when the interaction box is to the right,
			// or below the interactable
			FlxG.overlap(PlayState.ME.interactables, interactionBox, playerInteracts);
		}
	}

	function playerInteracts(i:Interactable, box:FlxObject) {
		trace('interaction beginneth!');
	}

	#if FLX_DEBUG
	override function drawDebug() {
		super.drawDebug();
		interactionBox.drawDebug();
	}
	#end
}
