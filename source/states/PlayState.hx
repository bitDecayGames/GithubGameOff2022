package states;

import flixel.util.FlxSignal;
import quest.GlobalQuestState;
import entities.interact.InteractableFactory;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

import bitdecay.flixel.debug.DebugDraw;
import encounters.CharacterDialog;
import entities.Door;
import entities.Player;
import entities.npcs.NPCFactory;
import signals.Lifecycle;

using extension.CardinalExt;
using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
	public static var ME:PlayState;

	private static inline var START_LEVEL = "House_Lonk_2";

	public var player:Player;

	// the sorting layer will hold anything we want sorted by it's positional y-value
	public var sortingLayer:FlxTypedGroup<FlxSprite>;

	public var terrain:FlxSpriteGroup;
	public var entities:FlxTypedGroup<FlxSprite>;
	public var doors:FlxTypedGroup<Door>;
	public var interactables:FlxTypedGroup<FlxSprite>;
	public var collisions:FlxTypedGroup<FlxSprite>;
	public var dialogs:FlxGroup;
	public var level:LDTKProject_Level;

	var dialogCount = 0;

	public var playerActive:Bool = true;
	public var playerInTransition:Bool = false;

	public var transitionSignal = new FlxTypedSignal<String->Void>();

	override public function create() {
		super.create();
		ME = this;
		camera.bgColor = FlxColor.PINK;
		// FlxG.camera.pixelPerfectRender = true;

		Lifecycle.startup.dispatch();

		sortingLayer = new FlxTypedGroup<FlxSprite>();
		terrain = new FlxSpriteGroup();
		collisions = new FlxTypedGroup<FlxSprite>();
		entities = new FlxTypedGroup<FlxSprite>();
		interactables = new FlxTypedGroup<FlxSprite>();
		doors = new FlxTypedGroup<Door>();
		dialogs = new FlxGroup();
		add(terrain);
		add(collisions);
		// add(entities);
		// add(interactables);
		add(doors);
		add(sortingLayer);
		add(dialogs);

		loadLevel(START_LEVEL);
		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));

		FlxG.watch.add(GlobalQuestState, "currentQuest", "quest");
		FlxG.watch.add(GlobalQuestState, "subQuest", "subQuest");
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
		interactables.forEach((c) -> {
			c.destroy();
		});
		interactables.clear();
		sortingLayer.clear();

		// We might be able to just have this be a nice static thing
		var project = new LDTKProject();

		level = project.getLevel(uid, id);
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
			// sortingLayer.add(door);
		}

		for (eNPC in level.l_Entities.all_NPC) {
			var npc = NPCFactory.make(eNPC);
			if (npc != null) {
				// we may get null back if the NPC shouldn't spawn based on the current quest
				interactables.add(npc);
				sortingLayer.add(npc);
			}
		}

		for (eInteract in level.l_Entities.all_Interactable) {
			// TODO: need to come up with a proper way to parse out unique interactables
			var interact = InteractableFactory.make(eInteract);
			interactables.add(interact);
			sortingLayer.add(interact);
		}

		if (level.l_Entities.all_PlayerSpawn.length > 1) {
			throw('level ${level.identifier} has multiple spawns');
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
		sortingLayer.add(player);

		camera.follow(player);

		// TODO pass in name of level to help pick song
		playSong(level);
	}

	private function playSong(level:LDTKProject_Level) {
		if (!GlobalQuestState.DEFEATED_ALARM_CLOCK) {
			if (StringTools.startsWith(level.identifier, "House_Lonk")) {
				FmodManager.PlaySong(FmodSFX.AlarmClock);
			}
			if (level.identifier == "House_Lonk_1") {
				// FmodManager.SetEventParameterOnSong();
			}
		}
	}

	override public function update(elapsed:Float) {
		// TODO: probably a better way of handling this
		// dialogs.mem
		playerActive = dialogCount == 0 && !playerInTransition;

		super.update(elapsed);

		sortingLayer.sort(FlxSort.byY);

		var cam = FlxG.camera;
		DebugDraw.ME.drawWorldRect(-5, -5, 10, 10);

		FlxG.overlap(doors, player, playerTouchDoor);
		FlxG.collide(collisions, player);
		FlxG.collide(interactables, player);
	}

	function playerTouchDoor(d:Door, p:Player) {
		if (!playerActive) {
			return;
		}

		var diff = d.getMidpoint().subtractPoint(p.getMidpoint());
		if (d.accessDir.vertical() && Math.abs(diff.x) > 1) {
			p.oneFrameDirectionInfluence.set(diff.x, 0);
		} else if (d.accessDir.horizontal() && Math.abs(diff.y) > 1) {
			p.oneFrameDirectionInfluence.set(0, diff.y);
		} else {
			FmodManager.PlaySoundOneShot(FmodSFX.DoorOpen);
			transitionSignal.dispatch(d.destinationLevel);
			playerInTransition = true;
			d.animation.play('open');
			d.animation.finishCallback = (name) -> {
				p.allowCollisions = FlxObject.NONE;
				d.accessDir.opposite().asCleanVector(p.persistentDirectionInfluence);
				var clip = FlxRect.get(d.x, d.y, 16, 16);
				var walkDistance = 0.0;
				switch(d.accessDir) {
					case N:
						clip.y -= p.frameHeight;
						clip.height += p.frameHeight;
						walkDistance = clip.height + p.frameHeight;
					case S:
						clip.y += 1; // for nice pixel clipping
						clip.height += 16;
						walkDistance = clip.height + p.height;
					default:
						FlxG.log.warn('found a door with a unhandled access dir: ${d.accessDir}');
				}
				p.worldClip = clip;
				new FlxTimer().start(walkDistance / p.speed, (t) -> {
					p.persistentDirectionInfluence.set();
					loadLevel(d.destinationLevel, d.destinationDoorID);
					p.allowCollisions = FlxObject.ANY;
					playerInTransition = false;
					p.worldClip = null;
				});
			};
		}
	}

	public function startEncounter(encounterSubState:FlxSubState) {
		openSubState(encounterSubState);
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
