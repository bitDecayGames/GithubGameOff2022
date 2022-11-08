package extension;

import flixel.FlxObject;
import bitdecay.flixel.spacial.Cardinal;

class CardinalExt {
	public static function fromFacing(facing:Int):Cardinal {
		switch(facing) {
			case FlxObject.UP:
				return N;
			case FlxObject.DOWN:
				return S;
			case FlxObject.LEFT:
				return W;
			case FlxObject.RIGHT:
				return E;
		}

		return NONE;
	}

	public static function asUDLR(c:Cardinal):String {
		switch(c) {
			case N:
				return "up";
			case E:
				return "right";
			case S:
				return "down";
			case W:
				return "left";
			default:
				return "none";
		}
	}
}