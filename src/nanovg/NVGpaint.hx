package nanovg;

import haxe.ds.Vector;

class NVGpaint {
	public var xform: Vector<Float>;
	public var extent: Vector<Float>;
	public var radius: Float;
	public var feather: Float;
	public var innerColor: NVGcolor;
	public var outerColor: NVGcolor;
	public var image: Int;

	public function new() {
		xform = new Vector<Float>(6);
		extent = new Vector<Float>(2);
		innerColor = new NVGcolor();
		outerColor = new NVGcolor();
	}

	public function nullify(): Void {
		for (i in 0...xform.length) {
			xform[i] = 0.0;
		}
		for (i in 0...extent.length) {
			extent[i] = 0.0;
		}
		radius = 0.0;
		feather = 0.0;
		innerColor.r = innerColor.g = innerColor.b = innerColor.a = 0;
		outerColor.r = outerColor.g = outerColor.b = outerColor.a = 0;
		image = 0;
	}

	public function copyTo(paint: NVGpaint): Void {
		for (i in 0...xform.length) {
			paint.xform[i] = xform[i];
		}
		for (i in 0...extent.length) {
			paint.extent[i] = extent[i];
		}
		paint.radius = radius;
		paint.feather = feather;
		innerColor.copyTo(paint.innerColor);
		outerColor.copyTo(paint.outerColor);
		paint.image = image;
	}
}
