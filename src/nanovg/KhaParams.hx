package nanovg;

import kha.graphics4.BlendingFactor;
import haxe.ds.Vector;
import kha.Image;

enum abstract KhaShaderType(Int) from Int to Int {
	var NSVG_SHADER_FILLGRAD;
	var NSVG_SHADER_FILLIMG;
	var NSVG_SHADER_SIMPLE;
	var NSVG_SHADER_IMG;
}

enum abstract KhaCallType(Int) from Int to Int {
	var KHA_NONE = 0;
	var KHA_FILL;
	var KHA_CONVEXFILL;
	var KHA_STROKE;
	var KHA_TRIANGLES;
}

class KhaParams extends NVGparams {
	override public function renderCreate(uptr: Dynamic): Int {
		var kha: KhaContext = uptr;
		var align: Int = 4;
		return 1;
	}

	override public function renderCreateTexture(uptr: Dynamic, type: Int, w: Int, h: Int, imageFlags: Int, data: Array<Int>): Int {
		var context: KhaContext = uptr;
		var tex = new KhaTexture();
		tex.id = context.textures.length;
		tex.image = Image.create(w, h);

		if (tex == null) return 0;

		if (data != null) {
			var pixels = tex.image.lock();
			for (x in 0...w) {
				for (y in 0...h) {
					pixels.set(y * h * w * 4 + x * 4, data[y * h * w + x]);
				}
			}
			tex.image.unlock();
		}

		context.textures.push(tex);
		return tex.id;
	}

	override public function renderDeleteTexture(uptr: Dynamic, image: Int): Int {
		var context: KhaContext = uptr;

		var tex = context.textures[image];
		if (tex != null) {
			tex.image.unload();
			context.textures[image] = null;
			return 1;
		}

		return 0;
	}

