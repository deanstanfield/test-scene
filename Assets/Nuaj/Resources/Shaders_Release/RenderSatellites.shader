// This renders different types of satellites
//	. Planetary Bodies, like the Moon
//	. Nearby Stars, like the Sun
//	. Cosmic Background, like the milky way and all the stars in the galaxy
//
Shader "Hidden/Nuaj/RenderSatellites"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDiffuse( "Base (RGB)", 2D ) = "black" {}
		_TexNormal( "Base (RGB)", 2D ) = "bump" {}
		_TexEmissive( "Base (RGB)", 2D ) = "black" {}
		_TexCubeEmissive( "Base (RGB)", CUBE ) = "black" {}
	}

	SubShader
	{
		Tags { "Queue" = "Overlay-1" }
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend SrcAlpha OneMinusSrcAlpha	// Alpha blending

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 renders a planetary body without lighting
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_projection]
Vector 12 [_Direction]
Vector 13 [_Tangent]
Vector 14 [_BiTangent]
Vector 15 [_Size]
Vector 16 [_UV]
Vector 17 [_CameraData]
Matrix 4 [_Camera2World]
Matrix 8 [_World2Camera]
"!!ARBvp1.0
OPTION NV_vertex_program3;
PARAM c[19] = { state.matrix.projection.row[0..3],
		program.local[4..17],
		{ 1, 0.5 } };
TEMP R0;
TEMP R1;
TEMP RC, HC;
BB0:
MUL   R0.xy, vertex.texcoord[0].yxzw, c[15].yxzw;
MUL   R1.xyz, R0.x, c[14];
MAD   R1.xyz, R0.y, c[13], R1;
MOV   R1.w, c[18].x;
MOV   R0.x, c[4].w;
MOV   R0.z, c[6].w;
MOV   R0.y, c[5].w;
MAD   R0.xyz, R1, c[17].y, R0;
ADD   R1.xyz, c[12], R0;
DP4   R0.w, R1, c[11];
DP4   R0.z, R1, c[10];
DP4   R0.x, R1, c[8];
DP4   R0.y, R1, c[9];
ADD   R1.xy, c[18].x, vertex.texcoord[0];
MUL   R1.xy, R1, c[16].zwzw;
MUL   R1.xy, R1, c[18].y;
DP4   result.position.w, R0, c[3];
DP4   result.position.z, R0, c[2];
DP4   result.position.y, R0, c[1];
DP4   result.position.x, R0, c[0];
ADD   result.texcoord[0].xy, c[16], R1;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_projection]
Vector 12 [_Direction]
Vector 13 [_Tangent]
Vector 14 [_BiTangent]
Vector 15 [_Size]
Vector 16 [_UV]
Vector 17 [_CameraData]
Matrix 4 [_Camera2World]
Matrix 8 [_World2Camera]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
def c18, 1.00000000, 0.50000000, 0, 0
dcl_texcoord0 v0
mul r0.x, v0.y, c15.y
mul r1.xyz, r0.x, c14
mul r0.x, v0, c15
mad r1.xyz, r0.x, c13, r1
mov r1.w, c18.x
mov r0.x, c4.w
mov r0.z, c6.w
mov r0.y, c5.w
mad r0.xyz, r1, c17.y, r0
add r1.xyz, r0, c12
dp4 r0.w, r1, c11
dp4 r0.z, r1, c10
dp4 r0.x, r1, c8
dp4 r0.y, r1, c9
add r1.xy, v0, c18.x
mul r1.xy, r1, c16.zwzw
mul r1.xy, r1, c18.y
dp4 o0.w, r0, c3
dp4 o0.z, r0, c2
dp4 o0.y, r0, c1
dp4 o0.x, r0, c0
add o1.xy, r1, c16

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Float 0 [_Luminance]
Vector 1 [_Albedo]
SetTexture 0 [_TexDiffuse] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0..1] };
TEMP R0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MULR  R0, R0, c[1];
MULR  oCol.xyz, R0, c[0].x;
MOVH  oCol.w, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_Luminance]
Vector 1 [_Albedo]
SetTexture 0 [_TexDiffuse] 2D

"ps_3_0
dcl_2d s0
dcl_texcoord0 v0.xy
texld r0, v0, s0
mul r0, r0, c1
mul oC0.xyz, r0, c0.x
mov oC0.w, r0

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 renders a planetary body with lighting
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_projection]
Vector 12 [_Direction]
Vector 13 [_Tangent]
Vector 14 [_BiTangent]
Vector 15 [_Size]
Vector 16 [_CameraData]
Matrix 4 [_Camera2World]
Matrix 8 [_World2Camera]
"!!ARBvp1.0
OPTION NV_vertex_program3;
PARAM c[18] = { state.matrix.projection.row[0..3],
		program.local[4..16],
		{ 1 } };
