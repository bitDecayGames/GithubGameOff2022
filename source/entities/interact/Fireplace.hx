package entities.interact;

import states.PlayState;

class Fireplace extends Interactable {
	public function new(data:Entity_Interactable) {
		super(data.pixelX, data.pixelY, NONE);
		loadGraphic(AssetPaths.fire__png, true, 16, 16);
		animation.add('burn', [for (i in 1...8) i], 5);
		animation.play('burn');
	}

	override function update(elapsed:Float) {
		super.update(elapsed);


		if (PlayState.ME.levelState.lightenShader != null){
			PlayState.ME.levelState.lightenShader.fireActive.value = [true];
            //TODO optimize
            var screenPosition = camera.project(getMidpoint());
            PlayState.ME.levelState.lightenShader.lightSourceFireX.value = [screenPosition.x];
            PlayState.ME.levelState.lightenShader.lightSourceFireY.value = [screenPosition.y];
        }
	}
}