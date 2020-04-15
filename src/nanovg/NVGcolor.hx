package nanovg;

class NVGcolor {
	public var r: Float;
	public var g: Float;
	public var b: Float;
	public var a: Float;

	public function new() {
		r = g = b = a = 0;
	}

	public function copyTo(color: NVGcolor): Void {
		color.r = r;
		color.g = g;
		color.b = b;
		color.a = a;
	}
}