TEMP R0;
TEMP R1;
TEMP RC, HC;
BB0:
MUL   R0.xy, vertex.texcoord[0].yxzw, c[15].yxzw;
MUL   R1.xyz, R0.x, c[14];
MAD   R1.xyz, R0.y, c[13], R1;
MOV   R1.w, c[17].x;
MOV   R0.x, c[4].w;
MOV   R0.z, c[6].w;
MOV   R0.y, c[5].w;
MAD   R0.xyz, R1, c[16].y, R0;
ADD   R1.xyz, c[12], R0;
DP4   R0.w, R1, c[11];
DP4   R0.z, R1, c[10];
DP4   R0.x, R1, c[8];
DP4   R0.y, R1, c[9];
DP4   result.position.w, R0, c[3];
DP4   result.position.z, R0, c[2];
DP4   result.position.y, R0, c[1];
DP4   result.position.x, R0, c[0];
MOV   result.texcoord[0].xy, vertex.texcoord[0];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_projection]
Vector 12 [_Direction]
Vector 13 [_Tangent]
Vector 14 [_BiTangent]
Vector 15 [_Size]
Vector 16 [_CameraData]
Matrix 4 [_Camera2World]
Matrix 8 [_World2Camera]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
def c17, 1.00000000, 0, 0, 0
dcl_texcoord0 v0
mul r0.x, v0.y, c15.y
mul r1.xyz, r0.x, c14
mul r0.x, v0, c15
mad r1.xyz, r0.x, c13, r1
mov r1.w, c17.x
mov r0.x, c4.w
mov r0.z, c6.w
mov r0.y, c5.w
mad r0.xyz, r1, c16.y, r0
add r1.xyz, r0, c12
dp4 r0.w, r1, c11
dp4 r0.z, r1, c10
dp4 r0.x, r1, c8
dp4 r0.y, r1, c9
dp4 o0.w, r0, c3
dp4 o0.z, r0, c2
dp4 o0.y, r0, c1
dp4 o0.x, r0, c0
mov o1.xy, v0

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Vector 8 [_UV]
Vector 9 [_Albedo]
Vector 10 [_OrenNayarCoefficients]
SetTexture 1 [_TexDiffuse] 2D
SetTexture 0 [_TexNormal] 2D
Vector 11 [_CameraData]
Matrix 0 [_Camera2World]
Vector 12 [_SunDirection]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[15] = { program.local[0..12],
		{ 1, 0, 0.5, 1.9990234 },
		{ 0.31830987 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
DP2R  R0.x, fragment.texcoord[0], fragment.texcoord[0];
SLTRC HC.x, -R0, -c[13];
ADDR  R0.x, -R0, c[13];
MULR  R1.xyz, fragment.texcoord[0].y, c[6];
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MADR  R1.xyz, fragment.texcoord[0].x, c[5], R1;
MADR  R1.xyz, -R0.x, c[4], R1;
MULR  R0.xyz, R1.zxyw, c[6].yzxw;
MADR  R2.xyz, R1.yzxw, c[6].zxyw, -R0;
MOVR  R0.zw, c[13].xyxy;
MULR  R0.xy, fragment.texcoord[0], c[11];
DP4R  R3.z, R0, c[2];
DP4R  R3.x, R0, c[0];
DP4R  R3.y, R0, c[1];
DP3R  R0.y, R3, R3;
RSQR  R0.z, R0.y;
MULR  R4.xyz, R0.z, R3;
MULR  R3.xyz, R2.zxyw, R1.yzxw;
MADR  R3.xyz, R2.yzxw, R1.zxyw, -R3;
MOVR  R0.x, c[13].z;
MULR  R0.xy, R0.x, c[8].zwzw;
MADR  R0.zw, fragment.texcoord[0].xyxy, R0.xyxy, R0.xyxy;
ADDR  R5.xy, R0.zwzw, c[8];
DP3R  R1.w, R1, R4;
DP3R  R0.w, R3, R4;
DP3R  R2.w, R3, c[12];
DP3R  R3.x, R1, c[12];
TEX   H0.yw, R5, texture[0], 2D;
MADX  H0.xy, H0.wyzw, c[13].w, -c[13].x;
MADX  H0.z, -H0.x, H0.x, c[13].x;
MADX  H0.z, -H0.y, H0.y, H0;
RSQH  H0.z, H0.z;
DP3R  R0.x, R2, R4;
MOVR  R0.z, R1.w;
DP3R  R1.x, R2, c[12];
MOVR  R0.y, R0.w;
RCPH  H0.z, H0.z;
DP3R  R0.y, H0, R0;
MAXR  R0.z, R0.y, c[13].y;
MADR  R0.y, -R0.z, R0.z, c[13].x;
RSQR  R0.y, R0.y;
RCPR  R0.y, R0.y;
RCPR  R0.z, R0.z;
MULR  R0.z, R0.y, R0;
MOVR  R1.y, R2.w;
MOVR  R1.z, R3.x;
DP3R  R2.x, R1, H0;
MADR  R1.y, -R1.w, R1.w, c[13].x;
RSQR  R1.y, R1.y;
MADR  R1.z, -R3.x, R3.x, c[13].x;
RSQR  R1.z, R1.z;
MULR  R1.w, R1.z, R2;
MULR  R0.w, R1.y, R0;
MULR  R0.w, R1, R0;
MULR  R0.x, R1.y, R0;
MULR  R1.x, R1.z, R1;
MADR  R0.x, R1, R0, R0.w;
MADR  R1.w, -R2.x, R2.x, c[13].x;
RSQR  R0.w, R1.w;
RCPR  R0.w, R0.w;
RCPR  R1.x, R2.x;
MULR  R1.x, R0.w, R1;
MAXR  R0.x, R0, c[13].y;
MINR  R0.z, R1.x, R0;
MAXR  R0.y, R0.w, R0;
MULR  R0.x, R0, c[10].y;
MULR  R0.x, R0, R0.y;
MADR_SAT R1.x, R0, R0.z, c[10];
MULR  R1.y, R2.x, c[7].x;
TEX   R0, R5, texture[1], 2D;
MULR  R0, R0, c[9];
MULR  R1.x, R1.y, R1;
MULR  R0.xyz, R1.x, R0;
MULR  R1.xyz, R0, c[14].x;
MULR  R1.w, R0, c[9];
MOVR  R0.w, c[9];
MOVR  R0.xyz, c[13].y;
ADDR  R1, R1, -R0;
SGER  H0.x, R2, c[13].y;
KIL   NE.x;
MADR  oCol, H0.x, R1, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Vector 8 [_UV]
Vector 9 [_Albedo]
Vector 10 [_OrenNayarCoefficients]
SetTexture 1 [_TexDiffuse] 2D
SetTexture 0 [_TexNormal] 2D
Vector 11 [_CameraData]
Matrix 0 [_Camera2World]
Vector 12 [_SunDirection]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c13, 1.00000000, 0.00000000, 0.50000000, 0.31830987
def c14, 1.99902344, -1.00000000, 0, 0
dcl_texcoord0 v0.xy
mul r0.xy, v0, v0
add r0.x, r0, r0.y
add r0.w, -r0.x, c13.x
rsq r0.x, r0.w
mul r1.xyz, v0.y, c6
mad r1.xyz, v0.x, c5, r1
rcp r0.x, r0.x
mad r2.xyz, -r0.x, c4, r1
mul r0.xyz, r2.zxyw, c6.yzxw
mad r3.xyz, r2.yzxw, c6.zxyw, -r0
mov r1.zw, c13.xyxy
mul r1.xy, v0, c11
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
dp3 r1.z, r0, r0
rsq r1.z, r1.z
mul r5.xyz, r1.z, r0
dp3 r2.w, r2, r5
add r1.xy, v0, c13.x
mul r1.xy, r1, c8.zwzw
mul r0.xy, r1, c13.z
add r6.xy, r0, c8
mul r0.xyz, r3.zxyw, r2.yzxw
mad r4.xyz, r3.yzxw, r2.zxyw, -r0
texld r1.yw, r6, s0
mad_pp r0.xy, r1.wyzw, c14.x, c14.y
dp3 r1.w, r4, r5
mad_pp r0.z, -r0.x, r0.x, c13.x
mad_pp r0.z, -r0.y, r0.y, r0
rsq_pp r0.z, r0.z
dp3 r1.x, r3, r5
mov r1.z, r2.w
rcp_pp r0.z, r0.z
mov r1.y, r1.w
dp3 r1.y, r0, r1
max r1.y, r1, c13
mad r1.z, -r1.y, r1.y, c13.x
rcp r3.w, r1.y
rsq r1.z, r1.z
rcp r1.y, r1.z
mul r1.z, r1.y, r3.w
dp3 r3.w, r4, c12
dp3 r4.x, r2, c12
dp3 r2.x, r3, c12
mov r2.y, r3.w
mov r2.z, r4.x
dp3 r0.x, r2, r0
mad r0.z, -r2.w, r2.w, c13.x
rsq r0.z, r0.z
mul r2.y, r0.z, r1.w
mul r0.z, r0, r1.x
mad r0.y, -r4.x, r4.x, c13.x
rsq r0.y, r0.y
mul r1.w, r0.y, r3
mul r1.w, r1, r2.y
mul r0.y, r0, r2.x
mad r0.y, r0, r0.z, r1.w
mad r2.y, -r0.x, r0.x, c13.x
rsq r0.z, r2.y
max r0.y, r0, c13
rcp r1.x, r0.x
rcp r0.z, r0.z
mul r1.x, r0.z, r1
max r0.z, r0, r1.y
mul r0.y, r0, c10
mul r0.y, r0, r0.z
min r1.x, r1, r1.z
mad_sat r0.z, r0.y, r1.x, c10.x
mul r0.y, r0.x, c7.x
texld r1, r6, s1
mul r1, r1, c9
mul r0.y, r0, r0.z
mul r1.xyz, r0.y, r1
mul r2.xyz, r1, c13.w
mul r2.w, r1, c9
mov r1.w, c9
mov r1.xyz, c13.y
cmp r3.x, r0, c13, c13.y
add r2, r2, -r1
cmp r0.y, r0.w, c13, c13.x
mov_pp r0, -r0.y
mad oC0, r3.x, r2, r1
texkill r0.xyzw

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 renders an emissive nearby star
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_projection]
Vector 12 [_Direction]
Vector 13 [_Tangent]
Vector 14 [_BiTangent]
Vector 15 [_Size]
Vector 16 [_UV]
Vector 17 [_CameraData]
Matrix 4 [_Camera2World]
Matrix 8 [_World2Camera]
"!!ARBvp1.0
OPTION NV_vertex_program3;
PARAM c[19] = { state.matrix.projection.row[0..3],
		program.local[4..17],
		{ 1, 0.5 } };
TEMP R0;
TEMP R1;
TEMP RC, HC;
BB0:
MUL   R0.xy, vertex.texcoord[0].yxzw, c[15].yxzw;
MUL   R1.xyz, R0.x, c[14];
MAD   R1.xyz, R0.y, c[13], R1;
MOV   R1.w, c[18].x;
MOV   R0.x, c[4].w;
MOV   R0.z, c[6].w;
MOV   R0.y, c[5].w;
MAD   R0.xyz, R1, c[17].y, R0;
ADD   R1.xyz, c[12], R0;
DP4   R0.w, R1, c[11];
DP4   R0.z, R1, c[10];
DP4   R0.x, R1, c[8];
DP4   R0.y, R1, c[9];
ADD   R1.xy, c[18].x, vertex.texcoord[0];
MUL   R1.xy, R1, c[16].zwzw;
MUL   R1.xy, R1, c[18].y;
DP4   result.position.w, R0, c[3];
DP4   result.position.z, R0, c[2];
DP4   result.position.y, R0, c[1];
DP4   result.position.x, R0, c[0];
ADD   result.texcoord[0].xy, c[16], R1;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_projection]
Vector 12 [_Direction]
Vector 13 [_Tangent]
Vector 14 [_BiTangent]
Vector 15 [_Size]
Vector 16 [_UV]
Vector 17 [_CameraData]
Matrix 4 [_Camera2World]
Matrix 8 [_World2Camera]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
def c18, 1.00000000, 0.50000000, 0, 0
dcl_texcoord0 v0
mul r0.x, v0.y, c15.y
mul r1.xyz, r0.x, c14
mul r0.x, v0, c15
mad r1.xyz, r0.x, c13, r1
mov r1.w, c18.x
mov r0.x, c4.w
mov r0.z, c6.w
mov r0.y, c5.w
mad r0.xyz, r1, c17.y, r0
add r1.xyz, r0, c12
dp4 r0.w, r1, c11
dp4 r0.z, r1, c10
dp4 r0.x, r1, c8
dp4 r0.y, r1, c9
add r1.xy, v0, c18.x
mul r1.xy, r1, c16.zwzw
mul r1.xy, r1, c18.y
dp4 o0.w, r0, c3
dp4 o0.z, r0, c2
dp4 o0.y, r0, c1
dp4 o0.x, r0, c0
add o1.xy, r1, c16

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Float 0 [_Luminance]
SetTexture 0 [_TexEmissive] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[1] = { program.local[0] };
TEMP R0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MULR  oCol.xyz, R0, c[0].x;
MOVH  oCol.w, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_Luminance]
SetTexture 0 [_TexEmissive] 2D

