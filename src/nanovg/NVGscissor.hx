package nanovg;

import haxe.ds.Vector;

class NVGscissor {
	public var xform: Vector<Float>;
	public var extent: Vector<Float>;

	public function new() {
		xform = new Vector<Float>(6);
		extent = new Vector<Float>(2);
	}

	public function copyTo(scissor: NVGscissor): Void {
		for (i in 0...xform.length) {
			scissor.xform[i] = xform[i];
		}
		for (i in 0...extent.length) {
			scissor.extent[i] = extent[i];
		}
	}
}
