package nanovg;

class KhaPath {
	public var fillOffset: Int;
	public var fillCount: Int;
	public var strokeOffset: Int;
	public var strokeCount: Int;

	public function new() {}

	public function nullify() {
		fillOffset = 0;
		fillCount = 0;
		strokeOffset = 0;
		strokeCount = 0;
	}
}
