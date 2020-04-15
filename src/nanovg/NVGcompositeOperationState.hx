package nanovg;

class NVGcompositeOperationState {
	public var srcRGB: Int;
	public var dstRGB: Int;
	public var srcAlpha: Int;
	public var dstAlpha: Int;

	public function new() {
		srcRGB = 0;
		dstRGB = 0;
		srcAlpha = 0;
		dstAlpha = 0;
	}

	public function copyTo(state: NVGcompositeOperationState): Void {
		state.srcRGB = srcRGB;
		state.dstRGB = dstRGB;
		state.srcAlpha = srcAlpha;
		state.dstAlpha = dstAlpha;
	}
}
