package states;

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
	var player:FlxSprite;

	var collisions:FlxTypedGroup<FlxSprite>;

	override public function create() {
		super.create();
		camera.bgColor = FlxColor.PINK;

		var test = new LDTKProject();

		var level = test.getLevel(0);
		trace(level.l_Entities.all_PlayerSpawn[0].f_ThisIsForJake);
		trace(level.bgImageInfos);
		// var terrainGroup = level.l_Terrain.render();
		// add(terrainGroup);

		var collisionLayer = level.l_Collisions;
		FlxG.worldBounds.set(0, 0, collisionLayer.cWid * collisionLayer.gridSize, collisionLayer.cHei * collisionLayer.gridSize );
		trace(FlxG.worldBounds);
		collisions = new FlxTypedGroup<FlxSprite>();
		collisionLayer.render().forEach((s) -> {
			s.immovable = true;
			s.updateHitbox();
			collisions.add(s);
		});

		trace(collisions.members.length);
		add(collisions);

		Lifecycle.startup.dispatch();

		FlxG.camera.pixelPerfectRender = true;

		if (level.l_Entities.all_PlayerSpawn.length > 1) {
			throw ('level ${level.identifier} has multiple spawns');
		}

		var spawnData = level.l_Entities.all_PlayerSpawn[0];
		player = new Player();
		player.setPosition(spawnData.cx * 16, spawnData.cy * 16);
		add(player);
		camera.follow(player);



		add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var cam = FlxG.camera;
		DebugDraw.ME.drawCameraRect(cam.width/2 - 5, cam.height/2 - 5, 10, 10);

		FlxG.collide(collisions, player);
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
