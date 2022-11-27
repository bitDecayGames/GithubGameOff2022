package entities.interact;

import states.LevelState;
import states.PlayState;

class Fireplace extends Interactable {
	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE, data.f_Description);
		loadGraphic(AssetPaths.fire__png, true, 16, 16);
		animation.add('burn', [for (i in 1...7) i], 5);
		animation.play('burn');
	}

	override function update(elapsed:Float) {
		super.update(elapsed);


		if (PlayState.ME.levelState.lightenShader != null){
			PlayState.ME.levelState.lightenShader.fireActive.value = [true];
            //TODO optimize

			if (LevelState.skipRadiusFrames == 0) {
				// XXX: only set this position if we are outside of the skip frames
				var screenPosition = camera.project(getMidpoint());
				PlayState.ME.levelState.lightenShader.lightSourceFireX.value = [screenPosition.x];
				PlayState.ME.levelState.lightenShader.lightSourceFireY.value = [screenPosition.y];
			}

			switch animation.frameIndex {
				case 1:
					PlayState.ME.levelState.lightenShader.lightFireRadius.value = [49];
				case 2:
					PlayState.ME.levelState.lightenShader.lightFireRadius.value = [48];
				case 3:
					PlayState.ME.levelState.lightenShader.lightFireRadius.value = [50];
				case 4:
					PlayState.ME.levelState.lightenShader.lightFireRadius.value = [50];
				case 5:
					PlayState.ME.levelState.lightenShader.lightFireRadius.value = [51];
				case 6:
					PlayState.ME.levelState.lightenShader.lightFireRadius.value = [52];
			}
        }
	}
}