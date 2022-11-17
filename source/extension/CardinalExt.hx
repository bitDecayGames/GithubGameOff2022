package extension;

import flixel.math.FlxVector;
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

	public static function asCleanVector(c:Cardinal, v:FlxVector = null) {
		if (v == null) {
			v = FlxVector.get();
		}
		v.set();

		switch (c) {
			case NW | N | NE:
				v.y = -1;
			case SW | S | SE:
				v.y = 1;
			default:
		}
		switch (c) {
			case NE | E | SE:
				v.x = 1;
			case NW | W | SW:
				v.x = -1;
			default:
		}

		return v.normalize();
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