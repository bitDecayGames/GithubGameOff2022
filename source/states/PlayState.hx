package states;

import encounters.CharacterDialog;
import characters.BasicPot;
import states.battles.PotBattleState;
import states.battles.EncounterBaseState;
import flixel.group.FlxSpriteGroup;
import entities.Interactable;
import entities.NPC;
import flixel.math.FlxVector;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import entities.Door;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import achievements.Achievements;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import bitdecay.flixel.debug.DebugDraw;

using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
	public static var ME:PlayState;

	public var player:FlxSprite;

	public var terrain:FlxSpriteGroup;
	public var entities:FlxTypedGroup<FlxSprite>;
	public var doors:FlxTypedGroup<Door>;
	public var interactables:FlxTypedGroup<FlxSprite>;
	public var collisions:FlxTypedGroup<FlxSprite>;
	public var dialogs:FlxGroup;
	var dialogCount = 0;

	public var playerActive:Bool = true;

	override public function create() {
		super.create();
		ME = this;
		camera.bgColor = FlxColor.PINK;
		FlxG.camera.pixelPerfectRender = true;

		Lifecycle.startup.dispatch();

		terrain = new FlxSpriteGroup();
		collisions = new FlxTypedGroup<FlxSprite>();
		entities = new FlxTypedGroup<FlxSprite>();
		interactables = new FlxTypedGroup<FlxSprite>();
		doors = new FlxTypedGroup<Door>();
		dialogs = new FlxGroup();
		add(terrain);
		add(collisions);
		add(entities);
		add(interactables);
		add(doors);
		add(dialogs);

		loadLevel(0);
		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));
	}

	// loads the level with the given id, optionally spawning the player at the provided doorID
	// Can provide either the uid int, or the iid string, but not both
	function loadLevel(?uid:Null<Int>, ?id:Null<String>, doorID:String = null) {
		// clean up current level;
		player = null;
		doors.forEach((d) -> {
			d.destroy();
		});
		doors.clear();
		terrain.forEach((e) -> {
			e.destroy();
		});
		terrain.clear();
		entities.forEach((e) -> {
			e.destroy();
		});
		entities.clear();
		collisions.forEach((c) -> {
			c.destroy();
		});
		collisions.clear();

		// We might be able to just have this be a nice static thing
		var project = new LDTKProject();

		var level = project.getLevel(uid, id);
		if (level == null) {
			for (pl in project.levels) {
				if (pl.iid == id) {
					level = pl;
					break;
				}
			}
		}

		var collisionLayer = level.l_Collisions;
		// NOTE: We do stuff in screen space, so we need to make sure at least our raw screen coords are within
		// the world bounds
		var boundsWidth = Math.max(FlxG.width, collisionLayer.cWid * collisionLayer.gridSize);
		var boundsHeight = Math.max(FlxG.height, collisionLayer.cHei * collisionLayer.gridSize);
		FlxG.worldBounds.set(0, 0, boundsWidth, boundsHeight);
		trace(FlxG.worldBounds);
		collisionLayer.render().forEach((s) -> {
			s.immovable = true;
			s.updateHitbox();
			collisions.add(s);
		});

		level.l_Terrain.render(terrain);

		for (eDoor in level.l_Entities.all_Door) {
			var door = new Door(eDoor);
			doors.add(door);
		}

		for (eNPC in level.l_Entities.all_NPC) {
			var npc = new NPC(eNPC);
			interactables.add(npc);
		}

		for (eInteract in level.l_Entities.all_Interactable) {
			// TODO: need to come up with a proper way to parse out unique interactables
			var interact = new Interactable(eInteract.cx * Constants.TILE_SIZE, eInteract.cy * Constants.TILE_SIZE);
			interactables.add(interact);
		}

		if (level.l_Entities.all_PlayerSpawn.length > 1) {
			throw ('level ${level.identifier} has multiple spawns');
		}

		var playerStart = FlxPoint.get();
		if (FlxStringUtil.isNullOrEmpty(doorID)) {
			var spawnData = level.l_Entities.all_PlayerSpawn[0];
			playerStart.set(spawnData.cx * 16, spawnData.cy * 16);
		} else {
			var matches = doors.members.filter((d) -> d.iid == doorID);
			if (matches.length != 1) {
				throw 'expected door in level ${level.identifier} with iid ${doorID}, but got ${matches.length} matches';
			}
			playerStart.set(matches[0].x, matches[0].y);
			var tmp = FlxVector.get();
			// TODO: Likely will want to tween the player into the stage
			playerStart.addPoint(matches[0].accessDir.asVector(tmp).scale(17));
			tmp.put();

			playerStart.put();
		}
		player = new Player(playerStart.x, playerStart.y);
		entities.add(player);
		camera.follow(player);
	}

	override public function update(elapsed:Float) {
		// TODO: probably a better way of handling this
		// dialogs.mem
		playerActive = dialogCount == 0;

		super.update(elapsed);

		var cam = FlxG.camera;
		DebugDraw.ME.drawWorldRect(-5, -5, 10, 10);

		FlxG.overlap(doors, player, playerTouchDoor);
		FlxG.collide(collisions, player);
	}

	function playerTouchDoor(d:Door, p:Player) {
		var diff = d.getMidpoint().subtractPoint(p.getMidpoint());
		if (d.accessDir.vertical() && Math.abs(diff.x) > 1) {
			p.directionInfluence.set(diff.x, 0);
		} else if (d.accessDir.horizontal() && Math.abs(diff.y) > 1) {
			p.directionInfluence.set(0, diff.y);
		} else {
			loadLevel(d.destinationLevel, d.destinationDoorID);
		}
	}

	public function startEncounter() {
		openSubState(new PotBattleState(new BasicPot()));
	}

	public function openDialog(dialog:CharacterDialog) {
		// TODO: need to figure out how to clear this stuff out
		dialogs.add(dialog);
		dialogCount++;
	}

	public function closeDialog(dialog:CharacterDialog) {
		// TODO: need to figure out how to clear this stuff out
		if (dialogs.remove(dialog) != null) {
			dialogCount--;
		}
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
