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
		loadGraphic(AssetPaths.doorSheet__png, true, 32, 32);
		animation.add('closed', [0]);
		animation.add('open', [1, 2, 3], 5, false);
		animation.add('opened', [3]);
		animation.play('closed');
		setSize(16, 16);
		offset.set(8, 13);
		iid = data.iid;
		destinationLevel = data.f_connection.levelIid;
		destinationDoorID = data.f_connection.entityIid;
		accessDir = LDTKEnum.asCardinal(data.f_AccessDirection);
	}
}