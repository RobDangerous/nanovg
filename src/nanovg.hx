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

enum NVGcommands {
	NVG_MOVETO = 0,
	NVG_LINETO = 1,
	NVG_BEZIERTO = 2,
	NVG_CLOSE = 3,
	NVG_WINDING = 4,
}

enum NVGpointFlags
{
	NVG_PT_CORNER = 0x01,
	NVG_PT_LEFT = 0x02,
	NVG_PT_BEVEL = 0x04,
	NVG_PR_INNERBEVEL = 0x08,
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
	public var xform_0;
	public var xform_1;
	public var xform_2;
	public var xform_3;
	public var xform_4;
	public var xform_5;
	public var scissor: NVGscissor;
	public var fontSize: Float;
	public var letterSpacing: Float;
	public var lineHeight: Float;
	public var fontBlur: Float;
	public var textAlign: Int;
	public var fontId: Int;
}

class NVGpoint {
	public var x: Float; public var y: Float;
	public var dx: Float; public var dy: Float;
	public var len: Float;
	public var dmx: Float; public var dmy: Float;
	public var flags: Int;
}

class NVGpathCache {
	public var points: Vector<NVGpoint>;
	public var npoints: Int;
	public var cpoints: Int;
	public var paths: Vector<NVGpath>;
	public var npaths: Int;
	public var cpaths: Int;
	public var verts: Vector<NVGvertex>;
	public var nverts: Int;
	public var cverts: Int;
	public var bounds_0: Float;
	public var bounds_1: Float;
	public var bounds_2: Float;
	public var bounds_3: Float;
}

class NVGcontext {
	public var params: NVGparams;
	public var commands: Array<Float>;
	public var ccommands: Int;
	public var ncommands: Int;
	public var commandx: Float; public var commandy: Float;
	public var states: Array<NVGstate>;
	public var nstates: Int;
	public var cache: NVGpathCache;
	public var tessTol: Float;
	public var distTol: Float;
	public var fringeWidth: Float;
	public var devicePxRatio: Float;
	public var fs: FONScontext;
	public var fontImages: Array<Int>;
	public var fontImageIdx: Int;
	public var drawCallCount: Int;
	public var fillTriCount: Int;
	public var strokeTriCount: Int;
	public var textTriCount: Int;
}

class NVG {
	static final var NVG_INIT_FONTIMAGE_SIZE = 512;
	static final var NVG_MAX_FONTIMAGE_SIZE = 2048;
	static final var NVG_MAX_FONTIMAGES = 4;

	static final var NVG_INIT_COMMANDS_SIZE = 256;
	static final var NVG_INIT_POINTS_SIZE = 128;
	static final var NVG_INIT_PATHS_SIZE = 16;
	static final var NVG_INIT_VERTS_SIZE = 256;
	static final var NVG_MAX_STATES = 32;

	static final var NVG_KAPPA90 = 0.5522847493; // Length proportional to radius of a cubic bezier handle for 90deg arcs.

	static function NVG_COUNTOF(arr) { return (sizeof(arr) / sizeof(0[arr])); }

static function nvg__sqrtf(a: Float): Float { return Math.sqrt(a); }
static function nvg__modf(a: Float, b: Float): Float { return fmodf(a, b); }
static function nvg__sinf(a: Float): Float { return sinf(a); }
static function nvg__cosf(a: Float): Float { return cosf(a); }
static function nvg__tanf(a: Float): Float { return tanf(a); }
static function nvg__atan2f(a: Float, b: Float): Float { return atan2f(a, b); }
static function nvg__acosf(a: Float): Float { return acosf(a); }

static function nvg__mini(a: Int, b: Int): Int { return a < b ? a : b; }
static function nvg__maxi(a: Int, b: Int): Int { return a > b ? a : b; }
static function nvg__clampi(a: Int, mn: Int, mx: Int): Int { return a < mn ? mn : (a > mx ? mx : a); }
static function nvg__minf(a: Float, b: Float): Float { return a < b ? a : b; }
static function nvg__maxf(a: Float, b: Float): Float { return a > b ? a : b; }
static function nvg__absf(a: Float): Float { return a >= 0.0f ? a : -a; }
static function nvg__signf(a: Float): Float { return a >= 0.0f ? 1.0f : -1.0f; }
static function nvg__clampf(a: Float, mn: Float, mx: Float): Float { return a < mn ? mn : (a > mx ? mx : a); }
static function nvg__cross(dx0: Float, dy0: Float, dx1: Float, dy1: Float): Float { return dx1*dy0 - dx0*dy1; }

static function nvg__normalize(x: Ref<Float>, y: Ref<Float>): Float
{
	var d: Float = nvg__sqrtf((*x)*(*x) + (*y)*(*y));
	if (d > 1e-6f) {
		var id: Float = 1.0f / d;
		*x *= id;
		*y *= id;
	}
	return d;
}


static function nvg__deletePathCache(c: NVGpathCache): Void
{
	// if (c == null) return;
	// if (c->points != NULL) free(c->points);
	// if (c->paths != NULL) free(c->paths);
	// if (c->verts != NULL) free(c->verts);
	// free(c);
}

static function nvg__allocPathCache(): NVGpathCache
{
	var c: NVGpathCache = new NVGpathCache();
	if (c == null) return null;
	// memset(c, 0, sizeof(NVGpathCache));

	c.points = (NVGpoint*)malloc(sizeof(NVGpoint)*NVG_INIT_POINTS_SIZE);
	if (c.points == null) return null;
	c.npoints = 0;
	c.cpoints = NVG_INIT_POINTS_SIZE;

	c.paths = (NVGpath*)malloc(sizeof(NVGpath)*NVG_INIT_PATHS_SIZE);
	if (c.paths == null) return null;
	c.npaths = 0;
	c.cpaths = NVG_INIT_PATHS_SIZE;

	c.verts = (NVGvertex*)malloc(sizeof(NVGvertex)*NVG_INIT_VERTS_SIZE);
	if (c.verts == null) return null;
	c.nverts = 0;
	c.cverts = NVG_INIT_VERTS_SIZE;

	return c;
}

static function nvg__setDevicePixelRatio(ctx: NVGcontext, ratio: Float): Void
{
	ctx.tessTol = 0.25 / ratio;
	ctx.distTol = 0.01 / ratio;
	ctx.fringeWidth = 1.0 / ratio;
	ctx.devicePxRatio = ratio;
}

static function nvg__compositeOperationState(op: Int): NVGcompositeOperationState
{
	var sfactor: Int; var dfactor: Int;

	if (op == NVG_SOURCE_OVER)
	{
		sfactor = NVG_ONE;
		dfactor = NVG_ONE_MINUS_SRC_ALPHA;
	}
	else if (op == NVG_SOURCE_IN)
	{
		sfactor = NVG_DST_ALPHA;
		dfactor = NVG_ZERO;
	}
	else if (op == NVG_SOURCE_OUT)
	{
		sfactor = NVG_ONE_MINUS_DST_ALPHA;
		dfactor = NVG_ZERO;
	}
	else if (op == NVG_ATOP)
	{
		sfactor = NVG_DST_ALPHA;
		dfactor = NVG_ONE_MINUS_SRC_ALPHA;
	}
	else if (op == NVG_DESTINATION_OVER)
	{
		sfactor = NVG_ONE_MINUS_DST_ALPHA;
		dfactor = NVG_ONE;
	}
	else if (op == NVG_DESTINATION_IN)
	{
		sfactor = NVG_ZERO;
		dfactor = NVG_SRC_ALPHA;
	}
	else if (op == NVG_DESTINATION_OUT)
	{
		sfactor = NVG_ZERO;
		dfactor = NVG_ONE_MINUS_SRC_ALPHA;
	}
	else if (op == NVG_DESTINATION_ATOP)
	{
		sfactor = NVG_ONE_MINUS_DST_ALPHA;
		dfactor = NVG_SRC_ALPHA;
	}
	else if (op == NVG_LIGHTER)
	{
		sfactor = NVG_ONE;
		dfactor = NVG_ONE;
	}
	else if (op == NVG_COPY)
	{
		sfactor = NVG_ONE;
		dfactor = NVG_ZERO;
	}
	else if (op == NVG_XOR)
	{
		sfactor = NVG_ONE_MINUS_DST_ALPHA;
		dfactor = NVG_ONE_MINUS_SRC_ALPHA;
	}
	else
	{
		sfactor = NVG_ONE;
		dfactor = NVG_ZERO;
	}

	var state : NVGcompositeOperationState = new NVGcompositeOperationState();
	state.srcRGB = sfactor;
	state.dstRGB = dfactor;
	state.srcAlpha = sfactor;
	state.dstAlpha = dfactor;
	return state;
}

static NVGstate* nvg__getState(NVGcontext* ctx)
{
	return &ctx->states[ctx->nstates-1];
}

static function nvgCreateInternal(params: NVGparams): NVGcontext
{
	var fontParams: FONSparams;
	var ctx: NVGcontext = new NVGcontext();
	var i: Int;
	if (ctx == null) return null;
	// memset(ctx, 0, sizeof(NVGcontext));

	ctx->params = *params;
	for (i = 0; i < NVG_MAX_FONTIMAGES; i++)
		ctx->fontImages[i] = 0;

	ctx->commands = (float*)malloc(sizeof(float)*NVG_INIT_COMMANDS_SIZE);
	if (ctx.commands == null) return null;
	ctx->ncommands = 0;
	ctx->ccommands = NVG_INIT_COMMANDS_SIZE;

	ctx.cache = nvg__allocPathCache();
	if (ctx.cache == null) return null;

	nvgSave(ctx);
	nvgReset(ctx);

	nvg__setDevicePixelRatio(ctx, 1.0f);

	if (ctx.params.renderCreate(ctx->params.userPtr) == 0) goto error;

	// Init font rendering
	memset(&fontParams, 0, sizeof(fontParams));
	fontParams.width = NVG_INIT_FONTIMAGE_SIZE;
	fontParams.height = NVG_INIT_FONTIMAGE_SIZE;
	fontParams.flags = FONS_ZERO_TOPLEFT;
	fontParams.renderCreate = NULL;
	fontParams.renderUpdate = NULL;
	fontParams.renderDraw = NULL;
	fontParams.renderDelete = NULL;
	fontParams.userPtr = NULL;
	ctx->fs = fonsCreateInternal(&fontParams);
	if (ctx->fs == NULL) goto error;

	// Create font texture
	ctx->fontImages[0] = ctx->params.renderCreateTexture(ctx->params.userPtr, NVG_TEXTURE_ALPHA, fontParams.width, fontParams.height, 0, NULL);
	if (ctx->fontImages[0] == 0) goto error;
	ctx->fontImageIdx = 0;

	return ctx;
}

static function nvgInternalParams(ctx: NVGcontext): NVGparams
{
    return ctx.params;
}

static function nvgDeleteInternal(ctx: NVGcontext): Void
{
	var i: Int;
	if (ctx == null) return;
	// if (ctx->commands != null) free(ctx->commands);
	if (ctx.cache != null) nvg__deletePathCache(ctx->cache);

	if (ctx.fs)
		fonsDeleteInternal(ctx->fs);

	for (i in 0...NVG_MAX_FONTIMAGES) {
		if (ctx.fontImages[i] != 0) {
			nvgDeleteImage(ctx, ctx.fontImages[i]);
			ctx.fontImages[i] = 0;
		}
	}

	if (ctx.params.renderDelete != NULL)
		ctx.params.renderDelete(ctx.params.userPtr);

	free(ctx);
}

static function nvgBeginFrame(ctx: NVGcontext, windowWidth: Float, windowHeight: Float, devicePixelRatio: Float): Void
{
/*	printf("Tris: draws:%d  fill:%d  stroke:%d  text:%d  TOT:%d\n",
		ctx->drawCallCount, ctx->fillTriCount, ctx->strokeTriCount, ctx->textTriCount,
		ctx->fillTriCount+ctx->strokeTriCount+ctx->textTriCount);*/

	ctx->nstates = 0;
	nvgSave(ctx);
	nvgReset(ctx);

	nvg__setDevicePixelRatio(ctx, devicePixelRatio);

	ctx->params.renderViewport(ctx->params.userPtr, windowWidth, windowHeight, devicePixelRatio);

	ctx->drawCallCount = 0;
	ctx->fillTriCount = 0;
	ctx->strokeTriCount = 0;
	ctx->textTriCount = 0;
}

static function nvgCancelFrame(ctx: NVGcontext): Void
{
	ctx.params.renderCancel(ctx.params.userPtr);
}

static function nvgEndFrame(ctx: NVGcontext): Void
{
	ctx.params.renderFlush(ctx.params.userPtr);
	if (ctx.fontImageIdx != 0) {
		int fontImage = ctx->fontImages[ctx->fontImageIdx];
		int i, j, iw, ih;
		// delete images that smaller than current one
		if (fontImage == 0)
			return;
		nvgImageSize(ctx, fontImage, &iw, &ih);
		for (i = j = 0; i < ctx->fontImageIdx; i++) {
			if (ctx->fontImages[i] != 0) {
				int nw, nh;
				nvgImageSize(ctx, ctx->fontImages[i], &nw, &nh);
				if (nw < iw || nh < ih)
					nvgDeleteImage(ctx, ctx->fontImages[i]);
				else
					ctx->fontImages[j++] = ctx->fontImages[i];
			}
		}
		// make current font image to first
		ctx->fontImages[j++] = ctx->fontImages[0];
		ctx->fontImages[0] = fontImage;
		ctx->fontImageIdx = 0;
		// clear all images after j
		for (i = j; i < NVG_MAX_FONTIMAGES; i++)
			ctx->fontImages[i] = 0;
	}
}

static function nvgRGB(r: Int, g: Int, b: Int): NVGcolor
{
	return nvgRGBA(r,g,b,255);
}

static function nvgRGBf(r: Float, g: Float, b: Float): NVGcolor
{
	return nvgRGBAf(r,g,b,1.0);
}

static function nvgRGBA(r: Int, g: Int, b: Int, a: Int): NVGcolor
{
	var color: NVGcolor;
	// Use longer initialization to suppress warning.
	color.r = r / 255.0f;
	color.g = g / 255.0f;
	color.b = b / 255.0f;
	color.a = a / 255.0f;
	return color;
}

static function nvgRGBAf(r: Float, g: Float, b: Float, a: Float): NVGcolor
{
	var color: NVGcolor;
	// Use longer initialization to suppress warning.
	color.r = r;
	color.g = g;
	color.b = b;
	color.a = a;
	return color;
}

static function nvgTransRGBA(c: NVGcolor, a: Int): NVGcolor
{
	c.a = a / 255.0;
	return c;
}

static function nvgTransRGBAf(c: NVGcolor, a: Float): NVGcolor
{
	c.a = a;
	return c;
}

static function nvgLerpRGBA(c0: NVGcolor, c1: NVGcolor, u: Float): NVGcolor
{
	// var i: Int;
	var oneminu: Float;
	var cint: NVGcolor = {{{0}}};

	u = nvg__clampf(u, 0.0f, 1.0f);
	oneminu = 1.0f - u;
	for( i in 0...4 )
	{
		cint.rgba[i] = c0.rgba[i] * oneminu + c1.rgba[i] * u;
	}

	return cint;
}

static function nvgHSL(h: Float, s: Float, l: Float): NVGcolor
{
	return nvgHSLA(h,s,l,255);
}

static function nvg__hue(h: Float, m1: Float, m2: Float): Float
{
	if (h < 0) h += 1;
	if (h > 1) h -= 1;
	if (h < 1.0/6.0)
		return m1 + (m2 - m1) * h * 6.0;
	else if (h < 3.0/6.0)
		return m2;
	else if (h < 4.0/6.0)
		return m1 + (m2 - m1) * (2.0/3.0 - h) * 6.0;
	return m1;
}

static function nvgHSLA(h: Float, s: Float, l: Float, a: Int): NVGcolor
{
	var m1: Float; var m2: Float;
	var col: NVGcolor;
	h = nvg__modf(h, 1.0);
	if (h < 0.0) h += 1.0;
	s = nvg__clampf(s, 0.0, 1.0);
	l = nvg__clampf(l, 0.0, 1.0);
	m2 = l <= 0.5f ? (l * (1 + s)) : (l + s - l * s);
	m1 = 2 * l - m2;
	col.r = nvg__clampf(nvg__hue(h + 1.0/3.0, m1, m2), 0.0, 1.0);
	col.g = nvg__clampf(nvg__hue(h, m1, m2), 0.0, 1.0);
	col.b = nvg__clampf(nvg__hue(h - 1.0/3.0, m1, m2), 0.0, 1.0);
	col.a = a/255.0;
	return col;
}

static function nvgTransformIdentity(t: Array<Float>): Void
{
	t[0] = 1.0; t[1] = 0.0;
	t[2] = 0.0; t[3] = 1.0;
	t[4] = 0.0; t[5] = 0.0;
}

static function nvgTransformTranslate(t: Array<Float>, tx: Float, ty: Float): Void
{
	t[0] = 1.0; t[1] = 0.0;
	t[2] = 0.0; t[3] = 1.0;
	t[4] = tx; t[5] = ty;
}

static function nvgTransformScale(t: Array<Float>, sx: Float, sy: Float): Void
{
	t[0] = sx; t[1] = 0.0;
	t[2] = 0.0; t[3] = sy;
	t[4] = 0.0; t[5] = 0.0;
}

static function nvgTransformRotate(t: Array<Float>, a: Float): Void
{
	var cs: Float = nvg__cosf(a), sn = nvg__sinf(a);
	t[0] = cs; t[1] = sn;
	t[2] = -sn; t[3] = cs;
	t[4] = 0.0; t[5] = 0.0;
}

static function nvgTransformSkewX(t: Array<Float>, a: Float): Void
{
	t[0] = 1.0; t[1] = 0.0;
	t[2] = nvg__tanf(a); t[3] = 1.0;
	t[4] = 0.0; t[5] = 0.0;
}

static function nvgTransformSkewY(t: Array<Float>, a: Float): Void
{
	t[0] = 1.0; t[1] = nvg__tanf(a);
	t[2] = 0.0; t[3] = 1.0;
	t[4] = 0.0; t[5] = 0.0;
}

static function nvgTransformMultiply(t: Array<Float>, s: Array<Float>): Void
{
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

static function nvgTransformPremultiply(t: Array<Float>, s: Array<Float>): Void
{
	float s2[6];
	memcpy(s2, s, sizeof(float)*6);
	nvgTransformMultiply(s2, t);
	memcpy(t, s2, sizeof(float)*6);
}

static function nvgTransformInverse(inv: Array<Float>, t: Array<Float>): Int
{
	var invdet: Float; var det: Float = t[0] * t[3] - t[2] * t[1];
	if (det > -1e-6 && det < 1e-6) {
		nvgTransformIdentity(inv);
		return 0;
	}
	invdet = 1.0 / det;
	inv[0] = (float)(t[3] * invdet);
	inv[2] = (float)(-t[2] * invdet);
	inv[4] = (float)(((double)t[2] * t[5] - (double)t[3] * t[4]) * invdet);
	inv[1] = (float)(-t[1] * invdet);
	inv[3] = (float)(t[0] * invdet);
	inv[5] = (float)(((double)t[1] * t[4] - (double)t[0] * t[5]) * invdet);
	return 1;
}

static function nvgTransformPoint(dx: Ref<Float>, dy: Ref<Float>, t: Array<Float>, sx: Float, sy: Float): Void
{
	*dx = sx*t[0] + sy*t[2] + t[4];
	*dy = sx*t[1] + sy*t[3] + t[5];
}

static function nvgDegToRad(deg: Float): Float
{
	return deg / 180.0 * NVG_PI;
}

static function nvgRadToDeg(rad: Float): Float
{
	return rad / NVG_PI * 180.0;
}

static function nvg__setPaintColor(p: NVGpaint, color: NVGcolor): Void
{
	memset(p, 0, sizeof(*p));
	nvgTransformIdentity(p->xform);
	p.radius = 0.0;
	p.feather = 1.0;
	p.innerColor = color;
	p.outerColor = color;
}


// State handling
static function nvgSave(ctx: NVGcontext): Void
{
	if (ctx.nstates >= NVG_MAX_STATES)
		return;
	if (ctx.nstates > 0)
		memcpy(&ctx->states[ctx->nstates], &ctx->states[ctx->nstates-1], sizeof(NVGstate));
	ctx->nstates++;
}

static function nvgRestore(ctx: NVGcontext): Void
{
	if (ctx.nstates <= 1)
		return;
	ctx.nstates--;
}

static function nvgReset(ctx: NVGcontext): Void
{
	var state: NVGstate = nvg__getState(ctx);
	memset(state, 0, sizeof(*state));

	nvg__setPaintColor(state.fill, nvgRGBA(255,255,255,255));
	nvg__setPaintColor(state.stroke, nvgRGBA(0,0,0,255));
	state.compositeOperation = nvg__compositeOperationState(NVG_SOURCE_OVER);
	state.shapeAntiAlias = 1;
	state.strokeWidth = 1.0;
	state.miterLimit = 10.0;
	state.lineCap = NVG_BUTT;
	state.lineJoin = NVG_MITER;
	state.alpha = 1.0;
	nvgTransformIdentity(state->xform);

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
static function nvgShapeAntiAlias(ctx: NVGcontext, enabled: Int): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.shapeAntiAlias = enabled;
}

static function nvgStrokeWidth(ctx: NVGcontext, width: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state->strokeWidth = width;
}

static function nvgMiterLimit(ctx: NVGcontext, limit: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.miterLimit = limit;
}

static function nvgLineCap(ctx: NVGcontext, cap: Int): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.lineCap = cap;
}

static function nvgLineJoin(ctx: NVGcontext, join: Int): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.lineJoin = join;
}

