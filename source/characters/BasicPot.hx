package characters;

import com.bitdecay.lucidtext.parse.TagLocation;
import encounters.CharacterDialog;

class BasicPot extends CharacterDialog {
	public function new() {
		super(POT, "It is a pot");

		// hook up any special handling we want for tags
		textGroup.tagCallback = (tag:TagLocation) -> {
			if (tag.tag == "cb") {
				if (tag.parsedOptions.val == "camred") {
					portrait.animation.frameIndex = 1;
				} else if (tag.parsedOptions.val == "camgrey") {
					portrait.animation.frameIndex = 0;
				}
			}
		};
	}
}