//
// Copyright (c) 2013 Mikko Mononen memon@inside.org
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.
//
package nanovg;

import haxe.ds.Vector;

class StringPointer {
	var string: String;
	var index: Int;

	public function new(string: String, index: Int = 0) {
		this.string = string;
		this.index = index;
	}

	public inline function value(index: Int = 0): Int {
		return string.charCodeAt(this.index + index);
	}

	public inline function inc(): Void {
		++index;
	}

	public inline function pointer(index: Int): StringPointer {
		return new StringPointer(string, this.index + index);
	}

	public inline function sub(pointer: StringPointer): Int {
		return index - pointer.index;
	}

	public inline function length(): Int {
		return string.length - index;
	}
}

enum abstract NVGwinding(Int) from Int to Int {
	var NVG_CCW = 1; // Winding for solid shapes
	var NVG_CW = 2; // Winding for holes
}

enum abstract NVGsolidity(Int) from Int to Int {
	var NVG_SOLID = 1; // CCW
	var NVG_HOLE = 2; // CW
}

enum abstract NVGlineCap(Int) from Int to Int {
	var NVG_BUTT;
	var NVG_ROUND;
	var NVG_SQUARE;
	var NVG_BEVEL;
	var NVG_MITER;
}

enum abstract NVGalign(Int) from Int to Int {
	// Horizontal align
	var NVG_ALIGN_LEFT = 1 << 0; // Default, align text horizontally to left.
	var NVG_ALIGN_CENTER = 1 << 1; // Align text horizontally to center.
	var NVG_ALIGN_RIGHT = 1 << 2; // Align text horizontally to right.
	// Vertical align
	var NVG_ALIGN_TOP = 1 << 3; // Align text vertically to top.
	var NVG_ALIGN_MIDDLE = 1 << 4; // Align text vertically to middle.
	var NVG_ALIGN_BOTTOM = 1 << 5; // Align text vertically to bottom.
	var NVG_ALIGN_BASELINE = 1 << 6; // Default, align text vertically to baseline.
}

enum abstract NVGcompositeOperation(Int) from Int to Int {
	var NVG_SOURCE_OVER;
	var NVG_SOURCE_IN;
	var NVG_SOURCE_OUT;
	var NVG_ATOP;
	var NVG_DESTINATION_OVER;
	var NVG_DESTINATION_IN;
	var NVG_DESTINATION_OUT;
	var NVG_DESTINATION_ATOP;
	var NVG_LIGHTER;
	var NVG_COPY;
	var NVG_XOR;
}

class NVGglyphPosition {
	public var str: StringPointer; // Position of the glyph in the input string.
	public var x: Float; // The x-coordinate of the logical glyph position.
	public var minx: Float;
	public var maxx: Float; // The bounds of the glyph shape.
}

class NVGtextRow {
	public var start: StringPointer; // Pointer to the input text where the row starts.
	public var end: StringPointer; // Pointer to the input text where the row ends (one past the last character).
	public var next: StringPointer; // Pointer to the beginning of the next row.
	public var width: Float; // Logical width of the row.
	public var minx: Float;
	public var maxx: Float; // Actual bounds of the row. Logical with and bounds can differ because of kerning and some parts over extending.
}

enum abstract NVGcommands(Int) from Int to Int {
	var NVG_MOVETO = 0;
	var NVG_LINETO = 1;
	var NVG_BEZIERTO = 2;
	var NVG_CLOSE = 3;
	var NVG_WINDING = 4;
}

enum abstract NVGpointFlags(Int) from Int to Int {
	var NVG_PT_CORNER = 0x01;
	var NVG_PT_LEFT = 0x02;
	var NVG_PT_BEVEL = 0x04;
	var NVG_PR_INNERBEVEL = 0x08;
}

class NVGstate {
	public var compositeOperation: NVGcompositeOperationState;
	public var shapeAntiAlias: Int;
	public var fill: NVGpaint;
	public var stroke: NVGpaint;
	public var strokeWidth: Float;
	public var miterLimit: Float;
	public var lineJoin: Int;
	public var lineCap: Int;
	public var alpha: Float;
	public var xform: Vector<Float>;
	public var scissor: NVGscissor;
	public var fontSize: Float;
	public var letterSpacing: Float;
	public var lineHeight: Float;
	public var fontBlur: Float;
	public var textAlign: Int;
	public var fontId: Int;

	public function new() {
		xform = new Vector<Float>(6);
	}

	public function nullify(): Void {
		compositeOperation = new NVGcompositeOperationState();
		shapeAntiAlias = 0;
		fill = new NVGpaint();
		stroke = new NVGpaint();
		strokeWidth = 0;
		miterLimit = 0;
		lineJoin = 0;
		lineCap = 0;
		alpha = 0;
		xform = new Vector<Float>(6);
		scissor = new NVGscissor();
		fontSize = 0;
		letterSpacing = 0;
		lineHeight = 0;
		fontBlur = 0;
		textAlign = 0;
		fontId = 0;
	}

	public function copyTo(state: NVGstate): Void {
		compositeOperation.copyTo(state.compositeOperation);
		state.shapeAntiAlias = shapeAntiAlias;
		fill.copyTo(state.fill);
		stroke.copyTo(state.stroke);
		state.strokeWidth = strokeWidth;
		state.miterLimit = miterLimit;
		state.lineJoin = lineJoin;
		state.lineCap = lineCap;
		state.alpha = alpha;
		for (i in 0...xform.length) {
			state.xform[i] = xform[i];
		}
		scissor.copyTo(state.scissor);
		state.fontSize = fontSize;
		state.letterSpacing = letterSpacing;
		state.lineHeight = lineHeight;
		state.fontBlur = fontBlur;
		state.textAlign = textAlign;
		state.fontId = fontId;
	}
}

class NVGpoint {
	public var x: Float;
	public var y: Float;
	public var dx: Float;
	public var dy: Float;
	public var len: Float;
	public var dmx: Float;
	public var dmy: Float;
	public var flags: Int;

	public function new() {}

	public function nullify(): Void {
		x = 0.0;
		y = 0.0;
		dx = 0.0;
		dy = 0.0;
		len = 0.0;
		dmx = 0.0;
		dmy = 0.0;
		flags = 0;
	}
}

class NVGpathCache {
	public var points: Pointer<NVGpoint>;
	public var npoints: Int;
	public var cpoints: Int;
	public var paths: Vector<NVGpath>;
	public var npaths: Int;
	public var cpaths: Int;
	public var verts: Pointer<NVGvertex>;
	public var nverts: Int;
	public var cverts: Int;
	public var bounds: Vector<Float>;

	public function new() {
		bounds = new Vector<Float>(4);
	}
}

class NVGcontext {
	public var params: NVGparams;
	public var commands: Pointer<Float>;
	public var ccommands: Int;
	public var ncommands: Int;
	public var commandx: Float;
	public var commandy: Float;
	public var states: Vector<NVGstate>;
	public var nstates: Int;
	public var cache: NVGpathCache;
	public var tessTol: Float;
	public var distTol: Float;
	public var fringeWidth: Float;
	public var devicePxRatio: Float;
	public var fs: FONScontext;
	public var fontImages: Vector<Int>;
	public var fontImageIdx: Int;
	public var drawCallCount: Int;
	public var fillTriCount: Int;
	public var strokeTriCount: Int;
	public var textTriCount: Int;

	public function new() {
		states = new Vector<NVGstate>(NVG.NVG_MAX_STATES);
		for (i in 0...states.length) {
			states[i] = new NVGstate();
		}
		fontImages = new Vector<Int>(NVG.NVG_MAX_FONTIMAGES);
	}
}

enum abstract NVGcodepointType(Int) from Int to Int {
	var NVG_SPACE;
	var NVG_NEWLINE;
	var NVG_CHAR;
	var NVG_CJK_CHAR;
}

enum abstract NVGcreateFlags(Int) from Int to Int {
	// Flag indicating if geometry based anti-aliasing is used (may not be needed when using MSAA).
	var NVG_ANTIALIAS = 1 << 0;
	// Flag indicating if strokes should be drawn using stencil buffer. The rendering will be a little
	// slower, but path overlaps (i.e. self-intersecting or sharp turns) will be drawn just once.
	var NVG_STENCIL_STROKES = 1 << 1;
	// Flag indicating that additional debug checks are done.
	var NVG_DEBUG = 1 << 2;
}

class NVG {
	static final NVG_PI = 3.14159265358979323846264338327;

	static final NVG_INIT_FONTIMAGE_SIZE = 512;
	static final NVG_MAX_FONTIMAGE_SIZE = 2048;
	public static final NVG_MAX_FONTIMAGES = 4;

	static final NVG_INIT_COMMANDS_SIZE = 256;
	static final NVG_INIT_POINTS_SIZE = 128;
	static final NVG_INIT_PATHS_SIZE = 16;
	static final NVG_INIT_VERTS_SIZE = 256;
	public static final NVG_MAX_STATES = 32;

	static final NVG_KAPPA90 = 0.5522847493; // Length proportional to radius of a cubic bezier handle for 90deg arcs.

	// static function NVG_COUNTOF(arr) { return (sizeof(arr) / sizeof(0[arr])); }

	public static function nvg__sqrtf(a: Float): Float {
		return Math.sqrt(a);
	}

	static function nvg__modf(a: Float, b: Float): Float {
		return a % b;
	}

	static function nvg__sinf(a: Float): Float {
		return Math.sin(a);
	}

	static function nvg__cosf(a: Float): Float {
		return Math.cos(a);
	}

	static function nvg__tanf(a: Float): Float {
		return Math.tan(a);
	}

	static function nvg__atan2f(a: Float, b: Float): Float {
		return Math.atan2(a, b);
	}

	static function nvg__acosf(a: Float): Float {
		return Math.acos(a);
	}

	static function nvg__ceilf(a: Float): Float {
		return Math.ceil(a);
	}

	static function nvg__mini(a: Int, b: Int): Int {
		return a < b ? a : b;
	}

	static function nvg__maxi(a: Int, b: Int): Int {
		return a > b ? a : b;
	}

	static function nvg__clampi(a: Int, mn: Int, mx: Int): Int {
		return a < mn ? mn : (a > mx ? mx : a);
	}

	static function nvg__minf(a: Float, b: Float): Float {
		return a < b ? a : b;
	}

	static function nvg__maxf(a: Float, b: Float): Float {
		return a > b ? a : b;
	}

	static function nvg__absf(a: Float): Float {
		return a >= 0.0 ? a : -a;
	}

	static function nvg__signf(a: Float): Float {
		return a >= 0.0 ? 1.0 : -1.0;
	}

	static function nvg__clampf(a: Float, mn: Float, mx: Float): Float {
		return a < mn ? mn : (a > mx ? mx : a);
	}

	static function nvg__cross(dx0: Float, dy0: Float, dx1: Float, dy1: Float): Float {
		return dx1 * dy0 - dx0 * dy1;
	}

	static function nvg__normalize(x: Ref<Float>, y: Ref<Float>): Float {
		var d: Float = nvg__sqrtf((x.value) * (x.value) + (y.value) * (y.value));
		if (d > 1e-6) {
			var id: Float = 1.0 / d;
			x.value *= id;
			y.value *= id;
		}
		return d;
	}

	static function nvg__deletePathCache(c: NVGpathCache): Void {
		// if (c == null) return;
		// if (c->points != NULL) free(c->points);
		// if (c->paths != NULL) free(c->paths);
		// if (c->verts != NULL) free(c->verts);
		// free(c);
	}

	static function nvg__allocPathCache(): NVGpathCache {
		var c: NVGpathCache = new NVGpathCache();
		if (c == null)
			return null;
		// memset(c, 0, sizeof(NVGpathCache));

		c.points = new Pointer<NVGpoint>(new Vector<NVGpoint>(NVG_INIT_POINTS_SIZE));
		if (c.points == null)
			return null;
		for (i in 0...c.points.arr.length) {
			c.points.arr[i] = new NVGpoint();
		}
		c.npoints = 0;
		c.cpoints = NVG_INIT_POINTS_SIZE;

		c.paths = new Vector<NVGpath>(NVG_INIT_PATHS_SIZE);
		if (c.paths == null)
			return null;
		for (i in 0...c.paths.length) {
			c.paths[i] = new NVGpath();
		}
		c.npaths = 0;
		c.cpaths = NVG_INIT_PATHS_SIZE;

		c.verts = new Pointer<NVGvertex>(new Vector<NVGvertex>(NVG_INIT_VERTS_SIZE));
		if (c.verts == null)
			return null;
		for (i in 0...c.verts.arr.length) {
			c.verts.arr[i] = new NVGvertex();
		}
		c.nverts = 0;
		c.cverts = NVG_INIT_VERTS_SIZE;

		return c;
	}

	static function nvg__setDevicePixelRatio(ctx: NVGcontext, ratio: Float): Void {
		ctx.tessTol = 0.25 / ratio;
		ctx.distTol = 0.01 / ratio;
		ctx.fringeWidth = 1.0 / ratio;
		ctx.devicePxRatio = ratio;
	}

	static function nvg__compositeOperationState(op: Int): NVGcompositeOperationState {
		var sfactor: Int;
		var dfactor: Int;

		if (op == NVG_SOURCE_OVER) {
			sfactor = NVGblendFactor.NVG_ONE;
			dfactor = NVGblendFactor.NVG_ONE_MINUS_SRC_ALPHA;
		}
		else if (op == NVG_SOURCE_IN) {
			sfactor = NVGblendFactor.NVG_DST_ALPHA;
			dfactor = NVGblendFactor.NVG_ZERO;
		}
		else if (op == NVG_SOURCE_OUT) {
			sfactor = NVGblendFactor.NVG_ONE_MINUS_DST_ALPHA;
			dfactor = NVGblendFactor.NVG_ZERO;
		}
		else if (op == NVG_ATOP) {
			sfactor = NVGblendFactor.NVG_DST_ALPHA;
			dfactor = NVGblendFactor.NVG_ONE_MINUS_SRC_ALPHA;
		}
		else if (op == NVG_DESTINATION_OVER) {
			sfactor = NVGblendFactor.NVG_ONE_MINUS_DST_ALPHA;
			dfactor = NVGblendFactor.NVG_ONE;
		}
		else if (op == NVG_DESTINATION_IN) {
			sfactor = NVGblendFactor.NVG_ZERO;
			dfactor = NVGblendFactor.NVG_SRC_ALPHA;
		}
		else if (op == NVG_DESTINATION_OUT) {
			sfactor = NVGblendFactor.NVG_ZERO;
			dfactor = NVGblendFactor.NVG_ONE_MINUS_SRC_ALPHA;
		}
		else if (op == NVG_DESTINATION_ATOP) {
			sfactor = NVGblendFactor.NVG_ONE_MINUS_DST_ALPHA;
			dfactor = NVGblendFactor.NVG_SRC_ALPHA;
		}
		else if (op == NVG_LIGHTER) {
			sfactor = NVGblendFactor.NVG_ONE;
			dfactor = NVGblendFactor.NVG_ONE;
		}
		else if (op == NVG_COPY) {
			sfactor = NVGblendFactor.NVG_ONE;
			dfactor = NVGblendFactor.NVG_ZERO;
		}
		else if (op == NVG_XOR) {
			sfactor = NVGblendFactor.NVG_ONE_MINUS_DST_ALPHA;
			dfactor = NVGblendFactor.NVG_ONE_MINUS_SRC_ALPHA;
		}
		else {
			sfactor = NVGblendFactor.NVG_ONE;
			dfactor = NVGblendFactor.NVG_ZERO;
		}

		var state: NVGcompositeOperationState = new NVGcompositeOperationState();
		state.srcRGB = sfactor;
		state.dstRGB = dfactor;
		state.srcAlpha = sfactor;
		state.dstAlpha = dfactor;
		return state;
	}

	static function nvg__getState(ctx: NVGcontext): NVGstate {
		return ctx.states[ctx.nstates - 1];
	}

