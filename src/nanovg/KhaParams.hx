package nanovg;

import haxe.ds.Vector;
import kha.Image;

class KhaParams extends NVGparams {
	override public function renderCreate(uptr: Dynamic): Int {
		var kha: KhaContext = uptr;
		var align: Int = 4;
		return 1;
	}

	override public function renderCreateTexture(uptr: Dynamic, type: Int, w: Int, h: Int, imageFlags: Int, data: Array<Int>): Int {
		var context: KhaContext = uptr;
		var tex = Image.create(w, h);

		if (tex == null) return 0;

		var pixels = tex.lock();
		for (x in 0...w) {
			for (y in 0...h) {
				pixels.set(y * h * w * 4 + x * 4, data[y * h * w + x]);
			}
		}
		tex.unlock();

		context.textures.push(tex);
		return context.textures.length - 1;
	}

	override public function renderDeleteTexture(uptr: Dynamic, image: Int): Int {
		var context: KhaContext = uptr;

		var tex = context.textures[image];
		if (tex != null) {
			tex.unload();
			context.textures[image] = null;
			return 1;
		}

		return 0;
	}

	override public function renderUpdateTexture(uptr: Dynamic, image: Int, x: Int, y: Int, w: Int, h: Int, data: Array<Int>): Int {
		var context: KhaContext = uptr;

		var tex = context.textures[image];
		if (context.textures[image] != null) {
			var pixels = tex.lock();
			for (x in 0...w) {
				for (y in 0...h) {
					pixels.set(y * h * w * 4 + x * 4, data[y * h * w + x]);
				}
			}
			tex.unlock();
			return 1;
		}

		return 0;
	}

	override public function renderGetTextureSize(uptr: Dynamic, image: Int, w: Ref<Int>, h: Ref<Int>): Int {
		var context: KhaContext = uptr;

		var tex = context.textures[image];
		if (context.textures[image] != null) {
			w.value = tex.width;
			h.value = tex.height;
			return 1;
		}

		return 0;
	}
	
	override public function renderViewport(uptr: Dynamic, width: Float, height: Float, devicePixelRatio: Float): Void {
		var context: KhaContext = uptr;
		context.view0 = width;
		context.view1 = width;
	}

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