static function nvgGlobalAlpha(ctx: NVGcontext, alpha: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.alpha = alpha;
}

static function nvgTransform(ctx: NVGcontext, a: Float, b: Float, c: Float, d: Float, e: Float, f: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	float t[6] = { a, b, c, d, e, f };
	nvgTransformPremultiply(state.xform, t);
}

static function nvgResetTransform(ctx: NVGcontext): Void
{
	var state: NVGstate = nvg__getState(ctx);
	nvgTransformIdentity(state.xform);
}

static function nvgTranslate(ctx: NVGcontext, x: Float, y: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	float t[6];
	nvgTransformTranslate(t, x,y);
	nvgTransformPremultiply(state.xform, t);
}

static function nvgRotate(ctx: NVGcontext, angle: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	float t[6];
	nvgTransformRotate(t, angle);
	nvgTransformPremultiply(state.xform, t);
}

static function nvgSkewX(ctx: NVGcontext, angle: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	float t[6];
	nvgTransformSkewX(t, angle);
	nvgTransformPremultiply(state->xform, t);
}

static function nvgSkewY(ctx: NVGcontext, angle: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	float t[6];
	nvgTransformSkewY(t, angle);
	nvgTransformPremultiply(state->xform, t);
}

static function nvgScale(ctx: NVGcontext, x: Float, y: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	float t[6];
	nvgTransformScale(t, x,y);
	nvgTransformPremultiply(state->xform, t);
}

static function nvgCurrentTransform(ctx: NVGcontext, xform: Array<Float>): Void
{
	var state: NVGstate = nvg__getState(ctx);
	if (xform == NULL) return;
	memcpy(xform, state.xform, sizeof(float)*6);
}

static function nvgStrokeColor(ctx: NVGcontext, color: NVGcolor): Void
{
	var state: NVGstate = nvg__getState(ctx);
	nvg__setPaintColor(&state.stroke, color);
}

static function nvgStrokePaint(ctx: NVGcontext, paint: NVGpaint): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.stroke = paint;
	nvgTransformMultiply(state.stroke.xform, state.xform);
}

static function nvgFillColor(ctx: NVGcontext, color: NVGcolor): Void
{
	var state: NVGstate = nvg__getState(ctx);
	nvg__setPaintColor(state.fill, color);
}

static function nvgFillPaint(ctx: NVGcontext, paint: NVGpaint): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.fill = paint;
	nvgTransformMultiply(state.fill.xform, state.xform);
}

static function nvgCreateImage(ctx: NVGcontext, filename: String, imageFlags: Int): Int
{
	var w: Int; var h: Int; var n: Int; var image: Int;
	var img: Array<Int>;
	stbi_set_unpremultiply_on_load(1);
	stbi_convert_iphone_png_to_rgb(1);
	img = stbi_load(filename, &w, &h, &n, 4);
	if (img == NULL) {
//		printf("Failed to load %s - %s\n", filename, stbi_failure_reason());
		return 0;
	}
	image = nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
	stbi_image_free(img);
	return image;
}

static function nvgCreateImageMem(ctx: NVGcontext, imageFlags: Int, data: Array<Int>, ndata: Int): Int
{
	var w: Int; var h: Int; var n: Int; var image: Int;
	var img: Array<Int> = stbi_load_from_memory(data, ndata, &w, &h, &n, 4);
	if (img == null) {
//		printf("Failed to load %s - %s\n", filename, stbi_failure_reason());
		return 0;
	}
	image = nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
	stbi_image_free(img);
	return image;
}

