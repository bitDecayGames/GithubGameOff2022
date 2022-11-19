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
	var lightenShader:Lighten;
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
            // FlxG.watch.addQuick("Cludd distance: ", distanceFromCludd);
            distanceFromCludd-=16;
            // FlxG.watch.addQuick("Cludd distance adjusted: ", distanceFromCludd);
            distanceFromCludd = FlxMath.maxInt(0, distanceFromCludd);
            distanceFromCludd = FlxMath.minInt(distanceFromCludd, 100);
            // FlxG.watch.addQuick("Cludd distance bound: ", distanceFromCludd);
            snoreVolumeModifier = cast(1, Float) - (cast(distanceFromCludd, Float)/cast(100, Float));
            // FlxG.watch.addQuick("Cludd sound modifer final: ", snoreVolumeModifier);
            FmodManager.SetEventParameterOnSound(cluddId, "SnoreVolume", snoreVolumeModifier);
        }
    }

    public function updateReferences() {
        
        if (levelId == "House_compass_1") {
            PlayState.ME.interactables.forEach((i) -> {
                if (Std.isOfType(i, entities.npcs.Lonk)) {
                    cludd = cast(i, entities.npcs.Lonk);
                }
            });
        }
    }

    public function updateShaders() {

        if (StringTools.startsWith(levelId, "House_compass")) {
            lightenShader = new Lighten();
            lightenShader.iTime.value = [0];
            lightenShader.lightSourceX.value = [0];
            lightenShader.lightSourceY.value = [0];
            lightenShader.isShaderActive.value = [true];
            lightFilter = new ShaderFilter(lightenShader);
            camera.setFilters([lightFilter]);
            
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
        if (levelId == "House_compass_1") {
            FmodManager.PlaySoundAndAssignId(FmodSFX.CluddSnore, cluddId);
        } else {
            FmodManager.StopSound(cluddId);
        }
    }

	// TODO Transitions when going through doors would be cool to do when link touches the door rather than when the new level is loaded
	private function updateSong() {
		if(!FmodManager.IsSongPlaying()){
			FmodManager.PlaySong(FmodSongs.Silence);
		}

		if (StringTools.startsWith(levelId, "House_Lonk")) {
			if (!GlobalQuestState.WOKEN_FIRST_TIME){
				FmodManager.PlaySongTransition(FmodSongs.AwakenLullaby);
			} else if (!GlobalQuestState.DEFEATED_ALARM_CLOCK) {
				FmodManager.PlaySongTransition(FmodSFX.AlarmClock);
				FmodManager.SetEventParameterOnSong("AlarmLowPass", 0);
				if (levelId == "House_Lonk_1") {
					FmodManager.SetEventParameterOnSong("AlarmLowPass", 1);
				}
			} else if (GlobalQuestState.leftHouseFirstTime) {
				FmodManager.PlaySong(FmodSongs.Awaken);
			}
        } else if (StringTools.startsWith(levelId, "House_compass")) {
			FmodManager.PlaySong(FmodSongs.Haunted);
		} else {
			FmodManager.PlaySong(FmodSongs.Awaken);
		}
	}
}