	public static function nvgCreateInternal(params: NVGparams): NVGcontext {
		var fontParams: FONSparams;
		var ctx: NVGcontext = new NVGcontext();
		// var i: Int;
		if (ctx == null)
			return null;
		// memset(ctx, 0, sizeof(NVGcontext));

		ctx.params = params;
		for (i in 0...NVG_MAX_FONTIMAGES)
			ctx.fontImages[i] = 0;

		ctx.commands = new Pointer<Float>(new Vector<Float>(NVG_INIT_COMMANDS_SIZE));
		if (ctx.commands == null)
			return null;
		ctx.ncommands = 0;
		ctx.ccommands = NVG_INIT_COMMANDS_SIZE;

		ctx.cache = nvg__allocPathCache();
		if (ctx.cache == null)
			return null;

		nvgSave(ctx);
		nvgReset(ctx);

		nvg__setDevicePixelRatio(ctx, 1.0);

		if (ctx.params.renderCreate(ctx.params.userPtr) == 0)
			return null;

		// Init font rendering
		// memset(&fontParams, 0, sizeof(fontParams));
		fontParams = new FONSparams();
		fontParams.width = NVG_INIT_FONTIMAGE_SIZE;
		fontParams.height = NVG_INIT_FONTIMAGE_SIZE;
		fontParams.flags = FONS_ZERO_TOPLEFT;
		fontParams.renderCreate = null;
		fontParams.renderUpdate = null;
		fontParams.renderDraw = null;
		fontParams.renderDelete = null;
		fontParams.userPtr = null;
		ctx.fs = fonsCreateInternal(fontParams);
		if (ctx.fs == null)
			return null;

		// Create font texture
		ctx.fontImages[0] = ctx.params.renderCreateTexture(ctx.params.userPtr, NVGtexture.NVG_TEXTURE_ALPHA, fontParams.width, fontParams.height, 0, null);
		if (ctx.fontImages[0] == 0)
			return null;
		ctx.fontImageIdx = 0;

		return ctx;
	}

	public static function nvgInternalParams(ctx: NVGcontext): NVGparams {
		return ctx.params;
	}

	public static function nvgDeleteInternal(ctx: NVGcontext): Void {
		var i: Int;
		if (ctx == null)
			return;
		// if (ctx->commands != null) free(ctx->commands);
		if (ctx.cache != null)
			nvg__deletePathCache(ctx.cache);

		if (ctx.fs != null)
			fonsDeleteInternal(ctx.fs);

		for (i in 0...NVG_MAX_FONTIMAGES) {
			if (ctx.fontImages[i] != 0) {
				nvgDeleteImage(ctx, ctx.fontImages[i]);
				ctx.fontImages[i] = 0;
			}
		}

		if (ctx.params.renderDelete != null)
			ctx.params.renderDelete(ctx.params.userPtr);

		// free(ctx);
	}

	public static function nvgBeginFrame(ctx: NVGcontext, windowWidth: Float, windowHeight: Float, devicePixelRatio: Float): Void {
		/*	printf("Tris: draws:%d  fill:%d  stroke:%d  text:%d  TOT:%d\n",
			ctx->drawCallCount, ctx->fillTriCount, ctx->strokeTriCount, ctx->textTriCount,
			ctx->fillTriCount+ctx->strokeTriCount+ctx->textTriCount); */

		ctx.nstates = 0;
		nvgSave(ctx);
		nvgReset(ctx);

		nvg__setDevicePixelRatio(ctx, devicePixelRatio);

		ctx.params.renderViewport(ctx.params.userPtr, windowWidth, windowHeight, devicePixelRatio);

		ctx.drawCallCount = 0;
		ctx.fillTriCount = 0;
		ctx.strokeTriCount = 0;
		ctx.textTriCount = 0;
	}

	public static function nvgCancelFrame(ctx: NVGcontext): Void {
		ctx.params.renderCancel(ctx.params.userPtr);
	}

	public static function nvgEndFrame(ctx: NVGcontext): Void {
		ctx.params.renderFlush(ctx.params.userPtr);
		if (ctx.fontImageIdx != 0) {
			var fontImage: Int = ctx.fontImages[ctx.fontImageIdx];
			var j: Int;
			var iw: Int = 0;
			var ih: Int = 0;
			// delete images that smaller than current one
			if (fontImage == 0)
				return;
			nvgImageSize(ctx, fontImage, new Ref<Int>(iw), new Ref<Int>(ih));
			j = 0;
			for (i in 0...ctx.fontImageIdx) {
				if (ctx.fontImages[i] != 0) {
					var nw: Int = 0;
					var nh: Int = 0;
					nvgImageSize(ctx, ctx.fontImages[i], new Ref<Int>(nw), new Ref<Int>(nh));
					if (nw < iw || nh < ih)
						nvgDeleteImage(ctx, ctx.fontImages[i]);
					else
						ctx.fontImages[j++] = ctx.fontImages[i];
				}
			}
			// make current font image to first
			ctx.fontImages[j++] = ctx.fontImages[0];
			ctx.fontImages[0] = fontImage;
			ctx.fontImageIdx = 0;
			// clear all images after j
			for (i in j...NVG_MAX_FONTIMAGES)
				ctx.fontImages[i] = 0;
		}
	}

	public static function nvgRGB(r: Int, g: Int, b: Int): NVGcolor {
		return nvgRGBA(r, g, b, 255);
	}

	public static function nvgRGBf(r: Float, g: Float, b: Float): NVGcolor {
		return nvgRGBAf(r, g, b, 1.0);
	}

	public static function nvgRGBA(r: Int, g: Int, b: Int, a: Int): NVGcolor {
		var color: NVGcolor = new NVGcolor();
		// Use longer initialization to suppress warning.
		color.r = r / 255.0;
		color.g = g / 255.0;
		color.b = b / 255.0;
		color.a = a / 255.0;
		return color;
	}

	public static function nvgRGBAf(r: Float, g: Float, b: Float, a: Float): NVGcolor {
		var color: NVGcolor = new NVGcolor();
		// Use longer initialization to suppress warning.
		color.r = r;
		color.g = g;
		color.b = b;
		color.a = a;
		return color;
	}

	public static function nvgTransRGBA(c: NVGcolor, a: Int): NVGcolor {
		c.a = a / 255.0;
		return c;
	}

	public static function nvgTransRGBAf(c: NVGcolor, a: Float): NVGcolor {
		c.a = a;
		return c;
	}

	public static function nvgLerpRGBA(c0: NVGcolor, c1: NVGcolor, u: Float): NVGcolor {
		// var i: Int;
		var oneminu: Float;
		var cint: NVGcolor = new NVGcolor();

		u = nvg__clampf(u, 0.0, 1.0);
		oneminu = 1.0 - u;
		// for( i in 0...4 )
		{
			cint.r = c0.r * oneminu + c1.r * u;
			cint.g = c0.g * oneminu + c1.g * u;
			cint.b = c0.b * oneminu + c1.b * u;
			cint.a = c0.a * oneminu + c1.a * u;
		}

		return cint;
	}

	public static function nvgHSL(h: Float, s: Float, l: Float): NVGcolor {
		return nvgHSLA(h, s, l, 255);
	}

	static function nvg__hue(h: Float, m1: Float, m2: Float): Float {
		if (h < 0)
			h += 1;
		if (h > 1)
			h -= 1;
		if (h < 1.0 / 6.0)
			return m1 + (m2 - m1) * h * 6.0;
		else if (h < 3.0 / 6.0)
			return m2;
		else if (h < 4.0 / 6.0)
			return m1 + (m2 - m1) * (2.0 / 3.0 - h) * 6.0;
		return m1;
	}

	public static function nvgHSLA(h: Float, s: Float, l: Float, a: Int): NVGcolor {
		var m1: Float;
		var m2: Float;
		var col: NVGcolor = new NVGcolor();
		h = nvg__modf(h, 1.0);
		if (h < 0.0)
			h += 1.0;
		s = nvg__clampf(s, 0.0, 1.0);
		l = nvg__clampf(l, 0.0, 1.0);
		m2 = l <= 0.5 ? (l * (1 + s)) : (l + s - l * s);
		m1 = 2 * l - m2;
		col.r = nvg__clampf(nvg__hue(h + 1.0 / 3.0, m1, m2), 0.0, 1.0);
		col.g = nvg__clampf(nvg__hue(h, m1, m2), 0.0, 1.0);
		col.b = nvg__clampf(nvg__hue(h - 1.0 / 3.0, m1, m2), 0.0, 1.0);
		col.a = a / 255.0;
		return col;
	}

	public static function nvgTransformIdentity(t: Vector<Float>): Void {
		t[0] = 1.0;
		t[1] = 0.0;
		t[2] = 0.0;
		t[3] = 1.0;
		t[4] = 0.0;
		t[5] = 0.0;
	}

	public static function nvgTransformTranslate(t: Vector<Float>, tx: Float, ty: Float): Void {
		t[0] = 1.0;
		t[1] = 0.0;
		t[2] = 0.0;
		t[3] = 1.0;
		t[4] = tx;
		t[5] = ty;
	}

	public static function nvgTransformScale(t: Vector<Float>, sx: Float, sy: Float): Void {
		t[0] = sx;
		t[1] = 0.0;
		t[2] = 0.0;
		t[3] = sy;
		t[4] = 0.0;
		t[5] = 0.0;
	}

	public static function nvgTransformRotate(t: Vector<Float>, a: Float): Void {
		var cs: Float = nvg__cosf(a), sn = nvg__sinf(a);
		t[0] = cs;
		t[1] = sn;
		t[2] = -sn;
		t[3] = cs;
		t[4] = 0.0;
		t[5] = 0.0;
	}

	public static function nvgTransformSkewX(t: Vector<Float>, a: Float): Void {
		t[0] = 1.0;
		t[1] = 0.0;
		t[2] = nvg__tanf(a);
		t[3] = 1.0;
		t[4] = 0.0;
		t[5] = 0.0;
	}

	public static function nvgTransformSkewY(t: Vector<Float>, a: Float): Void {
		t[0] = 1.0;
		t[1] = nvg__tanf(a);
		t[2] = 0.0;
		t[3] = 1.0;
		t[4] = 0.0;
		t[5] = 0.0;
	}

	public static function nvgTransformMultiply(t: Vector<Float>, s: Vector<Float>): Void {
		var t0: Float = t[0] * s[0] + t[1] * s[2];
		var t2: Float = t[2] * s[0] + t[3] * s[2];
		var t4: Float = t[4] * s[0] + t[5] * s[2] + s[4];
		t[1] = t[0] * s[1] + t[1] * s[3];
		t[3] = t[2] * s[1] + t[3] * s[3];
		t[5] = t[4] * s[1] + t[5] * s[3] + s[5];
		t[0] = t0;
		t[2] = t2;
		t[4] = t4;
	}

	public static function nvgTransformPremultiply(t: Vector<Float>, s: Vector<Float>): Void {
		var s2 = new Vector<Float>(6);
		for (i in 0...6) {
			s2[i] = s[i];
		}
		nvgTransformMultiply(s2, t);
		for (i in 0...6) {
			t[i] = s2[i];
		}
	}

	public static function nvgTransformInverse(inv: Vector<Float>, t: Vector<Float>): Int {
		var invdet: Float;
		var det: Float = t[0] * t[3] - t[2] * t[1];
		if (det > -1e-6 && det < 1e-6) {
			nvgTransformIdentity(inv);
			return 0;
		}
		invdet = 1.0 / det;
		inv[0] = (t[3] * invdet);
		inv[2] = (-t[2] * invdet);
		inv[4] = ((t[2] * t[5] - t[3] * t[4]) * invdet);
		inv[1] = (-t[1] * invdet);
		inv[3] = (t[0] * invdet);
		inv[5] = ((t[1] * t[4] - t[0] * t[5]) * invdet);
		return 1;
	}

	public static function nvgTransformPoint(dx: Ref<Float>, dy: Ref<Float>, t: Vector<Float>, sx: Float, sy: Float): Void {
		dx.value = sx * t[0] + sy * t[2] + t[4];
		dy.value = sx * t[1] + sy * t[3] + t[5];
	}

	public static function nvgDegToRad(deg: Float): Float {
		return deg / 180.0 * NVG_PI;
	}

	public static function nvgRadToDeg(rad: Float): Float {
		return rad / NVG_PI * 180.0;
	}

	public static function nvg__setPaintColor(p: NVGpaint, color: NVGcolor): Void {
		p.nullify();
		nvgTransformIdentity(p.xform);
		p.radius = 0.0;
		p.feather = 1.0;
		p.innerColor = color;
		p.outerColor = color;
	}

	// State handling
	public static function nvgSave(ctx: NVGcontext): Void {
		if (ctx.nstates >= NVG_MAX_STATES)
			return;
		if (ctx.nstates > 0)
			ctx.states[ctx.nstates - 1].copyTo(ctx.states[ctx.nstates]);
		ctx.nstates++;
	}

	public static function nvgRestore(ctx: NVGcontext): Void {
		if (ctx.nstates <= 1)
			return;
		ctx.nstates--;
	}

	public static function nvgReset(ctx: NVGcontext): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.nullify();

		nvg__setPaintColor(state.fill, nvgRGBA(255, 255, 255, 255));
		nvg__setPaintColor(state.stroke, nvgRGBA(0, 0, 0, 255));
		state.compositeOperation = nvg__compositeOperationState(NVG_SOURCE_OVER);
		state.shapeAntiAlias = 1;
		state.strokeWidth = 1.0;
		state.miterLimit = 10.0;
		state.lineCap = NVG_BUTT;
		state.lineJoin = NVG_MITER;
		state.alpha = 1.0;
		nvgTransformIdentity(state.xform);

		state.scissor.extent[0] = -1.0;
		state.scissor.extent[1] = -1.0;

