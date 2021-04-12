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

class Uniforms {
	public var tex: TextureUnit;
	public var viewSize: ConstantLocation;

	public var scissorMat: ConstantLocation;
	public var paintMat: ConstantLocation;
	public var innerCol: ConstantLocation;
	public var outerCol: ConstantLocation;
	public var scissorExt: ConstantLocation;
	public var scissorScale: ConstantLocation;
	public var extent: ConstantLocation;
	public var radius: ConstantLocation;
	public var feather: ConstantLocation;
	public var strokeMult: ConstantLocation;
	public var strokeThr: ConstantLocation;
	public var texType: ConstantLocation;
	public var type: ConstantLocation;

	public function new() {}
}

class KhaContext {
	public var pipeline: PipelineState;
	public var pipelineFill0: PipelineState;
	public var pipelineFill1: PipelineState;
	public var pipelineFill2: PipelineState;
	public var structure: VertexStructure;
	public var uniformsBase: Uniforms;
	public var uniformsFill0: Uniforms;
	public var uniformsFill1: Uniforms;
	public var uniformsFill2: Uniforms;

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
		structure = new VertexStructure();
		structure.add("vertex", Float2);
		structure.add("tcoord", Float2);

		pipeline = createPipeline();
		pipeline.compile();

		pipelineFill0 = createPipeline();
		pipelineFill0.stencilFrontWriteMask = 0xff;
		pipelineFill0.stencilBackWriteMask = 0xff;
		pipelineFill0.stencilFrontMode = Always;
		pipelineFill0.stencilBackMode = Always;
		pipelineFill0.stencilFrontReferenceValue = Static(0);
		pipelineFill0.stencilBackReferenceValue = Static(0);
		pipelineFill0.stencilFrontReadMask = 0xff;
		pipelineFill0.stencilBackReadMask = 0xff;
		pipelineFill0.stencilFrontFail = Keep;
		pipelineFill0.stencilFrontDepthFail = Keep;
		pipelineFill0.stencilFrontBothPass = IncrementWrap;
		pipelineFill0.stencilBackFail = Keep;
		pipelineFill0.stencilBackDepthFail = Keep;
		pipelineFill0.stencilBackBothPass = DecrementWrap;
		pipelineFill0.colorWriteMaskRed = false;
		pipelineFill0.colorWriteMaskGreen = false;
		pipelineFill0.colorWriteMaskBlue = false;
		pipelineFill0.colorWriteMaskAlpha = false;
		pipelineFill0.compile();

		pipelineFill1 = createPipeline();
		pipelineFill1.stencilFrontWriteMask = 0xff;
		pipelineFill1.stencilBackWriteMask = 0xff;
		pipelineFill1.stencilFrontMode = Equal;
		pipelineFill1.stencilBackMode = Equal;
		pipelineFill1.stencilFrontReferenceValue = Static(0);
		pipelineFill1.stencilBackReferenceValue = Static(0);
		pipelineFill1.stencilFrontReadMask = 0xff;
		pipelineFill1.stencilBackReadMask = 0xff;
		pipelineFill1.stencilFrontFail = Keep;
		pipelineFill1.stencilFrontDepthFail = Keep;
		pipelineFill1.stencilFrontBothPass = Keep;
		pipelineFill1.stencilBackFail = Keep;
		pipelineFill1.stencilBackDepthFail = Keep;
		pipelineFill1.stencilBackBothPass = Keep;
		pipelineFill1.colorWriteMaskRed = true;
		pipelineFill1.colorWriteMaskGreen = true;
		pipelineFill1.colorWriteMaskBlue = true;
		pipelineFill1.colorWriteMaskAlpha = true;
		pipelineFill1.compile();

		pipelineFill2 = createPipeline();
		pipelineFill2.stencilFrontWriteMask = 0xff;
		pipelineFill2.stencilBackWriteMask = 0xff;
		pipelineFill2.stencilFrontMode = NotEqual;
		pipelineFill2.stencilBackMode = NotEqual;
		pipelineFill2.stencilFrontReferenceValue = Static(0);
		pipelineFill2.stencilBackReferenceValue = Static(0);
		pipelineFill2.stencilFrontReadMask = 0xff;
		pipelineFill2.stencilBackReadMask = 0xff;
		pipelineFill2.stencilFrontFail = Zero;
		pipelineFill2.stencilFrontDepthFail = Zero;
		pipelineFill2.stencilFrontBothPass = Zero;
		pipelineFill2.stencilBackFail = Zero;
		pipelineFill2.stencilBackDepthFail = Zero;
		pipelineFill2.stencilBackBothPass = Zero;
		pipelineFill2.colorWriteMaskRed = true;
		pipelineFill2.colorWriteMaskGreen = true;
		pipelineFill2.colorWriteMaskBlue = true;
		pipelineFill2.colorWriteMaskAlpha = true;
		pipelineFill2.compile();

