package nanovg;

class NVGvertex {
	public var x: Float;
	public var y: Float;
	public var u: Float;
	public var v: Float;

	public function new() {
		x = 0;
		y = 0;
		u = 0;
		v = 0;
	}

	public function copyTo(vert: NVGvertex): Void {
		vert.x = x;
		vert.y = y;
		vert.u = u;
		vert.v = v;
	}
}
