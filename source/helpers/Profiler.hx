package helpers;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class Profiler {

	public var timeSinceLastCheck:Float = 0;
	public var initialTime:Float = 0;

	public var summaryLables:Array<String> = new Array<String>(); 
	public var summaryTimes:Array<Float> = new Array<Float>();

	public function new() {
		timeSinceLastCheck = Date.now().getTime();	
		initialTime = Date.now().getTime();	
	}

	public function checkpoint(label:String) {
		var now = Date.now().getTime();
		var timeSinceLastCheckpoint = now-timeSinceLastCheck;
		summaryLables.push(label);
		summaryTimes.push(timeSinceLastCheckpoint);
		// trace(label + ": " + timeSinceLastCheckpoint);
		timeSinceLastCheck = now;	
	}

	public function printSummary() {
		for (i in 0...summaryLables.length) {
			trace(summaryLables[i] + ": " + summaryTimes[i]);
		}
		var totalTime = Date.now().getTime()-initialTime;
		trace("Total profiler time: " + totalTime);
	}
}
