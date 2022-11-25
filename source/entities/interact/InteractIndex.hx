package entities.interact;

enum abstract InteractIndex(Int) to Int from Int {
	var LOAD_TILE = 0;
	var ALARM_CLOCK = 1;
	var POT_RUBBER = 2;
	var POT_NORMAL = 3;
	var CHEST = 4;
	var GATE = 5;
	var MAP = 6;
	var TREE = 7;
}