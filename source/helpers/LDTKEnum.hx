package helpers;

import flixel.FlxG;
import bitdecay.flixel.spacial.Cardinal;

class LDTKEnum {
	public static function asCardinal(val:Enum_Direction):Cardinal {
		switch(val) {
			case Enum_Direction.UP:
				return Cardinal.N;
			case Enum_Direction.DOWN:
				return Cardinal.S;
			case Enum_Direction.LEFT:
				return Cardinal.W;
			case Enum_Direction.RIGHT:
				return Cardinal.E;
			default:
				FlxG.log.warn('unhandled enum value $val');
				return Cardinal.NONE;
		}
	}
}