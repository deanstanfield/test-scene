// This shader is responsible for rendering 3 tiny environment maps
// . The first map renders the sky without the clouds and is used to compute the ambient sky light for clouds
// . The second map renders the sky with the clouds and is used to compute the ambient sky light for the scene
// . The third map renders the sun with the clouds and is used to compute the directional sun light to use for the scene
//
Shader "Hidden/Nuaj/RenderSkyEnvironmentNone"
{
	Properties
	{
		_TexCloudLayer0( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer1( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer2( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer3( "Base (RGB)", 2D ) = "white" {}
		_TexBackground( "Base (RGB)", 2D ) = "black" {}
	}

	SubShader
	{
		Tags { "Queue" = "Overlay-1" }
		ZTest Off			// http://unity3d.com/support/documentation/Components/SL-CullAndDepth.html
		Cull Off
		ZWrite Off
		Fog { Mode off }	// http://unity3d.com/support/documentation/Components/SL-Fog.html
		AlphaTest Off		// http://unity3d.com/support/documentation/Components/SL-AlphaTest.html
		Blend Off			// http://unity3d.com/support/documentation/Components/SL-Blend.html


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 renders the sky WITHOUT clouds
		// This envmap value will be used to light clouds
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
SetTexture 0 [_TexBackground] 2D
Float 0 [_LuminanceScale]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 0.001, 1 } };
TEMP R0;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   H0.xyz, fragment.texcoord[0], texture[0], 2D;
MOVH  H0.w, c[1].y;
MOVR  R0.x, c[1];
MAXR  R0.y, H0.x, H0;
MAXR  R0.y, H0.z, R0;
MOVH  oCol, H0;
SLTRC HC.x, c[0], R0;
MOVH  oCol(EQ.x), H1;
RCPR  R0.z, R0.y;
MULR  H0.xyz, H0, R0.z;
MULR  H0.w, R0.y, c[0].x;
SGERC HC.x, c[0], R0;
MOVH  oCol(NE.x), H0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_TexBackground] 2D
Float 0 [_LuminanceScale]

"ps_3_0
dcl_2d s0
def c1, -0.00100000, 1.00000000, 0.00000000, 0
dcl_texcoord0 v0.xyzw
texldl r0.xyz, v0, s0
max r0.w, r0.x, r0.y
max r2.y, r0.z, r0.w
mov r2.x, c0
mov r0.w, c1.y
add r2.x, c1, r2
cmp_pp r1, r2.x, r1, r0
rcp r2.z, r2.y
mul r0.xyz, r0, r2.z
mul r0.w, r2.y, c0.x
cmp_pp r2.x, r2, c1.y, c1.z
cmp_pp oC0, -r2.x, r1, r0

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 renders the sky WITH clouds
		// This envmap value will be used as the scene's ambient term
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
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 4 [_TexBackground] 2D
Float 0 [_LuminanceScale]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 0.001, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
TEX   R3, fragment.texcoord[0], texture[3], 2D;
TEX   R2, fragment.texcoord[0], texture[2], 2D;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
MADR  R2.xyz, R2.w, R3, R2;
MADR  R1.xyz, R1.w, R2, R1;
MADR  R1.xyz, R0.w, R1, R0;
MULR  R3.x, R0.w, R1.w;
MULR  R1.w, R3.x, R2;
TEX   R0.xyz, fragment.texcoord[0], texture[4], 2D;
MULR  R0.w, R1, R3;
MADR  H1.xyz, R0, R0.w, R1;
MOVR  R0.x, c[1];
MOVH  H1.w, c[1].y;
MAXR  R0.y, H1.x, H1;
MAXR  R0.y, H1.z, R0;
MOVH  oCol, H1;
SLTRC HC.x, c[0], R0;
MOVH  oCol(EQ.x), H0;
RCPR  R0.z, R0.y;
MULR  H0.xyz, H1, R0.z;
MULR  H0.w, R0.y, c[0].x;
SGERC HC.x, c[0], R0;
MOVH  oCol(NE.x), H0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 4 [_TexBackground] 2D
Float 0 [_LuminanceScale]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c1, -0.00100000, 1.00000000, 0.00000000, 0
dcl_texcoord0 v0.xyzw
texldl r0, v0, s0
texldl r4, v0, s3
texldl r3, v0, s2
mad r3.xyz, r3.w, r4, r3
texldl r1, v0, s1
mad r1.xyz, r1.w, r3, r1
mad r1.xyz, r0.w, r1, r0
mul r4.x, r0.w, r1.w
mul r1.w, r4.x, r3
mul r0.w, r1, r4
texldl r0.xyz, v0, s4
mad r0.xyz, r0, r0.w, r1
max r0.w, r0.x, r0.y
max r3.y, r0.z, r0.w
mov r1.x, c0
add r3.x, c1, r1
mov r0.w, c1.y
cmp_pp r1, r3.x, r2, r0
rcp r3.z, r3.y
mul r0.xyz, r0, r3.z
mul r0.w, r3.y, c0.x
cmp_pp r2.x, r3, c1.y, c1.z
cmp_pp oC0, -r2.x, r1, r0

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 renders the Sun (i.e. a single pixel in the Sun's direction)
		// This value will be used as the scene's directional term
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
Vector 0 [_SunColor]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
Float 1 [_LuminanceScale]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[3] = { program.local[0..1],
		{ 0.001, 1 } };
TEMP R0;
TEMP R1;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R1.w, fragment.texcoord[0], texture[1], 2D;
TEX   R0.w, fragment.texcoord[0], texture[0], 2D;
MULR  R0.x, R0.w, R1.w;
TEX   R1.w, fragment.texcoord[0], texture[2], 2D;
TEX   R0.w, fragment.texcoord[0], texture[3], 2D;
MULR  R0.x, R0, R1.w;
MULR  R0.x, R0, R0.w;
MULR  H1.xyz, R0.x, c[0];
MOVR  R0.x, c[2];
MOVH  H1.w, c[2].y;
MAXR  R0.y, H1.x, H1;
MAXR  R0.y, H1.z, R0;
MOVH  oCol, H1;
SLTRC HC.x, c[1], R0;
MOVH  oCol(EQ.x), H0;
RCPR  R0.z, R0.y;
MULR  H0.xyz, H1, R0.z;
MULR  H0.w, R0.y, c[1].x;
SGERC HC.x, c[1], R0;
MOVH  oCol(NE.x), H0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 0 [_SunColor]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
Float 1 [_LuminanceScale]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c2, -0.00100000, 1.00000000, 0.00000000, 0
dcl_texcoord0 v0.xyzw
mov r2.y, c1.x
texldl r1.w, v0, s1
texldl r2.w, v0, s0
mul r1.x, r2.w, r1.w
texldl r2.w, v0, s2
texldl r1.w, v0, s3
mul r1.x, r1, r2.w
mul r1.x, r1, r1.w
mul r1.xyz, r1.x, c0
max r1.w, r1.x, r1.y
max r2.x, r1.z, r1.w
rcp r2.z, r2.x
mov r1.w, c2.y
add r2.y, c2.x, r2
cmp_pp r0, r2.y, r0, r1
mul r1.w, r2.x, c1.x
mul r1.xyz, r1, r2.z
cmp_pp r2.x, r2.y, c2.y, c2.z
cmp_pp oC0, -r2.x, r0, r1

"
}

}

		}
	}
	Fallback off
}
