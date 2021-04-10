package nanovg;

import kha.graphics4.IndexBuffer;
import kha.math.FastMatrix3;
import kha.graphics4.VertexStructure;
import haxe.ds.Vector;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.VertexBuffer;
import kha.Shaders;

class KhaContext {
	public var pipeline: PipelineState;
	public var structure: VertexStructure;
	public var tex: TextureUnit;
	public var viewSize: ConstantLocation;

	var scissorMat: ConstantLocation;
	var paintMat: ConstantLocation;
	var innerCol: ConstantLocation;
	var outerCol: ConstantLocation;
	var scissorExt: ConstantLocation;
	var scissorScale: ConstantLocation;
	var extent: ConstantLocation;
	var radius: ConstantLocation;
	var feather: ConstantLocation;
	var strokeMult: ConstantLocation;
	var strokeThr: ConstantLocation;
	var texType: ConstantLocation;
	var type: ConstantLocation;

	public var textures = new Array<KhaTexture>();
	public var view0: Float;
	public var view1: Float;
	public var ntextures: Int;
	public var ctextures: Int;
	public var textureId: Int;
	public var vertBuf: VertexBuffer;
	public var stripIndexBuf: IndexBuffer;
	public var fanIndexBuf: IndexBuffer;

	public var fragSize: Int;
	public var flags: Int;

	public var calls: Vector<KhaCall>;
	public var ccalls: Int;
	public var ncalls: Int;
	public var paths: Pointer<KhaPath>;
	public var cpaths: Int;
	public var npaths: Int;
	public var verts: Pointer<NVGvertex>;
	public var cverts: Int;
	public var nverts: Int;
	public var uniforms: Vector<KhaFragUniforms>;
	public var cuniforms: Int;
	public var nuniforms: Int;

	public var g: Graphics;

	public function new() {
		pipeline = new PipelineState();
		pipeline.fragmentShader = Shaders.fill_frag;
		pipeline.vertexShader = Shaders.fill_vert;
		structure = new VertexStructure();
		structure.add("vertex", Float2);
		structure.add("tcoord", Float2);
		pipeline.inputLayout = [structure];
		pipeline.cullMode = CounterClockwise;
		pipeline.stencilMode = Always;
		pipeline.stencilBothPass = Keep;
		pipeline.stencilDepthFail = Keep;
		pipeline.stencilFail = Keep;
		pipeline.stencilReferenceValue = Static(0);
		pipeline.stencilReadMask = 0xffffffff;
		pipeline.stencilWriteMask = 0xffffffff;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.alphaBlendSource = BlendOne;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		pipeline.compile();

		tex = pipeline.getTextureUnit("tex");
		viewSize = pipeline.getConstantLocation("viewSize");
		scissorMat = pipeline.getConstantLocation("scissorMat");
		paintMat = pipeline.getConstantLocation("paintMat");
		innerCol = pipeline.getConstantLocation("innerCol");
		outerCol = pipeline.getConstantLocation("outerCol");
		scissorExt = pipeline.getConstantLocation("scissorExt");
		scissorScale = pipeline.getConstantLocation("scissorScale");
		extent = pipeline.getConstantLocation("extent");
		radius = pipeline.getConstantLocation("radius");
		feather = pipeline.getConstantLocation("feather");
		strokeMult = pipeline.getConstantLocation("strokeMult");
		strokeThr = pipeline.getConstantLocation("strokeThr");
		texType = pipeline.getConstantLocation("texType");
		type = pipeline.getConstantLocation("type");

		textures[0] = null;
	}

	public function setConstants(frag: KhaFragUniforms): Void {
		g.setMatrix3(scissorMat,
			new FastMatrix3(frag.scissorMat[0], frag.scissorMat[1], frag.scissorMat[2], frag.scissorMat[3], frag.scissorMat[4], frag.scissorMat[5],
				frag.scissorMat[6], frag.scissorMat[7], frag.scissorMat[8]));
		g.setMatrix3(paintMat,
			new FastMatrix3(frag.paintMat[0], frag.paintMat[1], frag.paintMat[2], frag.paintMat[3], frag.paintMat[4], frag.paintMat[5], frag.paintMat[6],
				frag.paintMat[7], frag.paintMat[8]));
		g.setFloat4(innerCol, frag.innerCol.r, frag.innerCol.g, frag.innerCol.b, frag.innerCol.a);
		g.setFloat4(outerCol, frag.outerCol.r, frag.outerCol.g, frag.outerCol.b, frag.outerCol.a);
		g.setFloat2(scissorExt, frag.scissorExt[0], frag.scissorExt[1]);
		g.setFloat2(scissorScale, frag.scissorScale[0], frag.scissorScale[1]);
		g.setFloat2(extent, frag.extent[0], frag.extent[1]);
		g.setFloat(radius, frag.radius);
		g.setFloat(feather, frag.feather);
		g.setFloat(strokeMult, frag.strokeMult);
		g.setFloat(strokeThr, frag.strokeThr);
		g.setInt(texType, frag.texType);
		g.setInt(type, frag.type);
	}
}