		uniformsBase = createUniforms(pipeline);
		uniformsFill0 = createUniforms(pipelineFill0);
		uniformsFill1 = createUniforms(pipelineFill1);
		uniformsFill2 = createUniforms(pipelineFill2);

		textures[0] = null;
	}

	function createUniforms(pipeline: PipelineState): Uniforms {
		var uniforms = new Uniforms();
		uniforms.tex = pipeline.getTextureUnit("tex");
		uniforms.viewSize = pipeline.getConstantLocation("viewSize");
		uniforms.scissorMat = pipeline.getConstantLocation("scissorMat");
		uniforms.paintMat = pipeline.getConstantLocation("paintMat");
		uniforms.innerCol = pipeline.getConstantLocation("innerCol");
		uniforms.outerCol = pipeline.getConstantLocation("outerCol");
		uniforms.scissorExt = pipeline.getConstantLocation("scissorExt");
		uniforms.scissorScale = pipeline.getConstantLocation("scissorScale");
		uniforms.extent = pipeline.getConstantLocation("extent");
		uniforms.radius = pipeline.getConstantLocation("radius");
		uniforms.feather = pipeline.getConstantLocation("feather");
		uniforms.strokeMult = pipeline.getConstantLocation("strokeMult");
		uniforms.strokeThr = pipeline.getConstantLocation("strokeThr");
		uniforms.texType = pipeline.getConstantLocation("texType");
		uniforms.type = pipeline.getConstantLocation("type");
		return uniforms;
	}

	function createPipeline(): PipelineState {
		var pipeline = new PipelineState();
		pipeline.fragmentShader = Shaders.fill_frag;
		pipeline.vertexShader = Shaders.fill_vert;
		pipeline.inputLayout = [structure];
		pipeline.cullMode = None; // TODO
		pipeline.stencilFrontMode = Always;
		pipeline.stencilFrontBothPass = Keep;
		pipeline.stencilFrontDepthFail = Keep;
		pipeline.stencilFrontFail = Keep;
		pipeline.stencilFrontReferenceValue = Static(0);
		pipeline.stencilFrontReadMask = 0xffffffff;
		pipeline.stencilFrontWriteMask = 0xffffffff;
		pipeline.stencilBackMode = Always;
		pipeline.stencilBackBothPass = Keep;
		pipeline.stencilBackDepthFail = Keep;
		pipeline.stencilBackFail = Keep;
		pipeline.stencilBackReferenceValue = Static(0);
		pipeline.stencilBackReadMask = 0xffffffff;
		pipeline.stencilBackWriteMask = 0xffffffff;
		pipeline.blendSource = BlendOne;
		pipeline.blendDestination = InverseSourceAlpha;
		pipeline.alphaBlendSource = BlendOne;
		pipeline.alphaBlendDestination = InverseSourceAlpha;
		return pipeline;
	}

	public function setConstants(uniforms: Uniforms, frag: KhaFragUniforms): Void {
		g.setMatrix3(uniforms.scissorMat,
			new FastMatrix3(frag.scissorMat[0], frag.scissorMat[1], frag.scissorMat[2], frag.scissorMat[3], frag.scissorMat[4], frag.scissorMat[5],
				frag.scissorMat[6], frag.scissorMat[7], frag.scissorMat[8]));
		g.setMatrix3(uniforms.paintMat,
			new FastMatrix3(frag.paintMat[0], frag.paintMat[1], frag.paintMat[2], frag.paintMat[3], frag.paintMat[4], frag.paintMat[5], frag.paintMat[6],
				frag.paintMat[7], frag.paintMat[8]));
		g.setFloat4(uniforms.innerCol, frag.innerCol.r, frag.innerCol.g, frag.innerCol.b, frag.innerCol.a);
		g.setFloat4(uniforms.outerCol, frag.outerCol.r, frag.outerCol.g, frag.outerCol.b, frag.outerCol.a);
		g.setFloat2(uniforms.scissorExt, frag.scissorExt[0], frag.scissorExt[1]);
		g.setFloat2(uniforms.scissorScale, frag.scissorScale[0], frag.scissorScale[1]);
		g.setFloat2(uniforms.extent, frag.extent[0], frag.extent[1]);
		g.setFloat(uniforms.radius, frag.radius);
		g.setFloat(uniforms.feather, frag.feather);
		g.setFloat(uniforms.strokeMult, frag.strokeMult);
		g.setFloat(uniforms.strokeThr, frag.strokeThr);
		g.setInt(uniforms.texType, frag.texType);
		g.setInt(uniforms.type, frag.type);
	}
}
