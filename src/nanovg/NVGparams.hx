package nanovg;

import haxe.ds.Vector;

class NVGparams {
	public var userPtr: Dynamic;
	public var edgeAntiAlias: Int;
	public function renderCreate(uptr: Dynamic): Int { return 0; }
	public function renderCreateTexture(uptr: Dynamic, type: Int, w: Int, h: Int, imageFlags: Int, data: Array<Int>): Int { return 0; }
	public function renderDeleteTexture(uptr: Dynamic, image: Int): Int { return 0; }
	public function renderUpdateTexture(uptr: Dynamic, image: Int, x: Int, y: Int, w: Int, h: Int, data: Array<Int>): Int { return 0; }
	public function renderGetTextureSize(uptr: Dynamic, image: Int, w: Ref<Int>, h: Ref<Int>): Int { return 0; }
	public function renderViewport(uptr: Dynamic, width: Float, height: Float, devicePixelRatio: Float): Void {}
	public function renderCancel(uptr: Dynamic): Void {}
	public function renderFlush(uptr: Dynamic): Void {}
	public function renderFill(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, fringe: Float, bounds: Vector<Float>, paths: Vector<NVGpath>, npaths: Int): Void {}
	public function renderStroke(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, fringe: Float, strokeWidth: Float, paths: Vector<NVGpath>, npaths: Int): Void {}
	public function renderTriangles(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, verts: Pointer<NVGvertex>, nverts: Int, fringe: Float): Void {}
	public function renderDelete(uptr: Dynamic): Void {}

	public function new() {}
}
