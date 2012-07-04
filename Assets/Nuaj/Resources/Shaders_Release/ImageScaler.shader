// This shader performs luminance sampling on the scattering buffer
// Unity doesn't render in HDR but we do. The difficulty lies in combining a HDR buffer with a LDR rendering.
// For this purpose, we tone map the HDR light sources to obtain a LDR light source Unity can use.
// And for tone mapping, we map the LDR-lit scene to a HDR scene using the inverse of the tone map factor.
// This way, we can mix the LDR scene with our HDR rendering all into a single HDR scene + atmosphere, that
//	we use for tone mapping.
//
// Basically, we downscale the HDR scattering buffer and read back the 1x1 end-mipmap to tone-map the result,
//	the tone mapped image will yield an average luminance that we also use to configure the Sun light and
//	ambient Sky light so the LDR rendering in Unity is coherent with our lighting.
//
// Of course, the LDR lighting has already occurred since we're a post-process, so the Sun & Ambient
//	light configuration is set for the next frame, hoping the light doesn't change too much from one
//	frame to the next...
//
Shader "Nuaj/ImageScaler"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexScattering( "Base (RGB)", 2D ) = "white" {}
		_TexDownScaledZBuffer( "Base (RGB)", 2D ) = "white" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }

		// This pass downscales the main texture to a buffer at most 2x smaller
		// It also assumes the scene was rendered in LDR
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
Float 0 [_LerpAvgMax]
Vector 1 [_dUV]
Float 2 [_SceneDirectionalLuminanceFactor]
Float 3 [_SceneAmbientLuminanceLDR]
Float 4 [_SceneAmbientLuminanceLDR2HDR]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[12] = { program.local[0..4],
		{ 0, 0.5, 128, 15 },
		{ 4, 1024, 0.00390625, 0.0047619049 },
		{ 0.63999999, 0, 0.25 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[5].y;
MADR  R1.xy, R0.x, -c[1], fragment.texcoord[0];
TEX   R0, R1, texture[1], 2D;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R0.w|, H0;
MADH  H0.y, H0, c[6], -c[6];
MULR  R1.z, H0.y, c[6];
FRCR  R1.w, R1.z;
ADDH  H0.x, H0, c[5].w;
MULH  H0.z, H0.x, c[6].x;
SGEH  H0.xy, c[5].x, R0.wyzw;
MULR  R0.w, R1, c[7].x;
MADH  H0.x, H0, c[5].z, H0.z;
FLRR  R1.z, R1;
ADDR  R1.z, H0.x, R1;
MULR  R2.z, R1, c[6].w;
ADDR  R1.z, -R2, -R0.w;
ADDR  R2.xy, R1, c[1].xzzw;
MADR  R2.w, R1.z, R0.z, R0.z;
TEX   R1, R2, texture[1], 2D;
RCPR  R3.x, R0.w;
MULR  R2.z, R2, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[5].w;
MULR  R0.w, R2, R3.x;
MULR  R2.z, R3.x, R2;
MULR  R3.xyz, R0.z, c[10];
MADH  H0.z, H0, c[6].y, -c[6].y;
MULR  R0.z, H0, c[6];
MADR  R3.xyz, R2.z, c[9], R3;
MADR  R3.xyz, R0.w, c[8], R3;
FRCR  R0.w, R0.z;
SGEH  H0.zw, c[5].x, R1.xywy;
MULH  H0.x, H0, c[6];
MADH  H0.x, H0.z, c[5].z, H0;
FLRR  R0.z, R0;
ADDR  R1.w, H0.x, R0.z;
MULR  R0.z, R0.w, c[7].x;
MULR  R3.w, R1, c[6];
ADDR  R0.w, -R3, -R0.z;
RCPR  R4.x, R0.z;
MADR  R1.w, R0, R1.z, R1.z;
ADDR  R0.zw, R2.xyxy, c[1].xyzy;
TEX   R2, R0.zwzw, texture[1], 2D;
MULR  R3.w, R3, R1.z;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
ADDH  H0.x, H0, c[5].w;
MULR  R1.w, R1, R4.x;
MULR  R3.w, R4.x, R3;
MULR  R4.xyz, R1.z, c[10];
MADR  R4.xyz, R3.w, c[9], R4;
MADR  R4.xyz, R1.w, c[8], R4;
MADH  H0.z, H0, c[6].y, -c[6].y;
MULR  R1.z, H0, c[6];
FRCR  R1.w, R1.z;
SGEH  H1.xy, c[5].x, R2.wyzw;
MULH  H0.x, H0, c[6];
ADDR  R0.zw, R0, -c[1].xyxz;
MULR  R1.w, R1, c[7].x;
MAXR  R3.xyz, R3, c[5].x;
MAXR  R4.xyz, R4, c[5].x;
ADDR  R4.xyz, R3, R4;
TEX   R3, R0.zwzw, texture[1], 2D;
RCPR  R0.w, R1.w;
SGEH  H1.zw, c[5].x, R3.xywy;
MADH  H0.x, H1, c[5].z, H0;
FLRR  R1.z, R1;
ADDR  R1.z, H0.x, R1;
MULR  R1.z, R1, c[6].w;
ADDR  R2.w, -R1.z, -R1;
MADR  R2.w, R2, R2.z, R2.z;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[5].w;
MULH  H0.x, H0, c[6];
MULR  R0.z, R2.w, R0.w;
MULR  R1.z, R1, R2;
MULR  R0.w, R0, R1.z;
MULR  R5.xyz, R2.z, c[10];
MADR  R5.xyz, R0.w, c[9], R5;
MADH  H0.z, H0, c[6].y, -c[6].y;
MADR  R5.xyz, R0.z, c[8], R5;
MULR  R0.w, H0.z, c[6].z;
FRCR  R0.z, R0.w;
MAXR  R5.xyz, R5, c[5].x;
ADDR  R4.xyz, R4, R5;
FLRR  R0.w, R0;
MADH  H0.x, H1.z, c[5].z, H0;
ADDR  R1.z, H0.x, R0.w;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[6].y, -c[6].y;
ADDH  H0.x, H0, c[5].w;
MULH  H0.x, H0, c[6];
MULR  R0.w, R0.z, c[7].x;
MULR  R1.z, R1, c[6].w;
ADDR  R0.z, -R1, -R0.w;
MADR  R0.z, R0, R3, R3;
RCPR  R0.w, R0.w;
MULR  R1.z, R1, R3;
MULR  R0.z, R0, R0.w;
MULR  R1.z, R0.w, R1;
MULR  R6.xyz, R3.z, c[10];
MADR  R6.xyz, R1.z, c[9], R6;
MADR  R6.xyz, R0.z, c[8], R6;
MULR  R0.y, H0.z, c[6].z;
FRCR  R0.z, R0.y;
MAXR  R5.xyz, R6, c[5].x;
ADDR  R5.xyz, R4, R5;
TEX   R4.xyz, fragment.texcoord[0], texture[0], 2D;
MULR  R4.xyz, R5, R4;
MULR  R4.xyz, R4, c[7].z;
DP3R  R0.w, R4, c[11];
MADH  H0.x, H0.y, c[5].z, H0;
FLRR  R0.y, R0;
ADDR  R0.y, H0.x, R0;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
ADDH  H0.x, H0, c[5].w;
MULH  H0.x, H0, c[6];
MULR  R0.z, R0, c[7].x;
MULR  R0.y, R0, c[6].w;
ADDR  R1.z, -R0.y, -R0;
MADR  R1.z, R0.x, R1, R0.x;
RCPR  R0.z, R0.z;
MULR  R0.y, R0.x, R0;
MULR  R1.z, R1, R0;
MULR  R1.w, R0.z, R0.y;
MULR  R0.xyz, R0.x, c[10];
MADR  R0.xyz, R1.w, c[9], R0;
MADR  R0.xyz, R1.z, c[8], R0;
MADH  H0.y, H0, c[6], -c[6];
MULR  R1.z, H0.y, c[6];
FRCR  R1.y, R1.z;
MULR  R1.y, R1, c[7].x;
RCPR  R2.z, R1.y;
MADH  H0.x, H0.w, c[5].z, H0;
FLRR  R1.z, R1;
ADDR  R1.z, H0.x, R1;
MULR  R1.z, R1, c[6].w;
ADDR  R1.w, -R1.z, -R1.y;
MADR  R1.w, R1.x, R1, R1.x;
MULR  R2.w, R1.x, R1.z;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R2|, H0;
ADDH  H0.x, H0, c[5].w;
MULH  H0.x, H0, c[6];
MULR  R1.w, R1, R2.z;
MULR  R2.w, R2.z, R2;
MULR  R1.xyz, R1.x, c[10];
MADR  R1.xyz, R2.w, c[9], R1;
MADR  R1.xyz, R1.w, c[8], R1;
MAXR  R1.xyz, R1, c[5].x;
MAXR  R0.xyz, R0, c[5].x;
MAXR  R4.xyz, R0, R1;
ADDR  R0.xyz, R0, R1;
MADH  H0.y, H0, c[6], -c[6];
MULR  R1.y, H0, c[6].z;
FLRR  R1.x, R1.y;
MADH  H0.x, H1.y, c[5].z, H0;
ADDR  R1.x, H0, R1;
LG2H  H0.y, |R3.y|;
FLRH  H0.x, H0.y;
EX2H  H0.y, -H0.x;
MULR  R1.x, R1, c[6].w;
MULH  H0.y, |R3|, H0;
FRCR  R1.y, R1;
MULR  R1.y, R1, c[7].x;
ADDR  R1.z, -R1.x, -R1.y;
MADH  H0.y, H0, c[6], -c[6];
MULR  R1.w, H0.y, c[6].z;
FRCR  R2.y, R1.w;
ADDH  H0.x, H0, c[5].w;
MULH  H0.x, H0, c[6];
MADR  R2.w, R2.x, R1.z, R2.x;
RCPR  R3.y, R1.y;
MULR  R3.z, R2.x, R1.x;
MULR  R1.xyz, R2.x, c[10];
MULR  R2.x, R3.y, R3.z;
MADR  R1.xyz, R2.x, c[9], R1;
MULR  R2.x, R2.w, R3.y;
MADR  R1.xyz, R2.x, c[8], R1;
MAXR  R1.xyz, R1, c[5].x;
ADDR  R0.xyz, R1, R0;
MULR  R2.y, R2, c[7].x;
FLRR  R1.w, R1;
MADH  H0.x, H1.w, c[5].z, H0;
ADDR  R1.w, H0.x, R1;
MULR  R1.w, R1, c[6];
ADDR  R2.z, -R1.w, -R2.y;
MULR  R3.y, R3.x, R1.w;
MADR  R2.w, R3.x, R2.z, R3.x;
RCPR  R1.w, R2.y;
MULR  R2.xyz, R3.x, c[10];
MULR  R3.x, R1.w, R3.y;
MADR  R2.xyz, R3.x, c[9], R2;
MULR  R1.w, R2, R1;
MADR  R2.xyz, R1.w, c[8], R2;
MAXR  R2.xyz, R2, c[5].x;
ADDR  R0.xyz, R2, R0;
MULR  R0.xyz, R0, c[7].z;
MAXR  R1.xyz, R4, R1;
DP3R  R0.x, R0, c[11];
MAXR  R1.xyz, R1, R2;
DP3R  R0.y, R1, c[11];
ADDR  R0.z, R0.y, -R0.x;
MINR  R0.y, R0.w, c[3].x;
MADR  R0.x, R0.z, c[0], R0;
ADDR  R0.z, R0.w, -R0.y;
MULR  R0.y, R0, c[4].x;
MAXR  R0.z, R0, c[5].x;
MADR  R0.y, R0.z, c[2].x, R0;
ADDR  oCol, R0.y, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_LerpAvgMax]
Vector 1 [_dUV]
Float 2 [_SceneDirectionalLuminanceFactor]
Float 3 [_SceneAmbientLuminanceLDR]
Float 4 [_SceneAmbientLuminanceLDR2HDR]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
def c5, 0.50000000, 1.00000000, 0.00000000, 15.00000000
def c6, 4.00000000, 128.00000000, -1.00000000, 1024.00000000
def c7, 0.00390625, 0.00476190, 0.63999999, 0.25000000
def c8, -1.02170002, 1.97770000, 0.04390000, 0
def c9, 2.56509995, -1.16649997, -0.39860001, 0
def c10, 0.07530000, -0.25430000, 1.18920004, 0
def c11, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
mov r0.xyz, c1
mad r1.xyz, c5.x, -r0, v0.xyww
texldl r0, r1.xyzz, s1
abs_pp r1.w, r0
log_pp r2.x, r1.w
frc_pp r2.y, r2.x
add_pp r2.x, r2, -r2.y
exp_pp r2.y, -r2.x
mad_pp r1.w, r1, r2.y, c6.z
mul_pp r1.w, r1, c6
mul r2.y, r1.w, c7.x
add_pp r1.w, r2.x, c5
frc r2.z, r2.y
add r2.x, r2.y, -r2.z
mul_pp r1.w, r1, c6.x
cmp_pp r0.w, -r0, c5.y, c5.z
mad_pp r0.w, r0, c6.y, r1
add r0.w, r0, r2.x
mul r3.x, r0.w, c7.y
mul r0.w, r2.z, c7.z
add r2.w, -r3.x, -r0
add r2.xyz, r1, c1.xzzw
texldl r1, r2.xyzz, s1
abs_pp r3.z, r1.w
add r2.w, r2, c5.y
log_pp r3.w, r3.z
rcp r3.y, r0.w
mul r2.w, r2, r0.z
frc_pp r0.w, r3
add_pp r0.w, r3, -r0
mul r3.x, r3, r0.z
exp_pp r4.x, -r0.w
mul r2.w, r2, r3.y
mul r3.w, r3.y, r3.x
mad_pp r4.x, r3.z, r4, c6.z
mul r3.xyz, r0.z, c8
mad r3.xyz, r3.w, c9, r3
mul_pp r0.z, r4.x, c6.w
mul r3.w, r0.z, c7.x
mad r3.xyz, r2.w, c10, r3
frc r2.w, r3
add_pp r0.z, r0.w, c5.w
mul_pp r0.w, r0.z, c6.x
cmp_pp r0.z, -r1.w, c5.y, c5
mad_pp r0.z, r0, c6.y, r0.w
add r3.w, r3, -r2
mul r0.w, r2, c7.z
add r0.z, r0, r3.w
mul r0.z, r0, c7.y
add r1.w, -r0.z, -r0
max r4.xyz, r3, c5.z
add r3.xyz, r2, c1.zyzw
texldl r2, r3.xyzz, s1
add r1.w, r1, c5.y
mul r3.w, r1, r1.z
rcp r4.w, r0.w
abs_pp r1.w, r2
log_pp r5.x, r1.w
mul r0.w, r3, r4
mul r0.z, r0, r1
mul r3.w, r4, r0.z
frc_pp r5.y, r5.x
add_pp r0.z, r5.x, -r5.y
mul r5.xyz, r1.z, c8
exp_pp r1.z, -r0.z
mad r5.xyz, r3.w, c9, r5
mad r5.xyz, r0.w, c10, r5
max r5.xyz, r5, c5.z
mad_pp r1.z, r1.w, r1, c6
mul_pp r0.w, r1.z, c6
mul r0.w, r0, c7.x
frc r1.z, r0.w
add r3.xyz, r3, -c1.xzzw
texldl r3, r3.xyzz, s1
add r4.xyz, r4, r5
add r1.w, r0, -r1.z
add_pp r0.z, r0, c5.w
mul_pp r0.w, r0.z, c6.x
cmp_pp r0.z, -r2.w, c5.y, c5
mad_pp r0.z, r0, c6.y, r0.w
mul r0.w, r1.z, c7.z
add r0.z, r0, r1.w
mul r0.z, r0, c7.y
add r1.z, -r0, -r0.w
add r1.z, r1, c5.y
mul r1.w, r1.z, r2.z
rcp r2.w, r0.w
mul r0.w, r1, r2
mul r1.w, r0.z, r2.z
abs_pp r1.z, r3.w
log_pp r4.w, r1.z
frc_pp r5.x, r4.w
add_pp r0.z, r4.w, -r5.x
mul r1.w, r2, r1
exp_pp r2.w, -r0.z
mad_pp r1.z, r1, r2.w, c6
abs_pp r2.w, r1.y
mul r5.xyz, r2.z, c8
mad r5.xyz, r1.w, c9, r5
mad r5.xyz, r0.w, c10, r5
max r5.xyz, r5, c5.z
add r4.xyz, r4, r5
mul_pp r1.z, r1, c6.w
mul r1.z, r1, c7.x
frc r0.w, r1.z
add r1.w, r1.z, -r0
add_pp r0.z, r0, c5.w
mul_pp r1.z, r0, c6.x
cmp_pp r0.z, -r3.w, c5.y, c5
mad_pp r0.z, r0, c6.y, r1
add r0.z, r0, r1.w
mul r0.w, r0, c7.z
mul r0.z, r0, c7.y
add r1.z, -r0, -r0.w
rcp r1.w, r0.w
mul r0.z, r0, r3
add r1.z, r1, c5.y
mul r0.w, r1.z, r3.z
mul r1.z, r0.w, r1.w
abs_pp r0.w, r0.y
mul r0.z, r1.w, r0
log_pp r1.w, r0.w
mul r5.xyz, r3.z, c8
mad r5.xyz, r0.z, c9, r5
frc_pp r2.z, r1.w
add_pp r0.z, r1.w, -r2
mad r5.xyz, r1.z, c10, r5
exp_pp r1.z, -r0.z
mad_pp r0.w, r0, r1.z, c6.z
max r5.xyz, r5, c5.z
add r5.xyz, r4, r5
mul_pp r0.w, r0, c6
mul r0.w, r0, c7.x
frc r1.z, r0.w
texldl r4.xyz, v0, s0
mul r4.xyz, r5, r4
add_pp r0.z, r0, c5.w
add r0.w, r0, -r1.z
log_pp r2.z, r2.w
mul_pp r0.z, r0, c6.x
cmp_pp r0.y, -r0, c5, c5.z
mad_pp r0.y, r0, c6, r0.z
add r0.y, r0, r0.w
mul r0.z, r1, c7
mul r0.y, r0, c7
add r0.w, -r0.y, -r0.z
add r1.z, r0.w, c5.y
mul r4.xyz, r4, c7.w
dp3 r0.w, r4, c11
mul r1.z, r0.x, r1
rcp r0.z, r0.z
mul r1.w, r1.z, r0.z
frc_pp r1.z, r2
add_pp r1.z, r2, -r1
exp_pp r3.z, -r1.z
mul r0.y, r0.x, r0
mul r2.z, r0, r0.y
mul r0.xyz, r0.x, c8
mad r0.xyz, r2.z, c9, r0
mad_pp r2.w, r2, r3.z, c6.z
mad r0.xyz, r1.w, c10, r0
mul_pp r2.z, r2.w, c6.w
mul r1.w, r2.z, c7.x
frc r2.z, r1.w
add_pp r1.z, r1, c5.w
add r1.w, r1, -r2.z
max r0.xyz, r0, c5.z
mul_pp r1.z, r1, c6.x
cmp_pp r1.y, -r1, c5, c5.z
mad_pp r1.y, r1, c6, r1.z
add r1.y, r1, r1.w
mul r1.y, r1, c7
mul r1.z, r2, c7
add r1.w, -r1.y, -r1.z
mul r2.w, r1.x, r1.y
add r1.y, r1.w, c5
rcp r1.z, r1.z
abs_pp r1.w, r2.y
mul r1.y, r1.x, r1
log_pp r3.z, r1.w
mul r2.z, r1.y, r1
mul r2.w, r1.z, r2
mul r1.xyz, r1.x, c8
mad r1.xyz, r2.w, c9, r1
mad r1.xyz, r2.z, c10, r1
max r1.xyz, r1, c5.z
max r4.xyz, r0, r1
add r0.xyz, r0, r1
frc_pp r2.w, r3.z
add_pp r2.z, r3, -r2.w
exp_pp r2.w, -r2.z
mad_pp r1.w, r1, r2, c6.z
mul_pp r1.x, r1.w, c6.w
abs_pp r1.y, r3
mul r1.z, r1.x, c7.x
log_pp r1.w, r1.y
frc r1.x, r1.z
add r2.w, r1.z, -r1.x
frc_pp r3.z, r1.w
add_pp r1.z, r1.w, -r3
add_pp r1.w, r2.z, c5
exp_pp r3.z, -r1.z
mul_pp r2.z, r1.w, c6.x
cmp_pp r1.w, -r2.y, c5.y, c5.z
mad_pp r1.w, r1, c6.y, r2.z
add r1.w, r1, r2
mad_pp r2.y, r1, r3.z, c6.z
mul r1.y, r1.w, c7
mul r1.x, r1, c7.z
mul_pp r1.w, r2.y, c6
mul r1.w, r1, c7.x
frc r2.y, r1.w
add r2.w, r1, -r2.y
add_pp r1.z, r1, c5.w
mul_pp r1.w, r1.z, c6.x
cmp_pp r1.z, -r3.y, c5.y, c5
mad_pp r1.z, r1, c6.y, r1.w
add r1.z, r1, r2.w
mul r1.w, r1.z, c7.y
add r2.z, -r1.y, -r1.x
mul r2.y, r2, c7.z
add r2.w, -r1, -r2.y
add r1.z, r2, c5.y
add r2.z, r2.w, c5.y
mul r2.w, r2.x, r1.z
rcp r3.y, r1.x
mul r3.z, r2.x, r1.y
mul r1.xyz, r2.x, c8
mul r2.x, r3.y, r3.z
mad r1.xyz, r2.x, c9, r1
mul r2.x, r2.w, r3.y
mul r3.y, r3.x, r1.w
mad r1.xyz, r2.x, c10, r1
max r1.xyz, r1, c5.z
add r0.xyz, r1, r0
mul r2.w, r3.x, r2.z
rcp r1.w, r2.y
mul r2.xyz, r3.x, c8
mul r3.x, r1.w, r3.y
mad r2.xyz, r3.x, c9, r2
mul r1.w, r2, r1
mad r2.xyz, r1.w, c10, r2
max r2.xyz, r2, c5.z
add r0.xyz, r2, r0
mul r0.xyz, r0, c7.w
max r1.xyz, r4, r1
dp3 r0.y, r0, c11
max r1.xyz, r1, r2
dp3 r0.x, r1, c11
add r0.z, r0.x, -r0.y
min r0.x, r0.w, c3
mad r1.x, r0.z, c0, r0.y
mul r0.z, r0.x, c4.x
add r0.y, r0.w, -r0.x
max r0.x, r0.y, c5.z
mad r0.x, r0, c2, r0.z
add oC0, r0.x, r1.x

"
}

}

		}

		// This pass downscales the main texture to a buffer at most 2x smaller
		// It also assumes the scene was rendered in HDR
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
Float 0 [_LerpAvgMax]
Vector 1 [_dUV]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[9] = { program.local[0..1],
		{ 0, 0.5, 128, 15 },
		{ 4, 1024, 0.00390625, 0.0047619049 },
		{ 0.63999999, 0, 0.25 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[2].y;
MADR  R0.zw, R0.x, -c[1].xyxy, fragment.texcoord[0].xyxy;
TEX   R4, R0.zwzw, texture[1], 2D;
ADDR  R2.xy, R0.zwzw, c[1].xzzw;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R4|, H0;
MADH  H0.y, H0, c[3], -c[3];
MULR  R0.x, H0.y, c[3].z;
FRCR  R0.y, R0.x;
MULR  R1.x, R0.y, c[4];
ADDH  H0.x, H0, c[2].w;
MULH  H0.z, H0.x, c[3].x;
SGEH  H0.xy, c[2].x, R4.wyzw;
TEX   R5, R2, texture[1], 2D;
MADH  H0.y, H0, c[2].z, H0.z;
FLRR  R0.x, R0;
ADDR  R0.x, H0.y, R0;
MULR  R0.x, R0, c[3].w;
ADDR  R0.y, -R0.x, -R1.x;
LG2H  H0.y, |R5.y|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |R5.y|, H0;
ADDH  H0.y, H0, c[2].w;
MADR  R0.y, R4.x, R0, R4.x;
RCPR  R0.z, R1.x;
MULR  R0.x, R4, R0;
MULR  R0.w, R0.y, R0.z;
MULR  R1.x, R0.z, R0;
MULR  R0.xyz, R4.x, c[7];
MADR  R0.xyz, R1.x, c[6], R0;
MADR  R0.xyz, R0.w, c[5], R0;
MADH  H0.z, H0, c[3].y, -c[3].y;
MULR  R0.w, H0.z, c[3].z;
MAXR  R1.xyz, R0, c[2].x;
FRCR  R0.x, R0.w;
MULR  R0.z, R0.x, c[4].x;
ADDR  R4.xy, R2, c[1].zyzw;
SGEH  H0.zw, c[2].x, R5.xywy;
MULH  H0.y, H0, c[3].x;
MADH  H0.y, H0.w, c[2].z, H0;
FLRR  R0.y, R0.w;
ADDR  R0.y, H0, R0;
MULR  R0.x, R0.y, c[3].w;
ADDR  R0.y, -R0.x, -R0.z;
RCPR  R1.w, R0.z;
MADR  R0.y, R5.x, R0, R5.x;
MULR  R0.w, R0.y, R1;
MULR  R2.z, R5.x, R0.x;
MULR  R1.w, R1, R2.z;
MULR  R0.xyz, R5.x, c[7];
MADR  R0.xyz, R1.w, c[6], R0;
MADR  R2.xyz, R0.w, c[5], R0;
TEX   R0, R4, texture[1], 2D;
LG2H  H0.y, |R0.y|;
FLRH  H0.w, H0.y;
ADDH  H0.y, H0.w, c[2].w;
MAXR  R2.xyz, R2, c[2].x;
MAXR  R3.xyz, R1, R2;
ADDR  R2.xyz, R1, R2;
ADDR  R1.xy, R4, -c[1].xzzw;
TEX   R1, R1, texture[1], 2D;
EX2H  H0.w, -H0.w;
MULH  H0.w, |R0.y|, H0;
SGEH  H1.xy, c[2].x, R0.wyzw;
MADH  H0.w, H0, c[3].y, -c[3].y;
MULR  R0.y, H0.w, c[3].z;
LG2H  H0.w, |R1.y|;
FLRR  R2.w, R0.y;
FRCR  R0.y, R0;
MULH  H0.y, H0, c[3].x;
MADH  H0.y, H1, c[2].z, H0;
ADDR  R2.w, H0.y, R2;
FLRH  H0.w, H0;
EX2H  H0.y, -H0.w;
MULH  H0.y, |R1|, H0;
SGEH  H1.zw, c[2].x, R1.xywy;
MULR  R4.y, R2.w, c[3].w;
MULR  R4.x, R0.y, c[4];
ADDR  R3.w, -R4.y, -R4.x;
MADH  H0.y, H0, c[3], -c[3];
MULR  R0.y, H0, c[3].z;
FRCR  R2.w, R0.y;
ADDH  H0.y, H0.w, c[2].w;
MULH  H0.y, H0, c[3].x;
MULR  R1.y, R2.w, c[4].x;
MULR  R4.y, R0.x, R4;
RCPR  R4.x, R4.x;
MADH  H0.y, H1.w, c[2].z, H0;
FLRR  R0.y, R0;
ADDR  R0.y, H0, R0;
MULR  R0.y, R0, c[3].w;
LG2H  H0.y, |R4.w|;
FLRH  H0.y, H0;
EX2H  H0.w, -H0.y;
MULH  H0.w, |R4|, H0;
ADDH  H0.y, H0, c[2].w;
MULH  H0.y, H0, c[3].x;
ADDR  R2.w, -R0.y, -R1.y;
MADH  H0.x, H0, c[2].z, H0.y;
MADR  R3.w, R0.x, R3, R0.x;
MULR  R6.xyz, R0.x, c[7];
MULR  R0.x, R4, R4.y;
MADR  R6.xyz, R0.x, c[6], R6;
MULR  R0.x, R3.w, R4;
MADR  R6.xyz, R0.x, c[5], R6;
MAXR  R6.xyz, R6, c[2].x;
MADR  R0.x, R1, R2.w, R1;
MULR  R2.w, R1.x, R0.y;
RCPR  R0.y, R1.y;
MULR  R7.xyz, R1.x, c[7];
MULR  R1.x, R0.y, R2.w;
MULR  R0.x, R0, R0.y;
MADR  R7.xyz, R1.x, c[6], R7;
MADR  R7.xyz, R0.x, c[5], R7;
MADH  H0.w, H0, c[3].y, -c[3].y;
MULR  R0.y, H0.w, c[3].z;
FLRR  R0.x, R0.y;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[3].w;
FRCR  R0.y, R0;
LG2H  H0.x, |R5.w|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R5.w|, H0;
ADDH  H0.x, H0, c[2].w;
MULH  H0.x, H0, c[3];
MULR  R1.x, R0, R4.z;
MULR  R0.y, R0, c[4].x;
ADDR  R0.x, -R0, -R0.y;
MADR  R0.x, R0, R4.z, R4.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.y, R0, R1.x;
MAXR  R7.xyz, R7, c[2].x;
ADDR  R2.xyz, R2, R6;
MAXR  R3.xyz, R6, R3;
ADDR  R2.xyz, R2, R7;
MAXR  R3.xyz, R7, R3;
MADR  R3.xyz, -R2, c[4].z, R3;
MULR  R2.xyz, R2, c[4].z;
MADR  R2.xyz, R3, c[0].x, R2;
MULR  R3.xyz, R4.z, c[7];
MADR  R3.xyz, R0.y, c[6], R3;
MADR  R3.xyz, R0.x, c[5], R3;
MADH  H0.y, H0, c[3], -c[3];
MULR  R0.y, H0, c[3].z;
FLRR  R0.x, R0.y;
MADH  H0.x, H0.z, c[2].z, H0;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[3].w;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R0.w|, H0;
FRCR  R0.y, R0;
ADDH  H0.x, H0, c[2].w;
MULH  H0.x, H0, c[3];
MULR  R1.x, R0, R5.z;
MULR  R0.y, R0, c[4].x;
ADDR  R0.x, -R0, -R0.y;
RCPR  R0.y, R0.y;
MADR  R0.x, R0, R5.z, R5.z;
MULR  R0.x, R0, R0.y;
MULR  R0.y, R0, R1.x;
MULR  R4.xyz, R5.z, c[7];
MADR  R4.xyz, R0.y, c[6], R4;
MADR  R4.xyz, R0.x, c[5], R4;
MADH  H0.y, H0, c[3], -c[3];
MULR  R0.x, H0.y, c[3].z;
FRCR  R0.y, R0.x;
MADH  H0.x, H1, c[2].z, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1.w|, H0;
ADDH  H0.x, H0, c[2].w;
MULH  H0.x, H0, c[3];
MULR  R0.y, R0, c[4].x;
MULR  R0.x, R0, c[3].w;
ADDR  R0.w, -R0.x, -R0.y;
RCPR  R0.y, R0.y;
MADR  R0.w, R0, R0.z, R0.z;
MULR  R0.x, R0, R0.z;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[7];
MADR  R0.xyz, R1.x, c[6], R0;
MADR  R0.xyz, R0.w, c[5], R0;
MADH  H0.y, H0, c[3], -c[3];
MULR  R0.w, H0.y, c[3].z;
FRCR  R1.x, R0.w;
MULR  R1.x, R1, c[4];
RCPR  R1.w, R1.x;
MAXR  R3.xyz, R3, c[2].x;
MAXR  R4.xyz, R4, c[2].x;
ADDR  R3.xyz, R3, R4;
MAXR  R0.xyz, R0, c[2].x;
ADDR  R0.xyz, R3, R0;
FLRR  R0.w, R0;
MADH  H0.x, H1.z, c[2].z, H0;
ADDR  R0.w, H0.x, R0;
MULR  R1.y, R0.w, c[3].w;
ADDR  R0.w, -R1.y, -R1.x;
MADR  R0.w, R0, R1.z, R1.z;
MULR  R2.w, R1.y, R1.z;
MULR  R1.xyz, R1.z, c[7];
MULR  R2.w, R1, R2;
MADR  R1.xyz, R2.w, c[6], R1;
MULR  R0.w, R0, R1;
MADR  R1.xyz, R0.w, c[5], R1;
MAXR  R3.xyz, R1, c[2].x;
TEX   R1.xyz, fragment.texcoord[0], texture[0], 2D;
ADDR  R0.xyz, R0, R3;
MULR  R0.xyz, R0, R1;
MADR  R0.xyz, R0, c[4].z, R2;
DP3R  oCol, R0, c[8];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_LerpAvgMax]
Vector 1 [_dUV]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
def c2, 0.50000000, 1.00000000, 0.00000000, 15.00000000
def c3, 4.00000000, 128.00000000, -1.00000000, 1024.00000000
def c4, 0.00390625, 0.00476190, 0.63999999, 0.25000000
def c5, -1.02170002, 1.97770000, 0.04390000, 0
def c6, 2.56509995, -1.16649997, -0.39860001, 0
def c7, 0.07530000, -0.25430000, 1.18920004, 0
def c8, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
mov r0.xyz, c1
mad r0.xyz, c2.x, -r0, v0.xyww
texldl r7, r0.xyzz, s1
add r0.xyz, r0, c1.xzzw
texldl r5, r0.xyzz, s1
abs_pp r2.y, r5
abs_pp r0.w, r7.y
log_pp r1.x, r0.w
frc_pp r1.y, r1.x
add_pp r1.x, r1, -r1.y
exp_pp r1.y, -r1.x
mad_pp r0.w, r0, r1.y, c3.z
mul_pp r0.w, r0, c3
mul r1.y, r0.w, c4.x
frc r1.z, r1.y
add_pp r0.w, r1.x, c2
mul_pp r1.x, r0.w, c3
cmp_pp r0.w, -r7.y, c2.y, c2.z
add r1.y, r1, -r1.z
mad_pp r0.w, r0, c3.y, r1.x
add r0.w, r0, r1.y
mul r1.x, r0.w, c4.y
mul r0.w, r1.z, c4.z
add r1.y, -r1.x, -r0.w
add r1.y, r1, c2
log_pp r2.x, r2.y
rcp r1.z, r0.w
mul r1.y, r7.x, r1
frc_pp r0.w, r2.x
mul r1.w, r1.y, r1.z
add_pp r0.w, r2.x, -r0
exp_pp r1.y, -r0.w
mad_pp r2.y, r2, r1, c3.z
mul r1.x, r7, r1
mul r2.x, r1.z, r1
mul r1.xyz, r7.x, c5
mad r1.xyz, r2.x, c6, r1
mul_pp r2.y, r2, c3.w
mul r2.x, r2.y, c4
frc r2.y, r2.x
mul r2.w, r2.y, c4.z
rcp r3.y, r2.w
mad r1.xyz, r1.w, c7, r1
add_pp r0.w, r0, c2
mul_pp r1.w, r0, c3.x
cmp_pp r0.w, -r5.y, c2.y, c2.z
mad_pp r0.w, r0, c3.y, r1
add r2.x, r2, -r2.y
add r0.w, r0, r2.x
mul r1.w, r0, c4.y
add r0.w, -r1, -r2
max r2.xyz, r1, c2.z
mul r1.w, r5.x, r1
add r0.w, r0, c2.y
mul r3.x, r5, r0.w
add r1.xyz, r0, c1.zyzw
texldl r0, r1.xyzz, s1
abs_pp r2.w, r0.y
mul r3.w, r3.x, r3.y
log_pp r3.x, r2.w
mul r4.x, r3.y, r1.w
frc_pp r3.z, r3.x
add_pp r1.w, r3.x, -r3.z
exp_pp r4.y, -r1.w
mad_pp r2.w, r2, r4.y, c3.z
mul r3.xyz, r5.x, c5
mad r3.xyz, r4.x, c6, r3
mad r3.xyz, r3.w, c7, r3
max r3.xyz, r3, c2.z
add r4.xyz, r2, r3
mul_pp r2.w, r2, c3
mul r3.w, r2, c4.x
frc r2.w, r3
add r3.w, r3, -r2
mul r2.w, r2, c4.z
add_pp r1.w, r1, c2
rcp r4.w, r2.w
max r2.xyz, r2, r3
mul_pp r1.w, r1, c3.x
cmp_pp r0.y, -r0, c2, c2.z
mad_pp r0.y, r0, c3, r1.w
add r0.y, r0, r3.w
mul r0.y, r0, c4
add r1.w, -r0.y, -r2
add r3.w, r1, c2.y
mul r5.x, r0, r3.w
mul r2.w, r5.x, r4
mul r5.x, r0, r0.y
add r1.xyz, r1, -c1.xzzw
texldl r1, r1.xyzz, s1
abs_pp r3.w, r1.y
log_pp r5.y, r3.w
frc_pp r6.x, r5.y
add_pp r0.y, r5, -r6.x
mul r4.w, r4, r5.x
exp_pp r5.x, -r0.y
mul r6.xyz, r0.x, c5
mad_pp r0.x, r3.w, r5, c3.z
mad r6.xyz, r4.w, c6, r6
mad r6.xyz, r2.w, c7, r6
max r6.xyz, r6, c2.z
mul_pp r0.x, r0, c3.w
mul r0.x, r0, c4
frc r2.w, r0.x
add r3.w, r0.x, -r2
add_pp r0.y, r0, c2.w
mul_pp r0.y, r0, c3.x
cmp_pp r0.x, -r1.y, c2.y, c2.z
mad_pp r0.x, r0, c3.y, r0.y
add r0.x, r0, r3.w
mul r0.y, r2.w, c4.z
mul r0.x, r0, c4.y
add r1.y, -r0.x, -r0
add r2.w, r1.y, c2.y
rcp r1.y, r0.y
mul r0.y, r1.x, r2.w
mul r0.x, r1, r0
mul r0.y, r0, r1
mul r0.x, r1.y, r0
mul r8.xyz, r1.x, c5
mad r8.xyz, r0.x, c6, r8
mad r8.xyz, r0.y, c7, r8
abs_pp r0.x, r7.w
log_pp r0.y, r0.x
frc_pp r1.x, r0.y
add_pp r0.y, r0, -r1.x
exp_pp r1.x, -r0.y
mad_pp r0.x, r0, r1, c3.z
mul_pp r0.x, r0, c3.w
mul r1.x, r0, c4
frc r1.y, r1.x
add_pp r0.x, r0.y, c2.w
mul_pp r0.y, r0.x, c3.x
cmp_pp r0.x, -r7.w, c2.y, c2.z
mad_pp r0.x, r0, c3.y, r0.y
add r1.x, r1, -r1.y
add r0.x, r0, r1
mul r0.y, r1, c4.z
mul r1.x, r0, c4.y
add r0.x, -r1, -r0.y
add r0.x, r0, c2.y
rcp r1.y, r0.y
mul r0.x, r0, r7.z
mul r1.x, r1, r7.z
mul r0.y, r0.x, r1
abs_pp r2.w, r5
mul r1.x, r1.y, r1
max r8.xyz, r8, c2.z
add r4.xyz, r4, r6
add r4.xyz, r4, r8
max r2.xyz, r6, r2
max r2.xyz, r8, r2
mul r3.xyz, r4, c4.w
mad r2.xyz, -r4, c4.w, r2
mad r2.xyz, r2, c0.x, r3
log_pp r3.x, r2.w
frc_pp r3.y, r3.x
add_pp r0.x, r3, -r3.y
exp_pp r3.x, -r0.x
mad_pp r1.y, r2.w, r3.x, c3.z
mul r3.xyz, r7.z, c5
mad r3.xyz, r1.x, c6, r3
mul_pp r1.y, r1, c3.w
mul r1.x, r1.y, c4
frc r1.y, r1.x
mad r3.xyz, r0.y, c7, r3
add_pp r0.x, r0, c2.w
mul_pp r0.y, r0.x, c3.x
cmp_pp r0.x, -r5.w, c2.y, c2.z
mad_pp r0.x, r0, c3.y, r0.y
add r1.x, r1, -r1.y
mul r0.y, r1, c4.z
add r0.x, r0, r1
mul r0.x, r0, c4.y
add r1.x, -r0, -r0.y
rcp r1.y, r0.y
add r1.x, r1, c2.y
mul r0.y, r1.x, r5.z
mul r1.x, r0.y, r1.y
abs_pp r0.y, r0.w
mul r0.x, r0, r5.z
log_pp r2.w, r0.y
mul r1.y, r1, r0.x
frc_pp r0.x, r2.w
add_pp r0.x, r2.w, -r0
abs_pp r2.w, r1
mul r4.xyz, r5.z, c5
mad r4.xyz, r1.y, c6, r4
exp_pp r1.y, -r0.x
mad_pp r0.y, r0, r1, c3.z
mad r4.xyz, r1.x, c7, r4
mul_pp r0.y, r0, c3.w
mul r0.y, r0, c4.x
frc r1.x, r0.y
add r1.y, r0, -r1.x
log_pp r3.w, r2.w
frc_pp r0.y, r3.w
add_pp r3.w, r3, -r0.y
add_pp r0.x, r0, c2.w
mul_pp r0.y, r0.x, c3.x
cmp_pp r0.x, -r0.w, c2.y, c2.z
mad_pp r0.x, r0, c3.y, r0.y
add r0.x, r0, r1.y
exp_pp r0.y, -r3.w
mad_pp r0.w, r2, r0.y, c3.z
mul r0.y, r1.x, c4.z
mul_pp r1.x, r0.w, c3.w
mul r0.x, r0, c4.y
add r0.w, -r0.x, -r0.y
add r1.y, r0.w, c2
mul r1.x, r1, c4
frc r2.w, r1.x
add_pp r0.w, r3, c2
add r3.w, r1.x, -r2
mul_pp r1.x, r0.w, c3
cmp_pp r0.w, -r1, c2.y, c2.z
mad_pp r0.w, r0, c3.y, r1.x
mul r1.x, r2.w, c4.z
add r0.w, r0, r3
mul r0.w, r0, c4.y
rcp r1.w, r0.y
mul r1.y, r1, r0.z
mul r2.w, r0.x, r0.z
mul r1.y, r1, r1.w
add r3.w, -r0, -r1.x
mul r2.w, r1, r2
mul r0.xyz, r0.z, c5
mad r0.xyz, r2.w, c6, r0
mad r0.xyz, r1.y, c7, r0
mul r2.w, r0, r1.z
rcp r0.w, r1.x
add r1.y, r3.w, c2
mul r1.w, r1.y, r1.z
mul r2.w, r0, r2
mul r1.xyz, r1.z, c5
max r0.xyz, r0, c2.z
max r3.xyz, r3, c2.z
max r4.xyz, r4, c2.z
add r3.xyz, r3, r4
add r3.xyz, r3, r0
mad r1.xyz, r2.w, c6, r1
mul r0.w, r1, r0
mad r1.xyz, r0.w, c7, r1
max r1.xyz, r1, c2.z
texldl r0.xyz, v0, s0
add r1.xyz, r3, r1
mul r0.xyz, r1, r0
mad r0.xyz, r0, c4.w, r2
dp3 oC0, r0, c8

"
}

}

		}

		// This pass downscales the main texture to a buffer at most 2x smaller
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
Float 0 [_LerpAvgMax]
Vector 1 [_dUV]
SetTexture 0 [_MainTex] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[3] = { program.local[0..1],
		{ 0.5, 0.25 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[2];
MADR  R1.xy, R0.x, -c[1], fragment.texcoord[0];
ADDR  R0.xy, R1, c[1].xzzw;
ADDR  R0.zw, R0.xyxy, c[1].xyzy;
TEX   R2.x, R1, texture[0], 2D;
TEX   R0.x, R0, texture[0], 2D;
TEX   R1.x, R0.zwzw, texture[0], 2D;
MAXR  R0.y, R2.x, R0.x;
MAXR  R0.y, R1.x, R0;
ADDR  R0.zw, R0, -c[1].xyxz;
ADDR  R1.y, R2.x, R0.x;
TEX   R0.x, R0.zwzw, texture[0], 2D;
ADDR  R0.z, R1.y, R1.x;
ADDR  R0.z, R0, R0.x;
MAXR  R0.x, R0, R0.y;
MULR  R0.y, R0.z, c[2];
MADR  R0.x, -R0.z, c[2].y, R0;
MADR  oCol, R0.x, c[0].x, R0.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_LerpAvgMax]
Vector 1 [_dUV]
SetTexture 0 [_MainTex] 2D

"ps_3_0
dcl_2d s0
def c2, 0.50000000, 0.25000000, 0, 0
dcl_texcoord0 v0.xyzw
mov r0.xyz, c1
mad r1.xyz, c2.x, -r0, v0.xyww
add r2.xyz, r1, c1.xzzw
texldl r0.x, r2.xyzz, s0
add r0.yzw, r2.xxyz, c1.xzyz
texldl r2.x, r1.xyzz, s0
texldl r1.x, r0.yzzw, s0
max r1.y, r2.x, r0.x
add r0.yzw, r0, -c1.xxzz
add r1.z, r2.x, r0.x
texldl r0.x, r0.yzzw, s0
add r0.y, r1.z, r1.x
add r0.y, r0, r0.x
max r1.y, r1.x, r1
max r0.x, r0, r1.y
mul r0.z, r0.y, c2.y
mad r0.x, -r0.y, c2.y, r0
mad oC0, r0.x, c0.x, r0.z

"
}

}

		}

		// This pass is the last one and downscales the main texture down to a 1x1
		//	and takes the exp of the result
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
Float 0 [_LerpAvgMax]
SetTexture 0 [_MainTex] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 0.25, 0.75, 0.00390625 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   R1.x, c[1].x, texture[0], 2D;
TEX   R2.x, c[1].yxzw, texture[0], 2D;
ADDR  R0.z, R1.x, R2.x;
MAXR  R0.y, R1.x, R2.x;
TEX   R0.x, c[1], texture[0], 2D;
MAXR  R0.y, R0.x, R0;
TEX   R1.x, c[1].y, texture[0], 2D;
ADDR  R0.x, R0.z, R0;
ADDR  R0.x, R0, R1;
MULR  R0.z, R0.x, c[1].x;
MAXR  R0.y, R1.x, R0;
MADR  R0.x, -R0, c[1], R0.y;
MADR  R0.x, R0, c[0], R0.z;
FLRR  R0.y, R0.x;
MULR  R0.y, R0, c[1].z;
FLRR  R0.z, R0.y;
MULR  R0.z, R0, c[1];
FLRR  R0.w, R0.z;
MULR  R0.w, R0, c[1].z;
FRCR  oCol.w, R0;
FRCR  oCol.z, R0;
FRCR  oCol.y, R0;
FRCR  oCol.x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_LerpAvgMax]
SetTexture 0 [_MainTex] 2D

"ps_3_0
dcl_2d s0
def c1, 0.25000000, 0.00000000, 0.75000000, 0.00390625
texldl r1.x, c1.xxzy, s0
texldl r2.x, c1.zxzy, s0
add r0.z, r1.x, r2.x
max r0.y, r1.x, r2.x
texldl r0.x, c1.xzzy, s0
max r0.y, r0.x, r0
texldl r1.x, c1.zzzy, s0
add r0.x, r0.z, r0
add r0.x, r0, r1
mul r0.z, r0.x, c1.x
max r0.y, r1.x, r0
mad r0.x, -r0, c1, r0.y
mad r0.y, r0.x, c0.x, r0.z
frc r0.x, r0.y
add r0.y, r0, -r0.x
mul r0.z, r0.y, c1.w
frc r0.y, r0.z
add r0.z, r0, -r0.y
mul r0.w, r0.z, c1
frc r0.z, r0.w
add r0.w, r0, -r0.z
mul r0.w, r0, c1
frc r0.w, r0
mov oC0, r0

"
}

}

		}
	}
	Fallback off
}
