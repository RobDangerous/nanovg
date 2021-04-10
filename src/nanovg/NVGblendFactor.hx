package nanovg;

enum abstract NVGblendFactor(Int) from Int to Int {
	var NVG_ZERO = 1 << 0;
	var NVG_ONE = 1 << 1;
	var NVG_SRC_COLOR = 1 << 2;
	var NVG_ONE_MINUS_SRC_COLOR = 1 << 3;
	var NVG_DST_COLOR = 1 << 4;
	var NVG_ONE_MINUS_DST_COLOR = 1 << 5;
	var NVG_SRC_ALPHA = 1 << 6;
	var NVG_ONE_MINUS_SRC_ALPHA = 1 << 7;
	var NVG_DST_ALPHA = 1 << 8;
	var NVG_ONE_MINUS_DST_ALPHA = 1 << 9;
	var NVG_SRC_ALPHA_SATURATE = 1 << 10;
}
