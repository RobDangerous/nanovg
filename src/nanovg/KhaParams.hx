package nanovg;

import haxe.ds.Vector;
import kha.Image;
import kha.graphics4.BlendingFactor;

class KhaBlend {
	public var srcRGB: BlendingFactor;
	public var dstRGB: BlendingFactor;
	public var srcAlpha: BlendingFactor;
	public var dstAlpha: BlendingFactor;
}

class KhaCall {
	public var type: Int;
	public var image: Int;
	public var pathOffset: Int;
	public var pathCount: Int;
	public var triangleOffset: Int;
	public var triangleCount: Int;
	public var uniformOffset: Int;
	public var blendFunc: KhaBlend;
}

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

		if (data != null) {
			var pixels = tex.lock();
			for (x in 0...w) {
				for (y in 0...h) {
					pixels.set(y * h * w * 4 + x * 4, data[y * h * w + x]);
				}
			}
			tex.unlock();
		}

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

	override public function renderCancel(uptr: Dynamic): Void {
		trace("renderCancel");
	}

	override public function renderFlush(uptr: Dynamic): Void {
		trace("renderFlush");
	}

	static function kha__maxi(a: Int, b: Int): Int { return a > b ? a : b; }

	static function kha__allocCall(context: KhaContext): KhaCall {
		var ret: KhaCall = null;
		if (context.ncalls+1 > context.ccalls) {
			var calls: Vector<KhaCall>;
			var ccalls: Int = kha__maxi(context.ncalls+1, 128) + Std.int(context.ccalls/2); // 1.5x Overallocate
			calls = new Vector<KhaCall>(ccalls);
			if (calls == null) return null;
			context.calls = calls;
			context.ccalls = ccalls;
		}
		ret = context.calls[context.ncalls++];
		ret.nullify();
		return ret;
	}

	static function glnvg__maxVertCount(paths: Vector<NVGpath>, npaths: Int): Int {
		var count: Int = 0;
		for (i in 0...npaths) {
			count += paths[i].nfill;
			count += paths[i].nstroke;
		}
		return count;
	}

	override public function renderFill(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, fringe: Float, bounds: Vector<Float>, paths: Vector<NVGpath>, npaths: Int): Void {
		var context: KhaContext = uptr;
		var call: KhaCall = kha__allocCall(context);
		var quad: NVGvertex;
		var frag: KhaFragUniforms;
		var maxverts: Int; var offset: Int;

		if (call == null) return;

		call.type = KHA_FILL;
		call.triangleCount = 4;
		call.pathOffset = kha__allocPaths(context, npaths);
		if (call.pathOffset == -1) {
			if (context.ncalls > 0) context.ncalls--;
			return;
		}
		call.pathCount = npaths;
		call.image = paint.image;
		call.blendFunc = kha__blendCompositeOperation(compositeOperation);

		if (npaths == 1 && paths[0].convex)
		{
			call.type = GLNVG_CONVEXFILL;
			call.triangleCount = 0;	// Bounding box fill quad not needed for convex fill
		}

		// Allocate vertices for all the paths.
		maxverts = kha__maxVertCount(paths, npaths) + call.triangleCount;
		offset = kha__allocVerts(context, maxverts);
		if (offset == -1) {
			if (context.ncalls > 0) context.ncalls--;
			return;
		}

		for (i in 0...npaths) {
			var copy: GLNVGpath = context.paths[call.pathOffset + i];
			var path: NVGpath = paths[i];
			path.nullify();
			if (path.nfill > 0) {
				copy.fillOffset = offset;
				copy.fillCount = path.nfill;
				memcpy(context.verts[offset], path.fill, sizeof(NVGvertex) * path.nfill);
				offset += path.nfill;
			}
			if (path.nstroke > 0) {
				copy.strokeOffset = offset;
				copy.strokeCount = path->nstroke;
				memcpy(context.verts[offset], path.stroke, sizeof(NVGvertex) * path.nstroke);
				offset += path.nstroke;
			}
		}

		// Setup uniforms for draw calls
		if (call.type == KHA_FILL) {
			// Quad
			call.triangleOffset = offset;
			quad = context.verts[call.triangleOffset];
			kha__vset(quad[0], bounds[2], bounds[3], 0.5, 1.0);
			kha__vset(quad[1], bounds[2], bounds[1], 0.5, 1.0);
			kha__vset(quad[2], bounds[0], bounds[3], 0.5, 1.0);
			kha__vset(quad[3], bounds[0], bounds[1], 0.5, 1.0);

			call.uniformOffset = kha__allocFragUniforms(context, 2);
			if (call.uniformOffset == -1) {
				if (context.ncalls > 0) context.ncalls--;
				return;
			}
			// Simple shader for stencil
			frag = nvg__fragUniformPtr(context, call.uniformOffset);
			frag.nullify();
			frag.strokeThr = -1.0;
			frag.type = NSVG_SHADER_SIMPLE;
			// Fill shader
			kha__convertPaint(context, nvg__fragUniformPtr(context, call.uniformOffset + context.fragSize), paint, scissor, fringe, fringe, -1.0);
		} else {
			call.uniformOffset = glnvg__allocFragUniforms(context, 1);
			if (call.uniformOffset == -1) {
				if (context.ncalls > 0) context.ncalls--;
				return;
			}
			// Fill shader
			kha__convertPaint(context, nvg__fragUniformPtr(context, call.uniformOffset), paint, scissor, fringe, fringe, -1.0);
		}

		return;
	}

	override public function renderStroke(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, fringe: Float, strokeWidth: Float, paths: Vector<NVGpath>, npaths: Int): Void {
		trace("renderStroke");
	}

	override public function renderTriangles(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, verts: Pointer<NVGvertex>, nverts: Int, fringe: Float): Void {
		trace("renderTriangles");
	}

	override public function renderDelete(uptr: Dynamic): Void {
		trace("renderDelete");
	}

	public function new() {
		super();
	}
}
