// This shader is responsible for combining the result of the Nuaj' Manager modules with the default rendering without atmospheric effects
// It also manages basic tone mapping
//
Shader "Hidden/Nuaj/ComposeAtmosphere"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexScattering( "Base (RGB)", 2D ) = "Black" {}

_DEBUGTexLuminance0( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance1( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance2( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance3( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance4( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance5( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance6( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance7( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance8( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLuminance9( "Base (RGB)", 2D ) = "Black" {}

_DEBUGSkyEnvMap0( "Base (RGB)", 2D ) = "Black" {}
_DEBUGSkyEnvMap1( "Base (RGB)", 2D ) = "Black" {}
_DEBUGSkyEnvMap2( "Base (RGB)", 2D ) = "Black" {}
_DEBUGSkyEnvMap3( "Base (RGB)", 2D ) = "Black" {}
_DEBUGSkyEnvMap4( "Base (RGB)", 2D ) = "Black" {}
_DEBUGSkyEnvMap( "Base (RGB)", 2D ) = "Black" {}
_DEBUGSunEnvMap( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexDensity( "Base (RGB)", 2D ) = "Black" {}

_DEBUGLayerEnvSky0( "Base (RGB)", 2D ) = "Black" {}
_DEBUGLayerEnvSky1( "Base (RGB)", 2D ) = "Black" {}
_DEBUGLayerEnvSky2( "Base (RGB)", 2D ) = "Black" {}
_DEBUGLayerEnvSky3( "Base (RGB)", 2D ) = "Black" {}
_DEBUGLayerEnvSun0( "Base (RGB)", 2D ) = "Black" {}
_DEBUGLayerEnvSun1( "Base (RGB)", 2D ) = "Black" {}
_DEBUGLayerEnvSun2( "Base (RGB)", 2D ) = "Black" {}
_DEBUGLayerEnvSun3( "Base (RGB)", 2D ) = "Black" {}


_DEBUGTexPrecisionTest128x128( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexPrecisionTest256( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexShadowMap( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexLightCookie( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexCloudVolume( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexCloudLayer( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexFogLayer( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexSky( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexBackground( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexBackgroundEnvironment( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexDeepShadowMap0( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexDeepShadowMap1( "Base (RGB)", 2D ) = "Black" {}
_DEBUGTexDeepShadowMap2( "Base (RGB)", 2D ) = "Black" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend Off
		ColorMask RGBA

		// Filmic
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
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_Filmic_A]
Float 9 [_Filmic_B]
Float 10 [_Filmic_C]
Float 11 [_Filmic_D]
Float 12 [_Filmic_E]
Float 13 [_Filmic_F]
Float 14 [_Filmic_W]
Float 15 [_FilmicMiddleGrey]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[26] = { program.local[0..15],
		{ 0, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 9.9999997e-006 },
		{ 0.63999999, 0, 0.5, 0.001 },
		{ 0.075300001, -0.2543, 1.1892, 2 },
		{ 2.5651, -1.1665, -0.39860001, 3 },
		{ -1.0217, 1.9777, 0.043900002, 0.0099999998 },
		{ 0.0241188, 0.1228178, 0.84442663 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
MADH  H0.y, H0, c[17].x, -c[17].x;
MULR  R0.x, H0.y, c[17].y;
FRCR  R0.y, R0.x;
ADDH  H0.x, H0, c[16].z;
MULH  H0.z, H0.x, c[16].w;
SGEH  H0.xy, c[16].x, R1.wyzw;
MADH  H0.y, H0, c[16], H0.z;
FLRR  R0.x, R0;
ADDR  R0.z, H0.y, R0.x;
MULR  R0.x, R0.y, c[18];
MULR  R0.y, R0.z, c[17].z;
ADDR  R0.z, -R0.y, -R0.x;
LG2H  H0.y, |R1.w|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.y, H0, c[16].z;
MULH  H0.y, H0, c[16].w;
MADR  R0.w, R1.x, R0.z, R1.x;
RCPR  R1.y, R0.x;
MULR  R2.x, R1, R0.y;
MULR  R0.xyz, R1.x, c[21];
MULR  R1.x, R1.y, R2;
MULR  R0.w, R0, R1.y;
MADR  R0.xyz, R1.x, c[20], R0;
MADR  R0.xyz, R0.w, c[19], R0;
MAXR  R0.xyz, R0, c[16].x;
MAXR  R3.xyz, R0, c[17].w;
MULR  R0.xyz, R3.y, c[24];
MOVR  R2.xyz, c[25];
DP3R  R1.x, R2, c[0];
MADR  R0.xyz, R3.x, c[23], R0;
MADR  R2.xyz, R3.z, c[22], R0;
MOVR  R0.w, c[15].x;
RCPR  R1.x, R1.x;
MULR  R0.w, R0, c[1].x;
MULR  R0.w, R0, R1.x;
MULR  R0.z, R2.y, R0.w;
MOVR  R0.y, c[13].x;
MULR  R0.w, R0.y, c[11].x;
MOVR  R0.x, c[9];
MADR  R0.y, R0.z, c[8].x, R0.x;
MADR  R1.x, R0.z, R0.y, R0.w;
MULR  R0.x, R0, c[10];
MOVR  R0.y, c[12].x;
MAXR  R1.x, R1, c[18].w;
MADR  R1.y, R0.z, c[8].x, R0.x;
MULR  R0.y, R0, c[11].x;
MADR  R0.z, R0, R1.y, R0.y;
MOVR  R1.y, c[14].x;
MADR  R0.x, R1.y, c[8], R0;
MULR  R2.w, R1.y, c[8].x;
ADDR  R1.y, R2.w, c[9].x;
MADR  R0.x, R0, c[14], R0.y;
MADR  R0.w, R1.y, c[14].x, R0;
RCPR  R0.y, c[13].x;
MAXR  R0.w, R0, c[18];
RCPR  R1.x, R1.x;
MULR  R0.y, R0, c[12].x;
RCPR  R0.w, R0.w;
MADR  R0.x, R0, R0.w, -R0.y;
MADR  R0.y, R0.z, R1.x, -R0;
RCPR  R0.x, R0.x;
MULR  R0.y, R0, R0.x;
MOVR  R0.z, c[18];
MADR  R0.x, R0.z, -c[4], c[4];
RCPR  R0.w, R0.x;
MADR  R0.z, R0, -c[4].x, R0.y;
MULR_SAT R0.z, R0, R0.w;
MOVR  R0.x, c[20].w;
MADR  R0.w, -R0.z, c[19], R0.x;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
POWR  R0.w, R0.y, c[2].x;
POWR  R0.y, R0.y, c[3].x;
ADDR  R1.x, R0.y, -R0.w;
MADR  R3.x, R0.z, R1, R0.w;
ADDR  R0.y, c[7], -c[7].x;
RCPR  R0.z, R0.y;
ADDR  R0.y, R3.x, -c[7].x;
MULR_SAT R0.y, R0, R0.z;
MADR  R0.x, -R0.y, c[19].w, R0;
MULR  R0.y, R0, R0;
MULR  R1.y, R0, R0.x;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MAXR  R2.w, R0, R1.y;
ADDR  R2.w, R2, -R1.y;
MADR  R1.y, R2.w, c[6].x, R1;
ADDR  R1.x, R2, R2.y;
ADDR  R1.x, R2.z, R1;
ADDR  R2.w, -R0, R1.y;
RCPR  R1.x, R1.x;
MULR  R1.xy, R2, R1.x;
MULR  R3.z, R1.x, R3.x;
RCPR  R3.y, R1.y;
ADDR  R1.x, -R1, -R1.y;
MADR  R1.x, R1, R3, R3;
MULR  R1.x, R1, R3.y;
MULR  R3.z, R3.y, R3;
MULR  R2.xyz, R3.x, c[21];
MADR  R2.xyz, R3.z, c[20], R2;
MADR  R2.xyz, R1.x, c[19], R2;
MADH  H0.z, H0, c[17].x, -c[17].x;
MULR  R1.x, H0.z, c[17].y;
FRCR  R1.y, R1.x;
MULR  R1.y, R1, c[18].x;
MAXR  R2.xyz, R2, c[16].x;
FLRR  R1.x, R1;
MADH  H0.x, H0, c[16].y, H0.y;
ADDR  R1.x, H0, R1;
MULR  R3.x, R1, c[17].z;
ADDR  R1.x, -R3, -R1.y;
MADR  R1.x, R1, R1.z, R1.z;
RCPR  R1.y, R1.y;
MULR  R3.x, R3, R1.z;
MULR  R1.w, R1.x, R1.y;
MAXR  R1.x, c[0], c[0].y;
MULR  R3.y, R1, R3.x;
MAXR  R1.x, R1, c[0].z;
MAXR  R3.x, R1, c[21].w;
MULR  R1.xyz, R1.z, c[21];
MADR  R1.xyz, R3.y, c[20], R1;
RCPR  R3.x, R3.x;
MULR  R3.xyz, R3.x, c[0];
MADR  R1.xyz, R1.w, c[19], R1;
MULR  R2.xyz, R2, R3;
MAXR  R1.xyz, R1, c[16].x;
MADR  oCol.xyz, R0, R1, R2;
MADR  oCol.w, R2, c[5].x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_Filmic_A]
Float 9 [_Filmic_B]
Float 10 [_Filmic_C]
Float 11 [_Filmic_D]
Float 12 [_Filmic_E]
Float 13 [_Filmic_F]
Float 14 [_Filmic_W]
Float 15 [_FilmicMiddleGrey]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c16, 1.00000000, 0.00000000, 15.00000000, 4.00000000
def c17, 128.00000000, -1.00000000, 1024.00000000, 0.00390625
def c18, 0.00476190, 0.63999999, 0.00001000, 0.00100000
def c19, -1.02170002, 1.97770000, 0.04390000, 0.50000000
def c20, 2.56509995, -1.16649997, -0.39860001, 0.01000000
def c21, 0.07530000, -0.25430000, 1.18920004, 0
def c22, 0.26506799, 0.67023426, 0.06409157, 0
def c23, 0.51413637, 0.32387859, 0.16036376, 0
def c24, 0.02411880, 0.12281780, 0.84442663, 0
def c25, 0.21259999, 0.71520001, 0.07220000, 0
def c26, 2.00000000, 3.00000000, 0, 0
dcl_texcoord0 v0.xyzw
texldl r1, v0, s1
abs_pp r0.x, r1.y
log_pp r0.y, r0.x
frc_pp r0.z, r0.y
add_pp r0.y, r0, -r0.z
exp_pp r0.z, -r0.y
mad_pp r0.x, r0, r0.z, c17.y
mul_pp r0.x, r0, c17.z
mul r0.z, r0.x, c17.w
frc r0.w, r0.z
add_pp r0.x, r0.y, c16.z
mul_pp r0.y, r0.x, c16.w
cmp_pp r0.x, -r1.y, c16, c16.y
mad_pp r0.x, r0, c17, r0.y
add r0.z, r0, -r0.w
add r0.x, r0, r0.z
mov r2.w, c8.x
mul r2.w, c14.x, r2
mul r0.y, r0.w, c18
mul r0.x, r0, c18
add r0.z, -r0.x, -r0.y
mul r0.w, r1.x, r0.x
rcp r0.x, r0.y
mul r0.y, r0.x, r0.w
mul r2.xyz, r1.x, c19
add r0.z, r0, c16.x
mul r0.z, r1.x, r0
mov r0.w, c1.x
mad r2.xyz, r0.y, c20, r2
mul r0.x, r0.z, r0
mad r0.xyz, r0.x, c21, r2
max r0.xyz, r0, c16.y
max r3.xyz, r0, c18.z
mul r0.xyz, r3.y, c22
mov r2.xyz, c0
dp3 r1.x, c25, r2
mad r0.xyz, r3.x, c23, r0
mad r2.xyz, r3.z, c24, r0
mov r0.x, c11
mul r0.x, c13, r0
rcp r1.x, r1.x
mul r0.w, c15.x, r0
mul r0.w, r0, r1.x
mul r0.w, r2.y, r0
mul r0.y, r0.w, c8.x
add r0.y, r0, c9.x
mad r0.y, r0.w, r0, r0.x
max r1.y, r0, c18.w
mov r0.y, c10.x
mul r0.z, c9.x, r0.y
mov r1.x, c11
mul r0.y, c12.x, r1.x
mad r1.x, r0.w, c8, r0.z
mad r0.w, r0, r1.x, r0.y
rcp r1.x, r1.y
rcp r1.y, c13.x
mul r1.y, r1, c12.x
mad r0.w, r0, r1.x, -r1.y
add r2.w, r2, c9.x
mad r1.x, r2.w, c14, r0
mov r0.x, c8
mad r0.x, c14, r0, r0.z
mad r0.x, r0, c14, r0.y
max r1.x, r1, c18.w
rcp r0.z, r1.x
mad r0.x, r0, r0.z, -r1.y
rcp r0.x, r0.x
mul r1.x, r0.w, r0
pow r3, r1.x, c3.x
abs_pp r3.y, r1.w
log_pp r4.x, r3.y
mov r0.y, c19.w
mad r0.y, r0, -c4.x, c4.x
mov r0.x, c4
frc_pp r3.w, r4.x
mad r0.x, c19.w, -r0, r1
rcp r0.y, r0.y
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c26.x, c26
mul r0.x, r0, r0
mul r1.y, r0.x, r0
pow r0, r1.x, c2.x
mov r0.y, r0.x
add r1.x, r2, r2.y
mov r0.x, r3
add r0.x, r0, -r0.y
mad r3.x, r1.y, r0, r0.y
add r0.z, c7.y, -c7.x
add r1.x, r2.z, r1
rcp r0.y, r0.z
add r0.x, r3, -c7
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c26.x, c26
mul r0.x, r0, r0
mul r1.y, r0.x, r0
texldl r0, v0, s0
max r2.w, r0, r1.y
add r2.z, r2.w, -r1.y
mad r2.z, r2, c6.x, r1.y
add r2.w, -r0, r2.z
rcp r1.x, r1.x
mul r1.xy, r2, r1.x
rcp r3.z, r1.y
mul r2.x, r1, r3
mul r4.y, r3.z, r2.x
mul r2.xyz, r3.x, c19
add r1.y, -r1.x, -r1
add_pp r3.w, r4.x, -r3
exp_pp r1.x, -r3.w
mad_pp r1.x, r3.y, r1, c17.y
add r1.y, r1, c16.x
mul r1.y, r1, r3.x
mul r3.x, r1.y, r3.z
mul_pp r1.x, r1, c17.z
mul r1.y, r1.x, c17.w
mad r2.xyz, r4.y, c20, r2
mad r2.xyz, r3.x, c21, r2
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r3.w, c16.z
mul_pp r1.y, r1.x, c16.w
cmp_pp r1.x, -r1.w, c16, c16.y
mad_pp r1.x, r1, c17, r1.y
mul r1.y, r3.x, c18
add r1.x, r1, r3.y
mul r1.x, r1, c18
add r1.w, -r1.x, -r1.y
rcp r3.x, r1.y
add r1.w, r1, c16.x
mul r1.y, r1.w, r1.z
mul r1.w, r1.y, r3.x
mul r1.x, r1, r1.z
max r1.y, c0.x, c0
max r1.y, r1, c0.z
max r3.y, r1, c20.w
mul r3.x, r3, r1
mul r1.xyz, r1.z, c19
mad r1.xyz, r3.x, c20, r1
rcp r3.y, r3.y
mad r1.xyz, r1.w, c21, r1
max r2.xyz, r2, c16.y
mul r3.xyz, r3.y, c0
mul r2.xyz, r2, r3
max r1.xyz, r1, c16.y
mad oC0.xyz, r0, r1, r2
mad oC0.w, r2, c5.x, r0

"
}

}

		}

		// Reinhard
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
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_ReinhardMiddleGrey]
Float 9 [_ReinhardWhiteLuminance]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[20] = { program.local[0..9],
		{ 0, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.5 },
		{ 0.63999999, 0, 0.001, 1 },
		{ 0.075300001, -0.2543, 1.1892, 2 },
		{ 2.5651, -1.1665, -0.39860001, 3 },
		{ -1.0217, 1.9777, 0.043900002, 0.0099999998 },
		{ 0.0241188, 0.1228178, 0.84442663 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
MADH  H0.y, H0, c[11].x, -c[11].x;
MULR  R0.x, H0.y, c[11].y;
FRCR  R0.y, R0.x;
ADDH  H0.x, H0, c[10].z;
MULH  H0.z, H0.x, c[10].w;
SGEH  H0.xy, c[10].x, R1.wyzw;
MADH  H0.y, H0, c[10], H0.z;
FLRR  R0.x, R0;
ADDR  R0.z, H0.y, R0.x;
MULR  R0.x, R0.y, c[12];
MULR  R0.y, R0.z, c[11].z;
ADDR  R0.z, -R0.y, -R0.x;
LG2H  H0.y, |R1.w|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.y, H0, c[10].z;
MULH  H0.y, H0, c[10].w;
MADR  R0.w, R1.x, R0.z, R1.x;
RCPR  R1.y, R0.x;
MULR  R2.x, R1, R0.y;
MULR  R0.xyz, R1.x, c[15];
MULR  R1.x, R1.y, R2;
MULR  R0.w, R0, R1.y;
MADR  R0.xyz, R1.x, c[14], R0;
MADR  R0.xyz, R0.w, c[13], R0;
MAXR  R0.xyz, R0, c[10].x;
MULR  R3.xyz, R0.y, c[18];
MOVR  R2.xyz, c[19];
DP3R  R0.y, R2, c[0];
MADR  R2.xyz, R0.x, c[17], R3;
ADDR  R0.x, R0.y, c[12].z;
MADR  R2.xyz, R0.z, c[16], R2;
RCPR  R0.y, R0.x;
MULR  R0.x, R2.y, c[8];
MULR  R0.x, R0, R0.y;
MULR  R0.y, c[9].x, c[9].x;
ADDR  R0.w, R0.x, c[12];
MULR  R0.z, R0.x, c[1].x;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MADR  R0.x, R0, R0.z, R0.z;
RCPR  R0.y, R0.w;
MULR  R0.y, R0.x, R0;
MOVR  R0.z, c[11].w;
MADR  R0.x, R0.z, -c[4], c[4];
RCPR  R0.w, R0.x;
MADR  R0.z, R0, -c[4].x, R0.y;
MULR_SAT R0.z, R0, R0.w;
MOVR  R0.x, c[14].w;
MADR  R0.w, -R0.z, c[13], R0.x;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
POWR  R0.w, R0.y, c[2].x;
POWR  R0.y, R0.y, c[3].x;
ADDR  R1.x, R0.y, -R0.w;
MADR  R3.x, R0.z, R1, R0.w;
ADDR  R0.y, c[7], -c[7].x;
RCPR  R0.z, R0.y;
ADDR  R0.y, R3.x, -c[7].x;
MULR_SAT R0.y, R0, R0.z;
MADR  R0.x, -R0.y, c[13].w, R0;
MULR  R0.y, R0, R0;
MULR  R1.y, R0, R0.x;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MAXR  R2.w, R0, R1.y;
ADDR  R2.w, R2, -R1.y;
MADR  R1.y, R2.w, c[6].x, R1;
ADDR  R1.x, R2, R2.y;
ADDR  R1.x, R2.z, R1;
ADDR  R2.w, -R0, R1.y;
RCPR  R1.x, R1.x;
MULR  R1.xy, R2, R1.x;
MULR  R3.z, R1.x, R3.x;
RCPR  R3.y, R1.y;
ADDR  R1.x, -R1, -R1.y;
MADR  R1.x, R1, R3, R3;
MULR  R1.x, R1, R3.y;
MULR  R3.z, R3.y, R3;
MULR  R2.xyz, R3.x, c[15];
MADR  R2.xyz, R3.z, c[14], R2;
MADR  R2.xyz, R1.x, c[13], R2;
MADH  H0.z, H0, c[11].x, -c[11].x;
MULR  R1.x, H0.z, c[11].y;
FRCR  R1.y, R1.x;
MULR  R1.y, R1, c[12].x;
MAXR  R2.xyz, R2, c[10].x;
FLRR  R1.x, R1;
MADH  H0.x, H0, c[10].y, H0.y;
ADDR  R1.x, H0, R1;
MULR  R3.x, R1, c[11].z;
ADDR  R1.x, -R3, -R1.y;
MADR  R1.x, R1, R1.z, R1.z;
RCPR  R1.y, R1.y;
MULR  R3.x, R3, R1.z;
MULR  R1.w, R1.x, R1.y;
MAXR  R1.x, c[0], c[0].y;
MULR  R3.y, R1, R3.x;
MAXR  R1.x, R1, c[0].z;
MAXR  R3.x, R1, c[15].w;
MULR  R1.xyz, R1.z, c[15];
MADR  R1.xyz, R3.y, c[14], R1;
RCPR  R3.x, R3.x;
MULR  R3.xyz, R3.x, c[0];
MADR  R1.xyz, R1.w, c[13], R1;
MULR  R2.xyz, R2, R3;
MAXR  R1.xyz, R1, c[10].x;
MADR  oCol.xyz, R0, R1, R2;
MADR  oCol.w, R2, c[5].x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_ReinhardMiddleGrey]
Float 9 [_ReinhardWhiteLuminance]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c10, 1.00000000, 0.00000000, 15.00000000, 4.00000000
def c11, 128.00000000, -1.00000000, 1024.00000000, 0.00390625
def c12, 0.00476190, 0.63999999, 0.00100000, 0.50000000
def c13, -1.02170002, 1.97770000, 0.04390000, 0.01000000
def c14, 2.56509995, -1.16649997, -0.39860001, 0
def c15, 0.07530000, -0.25430000, 1.18920004, 0
def c16, 0.26506799, 0.67023426, 0.06409157, 0
def c17, 0.51413637, 0.32387859, 0.16036376, 0
def c18, 0.02411880, 0.12281780, 0.84442663, 0
def c19, 0.21259999, 0.71520001, 0.07220000, 0
def c20, 2.00000000, 3.00000000, 0, 0
dcl_texcoord0 v0.xyzw
texldl r1, v0, s1
abs_pp r0.x, r1.y
log_pp r0.y, r0.x
frc_pp r0.z, r0.y
add_pp r0.y, r0, -r0.z
exp_pp r0.z, -r0.y
mad_pp r0.x, r0, r0.z, c11.y
mul_pp r0.x, r0, c11.z
mul r0.z, r0.x, c11.w
frc r0.w, r0.z
add_pp r0.x, r0.y, c10.z
mul_pp r0.y, r0.x, c10.w
cmp_pp r0.x, -r1.y, c10, c10.y
mad_pp r0.x, r0, c11, r0.y
add r0.z, r0, -r0.w
add r0.x, r0, r0.z
mul r0.y, r0.w, c12
mul r0.x, r0, c12
add r0.z, -r0.x, -r0.y
mul r0.w, r1.x, r0.x
rcp r0.x, r0.y
add r0.z, r0, c10.x
mul r0.y, r0.x, r0.w
mul r0.z, r1.x, r0
mul r2.xyz, r1.x, c13
mad r2.xyz, r0.y, c14, r2
mul r0.x, r0.z, r0
mad r0.xyz, r0.x, c15, r2
max r2.xyz, r0, c10.y
mul r0.xyz, r2.y, c16
mad r3.xyz, r2.x, c17, r0
mov r0.xyz, c0
dp3 r0.y, c19, r0
mad r2.xyz, r2.z, c18, r3
add r0.y, r0, c12.z
mul r0.z, c9.x, c9.x
mul r0.x, r2.y, c8
rcp r0.y, r0.y
mul r0.x, r0, r0.y
rcp r0.z, r0.z
mad r0.z, r0.x, r0, c10.x
mul r0.y, r0.x, c1.x
mul r0.y, r0, r0.z
add r0.x, r0, c10
rcp r0.x, r0.x
mul r1.x, r0.y, r0
pow r3, r1.x, c3.x
abs_pp r3.y, r1.w
log_pp r4.x, r3.y
mov r0.z, c12.w
mad r0.z, r0, -c4.x, c4.x
mov r0.x, c4
frc_pp r3.w, r4.x
rcp r0.y, r0.z
mad r0.x, c12.w, -r0, r1
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c20.x, c20
mul r0.x, r0, r0
mul r1.y, r0.x, r0
pow r0, r1.x, c2.x
mov r0.y, r0.x
add r1.x, r2, r2.y
mov r0.x, r3
add r0.x, r0, -r0.y
mad r3.x, r1.y, r0, r0.y
add r0.z, c7.y, -c7.x
add r1.x, r2.z, r1
rcp r0.y, r0.z
add r0.x, r3, -c7
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c20.x, c20
mul r0.x, r0, r0
mul r1.y, r0.x, r0
texldl r0, v0, s0
max r2.w, r0, r1.y
add r2.z, r2.w, -r1.y
mad r2.z, r2, c6.x, r1.y
add r2.w, -r0, r2.z
rcp r1.x, r1.x
mul r1.xy, r2, r1.x
rcp r3.z, r1.y
mul r2.x, r1, r3
mul r4.y, r3.z, r2.x
mul r2.xyz, r3.x, c13
add r1.y, -r1.x, -r1
add_pp r3.w, r4.x, -r3
exp_pp r1.x, -r3.w
mad_pp r1.x, r3.y, r1, c11.y
add r1.y, r1, c10.x
mul r1.y, r1, r3.x
mul r3.x, r1.y, r3.z
mul_pp r1.x, r1, c11.z
mul r1.y, r1.x, c11.w
mad r2.xyz, r4.y, c14, r2
mad r2.xyz, r3.x, c15, r2
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r3.w, c10.z
mul_pp r1.y, r1.x, c10.w
cmp_pp r1.x, -r1.w, c10, c10.y
mad_pp r1.x, r1, c11, r1.y
mul r1.y, r3.x, c12
add r1.x, r1, r3.y
mul r1.x, r1, c12
add r1.w, -r1.x, -r1.y
rcp r3.x, r1.y
add r1.w, r1, c10.x
mul r1.y, r1.w, r1.z
mul r1.w, r1.y, r3.x
mul r1.x, r1, r1.z
max r1.y, c0.x, c0
max r1.y, r1, c0.z
max r3.y, r1, c13.w
mul r3.x, r3, r1
mul r1.xyz, r1.z, c13
mad r1.xyz, r3.x, c14, r1
rcp r3.y, r3.y
mad r1.xyz, r1.w, c15, r1
max r2.xyz, r2, c10.y
mul r3.xyz, r3.y, c0
mul r2.xyz, r2, r3
max r1.xyz, r1, c10.y
mad oC0.xyz, r0, r1, r2
mad oC0.w, r2, c5.x, r0

"
}

}

		}

		// Drago
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
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_DragoMaxDisplayLuminance]
Float 9 [_DragoBias]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[21] = { program.local[0..9],
		{ 0, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.5 },
		{ 0.63999999, 0, 1, 0.69314718 },
		{ 0.075300001, -0.2543, 1.1892, 0.80000001 },
		{ 2.5651, -1.1665, -0.39860001, 2 },
		{ -1.0217, 1.9777, 0.043900002, 0.30103001 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.0099999998 },
		{ 0.51413637, 0.32387859, 0.16036376, 3 },
		{ 0.26506799, 0.67023426, 0.064091571 },
		{ 0.21259999, 0.71520001, 0.0722 },
		{ -1, 0 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
MADH  H0.y, H0, c[11].x, -c[11].x;
MULR  R0.x, H0.y, c[11].y;
FRCR  R0.y, R0.x;
ADDH  H0.x, H0, c[10].z;
MULH  H0.z, H0.x, c[10].w;
SGEH  H0.xy, c[10].x, R1.wyzw;
MADH  H0.y, H0, c[10], H0.z;
FLRR  R0.x, R0;
ADDR  R0.z, H0.y, R0.x;
MULR  R0.x, R0.y, c[12];
MULR  R0.y, R0.z, c[11].z;
ADDR  R0.z, -R0.y, -R0.x;
LG2H  H0.y, |R1.w|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.y, H0, c[10].z;
MULH  H0.y, H0, c[10].w;
MADR  R0.w, R1.x, R0.z, R1.x;
RCPR  R1.y, R0.x;
MULR  R2.x, R1, R0.y;
MULR  R0.xyz, R1.x, c[15];
MULR  R1.x, R1.y, R2;
MULR  R0.w, R0, R1.y;
MADR  R0.xyz, R1.x, c[14], R0;
MADR  R0.xyz, R0.w, c[13], R0;
MAXR  R3.xyz, R0, c[10].x;
MULR  R0.xyz, R3.y, c[18];
MOVR  R2.xyz, c[19];
MADR  R0.xyz, R3.x, c[17], R0;
DP3R  R0.w, R2, c[0];
MADR  R2.xyz, R3.z, c[16], R0;
RCPR  R0.y, R0.w;
LG2R  R0.x, c[9].x;
MULR  R0.z, R0.x, c[20].x;
MULR  R0.y, R2, R0;
POWR  R0.y, R0.y, R0.z;
MOVR  R0.x, c[14].w;
MADR  R0.y, R0, c[13].w, R0.x;
ADDR  R0.x, R2.y, c[12].z;
ADDR  R0.z, R0.w, c[12];
LG2R  R0.y, R0.y;
LG2R  R0.x, R0.x;
MULR  R0.x, R0, c[12].w;
LG2R  R0.z, R0.z;
MULR  R0.y, R0, c[12].w;
MULR  R0.y, R0.z, R0;
MULR  R0.y, R0, c[15].w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, c[8];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, c[1];
MULR  R0.y, R0.x, c[16].w;
MOVR  R0.z, c[11].w;
MADR  R0.x, R0.z, -c[4], c[4];
RCPR  R0.w, R0.x;
MADR  R0.z, R0, -c[4].x, R0.y;
MULR_SAT R0.z, R0, R0.w;
MOVR  R0.x, c[17].w;
MADR  R0.w, -R0.z, c[14], R0.x;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
POWR  R0.w, R0.y, c[2].x;
POWR  R0.y, R0.y, c[3].x;
ADDR  R1.x, R0.y, -R0.w;
MADR  R3.x, R0.z, R1, R0.w;
ADDR  R0.y, c[7], -c[7].x;
RCPR  R0.z, R0.y;
ADDR  R0.y, R3.x, -c[7].x;
MULR_SAT R0.y, R0, R0.z;
MADR  R0.x, -R0.y, c[14].w, R0;
MULR  R0.y, R0, R0;
MULR  R1.y, R0, R0.x;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MAXR  R2.w, R0, R1.y;
ADDR  R2.w, R2, -R1.y;
MADR  R1.y, R2.w, c[6].x, R1;
ADDR  R1.x, R2, R2.y;
ADDR  R1.x, R2.z, R1;
ADDR  R2.w, -R0, R1.y;
RCPR  R1.x, R1.x;
MULR  R1.xy, R2, R1.x;
MULR  R3.z, R1.x, R3.x;
RCPR  R3.y, R1.y;
ADDR  R1.x, -R1, -R1.y;
MADR  R1.x, R1, R3, R3;
MULR  R1.x, R1, R3.y;
MULR  R3.z, R3.y, R3;
MULR  R2.xyz, R3.x, c[15];
MADR  R2.xyz, R3.z, c[14], R2;
MADR  R2.xyz, R1.x, c[13], R2;
MADH  H0.z, H0, c[11].x, -c[11].x;
MULR  R1.x, H0.z, c[11].y;
FRCR  R1.y, R1.x;
MULR  R1.y, R1, c[12].x;
MAXR  R2.xyz, R2, c[10].x;
FLRR  R1.x, R1;
MADH  H0.x, H0, c[10].y, H0.y;
ADDR  R1.x, H0, R1;
MULR  R3.x, R1, c[11].z;
ADDR  R1.x, -R3, -R1.y;
MADR  R1.x, R1, R1.z, R1.z;
RCPR  R1.y, R1.y;
MULR  R3.x, R3, R1.z;
MULR  R1.w, R1.x, R1.y;
MAXR  R1.x, c[0], c[0].y;
MULR  R3.y, R1, R3.x;
MAXR  R1.x, R1, c[0].z;
MAXR  R3.x, R1, c[16].w;
MULR  R1.xyz, R1.z, c[15];
MADR  R1.xyz, R3.y, c[14], R1;
RCPR  R3.x, R3.x;
MULR  R3.xyz, R3.x, c[0];
MADR  R1.xyz, R1.w, c[13], R1;
MULR  R2.xyz, R2, R3;
MAXR  R1.xyz, R1, c[10].x;
MADR  oCol.xyz, R0, R1, R2;
MADR  oCol.w, R2, c[5].x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_DragoMaxDisplayLuminance]
Float 9 [_DragoBias]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c10, 1.00000000, 0.00000000, 15.00000000, 4.00000000
def c11, 128.00000000, -1.00000000, 1024.00000000, 0.00390625
def c12, 0.00476190, 0.63999999, 0.69314718, 0.30103001
def c13, -1.02170002, 1.97770000, 0.04390000, 0.01000000
def c14, 2.56509995, -1.16649997, -0.39860001, 0.50000000
def c15, 0.07530000, -0.25430000, 1.18920004, 0
def c16, 0.26506799, 0.67023426, 0.06409157, 0
def c17, 0.51413637, 0.32387859, 0.16036376, 0
def c18, 0.02411880, 0.12281780, 0.84442663, 0
def c19, 0.21259999, 0.71520001, 0.07220000, 0
def c20, 0.80000001, 2.00000000, 3.00000000, 0
dcl_texcoord0 v0.xyzw
texldl r1, v0, s1
abs_pp r0.x, r1.y
log_pp r0.y, r0.x
frc_pp r0.z, r0.y
add_pp r0.y, r0, -r0.z
exp_pp r0.z, -r0.y
mad_pp r0.x, r0, r0.z, c11.y
mul_pp r0.x, r0, c11.z
mul r0.z, r0.x, c11.w
frc r0.w, r0.z
add_pp r0.x, r0.y, c10.z
mul_pp r0.y, r0.x, c10.w
cmp_pp r0.x, -r1.y, c10, c10.y
mad_pp r0.x, r0, c11, r0.y
add r0.z, r0, -r0.w
add r0.x, r0, r0.z
mul r0.y, r0.w, c12
mul r0.x, r0, c12
add r0.z, -r0.x, -r0.y
mul r0.w, r1.x, r0.x
rcp r0.x, r0.y
add r0.z, r0, c10.x
mul r0.y, r0.x, r0.w
mul r0.z, r1.x, r0
mul r2.xyz, r1.x, c13
mad r2.xyz, r0.y, c14, r2
mul r0.x, r0.z, r0
mad r0.xyz, r0.x, c15, r2
max r2.xyz, r0, c10.y
mul r0.xyz, r2.y, c16
mad r3.xyz, r2.x, c17, r0
mov r0.xyz, c0
dp3 r1.x, c19, r0
log r0.y, c9.x
mad r2.xyz, r2.z, c18, r3
rcp r0.x, r1.x
mul r1.y, r2, r0.x
mul r2.w, r0.y, c11.y
pow r0, r1.y, r2.w
mad r0.y, r0.x, c20.x, c20
log r0.z, r0.y
add r0.x, r2.y, c10
add r0.y, r1.x, c10.x
log r0.x, r0.x
mul r0.x, r0, c12.z
mul r0.z, r0, c12
log r0.y, r0.y
mul r0.y, r0, r0.z
mul r0.y, r0, c12.w
rcp r0.y, r0.y
mul r0.x, r0, c8
mul r0.x, r0, r0.y
mul r0.x, r0, c1
mul r1.x, r0, c13.w
pow r3, r1.x, c3.x
abs_pp r3.y, r1.w
log_pp r4.x, r3.y
mov r0.y, c14.w
mad r0.y, r0, -c4.x, c4.x
mov r0.x, c4
frc_pp r3.w, r4.x
mad r0.x, c14.w, -r0, r1
rcp r0.y, r0.y
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c20, c20.z
mul r0.x, r0, r0
mul r1.y, r0.x, r0
pow r0, r1.x, c2.x
mov r0.y, r0.x
add r1.x, r2, r2.y
mov r0.x, r3
add r0.x, r0, -r0.y
mad r3.x, r1.y, r0, r0.y
add r0.z, c7.y, -c7.x
add r1.x, r2.z, r1
rcp r0.y, r0.z
add r0.x, r3, -c7
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c20, c20.z
mul r0.x, r0, r0
mul r1.y, r0.x, r0
texldl r0, v0, s0
max r2.w, r0, r1.y
add r2.z, r2.w, -r1.y
mad r2.z, r2, c6.x, r1.y
add r2.w, -r0, r2.z
rcp r1.x, r1.x
mul r1.xy, r2, r1.x
rcp r3.z, r1.y
mul r2.x, r1, r3
mul r4.y, r3.z, r2.x
mul r2.xyz, r3.x, c13
add r1.y, -r1.x, -r1
add_pp r3.w, r4.x, -r3
exp_pp r1.x, -r3.w
mad_pp r1.x, r3.y, r1, c11.y
add r1.y, r1, c10.x
mul r1.y, r1, r3.x
mul r3.x, r1.y, r3.z
mul_pp r1.x, r1, c11.z
mul r1.y, r1.x, c11.w
mad r2.xyz, r4.y, c14, r2
mad r2.xyz, r3.x, c15, r2
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r3.w, c10.z
mul_pp r1.y, r1.x, c10.w
cmp_pp r1.x, -r1.w, c10, c10.y
mad_pp r1.x, r1, c11, r1.y
mul r1.y, r3.x, c12
add r1.x, r1, r3.y
mul r1.x, r1, c12
add r1.w, -r1.x, -r1.y
rcp r3.x, r1.y
add r1.w, r1, c10.x
mul r1.y, r1.w, r1.z
mul r1.w, r1.y, r3.x
mul r1.x, r1, r1.z
max r1.y, c0.x, c0
max r1.y, r1, c0.z
max r3.y, r1, c13.w
mul r3.x, r3, r1
mul r1.xyz, r1.z, c13
mad r1.xyz, r3.x, c14, r1
rcp r3.y, r3.y
mad r1.xyz, r1.w, c15, r1
max r2.xyz, r2, c10.y
mul r3.xyz, r3.y, c0
mul r2.xyz, r2, r3
max r1.xyz, r1, c10.y
mad oC0.xyz, r0, r1, r2
mad oC0.w, r2, c5.x, r0

"
}

}

		}

		// Exponential
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
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_ExponentialExposure]
Float 9 [_ExponentialGain]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[19] = { program.local[0..9],
		{ 0, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.5 },
		{ 0.63999999, 0, 2.718282, 2 },
		{ 0.075300001, -0.2543, 1.1892, 3 },
		{ 2.5651, -1.1665, -0.39860001, 0.0099999998 },
		{ -1.0217, 1.9777, 0.043900002 },
		{ 0.0241188, 0.1228178, 0.84442663 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
MADH  H0.y, H0, c[11].x, -c[11].x;
MULR  R0.x, H0.y, c[11].y;
FRCR  R0.y, R0.x;
ADDH  H0.x, H0, c[10].z;
MULH  H0.z, H0.x, c[10].w;
SGEH  H0.xy, c[10].x, R1.wyzw;
MADH  H0.y, H0, c[10], H0.z;
FLRR  R0.x, R0;
ADDR  R0.z, H0.y, R0.x;
MULR  R0.x, R0.y, c[12];
MULR  R0.y, R0.z, c[11].z;
ADDR  R0.z, -R0.y, -R0.x;
LG2H  H0.y, |R1.w|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.y, H0, c[10].z;
MULH  H0.y, H0, c[10].w;
MADR  R0.w, R1.x, R0.z, R1.x;
RCPR  R1.y, R0.x;
MULR  R2.x, R1, R0.y;
MULR  R0.xyz, R1.x, c[15];
MULR  R1.x, R1.y, R2;
MULR  R0.w, R0, R1.y;
MADR  R0.xyz, R1.x, c[14], R0;
MADR  R0.xyz, R0.w, c[13], R0;
MAXR  R0.xyz, R0, c[10].x;
MULR  R2.xyz, R0.y, c[18];
MADR  R2.xyz, R0.x, c[17], R2;
MADR  R2.xyz, R0.z, c[16], R2;
MULR  R0.x, R2.y, -c[8];
MOVR  R0.y, c[1].x;
POWR  R0.x, c[12].z, R0.x;
MULR  R0.y, R0, c[9].x;
MADR  R0.y, -R0.x, R0, R0;
MOVR  R0.z, c[11].w;
MADR  R0.x, R0.z, -c[4], c[4];
RCPR  R0.w, R0.x;
MADR  R0.z, R0, -c[4].x, R0.y;
MULR_SAT R0.z, R0, R0.w;
MOVR  R0.x, c[13].w;
MADR  R0.w, -R0.z, c[12], R0.x;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
POWR  R0.w, R0.y, c[2].x;
POWR  R0.y, R0.y, c[3].x;
ADDR  R1.x, R0.y, -R0.w;
MADR  R3.x, R0.z, R1, R0.w;
ADDR  R0.y, c[7], -c[7].x;
RCPR  R0.z, R0.y;
ADDR  R0.y, R3.x, -c[7].x;
MULR_SAT R0.y, R0, R0.z;
MADR  R0.x, -R0.y, c[12].w, R0;
MULR  R0.y, R0, R0;
MULR  R1.y, R0, R0.x;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MAXR  R2.w, R0, R1.y;
ADDR  R2.w, R2, -R1.y;
MADR  R1.y, R2.w, c[6].x, R1;
ADDR  R1.x, R2, R2.y;
ADDR  R1.x, R2.z, R1;
ADDR  R2.w, -R0, R1.y;
RCPR  R1.x, R1.x;
MULR  R1.xy, R2, R1.x;
MULR  R3.z, R1.x, R3.x;
RCPR  R3.y, R1.y;
ADDR  R1.x, -R1, -R1.y;
MADR  R1.x, R1, R3, R3;
MULR  R1.x, R1, R3.y;
MULR  R3.z, R3.y, R3;
MULR  R2.xyz, R3.x, c[15];
MADR  R2.xyz, R3.z, c[14], R2;
MADR  R2.xyz, R1.x, c[13], R2;
MADH  H0.z, H0, c[11].x, -c[11].x;
MULR  R1.x, H0.z, c[11].y;
FRCR  R1.y, R1.x;
MULR  R1.y, R1, c[12].x;
MAXR  R2.xyz, R2, c[10].x;
FLRR  R1.x, R1;
MADH  H0.x, H0, c[10].y, H0.y;
ADDR  R1.x, H0, R1;
MULR  R3.x, R1, c[11].z;
ADDR  R1.x, -R3, -R1.y;
MADR  R1.x, R1, R1.z, R1.z;
RCPR  R1.y, R1.y;
MULR  R3.x, R3, R1.z;
MULR  R1.w, R1.x, R1.y;
MAXR  R1.x, c[0], c[0].y;
MULR  R3.y, R1, R3.x;
MAXR  R1.x, R1, c[0].z;
MAXR  R3.x, R1, c[14].w;
MULR  R1.xyz, R1.z, c[15];
MADR  R1.xyz, R3.y, c[14], R1;
RCPR  R3.x, R3.x;
MULR  R3.xyz, R3.x, c[0];
MADR  R1.xyz, R1.w, c[13], R1;
MULR  R2.xyz, R2, R3;
MAXR  R1.xyz, R1, c[10].x;
MADR  oCol.xyz, R0, R1, R2;
MADR  oCol.w, R2, c[5].x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_ExponentialExposure]
Float 9 [_ExponentialGain]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c10, 1.00000000, 0.00000000, 15.00000000, 4.00000000
def c11, 128.00000000, -1.00000000, 1024.00000000, 0.00390625
def c12, 0.00476190, 0.63999999, 2.71828198, 0.50000000
def c13, -1.02170002, 1.97770000, 0.04390000, 0.01000000
def c14, 2.56509995, -1.16649997, -0.39860001, 0
def c15, 0.07530000, -0.25430000, 1.18920004, 0
def c16, 0.26506799, 0.67023426, 0.06409157, 0
def c17, 0.51413637, 0.32387859, 0.16036376, 0
def c18, 0.02411880, 0.12281780, 0.84442663, 0
def c19, 2.00000000, 3.00000000, 0, 0
dcl_texcoord0 v0.xyzw
texldl r1, v0, s1
abs_pp r0.x, r1.y
log_pp r0.y, r0.x
frc_pp r0.z, r0.y
add_pp r0.y, r0, -r0.z
exp_pp r0.z, -r0.y
mad_pp r0.x, r0, r0.z, c11.y
mul_pp r0.x, r0, c11.z
mul r0.z, r0.x, c11.w
frc r0.w, r0.z
add_pp r0.x, r0.y, c10.z
mul_pp r0.y, r0.x, c10.w
cmp_pp r0.x, -r1.y, c10, c10.y
mad_pp r0.x, r0, c11, r0.y
add r0.z, r0, -r0.w
add r0.x, r0, r0.z
mul r0.y, r0.w, c12
mul r0.x, r0, c12
add r0.z, -r0.x, -r0.y
mul r0.w, r1.x, r0.x
rcp r0.x, r0.y
add r0.z, r0, c10.x
mul r0.y, r0.x, r0.w
mul r0.z, r1.x, r0
mul r2.xyz, r1.x, c13
mad r2.xyz, r0.y, c14, r2
mul r0.x, r0.z, r0
mad r0.xyz, r0.x, c15, r2
max r0.xyz, r0, c10.y
mul r2.xyz, r0.y, c16
mad r2.xyz, r0.x, c17, r2
mad r2.xyz, r0.z, c18, r2
mul r1.x, r2.y, -c8
pow r0, c12.z, r1.x
add r0.y, -r0.x, c10.x
mov r0.z, c12.w
mov r0.x, c9
mul r0.x, c1, r0
mul r1.x, r0, r0.y
pow r3, r1.x, c3.x
abs_pp r3.y, r1.w
log_pp r4.x, r3.y
mad r0.z, r0, -c4.x, c4.x
mov r0.x, c4
frc_pp r3.w, r4.x
rcp r0.y, r0.z
mad r0.x, c12.w, -r0, r1
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c19.x, c19
mul r0.x, r0, r0
mul r1.y, r0.x, r0
pow r0, r1.x, c2.x
mov r0.y, r0.x
add r1.x, r2, r2.y
mov r0.x, r3
add r0.x, r0, -r0.y
mad r3.x, r1.y, r0, r0.y
add r0.z, c7.y, -c7.x
add r1.x, r2.z, r1
rcp r0.y, r0.z
add r0.x, r3, -c7
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c19.x, c19
mul r0.x, r0, r0
mul r1.y, r0.x, r0
texldl r0, v0, s0
max r2.w, r0, r1.y
add r2.z, r2.w, -r1.y
mad r2.z, r2, c6.x, r1.y
add r2.w, -r0, r2.z
rcp r1.x, r1.x
mul r1.xy, r2, r1.x
rcp r3.z, r1.y
mul r2.x, r1, r3
mul r4.y, r3.z, r2.x
mul r2.xyz, r3.x, c13
add r1.y, -r1.x, -r1
add_pp r3.w, r4.x, -r3
exp_pp r1.x, -r3.w
mad_pp r1.x, r3.y, r1, c11.y
add r1.y, r1, c10.x
mul r1.y, r1, r3.x
mul r3.x, r1.y, r3.z
mul_pp r1.x, r1, c11.z
mul r1.y, r1.x, c11.w
mad r2.xyz, r4.y, c14, r2
mad r2.xyz, r3.x, c15, r2
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r3.w, c10.z
mul_pp r1.y, r1.x, c10.w
cmp_pp r1.x, -r1.w, c10, c10.y
mad_pp r1.x, r1, c11, r1.y
mul r1.y, r3.x, c12
add r1.x, r1, r3.y
mul r1.x, r1, c12
add r1.w, -r1.x, -r1.y
rcp r3.x, r1.y
add r1.w, r1, c10.x
mul r1.y, r1.w, r1.z
mul r1.w, r1.y, r3.x
mul r1.x, r1, r1.z
max r1.y, c0.x, c0
max r1.y, r1, c0.z
max r3.y, r1, c13.w
mul r3.x, r3, r1
mul r1.xyz, r1.z, c13
mad r1.xyz, r3.x, c14, r1
rcp r3.y, r3.y
mad r1.xyz, r1.w, c15, r1
max r2.xyz, r2, c10.y
mul r3.xyz, r3.y, c0
mul r2.xyz, r2, r3
max r1.xyz, r1, c10.y
mad oC0.xyz, r0, r1, r2
mad oC0.w, r2, c5.x, r0

"
}

}

		}

		// Linear
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
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_LinearMiddleGrey]
Float 9 [_LinearFactor]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[20] = { program.local[0..9],
		{ 0, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.5 },
		{ 0.63999999, 0, 2, 3 },
		{ 0.075300001, -0.2543, 1.1892, 0.0099999998 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 },
		{ 0.0241188, 0.1228178, 0.84442663 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
MADH  H0.y, H0, c[11].x, -c[11].x;
MULR  R0.x, H0.y, c[11].y;
FRCR  R0.y, R0.x;
ADDH  H0.x, H0, c[10].z;
MULH  H0.z, H0.x, c[10].w;
SGEH  H0.xy, c[10].x, R1.wyzw;
MADH  H0.y, H0, c[10], H0.z;
FLRR  R0.x, R0;
ADDR  R0.z, H0.y, R0.x;
MULR  R0.x, R0.y, c[12];
MULR  R0.y, R0.z, c[11].z;
ADDR  R0.z, -R0.y, -R0.x;
LG2H  H0.y, |R1.w|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.y, H0, c[10].z;
MULH  H0.y, H0, c[10].w;
MADR  R0.w, R1.x, R0.z, R1.x;
RCPR  R1.y, R0.x;
MULR  R2.x, R1, R0.y;
MULR  R0.xyz, R1.x, c[15];
MULR  R1.x, R1.y, R2;
MULR  R0.w, R0, R1.y;
MADR  R0.xyz, R1.x, c[14], R0;
MADR  R0.xyz, R0.w, c[13], R0;
MAXR  R3.xyz, R0, c[10].x;
MULR  R0.xyz, R3.y, c[18];
MADR  R2.xyz, R3.x, c[17], R0;
MADR  R2.xyz, R3.z, c[16], R2;
MOVR  R0.xyz, c[19];
DP3R  R0.y, R0, c[0];
RCPR  R0.z, R0.y;
ADDR  R1.x, R2, R2.y;
ADDR  R1.x, R2.z, R1;
MOVR  R0.x, c[1];
MULR  R0.x, R0, c[9];
MULR  R0.x, R0, c[8];
MULR  R0.x, R0, R0.z;
MOVR  R0.y, c[11].w;
MADR  R0.z, R0.y, -c[4].x, c[4].x;
MULR  R0.x, R2.y, R0;
MADR  R0.y, R0, -c[4].x, R0.x;
RCPR  R0.z, R0.z;
MULR_SAT R0.y, R0, R0.z;
MADR  R0.z, -R0.y, c[12], c[12].w;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R0.z;
POWR  R0.z, R0.x, c[2].x;
POWR  R0.x, R0.x, c[3].x;
ADDR  R0.w, R0.x, -R0.z;
MADR  R3.x, R0.y, R0.w, R0.z;
ADDR  R0.x, c[7].y, -c[7];
RCPR  R0.y, R0.x;
ADDR  R0.x, R3, -c[7];
MULR_SAT R0.x, R0, R0.y;
MADR  R0.y, -R0.x, c[12].z, c[12].w;
MULR  R0.x, R0, R0;
MULR  R1.y, R0.x, R0;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MAXR  R2.w, R0, R1.y;
ADDR  R2.w, R2, -R1.y;
MADR  R1.y, R2.w, c[6].x, R1;
ADDR  R2.w, -R0, R1.y;
RCPR  R1.x, R1.x;
MULR  R1.xy, R2, R1.x;
MULR  R3.z, R1.x, R3.x;
RCPR  R3.y, R1.y;
ADDR  R1.x, -R1, -R1.y;
MADR  R1.x, R1, R3, R3;
MULR  R1.x, R1, R3.y;
MULR  R3.z, R3.y, R3;
MULR  R2.xyz, R3.x, c[15];
MADR  R2.xyz, R3.z, c[14], R2;
MADR  R2.xyz, R1.x, c[13], R2;
MADH  H0.z, H0, c[11].x, -c[11].x;
MULR  R1.x, H0.z, c[11].y;
FRCR  R1.y, R1.x;
MULR  R1.y, R1, c[12].x;
MAXR  R2.xyz, R2, c[10].x;
FLRR  R1.x, R1;
MADH  H0.x, H0, c[10].y, H0.y;
ADDR  R1.x, H0, R1;
MULR  R3.x, R1, c[11].z;
ADDR  R1.x, -R3, -R1.y;
MADR  R1.x, R1, R1.z, R1.z;
RCPR  R1.y, R1.y;
MULR  R3.x, R3, R1.z;
MULR  R1.w, R1.x, R1.y;
MAXR  R1.x, c[0], c[0].y;
MULR  R3.y, R1, R3.x;
MAXR  R1.x, R1, c[0].z;
MAXR  R3.x, R1, c[13].w;
MULR  R1.xyz, R1.z, c[15];
MADR  R1.xyz, R3.y, c[14], R1;
RCPR  R3.x, R3.x;
MULR  R3.xyz, R3.x, c[0];
MADR  R1.xyz, R1.w, c[13], R1;
MULR  R2.xyz, R2, R3;
MAXR  R1.xyz, R1, c[10].x;
MADR  oCol.xyz, R0, R1, R2;
MADR  oCol.w, R2, c[5].x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Vector 0 [_ToneMappingLuminance]
Float 1 [_ToneMappingBoostFactor]
Float 2 [_GammaShadows]
Float 3 [_GammaHighlights]
Float 4 [_GammaBoundary]
Float 5 [_GlowSupport]
Float 6 [_GlowUseMax]
Vector 7 [_GlowIntensityThreshold]
Float 8 [_LinearMiddleGrey]
Float 9 [_LinearFactor]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c10, 1.00000000, 0.00000000, 15.00000000, 4.00000000
def c11, 128.00000000, -1.00000000, 1024.00000000, 0.00390625
def c12, 0.00476190, 0.63999999, 0.50000000, 0.01000000
def c13, -1.02170002, 1.97770000, 0.04390000, 0
def c14, 2.56509995, -1.16649997, -0.39860001, 0
def c15, 0.07530000, -0.25430000, 1.18920004, 0
def c16, 0.26506799, 0.67023426, 0.06409157, 0
def c17, 0.51413637, 0.32387859, 0.16036376, 0
def c18, 0.02411880, 0.12281780, 0.84442663, 0
def c19, 0.21259999, 0.71520001, 0.07220000, 0
def c20, 2.00000000, 3.00000000, 0, 0
dcl_texcoord0 v0.xyzw
texldl r1, v0, s1
abs_pp r0.x, r1.y
log_pp r0.y, r0.x
frc_pp r0.z, r0.y
add_pp r0.y, r0, -r0.z
exp_pp r0.z, -r0.y
mad_pp r0.x, r0, r0.z, c11.y
mul_pp r0.x, r0, c11.z
mul r0.z, r0.x, c11.w
frc r0.w, r0.z
add_pp r0.x, r0.y, c10.z
mul_pp r0.y, r0.x, c10.w
cmp_pp r0.x, -r1.y, c10, c10.y
mad_pp r0.x, r0, c11, r0.y
add r0.z, r0, -r0.w
add r0.x, r0, r0.z
mul r0.y, r0.w, c12
mul r0.x, r0, c12
add r0.z, -r0.x, -r0.y
mul r0.w, r1.x, r0.x
rcp r0.x, r0.y
add r0.z, r0, c10.x
mul r0.y, r0.x, r0.w
mul r0.z, r1.x, r0
mul r2.xyz, r1.x, c13
mad r2.xyz, r0.y, c14, r2
mul r0.x, r0.z, r0
mad r0.xyz, r0.x, c15, r2
max r2.xyz, r0, c10.y
mul r0.xyz, r2.y, c16
mad r3.xyz, r2.x, c17, r0
mov r0.xyz, c0
dp3 r0.y, c19, r0
mov r0.x, c9
mul r0.x, c1, r0
mad r2.xyz, r2.z, c18, r3
rcp r0.y, r0.y
mul r0.x, r0, c8
mul r0.x, r0, r0.y
mul r1.x, r2.y, r0
pow r3, r1.x, c3.x
abs_pp r3.y, r1.w
log_pp r4.x, r3.y
mov r0.z, c12
mad r0.y, r0.z, -c4.x, c4.x
mov r0.x, c4
frc_pp r3.w, r4.x
mad r0.x, c12.z, -r0, r1
rcp r0.y, r0.y
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c20.x, c20
mul r0.x, r0, r0
mul r1.y, r0.x, r0
pow r0, r1.x, c2.x
mov r0.y, r0.x
add r1.x, r2, r2.y
mov r0.x, r3
add r0.x, r0, -r0.y
mad r3.x, r1.y, r0, r0.y
add r0.z, c7.y, -c7.x
add r1.x, r2.z, r1
rcp r0.y, r0.z
add r0.x, r3, -c7
mul_sat r0.x, r0, r0.y
mad r0.y, -r0.x, c20.x, c20
mul r0.x, r0, r0
mul r1.y, r0.x, r0
texldl r0, v0, s0
max r2.w, r0, r1.y
add r2.z, r2.w, -r1.y
mad r2.z, r2, c6.x, r1.y
add r2.w, -r0, r2.z
rcp r1.x, r1.x
mul r1.xy, r2, r1.x
rcp r3.z, r1.y
mul r2.x, r1, r3
mul r4.y, r3.z, r2.x
mul r2.xyz, r3.x, c13
add r1.y, -r1.x, -r1
add_pp r3.w, r4.x, -r3
exp_pp r1.x, -r3.w
mad_pp r1.x, r3.y, r1, c11.y
add r1.y, r1, c10.x
mul r1.y, r1, r3.x
mul r3.x, r1.y, r3.z
mul_pp r1.x, r1, c11.z
mul r1.y, r1.x, c11.w
mad r2.xyz, r4.y, c14, r2
mad r2.xyz, r3.x, c15, r2
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r3.w, c10.z
mul_pp r1.y, r1.x, c10.w
cmp_pp r1.x, -r1.w, c10, c10.y
mad_pp r1.x, r1, c11, r1.y
mul r1.y, r3.x, c12
add r1.x, r1, r3.y
mul r1.x, r1, c12
add r1.w, -r1.x, -r1.y
rcp r3.x, r1.y
add r1.w, r1, c10.x
mul r1.y, r1.w, r1.z
mul r1.w, r1.y, r3.x
mul r1.x, r1, r1.z
max r1.y, c0.x, c0
max r1.y, r1, c0.z
max r3.y, r1, c12.w
mul r3.x, r3, r1
mul r1.xyz, r1.z, c13
mad r1.xyz, r3.x, c14, r1
rcp r3.y, r3.y
mad r1.xyz, r1.w, c15, r1
max r2.xyz, r2, c10.y
mul r3.xyz, r3.y, c0
mul r2.xyz, r2, r3
max r1.xyz, r1, c10.y
mad oC0.xyz, r0, r1, r2
mad oC0.w, r2, c5.x, r0

"
}

}

		}

		// Disabled
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
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Float 0 [_GlowSupport]
Float 1 [_GlowUseMax]
Vector 2 [_GlowIntensityThreshold]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[10] = { program.local[0..2],
		{ 0, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 2 },
		{ 0.63999999, 0, 3 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
MADH  H0.y, H0, c[4].x, -c[4].x;
MULR  R0.x, H0.y, c[4].y;
FRCR  R0.y, R0.x;
ADDH  H0.x, H0, c[3].z;
MULH  H0.z, H0.x, c[3].w;
SGEH  H0.xy, c[3].x, R1.wyzw;
MADH  H0.y, H0, c[3], H0.z;
FLRR  R0.x, R0;
ADDR  R0.z, H0.y, R0.x;
MULR  R0.x, R0.y, c[5];
MULR  R0.y, R0.z, c[4].z;
ADDR  R0.z, -R0.y, -R0.x;
LG2H  H0.y, |R1.w|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.y, H0, c[3].z;
MULH  H0.y, H0, c[3].w;
MADR  R1.y, R1.x, R0.z, R1.x;
MULR  R2.x, R1, R0.y;
RCPR  R0.w, R0.x;
MULR  R0.xyz, R1.x, c[7];
MULR  R1.x, R2, R0.w;
MULR  R0.w, R1.y, R0;
MADR  R0.xyz, R1.x, c[6], R0;
MADR  R0.xyz, R0.w, c[8], R0;
MAXR  R2.xyz, R0, c[3].x;
ADDR  R0.y, c[2], -c[2].x;
DP3R  R0.x, R2, c[9];
MADH  H0.z, H0, c[4].x, -c[4].x;
MULR  R1.y, H0.z, c[4];
FRCR  R1.x, R1.y;
MULR  R1.x, R1, c[5];
ADDR  R0.x, R0, -c[2];
RCPR  R0.y, R0.y;
MULR_SAT R0.y, R0.x, R0;
MOVR  R0.x, c[5].z;
MULR  R0.z, R0.y, R0.y;
MADR  R0.x, -R0.y, c[4].w, R0;
MULR  R1.w, R0.z, R0.x;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MAXR  R2.w, R0, R1;
ADDR  R2.w, R2, -R1;
MADR  R1.w, R2, c[1].x, R1;
ADDR  R1.w, -R0, R1;
FLRR  R1.y, R1;
MADH  H0.x, H0, c[3].y, H0.y;
ADDR  R1.y, H0.x, R1;
MULR  R1.y, R1, c[4].z;
ADDR  R3.x, -R1.y, -R1;
MADR  R3.y, R3.x, R1.z, R1.z;
RCPR  R3.x, R1.x;
MULR  R3.z, R1.y, R1;
MULR  R3.z, R3, R3.x;
MULR  R1.xyz, R1.z, c[7];
MADR  R1.xyz, R3.z, c[6], R1;
MULR  R3.x, R3.y, R3;
MADR  R1.xyz, R3.x, c[8], R1;
MAXR  R1.xyz, R1, c[3].x;
MADR  oCol.xyz, R0, R1, R2;
MADR  oCol.w, R1, c[0].x, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_TexScattering] 2D
Float 0 [_GlowSupport]
Float 1 [_GlowUseMax]
Vector 2 [_GlowIntensityThreshold]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c3, 1.00000000, 0.00000000, 15.00000000, 4.00000000
def c4, -1.00000000, 1024.00000000, 0.00390625, 128.00000000
def c5, 0.00476190, 0.63999999, 2.00000000, 3.00000000
def c6, -1.02170002, 1.97770000, 0.04390000, 0
def c7, 2.56509995, -1.16649997, -0.39860001, 0
def c8, 0.07530000, -0.25430000, 1.18920004, 0
def c9, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
texldl r3, v0, s1
abs_pp r0.x, r3.y
log_pp r0.y, r0.x
frc_pp r0.z, r0.y
add_pp r0.y, r0, -r0.z
exp_pp r0.z, -r0.y
mad_pp r0.x, r0, r0.z, c4
mul_pp r0.x, r0, c4.y
mul r0.z, r0.x, c4
frc r0.w, r0.z
add_pp r0.x, r0.y, c3.z
mul_pp r0.y, r0.x, c3.w
cmp_pp r0.x, -r3.y, c3, c3.y
mad_pp r0.x, r0, c4.w, r0.y
add r0.z, r0, -r0.w
mul r0.y, r0.w, c5
add r0.x, r0, r0.z
mul r0.x, r0, c5
add r0.z, -r0.x, -r0.y
add r0.z, r0, c3.x
mul r0.w, r3.x, r0.z
rcp r1.x, r0.y
mul r1.y, r3.x, r0.x
mul r0.xyz, r3.x, c6
mul r1.y, r1, r1.x
mad r2.xyz, r1.y, c7, r0
mul r0.x, r0.w, r1
mad r0.xyz, r0.x, c8, r2
max r2.xyz, r0, c3.y
abs_pp r0.y, r3.w
dp3 r0.z, r2, c9
add r1.x, c2.y, -c2
log_pp r0.x, r0.y
add r0.w, r0.z, -c2.x
frc_pp r0.z, r0.x
add_pp r0.x, r0, -r0.z
exp_pp r0.z, -r0.x
mad_pp r0.y, r0, r0.z, c4.x
rcp r1.x, r1.x
mul_sat r0.w, r0, r1.x
mul r0.z, r0.w, r0.w
mad r0.w, -r0, c5.z, c5
mul_pp r0.y, r0, c4
mul r1.w, r0.z, r0
mul r0.y, r0, c4.z
frc r0.z, r0.y
mul r1.x, r0.z, c5.y
add r0.w, r0.y, -r0.z
add_pp r0.x, r0, c3.z
mul_pp r0.y, r0.x, c3.w
cmp_pp r0.x, -r3.w, c3, c3.y
mad_pp r0.x, r0, c4.w, r0.y
add r0.x, r0, r0.w
mul r1.y, r0.x, c5.x
texldl r0, v0, s0
add r1.z, -r1.y, -r1.x
max r2.w, r0, r1
add r1.z, r1, c3.x
add r2.w, r2, -r1
mad r1.w, r2, c1.x, r1
add r1.w, -r0, r1
mul r3.x, r1.z, r3.z
rcp r3.y, r1.x
mul r3.w, r1.y, r3.z
mul r1.xyz, r3.z, c6
mul r3.z, r3.w, r3.y
mad r1.xyz, r3.z, c7, r1
mul r3.x, r3, r3.y
mad r1.xyz, r3.x, c8, r1
max r1.xyz, r1, c3.y
mad oC0.xyz, r0, r1, r2
mad oC0.w, r1, c0.x, r0

"
}

}

		}
	}
	Fallback off
}
