package nanovg;

class NVGpath {
	public var first: Int;
	public var count: Int;
	public var closed: Int;
	public var nbevel: Int;
	public var fill: Pointer<NVGvertex>;
	public var nfill: Int;
	public var stroke: Pointer<NVGvertex>;
	public var nstroke: Int;
	public var winding: Int;
	public var convex: Bool;

	public function new() {}

	public function nullify(): Void {
		first = 0;
		count = 0;
		closed = 0;
		nbevel = 0;
		fill = null;
		nfill = 0;
		stroke = null;
		nstroke = 0;
		winding = 0;
		convex = false;
	}
}
