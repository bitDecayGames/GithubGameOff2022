package entities;

import quest.GlobalQuestState;
import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.math.FlxRect;
import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;
import helpers.LDTKEnum;
import states.PlayState;

class Door extends FlxSprite {
	public var data:Entity_Door;

	public var iid:String;
	public var destinationLevel:String;
	public var destinationDoorID:String;
	public var accessDir:Cardinal;

	public var isStairs:Bool = false;
	public var isDownStairs:Bool = false;

	public var checks:Array<YayOrNay> = [];

	public function new(data:Entity_Door) {
		super(data.cx * 16, data.cy * 16);
		this.data = data;

		loadGraphic(AssetPaths.doorSheet__png, true, 32, 32);
		setSize(16, 16);
		iid = data.iid;

		updateDestination();

		accessDir = LDTKEnum.asCardinal(data.f_AccessDirection);

		immovable = true;

		isStairs = data.f_Stairs;
		isDownStairs = data.f_Down;
		if (isStairs) {
			if (isDownStairs) {
				animation.add('closed', [8], 5, false);
				animation.add('close', [8], 5, false);
				animation.add('open', [8], 5, false);
				animation.add('opened', [8], 5, false);
			} else {
				animation.add('closed', [9], 5, false);
				animation.add('close', [9], 5, false);
				animation.add('open', [9], 5, false);
				animation.add('opened', [9], 5, false);
			}
		} else {
			switch(accessDir) {
				case N | S:
					animation.add('closed', [0]);
					animation.add('close', [3, 2, 1], 5, false);
					animation.add('open', [1, 2, 3], 5, false);
					animation.add('opened', [3]);
					// offset.set(8, 13);
				case E | W:
					animation.add('closed', [4]);
					animation.add('close', [7, 6, 5], 5, false);
					animation.add('open', [5, 6, 7], 5, false);
					animation.add('opened', [7]);
					// offset.set(3, 7);
				default:
					// nothing to do here
			}
		}

		switch(accessDir) {
			case N:
				flipY = true;
				offset.set(8, 3);
			case S:
				offset.set(8, 13);
			case E:
				flipX = true;
				// x -= 10;
				offset.set(13, 7);
			case W:
				offset.set(3, 7);
			default:
		}

		animation.play('closed');
	}

	public function getClipRect():FlxRect {
		var clip = FlxRect.get(x, y, 16, 16);
		var player = PlayState.ME.player;
		switch(accessDir) {
			case N:
				clip.x -= 16;
				clip.width += 32;
				clip.y -= player.frameHeight;
				clip.height += player.frameHeight;
			case S:
				clip.x -= 16;
				clip.width += 32;
				clip.y += 1; // for nice pixel clipping
				clip.height += player.frameHeight;
			case E:
				clip.width += player.frameWidth;
				clip.y -= 16;
				clip.height += 32;
			case W:
				clip.y -= 16;
				clip.height += 32;
				clip.x -= player.frameWidth;
				clip.width += player.frameWidth;
			default:
				FlxG.log.warn('found a door with a unhandled access dir: ${accessDir}');
		}
		return clip;
	}

	// returns true if all checks pass, false otherwise
	public function shouldPass():Bool {
		for (ask in checks) {
			if (!ask.CheckDoor(this)) {
				return false;
			}
		}
		return true;
	}

	public function updateDestination() {
		// If we have specific quest doors, check to see if we should send the player somewhere else
		if (data.f_QuestDoor != null) {
			for (questName in data.f_QuestNames) {
				if (GlobalQuestState.currentQuest == questName || questName == "*") {
					destinationLevel = data.f_QuestDoor.levelIid;
					destinationDoorID = data.f_QuestDoor.entityIid;
					break;
				}
			}
		} else {
			destinationLevel = data.f_connection.levelIid;
			destinationDoorID = data.f_connection.entityIid;
		}
	}

	// Logic for SFX put in playstate next to doors
	public function enter() {
		if (isStairs) {
			if (isDownStairs) {

			} else {

			}
		}

		// make sure we are accurate to the current state
		updateDestination();
		PlayState.ME.loadLevel(destinationLevel, destinationDoorID);
	}
}