package states;

import flixel.math.FlxMath;
import flixel.FlxCamera;
import openfl.filters.ShaderFilter;
import shaders.Lighten;
import flixel.FlxCamera.FlxCameraFollowStyle;
import shaders.BlinkHelper;
import input.SimpleController;
import entities.misc.House;
import constants.Characters;
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

import entities.interact.AlarmClock;

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

	private static inline var START_LEVEL = "House_Lonk_room_boy";

	private static var LEVEL_ARRAY = ["House_Lonk_room_boy", "Town_main", "House_Cludd_Main", "House_Cludd_Basement"];
	private var levelSelectionCursor = 0;

	public var player:Player;

	// the sorting layer will hold anything we want sorted by it's positional y-value
	public var sortingLayer:FlxTypedGroup<FlxSprite>;

	public var terrain:FlxSpriteGroup;
	public var entities:FlxTypedGroup<FlxSprite>;
	public var doors:FlxTypedGroup<Door>;
	public var interactables:FlxTypedGroup<FlxSprite>;
	public var collisions:FlxTypedGroup<FlxSprite>;
	public var uiHelpers:FlxTypedGroup<FlxSprite>;
	public var dialogs:FlxGroup;
	public var level:LDTKProject_Level;

	public var levelState:LevelState;

	var project = new LDTKProject();

	var dialogCount = 0;

	public var playerActive:Bool = true;
	public var playerInTransition:Bool = false;

	public var transitionSignal = new FlxTypedSignal<String->Void>();

	// handle events for the current level. Cleared out on level load
	public var eventSignal = new FlxTypedSignal<String->Void>();

	// handle events. Please clean up after yourself as this is never emptied automatically
	public var eventSignalPersistent = new FlxTypedSignal<String->Void>();

	override public function create() {
		super.create();
		ME = this;
		camera.bgColor = FlxColor.BLACK;
		// FlxG.camera.pixelPerfectRender = true;

		var dialogCamera = new FlxCamera();
		dialogCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(dialogCamera, false);

		Lifecycle.startup.dispatch();

		sortingLayer = new FlxTypedGroup<FlxSprite>();
		terrain = new FlxSpriteGroup();
		collisions = new FlxTypedGroup<FlxSprite>();
		uiHelpers = new FlxTypedGroup<FlxSprite>();
		entities = new FlxTypedGroup<FlxSprite>();
		interactables = new FlxTypedGroup<FlxSprite>();
		doors = new FlxTypedGroup<Door>();
		dialogs = new FlxGroup();
		// dialogs go to a second camera so shaders don't mess with them
		dialogs.cameras = [dialogCamera];
		add(terrain);
		add(collisions);
		// add(entities);
		// add(interactables);
		// add(doors);
		add(sortingLayer);
		add(uiHelpers);
		add(dialogs);

		loadLevel(START_LEVEL);
		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));

		FlxG.watch.add(GlobalQuestState, "currentQuest", "quest");
		FlxG.watch.add(GlobalQuestState, "subQuest", "subQuest");
	}

	// loads the level with the given id, optionally spawning the player at the provided doorID
	// Can provide either the uid int, or the iid string, but not both
	@:access(flixel.FlxCamera)
	function loadLevel(?uid:Null<Int>, ?id:Null<String>, doorID:String = null) {
		// clean up current level;
		player = null;
		// Clean up any event listeners between levels;
		eventSignal.removeAll();
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
		uiHelpers.forEach((c) -> {
			c.destroy();
		});
		uiHelpers.clear();
		sortingLayer.clear();

		level = project.getLevel(uid, id);
		if (level == null) {
			for (pl in project.levels) {
				if (pl.iid == id) {
					level = pl;
					if (level.identifier == "Town_main") {
						GlobalQuestState.leftHouseFirstTime = true;
					}
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
		addCollisionsToWorld(collisionLayer);

		level.l_Ground.render(terrain);

		for (eHouse in level.l_Entities.all_House) {
			var house = new House(eHouse);
			sortingLayer.add(house);

			for (door in house.getDoors()) {
				doors.add(door);
				sortingLayer.add(door);
			}
		}

		for (eDoor in level.l_Entities.all_Door) {
			var found = false;
			for (eHouse in level.l_Entities.all_House) {
				for (doorRef in eHouse.f_Doors) {
					if (doorRef.entityIid == eDoor.iid) {
						found = true;
					}
				}
			}
			if (found) {
				// this door is accounted for by house logic. Don't load it here
				continue;
			}
			var door = new Door(eDoor);
			doors.add(door);
			sortingLayer.add(door);
		}

		for (eNPC in level.l_Entities.all_NPC) {
			var npc = NPCFactory.make(eNPC);
			if (npc != null) {
				// we may get null back if the NPC shouldn't spawn based on the current quest
				interactables.add(npc);
				sortingLayer.add(npc);
			}
		}

		// the BottomDecor layer is treated as terrain so that it renders underneath all entities
		level.l_BottomDecor.render(terrain);

		// The other decor layers are injected directly into our sorting group so they behave like world objects
		var group = level.l_Decor.render();
		level.l_TopDecor.render(group);
		for (decorSprite in group.members) {
			sortingLayer.add(decorSprite);
		}


		for (eInteract in level.l_Entities.all_Interactable) {
			// TODO: need to come up with a proper way to parse out unique interactables
			var interact = InteractableFactory.make(eInteract);
			if (interact == null) {
				// this happens if this item was already collected/killed/etc (i.e. shouldn't show up again)
				continue;
			}

			interactables.add(interact);
			sortingLayer.add(interact);
		}

		if (level.l_Entities.all_PlayerSpawn.length > 1) {
			throw('level ${level.identifier} has multiple spawns');
		}

		var playerStart = FlxVector.get();
		if (FlxStringUtil.isNullOrEmpty(doorID)) {
			var spawnData = level.l_Entities.all_PlayerSpawn[0];
			if (spawnData != null){
				player = new Player(spawnData.pixelX, spawnData.pixelY);
			} else {
				player = new Player(level.pxWid/2, level.pxHei/2);
			}
		} else {
			var matches = doors.members.filter((d) -> d.iid == doorID);
			if (matches.length != 1) {
				throw 'expected door in level ${level.identifier} with iid ${doorID}, but got ${matches.length} matches';
			}
			var startDoor = matches[0];
			startDoor.animation.play('opened');
			playerStart.set(startDoor.x, startDoor.y);
			var transitionStart = startDoor.accessDir.opposite().asVector().scale(17);
			var transitionEnd = startDoor.getPosition().addPoint(startDoor.accessDir.asVector().scale(17));
			playerStart.addPoint(transitionStart);
			if (startDoor.accessDir == N) {
				// make sure they walk in from fully off the screen (aka outside of the door)
				// This number is magic and is the difference between the player hitbox height and the sprite height
				playerStart.y += 20;
			}

			player = new Player(playerStart.x, playerStart.y);

			var walkDistance = playerStart.subtractPoint(transitionEnd).length;
			playerStart.put();
			transitionStart.put();
			transitionEnd.put();

			player.facing = startDoor.accessDir.asFacing();
			player.lockControls = true;
			player.persistentDirectionInfluence = startDoor.accessDir.asCleanVector();
			player.allowCollisions = FlxObject.NONE;

			var clip = startDoor.getClipRect();
			player.worldClip = clip;

			playerInTransition = true;

			// move the character slightly further than the edge of the door hitbox
			new FlxTimer().start(walkDistance / player.speed, (t) -> {
				player.worldClip = null;
				player.persistentDirectionInfluence.set();
				startDoor.animation.play('close');
				startDoor.animation.finishCallback = (n) -> {
					startDoor.animation.play('closed');
					playerInTransition = false;
					player.lockControls = false;
					player.allowCollisions = FlxObject.ANY;
				}
			});
		}
		entities.add(player);
		sortingLayer.add(player);

		camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT);

		if (level.pxWid <= camera.width) {
			camera.deadzone.x = 1;
			camera.deadzone.width = FlxG.width - 2;
			camera.scroll.x = -(FlxG.width - level.pxWid) / 2;
		}

		if (level.pxHei <= camera.height) {
			camera.deadzone.y = 1;
			camera.deadzone.height = FlxG.height - 2;
			camera.scroll.y = -(FlxG.height - level.pxHei) / 2;
		}

		// do this so our scroll start point is respected (it gets overriden otherwise and the camera is in the wrong)
		camera._scrollTarget.set(camera.scroll.x, camera.scroll.y);

		levelState = LevelState.LoadLevelState(level);
	}

	override public function update(elapsed:Float) {

		levelState.update();

		if (FlxG.keys.justPressed.LBRACKET) {
			levelSelectionCursor = FlxMath.wrap(levelSelectionCursor-1, 0, LEVEL_ARRAY.length-1);
			loadLevel(LEVEL_ARRAY[levelSelectionCursor]);
		} else if (FlxG.keys.justPressed.RBRACKET) {
			levelSelectionCursor = FlxMath.wrap(levelSelectionCursor+1, 0, LEVEL_ARRAY.length-1);
			loadLevel(LEVEL_ARRAY[levelSelectionCursor]);
		}

		#if cam_debug
		if (FlxG.keys.pressed.J) {
			camera.scroll.x--;
		}
		if (FlxG.keys.pressed.L) {
			camera.scroll.x++;
		}
		if (FlxG.keys.pressed.I) {
			camera.scroll.y--;
		}
		if (FlxG.keys.pressed.K) {
			camera.scroll.y++;
		}

		DebugDraw.ME.drawCameraRect(camera.deadzone.x, camera.deadzone.y, camera.deadzone.width, camera.deadzone.height);
		DebugDraw.ME.drawWorldRect(-5, -5, 10, 10);

		FlxG.watch.addQuick("cam scroll:", camera.scroll);
		#end

		// TODO: probably a better way of handling this
		// dialogs.mem
		playerActive = dialogCount == 0 && !playerInTransition;

		// TODO terrible hack I sorry
		if (!GlobalQuestState.DEFEATED_ALARM_CLOCK && FmodManager.GetCurrentSongPath() == FmodSFX.AlarmClock) {
			FmodManager.SetEventParameterOnSong("AlarmLowPass", 0);
			if (level.identifier == "House_Lonk_1") {
				FmodManager.SetEventParameterOnSong("AlarmLowPass", 1);
			}
		}

		FlxG.watch.addQuick("Active: ", playerActive);
		if (!GlobalQuestState.WOKEN_FIRST_TIME){
			GlobalQuestState.WOKEN_FIRST_TIME = true;
			if (!GlobalQuestState.SPEEDY_DEBUG) {
				player.lockControls = true;
				player.animation.play(Player.SLEEP);
				new FlxTimer().start(6.75, (t) -> {
					eventSignal.dispatch('alarmStart');
					FmodManager.PlaySong(FmodSFX.AlarmClock);
					player.animation.play(Player.STARTLED);
					new FlxTimer().start(2.5, (t) -> {
						player.animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');
						player.lockControls = false;
					});
				});
			}
		}

		FmodManager.Update();

		super.update(elapsed);

		FlxG.overlap(doors, player, playerTouchDoor);
		FlxG.collide(collisions, player);
		FlxG.collide(interactables, player);

		sortTheSortingLayer();
	}

	function sortTheSortingLayer() {
		// sort objects by their reference Y (typically bottom edge)
		sortingLayer.sort((Order:Int, Obj1:FlxObject, Obj2:FlxObject) -> {
			var o1RefY = Obj1.y + Obj1.height;
			var o2RefY = Obj2.y + Obj2.height;

			if (Obj1 is Door) {
				o1RefY = Obj1.y - 2;
			} else if (Obj2 is Door) {
				o2RefY = Obj2.y - 2;
			}

			return FlxSort.byValues(Order, o1RefY, o2RefY);
		});
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
			// make the player face the door
			p.setIdleAnimation(d.accessDir.opposite());
			FmodManager.PlaySoundOneShot(FmodSFX.DoorOpen);
			transitionSignal.dispatch(d.destinationLevel);
			playerInTransition = true;
			d.animation.play('open');
			d.animation.finishCallback = (name) -> {
				p.allowCollisions = FlxObject.NONE;
				d.accessDir.opposite().asCleanVector(p.persistentDirectionInfluence);
				var clip = d.getClipRect();
				var walkDistance = 0.0;
				switch(d.accessDir) {
					case N:
						walkDistance = Math.abs(clip.bottom - player.y) + player.height;
						// walkDistance = Math.abs(clip.bottom - player.y) + player.frameHeight;
					case S:
						walkDistance = Math.abs(clip.y - player.y) + player.height;
					case E:
						walkDistance = 32;
					case W:
						walkDistance = 32;
					default:
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
		camera.setFilters([]);
		openSubState(encounterSubState);
	}

	override public function closeSubState():Void {
		super.closeSubState();
		levelState.updateShaders();
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

	function addCollisionsToWorld(collisionLayer:levels.ldtk.Layer_Collisions) {
		var checkPoint = FlxPoint.get();
		var result = 0;
		collisionLayer.render().forEach((s) -> {
			s.immovable = true;
			s.updateHitbox();
			// Comment this line out if you want to render/debug collisions
			s.visible = false;
			collisions.add(s);
			s.allowCollisions = FlxObject.ANY;
			checkPoint.set(Std.int(s.x/8) + 1, Std.int(s.y/8));
			result = collisionLayer.getInt(Std.int(checkPoint.x), Std.int(checkPoint.y));
			if (result > 0) {
				//collision to the right, so clean up this collision edge
				s.allowCollisions = s.allowCollisions & ~FlxObject.RIGHT;
			}
			checkPoint.set(Std.int(s.x/8) - 1, Std.int(s.y/8));
			result = collisionLayer.getInt(Std.int(checkPoint.x), Std.int(checkPoint.y));
			if (result > 0) {
				//collision to the left, so clean up this collision edge
				s.allowCollisions = s.allowCollisions & ~FlxObject.LEFT;
			}
			checkPoint.set(Std.int(s.x/8) , Std.int(s.y/8) + 1);
			result = collisionLayer.getInt(Std.int(checkPoint.x), Std.int(checkPoint.y));
			if (result > 0) {
				//collision to the bottom, so clean up this collision edge
				s.allowCollisions = s.allowCollisions & ~FlxObject.DOWN;
			}
			checkPoint.set(Std.int(s.x/8) , Std.int(s.y/8) - 1);
			result = collisionLayer.getInt(Std.int(checkPoint.x), Std.int(checkPoint.y));
			if (result > 0) {
				//collision to the top, so clean up this collision edge
				s.allowCollisions = s.allowCollisions & ~FlxObject.UP;
			}
		});
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
