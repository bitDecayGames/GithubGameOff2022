package states;

import entities.npcs.Lonk;
import states.FinalTransition;
import helpers.Profiler;
import entities.npcs.NPC;
import flixel.tweens.FlxEase;
import entities.interact.Interactable;
import helpers.SaveFileOverrides;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import shaders.MosaicManager;
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

@:access(flixel.FlxCamera)
@:access(ldtk.Layer_Tiles)
class PlayState extends FlxTransitionableState {
	public static var ME:PlayState;

	private static inline var START_LEVEL = "House_Lonk_room_boy";
	var startLevelOverride:String = null;

	private static var firstLoad = true;

	private static var LEVEL_ARRAY = ["House_Lonk_room_boy", "Town_main", "House_Cludd_Main", "House_Cludd_Upstairs", "House_Cludd_Basement"];
	private var levelSelectionCursor = 0;

	public var player:Player;
	public var flavorText:FlxBitmapText;
	public var flavorTextBackdrop:FlxSprite;

	// the sorting layer will hold anything we want sorted by it's positional y-value
	public var sortingLayer:FlxTypedGroup<FlxSprite>;

	public var terrain:FlxSpriteGroup;
	public var terrainMainTown:FlxSpriteGroup;
	public var entities:FlxTypedGroup<FlxSprite>;
	public var doors:FlxTypedGroup<Door>;
	public var npcs:FlxTypedGroup<NPC>;
	public var houses:FlxTypedGroup<House>;
	public var interactables:FlxTypedGroup<FlxSprite>;
	public var collisions:FlxTypedGroup<FlxSprite>;
	public var collisionsMainTown:FlxTypedGroup<FlxSprite>;
	public var uiHelpers:FlxTypedGroup<FlxSprite>;
	public var dialogs:FlxGroup;
	public var level:LDTKProject_Level;

	public var levelState:LevelState;

	public var mosaicShaderManager:MosaicManager;
	public var mosaicFilter:ShaderFilter;

	var project = new LDTKProject();

	var dialogCount = 0;

	public var playerActive:Bool = true;
	public var playerInTransition:Bool = false;

	public var transitionSignal = new FlxTypedSignal<String->Void>();
	public var dialogCamera:FlxCamera;

	// handle events for the current level. Cleared out on level load
	public var eventSignal = new FlxTypedSignal<String->Void>();

	// handle events. Please clean up after yourself as this is never emptied automatically
	public var eventSignalPersistent = new FlxTypedSignal<String->Void>();

	public var triggerFinalFade = false;
	// XXX: Oh god it's horrible
	public var lonk:Lonk = null;

	public function new(startingLevel:String = null) {
		super();
		if (startingLevel != null) {
			startLevelOverride = startingLevel;
		}
	}