		state.fontSize = 16.0;
		state.letterSpacing = 0.0;
		state.lineHeight = 1.0;
		state.fontBlur = 0.0;
		state.textAlign = NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE;
		state.fontId = 0;
	}

	// State setting
	public static function nvgShapeAntiAlias(ctx: NVGcontext, enabled: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.shapeAntiAlias = enabled;
	}

	public static function nvgStrokeWidth(ctx: NVGcontext, width: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.strokeWidth = width;
	}

	public static function nvgMiterLimit(ctx: NVGcontext, limit: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.miterLimit = limit;
	}

	public static function nvgLineCap(ctx: NVGcontext, cap: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.lineCap = cap;
	}

	public static function nvgLineJoin(ctx: NVGcontext, join: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.lineJoin = join;
	}

	public static function nvgGlobalAlpha(ctx: NVGcontext, alpha: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.alpha = alpha;
	}

	public static function nvgTransform(ctx: NVGcontext, a: Float, b: Float, c: Float, d: Float, e: Float, f: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		var t = new Vector<Float>(6);
		t[0] = a;
		t[1] = b;
		t[2] = c;
		t[3] = d;
		t[4] = e;
		t[5] = f;
		nvgTransformPremultiply(state.xform, t);
	}

	public static function nvgResetTransform(ctx: NVGcontext): Void {
		var state: NVGstate = nvg__getState(ctx);
		nvgTransformIdentity(state.xform);
	}

	public static function nvgTranslate(ctx: NVGcontext, x: Float, y: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		var t = new Vector<Float>(6);
		nvgTransformTranslate(t, x, y);
		nvgTransformPremultiply(state.xform, t);
	}

	public static function nvgRotate(ctx: NVGcontext, angle: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		var t = new Vector<Float>(6);
		nvgTransformRotate(t, angle);
		nvgTransformPremultiply(state.xform, t);
	}

	public static function nvgSkewX(ctx: NVGcontext, angle: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		var t = new Vector<Float>(6);
		nvgTransformSkewX(t, angle);
		nvgTransformPremultiply(state.xform, t);
	}

	public static function nvgSkewY(ctx: NVGcontext, angle: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		var t = new Vector<Float>(6);
		nvgTransformSkewY(t, angle);
		nvgTransformPremultiply(state.xform, t);
	}

	public static function nvgScale(ctx: NVGcontext, x: Float, y: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		var t = new Vector<Float>(6);
		nvgTransformScale(t, x, y);
		nvgTransformPremultiply(state.xform, t);
	}

	public static function nvgCurrentTransform(ctx: NVGcontext, xform: Array<Float>): Void {
		var state: NVGstate = nvg__getState(ctx);
		if (xform == null)
			return;
		for (i in 0...state.xform.length) {
			xform[i] = state.xform[i];
		}
	}

	public static function nvgStrokeColor(ctx: NVGcontext, color: NVGcolor): Void {
		var state: NVGstate = nvg__getState(ctx);
		nvg__setPaintColor(state.stroke, color);
	}

	public static function nvgStrokePaint(ctx: NVGcontext, paint: NVGpaint): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.stroke = paint;
		nvgTransformMultiply(state.stroke.xform, state.xform);
	}

	public static function nvgFillColor(ctx: NVGcontext, color: NVGcolor): Void {
		var state: NVGstate = nvg__getState(ctx);
		nvg__setPaintColor(state.fill, color);
	}

	public static function nvgFillPaint(ctx: NVGcontext, paint: NVGpaint): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.fill = paint;
		nvgTransformMultiply(state.fill.xform, state.xform);
	}

	public static function nvgCreateImage(ctx: NVGcontext, filename: String, imageFlags: Int): Int {
		var w: Int = 0;
		var h: Int = 0;
		var n: Int;
		var image: Int;
		var img: Array<Int> = null;
		// stbi_set_unpremultiply_on_load(1);
		// stbi_convert_iphone_png_to_rgb(1);
		//**img = stbi_load(filename, new Ref<Int>(w), new Ref<Int>(h), new Ref<Int>(n), 4);
		if (img == null) {
			//		printf("Failed to load %s - %s\n", filename, stbi_failure_reason());
			return 0;
		}
		image = nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
		// stbi_image_free(img);
		return image;
	}

	public static function nvgCreateImageMem(ctx: NVGcontext, imageFlags: Int, data: Array<Int>, ndata: Int): Int {
		var w: Int = 0;
		var h: Int = 0;
		var n: Int;
		var image: Int;
		var img: Array<Int> = null; //**stbi_load_from_memory(data, ndata, new Ref<Int>(w), new Ref<Int>(h), new Ref<Int>(n), 4);
		if (img == null) {
			//		printf("Failed to load %s - %s\n", filename, stbi_failure_reason());
			return 0;
		}
		image = nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
		// stbi_image_free(img);
		return image;
	}

	public static function nvgCreateImageRGBA(ctx: NVGcontext, w: Int, h: Int, imageFlags: Int, data: Array<Int>): Int {
		return ctx.params.renderCreateTexture(ctx.params.userPtr, NVGtexture.NVG_TEXTURE_RGBA, w, h, imageFlags, data);
	}

	public static function nvgUpdateImage(ctx: NVGcontext, image: Int, data: Array<Int>): Void {
		var w: Int = 0;
		var h: Int = 0;
		ctx.params.renderGetTextureSize(ctx.params.userPtr, image, new Ref<Int>(w), new Ref<Int>(h));
		ctx.params.renderUpdateTexture(ctx.params.userPtr, image, 0, 0, w, h, data);
	}

	public static function nvgImageSize(ctx: NVGcontext, image: Int, w: Ref<Int>, h: Ref<Int>): Void {
		ctx.params.renderGetTextureSize(ctx.params.userPtr, image, w, h);
	}

	public static function nvgDeleteImage(ctx: NVGcontext, image: Int): Void {
		ctx.params.renderDeleteTexture(ctx.params.userPtr, image);
	}

	public static function nvgLinearGradient(ctx: NVGcontext, sx: Float, sy: Float, ex: Float, ey: Float, icol: NVGcolor, ocol: NVGcolor): NVGpaint {
		var p: NVGpaint = new NVGpaint();
		var dx: Float;
		var dy: Float;
		var d: Float;
		final large: Float = 1e5;
		// NVG_NOTUSED(ctx);
		p.nullify();

		// Calculate transform aligned to the line
		dx = ex - sx;
		dy = ey - sy;
		d = nvg__sqrtf(dx * dx + dy * dy);
		if (d > 0.0001) {
			dx /= d;
			dy /= d;
		}
		else {
			dx = 0;
			dy = 1;
		}

		p.xform[0] = dy;
		p.xform[1] = -dx;
		p.xform[2] = dx;
		p.xform[3] = dy;
		p.xform[4] = sx - dx * large;
		p.xform[5] = sy - dy * large;

		p.extent[0] = large;
		p.extent[1] = large + d * 0.5;

		p.radius = 0.0;

		p.feather = nvg__maxf(1.0, d);

		p.innerColor = icol;
		p.outerColor = ocol;

		return p;
	}

	public static function nvgRadialGradient(ctx: NVGcontext, cx: Float, cy: Float, inr: Float, outr: Float, icol: NVGcolor, ocol: NVGcolor): NVGpaint {
		var p: NVGpaint = new NVGpaint();
		var r: Float = (inr + outr) * 0.5;
		var f: Float = (outr - inr);
		// NVG_NOTUSED(ctx);
		p.nullify();

		nvgTransformIdentity(p.xform);
		p.xform[4] = cx;
		p.xform[5] = cy;

		p.extent[0] = r;
		p.extent[1] = r;

		p.radius = r;

		p.feather = nvg__maxf(1.0, f);

		p.innerColor = icol;
		p.outerColor = ocol;

		return p;
	}

	public static function nvgBoxGradient(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float, r: Float, f: Float, icol: NVGcolor,
			ocol: NVGcolor): NVGpaint {
		var p: NVGpaint = new NVGpaint();
		// NVG_NOTUSED(ctx);
		p.nullify();

		nvgTransformIdentity(p.xform);
		p.xform[4] = x + w * 0.5;
		p.xform[5] = y + h * 0.5;

		p.extent[0] = w * 0.5;
		p.extent[1] = h * 0.5;

		p.radius = r;

		p.feather = nvg__maxf(1.0, f);

		p.innerColor = icol;
		p.outerColor = ocol;

		return p;
	}

	public static function nvgImagePattern(ctx: NVGcontext, cx: Float, cy: Float, w: Float, h: Float, angle: Float, image: Int, alpha: Float): NVGpaint {
		var p: NVGpaint = new NVGpaint();
		// NVG_NOTUSED(ctx);
		p.nullify();

		nvgTransformRotate(p.xform, angle);
		p.xform[4] = cx;
		p.xform[5] = cy;

		p.extent[0] = w;
		p.extent[1] = h;

		p.image = image;

		p.innerColor = p.outerColor = nvgRGBAf(1, 1, 1, alpha);

		return p;
	}

	// Scissoring
	public static function nvgScissor(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float): Void {
		var state: NVGstate = nvg__getState(ctx);

		w = nvg__maxf(0.0, w);
		h = nvg__maxf(0.0, h);

		nvgTransformIdentity(state.scissor.xform);
		state.scissor.xform[4] = x + w * 0.5;
		state.scissor.xform[5] = y + h * 0.5;
		nvgTransformMultiply(state.scissor.xform, state.xform);

		state.scissor.extent[0] = w * 0.5;
		state.scissor.extent[1] = h * 0.5;
	}

	static function nvg__isectRects(dst: Vector<Float>, ax: Float, ay: Float, aw: Float, ah: Float, bx: Float, by: Float, bw: Float, bh: Float): Void {
		var minx: Float = nvg__maxf(ax, bx);
		var miny: Float = nvg__maxf(ay, by);
		var maxx: Float = nvg__minf(ax + aw, bx + bw);
		var maxy: Float = nvg__minf(ay + ah, by + bh);
		dst[0] = minx;
		dst[1] = miny;
		dst[2] = nvg__maxf(0.0, maxx - minx);
		dst[3] = nvg__maxf(0.0, maxy - miny);
	}

	public static function nvgIntersectScissor(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		var pxform = new Vector<Float>(6);
		var invxorm = new Vector<Float>(6);
		var rect = new Vector<Float>(4);
		var ex: Float;
		var ey: Float;
		var tex: Float;
		var tey: Float;

		// If no previous scissor has been set, set the scissor as current scissor.
		if (state.scissor.extent[0] < 0) {
			nvgScissor(ctx, x, y, w, h);
			return;
		}

		// Transform the current scissor rect into current transform space.
		// If there is difference in rotation, this will be approximation.
		for (i in 0...state.scissor.xform.length) {
			pxform[i] = state.scissor.xform[i];
		}
		ex = state.scissor.extent[0];
		ey = state.scissor.extent[1];
		nvgTransformInverse(invxorm, state.xform);
		nvgTransformMultiply(pxform, invxorm);
		tex = ex * nvg__absf(pxform[0]) + ey * nvg__absf(pxform[2]);
		tey = ex * nvg__absf(pxform[1]) + ey * nvg__absf(pxform[3]);

		// Intersect rects.
		nvg__isectRects(rect, pxform[4] - tex, pxform[5] - tey, tex * 2, tey * 2, x, y, w, h);

		nvgScissor(ctx, rect[0], rect[1], rect[2], rect[3]);
	}

	public static function nvgResetScissor(ctx: NVGcontext): Void {
		var state: NVGstate = nvg__getState(ctx);
		for (i in 0...state.scissor.xform.length) {
			state.scissor.xform[i] = 0;
		}
		state.scissor.extent[0] = -1.0;
		state.scissor.extent[1] = -1.0;
	}

	// Global composite operation.
	public static function nvgGlobalCompositeOperation(ctx: NVGcontext, op: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.compositeOperation = nvg__compositeOperationState(op);
	}

	public static function nvgGlobalCompositeBlendFunc(ctx: NVGcontext, sfactor: Int, dfactor: Int): Void {
		nvgGlobalCompositeBlendFuncSeparate(ctx, sfactor, dfactor, sfactor, dfactor);
	}

	public static function nvgGlobalCompositeBlendFuncSeparate(ctx: NVGcontext, srcRGB: Int, dstRGB: Int, srcAlpha: Int, dstAlpha: Int): Void {
		var op: NVGcompositeOperationState = new NVGcompositeOperationState();
		op.srcRGB = srcRGB;
		op.dstRGB = dstRGB;
		op.srcAlpha = srcAlpha;
		op.dstAlpha = dstAlpha;

		var state: NVGstate = nvg__getState(ctx);
		state.compositeOperation = op;
	}

	static function nvg__ptEquals(x1: Float, y1: Float, x2: Float, y2: Float, tol: Float): Bool {
		var dx: Float = x2 - x1;
		var dy: Float = y2 - y1;
		return dx * dx + dy * dy < tol * tol;
	}

	static function nvg__distPtSeg(x: Float, y: Float, px: Float, py: Float, qx: Float, qy: Float): Float {
		var pqx: Float;
		var pqy: Float;
		var dx: Float;
		var dy: Float;
		var d: Float;
		var t: Float;
		pqx = qx - px;
		pqy = qy - py;
		dx = x - px;
		dy = y - py;
		d = pqx * pqx + pqy * pqy;
		t = pqx * dx + pqy * dy;
		if (d > 0)
			t /= d;
		if (t < 0)
			t = 0;
		else if (t > 1)
			t = 1;
		dx = px + t * pqx - x;
		dy = py + t * pqy - y;
		return dx * dx + dy * dy;
	}

	static function nvg__appendCommands(ctx: NVGcontext, vals: Vector<Float>, nvals: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		var i: Int;

		if (ctx.ncommands + nvals > ctx.ccommands) {
			var commands: Vector<Float>;
			var ccommands: Int = ctx.ncommands + nvals + Std.int(ctx.ccommands / 2);
			commands = new Vector<Float>(ccommands);
			if (commands == null)
				return;
			ctx.commands = new Pointer<Float>(commands);
			ctx.ccommands = ccommands;
		}

		if (Std.int(vals[0]) != NVG_CLOSE && Std.int(vals[0]) != NVG_WINDING) {
			ctx.commandx = vals[nvals - 2];
			ctx.commandy = vals[nvals - 1];
		}

		// transform commands
		i = 0;
		while (i < nvals) {
			var cmd: Int = Std.int(vals[i]);
			switch (cmd) {
				case NVG_MOVETO:
					nvgTransformPoint(new Ref<Float>(vals[i + 1]), new Ref<Float>(vals[i + 2]), state.xform, vals[i + 1], vals[i + 2]);
					i += 3;
				case NVG_LINETO:
					nvgTransformPoint(new Ref<Float>(vals[i + 1]), new Ref<Float>(vals[i + 2]), state.xform, vals[i + 1], vals[i + 2]);
					i += 3;
				case NVG_BEZIERTO:
					nvgTransformPoint(new Ref<Float>(vals[i + 1]), new Ref<Float>(vals[i + 2]), state.xform, vals[i + 1], vals[i + 2]);
					nvgTransformPoint(new Ref<Float>(vals[i + 3]), new Ref<Float>(vals[i + 4]), state.xform, vals[i + 3], vals[i + 4]);
					nvgTransformPoint(new Ref<Float>(vals[i + 5]), new Ref<Float>(vals[i + 6]), state.xform, vals[i + 5], vals[i + 6]);
					i += 7;
				case NVG_CLOSE:
					i++;
				case NVG_WINDING:
					i += 2;
				default:
					i++;
			}
		}

		for (i in 0...nvals) {
			ctx.commands.setValue(ctx.ncommands + i, vals[i]);
		}

		ctx.ncommands += nvals;
	}

	static function nvg__clearPathCache(ctx: NVGcontext): Void {
		ctx.cache.npoints = 0;
		ctx.cache.npaths = 0;
	}

	static function nvg__lastPath(ctx: NVGcontext): NVGpath {
		if (ctx.cache.npaths > 0)
			return ctx.cache.paths[ctx.cache.npaths - 1];
		return null;
	}

	static function nvg__addPath(ctx: NVGcontext): Void {
		var path: NVGpath;
		if (ctx.cache.npaths + 1 > ctx.cache.cpaths) {
			var paths: Vector<NVGpath>;
			var cpaths: Int = ctx.cache.npaths + 1 + Std.int(ctx.cache.cpaths / 2);
			paths = new Vector<NVGpath>(cpaths);
			if (paths == null)
				return;
			for (i in 0...paths.length) {
				paths[i] = new NVGpath();
			}
			ctx.cache.paths = paths;
			ctx.cache.cpaths = cpaths;
		}
		path = ctx.cache.paths[ctx.cache.npaths];
		path.nullify();
		path.first = ctx.cache.npoints;
		path.winding = NVG_CCW;

		ctx.cache.npaths++;
	}

	static function nvg__lastPoint(ctx: NVGcontext): NVGpoint {
		if (ctx.cache.npoints > 0)
			return ctx.cache.points.value(ctx.cache.npoints - 1);
		return null;
	}

	static function nvg__addPoint(ctx: NVGcontext, x: Float, y: Float, flags: Int): Void {
		var path: NVGpath = nvg__lastPath(ctx);
		var pt: NVGpoint;
		if (path == null)
			return;

		if (path.count > 0 && ctx.cache.npoints > 0) {
			pt = nvg__lastPoint(ctx);
			if (nvg__ptEquals(pt.x, pt.y, x, y, ctx.distTol)) {
				pt.flags |= flags;
				return;
			}
		}

		if (ctx.cache.npoints + 1 > ctx.cache.cpoints) {
			var points: Vector<NVGpoint>;
			var cpoints: Int = ctx.cache.npoints + 1 + Std.int(ctx.cache.cpoints / 2);
			points = new Vector<NVGpoint>(cpoints);
			if (points == null)
				return;
			for (i in 0...points.length) {
				points[i] = new NVGpoint();
			}
			ctx.cache.points = new Pointer<NVGpoint>(points);
			ctx.cache.cpoints = cpoints;
		}

		pt = ctx.cache.points.value(ctx.cache.npoints);
		pt.nullify();
		pt.x = x;
		pt.y = y;
		pt.flags = flags;

		ctx.cache.npoints++;
		path.count++;
	}

	static function nvg__closePath(ctx: NVGcontext): Void {
		var path: NVGpath = nvg__lastPath(ctx);
		if (path == null)
			return;
		path.closed = 1;
	}

	static function nvg__pathWinding(ctx: NVGcontext, winding: Int): Void {
		var path: NVGpath = nvg__lastPath(ctx);
		if (path == null)
			return;
		path.winding = winding;
	}

	static function nvg__getAverageScale(t: Vector<Float>): Float {
		var sx: Float = nvg__sqrtf(t[0] * t[0] + t[2] * t[2]);
		var sy: Float = nvg__sqrtf(t[1] * t[1] + t[3] * t[3]);
		return (sx + sy) * 0.5;
	}

	static function nvg__allocTempVerts(ctx: NVGcontext, nverts: Int): Pointer<NVGvertex> {
		if (nverts > ctx.cache.cverts) {
			var verts: Vector<NVGvertex>;
			var cverts: Int = (nverts + 0xff) & ~0xff; // Round up to prevent allocations when things change just slightly.
			verts = new Vector<NVGvertex>(cverts);
			if (verts == null)
				return null;
			for (i in 0...verts.length) {
				verts[i] = new NVGvertex();
			}
			ctx.cache.verts = new Pointer<NVGvertex>(verts);
			ctx.cache.cverts = cverts;
		}

		return ctx.cache.verts;
	}

	static function nvg__triarea2(ax: Float, ay: Float, bx: Float, by: Float, cx: Float, cy: Float): Float {
		var abx: Float = bx - ax;
		var aby: Float = by - ay;
		var acx: Float = cx - ax;
		var acy: Float = cy - ay;
		return acx * aby - abx * acy;
	}

	static function nvg__polyArea(pts: Pointer<NVGpoint>, npts: Int): Float {
		// int i;
		var area: Float = 0;
		for (i in 2...npts) {
			var a: NVGpoint = pts.value(0);
			var b: NVGpoint = pts.value(i - 1);
			var c: NVGpoint = pts.value(i);
			area += nvg__triarea2(a.x, a.y, b.x, b.y, c.x, c.y);
		}
		return area * 0.5;
	}

	static function nvg__polyReverse(pts: Pointer<NVGpoint>, npts: Int): Void {
		var tmp: NVGpoint;
		var i: Int = 0;
		var j: Int = npts - 1;
		while (i < j) {
			tmp = pts.value(i);
			pts.setValue(i, pts.value(j));
			pts.setValue(j, tmp);
			i++;
			j--;
		}
	}

	static function nvg__vset(vtx: NVGvertex, x: Float, y: Float, u: Float, v: Float): Void {
		vtx.x = x;
		vtx.y = y;
		vtx.u = u;
		vtx.v = v;
	}

	static function nvg__tesselateBezier(ctx: NVGcontext, x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float, level: Int,
			type: Int) {
		var x12: Float;
		var y12: Float;
		var x23: Float;
		var y23: Float;
		var x34: Float;
		var y34: Float;
		var x123: Float;
		var y123: Float;
		var x234: Float;
		var y234: Float;
		var x1234: Float;
		var y1234: Float;
		var dx: Float;
		var dy: Float;
		var d2: Float;
		var d3: Float;

		if (level > 10)
			return;

		x12 = (x1 + x2) * 0.5;
		y12 = (y1 + y2) * 0.5;
		x23 = (x2 + x3) * 0.5;
		y23 = (y2 + y3) * 0.5;
		x34 = (x3 + x4) * 0.5;
		y34 = (y3 + y4) * 0.5;
		x123 = (x12 + x23) * 0.5;
		y123 = (y12 + y23) * 0.5;

		dx = x4 - x1;
		dy = y4 - y1;
		d2 = nvg__absf(((x2 - x4) * dy - (y2 - y4) * dx));
		d3 = nvg__absf(((x3 - x4) * dy - (y3 - y4) * dx));

		if ((d2 + d3) * (d2 + d3) < ctx.tessTol * (dx * dx + dy * dy)) {
			nvg__addPoint(ctx, x4, y4, type);
			return;
		}

		/*	if (nvg__absf(x1+x3-x2-x2) + nvg__absf(y1+y3-y2-y2) + nvg__absf(x2+x4-x3-x3) + nvg__absf(y2+y4-y3-y3) < ctx->tessTol) {
			nvg__addPoint(ctx, x4, y4, type);
			return;
		}*/

		x234 = (x23 + x34) * 0.5;
		y234 = (y23 + y34) * 0.5;
		x1234 = (x123 + x234) * 0.5;
		y1234 = (y123 + y234) * 0.5;

		nvg__tesselateBezier(ctx, x1, y1, x12, y12, x123, y123, x1234, y1234, level + 1, 0);
		nvg__tesselateBezier(ctx, x1234, y1234, x234, y234, x34, y34, x4, y4, level + 1, type);
	}

	static function nvg__flattenPaths(ctx: NVGcontext): Void {
		var cache: NVGpathCache = ctx.cache;
		//	NVGstate* state = nvg__getState(ctx);
		var last: NVGpoint;
		var p0: Pointer<NVGpoint>;
		var p1: Pointer<NVGpoint>;
		var pts: Pointer<NVGpoint>;
		var path: NVGpath;
		var i: Int;
		var j: Int;
		var cp1: Pointer<Float>;
		var cp2: Pointer<Float>;
		var p: Pointer<Float>;
		var area: Float;

		if (cache.npaths > 0)
			return;

		// Flatten
		i = 0;
		while (i < ctx.ncommands) {
			var cmd: Int = Std.int(ctx.commands.value(i));
			switch (cmd) {
				case NVG_MOVETO:
					nvg__addPath(ctx);
					p = ctx.commands.pointer(i + 1);
					nvg__addPoint(ctx, p.value(0), p.value(1), NVG_PT_CORNER);
					i += 3;
				case NVG_LINETO:
					p = ctx.commands.pointer(i + 1);
					nvg__addPoint(ctx, p.value(0), p.value(1), NVG_PT_CORNER);
					i += 3;
				case NVG_BEZIERTO:
					last = nvg__lastPoint(ctx);
					if (last != null) {
						cp1 = ctx.commands.pointer(i + 1);
						cp2 = ctx.commands.pointer(i + 3);
						p = ctx.commands.pointer(i + 5);
						nvg__tesselateBezier(ctx, last.x, last.y, cp1.value(0), cp1.value(1), cp2.value(0), cp2.value(1), p.value(0), p.value(1), 0,
							NVG_PT_CORNER);
					}
					i += 7;
				case NVG_CLOSE:
					nvg__closePath(ctx);
					i++;
				case NVG_WINDING:
					nvg__pathWinding(ctx, Std.int(ctx.commands.value(i + 1)));
					i += 2;
				default:
					i++;
			}
		}

		cache.bounds[0] = cache.bounds[1] = 1e6;
		cache.bounds[2] = cache.bounds[3] = -1e6;

		// Calculate the direction and length of line segments.
		for (j in 0...cache.npaths) {
			path = cache.paths[j];
			pts = cache.points.pointer(path.first);

			// If the first and last points are the same, remove the last, mark as closed path.
			p0 = pts.pointer(path.count - 1);
			p1 = pts.pointer(0);
			if (nvg__ptEquals(p0.value().x, p0.value().y, p1.value().x, p1.value().y, ctx.distTol)) {
				path.count--;
				p0 = pts.pointer(path.count - 1);
				path.closed = 1;
			}

			// Enforce winding.
			if (path.count > 2) {
				area = nvg__polyArea(pts, path.count);
				if (path.winding == NVG_CCW && area < 0.0)
					nvg__polyReverse(pts, path.count);
				if (path.winding == NVG_CW && area > 0.0)
					nvg__polyReverse(pts, path.count);
			}

			for (i in 0...path.count) {
				// Calculate segment direction and length
				p0.value().dx = p1.value().x - p0.value().x;
				p0.value().dy = p1.value().y - p0.value().y;
				p0.value().len = nvg__normalize(new Ref<Float>(p0.value().dx), new Ref<Float>(p0.value().dy));
				// Update bounds
				cache.bounds[0] = nvg__minf(cache.bounds[0], p0.value().x);
				cache.bounds[1] = nvg__minf(cache.bounds[1], p0.value().y);
				cache.bounds[2] = nvg__maxf(cache.bounds[2], p0.value().x);
				cache.bounds[3] = nvg__maxf(cache.bounds[3], p0.value().y);
				// Advance
				p0 = p1.pointer(0);
				p1.inc();
			}
		}
	}

	static function nvg__curveDivs(r: Float, arc: Float, tol: Float): Int {
		var da: Float = nvg__acosf(r / (r + tol)) * 2.0;
		return nvg__maxi(2, Std.int(nvg__ceilf(arc / da)));
	}

	static function nvg__chooseBevel(bevel: Int, p0: NVGpoint, p1: NVGpoint, w: Float, x0: Ref<Float>, y0: Ref<Float>, x1: Ref<Float>, y1: Ref<Float>) {
		if (bevel != 0) {
			x0.value = p1.x + p0.dy * w;
			y0.value = p1.y - p0.dx * w;
			x1.value = p1.x + p1.dy * w;
			y1.value = p1.y - p1.dx * w;
		}
		else {
			x0.value = p1.x + p1.dmx * w;
			y0.value = p1.y + p1.dmy * w;
			x1.value = p1.x + p1.dmx * w;
			y1.value = p1.y + p1.dmy * w;
		}
	}

	static function nvg__roundJoin(dst_: Pointer<NVGvertex>, p0: NVGpoint, p1: NVGpoint, lw: Float, rw: Float, lu: Float, ru: Float, ncap: Int,
			fringe: Float): Pointer<NVGvertex> {
		var dst = dst_.pointer(0);
		var i: Int;
		var n: Int;
		var dlx0: Float = p0.dy;
		var dly0: Float = -p0.dx;
		var dlx1: Float = p1.dy;
		var dly1: Float = -p1.dx;
		// NVG_NOTUSED(fringe);

		if ((p1.flags & NVG_PT_LEFT) != 0) {
			var lx0: Float = 0;
			var ly0: Float = 0;
			var lx1: Float = 0;
			var ly1: Float = 0;
			var a0: Float;
			var a1: Float;
			nvg__chooseBevel(p1.flags & NVG_PR_INNERBEVEL, p0, p1, lw, new Ref<Float>(lx0), new Ref<Float>(ly0), new Ref<Float>(lx1), new Ref<Float>(ly1));
			a0 = nvg__atan2f(-dly0, -dlx0);
			a1 = nvg__atan2f(-dly1, -dlx1);
			if (a1 > a0)
				a1 -= NVG_PI * 2;

			nvg__vset(dst.value(), lx0, ly0, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), p1.x - dlx0 * rw, p1.y - dly0 * rw, ru, 1);
			dst.inc();

			n = nvg__clampi(Std.int(nvg__ceilf(((a0 - a1) / NVG_PI) * ncap)), 2, ncap);
			for (i in 0...n) {
				var u: Float = i / (n - 1);
				var a: Float = a0 + u * (a1 - a0);
				var rx: Float = p1.x + nvg__cosf(a) * rw;
				var ry: Float = p1.y + nvg__sinf(a) * rw;
				nvg__vset(dst.value(), p1.x, p1.y, 0.5, 1);
				dst.inc();
				nvg__vset(dst.value(), rx, ry, ru, 1);
				dst.inc();
			}

			nvg__vset(dst.value(), lx1, ly1, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), p1.x - dlx1 * rw, p1.y - dly1 * rw, ru, 1);
			dst.inc();
		}
		else {
			var rx0: Float = 0;
			var ry0: Float = 0;
			var rx1: Float = 0;
			var ry1: Float = 0;
			var a0: Float;
			var a1: Float;
			nvg__chooseBevel(p1.flags & NVG_PR_INNERBEVEL, p0, p1, -rw, new Ref<Float>(rx0), new Ref<Float>(ry0), new Ref<Float>(rx1), new Ref<Float>(ry1));
			a0 = nvg__atan2f(dly0, dlx0);
			a1 = nvg__atan2f(dly1, dlx1);
			if (a1 < a0)
				a1 += NVG_PI * 2;

			nvg__vset(dst.value(), p1.x + dlx0 * rw, p1.y + dly0 * rw, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), rx0, ry0, ru, 1);
			dst.inc();

			n = nvg__clampi(Std.int(nvg__ceilf(((a1 - a0) / NVG_PI) * ncap)), 2, ncap);
			for (i in 0...n) {
				var u: Float = i / (n - 1);
				var a: Float = a0 + u * (a1 - a0);
				var lx: Float = p1.x + nvg__cosf(a) * lw;
				var ly: Float = p1.y + nvg__sinf(a) * lw;
				nvg__vset(dst.value(), lx, ly, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), p1.x, p1.y, 0.5, 1);
				dst.inc();
			}

			nvg__vset(dst.value(), p1.x + dlx1 * rw, p1.y + dly1 * rw, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), rx1, ry1, ru, 1);
			dst.inc();
		}
		return dst;
	}

	static function nvg__bevelJoin(dst: Pointer<NVGvertex>, p0: NVGpoint, p1: NVGpoint, lw: Float, rw: Float, lu: Float, ru: Float,
			fringe: Float): Pointer<NVGvertex> {
		var rx0: Float = 0;
		var ry0: Float = 0;
		var rx1: Float = 0;
		var ry1: Float = 0;
		var lx0: Float = 0;
		var ly0: Float = 0;
		var lx1: Float = 0;
		var ly1: Float = 0;
		var dlx0: Float = p0.dy;
		var dly0: Float = -p0.dx;
		var dlx1: Float = p1.dy;
		var dly1: Float = -p1.dx;
		// NVG_NOTUSED(fringe);

		if ((p1.flags & NVG_PT_LEFT) != 0) {
			nvg__chooseBevel(p1.flags & NVG_PR_INNERBEVEL, p0, p1, lw, new Ref<Float>(lx0), new Ref<Float>(ly0), new Ref<Float>(lx1), new Ref<Float>(ly1));

			nvg__vset(dst.value(), lx0, ly0, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), p1.x - dlx0 * rw, p1.y - dly0 * rw, ru, 1);
			dst.inc();

			if ((p1.flags & NVG_PT_BEVEL) != 0) {
				nvg__vset(dst.value(), lx0, ly0, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), p1.x - dlx0 * rw, p1.y - dly0 * rw, ru, 1);
				dst.inc();

				nvg__vset(dst.value(), lx1, ly1, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), p1.x - dlx1 * rw, p1.y - dly1 * rw, ru, 1);
				dst.inc();
			}
			else {
				rx0 = p1.x - p1.dmx * rw;
				ry0 = p1.y - p1.dmy * rw;

				nvg__vset(dst.value(), p1.x, p1.y, 0.5, 1);
				dst.inc();
				nvg__vset(dst.value(), p1.x - dlx0 * rw, p1.y - dly0 * rw, ru, 1);
				dst.inc();

				nvg__vset(dst.value(), rx0, ry0, ru, 1);
				dst.inc();
				nvg__vset(dst.value(), rx0, ry0, ru, 1);
				dst.inc();

				nvg__vset(dst.value(), p1.x, p1.y, 0.5, 1);
				dst.inc();
				nvg__vset(dst.value(), p1.x - dlx1 * rw, p1.y - dly1 * rw, ru, 1);
				dst.inc();
			}

			nvg__vset(dst.value(), lx1, ly1, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), p1.x - dlx1 * rw, p1.y - dly1 * rw, ru, 1);
			dst.inc();
		}
		else {
			nvg__chooseBevel(p1.flags & NVG_PR_INNERBEVEL, p0, p1, -rw, new Ref<Float>(rx0), new Ref<Float>(ry0), new Ref<Float>(rx1), new Ref<Float>(ry1));

			nvg__vset(dst.value(), p1.x + dlx0 * lw, p1.y + dly0 * lw, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), rx0, ry0, ru, 1);
			dst.inc();

			if ((p1.flags & NVG_PT_BEVEL) != 0) {
				nvg__vset(dst.value(), p1.x + dlx0 * lw, p1.y + dly0 * lw, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), rx0, ry0, ru, 1);
				dst.inc();

				nvg__vset(dst.value(), p1.x + dlx1 * lw, p1.y + dly1 * lw, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), rx1, ry1, ru, 1);
				dst.inc();
			}
			else {
				lx0 = p1.x + p1.dmx * lw;
				ly0 = p1.y + p1.dmy * lw;

				nvg__vset(dst.value(), p1.x + dlx0 * lw, p1.y + dly0 * lw, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), p1.x, p1.y, 0.5, 1);
				dst.inc();

				nvg__vset(dst.value(), lx0, ly0, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), lx0, ly0, lu, 1);
				dst.inc();

				nvg__vset(dst.value(), p1.x + dlx1 * lw, p1.y + dly1 * lw, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), p1.x, p1.y, 0.5, 1);
				dst.inc();
			}

			nvg__vset(dst.value(), p1.x + dlx1 * lw, p1.y + dly1 * lw, lu, 1);
			dst.inc();
			nvg__vset(dst.value(), rx1, ry1, ru, 1);
			dst.inc();
		}

		return dst;
	}

	static function nvg__buttCapStart(dst_: Pointer<NVGvertex>, p: NVGpoint, dx: Float, dy: Float, w: Float, d: Float, aa: Float, u0: Float,
			u1: Float): Pointer<NVGvertex> {
		var dst = dst_.pointer(0);
		var px: Float = p.x - dx * d;
		var py: Float = p.y - dy * d;
		var dlx: Float = dy;
		var dly: Float = -dx;
		nvg__vset(dst.value(), px + dlx * w - dx * aa, py + dly * w - dy * aa, u0, 0);
		dst.inc();
		nvg__vset(dst.value(), px - dlx * w - dx * aa, py - dly * w - dy * aa, u1, 0);
		dst.inc();
		nvg__vset(dst.value(), px + dlx * w, py + dly * w, u0, 1);
		dst.inc();
		nvg__vset(dst.value(), px - dlx * w, py - dly * w, u1, 1);
		dst.inc();
		return dst;
	}

	static function nvg__buttCapEnd(dst_: Pointer<NVGvertex>, p: NVGpoint, dx: Float, dy: Float, w: Float, d: Float, aa: Float, u0: Float,
			u1: Float): Pointer<NVGvertex> {
		var dst = dst_.pointer(0);
		var px: Float = p.x + dx * d;
		var py: Float = p.y + dy * d;
		var dlx: Float = dy;
		var dly: Float = -dx;
		nvg__vset(dst.value(), px + dlx * w, py + dly * w, u0, 1);
		dst.inc();
		nvg__vset(dst.value(), px - dlx * w, py - dly * w, u1, 1);
		dst.inc();
		nvg__vset(dst.value(), px + dlx * w + dx * aa, py + dly * w + dy * aa, u0, 0);
		dst.inc();
		nvg__vset(dst.value(), px - dlx * w + dx * aa, py - dly * w + dy * aa, u1, 0);
		dst.inc();
		return dst;
	}

	static function nvg__roundCapStart(dst_: Pointer<NVGvertex>, p: NVGpoint, dx: Float, dy: Float, w: Float, ncap: Int, aa: Float, u0: Float,
			u1: Float): Pointer<NVGvertex> {
		var dst = dst_.pointer(0);
		// int i;
		var px: Float = p.x;
		var py: Float = p.y;
		var dlx: Float = dy;
		var dly: Float = -dx;
		// NVG_NOTUSED(aa);
		for (i in 0...ncap) {
			var a: Float = i / (ncap - 1) * NVG_PI;
			var ax: Float = nvg__cosf(a) * w, ay = nvg__sinf(a) * w;
			nvg__vset(dst.value(), px - dlx * ax - dx * ay, py - dly * ax - dy * ay, u0, 1);
			dst.inc();
			nvg__vset(dst.value(), px, py, 0.5, 1);
			dst.inc();
		}
		nvg__vset(dst.value(), px + dlx * w, py + dly * w, u0, 1);
		dst.inc();
		nvg__vset(dst.value(), px - dlx * w, py - dly * w, u1, 1);
		dst.inc();
		return dst;
	}

	static function nvg__roundCapEnd(dst_: Pointer<NVGvertex>, p: NVGpoint, dx: Float, dy: Float, w: Float, ncap: Int, aa: Float, u0: Float,
			u1: Float): Pointer<NVGvertex> {
		var dst = dst_.pointer(0);
		// int i;
		var px: Float = p.x;
		var py: Float = p.y;
		var dlx: Float = dy;
		var dly: Float = -dx;
		// NVG_NOTUSED(aa);
		nvg__vset(dst.value(), px + dlx * w, py + dly * w, u0, 1);
		dst.inc();
		nvg__vset(dst.value(), px - dlx * w, py - dly * w, u1, 1);
		dst.inc();
		for (i in 0...ncap) {
			var a: Float = i / (ncap - 1) * NVG_PI;
			var ax: Float = nvg__cosf(a) * w, ay = nvg__sinf(a) * w;
			nvg__vset(dst.value(), px, py, 0.5, 1);
			dst.inc();
			nvg__vset(dst.value(), px - dlx * ax + dx * ay, py - dly * ax + dy * ay, u0, 1);
			dst.inc();
		}
		return dst;
	}

	static function nvg__calculateJoins(ctx: NVGcontext, w: Float, lineJoin: Int, miterLimit: Float): Void {
		var cache: NVGpathCache = ctx.cache;
		// var j: Int;
		var iw: Float = 0.0;

		if (w > 0.0)
			iw = 1.0 / w;

		// Calculate which joins needs extra vertices to append, and gather vertex count.
		for (i in 0...cache.npaths) {
			var path: NVGpath = cache.paths[i];
			var pts: Pointer<NVGpoint> = cache.points.pointer(path.first);
			var p0: Pointer<NVGpoint> = pts.pointer(path.count - 1);
			var p1: Pointer<NVGpoint> = pts.pointer(0);
			var nleft: Int = 0;

			path.nbevel = 0;

			for (j in 0...path.count) {
				var dlx0: Float;
				var dly0: Float;
				var dlx1: Float;
				var dly1: Float;
				var dmr2: Float;
				var cross: Float;
				var limit: Float;
				dlx0 = p0.value().dy;
				dly0 = -p0.value().dx;
				dlx1 = p1.value().dy;
				dly1 = -p1.value().dx;
				// Calculate extrusions
				p1.value().dmx = (dlx0 + dlx1) * 0.5;
				p1.value().dmy = (dly0 + dly1) * 0.5;
				dmr2 = p1.value().dmx * p1.value().dmx + p1.value().dmy * p1.value().dmy;
				if (dmr2 > 0.000001) {
					var scale: Float = 1.0 / dmr2;
					if (scale > 600.0) {
						scale = 600.0;
					}
					p1.value().dmx *= scale;
					p1.value().dmy *= scale;
				}

				// Clear flags, but keep the corner.
				p1.value().flags = ((p1.value().flags & NVG_PT_CORNER) != 0) ? NVG_PT_CORNER : 0;

				// Keep track of left turns.
				cross = p1.value().dx * p0.value().dy - p0.value().dx * p1.value().dy;
				if (cross > 0.0) {
					nleft++;
					p1.value().flags |= NVG_PT_LEFT;
				}

				// Calculate if we should use bevel or miter for inner join.
				limit = nvg__maxf(1.01, nvg__minf(p0.value().len, p1.value().len) * iw);
				if ((dmr2 * limit * limit) < 1.0)
					p1.value().flags |= NVG_PR_INNERBEVEL;

				// Check to see if the corner needs to be beveled.
				if ((p1.value().flags & NVG_PT_CORNER) != 0) {
					if ((dmr2 * miterLimit * miterLimit) < 1.0 || lineJoin == NVG_BEVEL || lineJoin == NVG_ROUND) {
						p1.value().flags |= NVG_PT_BEVEL;
					}
				}

				if ((p1.value().flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0)
					path.nbevel++;

				p0 = p1.pointer(0);
				p1.inc();
			}

			path.convex = nleft == path.count;
		}
	}

	static function nvg__expandStroke(ctx: NVGcontext, w: Float, fringe: Float, lineCap: Int, lineJoin: Int, miterLimit: Float): Int {
		var cache: NVGpathCache = ctx.cache;
		var verts: Pointer<NVGvertex>;
		var dst: Pointer<NVGvertex>;
		var cverts: Int;
		var aa: Float = fringe; // ctx->fringeWidth;
		var u0: Float = 0.0;
		var u1: Float = 1.0;
		var ncap: Int = nvg__curveDivs(w, NVG_PI, ctx.tessTol); // Calculate divisions per half circle.

		w += aa * 0.5;

		// Disable the gradient used for antialiasing when antialiasing is not used.
		if (aa == 0.0) {
			u0 = 0.5;
			u1 = 0.5;
		}

		nvg__calculateJoins(ctx, w, lineJoin, miterLimit);

		// Calculate max vertex usage.
		cverts = 0;
		for (i in 0...cache.npaths) {
			var path: NVGpath = cache.paths[i];
			var loop: Int = (path.closed == 0) ? 0 : 1;
			if (lineJoin == NVG_ROUND)
				cverts += (path.count + path.nbevel * (ncap + 2) + 1) * 2; // plus one for loop
			else
				cverts += (path.count + path.nbevel * 5 + 1) * 2; // plus one for loop
			if (loop == 0) {
				// space for caps
				if (lineCap == NVG_ROUND) {
					cverts += (ncap * 2 + 2) * 2;
				}
				else {
					cverts += (3 + 3) * 2;
				}
			}
		}

		verts = nvg__allocTempVerts(ctx, cverts);
		if (verts == null)
			return 0;

		for (i in 0...cache.npaths) {
			var path: NVGpath = cache.paths[i];
			var pts: Pointer<NVGpoint> = cache.points.pointer(path.first);
			var p0: Pointer<NVGpoint>;
			var p1: Pointer<NVGpoint>;
			var s: Int;
			var e: Int;
			var loop: Bool;
			var dx: Float;
			var dy: Float;

			path.fill = null;
			path.nfill = 0;

			// Calculate fringe or stroke
			loop = path.closed != 0;
			dst = verts.pointer(0);
			path.stroke = dst.pointer(0);

			if (loop) {
				// Looping
				p0 = pts.pointer(path.count - 1);
				p1 = pts.pointer(0);
				s = 0;
				e = path.count;
			}
			else {
				// Add cap
				p0 = pts.pointer(0);
				p1 = pts.pointer(1);
				s = 1;
				e = path.count - 1;
			}

			if (!loop) {
				// Add cap
				dx = p1.value().x - p0.value().x;
				dy = p1.value().y - p0.value().y;
				nvg__normalize(new Ref<Float>(dx), new Ref<Float>(dy));
				if (lineCap == NVG_BUTT)
					dst = nvg__buttCapStart(dst, p0.value(), dx, dy, w, -aa * 0.5, aa, u0, u1);
				else if (lineCap == NVG_BUTT || lineCap == NVG_SQUARE)
					dst = nvg__buttCapStart(dst, p0.value(), dx, dy, w, w - aa, aa, u0, u1);
				else if (lineCap == NVG_ROUND)
					dst = nvg__roundCapStart(dst, p0.value(), dx, dy, w, ncap, aa, u0, u1);
			}

			for (j in s...e) {
				if ((p1.value().flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0) {
					if (lineJoin == NVG_ROUND) {
						dst = nvg__roundJoin(dst, p0.value(), p1.value(), w, w, u0, u1, ncap, aa);
					}
					else {
						dst = nvg__bevelJoin(dst, p0.value(), p1.value(), w, w, u0, u1, aa);
					}
				}
				else {
					nvg__vset(dst.value(), p1.value().x + (p1.value().dmx * w), p1.value().y + (p1.value().dmy * w), u0, 1);
					dst.inc();
					nvg__vset(dst.value(), p1.value().x - (p1.value().dmx * w), p1.value().y - (p1.value().dmy * w), u1, 1);
					dst.inc();
				}
				p0 = p1.pointer(0);
				p1.inc();
			}

			if (loop) {
				// Loop it
				nvg__vset(dst.value(), verts.value(0).x, verts.value(0).y, u0, 1);
				dst.inc();
				nvg__vset(dst.value(), verts.value(1).x, verts.value(1).y, u1, 1);
				dst.inc();
			}
			else {
				// Add cap
				dx = p1.value().x - p0.value().x;
				dy = p1.value().y - p0.value().y;
				nvg__normalize(new Ref<Float>(dx), new Ref<Float>(dy));
				if (lineCap == NVG_BUTT)
					dst = nvg__buttCapEnd(dst, p1.value(), dx, dy, w, -aa * 0.5, aa, u0, u1);
				else if (lineCap == NVG_BUTT || lineCap == NVG_SQUARE)
					dst = nvg__buttCapEnd(dst, p1.value(), dx, dy, w, w - aa, aa, u0, u1);
				else if (lineCap == NVG_ROUND)
					dst = nvg__roundCapEnd(dst, p1.value(), dx, dy, w, ncap, aa, u0, u1);
			}

			path.nstroke = dst.sub(verts);

			verts = dst;
		}

		return 1;
	}

	static function nvg__expandFill(ctx: NVGcontext, w: Float, lineJoin: Int, miterLimit: Float): Int {
		var cache: NVGpathCache = ctx.cache;
		var verts: Pointer<NVGvertex>;
		var dst: Pointer<NVGvertex>;
		var cverts: Int;
		var convex: Bool;
		var aa: Float = ctx.fringeWidth;
		var fringe: Bool = w > 0.0;

		nvg__calculateJoins(ctx, w, lineJoin, miterLimit);

		// Calculate max vertex usage.
		cverts = 0;
		for (i in 0...cache.npaths) {
			var path: NVGpath = cache.paths[i];
			cverts += path.count + path.nbevel + 1;
			if (fringe)
				cverts += (path.count + path.nbevel * 5 + 1) * 2; // plus one for loop
		}

		verts = nvg__allocTempVerts(ctx, cverts);
		if (verts == null)
			return 0;

		convex = cache.npaths == 1 && cache.paths[0].convex;

		for (i in 0...cache.npaths) {
			var path: NVGpath = cache.paths[i];
			var pts: Pointer<NVGpoint> = cache.points.pointer(path.first);
			var p0: Pointer<NVGpoint>;
			var p1: Pointer<NVGpoint>;
			var rw: Float;
			var lw: Float;
			var woff: Float;
			var ru: Float;
			var lu: Float;

			// Calculate shape vertices.
			woff = 0.5 * aa;
			dst = verts.pointer(0);
			path.fill = dst.pointer(0);

			if (fringe) {
				// Looping
				p0 = pts.pointer(path.count - 1);
				p1 = pts.pointer(0);
				for (j in 0...path.count) {
					if ((p1.value().flags & NVG_PT_BEVEL) != 0) {
						var dlx0: Float = p0.value().dy;
						var dly0: Float = -p0.value().dx;
						var dlx1: Float = p1.value().dy;
						var dly1: Float = -p1.value().dx;
						if ((p1.value().flags & NVG_PT_LEFT) != 0) {
							var lx: Float = p1.value().x + p1.value().dmx * woff;
							var ly: Float = p1.value().y + p1.value().dmy * woff;
							nvg__vset(dst.value(), lx, ly, 0.5, 1);
							dst.inc();
						}
						else {
							var lx0: Float = p1.value().x + dlx0 * woff;
							var ly0: Float = p1.value().y + dly0 * woff;
							var lx1: Float = p1.value().x + dlx1 * woff;
							var ly1: Float = p1.value().y + dly1 * woff;
							nvg__vset(dst.value(), lx0, ly0, 0.5, 1);
							dst.inc();
							nvg__vset(dst.value(), lx1, ly1, 0.5, 1);
							dst.inc();
						}
					}
					else {
						nvg__vset(dst.value(), p1.value().x + (p1.value().dmx * woff), p1.value().y + (p1.value().dmy * woff), 0.5, 1);
						dst.inc();
					}
					p0 = p1.pointer(0);
					p1.inc();
				}
			}
			else {
				for (j in 0...path.count) {
					nvg__vset(dst.value(), pts.value(j).x, pts.value(j).y, 0.5, 1);
					dst.inc();
				}
			}

			path.nfill = dst.sub(verts);
			verts = dst;

			// Calculate fringe
			if (fringe) {
				lw = w + woff;
				rw = w - woff;
				lu = 0;
				ru = 1;
				dst = verts.pointer(0);
				path.stroke = dst.pointer(0);

				// Create only half a fringe for convex shapes so that
				// the shape can be rendered without stenciling.
				if (convex) {
					lw = woff; // This should generate the same vertex as fill inset above.
					lu = 0.5; // Set outline fade at middle.
				}

				// Looping
				p0 = pts.pointer(path.count - 1);
				p1 = pts.pointer(0);

				for (j in 0...path.count) {
					if ((p1.value().flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0) {
						dst = nvg__bevelJoin(dst, p0.value(), p1.value(), lw, rw, lu, ru, ctx.fringeWidth);
					}
					else {
						nvg__vset(dst.value(), p1.value().x + (p1.value().dmx * lw), p1.value().y + (p1.value().dmy * lw), lu, 1);
						dst.inc();
						nvg__vset(dst.value(), p1.value().x - (p1.value().dmx * rw), p1.value().y - (p1.value().dmy * rw), ru, 1);
						dst.inc();
					}
					p0 = p1.pointer(0);
					p1.inc();
				}

				// Loop it
				nvg__vset(dst.value(), verts.value(0).x, verts.value(0).y, lu, 1);
				dst.inc();
				nvg__vset(dst.value(), verts.value(1).x, verts.value(1).y, ru, 1);
				dst.inc();

				path.nstroke = dst.sub(verts);
				verts = dst;
			}
			else {
				path.stroke = null;
				path.nstroke = 0;
			}
		}

		return 1;
	}

	// Draw
	public static function nvgBeginPath(ctx: NVGcontext): Void {
		ctx.ncommands = 0;
		nvg__clearPathCache(ctx);
	}

	public static function nvgMoveTo(ctx: NVGcontext, x: Float, y: Float): Void {
		var vals = new Vector<Float>(3);
		vals[0] = NVG_MOVETO;
		vals[1] = x;
		vals[2] = y;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgLineTo(ctx: NVGcontext, x: Float, y: Float): Void {
		var vals = new Vector<Float>(3);
		vals[0] = NVG_LINETO;
		vals[1] = x;
		vals[2] = y;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgBezierTo(ctx: NVGcontext, c1x: Float, c1y: Float, c2x: Float, c2y: Float, x: Float, y: Float): Void {
		var vals = new Vector<Float>(7);
		vals[0] = NVG_BEZIERTO;
		vals[1] = c1x;
		vals[2] = c1y;
		vals[3] = c2x;
		vals[4] = c2y;
		vals[5] = x;
		vals[6] = y;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgQuadTo(ctx: NVGcontext, cx: Float, cy: Float, x: Float, y: Float): Void {
		var x0: Float = ctx.commandx;
		var y0: Float = ctx.commandy;
		var vals = new Vector<Float>(7);
		vals[0] = NVG_BEZIERTO;
		vals[1] = x0 + 2.0 / 3.0 * (cx - x0);
		vals[2] = y0 + 2.0 / 3.0 * (cy - y0);
		vals[3] = x + 2.0 / 3.0 * (cx - x);
		vals[4] = y + 2.0 / 3.0 * (cy - y);
		vals[5] = x;
		vals[6] = y;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgArcTo(ctx: NVGcontext, x1: Float, y1: Float, x2: Float, y2: Float, radius: Float): Void {
		var x0: Float = ctx.commandx;
		var y0: Float = ctx.commandy;
		var dx0: Float;
		var dy0: Float;
		var dx1: Float;
		var dy1: Float;
		var a: Float;
		var d: Float;
		var cx: Float;
		var cy: Float;
		var a0: Float;
		var a1: Float;
		var dir: Int;

		if (ctx.ncommands == 0) {
			return;
		}

		// Handle degenerate cases.
		if (nvg__ptEquals(x0, y0, x1, y1, ctx.distTol)
			|| nvg__ptEquals(x1, y1, x2, y2, ctx.distTol)
			|| nvg__distPtSeg(x1, y1, x0, y0, x2, y2) < ctx.distTol * ctx.distTol
			|| radius < ctx.distTol) {
			nvgLineTo(ctx, x1, y1);
			return;
		}

		// Calculate tangential circle to lines (x0,y0)-(x1,y1) and (x1,y1)-(x2,y2).
		dx0 = x0 - x1;
		dy0 = y0 - y1;
		dx1 = x2 - x1;
		dy1 = y2 - y1;
		nvg__normalize(new Ref<Float>(dx0), new Ref<Float>(dy0));
		nvg__normalize(new Ref<Float>(dx1), new Ref<Float>(dy1));
		a = nvg__acosf(dx0 * dx1 + dy0 * dy1);
		d = radius / nvg__tanf(a / 2.0);

		//	printf("a=%f° d=%f\n", a/NVG_PI*180.0f, d);

		if (d > 10000.0) {
			nvgLineTo(ctx, x1, y1);
			return;
		}

		if (nvg__cross(dx0, dy0, dx1, dy1) > 0.0) {
			cx = x1 + dx0 * d + dy0 * radius;
			cy = y1 + dy0 * d + -dx0 * radius;
			a0 = nvg__atan2f(dx0, -dy0);
			a1 = nvg__atan2f(-dx1, dy1);
			dir = NVG_CW;
			//		printf("CW c=(%f, %f) a0=%f° a1=%f°\n", cx, cy, a0/NVG_PI*180.0f, a1/NVG_PI*180.0f);
		}
		else {
			cx = x1 + dx0 * d + -dy0 * radius;
			cy = y1 + dy0 * d + dx0 * radius;
			a0 = nvg__atan2f(-dx0, dy0);
			a1 = nvg__atan2f(dx1, -dy1);
			dir = NVG_CCW;
			//		printf("CCW c=(%f, %f) a0=%f° a1=%f°\n", cx, cy, a0/NVG_PI*180.0f, a1/NVG_PI*180.0f);
		}

		nvgArc(ctx, cx, cy, radius, a0, a1, dir);
	}

	public static function nvgClosePath(ctx: NVGcontext): Void {
		var vals = new Vector<Float>(1);
		vals[0] = NVG_CLOSE;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgPathWinding(ctx: NVGcontext, dir: Int): Void {
		var vals = new Vector<Float>(2);
		vals[0] = NVG_WINDING;
		vals[1] = dir;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgArc(ctx: NVGcontext, cx: Float, cy: Float, r: Float, a0: Float, a1: Float, dir: Int) {
		var a: Float = 0;
		var da: Float = 0;
		var hda: Float = 0;
		var kappa: Float = 0;
		var dx: Float = 0;
		var dy: Float = 0;
		var x: Float = 0;
		var y: Float = 0;
		var tanx: Float = 0;
		var tany: Float = 0;
		var px: Float = 0;
		var py: Float = 0;
		var ptanx: Float = 0;
		var ptany: Float = 0;
		var vals = new Vector<Float>(3 + 5 * 7 + 100);
		var i: Int;
		var ndivs: Int;
		var nvals: Int;
		var move: Int = ctx.ncommands > 0 ? NVG_LINETO : NVG_MOVETO;

		// Clamp angles
		da = a1 - a0;
		if (dir == NVG_CW) {
			if (nvg__absf(da) >= NVG_PI * 2) {
				da = NVG_PI * 2;
			}
			else {
				while (da < 0.0)
					da += NVG_PI * 2;
			}
		}
		else {
			if (nvg__absf(da) >= NVG_PI * 2) {
				da = -NVG_PI * 2;
			}
			else {
				while (da > 0.0)
					da -= NVG_PI * 2;
			}
		}

		// Split arc into max 90 degree segments.
		ndivs = nvg__maxi(1, nvg__mini(Std.int(nvg__absf(da) / (NVG_PI * 0.5) + 0.5), 5));
		hda = (da / ndivs) / 2.0;
		kappa = nvg__absf(4.0 / 3.0 * (1.0 - nvg__cosf(hda)) / nvg__sinf(hda));

		if (dir == NVG_CCW)
			kappa = -kappa;

		nvals = 0;
		for (i in 0...ndivs + 1) {
			a = a0 + da * (i / ndivs);
			dx = nvg__cosf(a);
			dy = nvg__sinf(a);
			x = cx + dx * r;
			y = cy + dy * r;
			tanx = -dy * r * kappa;
			tany = dx * r * kappa;

			if (i == 0) {
				vals[nvals++] = move;
				vals[nvals++] = x;
				vals[nvals++] = y;
			}
			else {
				vals[nvals++] = NVG_BEZIERTO;
				vals[nvals++] = px + ptanx;
				vals[nvals++] = py + ptany;
				vals[nvals++] = x - tanx;
				vals[nvals++] = y - tany;
				vals[nvals++] = x;
				vals[nvals++] = y;
			}
			px = x;
			py = y;
			ptanx = tanx;
			ptany = tany;
		}

		nvg__appendCommands(ctx, vals, nvals);
	}

	public static function nvgRect(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float): Void {
		var vals = new Vector<Float>(13);
		vals[0] = NVG_MOVETO;
		vals[1] = x;
		vals[2] = y;
		vals[3] = NVG_LINETO;
		vals[4] = x;
		vals[5] = y + h;
		vals[6] = NVG_LINETO;
		vals[7] = x + w;
		vals[8] = y + h;
		vals[9] = NVG_LINETO;
		vals[10] = x + w;
		vals[11] = y;
		vals[12] = NVG_CLOSE;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgRoundedRect(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float, r: Float): Void {
		nvgRoundedRectVarying(ctx, x, y, w, h, r, r, r, r);
	}

	public static function nvgRoundedRectVarying(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float, radTopLeft: Float, radTopRight: Float,
			radBottomRight: Float, radBottomLeft: Float): Void {
		if (radTopLeft < 0.1 && radTopRight < 0.1 && radBottomRight < 0.1 && radBottomLeft < 0.1) {
			nvgRect(ctx, x, y, w, h);
			return;
		}
		else {
			var halfw: Float = nvg__absf(w) * 0.5;
			var halfh: Float = nvg__absf(h) * 0.5;
			var rxBL: Float = nvg__minf(radBottomLeft, halfw) * nvg__signf(w),
				ryBL = nvg__minf(radBottomLeft, halfh) * nvg__signf(h);
			var rxBR: Float = nvg__minf(radBottomRight, halfw) * nvg__signf(w),
				ryBR = nvg__minf(radBottomRight, halfh) * nvg__signf(h);
			var rxTR: Float = nvg__minf(radTopRight, halfw) * nvg__signf(w),
				ryTR = nvg__minf(radTopRight, halfh) * nvg__signf(h);
			var rxTL: Float = nvg__minf(radTopLeft, halfw) * nvg__signf(w),
				ryTL = nvg__minf(radTopLeft, halfh) * nvg__signf(h);
			var vals = new Vector<Float>(44);
			vals[0] = NVG_MOVETO;
			vals[1] = x;
			vals[2] = y + ryTL;
			vals[3] = NVG_LINETO;
			vals[4] = x;
			vals[5] = y + h - ryBL;
			vals[6] = NVG_BEZIERTO;
			vals[7] = x;
			vals[8] = y + h - ryBL * (1 - NVG_KAPPA90);
			vals[9] = x + rxBL * (1 - NVG_KAPPA90);
			vals[10] = y + h;
			vals[11] = x + rxBL;
			vals[12] = y + h;
			vals[13] = NVG_LINETO;
			vals[14] = x + w - rxBR;
			vals[15] = y + h;
			vals[16] = NVG_BEZIERTO;
			vals[17] = x + w - rxBR * (1 - NVG_KAPPA90);
			vals[18] = y + h;
			vals[19] = x + w;
			vals[20] = y + h - ryBR * (1 - NVG_KAPPA90);
			vals[21] = x + w;
			vals[22] = y + h - ryBR;
			vals[23] = NVG_LINETO;
			vals[24] = x + w;
			vals[25] = y + ryTR;
			vals[26] = NVG_BEZIERTO;
			vals[27] = x + w;
			vals[28] = y + ryTR * (1 - NVG_KAPPA90);
			vals[29] = x + w - rxTR * (1 - NVG_KAPPA90);
			vals[30] = y;
			vals[31] = x + w - rxTR;
			vals[32] = y;
			vals[33] = NVG_LINETO;
			vals[34] = x + rxTL;
			vals[35] = y;
			vals[36] = NVG_BEZIERTO;
			vals[37] = x + rxTL * (1 - NVG_KAPPA90);
			vals[38] = y;
			vals[39] = x;
			vals[40] = y + ryTL * (1 - NVG_KAPPA90);
			vals[41] = x;
			vals[42] = y + ryTL;
			vals[43] = NVG_CLOSE;
			nvg__appendCommands(ctx, vals, vals.length);
		}
	}

	public static function nvgEllipse(ctx: NVGcontext, cx: Float, cy: Float, rx: Float, ry: Float): Void {
		var vals = new Vector<Float>(32);
		vals[0] = NVG_MOVETO;
		vals[1] = cx - rx;
		vals[2] = cy;
		vals[3] = NVG_BEZIERTO;
		vals[4] = cx - rx;
		vals[5] = cy + ry * NVG_KAPPA90;
		vals[6] = cx - rx * NVG_KAPPA90;
		vals[7] = cy + ry;
		vals[8] = cx;
		vals[9] = cy + ry;
		vals[10] = NVG_BEZIERTO;
		vals[11] = cx + rx * NVG_KAPPA90;
		vals[12] = cy + ry;
		vals[13] = cx + rx;
		vals[14] = cy + ry * NVG_KAPPA90;
		vals[15] = cx + rx;
		vals[16] = cy;
		vals[17] = NVG_BEZIERTO;
		vals[18] = cx + rx;
		vals[19] = cy - ry * NVG_KAPPA90;
		vals[20] = cx + rx * NVG_KAPPA90;
		vals[21] = cy - ry;
		vals[22] = cx;
		vals[23] = cy - ry;
		vals[24] = NVG_BEZIERTO;
		vals[25] = cx - rx * NVG_KAPPA90;
		vals[26] = cy - ry;
		vals[27] = cx - rx;
		vals[28] = cy - ry * NVG_KAPPA90;
		vals[29] = cx - rx;
		vals[30] = cy;
		vals[31] = NVG_CLOSE;
		nvg__appendCommands(ctx, vals, vals.length);
	}

	public static function nvgCircle(ctx: NVGcontext, cx: Float, cy: Float, r: Float): Void {
		nvgEllipse(ctx, cx, cy, r, r);
	}

	public static function nvgDebugDumpPathCache(ctx: NVGcontext): Void {
		var path: NVGpath;
		// int i, j;

		trace("Dumping " + ctx.cache.npaths + " cached paths\n");
		for (i in 0...ctx.cache.npaths) {
			path = ctx.cache.paths[i];
			trace(" - Path " + i + "\n");
			if (path.nfill != 0) {
				trace("   - fill: " + path.nfill + "\n");
				for (j in 0...path.nfill)
					trace("" + path.fill.value(j).x + "\t" + path.fill.value(j).y + "\n");
			}
			if (path.nstroke != 0) {
				trace("   - stroke: " + path.nstroke + "\n");
				for (j in 0...path.nstroke)
					trace("" + path.stroke.value(j).x + "\t" + path.stroke.value(j).y + "\n");
			}
		}
	}

	public static function nvgFill(ctx: NVGcontext): Void {
		var state: NVGstate = nvg__getState(ctx);
		var path: NVGpath;
		var fillPaint: NVGpaint = state.fill;
		// int i;

		nvg__flattenPaths(ctx);
		if (ctx.params.edgeAntiAlias != 0 && state.shapeAntiAlias != 0)
			nvg__expandFill(ctx, ctx.fringeWidth, NVG_MITER, 2.4);
		else
			nvg__expandFill(ctx, 0.0, NVG_MITER, 2.4);

		// Apply global alpha
		fillPaint.innerColor.a *= state.alpha;
		fillPaint.outerColor.a *= state.alpha;

		ctx.params.renderFill(ctx.params.userPtr, fillPaint, state.compositeOperation, state.scissor, ctx.fringeWidth, ctx.cache.bounds, ctx.cache.paths,
			ctx.cache.npaths);

		// Count triangles
		for (i in 0...ctx.cache.npaths) {
			path = ctx.cache.paths[i];
			ctx.fillTriCount += path.nfill - 2;
			ctx.fillTriCount += path.nstroke - 2;
			ctx.drawCallCount += 2;
		}
	}

	public static function nvgStroke(ctx: NVGcontext): Void {
		var state: NVGstate = nvg__getState(ctx);
		var scale: Float = nvg__getAverageScale(state.xform);
		var strokeWidth: Float = nvg__clampf(state.strokeWidth * scale, 0.0, 200.0);
		var strokePaint: NVGpaint = state.stroke;
		var path: NVGpath;
		// int i;

		if (strokeWidth < ctx.fringeWidth) {
			// If the stroke width is less than pixel size, use alpha to emulate coverage.
			// Since coverage is area, scale by alpha*alpha.
			var alpha: Float = nvg__clampf(strokeWidth / ctx.fringeWidth, 0.0, 1.0);
			strokePaint.innerColor.a *= alpha * alpha;
			strokePaint.outerColor.a *= alpha * alpha;
			strokeWidth = ctx.fringeWidth;
		}

		// Apply global alpha
		strokePaint.innerColor.a *= state.alpha;
		strokePaint.outerColor.a *= state.alpha;

		nvg__flattenPaths(ctx);

		if (ctx.params.edgeAntiAlias != 0 && state.shapeAntiAlias != 0)
			nvg__expandStroke(ctx, strokeWidth * 0.5, ctx.fringeWidth, state.lineCap, state.lineJoin, state.miterLimit);
		else
			nvg__expandStroke(ctx, strokeWidth * 0.5, 0.0, state.lineCap, state.lineJoin, state.miterLimit);

		ctx.params.renderStroke(ctx.params.userPtr, strokePaint, state.compositeOperation, state.scissor, ctx.fringeWidth, strokeWidth, ctx.cache.paths,
			ctx.cache.npaths);

		// Count triangles
		for (i in 0...ctx.cache.npaths) {
			path = ctx.cache.paths[i];
			ctx.strokeTriCount += path.nstroke - 2;
			ctx.drawCallCount++;
		}
	}

	// Add fonts
	static function nvgCreateFont(ctx: NVGcontext, name: String, filename: String): Int {
		return fonsAddFont(ctx.fs, name, filename, 0);
	}

	static function nvgCreateFontAtIndex(ctx: NVGcontext, name: String, filename: String, fontIndex: Int): Int {
		return fonsAddFont(ctx.fs, name, filename, fontIndex);
	}

	static function nvgCreateFontMem(ctx: NVGcontext, name: String, data: Array<Int>, ndata: Int, freeData: Int): Int {
		return fonsAddFontMem(ctx.fs, name, data, ndata, freeData, 0);
	}

	static function nvgCreateFontMemAtIndex(ctx: NVGcontext, name: String, data: Array<Int>, ndata: Int, freeData: Int, fontIndex: Int): Int {
		return fonsAddFontMem(ctx.fs, name, data, ndata, freeData, fontIndex);
	}

	static function nvgFindFont(ctx: NVGcontext, name: String): Int {
		if (name == null)
			return -1;
		return fonsGetFontByName(ctx.fs, name);
	}

	static function nvgAddFallbackFontId(ctx: NVGcontext, baseFont: Int, fallbackFont: Int): Int {
		if (baseFont == -1 || fallbackFont == -1)
			return 0;
		return fonsAddFallbackFont(ctx.fs, baseFont, fallbackFont);
	}

	static function nvgAddFallbackFont(ctx: NVGcontext, baseFont: String, fallbackFont: String): Int {
		return nvgAddFallbackFontId(ctx, nvgFindFont(ctx, baseFont), nvgFindFont(ctx, fallbackFont));
	}

	static function nvgResetFallbackFontsId(ctx: NVGcontext, baseFont: Int): Void {
		fonsResetFallbackFont(ctx.fs, baseFont);
	}

	static function nvgResetFallbackFonts(ctx: NVGcontext, baseFont: String): Void {
		nvgResetFallbackFontsId(ctx, nvgFindFont(ctx, baseFont));
	}

	// State setting
	static function nvgFontSize(ctx: NVGcontext, size: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.fontSize = size;
	}

	static function nvgFontBlur(ctx: NVGcontext, blur: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.fontBlur = blur;
	}

	static function nvgTextLetterSpacing(ctx: NVGcontext, spacing: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.letterSpacing = spacing;
	}

	static function nvgTextLineHeight(ctx: NVGcontext, lineHeight: Float): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.lineHeight = lineHeight;
	}

	static function nvgTextAlign(ctx: NVGcontext, align: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.textAlign = align;
	}

	static function nvgFontFaceId(ctx: NVGcontext, font: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.fontId = font;
	}

	static function nvgFontFace(ctx: NVGcontext, font: String): Void {
		var state: NVGstate = nvg__getState(ctx);
		state.fontId = fonsGetFontByName(ctx.fs, font);
	}

	static function nvg__quantize(a: Float, d: Float): Float {
		return Std.int((a / d + 0.5)) * d;
	}

	static function nvg__getFontScale(state: NVGstate): Float {
		return nvg__minf(nvg__quantize(nvg__getAverageScale(state.xform), 0.01), 4.0);
	}

	static function nvg__flushTextTexture(ctx: NVGcontext): Void {
		var dirty = new Vector<Int>(4);

		if (fonsValidateTexture(ctx.fs, dirty) != 0) {
			var fontImage: Int = ctx.fontImages[ctx.fontImageIdx];
			// Update texture
			if (fontImage != 0) {
				var iw: Int = 0;
				var ih: Int = 0;
				var data: Array<Int> = fonsGetTextureData(ctx.fs, new Ref<Int>(iw), new Ref<Int>(ih));
				var x: Int = dirty[0];
				var y: Int = dirty[1];
				var w: Int = dirty[2] - dirty[0];
				var h: Int = dirty[3] - dirty[1];
				ctx.params.renderUpdateTexture(ctx.params.userPtr, fontImage, x, y, w, h, data);
			}
		}
	}

	static function nvg__allocTextAtlas(ctx: NVGcontext): Bool {
		var iw: Int = 0;
		var ih: Int = 0;
		nvg__flushTextTexture(ctx);
		if (ctx.fontImageIdx >= NVG_MAX_FONTIMAGES - 1)
			return false;
		// if next fontImage already have a texture
		if (ctx.fontImages[ctx.fontImageIdx + 1] != 0)
			nvgImageSize(ctx, ctx.fontImages[ctx.fontImageIdx + 1], new Ref<Int>(iw), new Ref<Int>(ih));
		else { // calculate the new font image size and create it.
			nvgImageSize(ctx, ctx.fontImages[ctx.fontImageIdx], new Ref<Int>(iw), new Ref<Int>(ih));
			if (iw > ih)
				ih *= 2;
			else
				iw *= 2;
			if (iw > NVG_MAX_FONTIMAGE_SIZE || ih > NVG_MAX_FONTIMAGE_SIZE)
				iw = ih = NVG_MAX_FONTIMAGE_SIZE;
			ctx.fontImages[ctx.fontImageIdx + 1] = ctx.params.renderCreateTexture(ctx.params.userPtr, NVGtexture.NVG_TEXTURE_ALPHA, iw, ih, 0, null);
		}
		++ctx.fontImageIdx;
		fonsResetAtlas(ctx.fs, iw, ih);
		return true;
	}

	static function nvg__renderText(ctx: NVGcontext, verts: Pointer<NVGvertex>, nverts: Int): Void {
		var state: NVGstate = nvg__getState(ctx);
		var paint: NVGpaint = state.fill;

		// Render triangles.
		paint.image = ctx.fontImages[ctx.fontImageIdx];

		// Apply global alpha
		paint.innerColor.a *= state.alpha;
		paint.outerColor.a *= state.alpha;

		ctx.params.renderTriangles(ctx.params.userPtr, paint, state.compositeOperation, state.scissor, verts, nverts, ctx.fringeWidth);

		ctx.drawCallCount++;
		ctx.textTriCount += Std.int(nverts / 3);
	}

	static function nvgText(ctx: NVGcontext, x: Float, y: Float, string: StringPointer, end: StringPointer): Float {
		var state: NVGstate = nvg__getState(ctx);
		var iter: FONStextIter = new FONStextIter();
		var prevIter: FONStextIter;
		var q: FONSquad = new FONSquad();
		var verts: Pointer<NVGvertex>;
		var scale: Float = nvg__getFontScale(state) * ctx.devicePxRatio;
		var invscale: Float = 1.0 / scale;
		var cverts: Int = 0;
		var nverts: Int = 0;

		if (end == null)
			end = string.pointer(string.length());

		if (state.fontId == FONS_INVALID)
			return x;

		fonsSetSize(ctx.fs, state.fontSize * scale);
		fonsSetSpacing(ctx.fs, state.letterSpacing * scale);
		fonsSetBlur(ctx.fs, state.fontBlur * scale);
		fonsSetAlign(ctx.fs, state.textAlign);
		fonsSetFont(ctx.fs, state.fontId);

		cverts = nvg__maxi(2, end.sub(string)) * 6; // conservative estimate.
		verts = nvg__allocTempVerts(ctx, cverts);
		if (verts == null)
			return x;

		fonsTextIterInit(ctx.fs, iter, x * scale, y * scale, string, end, FONS_GLYPH_BITMAP_REQUIRED);
		prevIter = iter;
		while (fonsTextIterNext(ctx.fs, iter, q) != 0) {
			var c = new Vector<Float>(4 * 2);
			if (iter.prevGlyphIndex == -1) { // can not retrieve glyph?
				if (nverts != 0) {
					nvg__renderText(ctx, verts, nverts);
					nverts = 0;
				}
				if (!nvg__allocTextAtlas(ctx))
					break; // no memory :(
				iter = prevIter;
				fonsTextIterNext(ctx.fs, iter, q); // try again
				if (iter.prevGlyphIndex == -1) // still can not find glyph?
					break;
			}
			prevIter = iter;
			// Transform corners.
			nvgTransformPoint(new Ref<Float>(c[0]), new Ref<Float>(c[1]), state.xform, q.x0 * invscale, q.y0 * invscale);
			nvgTransformPoint(new Ref<Float>(c[2]), new Ref<Float>(c[3]), state.xform, q.x1 * invscale, q.y0 * invscale);
			nvgTransformPoint(new Ref<Float>(c[4]), new Ref<Float>(c[5]), state.xform, q.x1 * invscale, q.y1 * invscale);
			nvgTransformPoint(new Ref<Float>(c[6]), new Ref<Float>(c[7]), state.xform, q.x0 * invscale, q.y1 * invscale);
			// Create triangles
			if (nverts + 6 <= cverts) {
				nvg__vset(verts.value(nverts), c[0], c[1], q.s0, q.t0);
				nverts++;
				nvg__vset(verts.value(nverts), c[4], c[5], q.s1, q.t1);
				nverts++;
				nvg__vset(verts.value(nverts), c[2], c[3], q.s1, q.t0);
				nverts++;
				nvg__vset(verts.value(nverts), c[0], c[1], q.s0, q.t0);
				nverts++;
				nvg__vset(verts.value(nverts), c[6], c[7], q.s0, q.t1);
				nverts++;
				nvg__vset(verts.value(nverts), c[4], c[5], q.s1, q.t1);
				nverts++;
			}
		}

		// TODO: add back-end bit to do this just once per frame.
		nvg__flushTextTexture(ctx);

		nvg__renderText(ctx, verts, nverts);

		return iter.nextx / scale;
	}

	static function nvgTextBox(ctx: NVGcontext, x: Float, y: Float, breakRowWidth: Float, string: StringPointer, end: StringPointer): Void {
		var state: NVGstate = nvg__getState(ctx);
		var rows = new Vector<NVGtextRow>(2);
		var nrows: Int = 0;
		var i: Int;
		var oldAlign: Int = state.textAlign;
		var haling: Int = state.textAlign & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
		var valign: Int = state.textAlign & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE);
		var lineh: Float = 0;

		if (state.fontId == FONS_INVALID)
			return;

		nvgTextMetrics(ctx, null, null, new Ref<Float>(lineh));

		state.textAlign = NVG_ALIGN_LEFT | valign;

		while ((nrows = nvgTextBreakLines(ctx, string, end, breakRowWidth, rows, 2)) != 0) {
			for (i in 0...nrows) {
				var row: NVGtextRow = rows[i];
				if ((haling & NVG_ALIGN_LEFT) != 0)
					nvgText(ctx, x, y, row.start, row.end);
				else if ((haling & NVG_ALIGN_CENTER) != 0)
					nvgText(ctx, x + breakRowWidth * 0.5 - row.width * 0.5, y, row.start, row.end);
				else if ((haling & NVG_ALIGN_RIGHT) != 0)
					nvgText(ctx, x + breakRowWidth - row.width, y, row.start, row.end);
				y += lineh * state.lineHeight;
			}
			string = rows[nrows - 1].next;
		}

		state.textAlign = oldAlign;
	}

	static function nvgTextGlyphPositions(ctx: NVGcontext, x: Float, y: Float, string: StringPointer, end: StringPointer, positions: Array<NVGglyphPosition>,
			maxPositions: Int): Int {
		var state: NVGstate = nvg__getState(ctx);
		var scale: Float = nvg__getFontScale(state) * ctx.devicePxRatio;
		var invscale: Float = 1.0 / scale;
		var iter: FONStextIter = new FONStextIter();
		var prevIter: FONStextIter;
		var q: FONSquad = new FONSquad();
		var npos: Int = 0;

		if (state.fontId == FONS_INVALID)
			return 0;

		if (end == null)
			end = string.pointer(string.length());

		if (string == end)
			return 0;

		fonsSetSize(ctx.fs, state.fontSize * scale);
		fonsSetSpacing(ctx.fs, state.letterSpacing * scale);
		fonsSetBlur(ctx.fs, state.fontBlur * scale);
		fonsSetAlign(ctx.fs, state.textAlign);
		fonsSetFont(ctx.fs, state.fontId);

		fonsTextIterInit(ctx.fs, iter, x * scale, y * scale, string, end, FONS_GLYPH_BITMAP_OPTIONAL);
		prevIter = iter;
		while (fonsTextIterNext(ctx.fs, iter, q) != 0) {
			if (iter.prevGlyphIndex < 0 && nvg__allocTextAtlas(ctx)) { // can not retrieve glyph?
				iter = prevIter;
				fonsTextIterNext(ctx.fs, iter, q); // try again
			}
			prevIter = iter;
			positions[npos].str = iter.str;
			positions[npos].x = iter.x * invscale;
			positions[npos].minx = nvg__minf(iter.x, q.x0) * invscale;
			positions[npos].maxx = nvg__maxf(iter.nextx, q.x1) * invscale;
			npos++;
			if (npos >= maxPositions)
				break;
		}

		return npos;
	}

	static function nvgTextBreakLines(ctx: NVGcontext, string: StringPointer, end: StringPointer, breakRowWidth: Float, rows: Vector<NVGtextRow>,
			maxRows: Int): Int {
		var state: NVGstate = nvg__getState(ctx);
		var scale: Float = nvg__getFontScale(state) * ctx.devicePxRatio;
		var invscale: Float = 1.0 / scale;
		var iter: FONStextIter = new FONStextIter();
		var prevIter: FONStextIter;
		var q: FONSquad = new FONSquad();
		var nrows: Int = 0;
		var rowStartX: Float = 0;
		var rowWidth: Float = 0;
		var rowMinX: Float = 0;
		var rowMaxX: Float = 0;
		var rowStart: StringPointer = null;
		var rowEnd: StringPointer = null;
		var wordStart: StringPointer = null;
		var wordStartX: Float = 0;
		var wordMinX: Float = 0;
		var breakEnd: StringPointer = null;
		var breakWidth: Float = 0;
		var breakMaxX: Float = 0;
		var type: Int = NVG_SPACE, ptype = NVG_SPACE;
		var pcodepoint: Int = 0;

		if (maxRows == 0)
			return 0;
		if (state.fontId == FONS_INVALID)
			return 0;

		if (end == null)
			end = string.pointer(string.length());

		if (string == end)
			return 0;

		fonsSetSize(ctx.fs, state.fontSize * scale);
		fonsSetSpacing(ctx.fs, state.letterSpacing * scale);
		fonsSetBlur(ctx.fs, state.fontBlur * scale);
		fonsSetAlign(ctx.fs, state.textAlign);
		fonsSetFont(ctx.fs, state.fontId);

		breakRowWidth *= scale;

		fonsTextIterInit(ctx.fs, iter, 0, 0, string, end, FONS_GLYPH_BITMAP_OPTIONAL);
		prevIter = iter;
		while (fonsTextIterNext(ctx.fs, iter, q) != 0) {
			if (iter.prevGlyphIndex < 0 && nvg__allocTextAtlas(ctx)) { // can not retrieve glyph?
				iter = prevIter;
				fonsTextIterNext(ctx.fs, iter, q); // try again
			}
			prevIter = iter;
			switch (iter.codepoint) {
				case 9: // \t
				case 11: // \v
				case 12: // \f
				case 32: // space
				case 0x00a0: // NBSP
					type = NVG_SPACE;
				case 10: // \n
					type = pcodepoint == 13 ? NVG_SPACE : NVG_NEWLINE;
				case 13: // \r
					type = pcodepoint == 10 ? NVG_SPACE : NVG_NEWLINE;
				case 0x0085: // NEL
					type = NVG_NEWLINE;
				default:
					if ((iter.codepoint >= 0x4E00 && iter.codepoint <= 0x9FFF)
						|| (iter.codepoint >= 0x3000 && iter.codepoint <= 0x30FF)
						|| (iter.codepoint >= 0xFF00 && iter.codepoint <= 0xFFEF)
						|| (iter.codepoint >= 0x1100 && iter.codepoint <= 0x11FF)
						|| (iter.codepoint >= 0x3130 && iter.codepoint <= 0x318F)
						|| (iter.codepoint >= 0xAC00 && iter.codepoint <= 0xD7AF))
						type = NVG_CJK_CHAR;
					else
						type = NVG_CHAR;
			}

			if (type == NVG_NEWLINE) {
				// Always handle new lines.
				rows[nrows].start = rowStart != null ? rowStart : iter.str;
				rows[nrows].end = rowEnd != null ? rowEnd : iter.str;
				rows[nrows].width = rowWidth * invscale;
				rows[nrows].minx = rowMinX * invscale;
				rows[nrows].maxx = rowMaxX * invscale;
				rows[nrows].next = iter.next;
				nrows++;
				if (nrows >= maxRows)
					return nrows;
				// Set null break point
				breakEnd = rowStart;
				breakWidth = 0.0;
				breakMaxX = 0.0;
				// Indicate to skip the white space at the beginning of the row.
				rowStart = null;
				rowEnd = null;
				rowWidth = 0;
				rowMinX = rowMaxX = 0;
			}
			else {
				if (rowStart == null) {
					// Skip white space until the beginning of the line
					if (type == NVG_CHAR || type == NVG_CJK_CHAR) {
						// The current char is the row so far
						rowStartX = iter.x;
						rowStart = iter.str;
						rowEnd = iter.next;
						rowWidth = iter.nextx - rowStartX;
						rowMinX = q.x0 - rowStartX;
						rowMaxX = q.x1 - rowStartX;
						wordStart = iter.str;
						wordStartX = iter.x;
						wordMinX = q.x0 - rowStartX;
						// Set null break point
						breakEnd = rowStart;
						breakWidth = 0.0;
						breakMaxX = 0.0;
					}
				}
				else {
					var nextWidth: Float = iter.nextx - rowStartX;

					// track last non-white space character
					if (type == NVG_CHAR || type == NVG_CJK_CHAR) {
						rowEnd = iter.next;
						rowWidth = iter.nextx - rowStartX;
						rowMaxX = q.x1 - rowStartX;
					}
					// track last end of a word
					if (((ptype == NVG_CHAR || ptype == NVG_CJK_CHAR) && type == NVG_SPACE) || type == NVG_CJK_CHAR) {
						breakEnd = iter.str;
						breakWidth = rowWidth;
						breakMaxX = rowMaxX;
					}
					// track last beginning of a word
					if ((ptype == NVG_SPACE && (type == NVG_CHAR || type == NVG_CJK_CHAR)) || type == NVG_CJK_CHAR) {
						wordStart = iter.str;
						wordStartX = iter.x;
						wordMinX = q.x0;
					}

					// Break to new line when a character is beyond break width.
					if ((type == NVG_CHAR || type == NVG_CJK_CHAR) && nextWidth > breakRowWidth) {
						// The run length is too long, need to break to new line.
						if (breakEnd == rowStart) {
							// The current word is longer than the row length, just break it from here.
							rows[nrows].start = rowStart;
							rows[nrows].end = iter.str;
							rows[nrows].width = rowWidth * invscale;
							rows[nrows].minx = rowMinX * invscale;
							rows[nrows].maxx = rowMaxX * invscale;
							rows[nrows].next = iter.str;
							nrows++;
							if (nrows >= maxRows)
								return nrows;
							rowStartX = iter.x;
							rowStart = iter.str;
							rowEnd = iter.next;
							rowWidth = iter.nextx - rowStartX;
							rowMinX = q.x0 - rowStartX;
							rowMaxX = q.x1 - rowStartX;
							wordStart = iter.str;
							wordStartX = iter.x;
							wordMinX = q.x0 - rowStartX;
						}
						else {
							// Break the line from the end of the last word, and start new line from the beginning of the new.
							rows[nrows].start = rowStart;
							rows[nrows].end = breakEnd;
							rows[nrows].width = breakWidth * invscale;
							rows[nrows].minx = rowMinX * invscale;
							rows[nrows].maxx = breakMaxX * invscale;
							rows[nrows].next = wordStart;
							nrows++;
							if (nrows >= maxRows)
								return nrows;
							// Update row
							rowStartX = wordStartX;
							rowStart = wordStart;
							rowEnd = iter.next;
							rowWidth = iter.nextx - rowStartX;
							rowMinX = wordMinX - rowStartX;
							rowMaxX = q.x1 - rowStartX;
						}
						// Set null break point
						breakEnd = rowStart;
						breakWidth = 0.0;
						breakMaxX = 0.0;
					}
				}
			}

			pcodepoint = iter.codepoint;
			ptype = type;
		}

		// Break the line from the end of the last word, and start new line from the beginning of the new.
		if (rowStart != null) {
			rows[nrows].start = rowStart;
			rows[nrows].end = rowEnd;
			rows[nrows].width = rowWidth * invscale;
			rows[nrows].minx = rowMinX * invscale;
			rows[nrows].maxx = rowMaxX * invscale;
			rows[nrows].next = end;
			nrows++;
		}

		return nrows;
	}

	static function nvgTextBounds(ctx: NVGcontext, x: Float, y: Float, string: StringPointer, end: StringPointer, bounds: Vector<Float>): Float {
		var state: NVGstate = nvg__getState(ctx);
		var scale: Float = nvg__getFontScale(state) * ctx.devicePxRatio;
		var invscale: Float = 1.0 / scale;
		var width: Float;

		if (state.fontId == FONS_INVALID)
			return 0;

		fonsSetSize(ctx.fs, state.fontSize * scale);
		fonsSetSpacing(ctx.fs, state.letterSpacing * scale);
		fonsSetBlur(ctx.fs, state.fontBlur * scale);
		fonsSetAlign(ctx.fs, state.textAlign);
		fonsSetFont(ctx.fs, state.fontId);

		width = fonsTextBounds(ctx.fs, x * scale, y * scale, string, end, bounds);
		if (bounds != null) {
			// Use line bounds for height.
			fonsLineBounds(ctx.fs, y * scale, new Ref<Float>(bounds[1]), new Ref<Float>(bounds[3]));
			bounds[0] *= invscale;
			bounds[1] *= invscale;
			bounds[2] *= invscale;
			bounds[3] *= invscale;
		}
		return width * invscale;
	}

	static function nvgTextBoxBounds(ctx: NVGcontext, x: Float, y: Float, breakRowWidth: Float, string: StringPointer, end: StringPointer,
			bounds: Array<Float>): Void {
		var state: NVGstate = nvg__getState(ctx);
		var rows = new Vector<NVGtextRow>(2);
		var scale: Float = nvg__getFontScale(state) * ctx.devicePxRatio;
		var invscale: Float = 1.0 / scale;
		var nrows: Int = 0; // var i: Int;
		var oldAlign: Int = state.textAlign;
		var haling: Int = state.textAlign & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
		var valign: Int = state.textAlign & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE);
		var lineh: Float = 0;
		var rminy: Float = 0;
		var rmaxy: Float = 0;
		var minx: Float;
		var miny: Float;
		var maxx: Float;
		var maxy: Float;

		if (state.fontId == FONS_INVALID) {
			if (bounds != null)
				bounds[0] = bounds[1] = bounds[2] = bounds[3] = 0.0;
			return;
		}

		nvgTextMetrics(ctx, null, null, new Ref<Float>(lineh));

		state.textAlign = NVG_ALIGN_LEFT | valign;

		minx = maxx = x;
		miny = maxy = y;

		fonsSetSize(ctx.fs, state.fontSize * scale);
		fonsSetSpacing(ctx.fs, state.letterSpacing * scale);
		fonsSetBlur(ctx.fs, state.fontBlur * scale);
		fonsSetAlign(ctx.fs, state.textAlign);
		fonsSetFont(ctx.fs, state.fontId);
		fonsLineBounds(ctx.fs, 0, new Ref<Float>(rminy), new Ref<Float>(rmaxy));
		rminy *= invscale;
		rmaxy *= invscale;

		while ((nrows = nvgTextBreakLines(ctx, string, end, breakRowWidth, rows, 2)) != 0) {
			for (i in 0...nrows) {
				var row: NVGtextRow = rows[i];
				var rminx: Float;
				var rmaxx: Float;
				var dx: Float = 0;
				// Horizontal bounds
				if ((haling & NVG_ALIGN_LEFT) != 0)
					dx = 0;
				else if ((haling & NVG_ALIGN_CENTER) != 0)
					dx = breakRowWidth * 0.5 - row.width * 0.5;
				else if ((haling & NVG_ALIGN_RIGHT) != 0)
					dx = breakRowWidth - row.width;
				rminx = x + row.minx + dx;
				rmaxx = x + row.maxx + dx;
				minx = nvg__minf(minx, rminx);
				maxx = nvg__maxf(maxx, rmaxx);
				// Vertical bounds.
				miny = nvg__minf(miny, y + rminy);
				maxy = nvg__maxf(maxy, y + rmaxy);

				y += lineh * state.lineHeight;
			}
			string = rows[nrows - 1].next;
		}

		state.textAlign = oldAlign;

		if (bounds != null) {
			bounds[0] = minx;
			bounds[1] = miny;
			bounds[2] = maxx;
			bounds[3] = maxy;
		}
	}

	static function nvgTextMetrics(ctx: NVGcontext, ascender: Ref<Float>, descender: Ref<Float>, lineh: Ref<Float>): Void {
		var state: NVGstate = nvg__getState(ctx);
		var scale: Float = nvg__getFontScale(state) * ctx.devicePxRatio;
		var invscale: Float = 1.0 / scale;

		if (state.fontId == FONS_INVALID)
			return;

		fonsSetSize(ctx.fs, state.fontSize * scale);
		fonsSetSpacing(ctx.fs, state.letterSpacing * scale);
		fonsSetBlur(ctx.fs, state.fontBlur * scale);
		fonsSetAlign(ctx.fs, state.textAlign);
		fonsSetFont(ctx.fs, state.fontId);

		fonsVertMetrics(ctx.fs, ascender, descender, lineh);
		if (ascender != null)
			ascender.value *= invscale;
		if (descender != null)
			descender.value *= invscale;
		if (lineh != null)
			lineh.value *= invscale;
	}

	// vim: ft=c nu noet ts=4
	static final FONS_INVALID: Int = -1;
	static final FONS_ZERO_TOPLEFT: Int = 0;
	static final FONS_GLYPH_BITMAP_OPTIONAL: Int = 0;
	static final FONS_GLYPH_BITMAP_REQUIRED: Int = 0;

	static function fonsSetSize(fs: FONScontext, size: Float): Void {}

	static function fonsSetSpacing(fs: FONScontext, size: Float): Void {}

	static function fonsSetBlur(fs: FONScontext, size: Float): Void {}

	static function fonsSetAlign(fs: FONScontext, size: Float): Void {}

	static function fonsSetFont(fs: FONScontext, font: Int) {}

	static function fonsVertMetrics(fs: FONScontext, ascender: Ref<Float>, descender: Ref<Float>, lineh: Ref<Float>): Void {}

	static function fonsLineBounds(fs: FONScontext, a: Float, b: Ref<Float>, c: Ref<Float>): Void {}

	static function fonsGetFontByName(fs: FONScontext, name: String): Int {
		return 0;
	}

	static function fonsResetAtlas(fs: FONScontext, w: Int, h: Int): Void {}

	static function fonsAddFont(fs: FONScontext, name: String, filename: String, value: Int): Int {
		return 0;
	}

	static function fonsAddFallbackFont(fs: FONScontext, baseFont: Int, fallbackFont: Int): Int {
		return 0;
	}

	static function fonsDeleteInternal(fs: FONScontext): Void {}

	static function fonsCreateInternal(params: FONSparams): FONScontext {
		return new FONScontext();
	}

	static function fonsTextBounds(s: FONScontext, x: Float, y: Float, string: StringPointer, end: StringPointer, bounds: Vector<Float>): Float {
		return 0;
	}

	static function fonsTextIterInit(stash: FONScontext, iter: FONStextIter, x: Float, y: Float, str: StringPointer, end: StringPointer,
			bitmapOption: Int): Int {
		return 0;
	}

	static function fonsTextIterNext(stash: FONScontext, iter: FONStextIter, quad: FONSquad): Int {
		return 0;
	}

	static function fonsAddFontMem(stash: FONScontext, name: String, data: Array<Int>, dataSize: Int, freeData: Int, fontIndex: Int): Int {
		return 0;
	}

	static function fonsResetFallbackFont(stash: FONScontext, base: Int): Void {}

	static function fonsValidateTexture(stash: FONScontext, dirty: Vector<Int>): Int {
		return 0;
	}

	static function fonsGetTextureData(stash: FONScontext, width: Ref<Int>, height: Ref<Int>): Array<Int> {
		return null;
	}

	public static function nvgCreateKha(flags: Int): NVGcontext {
		var params = new KhaParams();
		var ctx: NVGcontext = null;
		var kha: KhaContext = new KhaContext();
		if (kha == null)
			return null;

		params.userPtr = kha;
		params.edgeAntiAlias = (flags & NVG_ANTIALIAS != 0) ? 1 : 0;

		kha.flags = flags;

		ctx = nvgCreateInternal(params);
		if (ctx == null)
			return null;

		return ctx;
	}
}

class FONScontext {
	public function new() {}
}

class FONSquad {
	public var x0: Float;
	public var x1: Float;
	public var y0: Float;
	public var y1: Float;
	public var s0: Float;
	public var s1: Float;
	public var t0: Float;
	public var t1: Float;

	public function new() {}
}

class FONStextIter {
	public var nextx: Float;
	public var str: StringPointer;
	public var x: Float;
	public var y: Float;
	public var prevGlyphIndex: Int;
	public var codepoint: Int;
	public var next: StringPointer;

	public function new() {}
}

class FONSparams {
	public var width: Int;
	public var height: Int;
	public var flags: Int;
	public var renderCreate: Dynamic;
	public var renderUpdate: Dynamic;
	public var renderDraw: Dynamic;
	public var renderDelete: Dynamic;
	public var userPtr: Dynamic;

	public function new() {}
}
