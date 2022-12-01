package helpers;

import com.bitdecay.metrics.Tag;
import com.bitdecay.analytics.Bitlytics;

class Analytics {
	private static var METRIC_QUEST = "quest_num";

	private static var METRIC_VICTORY = "victory";

	private static var METRIC_ACHIEVEMENT = "achievement";

	private static var TAG_ACHIEVEMENT_NAME = "name_key";

	public static function reportAchievement(key:String) {
		Bitlytics.Instance().Queue(METRIC_ACHIEVEMENT, 1, [new Tag(TAG_ACHIEVEMENT_NAME, key)]);
	}

	public static function reportWin() {
		Bitlytics.Instance().Queue(METRIC_VICTORY, 1);
	}

	public static function reportQuestCheckpoint(mainQuest:Int, subQuest:Int) {
		// metrics are reported as numbers, i.e. quest 1 subquest 3 is reported as `1.3`
		Bitlytics.Instance().Queue(METRIC_QUEST, mainQuest + (subQuest / 10.0));

	}
}