	override public function create() {
		super.create();
		ME = this;
		camera.bgColor = FlxColor.BLACK;
		// FlxG.camera.pixelPerfectRender = true;

		mosaicShaderManager = new MosaicManager();
		mosaicFilter = new ShaderFilter(mosaicShaderManager.shader);

		dialogCamera = new FlxCamera();
		dialogCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(dialogCamera, false);

		Lifecycle.startup.dispatch();

		sortingLayer = new FlxTypedGroup<FlxSprite>();
		terrain = new FlxSpriteGroup();
		terrainMainTown = new FlxSpriteGroup();
		collisions = new FlxTypedGroup<FlxSprite>();
		collisionsMainTown = new FlxTypedGroup<FlxSprite>();
		uiHelpers = new FlxTypedGroup<FlxSprite>();
		entities = new FlxTypedGroup<FlxSprite>();
		interactables = new FlxTypedGroup<FlxSprite>();
		doors = new FlxTypedGroup<Door>();
		npcs = new FlxTypedGroup<NPC>();
		houses = new FlxTypedGroup<House>();
		dialogs = new FlxGroup();
		// dialogs go to a second camera so shaders don't mess with them
		dialogs.cameras = [dialogCamera];
		add(terrainMainTown);
		add(terrain);
		add(collisionsMainTown);
		add(collisions);
		// add(entities);
		// add(interactables);
		// add(doors);
		add(sortingLayer);
		add(uiHelpers);
		add(dialogs);

		// We will check for overrides right after the initial load
		loadLevel(startLevelOverride != null ? startLevelOverride : START_LEVEL);

		if (onlyLoadOverridesOnce) {
			// This is how we update the save file on-launch
			SaveFileOverrides.checkForSaveFileOverrides();
			onlyLoadOverridesOnce = false;
		}

		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));


		FlxG.watch.add(player, "speedModifier", "speed modifier");
		FlxG.watch.add(GlobalQuestState, "currentQuest", "quest");
		FlxG.watch.add(GlobalQuestState, "subQuest", "subQuest");
	}

	static var onlyLoadOverridesOnce = true;


	var groundTileCache:Array<FlxSprite> = new Array<FlxSprite>();
	var collisionTileCache:Array<FlxSprite> = new Array<FlxSprite>();

	// loads the level with the given id, optionally spawning the player at the provided doorID
	// Can provide either the uid int, or the iid string, but not both
	public function loadLevel(?uid:Null<Int>, ?id:Null<String>, doorID:String = null) {

		var profiler = new Profiler();

		// clean up current level;
		player = null;
		// Clean up any event listeners between levels;
		eventSignal.removeAll();
		doors.forEach((d) -> {
			d.destroy();
		});
		doors.clear();
		npcs.clear();
		houses.clear();

		terrain.forEach((e) -> {
			if (level != null && level.identifier != "Town_main"){
				e.destroy();
			} else {
				e.kill();
			}
		});
		terrain.clear();
		terrainMainTown.forEach((e) -> {
			e.kill();
		});
		entities.forEach((e) -> {
			e.destroy();
		});
		entities.clear();
		collisions.forEach((c) -> {
			if (level != null && level.identifier != "Town_main"){
				c.destroy();
			} else {
				c.kill();
			}
		});
		collisions.clear();
		collisionsMainTown.forEach((c) -> {
			c.kill();
		});
		interactables.forEach((c) -> {
			c.destroy();
		});
		interactables.clear();
		uiHelpers.forEach((c) -> {
			c.destroy();
		});
		uiHelpers.clear();
		sortingLayer.clear();

		profiler.checkpoint("cleared old level");

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

		profiler.checkpoint("pulled new level from project");

		var collisionLayer = level.l_Collisions;
		// NOTE: We do stuff in screen space, so we need to make sure at least our raw screen coords are within
		// the world bounds
		var boundsWidth = Math.max(FlxG.width, collisionLayer.cWid * collisionLayer.gridSize);
		var boundsHeight = Math.max(FlxG.height, collisionLayer.cHei * collisionLayer.gridSize);
		FlxG.worldBounds.set(0, 0, boundsWidth, boundsHeight);
		trace(FlxG.worldBounds);
		addCollisionsToWorld(collisionLayer);

		profiler.checkpoint("loaded collisions");

		if (level.identifier != "Town_main"){
			level.l_Ground.render(terrain);
		} else {
			cachedRender(terrainMainTown, level.l_Ground, groundTileCache);
		}

		profiler.checkpoint("render terrain");

		for (eHouse in level.l_Entities.all_House) {
			var house = new House(eHouse);
			sortingLayer.add(house);
			houses.add(house);

			for (door in house.getDoors()) {
				doors.add(door);
				sortingLayer.add(door);
			}
		}

		profiler.checkpoint("load houses");

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

		profiler.checkpoint("load doors");

		for (eNPC in level.l_Entities.all_NPC) {
			var npc = NPCFactory.make(eNPC);
			if (npc != null) {
				// we may get null back if the NPC shouldn't spawn based on the current quest

				for (ownee in eNPC.f_Owns) {
					for (door in doors) {
						if (door.iid == ownee.entityIid) {
							door.checks.push(npc);
						}
					}
				}

				interactables.add(npc);
				sortingLayer.add(npc);
				npcs.add(npc);
			}
		}

		profiler.checkpoint("load NPCs");

		// the BottomDecor layer is treated as terrain so that it renders underneath all entities
		level.l_BottomDecor.render(terrain);

		profiler.checkpoint("load decor");

		// The other decor layers are injected directly into our sorting group so they behave like world objects
		var group = level.l_Decor.render();
		level.l_TopDecor.render(group);
		for (decorSprite in group.members) {
			sortingLayer.add(decorSprite);
		}

		profiler.checkpoint("load more decor");

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

		profiler.checkpoint("load interactables");

		if (level.l_Entities.all_PlayerSpawn.length > 1) {
			throw('level ${level.identifier} has multiple spawns');
		}

		profiler.checkpoint("Update NPC ownership");

		var playerStart = FlxVector.get();
		if (FlxStringUtil.isNullOrEmpty(doorID)) {
			var spawnData = level.l_Entities.all_PlayerSpawn[0];
			if (spawnData != null){
				player = new Player(spawnData.pixelX, spawnData.pixelY, true);
				switch(spawnData.f_Direction) {
					case UP:
						player.facing = FlxObject.UP;
					case DOWN:
						player.facing = FlxObject.DOWN;
					case LEFT:
						player.facing = FlxObject.LEFT;
					case RIGHT:
						player.facing = FlxObject.RIGHT;
				}
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

			if (startDoor.data.f_Keys.contains(Enum_Keys.Cludd_frontdoor)) {
				// once they come OUT of cludd's house, it is unlocked
				GlobalQuestState.HAS_USED_CLUDDS_DOOR = true;
			}

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

			if (startDoor.isStairs){
				//This mutes one step after stairs to make it sound better
				player.muteNextStep = true;
			}

			// move the character slightly further than the edge of the door hitbox
			new FlxTimer().start(walkDistance / player.speed, (t) -> {
				player.worldClip = null;
				player.persistentDirectionInfluence.set();
				startDoor.animation.play('close');
				if (!startDoor.isStairs && !startDoor.data.f_Cave){
					FmodManager.PlaySoundOneShot(FmodSFX.DoorClose);
				}
				startDoor.animation.finishCallback = (n) -> {
					if (n == "close"){
						startDoor.animation.play('closed');
						playerInTransition = false;
						player.lockControls = false;
						player.allowCollisions = FlxObject.ANY;
						if (level.identifier == "Town_main" && GlobalQuestState.HAS_COMPASS && !GlobalQuestState.LONK_HOUSE_COLLAPSED){
							player.lockControls = true;
							GlobalQuestState.LONK_HOUSE_COLLAPSED = true;
							FmodManager.StopSong();
							new FlxTimer().start(2, (t) -> {
								new FlxTimer().start(0.4, (t) -> {
									FlxG.camera.shake(0.0025, 2.4);
								});
								new FlxTimer().start(1.9, (t) -> {
									FlxG.camera.shake(0.01, 0.5);
									player.animation.play(Player.STARTLED);
									FlxTween.tween(player, {y: player.y - 7.5}, 0.25, {
										onComplete: (t) -> {
											FlxTween.tween(player, {y: player.y + 7.5}, 1);
										},
									});
									new FlxTimer().start(1.5, (t) -> {
										player.animation.play('${Characters.IDLE_ANIM}_${Characters.DOWN}');
									});
								});
								FmodManager.PlaySoundOneShot(FmodSFX.LonkHouseCollapse);
								new FlxTimer().start(6, (t) -> {
									var dialogBox = new CharacterDialog(NONE, "");
									openDialog(dialogBox);
									dialogBox.textGroup.finishCallback = () -> {
										closeDialog(dialogBox);
										dialogBox.resetLastLine();
										player.lockControls = false;
										FmodManager.PlaySong(FmodSongs.AwakenDanger);
										GlobalQuestState.subQuest++;
									};
									dialogBox.loadDialogLine("That came from home....");
								});
							});
						}
					}
				}
			});
		}
		entities.add(player);
		sortingLayer.add(player);

		for (npc in npcs) {
			npc.UpdateOwnership();
		}

		profiler.checkpoint("setup player movement out of the last door");

		if (firstLoad) {
			firstLoad = false;
			camera.scroll.y = -FlxG.height;
			camera.scroll.x = -(FlxG.width - level.pxWid) / 2;
			var destScrollY = -(FlxG.height - level.pxHei) / 2;
			FlxTween.tween(camera.scroll, {y: destScrollY}, 2, {
				ease: FlxEase.quadOut,
				onComplete: (t) -> {setCameraFollow();}
			});
		} else {
			setCameraFollow();
		}

		profiler.checkpoint("set camera");

		// TODO: give this thing a nice little background thing
		flavorText = new FlxBitmapText();
		flavorText.setPosition(5, 5);
		flavorText.scrollFactor.set();
		flavorText.cameras = [dialogCamera];

		flavorTextBackdrop = new FlxSprite();
		flavorTextBackdrop.visible = false;
		flavorTextBackdrop.scrollFactor.set();

		profiler.checkpoint("Setup flavor text for quests");

		uiHelpers.add(flavorTextBackdrop);
		uiHelpers.add(flavorText);

		levelState = LevelState.LoadLevelState(level);

		profiler.checkpoint("Load level state");
		// profiler.printSummary();
	}

	private function setCameraFollow() {
		camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT);

		var boundCamera = true;

		if (level.pxWid <= camera.width) {
			boundCamera = false;
			camera.deadzone.x = 1;
			camera.deadzone.width = FlxG.width - 2;
			camera.scroll.x = -(FlxG.width - level.pxWid) / 2;
		}

		if (level.pxHei <= camera.height) {
			boundCamera = false;
			camera.deadzone.y = 1;
			camera.deadzone.height = FlxG.height - 2;
			camera.scroll.y = -(FlxG.height - level.pxHei) / 2;
		}

		trace(level.pxWid);
		trace(level.pxHei);

		if (boundCamera) {
			camera.setScrollBoundsRect(0, 0, level.pxWid, level.pxHei);
		} else {
			camera.setScrollBounds(null, null, null, null);
		}

		// do this so our scroll start point is respected (it gets overriden otherwise and the camera is in the wrong)
		camera._scrollTarget.set(camera.scroll.x, camera.scroll.y);
	}

	override public function update(elapsed:Float) {
		flavorText.text = GlobalQuestState.currentQuest.GetFlavorText();
		// Todo this might be causing performance issues
		if (flavorText.text != " "){
			flavorTextBackdrop.makeGraphic(flavorText.frameWidth+8, flavorText.frameHeight+7, FlxColor.BLACK);
			flavorTextBackdrop.visible = true;
		} else {
			flavorTextBackdrop.visible = false;
		}
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
		var alarmShouldBlare = !GlobalQuestState.DEFEATED_ALARM_CLOCK;
		if (GlobalQuestState.currentQuest == Enum_QuestName.Final_morning && !GlobalQuestState.FINAL_MORNING_TURNED_OFF_ALARM) {
			alarmShouldBlare = true;
		}
		if (alarmShouldBlare && FmodManager.GetCurrentSongPath() == FmodSFX.AlarmClock) {
			FmodManager.SetEventParameterOnSong("AlarmLowPass", 0);
			if (level.identifier == "House_Lonk_1" || level.identifier == "House_Lonk_room_lonk" || level.identifier == "House_Lonk_upstairs") {
				FmodManager.SetEventParameterOnSong("AlarmLowPass", 1);
			}
		}

		if (!GlobalQuestState.WOKEN_FIRST_TIME){
			GlobalQuestState.WOKEN_FIRST_TIME = true;
			if (!GlobalQuestState.SPEEDY_DEBUG) {
				player.lockControls = true;
				player.animation.play(Player.SLEEP);
				new FlxTimer().start(6.2, (t) -> {
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

		FlxG.collide(doors, player, playerTouchDoor);
		FlxG.collide(collisions, player);
		FlxG.collide(collisionsMainTown, player);
		FlxG.collide(interactables, player);

		sortTheSortingLayer();
	}

	function sortTheSortingLayer() {
		// sort objects by their reference Y (typically bottom edge)
		sortingLayer.sort((Order:Int, Obj1:FlxObject, Obj2:FlxObject) -> {
			var o1RefY = Obj1.y + Obj1.height;
			var o2RefY = Obj2.y + Obj2.height;

			if (Obj1 is Door) {
				switch (cast(Obj1, Door).accessDir) {
					case E | W | N:
						o1RefY = Obj1.y - 2;
					default:
				}
			} else if (Obj2 is Door) {
				switch (cast(Obj2, Door).accessDir) {
					case E | W | N:
						o2RefY = Obj2.y - 2;
					default:
				}
			}

			return FlxSort.byValues(Order, o1RefY, o2RefY);
		});
	}

	public function playerTouchDoor(d:Door, p:Player) {
		if (!playerActive) {
			return;
		}

		var diff = d.getMidpoint().subtractPoint(p.getMidpoint());
		if (d.accessDir.vertical() && Math.abs(diff.x) > 1) {
			p.oneFrameDirectionInfluence.set(diff.x, 0);
		} else if (d.accessDir.horizontal() && Math.abs(diff.y) > 1) {
			p.oneFrameDirectionInfluence.set(0, diff.y);
		} else {
			if (!d.shouldPass()) {
				// one of our checks failed and is preventing us from using this door
				d.interact();
				return;
			}

			// make the player face the door
			p.setIdleAnimation(d.accessDir.opposite());
			if (d.data.f_Cave){
				// nothing to do here, caves have no doors
			} else if (d.isStairs) {
				p.speedModifier = 0.3;
				new FlxTimer().start(0.85, (t) -> {
					if (d.isDownStairs){
						FmodManager.PlaySoundOneShot(FmodSFX.StairsDown);
					} else {
						FmodManager.PlaySoundOneShot(FmodSFX.StairsUp);
					}
				});
			} else {
				FmodManager.PlaySoundOneShot(FmodSFX.DoorOpen);
			}
			transitionSignal.dispatch(d.destinationLevel);
			playerInTransition = true;
			d.animation.play('open');
			d.animation.finishCallback = (name) -> {
				if (name == "close" || name == "open"){
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
					new FlxTimer().start(walkDistance / (p.speed * p.speedModifier), (t) -> {
						if (triggerFinalFade) {
							new FlxTimer().start(2, (t) -> {
								openSubState(new FinalTransition(lonk));
							});
							player.kill();
						} else {
							p.persistentDirectionInfluence.set();
							p.speedModifier = 1;
							p.hasTakenStepOnStairs1 = false;
							p.hasTakenStepOnStairs2 = false;
							d.enter();
							p.allowCollisions = FlxObject.ANY;
							playerInTransition = false;
							p.worldClip = null;
						}
					});
				}
			};
		}
	}

	public function startEncounter(encounterSubState:FlxSubState) {
		openSubState(encounterSubState);
	}

	override public function closeSubState():Void {
		super.closeSubState();
		levelState = LevelState.LoadLevelState(level);
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
		if (level.identifier != "Town_main"){
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
		} else {
			cachedCollisionRender(collisionLayer, collisionTileCache);
		}
	}

	function cachedRender(spriteGroup:FlxSpriteGroup, ground:Layer_Ground, cache:Array<FlxSprite>) {

		if( spriteGroup==null ) {
			spriteGroup = new FlxSpriteGroup();
			spriteGroup.active = false;
		}

		var firstPass = false;
		if (cache.length == 0){
			firstPass = true;
		}

		trace("first pass rendering ground layer: " + firstPass);

		var cursorIndex = 0;
		if (firstPass) {
		for( cy in 0...ground.cHei )
		for( cx in 0...ground.cWid )
			if( ground.hasAnyTileAt(cx,cy) )
				for( tile in ground.getTileStackAt(cx,cy) ) {
					var s:flixel.FlxSprite;
						s = new flixel.FlxSprite(cx*ground.gridSize + ground.pxTotalOffsetX, cy*ground.gridSize + ground.pxTotalOffsetY);
						s.flipX = tile.flipBits & 1 != 0;
						s.flipY = tile.flipBits & 2 != 0;
						s.frame = ground.untypedTileset.getFrame(tile.tileId);
						s.width = ground.gridSize;
						s.height = ground.gridSize;
						cache.insert(cursorIndex, s);
						cursorIndex++;
						spriteGroup.add(s);
					}
		} else {
			for (sprite in cache) {
				sprite.revive();
			}
		}
	}

	function cachedCollisionRender(collisionLayer:Layer_Collisions, cache:Array<FlxSprite>) {

		var firstPass = false;
		if (cache.length == 0){
			firstPass = true;
		}

		trace("first pass rendering collisions layer: " + firstPass);

		var cursorIndex = 0;


		if (firstPass) {
			for( autoTile in collisionLayer.autoTiles ) {
				var s:flixel.FlxSprite;
				s = new flixel.FlxSprite(autoTile.renderX, autoTile.renderY);
				s.flipX = autoTile.flips & 1 != 0;
				s.flipY = autoTile.flips & 2 != 0;
				s.frame = collisionLayer.untypedTileset.getFrame(autoTile.tileId);
				var checkPoint = FlxPoint.get();
				var result = 0;
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

				cache.insert(cursorIndex, s);
				cursorIndex++;
				collisionsMainTown.add(s);
			}
		} else {
			for (sprite in cache) {
				sprite.revive();
			}
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
