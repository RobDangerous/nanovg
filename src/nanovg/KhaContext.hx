package nanovg;

import kha.Image;

class KhaContext {
	public var flags: Int;
	public var textures = new Array<Image>();
	public var view0: Float;
	public var view1: Float;

	public function new() {
		textures[0] = null;
	}
}
