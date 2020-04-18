package nanovg;

class KhaCall {
	public var type: Int;
	public var image: Int;
	public var pathOffset: Int;
	public var pathCount: Int;
	public var triangleOffset: Int;
	public var triangleCount: Int;
	public var uniformOffset: Int;
	public var blendFunc: KhaBlend;

	public function new() {
		blendFunc = new KhaBlend();
	}

	public function nullify(): Void {
		type = 0;
		image = 0;
		pathOffset = 0;
		pathCount = 0;
		triangleOffset = 0;
		pathCount = 0;
		triangleOffset = 0;
		triangleCount = 0;
		uniformOffset = 0;
		blendFunc.nullify();
	}
}