static function nvgCreateImageRGBA(ctx: NVGcontext, w: Int, h: Int, imageFlags: Int, data: Array<Int>): Int
{
	return ctx.params.renderCreateTexture(ctx.params.userPtr, NVG_TEXTURE_RGBA, w, h, imageFlags, data);
}

static function nvgUpdateImage(ctx: NVGcontext, image: Int, data: Array<Int>): Void
{
	var w: Int; var h: Int;
	ctx.params.renderGetTextureSize(ctx.params.userPtr, image, &w, &h);
	ctx.params.renderUpdateTexture(ctx.params.userPtr, image, 0,0, w,h, data);
}

static function nvgImageSize(ctx: NVGcontext, image: Int, w: Ref<Int>, h: Ref<Int>): Void
{
	ctx.params.renderGetTextureSize(ctx.params.userPtr, image, w, h);
}

static function nvgDeleteImage(ctx: NVGcontext, image: Int): Void
{
	ctx.params.renderDeleteTexture(ctx.params.userPtr, image);
}

static function nvgLinearGradient(ctx: NVGcontext,
								  sx: Float, sy: Float, ex: Float, ey: Float,
								  icol: NVGcolor, ocol: NVGcolor): NVGpaint
{
	var p: NVGpaint;
	var dx: Float; var dy: Float; var d: Float;
	final var large: Float = 1e5;
	NVG_NOTUSED(ctx);
	memset(&p, 0, sizeof(p));

	// Calculate transform aligned to the line
	dx = ex - sx;
	dy = ey - sy;
	d = sqrtf(dx*dx + dy*dy);
	if (d > 0.0001f) {
		dx /= d;
		dy /= d;
	} else {
		dx = 0;
		dy = 1;
	}

	p.xform[0] = dy; p.xform[1] = -dx;
	p.xform[2] = dx; p.xform[3] = dy;
	p.xform[4] = sx - dx*large; p.xform[5] = sy - dy*large;

	p.extent[0] = large;
	p.extent[1] = large + d*0.5f;

	p.radius = 0.0f;

	p.feather = nvg__maxf(1.0f, d);

	p.innerColor = icol;
	p.outerColor = ocol;

	return p;
}

static function nvgRadialGradient(ctx: NVGcontext,
								  cx: Float, cy: Float, inr: Float, outr: Float,
								  icol: NVGcolor, ocol: NVGcolor): NVGpaint
{
	var p: NVGpaint;
	var r: Float = (inr+outr)*0.5;
	var f: Float = (outr-inr);
	NVG_NOTUSED(ctx);
	memset(&p, 0, sizeof(p));

	nvgTransformIdentity(p.xform);
	p.xform[4] = cx;
	p.xform[5] = cy;

	p.extent[0] = r;
	p.extent[1] = r;

	p.radius = r;

	p.feather = nvg__maxf(1.0f, f);

	p.innerColor = icol;
	p.outerColor = ocol;

	return p;
}

static function nvgBoxGradient(ctx: NVGcontext,
							   x: Float, y: Float, w: Float, h: Float, r: Float, f: Float,
							   icol: NVGcolor, ocol: NVGcolor): NVGpaint
{
	var p: NVGpaint;
	NVG_NOTUSED(ctx);
	memset(&p, 0, sizeof(p));

	nvgTransformIdentity(p.xform);
	p.xform[4] = x+w*0.5f;
	p.xform[5] = y+h*0.5f;

	p.extent[0] = w*0.5f;
	p.extent[1] = h*0.5f;

	p.radius = r;

	p.feather = nvg__maxf(1.0f, f);

	p.innerColor = icol;
	p.outerColor = ocol;

	return p;
}


static function nvgImagePattern(ctx: NVGcontext,
								cx: Float, cy: Float, w: Float, h: Float, angle: Float,
								image: Int, alpha: Float): NVGpaint
{
	var p: NVGpaint;
	NVG_NOTUSED(ctx);
	memset(&p, 0, sizeof(p));

	nvgTransformRotate(p.xform, angle);
	p.xform[4] = cx;
	p.xform[5] = cy;

	p.extent[0] = w;
	p.extent[1] = h;

	p.image = image;

	p.innerColor = p.outerColor = nvgRGBAf(1,1,1,alpha);

	return p;
}

// Scissoring
static function nvgScissor(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);

	w = nvg__maxf(0.0f, w);
	h = nvg__maxf(0.0f, h);

	nvgTransformIdentity(state->scissor.xform);
	state.scissor.xform[4] = x+w*0.5;
	state.scissor.xform[5] = y+h*0.5;
	nvgTransformMultiply(state.scissor.xform, state.xform);

	state.scissor.extent[0] = w*0.5;
	state.scissor.extent[1] = h*0.5;
}

static function nvg__isectRects(dst: Array<Float>,
							ax: Float, ay: Float, aw: Float, ah: Float,
							bx: Float, by: Float, bw: Float, bh: Float): Void
{
	var minx: Float = nvg__maxf(ax, bx);
	var miny: Float = nvg__maxf(ay, by);
	var maxx: Float = nvg__minf(ax+aw, bx+bw);
	var maxy: Float = nvg__minf(ay+ah, by+bh);
	dst[0] = minx;
	dst[1] = miny;
	dst[2] = nvg__maxf(0.0f, maxx - minx);
	dst[3] = nvg__maxf(0.0f, maxy - miny);
}

static function nvgIntersectScissor(ctx: NVGcontext, x: Float, y: Float, w: Float, h: Float): Void
{
	var state: NVGstate = nvg__getState(ctx);
	float pxform[6], invxorm[6];
	float rect[4];
	var ex: Float; var ey: Float; var tex: Float; var tey: Float;

	// If no previous scissor has been set, set the scissor as current scissor.
	if (state->scissor.extent[0] < 0) {
		nvgScissor(ctx, x, y, w, h);
		return;
	}

	// Transform the current scissor rect into current transform space.
	// If there is difference in rotation, this will be approximation.
	memcpy(pxform, state->scissor.xform, sizeof(float)*6);
	ex = state->scissor.extent[0];
	ey = state->scissor.extent[1];
	nvgTransformInverse(invxorm, state->xform);
	nvgTransformMultiply(pxform, invxorm);
	tex = ex*nvg__absf(pxform[0]) + ey*nvg__absf(pxform[2]);
	tey = ex*nvg__absf(pxform[1]) + ey*nvg__absf(pxform[3]);

	// Intersect rects.
	nvg__isectRects(rect, pxform[4]-tex,pxform[5]-tey,tex*2,tey*2, x,y,w,h);

	nvgScissor(ctx, rect[0], rect[1], rect[2], rect[3]);
}

static function nvgResetScissor(ctx: NVGcontext): Void
{
	var state: NVGstate = nvg__getState(ctx);
	memset(state.scissor.xform, 0, sizeof(state.scissor.xform));
	state.scissor.extent[0] = -1.0;
	state.scissor.extent[1] = -1.0;
}

// Global composite operation.
static function nvgGlobalCompositeOperation(ctx: NVGcontext, op: Int): Void
{
	var state: NVGstate = nvg__getState(ctx);
	state.compositeOperation = nvg__compositeOperationState(op);
}

static function nvgGlobalCompositeBlendFunc(ctx: NVGcontext, sfactor: Int, dfactor: Int): Void
{
	nvgGlobalCompositeBlendFuncSeparate(ctx, sfactor, dfactor, sfactor, dfactor);
}

static function nvgGlobalCompositeBlendFuncSeparate(ctx: NVGcontext, srcRGB: Int, dstRGB: Int, srcAlpha: Int, dstAlpha: Int): Void
{
	var op: NVGcompositeOperationState;
	op.srcRGB = srcRGB;
	op.dstRGB = dstRGB;
	op.srcAlpha = srcAlpha;
	op.dstAlpha = dstAlpha;

	var state: NVGstate = nvg__getState(ctx);
	state.compositeOperation = op;
}

static function nvg__ptEquals(x1: Float, y1: Float, x2: Float, y2: Float, tol: Float): Int
{
	var dx: Float = x2 - x1;
	var dy: Float = y2 - y1;
	return dx*dx + dy*dy < tol*tol;
}

static function nvg__distPtSeg(x: Float, y: Float, px: Float, py: Float, qx: Float, qy: Float): Float
{
	var pqx: Float; var pqy: Float; var dx: Float; var dy: Float; var d: Float; var t: Float;
	pqx = qx-px;
	pqy = qy-py;
	dx = x-px;
	dy = y-py;
	d = pqx*pqx + pqy*pqy;
	t = pqx*dx + pqy*dy;
	if (d > 0) t /= d;
	if (t < 0) t = 0;
	else if (t > 1) t = 1;
	dx = px + t*pqx - x;
	dy = py + t*pqy - y;
	return dx*dx + dy*dy;
}

static function nvg__appendCommands(ctx: NVGcontext, vals: Array<Float>, nvals: Int): Void
{
	var state: NVGstate = nvg__getState(ctx);
	var i: Int;

	if (ctx.ncommands+nvals > ctx.ccommands) {
		var commands: Array<Float>;
		var ccommands: Int = ctx.ncommands+nvals + ctx.ccommands/2;
		commands = (float*)realloc(ctx->commands, sizeof(float)*ccommands);
		if (commands == NULL) return;
		ctx.commands = commands;
		ctx.ccommands = ccommands;
	}

	if ((int)vals[0] != NVG_CLOSE && (int)vals[0] != NVG_WINDING) {
		ctx.commandx = vals[nvals-2];
		ctx.commandy = vals[nvals-1];
	}

	// transform commands
	i = 0;
	while (i < nvals) {
		var cmd: Int = (int)vals[i];
		switch (cmd) {
		case NVG_MOVETO:
			nvgTransformPoint(&vals[i+1],&vals[i+2], state->xform, vals[i+1],vals[i+2]);
			i += 3;
			break;
		case NVG_LINETO:
			nvgTransformPoint(&vals[i+1],&vals[i+2], state->xform, vals[i+1],vals[i+2]);
			i += 3;
			break;
		case NVG_BEZIERTO:
			nvgTransformPoint(&vals[i+1],&vals[i+2], state->xform, vals[i+1],vals[i+2]);
			nvgTransformPoint(&vals[i+3],&vals[i+4], state->xform, vals[i+3],vals[i+4]);
			nvgTransformPoint(&vals[i+5],&vals[i+6], state->xform, vals[i+5],vals[i+6]);
			i += 7;
			break;
		case NVG_CLOSE:
			i++;
			break;
		case NVG_WINDING:
			i += 2;
			break;
		default:
			i++;
		}
	}

	memcpy(&ctx.commands[ctx.ncommands], vals, nvals*sizeof(float));

	ctx.ncommands += nvals;
}


static function nvg__clearPathCache(ctx: NVGcontext): Void
{
	ctx.cache.npoints = 0;
	ctx.cache.npaths = 0;
}

static function nvg__lastPath(ctx: NVGcontext): NVGpath
{
	if (ctx.cache.npaths > 0)
		return &ctx.cache.paths[ctx.cache.npaths-1];
	return null;
}

static function nvg__addPath(ctx: NVGcontext): Void
{
	var path: NVGpath;
	if (ctx.cache.npaths+1 > ctx.cache.cpaths) {
		var paths: NVGpath;
		int cpaths = ctx.cache.npaths+1 + ctx.cache.cpaths/2;
		paths = (NVGpath*)realloc(ctx->cache->paths, sizeof(NVGpath)*cpaths);
		if (paths == null) return;
		ctx->cache->paths = paths;
		ctx->cache->cpaths = cpaths;
	}
	path = &ctx.cache.paths[ctx.cache.npaths];
	memset(path, 0, sizeof(*path));
	path.first = ctx.cache.npoints;
	path.winding = NVG_CCW;

	ctx.cache.npaths++;
}

static function nvg__lastPoint(ctx: NVGcontext): NVGpoint
{
	if (ctx.cache.npoints > 0)
		return &ctx.cache.points[ctx.cache.npoints-1];
	return null;
}

static function nvg__addPoint(ctx: NVGcontext, x: Float, y: Float, flags: Int): Void
{
	var path: NVGpath = nvg__lastPath(ctx);
	var pt: NVGpoint;
	if (path == null) return;

	if (path.count > 0 && ctx.cache.npoints > 0) {
		pt = nvg__lastPoint(ctx);
		if (nvg__ptEquals(pt.x,pt.y, x,y, ctx.distTol)) {
			pt.flags |= flags;
			return;
		}
	}

	if (ctx.cache.npoints+1 > ctx.cache.cpoints) {
		NVGpoint* points;
		var cpoints: Int = ctx.cache.npoints+1 + ctx.cache.cpoints/2;
		points = (NVGpoint*)realloc(ctx->cache->points, sizeof(NVGpoint)*cpoints);
		if (points == NULL) return;
		ctx->cache->points = points;
		ctx->cache->cpoints = cpoints;
	}

	pt = &ctx.cache.points[ctx.cache.npoints];
	memset(pt, 0, sizeof(*pt));
	pt.x = x;
	pt.y = y;
	pt.flags = (unsigned char)flags;

	ctx.cache.npoints++;
	path.count++;
}

