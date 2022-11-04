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
}