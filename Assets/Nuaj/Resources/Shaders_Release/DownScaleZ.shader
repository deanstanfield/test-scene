// This shader is simply used to downscale the Z-Buffer for modules that render in downscaled resolution
//
Shader "Nuaj/DownScaleZ"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "black" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }

		// Pass #0 Very simple downscale : sample a single value...
		//
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [glstate_matrix_texture0]
"!!ARBvp1.0
OPTION NV_vertex_program3;
PARAM c[9] = { state.matrix.mvp.row[0..3],
		state.matrix.texture[0].row[0..3],
		{ 0 } };
TEMP R0;
TEMP RC, HC;
BB0:
MOV   R0.zw, c[8].x;
MOV   R0.xy, vertex.texcoord[0];
DP4   result.texcoord[0].x, R0, c[4];
DP4   result.texcoord[0].y, R0, c[5];
MOV   result.texcoord[0].zw, c[8].x;
DP4   result.position.w, vertex.position, c[3];
DP4   result.position.z, vertex.position, c[2];
DP4   result.position.y, vertex.position, c[1];
DP4   result.position.x, vertex.position, c[0];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [glstate_matrix_texture0]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
def c8, 0.00000000, 0, 0, 0
dcl_position0 v0
dcl_texcoord0 v1
mov r0.zw, c8.x
mov r0.xy, v1
dp4 o1.x, r0, c4
dp4 o1.y, r0, c5
mov o1.zw, c8.x
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Vector 0 [_CameraData]
SetTexture 0 [_CameraDepthTexture] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[1] = { program.local[0] };
TEMP R0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
ADDR  R0.x, c[0].w, -c[0].z;
RCPR  R0.y, R0.x;
MULR  R0.y, R0, c[0].w;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R0.x, R0.y, -R0;
RCPR  R0.x, R0.x;
MULR  R0.y, R0, c[0].z;
MULR  oCol, R0.y, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 0 [_CameraData]
SetTexture 0 [_CameraDepthTexture] 2D

"ps_3_0
dcl_2d s0
dcl_texcoord0 v0.xyzw
add r0.x, c0.w, -c0.z
rcp r0.y, r0.x
mul r0.y, r0, c0.w
texldl r0.x, v0, s0
add r0.x, r0.y, -r0
rcp r0.z, r0.x
mul r0.x, r0.y, c0.z
mul oC0, r0.x, r0.z

"
}

}

		}
	}
	Fallback off
}
