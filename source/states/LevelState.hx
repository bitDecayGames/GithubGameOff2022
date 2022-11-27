package states;

import flixel.math.FlxMath;
import entities.npcs.NPC;
import flixel.FlxG;
import flixel.util.FlxTimer;
import entities.Player;
import flixel.FlxCamera;
import openfl.filters.ShaderFilter;
import shaders.Lighten;
import quest.GlobalQuestState;

class LevelState {

    var camera:FlxCamera;
    var player:Player;
	public var lightenShader:Lighten;
	var lightFilter:ShaderFilter;

    var cluddSnoring:Bool = false;
    var cluddId:String = "CluddSnoring";
    var cludd:NPC;
    var distanceFromCludd:Int;
    var snoreVolumeModifier:Float;

    var levelId:String;

    public function new(_levelId:String){
        camera = PlayState.ME.camera;
        player = PlayState.ME.player;
        levelId = _levelId;
		FlxG.watch.addQuick("Level: ", levelId);
    }

    public static function LoadLevelState(level:LDTKProject_Level):LevelState {
        var levelState = new LevelState(level.identifier);
        levelState.updateReferences();
        levelState.updateShaders();
        levelState.updateSfx();
        levelState.updateSong();
        return levelState;
    }

    public function update(){
        if (lightenShader != null){
            //TODO optimize
            var screenPosition = camera.project(player.getMidpoint().subtract(1,4));
            lightenShader.lightSourceX.value = [screenPosition.x];
            lightenShader.lightSourceY.value = [screenPosition.y];
        }


        if (cludd != null) {
            distanceFromCludd = FlxMath.distanceBetween(player, cludd);
            FlxG.watch.addQuick("Cludd distance: ", distanceFromCludd);
            distanceFromCludd-=24;
            FlxG.watch.addQuick("Cludd distance adjusted: ", distanceFromCludd);
            distanceFromCludd = FlxMath.maxInt(0, distanceFromCludd);
            distanceFromCludd = FlxMath.minInt(distanceFromCludd, 100);
            FlxG.watch.addQuick("Cludd distance bound: ", distanceFromCludd);
            snoreVolumeModifier = cast(1, Float) - (cast(distanceFromCludd, Float)/cast(100, Float));
            FlxG.watch.addQuick("Cludd sound modifer final: ", snoreVolumeModifier);
            FmodManager.SetEventParameterOnSound(cluddId, "SnoreVolume", snoreVolumeModifier);
        }
    }

    public function updateReferences() {

        if (levelId == "House_Cludd_Upstairs") {
            PlayState.ME.interactables.forEach((i) -> {
                if (Std.isOfType(i, entities.npcs.Cludd)) {
                    cludd = cast(i, entities.npcs.Cludd);
                }
            });
        }
    }

    public function updateShaders() {

        if (StringTools.startsWith(levelId, "House_Cludd")) {
            lightenShader = new Lighten();
            lightenShader.iTime.value = [0];
            lightenShader.lightSourceX.value = [0];
            lightenShader.lightSourceY.value = [0];

            lightenShader.fireActive.value = [false];
            lightenShader.lightSourceFireX.value = [-100];
            lightenShader.lightSourceFireY.value = [-100];

            lightenShader.isShaderActive.value = [true];
            lightFilter = new ShaderFilter(lightenShader);
            #if !disable_shader
            camera.setFilters([lightFilter]);
            #end

            var bigRadius = 50;
            var smallRadius = 49;
            lightenShader.lightRadius.value = [50];

            // Make the light flicker
            new FlxTimer().start(0.33, (t) -> {
                if (lightenShader.lightRadius.value[0] == smallRadius){
                    lightenShader.lightRadius.value[0] = bigRadius;
                } else {
                    lightenShader.lightRadius.value[0] = smallRadius;
                }
            }, 0);
        } else {
            camera.setFilters([]);
        }
    }
	private function updateSfx() {
        if (levelId == "House_Cludd_Upstairs") {
            FmodManager.PlaySoundAndAssignId(FmodSFX.CluddSnore, cluddId);
        } else {
            FmodManager.StopSound(cluddId);
        }
    }

	// TODO Transitions when going through doors would be cool to do when link touches the door rather than when the new level is loaded
	private function updateSong() {

        trace("playing song");
		if(!FmodManager.IsSongPlaying()){
			FmodManager.PlaySong(FmodSongs.Silence);
		}

		if (StringTools.startsWith(levelId, "House_Lonk")) {
			if (!GlobalQuestState.WOKEN_FIRST_TIME){
				FmodManager.PlaySongTransition(FmodSongs.AwakenLullaby);
			} else if (!GlobalQuestState.DEFEATED_ALARM_CLOCK && FmodManager.GetCurrentSongPath() != FmodSongs.AwakenLullaby) {
				FmodManager.PlaySongTransition(FmodSFX.AlarmClock);
				FmodManager.SetEventParameterOnSong("AlarmLowPass", 0);
				if (levelId == "House_Lonk_1") {
					FmodManager.SetEventParameterOnSong("AlarmLowPass", 1);
				}
			} else if (GlobalQuestState.leftHouseFirstTime) {
				FmodManager.PlaySong(FmodSongs.AwakenSofterC);
			}
        } else if (StringTools.startsWith(levelId, "House_Cludd")) {
			FmodManager.PlaySong(FmodSongs.Haunted);
		} else {
			FmodManager.PlaySong(FmodSongs.AwakenSofterC);
		}
	}
}