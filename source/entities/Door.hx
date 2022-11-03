package entities;

import bitdecay.flixel.spacial.Cardinal;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import helpers.LDTKEnum;

class Door extends FlxSprite {
	public var iid:String;
	public var destinationLevel:String;
	public var destinationDoorID:String;
	public var accessDir:Cardinal;

	public function new(data:Entity_Door) {
		super(data.cx * 16, data.cy * 16);
		makeGraphic(16, 16, FlxColor.PURPLE);
		updateHitbox();
		iid = data.iid;
		destinationLevel = data.f_connection.levelIid;
		destinationDoorID = data.f_connection.entityIid;
		accessDir = LDTKEnum.asCardinal(data.f_AccessDirection);
	}
}