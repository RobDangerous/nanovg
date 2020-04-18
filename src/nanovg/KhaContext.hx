package nanovg;

import haxe.ds.Vector;

class KhaContext {
	public var textures = new Array<KhaTexture>();
	public var view0: Float;
	public var view1: Float;
	public var ntextures: Int;
	public var ctextures: Int;
	public var textureId: Int;

	public var fragSize: Int;
	public var flags: Int;

	public var calls: Vector<KhaCall>;
	public var ccalls: Int;
	public var ncalls: Int;
	public var paths: Vector<KhaPath>;
	public var cpaths: Int;
	public var npaths: Int;
	public var verts: Pointer<NVGvertex>;
	public var cverts: Int;
	public var nverts: Int;
	public var uniforms: Vector<KhaFragUniforms>;
	public var cuniforms: Int;
	public var nuniforms: Int;

	public function new() {
		textures[0] = null;
	}
}