static function nvg__closePath(ctx: NVGcontext): Void
{
	var path: NVGpath = nvg__lastPath(ctx);
	if (path == null) return;
	path.closed = 1;
}

static function nvg__pathWinding(ctx: NVGcontext, winding: Int): Void
{
	var path: NVGpath = nvg__lastPath(ctx);
	if (path == null) return;
	path.winding = winding;
}

static function nvg__getAverageScale(t: Array<Float>): Float
{
	var sx: Float = sqrtf(t[0]*t[0] + t[2]*t[2]);
	var sy: Float = sqrtf(t[1]*t[1] + t[3]*t[3]);
	return (sx + sy) * 0.5;
}

static function nvg__allocTempVerts(ctx: NVGcontext, nverts: Int): NVGvertex
{
	if (nverts > ctx->cache->cverts) {
		var verts: NVGvertex;
		int cverts = (nverts + 0xff) & ~0xff; // Round up to prevent allocations when things change just slightly.
		verts = (NVGvertex*)realloc(ctx->cache->verts, sizeof(NVGvertex)*cverts);
		if (verts == NULL) return NULL;
		ctx.cache.verts = verts;
		ctx.cache.cverts = cverts;
	}

	return ctx.cache.verts;
}

static function nvg__triarea2(ax: Float, ay: Float, bx: Float, by: Float, cx: Float, cy: Float): Float
{
	var abx: Float = bx - ax;
	var aby: Float = by - ay;
	var acx: Float = cx - ax;
	var acy: Float = cy - ay;
	return acx*aby - abx*acy;
}

static function nvg__polyArea(pts: NVGpoint, npts: Int): Float
{
	// int i;
	var area: Float = 0;
	for (i in 2...npts) {
		var a: NVGpoint = &pts[0];
		var b: NVGpoint = &pts[i-1];
		var c: NVGpoint = &pts[i];
		area += nvg__triarea2(a->x,a->y, b->x,b->y, c->x,c->y);
	}
	return area * 0.5;
}

static function nvg__polyReverse(pts: NVGpoint, npts: Int): Void
{
	var tmp: NVGpoint;
	var i: Int = 0; var j: Int = npts-1;
	while (i < j) {
		tmp = pts[i];
		pts[i] = pts[j];
		pts[j] = tmp;
		i++;
		j--;
	}
}


static function nvg__vset(vtx: NVGvertex, x: Float, y: Float, u: Float, v: Float): Void
{
	vtx.x = x;
	vtx.y = y;
	vtx.u = u;
	vtx.v = v;
}

static function nvg__tesselateBezier(ctx: NVGcontext,
								 x1: Float, y1: Float, x2: Float, y2: Float,
								 x3: Float, y3: Float, x4: Float, y4: Float,
								 level: Int, type: Int)
{
	var x12: Float; var y12: Float; var x23: Float; var y23: Float; var x34: Float; var y34: Float; var x123: Float; var y123: Float; var x234: Float; var y234: Float; var x1234: Float; var y1234: Float;
	var dx: Float; var dy: Float; var d2: Float; var d3: Float;

	if (level > 10) return;

	x12 = (x1+x2)*0.5f;
	y12 = (y1+y2)*0.5f;
	x23 = (x2+x3)*0.5f;
	y23 = (y2+y3)*0.5f;
	x34 = (x3+x4)*0.5f;
	y34 = (y3+y4)*0.5f;
	x123 = (x12+x23)*0.5f;
	y123 = (y12+y23)*0.5f;

	dx = x4 - x1;
	dy = y4 - y1;
	d2 = nvg__absf(((x2 - x4) * dy - (y2 - y4) * dx));
	d3 = nvg__absf(((x3 - x4) * dy - (y3 - y4) * dx));

	if ((d2 + d3)*(d2 + d3) < ctx.tessTol * (dx*dx + dy*dy)) {
		nvg__addPoint(ctx, x4, y4, type);
		return;
	}

/*	if (nvg__absf(x1+x3-x2-x2) + nvg__absf(y1+y3-y2-y2) + nvg__absf(x2+x4-x3-x3) + nvg__absf(y2+y4-y3-y3) < ctx->tessTol) {
		nvg__addPoint(ctx, x4, y4, type);
		return;
	}*/

	x234 = (x23+x34)*0.5f;
	y234 = (y23+y34)*0.5f;
	x1234 = (x123+x234)*0.5f;
	y1234 = (y123+y234)*0.5f;

	nvg__tesselateBezier(ctx, x1,y1, x12,y12, x123,y123, x1234,y1234, level+1, 0);
	nvg__tesselateBezier(ctx, x1234,y1234, x234,y234, x34,y34, x4,y4, level+1, type);
}

static function nvg__flattenPaths(ctx: NVGcontext): Void
{
	var cache: NVGpathCache = ctx.cache;
//	NVGstate* state = nvg__getState(ctx);
	var last: NVGpoint;
	var p0: NVGpoint;
	var p1: NVGpoint;
	var pts: NVGpoint;
	var path: NVGpath;
	var i: Int; var j: Int;
	var cp1: Array<Float>;
	var cp2: Array<Float>;
	var p: Array<Float>;
	var area: Float;

	if (cache->npaths > 0)
		return;

	// Flatten
	i = 0;
	while (i < ctx.ncommands) {
		var cmd: Int = (int)ctx.commands[i];
		switch (cmd) {
		case NVG_MOVETO:
			nvg__addPath(ctx);
			p = &ctx.commands[i+1];
			nvg__addPoint(ctx, p[0], p[1], NVG_PT_CORNER);
			i += 3;
			break;
		case NVG_LINETO:
			p = &ctx.commands[i+1];
			nvg__addPoint(ctx, p[0], p[1], NVG_PT_CORNER);
			i += 3;
			break;
		case NVG_BEZIERTO:
			last = nvg__lastPoint(ctx);
			if (last != NULL) {
				cp1 = &ctx.commands[i+1];
				cp2 = &ctx.commands[i+3];
				p = &ctx.commands[i+5];
				nvg__tesselateBezier(ctx, last.x,last.y, cp1[0],cp1[1], cp2[0],cp2[1], p[0],p[1], 0, NVG_PT_CORNER);
			}
			i += 7;
			break;
		case NVG_CLOSE:
			nvg__closePath(ctx);
			i++;
			break;
		case NVG_WINDING:
			nvg__pathWinding(ctx, (int)ctx.commands[i+1]);
			i += 2;
			break;
		default:
			i++;
		}
	}

	cache.bounds[0] = cache.bounds[1] = 1e6f;
	cache.bounds[2] = cache.bounds[3] = -1e6f;

	// Calculate the direction and length of line segments.
	for (j = 0; j < cache.npaths; j++) {
		path = &cache.paths[j];
		pts = &cache.points[path->first];

		// If the first and last points are the same, remove the last, mark as closed path.
		p0 = &pts[path.count-1];
		p1 = &pts[0];
		if (nvg__ptEquals(p0.x,p0.y, p1.x,p1.y, ctx.distTol)) {
			path.count--;
			p0 = &pts[path->count-1];
			path.closed = 1;
		}

		// Enforce winding.
		if (path.count > 2) {
			area = nvg__polyArea(pts, path.count);
			if (path->winding == NVG_CCW && area < 0.0f)
				nvg__polyReverse(pts, path.count);
			if (path->winding == NVG_CW && area > 0.0f)
				nvg__polyReverse(pts, path.count);
		}

		for(i = 0; i < path.count; i++) {
			// Calculate segment direction and length
			p0.dx = p1.x - p0.x;
			p0.dy = p1.y - p0.y;
			p0.len = nvg__normalize(&p0.dx, &p0.dy);
			// Update bounds
			cache.bounds[0] = nvg__minf(cache.bounds[0], p0.x);
			cache.bounds[1] = nvg__minf(cache.bounds[1], p0.y);
			cache.bounds[2] = nvg__maxf(cache.bounds[2], p0.x);
			cache.bounds[3] = nvg__maxf(cache.bounds[3], p0.y);
			// Advance
			p0 = p1++;
		}
	}
}

static function nvg__curveDivs(r: Float, arc: Float, tol: Float): Int
{
	var da: Float = acosf(r / (r + tol)) * 2.0;
	return nvg__maxi(2, (int)ceilf(arc / da));
}

static function nvg__chooseBevel(bevel: Int, p0: NVGpoint, p1: NVGpoint, w: Float,
							x0: Ref<Float>, y0: Ref<Float>, x1: Ref<Float>, y1: Ref<Float>)
{
	if (bevel) {
		*x0 = p1->x + p0->dy * w;
		*y0 = p1->y - p0->dx * w;
		*x1 = p1->x + p1->dy * w;
		*y1 = p1->y - p1->dx * w;
	} else {
		*x0 = p1->x + p1->dmx * w;
		*y0 = p1->y + p1->dmy * w;
		*x1 = p1->x + p1->dmx * w;
		*y1 = p1->y + p1->dmy * w;
	}
}

static function nvg__roundJoin(dst: NVGvertex, p0: NVGpoint, p1: NVGpoint,
								 lw: Float, rw: Float, lu: Float, ru: Float, ncap: Int,
								 fringe: Float): NVGvertex
{
	var i: Int; var n: Int;
	var dlx0: Float = p0->dy;
	var dly0: Float = -p0->dx;
	var dlx1: Float = p1->dy;
	var dly1: Float = -p1->dx;
	NVG_NOTUSED(fringe);

	if (p1.flags & NVG_PT_LEFT) {
		var lx0: Float; var ly0: Float; var lx1: Float; var ly1: Float; var a0: Float; var a1: Float;
		nvg__chooseBevel(p1->flags & NVG_PR_INNERBEVEL, p0, p1, lw, &lx0,&ly0, &lx1,&ly1);
		a0 = atan2f(-dly0, -dlx0);
		a1 = atan2f(-dly1, -dlx1);
		if (a1 > a0) a1 -= NVG_PI*2;

		nvg__vset(dst, lx0, ly0, lu,1); dst++;
		nvg__vset(dst, p1->x - dlx0*rw, p1->y - dly0*rw, ru,1); dst++;

		n = nvg__clampi((int)ceilf(((a0 - a1) / NVG_PI) * ncap), 2, ncap);
		for (i = 0; i < n; i++) {
			float u = i/(float)(n-1);
			float a = a0 + u*(a1-a0);
			float rx = p1->x + cosf(a) * rw;
			float ry = p1->y + sinf(a) * rw;
			nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;
			nvg__vset(dst, rx, ry, ru,1); dst++;
		}

		nvg__vset(dst, lx1, ly1, lu,1); dst++;
		nvg__vset(dst, p1->x - dlx1*rw, p1->y - dly1*rw, ru,1); dst++;

	} else {
		var rx0: Float; var ry0: Float; var rx1: Float; var ry1: Float; var a0: Float; var a1: Float;
		nvg__chooseBevel(p1->flags & NVG_PR_INNERBEVEL, p0, p1, -rw, &rx0,&ry0, &rx1,&ry1);
		a0 = atan2f(dly0, dlx0);
		a1 = atan2f(dly1, dlx1);
		if (a1 < a0) a1 += NVG_PI*2;

		nvg__vset(dst, p1->x + dlx0*rw, p1->y + dly0*rw, lu,1); dst++;
		nvg__vset(dst, rx0, ry0, ru,1); dst++;

		n = nvg__clampi((int)ceilf(((a1 - a0) / NVG_PI) * ncap), 2, ncap);
		for (i = 0; i < n; i++) {
			float u = i/(float)(n-1);
			float a = a0 + u*(a1-a0);
			float lx = p1->x + cosf(a) * lw;
			float ly = p1->y + sinf(a) * lw;
			nvg__vset(dst, lx, ly, lu,1); dst++;
			nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;
		}

		nvg__vset(dst, p1->x + dlx1*rw, p1->y + dly1*rw, lu,1); dst++;
		nvg__vset(dst, rx1, ry1, ru,1); dst++;

	}
	return dst;
}

