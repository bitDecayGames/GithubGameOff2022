package entities.particles;

// These align with the order of things in the items.png image
enum abstract ItemIndex(Int) to Int from Int {
	var COMPASS = 0;
	var BOMB = 1;
	var KEY = 2;
	var CANDLE = 3;
	var MAP = 4;
	var GAMEBOY = 5;
	var DONUT = 6;
	var COUGH_DROP = 7;
}