"ps_3_0
dcl_2d s0
dcl_texcoord0 v0.xy
texld r0, v0, s0
mul oC0.xyz, r0, c0.x
mov oC0.w, r0

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 renders an emissive cosmic background
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"!!ARBvp1.0
OPTION NV_vertex_program3;
PARAM c[1] = { { 1 } };
TEMP RC, HC;
BB0:
MOV   result.position.xy, vertex.texcoord[0];
MOV   result.position.zw, c[0].x;
MOV   result.texcoord[0].xy, vertex.texcoord[0];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
def c0, 1.00000000, 0, 0, 0
dcl_texcoord0 v0
mov o0.xy, v0
mov o0.zw, c0.x
mov o1.xy, v0

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Float 8 [_Brightness]
Float 9 [_Contrast]
Float 10 [_Gamma]
SetTexture 0 [_TexCubeEmissive] CUBE
Float 11 [_FlipCubeMap]
Vector 12 [_CameraData]
Matrix 0 [_Camera2World]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[14] = { program.local[0..12],
		{ -1, 0, 1, 0.5 } };
TEMP R0;
TEMP R1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R1.zw, c[13].xyxy;
MOVR  R0.y, c[11].x;
MOVR  R0.x, c[13].z;
MULR  R0.xy, R0, c[12];
MULR  R1.xy, R0, fragment.texcoord[0];
DP4R  R0.z, R1, c[2];
DP4R  R0.x, R1, c[0];
DP4R  R0.y, R1, c[1];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R1.xyz, R0.w, R0;
DP3R  R0.x, R1, c[5];
DP3R  R0.z, R1, c[4];
DP3R  R0.y, R1, c[6];
TEX   R0, R0, texture[0], CUBE;
ADDR  R0.xyz, R0, c[8].x;
MOVR  R1.x, c[13].w;
ADDR  R0.xyz, R0, -c[13].w;
MADR_SAT R0.xyz, R0, c[9].x, R1.x;
POWR  R0.x, R0.x, c[10].x;
POWR  R0.z, R0.z, c[10].x;
POWR  R0.y, R0.y, c[10].x;
MULR  oCol.xyz, R0, c[7].x;
MOVH  oCol.w, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Float 8 [_Brightness]
Float 9 [_Contrast]
Float 10 [_Gamma]
SetTexture 0 [_TexCubeEmissive] CUBE
Float 11 [_FlipCubeMap]
Vector 12 [_CameraData]
Matrix 0 [_Camera2World]

