// This shader renders layers of flat, high-altitude clouds
//
Shader "Hidden/Nuaj/Layer"
{
	Properties
	{
		_TexPhaseMie( "Base (RGB)", 2D ) = "black" {}
		_TexNoise0( "Base (RGB)", 2D ) = "white" {}
		_TexNoise1( "Base (RGB)", 2D ) = "white" {}
		_TexNoise2( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3( "Base (RGB)", 2D ) = "white" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSky( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSun( "Base (RGB)", 2D ) = "white" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
	}

	SubShader
	{
		Tags { "Queue" = "Overlay-1" }
		ZTest Off		// http://unity3d.com/support/documentation/Components/SL-CullAndDepth.html
		Cull Off
		ZWrite Off
		Fog { Mode off }	// http://unity3d.com/support/documentation/Components/SL-Fog.html
		AlphaTest Off		// http://unity3d.com/support/documentation/Components/SL-AlphaTest.html
		Blend Off			// http://unity3d.com/support/documentation/Components/SL-Blend.html
		ColorMask RGBA		// Write ALL


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 Computes cloud shadowing for layer 0
		Pass
		{
			ColorMask R	// Only write RED

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
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[31] = { program.local[0..27],
		{ 0, 1, 2, 0.5 },
		{ 3, 4, 0.0099999998, 1000 },
		{ 2.718282 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.zw, c[28].xyxy;
MOVR  R0.xy, fragment.texcoord[0];
DP4R  R1.z, R0, c[2];
DP4R  R1.x, R0, c[0];
DP4R  R1.y, R0, c[1];
ADDR  R0.xyz, R1, -c[8];
DP3R  R0.w, R0, c[13];
DP3R  R0.x, R0, R0;
MOVR  R2.y, c[16].x;
ADDR  R0.y, R2, c[11].x;
MADR  R0.y, -R0, R0, R0.x;
MULR  R2.x, R0.w, R0.w;
SGER  H0.z, R2.x, R0.y;
ADDR  R0.z, R2.x, -R0.y;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R0.x, c[28];
SLTRC HC.x, R2, R0.y;
MOVR  R0.x(EQ), R1.w;
SLTR  H0.x, -R0.w, -R0.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[28].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R0.x(NE), c[28];
SLTR  H0.z, -R0.w, R0;
MULXC HC.x, H0.y, H0.z;
ADDR  R0.x(NE), -R0.w, R0.z;
MOVX  H0.x(NE), c[28];
MULXC HC.x, H0.y, H0;
ADDR  R0.x(NE), -R0.w, -R0.z;
MOVR  R3.xyw, c[28].xyzz;
SEQR  H0.xyz, c[18].x, R3.xyww;
SEQX  H1.xyz, H0, c[28].x;
MADR  R1.xyz, R0.x, c[13], R1;
MULR  R0.xyz, R1, c[12].x;
MOVR  R0.w, c[28].y;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[28].w, c[28].w;
MOVR  R2, c[14];
TEX   R0, R0, texture[0], 2D;
MADR  R0, R0, c[15], R2;
MOVR  R1.w, R0.x;
MULXC HC.x, H1, H0.y;
MOVR  R1.w(NE.x), R0.y;
MULX  H0.x, H1, H1.y;
MULXC HC.x, H0, H0.z;
MOVR  R1.w(NE.x), R0.z;
ADDR  R0.xyz, R1, -c[8];
MULXC HC.x, H0, H1.z;
MOVR  R1.w(NE.x), R0;
DP3R  R2.x, R0, c[9];
DP3R  R2.y, R0, c[10];
MOVR  R0.xy, c[22];
MADR  R3.xy, R2, c[20].x, R0;
TEX   R0, R3, texture[1], 2D;
MOVR  R4.x, R0.w;
SLTRC HC.x, c[21], R3.w;
MOVR  R4.x(EQ), R3.z;
SGER  H0.x, c[21], R3.w;
MOVXC RC.x, H0;
MOVR  R2.w, R0;
MADR  R2.xyz, R0, c[28].z, -c[28].y;
MOVR  R3.z, R4.x;
IF    NE.x;
MOVR  R0.x, c[29];
SLTRC HC.x, c[21], R0;
MOVX  H0.y, c[28].x;
MOVX  H0.y(EQ.x), H0.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[2], 2D;
MADR  R2.w, R0, c[24].x, R2;
MULR  R3.z(NE.x), R2.w, c[24].y;
MOVXC RC.x, H0.y;
MOVR  R0.w, c[24].x;
MULR  R0.xyz, R0, c[24].x;
MADR  R0.xyz, R0, c[28].z, -R0.w;
MOVX  H0.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[3], 2D;
MULR  R3.w, c[24].x, c[24].x;
MADR  R2.w, R3, R0, R2;
MOVR  R0.w, c[29].y;
SLTRC HC.x, c[21], R0.w;
MOVX  H0.y, c[28].x;
MULR  R0.xyz, R3.w, R0;
MADR  R0.xyz, R0, c[28].z, -R3.w;
MULR  R3.z(NE.x), R2.w, c[24];
MOVX  H0.y(EQ.x), H0.x;
MOVXC RC.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R0.xy, R3, c[23], R0;
MULR  R3.x, R3.w, c[24];
TEX   R0, R0, texture[4], 2D;
MULR  R0.xyz, R0, R3.x;
MADR  R0.xyz, R0, c[28].z, -R3.x;
MADR  R0.w, R0, R3.x, R2;
ADDR  R2.xyz, R2, R0;
MULR  R3.z, R0.w, c[24].w;
ENDIF;
ENDIF;
ENDIF;
MOVR  R0.z, c[28].y;
MOVR  R0.xy, c[26].x;
MULR  R0.xyz, R0, R2;
DP3R  R0.w, R0, R0;
MOVR  R2.x, c[16];
ADDR  R2.x, R2, c[11];
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R2.x, R2.x;
ADDR  R1.xyz, R1, -c[8];
MULR  R1.xyz, R1, R2.x;
MULR  R1.xyz, R0.z, R1;
MADR  R1.xyz, -R0.x, c[9], R1;
ADDR  R0.x, R3.z, c[19];
MADR  R1.xyz, R0.y, c[10], R1;
ADDR  R0.x, R0, -c[28].w;
DP3R  R0.y, R1, c[13];
MULR_SAT R0.x, R1.w, R0;
MAXR  R0.y, R0, c[29].z;
MULR  R0.x, R0, R0;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, c[17];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[27];
MULR  R0.x, R0, c[29].w;
POWR  oCol, c[30].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c28, 0.00000000, 1.00000000, -1.00000000, -2.00000000
def c29, 0.50000000, 2.00000000, -1.00000000, -3.00000000
def c30, -4.00000000, -0.50000000, 0.01000000, 1000.00000000
def c31, 2.71828198, 0, 0, 0
dcl_texcoord0 v0.xy
mov r3.x, c21
add r4.y, c28.w, r3.x
mov r1.zw, c28.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r2.x, r1, r1
mov r1.w, c11.x
add r1.w, c16.x, r1
dp3 r1.x, r1, c13
mad r1.w, -r1, r1, r2.x
mad r1.y, r1.x, r1.x, -r1.w
rsq r1.z, r1.y
rcp r1.w, r1.z
add r2.x, -r1, r1.w
cmp_pp r1.z, r1.y, c28.y, c28.x
cmp r2.y, r2.x, c28.x, c28
mul_pp r2.y, r1.z, r2
cmp_pp r2.z, -r2.y, r1, c28.x
add r1.w, -r1.x, -r1
mul_pp r1.x, r1.z, r2.z
cmp r1.y, r1, r0.w, c28.x
cmp r1.z, r1.w, c28.x, c28.y
mul_pp r0.w, r1.x, r1.z
cmp r1.z, -r2.y, r1.y, c28.x
cmp r1.z, -r0.w, r1, r2.x
cmp_pp r1.y, -r0.w, r2.z, c28.x
mul_pp r0.w, r1.x, r1.y
cmp r0.w, -r0, r1.z, r1
mad r1.xyz, r0.w, c13, r0
mul r0.xyz, r1, c12.x
mov r0.w, c28.y
dp4 r2.x, r0, c4
dp4 r2.y, r0, c6
add r0.xy, r2, c28.y
mov r1.w, c18.x
add r2.y, c28.z, r1.w
abs r2.x, c18
cmp r1.w, -r2.x, c28.y, c28.x
abs r2.x, r2.y
cmp r2.y, -r2.x, c28, c28.x
abs_pp r1.w, r1
cmp_pp r2.x, -r1.w, c28.y, c28
mul_pp r2.z, r2.x, r2.y
mov r1.w, c18.x
mov r0.z, c28.x
mul r0.xy, r0, c29.x
texldl r0, r0.xyzz, s0
mul r0, r0, c15
add r0, r0, c14
cmp r2.z, -r2, r0.x, r0.y
add r0.y, c28.w, r1.w
abs_pp r0.x, r2.y
cmp_pp r0.x, -r0, c28.y, c28
abs r0.y, r0
mul_pp r1.w, r2.x, r0.x
cmp r0.y, -r0, c28, c28.x
mul_pp r2.x, r1.w, r0.y
cmp r2.y, -r2.x, r2.z, r0.z
abs_pp r0.x, r0.y
cmp_pp r2.x, -r0, c28.y, c28
mul_pp r1.w, r1, r2.x
add r0.xyz, r1, -c8
cmp r1.w, -r1, r2.y, r0
dp3 r0.w, r0, c10
dp3 r0.z, r0, c9
mul r0.xy, r0.zwzw, c20.x
mov r2.z, c25.x
add r2.xy, r0, c22
texldl r0, r2.xyzz, s1
mad r3.xyz, r0, c29.y, c29.z
cmp_pp r4.x, r4.y, c28.y, c28
mov r2.w, r0
cmp r3.w, r4.y, r3, r0
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s2
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r0, c24.x, r3
mov r0.x, c21
add r0.x, c29.w, r0
mad r2.w, r0, c24.x, r2
mul r0.y, r2.w, c24
cmp_pp r4.x, r0, r4, c28
cmp r3.w, r0.x, r3, r0.y
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s3
mul r4.y, c24.x, c24.x
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r4.y, r0, r3
mov r0.x, c21
add r0.x, c30, r0
mad r2.w, r4.y, r0, r2
mul r0.y, r2.w, c24.z
cmp_pp r0.z, r0.x, r4.x, c28.x
cmp r3.w, r0.x, r3, r0.y
if_gt r0.z, c28.x
mul r0.xy, r2, c23
mul r2.x, r4.y, c24
mov r0.z, r2
add r0.xy, r0, c22.zwzw
texldl r0, r0.xyzz, s4
mad r0.xyz, r0, c29.y, c29.z
mad r0.w, r2.x, r0, r2
mad r3.xyz, r2.x, r0, r3
mul r3.w, r0, c24
endif
endif
endif
mov r2.x, c11
add r2.x, c16, r2
mov r0.z, c28.y
mov r0.xy, c26.x
mul r0.xyz, r0, r3
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
rcp r2.x, r2.x
add r1.xyz, r1, -c8
mul r1.xyz, r1, r2.x
mul r1.xyz, r0.z, r1
mad r1.xyz, -r0.x, c9, r1
mad r1.xyz, r0.y, c10, r1
dp3 r0.y, r1, c13
add r0.x, r3.w, c19
add r0.x, r0, c30.y
mul_sat r0.x, r1.w, r0
max r0.y, r0, c30.z
mul r0.x, r0, r0
rcp r0.y, r0.y
mul r0.x, r0, c17
mul r0.x, r0, r0.y
mul r0.x, r0, -c27
mul r1.x, r0, c30.w
pow r0, c31.x, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 Computes cloud shadowing for layer 1
		Pass
		{
			ColorMask G	// Only write GREEN

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
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[31] = { program.local[0..27],
		{ 0, 1, 2, 0.5 },
		{ 3, 4, 0.0099999998, 1000 },
		{ 2.718282 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.zw, c[28].xyxy;
MOVR  R0.xy, fragment.texcoord[0];
DP4R  R1.z, R0, c[2];
DP4R  R1.x, R0, c[0];
DP4R  R1.y, R0, c[1];
ADDR  R0.xyz, R1, -c[8];
DP3R  R0.w, R0, c[13];
DP3R  R0.x, R0, R0;
MOVR  R2.y, c[16].x;
ADDR  R0.y, R2, c[11].x;
MADR  R0.y, -R0, R0, R0.x;
MULR  R2.x, R0.w, R0.w;
SGER  H0.z, R2.x, R0.y;
ADDR  R0.z, R2.x, -R0.y;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R0.x, c[28];
SLTRC HC.x, R2, R0.y;
MOVR  R0.x(EQ), R1.w;
SLTR  H0.x, -R0.w, -R0.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[28].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R0.x(NE), c[28];
SLTR  H0.z, -R0.w, R0;
MULXC HC.x, H0.y, H0.z;
ADDR  R0.x(NE), -R0.w, R0.z;
MOVX  H0.x(NE), c[28];
MULXC HC.x, H0.y, H0;
ADDR  R0.x(NE), -R0.w, -R0.z;
MOVR  R3.xyw, c[28].xyzz;
SEQR  H0.xyz, c[18].x, R3.xyww;
SEQX  H1.xyz, H0, c[28].x;
MADR  R1.xyz, R0.x, c[13], R1;
MULR  R0.xyz, R1, c[12].x;
MOVR  R0.w, c[28].y;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[28].w, c[28].w;
MOVR  R2, c[14];
TEX   R0, R0, texture[0], 2D;
MADR  R0, R0, c[15], R2;
MOVR  R1.w, R0.x;
MULXC HC.x, H1, H0.y;
MOVR  R1.w(NE.x), R0.y;
MULX  H0.x, H1, H1.y;
MULXC HC.x, H0, H0.z;
MOVR  R1.w(NE.x), R0.z;
ADDR  R0.xyz, R1, -c[8];
MULXC HC.x, H0, H1.z;
MOVR  R1.w(NE.x), R0;
DP3R  R2.x, R0, c[9];
DP3R  R2.y, R0, c[10];
MOVR  R0.xy, c[22];
MADR  R3.xy, R2, c[20].x, R0;
TEX   R0, R3, texture[1], 2D;
MOVR  R4.x, R0.w;
SLTRC HC.x, c[21], R3.w;
MOVR  R4.x(EQ), R3.z;
SGER  H0.x, c[21], R3.w;
MOVXC RC.x, H0;
MOVR  R2.w, R0;
MADR  R2.xyz, R0, c[28].z, -c[28].y;
MOVR  R3.z, R4.x;
IF    NE.x;
MOVR  R0.x, c[29];
SLTRC HC.x, c[21], R0;
MOVX  H0.y, c[28].x;
MOVX  H0.y(EQ.x), H0.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[2], 2D;
MADR  R2.w, R0, c[24].x, R2;
MULR  R3.z(NE.x), R2.w, c[24].y;
MOVXC RC.x, H0.y;
MOVR  R0.w, c[24].x;
MULR  R0.xyz, R0, c[24].x;
MADR  R0.xyz, R0, c[28].z, -R0.w;
MOVX  H0.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[3], 2D;
MULR  R3.w, c[24].x, c[24].x;
MADR  R2.w, R3, R0, R2;
MOVR  R0.w, c[29].y;
SLTRC HC.x, c[21], R0.w;
MOVX  H0.y, c[28].x;
MULR  R0.xyz, R3.w, R0;
MADR  R0.xyz, R0, c[28].z, -R3.w;
MULR  R3.z(NE.x), R2.w, c[24];
MOVX  H0.y(EQ.x), H0.x;
MOVXC RC.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R0.xy, R3, c[23], R0;
MULR  R3.x, R3.w, c[24];
TEX   R0, R0, texture[4], 2D;
MULR  R0.xyz, R0, R3.x;
MADR  R0.xyz, R0, c[28].z, -R3.x;
MADR  R0.w, R0, R3.x, R2;
ADDR  R2.xyz, R2, R0;
MULR  R3.z, R0.w, c[24].w;
ENDIF;
ENDIF;
ENDIF;
MOVR  R0.z, c[28].y;
MOVR  R0.xy, c[26].x;
MULR  R0.xyz, R0, R2;
DP3R  R0.w, R0, R0;
MOVR  R2.x, c[16];
ADDR  R2.x, R2, c[11];
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R2.x, R2.x;
ADDR  R1.xyz, R1, -c[8];
MULR  R1.xyz, R1, R2.x;
MULR  R1.xyz, R0.z, R1;
MADR  R1.xyz, -R0.x, c[9], R1;
ADDR  R0.x, R3.z, c[19];
MADR  R1.xyz, R0.y, c[10], R1;
ADDR  R0.x, R0, -c[28].w;
DP3R  R0.y, R1, c[13];
MULR_SAT R0.x, R1.w, R0;
MAXR  R0.y, R0, c[29].z;
MULR  R0.x, R0, R0;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, c[17];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[27];
MULR  R0.x, R0, c[29].w;
POWR  oCol, c[30].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c28, 0.00000000, 1.00000000, -1.00000000, -2.00000000
def c29, 0.50000000, 2.00000000, -1.00000000, -3.00000000
def c30, -4.00000000, -0.50000000, 0.01000000, 1000.00000000
def c31, 2.71828198, 0, 0, 0
dcl_texcoord0 v0.xy
mov r3.x, c21
add r4.y, c28.w, r3.x
mov r1.zw, c28.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r2.x, r1, r1
mov r1.w, c11.x
add r1.w, c16.x, r1
dp3 r1.x, r1, c13
mad r1.w, -r1, r1, r2.x
mad r1.y, r1.x, r1.x, -r1.w
rsq r1.z, r1.y
rcp r1.w, r1.z
add r2.x, -r1, r1.w
cmp_pp r1.z, r1.y, c28.y, c28.x
cmp r2.y, r2.x, c28.x, c28
mul_pp r2.y, r1.z, r2
cmp_pp r2.z, -r2.y, r1, c28.x
add r1.w, -r1.x, -r1
mul_pp r1.x, r1.z, r2.z
cmp r1.y, r1, r0.w, c28.x
cmp r1.z, r1.w, c28.x, c28.y
mul_pp r0.w, r1.x, r1.z
cmp r1.z, -r2.y, r1.y, c28.x
cmp r1.z, -r0.w, r1, r2.x
cmp_pp r1.y, -r0.w, r2.z, c28.x
mul_pp r0.w, r1.x, r1.y
cmp r0.w, -r0, r1.z, r1
mad r1.xyz, r0.w, c13, r0
mul r0.xyz, r1, c12.x
mov r0.w, c28.y
dp4 r2.x, r0, c4
dp4 r2.y, r0, c6
add r0.xy, r2, c28.y
mov r1.w, c18.x
add r2.y, c28.z, r1.w
abs r2.x, c18
cmp r1.w, -r2.x, c28.y, c28.x
abs r2.x, r2.y
cmp r2.y, -r2.x, c28, c28.x
abs_pp r1.w, r1
cmp_pp r2.x, -r1.w, c28.y, c28
mul_pp r2.z, r2.x, r2.y
mov r1.w, c18.x
mov r0.z, c28.x
mul r0.xy, r0, c29.x
texldl r0, r0.xyzz, s0
mul r0, r0, c15
add r0, r0, c14
cmp r2.z, -r2, r0.x, r0.y
add r0.y, c28.w, r1.w
abs_pp r0.x, r2.y
cmp_pp r0.x, -r0, c28.y, c28
abs r0.y, r0
mul_pp r1.w, r2.x, r0.x
cmp r0.y, -r0, c28, c28.x
mul_pp r2.x, r1.w, r0.y
cmp r2.y, -r2.x, r2.z, r0.z
abs_pp r0.x, r0.y
cmp_pp r2.x, -r0, c28.y, c28
mul_pp r1.w, r1, r2.x
add r0.xyz, r1, -c8
cmp r1.w, -r1, r2.y, r0
dp3 r0.w, r0, c10
dp3 r0.z, r0, c9
mul r0.xy, r0.zwzw, c20.x
mov r2.z, c25.x
add r2.xy, r0, c22
texldl r0, r2.xyzz, s1
mad r3.xyz, r0, c29.y, c29.z
cmp_pp r4.x, r4.y, c28.y, c28
mov r2.w, r0
cmp r3.w, r4.y, r3, r0
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s2
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r0, c24.x, r3
mov r0.x, c21
add r0.x, c29.w, r0
mad r2.w, r0, c24.x, r2
mul r0.y, r2.w, c24
cmp_pp r4.x, r0, r4, c28
cmp r3.w, r0.x, r3, r0.y
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s3
mul r4.y, c24.x, c24.x
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r4.y, r0, r3
mov r0.x, c21
add r0.x, c30, r0
mad r2.w, r4.y, r0, r2
mul r0.y, r2.w, c24.z
cmp_pp r0.z, r0.x, r4.x, c28.x
cmp r3.w, r0.x, r3, r0.y
if_gt r0.z, c28.x
mul r0.xy, r2, c23
mul r2.x, r4.y, c24
mov r0.z, r2
add r0.xy, r0, c22.zwzw
texldl r0, r0.xyzz, s4
mad r0.xyz, r0, c29.y, c29.z
mad r0.w, r2.x, r0, r2
mad r3.xyz, r2.x, r0, r3
mul r3.w, r0, c24
endif
endif
endif
mov r2.x, c11
add r2.x, c16, r2
mov r0.z, c28.y
mov r0.xy, c26.x
mul r0.xyz, r0, r3
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
rcp r2.x, r2.x
add r1.xyz, r1, -c8
mul r1.xyz, r1, r2.x
mul r1.xyz, r0.z, r1
mad r1.xyz, -r0.x, c9, r1
mad r1.xyz, r0.y, c10, r1
dp3 r0.y, r1, c13
add r0.x, r3.w, c19
add r0.x, r0, c30.y
mul_sat r0.x, r1.w, r0
max r0.y, r0, c30.z
mul r0.x, r0, r0
rcp r0.y, r0.y
mul r0.x, r0, c17
mul r0.x, r0, r0.y
mul r0.x, r0, -c27
mul r1.x, r0, c30.w
pow r0, c31.x, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 Computes cloud shadowing for layer 2
		Pass
		{
			ColorMask B	// Only write BLUE

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
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[31] = { program.local[0..27],
		{ 0, 1, 2, 0.5 },
		{ 3, 4, 0.0099999998, 1000 },
		{ 2.718282 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.zw, c[28].xyxy;
MOVR  R0.xy, fragment.texcoord[0];
DP4R  R1.z, R0, c[2];
DP4R  R1.x, R0, c[0];
DP4R  R1.y, R0, c[1];
ADDR  R0.xyz, R1, -c[8];
DP3R  R0.w, R0, c[13];
DP3R  R0.x, R0, R0;
MOVR  R2.y, c[16].x;
ADDR  R0.y, R2, c[11].x;
MADR  R0.y, -R0, R0, R0.x;
MULR  R2.x, R0.w, R0.w;
SGER  H0.z, R2.x, R0.y;
ADDR  R0.z, R2.x, -R0.y;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R0.x, c[28];
SLTRC HC.x, R2, R0.y;
MOVR  R0.x(EQ), R1.w;
SLTR  H0.x, -R0.w, -R0.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[28].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R0.x(NE), c[28];
SLTR  H0.z, -R0.w, R0;
MULXC HC.x, H0.y, H0.z;
ADDR  R0.x(NE), -R0.w, R0.z;
MOVX  H0.x(NE), c[28];
MULXC HC.x, H0.y, H0;
ADDR  R0.x(NE), -R0.w, -R0.z;
MOVR  R3.xyw, c[28].xyzz;
SEQR  H0.xyz, c[18].x, R3.xyww;
SEQX  H1.xyz, H0, c[28].x;
MADR  R1.xyz, R0.x, c[13], R1;
MULR  R0.xyz, R1, c[12].x;
MOVR  R0.w, c[28].y;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[28].w, c[28].w;
MOVR  R2, c[14];
TEX   R0, R0, texture[0], 2D;
MADR  R0, R0, c[15], R2;
MOVR  R1.w, R0.x;
MULXC HC.x, H1, H0.y;
MOVR  R1.w(NE.x), R0.y;
MULX  H0.x, H1, H1.y;
MULXC HC.x, H0, H0.z;
MOVR  R1.w(NE.x), R0.z;
ADDR  R0.xyz, R1, -c[8];
MULXC HC.x, H0, H1.z;
MOVR  R1.w(NE.x), R0;
DP3R  R2.x, R0, c[9];
DP3R  R2.y, R0, c[10];
MOVR  R0.xy, c[22];
MADR  R3.xy, R2, c[20].x, R0;
TEX   R0, R3, texture[1], 2D;
MOVR  R4.x, R0.w;
SLTRC HC.x, c[21], R3.w;
MOVR  R4.x(EQ), R3.z;
SGER  H0.x, c[21], R3.w;
MOVXC RC.x, H0;
MOVR  R2.w, R0;
MADR  R2.xyz, R0, c[28].z, -c[28].y;
MOVR  R3.z, R4.x;
IF    NE.x;
MOVR  R0.x, c[29];
SLTRC HC.x, c[21], R0;
MOVX  H0.y, c[28].x;
MOVX  H0.y(EQ.x), H0.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[2], 2D;
MADR  R2.w, R0, c[24].x, R2;
MULR  R3.z(NE.x), R2.w, c[24].y;
MOVXC RC.x, H0.y;
MOVR  R0.w, c[24].x;
MULR  R0.xyz, R0, c[24].x;
MADR  R0.xyz, R0, c[28].z, -R0.w;
MOVX  H0.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[3], 2D;
MULR  R3.w, c[24].x, c[24].x;
MADR  R2.w, R3, R0, R2;
MOVR  R0.w, c[29].y;
SLTRC HC.x, c[21], R0.w;
MOVX  H0.y, c[28].x;
MULR  R0.xyz, R3.w, R0;
MADR  R0.xyz, R0, c[28].z, -R3.w;
MULR  R3.z(NE.x), R2.w, c[24];
MOVX  H0.y(EQ.x), H0.x;
MOVXC RC.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R0.xy, R3, c[23], R0;
MULR  R3.x, R3.w, c[24];
TEX   R0, R0, texture[4], 2D;
MULR  R0.xyz, R0, R3.x;
MADR  R0.xyz, R0, c[28].z, -R3.x;
MADR  R0.w, R0, R3.x, R2;
ADDR  R2.xyz, R2, R0;
MULR  R3.z, R0.w, c[24].w;
ENDIF;
ENDIF;
ENDIF;
MOVR  R0.z, c[28].y;
MOVR  R0.xy, c[26].x;
MULR  R0.xyz, R0, R2;
DP3R  R0.w, R0, R0;
MOVR  R2.x, c[16];
ADDR  R2.x, R2, c[11];
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R2.x, R2.x;
ADDR  R1.xyz, R1, -c[8];
MULR  R1.xyz, R1, R2.x;
MULR  R1.xyz, R0.z, R1;
MADR  R1.xyz, -R0.x, c[9], R1;
ADDR  R0.x, R3.z, c[19];
MADR  R1.xyz, R0.y, c[10], R1;
ADDR  R0.x, R0, -c[28].w;
DP3R  R0.y, R1, c[13];
MULR_SAT R0.x, R1.w, R0;
MAXR  R0.y, R0, c[29].z;
MULR  R0.x, R0, R0;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, c[17];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[27];
MULR  R0.x, R0, c[29].w;
POWR  oCol, c[30].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c28, 0.00000000, 1.00000000, -1.00000000, -2.00000000
def c29, 0.50000000, 2.00000000, -1.00000000, -3.00000000
def c30, -4.00000000, -0.50000000, 0.01000000, 1000.00000000
def c31, 2.71828198, 0, 0, 0
dcl_texcoord0 v0.xy
mov r3.x, c21
add r4.y, c28.w, r3.x
mov r1.zw, c28.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r2.x, r1, r1
mov r1.w, c11.x
add r1.w, c16.x, r1
dp3 r1.x, r1, c13
mad r1.w, -r1, r1, r2.x
mad r1.y, r1.x, r1.x, -r1.w
rsq r1.z, r1.y
rcp r1.w, r1.z
add r2.x, -r1, r1.w
cmp_pp r1.z, r1.y, c28.y, c28.x
cmp r2.y, r2.x, c28.x, c28
mul_pp r2.y, r1.z, r2
cmp_pp r2.z, -r2.y, r1, c28.x
add r1.w, -r1.x, -r1
mul_pp r1.x, r1.z, r2.z
cmp r1.y, r1, r0.w, c28.x
cmp r1.z, r1.w, c28.x, c28.y
mul_pp r0.w, r1.x, r1.z
cmp r1.z, -r2.y, r1.y, c28.x
cmp r1.z, -r0.w, r1, r2.x
cmp_pp r1.y, -r0.w, r2.z, c28.x
mul_pp r0.w, r1.x, r1.y
cmp r0.w, -r0, r1.z, r1
mad r1.xyz, r0.w, c13, r0
mul r0.xyz, r1, c12.x
mov r0.w, c28.y
dp4 r2.x, r0, c4
dp4 r2.y, r0, c6
add r0.xy, r2, c28.y
mov r1.w, c18.x
add r2.y, c28.z, r1.w
abs r2.x, c18
cmp r1.w, -r2.x, c28.y, c28.x
abs r2.x, r2.y
cmp r2.y, -r2.x, c28, c28.x
abs_pp r1.w, r1
cmp_pp r2.x, -r1.w, c28.y, c28
mul_pp r2.z, r2.x, r2.y
mov r1.w, c18.x
mov r0.z, c28.x
mul r0.xy, r0, c29.x
texldl r0, r0.xyzz, s0
mul r0, r0, c15
add r0, r0, c14
cmp r2.z, -r2, r0.x, r0.y
add r0.y, c28.w, r1.w
abs_pp r0.x, r2.y
cmp_pp r0.x, -r0, c28.y, c28
abs r0.y, r0
mul_pp r1.w, r2.x, r0.x
cmp r0.y, -r0, c28, c28.x
mul_pp r2.x, r1.w, r0.y
cmp r2.y, -r2.x, r2.z, r0.z
abs_pp r0.x, r0.y
cmp_pp r2.x, -r0, c28.y, c28
mul_pp r1.w, r1, r2.x
add r0.xyz, r1, -c8
cmp r1.w, -r1, r2.y, r0
dp3 r0.w, r0, c10
dp3 r0.z, r0, c9
mul r0.xy, r0.zwzw, c20.x
mov r2.z, c25.x
add r2.xy, r0, c22
texldl r0, r2.xyzz, s1
mad r3.xyz, r0, c29.y, c29.z
cmp_pp r4.x, r4.y, c28.y, c28
mov r2.w, r0
cmp r3.w, r4.y, r3, r0
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s2
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r0, c24.x, r3
mov r0.x, c21
add r0.x, c29.w, r0
mad r2.w, r0, c24.x, r2
mul r0.y, r2.w, c24
cmp_pp r4.x, r0, r4, c28
cmp r3.w, r0.x, r3, r0.y
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s3
mul r4.y, c24.x, c24.x
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r4.y, r0, r3
mov r0.x, c21
add r0.x, c30, r0
mad r2.w, r4.y, r0, r2
mul r0.y, r2.w, c24.z
cmp_pp r0.z, r0.x, r4.x, c28.x
cmp r3.w, r0.x, r3, r0.y
if_gt r0.z, c28.x
mul r0.xy, r2, c23
mul r2.x, r4.y, c24
mov r0.z, r2
add r0.xy, r0, c22.zwzw
texldl r0, r0.xyzz, s4
mad r0.xyz, r0, c29.y, c29.z
mad r0.w, r2.x, r0, r2
mad r3.xyz, r2.x, r0, r3
mul r3.w, r0, c24
endif
endif
endif
mov r2.x, c11
add r2.x, c16, r2
mov r0.z, c28.y
mov r0.xy, c26.x
mul r0.xyz, r0, r3
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
rcp r2.x, r2.x
add r1.xyz, r1, -c8
mul r1.xyz, r1, r2.x
mul r1.xyz, r0.z, r1
mad r1.xyz, -r0.x, c9, r1
mad r1.xyz, r0.y, c10, r1
dp3 r0.y, r1, c13
add r0.x, r3.w, c19
add r0.x, r0, c30.y
mul_sat r0.x, r1.w, r0
max r0.y, r0, c30.z
mul r0.x, r0, r0
rcp r0.y, r0.y
mul r0.x, r0, c17
mul r0.x, r0, r0.y
mul r0.x, r0, -c27
mul r1.x, r0, c30.w
pow r0, c31.x, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 Computes cloud shadowing for layer 3
		Pass
		{
			ColorMask A	// Only write ALPHA

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
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[31] = { program.local[0..27],
		{ 0, 1, 2, 0.5 },
		{ 3, 4, 0.0099999998, 1000 },
		{ 2.718282 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.zw, c[28].xyxy;
MOVR  R0.xy, fragment.texcoord[0];
DP4R  R1.z, R0, c[2];
DP4R  R1.x, R0, c[0];
DP4R  R1.y, R0, c[1];
ADDR  R0.xyz, R1, -c[8];
DP3R  R0.w, R0, c[13];
DP3R  R0.x, R0, R0;
MOVR  R2.y, c[16].x;
ADDR  R0.y, R2, c[11].x;
MADR  R0.y, -R0, R0, R0.x;
MULR  R2.x, R0.w, R0.w;
SGER  H0.z, R2.x, R0.y;
ADDR  R0.z, R2.x, -R0.y;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R0.x, c[28];
SLTRC HC.x, R2, R0.y;
MOVR  R0.x(EQ), R1.w;
SLTR  H0.x, -R0.w, -R0.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[28].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R0.x(NE), c[28];
SLTR  H0.z, -R0.w, R0;
MULXC HC.x, H0.y, H0.z;
ADDR  R0.x(NE), -R0.w, R0.z;
MOVX  H0.x(NE), c[28];
MULXC HC.x, H0.y, H0;
ADDR  R0.x(NE), -R0.w, -R0.z;
MOVR  R3.xyw, c[28].xyzz;
SEQR  H0.xyz, c[18].x, R3.xyww;
SEQX  H1.xyz, H0, c[28].x;
MADR  R1.xyz, R0.x, c[13], R1;
MULR  R0.xyz, R1, c[12].x;
MOVR  R0.w, c[28].y;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[28].w, c[28].w;
MOVR  R2, c[14];
TEX   R0, R0, texture[0], 2D;
MADR  R0, R0, c[15], R2;
MOVR  R1.w, R0.x;
MULXC HC.x, H1, H0.y;
MOVR  R1.w(NE.x), R0.y;
MULX  H0.x, H1, H1.y;
MULXC HC.x, H0, H0.z;
MOVR  R1.w(NE.x), R0.z;
ADDR  R0.xyz, R1, -c[8];
MULXC HC.x, H0, H1.z;
MOVR  R1.w(NE.x), R0;
DP3R  R2.x, R0, c[9];
DP3R  R2.y, R0, c[10];
MOVR  R0.xy, c[22];
MADR  R3.xy, R2, c[20].x, R0;
TEX   R0, R3, texture[1], 2D;
MOVR  R4.x, R0.w;
SLTRC HC.x, c[21], R3.w;
MOVR  R4.x(EQ), R3.z;
SGER  H0.x, c[21], R3.w;
MOVXC RC.x, H0;
MOVR  R2.w, R0;
MADR  R2.xyz, R0, c[28].z, -c[28].y;
MOVR  R3.z, R4.x;
IF    NE.x;
MOVR  R0.x, c[29];
SLTRC HC.x, c[21], R0;
MOVX  H0.y, c[28].x;
MOVX  H0.y(EQ.x), H0.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[2], 2D;
MADR  R2.w, R0, c[24].x, R2;
MULR  R3.z(NE.x), R2.w, c[24].y;
MOVXC RC.x, H0.y;
MOVR  R0.w, c[24].x;
MULR  R0.xyz, R0, c[24].x;
MADR  R0.xyz, R0, c[28].z, -R0.w;
MOVX  H0.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R3.xy, R3, c[23], R0;
TEX   R0, R3, texture[3], 2D;
MULR  R3.w, c[24].x, c[24].x;
MADR  R2.w, R3, R0, R2;
MOVR  R0.w, c[29].y;
SLTRC HC.x, c[21], R0.w;
MOVX  H0.y, c[28].x;
MULR  R0.xyz, R3.w, R0;
MADR  R0.xyz, R0, c[28].z, -R3.w;
MULR  R3.z(NE.x), R2.w, c[24];
MOVX  H0.y(EQ.x), H0.x;
MOVXC RC.x, H0.y;
ADDR  R2.xyz, R2, R0;
IF    NE.x;
MOVR  R0.xy, c[22].zwzw;
MADR  R0.xy, R3, c[23], R0;
MULR  R3.x, R3.w, c[24];
TEX   R0, R0, texture[4], 2D;
MULR  R0.xyz, R0, R3.x;
MADR  R0.xyz, R0, c[28].z, -R3.x;
MADR  R0.w, R0, R3.x, R2;
ADDR  R2.xyz, R2, R0;
MULR  R3.z, R0.w, c[24].w;
ENDIF;
ENDIF;
ENDIF;
MOVR  R0.z, c[28].y;
MOVR  R0.xy, c[26].x;
MULR  R0.xyz, R0, R2;
DP3R  R0.w, R0, R0;
MOVR  R2.x, c[16];
ADDR  R2.x, R2, c[11];
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R2.x, R2.x;
ADDR  R1.xyz, R1, -c[8];
MULR  R1.xyz, R1, R2.x;
MULR  R1.xyz, R0.z, R1;
MADR  R1.xyz, -R0.x, c[9], R1;
ADDR  R0.x, R3.z, c[19];
MADR  R1.xyz, R0.y, c[10], R1;
ADDR  R0.x, R0, -c[28].w;
DP3R  R0.y, R1, c[13];
MULR_SAT R0.x, R1.w, R0;
MAXR  R0.y, R0, c[29].z;
MULR  R0.x, R0, R0;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, c[17];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[27];
MULR  R0.x, R0, c[29].w;
POWR  oCol, c[30].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetTangent]
Vector 10 [_PlanetBiTangent]
Float 11 [_PlanetRadiusKm]
Float 12 [_Kilometer2WorldUnit]
Vector 13 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Vector 14 [_NuajLocalCoverageOffset]
Vector 15 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Float 16 [_CloudAltitudeKm]
Vector 17 [_CloudThicknessKm]
Float 18 [_CloudLayerIndex]
Float 19 [_Coverage]
Float 20 [_NoiseTiling]
Float 21 [_NoiseOctavesCount]
Vector 22 [_CloudPosition]
Vector 23 [_FrequencyFactor]
Vector 24 [_AmplitudeFactor]
Float 25 [_Smoothness]
Float 26 [_NormalAmplitude]
SetTexture 1 [_TexNoise0] 2D
SetTexture 2 [_TexNoise1] 2D
SetTexture 3 [_TexNoise2] 2D
SetTexture 4 [_TexNoise3] 2D
Float 27 [_ScatteringCoeff]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c28, 0.00000000, 1.00000000, -1.00000000, -2.00000000
def c29, 0.50000000, 2.00000000, -1.00000000, -3.00000000
def c30, -4.00000000, -0.50000000, 0.01000000, 1000.00000000
def c31, 2.71828198, 0, 0, 0
dcl_texcoord0 v0.xy
mov r3.x, c21
add r4.y, c28.w, r3.x
mov r1.zw, c28.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r2.x, r1, r1
mov r1.w, c11.x
add r1.w, c16.x, r1
dp3 r1.x, r1, c13
mad r1.w, -r1, r1, r2.x
mad r1.y, r1.x, r1.x, -r1.w
rsq r1.z, r1.y
rcp r1.w, r1.z
add r2.x, -r1, r1.w
cmp_pp r1.z, r1.y, c28.y, c28.x
cmp r2.y, r2.x, c28.x, c28
mul_pp r2.y, r1.z, r2
cmp_pp r2.z, -r2.y, r1, c28.x
add r1.w, -r1.x, -r1
mul_pp r1.x, r1.z, r2.z
cmp r1.y, r1, r0.w, c28.x
cmp r1.z, r1.w, c28.x, c28.y
mul_pp r0.w, r1.x, r1.z
cmp r1.z, -r2.y, r1.y, c28.x
cmp r1.z, -r0.w, r1, r2.x
cmp_pp r1.y, -r0.w, r2.z, c28.x
mul_pp r0.w, r1.x, r1.y
cmp r0.w, -r0, r1.z, r1
mad r1.xyz, r0.w, c13, r0
mul r0.xyz, r1, c12.x
mov r0.w, c28.y
dp4 r2.x, r0, c4
dp4 r2.y, r0, c6
add r0.xy, r2, c28.y
mov r1.w, c18.x
add r2.y, c28.z, r1.w
abs r2.x, c18
cmp r1.w, -r2.x, c28.y, c28.x
abs r2.x, r2.y
cmp r2.y, -r2.x, c28, c28.x
abs_pp r1.w, r1
cmp_pp r2.x, -r1.w, c28.y, c28
mul_pp r2.z, r2.x, r2.y
mov r1.w, c18.x
mov r0.z, c28.x
mul r0.xy, r0, c29.x
texldl r0, r0.xyzz, s0
mul r0, r0, c15
add r0, r0, c14
cmp r2.z, -r2, r0.x, r0.y
add r0.y, c28.w, r1.w
abs_pp r0.x, r2.y
cmp_pp r0.x, -r0, c28.y, c28
abs r0.y, r0
mul_pp r1.w, r2.x, r0.x
cmp r0.y, -r0, c28, c28.x
mul_pp r2.x, r1.w, r0.y
cmp r2.y, -r2.x, r2.z, r0.z
abs_pp r0.x, r0.y
cmp_pp r2.x, -r0, c28.y, c28
mul_pp r1.w, r1, r2.x
add r0.xyz, r1, -c8
cmp r1.w, -r1, r2.y, r0
dp3 r0.w, r0, c10
dp3 r0.z, r0, c9
mul r0.xy, r0.zwzw, c20.x
mov r2.z, c25.x
add r2.xy, r0, c22
texldl r0, r2.xyzz, s1
mad r3.xyz, r0, c29.y, c29.z
cmp_pp r4.x, r4.y, c28.y, c28
mov r2.w, r0
cmp r3.w, r4.y, r3, r0
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s2
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r0, c24.x, r3
mov r0.x, c21
add r0.x, c29.w, r0
mad r2.w, r0, c24.x, r2
mul r0.y, r2.w, c24
cmp_pp r4.x, r0, r4, c28
cmp r3.w, r0.x, r3, r0.y
if_gt r4.x, c28.x
mul r0.xy, r2, c23
add r2.xy, r0, c22.zwzw
texldl r0, r2.xyzz, s3
mul r4.y, c24.x, c24.x
mad r0.xyz, r0, c29.y, c29.z
mad r3.xyz, r4.y, r0, r3
mov r0.x, c21
add r0.x, c30, r0
mad r2.w, r4.y, r0, r2
mul r0.y, r2.w, c24.z
cmp_pp r0.z, r0.x, r4.x, c28.x
cmp r3.w, r0.x, r3, r0.y
if_gt r0.z, c28.x
mul r0.xy, r2, c23
mul r2.x, r4.y, c24
mov r0.z, r2
add r0.xy, r0, c22.zwzw
texldl r0, r0.xyzz, s4
mad r0.xyz, r0, c29.y, c29.z
mad r0.w, r2.x, r0, r2
mad r3.xyz, r2.x, r0, r3
mul r3.w, r0, c24
endif
endif
endif
mov r2.x, c11
add r2.x, c16, r2
mov r0.z, c28.y
mov r0.xy, c26.x
mul r0.xyz, r0, r3
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
rcp r2.x, r2.x
add r1.xyz, r1, -c8
mul r1.xyz, r1, r2.x
mul r1.xyz, r0.z, r1
mad r1.xyz, -r0.x, c9, r1
mad r1.xyz, r0.y, c10, r1
dp3 r0.y, r1, c13
add r0.x, r3.w, c19
add r0.x, r0, c30.y
mul_sat r0.x, r1.w, r0
max r0.y, r0, c30.z
mul r0.x, r0, r0
rcp r0.y, r0.y
mul r0.x, r0, c17
mul r0.x, r0, r0.y
mul r0.x, r0, -c27
mul r1.x, r0, c30.w
pow r0, c31.x, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 computes the actual cloud lighting
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
MOV   result.texcoord[1].xyz, c[8].x;
MOV   result.texcoord[2].xyz, c[8].x;
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
Vector 8 [_PlanetNormal]
Float 9 [_PlanetRadiusKm]
Float 10 [_PlanetAtmosphereRadiusKm]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 1 [_TexAmbientSky] 2D
Vector 13 [_SoftAmbientSky]
SetTexture 0 [_TexShadowEnvMapSky] 2D
Vector 14 [_Sigma_Rayleigh]
Float 15 [_Sigma_Mie]
SetTexture 2 [_TexDensity] 2D
Float 16 [_CloudAltitudeKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c17, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
mov r0.y, c10.x
add r0.x, -r0, c17.z
add r0.y, -c9.x, r0
rcp r0.y, r0.y
mul r0.x, r0, c17.y
mul r0.y, r0, c16.x
mov r0.z, c17.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c17.w, r1.x
mov r1.x, r0
pow r0, c17.w, r1.z
mov r1.z, r0
pow r2, c17.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c17.yyzx, s1
mov r1.zw, c17.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c17.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c17.x
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
Vector 16 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 3 [_CameraDepthTexture] 2D
Vector 17 [_PlanetCenterKm]
Vector 18 [_PlanetNormal]
Vector 19 [_PlanetTangent]
Vector 20 [_PlanetBiTangent]
Float 21 [_PlanetRadiusKm]
Float 22 [_PlanetAtmosphereRadiusKm]
Float 23 [_WorldUnit2Kilometer]
Float 24 [_Kilometer2WorldUnit]
Float 25 [_bComputePlanetShadow]
Vector 26 [_SunColor]
Vector 27 [_SunColorFromGround]
Vector 28 [_SunDirection]
SetTexture 1 [_TexAmbientSky] 2D
Vector 29 [_SoftAmbientSky]
Vector 30 [_AmbientSkyFromGround]
Vector 31 [_AmbientNightSky]
SetTexture 0 [_TexShadowEnvMapSky] 2D
Vector 32 [_NuajLightningPosition00]
Vector 33 [_NuajLightningPosition01]
Vector 34 [_NuajLightningColor0]
Vector 35 [_NuajLightningPosition10]
Vector 36 [_NuajLightningPosition11]
Vector 37 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 38 [_ShadowAltitudesMinKm]
Vector 39 [_ShadowAltitudesMaxKm]
SetTexture 11 [_TexShadowMap] 2D
Vector 40 [_NuajLocalCoverageOffset]
Vector 41 [_NuajLocalCoverageFactor]
SetTexture 5 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 42 [_NuajTerrainEmissiveOffset]
Vector 43 [_NuajTerrainEmissiveFactor]
SetTexture 4 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 44 [_NuajTerrainAlbedo]
Vector 45 [_Sigma_Rayleigh]
Float 46 [_Sigma_Mie]
Float 47 [_MiePhaseAnisotropy]
SetTexture 2 [_TexDensity] 2D
Vector 48 [_BufferInvSize]
Float 49 [_CloudAltitudeKm]
Vector 50 [_CloudThicknessKm]
Float 51 [_CloudLayerIndex]
Float 52 [_Coverage]
Float 53 [_NoiseTiling]
Float 54 [_NoiseOctavesCount]
Vector 55 [_CloudPosition]
Vector 56 [_FrequencyFactor]
Vector 57 [_AmplitudeFactor]
Float 58 [_Smoothness]
Float 59 [_NormalAmplitude]
SetTexture 6 [_TexNoise0] 2D
SetTexture 7 [_TexNoise1] 2D
SetTexture 8 [_TexNoise2] 2D
SetTexture 9 [_TexNoise3] 2D
SetTexture 10 [_TexPhaseMie] 2D
Float 60 [_ScatteringCoeff]
Vector 61 [_CloudColor]
Vector 62 [_ScatteringFactors]
Float 63 [_ScatteringSkyFactor]
Float 64 [_ScatteringTerrainFactor]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[72] = { program.local[0..64],
		{ 0.5, 2.718282, 2, -1 },
		{ 0, 1, 1000000, -1000000 },
		{ 0.995, 500000, 0.89999998, 1.1 },
		{ 3, 4, 1000, 0.0099999998 },
		{ 0.00390625, 0.079577468, 10, 0.12509382 },
		{ 0.83333331, 0.21259999, 0.71520001, 0.0722 },
		{ 0.25 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
TEMP R8;
TEMP R9;
TEMP R10;
TEMP R11;
TEMP R12;
TEMP R13;
TEMP R14;
TEMP R15;
TEMP R16;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R1.xy, c[16];
MULR  R0.xy, fragment.texcoord[0], c[16];
MADR  R0.xy, R0, c[65].z, -R1;
MOVR  R0.z, c[65].w;
DP3R  R0.w, R0, R0;
RSQR  R5.x, R0.w;
MULR  R0.xyz, R5.x, R0;
MOVR  R0.w, c[66].x;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
MOVR  R0.w, c[49].x;
ADDR  R0.w, R0, c[21].x;
MOVX  H0.x, c[66];
MOVR  R1.x, c[0].w;
MOVR  R1.z, c[2].w;
MOVR  R1.y, c[1].w;
MULR  R1.xyz, R1, c[23].x;
ADDR  R4.xyz, R1, -c[17];
DP3R  R0.z, R4, R4;
DP3R  R0.y, R2, R4;
RSQR  R1.w, R0.z;
RCPR  R1.w, R1.w;
SLTR  H0.y, R1.w, R0.w;
MULR  R0.x, R0.y, R0.y;
MADR  R4.y, -R0.w, R0.w, R0.z;
ADDR  R0.w, R0.x, -R4.y;
SLTR  H0.w, R0.x, R4.y;
SEQX  H0.z, H0.y, c[66].x;
MULXC HC.x, H0.z, H0.w;
MOVR  R4.x, c[66].z;
RSQR  R0.w, R0.w;
RCPR  R4.y, R0.w;
MOVR  R0.w, c[66];
MOVR  R4.x(EQ), R2.w;
MOVX  H0.x(EQ), c[66].y;
MULXC HC.x, H0, H0.z;
ADDR  R4.x(NE), -R0.y, -R4.y;
MULXC HC.x, H0.y, H0.w;
MOVX  H0.x, c[66];
MOVR  R0.w(EQ.x), R2;
MOVX  H0.x(EQ), c[66].y;
MULXC HC.x, H0.y, H0;
ADDR  R0.w(NE.x), -R0.y, R4.y;
MOVXC RC.x, H0.y;
MOVR  R0.w(EQ.x), R4.x;
MADR  R4.x, -c[21], c[21], R0.z;
ADDR  R4.y, R0.x, -R4.x;
RSQR  R4.y, R4.y;
MOVR  R0.z, c[66];
SLTRC HC.x, R0, R4;
MOVR  R0.z(EQ.x), R2.w;
SGERC HC.x, R0, R4;
RCPR  R4.y, R4.y;
ADDR  R0.z(NE.x), -R0.y, -R4.y;
MOVR  R0.y, R0.z;
SGTR  H0.y, R0.z, c[67];
SLTR  H0.x, R0.z, c[66];
ADDXC_SAT HC.x, H0, H0.y;
ADDR  R0.x, c[16].w, -c[16].z;
RCPR  R0.z, R0.x;
MOVR  R0.y(NE.x), c[67];
RCPR  R4.x, R5.x;
TEX   R0.x, fragment.texcoord[0], texture[3], 2D;
MULR  R0.z, R0, c[16].w;
ADDR  R4.y, R0.z, -R0.x;
MULR  R0.x, R4, c[23];
RCPR  R4.x, R4.y;
MULR  R0.z, R0, c[16];
MULR  R0.z, R0, R4.x;
MADR  R0.y, R0.z, -R0.x, R0;
MOVR  R4.x, c[67];
MULR  R4.x, R4, c[16].w;
SGER  H0.x, R0.z, R4;
MULR  R0.x, R0.z, R0;
MADR  R0.x, H0, R0.y, R0;
SGTR  H0.y, R0.w, R0.x;
SLTR  H0.x, R0.w, c[66];
ADDXC_SAT HC.x, H0, H0.y;
MOVX  H0.x, c[66];
MOVR  oCol, c[66].xxxy;
MOVR  oCol(EQ.x), R3;
MOVR  R0.x, c[21];
ADDR  R3.x, -R0, c[22];
MOVR  R0.xyz, c[18];
DP3R  R0.x, R0, c[28];
RCPR  R3.x, R3.x;
MOVX  H0.x(EQ), c[66].y;
MOVXC RC.x, H0;
MULR  R0.y, R3.x, c[49].x;
MADR  R0.x, -R0, c[65], c[65];
TEX   R3.zw, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[46];
MADR  R0.xyz, R3.z, -c[45], -R0.x;
POWR  R3.x, c[65].y, R0.x;
POWR  R3.y, c[65].y, R0.y;
POWR  R3.z, c[65].y, R0.z;
TEX   R0.xyz, c[65].x, texture[1], 2D;
ADDR  R0.xyz, R0, c[29];
TEX   R3.w, c[65].x, texture[0], 2D;
MULR  R3.xyz, R3, c[26];
MULR  R0.xyz, R3.w, R0;
IF    NE.x;
ADDR  R4.xyz, R1, -c[17];
MULR  R5.xyz, R4.zxyw, c[28].yzxw;
MADR  R5.xyz, R4.yzxw, c[28].zxyw, -R5;
DP3R  R4.y, R4, c[28];
SLER  H0.x, R4.y, c[66];
MULR  R6.xyz, R2.zxyw, c[28].yzxw;
MADR  R6.xyz, R2.yzxw, c[28].zxyw, -R6;
DP3R  R3.w, R5, R6;
DP3R  R5.w, R5, R5;
DP3R  R5.x, R6, R6;
MADR  R5.y, -c[21].x, c[21].x, R5.w;
MULR  R5.z, R5.x, R5.y;
MULR  R5.w, R3, R3;
RCPR  R4.y, R5.x;
ADDR  R5.y, R5.w, -R5.z;
SGTR  H0.y, R5.w, R5.z;
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
ADDR  R4.x, -R3.w, R5.y;
MULX  H0.x, H0, c[25];
MULX  H0.x, H0, H0.y;
MOVR  R5.w, c[66].y;
MOVXC RC.x, H0;
MOVR  R4.z, c[66].w;
MULR  R4.z(NE.x), R4.y, R4.x;
ADDR  R3.w, -R3, -R5.y;
MOVR  R5.x, c[66].z;
MULR  R5.x(NE), R3.w, R4.y;
MOVR  R5.y, R4.z;
MOVR  R4.xy, R5;
MADR  R5.xyz, R2, R5.x, R1;
ADDR  R5.xyz, R5, -c[17];
DP3R  R3.w, R5, c[28];
SGTR  H0.y, R3.w, c[66].x;
MULXC HC.x, H0, H0.y;
MOVR  R8.zw, c[66].xyxy;
SEQR  H0.xy, c[51].x, R8.zwzw;
MADR  R1.xyz, R2, R0.w, R1;
MULR  R5.xyz, R1, c[24].x;
MOVR  R4.xy(NE.x), c[66].zwzw;
SEQX  H0.zw, H0.xyxy, c[66].x;
MULXC HC.x, H0.z, H0.y;
DP4R  R6.x, R5, c[8];
DP4R  R6.y, R5, c[10];
MADR  R6.xy, R6, c[65].x, c[65].x;
MOVR  R9, c[40];
TEX   R6, R6, texture[5], 2D;
MADR  R6, R6, c[41], R9;
MOVR  R7.y, R6.x;
MOVR  R7.y(NE.x), R6;
MOVR  R9.x, c[65].z;
MULR  R9.zw, R4.xyxy, c[67];
MADR  R9.zw, R4.xyxy, c[67].xywz, -R9;
MADR  R4.xy, -R4, c[67].zwzw, R0.w;
ADDR  R8.xyz, R1, -c[17];
SEQR  H0.x, c[51], R9;
MULX  H0.y, H0.z, H0.w;
MULXC HC.x, H0.y, H0;
MOVR  R7.y(NE.x), R6.z;
SEQX  H0.x, H0, c[66];
MULXC HC.x, H0.y, H0;
MOVR  R7.y(NE.x), R6.w;
DP3R  R6.z, R8, c[19];
MOVR  R6.xy, c[55];
DP3R  R6.w, R8, c[20];
MADR  R7.zw, R6, c[53].x, R6.xyxy;
TEX   R6, R7.zwzw, texture[6], 2D;
MOVR  R3.w, R6;
SLTRC HC.x, c[54], R9;
MOVR  R3.w(EQ.x), R7.x;
RCPR  R4.z, R9.w;
MULR_SAT R7.x, R4.y, R4.z;
MOVR  R4.z, c[68].x;
MADR  R4.y, -R7.x, c[65].z, R4.z;
MULR  R7.x, R7, R7;
MULR  R4.y, R7.x, R4;
RCPR  R7.x, R9.z;
MULR_SAT R7.x, R4, R7;
MADR  R4.x, -R7, c[65].z, R4.z;
MULR  R4.z, R7.x, R7.x;
MULR  R4.x, R4.z, R4;
MULR  R4.x, R4, R4.y;
MADR  R4.xyz, -R4.x, R3, R3;
SGER  H0.x, c[54], R9;
MOVXC RC.x, H0;
DP4R  R3.x, R5, c[12];
DP4R  R3.y, R5, c[14];
MADR  R5.xy, R3, c[65].x, c[65].x;
MOVR  R7.x, R3.w;
TEX   R5, R5, texture[4], 2D;
MOVR  R3, c[42];
MADR  R3, R5, c[43], R3;
MOVR  R5.x, c[49];
ADDR  R5.x, R5, c[21];
RCPR  R5.x, R5.x;
MOVR  R5.w, R6;
MADR  R6.xyz, R6, c[65].z, -R8.w;
MULR  R5.xyz, R8, R5.x;
IF    NE.x;
MOVR  R6.w, c[68].x;
SLTRC HC.x, c[54], R6.w;
MOVX  H0.y, c[66].x;
MOVX  H0.y(EQ.x), H0.x;
MOVR  R8.xy, c[55].zwzw;
MADR  R7.zw, R7, c[56].xyxy, R8.xyxy;
TEX   R8, R7.zwzw, texture[7], 2D;
MADR  R5.w, R8, c[57].x, R5;
MULR  R7.x(NE), R5.w, c[57].y;
MOVXC RC.x, H0.y;
MOVR  R6.w, c[57].x;
MULR  R8.xyz, R8, c[57].x;
MADR  R8.xyz, R8, c[65].z, -R6.w;
MOVX  H0.x, H0.y;
ADDR  R6.xyz, R6, R8;
IF    NE.x;
MOVR  R8.xy, c[55].zwzw;
MADR  R7.zw, R7, c[56].xyxy, R8.xyxy;
TEX   R8, R7.zwzw, texture[8], 2D;
MULR  R6.w, c[57].x, c[57].x;
MADR  R5.w, R6, R8, R5;
MOVR  R8.w, c[68].y;
SLTRC HC.x, c[54], R8.w;
MOVX  H0.y, c[66].x;
MULR  R8.xyz, R6.w, R8;
MADR  R8.xyz, R8, c[65].z, -R6.w;
MULR  R7.x(NE), R5.w, c[57].z;
MOVX  H0.y(EQ.x), H0.x;
MOVXC RC.x, H0.y;
ADDR  R6.xyz, R6, R8;
IF    NE.x;
MOVR  R8.xy, c[55].zwzw;
MADR  R7.zw, R7, c[56].xyxy, R8.xyxy;
MULR  R6.w, R6, c[57].x;
TEX   R8, R7.zwzw, texture[9], 2D;
MULR  R8.xyz, R8, R6.w;
MADR  R8.xyz, R8, c[65].z, -R6.w;
MADR  R5.w, R8, R6, R5;
ADDR  R6.xyz, R6, R8;
MULR  R7.x, R5.w, c[57].w;
ENDIF;
ENDIF;
ENDIF;
ADDR  R8.xyz, R1, -c[17];
DP3R  R5.w, R8, R8;
ADDR  R12.xyz, -R1, c[35];
DP3R  R13.y, R12, R12;
RSQR  R13.z, R13.y;
MULR  R12.xyz, R13.z, R12;
MULR  R15.xyz, R3.w, c[44];
RSQR  R5.w, R5.w;
RCPR  R5.w, R5.w;
ADDR  R5.w, R5, -c[21].x;
ADDR  R7.x, R7, c[52];
ADDR  R7.x, R7, -c[65];
RCPR  R13.z, R13.z;
MOVR  R16.xyz, c[30];
DP3R  R12.x, R2, R12;
MOVR  R6.w, c[66].y;
SGERC HC.x, R5.w, c[39].w;
MOVR  R6.w(EQ.x), R2;
MOVR  R2.w, R6;
MOVR  R6.w, c[49].x;
ADDR  R7.z, R6.w, c[21].x;
RCPR  R7.z, R7.z;
SLTRC HC.x, R5.w, c[39].w;
MULR  R8.xyz, R8, R7.z;
MULR_SAT R7.x, R7.y, R7;
MULR  R13.y, c[47].x, c[47].x;
MOVR  R9.xy, c[59].x;
MOVR  R9.z, c[66].y;
MULR  R6.xyz, R9, R6;
DP3R  R6.w, R6, R6;
RSQR  R6.w, R6.w;
MULR  R6.xyz, R6.w, R6;
MULR  R8.xyz, R6.z, R8;
MADR  R8.xyz, -R6.x, c[19], R8;
MADR  R6.xyz, R6.y, c[20], R8;
DP3R  R12.w, R6, c[28];
DP3R  R7.z, R2, R6;
ADDR  R7.y, |R7.z|, -R12.w;
MAXR  R6.w, |R7.z|, c[68];
MULR  R6.y, R7.x, R7.x;
MAXR  R6.x, |R12.w|, c[68].w;
MULR  R6.y, R6, c[50].x;
MULR  R10.z, R6.y, c[68];
MULR  R10.w, R10.z, -c[60].x;
RCPR  R6.x, R6.x;
MULR  R6.y, R10.z, R6.x;
RCPR  R6.w, R6.w;
MULR  R6.x, R10.z, R6.w;
MULR  R8.w, R6.x, c[60].x;
MULR  R6.y, R6, -c[60].x;
POWR  R6.z, c[65].y, R6.y;
POWR  R7.w, c[65].y, -R8.w;
ADDR  R6.x, R7.w, -R6.z;
MULR  R7.x, R12.w, R6;
DP3R  R6.x, R2, c[28];
RCPR  R6.y, R7.y;
MULR  R7.x, R7, R6.y;
MAXR  R8.x, R7.y, c[68].w;
MULR  R7.y, R7.w, R6.z;
MAXR  R11.x, R12.w, c[68].w;
RCPR  R11.x, R11.x;
MULR  R11.x, R10.z, R11;
MULR  R10.z, R11.x, -c[60].x;
MULR  R11.x, R11, c[62];
MADR  R7.y, -R12.w, -R7, -R12.w;
RCPR  R6.z, R8.x;
MULR  R7.y, R7, R6.z;
MOVR_SAT R13.x, -R12.w;
MADR  R6.x, -R6, c[65], c[65];
MOVR  R6.y, c[65].x;
TEX   R9, R6, texture[10], 2D;
MADR  R10.xy, R9.ywzw, c[69].x, R9.xzzw;
MOVR  R7.z, c[60].x;
MULR  R6.xy, R7.z, c[62].yzzw;
MULR  R6.x, R10, R6;
MULR  R7.z, R6.x, R7.x;
POWR  R11.w, c[65].y, R10.w;
MULR  R9.y, -R10.w, R11.w;
MOVR_SAT R9.x, R12.w;
MAXR  R8.xyz, R7.z, c[66].x;
MULR  R7.z, R6.y, c[60].x;
MULR  R7.z, R10.y, R7;
MULR  R6.x, R6, R7.y;
MULR  R10.x, R10, c[65];
MADR  R11.w, -R10, -R11, -R10;
MULR  R11.w, R11, R13.x;
MULR  R7.x, R7, R7.z;
MULR  R9.w, R9.y, R9.x;
MAXR  R9.xyz, R7.x, c[66].x;
MULR  R7.x, R9.w, c[62].w;
MULR  R10.y, R12.w, R7.x;
MULR  R10.y, R6.w, R10;
MULR  R13.x, R11.w, c[62].w;
MULR  R12.w, -R12, R13.x;
MOVR  R13.x, c[66].y;
MADR  R12.x, R12, c[47], R13;
RCPR  R14.x, R12.x;
MADR  R13.w, -R13.y, R14.x, R14.x;
MULR  R12.w, R6, R12;
MULR  R7.y, R7, R7.z;
MOVR  R12.xyz, c[35];
MULR  R6.w, R10, R6;
MULR  R13.w, R13, R14.x;
ADDR  R12.xyz, -R12, c[36];
DP3R  R14.x, R12, R12;
ADDR  R12.xyz, -R1, c[32];
RSQR  R14.x, R14.x;
RCPR  R14.x, R14.x;
MULR  R14.x, R14, R13.w;
DP3R  R14.y, R12, R12;
RSQR  R13.w, R14.y;
MULR  R12.xyz, R13.w, R12;
DP3R  R2.y, R2, R12;
MULR  R13.z, R13, c[68];
RCPR  R12.z, R13.w;
MADR  R2.z, R2.y, c[47].x, R13.x;
MULR  R2.x, R13.z, R13.z;
RCPR  R2.y, R2.x;
MULR  R2.y, R14.x, R2;
RCPR  R2.x, R2.z;
MADR  R2.z, -R13.y, R2.x, R2.x;
MULR  R12.x, R2.y, c[68].z;
MULR  R12.y, R2.z, R2.x;
MOVR  R2.xyz, c[32];
ADDR  R2.xyz, -R2, c[33];
DP3R  R2.y, R2, R2;
MULR  R12.z, R12, c[68];
MULR  R2.x, R12.z, R12.z;
RSQR  R2.y, R2.y;
RCPR  R2.y, R2.y;
MULR  R2.y, R2, R12;
RCPR  R2.x, R2.x;
MULR  R2.y, R2, R2.x;
MINR  R2.x, R12, c[66].y;
MULR  R12.x, R2.y, c[68].z;
POWR  R10.x, R10.x, R8.w;
MULR  R11.x, R11, c[60];
POWR  R10.z, c[65].y, R10.z;
MULR  R10.z, R11.x, R10;
MINR  R12.x, R12, c[66].y;
MULR  R2.xyz, R2.x, c[37];
MADR  R2.xyz, R12.x, c[34], R2;
MULR  R12.x, R12.w, c[69].y;
MULR  R2.xyz, R8.w, R2;
MULR  R2.xyz, R7.w, R2;
DP3R_SAT R3.w, R5, c[28];
ADDR  R16.xyz, R16, c[27];
MULR  R5.xyz, R15, R16;
MULR  R10.y, R10, c[69];
MULR  R11.xyz, R10.z, R10.x;
MAXR  R6.xyz, R6.x, c[66].x;
MAXR  R7.xyz, R7.y, c[66].x;
MAXR  R10.xyz, R10.y, c[66].x;
MAXR  R12.xyz, R12.x, c[66].x;
MULR  R2.xyz, R2, c[69].z;
POWR  R6.w, c[65].y, R6.w;
MOVR  R14.xyz, R9.w;
MOVR  R13.xyz, R11.w;
MADR  R3.xyz, R5, R3.w, R3;
IF    NE.x;
MOVR  R2.w, c[66].y;
SGERC HC.x, R5.w, c[39].w;
MOVR  R2.w(EQ.x), R4;
SLTRC HC.x, R5.w, c[39].w;
MOVR  R15.w, c[66].y;
MOVR  R15.xyz, R1;
MOVR  R4.w, R2;
DP4R  R5.y, R15, c[5];
DP4R  R5.x, R15, c[4];
IF    NE.x;
MOVR  R15, c[39];
ADDR  R16, -R15, c[38];
ADDR  R15, R5.w, -c[39];
RCPR  R2.w, R16.y;
MULR_SAT R4.w, R15.y, R2;
MOVR  R2.w, c[68].x;
MULR  R3.w, R4, R4;
MADR  R4.w, -R4, c[65].z, R2;
RCPR  R5.z, R16.x;
MULR  R4.w, R3, R4;
MULR_SAT R3.w, R15.x, R5.z;
TEX   R5, R5, texture[11], 2D;
MADR  R4.w, R5.y, R4, -R4;
MADR  R5.y, -R3.w, c[65].z, R2.w;
MULR  R3.w, R3, R3;
MULR  R5.y, R3.w, R5;
ADDR  R3.w, R4, c[66].y;
MADR  R4.w, R5.x, R5.y, -R5.y;
MADR  R3.w, R4, R3, R3;
RCPR  R5.x, R16.z;
MULR_SAT R5.x, R5, R15.z;
MADR  R5.y, -R5.x, c[65].z, R2.w;
RCPR  R4.w, R16.w;
MULR_SAT R4.w, R4, R15;
MADR  R2.w, -R4, c[65].z, R2;
MULR  R4.w, R4, R4;
MULR  R2.w, R4, R2;
MULR  R5.x, R5, R5;
MULR  R5.x, R5, R5.y;
MADR  R4.w, R5.z, R5.x, -R5.x;
MADR  R3.w, R4, R3, R3;
MADR  R2.w, R5, R2, -R2;
MADR  R4.w, R2, R3, R3;
ENDIF;
MOVR  R2.w, R4;
ENDIF;
ADDR  R5.xyz, R11, R8;
ADDR  R5.xyz, R5, R9;
ADDR  R8.xyz, R5, R10;
ADDR  R5.xyz, R0, c[31];
MULR  R0.xyz, R14, c[63].x;
MULR  R9.xyz, R0, R5;
MULR  R0.xyz, R2.w, R4;
ADDR  R4.xyz, R1, -c[17];
DP3R  R2.w, R4, R4;
MADR  R8.xyz, R0, R8, R9;
RSQR  R2.w, R2.w;
RCPR  R2.w, R2.w;
ADDR  R2.w, R2, -c[21].x;
MULR  R3.w, R2, c[69];
ADDR  R1.xyz, R8, R2;
MULR  R4.xyz, R13, c[64].x;
MADR  R1.xyz, R4, R3, R1;
ADDR  R3.xyz, R6, R7;
MULR  R4.xyz, R13, c[63].x;
MULR  R4.xyz, R5, R4;
ADDR  R3.xyz, R3, R12;
MADR  R0.xyz, R0, R3, R4;
ADDR  R0.xyz, R2, R0;
ADDR  R1.xyz, R1, R0;
MULR  R2.w, R2, c[70].x;
ADDR  R1.w, R1, -c[21].x;
POWR  R5.y, c[65].y, -R2.w;
MULR  R2.w, R1, c[69];
MULR  R1.w, R1, c[70].x;
POWR  R5.w, c[65].y, -R1.w;
POWR  R5.x, c[65].y, -R3.w;
POWR  R5.z, c[65].y, -R2.w;
ADDR  R5.xy, R5.zwzw, R5;
MULR  R3.xy, R5, c[65].x;
MULR  R1.w, R3.y, c[46].x;
MULR  R2.xyz, R3.x, c[45];
MADR  R2.xyz, R2, c[71].x, R1.w;
MULR  R0.xyz, -R2, R0.w;
MULR  R1.xyz, R1, c[61];
POWR  R0.x, c[65].y, R0.x;
POWR  R0.z, c[65].y, R0.z;
POWR  R0.y, c[65].y, R0.y;
MULR  oCol.xyz, R1, R0;
DP3R  oCol.w, R6.w, c[70].yzww;
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 16 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 17 [_PlanetCenterKm]
Vector 18 [_PlanetNormal]
Vector 19 [_PlanetTangent]
Vector 20 [_PlanetBiTangent]
Float 21 [_PlanetRadiusKm]
Float 22 [_WorldUnit2Kilometer]
Float 23 [_Kilometer2WorldUnit]
Float 24 [_bComputePlanetShadow]
Vector 25 [_SunColorFromGround]
Vector 26 [_SunDirection]
Vector 27 [_AmbientSkyFromGround]
Vector 28 [_AmbientNightSky]
Vector 29 [_NuajLightningPosition00]
Vector 30 [_NuajLightningPosition01]
Vector 31 [_NuajLightningColor0]
Vector 32 [_NuajLightningPosition10]
Vector 33 [_NuajLightningPosition11]
Vector 34 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 35 [_ShadowAltitudesMinKm]
Vector 36 [_ShadowAltitudesMaxKm]
SetTexture 8 [_TexShadowMap] 2D
Vector 37 [_NuajLocalCoverageOffset]
Vector 38 [_NuajLocalCoverageFactor]
SetTexture 2 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 39 [_NuajTerrainEmissiveOffset]
Vector 40 [_NuajTerrainEmissiveFactor]
SetTexture 1 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 41 [_NuajTerrainAlbedo]
Vector 42 [_Sigma_Rayleigh]
Float 43 [_Sigma_Mie]
Float 44 [_MiePhaseAnisotropy]
Vector 45 [_BufferInvSize]
Float 46 [_CloudAltitudeKm]
Vector 47 [_CloudThicknessKm]
Float 48 [_CloudLayerIndex]
Float 49 [_Coverage]
Float 50 [_NoiseTiling]
Float 51 [_NoiseOctavesCount]
Vector 52 [_CloudPosition]
Vector 53 [_FrequencyFactor]
Vector 54 [_AmplitudeFactor]
Float 55 [_Smoothness]
Float 56 [_NormalAmplitude]
SetTexture 3 [_TexNoise0] 2D
SetTexture 4 [_TexNoise1] 2D
SetTexture 5 [_TexNoise2] 2D
SetTexture 6 [_TexNoise3] 2D
SetTexture 7 [_TexPhaseMie] 2D
Float 57 [_ScatteringCoeff]
Vector 58 [_CloudColor]
Vector 59 [_ScatteringFactors]
Float 60 [_ScatteringSkyFactor]
Float 61 [_ScatteringTerrainFactor]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
dcl_2d s8
def c62, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c63, 1000000.00000000, -1000000.00000000, 0.99500000, 500000.00000000
def c64, 0.89999998, 1.10000002, 2.00000000, 3.00000000
def c65, 0.50000000, -2.00000000, 512.00000000, -3.00000000
def c66, -4.00000000, -0.50000000, 1000.00000000, 0.01000000
def c67, 2.71828198, 0.50000000, 0.00000000, 0.00390625
def c68, 0.07957747, 10.00000000, 0.12509382, 0.83333331
def c69, 0.21259999, 0.71520001, 0.07220000, 0.25000000
dcl_texcoord0 v0.xyzw
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
mad r1.xy, v0, c62.x, c62.y
mov r1.z, c62.y
mul r1.xy, r1, c16
dp3 r1.w, r1, r1
rsq r2.w, r1.w
mul r1.xyz, r2.w, r1
mov r1.w, c62.z
dp4 r3.z, r1, c2
dp4 r3.y, r1, c1
dp4 r3.x, r1, c0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c22.x
add r4.xyz, r2, -c17
dp3 r4.w, r4, r4
dp3 r1.y, r3, r4
mad r1.x, -c21, c21, r4.w
mad r1.x, r1.y, r1.y, -r1
rsq r1.z, r1.x
rcp r1.z, r1.z
add r1.w, -r1.y, -r1.z
cmp_pp r1.z, r1.x, c62.w, c62
cmp r1.x, r1, r0, c63
cmp r1.x, -r1.z, r1, r1.w
add r1.z, -r1.x, c63.w
cmp r1.w, r1.z, c62.z, c62
cmp r1.z, r1.x, c62, c62.w
add_pp_sat r1.z, r1, r1.w
cmp r4.y, -r1.z, r1.x, c63.w
rcp r1.w, r2.w
add r1.x, c16.w, -c16.z
rcp r1.z, r1.x
mul r4.x, r1.w, c22
mul r1.z, r1, c16.w
texldl r1.x, v0, s0
add r1.x, r1.z, -r1
rcp r1.w, r1.x
mul r1.x, r1.z, c16.z
mul r2.w, r1.x, r1
mov r1.x, c21
add r1.z, c46.x, r1.x
mad r1.w, -r1.z, r1.z, r4
mov r1.x, c16.w
mad r1.x, c63.z, -r1, r2.w
mad r4.y, r2.w, -r4.x, r4
mul r2.w, r2, r4.x
cmp r1.x, r1, c62.w, c62.z
mad r5.x, r1, r4.y, r2.w
mad r1.w, r1.y, r1.y, -r1
rsq r1.x, r4.w
rsq r2.w, r1.w
rcp r4.x, r2.w
add r4.w, -r1.y, r4.x
rcp r5.w, r1.x
add r1.x, r5.w, -r1.z
cmp r1.x, r1, c62.z, c62.w
cmp r2.w, r1, c62.z, c62
mul_pp r4.y, r1.x, r2.w
abs_pp r1.z, r1.x
cmp_pp r4.z, -r4.y, c62.w, c62
cmp_pp r1.w, -r1.z, c62, c62.z
cmp r4.y, -r4, r0.x, c63
mul_pp r1.x, r1, r4.z
mul_pp r2.w, r1, r2
cmp r4.y, -r1.x, r4, r4.w
add r4.x, -r1.y, -r4
cmp_pp r1.x, -r2.w, c62.w, c62.z
cmp r1.y, -r2.w, r0.x, c63.x
mul_pp r1.x, r1, r1.w
cmp r1.x, -r1, r1.y, r4
cmp r6.w, -r1.z, r1.x, r4.y
add r1.x, -r6.w, r5
cmp r1.y, r1.x, c62.z, c62.w
cmp r1.x, r6.w, c62.z, c62.w
add_pp_sat r1.x, r1, r1.y
cmp_pp r1.y, -r1.x, c62.w, c62.z
cmp oC0, -r1.x, r0, c62.zzzw
if_gt r1.y, c62.z
add r1.xyz, r2, -c17
mul r4.xyz, r1.zxyw, c26.yzxw
mad r4.xyz, r1.yzxw, c26.zxyw, -r4
dp3 r0.y, r4, r4
mul r5.xyz, r3.zxyw, c26.yzxw
mad r5.xyz, r3.yzxw, c26.zxyw, -r5
mad r0.z, -c21.x, c21.x, r0.y
dp3 r0.y, r5, r5
dp3 r0.w, r4, r5
mul r0.z, r0.y, r0
rcp r4.x, r0.y
mad r0.z, r0.w, r0.w, -r0
rsq r1.w, r0.z
dp3 r0.y, r1, c26
rcp r1.w, r1.w
add r2.w, -r0, -r1
cmp r0.y, -r0, c62.w, c62.z
mul r1.x, r2.w, r4
add r1.w, -r0, r1
cmp r0.z, -r0, c62, c62.w
mul_pp r0.y, r0, c24.x
mul_pp r0.y, r0, r0.z
cmp r0.z, -r0.y, c63.x, r1.x
mad r1.xyz, r3, r0.z, r2
add r1.xyz, r1, -c17
dp3 r0.w, r1, c26
mul r1.y, r4.x, r1.w
mul r4.xyz, r3, r6.w
add r6.xyz, r2, r4
cmp r1.x, -r0.w, c62.z, c62.w
cmp r0.w, -r0.y, c63.y, r1.y
mul_pp r0.y, r0, r1.x
cmp r0.zw, -r0.y, r0, c63.xyxy
mul r1.x, r0.w, c64.y
mul r0.y, r0.z, c64.x
mov r1.w, c62
mad r1.y, r0.w, c64.x, -r1.x
mad r0.y, r0.z, c64, -r0
rcp r1.x, r0.y
mad r0.y, -r0.z, c64.x, r6.w
mul_sat r0.y, r0, r1.x
mad r0.z, -r0.w, c64.y, r6.w
rcp r1.x, r1.y
mul_sat r0.w, r0.z, r1.x
mad r0.z, -r0.y, c64, c64.w
mul r0.y, r0, r0
mul r0.y, r0, r0.z
mul r0.z, r0.w, r0.w
mad r0.w, -r0, c64.z, c64
mul r4.w, r0.z, r0
mul r1.xyz, r6, c23.x
mad r0.y, -r0, r4.w, c62.w
mul r5.xyz, v2, r0.y
dp4 r0.z, r1, c8
dp4 r0.w, r1, c10
add r0.zw, r0, c62.w
mul r2.xy, r0.zwzw, c65.x
mov r0.y, c48.x
mov r2.z, c62
texldl r2, r2.xyzz, s2
mul r2, r2, c38
add r2, r2, c37
add r0.w, c62.y, r0.y
abs r0.z, c48.x
cmp r0.y, -r0.z, c62.w, c62.z
abs r0.z, r0.w
cmp r0.w, -r0.z, c62, c62.z
abs_pp r0.y, r0
cmp_pp r0.z, -r0.y, c62.w, c62
mul_pp r4.w, r0.z, r0
cmp r2.y, -r4.w, r2.x, r2
mov r0.y, c48.x
add r2.x, c65.y, r0.y
abs_pp r0.y, r0.w
abs r0.w, r2.x
cmp_pp r0.y, -r0, c62.w, c62.z
mul_pp r0.y, r0.z, r0
cmp r0.w, -r0, c62, c62.z
abs_pp r0.z, r0.w
mul_pp r0.w, r0.y, r0
cmp_pp r0.z, -r0, c62.w, c62
mul_pp r0.y, r0, r0.z
cmp r0.w, -r0, r2.y, r2.z
cmp r8.w, -r0.y, r0, r2
dp3 r0.y, r4, r4
rsq r0.y, r0.y
dp4 r0.z, r1, c12
dp4 r0.w, r1, c14
add r0.zw, r0, c62.w
mul r2.xyz, r0.y, r4
mul r1.xy, r0.zwzw, c65.x
dp3 r0.z, r2, c18
abs r0.z, r0
rcp r0.w, r0.z
rcp r0.z, r0.y
mov r1.z, c62
texldl r1, r1.xyzz, s1
mul r2, r1, c40
mov r0.y, c50.x
add r7.xyz, r6, -c17
mul r1.x, c65.z, r0.y
mul r0.z, r0, c16.y
mul r0.y, r0.z, c45
mul r0.y, r0, r0.w
rcp r0.z, r1.x
mul r0.y, r0, r0.z
mul r0.y, r0, c62.x
log r0.y, r0.y
dp3 r0.z, r7, c19
dp3 r0.w, r7, c20
mul r0.zw, r0, c50.x
add r8.xy, r0.zwzw, c52
add r8.z, r0.y, c55.x
texldl r1, r8.xyzz, s3
add r4, r2, c39
mov r0.z, c21.x
mov r0.w, c51.x
mad r2.xyz, r1, c62.x, c62.y
add r1.x, c65.y, r0.w
add r0.z, c46.x, r0
rcp r0.w, r0.z
cmp_pp r0.z, r1.x, c62.w, c62
mov r0.y, r1.w
cmp r3.w, r1.x, r3, r1
mul r7.xyz, r7, r0.w
if_gt r0.z, c62.z
mul r1.xy, r8, c53
add r8.xy, r1, c52.zwzw
texldl r1, r8.xyzz, s4
mad r1.xyz, r1, c62.x, c62.y
mov r0.w, c51.x
add r0.w, c65, r0
cmp_pp r0.z, r0.w, r0, c62
mad r2.xyz, r1, c54.x, r2
mad r0.y, r1.w, c54.x, r0
mul r1.x, r0.y, c54.y
cmp r3.w, r0, r3, r1.x
if_gt r0.z, c62.z
mul r1.xy, r8, c53
add r8.xy, r1, c52.zwzw
texldl r1, r8.xyzz, s5
mul r0.w, c54.x, c54.x
mad r1.xyz, r1, c62.x, c62.y
mad r2.xyz, r0.w, r1, r2
mov r1.x, c51
add r1.x, c66, r1
mad r0.y, r0.w, r1.w, r0
mul r1.y, r0, c54.z
cmp_pp r0.z, r1.x, r0, c62
cmp r3.w, r1.x, r3, r1.y
if_gt r0.z, c62.z
mul r1.xy, r8, c53
mul r0.z, r0.w, c54.x
mov r1.z, r8
add r1.xy, r1, c52.zwzw
texldl r1, r1.xyzz, s6
mad r1.xyz, r1, c62.x, c62.y
mad r0.y, r0.z, r1.w, r0
mad r2.xyz, r0.z, r1, r2
mul r3.w, r0.y, c54
endif
endif
endif
mov r0.z, c21.x
add r0.z, c46.x, r0
add r14.xyz, -r6, c32
mov r15.xyz, c33
mov r1.z, c62.w
mov r1.xy, c56.x
mul r1.xyz, r1, r2
dp3 r0.y, r1, r1
rsq r1.w, r0.y
rcp r2.x, r0.z
add r0.yzw, r6.xxyz, -c17.xxyz
mul r1.xyz, r1.w, r1
mul r2.xyz, r0.yzww, r2.x
mul r2.xyz, r1.z, r2
mad r2.xyz, -r1.x, c19, r2
mad r1.xyz, r1.y, c20, r2
dp3 r11.w, r1, c26
dp3 r1.w, r3, r1
abs r1.y, r1.w
add r8.z, r1.y, -r11.w
add r1.x, r3.w, c49
max r1.y, r1, c66.w
rcp r3.w, r1.y
add r1.x, r1, c66.y
mul_sat r1.x, r8.w, r1
abs r1.y, r11.w
mul r1.x, r1, r1
mul r1.x, r1, c47
mul r8.x, r1, c66.z
mul r1.x, r8, r3.w
max r1.y, r1, c66.w
rcp r1.y, r1.y
mul r1.y, r8.x, r1
mul r12.w, r8.x, -c57.x
mul r9.w, r1.x, c57.x
mul r2.x, r1.y, -c57
pow r1, c67.x, r2.x
pow r2, c67.x, -r9.w
mov r10.w, r2.x
add r1.y, r10.w, -r1.x
max r1.z, r8, c66.w
mad r1.x, -r10.w, r1, c62.w
rcp r1.z, r1.z
mul r1.x, -r11.w, r1
mul r8.y, r1.x, r1.z
dp3 r1.x, r3, c26
add r1.x, -r1, c62.w
rcp r1.z, r8.z
mul r1.y, r11.w, r1
mul r8.z, r1.y, r1
mov r1.yz, c67
mul r1.x, r1, c67.y
texldl r2, r1.xyzz, s7
mad r2.x, r2.y, c67.w, r2
mov r1.w, c59.y
mul r1.x, c57, r1.w
mul r1.x, r2, r1
mul r1.y, r1.x, r8.z
mul r1.x, r1, r8.y
mov r2.y, c59.z
max r9.xyz, r1.y, c62.z
max r10.xyz, r1.x, c62.z
pow r1, c67.x, r12.w
mul r1.y, c57.x, r2
mul r1.y, r1, c57.x
mad r1.z, r2.w, c67.w, r2
mul r1.z, r1.y, r1
mul r1.w, r8.z, r1.z
mul r1.z, r8.y, r1
mov r1.y, r1.x
mul r1.x, -r12.w, r1.y
mov_sat r2.y, r11.w
add r1.y, -r1, c62.w
mul r1.x, r1, r2.y
mul r8.y, r2.x, c67
max r11.xyz, r1.w, c62.z
mul r1.w, r1.x, c59
pow r2, r8.y, r9.w
mul r1.w, r11, r1
max r12.xyz, r1.z, c62.z
mul r1.z, r3.w, r1.w
mul r1.z, r1, c68.x
max r1.w, r11, c66
rcp r1.w, r1.w
mul r1.w, r8.x, r1
mul r2.y, r1.w, -c57.x
pow r8, c67.x, r2.y
mul r1.w, r1, c59.x
max r13.xyz, r1.z, c62.z
mov r2.y, r2.x
mov r2.x, r8
mul r1.w, r1, c57.x
mul r1.w, r1, r2.x
mul r8.xyz, r1.w, r2.y
mul r2.y, r12.w, r3.w
mov_sat r1.z, -r11.w
mul r1.y, -r12.w, r1
mul r2.x, r1.y, r1.z
dp3 r1.z, r14, r14
rsq r2.z, r1.z
mul r14.xyz, r2.z, r14
mul r1.y, r2.x, c59.w
mul r1.y, -r11.w, r1
mul r1.y, r3.w, r1
rcp r2.z, r2.z
mul r2.z, r2, c66
mul r2.z, r2, r2
dp3 r1.z, r3, r14
mul r1.y, r1, c68.x
max r14.xyz, r1.y, c62.z
mul r1.y, r1.z, c44.x
add r1.z, r1.y, c62.w
mul r1.y, -c44.x, c44.x
rcp r1.z, r1.z
add r2.w, r1.y, c62
mul r1.y, r2.w, r1.z
mul r3.w, r1.y, r1.z
add r1.yzw, -c32.xxyz, r15.xxyz
dp3 r1.z, r1.yzww, r1.yzww
add r15.xyz, -r6, c29
dp3 r1.y, r15, r15
rsq r1.y, r1.y
mul r15.xyz, r1.y, r15
dp3 r1.w, r3, r15
rsq r1.z, r1.z
rcp r1.z, r1.z
mul r1.w, r1, c44.x
add r1.w, r1, c62
mov r3.xyz, c30
mul r1.z, r1, r3.w
rcp r2.z, r2.z
mul r1.z, r1, r2
rcp r1.w, r1.w
mul r2.z, r2.w, r1.w
mul r1.z, r1, c66
mul r1.w, r2.z, r1
rcp r1.y, r1.y
mul r2.z, r1.y, c66
add r3.xyz, -c29, r3
dp3 r1.y, r3, r3
min r1.z, r1, c62.w
mul r2.z, r2, r2
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r1.y, r1, r1.w
rcp r2.z, r2.z
mul r1.y, r1, r2.z
mul r1.y, r1, c66.z
mul r3.xyz, r1.z, c34
min r1.y, r1, c62.w
mad r15.xyz, r1.y, c31, r3
pow r3, c67.x, r2.y
mul r15.xyz, r9.w, r15
mul r15.xyz, r10.w, r15
mul r1.yzw, r15.xxyz, c68.y
mov r3.w, r3.x
mov r3.xyz, r1.x
dp3 r1.x, r0.yzww, r0.yzww
mov r15.xyz, r2.x
mov r0.yzw, c25.xxyz
rsq r1.x, r1.x
rcp r1.x, r1.x
add r0.yzw, c27.xxyz, r0
mul r2.xyz, r4.w, c41
mul r2.xyz, r2, r0.yzww
dp3_sat r0.y, r7, c26
add r1.x, r1, -c21
add r0.z, r1.x, -c36.w
mad r4.xyz, r2, r0.y, r4
cmp_pp r0.y, r0.z, c62.z, c62.w
cmp r7.w, r0.z, c62, r7
if_gt r0.y, c62.z
add r0.y, r1.x, -c36.w
mov r2.xyz, r6
mov r2.w, c62
dp4 r0.w, r2, c5
dp4 r0.z, r2, c4
cmp_pp r2.x, r0.y, c62.z, c62.w
cmp r0.x, r0.y, c62.w, r0
if_gt r2.x, c62.z
mov r0.xy, r0.zwzw
mov r0.w, c35.x
add r2.x, -c36, r0.w
rcp r2.y, r2.x
add r2.x, r1, -c36
mul_sat r2.x, r2, r2.y
mul r2.y, r2.x, r2.x
mov r0.z, c62
texldl r0, r0.xyzz, s8
add r2.z, r0.x, c62.y
mad r2.x, -r2, c64.z, c64.w
mul r2.x, r2.y, r2
mov r0.x, c35.y
add r0.x, -c36.y, r0
rcp r2.y, r0.x
add r0.x, r1, -c36.y
mul_sat r0.x, r0, r2.y
add r2.y, r0, c62
mad r0.y, -r0.x, c64.z, c64.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2, c62.w
mov r0.x, c35.z
add r2.y, -c36.z, r0.x
mad r2.x, r2, r2.z, c62.w
mul r0.x, r2, r0.y
rcp r2.x, r2.y
add r0.y, r1.x, -c36.z
mul_sat r0.y, r0, r2.x
add r2.y, r0.z, c62
mad r2.x, -r0.y, c64.z, c64.w
mul r0.z, r0.y, r0.y
mul r0.z, r0, r2.x
mov r0.y, c35.w
add r2.x, -c36.w, r0.y
mad r0.y, r0.z, r2, c62.w
add r0.z, r1.x, -c36.w
rcp r2.x, r2.x
mul_sat r0.z, r0, r2.x
add r1.x, r0.w, c62.y
mad r0.w, -r0.z, c64.z, c64
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.x, c62.w
mul r0.x, r0, r0.y
mul r0.x, r0, r0.z
endif
mov r7.w, r0.x
endif
add r1.x, r5.w, -c21
mul r2.w, r1.x, c68.z
add r0.xyz, r8, r9
add r0.xyz, r0, r11
add r2.xyz, r0, r13
mul r0.xyz, r3, c60.x
add r3.xyz, v1, c28
mul r7.xyz, r0, r3
pow r0, c67.x, -r2.w
mul r5.xyz, r7.w, r5
mad r7.xyz, r5, r2, r7
add r2.xyz, r6, -c17
mov r6.x, r0
dp3 r0.x, r2, r2
rsq r2.x, r0.x
mul r1.x, r1, c68.w
pow r0, c67.x, -r1.x
rcp r0.x, r2.x
add r0.x, r0, -c21
mov r6.y, r0
mul r2.x, r0, c68.w
mul r1.x, r0, c68.z
pow r0, c67.x, -r2.x
pow r2, c67.x, -r1.x
mov r0.x, r2
add r0.xy, r6, r0
mul r6.xy, r0, c65.x
add r2.xyz, r7, r1.yzww
mul r0.xyz, r15, c61.x
mad r0.xyz, r0, r4, r2
mul r4.xyz, r15, c60.x
mul r0.w, r6.y, c43.x
mul r2.xyz, r6.x, c42
mad r2.xyz, r2, c69.w, r0.w
mul r2.xyz, -r2, r6.w
mul r3.xyz, r3, r4
add r6.xyz, r10, r12
add r4.xyz, r6, r14
mad r3.xyz, r5, r4, r3
add r3.xyz, r1.yzww, r3
add r0.xyz, r0, r3
pow r1, c67.x, r2.x
mul r3.xyz, r0, c58
mov r2.x, r1
pow r1, c67.x, r2.z
pow r0, c67.x, r2.y
mov r2.z, r1
mov r2.y, r0
mul oC0.xyz, r3, r2
dp3 oC0.w, r3.w, c69
endif

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 computes environment lighting (this is simply the cloud rendered into a small map)
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
MOV   result.texcoord[1].xyz, c[8].x;
MOV   result.texcoord[2].xyz, c[8].x;
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
Vector 8 [_PlanetNormal]
Float 9 [_PlanetRadiusKm]
Float 10 [_PlanetAtmosphereRadiusKm]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 1 [_TexAmbientSky] 2D
Vector 13 [_SoftAmbientSky]
SetTexture 0 [_TexShadowEnvMapSky] 2D
Vector 14 [_Sigma_Rayleigh]
Float 15 [_Sigma_Mie]
SetTexture 2 [_TexDensity] 2D
Float 16 [_CloudAltitudeKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c17, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
mov r0.y, c10.x
add r0.x, -r0, c17.z
add r0.y, -c9.x, r0
rcp r0.y, r0.y
mul r0.x, r0, c17.y
mul r0.y, r0, c16.x
mov r0.z, c17.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c17.w, r1.x
mov r1.x, r0
pow r0, c17.w, r1.z
mov r1.z, r0
pow r2, c17.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c17.yyzx, s1
mov r1.zw, c17.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c17.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c17.x
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
Matrix 0 [_Camera2World]
Vector 16 [_PlanetCenterKm]
Vector 17 [_PlanetNormal]
Vector 18 [_PlanetTangent]
Vector 19 [_PlanetBiTangent]
Float 20 [_PlanetRadiusKm]
Float 21 [_WorldUnit2Kilometer]
Float 22 [_Kilometer2WorldUnit]
Vector 23 [_SunColorFromGround]
Vector 24 [_SunDirection]
Vector 25 [_AmbientSkyFromGround]
Vector 26 [_AmbientNightSky]
Float 27 [_EnvironmentMapPixelSize]
Vector 28 [_EnvironmentAngles]
Vector 29 [_NuajLightningPosition00]
Vector 30 [_NuajLightningPosition01]
Vector 31 [_NuajLightningColor0]
Vector 32 [_NuajLightningPosition10]
Vector 33 [_NuajLightningPosition11]
Vector 34 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 35 [_ShadowAltitudesMinKm]
Vector 36 [_ShadowAltitudesMaxKm]
SetTexture 7 [_TexShadowMap] 2D
Vector 37 [_NuajLocalCoverageOffset]
Vector 38 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 39 [_NuajTerrainEmissiveOffset]
Vector 40 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 41 [_NuajTerrainAlbedo]
Vector 42 [_Sigma_Rayleigh]
Float 43 [_Sigma_Mie]
Float 44 [_MiePhaseAnisotropy]
Float 45 [_CloudAltitudeKm]
Vector 46 [_CloudThicknessKm]
Float 47 [_CloudLayerIndex]
Float 48 [_Coverage]
Float 49 [_NoiseTiling]
Float 50 [_NoiseOctavesCount]
Vector 51 [_CloudPosition]
Vector 52 [_FrequencyFactor]
Vector 53 [_AmplitudeFactor]
Float 54 [_Smoothness]
Float 55 [_NormalAmplitude]
SetTexture 2 [_TexNoise0] 2D
SetTexture 3 [_TexNoise1] 2D
SetTexture 4 [_TexNoise2] 2D
SetTexture 5 [_TexNoise3] 2D
SetTexture 6 [_TexPhaseMie] 2D
Float 56 [_ScatteringCoeff]
Vector 57 [_CloudColor]
Vector 58 [_ScatteringFactors]
Float 59 [_ScatteringSkyFactor]
Float 60 [_ScatteringTerrainFactor]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[66] = { program.local[0..60],
		{ 0, 0.0099999998, 1, 0.5 },
		{ 2, 3, 4, 2.718282 },
		{ 1000, 0.00390625, 0.079577468, 10 },
		{ 0.12509382, 0.83333331, 0.25 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
TEMP R8;
TEMP R9;
TEMP R10;
TEMP R11;
TEMP R12;
TEMP R13;
TEMP R14;
TEMP R15;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MADR  R2.xy, fragment.texcoord[0], c[28].zwzw, c[28];
COSR  R0.x, R2.y;
MULR  R0.xyz, R0.x, c[17];
SINR  R2.w, R2.y;
SINR  R2.z, R2.x;
MULR  R2.y, R2.w, R2.z;
MADR  R3.xyz, R2.y, c[18], R0;
COSR  R4.x, R2.x;
MULR  R2.w, R2, R4.x;
MOVR  R0.y, c[2].w;
MOVR  R0.x, c[0].w;
MULR  R0.xz, R0.xyyw, c[21].x;
MOVR  R0.y, c[61].x;
ADDR  R2.xyz, R0, -c[16];
MADR  R3.xyz, R2.w, c[19], R3;
DP3R  R4.x, R3, R2;
DP3R  R2.x, R2, R2;
MOVR  R4.y, c[45].x;
ADDR  R2.y, R4, c[20].x;
MADR  R2.x, -R2.y, R2.y, R2;
MULR  R2.w, R4.x, R4.x;
SGER  H0.z, R2.w, R2.x;
MOVR  R2.y, c[61].x;
SLTRC HC.x, R2.w, R2;
MOVR  R2.y(EQ.x), R0.w;
ADDR  R0.w, R2, -R2.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
SLTR  H0.x, -R4, -R0.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[61].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R2.y(NE.x), c[61].x;
SLTR  H0.z, -R4.x, R0.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R2.y(NE.x), -R4.x, R0.w;
MOVX  H0.x(NE), c[61];
MULXC HC.x, H0.y, H0;
ADDR  R2.y(NE.x), -R4.x, -R0.w;
SLERC HC.x, R2.y, c[61].y;
MOVR  oCol, c[61].xxxz;
MOVR  oCol(EQ.x), R1;
SGTRC HC.x, R2.y, c[61].y;
MOVR  R0.w, R2.y;
IF    NE.x;
MADR  R1.xyz, R0.w, R3, R0;
MOVR  R5.xy, c[61].xzzw;
SEQR  H0.xy, c[47].x, R5;
SEQX  H0.zw, H0.xyxy, c[61].x;
MULXC HC.x, H0.z, H0.y;
MOVR  R2.w, c[61].z;
MULR  R2.xyz, R1, c[22].x;
MOVR  R6, c[37];
ADDR  R7.xyz, R1, -c[16];
DP4R  R4.x, R2, c[8];
DP4R  R4.y, R2, c[10];
MADR  R4.xy, R4, c[61].w, c[61].w;
TEX   R4, R4, texture[1], 2D;
MADR  R4, R4, c[38], R6;
MOVR  R6.z, R4.x;
MOVR  R6.z(NE.x), R4.y;
MOVR  R6.w, c[62].x;
SEQR  H0.x, c[47], R6.w;
MULX  H0.y, H0.z, H0.w;
MULXC HC.x, H0.y, H0;
MOVR  R6.z(NE.x), R4;
SEQX  H0.x, H0, c[61];
MULXC HC.x, H0.y, H0;
MOVR  R6.z(NE.x), R4.w;
DP3R  R4.z, R7, c[18];
MOVR  R4.xy, c[51];
DP3R  R4.w, R7, c[19];
MADR  R6.xy, R4.zwzw, c[49].x, R4;
TEX   R4, R6, texture[2], 2D;
MOVR  R5.x, R4.w;
SLTRC HC.x, c[50], R6.w;
MOVR  R5.x(EQ), R5.w;
MOVR  R5.w, R5.x;
MOVR  R5.x, c[45];
ADDR  R7.w, R5.x, c[20].x;
MADR  R5.xyz, R4, c[62].x, -R5.y;
RCPR  R4.x, R7.w;
SGER  H0.x, c[50], R6.w;
MOVXC RC.x, H0;
DP4R  R8.x, R2, c[12];
DP4R  R8.y, R2, c[14];
MADR  R8.xy, R8, c[61].w, c[61].w;
MOVR  R2, c[39];
TEX   R8, R8, texture[0], 2D;
MADR  R2, R8, c[40], R2;
MULR  R4.xyz, R7, R4.x;
IF    NE.x;
MOVR  R6.w, c[62].y;
SLTRC HC.x, c[50], R6.w;
MOVX  H0.y, c[61].x;
MOVX  H0.y(EQ.x), H0.x;
MOVR  R7.xy, c[51].zwzw;
MADR  R6.xy, R6, c[52], R7;
TEX   R7, R6, texture[3], 2D;
MADR  R4.w, R7, c[53].x, R4;
MULR  R5.w(NE.x), R4, c[53].y;
MOVXC RC.x, H0.y;
MOVR  R6.w, c[53].x;
MULR  R7.xyz, R7, c[53].x;
MADR  R7.xyz, R7, c[62].x, -R6.w;
MOVX  H0.x, H0.y;
ADDR  R5.xyz, R5, R7;
IF    NE.x;
MOVR  R7.xy, c[51].zwzw;
MADR  R6.xy, R6, c[52], R7;
TEX   R7, R6, texture[4], 2D;
MULR  R6.w, c[53].x, c[53].x;
MADR  R4.w, R6, R7, R4;
MOVR  R7.w, c[62].z;
SLTRC HC.x, c[50], R7.w;
MOVX  H0.y, c[61].x;
MULR  R7.xyz, R6.w, R7;
MADR  R7.xyz, R7, c[62].x, -R6.w;
MULR  R5.w(NE.x), R4, c[53].z;
MOVX  H0.y(EQ.x), H0.x;
MOVXC RC.x, H0.y;
ADDR  R5.xyz, R5, R7;
IF    NE.x;
MOVR  R7.xy, c[51].zwzw;
MADR  R6.xy, R6, c[52], R7;
MULR  R5.w, R6, c[53].x;
TEX   R7, R6, texture[5], 2D;
MULR  R7.xyz, R7, R5.w;
MADR  R7.xyz, R7, c[62].x, -R5.w;
MADR  R4.w, R7, R5, R4;
ADDR  R5.xyz, R5, R7;
MULR  R5.w, R4, c[53];
ENDIF;
ENDIF;
ENDIF;
ADDR  R7.xyz, R1, -c[16];
DP3R  R4.w, R7, R7;
MULR  R14.xyz, R2.w, c[41];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
ADDR  R4.w, R4, -c[20].x;
MOVR  R15.xyz, c[25];
MOVR  R11.z, c[61];
MOVR  R11.xy, c[55].x;
MULR  R5.xyz, R11, R5;
ADDR  R12.xyz, -R1, c[32];
DP3R  R11.y, R12, R12;
RSQR  R11.y, R11.y;
MULR  R12.xyz, R11.y, R12;
RCPR  R11.y, R11.y;
DP3R  R12.x, R3, R12;
MOVR  R6.x, c[61].z;
SGERC HC.x, R4.w, c[36].w;
MOVR  R6.x(EQ), R1.w;
MOVR  R1.w, R6.x;
MOVR  R6.x, c[45];
ADDR  R6.y, R6.x, c[20].x;
DP3R  R6.x, R5, R5;
RCPR  R6.y, R6.y;
MULR  R7.xyz, R7, R6.y;
RSQR  R6.x, R6.x;
MULR  R5.xyz, R6.x, R5;
MULR  R7.xyz, R5.z, R7;
MADR  R7.xyz, -R5.x, c[18], R7;
MADR  R5.xyz, R5.y, c[19], R7;
DP3R  R11.x, R5, c[24];
DP3R  R6.x, R3, R5;
ADDR  R6.y, R5.w, c[48].x;
MAXR  R5.w, |R6.x|, c[61].y;
MAXR  R5.x, |R11|, c[61].y;
MAXR  R10.x, R11, c[61].y;
ADDR  R6.y, R6, -c[61].w;
MULR_SAT R6.y, R6.z, R6;
MULR  R5.y, R6, R6;
MULR  R5.y, R5, c[46].x;
MULR  R9.z, R5.y, c[63].x;
MULR  R9.w, R9.z, -c[56].x;
RCPR  R5.x, R5.x;
MULR  R5.y, R9.z, R5.x;
RCPR  R5.w, R5.w;
MULR  R5.x, R9.z, R5.w;
MULR  R7.w, R5.x, c[56].x;
MULR  R5.y, R5, -c[56].x;
RCPR  R10.x, R10.x;
MULR  R10.x, R9.z, R10;
MULR  R9.z, R10.x, -c[56].x;
MULR  R10.x, R10, c[58];
SLTRC HC.x, R4.w, c[36].w;
ADDR  R6.y, |R6.x|, -R11.x;
POWR  R5.z, c[62].w, R5.y;
POWR  R6.w, c[62].w, -R7.w;
ADDR  R5.x, R6.w, -R5.z;
MULR  R6.x, R11, R5;
DP3R  R5.x, R3, c[24];
RCPR  R5.y, R6.y;
MULR  R6.x, R6, R5.y;
MOVR_SAT R11.w, -R11.x;
MADR  R5.x, -R5, c[61].w, c[61].w;
MOVR  R5.y, c[61].w;
TEX   R8, R5, texture[6], 2D;
MOVR  R6.z, c[56].x;
MULR  R5.xy, R6.z, c[58].yzzw;
MADR  R9.xy, R8.ywzw, c[63].y, R8.xzzw;
MULR  R5.x, R9, R5;
MULR  R6.z, R5.x, R6.x;
POWR  R10.w, c[62].w, R9.w;
MULR  R8.w, -R9, R10;
MAXR  R7.xyz, R6.z, c[61].x;
MAXR  R6.z, R6.y, c[61].y;
MULR  R6.y, R6.w, R5.z;
MULR  R9.x, R9, c[61].w;
MADR  R10.w, -R9, -R10, -R9;
MULR  R10.w, R10, R11;
MADR  R6.y, -R11.x, -R6, -R11.x;
RCPR  R5.z, R6.z;
MULR  R6.y, R6, R5.z;
MULR  R5.y, R5, c[56].x;
MULR  R6.z, R9.y, R5.y;
MULR  R6.x, R6, R6.z;
MULR  R5.x, R5, R6.y;
MAXR  R8.xyz, R6.x, c[61].x;
MOVR_SAT R6.x, R11;
MULR  R8.w, R8, R6.x;
MULR  R6.x, R6.y, R6.z;
MULR  R9.y, R8.w, c[58].w;
MULR  R9.y, R11.x, R9;
MULR  R11.w, R10, c[58];
MULR  R11.x, -R11, R11.w;
MADR  R11.w, R12.x, c[44].x, R11.z;
RCPR  R13.x, R11.w;
MULR  R11.w, c[44].x, c[44].x;
MADR  R12.w, -R11, R13.x, R13.x;
MOVR  R12.xyz, c[32];
MULR  R12.w, R12, R13.x;
ADDR  R12.xyz, -R12, c[33];
DP3R  R13.x, R12, R12;
ADDR  R12.xyz, -R1, c[29];
RSQR  R13.x, R13.x;
RCPR  R13.x, R13.x;
MULR  R13.x, R13, R12.w;
DP3R  R13.y, R12, R12;
RSQR  R12.w, R13.y;
MULR  R12.xyz, R12.w, R12;
DP3R  R3.y, R3, R12;
MULR  R11.y, R11, c[63].x;
MADR  R3.z, R3.y, c[44].x, R11;
MULR  R3.x, R11.y, R11.y;
RCPR  R3.y, R3.x;
MULR  R3.y, R13.x, R3;
RCPR  R3.x, R3.z;
MADR  R3.z, -R11.w, R3.x, R3.x;
RCPR  R11.w, R12.w;
MULR  R9.y, R5.w, R9;
MULR  R11.x, R5.w, R11;
MULR  R5.w, R9, R5;
MULR  R11.y, R3, c[63].x;
MULR  R11.z, R3, R3.x;
MOVR  R3.xyz, c[29];
ADDR  R3.xyz, -R3, c[30];
DP3R  R3.y, R3, R3;
MULR  R11.w, R11, c[63].x;
MULR  R3.x, R11.w, R11.w;
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
MULR  R3.y, R3, R11.z;
RCPR  R3.x, R3.x;
MULR  R3.y, R3, R3.x;
MINR  R3.x, R11.y, c[61].z;
MULR  R11.y, R3, c[63].x;
POWR  R9.x, R9.x, R7.w;
MULR  R10.x, R10, c[56];
POWR  R9.z, c[62].w, R9.z;
MULR  R9.z, R10.x, R9;
MULR  R10.xyz, R9.z, R9.x;
MULR  R9.x, R9.y, c[63].z;
MINR  R11.y, R11, c[61].z;
MULR  R3.xyz, R3.x, c[34];
MADR  R3.xyz, R11.y, c[31], R3;
MULR  R11.w, R11.x, c[63].z;
MULR  R11.xyz, R7.w, R3;
MULR  R11.xyz, R6.w, R11;
DP3R_SAT R2.w, R4, c[24];
ADDR  R15.xyz, R15, c[23];
MULR  R4.xyz, R14, R15;
MAXR  R5.xyz, R5.x, c[61].x;
MAXR  R6.xyz, R6.x, c[61].x;
MAXR  R9.xyz, R9.x, c[61].x;
MAXR  R3.xyz, R11.w, c[61].x;
MULR  R11.xyz, R11, c[63].w;
POWR  R5.w, c[62].w, R5.w;
MOVR  R13.xyz, R8.w;
MOVR  R12.xyz, R10.w;
MADR  R2.xyz, R4, R2.w, R2;
IF    NE.x;
MOVR  R1.w, c[61].z;
SGERC HC.x, R4.w, c[36].w;
MOVR  R1.w(EQ.x), R3;
SLTRC HC.x, R4.w, c[36].w;
MOVR  R14.w, c[61].z;
MOVR  R14.xyz, R1;
MOVR  R3.w, R1;
DP4R  R4.y, R14, c[5];
DP4R  R4.x, R14, c[4];
IF    NE.x;
MOVR  R14, c[36];
ADDR  R15, -R14, c[35];
ADDR  R14, R4.w, -c[36];
RCPR  R1.w, R15.y;
MULR_SAT R2.w, R14.y, R1;
MULR  R1.w, R2, R2;
MADR  R2.w, -R2, c[62].x, c[62].y;
TEX   R4, R4, texture[7], 2D;
MULR  R2.w, R1, R2;
RCPR  R3.w, R15.x;
MULR_SAT R1.w, R14.x, R3;
MADR  R3.w, -R1, c[62].x, c[62].y;
MULR  R1.w, R1, R1;
MULR  R3.w, R1, R3;
MADR  R2.w, R4.y, R2, -R2;
ADDR  R1.w, R2, c[61].z;
MADR  R2.w, R4.x, R3, -R3;
MADR  R1.w, R2, R1, R1;
RCPR  R3.w, R15.z;
MULR_SAT R3.w, R3, R14.z;
MADR  R4.x, -R3.w, c[62], c[62].y;
RCPR  R2.w, R15.w;
MULR  R3.w, R3, R3;
MULR  R3.w, R3, R4.x;
MULR_SAT R2.w, R2, R14;
MADR  R4.x, -R2.w, c[62], c[62].y;
MADR  R3.w, R4.z, R3, -R3;
MULR  R2.w, R2, R2;
MULR  R2.w, R2, R4.x;
MADR  R1.w, R3, R1, R1;
MADR  R2.w, R4, R2, -R2;
MADR  R3.w, R2, R1, R1;
ENDIF;
MOVR  R1.w, R3;
ENDIF;
ADDR  R4.xyz, R10, R7;
ADDR  R1.xyz, R1, -c[16];
DP3R  R1.y, R1, R1;
ADDR  R4.xyz, R4, R8;
ADDR  R8.xyz, R4, R9;
RSQR  R1.y, R1.y;
RCPR  R1.z, R1.y;
ADDR  R5.xyz, R5, R6;
ADDR  R4.xyz, fragment.texcoord[1], c[26];
MULR  R7.xyz, R13, c[59].x;
MULR  R9.xyz, R7, R4;
MULR  R7.xyz, R1.w, fragment.texcoord[2];
MADR  R8.xyz, R7, R8, R9;
ADDR  R9.xyz, R8, R11;
ADDR  R8.xyz, R0, -c[16];
MULR  R0.xyz, R12, c[60].x;
DP3R  R1.w, R8, R8;
RSQR  R1.w, R1.w;
RCPR  R1.x, R1.w;
ADDR  R1.x, R1, -c[20];
MULR  R1.xy, R1.x, c[64];
ADDR  R1.z, R1, -c[20].x;
MULR  R1.zw, R1.z, c[64].xyxy;
MADR  R0.xyz, R0, R2, R9;
POWR  R1.x, c[62].w, -R1.x;
POWR  R1.y, c[62].w, -R1.y;
POWR  R1.w, c[62].w, -R1.w;
POWR  R1.z, c[62].w, -R1.z;
ADDR  R2.xy, R1, R1.zwzw;
MULR  R2.xy, R2, c[61].w;
MULR  R1.w, R2.y, c[43].x;
MULR  R1.xyz, R12, c[59].x;
MULR  R2.xyz, R2.x, c[42];
MULR  R1.xyz, R4, R1;
ADDR  R3.xyz, R5, R3;
MADR  R1.xyz, R7, R3, R1;
ADDR  R1.xyz, R11, R1;
ADDR  R1.xyz, R0, R1;
MADR  R2.xyz, R2, c[64].z, R1.w;
MULR  R0.xyz, -R2, R0.w;
MULR  R1.xyz, R1, c[57];
POWR  R0.x, c[62].w, R0.x;
POWR  R0.z, c[62].w, R0.z;
POWR  R0.y, c[62].w, R0.y;
MULR  oCol.xyz, R1, R0;
DP3R  oCol.w, R5.w, c[65];
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 16 [_PlanetCenterKm]
Vector 17 [_PlanetNormal]
Vector 18 [_PlanetTangent]
Vector 19 [_PlanetBiTangent]
Float 20 [_PlanetRadiusKm]
Float 21 [_WorldUnit2Kilometer]
Float 22 [_Kilometer2WorldUnit]
Vector 23 [_SunColorFromGround]
Vector 24 [_SunDirection]
Vector 25 [_AmbientSkyFromGround]
Vector 26 [_AmbientNightSky]
Float 27 [_EnvironmentMapPixelSize]
Vector 28 [_EnvironmentAngles]
Vector 29 [_NuajLightningPosition00]
Vector 30 [_NuajLightningPosition01]
Vector 31 [_NuajLightningColor0]
Vector 32 [_NuajLightningPosition10]
Vector 33 [_NuajLightningPosition11]
Vector 34 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 35 [_ShadowAltitudesMinKm]
Vector 36 [_ShadowAltitudesMaxKm]
SetTexture 7 [_TexShadowMap] 2D
Vector 37 [_NuajLocalCoverageOffset]
Vector 38 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 39 [_NuajTerrainEmissiveOffset]
Vector 40 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 41 [_NuajTerrainAlbedo]
Vector 42 [_Sigma_Rayleigh]
Float 43 [_Sigma_Mie]
Float 44 [_MiePhaseAnisotropy]
Float 45 [_CloudAltitudeKm]
Vector 46 [_CloudThicknessKm]
Float 47 [_CloudLayerIndex]
Float 48 [_Coverage]
Float 49 [_NoiseTiling]
Float 50 [_NoiseOctavesCount]
Vector 51 [_CloudPosition]
Vector 52 [_FrequencyFactor]
Vector 53 [_AmplitudeFactor]
Float 54 [_Smoothness]
Float 55 [_NormalAmplitude]
SetTexture 2 [_TexNoise0] 2D
SetTexture 3 [_TexNoise1] 2D
SetTexture 4 [_TexNoise2] 2D
SetTexture 5 [_TexNoise3] 2D
SetTexture 6 [_TexPhaseMie] 2D
Float 56 [_ScatteringCoeff]
Vector 57 [_CloudColor]
Vector 58 [_ScatteringFactors]
Float 59 [_ScatteringSkyFactor]
Float 60 [_ScatteringTerrainFactor]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c61, 0.00000000, 0.15915491, 0.50000000, 1.00000000
def c62, 6.28318501, -3.14159298, -0.01000000, -1.00000000
def c63, -2.00000000, 512.00000000, 2.00000000, -1.00000000
def c64, -3.00000000, -4.00000000, -0.50000000, 1000.00000000
def c65, 0.01000000, 2.71828198, 0.00390625, 0.07957747
def c66, 10.00000000, 2.00000000, 3.00000000, 0.12509382
def c67, 0.21259999, 0.71520001, 0.07220000, 0.83333331
def c68, 0.25000000, 0, 0, 0
dcl_texcoord0 v0.xy
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
mad r1.xy, v0, c28.zwzw, c28
mad r1.z, r1.x, c61.y, c61
mad r1.y, r1, c61, c61.z
frc r1.x, r1.y
frc r1.y, r1.z
mad r1.x, r1, c62, c62.y
sincos r2.xy, r1.x
mad r3.x, r1.y, c62, c62.y
sincos r1.xy, r3.x
mov r1.w, c20.x
mul r1.y, r2, r1
mul r3.xyz, r2.x, c17
mad r3.xyz, r1.y, c18, r3
mul r1.x, r2.y, r1
mad r3.xyz, r1.x, c19, r3
mov r1.y, c2.w
mov r1.x, c0.w
mul r5.xz, r1.xyyw, c21.x
mov r5.y, c61.x
add r1.xyz, r5, -c16
dp3 r2.x, r1, r1
add r1.w, c45.x, r1
dp3 r1.x, r3, r1
mad r1.w, -r1, r1, r2.x
mad r1.y, r1.x, r1.x, -r1.w
rsq r1.z, r1.y
rcp r1.w, r1.z
add r2.x, -r1, r1.w
cmp_pp r1.z, r1.y, c61.w, c61.x
cmp r2.y, r2.x, c61.x, c61.w
mul_pp r2.y, r1.z, r2
cmp_pp r2.z, -r2.y, r1, c61.x
add r1.w, -r1.x, -r1
mul_pp r1.x, r1.z, r2.z
cmp r2.w, r1.y, r5, c61.x
cmp r1.z, r1.w, c61.x, c61.w
mul_pp r1.y, r1.x, r1.z
cmp_pp r1.z, -r1.y, r2, c61.x
cmp r2.y, -r2, r2.w, c61.x
cmp r1.y, -r1, r2, r2.x
mul_pp r1.x, r1, r1.z
cmp r5.w, -r1.x, r1.y, r1
add r1.x, r5.w, c62.z
cmp_pp r1.y, -r1.x, c61.x, c61.w
cmp oC0, -r1.x, c61.xxxw, r0
if_gt r1.y, c61.x
mul r4.xyz, r5.w, r3
add r6.xyz, r5, r4
mov r2.w, c61
mul r2.xyz, r6, c22.x
add r7.xyz, r6, -c16
dp4 r0.z, r2, c8
dp4 r0.w, r2, c10
add r0.zw, r0, c61.w
mul r1.xy, r0.zwzw, c61.z
mov r0.y, c47.x
mov r1.z, c61.x
texldl r1, r1.xyzz, s1
mul r1, r1, c38
add r1, r1, c37
add r0.w, c62, r0.y
abs r0.z, c47.x
cmp r0.y, -r0.z, c61.w, c61.x
abs r0.z, r0.w
cmp r0.w, -r0.z, c61, c61.x
abs_pp r0.y, r0
cmp_pp r0.z, -r0.y, c61.w, c61.x
mul_pp r4.w, r0.z, r0
cmp r1.y, -r4.w, r1.x, r1
mov r0.y, c47.x
add r1.x, c63, r0.y
abs_pp r0.y, r0.w
abs r0.w, r1.x
cmp r1.x, -r0.w, c61.w, c61
cmp_pp r0.y, -r0, c61.w, c61.x
mul_pp r0.y, r0.z, r0
mul_pp r0.z, r0.y, r1.x
cmp r1.y, -r0.z, r1, r1.z
abs_pp r1.x, r1
cmp_pp r1.x, -r1, c61.w, c61
mul_pp r0.y, r0, r1.x
cmp r7.w, -r0.y, r1.y, r1
dp3 r0.y, r4, r4
dp4 r0.w, r2, c14
dp4 r0.z, r2, c12
add r0.zw, r0, c61.w
mul r1.xy, r0.zwzw, c61.z
rsq r0.w, r0.y
mul r4.xyz, r0.w, r4
dp3 r0.y, r4, c17
mov r1.z, c61.x
texldl r1, r1.xyzz, s0
mul r2, r1, c40
abs r0.y, r0
rcp r1.x, r0.y
mov r0.y, c49.x
mul r1.y, c63, r0
rcp r0.w, r0.w
mul r0.y, r0.w, c27.x
rcp r0.w, r1.y
mul r0.y, r0, r1.x
mul r0.y, r0, r0.w
log r0.y, r0.y
dp3 r0.z, r7, c18
dp3 r0.w, r7, c19
mul r0.zw, r0, c49.x
add r8.xy, r0.zwzw, c51
add r8.z, r0.y, c54.x
texldl r1, r8.xyzz, s2
add r4, r2, c39
mov r0.z, c20.x
mov r0.w, c50.x
mad r2.xyz, r1, c63.z, c63.w
add r1.x, c63, r0.w
add r0.z, c45.x, r0
rcp r0.w, r0.z
cmp_pp r0.z, r1.x, c61.w, c61.x
mov r0.y, r1.w
cmp r3.w, r1.x, r3, r1
mul r7.xyz, r7, r0.w
if_gt r0.z, c61.x
mul r1.xy, r8, c52
add r8.xy, r1, c51.zwzw
texldl r1, r8.xyzz, s3
mad r1.xyz, r1, c63.z, c63.w
mov r0.w, c50.x
add r0.w, c64.x, r0
cmp_pp r0.z, r0.w, r0, c61.x
mad r2.xyz, r1, c53.x, r2
mad r0.y, r1.w, c53.x, r0
mul r1.x, r0.y, c53.y
cmp r3.w, r0, r3, r1.x
if_gt r0.z, c61.x
mul r1.xy, r8, c52
add r8.xy, r1, c51.zwzw
texldl r1, r8.xyzz, s4
mul r0.w, c53.x, c53.x
mad r1.xyz, r1, c63.z, c63.w
mad r2.xyz, r0.w, r1, r2
mov r1.x, c50
add r1.x, c64.y, r1
mad r0.y, r0.w, r1.w, r0
mul r1.y, r0, c53.z
cmp_pp r0.z, r1.x, r0, c61.x
cmp r3.w, r1.x, r3, r1.y
if_gt r0.z, c61.x
mul r1.xy, r8, c52
mul r0.z, r0.w, c53.x
mov r1.z, r8
add r1.xy, r1, c51.zwzw
texldl r1, r1.xyzz, s5
mad r1.xyz, r1, c63.z, c63.w
mad r0.y, r0.z, r1.w, r0
mad r2.xyz, r0.z, r1, r2
mul r3.w, r0.y, c53
endif
endif
endif
mov r0.z, c20.x
add r0.z, c45.x, r0
add r14.xyz, -r6, c32
mov r15.xyz, c33
mov r1.z, c61.w
mov r1.xy, c55.x
mul r1.xyz, r1, r2
dp3 r0.y, r1, r1
rsq r1.w, r0.y
rcp r2.x, r0.z
add r0.yzw, r6.xxyz, -c16.xxyz
mul r1.xyz, r1.w, r1
mul r2.xyz, r0.yzww, r2.x
mul r2.xyz, r1.z, r2
mad r2.xyz, -r1.x, c18, r2
mad r1.xyz, r1.y, c19, r2
dp3 r10.w, r1, c24
dp3 r1.w, r3, r1
abs r1.y, r1.w
add r8.z, r1.y, -r10.w
add r1.x, r3.w, c48
max r1.y, r1, c65.x
rcp r3.w, r1.y
add r1.x, r1, c64.z
mul_sat r1.x, r7.w, r1
abs r1.y, r10.w
mul r1.x, r1, r1
mul r1.x, r1, c46
mul r8.x, r1, c64.w
mul r1.x, r8, r3.w
max r1.y, r1, c65.x
rcp r1.y, r1.y
mul r1.y, r8.x, r1
mul r7.w, r1.x, c56.x
mul r2.x, r1.y, -c56
pow r1, c65.y, r2.x
pow r2, c65.y, -r7.w
mov r9.w, r2.x
add r1.y, r9.w, -r1.x
max r1.z, r8, c65.x
mad r1.x, -r9.w, r1, c61.w
mul r11.w, r8.x, -c56.x
rcp r1.z, r1.z
mul r1.x, -r10.w, r1
mul r8.y, r1.x, r1.z
dp3 r1.x, r3, c24
add r1.x, -r1, c61.w
rcp r1.z, r8.z
mul r1.y, r10.w, r1
mul r8.z, r1.y, r1
mov r1.yz, c61.xzxw
mul r1.x, r1, c61.z
texldl r2, r1.xyzz, s6
mad r2.x, r2.y, c65.z, r2
mov r1.w, c58.y
mul r1.x, c56, r1.w
mul r1.x, r2, r1
mul r1.y, r1.x, r8.z
mul r1.x, r1, r8.y
mov r2.y, c58.z
max r9.xyz, r1.y, c61.x
max r10.xyz, r1.x, c61.x
pow r1, c65.y, r11.w
mul r1.y, c56.x, r2
mul r1.y, r1, c56.x
mad r1.z, r2.w, c65, r2
mul r1.z, r1.y, r1
mul r1.w, r8.z, r1.z
mul r1.z, r8.y, r1
mov r1.y, r1.x
mul r1.x, -r11.w, r1.y
mov_sat r2.y, r10.w
add r1.y, -r1, c61.w
mul r1.x, r1, r2.y
mul r8.y, r2.x, c61.z
max r11.xyz, r1.w, c61.x
mul r1.w, r1.x, c58
pow r2, r8.y, r7.w
mul r1.w, r10, r1
max r12.xyz, r1.z, c61.x
mul r1.z, r3.w, r1.w
mul r1.z, r1, c65.w
max r1.w, r10, c65.x
rcp r1.w, r1.w
mul r1.w, r8.x, r1
mul r2.y, r1.w, -c56.x
pow r8, c65.y, r2.y
mul r1.w, r1, c58.x
max r13.xyz, r1.z, c61.x
mov r2.y, r2.x
mov r2.x, r8
mul r1.w, r1, c56.x
mul r1.w, r1, r2.x
mul r8.xyz, r1.w, r2.y
mul r2.y, r11.w, r3.w
mov_sat r1.z, -r10.w
mul r1.y, -r11.w, r1
mul r2.x, r1.y, r1.z
dp3 r1.z, r14, r14
rsq r2.z, r1.z
mul r14.xyz, r2.z, r14
mul r1.y, r2.x, c58.w
mul r1.y, -r10.w, r1
mul r1.y, r3.w, r1
rcp r2.z, r2.z
mul r2.z, r2, c64.w
mul r2.z, r2, r2
dp3 r1.z, r3, r14
mul r1.y, r1, c65.w
max r14.xyz, r1.y, c61.x
mul r1.y, r1.z, c44.x
add r1.z, r1.y, c61.w
mul r1.y, -c44.x, c44.x
rcp r1.z, r1.z
add r2.w, r1.y, c61
mul r1.y, r2.w, r1.z
mul r3.w, r1.y, r1.z
add r1.yzw, -c32.xxyz, r15.xxyz
dp3 r1.z, r1.yzww, r1.yzww
add r15.xyz, -r6, c29
dp3 r1.y, r15, r15
rsq r1.y, r1.y
mul r15.xyz, r1.y, r15
dp3 r1.w, r3, r15
rsq r1.z, r1.z
rcp r1.z, r1.z
mul r1.w, r1, c44.x
add r1.w, r1, c61
mov r3.xyz, c30
mul r1.z, r1, r3.w
rcp r2.z, r2.z
mul r1.z, r1, r2
rcp r1.w, r1.w
mul r2.z, r2.w, r1.w
mul r1.z, r1, c64.w
mul r1.w, r2.z, r1
rcp r1.y, r1.y
mul r2.z, r1.y, c64.w
add r3.xyz, -c29, r3
dp3 r1.y, r3, r3
min r1.z, r1, c61.w
mul r2.z, r2, r2
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r1.y, r1, r1.w
rcp r2.z, r2.z
mul r1.y, r1, r2.z
mul r1.y, r1, c64.w
mul r3.xyz, r1.z, c34
min r1.y, r1, c61.w
mad r15.xyz, r1.y, c31, r3
pow r3, c65.y, r2.y
mul r15.xyz, r7.w, r15
mul r15.xyz, r9.w, r15
mul r1.yzw, r15.xxyz, c66.x
mov r7.w, r3.x
mov r3.xyz, r1.x
dp3 r1.x, r0.yzww, r0.yzww
mov r15.xyz, r2.x
mov r0.yzw, c23.xxyz
rsq r1.x, r1.x
rcp r1.x, r1.x
add r0.yzw, c25.xxyz, r0
mul r2.xyz, r4.w, c41
mul r2.xyz, r2, r0.yzww
dp3_sat r0.y, r7, c24
add r1.x, r1, -c20
add r0.z, r1.x, -c36.w
mad r4.xyz, r2, r0.y, r4
cmp_pp r0.y, r0.z, c61.x, c61.w
cmp r6.w, r0.z, c61, r6
if_gt r0.y, c61.x
add r0.y, r1.x, -c36.w
mov r2.xyz, r6
mov r2.w, c61
dp4 r0.w, r2, c5
dp4 r0.z, r2, c4
cmp_pp r2.x, r0.y, c61, c61.w
cmp r0.x, r0.y, c61.w, r0
if_gt r2.x, c61.x
mov r0.xy, r0.zwzw
mov r0.w, c35.x
add r2.x, -c36, r0.w
rcp r2.y, r2.x
add r2.x, r1, -c36
mul_sat r2.x, r2, r2.y
mul r2.y, r2.x, r2.x
mov r0.z, c61.x
texldl r0, r0.xyzz, s7
add r2.z, r0.x, c62.w
mad r2.x, -r2, c66.y, c66.z
mul r2.x, r2.y, r2
mov r0.x, c35.y
add r0.x, -c36.y, r0
rcp r2.y, r0.x
add r0.x, r1, -c36.y
mul_sat r0.x, r0, r2.y
add r2.y, r0, c62.w
mad r0.y, -r0.x, c66, c66.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2, c61.w
mov r0.x, c35.z
add r2.y, -c36.z, r0.x
mad r2.x, r2, r2.z, c61.w
mul r0.x, r2, r0.y
rcp r2.x, r2.y
add r0.y, r1.x, -c36.z
mul_sat r0.y, r0, r2.x
add r2.y, r0.z, c62.w
mad r2.x, -r0.y, c66.y, c66.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r2.x
mov r0.y, c35.w
add r2.x, -c36.w, r0.y
mad r0.y, r0.z, r2, c61.w
add r0.z, r1.x, -c36.w
rcp r2.x, r2.x
mul_sat r0.z, r0, r2.x
add r1.x, r0.w, c62.w
mad r0.w, -r0.z, c66.y, c66.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.x, c61.w
mul r0.x, r0, r0.y
mul r0.x, r0, r0.z
endif
mov r6.w, r0.x
endif
add r0.xyz, r5, -c16
dp3 r0.x, r0, r0
rsq r0.w, r0.x
rcp r0.w, r0.w
add r1.x, r0.w, -c20
mul r2.w, r1.x, c66
add r0.xyz, r8, r9
add r0.xyz, r0, r11
add r7.xyz, r0, r13
mul r0.xyz, r3, c59.x
add r2.xyz, v1, c26
mul r3.xyz, r0, r2
pow r0, c65.y, -r2.w
mul r5.xyz, r6.w, v2
mad r7.xyz, r5, r7, r3
add r3.xyz, r6, -c16
mov r6.x, r0
dp3 r0.x, r3, r3
rsq r2.w, r0.x
mul r1.x, r1, c67.w
pow r0, c65.y, -r1.x
rcp r0.x, r2.w
add r0.x, r0, -c20
mul r1.x, r0, c66.w
pow r3, c65.y, -r1.x
mov r6.y, r0
mul r2.w, r0.x, c67
pow r0, c65.y, -r2.w
mov r0.x, r3
add r0.xy, r6, r0
mul r6.xy, r0, c61.z
add r3.xyz, r7, r1.yzww
mul r0.xyz, r15, c60.x
mad r0.xyz, r0, r4, r3
mul r4.xyz, r15, c59.x
mul r2.xyz, r2, r4
mul r0.w, r6.y, c43.x
mul r3.xyz, r6.x, c42
add r6.xyz, r10, r12
add r4.xyz, r6, r14
mad r3.xyz, r3, c68.x, r0.w
mad r4.xyz, r5, r4, r2
mul r2.xyz, -r3, r5.w
add r3.xyz, r1.yzww, r4
add r0.xyz, r0, r3
pow r1, c65.y, r2.x
mul r3.xyz, r0, c57
mov r2.x, r1
pow r1, c65.y, r2.z
pow r0, c65.y, r2.y
mov r2.z, r1
mov r2.y, r0
mul oC0.xyz, r3, r2
dp3 oC0.w, r7.w, c67
endif

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #6 computes environment lighting in the Sun's direction (this is simply the cloud rendered into a 1x1 map)
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
MOV   result.texcoord[1].xyz, c[8].x;
MOV   result.texcoord[2].xyz, c[8].x;
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
Vector 8 [_PlanetNormal]
Float 9 [_PlanetRadiusKm]
Float 10 [_PlanetAtmosphereRadiusKm]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 1 [_TexAmbientSky] 2D
Vector 13 [_SoftAmbientSky]
SetTexture 0 [_TexShadowEnvMapSky] 2D
Vector 14 [_Sigma_Rayleigh]
Float 15 [_Sigma_Mie]
SetTexture 2 [_TexDensity] 2D
Float 16 [_CloudAltitudeKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c17, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
mov r0.y, c10.x
add r0.x, -r0, c17.z
add r0.y, -c9.x, r0
rcp r0.y, r0.y
mul r0.x, r0, c17.y
mul r0.y, r0, c16.x
mov r0.z, c17.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c17.w, r1.x
mov r1.x, r0
pow r0, c17.w, r1.z
mov r1.z, r0
pow r2, c17.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c17.yyzx, s1
mov r1.zw, c17.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c17.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c17.x
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
Matrix 0 [_Camera2World]
Vector 16 [_PlanetCenterKm]
Vector 17 [_PlanetNormal]
Vector 18 [_PlanetTangent]
Vector 19 [_PlanetBiTangent]
Float 20 [_PlanetRadiusKm]
Float 21 [_WorldUnit2Kilometer]
Float 22 [_Kilometer2WorldUnit]
Vector 23 [_SunColorFromGround]
Vector 24 [_SunDirection]
Vector 25 [_AmbientSkyFromGround]
Vector 26 [_AmbientNightSky]
Float 27 [_EnvironmentMapPixelSize]
Vector 28 [_NuajLightningPosition00]
Vector 29 [_NuajLightningPosition01]
Vector 30 [_NuajLightningColor0]
Vector 31 [_NuajLightningPosition10]
Vector 32 [_NuajLightningPosition11]
Vector 33 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 34 [_ShadowAltitudesMinKm]
Vector 35 [_ShadowAltitudesMaxKm]
SetTexture 7 [_TexShadowMap] 2D
Vector 36 [_NuajLocalCoverageOffset]
Vector 37 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 38 [_NuajTerrainEmissiveOffset]
Vector 39 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 40 [_NuajTerrainAlbedo]
Vector 41 [_Sigma_Rayleigh]
Float 42 [_Sigma_Mie]
Float 43 [_MiePhaseAnisotropy]
Float 44 [_CloudAltitudeKm]
Vector 45 [_CloudThicknessKm]
Float 46 [_CloudLayerIndex]
Float 47 [_Coverage]
Float 48 [_NoiseTiling]
Float 49 [_NoiseOctavesCount]
Vector 50 [_CloudPosition]
Vector 51 [_FrequencyFactor]
Vector 52 [_AmplitudeFactor]
Float 53 [_Smoothness]
Float 54 [_NormalAmplitude]
SetTexture 2 [_TexNoise0] 2D
SetTexture 3 [_TexNoise1] 2D
SetTexture 4 [_TexNoise2] 2D
SetTexture 5 [_TexNoise3] 2D
SetTexture 6 [_TexPhaseMie] 2D
Float 55 [_ScatteringCoeff]
Vector 56 [_CloudColor]
Vector 57 [_ScatteringFactors]
Float 58 [_ScatteringSkyFactor]
Float 59 [_ScatteringTerrainFactor]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[65] = { program.local[0..59],
		{ 0, 0.0099999998, 1, 0.5 },
		{ 2, 3, 4, 2.718282 },
		{ 1000, 0.00390625, 0.079577468, 10 },
		{ 0.12509382, 0.83333331, 0.25 },
		{ 0.21259999, 0.71520001, 0.0722 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
TEMP R8;
TEMP R9;
TEMP R10;
TEMP R11;
TEMP R12;
TEMP R13;
TEMP R14;
TEMP R15;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R1.y, c[2].w;
MOVR  R1.x, c[0].w;
MULR  R3.xz, R1.xyyw, c[21].x;
MOVR  R3.y, c[60].x;
ADDR  R1.xyz, R3, -c[16];
DP3R  R2.x, R1, c[24];
DP3R  R1.x, R1, R1;
MOVR  R1.w, c[44].x;
ADDR  R1.y, R1.w, c[20].x;
MADR  R1.y, -R1, R1, R1.x;
MULR  R2.y, R2.x, R2.x;
SGER  H0.z, R2.y, R1.y;
ADDR  R1.z, R2.y, -R1.y;
RSQR  R1.z, R1.z;
RCPR  R1.z, R1.z;
MOVR  R1.x, c[60];
SLTRC HC.x, R2.y, R1.y;
MOVR  R1.x(EQ), R3.w;
SLTR  H0.x, -R2, -R1.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[60].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.x(NE), c[60];
SLTR  H0.z, -R2.x, R1;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.x(NE), -R2, R1.z;
MOVX  H0.x(NE), c[60];
MULXC HC.x, H0.y, H0;
ADDR  R1.x(NE), -R2, -R1.z;
SLERC HC.x, R1, c[60].y;
MOVR  oCol, c[60].xxxz;
MOVR  oCol(EQ.x), R0;
SGTRC HC.x, R1, c[60].y;
MOVR  R3.w, R1.x;
IF    NE.x;
MOVR  R5.zw, c[60].xyxz;
SEQR  H0.xy, c[46].x, R5.zwzw;
MADR  R4.xyz, R3.w, c[24], R3;
SEQX  H0.zw, H0.xyxy, c[60].x;
MULXC HC.x, H0.z, H0.y;
MOVR  R8.x, c[61];
MOVR  R2.w, c[60].z;
MULR  R2.xyz, R4, c[22].x;
MOVR  R1, c[36];
ADDR  R5.xyz, R4, -c[16];
DP4R  R0.x, R2, c[8];
DP4R  R0.y, R2, c[10];
MADR  R0.xy, R0, c[60].w, c[60].w;
TEX   R0, R0, texture[1], 2D;
MADR  R0, R0, c[37], R1;
MOVR  R7.w, R0.x;
MOVR  R7.w(NE.x), R0.y;
SEQR  H0.x, c[46], R8;
MULX  H0.y, H0.z, H0.w;
MULXC HC.x, H0.y, H0;
MOVR  R7.w(NE.x), R0.z;
SEQX  H0.x, H0, c[60];
MULXC HC.x, H0.y, H0;
MOVR  R7.w(NE.x), R0;
DP3R  R0.x, R5, c[18];
MOVR  R0.zw, c[50].xyxy;
DP3R  R0.y, R5, c[19];
MADR  R7.xy, R0, c[48].x, R0.zwzw;
TEX   R0, R7, texture[2], 2D;
MOVR  R1.x, R0.w;
SLTRC HC.x, c[49], R8;
MOVR  R1.x(EQ), R7.z;
MOVR  R7.z, R1.x;
SGER  H0.x, c[49], R8;
MOVXC RC.x, H0;
DP4R  R1.x, R2, c[12];
DP4R  R1.y, R2, c[14];
MADR  R1.xy, R1, c[60].w, c[60].w;
MOVR  R2, c[38];
TEX   R1, R1, texture[0], 2D;
MADR  R1, R1, c[39], R2;
MOVR  R2.x, c[44];
MOVR  R2.w, R0;
ADDR  R0.w, R2.x, c[20].x;
MADR  R6.xyz, R0, c[61].x, -R5.w;
RCPR  R0.x, R0.w;
MULR  R2.xyz, R5, R0.x;
IF    NE.x;
MOVR  R0.x, c[61].y;
SLTRC HC.x, c[49], R0;
MOVX  H0.y, c[60].x;
MOVX  H0.y(EQ.x), H0.x;
MOVR  R0.xy, c[50].zwzw;
MADR  R7.xy, R7, c[51], R0;
TEX   R0, R7, texture[3], 2D;
MADR  R2.w, R0, c[52].x, R2;
MULR  R7.z(NE.x), R2.w, c[52].y;
MOVXC RC.x, H0.y;
MOVR  R0.w, c[52].x;
MULR  R0.xyz, R0, c[52].x;
MADR  R0.xyz, R0, c[61].x, -R0.w;
MOVX  H0.x, H0.y;
ADDR  R6.xyz, R6, R0;
IF    NE.x;
MOVR  R0.xy, c[50].zwzw;
MADR  R7.xy, R7, c[51], R0;
TEX   R0, R7, texture[4], 2D;
MULR  R5.x, c[52], c[52];
MADR  R2.w, R5.x, R0, R2;
MOVR  R0.w, c[61].z;
SLTRC HC.x, c[49], R0.w;
MOVX  H0.y, c[60].x;
MULR  R0.xyz, R5.x, R0;
MADR  R0.xyz, R0, c[61].x, -R5.x;
MULR  R7.z(NE.x), R2.w, c[52];
MOVX  H0.y(EQ.x), H0.x;
MOVXC RC.x, H0.y;
ADDR  R6.xyz, R6, R0;
IF    NE.x;
MOVR  R0.xy, c[50].zwzw;
MADR  R0.xy, R7, c[51], R0;
MULR  R5.x, R5, c[52];
TEX   R0, R0, texture[5], 2D;
MULR  R0.xyz, R0, R5.x;
MADR  R0.xyz, R0, c[61].x, -R5.x;
MADR  R0.w, R0, R5.x, R2;
ADDR  R6.xyz, R6, R0;
MULR  R7.z, R0.w, c[52].w;
ENDIF;
ENDIF;
ENDIF;
ADDR  R0.xyz, R4, -c[16];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.w, R0, -c[20].x;
MOVR  R5.z, c[60];
MOVR  R5.xy, c[54].x;
MULR  R6.xyz, R5, R6;
MOVR  R0.w, c[60].z;
SGERC HC.x, R2.w, c[35].w;
MOVR  R0.w(EQ.x), R4;
MOVR  R4.w, R0;
MOVR  R0.w, c[44].x;
ADDR  R5.x, R0.w, c[20];
DP3R  R0.w, R6, R6;
RCPR  R5.x, R5.x;
RSQR  R0.w, R0.w;
MULR  R6.xyz, R0.w, R6;
MULR  R0.xyz, R0, R5.x;
MULR  R0.xyz, R6.z, R0;
MADR  R0.xyz, -R6.x, c[18], R0;
MADR  R0.xyz, R6.y, c[19], R0;
DP3R  R6.z, R0, c[24];
MAXR  R0.x, |R6.z|, c[60].y;
RCPR  R5.x, R0.x;
ADDR  R0.w, R7.z, c[47].x;
ADDR  R0.w, R0, -c[60];
MULR_SAT R0.y, R7.w, R0.w;
MULR  R0.z, R0.y, R0.y;
MAXR  R0.y, R6.z, c[60];
MULR  R0.z, R0, c[45].x;
MULR  R5.y, R0.z, c[62].x;
MULR  R6.x, R5.y, R5;
MULR  R6.y, R6.x, c[55].x;
RCPR  R0.y, R0.y;
MULR  R5.w, R5.y, R0.y;
DP3R  R0.x, c[24], c[24];
SLTRC HC.x, R2.w, c[35].w;
POWR  R6.x, c[61].w, -R6.y;
MULR  R15.xyz, R1.w, c[40];
MOVR  R0.y, c[60].w;
MADR  R0.x, -R0, c[60].w, c[60].w;
TEX   R0, R0, texture[6], 2D;
MADR  R0.zw, R0.xyyw, c[62].y, R0.xyxz;
MULR  R0.x, R0.z, c[60].w;
POWR  R0.y, R0.x, R6.y;
MULR  R0.x, R5.w, -c[55];
MULR  R5.w, R5, c[57].x;
MULR  R5.w, R5, c[55].x;
POWR  R0.x, c[61].w, R0.x;
MULR  R0.x, R5.w, R0;
MULR  R12.xyz, R0.x, R0.y;
MULR  R0.y, R6.x, R6.x;
ADDR  R0.x, -R6.z, |R6.z|;
MADR  R5.w, -R6.z, -R0.y, -R6.z;
MAXR  R0.x, R0, c[60].y;
RCPR  R0.y, R0.x;
MULR  R7.x, R5.w, R0.y;
ADDR  R0.x, R6, -R6;
MULR  R7.y, R6.z, R0.x;
ADDR  R0.y, |R6.z|, -R6.z;
RCPR  R5.w, R0.y;
MULR  R7.z, R7.y, R5.w;
MULR  R5.w, R5.y, -c[55].x;
MOVR  R0.x, c[55];
MULR  R0.xy, R0.x, c[57].yzzw;
MULR  R0.x, R0.z, R0;
MULR  R0.z, R0.x, R7;
MULR  R0.x, R0, R7;
MAXR  R11.xyz, R0.z, c[60].x;
MAXR  R14.xyz, R0.x, c[60].x;
MULR  R0.x, R0.y, c[55];
POWR  R7.y, c[61].w, R5.w;
MULR  R0.y, -R5.w, R7;
MOVR_SAT R0.z, R6;
MULR  R5.y, R0, R0.z;
MULR  R0.x, R0.w, R0;
MULR  R0.z, R7, R0.x;
MULR  R0.y, R5, c[57].w;
MAXR  R10.xyz, R0.z, c[60].x;
MULR  R0.z, R7.x, R0.x;
MULR  R0.y, R6.z, R0;
MULR  R0.x, R5, R0.y;
MULR  R0.w, R0.x, c[62].z;
MAXR  R13.xyz, R0.z, c[60].x;
ADDR  R0.xyz, -R4, c[31];
DP3R  R7.x, R0, R0;
RSQR  R7.x, R7.x;
MULR  R0.xyz, R7.x, R0;
DP3R  R0.x, R0, c[24];
MADR  R0.x, R0, c[43], R5.z;
MAXR  R9.xyz, R0.w, c[60].x;
RCPR  R7.x, R7.x;
MADR  R7.y, -R5.w, -R7, -R5.w;
MOVR_SAT R0.w, -R6.z;
MULR  R0.w, R7.y, R0;
MULR  R7.y, R0.w, c[57].w;
MULR  R0.y, -R6.z, R7;
MULR  R6.z, R5.x, R0.y;
RCPR  R7.z, R0.x;
MULR  R7.y, c[43].x, c[43].x;
MADR  R7.w, -R7.y, R7.z, R7.z;
MULR  R5.x, R5.w, R5;
MOVR  R0.xyz, c[31];
MULR  R7.z, R7.w, R7;
ADDR  R0.xyz, -R0, c[32];
DP3R  R7.w, R0, R0;
ADDR  R0.xyz, -R4, c[28];
RSQR  R7.w, R7.w;
RCPR  R7.w, R7.w;
DP3R  R8.x, R0, R0;
MULR  R7.w, R7, R7.z;
RSQR  R7.z, R8.x;
MULR  R0.xyz, R7.z, R0;
DP3R  R0.x, R0, c[24];
MADR  R0.x, R0, c[43], R5.z;
MULR  R7.x, R7, c[62];
MULR  R0.y, R7.x, R7.x;
RCPR  R0.y, R0.y;
MULR  R0.z, R7.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R7, R0.x, R0.x;
RCPR  R7.y, R7.z;
MULR  R7.x, R0.z, c[62];
MULR  R5.z, R0.y, R0.x;
MOVR  R0.xyz, c[28];
ADDR  R0.xyz, -R0, c[29];
DP3R  R0.x, R0, R0;
MULR  R7.y, R7, c[62].x;
MULR  R0.y, R7, R7;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R5.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R5.z, R0.x, c[62].x;
MINR  R0.y, R7.x, c[60].z;
MINR  R5.z, R5, c[60];
MULR  R0.xyz, R0.y, c[33];
MADR  R0.xyz, R5.z, c[30], R0;
MULR  R5.z, R6, c[62];
MULR  R0.xyz, R6.y, R0;
MULR  R0.xyz, R6.x, R0;
MULR  R7.xyz, R0, c[62].w;
MOVR  R6.xyz, R0.w;
MOVR  R0.xyz, c[25];
ADDR  R0.xyz, R0, c[23];
MAXR  R8.xyz, R5.z, c[60].x;
POWR  R5.w, c[61].w, R5.x;
DP3R_SAT R0.w, R2, c[24];
MULR  R0.xyz, R15, R0;
MOVR  R5.xyz, R5.y;
MADR  R15.xyz, R0, R0.w, R1;
IF    NE.x;
MOVR  R0.x, c[60].z;
SGERC HC.x, R2.w, c[35].w;
MOVR  R0.x(EQ), R6.w;
MOVR  R6.w, R0.x;
SLTRC HC.x, R2.w, c[35].w;
MOVR  R0.w, c[60].z;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[35];
ADDR  R0, -R0, c[34];
ADDR  R1, R2.w, -c[35];
RCPR  R0.y, R0.y;
MULR_SAT R0.y, R1, R0;
MULR  R2.z, R0.y, R0.y;
MADR  R1.y, -R0, c[61].x, c[61];
RCPR  R0.y, R0.x;
MULR  R0.x, R2.z, R1.y;
TEX   R2, R2, texture[7], 2D;
MULR_SAT R0.y, R1.x, R0;
MADR  R1.x, R2.y, R0, -R0;
MADR  R0.x, -R0.y, c[61], c[61].y;
MULR  R0.y, R0, R0;
MULR  R0.x, R0.y, R0;
ADDR  R0.y, R1.x, c[60].z;
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R0.y, R0.y;
RCPR  R0.y, R0.z;
RCPR  R0.z, R0.w;
MULR_SAT R0.w, R0.z, R1;
MULR_SAT R0.y, R0, R1.z;
MADR  R0.z, -R0.y, c[61].x, c[61].y;
MULR  R0.y, R0, R0;
MULR  R0.z, R0.y, R0;
MADR  R0.y, -R0.w, c[61].x, c[61];
MULR  R0.w, R0, R0;
MULR  R0.y, R0.w, R0;
MADR  R0.z, R2, R0, -R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R6.w, R0.y, R0.x, R0.x;
ENDIF;
MOVR  R4.w, R6;
ENDIF;
MULR  R2.xyz, R5, c[58].x;
ADDR  R1.xyz, fragment.texcoord[1], c[26];
ADDR  R3.xyz, R3, -c[16];
DP3R  R0.w, R3, R3;
ADDR  R0.xyz, R12, R11;
ADDR  R0.xyz, R0, R10;
RSQR  R0.w, R0.w;
MULR  R2.xyz, R2, R1;
MULR  R5.xyz, R4.w, fragment.texcoord[2];
ADDR  R0.xyz, R0, R9;
MADR  R0.xyz, R5, R0, R2;
MULR  R2.xyz, R6, c[59].x;
ADDR  R0.xyz, R0, R7;
MADR  R0.xyz, R2, R15, R0;
ADDR  R2.xyz, R4, -c[16];
DP3R  R1.w, R2, R2;
RCPR  R0.w, R0.w;
ADDR  R2.x, R0.w, -c[20];
MULR  R2.zw, R2.x, c[63].xyxy;
RSQR  R1.w, R1.w;
RCPR  R0.w, R1.w;
ADDR  R0.w, R0, -c[20].x;
MULR  R2.xy, R0.w, c[63];
POWR  R2.z, c[61].w, -R2.z;
POWR  R2.y, c[61].w, -R2.y;
POWR  R2.x, c[61].w, -R2.x;
POWR  R2.w, c[61].w, -R2.w;
ADDR  R4.xy, R2.zwzw, R2;
MULR  R2.xyz, R6, c[58].x;
MULR  R1.xyz, R1, R2;
ADDR  R3.xyz, R14, R13;
ADDR  R2.xyz, R3, R8;
MADR  R1.xyz, R5, R2, R1;
MULR  R3.xy, R4, c[60].w;
ADDR  R2.xyz, R7, R1;
ADDR  R0.xyz, R0, R2;
MULR  R0.w, R3.y, c[42].x;
MULR  R1.xyz, R3.x, c[41];
MADR  R1.xyz, R1, c[63].z, R0.w;
MULR  R1.xyz, -R1, R3.w;
MULR  R0.xyz, R0, c[56];
POWR  R1.x, c[61].w, R1.x;
POWR  R1.z, c[61].w, R1.z;
POWR  R1.y, c[61].w, R1.y;
MULR  oCol.xyz, R0, R1;
DP3R  oCol.w, R5.w, c[64];
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 16 [_PlanetCenterKm]
Vector 17 [_PlanetNormal]
Vector 18 [_PlanetTangent]
Vector 19 [_PlanetBiTangent]
Float 20 [_PlanetRadiusKm]
Float 21 [_WorldUnit2Kilometer]
Float 22 [_Kilometer2WorldUnit]
Vector 23 [_SunColorFromGround]
Vector 24 [_SunDirection]
Vector 25 [_AmbientSkyFromGround]
Vector 26 [_AmbientNightSky]
Float 27 [_EnvironmentMapPixelSize]
Vector 28 [_NuajLightningPosition00]
Vector 29 [_NuajLightningPosition01]
Vector 30 [_NuajLightningColor0]
Vector 31 [_NuajLightningPosition10]
Vector 32 [_NuajLightningPosition11]
Vector 33 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 34 [_ShadowAltitudesMinKm]
Vector 35 [_ShadowAltitudesMaxKm]
SetTexture 7 [_TexShadowMap] 2D
Vector 36 [_NuajLocalCoverageOffset]
Vector 37 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 38 [_NuajTerrainEmissiveOffset]
Vector 39 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 40 [_NuajTerrainAlbedo]
Vector 41 [_Sigma_Rayleigh]
Float 42 [_Sigma_Mie]
Float 43 [_MiePhaseAnisotropy]
Float 44 [_CloudAltitudeKm]
Vector 45 [_CloudThicknessKm]
Float 46 [_CloudLayerIndex]
Float 47 [_Coverage]
Float 48 [_NoiseTiling]
Float 49 [_NoiseOctavesCount]
Vector 50 [_CloudPosition]
Vector 51 [_FrequencyFactor]
Vector 52 [_AmplitudeFactor]
Float 53 [_Smoothness]
Float 54 [_NormalAmplitude]
SetTexture 2 [_TexNoise0] 2D
SetTexture 3 [_TexNoise1] 2D
SetTexture 4 [_TexNoise2] 2D
SetTexture 5 [_TexNoise3] 2D
SetTexture 6 [_TexPhaseMie] 2D
Float 55 [_ScatteringCoeff]
Vector 56 [_CloudColor]
Vector 57 [_ScatteringFactors]
Float 58 [_ScatteringSkyFactor]
Float 59 [_ScatteringTerrainFactor]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c60, 0.00000000, 1.00000000, -0.01000000, 0.50000000
def c61, -1.00000000, -2.00000000, 512.00000000, 2.00000000
def c62, -3.00000000, -4.00000000, -0.50000000, 1000.00000000
def c63, 0.01000000, 2.71828198, 0.00390625, 0.07957747
def c64, 10.00000000, 2.00000000, 3.00000000, 0.12509382
def c65, 0.21259999, 0.71520001, 0.07220000, 0.83333331
def c66, 0.25000000, 0, 0, 0
dcl_texcoord1 v0.xyz
dcl_texcoord2 v1.xyz
mov r1.w, c20.x
mov r1.y, c2.w
mov r1.x, c0.w
mul r5.xz, r1.xyyw, c21.x
mov r5.y, c60.x
add r1.xyz, r5, -c16
dp3 r2.x, r1, r1
add r1.w, c44.x, r1
dp3 r1.x, r1, c24
mad r1.w, -r1, r1, r2.x
mad r1.y, r1.x, r1.x, -r1.w
rsq r1.z, r1.y
rcp r1.w, r1.z
add r2.x, -r1, r1.w
cmp_pp r1.z, r1.y, c60.y, c60.x
cmp r2.y, r2.x, c60.x, c60
mul_pp r2.y, r1.z, r2
cmp_pp r2.z, -r2.y, r1, c60.x
add r1.w, -r1.x, -r1
mul_pp r1.x, r1.z, r2.z
cmp r2.w, r1.y, r5, c60.x
cmp r1.z, r1.w, c60.x, c60.y
mul_pp r1.y, r1.x, r1.z
cmp_pp r1.z, -r1.y, r2, c60.x
cmp r2.y, -r2, r2.w, c60.x
cmp r1.y, -r1, r2, r2.x
mul_pp r1.x, r1, r1.z
cmp r5.w, -r1.x, r1.y, r1
add r1.x, r5.w, c60.z
cmp_pp r1.y, -r1.x, c60.x, c60
cmp oC0, -r1.x, c60.xxxy, r0
if_gt r1.y, c60.x
mul r3.xyz, r5.w, c24
add r6.xyz, r5, r3
mov r2.w, c60.y
mul r2.xyz, r6, c22.x
dp4 r0.z, r2, c8
dp4 r0.w, r2, c10
add r0.zw, r0, c60.y
mul r1.xy, r0.zwzw, c60.w
mov r0.z, c46.x
mov r1.z, c60.x
texldl r1, r1.xyzz, s1
mul r1, r1, c37
add r1, r1, c36
add r3.w, c61.x, r0.z
abs r0.w, c46.x
cmp r0.z, -r0.w, c60.y, c60.x
abs r0.w, r3
cmp r3.w, -r0, c60.y, c60.x
abs_pp r0.z, r0
cmp_pp r0.w, -r0.z, c60.y, c60.x
mul_pp r4.x, r0.w, r3.w
cmp r1.y, -r4.x, r1.x, r1
mov r0.z, c46.x
add r1.x, c61.y, r0.z
abs_pp r0.z, r3.w
cmp_pp r0.z, -r0, c60.y, c60.x
mul_pp r3.w, r0, r0.z
abs r1.x, r1
cmp r1.x, -r1, c60.y, c60
mul_pp r0.z, r3.w, r1.x
cmp r4.x, -r0.z, r1.y, r1.z
abs_pp r1.x, r1
dp4 r0.w, r2, c14
dp4 r0.z, r2, c12
cmp_pp r1.z, -r1.x, c60.y, c60.x
add r1.xy, r0.zwzw, c60.y
mul_pp r0.z, r3.w, r1
dp3 r0.w, r3, r3
rsq r2.w, r0.w
mul r2.xyz, r2.w, r3
dp3 r0.w, r2, c17
add r7.xyz, r6, -c16
cmp r0.z, -r0, r4.x, r1.w
abs r0.w, r0
mul r1.xy, r1, c60.w
mov r1.z, c60.x
texldl r1, r1.xyzz, s0
mul r3, r1, c39
rcp r1.z, r0.w
mov r0.w, c48.x
rcp r1.y, r2.w
mul r1.w, c61.z, r0
mul r0.w, r1.y, c27.x
rcp r1.y, r1.w
mul r0.w, r0, r1.z
mul r0.w, r0, r1.y
log r0.w, r0.w
dp3 r1.x, r7, c18
dp3 r1.y, r7, c19
mul r1.xy, r1, c48.x
add r2.z, r0.w, c53.x
add r2.xy, r1, c50
texldl r1, r2.xyzz, s2
add r4, r3, c38
mad r3.xyz, r1, c61.w, c61.x
mov r1.y, c49.x
add r1.y, c61, r1
mov r1.x, c20
add r1.x, c44, r1
rcp r1.x, r1.x
cmp_pp r2.w, r1.y, c60.y, c60.x
mov r0.w, r1
cmp r0.y, r1, r0, r1.w
mul r7.xyz, r7, r1.x
if_gt r2.w, c60.x
mul r1.xy, r2, c51
add r2.xy, r1, c50.zwzw
texldl r1, r2.xyzz, s3
mad r1.xyz, r1, c61.w, c61.x
mad r3.xyz, r1, c52.x, r3
mov r1.x, c49
add r1.x, c62, r1
mad r0.w, r1, c52.x, r0
mul r1.y, r0.w, c52
cmp_pp r2.w, r1.x, r2, c60.x
cmp r0.y, r1.x, r0, r1
if_gt r2.w, c60.x
mul r1.xy, r2, c51
add r2.xy, r1, c50.zwzw
texldl r1, r2.xyzz, s4
mul r3.w, c52.x, c52.x
mad r1.xyz, r1, c61.w, c61.x
mad r3.xyz, r3.w, r1, r3
mov r1.x, c49
add r1.x, c62.y, r1
mad r0.w, r3, r1, r0
mul r1.y, r0.w, c52.z
cmp_pp r1.z, r1.x, r2.w, c60.x
cmp r0.y, r1.x, r0, r1
if_gt r1.z, c60.x
mul r1.xy, r2, c51
mul r0.y, r3.w, c52.x
mov r1.z, r2
add r1.xy, r1, c50.zwzw
texldl r1, r1.xyzz, s5
mad r1.xyz, r1, c61.w, c61.x
mad r0.w, r0.y, r1, r0
mad r3.xyz, r0.y, r1, r3
mul r0.y, r0.w, c52.w
endif
endif
endif
mov r1.xy, c54.x
mov r1.z, c60.y
mul r2.xyz, r1, r3
dp3 r0.w, r2, r2
rsq r0.w, r0.w
mov r1.x, c20
add r1.x, c44, r1
mul r2.xyz, r0.w, r2
add r0.y, r0, c47.x
add r0.w, r0.y, c62.z
mul_sat r0.z, r0, r0.w
mul r0.z, r0, r0
mul r0.z, r0, c45.x
mul r0.z, r0, c62.w
mul r10.w, r0.z, -c55.x
add r1.yzw, r6.xxyz, -c16.xxyz
rcp r1.x, r1.x
mul r3.xyz, r1.yzww, r1.x
dp3 r1.w, r1.yzww, r1.yzww
mul r3.xyz, r2.z, r3
mad r3.xyz, -r2.x, c18, r3
mad r2.xyz, r2.y, c19, r3
dp3 r0.y, r2, c24
abs r0.w, r0.y
max r1.x, r0.w, c63
rcp r9.w, r1.x
mul r1.x, r0.z, r9.w
mul r8.w, r1.x, c55.x
pow r2, c63.y, -r8.w
rsq r1.w, r1.w
mov r7.w, r2.x
add r1.x, r0.w, -r0.y
max r2.x, r1, c63
mad r0.w, -r7, r7, c60.y
mul r0.w, -r0.y, r0
rcp r2.x, r2.x
mul r8.x, r0.w, r2
add r0.w, r7, -r7
rcp r1.x, r1.x
mul r0.w, r0.y, r0
mul r0.w, r0, r1.x
dp3 r1.x, c24, c24
add r1.x, -r1, c60.y
mul r2.x, r1, c60.w
mov r2.yz, c60.xwxw
texldl r3, r2.xyzz, s6
mov r2.w, c57.y
mad r3.x, r3.y, c63.z, r3
mul r1.x, c55, r2.w
mul r1.x, r3, r1
mul r2.x, r1, r0.w
mul r1.x, r1, r8
max r9.xyz, r2.x, c60.x
pow r2, c63.y, r10.w
max r10.xyz, r1.x, c60.x
mov r1.x, c57.z
mul r1.x, c55, r1
mad r2.y, r3.w, c63.z, r3.z
mul r1.x, r1, c55
mul r2.y, r1.x, r2
mul r2.z, r0.w, r2.y
mov r0.w, r2.x
mov_sat r2.x, r0.y
mul r1.x, -r10.w, r0.w
mul r1.x, r1, r2
mul r2.x, r8, r2.y
max r11.xyz, r2.z, c60.x
mul r2.z, r1.x, c57.w
mul r2.y, r0, r2.z
mul r2.y, r9.w, r2
mul r11.w, r2.y, c63
max r12.xyz, r2.x, c60.x
max r2.x, r0.y, c63
rcp r2.x, r2.x
mul r0.z, r0, r2.x
mul r3.x, r3, c60.w
pow r2, r3.x, r8.w
mul r2.y, r0.z, -c55.x
pow r3, c63.y, r2.y
mul r0.z, r0, c57.x
mov r2.y, r2.x
mov r2.x, r3
mul r0.z, r0, c55.x
mul r0.z, r0, r2.x
mul r8.xyz, r0.z, r2.y
add r0.z, -r0.w, c60.y
mov_sat r0.w, -r0.y
mul r0.z, -r10.w, r0
mul r2.x, r0.z, r0.w
mul r0.z, r2.x, c57.w
mul r0.y, -r0, r0.z
add r3.xyz, -r6, c31
dp3 r0.w, r3, r3
rsq r2.z, r0.w
mul r3.xyz, r2.z, r3
dp3 r2.y, r3, c24
mul r2.w, r2.y, c43.x
add r3.x, r2.w, c60.y
rcp r3.w, r3.x
mul r0.y, r9.w, r0
mov r3.xyz, c32
add r14.xyz, -c31, r3
mul r2.y, r10.w, r9.w
dp3 r10.w, r14, r14
mul r0.y, r0, c63.w
mul r2.w, -c43.x, c43.x
add r2.w, r2, c60.y
mul r9.w, r2, r3
rsq r10.w, r10.w
mul r9.w, r9, r3
add r3.xyz, -r6, c28
dp3 r3.w, r3, r3
rsq r3.w, r3.w
mul r3.xyz, r3.w, r3
rcp r10.w, r10.w
mul r9.w, r10, r9
rcp r10.w, r2.z
dp3 r2.z, r3, c24
mul r3.x, r10.w, c62.w
mul r2.z, r2, c43.x
mul r3.x, r3, r3
rcp r3.x, r3.x
add r2.z, r2, c60.y
rcp r3.w, r3.w
mul r3.y, r9.w, r3.x
rcp r2.z, r2.z
mul r3.x, r2.w, r2.z
mul r2.w, r3.y, c62
mul r2.z, r3.x, r2
mov r3.xyz, c29
add r3.xyz, -c28, r3
dp3 r3.x, r3, r3
mul r3.w, r3, c62
mul r3.y, r3.w, r3.w
rsq r3.x, r3.x
rcp r3.x, r3.x
rcp r3.y, r3.y
mul r2.z, r3.x, r2
mul r2.z, r2, r3.y
min r2.w, r2, c60.y
mul r2.z, r2, c62.w
mul r3.xyz, r2.w, c33
min r2.z, r2, c60.y
mad r14.xyz, r2.z, c30, r3
pow r3, c63.y, r2.y
mul r14.xyz, r8.w, r14
mul r14.xyz, r7.w, r14
mul r2.yzw, r14.xxyz, c64.x
mov r7.w, r3.x
mov r3.xyz, r1.x
mov r1.xyz, c23
rcp r1.w, r1.w
mov r14.xyz, r2.x
add r2.x, r1.w, -c20
add r3.w, r2.x, -c35
mul r15.xyz, r4.w, c40
add r1.xyz, c25, r1
mul r1.xyz, r15, r1
dp3_sat r1.w, r7, c24
mad r4.xyz, r1, r1.w, r4
cmp_pp r1.x, r3.w, c60, c60.y
max r13.xyz, r11.w, c60.x
max r0.yzw, r0.y, c60.x
cmp r6.w, r3, c60.y, r6
if_gt r1.x, c60.x
add r3.w, r2.x, -c35
mov r1.xyz, r6
mov r1.w, c60.y
dp4 r7.y, r1, c5
dp4 r7.x, r1, c4
cmp_pp r1.x, r3.w, c60, c60.y
cmp r0.x, r3.w, c60.y, r0
if_gt r1.x, c60.x
mov r0.x, c34
add r0.x, -c35, r0
rcp r3.w, r0.x
add r0.x, r2, -c35
mul_sat r0.x, r0, r3.w
mad r3.w, -r0.x, c64.y, c64.z
mov r1.xy, r7
mov r1.z, c60.x
texldl r1, r1.xyzz, s7
add r4.w, r1.x, c61.x
mul r1.x, r0, r0
mul r1.x, r1, r3.w
mov r0.x, c34.y
add r3.w, -c35.y, r0.x
mad r0.x, r1, r4.w, c60.y
rcp r3.w, r3.w
add r1.x, r2, -c35.y
mul_sat r1.x, r1, r3.w
add r3.w, r1.y, c61.x
mad r1.y, -r1.x, c64, c64.z
mul r1.x, r1, r1
mul r1.y, r1.x, r1
mad r1.y, r1, r3.w, c60
mov r1.x, c34.z
mul r0.x, r0, r1.y
add r1.x, -c35.z, r1
rcp r1.y, r1.x
add r1.x, r2, -c35.z
mul_sat r1.x, r1, r1.y
add r3.w, r1.z, c61.x
mad r1.z, -r1.x, c64.y, c64
mul r1.y, r1.x, r1.x
mul r1.y, r1, r1.z
mov r1.x, c34.w
add r1.z, -c35.w, r1.x
mad r1.x, r1.y, r3.w, c60.y
rcp r1.z, r1.z
add r1.y, r2.x, -c35.w
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c64.y, c64
mul r1.y, r1, r1
add r1.w, r1, c61.x
mul r1.y, r1, r1.z
mad r1.y, r1, r1.w, c60
mul r0.x, r0, r1
mul r0.x, r0, r1.y
endif
mov r6.w, r0.x
endif
add r1.xyz, r5, -c16
dp3 r0.x, r1, r1
add r1.xyz, r8, r9
add r1.xyz, r1, r11
add r8.xyz, r1, r13
rsq r0.x, r0.x
rcp r0.x, r0.x
add r0.x, r0, -c20
mul r2.x, r0, c64.w
mul r1.xyz, r3, c58.x
add r5.xyz, v0, c26
mul r3.xyz, r1, r5
pow r1, c63.y, -r2.x
mul r7.xyz, r6.w, v1
mad r8.xyz, r7, r8, r3
add r3.xyz, r6, -c16
mov r6.x, r1
dp3 r1.x, r3, r3
rsq r2.x, r1.x
mul r0.x, r0, c65.w
pow r1, c63.y, -r0.x
rcp r0.x, r2.x
add r0.x, r0, -c20
mul r2.x, r0, c65.w
mov r6.y, r1
pow r1, c63.y, -r2.x
mul r0.x, r0, c64.w
pow r3, c63.y, -r0.x
mov r1.x, r3
add r1.xy, r6, r1
mul r6.xy, r1, c60.w
add r3.xyz, r8, r2.yzww
mul r1.xyz, r14, c59.x
mad r1.xyz, r1, r4, r3
mul r4.xyz, r14, c58.x
mul r0.x, r6.y, c42
mul r3.xyz, r6.x, c41
mad r3.xyz, r3, c66.x, r0.x
add r6.xyz, r10, r12
add r0.xyz, r6, r0.yzww
mul r4.xyz, r5, r4
mad r0.xyz, r7, r0, r4
add r2.xyz, r2.yzww, r0
add r1.xyz, r1, r2
mul r3.xyz, -r3, r5.w
pow r0, c63.y, r3.x
mul r4.xyz, r1, c56
mov r2.x, r0
pow r1, c63.y, r3.z
pow r0, c63.y, r3.y
mov r2.z, r1
mov r2.y, r0
mul oC0.xyz, r4, r2
dp3 oC0.w, r7.w, c65
endif

"
}

}

		}
	}
	Fallback off
}