static function nvg__bevelJoin(dst: NVGvertex, p0: NVGpoint, p1: NVGpoint,
										lw: Float, rw: Float, lu: Float, ru: Float, fringe: Float): NVGvertex
{
	var rx0: Float; var ry0: Float; var rx1 : Float; var ry1: Float;
	var lx0: Float; var ly0: Float; var lx1: Float; var ly1: Float;
	var dlx0: Float = p0.dy;
	var dly0: Float = -p0.dx;
	var dlx1: Float = p1.dy;
	var dly1: Float = -p1.dx;
	NVG_NOTUSED(fringe);

	if (p1->flags & NVG_PT_LEFT) {
		nvg__chooseBevel(p1->flags & NVG_PR_INNERBEVEL, p0, p1, lw, &lx0,&ly0, &lx1,&ly1);

		nvg__vset(dst, lx0, ly0, lu,1); dst++;
		nvg__vset(dst, p1.x - dlx0*rw, p1.y - dly0*rw, ru,1); dst++;

		if (p1->flags & NVG_PT_BEVEL) {
			nvg__vset(dst, lx0, ly0, lu,1); dst++;
			nvg__vset(dst, p1.x - dlx0*rw, p1.y - dly0*rw, ru,1); dst++;

			nvg__vset(dst, lx1, ly1, lu,1); dst++;
			nvg__vset(dst, p1.x - dlx1*rw, p1.y - dly1*rw, ru,1); dst++;
		} else {
			rx0 = p1.x - p1.dmx * rw;
			ry0 = p1.y - p1.dmy * rw;

			nvg__vset(dst, p1.x, p1.y, 0.5f,1); dst++;
			nvg__vset(dst, p1.x - dlx0*rw, p1.y - dly0*rw, ru,1); dst++;

			nvg__vset(dst, rx0, ry0, ru,1); dst++;
			nvg__vset(dst, rx0, ry0, ru,1); dst++;

			nvg__vset(dst, p1.x, p1.y, 0.5f,1); dst++;
			nvg__vset(dst, p1.x - dlx1*rw, p1.y - dly1*rw, ru,1); dst++;
		}

		nvg__vset(dst, lx1, ly1, lu,1); dst++;
		nvg__vset(dst, p1.x - dlx1*rw, p1.y - dly1*rw, ru,1); dst++;

	} else {
		nvg__chooseBevel(p1.flags & NVG_PR_INNERBEVEL, p0, p1, -rw, &rx0,&ry0, &rx1,&ry1);

		nvg__vset(dst, p1.x + dlx0*lw, p1.y + dly0*lw, lu,1); dst++;
		nvg__vset(dst, rx0, ry0, ru,1); dst++;

		if (p1->flags & NVG_PT_BEVEL) {
			nvg__vset(dst, p1.x + dlx0*lw, p1.y + dly0*lw, lu,1); dst++;
			nvg__vset(dst, rx0, ry0, ru,1); dst++;

			nvg__vset(dst, p1.x + dlx1*lw, p1.y + dly1*lw, lu,1); dst++;
			nvg__vset(dst, rx1, ry1, ru,1); dst++;
		} else {
			lx0 = p1.x + p1->dmx * lw;
			ly0 = p1.y + p1->dmy * lw;

			nvg__vset(dst, p1.x + dlx0*lw, p1.y + dly0*lw, lu,1); dst++;
			nvg__vset(dst, p1.x, p1.y, 0.5f,1); dst++;

			nvg__vset(dst, lx0, ly0, lu,1); dst++;
			nvg__vset(dst, lx0, ly0, lu,1); dst++;

			nvg__vset(dst, p1.x + dlx1*lw, p1.y + dly1*lw, lu,1); dst++;
			nvg__vset(dst, p1.x, p1.y, 0.5f,1); dst++;
		}

		nvg__vset(dst, p1.x + dlx1*lw, p1.y + dly1*lw, lu,1); dst++;
		nvg__vset(dst, rx1, ry1, ru,1); dst++;
	}

	return dst;
}

static function nvg__buttCapStart(dst: NVGvertex, p: NVGpoint,
									dx: Float, dy: Float, w: Float, d: Float,
									aa: Float, u0: Float, u1: Float): NVGvertex
{
	var px: Float = p.x - dx*d;
	var py: Float = p.y - dy*d;
	var dlx: Float = dy;
	var dly: Float = -dx;
	nvg__vset(dst, px + dlx*w - dx*aa, py + dly*w - dy*aa, u0,0); dst++;
	nvg__vset(dst, px - dlx*w - dx*aa, py - dly*w - dy*aa, u1,0); dst++;
	nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
	nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
	return dst;
}

static function nvg__buttCapEnd(dst: NVGvertex, p: NVGpoint,
								  dx: Float, dy: Float, w: Float, d: Float,
								  aa: Float, u0: Float, u1: Float): NVGvertex
{
	var px: Float = p.x + dx*d;
	var py: Float = p.y + dy*d;
	var dlx: Float = dy;
	var dly: Float = -dx;
	nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
	nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
	nvg__vset(dst, px + dlx*w + dx*aa, py + dly*w + dy*aa, u0,0); dst++;
	nvg__vset(dst, px - dlx*w + dx*aa, py - dly*w + dy*aa, u1,0); dst++;
	return dst;
}


static function nvg__roundCapStart(dst: NVGvertex, p: NVGpoint,
									 dx: Float, dy: Float, w: Float, ncap: Int,
									 aa: Float, u0: Float, u1: Float): NVGvertex
{
	//int i;
	var px: Float = p.x;
	var py: Float = p.y;
	var dlx: Float = dy;
	var dly: Float = -dx;
	NVG_NOTUSED(aa);
	for (i in 0...ncap) {
		var a: Float = i/(float)(ncap-1)*NVG_PI;
		var ax: Float = cosf(a) * w, ay = sinf(a) * w;
		nvg__vset(dst, px - dlx*ax - dx*ay, py - dly*ax - dy*ay, u0,1); dst++;
		nvg__vset(dst, px, py, 0.5f,1); dst++;
	}
	nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
	nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
	return dst;
}

static function nvg__roundCapEnd(dst: NVGvertex, p: NVGpoint,
								   dx: Float, dy: Float, w: Float, ncap: Int,
								   aa: Float, u0: Float, u1: Float): NVGvertex
{
	// int i;
	var px: Float = p.x;
	var py: Float = p.y;
	var dlx: Float = dy;
	var dly: Float = -dx;
	NVG_NOTUSED(aa);
	nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
	nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
	for (i in 0...ncap) {
		var a: Float = i/(float)(ncap-1)*NVG_PI;
		var ax: Float = cosf(a) * w, ay = sinf(a) * w;
		nvg__vset(dst, px, py, 0.5f,1); dst++;
		nvg__vset(dst, px - dlx*ax + dx*ay, py - dly*ax + dy*ay, u0,1); dst++;
	}
	return dst;
}


