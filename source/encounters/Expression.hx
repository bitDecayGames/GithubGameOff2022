package encounters;

enum abstract Expression(String) to String from String {
	var NEUTRAL = "neutral";
	var HAPPY = "happy";
	var MAD = "mad";
	var SAD = "sad";

	public function asIndex() {
		return switch(this) {
			case NEUTRAL:
				0;
			case HAPPY:
				1;
			case MAD:
				2;
			case SAD:
				3;
			default:
				0;
		}
	}
}
