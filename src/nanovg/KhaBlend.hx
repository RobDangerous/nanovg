package nanovg;

import kha.graphics4.BlendingFactor;

class KhaBlend {
	public var srcRGB: BlendingFactor;
	public var dstRGB: BlendingFactor;
	public var srcAlpha: BlendingFactor;
	public var dstAlpha: BlendingFactor;

	public function new() {}

	public function nullify(): Void {
		srcRGB = BlendZero;
		dstRGB = BlendZero;
		srcAlpha = BlendZero;
		dstAlpha = BlendZero;
	}
}