static function nvg__calculateJoins(ctx: NVGcontext, w: Float, lineJoin: Int, miterLimit: Float): Void
{
	var cache: NVGpathCache = ctx.cache;
	// var j: Int;
	var iw: Float = 0.0;

	if (w > 0.0) iw = 1.0 / w;

	// Calculate which joins needs extra vertices to append, and gather vertex count.
	for (i in 0...cache.npaths) {
		var path: NVGpath = &cache->paths[i];
		var pts: NVGpoint = &cache->points[path->first];
		var p0: NVGpoint = &pts[path->count-1];
		var p1: NVGpoint = &pts[0];
		var nleft: Int = 0;

		path.nbevel = 0;

		for (j in 0...path.count) {
			var dlx0: Float; var dly0: Float; var dlx1: Float; var dly1: Float; var dmr2: Float; var cross: Float; var limit: Float;
			dlx0 = p0.dy;
			dly0 = -p0.dx;
			dlx1 = p1.dy;
			dly1 = -p1.dx;
			// Calculate extrusions
			p1.dmx = (dlx0 + dlx1) * 0.5;
			p1.dmy = (dly0 + dly1) * 0.5;
			dmr2 = p1.dmx*p1.dmx + p1.dmy*p1.dmy;
			if (dmr2 > 0.000001) {
				var scale: Float = 1.0 / dmr2;
				if (scale > 600.0) {
					scale = 600.0;
				}
				p1.dmx *= scale;
				p1.dmy *= scale;
			}

			// Clear flags, but keep the corner.
			p1.flags = (p1.flags & NVG_PT_CORNER) ? NVG_PT_CORNER : 0;

			// Keep track of left turns.
			cross = p1.dx * p0.dy - p0.dx * p1.dy;
			if (cross > 0.0) {
				nleft++;
				p1.flags |= NVG_PT_LEFT;
			}

			// Calculate if we should use bevel or miter for inner join.
			limit = nvg__maxf(1.01f, nvg__minf(p0.len, p1.len) * iw);
			if ((dmr2 * limit*limit) < 1.0)
				p1.flags |= NVG_PR_INNERBEVEL;

			// Check to see if the corner needs to be beveled.
			if (p1.flags & NVG_PT_CORNER) {
				if ((dmr2 * miterLimit*miterLimit) < 1.0f || lineJoin == NVG_BEVEL || lineJoin == NVG_ROUND) {
					p1.flags |= NVG_PT_BEVEL;
				}
			}

			if ((p1.flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0)
				path.nbevel++;

			p0 = p1++;
		}

		path.convex = (nleft == path->count) ? 1 : 0;
	}
}


static function nvg__expandStroke(ctx: NVGcontext, w: Float, fringe: Float, lineCap: Int, lineJoin: Int, miterLimit: Float): Int
{
	var cache: NVGpathCache = ctx.cache;
	var verts: NVGvertex;
	var dst: NVGvertex;
	var cverts: Int;
	var aa: Float = fringe;//ctx->fringeWidth;
	var u0: Float = 0.0; var u1: Float = 1.0;
	var ncap: Int = nvg__curveDivs(w, NVG_PI, ctx.tessTol);	// Calculate divisions per half circle.

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
		NVGpath* path = &cache->paths[i];
		int loop = (path->closed == 0) ? 0 : 1;
		if (lineJoin == NVG_ROUND)
			cverts += (path->count + path.nbevel*(ncap+2) + 1) * 2; // plus one for loop
		else
			cverts += (path->count + path.nbevel*5 + 1) * 2; // plus one for loop
		if (loop == 0) {
			// space for caps
			if (lineCap == NVG_ROUND) {
				cverts += (ncap*2 + 2)*2;
			} else {
				cverts += (3+3)*2;
			}
		}
	}

	verts = nvg__allocTempVerts(ctx, cverts);
	if (verts == NULL) return 0;

	for (i in 0...cache.npaths) {
		var path: NVGpath = &cache.paths[i];
		var pts: NVGpoint = &cache.points[path->first];
		var p0: NVGpoint;
		var p1: NVGpoint;
		var s: Int; var e: Int; var loop: Int;
		var dx: Float; var dy: Float;

		path.fill = 0;
		path.nfill = 0;

		// Calculate fringe or stroke
		loop = (path.closed == 0) ? 0 : 1;
		dst = verts;
		path.stroke = dst;

		if (loop) {
			// Looping
			p0 = &pts[path.count-1];
			p1 = &pts[0];
			s = 0;
			e = path.count;
		} else {
			// Add cap
			p0 = &pts[0];
			p1 = &pts[1];
			s = 1;
			e = path.count-1;
		}

		if (loop == 0) {
			// Add cap
			dx = p1.x - p0.x;
			dy = p1.y - p0.y;
			nvg__normalize(&dx, &dy);
			if (lineCap == NVG_BUTT)
				dst = nvg__buttCapStart(dst, p0, dx, dy, w, -aa*0.5f, aa, u0, u1);
			else if (lineCap == NVG_BUTT || lineCap == NVG_SQUARE)
				dst = nvg__buttCapStart(dst, p0, dx, dy, w, w-aa, aa, u0, u1);
			else if (lineCap == NVG_ROUND)
				dst = nvg__roundCapStart(dst, p0, dx, dy, w, ncap, aa, u0, u1);
		}

		for (j in s...e) {
			if ((p1.flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0) {
				if (lineJoin == NVG_ROUND) {
					dst = nvg__roundJoin(dst, p0, p1, w, w, u0, u1, ncap, aa);
				} else {
					dst = nvg__bevelJoin(dst, p0, p1, w, w, u0, u1, aa);
				}
			} else {
				nvg__vset(dst, p1->x + (p1->dmx * w), p1->y + (p1->dmy * w), u0,1); dst++;
				nvg__vset(dst, p1->x - (p1->dmx * w), p1->y - (p1->dmy * w), u1,1); dst++;
			}
			p0 = p1++;
		}

		if (loop) {
			// Loop it
			nvg__vset(dst, verts[0].x, verts[0].y, u0,1); dst++;
			nvg__vset(dst, verts[1].x, verts[1].y, u1,1); dst++;
		} else {
			// Add cap
			dx = p1.x - p0.x;
			dy = p1.y - p0.y;
			nvg__normalize(&dx, &dy);
			if (lineCap == NVG_BUTT)
				dst = nvg__buttCapEnd(dst, p1, dx, dy, w, -aa*0.5, aa, u0, u1);
			else if (lineCap == NVG_BUTT || lineCap == NVG_SQUARE)
				dst = nvg__buttCapEnd(dst, p1, dx, dy, w, w-aa, aa, u0, u1);
			else if (lineCap == NVG_ROUND)
				dst = nvg__roundCapEnd(dst, p1, dx, dy, w, ncap, aa, u0, u1);
		}

		path->nstroke = (int)(dst - verts);

		verts = dst;
	}

	return 1;
}

static function nvg__expandFill(ctx: NVGcontext, w: Float, lineJoin: Int, miterLimit: Float): Int
{
	var cache: NVGpathCache = ctx.cache;
	var verts: NVGvertex;
	var dst: NVGvertex;
	var cverts: Int; var convex: Int;
	var aa: Float = ctx.fringeWidth;
	var fringe: Int = w > 0.0;

	nvg__calculateJoins(ctx, w, lineJoin, miterLimit);

	// Calculate max vertex usage.
	cverts = 0;
	for (i in 0...cache.npaths) {
		var path: NVGpath = &cache.paths[i];
		cverts += path->count + path.nbevel + 1;
		if (fringe)
			cverts += (path.count + path.nbevel*5 + 1) * 2; // plus one for loop
	}

	verts = nvg__allocTempVerts(ctx, cverts);
	if (verts == null) return 0;

	convex = cache.npaths == 1 && cache.paths[0].convex;

	for (i in 0...cache.npaths) {
		var path: NVGpath = &cache->paths[i];
		var pts: NVGpoint = &cache->points[path->first];
		var p0: NVGpoint;
		var p1: NVGpoint;
		var rw: Float; var lw: Float; var woff: Float;
		var ru: Float; var lu: Float;

		// Calculate shape vertices.
		woff = 0.5*aa;
		dst = verts;
		path.fill = dst;

		if (fringe) {
			// Looping
			p0 = &pts[path.count-1];
			p1 = &pts[0];
			for (j in 0...path.count) {
				if (p1.flags & NVG_PT_BEVEL) {
					var dlx0: Float = p0.dy;
					var dly0: Float = -p0.dx;
					var dlx1: Float = p1.dy;
					var dly1: Float = -p1.dx;
					if (p1->flags & NVG_PT_LEFT) {
						var lx: Float = p1.x + p1.dmx * woff;
						var ly: Float = p1.y + p1.dmy * woff;
						nvg__vset(dst, lx, ly, 0.5,1); dst++;
					} else {
						var lx0: Float = p1.x + dlx0 * woff;
						var ly0: Float = p1.y + dly0 * woff;
						var lx1: Float = p1.x + dlx1 * woff;
						var ly1: Float = p1.y + dly1 * woff;
						nvg__vset(dst, lx0, ly0, 0.5,1); dst++;
						nvg__vset(dst, lx1, ly1, 0.5,1); dst++;
					}
				} else {
					nvg__vset(dst, p1.x + (p1.dmx * woff), p1.y + (p1.dmy * woff), 0.5,1); dst++;
				}
				p0 = p1++;
			}
		} else {
			for (j in 0...path.count) {
				nvg__vset(dst, pts[j].x, pts[j].y, 0.5,1);
				dst++;
			}
		}

		path.nfill = (int)(dst - verts);
		verts = dst;

		// Calculate fringe
		if (fringe) {
			lw = w + woff;
			rw = w - woff;
			lu = 0;
			ru = 1;
			dst = verts;
			path.stroke = dst;

			// Create only half a fringe for convex shapes so that
			// the shape can be rendered without stenciling.
			if (convex) {
				lw = woff;	// This should generate the same vertex as fill inset above.
				lu = 0.5f;	// Set outline fade at middle.
			}

			// Looping
			p0 = &pts[path.count-1];
			p1 = &pts[0];

			for (j in 0...path.count) {
				if ((p1.flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0) {
					dst = nvg__bevelJoin(dst, p0, p1, lw, rw, lu, ru, ctx.fringeWidth);
				} else {
					nvg__vset(dst, p1.x + (p1.dmx * lw), p1.y + (p1.dmy * lw), lu,1); dst++;
					nvg__vset(dst, p1.x - (p1.dmx * rw), p1.y - (p1.dmy * rw), ru,1); dst++;
				}
				p0 = p1++;
			}

			// Loop it
			nvg__vset(dst, verts[0].x, verts[0].y, lu,1); dst++;
			nvg__vset(dst, verts[1].x, verts[1].y, ru,1); dst++;

			path.nstroke = (int)(dst - verts);
			verts = dst;
		} else {
			path.stroke = null;
			path.nstroke = 0;
		}
	}

	return 1;
}


// Draw
static function nvgBeginPath(ctx: NVGcontext): Void
{
	ctx.ncommands = 0;
	nvg__clearPathCache(ctx);
}

static function nvgMoveTo(ctx: NVGcontext, x: Float, y: Float): Void
{
	float vals[] = { NVG_MOVETO, x, y };
	nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

static function nvgLineTo(ctx: NVGcontext, x: Float, y: Float): Void
{
	float vals[] = { NVG_LINETO, x, y };
	nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

static function nvgBezierTo(ctx: NVGcontext, c1x: Float, c1y: Float, c2x: Float, c2y: Float, x: Float, y: Float): Void
{
	float vals[] = { NVG_BEZIERTO, c1x, c1y, c2x, c2y, x, y };
	nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

static function nvgQuadTo(ctx: NVGcontext, cx: Float, cy: Float, x: Float, y: Float): Void
{
    var x0: Float = ctx.commandx;
    var y0: Float = ctx.commandy;
    float vals[] = { NVG_BEZIERTO,
        x0 + 2.0/3.0*(cx - x0), y0 + 2.0/3.0*(cy - y0),
        x + 2.0/3.0*(cx - x), y + 2.0/3.0*(cy - y),
        x, y };
    nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

static function nvgArcTo(ctx: NVGcontext, x1: Float, y1: Float, x2: Float, y2: Float, radius: Float): Void
{
	var x0: Float = ctx.commandx;
	var y0: Float = ctx.commandy;
	var dx0: Float; var dy0: Float; var dx1: Float; var dy1: Float; var a: Float; var d: Float; var cx: Float; var cy: Float; var a0: Float; var a1: Float;
	var dir: Int;

	if (ctx.ncommands == 0) {
		return;
	}

	// Handle degenerate cases.
	if (nvg__ptEquals(x0,y0, x1,y1, ctx.distTol) ||
		nvg__ptEquals(x1,y1, x2,y2, ctx.distTol) ||
		nvg__distPtSeg(x1,y1, x0,y0, x2,y2) < ctx.distTol*ctx.distTol ||
		radius < ctx.distTol) {
		nvgLineTo(ctx, x1,y1);
		return;
	}

	// Calculate tangential circle to lines (x0,y0)-(x1,y1) and (x1,y1)-(x2,y2).
	dx0 = x0-x1;
	dy0 = y0-y1;
	dx1 = x2-x1;
	dy1 = y2-y1;
	nvg__normalize(&dx0,&dy0);
	nvg__normalize(&dx1,&dy1);
	a = nvg__acosf(dx0*dx1 + dy0*dy1);
	d = radius / nvg__tanf(a/2.0);

//	printf("a=%f° d=%f\n", a/NVG_PI*180.0f, d);

	if (d > 10000.0) {
		nvgLineTo(ctx, x1,y1);
		return;
	}

	if (nvg__cross(dx0,dy0, dx1,dy1) > 0.0) {
		cx = x1 + dx0*d + dy0*radius;
		cy = y1 + dy0*d + -dx0*radius;
		a0 = nvg__atan2f(dx0, -dy0);
		a1 = nvg__atan2f(-dx1, dy1);
		dir = NVG_CW;
//		printf("CW c=(%f, %f) a0=%f° a1=%f°\n", cx, cy, a0/NVG_PI*180.0f, a1/NVG_PI*180.0f);
	} else {
		cx = x1 + dx0*d + -dy0*radius;
		cy = y1 + dy0*d + dx0*radius;
		a0 = nvg__atan2f(-dx0, dy0);
		a1 = nvg__atan2f(dx1, -dy1);
		dir = NVG_CCW;
//		printf("CCW c=(%f, %f) a0=%f° a1=%f°\n", cx, cy, a0/NVG_PI*180.0f, a1/NVG_PI*180.0f);
	}

	nvgArc(ctx, cx, cy, radius, a0, a1, dir);
}

static function nvgClosePath(ctx: NVGcontext): Void
{
	float vals[] = { NVG_CLOSE };
	nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

static function nvgPathWinding(ctx: NVGcontext, dir: Int): Void
{
	float vals[] = { NVG_WINDING, (float)dir };
	nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

static function nvgArc(ctx: NVGcontext, cx: Float, cy: Float, r: Float, a0: Float, a1: Float, dir: Int)
{
	var a: Float = 0; var da: Float = 0; var hda: Float = 0; var kappa: Float = 0;
	var dx: Float = 0; var dy: Float = 0; var x: Float = 0; var y: Float = 0; var tanx: Float = 0; var tany: Float = 0;
	var px: Float = 0; var py: Float = 0; var ptanx: Float = 0; var ptany: Float = 0;
	float vals[3 + 5*7 + 100];
	var i: Int; var ndivs: Int; var nvals: Int;
	var move: Int = ctx.ncommands > 0 ? NVG_LINETO : NVG_MOVETO;

	// Clamp angles
	da = a1 - a0;
	if (dir == NVG_CW) {
		if (nvg__absf(da) >= NVG_PI*2) {
			da = NVG_PI*2;
		} else {
			while (da < 0.0f) da += NVG_PI*2;
		}
	} else {
		if (nvg__absf(da) >= NVG_PI*2) {
			da = -NVG_PI*2;
		} else {
			while (da > 0.0f) da -= NVG_PI*2;
		}
	}

	// Split arc into max 90 degree segments.
	ndivs = nvg__maxi(1, nvg__mini((int)(nvg__absf(da) / (NVG_PI*0.5f) + 0.5f), 5));
	hda = (da / (float)ndivs) / 2.0f;
	kappa = nvg__absf(4.0f / 3.0f * (1.0f - nvg__cosf(hda)) / nvg__sinf(hda));

	if (dir == NVG_CCW)
		kappa = -kappa;

	nvals = 0;
	for (i = 0; i <= ndivs; i++) {
		a = a0 + da * (i/(float)ndivs);
		dx = nvg__cosf(a);
		dy = nvg__sinf(a);
		x = cx + dx*r;
		y = cy + dy*r;
		tanx = -dy*r*kappa;
		tany = dx*r*kappa;

		if (i == 0) {
			vals[nvals++] = (float)move;
			vals[nvals++] = x;
			vals[nvals++] = y;
		} else {
			vals[nvals++] = NVG_BEZIERTO;
			vals[nvals++] = px+ptanx;
			vals[nvals++] = py+ptany;
			vals[nvals++] = x-tanx;
			vals[nvals++] = y-tany;
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

void nvgRect(NVGcontext* ctx, float x, float y, float w, float h)
{
	float vals[] = {
		NVG_MOVETO, x,y,
		NVG_LINETO, x,y+h,
		NVG_LINETO, x+w,y+h,
		NVG_LINETO, x+w,y,
		NVG_CLOSE
	};
	nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

void nvgRoundedRect(NVGcontext* ctx, float x, float y, float w, float h, float r)
{
	nvgRoundedRectVarying(ctx, x, y, w, h, r, r, r, r);
}

void nvgRoundedRectVarying(NVGcontext* ctx, float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft)
{
	if(radTopLeft < 0.1f && radTopRight < 0.1f && radBottomRight < 0.1f && radBottomLeft < 0.1f) {
		nvgRect(ctx, x, y, w, h);
		return;
	} else {
		float halfw = nvg__absf(w)*0.5f;
		float halfh = nvg__absf(h)*0.5f;
		float rxBL = nvg__minf(radBottomLeft, halfw) * nvg__signf(w), ryBL = nvg__minf(radBottomLeft, halfh) * nvg__signf(h);
		float rxBR = nvg__minf(radBottomRight, halfw) * nvg__signf(w), ryBR = nvg__minf(radBottomRight, halfh) * nvg__signf(h);
		float rxTR = nvg__minf(radTopRight, halfw) * nvg__signf(w), ryTR = nvg__minf(radTopRight, halfh) * nvg__signf(h);
		float rxTL = nvg__minf(radTopLeft, halfw) * nvg__signf(w), ryTL = nvg__minf(radTopLeft, halfh) * nvg__signf(h);
		float vals[] = {
			NVG_MOVETO, x, y + ryTL,
			NVG_LINETO, x, y + h - ryBL,
			NVG_BEZIERTO, x, y + h - ryBL*(1 - NVG_KAPPA90), x + rxBL*(1 - NVG_KAPPA90), y + h, x + rxBL, y + h,
			NVG_LINETO, x + w - rxBR, y + h,
			NVG_BEZIERTO, x + w - rxBR*(1 - NVG_KAPPA90), y + h, x + w, y + h - ryBR*(1 - NVG_KAPPA90), x + w, y + h - ryBR,
			NVG_LINETO, x + w, y + ryTR,
			NVG_BEZIERTO, x + w, y + ryTR*(1 - NVG_KAPPA90), x + w - rxTR*(1 - NVG_KAPPA90), y, x + w - rxTR, y,
			NVG_LINETO, x + rxTL, y,
			NVG_BEZIERTO, x + rxTL*(1 - NVG_KAPPA90), y, x, y + ryTL*(1 - NVG_KAPPA90), x, y + ryTL,
			NVG_CLOSE
		};
		nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
	}
}

void nvgEllipse(NVGcontext* ctx, float cx, float cy, float rx, float ry)
{
	float vals[] = {
		NVG_MOVETO, cx-rx, cy,
		NVG_BEZIERTO, cx-rx, cy+ry*NVG_KAPPA90, cx-rx*NVG_KAPPA90, cy+ry, cx, cy+ry,
		NVG_BEZIERTO, cx+rx*NVG_KAPPA90, cy+ry, cx+rx, cy+ry*NVG_KAPPA90, cx+rx, cy,
		NVG_BEZIERTO, cx+rx, cy-ry*NVG_KAPPA90, cx+rx*NVG_KAPPA90, cy-ry, cx, cy-ry,
		NVG_BEZIERTO, cx-rx*NVG_KAPPA90, cy-ry, cx-rx, cy-ry*NVG_KAPPA90, cx-rx, cy,
		NVG_CLOSE
	};
	nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

void nvgCircle(NVGcontext* ctx, float cx, float cy, float r)
{
	nvgEllipse(ctx, cx,cy, r,r);
}

void nvgDebugDumpPathCache(NVGcontext* ctx)
{
	const NVGpath* path;
	int i, j;

	printf("Dumping %d cached paths\n", ctx->cache->npaths);
	for (i = 0; i < ctx->cache->npaths; i++) {
		path = &ctx->cache->paths[i];
		printf(" - Path %d\n", i);
		if (path->nfill) {
			printf("   - fill: %d\n", path->nfill);
			for (j = 0; j < path->nfill; j++)
				printf("%f\t%f\n", path->fill[j].x, path->fill[j].y);
		}
		if (path->nstroke) {
			printf("   - stroke: %d\n", path->nstroke);
			for (j = 0; j < path->nstroke; j++)
				printf("%f\t%f\n", path->stroke[j].x, path->stroke[j].y);
		}
	}
}

void nvgFill(NVGcontext* ctx)
{
	NVGstate* state = nvg__getState(ctx);
	const NVGpath* path;
	NVGpaint fillPaint = state->fill;
	int i;

	nvg__flattenPaths(ctx);
	if (ctx->params.edgeAntiAlias && state->shapeAntiAlias)
		nvg__expandFill(ctx, ctx->fringeWidth, NVG_MITER, 2.4f);
	else
		nvg__expandFill(ctx, 0.0f, NVG_MITER, 2.4f);

	// Apply global alpha
	fillPaint.innerColor.a *= state->alpha;
	fillPaint.outerColor.a *= state->alpha;

	ctx->params.renderFill(ctx->params.userPtr, &fillPaint, state->compositeOperation, &state->scissor, ctx->fringeWidth,
						   ctx->cache->bounds, ctx->cache->paths, ctx->cache->npaths);

	// Count triangles
	for (i = 0; i < ctx->cache->npaths; i++) {
		path = &ctx->cache->paths[i];
		ctx->fillTriCount += path->nfill-2;
		ctx->fillTriCount += path->nstroke-2;
		ctx->drawCallCount += 2;
	}
}

void nvgStroke(NVGcontext* ctx)
{
	NVGstate* state = nvg__getState(ctx);
	float scale = nvg__getAverageScale(state->xform);
	float strokeWidth = nvg__clampf(state->strokeWidth * scale, 0.0f, 200.0f);
	NVGpaint strokePaint = state->stroke;
	const NVGpath* path;
	int i;


	if (strokeWidth < ctx->fringeWidth) {
		// If the stroke width is less than pixel size, use alpha to emulate coverage.
		// Since coverage is area, scale by alpha*alpha.
		float alpha = nvg__clampf(strokeWidth / ctx->fringeWidth, 0.0f, 1.0f);
		strokePaint.innerColor.a *= alpha*alpha;
		strokePaint.outerColor.a *= alpha*alpha;
		strokeWidth = ctx->fringeWidth;
	}

	// Apply global alpha
	strokePaint.innerColor.a *= state->alpha;
	strokePaint.outerColor.a *= state->alpha;

	nvg__flattenPaths(ctx);

	if (ctx->params.edgeAntiAlias && state->shapeAntiAlias)
		nvg__expandStroke(ctx, strokeWidth*0.5f, ctx->fringeWidth, state->lineCap, state->lineJoin, state->miterLimit);
	else
		nvg__expandStroke(ctx, strokeWidth*0.5f, 0.0f, state->lineCap, state->lineJoin, state->miterLimit);

	ctx->params.renderStroke(ctx->params.userPtr, &strokePaint, state->compositeOperation, &state->scissor, ctx->fringeWidth,
							 strokeWidth, ctx->cache->paths, ctx->cache->npaths);

	// Count triangles
	for (i = 0; i < ctx->cache->npaths; i++) {
		path = &ctx->cache->paths[i];
		ctx->strokeTriCount += path->nstroke-2;
		ctx->drawCallCount++;
	}
}

// Add fonts
int nvgCreateFont(NVGcontext* ctx, const char* name, const char* filename)
{
	return fonsAddFont(ctx->fs, name, filename, 0);
}

int nvgCreateFontAtIndex(NVGcontext* ctx, const char* name, const char* filename, const int fontIndex)
{
	return fonsAddFont(ctx->fs, name, filename, fontIndex);
}

int nvgCreateFontMem(NVGcontext* ctx, const char* name, unsigned char* data, int ndata, int freeData)
{
	return fonsAddFontMem(ctx->fs, name, data, ndata, freeData, 0);
}

int nvgCreateFontMemAtIndex(NVGcontext* ctx, const char* name, unsigned char* data, int ndata, int freeData, const int fontIndex)
{
	return fonsAddFontMem(ctx->fs, name, data, ndata, freeData, fontIndex);
}

int nvgFindFont(NVGcontext* ctx, const char* name)
{
	if (name == NULL) return -1;
	return fonsGetFontByName(ctx->fs, name);
}


int nvgAddFallbackFontId(NVGcontext* ctx, int baseFont, int fallbackFont)
{
	if(baseFont == -1 || fallbackFont == -1) return 0;
	return fonsAddFallbackFont(ctx->fs, baseFont, fallbackFont);
}

int nvgAddFallbackFont(NVGcontext* ctx, const char* baseFont, const char* fallbackFont)
{
	return nvgAddFallbackFontId(ctx, nvgFindFont(ctx, baseFont), nvgFindFont(ctx, fallbackFont));
}

void nvgResetFallbackFontsId(NVGcontext* ctx, int baseFont)
{
	fonsResetFallbackFont(ctx->fs, baseFont);
}

void nvgResetFallbackFonts(NVGcontext* ctx, const char* baseFont)
{
	nvgResetFallbackFontsId(ctx, nvgFindFont(ctx, baseFont));
}

// State setting
void nvgFontSize(NVGcontext* ctx, float size)
{
	NVGstate* state = nvg__getState(ctx);
	state->fontSize = size;
}

void nvgFontBlur(NVGcontext* ctx, float blur)
{
	NVGstate* state = nvg__getState(ctx);
	state->fontBlur = blur;
}

void nvgTextLetterSpacing(NVGcontext* ctx, float spacing)
{
	NVGstate* state = nvg__getState(ctx);
	state->letterSpacing = spacing;
}

void nvgTextLineHeight(NVGcontext* ctx, float lineHeight)
{
	NVGstate* state = nvg__getState(ctx);
	state->lineHeight = lineHeight;
}

void nvgTextAlign(NVGcontext* ctx, int align)
{
	NVGstate* state = nvg__getState(ctx);
	state->textAlign = align;
}

void nvgFontFaceId(NVGcontext* ctx, int font)
{
	NVGstate* state = nvg__getState(ctx);
	state->fontId = font;
}

void nvgFontFace(NVGcontext* ctx, const char* font)
{
	NVGstate* state = nvg__getState(ctx);
	state->fontId = fonsGetFontByName(ctx->fs, font);
}

static float nvg__quantize(float a, float d)
{
	return ((int)(a / d + 0.5f)) * d;
}

static float nvg__getFontScale(NVGstate* state)
{
	return nvg__minf(nvg__quantize(nvg__getAverageScale(state->xform), 0.01f), 4.0f);
}

static void nvg__flushTextTexture(NVGcontext* ctx)
{
	int dirty[4];

	if (fonsValidateTexture(ctx->fs, dirty)) {
		int fontImage = ctx->fontImages[ctx->fontImageIdx];
		// Update texture
		if (fontImage != 0) {
			int iw, ih;
			const unsigned char* data = fonsGetTextureData(ctx->fs, &iw, &ih);
			int x = dirty[0];
			int y = dirty[1];
			int w = dirty[2] - dirty[0];
			int h = dirty[3] - dirty[1];
			ctx->params.renderUpdateTexture(ctx->params.userPtr, fontImage, x,y, w,h, data);
		}
	}
}

static int nvg__allocTextAtlas(NVGcontext* ctx)
{
	int iw, ih;
	nvg__flushTextTexture(ctx);
	if (ctx->fontImageIdx >= NVG_MAX_FONTIMAGES-1)
		return 0;
	// if next fontImage already have a texture
	if (ctx->fontImages[ctx->fontImageIdx+1] != 0)
		nvgImageSize(ctx, ctx->fontImages[ctx->fontImageIdx+1], &iw, &ih);
	else { // calculate the new font image size and create it.
		nvgImageSize(ctx, ctx->fontImages[ctx->fontImageIdx], &iw, &ih);
		if (iw > ih)
			ih *= 2;
		else
			iw *= 2;
		if (iw > NVG_MAX_FONTIMAGE_SIZE || ih > NVG_MAX_FONTIMAGE_SIZE)
			iw = ih = NVG_MAX_FONTIMAGE_SIZE;
		ctx->fontImages[ctx->fontImageIdx+1] = ctx->params.renderCreateTexture(ctx->params.userPtr, NVG_TEXTURE_ALPHA, iw, ih, 0, NULL);
	}
	++ctx->fontImageIdx;
	fonsResetAtlas(ctx->fs, iw, ih);
	return 1;
}

static void nvg__renderText(NVGcontext* ctx, NVGvertex* verts, int nverts)
{
	NVGstate* state = nvg__getState(ctx);
	NVGpaint paint = state->fill;

	// Render triangles.
	paint.image = ctx->fontImages[ctx->fontImageIdx];

	// Apply global alpha
	paint.innerColor.a *= state->alpha;
	paint.outerColor.a *= state->alpha;

	ctx->params.renderTriangles(ctx->params.userPtr, &paint, state->compositeOperation, &state->scissor, verts, nverts, ctx->fringeWidth);

	ctx->drawCallCount++;
	ctx->textTriCount += nverts/3;
}

float nvgText(NVGcontext* ctx, float x, float y, const char* string, const char* end)
{
	NVGstate* state = nvg__getState(ctx);
	FONStextIter iter, prevIter;
	FONSquad q;
	NVGvertex* verts;
	float scale = nvg__getFontScale(state) * ctx->devicePxRatio;
	float invscale = 1.0f / scale;
	int cverts = 0;
	int nverts = 0;

	if (end == NULL)
		end = string + strlen(string);

	if (state->fontId == FONS_INVALID) return x;

	fonsSetSize(ctx->fs, state->fontSize*scale);
	fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
	fonsSetBlur(ctx->fs, state->fontBlur*scale);
	fonsSetAlign(ctx->fs, state->textAlign);
	fonsSetFont(ctx->fs, state->fontId);

	cverts = nvg__maxi(2, (int)(end - string)) * 6; // conservative estimate.
	verts = nvg__allocTempVerts(ctx, cverts);
	if (verts == NULL) return x;

	fonsTextIterInit(ctx->fs, &iter, x*scale, y*scale, string, end, FONS_GLYPH_BITMAP_REQUIRED);
	prevIter = iter;
	while (fonsTextIterNext(ctx->fs, &iter, &q)) {
		float c[4*2];
		if (iter.prevGlyphIndex == -1) { // can not retrieve glyph?
			if (nverts != 0) {
				nvg__renderText(ctx, verts, nverts);
				nverts = 0;
			}
			if (!nvg__allocTextAtlas(ctx))
				break; // no memory :(
			iter = prevIter;
			fonsTextIterNext(ctx->fs, &iter, &q); // try again
			if (iter.prevGlyphIndex == -1) // still can not find glyph?
				break;
		}
		prevIter = iter;
		// Transform corners.
		nvgTransformPoint(&c[0],&c[1], state->xform, q.x0*invscale, q.y0*invscale);
		nvgTransformPoint(&c[2],&c[3], state->xform, q.x1*invscale, q.y0*invscale);
		nvgTransformPoint(&c[4],&c[5], state->xform, q.x1*invscale, q.y1*invscale);
		nvgTransformPoint(&c[6],&c[7], state->xform, q.x0*invscale, q.y1*invscale);
		// Create triangles
		if (nverts+6 <= cverts) {
			nvg__vset(&verts[nverts], c[0], c[1], q.s0, q.t0); nverts++;
			nvg__vset(&verts[nverts], c[4], c[5], q.s1, q.t1); nverts++;
			nvg__vset(&verts[nverts], c[2], c[3], q.s1, q.t0); nverts++;
			nvg__vset(&verts[nverts], c[0], c[1], q.s0, q.t0); nverts++;
			nvg__vset(&verts[nverts], c[6], c[7], q.s0, q.t1); nverts++;
			nvg__vset(&verts[nverts], c[4], c[5], q.s1, q.t1); nverts++;
		}
	}

	// TODO: add back-end bit to do this just once per frame.
	nvg__flushTextTexture(ctx);

	nvg__renderText(ctx, verts, nverts);

	return iter.nextx / scale;
}

void nvgTextBox(NVGcontext* ctx, float x, float y, float breakRowWidth, const char* string, const char* end)
{
	NVGstate* state = nvg__getState(ctx);
	NVGtextRow rows[2];
	int nrows = 0, i;
	int oldAlign = state->textAlign;
	int haling = state->textAlign & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
	int valign = state->textAlign & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE);
	float lineh = 0;

	if (state->fontId == FONS_INVALID) return;

	nvgTextMetrics(ctx, NULL, NULL, &lineh);

	state->textAlign = NVG_ALIGN_LEFT | valign;

	while ((nrows = nvgTextBreakLines(ctx, string, end, breakRowWidth, rows, 2))) {
		for (i = 0; i < nrows; i++) {
			NVGtextRow* row = &rows[i];
			if (haling & NVG_ALIGN_LEFT)
				nvgText(ctx, x, y, row->start, row->end);
			else if (haling & NVG_ALIGN_CENTER)
				nvgText(ctx, x + breakRowWidth*0.5f - row->width*0.5f, y, row->start, row->end);
			else if (haling & NVG_ALIGN_RIGHT)
				nvgText(ctx, x + breakRowWidth - row->width, y, row->start, row->end);
			y += lineh * state->lineHeight;
		}
		string = rows[nrows-1].next;
	}

	state->textAlign = oldAlign;
}

int nvgTextGlyphPositions(NVGcontext* ctx, float x, float y, const char* string, const char* end, NVGglyphPosition* positions, int maxPositions)
{
	NVGstate* state = nvg__getState(ctx);
	float scale = nvg__getFontScale(state) * ctx->devicePxRatio;
	float invscale = 1.0f / scale;
	FONStextIter iter, prevIter;
	FONSquad q;
	int npos = 0;

	if (state->fontId == FONS_INVALID) return 0;

	if (end == NULL)
		end = string + strlen(string);

	if (string == end)
		return 0;

	fonsSetSize(ctx->fs, state->fontSize*scale);
	fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
	fonsSetBlur(ctx->fs, state->fontBlur*scale);
	fonsSetAlign(ctx->fs, state->textAlign);
	fonsSetFont(ctx->fs, state->fontId);

	fonsTextIterInit(ctx->fs, &iter, x*scale, y*scale, string, end, FONS_GLYPH_BITMAP_OPTIONAL);
	prevIter = iter;
	while (fonsTextIterNext(ctx->fs, &iter, &q)) {
		if (iter.prevGlyphIndex < 0 && nvg__allocTextAtlas(ctx)) { // can not retrieve glyph?
			iter = prevIter;
			fonsTextIterNext(ctx->fs, &iter, &q); // try again
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

enum NVGcodepointType {
	NVG_SPACE,
	NVG_NEWLINE,
	NVG_CHAR,
	NVG_CJK_CHAR,
};

int nvgTextBreakLines(NVGcontext* ctx, const char* string, const char* end, float breakRowWidth, NVGtextRow* rows, int maxRows)
{
	NVGstate* state = nvg__getState(ctx);
	float scale = nvg__getFontScale(state) * ctx->devicePxRatio;
	float invscale = 1.0f / scale;
	FONStextIter iter, prevIter;
	FONSquad q;
	int nrows = 0;
	float rowStartX = 0;
	float rowWidth = 0;
	float rowMinX = 0;
	float rowMaxX = 0;
	const char* rowStart = NULL;
	const char* rowEnd = NULL;
	const char* wordStart = NULL;
	float wordStartX = 0;
	float wordMinX = 0;
	const char* breakEnd = NULL;
	float breakWidth = 0;
	float breakMaxX = 0;
	int type = NVG_SPACE, ptype = NVG_SPACE;
	unsigned int pcodepoint = 0;

	if (maxRows == 0) return 0;
	if (state->fontId == FONS_INVALID) return 0;

	if (end == NULL)
		end = string + strlen(string);

	if (string == end) return 0;

	fonsSetSize(ctx->fs, state->fontSize*scale);
	fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
	fonsSetBlur(ctx->fs, state->fontBlur*scale);
	fonsSetAlign(ctx->fs, state->textAlign);
	fonsSetFont(ctx->fs, state->fontId);

	breakRowWidth *= scale;

	fonsTextIterInit(ctx->fs, &iter, 0, 0, string, end, FONS_GLYPH_BITMAP_OPTIONAL);
	prevIter = iter;
	while (fonsTextIterNext(ctx->fs, &iter, &q)) {
		if (iter.prevGlyphIndex < 0 && nvg__allocTextAtlas(ctx)) { // can not retrieve glyph?
			iter = prevIter;
			fonsTextIterNext(ctx->fs, &iter, &q); // try again
		}
		prevIter = iter;
		switch (iter.codepoint) {
			case 9:			// \t
			case 11:		// \v
			case 12:		// \f
			case 32:		// space
			case 0x00a0:	// NBSP
				type = NVG_SPACE;
				break;
			case 10:		// \n
				type = pcodepoint == 13 ? NVG_SPACE : NVG_NEWLINE;
				break;
			case 13:		// \r
				type = pcodepoint == 10 ? NVG_SPACE : NVG_NEWLINE;
				break;
			case 0x0085:	// NEL
				type = NVG_NEWLINE;
				break;
			default:
				if ((iter.codepoint >= 0x4E00 && iter.codepoint <= 0x9FFF) ||
					(iter.codepoint >= 0x3000 && iter.codepoint <= 0x30FF) ||
					(iter.codepoint >= 0xFF00 && iter.codepoint <= 0xFFEF) ||
					(iter.codepoint >= 0x1100 && iter.codepoint <= 0x11FF) ||
					(iter.codepoint >= 0x3130 && iter.codepoint <= 0x318F) ||
					(iter.codepoint >= 0xAC00 && iter.codepoint <= 0xD7AF))
					type = NVG_CJK_CHAR;
				else
					type = NVG_CHAR;
				break;
		}

		if (type == NVG_NEWLINE) {
			// Always handle new lines.
			rows[nrows].start = rowStart != NULL ? rowStart : iter.str;
			rows[nrows].end = rowEnd != NULL ? rowEnd : iter.str;
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
			rowStart = NULL;
			rowEnd = NULL;
			rowWidth = 0;
			rowMinX = rowMaxX = 0;
		} else {
			if (rowStart == NULL) {
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
			} else {
				float nextWidth = iter.nextx - rowStartX;

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
					} else {
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
	if (rowStart != NULL) {
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

float nvgTextBounds(NVGcontext* ctx, float x, float y, const char* string, const char* end, float* bounds)
{
	NVGstate* state = nvg__getState(ctx);
	float scale = nvg__getFontScale(state) * ctx->devicePxRatio;
	float invscale = 1.0f / scale;
	float width;

	if (state->fontId == FONS_INVALID) return 0;

	fonsSetSize(ctx->fs, state->fontSize*scale);
	fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
	fonsSetBlur(ctx->fs, state->fontBlur*scale);
	fonsSetAlign(ctx->fs, state->textAlign);
	fonsSetFont(ctx->fs, state->fontId);

	width = fonsTextBounds(ctx->fs, x*scale, y*scale, string, end, bounds);
	if (bounds != NULL) {
		// Use line bounds for height.
		fonsLineBounds(ctx->fs, y*scale, &bounds[1], &bounds[3]);
		bounds[0] *= invscale;
		bounds[1] *= invscale;
		bounds[2] *= invscale;
		bounds[3] *= invscale;
	}
	return width * invscale;
}

void nvgTextBoxBounds(NVGcontext* ctx, float x, float y, float breakRowWidth, const char* string, const char* end, float* bounds)
{
	NVGstate* state = nvg__getState(ctx);
	NVGtextRow rows[2];
	float scale = nvg__getFontScale(state) * ctx->devicePxRatio;
	float invscale = 1.0f / scale;
	int nrows = 0, i;
	int oldAlign = state->textAlign;
	int haling = state->textAlign & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
	int valign = state->textAlign & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE);
	float lineh = 0, rminy = 0, rmaxy = 0;
	float minx, miny, maxx, maxy;

	if (state->fontId == FONS_INVALID) {
		if (bounds != NULL)
			bounds[0] = bounds[1] = bounds[2] = bounds[3] = 0.0f;
		return;
	}

	nvgTextMetrics(ctx, NULL, NULL, &lineh);

	state->textAlign = NVG_ALIGN_LEFT | valign;

	minx = maxx = x;
	miny = maxy = y;

	fonsSetSize(ctx->fs, state->fontSize*scale);
	fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
	fonsSetBlur(ctx->fs, state->fontBlur*scale);
	fonsSetAlign(ctx->fs, state->textAlign);
	fonsSetFont(ctx->fs, state->fontId);
	fonsLineBounds(ctx->fs, 0, &rminy, &rmaxy);
	rminy *= invscale;
	rmaxy *= invscale;

	while ((nrows = nvgTextBreakLines(ctx, string, end, breakRowWidth, rows, 2))) {
		for (i = 0; i < nrows; i++) {
			NVGtextRow* row = &rows[i];
			float rminx, rmaxx, dx = 0;
			// Horizontal bounds
			if (haling & NVG_ALIGN_LEFT)
				dx = 0;
			else if (haling & NVG_ALIGN_CENTER)
				dx = breakRowWidth*0.5f - row->width*0.5f;
			else if (haling & NVG_ALIGN_RIGHT)
				dx = breakRowWidth - row->width;
			rminx = x + row->minx + dx;
			rmaxx = x + row->maxx + dx;
			minx = nvg__minf(minx, rminx);
			maxx = nvg__maxf(maxx, rmaxx);
			// Vertical bounds.
			miny = nvg__minf(miny, y + rminy);
			maxy = nvg__maxf(maxy, y + rmaxy);

			y += lineh * state->lineHeight;
		}
		string = rows[nrows-1].next;
	}

	state->textAlign = oldAlign;

	if (bounds != NULL) {
		bounds[0] = minx;
		bounds[1] = miny;
		bounds[2] = maxx;
		bounds[3] = maxy;
	}
}

void nvgTextMetrics(NVGcontext* ctx, float* ascender, float* descender, float* lineh)
{
	NVGstate* state = nvg__getState(ctx);
	float scale = nvg__getFontScale(state) * ctx->devicePxRatio;
	float invscale = 1.0f / scale;

	if (state->fontId == FONS_INVALID) return;

	fonsSetSize(ctx->fs, state->fontSize*scale);
	fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
	fonsSetBlur(ctx->fs, state->fontBlur*scale);
	fonsSetAlign(ctx->fs, state->textAlign);
	fonsSetFont(ctx->fs, state->fontId);

	fonsVertMetrics(ctx->fs, ascender, descender, lineh);
	if (ascender != NULL)
		*ascender *= invscale;
	if (descender != NULL)
		*descender *= invscale;
	if (lineh != NULL)
		*lineh *= invscale;
}
// vim: ft=c nu noet ts=4
}