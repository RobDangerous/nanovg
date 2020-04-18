package nanovg;

import haxe.ds.Vector;

class KhaFragUniforms {
	public var scissorMat: Vector<Float>; // matrices are actually 3 vec4s
	public var paintMat: Vector<Float>;
	public var innerCol: NVGcolor;
	public var outerCol: NVGcolor;
	public var scissorExt: Vector<Float>;
	public var scissorScale: Vector<Float>;
	public var extent: Vector<Float>;
	public var radius: Float;
	public var feather: Float;
	public var strokeMult: Float;
	public var strokeThr: Float;
	public var texType: Int;
	public var type: Int;

	public function new() {
		scissorMat = new Vector<Float>(12);
		paintMat = new Vector<Float>(12);
		innerCol = new NVGcolor();
		outerCol = new NVGcolor();
		scissorExt = new Vector<Float>(2);
		scissorScale = new Vector<Float>(2);
		extent = new Vector<Float>(2);
	}

	public function nullify(): Void {
		scissorMat = new Vector<Float>(12);
		paintMat = new Vector<Float>(12);
		innerCol = new NVGcolor();
		outerCol = new NVGcolor();
		scissorExt = new Vector<Float>(2);
		scissorScale = new Vector<Float>(2);
		extent = new Vector<Float>(2);
		radius = 0;
		feather = 0;
		strokeMult = 0;
		strokeThr = 0;
		texType = 0;
		type = 0;
	}
}
