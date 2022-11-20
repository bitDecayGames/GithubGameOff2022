package encounters;

enum abstract CharacterIndex(Int) to Int from Int {
	var NONE = -1;
	var WOMAN = 0;
	var POT = 1;
	var LONK = 2;
	var CRAFTSMAN = 3;
	var ALARM_CLOCK = 4;
	var RUBBERPOT = 5;
	var CLUDD = 6;

	public function getAssetPackage():String {
		switch(this) {
			case WOMAN:
				return AssetPaths.lady__png;
			case RUBBERPOT:
				// TODO: Obviously this is wrong
				return AssetPaths.player__png;
			case POT:
				// TODO: Obviously this is wrong
				return AssetPaths.player__png;
			case LONK:
				return AssetPaths.oldMan__png;
			case CLUDD:
				return AssetPaths.oldMan__png;
			default:
				// TODO: Obviously this is wrong
				return AssetPaths.player__png;
		}
	}
}