"ps_3_0
dcl_cube s0
def c13, 1.00000000, -1.00000000, 0.00000000, -0.50000000
def c14, 0.50000000, 0, 0, 0
dcl_texcoord0 v0.xy
mov r0.zw, c13.xyyz
mov r0.y, c11.x
mov r0.x, c13
mul r0.xy, r0, c12
mul r0.xy, r0, v0
dp4 r1.z, r0, c2
dp4 r1.x, r0, c0
dp4 r1.y, r0, c1
dp3 r0.x, r1, r1
rsq r0.x, r0.x
mul r1.xyz, r0.x, r1
dp3 r0.x, r1, c5
dp3 r0.z, r1, c4
dp3 r0.y, r1, c6
texld r1, r0, s0
add r0.xyz, r1, c8.x
add r0.xyz, r0, c13.w
mul r0.xyz, r0, c9.x
add_sat r1.xyz, r0, c14.x
pow r0, r1.x, c10.x
mov r1.x, r0
pow r0, r1.z, c10.x
pow r2, r1.y, c10.x
mov r1.z, r0
mov r1.y, r2
mul oC0.xyz, r1, c7.x
mov oC0.w, r1

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// ENVIRONMENT RENDERING
		//
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 renders a planetary body (with and without lighting)
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"!!ARBvp1.0
OPTION NV_vertex_program3;
TEMP RC, HC;
BB0:
MOV   result.position, vertex.position;
MOV   result.texcoord[0].xy, vertex.texcoord[0];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_position0 v0
dcl_texcoord0 v1
mov o0, v0
mov o1.xy, v1

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Vector 8 [_Size]
Vector 9 [_UV]
Vector 10 [_Albedo]
Vector 11 [_OrenNayarCoefficients]
Float 12 [_bSimulateLighting]
SetTexture 0 [_TexDiffuse] 2D
SetTexture 1 [_TexNormal] 2D
Vector 13 [_CameraData]
Matrix 0 [_Camera2World]
Vector 14 [_PlanetNormal]
Vector 15 [_PlanetTangent]
Vector 16 [_PlanetBiTangent]
Vector 17 [_SunDirection]
Vector 18 [_EnvironmentAngles]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[21] = { program.local[0..18],
		{ 1, 0, 0.5, 2 },
		{ 1.9990234, 0.31830987 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MADR  R2.xy, fragment.texcoord[0], c[18].zwzw, c[18];
COSR  R0.y, R2.y;
MULR  R1.xyz, R0.y, c[14];
SINR  R0.x, R2.y;
SINR  R0.z, R2.x;
MULR  R0.z, R0.x, R0;
COSR  R0.y, R2.x;
MULR  R0.x, R0, R0.y;
MADR  R1.xyz, R0.z, c[15], R1;
MADR  R1.xyz, R0.x, c[16], R1;
DP3R  R0.x, R1, c[4];
RCPR  R0.w, R0.x;
MOVR  R0.x, c[0].w;
MOVR  R0.z, c[2].w;
MOVR  R0.y, c[1].w;
ADDR  R2.xyz, R0, c[4];
MADR  R0.xyz, R0.w, R1, R0;
ADDR  R0.xyz, R0, -R2;
DP3R  R1.x, R0, c[5];
DP3R  R1.y, R0, c[6];
MULR  R5.zw, fragment.texcoord[0].xyxy, c[19].w;
RCPR  R0.y, c[8].y;
RCPR  R0.x, c[8].x;
MULR  R0.xy, R1, R0;
MADR  R5.xy, R0, c[19].z, c[19].z;
ADDR  R0.xy, R5.zwzw, -c[19].x;
MADRC HC.xy, -R5, R5, R5;
MULR  R1.xyz, R0.y, c[6];
KIL   LT.x;
MOVXC RC.x, R0.w;
DP2R  R0.z, R0, R0;
MADR  R1.xyz, R0.x, c[5], R1;
KIL   LT.x;
SLTRC HC.x, -R0.z, -c[19];
ADDR  R0.z, -R0, c[19].x;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MADR  R1.xyz, -R0.z, c[4], R1;
DP3R  R1.w, R1, c[17];
MULR  R2.xyz, R1.zxyw, c[6].yzxw;
MADR  R2.xyz, R1.yzxw, c[6].zxyw, -R2;
MULR  R3.xyz, R2.zxyw, R1.yzxw;
MADR  R2.w, -R1, R1, c[19].x;
MADR  R3.xyz, R2.yzxw, R1.zxyw, -R3;
MULR  R0.xy, R0, c[13];
MOVR  R0.zw, c[19].xyxy;
DP4R  R4.x, R0, c[0];
DP4R  R4.y, R0, c[1];
DP4R  R4.z, R0, c[2];
DP3R  R0.x, R4, R4;
RSQR  R0.x, R0.x;
MULR  R0.xyz, R0.x, R4;
DP3R  R1.z, R1, R0;
DP3R  R4.x, R3, R0;
DP3R  R0.w, R3, c[17];
RSQR  R2.w, R2.w;
MADR  R1.x, -R1.z, R1.z, c[19];
RSQR  R3.z, R1.x;
MULR  R3.w, R2, R0;
MULR  R4.y, R3.z, R4.x;
MOVR  R1.xy, c[9];
MULR  R3.xy, R5.zwzw, c[9].zwzw;
MADR  R3.xy, R3, c[19].z, R1;
DP3R  R1.x, R2, R0;
DP3R  R0.x, R2, c[17];
MULR  R0.z, R3, R1.x;
TEX   H0.yw, R3, texture[1], 2D;
MOVX  H0.x, c[19];
MADX  H0.xy, H0.wyzw, c[20].x, -H0.x;
MADX  H0.z, -H0.x, H0.x, c[19].x;
MADX  H0.z, -H0.y, H0.y, H0;
RSQH  H0.z, H0.z;
MOVR  R1.y, R4.x;
RCPH  H0.z, H0.z;
DP3R  R0.y, H0, R1;
MAXR  R1.y, R0, c[19];
MULR  R1.x, R2.w, R0;
MULR  R3.w, R3, R4.y;
MADR  R1.x, R1, R0.z, R3.w;
MOVR  R0.z, R1.w;
MOVR  R0.y, R0.w;
DP3R  R3.z, R0, H0;
MADR  R0.y, -R1, R1, c[19].x;
RCPR  R0.z, R1.y;
MADR  R0.x, -R3.z, R3.z, c[19];
RSQR  R0.y, R0.y;
RCPR  R0.y, R0.y;
RSQR  R0.x, R0.x;
MULR  R0.z, R0.y, R0;
RCPR  R0.x, R0.x;
RCPR  R0.w, R3.z;
MULR  R0.w, R0.x, R0;
MINR  R0.z, R0.w, R0;
MAXR  R0.w, R1.x, c[19].y;
MAXR  R0.x, R0, R0.y;
MULR  R0.y, R0.w, c[11];
MULR  R0.x, R0.y, R0;
MADR_SAT R1.x, R0, R0.z, c[11];
TEX   R0, R3, texture[0], 2D;
MULR  R0, R0, c[10];
MULR  R1.y, R3.z, c[7].x;
MULR  R1.x, R1.y, R1;
MULR  R0.xyz, R1.x, R0;
MULR  R0.xyz, R0, c[20].y;
MULR  R0.w, R0, c[10];
MOVR  R1.w, c[10];
MOVR  R1.xyz, c[19].y;
ADDR  R2, R0, -R1;
MADR  R3.xy, R5, c[9].zwzw, c[9];
TEX   R0, R3, texture[0], 2D;
MULR  R0, R0, c[10];
SGER  H0.x, R3.z, c[19].y;
MULR  R0.xyz, R0, c[7].x;
MADR  R1, H0.x, R2, R1;
ADDR  R1, R1, -R0;
KIL   LT.y;
KIL   NE.x;
MADR  oCol, R1, c[12].x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Vector 8 [_Size]
Vector 9 [_UV]
Vector 10 [_Albedo]
Vector 11 [_OrenNayarCoefficients]
Float 12 [_bSimulateLighting]
SetTexture 0 [_TexDiffuse] 2D
SetTexture 1 [_TexNormal] 2D
Vector 13 [_CameraData]
Matrix 0 [_Camera2World]
Vector 14 [_PlanetNormal]
Vector 15 [_PlanetTangent]
Vector 16 [_PlanetBiTangent]
Vector 17 [_SunDirection]
Vector 18 [_EnvironmentAngles]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c19, 0.15915491, 0.50000000, 6.28318501, -3.14159298
def c20, 0.00000000, 1.00000000, 2.00000000, -1.00000000
def c21, 1.99902344, -1.00000000, 0.31830987, 0
dcl_texcoord0 v0.xy
mul r5.xy, v0, c20.z
add r0.xy, r5, c20.w
mul r0.zw, r0.xyxy, r0.xyxy
add r0.z, r0, r0.w
add r3.w, -r0.z, c20.y
mul r1.xyz, r0.y, c6
mad r1.xyz, r0.x, c5, r1
rsq r0.z, r3.w
rcp r0.z, r0.z
mad r1.xyz, -r0.z, c4, r1
dp3 r1.w, r1, c17
mul r2.xyz, r1.zxyw, c6.yzxw
mad r2.xyz, r1.yzxw, c6.zxyw, -r2
mul r3.xyz, r2.zxyw, r1.yzxw
mad r2.w, -r1, r1, c20.y
mad r3.xyz, r2.yzxw, r1.zxyw, -r3
mul r0.xy, r0, c13
mov r0.zw, c20.xyyx
dp4 r4.z, r0, c2
dp4 r4.x, r0, c0
dp4 r4.y, r0, c1
dp3 r0.x, r4, r4
rsq r0.x, r0.x
mul r0.xyz, r0.x, r4
dp3 r1.z, r1, r0
dp3 r0.w, r3, c17
dp3 r3.z, r3, r0
dp3 r0.x, r2, r0
rsq r2.w, r2.w
dp3 r2.x, r2, c17
mad r1.x, -r1.z, r1.z, c20.y
rsq r4.y, r1.x
mul r1.xy, r5, c9.zwzw
mul r3.x, r4.y, r3.z
mul r4.x, r2.w, r0.w
mul r4.x, r4, r3
mul r1.xy, r1, c19.y
add r3.xy, r1, c9
mul r0.y, r4, r0.x
mul r2.y, r2.w, r2.x
mad r2.z, r2.y, r0.y, r4.x
texld r4.yw, r3, s1
mad_pp r1.xy, r4.wyzw, c21.x, c21.y
mad_pp r0.z, -r1.x, r1.x, c20.y
mad_pp r0.z, -r1.y, r1.y, r0
rsq_pp r2.y, r0.z
mov r0.z, r1
rcp_pp r1.z, r2.y
mov r0.y, r3.z
dp3 r0.x, r1, r0
max r0.y, r2.z, c20.x
mov r2.z, r1.w
mov r2.y, r0.w
dp3 r4.z, r2, r1
max r0.x, r0, c20
mad r0.w, -r0.x, r0.x, c20.y
mad r0.z, -r4, r4, c20.y
rsq r0.w, r0.w
rsq r0.z, r0.z
rcp r0.w, r0.w
rcp r0.z, r0.z
max r1.x, r0.z, r0.w
mul r0.y, r0, c11
mul r2.w, r0.y, r1.x
rcp r0.y, r4.z
rcp r0.x, r0.x
mul r0.z, r0, r0.y
mul r0.w, r0, r0.x
mad r0.xy, v0, c18.zwzw, c18
min r3.z, r0, r0.w
mad r0.z, r0.x, c19.x, c19.y
mad r0.y, r0, c19.x, c19
frc r0.x, r0.y
frc r0.y, r0.z
mad r0.x, r0, c19.z, c19.w
sincos r1.xy, r0.x
mad r2.x, r0.y, c19.z, c19.w
sincos r0.xy, r2.x
mul r0.y, r1, r0
mul r2.xyz, r1.x, c14
mul r0.x, r1.y, r0
mad r2.xyz, r0.y, c15, r2
mad r0.xyz, r0.x, c16, r2
mad_sat r1.w, r2, r3.z, c11.x
dp3 r1.x, r0, c4
rcp r3.z, r1.x
mul r0.w, r4.z, c7.x
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
add r2.xyz, r1, c4
mad r0.xyz, r3.z, r0, r1
add r1.xyz, r0, -r2
mul r1.w, r0, r1
texld r0, r3, s0
mul r0, r0, c10
mul r0.xyz, r1.w, r0
dp3 r2.x, r1, c5
dp3 r2.y, r1, c6
mul r0.xyz, r0, c21.z
mul r0.w, r0, c10
mov r1.w, c10
rcp r1.y, c8.y
rcp r1.x, c8.x
mad r1.xy, r2, r1, c20.y
mul r3.xy, r1, c19.y
mov r1.xyz, c20.x
mad r4.xy, r3, c9.zwzw, c9
add r2, r0, -r1
texld r0, r4, s0
mul r0, r0, c10
cmp r4.x, r4.z, c20.y, c20
mul r0.xyz, r0, c7.x
mad r1, r4.x, r2, r1
add r1, r1, -r0
mad oC0, r1, c12.x, r0
add r0.x, -r3, c20.y
add r0.y, -r3, c20
mul r0.y, r3, r0
cmp r1.x, r0.y, c20, c20.y
mov_pp r1, -r1.x
texkill r1.xyzw
mul r0.x, r3, r0
cmp r0.x, r0, c20, c20.y
mov_pp r0, -r0.x
texkill r0.xyzw
cmp r0.x, r3.z, c20, c20.y
cmp r1.x, r3.w, c20, c20.y
mov_pp r0, -r0.x
mov_pp r1, -r1.x
texkill r0.xyzw
texkill r1.xyzw

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 renders an emissive nearby star
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"!!ARBvp1.0
OPTION NV_vertex_program3;
TEMP RC, HC;
BB0:
MOV   result.position, vertex.position;
MOV   result.texcoord[0].xy, vertex.texcoord[0];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_position0 v0
dcl_texcoord0 v1
mov o0, v0
mov o1.xy, v1

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Vector 8 [_Size]
Vector 9 [_UV]
SetTexture 0 [_TexEmissive] 2D
Matrix 0 [_Camera2World]
Vector 10 [_PlanetNormal]
Vector 11 [_PlanetTangent]
Vector 12 [_PlanetBiTangent]
Vector 13 [_EnvironmentAngles]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[15] = { program.local[0..13],
		{ 0.5 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MADR  R2.xy, fragment.texcoord[0], c[13].zwzw, c[13];
COSR  R0.y, R2.y;
MULR  R1.xyz, R0.y, c[10];
SINR  R0.x, R2.y;
SINR  R0.z, R2.x;
MULR  R0.z, R0.x, R0;
COSR  R0.y, R2.x;
MULR  R0.x, R0, R0.y;
MADR  R1.xyz, R0.z, c[11], R1;
MADR  R1.xyz, R0.x, c[12], R1;
DP3R  R0.x, R1, c[4];
RCPR  R0.w, R0.x;
MOVR  R0.x, c[0].w;
MOVR  R0.z, c[2].w;
MOVR  R0.y, c[1].w;
ADDR  R2.xyz, R0, c[4];
MADR  R0.xyz, R0.w, R1, R0;
ADDR  R0.xyz, R0, -R2;
DP3R  R1.x, R0, c[5];
DP3R  R1.y, R0, c[6];
RCPR  R0.y, c[8].y;
RCPR  R0.x, c[8].x;
MULR  R0.xy, R1, R0;
MADR  R0.xy, R0, c[14].x, c[14].x;
MADRC HC.xy, -R0, R0, R0;
KIL   LT.x;
MOVXC RC.x, R0.w;
MADR  R0.xy, R0, c[9].zwzw, c[9];
TEX   R0, R0, texture[0], 2D;
KIL   LT.y;
KIL   LT.x;
MULR  oCol.xyz, R0, c[7].x;
MOVH  oCol.w, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_Direction]
Vector 5 [_Tangent]
Vector 6 [_BiTangent]
Float 7 [_Luminance]
Vector 8 [_Size]
Vector 9 [_UV]
SetTexture 0 [_TexEmissive] 2D
Matrix 0 [_Camera2World]
Vector 10 [_PlanetNormal]
Vector 11 [_PlanetTangent]
Vector 12 [_PlanetBiTangent]
Vector 13 [_EnvironmentAngles]

"ps_3_0
dcl_2d s0
def c14, 0.15915491, 0.50000000, 6.28318501, -3.14159298
def c15, 0.00000000, 1.00000000, 0, 0
dcl_texcoord0 v0.xy
mad r0.xy, v0, c13.zwzw, c13
mad r0.z, r0.x, c14.x, c14.y
mad r0.y, r0, c14.x, c14
frc r0.x, r0.y
frc r0.y, r0.z
mad r0.x, r0, c14.z, c14.w
sincos r1.xy, r0.x
mad r2.x, r0.y, c14.z, c14.w
sincos r0.xy, r2.x
mul r2.xyz, r1.x, c10
mul r0.y, r1, r0
mul r0.x, r1.y, r0
mad r2.xyz, r0.y, c11, r2
mad r0.xyz, r0.x, c12, r2
dp3 r0.w, r0, c4
rcp r0.w, r0.w
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mad r0.xyz, r0.w, r0, r1
add r2.xyz, r1, c4
add r0.xyz, r0, -r2
dp3 r1.x, r0, c5
dp3 r1.y, r0, c6
rcp r0.y, c8.y
rcp r0.x, c8.x
mad r0.xy, r1, r0, c15.y
mul r0.xy, r0, c14.y
add r1.x, -r0.y, c15.y
add r0.z, -r0.x, c15.y
mul r0.z, r0.x, r0
mul r2.x, r0.y, r1
cmp r0.z, r0, c15.x, c15.y
mov_pp r1, -r0.z
mad r0.xy, r0, c9.zwzw, c9
cmp r0.z, r2.x, c15.x, c15.y
texkill r1.xyzw
mov_pp r1, -r0.z
texkill r1.xyzw
texld r1, r0, s0
cmp r0.x, r0.w, c15, c15.y
mov_pp r0, -r0.x
mul oC0.xyz, r1, c7.x
mov oC0.w, r1
texkill r0.xyzw

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #6 renders an emissive cosmic background
		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"!!ARBvp1.0
OPTION NV_vertex_program3;
TEMP RC, HC;
BB0:
MOV   result.position, vertex.position;
MOV   result.texcoord[0].xy, vertex.texcoord[0];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_position0 v0
dcl_texcoord0 v1
mov o0, v0
mov o1.xy, v1

"
}

}
Program "fp" {

SubProgram "opengl " {
Keywords { }
Vector 0 [_Direction]
Vector 1 [_Tangent]
Vector 2 [_BiTangent]
Float 3 [_Luminance]
Float 4 [_Brightness]
Float 5 [_Contrast]
Float 6 [_Gamma]
SetTexture 0 [_TexCubeEmissive] CUBE
Vector 7 [_PlanetNormal]
Vector 8 [_PlanetTangent]
Vector 9 [_PlanetBiTangent]
Vector 10 [_EnvironmentAngles]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[12] = { program.local[0..10],
		{ 0.5 } };
TEMP R0;
TEMP R1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MADR  R0.xy, fragment.texcoord[0].yxzw, c[10].wzzw, c[10].yxzw;
COSR  R0.w, R0.x;
SINR  R0.z, R0.y;
SINR  R0.x, R0.x;
MULR  R0.z, R0.x, R0;
MULR  R1.xyz, R0.w, c[7];
COSR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MADR  R1.xyz, R0.z, c[8], R1;
MADR  R1.xyz, R0.x, c[9], R1;
DP3R  R0.x, R1, c[1];
DP3R  R0.z, R1, c[0];
DP3R  R0.y, R1, c[2];
TEX   R0, R0, texture[0], CUBE;
ADDR  R0.xyz, R0, c[4].x;
MOVR  R1.x, c[11];
ADDR  R0.xyz, R0, -c[11].x;
MADR_SAT R0.xyz, R0, c[5].x, R1.x;
POWR  R0.x, R0.x, c[6].x;
POWR  R0.z, R0.z, c[6].x;
POWR  R0.y, R0.y, c[6].x;
MULR  oCol.xyz, R0, c[3].x;
MOVH  oCol.w, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 0 [_Direction]
Vector 1 [_Tangent]
Vector 2 [_BiTangent]
Float 3 [_Luminance]
Float 4 [_Brightness]
Float 5 [_Contrast]
Float 6 [_Gamma]
SetTexture 0 [_TexCubeEmissive] CUBE
Vector 7 [_PlanetNormal]
Vector 8 [_PlanetTangent]
Vector 9 [_PlanetBiTangent]
Vector 10 [_EnvironmentAngles]

"ps_3_0
dcl_cube s0
def c11, 0.15915491, 0.50000000, 6.28318501, -3.14159298
def c12, -0.50000000, 0, 0, 0
dcl_texcoord0 v0.xy
mad r0.xy, v0, c10.zwzw, c10
mad r0.z, r0.x, c11.x, c11.y
mad r0.y, r0, c11.x, c11
frc r0.x, r0.y
frc r0.y, r0.z
mad r0.x, r0, c11.z, c11.w
sincos r1.xy, r0.x
mad r2.x, r0.y, c11.z, c11.w
sincos r0.xy, r2.x
mul r0.y, r1, r0
mul r2.xyz, r1.x, c7
mad r2.xyz, r0.y, c8, r2
mul r0.x, r1.y, r0
mad r1.xyz, r0.x, c9, r2
dp3 r0.x, r1, c1
dp3 r0.z, r1, c0
dp3 r0.y, r1, c2
texld r1, r0, s0
add r0.xyz, r1, c4.x
add r0.xyz, r0, c12.x
mul r0.xyz, r0, c5.x
add_sat r1.xyz, r0, c11.y
pow r0, r1.x, c6.x
mov r1.x, r0
pow r0, r1.z, c6.x
pow r2, r1.y, c6.x
mov r1.z, r0
mov r1.y, r2
mul oC0.xyz, r1, c3.x
mov oC0.w, r1

"
}

}

		}
	}
	Fallback off
}
