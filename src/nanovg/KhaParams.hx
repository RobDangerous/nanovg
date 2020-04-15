package nanovg;

import haxe.ds.Vector;

class KhaParams extends NVGparams {
	override public function renderCreate(uptr: Dynamic): Int {
		var kha: KhaContext = uptr;
		var align: Int = 4;
		return 1;
	}
	override public function renderCreateTexture(uptr: Dynamic, type: Int, w: Int, h: Int, imageFlags: Int, data: Array<Int>): Int { return 0; }
	override public function renderDeleteTexture(uptr: Dynamic, image: Int): Int { return 0; }
	override public function renderUpdateTexture(uptr: Dynamic, image: Int, x: Int, y: Int, w: Int, h: Int, data: Array<Int>): Int { return 0; }
	override public function renderGetTextureSize(uptr: Dynamic, image: Int, w: Ref<Int>, h: Ref<Int>): Int { return 0; }
	override public function renderViewport(uptr: Dynamic, width: Float, height: Float, devicePixelRatio: Float): Void {}
	override public function renderCancel(uptr: Dynamic): Void {}
	override public function renderFlush(uptr: Dynamic): Void {}
	override public function renderFill(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, fringe: Float, bounds: Vector<Float>, paths: Vector<NVGpath>, npaths: Int): Void {}
	override public function renderStroke(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, fringe: Float, strokeWidth: Float, paths: Vector<NVGpath>, npaths: Int): Void {}
	override public function renderTriangles(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, verts: Pointer<NVGvertex>, nverts: Int, fringe: Float): Void {}
	override public function renderDelete(uptr: Dynamic): Void {}

	public function new() {
		super();
	}
}