	override public function renderUpdateTexture(uptr: Dynamic, image: Int, x: Int, y: Int, w: Int, h: Int, data: Array<Int>): Int {
		var context: KhaContext = uptr;

		var tex = context.textures[image];
		if (context.textures[image] != null) {
			var pixels = tex.image.lock();
			for (x in 0...w) {
				for (y in 0...h) {
					pixels.set(y * h * w * 4 + x * 4, data[y * h * w + x]);
				}
			}
			tex.image.unlock();
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

	static function kha__maxVertCount(paths: Vector<NVGpath>, npaths: Int): Int {
		var count: Int = 0;
		for (i in 0...npaths) {
			count += paths[i].nfill;
			count += paths[i].nstroke;
		}
		return count;
	}

	static function kha__vset(vtx: NVGvertex, x: Float, y: Float, u: Float, v: Float): Void {
		vtx.x = x;
		vtx.y = y;
		vtx.u = u;
		vtx.v = v;
	}

	static function kha__xformToMat3x4(m3: Vector<Float>, t: Vector<Float>): Void {
		m3[0] = t[0];
		m3[1] = t[1];
		m3[2] = 0.0;
		m3[3] = 0.0;
		m3[4] = t[2];
		m3[5] = t[3];
		m3[6] = 0.0;
		m3[7] = 0.0;
		m3[8] = t[4];
		m3[9] = t[5];
		m3[10] = 1.0;
		m3[11] = 0.0;
	}

	static function kha__premulColor(c: NVGcolor): NVGcolor {
		c.r *= c.a;
		c.g *= c.a;
		c.b *= c.a;
		return c;
	}

	static function kha__findTexture(context: KhaContext, id: Int): KhaTexture {
		var i: Int;
		for (i in 0...context.ntextures)
			if (context.textures[i].id == id)
				return context.textures[i];
		return null;
	}

	static function kha__convertPaint(context: KhaContext, frag: KhaFragUniforms, paint: NVGpaint, scissor: NVGscissor, width: Float, fringe: Float, strokeThr: Float): Int {
		var tex: KhaTexture = null;
		var invxform = new Vector<Float>(6);

		frag.nullify();

		frag.innerCol = kha__premulColor(paint.innerColor);
		frag.outerCol = kha__premulColor(paint.outerColor);

		if (scissor.extent[0] < -0.5 || scissor.extent[1] < -0.5) {
			for (i in 0...frag.scissorMat.length) {
				frag.scissorMat[i] = 0;
			}
			frag.scissorExt[0] = 1.0;
			frag.scissorExt[1] = 1.0;
			frag.scissorScale[0] = 1.0;
			frag.scissorScale[1] = 1.0;
		} else {
			NVG.nvgTransformInverse(invxform, scissor.xform);
			kha__xformToMat3x4(frag.scissorMat, invxform);
			frag.scissorExt[0] = scissor.extent[0];
			frag.scissorExt[1] = scissor.extent[1];
			frag.scissorScale[0] = NVG.nvg__sqrtf(scissor.xform[0]*scissor.xform[0] + scissor.xform[2]*scissor.xform[2]) / fringe;
			frag.scissorScale[1] = NVG.nvg__sqrtf(scissor.xform[1]*scissor.xform[1] + scissor.xform[3]*scissor.xform[3]) / fringe;
		}

		for (i in 0...paint.extent.length) {
			frag.extent[i] = paint.extent[i];
		}
		frag.strokeMult = (width*0.5 + fringe*0.5) / fringe;
		frag.strokeThr = strokeThr;

		if (paint.image != 0) {
			tex = kha__findTexture(context, paint.image);
			if (tex == null) return 0;
			if ((tex.flags & NVGimageFlags.NVG_IMAGE_FLIPY) != 0) {
			var m1 = new Vector<Float>(6);
			var m2 = new Vector<Float>(6);
			NVG.nvgTransformTranslate(m1, 0.0, frag.extent[1] * 0.5);
			NVG.nvgTransformMultiply(m1, paint.xform);
			NVG.nvgTransformScale(m2, 1.0, -1.0);
			NVG.nvgTransformMultiply(m2, m1);
			NVG.nvgTransformTranslate(m1, 0.0, -frag.extent[1] * 0.5);
			NVG.nvgTransformMultiply(m1, m2);
			NVG.nvgTransformInverse(invxform, m1);
		} else {
			NVG.nvgTransformInverse(invxform, paint.xform);
		}
		frag.type = NSVG_SHADER_FILLIMG;

		#if NANOVG_GL_USE_UNIFORMBUFFER
		if (tex.type == NVGtexture.NVG_TEXTURE_RGBA)
			frag.texType = (tex.flags & NVGimageFlags.NVG_IMAGE_PREMULTIPLIED != 0) ? 0 : 1;
		else
			frag->texType = 2;
		#else
		if (tex.type == NVGtexture.NVG_TEXTURE_RGBA)
			frag.texType = (tex.flags & NVGimageFlags.NVG_IMAGE_PREMULTIPLIED != 0) ? 0 : 1;
		else
			frag.texType = 2;
		#end
		//		printf("frag->texType = %d\n", frag->texType);
		} else {
			frag.type = NSVG_SHADER_FILLGRAD;
			frag.radius = paint.radius;
			frag.feather = paint.feather;
			NVG.nvgTransformInverse(invxform, paint.xform);
		}

		kha__xformToMat3x4(frag.paintMat, invxform);

		return 1;
	}

	static function kha__allocPaths(context: KhaContext, n: Int): Int
	{
		var ret: Int = 0;
		if (context.npaths+n > context.cpaths) {
			var paths: Vector<KhaPath>;
			var cpaths: Int = kha__maxi(context.npaths + n, 128) + Std.int(context.cpaths/2); // 1.5x Overallocate
			paths = new Vector<KhaPath>(cpaths);
			if (paths == null) return -1;
			context.paths = paths;
			context.cpaths = cpaths;
		}
		ret = context.npaths;
		context.npaths += n;
		return ret;
	}

	static function kha_convertBlendFuncFactor(factor: Int): BlendingFactor {
		if (factor == NVGblendFactor.NVG_ZERO)
			return BlendZero;
		if (factor == NVGblendFactor.NVG_ONE)
			return BlendOne;
		if (factor == NVGblendFactor.NVG_SRC_COLOR)
			return SourceColor;
		if (factor == NVGblendFactor.NVG_ONE_MINUS_SRC_COLOR)
			return InverseSourceColor;
		if (factor == NVGblendFactor.NVG_DST_COLOR)
			return DestinationColor;
		if (factor == NVGblendFactor.NVG_ONE_MINUS_DST_COLOR)
			return InverseDestinationColor;
		if (factor == NVGblendFactor.NVG_SRC_ALPHA)
			return SourceAlpha;
		if (factor == NVGblendFactor.NVG_ONE_MINUS_SRC_ALPHA)
			return InverseSourceAlpha;
		if (factor == NVGblendFactor.NVG_DST_ALPHA)
			return DestinationAlpha;
		if (factor == NVGblendFactor.NVG_ONE_MINUS_DST_ALPHA)
			return InverseDestinationAlpha;
		//if (factor == NVG_SRC_ALPHA_SATURATE)
		//	return GL_SRC_ALPHA_SATURATE;
		//return GL_INVALID_ENUM;
		throw "Unsupported blend mode";
	}

	static function kha__blendCompositeOperation(op: NVGcompositeOperationState): KhaBlend {
		var blend: KhaBlend = new KhaBlend();
		blend.srcRGB = kha_convertBlendFuncFactor(op.srcRGB);
		blend.dstRGB = kha_convertBlendFuncFactor(op.dstRGB);
		blend.srcAlpha = kha_convertBlendFuncFactor(op.srcAlpha);
		blend.dstAlpha = kha_convertBlendFuncFactor(op.dstAlpha);
		/*if (blend.srcRGB == GL_INVALID_ENUM || blend.dstRGB == GL_INVALID_ENUM || blend.srcAlpha == GL_INVALID_ENUM || blend.dstAlpha == GL_INVALID_ENUM)
		{
			blend.srcRGB = GL_ONE;
			blend.dstRGB = GL_ONE_MINUS_SRC_ALPHA;
			blend.srcAlpha = GL_ONE;
			blend.dstAlpha = GL_ONE_MINUS_SRC_ALPHA;
		}*/
		return blend;
	}

	static function kha__allocVerts(context: KhaContext, n: Int): Int {
		var ret: Int = 0;
		if (context.nverts+n > context.cverts) {
			var verts: Pointer<NVGvertex>;
			var cverts: Int = kha__maxi(context.nverts + n, 4096) + Std.int(context.cverts/2); // 1.5x Overallocate
			verts = new Pointer<NVGvertex>(new Vector<NVGvertex>(cverts));
			if (verts == null) return -1;
			context.verts = verts;
			context.cverts = cverts;
		}
		ret = context.nverts;
		context.nverts += n;
		return ret;
	}

	static function kha__allocFragUniforms(context: KhaContext, n: Int): Int {
		var ret: Int = 0; var structSize: Int = context.fragSize;
		if (context.nuniforms+n > context.cuniforms) {
			var uniforms: Vector<KhaFragUniforms>;
			var cuniforms: Int = kha__maxi(context.nuniforms+n, 128) + Std.int(context.cuniforms/2); // 1.5x Overallocate
			uniforms = new Vector<KhaFragUniforms>(cuniforms);
			if (uniforms == null) return -1;
			context.uniforms = uniforms;
			context.cuniforms = cuniforms;
		}
		ret = context.nuniforms * structSize;
		context.nuniforms += n;
		return ret;
	}

	static function kha__fragUniformPtr(context: KhaContext, i: Int): KhaFragUniforms {
		return context.uniforms[i];
	}

	override public function renderFill(uptr: Dynamic, paint: NVGpaint, compositeOperation: NVGcompositeOperationState, scissor: NVGscissor, fringe: Float, bounds: Vector<Float>, paths: Vector<NVGpath>, npaths: Int): Void {
		var context: KhaContext = uptr;
		var call: KhaCall = kha__allocCall(context);
		var quad: Pointer<NVGvertex>;
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
			call.type = KHA_CONVEXFILL;
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
			var copy: KhaPath = context.paths[call.pathOffset + i];
			var path: NVGpath = paths[i];
			path.nullify();
			if (path.nfill > 0) {
				copy.fillOffset = offset;
				copy.fillCount = path.nfill;
				for (i in 0...path.nfill) {
					path.fill.value(i).copyTo(context.verts.value(offset + i));
				}
				offset += path.nfill;
			}
			if (path.nstroke > 0) {
				copy.strokeOffset = offset;
				copy.strokeCount = path.nstroke;
				for (i in 0...path.nstroke) {
					path.stroke.value(i).copyTo(context.verts.value(offset + i));
				}
				offset += path.nstroke;
			}
		}

		// Setup uniforms for draw calls
		if (call.type == KHA_FILL) {
			// Quad
			call.triangleOffset = offset;
			quad = context.verts.pointer(call.triangleOffset);
			kha__vset(quad.value(0), bounds[2], bounds[3], 0.5, 1.0);
			kha__vset(quad.value(1), bounds[2], bounds[1], 0.5, 1.0);
			kha__vset(quad.value(2), bounds[0], bounds[3], 0.5, 1.0);
			kha__vset(quad.value(3), bounds[0], bounds[1], 0.5, 1.0);

			call.uniformOffset = kha__allocFragUniforms(context, 2);
			if (call.uniformOffset == -1) {
				if (context.ncalls > 0) context.ncalls--;
				return;
			}
			// Simple shader for stencil
			frag = kha__fragUniformPtr(context, call.uniformOffset);
			frag.nullify();
			frag.strokeThr = -1.0;
			frag.type = NSVG_SHADER_SIMPLE;
			// Fill shader
			kha__convertPaint(context, kha__fragUniformPtr(context, call.uniformOffset + context.fragSize), paint, scissor, fringe, fringe, -1.0);
		} else {
			call.uniformOffset = kha__allocFragUniforms(context, 1);
			if (call.uniformOffset == -1) {
				if (context.ncalls > 0) context.ncalls--;
				return;
			}
			// Fill shader
			kha__convertPaint(context, kha__fragUniformPtr(context, call.uniformOffset), paint, scissor, fringe, fringe, -1.0);
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
