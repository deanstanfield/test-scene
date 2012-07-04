// This composes the previously computed downscaled sky buffer with cloud buffers
// It also computes more accurately the pixels that have too much discrepancy between the fullscale and downscaled versions
//
Shader "Hidden/Nuaj/ComposeSkyAndCloudsComplex"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownScaledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer0( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer1( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer2( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer3( "Base (RGB)", 2D ) = "white" {}
		_TexBackground( "Base (RGB)", 2D ) = "black" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
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
		// Pass #0 compose sky with NO cloud layer
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
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 3 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 2 [_TexDensity] 2D
SetTexture 5 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 1 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 4 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[65] = { program.local[0..50],
		{ 0, 2, -1, -1000000 },
		{ 1, 0.995, 1000000, -1000000 },
		{ 0.001, 0.75, 1.5, 0.5 },
		{ 255, 0, 1, 2.718282 },
		{ 3, 5.6020446, 9.4732847, 19.643803 },
		{ 1000, 10, 400, 210 },
		{ 0.0241188, 0.1228178, 0.84442663, 128 },
		{ 0.51413637, 0.32387859, 0.16036376, 0.25 },
		{ 0.26506799, 0.67023426, 0.064091571, 15 },
		{ 4, 256, 0.0009765625, 1024 },
		{ 0.00390625, 0.0047619049, 0.63999999, 0 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 } };
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
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R2.xyz, c[9];
MOVR  R3.x, c[51].w;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].y, -R0;
MOVR  R0.z, c[51];
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[13].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[51].x;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.w, R2, R1;
MOVR  R0, c[24];
MULR  R3.z, R3.w, R3.w;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.w, R1;
MOVR  R0.x, c[51].w;
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.w, R0.y;
MOVR  R0.y, c[51].w;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.w, R0.z;
MOVR  R0.z, c[51].w;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.w, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[35];
SGER  H0.x, c[51], R0;
MOVR  R0, c[40];
ADDR  R0, -R0, c[36];
MADR  R5, H0.x, R0, c[40];
MOVR  R0, c[41];
ADDR  R0, -R0, c[37];
MADR  R4, H0.x, R0, c[41];
MOVR  R0, c[42];
ADDR  R0, -R0, c[38];
MADR  R3, H0.x, R0, c[42];
MOVR  R0, c[43];
ADDR  R0, -R0, c[39];
MADR  R2, H0.x, R0, c[43];
DP4R  R1.x, R5, c[52].x;
DP4R  R1.w, R2, c[52].x;
DP4R  R1.y, R4, c[52].x;
DP4R  R1.z, R3, c[52].x;
DP4R  R0.x, R5, R5;
DP4R  R0.w, R2, R2;
DP4R  R0.y, R4, R4;
DP4R  R0.z, R3, R3;
MADR  R0, R1, R0, -R0;
ADDR  R0, R0, c[52].x;
MULR  R1.x, R0, R0.y;
MULR  R1.x, R1, R0.z;
MULR  R6.w, R1.x, R0;
DP4R  R1.x, R2, c[51].x;
DP4R  R0.w, R3, c[51].x;
MADR  R0.z, R0, R1.x, R0.w;
DP4R  R0.w, R4, c[51].x;
MADR  R0.y, R0, R0.z, R0.w;
DP4R  R0.z, R5, c[51].x;
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[49].xyxz;
MADR  R6.xyz, R0.x, R0.y, R0.z;
ADDR  R0.xy, R1.zwzw, c[49].zyzw;
ADDR  R0.zw, R0.xyxy, -c[49].xyxz;
TEX   R0.x, R0, texture[1], 2D;
TEX   R1.x, R0.zwzw, texture[1], 2D;
ADDR  R0.y, R1.x, -R0.x;
ADDR  R15.xy, R0.zwzw, -c[49].zyzw;
MULR  R0.zw, R15.xyxy, c[50].xyxy;
FRCR  R0.zw, R0;
MADR  R0.x, R0.z, R0.y, R0;
TEX   R1.x, fragment.texcoord[0], texture[1], 2D;
TEX   R2.x, R1.zwzw, texture[1], 2D;
ADDR  R1.y, R2.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[8].w, -c[8];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[8].w;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[8];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R5.w, R0.z, R0.x;
ADDR  R0.x, R5.w, -R0.y;
SGTRC HC.x, |R0|, c[47];
IF    NE.x;
MOVR  R4.w, c[51];
MOVR  R4.x, c[51].w;
MOVR  R4.z, c[51].w;
MOVR  R4.y, c[51].w;
MOVR  R3.x, c[52].z;
MULR  R1.xy, R15, c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].y, -R0;
MOVR  R0.z, c[51];
DP3R  R0.w, R0, R0;
RSQR  R8.z, R0.w;
MULR  R0.xyz, R8.z, R0;
MOVR  R0.w, c[51].x;
DP4R  R5.z, R0, c[2];
DP4R  R5.y, R0, c[1];
DP4R  R5.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R1.x, c[0].w;
MOVR  R1.z, c[2].w;
MOVR  R1.y, c[1].w;
MULR  R9.xyz, R1, c[13].x;
ADDR  R7.xyz, R9, -c[9];
DP3R  R3.z, R5, R7;
MULR  R3.y, R3.z, R3.z;
DP3R  R3.w, R7, R7;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R3.w;
ADDR  R1, R3.y, -R0;
SLTR  R2, R3.y, R0;
MOVXC RC.x, R2;
MOVR  R4.x(EQ), R7.w;
SGERC HC, R3.y, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R3.z, R1;
MOVXC RC.z, R2;
MOVR  R4.z(EQ), R7.w;
MOVXC RC.z, R2.w;
RCPR  R0.x, R0.x;
ADDR  R4.z(NE.y), -R3, R0.x;
MOVXC RC.y, R2;
RSQR  R0.x, R1.w;
MOVR  R4.w(EQ.z), R7;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE), -R3.z, R0.x;
RSQR  R0.x, R1.y;
MOVR  R4.y(EQ), R7.w;
RCPR  R0.x, R0.x;
ADDR  R4.y(NE.x), -R3.z, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R3.w;
ADDR  R1, R3.y, -R0;
SLTR  R2, R3.y, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R7.w;
SGERC HC, R3.y, R0.yzxw;
RSQR  R0.x, R1.z;
MADR  R2.x, -c[12], c[12], R3.w;
ADDR  R0.z, R3.y, -R2.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.z, -R1;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R1.x, c[52].z;
MOVXC RC.z, R2;
MOVR  R1.x(EQ.z), R7.w;
RCPR  R0.x, R0.x;
ADDR  R1.x(NE.y), -R3.z, -R0;
RSQR  R0.x, R1.w;
MOVXC RC.y, R2;
MOVR  R1.w, c[52].z;
MOVR  R1.z, c[52];
MOVXC RC.z, R2.w;
MOVR  R1.z(EQ), R7.w;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R3, -R0.x;
RSQR  R0.x, R1.y;
MOVR  R1.y, c[52].z;
MOVR  R1.w(EQ.y), R7;
RCPR  R0.x, R0.x;
ADDR  R1.w(NE.x), -R3.z, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R3.w;
SLTRC HC.x, R3.y, R0;
MOVR  R1.y(EQ.x), R7.w;
ADDR  R0.y, R3, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R3.w, R1.z;
SGERC HC.x, R3.y, R0;
RCPR  R0.y, R0.y;
ADDR  R1.y(NE.x), -R3.z, -R0;
MOVXC RC.x, R1.y;
MOVR  R1.y(LT.x), c[52].z;
MOVR  R0.xy, c[51].x;
SLTRC HC.x, R3.y, R2;
MOVR  R0.xy(EQ.x), R8;
SGERC HC.x, R3.y, R2;
MOVR  R3.y, R1.w;
ADDR  R0.w, -R3.z, -R0.z;
ADDR  R2.y, -R3.z, R0.z;
MOVR  R3.z, R1.x;
MAXR  R0.z, R0.w, c[51].x;
MAXR  R0.w, R2.y, c[51].x;
MOVR  R0.xy(NE.x), R0.zwzw;
DP4R  R1.x, R4, c[35];
SGER  R7.w, c[51].x, R1.x;
MAXR  R1.w, R0.x, c[53].x;
MOVR  R8.xy, c[52];
DP4R  R0.z, R3, c[40];
DP4R  R0.w, R4, c[36];
ADDR  R0.w, R0, -R0.z;
MADR  R0.z, R7.w, R0.w, R0;
RCPR  R0.w, R8.z;
MULR  R0.w, R5, R0;
MADR  R1.x, -R0.w, c[13], R1.y;
MULR  R1.y, R8, c[8].w;
SGER  H0.x, R5.w, R1.y;
MULR  R0.w, R0, c[13].x;
MADR  R0.w, H0.x, R1.x, R0;
MINR  R2.w, R0.y, R0;
ADDR  R1.z, R2.w, -R1.w;
RCPR  R0.x, R1.z;
MINR  R0.y, R2.w, R0.z;
MAXR  R11.y, R1.w, R0;
MULR  R10.w, R0.x, c[32].x;
ADDR  R1.y, R11, -R1.w;
MULR  R1.x, R10.w, R1.y;
RCPR  R2.y, c[32].x;
MULR  R11.w, R1.z, R2.y;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R7.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MOVR  R10.x, R0;
MOVR  R11.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R7.w, R0, c[46].y;
SLTR  H0.y, R1.x, R0.w;
SGTR  H0.x, R1, c[51];
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R1.x;
RCPR  R2.x, R0.w;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R1.y, R2.x;
MOVR  R14.w(NE.x), R0;
MULR  R1.xyz, R7.zxyw, c[16].yzxw;
MADR  R1.xyz, R7.yzxw, c[16].zxyw, -R1;
DP3R  R0.w, R1, R1;
MULR  R2.xyz, R5.zxyw, c[16].yzxw;
MADR  R2.xyz, R5.yzxw, c[16].zxyw, -R2;
DP3R  R1.y, R1, R2;
DP3R  R1.x, R2, R2;
DP3R  R2.y, R7, c[16];
MADR  R0.w, -c[11].x, c[11].x, R0;
SLER  H0.y, R2, c[51].x;
MULR  R2.x, R1, R0.w;
MULR  R1.z, R1.y, R1.y;
ADDR  R0.w, R1.z, -R2.x;
SGTR  H0.z, R1, R2.x;
RCPR  R2.x, R1.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.z, -R1.y, R0.w;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVR  R1.z, c[52].w;
MOVR  R1.x, c[52].z;
ADDR  R0.w, -R1.y, -R0;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0.y;
MULR  R1.z(NE.x), R2.x, R2;
MULR  R1.x(NE), R0.w, R2;
MOVR  R1.y, R1.z;
MOVR  R16.xy, R1;
MADR  R1.xyz, R5, R1.x, R9;
ADDR  R1.xyz, R1, -c[9];
DP3R  R0.w, R1, c[16];
SGTR  H0.z, R0.w, c[51].x;
MULXC HC.x, H0.y, H0.z;
MOVR  R16.xy(NE.x), c[52].zwzw;
MOVXC RC.x, H0;
DP4R  R1.x, R3, c[41];
DP4R  R0.w, R4, c[37];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R7, R0, R1.x;
MINR  R0.w, R2, R0;
MAXR  R12.y, R11, R0.w;
DP4R  R1.x, R3, c[42];
DP4R  R0.w, R4, c[38];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R7, R0, R1.x;
MINR  R0.w, R2, R0;
MAXR  R13.y, R12, R0.w;
DP4R  R0.w, R3, c[43];
DP4R  R1.x, R4, c[39];
ADDR  R1.x, R1, -R0.w;
MADR  R0.w, R7, R1.x, R0;
MINR  R0.w, R2, R0;
DP3R  R0.y, R5, c[16];
MULR  R13.x, R0, c[33];
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[51].y;
MADR  R0.x, c[30], c[30], R0;
ADDR  R0.x, R0, c[52];
MADR  R15.z, R0.y, c[53].y, c[53].y;
ADDR  R0.y, R8.x, c[30].x;
POWR  R0.x, R0.x, c[53].z;
RCPR  R0.x, R0.x;
MULR  R0.y, R0, R0;
MAXR  R4.w, R13.y, R0;
MOVR  R12.x, R0.z;
MOVR  R12.w, R2;
MULR  R15.w, R0.y, R0.x;
MOVR  R8.xyz, c[52].x;
MOVR  R7.xyz, c[51].x;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R3.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R3.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R2.x, R0, R0;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R3.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R3.z, R1.x, R13.w;
ADDR  R1.x, R3.z, R1.w;
RCPR  R1.z, R3.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R8.w;
MOVR  R8.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R8.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R8.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R2.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R3.z;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R3.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.y, -R11.y;
MULR  R0.y, R0.x, R10.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R11.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R3.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R3.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R2.x, R0, R0;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R3.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R3.z, R1.x, R13.w;
ADDR  R1.x, R3.z, R1.w;
RCPR  R1.z, R3.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R8.w;
MOVR  R8.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R8.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R8.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R2.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R3.z;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R3.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R13.y, -R12.y;
MULR  R0.y, R0.x, R10.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R12.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R3.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R3.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R2.x, R0, R0;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R3.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R3.z, R1.x, R13.w;
ADDR  R1.x, R3.z, R1.w;
RCPR  R1.z, R3.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R8.w;
MOVR  R8.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R8.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R8.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R2.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R3.z;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R3.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R4.w, -R13.y;
MULR  R0.y, R0.x, R10.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R12.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R12.x;
RCPR  R0.z, R12.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R12.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R13.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R3.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R3.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R2.x, R0, R0;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R3.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R3.z, R1.x, R13.w;
ADDR  R1.x, R3.z, R1.w;
RCPR  R1.z, R3.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R8.w;
MOVR  R8.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R8.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R8.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R2.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R3.z;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R3.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.w, -R4.w;
MULR  R0.y, R0.x, R10.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R13.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R13.x;
RCPR  R0.z, R13.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R13.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R4;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R3.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R3.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R2.x, R0, R0;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R3.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R4.xyz, R1.w, R5, R9;
ADDR  R0.xyz, R4, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R3, R0, texture[2], 2D;
MULR  R0.x, R3.w, c[29];
MADR  R0.xyz, R3.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R3.z, R1.x, R13.w;
ADDR  R1.x, R3.z, R1.w;
RCPR  R1.z, R3.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R8.w;
MOVR  R8.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R4;
DP4R  R2.y, R0, c[5];
DP4R  R2.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R2.z, -R1.y, c[51].y, R0.y;
MULR  R2.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R2.w, R2.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R2, R2, texture[3], 2D;
MADR  R1.y, R2, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R2, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R2, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R2.w, R0, -R0;
MADR  R8.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R8.w;
ENDIF;
ADDR  R0.xyz, -R4, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R4, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R2.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R2.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R3.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R3, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R3.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R3.z;
MADR  R1.xyz, R3.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R3.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
MOVR  R1, c[40];
ADDR  R1, -R1, c[36];
MADR  R4, R7.w, R1, c[40];
DP4R  R2.x, R4, c[52].x;
MOVR  R0, c[41];
ADDR  R0, -R0, c[37];
MADR  R3, R7.w, R0, c[41];
DP4R  R4.x, R4, R4;
MOVR  R1, c[42];
MOVR  R0, c[43];
ADDR  R1, -R1, c[38];
MADR  R1, R7.w, R1, c[42];
ADDR  R0, -R0, c[39];
MADR  R0, R7.w, R0, c[43];
DP4R  R4.z, R1, R1;
DP4R  R2.z, R1, c[52].x;
DP4R  R2.y, R3, c[52].x;
DP4R  R2.w, R0, c[52].x;
DP4R  R4.y, R3, R3;
DP4R  R4.w, R0, R0;
MADR  R0, R2, R4, -R4;
ADDR  R0, R0, c[52].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R12;
MADR  R1.xyz, R1, R0.y, R11;
MADR  R1.xyz, R1, R0.x, R10;
MULR  R0.xyz, R1.y, c[59];
MADR  R0.xyz, R1.x, c[58], R0;
MADR  R0.xyz, R1.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xywz;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].w;
SGER  H0.x, R0, c[57].w;
MULH  H0.y, H0.x, c[57].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[58].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[60].x;
ADDH  H0.y, H0, -c[59].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R8.y, c[59];
MADR  R1.xyz, R8.x, c[58], R1;
MADR  R1.xyz, R8.z, c[57], R1;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0.w, c[54].x;
MADR  R0.z, R0.x, c[60].y, R0;
MOVR  R0.x, c[52];
MADR  H0.z, R0, c[60], R0.x;
MADH  H0.x, H0, c[51].y, H0.y;
MULH  H0.x, H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
LG2H  H0.z, |H0.x|;
FLRH  H0.z, H0;
ADDH  H0.w, H0.z, c[59];
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xywz;
FLRR  R0.zw, R0;
MINR  R1.z, R0, c[56].w;
SGEH  H0.y, c[51].x, H0.x;
EX2H  H0.z, -H0.z;
MULH  H0.x, |H0|, H0.z;
MADH  H0.x, H0, c[60].w, -c[60].w;
MULR  R1.x, H0, c[61];
FLRR  R0.z, R1.x;
MULH  H0.w, H0, c[60].x;
MADH  H0.y, H0, c[57].w, H0.w;
ADDR  R0.z, H0.y, R0;
SGER  H0.x, R1.z, c[57].w;
MULH  H0.y, H0.x, c[57].w;
ADDR  R1.w, R1.z, -H0.y;
MULR  R1.z, R1.w, c[58].w;
FLRR  H0.y, R1.z;
MULH  H0.z, H0.y, c[60].x;
FRCR  R1.x, R1;
ADDH  H0.y, H0, -c[59].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.x, R1, c[61].z;
MULR  R0.z, R0, c[61].y;
ADDR  R1.z, -R0, -R1.x;
MADR  R1.z, R1, R0.y, R0.y;
MADH  H0.x, H0, c[51].y, H0.y;
ADDR  R1.w, R1, -H0.z;
MINR  R0.w, R0, c[54].x;
MADR  R0.w, R1, c[60].y, R0;
MADR  H0.z, R0.w, c[60], R0.x;
MULH  H0.x, H0, H0.z;
RCPR  R0.x, R1.x;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MULR  R0.z, R0, R0.y;
ADDH  H0.y, H0, c[59].w;
MULR  R0.w, R1.z, R0.x;
MULR  R1.x, R0, R0.z;
MULR  R0.xyz, R0.y, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R2.xyz, R0, c[51].x;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R1.x, H0.z, c[61];
FRCR  R0.w, R1.x;
MULR  R0.w, R0, c[61].z;
MULR  R0.xyz, R1.y, c[64];
FLRR  R1.x, R1;
MULH  H0.y, H0, c[60].x;
SGEH  H0.x, c[51], H0;
MADH  H0.x, H0, c[57].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.z, R1.x, c[61].y;
ADDR  R1.x, -R1.z, -R0.w;
MADR  R1.x, R1, R1.y, R1.y;
MULR  R1.z, R1, R1.y;
RCPR  R0.w, R0.w;
MULR  R1.y, R0.w, R1.z;
MADR  R0.xyz, R1.y, c[63], R0;
MULR  R0.w, R1.x, R0;
ADDR  R1.xyz, -R2, c[54].zyyw;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R0.xyz, R0, c[51].x;
MADR  R2.xyz, R1, c[48].x, R2;
MADR  R1.xyz, -R0, c[48].x, R0;
ELSE;
ADDR  R5.xy, R15, c[49].xzzw;
ADDR  R0.xy, R5, c[49].zyzw;
TEX   R3, R0, texture[4], 2D;
ADDR  R7.xy, R0, -c[49].xzzw;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R3|, H0;
MADH  H0.y, H0, c[60].w, -c[60].w;
MULR  R0.z, H0.y, c[61].x;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[61].z;
ADDH  H0.x, H0, c[59].w;
MULH  H0.z, H0.x, c[60].x;
SGEH  H0.xy, c[51].x, R3.ywzw;
TEX   R2, R7, texture[4], 2D;
MADH  H0.x, H0, c[57].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[61].y;
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[59].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R3.x;
MADR  R0.w, R0, R3.x, R3.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R3.x, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
MAXR  R1.xyz, R0, c[51].x;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[51].x, R2.xyyw;
MULR  R0.z, R0.x, c[61];
MULH  H0.x, H0, c[60];
RCPR  R2.y, R0.z;
MADH  H0.x, H0.z, c[57].w, H0;
FLRR  R0.y, R0.w;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[61].y;
MULR  R0.w, R0.x, R2.x;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R2.x, R2.x;
MULR  R1.w, R0.y, R2.y;
MULR  R0.xyz, R2.x, c[64];
MULR  R0.w, R2.y, R0;
MADR  R4.xyz, R0.w, c[63], R0;
TEX   R0, R5, texture[4], 2D;
MADR  R4.xyz, R1.w, c[62], R4;
MAXR  R5.xyz, R4, c[51].x;
ADDR  R4.xyz, R1, -R5;
TEX   R1, R15, texture[4], 2D;
ADDR  R15.xy, R7, -c[49].zyzw;
MULR  R2.xy, R15, c[50];
FRCR  R8.xy, R2;
MADR  R4.xyz, R8.x, R4, R5;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R3.x, H0.z, c[61];
ADDH  H0.x, H0, c[59].w;
SGEH  H1.xy, c[51].x, R0.ywzw;
MULH  H0.x, H0, c[60];
SGEH  H1.zw, c[51].x, R1.xyyw;
FRCR  R2.x, R3;
FLRR  R2.y, R3.x;
MADH  H0.x, H1, c[57].w, H0;
ADDR  R0.y, H0.x, R2;
MULR  R2.y, R2.x, c[61].z;
MULR  R2.x, R0.y, c[61].y;
ADDR  R0.y, -R2.x, -R2;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
RCPR  R2.y, R2.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R2.x, R2, R0;
MULR  R0.y, R0, R2;
MULR  R2.x, R2.y, R2;
MULR  R5.xyz, R0.x, c[64];
MADR  R5.xyz, R2.x, c[63], R5;
MADH  H0.z, H0, c[60].w, -c[60].w;
MADR  R5.xyz, R0.y, c[62], R5;
MULR  R0.x, H0.z, c[61];
FRCR  R0.y, R0.x;
MULR  R1.y, R0, c[61].z;
MADH  H0.x, H1.z, c[57].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.y, R0.x, c[61];
ADDR  R0.x, -R0.y, -R1.y;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
RCPR  R1.y, R1.y;
MADR  R0.x, R0, R1, R1;
MULR  R0.y, R0, R1.x;
MULR  R0.x, R0, R1.y;
MULR  R0.y, R1, R0;
MULR  R7.xyz, R1.x, c[64];
MADR  R7.xyz, R0.y, c[63], R7;
MADR  R7.xyz, R0.x, c[62], R7;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.x, H0.z, c[61];
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[51].x;
MAXR  R5.xyz, R5, c[51].x;
ADDR  R5.xyz, R5, -R7;
MADR  R5.xyz, R8.x, R5, R7;
MADH  H0.x, H1.y, c[57].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
MULR  R0.y, R0, c[61].z;
MULR  R0.x, R0, c[61].y;
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
FRCR  R1.x, R0.w;
MULR  R1.y, R1.x, c[61].z;
RCPR  R2.x, R1.y;
MADH  H0.x, H1.w, c[57].w, H0;
FLRR  R0.w, R0;
ADDR  R0.w, H0.x, R0;
MULR  R1.x, R0.w, c[61].y;
ADDR  R0.w, -R1.x, -R1.y;
MADR  R0.w, R1.z, R0, R1.z;
MULR  R1.w, R1.z, R1.x;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
ADDH  H0.x, H0, c[59].w;
MULR  R0.w, R0, R2.x;
MULR  R1.w, R2.x, R1;
MULR  R1.xyz, R1.z, c[64];
MADR  R1.xyz, R1.w, c[63], R1;
MADR  R1.xyz, R0.w, c[62], R1;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
MULH  H0.x, H0, c[60];
MADH  H0.z, H0.w, c[57].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULH  H0.z, |R3.w|, H0;
MULR  R2.y, R1.w, c[61];
MULR  R2.x, R0.w, c[61].z;
ADDR  R3.x, -R2.y, -R2;
MADR  R3.y, R2.z, R3.x, R2.z;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
MULR  R2.w, R1, c[61].z;
MAXR  R1.xyz, R1, c[51].x;
MAXR  R0.xyz, R0, c[51].x;
ADDR  R0.xyz, R0, -R1;
RCPR  R3.x, R2.x;
MULR  R3.w, R2.z, R2.y;
MULR  R3.w, R3.x, R3;
MULR  R2.xyz, R2.z, c[64];
MADR  R0.xyz, R8.x, R0, R1;
MADR  R2.xyz, R3.w, c[63], R2;
MULR  R3.x, R3.y, R3;
MADR  R2.xyz, R3.x, c[62], R2;
MAXR  R2.xyz, R2, c[51].x;
ADDR  R4.xyz, R4, -R5;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[57].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R1.w, R0, c[61].y;
ADDR  R0.w, -R1, -R2;
MULR  R3.w, R3.z, R1;
MADR  R0.w, R3.z, R0, R3.z;
RCPR  R1.w, R2.w;
MULR  R3.xyz, R3.z, c[64];
MULR  R2.w, R1, R3;
MADR  R3.xyz, R2.w, c[63], R3;
MULR  R0.w, R0, R1;
MADR  R3.xyz, R0.w, c[62], R3;
MAXR  R3.xyz, R3, c[51].x;
ADDR  R3.xyz, R3, -R2;
MADR  R1.xyz, R8.x, R3, R2;
ADDR  R1.xyz, R1, -R0;
MADR  R2.xyz, R8.y, R4, R5;
MADR  R1.xyz, R8.y, R1, R0;
ENDIF;
MOVR  R0.x, c[52].y;
MULR  R0.x, R0, c[8].w;
SGTRC HC.x, R5.w, R0;
IF    NE.x;
TEX   R0.xyz, R15, texture[5], 2D;
ELSE;
MOVR  R0.xyz, c[51].x;
ENDIF;
MULR  R1.xyz, R1, R6.w;
MADR  R0.xyz, R0, R1, R6;
ADDR  R2.xyz, R0, R2;
MULR  R0.xyz, R2.y, c[59];
MADR  R0.xyz, R2.x, c[58], R0;
MADR  R0.xyz, R2.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[59];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xywz;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].w;
SGER  H0.x, R0, c[57].w;
MULH  H0.y, H0.x, c[57].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[58].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[59].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[60].x;
MADR  R2.xyz, R1.x, c[58], R2;
MADR  R1.xyz, R1.z, c[57], R2;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[56].xywz;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[51].y, H0.z;
MINR  R0.z, R1, c[56].w;
SGER  H0.z, R0, c[57].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[57].w;
MINR  R0.w, R0, c[54].x;
MADR  R0.x, R0, c[60].y, R0.w;
ADDR  R0.z, R0, -H0.y;
MOVR  R1.x, c[52];
MADR  H0.y, R0.x, c[60].z, R1.x;
MULR  R0.w, R0.z, c[58];
FLRR  H0.w, R0;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[60];
ADDR  R0.x, R0.z, -H0;
ADDH  H0.x, H0.w, -c[59].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[54].x;
MADR  R0.x, R0, c[60].y, R0.y;
MADR  H0.z, R0.x, c[60], R1.x;
MADH  H0.x, H0.y, c[51].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 3 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 2 [_TexDensity] 2D
SetTexture 5 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 1 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 4 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c51, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c52, -1000000.00000000, 0.99500000, 1000000.00000000, 0.00100000
def c53, 0.75000000, 1.50000000, 0.50000000, 2.71828198
defi i0, 255, 0, 1, 0
def c54, 2.00000000, 3.00000000, 1000.00000000, 10.00000000
def c55, 400.00000000, 5.60204458, 9.47328472, 19.64380264
def c56, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c57, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c58, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c59, 0.25000000, -15.00000000, 4.00000000, 255.00000000
def c60, 256.00000000, 0.00097656, 1.00000000, 15.00000000
def c61, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c62, -1.02170002, 1.97770000, 0.04390000, 0
def c63, 2.56509995, -1.16649997, -0.39860001, 0
def c64, 0.07530000, -0.25430000, 1.18920004, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c51.x, c51.y
mov r4, c39
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c51.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
add r0.y, c24, r0
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r3.xyz, r3, c13.x
add r3.xyz, r3, -c9
dp3 r0.z, r1, r3
dp3 r1.x, r3, r3
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c24, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
cmp r0.x, r0, r1.w, c52
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c51.w, c51.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c52.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c11.x
add r1.y, c24.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.z, -r0, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c51, c51.z
cmp r1.z, r1, r1.w, c52.x
cmp_pp r0.z, r1.x, c51.w, c51
cmp r1.x, r1, r1.w, c52
cmp r0.w, -r0, r1.z, r2.z
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c35
cmp r2.z, -r0.x, c51.w, c51
mov r1, c36
add r1, -c40, r1
mad r3, r2.z, r1, c40
mov r0, c37
add r0, -c41, r0
mad r1, r2.z, r0, c41
mov r0, c38
add r4, -c43, r4
mad r4, r2.z, r4, c43
add r0, -c42, r0
mad r0, r2.z, r0, c42
dp4 r5.z, r0, c51.w
dp4 r5.y, r1, c51.w
dp4 r5.w, r4, c51.w
dp4 r5.x, r3, c51.w
add r6, r5, c51.y
dp4 r5.z, r0, r0
dp4 r0.y, r0, c51.z
dp4 r5.y, r1, r1
dp4 r5.w, r4, r4
dp4 r0.x, r4, c51.z
dp4 r5.x, r3, r3
mad r5, r5, r6, c51.w
mad r0.x, r5.z, r0, r0.y
dp4 r0.y, r1, c51.z
mul r2.z, r5.x, r5.y
mul r2.z, r2, r5
add r4.xy, v0, c49.xzzw
mad r0.w, r5.y, r0.x, r0.y
add r0.xy, r4, c49.zyzw
add r6.xy, r0, -c49.xzzw
mov r6.z, v0.w
mov r0.z, v0.w
add r7.xy, r6, -c49.zyzw
mul r1.zw, r7.xyxy, c50.xyxy
texldl r0.x, r0.xyzz, s1
texldl r1.x, r6.xyzz, s1
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
dp4 r1.y, r3, c51.z
mov r4.z, v0.w
texldl r1.x, v0, s1
texldl r3.x, r4.xyzz, s1
add r0.z, r3.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c8.w, -c8.z
rcp r0.y, r0.x
mul r0.y, r0, c8.w
texldl r0.x, v0, s0
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c8.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r6.w, r2.z, r5
mad r6.xyz, r5.x, r0.w, r1.y
mov r7.z, v0.w
if_gt r0.x, c47.x
mad r0.xy, r7, c51.x, c51.y
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.z, r0.w
mul r0.xyz, r2.z, r0
mov r0.w, c51.z
dp4 r8.z, r0, c2
dp4 r8.y, r0, c1
dp4 r8.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
mul r11.xyz, r8.zxyw, c16.yzxw
mad r11.xyz, r8.yzxw, c16.zxyw, -r11
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r9.xyz, r1, c13.x
add r5.xyz, r9, -c9
mul r10.xyz, r5.zxyw, c16.yzxw
dp3 r2.w, r8, r5
dp3 r3.x, r5, r5
add r0.y, c25, r0
mad r0.z, -r0.y, r0.y, r3.x
mad r0.w, r2, r2, -r0.z
rsq r1.x, r0.w
add r0.x, c25, r0
mad r0.x, -r0, r0, r3
mad r0.x, r2.w, r2.w, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2.w, -r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
cmp r0.x, r0, r2, c52.z
cmp r0.x, -r0.y, r0, r0.z
cmp_pp r0.y, r0.w, c51.w, c51.z
rcp r1.x, r1.x
cmp r0.w, r0, r2.x, c52.z
add r1.x, -r2.w, -r1
cmp r0.y, -r0, r0.w, r1.x
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.x, c25.w, r0.z
mad r0.w, -r0, r0, r3.x
mad r0.z, r2.w, r2.w, -r0.w
mad r1.x, -r1, r1, r3
mad r1.y, r2.w, r2.w, -r1.x
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r2.w, -r0.w
cmp_pp r0.w, r0.z, c51, c51.z
cmp r0.z, r0, r2.x, c52
cmp r0.z, -r0.w, r0, r1.x
rsq r1.z, r1.y
rcp r1.z, r1.z
cmp r1.x, r1.y, r2, c52.z
mad r10.xyz, r5.yzxw, c16.zxyw, -r10
add r1.z, -r2.w, -r1
cmp_pp r0.w, r1.y, c51, c51.z
cmp r0.w, -r0, r1.x, r1.z
mov r1.x, c11
add r1.y, c24.x, r1.x
mov r1.x, c11
add r1.z, c24.y, r1.x
mad r1.y, -r1, r1, r3.x
mad r1.x, r2.w, r2.w, -r1.y
mad r1.z, -r1, r1, r3.x
mad r1.w, r2, r2, -r1.z
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r2.w, r1.y
cmp_pp r1.y, r1.x, c51.w, c51.z
cmp r1.x, r1, r2, c52
cmp r1.x, -r1.y, r1, r1.z
rsq r3.z, r1.w
cmp_pp r1.y, r1.w, c51.w, c51.z
rcp r3.z, r3.z
dp4 r3.y, r0, c41
dp4 r4.y, r0, c40
cmp r1.w, r1, r2.x, c52.x
add r3.z, -r2.w, r3
cmp r1.y, -r1, r1.w, r3.z
mov r1.z, c11.x
add r1.w, c24, r1.z
mad r1.w, -r1, r1, r3.x
mad r3.w, r2, r2, -r1
rsq r1.w, r3.w
rcp r3.z, r1.w
mov r1.z, c11.x
add r1.z, c24, r1
mad r1.z, -r1, r1, r3.x
mad r1.z, r2.w, r2.w, -r1
add r4.x, -r2.w, r3.z
rsq r1.w, r1.z
rcp r3.z, r1.w
cmp_pp r1.w, r3, c51, c51.z
cmp r3.w, r3, r2.x, c52.x
cmp r1.w, -r1, r3, r4.x
add r3.w, -r2, r3.z
cmp_pp r3.z, r1, c51.w, c51
cmp r1.z, r1, r2.x, c52.x
cmp r1.z, -r3, r1, r3.w
dp4 r3.z, r1, c37
dp4 r3.w, r1, c35
add r4.x, r3.z, -r3.y
cmp r8.w, -r3, c51, c51.z
mad r3.y, r8.w, r4.x, r3
dp4 r4.x, r1, c36
add r4.z, r4.x, -r4.y
mov r3.z, c11.x
add r3.z, c31.x, r3
mad r3.z, -r3, r3, r3.x
mad r3.z, r2.w, r2.w, -r3
rsq r3.w, r3.z
rcp r3.w, r3.w
add r4.x, -r2.w, -r3.w
cmp_pp r3.w, r3.z, c51, c51.z
cmp r3.z, r3, r2.x, c52
cmp r3.z, -r3.w, r3, r4.x
rcp r2.z, r2.z
mul r3.w, r7, r2.z
cmp r3.z, r3, r3, c52
mad r4.x, -r3.w, c13, r3.z
mad r3.x, -c12, c12, r3
mad r3.x, r2.w, r2.w, -r3
rsq r3.z, r3.x
mov r2.z, c8.w
mad r2.z, c52.y, -r2, r7.w
rcp r3.z, r3.z
cmp r2.z, r2, c51.w, c51
mul r3.w, r3, c13.x
mad r3.w, r2.z, r4.x, r3
add r2.z, -r2.w, -r3
add r2.w, -r2, r3.z
cmp_pp r3.z, r3.x, c51.w, c51
max r2.z, r2, c51
max r2.w, r2, c51.z
cmp r2.xy, r3.x, r2, c51.z
cmp r2.xy, -r3.z, r2, r2.zwzw
min r3.x, r2.y, r3.w
dp4 r2.z, r0, c42
dp4 r0.y, r0, c43
dp4 r0.x, r1, c39
max r14.x, r2, c52.w
add r0.z, r0.x, -r0.y
mad r4.y, r8.w, r4.z, r4
min r2.y, r3.x, r4
max r4.x, r14, r2.y
dp4 r2.y, r1, c38
add r2.y, r2, -r2.z
mad r2.y, r8.w, r2, r2.z
min r2.x, r3, r3.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
min r0.x, r3, r2.y
max r2.x, r4, r2
mad r0.y, r8.w, r0.z, r0
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r8, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r14.x
rcp r0.z, r0.y
rcp r2.z, r1.w
add r1.y, r4.x, -r14.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c51.z, c51.w
cmp r0.w, -r1.z, c51.z, c51
mul_pp r2.y, r0.w, r2
cmp r11.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r14.w, -r2.y, r0, r1.y
dp3 r0.y, r10, r10
dp3 r1.y, r10, r11
dp3 r1.z, r11, r11
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
rsq r2.z, r1.w
dp3 r0.y, r5, c16
cmp r0.y, -r0, c51.w, c51.z
cmp r1.w, -r1, c51.z, c51
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c52, r1
mad r5.xyz, r8, r1.z, r9
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c52.x, r1
cmp r1.y, -r1, c51.z, c51.w
mul_pp r0.y, r0, r1
cmp r15.xy, -r0.y, r1.zwzw, c52.zxzw
mad r2.w, r8, r2, c45.y
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r8.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r8.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r8.w, r0, c46
dp3 r2.z, r8, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c51.w
mul r2.w, r2, c51.x
mad r2.w, c30.x, c30.x, r2
mul r15.z, r2, c53.x
mov r2.z, c30.x
add r2.z, c51.w, r2
add r2.w, r2, c51
mov r16.x, r3
pow r3, r2.w, c53.y
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r11.w, c51.z, c51.w
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r15.w, r2.z, r2
mov r11.xyz, c51.w
mov r10.xyz, c51.z
if_gt r2.y, c51.z
frc r2.y, r11.w
add r2.y, r11.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r16.y, r2, r2.z, -r2.z
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r16.z, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r16, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s2
mul r2.y, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r2.y
pow r13, c53.w, r17.x
pow r3, c53.w, r17.y
mov r13.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.w, -r14.x, r15.y
rcp r2.z, r14.w
add r2.y, r3.x, -r15.x
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r3
mul r13.xyz, r13, r2.y
mov r2.y, c51.z
mul r14.xyz, r13, c15
if_gt c34.x, r2.y
add r3.y, r16.z, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r12
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r10.w, r2.y, c51, r10
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s3
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r13.x, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c54.x, c54
mul r2.w, r2, r2
add r3.z, r13.w, c51.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c51
mul r2.y, r2, r2.z
mul r10.w, r2.y, r2
endif
mul r14.xyz, r14, r10.w
endif
add r13.xyz, -r12, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
add r13.xyz, -c21, r13
dp3 r3.z, r13, r13
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r12.xyz, -r12, c18
dp3 r3.y, r12, r12
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r12.xyz, r3.y, r12
dp3 r2.y, r12, r8
mul r3.z, r3, c54
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r12.xyz, c19
add r2.y, r2, c51.w
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c54.z
add r12.xyz, -c18, r12
dp3 r2.z, r12, r12
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c54.z
min r2.w, r2.y, c51
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c54.z
mul r2.z, r5.y, c28.x
min r2.y, r2, c51.w
mul r12.xyz, r2.w, c23
mad r12.xyz, r2.y, c20, r12
mul r2.y, r5, c29.x
mad r13.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r12.xyz, r12, c54.w
mul r12.xyz, r2.z, r12
mul r12.xyz, r12, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r5.xyz, r2.y, c55.yzww, r2.z
mad r5.xyz, r14, r5, r12
mul r12.xyz, r14.w, -r13
add r13.xyz, r5, c17
pow r5, c53.w, r12.x
mul r13.xyz, r13, r14.w
mad r10.xyz, r13, r11, r10
mov r12.x, r5
pow r13, c53.w, r12.y
pow r5, c53.w, r12.z
mov r12.y, r13
mov r12.z, r5
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r5.w, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r5.w, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s2
mul r2.y, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r2.y
pow r13, c53.w, r17.x
add r2.y, r11.w, -r16
mul r11.w, r2.y, r14
pow r12, c53.w, r17.y
add r2.y, r11.w, r14.x
mov r13.y, r12
pow r12, c53.w, r17.z
rcp r2.z, r11.w
add r2.y, r2, -r15.x
add r2.w, -r14.x, r15.y
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r12
mul r12.xyz, r13, r2.y
mov r2.y, c51.z
mul r12.xyz, r12, c15
if_gt c34.x, r2.y
add r5.w, r5, -c11.x
add r2.y, r5.w, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r5
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r9.w, r2.y, c51, r9
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r5.w, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s3
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r3.z, r13.x, c51.y
mad r2.z, r2, r3, c51.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r5.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.w, r2.y, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.y, c24.z
add r3.z, -c25, r2.y
mul r2.y, r2.z, r2.w
rcp r2.w, r3.z
add r2.z, r5.w, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25
mul_sat r2.w, r2, r3.z
mad r3.z, -r2.w, c54.x, c54.y
mul r2.w, r2, r2
add r3.w, r13, c51.y
mul r2.w, r2, r3.z
mad r2.w, r2, r3, c51
mul r2.y, r2, r2.z
mul r9.w, r2.y, r2
endif
mul r12.xyz, r12, r9.w
endif
add r13.xyz, -r5, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.z, r2, r2.w
mul r3.w, r3.z, r2
add r13.xyz, -c21, r13
add r5.xyz, -r5, c18
dp3 r3.z, r13, r13
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.z, r3.z
rcp r3.z, r3.z
mul r3.z, r3, r3.w
rcp r3.w, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r8
mul r3.w, r3, c54.z
mul r2.y, r2, c30.x
mul r3.w, r3, r3
rcp r3.w, r3.w
mul r3.z, r3, r3.w
add r2.y, r2, c51.w
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c54.z
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.z, r3, c54
min r2.z, r3, c51.w
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c54.z
min r2.y, r2, c51.w
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r13.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c54.w
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r3.xyz, r2.y, c55.yzww, r2.z
mad r3.xyz, r12, r3, r5
add r5.xyz, r3, c17
mul r12.xyz, r11.w, -r13
pow r3, c53.w, r12.x
mul r5.xyz, r5, r11.w
mad r10.xyz, r5, r11, r10
mov r12.x, r3
pow r5, c53.w, r12.y
pow r3, c53.w, r12.z
mov r12.y, r5
mov r12.z, r3
mul r11.xyz, r11, r12
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r13.xyz, r10
cmp r2.w, -r2.z, c51.z, c51
cmp r3.x, r3, c51.z, c51.w
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r11.w, -r2, r2.z, r1
cmp_pp r1.w, -r11, c51.z, c51
cmp r14.w, -r2, r0, r2.y
mov r14.x, r4
mov r10.xyz, c51.z
if_gt r1.w, c51.z
frc r1.w, r11
add r1.w, r11, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r16.y, r1.w, r2, -r2
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r16.z, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r16.z, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s2
mul r1.w, r5, c29.x
mad r17.xyz, r5.z, -c27, -r1.w
pow r4, c53.w, r17.x
pow r3, c53.w, r17.y
mov r4.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.z, -r14.x, r15.y
rcp r2.y, r14.w
add r1.w, r3.x, -r15.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c51.z
mul r14.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r12
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r10.w, r1, c51, r10
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s3
add r2.w, r4.x, c51.y
mad r1.w, r2.y, r2, c51
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.y, r4.w, c51
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c51.w
mul r1.w, r1, r2.y
mul r10.w, r1, r2.z
endif
mul r14.xyz, r14, r10.w
endif
add r4.xyz, -r12, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r12.xyz, -r12, c18
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r12, r12
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r12
dp3 r1.w, r4, r8
mul r3.y, r3, c54.z
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c51
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c54.z
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c51.w
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c54.z
mul r2.y, r5, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r12.xyz, r14.w, -r12
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r5.xyz, r1.w, c55.yzww, r2.y
mad r4.xyz, r14, r5, r4
add r5.xyz, r4, c17
pow r4, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r4
pow r5, c53.w, r12.y
pow r4, c53.w, r12.z
mov r12.y, r5
mov r12.z, r4
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r5.w, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r5.w, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s2
mul r1.w, r3, c29.x
mad r17.xyz, r3.z, -c27, -r1.w
pow r12, c53.w, r17.x
add r1.w, r11, -r16.y
mul r11.w, r1, r14
pow r4, c53.w, r17.y
add r1.w, r11, r14.x
mov r12.y, r4
pow r4, c53.w, r17.z
mov r12.z, r4
rcp r2.y, r11.w
add r1.w, r1, -r15.x
add r2.z, -r14.x, r15.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mul r4.xyz, r12, r1.w
mov r1.w, c51.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r5
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r9.w, r1, c51, r9
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r5, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c54.x, c54.y
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s3
add r2.w, r4.x, c51.y
mad r2.y, r2, r2.w, c51.w
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r1.w, c24.z
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r5.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r5.w, -c25.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.z, r4.w, c51.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3, c51.w
mul r1.w, r1, r2.y
mul r9.w, r1, r2.z
endif
mul r12.xyz, r12, r9.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.z, r4, r4
rsq r3.z, r3.z
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.z, r3.z
mul r3.z, r3, r2.w
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r8
mul r2.w, r2, c54.z
mul r2.w, r2, r2
mul r1.w, r1, c30.x
mov r4.xyz, c19
rcp r3.w, r2.w
add r1.w, r1, c51
rcp r2.w, r1.w
mul r2.y, r2, r2.w
mul r1.w, r3.z, r3
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c54
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c51.w
mul r1.w, r2.y, c54.z
mul r2.y, r3, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r5.xyz, r11.w, -r5
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r3.xyz, r1.w, c55.yzww, r2.y
mad r3.xyz, r12, r3, r4
add r4.xyz, r3, c17
pow r3, c53.w, r5.x
mul r4.xyz, r4, r11.w
mad r10.xyz, r4, r11, r10
mov r5.x, r3
pow r4, c53.w, r5.y
pow r3, c53.w, r5.z
mov r5.y, r4
mov r5.z, r3
mul r11.xyz, r11, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r10
cmp r2.z, -r2.y, c51, c51.w
cmp r2.w, r2, c51.z, c51
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r11.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r11.w, c51, c51.w
cmp r14.w, -r2.z, r0, r1
mov r14.x, r2
mov r10.xyz, c51.z
if_gt r1.z, c51.z
frc r1.z, r11.w
add r1.z, r11.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r16.y, r1.z, r1.w, -r1.w
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r2.xyz, r12, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r16.z, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r16.z, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c51.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r5, r2.xyzz, s2
mul r1.z, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r1.z
pow r2, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r2
pow r2, c53.w, r17.z
add r3.x, r14, r14.w
add r2.x, -r14, r15.y
rcp r1.w, r14.w
add r1.z, r3.x, -r15.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mov r17.z, r2
mul r2.xyz, r17, r1.z
mov r1.z, c51
mul r14.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r16.z, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r12
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r10.w, r1.z, c51, r10
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s3
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c51.w
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c54, c54.y
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r10.w, r1.z, r2.x
endif
mul r14.xyz, r14, r10.w
endif
add r2.xyz, -r12, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r12.xyz, -r12, c18
dp3 r2.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r12
rcp r3.z, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.z, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c54.z
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c54
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r12.xyz, r14.w, -r12
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.z, r2
mul r2.w, r15, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r15
mad r5.xyz, r1.z, c55.yzww, r2.w
mul r2.xyz, r2, c55.x
mad r2.xyz, r14, r5, r2
add r5.xyz, r2, c17
pow r2, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r2
pow r5, c53.w, r12.y
pow r2, c53.w, r12.z
mov r12.y, r5
mov r12.z, r2
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r2.xyz, r5, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r5.w, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r5, -c11.x
add r1.z, -r1, c51.w
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r3, r2.xyzz, s2
mul r1.z, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r1.z
pow r12, c53.w, r17.x
add r1.z, r11.w, -r16.y
mul r11.w, r1.z, r14
pow r2, c53.w, r17.y
add r1.z, r11.w, r14.x
mov r12.y, r2
pow r2, c53.w, r17.z
mov r12.z, r2
rcp r1.w, r11.w
add r1.z, r1, -r15.x
add r2.x, -r14, r15.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mul r2.xyz, r12, r1.z
mov r1.z, c51
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r5.w, r5, -c11.x
add r1.z, r5.w, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r5
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r9.w, r1.z, c51, r9
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r5.w, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s3
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r5.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c54, c54.y
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r3.z, c51
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r5, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r5.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r9.w, r1.z, r2.x
endif
mul r12.xyz, r12, r9.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.z, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.z, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r3.w, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.w, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r3, r2.y
mul r1.w, r1, r2.x
mul r3.z, r1.w, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c54.z
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3.z
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c54
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r3.y, c28.x
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.w, r2
mul r5.xyz, r11.w, -r5
mul r2.xyz, r2, c55.x
mul r1.w, r15, r1
mul r1.z, r1, r15
mad r3.xyz, r1.z, c55.yzww, r1.w
mad r2.xyz, r12, r3, r2
add r3.xyz, r2, c17
pow r2, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r2
pow r3, c53.w, r5.y
pow r2, c53.w, r5.z
mov r5.y, r3
mov r5.z, r2
mul r11.xyz, r11, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c51.z, c51.w
cmp r2.x, -r1.w, c51.z, c51.w
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r11.w, -r2.x, r1, r1.y
cmp r14.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r11.w, c51.z, c51.w
mov r2.xyz, r10
mov r14.x, r1
mov r10.xyz, c51.z
if_gt r1.y, c51.z
frc r1.x, r11.w
add r1.x, r11.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r16.y, r1.x, r1, -r1
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r1.xyz, r12, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r16.z, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r16.z, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r5, r1.xyzz, s2
mul r1.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r1.x
pow r1, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r1
pow r1, c53.w, r17.z
add r3.x, r14, r14.w
rcp r1.y, r14.w
add r1.w, -r14.x, r15.y
add r1.x, r3, -r15
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r17.z, r1
mul r1.xyz, r17, r1.x
mov r1.w, c51.z
mul r14.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r12
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r10.w, r2, c51, r10
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s3
add r3.w, r1.x, c51.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r10.w, r1.x, r1.z
endif
mul r14.xyz, r14, r10.w
endif
add r1.xyz, -r12, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
add r2.w, r1.x, c51
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r12.xyz, -r12, c18
dp3 r1.x, r12, r12
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r12
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c54.z
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r12.xyz, r14.w, -r12
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r15.w, r1.w
mul r1.w, r2, r15.z
mad r5.xyz, r1.w, c55.yzww, r3.y
mul r1.xyz, r1, c55.x
mad r1.xyz, r14, r5, r1
add r5.xyz, r1, c17
pow r1, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r1
pow r5, c53.w, r12.y
pow r1, c53.w, r12.z
mov r12.y, r5
mov r12.z, r1
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r3, r1.xyzz, s2
mul r1.x, r3.w, c29
mad r17.xyz, r3.z, -c27, -r1.x
pow r12, c53.w, r17.x
pow r1, c53.w, r17.y
add r1.x, r11.w, -r16.y
mov r12.y, r1
mul r11.w, r1.x, r14
pow r1, c53.w, r17.z
add r1.x, r11.w, r14
rcp r1.y, r11.w
add r1.x, r1, -r15
add r1.w, -r14.x, r15.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r12.z, r1
mul r1.xyz, r12, r1.x
mov r1.w, c51.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r2.w, r5, -c25
mov r1.xyz, r5
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r9.w, r2, c51, r9
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s3
add r3.w, r1.x, c51.y
add r2.w, r5, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r5.w, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r5.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r9.w, r1.x, r1.z
endif
mul r12.xyz, r12, r9.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
rcp r3.z, r1.y
add r2.w, r1.x, c51
mul r3.w, r2, r3.z
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r3.w, r3, r3.z
dp3 r1.x, r5, r5
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.w, r1.x, r3
mul r1.xyz, r3.z, r5
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.w, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.z, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.z, r3, c54
mul r1.y, r3.z, r3.z
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r2.w, r3.y, c28.x
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r2.w, r1
mul r5.xyz, r11.w, -r5
mul r1.w, r1, r15.z
mul r2.w, r15, r2
mad r3.xyz, r1.w, c55.yzww, r2.w
mul r1.xyz, r1, c55.x
mad r1.xyz, r12, r3, r1
add r3.xyz, r1, c17
pow r1, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r1
pow r3, c53.w, r5.y
pow r1, c53.w, r5.z
mov r5.y, r3
mov r5.z, r1
mul r11.xyz, r11, r5
endif
add r1.x, r16, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c51, c51.w
cmp r1.y, -r0.z, c51.z, c51.w
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r11.w, -r1.y, r0.z, r0.y
cmp r14.w, -r1.y, r0, r1.x
mov r1.xyz, r10
cmp_pp r0.y, -r11.w, c51.z, c51.w
mov r14.x, r0
mov r10.xyz, c51.z
if_gt r0.y, c51.z
frc r0.x, r11.w
add r0.x, r11.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r16.y, r0.x, r0, -r0
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r0.xyz, r12, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r16.z, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r16.z, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r5, r0.xyzz, s2
mul r0.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r0.x
pow r0, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r0
pow r0, c53.w, r17.z
add r3.x, r14, r14.w
rcp r0.y, r14.w
add r0.w, -r14.x, r15.y
add r0.x, r3, -r15
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r17.z, r0
mul r0.xyz, r17, r0.x
mov r0.w, c51.z
mul r14.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r12
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r10.w, r1, c51, r10
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s3
add r3.z, r0.x, c51.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c51.w
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c51.y
mad r2.w, -r1, c54.x, c54.y
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c51
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.y, c54.x, c54.y
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0, r0.y
mul r10.w, r0.x, r0.z
endif
mul r14.xyz, r14, r10.w
endif
add r0.xyz, -r12, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
add r1.w, r0.x, c51
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r12.xyz, -r12, c18
dp3 r0.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r12
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c54.z
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c54.z
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c51.w
mul r0.w, r0.x, c54.z
mul r1.w, r5.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r12.xyz, r14.w, -r12
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r5.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r14, r5, r0
add r5.xyz, r0, c17
pow r0, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r0
pow r5, c53.w, r12.y
pow r0, c53.w, r12.z
mov r12.y, r5
mov r12.z, r0
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r3, r0.xyzz, s2
mul r0.x, r3.w, c29
mad r9.xyz, r3.z, -c27, -r0.x
pow r0, c53.w, r9.y
pow r12, c53.w, r9.x
add r0.x, r11.w, -r16.y
mul r11.w, r0.x, r14
mov r9.y, r0
pow r0, c53.w, r9.z
add r0.x, r11.w, r14
rcp r0.y, r11.w
add r0.x, r0, -r15
add r0.w, -r14.x, r15.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r9.x, r12
mov r9.z, r0
mul r0.xyz, r9, r0.x
mov r0.w, c51.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
mov r0.xyz, r5
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r9.w, r1, c51, r9
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s3
add r3.z, r0.x, c51.y
mul r1.w, r2, r1
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r5.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c51.y
mad r0.y, -r0.x, c54.x, c54
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c51.w
mad r1.w, r1, r3.z, c51
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r5.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.x, c54.x, c54.y
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r5.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0.y, r0
mul r9.w, r0.x, r0.z
endif
mul r12.xyz, r12, r9.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c51
mul r3.z, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.z, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.z, r0, c54
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c54.z
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c54.z
min r0.y, r3.z, c51.w
mul r1.w, r3.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r5.xyz, r11.w, -r5
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r3.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r12, r3, r0
add r3.xyz, r0, c17
pow r0, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r0
pow r3, c53.w, r5.y
pow r0, c53.w, r5.z
mov r5.y, r3
mov r5.z, r0
mul r11.xyz, r11, r5
endif
mov r0, c36
mov r3, c37
add r0, -c40, r0
mad r0, r8.w, r0, c40
dp4 r8.x, r0, c51.w
add r3, -c41, r3
mad r3, r8.w, r3, c41
dp4 r0.x, r0, r0
mov r5, c39
mov r9, c38
add r5, -c43, r5
mad r5, r8.w, r5, c43
add r9, -c42, r9
mad r9, r8.w, r9, c42
dp4 r8.y, r3, c51.w
dp4 r8.w, r5, c51.w
dp4 r8.z, r9, c51.w
add r8, r8, c51.y
dp4 r0.y, r3, r3
dp4 r0.z, r9, r9
dp4 r0.w, r5, r5
mad r0, r0, r8, c51.w
mad r1.xyz, r10, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r13
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r0.xyz, r0.z, c58, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c56.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul r1.y, r0.w, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
min r0.x, r0, c56.w
add r0.z, r0.x, c57.w
cmp r0.z, r0, c51.w, c51
mul_pp r1.x, r0.z, c58.w
add r0.x, r0, -r1
mul r1.x, r0, c59
frc r0.w, r1.x
add r0.w, r1.x, -r0
mul_pp r1.x, r0.w, c59.z
mul r2.xyz, r11.y, c56
mad r2.xyz, r11.x, c57, r2
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.w, c59.y
exp_pp r0.w, r0.x
mad_pp r0.x, -r0.z, c51, c51.w
mul_pp r0.x, r0, r0.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r1
abs_pp r0.z, r0.x
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
mad r1.xyz, r11.z, c58, r2
add r2.x, r1, r1.y
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c51.y
add r1.z, r1, r2.x
mul_pp r0.z, r0, c61.x
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r2.x, r1.z, c56.w
mul r0.z, r0, c61.y
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c60.w
frc r2.y, r2.x
add r0.w, r2.x, -r2.y
min r0.w, r0, c56
add r2.x, r0.w, c57.w
mul r1.w, r1, c55.x
frc r2.y, r1.w
add r1.w, r1, -r2.y
cmp r2.x, r2, c51.w, c51.z
mul_pp r0.z, r0, c59
cmp_pp r0.x, -r0, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r2.x, c58.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c61.w
mul r1.x, r0.w, c59
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c59
add r0.w, r0, -r1.z
min r1.w, r1, c59
mad r1.z, r0.w, c60.x, r1.w
add_pp r0.w, r1.x, c59.y
exp_pp r1.x, r0.w
mad_pp r0.w, -r2.x, c51.x, c51
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c60.y, c60
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r2.x, r1.w
add_pp r1.w, r1, -r2.x
exp_pp r2.x, -r1.w
mad_pp r1.z, r1, r2.x, c51.y
mul r0.x, r0, c61.z
add r0.w, -r0.x, -r0.z
add r0.w, r0, c51
mul r2.xyz, r0.y, c62
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c61.x
mul r2.w, r0.z, c61.y
mad r0.xyz, r0.x, c63, r2
add_pp r1.z, r1.w, c60.w
frc r2.x, r2.w
mad r0.xyz, r0.w, c64, r0
add r1.w, r2, -r2.x
mul_pp r1.z, r1, c59
cmp_pp r1.x, -r1, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.z
mul r1.z, r2.x, c61.w
add r1.x, r1, r1.w
mul r1.x, r1, c61.z
add r1.w, -r1.x, -r1.z
add r0.w, r1, c51
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r2.xyz, r1.y, c62
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c51.z
mad r2.xyz, r1.y, c63, r2
mul r0.w, r0, r1.x
mad r2.xyz, r0.w, c64, r2
add r1.xyz, -r0, c51.wzzw
max r2.xyz, r2, c51.z
mad r1.xyz, r1, c48.x, r0
mad r2.xyz, -r2, c48.x, r2
else
add r2.xy, r7, c49.xzzw
add r1.xy, r2, c49.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s4
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r2.z, r1.w
add_pp r1.w, r1, -r2.z
exp_pp r2.z, -r1.w
mad_pp r1.z, r1, r2, c51.y
mul_pp r1.z, r1, c61.x
mul r2.z, r1, c61.y
add_pp r1.z, r1.w, c60.w
frc r2.w, r2.z
add r1.w, r2.z, -r2
add r8.xy, r1, -c49.xzzw
mul r2.z, r2.w, c61.w
mul_pp r1.z, r1, c59
cmp_pp r0.y, -r0, c51.w, c51.z
mad_pp r0.y, r0, c58.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c61.z
add r2.w, -r0.y, -r2.z
mov r8.z, r7
texldl r1, r8.xyzz, s4
abs_pp r3.x, r1.y
log_pp r3.y, r3.x
frc_pp r3.z, r3.y
add_pp r3.w, r3.y, -r3.z
add r2.w, r2, c51
mul r2.w, r2, r0.x
rcp r2.z, r2.z
mul r0.y, r0, r0.x
mul r2.w, r2, r2.z
exp_pp r3.y, -r3.w
mul r0.y, r2.z, r0
mad_pp r2.z, r3.x, r3.y, c51.y
mul r3.xyz, r0.x, c62
mad r3.xyz, r0.y, c63, r3
mul_pp r0.x, r2.z, c61
mul r0.y, r0.x, c61
mad r3.xyz, r2.w, c64, r3
frc r2.z, r0.y
add r2.w, r0.y, -r2.z
add_pp r0.x, r3.w, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r1.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r2.w
mul r0.y, r2.z, c61.w
mul r0.x, r0, c61.z
add r1.y, -r0.x, -r0
add r1.y, r1, c51.w
mov r2.z, r7
texldl r2, r2.xyzz, s4
abs_pp r3.w, r2.y
log_pp r4.x, r3.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r4.y, r4.x
add_pp r0.y, r4.x, -r4
mul r4.xyz, r1.x, c62
mad r4.xyz, r0.x, c63, r4
exp_pp r1.x, -r0.y
mad_pp r0.x, r3.w, r1, c51.y
mad r4.xyz, r1.y, c64, r4
mul_pp r0.x, r0, c61
mul r1.x, r0, c61.y
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r2.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r1
max r4.xyz, r4, c51.z
max r3.xyz, r3, c51.z
add r5.xyz, r3, -r4
texldl r3, r7.xyzz, s4
add r7.xy, r8, -c49.zyzw
mul r1.x, r0, c61.z
mul r1.y, r1, c61.w
add r2.y, -r1.x, -r1
mul r0.xy, r7, c50
frc r0.xy, r0
mad r5.xyz, r0.x, r5, r4
abs_pp r4.x, r3.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r2.y, r2, c51.w
mul r2.y, r2, r2.x
rcp r1.y, r1.y
mul r1.x, r1, r2
mul r2.y, r2, r1
exp_pp r4.y, -r4.w
mul r1.x, r1.y, r1
mad_pp r1.y, r4.x, r4, c51
mul r4.xyz, r2.x, c62
mad r4.xyz, r1.x, c63, r4
mad r4.xyz, r2.y, c64, r4
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
frc r2.x, r1.y
add r2.y, r1, -r2.x
add_pp r1.x, r4.w, c60.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.y, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
rcp r2.y, r1.y
mul r1.x, r1, r3
add r2.x, r2, c51.w
mul r1.y, r2.x, r3.x
abs_pp r2.x, r2.w
mul r1.y, r1, r2
log_pp r3.y, r2.x
mul r1.x, r2.y, r1
frc_pp r2.y, r3
mul r8.xyz, r3.x, c62
mad r8.xyz, r1.x, c63, r8
add_pp r2.y, r3, -r2
exp_pp r1.x, -r2.y
mad r8.xyz, r1.y, c64, r8
mad_pp r1.x, r2, r1, c51.y
mul_pp r1.x, r1, c61
mul r1.y, r1.x, c61
frc r2.x, r1.y
add_pp r1.x, r2.y, c60.w
add r2.y, r1, -r2.x
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r2.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
abs_pp r2.y, r3.w
log_pp r3.x, r2.y
frc_pp r3.y, r3.x
add_pp r3.x, r3, -r3.y
max r8.xyz, r8, c51.z
max r4.xyz, r4, c51.z
add r4.xyz, r4, -r8
mad r4.xyz, r0.x, r4, r8
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
add r2.x, r2, c51.w
mul r2.x, r2.z, r2
rcp r1.y, r1.y
mul r2.w, r2.x, r1.y
mul r1.x, r2.z, r1
exp_pp r2.x, -r3.x
mul r1.x, r1.y, r1
mad_pp r1.y, r2, r2.x, c51
mul r2.xyz, r2.z, c62
mad r2.xyz, r1.x, c63, r2
mad r2.xyz, r2.w, c64, r2
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
max r8.xyz, r2, c51.z
frc r2.w, r1.y
add_pp r1.x, r3, c60.w
add r3.x, r1.y, -r2.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
mul r1.y, r2.w, c61.w
add r1.x, r1, r3
mul r1.x, r1, c61.z
add r2.w, -r1.x, -r1.y
rcp r2.y, r1.y
add r2.x, r2.w, c51.w
mul r1.y, r3.z, r2.x
mul r3.x, r1.y, r2.y
mul r1.y, r3.z, r1.x
mul r3.y, r2, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r3.w, r1.y, -r2
exp_pp r1.y, -r3.w
mad_pp r1.x, r1, r1.y, c51.y
mul_pp r1.y, r1.x, c61.x
abs_pp r1.x, r0.w
mul r4.w, r1.y, c61.y
frc r5.w, r4
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r1.y, r1, -r2.w
exp_pp r2.w, -r1.y
mad_pp r1.x, r1, r2.w, c51.y
mul r2.xyz, r3.z, c62
mad r2.xyz, r3.y, c63, r2
mad r2.xyz, r3.x, c64, r2
max r2.xyz, r2, c51.z
add r3.xyz, r8, -r2
add_pp r3.w, r3, c60
add r4.w, r4, -r5
mad r2.xyz, r0.x, r3, r2
mul_pp r3.w, r3, c59.z
cmp_pp r1.w, -r1, c51, c51.z
mad_pp r1.w, r1, c58, r3
add r1.w, r1, r4
mul r3.w, r1, c61.z
mul r4.w, r5, c61
mul_pp r1.x, r1, c61
mul r1.w, r1.x, c61.y
add_pp r1.x, r1.y, c60.w
frc r2.w, r1
add r1.y, r1.w, -r2.w
add r5.w, -r3, -r4
mul r8.x, r1.z, r3.w
rcp r3.w, r4.w
mul r4.w, r3, r8.x
mul r1.w, r2, c61
mul_pp r1.x, r1, c59.z
cmp_pp r0.w, -r0, c51, c51.z
mad_pp r0.w, r0, c58, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c61.z
add r1.x, -r0.w, -r1.w
add r1.y, r5.w, c51.w
add r2.w, r1.x, c51
mul r5.w, r1.z, r1.y
mul r1.xyz, r1.z, c62
mul r3.w, r5, r3
mad r1.xyz, r4.w, c63, r1
mad r1.xyz, r3.w, c64, r1
mul r3.w, r0.z, r0
mul r2.w, r0.z, r2
rcp r0.w, r1.w
mul r8.xyz, r0.z, c62
mul r0.z, r0.w, r3.w
mad r8.xyz, r0.z, c63, r8
mul r0.z, r2.w, r0.w
mad r8.xyz, r0.z, c64, r8
max r1.xyz, r1, c51.z
max r8.xyz, r8, c51.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r3.xyz, r1, -r2
add r5.xyz, r5, -r4
mad r1.xyz, r0.y, r5, r4
mad r2.xyz, r0.y, r3, r2
endif
mov r0.x, c8.w
mul r0.x, c52.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s5
else
mov r0.xyz, c51.z
endif
mul r2.xyz, r2, r6.w
mad r0.xyz, r0, r2, r6
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r1.xyz, r0.z, c58, r1
add r0.x, r1, r1.y
add r0.x, r1.z, r0
rcp r0.x, r0.x
mul r0.zw, r1.xyxy, r0.x
mul r0.x, r0.z, c56.w
frc r0.y, r0.x
add r0.x, r0, -r0.y
min r0.x, r0, c56.w
add r0.y, r0.x, c57.w
cmp r1.x, r0.y, c51.w, c51.z
mul_pp r0.y, r1.x, c58.w
add r1.z, r0.x, -r0.y
mul r0.x, r1.z, c59
frc r0.y, r0.x
add r1.w, r0.x, -r0.y
mul r3.xyz, r2.y, c56
mad r0.xyz, r2.x, c57, r3
mad r0.xyz, r2.z, c58, r0
add_pp r2.x, r1.w, c59.y
add r2.y, r0.x, r0
add r2.y, r0.z, r2
exp_pp r2.x, r2.x
mad_pp r1.x, -r1, c51, c51.w
mul_pp r0.z, r1.x, r2.x
rcp r2.x, r2.y
mul_pp r1.x, r1.w, c59.z
mul r2.xy, r0, r2.x
add r0.x, r1.z, -r1
mul r1.z, r2.x, c56.w
mul r0.w, r0, c55.x
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r0.w, r0, c59
mad r0.x, r0, c60, r0.w
mad r0.x, r0, c60.y, c60.z
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c56.w
add r1.z, r1.x, c57.w
cmp r0.w, r1.z, c51, c51.z
mov_pp oC0.x, r1.y
mul_pp r1.z, r0.w, c58.w
mul_pp oC0.y, r0.z, r0.x
add r0.x, r1, -r1.z
mul r0.z, r0.x, c59.x
frc r1.x, r0.z
add r0.z, r0, -r1.x
mul_pp r1.x, r0.z, c59.z
mul r1.y, r2, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.z, c59.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r0.w, c51, c51.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r1.x
mov_pp oC0.z, r0.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 compose sky with 1 cloud layer
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
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 1 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 4 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 3 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 6 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 2 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 5 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[65] = { program.local[0..50],
		{ 1, 0, 2, -1 },
		{ -1000000, 0.995, 1000000, 0.001 },
		{ 0.75, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625, 1024, 0.00390625 },
		{ 0.0047619049, 0.63999999, 0 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 } };
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
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[9];
MOVR  R3.x, c[52];
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].z, -R0;
MOVR  R0.z, c[51].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[13].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[51].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.w, R2, R1;
MOVR  R0, c[24];
MULR  R3.z, R3.w, R3.w;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.w, R1;
MOVR  R0.x, c[52];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.w, R0.y;
MOVR  R0.y, c[52].x;
MOVXC RC.y, R2;
MOVXC RC.z, R2.w;
MOVR  R2, c[42];
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.w, R0.z;
MOVR  R0.z, c[52].x;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.w, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[35];
SGER  H0.x, c[51].y, R0;
ADDR  R2, -R2, c[38];
MADR  R5, H0.x, R2, c[42];
MOVR  R0, c[41];
ADDR  R0, -R0, c[37];
MADR  R7, H0.x, R0, c[41];
MOVR  R0, c[40];
ADDR  R0, -R0, c[36];
MADR  R6, H0.x, R0, c[40];
MOVR  R2, c[43];
ADDR  R2, -R2, c[39];
MADR  R4, H0.x, R2, c[43];
MOVR  R0.yzw, c[51].x;
MOVR  R0.x, R8.w;
DP4R  R1.z, R0, R5;
DP4R  R1.w, R0, R4;
DP4R  R1.y, R0, R7;
DP4R  R1.x, R0, R6;
DP4R  R0.w, R4, R4;
DP4R  R0.z, R5, R5;
MOVR  R3.x, R8.y;
MOVR  R3.yzw, c[51].y;
DP4R  R8.y, R4, R3;
DP4R  R0.y, R7, R7;
DP4R  R0.x, R6, R6;
MADR  R0, R1, R0, -R0;
ADDR  R2, R0, c[51].x;
MULR  R0.x, R2, R2.y;
MULR  R8.w, R0.x, R2.z;
MOVR  R1.yzw, c[51].y;
MOVR  R1.x, R8;
DP4R  R8.x, R4, R1;
MOVR  R0.yzw, c[51].y;
MOVR  R0.x, R8.z;
DP4R  R8.z, R4, R0;
DP4R  R4.x, R5, R1;
DP4R  R4.z, R5, R0;
DP4R  R4.y, R5, R3;
DP4R  R5.x, R7, R1;
DP4R  R1.x, R6, R1;
DP4R  R5.z, R7, R0;
DP4R  R1.z, R6, R0;
DP4R  R5.y, R7, R3;
MADR  R4.xyz, R2.z, R8, R4;
DP4R  R1.y, R6, R3;
MADR  R4.xyz, R2.y, R4, R5;
MADR  R2.xyz, R2.x, R4, R1;
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[49].xyxz;
ADDR  R0.xy, R1.zwzw, c[49].zyzw;
ADDR  R0.zw, R0.xyxy, -c[49].xyxz;
TEX   R0.x, R0, texture[2], 2D;
TEX   R1.x, R0.zwzw, texture[2], 2D;
ADDR  R0.y, R1.x, -R0.x;
ADDR  R15.xy, R0.zwzw, -c[49].zyzw;
MULR  R0.zw, R15.xyxy, c[50].xyxy;
FRCR  R0.zw, R0;
MADR  R0.x, R0.z, R0.y, R0;
TEX   R1.x, fragment.texcoord[0], texture[2], 2D;
TEX   R3.x, R1.zwzw, texture[2], 2D;
ADDR  R1.y, R3.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[8].w, -c[8];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[8].w;
TEX   R0.x, fragment.texcoord[0], texture[1], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[8];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R7.w, R0.z, R0.x;
ADDR  R0.x, R7.w, -R0.y;
SGTRC HC.x, |R0|, c[47];
MULR  R2.w, R8, R2;
IF    NE.x;
MOVR  R5.w, c[52].x;
MOVR  R5.x, c[52];
MOVR  R5.z, c[52].x;
MOVR  R5.y, c[52].x;
MOVR  R4.x, c[52].z;
MULR  R1.xy, R15, c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].z, -R0;
MOVR  R0.z, c[51].w;
DP3R  R0.w, R0, R0;
RSQR  R8.x, R0.w;
MULR  R0.xyz, R8.x, R0;
MOVR  R0.w, c[51].y;
DP4R  R6.z, R0, c[2];
DP4R  R6.y, R0, c[1];
DP4R  R6.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R1.x, c[0].w;
MOVR  R1.z, c[2].w;
MOVR  R1.y, c[1].w;
MULR  R9.xyz, R1, c[13].x;
ADDR  R7.xyz, R9, -c[9];
DP3R  R4.z, R6, R7;
MULR  R4.y, R4.z, R4.z;
DP3R  R4.w, R7, R7;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R5.x(EQ), R9.w;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R5.x(NE.z), -R4.z, R1;
MOVXC RC.z, R3;
MOVR  R5.z(EQ), R9.w;
MOVXC RC.z, R3.w;
RCPR  R0.x, R0.x;
ADDR  R5.z(NE.y), -R4, R0.x;
MOVXC RC.y, R3;
RSQR  R0.x, R1.w;
MOVR  R5.w(EQ.z), R9;
RCPR  R0.x, R0.x;
ADDR  R5.w(NE), -R4.z, R0.x;
RSQR  R0.x, R1.y;
MOVR  R5.y(EQ), R9.w;
RCPR  R0.x, R0.x;
ADDR  R5.y(NE.x), -R4.z, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R4.x(EQ), R9.w;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
MADR  R3.x, -c[12], c[12], R4.w;
ADDR  R0.z, R4.y, -R3.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R4.z, -R1;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R1.x, c[52].z;
MOVXC RC.z, R3;
MOVR  R1.x(EQ.z), R9.w;
RCPR  R0.x, R0.x;
ADDR  R1.x(NE.y), -R4.z, -R0;
RSQR  R0.x, R1.w;
MOVXC RC.y, R3;
MOVR  R1.w, c[52].z;
MOVR  R1.z, c[52];
MOVXC RC.z, R3.w;
ADDR  R0.w, -R4.z, -R0.z;
ADDR  R3.y, -R4.z, R0.z;
MAXR  R0.z, R0.w, c[51].y;
MAXR  R0.w, R3.y, c[51].y;
MOVR  R1.z(EQ), R9.w;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R4, -R0.x;
RSQR  R0.x, R1.y;
MOVR  R1.y, c[52].z;
MOVR  R1.w(EQ.y), R9;
RCPR  R0.x, R0.x;
ADDR  R1.w(NE.x), -R4.z, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R4.w;
SLTRC HC.x, R4.y, R0;
MOVR  R1.y(EQ.x), R9.w;
ADDR  R0.y, R4, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R4.w, R1.z;
SGERC HC.x, R4.y, R0;
RCPR  R0.y, R0.y;
ADDR  R1.y(NE.x), -R4.z, -R0;
MOVR  R4.z, R1.x;
MOVXC RC.x, R1.y;
DP4R  R1.x, R5, c[35];
SGER  R6.w, c[51].y, R1.x;
MOVR  R1.y(LT.x), c[52].z;
MOVR  R1.x, c[52].y;
MULR  R1.x, R1, c[8].w;
MOVR  R0.xy, c[51].y;
SLTRC HC.x, R4.y, R3;
MOVR  R0.xy(EQ.x), R10;
SGERC HC.x, R4.y, R3;
MOVR  R0.xy(NE.x), R0.zwzw;
MOVR  R4.y, R1.w;
MAXR  R1.w, R0.x, c[52];
SGER  H0.x, R7.w, R1;
DP4R  R0.z, R4, c[40];
DP4R  R0.w, R5, c[36];
ADDR  R0.w, R0, -R0.z;
MADR  R0.z, R6.w, R0.w, R0;
RCPR  R0.w, R8.x;
MULR  R0.w, R7, R0;
MADR  R1.y, -R0.w, c[13].x, R1;
MULR  R0.w, R0, c[13].x;
MADR  R0.w, H0.x, R1.y, R0;
MINR  R3.w, R0.y, R0;
ADDR  R1.z, R3.w, -R1.w;
RCPR  R0.x, R1.z;
MINR  R0.y, R3.w, R0.z;
MAXR  R11.y, R1.w, R0;
MULR  R8.w, R0.x, c[32].x;
ADDR  R1.y, R11, -R1.w;
MULR  R1.x, R8.w, R1.y;
RCPR  R3.y, c[32].x;
MULR  R11.w, R1.z, R3.y;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R6.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MOVR  R10.x, R0;
MOVR  R11.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R6.w, R0, c[46].y;
SLTR  H0.y, R1.x, R0.w;
SGTR  H0.x, R1, c[51].y;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R1.x;
RCPR  R3.x, R0.w;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R1.y, R3.x;
MOVR  R14.w(NE.x), R0;
MULR  R1.xyz, R7.zxyw, c[16].yzxw;
MADR  R1.xyz, R7.yzxw, c[16].zxyw, -R1;
DP3R  R0.w, R1, R1;
MULR  R3.xyz, R6.zxyw, c[16].yzxw;
MADR  R3.xyz, R6.yzxw, c[16].zxyw, -R3;
DP3R  R1.y, R1, R3;
DP3R  R1.x, R3, R3;
DP3R  R3.y, R7, c[16];
MADR  R0.w, -c[11].x, c[11].x, R0;
SLER  H0.y, R3, c[51];
MULR  R3.x, R1, R0.w;
MULR  R1.z, R1.y, R1.y;
ADDR  R0.w, R1.z, -R3.x;
SGTR  H0.z, R1, R3.x;
RCPR  R3.x, R1.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.z, -R1.y, R0.w;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVR  R1.z, c[52].x;
MOVR  R1.x, c[52].z;
ADDR  R0.w, -R1.y, -R0;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0.y;
MULR  R1.z(NE.x), R3.x, R3;
MULR  R1.x(NE), R0.w, R3;
MOVR  R1.y, R1.z;
MOVR  R16.xy, R1;
MADR  R1.xyz, R6, R1.x, R9;
ADDR  R1.xyz, R1, -c[9];
DP3R  R0.w, R1, c[16];
SGTR  H0.z, R0.w, c[51].y;
MULXC HC.x, H0.y, H0.z;
MOVR  R16.xy(NE.x), c[52].zxzw;
MOVXC RC.x, H0;
DP4R  R1.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R12.y, R11, R0.w;
DP4R  R1.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R13.y, R12, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R1.x, R5, c[39];
ADDR  R1.x, R1, -R0.w;
MADR  R0.w, R6, R1.x, R0;
MINR  R0.w, R3, R0;
DP3R  R0.y, R6, c[16];
MULR  R13.x, R0, c[33];
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[51].z;
MADR  R0.x, c[30], c[30], R0;
MADR  R15.z, R0.y, c[53].x, c[53].x;
ADDR  R0.y, R0.x, c[51].x;
MOVR  R0.x, c[51];
POWR  R0.y, R0.y, c[53].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R5.w, R13.y, R0;
MOVR  R12.x, R0.z;
MOVR  R12.w, R3;
MULR  R15.w, R0.x, R0.y;
MOVR  R8.xyz, c[51].x;
MOVR  R7.xyz, c[51].y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.y, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R11.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R13.y, -R12.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R12.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R5.w, -R13.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R12.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R12.x;
RCPR  R0.z, R12.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R12.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R13.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.w, -R5.w;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R13.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R13.x;
RCPR  R0.z, R13.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R13.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R5;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[3], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[4], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
MOVR  R1, c[41];
ADDR  R1, -R1, c[37];
MOVR  R0, c[40];
MOVR  R5, c[42];
ADDR  R5, -R5, c[38];
MADR  R3, R6.w, R1, c[41];
ADDR  R0, -R0, c[36];
MADR  R1, R6.w, R0, c[40];
TEX   R0.w, R15, texture[0], 2D;
MOVR  R4.x, R0.w;
MOVR  R4.yzw, c[51].x;
DP4R  R6.x, R4, R1;
DP4R  R1.x, R1, R1;
MADR  R5, R6.w, R5, c[42];
MOVR  R0, c[43];
ADDR  R0, -R0, c[39];
MADR  R0, R6.w, R0, c[43];
DP4R  R1.y, R3, R3;
DP4R  R1.w, R0, R0;
DP4R  R6.y, R4, R3;
DP4R  R1.z, R5, R5;
DP4R  R6.z, R4, R5;
DP4R  R6.w, R4, R0;
MADR  R0, R6, R1, -R1;
ADDR  R0, R0, c[51].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R12;
MADR  R1.xyz, R1, R0.y, R11;
MADR  R1.xyz, R1, R0.x, R10;
MULR  R0.xyz, R1.y, c[59];
MADR  R0.xyz, R1.x, c[58], R0;
MADR  R0.xyz, R1.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].z;
SGER  H0.x, R0, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[57].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[59].w;
ADDH  H0.y, H0, -c[58].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R8.y, c[59];
MADR  R1.xyz, R8.x, c[58], R1;
MADR  R1.xyz, R8.z, c[57], R1;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0.w, c[54].x;
MADR  R0.z, R0.x, c[60].x, R0;
MOVR  R0.x, c[51];
MADR  H0.z, R0, c[60].y, R0.x;
MADH  H0.x, H0, c[51].z, H0.y;
MULH  H0.x, H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
LG2H  H0.z, |H0.x|;
FLRH  H0.z, H0;
ADDH  H0.w, H0.z, c[58];
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R1.z, R0, c[56];
SGEH  H0.y, c[51], H0.x;
EX2H  H0.z, -H0.z;
MULH  H0.x, |H0|, H0.z;
MADH  H0.x, H0, c[60].z, -c[60].z;
MULR  R1.x, H0, c[60].w;
FLRR  R0.z, R1.x;
MULH  H0.w, H0, c[59];
MADH  H0.y, H0, c[56].w, H0.w;
ADDR  R0.z, H0.y, R0;
SGER  H0.x, R1.z, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R1.w, R1.z, -H0.y;
MULR  R1.z, R1.w, c[57].w;
FLRR  H0.y, R1.z;
MULH  H0.z, H0.y, c[59].w;
FRCR  R1.x, R1;
ADDH  H0.y, H0, -c[58].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.x, R1, c[61].y;
MULR  R0.z, R0, c[61].x;
ADDR  R1.z, -R0, -R1.x;
MADR  R1.z, R1, R0.y, R0.y;
MADH  H0.x, H0, c[51].z, H0.y;
ADDR  R1.w, R1, -H0.z;
MINR  R0.w, R0, c[54].x;
MADR  R0.w, R1, c[60].x, R0;
MADR  H0.z, R0.w, c[60].y, R0.x;
MULH  H0.x, H0, H0.z;
RCPR  R0.x, R1.x;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MULR  R0.z, R0, R0.y;
ADDH  H0.y, H0, c[58].w;
MULR  R0.w, R1.z, R0.x;
MULR  R1.x, R0, R0.z;
MULR  R0.xyz, R0.y, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R3.xyz, R0, c[51].y;
MADH  H0.z, H0, c[60], -c[60];
MULR  R1.x, H0.z, c[60].w;
FRCR  R0.w, R1.x;
MULR  R0.w, R0, c[61].y;
MULR  R0.xyz, R1.y, c[64];
FLRR  R1.x, R1;
MULH  H0.y, H0, c[59].w;
SGEH  H0.x, c[51].y, H0;
MADH  H0.x, H0, c[56].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.z, R1.x, c[61].x;
ADDR  R1.x, -R1.z, -R0.w;
MADR  R1.x, R1, R1.y, R1.y;
MULR  R1.z, R1, R1.y;
RCPR  R0.w, R0.w;
MULR  R1.y, R0.w, R1.z;
MADR  R0.xyz, R1.y, c[63], R0;
MULR  R0.w, R1.x, R0;
ADDR  R1.xyz, -R3, c[51].xyyw;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R0.xyz, R0, c[51].y;
MADR  R3.xyz, R1, c[48].x, R3;
MADR  R1.xyz, -R0, c[48].x, R0;
ELSE;
ADDR  R6.xy, R15, c[49].xzzw;
ADDR  R0.xy, R6, c[49].zyzw;
TEX   R4, R0, texture[5], 2D;
ADDR  R7.xy, R0, -c[49].xzzw;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R4|, H0;
MADH  H0.y, H0, c[60].z, -c[60].z;
MULR  R0.z, H0.y, c[60].w;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[61].y;
ADDH  H0.x, H0, c[58].w;
MULH  H0.z, H0.x, c[59].w;
SGEH  H0.xy, c[51].y, R4.ywzw;
TEX   R3, R7, texture[5], 2D;
MADH  H0.x, H0, c[56].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[61].x;
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[58].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R4.x;
MADR  R0.w, R0, R4.x, R4.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R4.x, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
MAXR  R1.xyz, R0, c[51].y;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[51].y, R3.xyyw;
MULR  R0.z, R0.x, c[61].y;
MULH  H0.x, H0, c[59].w;
RCPR  R3.y, R0.z;
MADH  H0.x, H0.z, c[56].w, H0;
FLRR  R0.y, R0.w;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[61];
MULR  R0.w, R0.x, R3.x;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R3.x, R3.x;
MULR  R1.w, R0.y, R3.y;
MULR  R0.xyz, R3.x, c[64];
MULR  R0.w, R3.y, R0;
MADR  R5.xyz, R0.w, c[63], R0;
TEX   R0, R6, texture[5], 2D;
MADR  R5.xyz, R1.w, c[62], R5;
MAXR  R6.xyz, R5, c[51].y;
ADDR  R5.xyz, R1, -R6;
TEX   R1, R15, texture[5], 2D;
ADDR  R15.xy, R7, -c[49].zyzw;
MULR  R3.xy, R15, c[50];
FRCR  R8.xy, R3;
MADR  R5.xyz, R8.x, R5, R6;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R4.x, H0.z, c[60].w;
ADDH  H0.x, H0, c[58].w;
SGEH  H1.xy, c[51].y, R0.ywzw;
MULH  H0.x, H0, c[59].w;
SGEH  H1.zw, c[51].y, R1.xyyw;
FRCR  R3.x, R4;
FLRR  R3.y, R4.x;
MADH  H0.x, H1, c[56].w, H0;
ADDR  R0.y, H0.x, R3;
MULR  R3.y, R3.x, c[61];
MULR  R3.x, R0.y, c[61];
ADDR  R0.y, -R3.x, -R3;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
RCPR  R3.y, R3.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R3.x, R3, R0;
MULR  R0.y, R0, R3;
MULR  R3.x, R3.y, R3;
MULR  R6.xyz, R0.x, c[64];
MADR  R6.xyz, R3.x, c[63], R6;
MADH  H0.z, H0, c[60], -c[60];
MADR  R6.xyz, R0.y, c[62], R6;
MULR  R0.x, H0.z, c[60].w;
FRCR  R0.y, R0.x;
MULR  R1.y, R0, c[61];
MADH  H0.x, H1.z, c[56].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.y, R0.x, c[61].x;
ADDR  R0.x, -R0.y, -R1.y;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
RCPR  R1.y, R1.y;
MADR  R0.x, R0, R1, R1;
MULR  R0.y, R0, R1.x;
MULR  R0.x, R0, R1.y;
MULR  R0.y, R1, R0;
MULR  R7.xyz, R1.x, c[64];
MADR  R7.xyz, R0.y, c[63], R7;
MADR  R7.xyz, R0.x, c[62], R7;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.x, H0.z, c[60].w;
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[51].y;
MAXR  R6.xyz, R6, c[51].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R8.x, R6, R7;
MADH  H0.x, H1.y, c[56].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
MULR  R0.y, R0, c[61];
MULR  R0.x, R0, c[61];
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
FRCR  R1.x, R0.w;
MULR  R1.y, R1.x, c[61];
RCPR  R3.x, R1.y;
MADH  H0.x, H1.w, c[56].w, H0;
FLRR  R0.w, R0;
ADDR  R0.w, H0.x, R0;
MULR  R1.x, R0.w, c[61];
ADDR  R0.w, -R1.x, -R1.y;
MADR  R0.w, R1.z, R0, R1.z;
MULR  R1.w, R1.z, R1.x;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULR  R0.w, R0, R3.x;
MULR  R1.w, R3.x, R1;
MULR  R1.xyz, R1.z, c[64];
MADR  R1.xyz, R1.w, c[63], R1;
MADR  R1.xyz, R0.w, c[62], R1;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
MULH  H0.x, H0, c[59].w;
MADH  H0.z, H0.w, c[56].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULH  H0.z, |R4.w|, H0;
MULR  R3.y, R1.w, c[61].x;
MULR  R3.x, R0.w, c[61].y;
ADDR  R4.x, -R3.y, -R3;
MADR  R4.y, R3.z, R4.x, R3.z;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
MULR  R3.w, R1, c[61].y;
MAXR  R1.xyz, R1, c[51].y;
MAXR  R0.xyz, R0, c[51].y;
ADDR  R0.xyz, R0, -R1;
RCPR  R4.x, R3.x;
MULR  R4.w, R3.z, R3.y;
MULR  R4.w, R4.x, R4;
MULR  R3.xyz, R3.z, c[64];
MADR  R0.xyz, R8.x, R0, R1;
MADR  R3.xyz, R4.w, c[63], R3;
MULR  R4.x, R4.y, R4;
MADR  R3.xyz, R4.x, c[62], R3;
MAXR  R3.xyz, R3, c[51].y;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[56].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R1.w, R0, c[61].x;
ADDR  R0.w, -R1, -R3;
MULR  R4.w, R4.z, R1;
MADR  R0.w, R4.z, R0, R4.z;
RCPR  R1.w, R3.w;
MULR  R4.xyz, R4.z, c[64];
MULR  R3.w, R1, R4;
MADR  R4.xyz, R3.w, c[63], R4;
MULR  R0.w, R0, R1;
MADR  R4.xyz, R0.w, c[62], R4;
MAXR  R4.xyz, R4, c[51].y;
ADDR  R4.xyz, R4, -R3;
MADR  R1.xyz, R8.x, R4, R3;
ADDR  R1.xyz, R1, -R0;
MADR  R3.xyz, R8.y, R5, R6;
MADR  R1.xyz, R8.y, R1, R0;
ENDIF;
MOVR  R0.x, c[52].y;
MULR  R0.x, R0, c[8].w;
SGTRC HC.x, R7.w, R0;
IF    NE.x;
TEX   R0.xyz, R15, texture[6], 2D;
ELSE;
MOVR  R0.xyz, c[51].y;
ENDIF;
MULR  R1.xyz, R1, R2.w;
MADR  R0.xyz, R0, R1, R2;
ADDR  R2.xyz, R0, R3;
MULR  R0.xyz, R2.y, c[59];
MADR  R0.xyz, R2.x, c[58], R0;
MADR  R0.xyz, R2.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[59];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].z;
SGER  H0.x, R0, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[57].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[58].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[59].w;
MADR  R2.xyz, R1.x, c[58], R2;
MADR  R1.xyz, R1.z, c[57], R2;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[56].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[51].z, H0.z;
MINR  R0.z, R1, c[56];
SGER  H0.z, R0, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[56].w;
MINR  R0.w, R0, c[54].x;
MADR  R0.x, R0, c[60], R0.w;
ADDR  R0.z, R0, -H0.y;
MOVR  R1.x, c[51];
MADR  H0.y, R0.x, c[60], R1.x;
MULR  R0.w, R0.z, c[57];
FLRR  H0.w, R0;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[59].w;
ADDR  R0.x, R0.z, -H0;
ADDH  H0.x, H0.w, -c[58].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[54].x;
MADR  R0.x, R0, c[60], R0.y;
MADR  H0.z, R0.x, c[60].y, R1.x;
MADH  H0.x, H0.y, c[51].z, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 1 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 4 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 3 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 6 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 2 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 5 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c51, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c52, -1000000.00000000, 0.99500000, 1000000.00000000, 0.00100000
def c53, 0.75000000, 1.50000000, 0.50000000, 2.71828198
defi i0, 255, 0, 1, 0
def c54, 2.00000000, 3.00000000, 1000.00000000, 10.00000000
def c55, 400.00000000, 5.60204458, 9.47328472, 19.64380264
def c56, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c57, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c58, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c59, 0.25000000, -15.00000000, 4.00000000, 255.00000000
def c60, 256.00000000, 0.00097656, 1.00000000, 15.00000000
def c61, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c62, -1.02170002, 1.97770000, 0.04390000, 0
def c63, 2.56509995, -1.16649997, -0.39860001, 0
def c64, 0.07530000, -0.25430000, 1.18920004, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c51.x, c51.y
mov r3, c39
texldl r8, v0, s0
add r3, -c43, r3
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c51.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
add r0.y, c24, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c13.x
add r2.xyz, r2, -c9
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c24, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
cmp r0.x, r0, r1.w, c52
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c51.w, c51.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c52.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c11.x
add r1.y, c24.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c51, c51.z
cmp r1.z, r1, r1.w, c52.x
cmp r0.w, -r0, r1.z, r2.x
cmp_pp r0.z, r1.x, c51.w, c51
cmp r1.x, r1, r1.w, c52
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c35
cmp r6.x, -r0, c51.w, c51.z
mad r7, r6.x, r3, c43
mov r1, c37
add r1, -c41, r1
mov r0, c36
add r0, -c40, r0
mad r4, r6.x, r0, c40
mov r2, c38
mad r5, r6.x, r1, c41
add r2, -c42, r2
mad r6, r6.x, r2, c42
mov r0.yzw, c51.w
mov r0.x, r8.w
dp4 r1.w, r7, r0
dp4 r1.z, r6, r0
dp4 r1.y, r5, r0
dp4 r1.x, r4, r0
dp4 r0.w, r7, r7
mov r3.yzw, c51.z
mov r3.x, r8
dp4 r8.x, r7, r3
mov r2.yzw, c51.z
mov r2.x, r8.y
dp4 r8.y, r7, r2
dp4 r0.z, r6, r6
add r1, r1, c51.y
dp4 r0.y, r5, r5
dp4 r0.x, r4, r4
mad r0, r0, r1, c51.w
mov r1.yzw, c51.z
mov r1.x, r8.z
dp4 r8.z, r7, r1
dp4 r7.x, r6, r3
dp4 r7.z, r6, r1
dp4 r7.y, r6, r2
mad r6.xyz, r0.z, r8, r7
dp4 r7.x, r5, r3
dp4 r3.x, r4, r3
dp4 r7.z, r5, r1
dp4 r7.y, r5, r2
dp4 r3.y, r4, r2
mad r5.xyz, r0.y, r6, r7
dp4 r3.z, r4, r1
mad r6.xyz, r0.x, r5, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r2.xy, v0, c49.xzzw
add r0.xy, r2, c49.zyzw
add r3.xy, r0, -c49.xzzw
mov r0.z, v0.w
mov r3.z, v0.w
mov r2.z, v0.w
add r7.xy, r3, -c49.zyzw
mul r1.zw, r7.xyxy, c50.xyxy
texldl r0.x, r0.xyzz, s2
texldl r1.x, r3.xyzz, s2
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s2
texldl r2.x, r2.xyzz, s2
add r0.z, r2.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c8.w, -c8.z
rcp r0.y, r0.x
mul r0.y, r0, c8.w
texldl r0.x, v0, s1
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c8.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r6.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c47.x
mad r0.xy, r7, c51.x, c51.y
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.x, r0.w
mul r0.xyz, r2.x, r0
mov r0.w, c51.z
dp4 r8.z, r0, c2
dp4 r8.y, r0, c1
dp4 r8.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
mul r11.xyz, r8.zxyw, c16.yzxw
mad r11.xyz, r8.yzxw, c16.zxyw, -r11
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r9.xyz, r1, c13.x
add r5.xyz, r9, -c9
dp3 r2.y, r8, r5
dp3 r2.z, r5, r5
add r0.y, c25, r0
mad r0.z, -r0.y, r0.y, r2
mad r0.w, r2.y, r2.y, -r0.z
rsq r1.x, r0.w
add r0.x, c25, r0
mad r0.x, -r0, r0, r2.z
mad r0.x, r2.y, r2.y, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2.y, -r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
rcp r1.x, r1.x
cmp r0.x, r0, r9.w, c52.z
cmp r0.x, -r0.y, r0, r0.z
cmp_pp r0.y, r0.w, c51.w, c51.z
add r1.x, -r2.y, -r1
cmp r0.w, r0, r9, c52.z
cmp r0.y, -r0, r0.w, r1.x
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.x, c25.w, r0.z
mad r0.w, -r0, r0, r2.z
mad r0.z, r2.y, r2.y, -r0.w
mad r1.x, -r1, r1, r2.z
mad r1.y, r2, r2, -r1.x
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r2.y, -r0.w
cmp_pp r0.w, r0.z, c51, c51.z
rsq r1.z, r1.y
rcp r1.z, r1.z
cmp r0.z, r0, r9.w, c52
cmp r0.z, -r0.w, r0, r1.x
add r1.z, -r2.y, -r1
cmp r1.x, r1.y, r9.w, c52.z
cmp_pp r0.w, r1.y, c51, c51.z
cmp r0.w, -r0, r1.x, r1.z
mov r1.x, c11
add r1.y, c24.x, r1.x
mov r1.x, c11
add r1.z, c24.y, r1.x
mad r1.y, -r1, r1, r2.z
mad r1.x, r2.y, r2.y, -r1.y
mad r1.z, -r1, r1, r2
mad r1.w, r2.y, r2.y, -r1.z
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r2.y, r1.y
cmp_pp r1.y, r1.x, c51.w, c51.z
rsq r3.x, r1.w
rcp r3.x, r3.x
cmp r1.x, r1, r9.w, c52
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c51.w, c51.z
dp4 r2.w, r0, c41
dp4 r3.w, r0, c40
add r3.x, -r2.y, r3
cmp r1.w, r1, r9, c52.x
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c11.x
add r1.w, c24, r1.z
mad r1.w, -r1, r1, r2.z
mad r3.y, r2, r2, -r1.w
rsq r1.w, r3.y
rcp r3.x, r1.w
mov r1.z, c11.x
add r1.z, c24, r1
mad r1.z, -r1, r1, r2
mad r1.z, r2.y, r2.y, -r1
add r3.z, -r2.y, r3.x
rsq r1.w, r1.z
rcp r3.x, r1.w
cmp_pp r1.w, r3.y, c51, c51.z
cmp r3.y, r3, r9.w, c52.x
cmp r1.w, -r1, r3.y, r3.z
add r3.y, -r2, r3.x
cmp_pp r3.x, r1.z, c51.w, c51.z
cmp r1.z, r1, r9.w, c52.x
cmp r1.z, -r3.x, r1, r3.y
dp4 r3.x, r1, c37
dp4 r3.y, r1, c35
add r3.z, r3.x, -r2.w
cmp r8.w, -r3.y, c51, c51.z
mad r3.y, r8.w, r3.z, r2.w
dp4 r3.z, r1, c36
add r4.x, r3.z, -r3.w
mov r3.x, c11
add r3.x, c31, r3
mad r3.x, -r3, r3, r2.z
mad r2.w, r2.y, r2.y, -r3.x
rsq r3.x, r2.w
rcp r3.x, r3.x
add r3.z, -r2.y, -r3.x
cmp_pp r3.x, r2.w, c51.w, c51.z
cmp r2.w, r2, r9, c52.z
cmp r2.w, -r3.x, r2, r3.z
rcp r2.x, r2.x
mul r3.x, r7.w, r2
cmp r2.w, r2, r2, c52.z
mad r3.z, -r3.x, c13.x, r2.w
mad r2.z, -c12.x, c12.x, r2
mad r2.z, r2.y, r2.y, -r2
rsq r2.w, r2.z
mov r2.x, c8.w
mad r2.x, c52.y, -r2, r7.w
mad r3.w, r8, r4.x, r3
rcp r2.w, r2.w
mul r3.x, r3, c13
cmp r2.x, r2, c51.w, c51.z
mad r3.z, r2.x, r3, r3.x
add r2.x, -r2.y, -r2.w
add r2.y, -r2, r2.w
cmp_pp r3.x, r2.z, c51.w, c51.z
cmp r2.zw, r2.z, r10.xyxy, c51.z
mul r10.xyz, r5.zxyw, c16.yzxw
mad r10.xyz, r5.yzxw, c16.zxyw, -r10
max r2.x, r2, c51.z
max r2.y, r2, c51.z
cmp r2.xy, -r3.x, r2.zwzw, r2
min r3.x, r2.y, r3.z
dp4 r2.z, r0, c42
dp4 r0.y, r0, c43
dp4 r0.x, r1, c39
max r14.x, r2, c52.w
add r0.z, r0.x, -r0.y
min r2.y, r3.x, r3.w
max r4.x, r14, r2.y
dp4 r2.y, r1, c38
add r2.y, r2, -r2.z
mad r2.y, r8.w, r2, r2.z
min r2.x, r3, r3.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
min r0.x, r3, r2.y
max r2.x, r4, r2
mad r0.y, r8.w, r0.z, r0
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r8, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r14.x
rcp r0.z, r0.y
rcp r2.z, r1.w
add r1.y, r4.x, -r14.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c51.z, c51.w
cmp r0.w, -r1.z, c51.z, c51
mul_pp r2.y, r0.w, r2
cmp r11.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r14.w, -r2.y, r0, r1.y
dp3 r0.y, r10, r10
dp3 r1.y, r10, r11
dp3 r1.z, r11, r11
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
rsq r2.z, r1.w
dp3 r0.y, r5, c16
cmp r0.y, -r0, c51.w, c51.z
cmp r1.w, -r1, c51.z, c51
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c52, r1
mad r5.xyz, r8, r1.z, r9
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c52.x, r1
cmp r1.y, -r1, c51.z, c51.w
mul_pp r0.y, r0, r1
cmp r15.xy, -r0.y, r1.zwzw, c52.zxzw
mad r2.w, r8, r2, c45.y
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r8.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r8.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r8.w, r0, c46
dp3 r2.z, r8, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c51.w
mul r2.w, r2, c51.x
mad r2.w, c30.x, c30.x, r2
mul r15.z, r2, c53.x
mov r2.z, c30.x
add r2.z, c51.w, r2
add r2.w, r2, c51
mov r16.x, r3
pow r3, r2.w, c53.y
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r11.w, c51.z, c51.w
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r15.w, r2.z, r2
mov r11.xyz, c51.w
mov r10.xyz, c51.z
if_gt r2.y, c51.z
frc r2.y, r11.w
add r2.y, r11.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r16.y, r2, r2.z, -r2.z
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r16.z, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r16, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s3
mul r2.y, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r2.y
pow r13, c53.w, r17.x
pow r3, c53.w, r17.y
mov r13.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.w, -r14.x, r15.y
rcp r2.z, r14.w
add r2.y, r3.x, -r15.x
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r3
mul r13.xyz, r13, r2.y
mov r2.y, c51.z
mul r14.xyz, r13, c15
if_gt c34.x, r2.y
add r3.y, r16.z, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r12
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r10.w, r2.y, c51, r10
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s4
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r13.x, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c54.x, c54
mul r2.w, r2, r2
add r3.z, r13.w, c51.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c51
mul r2.y, r2, r2.z
mul r10.w, r2.y, r2
endif
mul r14.xyz, r14, r10.w
endif
add r13.xyz, -r12, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
add r13.xyz, -c21, r13
dp3 r3.z, r13, r13
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r12.xyz, -r12, c18
dp3 r3.y, r12, r12
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r12.xyz, r3.y, r12
dp3 r2.y, r12, r8
mul r3.z, r3, c54
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r12.xyz, c19
add r2.y, r2, c51.w
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c54.z
add r12.xyz, -c18, r12
dp3 r2.z, r12, r12
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c54.z
min r2.w, r2.y, c51
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c54.z
mul r2.z, r5.y, c28.x
min r2.y, r2, c51.w
mul r12.xyz, r2.w, c23
mad r12.xyz, r2.y, c20, r12
mul r2.y, r5, c29.x
mad r13.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r12.xyz, r12, c54.w
mul r12.xyz, r2.z, r12
mul r12.xyz, r12, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r5.xyz, r2.y, c55.yzww, r2.z
mad r5.xyz, r14, r5, r12
mul r12.xyz, r14.w, -r13
add r13.xyz, r5, c17
pow r5, c53.w, r12.x
mul r13.xyz, r13, r14.w
mad r10.xyz, r13, r11, r10
mov r12.x, r5
pow r13, c53.w, r12.y
pow r5, c53.w, r12.z
mov r12.y, r13
mov r12.z, r5
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r5.w, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r5.w, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s3
mul r2.y, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r2.y
pow r13, c53.w, r17.x
add r2.y, r11.w, -r16
mul r11.w, r2.y, r14
pow r12, c53.w, r17.y
add r2.y, r11.w, r14.x
mov r13.y, r12
pow r12, c53.w, r17.z
rcp r2.z, r11.w
add r2.y, r2, -r15.x
add r2.w, -r14.x, r15.y
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r12
mul r12.xyz, r13, r2.y
mov r2.y, c51.z
mul r12.xyz, r12, c15
if_gt c34.x, r2.y
add r5.w, r5, -c11.x
add r2.y, r5.w, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r5
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r9.w, r2.y, c51, r9
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r5.w, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s4
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r3.z, r13.x, c51.y
mad r2.z, r2, r3, c51.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r5.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.w, r2.y, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.y, c24.z
add r3.z, -c25, r2.y
mul r2.y, r2.z, r2.w
rcp r2.w, r3.z
add r2.z, r5.w, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25
mul_sat r2.w, r2, r3.z
mad r3.z, -r2.w, c54.x, c54.y
mul r2.w, r2, r2
add r3.w, r13, c51.y
mul r2.w, r2, r3.z
mad r2.w, r2, r3, c51
mul r2.y, r2, r2.z
mul r9.w, r2.y, r2
endif
mul r12.xyz, r12, r9.w
endif
add r13.xyz, -r5, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.z, r2, r2.w
mul r3.w, r3.z, r2
add r13.xyz, -c21, r13
add r5.xyz, -r5, c18
dp3 r3.z, r13, r13
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.z, r3.z
rcp r3.z, r3.z
mul r3.z, r3, r3.w
rcp r3.w, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r8
mul r3.w, r3, c54.z
mul r2.y, r2, c30.x
mul r3.w, r3, r3
rcp r3.w, r3.w
mul r3.z, r3, r3.w
add r2.y, r2, c51.w
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c54.z
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.z, r3, c54
min r2.z, r3, c51.w
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c54.z
min r2.y, r2, c51.w
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r13.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c54.w
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r3.xyz, r2.y, c55.yzww, r2.z
mad r3.xyz, r12, r3, r5
add r5.xyz, r3, c17
mul r12.xyz, r11.w, -r13
pow r3, c53.w, r12.x
mul r5.xyz, r5, r11.w
mad r10.xyz, r5, r11, r10
mov r12.x, r3
pow r5, c53.w, r12.y
pow r3, c53.w, r12.z
mov r12.y, r5
mov r12.z, r3
mul r11.xyz, r11, r12
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r13.xyz, r10
cmp r2.w, -r2.z, c51.z, c51
cmp r3.x, r3, c51.z, c51.w
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r11.w, -r2, r2.z, r1
cmp_pp r1.w, -r11, c51.z, c51
cmp r14.w, -r2, r0, r2.y
mov r14.x, r4
mov r10.xyz, c51.z
if_gt r1.w, c51.z
frc r1.w, r11
add r1.w, r11, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r16.y, r1.w, r2, -r2
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r16.z, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r16.z, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s3
mul r1.w, r5, c29.x
mad r17.xyz, r5.z, -c27, -r1.w
pow r4, c53.w, r17.x
pow r3, c53.w, r17.y
mov r4.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.z, -r14.x, r15.y
rcp r2.y, r14.w
add r1.w, r3.x, -r15.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c51.z
mul r14.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r12
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r10.w, r1, c51, r10
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s4
add r2.w, r4.x, c51.y
mad r1.w, r2.y, r2, c51
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.y, r4.w, c51
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c51.w
mul r1.w, r1, r2.y
mul r10.w, r1, r2.z
endif
mul r14.xyz, r14, r10.w
endif
add r4.xyz, -r12, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r12.xyz, -r12, c18
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r12, r12
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r12
dp3 r1.w, r4, r8
mul r3.y, r3, c54.z
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c51
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c54.z
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c51.w
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c54.z
mul r2.y, r5, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r12.xyz, r14.w, -r12
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r5.xyz, r1.w, c55.yzww, r2.y
mad r4.xyz, r14, r5, r4
add r5.xyz, r4, c17
pow r4, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r4
pow r5, c53.w, r12.y
pow r4, c53.w, r12.z
mov r12.y, r5
mov r12.z, r4
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r5.w, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r5.w, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s3
mul r1.w, r3, c29.x
mad r17.xyz, r3.z, -c27, -r1.w
pow r12, c53.w, r17.x
add r1.w, r11, -r16.y
mul r11.w, r1, r14
pow r4, c53.w, r17.y
add r1.w, r11, r14.x
mov r12.y, r4
pow r4, c53.w, r17.z
mov r12.z, r4
rcp r2.y, r11.w
add r1.w, r1, -r15.x
add r2.z, -r14.x, r15.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mul r4.xyz, r12, r1.w
mov r1.w, c51.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r5
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r9.w, r1, c51, r9
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r5, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c54.x, c54.y
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s4
add r2.w, r4.x, c51.y
mad r2.y, r2, r2.w, c51.w
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r1.w, c24.z
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r5.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r5.w, -c25.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.z, r4.w, c51.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3, c51.w
mul r1.w, r1, r2.y
mul r9.w, r1, r2.z
endif
mul r12.xyz, r12, r9.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.z, r4, r4
rsq r3.z, r3.z
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.z, r3.z
mul r3.z, r3, r2.w
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r8
mul r2.w, r2, c54.z
mul r2.w, r2, r2
mul r1.w, r1, c30.x
mov r4.xyz, c19
rcp r3.w, r2.w
add r1.w, r1, c51
rcp r2.w, r1.w
mul r2.y, r2, r2.w
mul r1.w, r3.z, r3
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c54
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c51.w
mul r1.w, r2.y, c54.z
mul r2.y, r3, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r5.xyz, r11.w, -r5
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r3.xyz, r1.w, c55.yzww, r2.y
mad r3.xyz, r12, r3, r4
add r4.xyz, r3, c17
pow r3, c53.w, r5.x
mul r4.xyz, r4, r11.w
mad r10.xyz, r4, r11, r10
mov r5.x, r3
pow r4, c53.w, r5.y
pow r3, c53.w, r5.z
mov r5.y, r4
mov r5.z, r3
mul r11.xyz, r11, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r10
cmp r2.z, -r2.y, c51, c51.w
cmp r2.w, r2, c51.z, c51
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r11.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r11.w, c51, c51.w
cmp r14.w, -r2.z, r0, r1
mov r14.x, r2
mov r10.xyz, c51.z
if_gt r1.z, c51.z
frc r1.z, r11.w
add r1.z, r11.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r16.y, r1.z, r1.w, -r1.w
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r2.xyz, r12, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r16.z, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r16.z, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c51.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r5, r2.xyzz, s3
mul r1.z, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r1.z
pow r2, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r2
pow r2, c53.w, r17.z
add r3.x, r14, r14.w
add r2.x, -r14, r15.y
rcp r1.w, r14.w
add r1.z, r3.x, -r15.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mov r17.z, r2
mul r2.xyz, r17, r1.z
mov r1.z, c51
mul r14.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r16.z, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r12
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r10.w, r1.z, c51, r10
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s4
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c51.w
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c54, c54.y
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r10.w, r1.z, r2.x
endif
mul r14.xyz, r14, r10.w
endif
add r2.xyz, -r12, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r12.xyz, -r12, c18
dp3 r2.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r12
rcp r3.z, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.z, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c54.z
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c54
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r12.xyz, r14.w, -r12
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.z, r2
mul r2.w, r15, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r15
mad r5.xyz, r1.z, c55.yzww, r2.w
mul r2.xyz, r2, c55.x
mad r2.xyz, r14, r5, r2
add r5.xyz, r2, c17
pow r2, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r2
pow r5, c53.w, r12.y
pow r2, c53.w, r12.z
mov r12.y, r5
mov r12.z, r2
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r2.xyz, r5, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r5.w, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r5, -c11.x
add r1.z, -r1, c51.w
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r3, r2.xyzz, s3
mul r1.z, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r1.z
pow r12, c53.w, r17.x
add r1.z, r11.w, -r16.y
mul r11.w, r1.z, r14
pow r2, c53.w, r17.y
add r1.z, r11.w, r14.x
mov r12.y, r2
pow r2, c53.w, r17.z
mov r12.z, r2
rcp r1.w, r11.w
add r1.z, r1, -r15.x
add r2.x, -r14, r15.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mul r2.xyz, r12, r1.z
mov r1.z, c51
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r5.w, r5, -c11.x
add r1.z, r5.w, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r5
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r9.w, r1.z, c51, r9
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r5.w, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s4
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r5.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c54, c54.y
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r3.z, c51
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r5, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r5.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r9.w, r1.z, r2.x
endif
mul r12.xyz, r12, r9.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.z, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.z, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r3.w, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.w, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r3, r2.y
mul r1.w, r1, r2.x
mul r3.z, r1.w, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c54.z
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3.z
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c54
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r3.y, c28.x
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.w, r2
mul r5.xyz, r11.w, -r5
mul r2.xyz, r2, c55.x
mul r1.w, r15, r1
mul r1.z, r1, r15
mad r3.xyz, r1.z, c55.yzww, r1.w
mad r2.xyz, r12, r3, r2
add r3.xyz, r2, c17
pow r2, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r2
pow r3, c53.w, r5.y
pow r2, c53.w, r5.z
mov r5.y, r3
mov r5.z, r2
mul r11.xyz, r11, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c51.z, c51.w
cmp r2.x, -r1.w, c51.z, c51.w
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r11.w, -r2.x, r1, r1.y
cmp r14.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r11.w, c51.z, c51.w
mov r2.xyz, r10
mov r14.x, r1
mov r10.xyz, c51.z
if_gt r1.y, c51.z
frc r1.x, r11.w
add r1.x, r11.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r16.y, r1.x, r1, -r1
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r1.xyz, r12, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r16.z, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r16.z, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r5, r1.xyzz, s3
mul r1.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r1.x
pow r1, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r1
pow r1, c53.w, r17.z
add r3.x, r14, r14.w
rcp r1.y, r14.w
add r1.w, -r14.x, r15.y
add r1.x, r3, -r15
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r17.z, r1
mul r1.xyz, r17, r1.x
mov r1.w, c51.z
mul r14.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r12
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r10.w, r2, c51, r10
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s4
add r3.w, r1.x, c51.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r10.w, r1.x, r1.z
endif
mul r14.xyz, r14, r10.w
endif
add r1.xyz, -r12, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
add r2.w, r1.x, c51
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r12.xyz, -r12, c18
dp3 r1.x, r12, r12
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r12
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c54.z
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r12.xyz, r14.w, -r12
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r15.w, r1.w
mul r1.w, r2, r15.z
mad r5.xyz, r1.w, c55.yzww, r3.y
mul r1.xyz, r1, c55.x
mad r1.xyz, r14, r5, r1
add r5.xyz, r1, c17
pow r1, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r1
pow r5, c53.w, r12.y
pow r1, c53.w, r12.z
mov r12.y, r5
mov r12.z, r1
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r3, r1.xyzz, s3
mul r1.x, r3.w, c29
mad r17.xyz, r3.z, -c27, -r1.x
pow r12, c53.w, r17.x
pow r1, c53.w, r17.y
add r1.x, r11.w, -r16.y
mov r12.y, r1
mul r11.w, r1.x, r14
pow r1, c53.w, r17.z
add r1.x, r11.w, r14
rcp r1.y, r11.w
add r1.x, r1, -r15
add r1.w, -r14.x, r15.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r12.z, r1
mul r1.xyz, r12, r1.x
mov r1.w, c51.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r2.w, r5, -c25
mov r1.xyz, r5
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r9.w, r2, c51, r9
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s4
add r3.w, r1.x, c51.y
add r2.w, r5, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r5.w, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r5.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r9.w, r1.x, r1.z
endif
mul r12.xyz, r12, r9.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
rcp r3.z, r1.y
add r2.w, r1.x, c51
mul r3.w, r2, r3.z
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r3.w, r3, r3.z
dp3 r1.x, r5, r5
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.w, r1.x, r3
mul r1.xyz, r3.z, r5
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.w, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.z, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.z, r3, c54
mul r1.y, r3.z, r3.z
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r2.w, r3.y, c28.x
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r2.w, r1
mul r5.xyz, r11.w, -r5
mul r1.w, r1, r15.z
mul r2.w, r15, r2
mad r3.xyz, r1.w, c55.yzww, r2.w
mul r1.xyz, r1, c55.x
mad r1.xyz, r12, r3, r1
add r3.xyz, r1, c17
pow r1, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r1
pow r3, c53.w, r5.y
pow r1, c53.w, r5.z
mov r5.y, r3
mov r5.z, r1
mul r11.xyz, r11, r5
endif
add r1.x, r16, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c51, c51.w
cmp r1.y, -r0.z, c51.z, c51.w
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r11.w, -r1.y, r0.z, r0.y
cmp r14.w, -r1.y, r0, r1.x
mov r1.xyz, r10
cmp_pp r0.y, -r11.w, c51.z, c51.w
mov r14.x, r0
mov r10.xyz, c51.z
if_gt r0.y, c51.z
frc r0.x, r11.w
add r0.x, r11.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r16.y, r0.x, r0, -r0
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r0.xyz, r12, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r16.z, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r16.z, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r5, r0.xyzz, s3
mul r0.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r0.x
pow r0, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r0
pow r0, c53.w, r17.z
add r3.x, r14, r14.w
rcp r0.y, r14.w
add r0.w, -r14.x, r15.y
add r0.x, r3, -r15
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r17.z, r0
mul r0.xyz, r17, r0.x
mov r0.w, c51.z
mul r14.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r12
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r10.w, r1, c51, r10
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s4
add r3.z, r0.x, c51.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c51.w
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c51.y
mad r2.w, -r1, c54.x, c54.y
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c51
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.y, c54.x, c54.y
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0, r0.y
mul r10.w, r0.x, r0.z
endif
mul r14.xyz, r14, r10.w
endif
add r0.xyz, -r12, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
add r1.w, r0.x, c51
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r12.xyz, -r12, c18
dp3 r0.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r12
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c54.z
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c54.z
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c51.w
mul r0.w, r0.x, c54.z
mul r1.w, r5.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r12.xyz, r14.w, -r12
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r5.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r14, r5, r0
add r5.xyz, r0, c17
pow r0, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r0
pow r5, c53.w, r12.y
pow r0, c53.w, r12.z
mov r12.y, r5
mov r12.z, r0
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r3, r0.xyzz, s3
mul r0.x, r3.w, c29
mad r9.xyz, r3.z, -c27, -r0.x
pow r0, c53.w, r9.y
pow r12, c53.w, r9.x
add r0.x, r11.w, -r16.y
mul r11.w, r0.x, r14
mov r9.y, r0
pow r0, c53.w, r9.z
add r0.x, r11.w, r14
rcp r0.y, r11.w
add r0.x, r0, -r15
add r0.w, -r14.x, r15.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r9.x, r12
mov r9.z, r0
mul r0.xyz, r9, r0.x
mov r0.w, c51.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
mov r0.xyz, r5
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r9.w, r1, c51, r9
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s4
add r3.z, r0.x, c51.y
mul r1.w, r2, r1
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r5.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c51.y
mad r0.y, -r0.x, c54.x, c54
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c51.w
mad r1.w, r1, r3.z, c51
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r5.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.x, c54.x, c54.y
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r5.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0.y, r0
mul r9.w, r0.x, r0.z
endif
mul r12.xyz, r12, r9.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c51
mul r3.z, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.z, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.z, r0, c54
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c54.z
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c54.z
min r0.y, r3.z, c51.w
mul r1.w, r3.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r5.xyz, r11.w, -r5
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r3.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r12, r3, r0
add r3.xyz, r0, c17
pow r0, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r0
pow r3, c53.w, r5.y
pow r0, c53.w, r5.z
mov r5.y, r3
mov r5.z, r0
mul r11.xyz, r11, r5
endif
mov r3, c37
add r3, -c41, r3
mov r0, c36
mov r9, c39
mov r14, c38
add r9, -c43, r9
add r0, -c40, r0
mad r5, r8.w, r3, c41
mad r3, r8.w, r0, c40
texldl r1.w, r7.xyzz, s0
mov r0.x, r1.w
mov r0.yzw, c51.w
dp4 r12.x, r3, r0
dp4 r3.x, r3, r3
mad r9, r8.w, r9, c43
add r14, -c42, r14
mad r8, r8.w, r14, c42
dp4 r12.y, r5, r0
dp4 r12.w, r9, r0
dp4 r12.z, r8, r0
add r0, r12, c51.y
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r3.w, r9, r9
mad r0, r3, r0, c51.w
mad r1.xyz, r10, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r13
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r0.xyz, r0.z, c58, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c56.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul r1.y, r0.w, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
min r0.x, r0, c56.w
add r0.z, r0.x, c57.w
cmp r0.z, r0, c51.w, c51
mul_pp r1.x, r0.z, c58.w
add r0.x, r0, -r1
mul r1.x, r0, c59
frc r0.w, r1.x
add r0.w, r1.x, -r0
mul_pp r1.x, r0.w, c59.z
mul r2.xyz, r11.y, c56
mad r2.xyz, r11.x, c57, r2
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.w, c59.y
exp_pp r0.w, r0.x
mad_pp r0.x, -r0.z, c51, c51.w
mul_pp r0.x, r0, r0.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r1
abs_pp r0.z, r0.x
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
mad r1.xyz, r11.z, c58, r2
add r2.x, r1, r1.y
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c51.y
add r1.z, r1, r2.x
mul_pp r0.z, r0, c61.x
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r2.x, r1.z, c56.w
mul r0.z, r0, c61.y
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c60.w
frc r2.y, r2.x
add r0.w, r2.x, -r2.y
min r0.w, r0, c56
add r2.x, r0.w, c57.w
mul r1.w, r1, c55.x
frc r2.y, r1.w
add r1.w, r1, -r2.y
cmp r2.x, r2, c51.w, c51.z
mul_pp r0.z, r0, c59
cmp_pp r0.x, -r0, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r2.x, c58.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c61.w
mul r1.x, r0.w, c59
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c59
add r0.w, r0, -r1.z
min r1.w, r1, c59
mad r1.z, r0.w, c60.x, r1.w
add_pp r0.w, r1.x, c59.y
exp_pp r1.x, r0.w
mad_pp r0.w, -r2.x, c51.x, c51
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c60.y, c60
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r2.x, r1.w
add_pp r1.w, r1, -r2.x
exp_pp r2.x, -r1.w
mad_pp r1.z, r1, r2.x, c51.y
mul r0.x, r0, c61.z
add r0.w, -r0.x, -r0.z
add r0.w, r0, c51
mul r2.xyz, r0.y, c62
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c61.x
mul r2.w, r0.z, c61.y
mad r0.xyz, r0.x, c63, r2
add_pp r1.z, r1.w, c60.w
frc r2.x, r2.w
mad r0.xyz, r0.w, c64, r0
add r1.w, r2, -r2.x
mul_pp r1.z, r1, c59
cmp_pp r1.x, -r1, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.z
mul r1.z, r2.x, c61.w
add r1.x, r1, r1.w
mul r1.x, r1, c61.z
add r1.w, -r1.x, -r1.z
add r0.w, r1, c51
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r2.xyz, r1.y, c62
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c51.z
mad r2.xyz, r1.y, c63, r2
mul r0.w, r0, r1.x
mad r2.xyz, r0.w, c64, r2
add r1.xyz, -r0, c51.wzzw
max r2.xyz, r2, c51.z
mad r1.xyz, r1, c48.x, r0
mad r2.xyz, -r2, c48.x, r2
else
add r2.xy, r7, c49.xzzw
add r1.xy, r2, c49.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s5
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r2.z, r1.w
add_pp r1.w, r1, -r2.z
exp_pp r2.z, -r1.w
mad_pp r1.z, r1, r2, c51.y
mul_pp r1.z, r1, c61.x
mul r2.z, r1, c61.y
add_pp r1.z, r1.w, c60.w
frc r2.w, r2.z
add r1.w, r2.z, -r2
add r8.xy, r1, -c49.xzzw
mul r2.z, r2.w, c61.w
mul_pp r1.z, r1, c59
cmp_pp r0.y, -r0, c51.w, c51.z
mad_pp r0.y, r0, c58.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c61.z
add r2.w, -r0.y, -r2.z
mov r8.z, r7
texldl r1, r8.xyzz, s5
abs_pp r3.x, r1.y
log_pp r3.y, r3.x
frc_pp r3.z, r3.y
add_pp r3.w, r3.y, -r3.z
add r2.w, r2, c51
mul r2.w, r2, r0.x
rcp r2.z, r2.z
mul r0.y, r0, r0.x
mul r2.w, r2, r2.z
exp_pp r3.y, -r3.w
mul r0.y, r2.z, r0
mad_pp r2.z, r3.x, r3.y, c51.y
mul r3.xyz, r0.x, c62
mad r3.xyz, r0.y, c63, r3
mul_pp r0.x, r2.z, c61
mul r0.y, r0.x, c61
mad r3.xyz, r2.w, c64, r3
frc r2.z, r0.y
add r2.w, r0.y, -r2.z
add_pp r0.x, r3.w, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r1.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r2.w
mul r0.y, r2.z, c61.w
mul r0.x, r0, c61.z
add r1.y, -r0.x, -r0
add r1.y, r1, c51.w
mov r2.z, r7
texldl r2, r2.xyzz, s5
abs_pp r3.w, r2.y
log_pp r4.x, r3.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r4.y, r4.x
add_pp r0.y, r4.x, -r4
mul r4.xyz, r1.x, c62
mad r4.xyz, r0.x, c63, r4
exp_pp r1.x, -r0.y
mad_pp r0.x, r3.w, r1, c51.y
mad r4.xyz, r1.y, c64, r4
mul_pp r0.x, r0, c61
mul r1.x, r0, c61.y
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r2.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r1
max r4.xyz, r4, c51.z
max r3.xyz, r3, c51.z
add r5.xyz, r3, -r4
texldl r3, r7.xyzz, s5
add r7.xy, r8, -c49.zyzw
mul r1.x, r0, c61.z
mul r1.y, r1, c61.w
add r2.y, -r1.x, -r1
mul r0.xy, r7, c50
frc r0.xy, r0
mad r5.xyz, r0.x, r5, r4
abs_pp r4.x, r3.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r2.y, r2, c51.w
mul r2.y, r2, r2.x
rcp r1.y, r1.y
mul r1.x, r1, r2
mul r2.y, r2, r1
exp_pp r4.y, -r4.w
mul r1.x, r1.y, r1
mad_pp r1.y, r4.x, r4, c51
mul r4.xyz, r2.x, c62
mad r4.xyz, r1.x, c63, r4
mad r4.xyz, r2.y, c64, r4
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
frc r2.x, r1.y
add r2.y, r1, -r2.x
add_pp r1.x, r4.w, c60.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.y, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
rcp r2.y, r1.y
mul r1.x, r1, r3
add r2.x, r2, c51.w
mul r1.y, r2.x, r3.x
abs_pp r2.x, r2.w
mul r1.y, r1, r2
log_pp r3.y, r2.x
mul r1.x, r2.y, r1
frc_pp r2.y, r3
mul r8.xyz, r3.x, c62
mad r8.xyz, r1.x, c63, r8
add_pp r2.y, r3, -r2
exp_pp r1.x, -r2.y
mad r8.xyz, r1.y, c64, r8
mad_pp r1.x, r2, r1, c51.y
mul_pp r1.x, r1, c61
mul r1.y, r1.x, c61
frc r2.x, r1.y
add_pp r1.x, r2.y, c60.w
add r2.y, r1, -r2.x
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r2.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
abs_pp r2.y, r3.w
log_pp r3.x, r2.y
frc_pp r3.y, r3.x
add_pp r3.x, r3, -r3.y
max r8.xyz, r8, c51.z
max r4.xyz, r4, c51.z
add r4.xyz, r4, -r8
mad r4.xyz, r0.x, r4, r8
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
add r2.x, r2, c51.w
mul r2.x, r2.z, r2
rcp r1.y, r1.y
mul r2.w, r2.x, r1.y
mul r1.x, r2.z, r1
exp_pp r2.x, -r3.x
mul r1.x, r1.y, r1
mad_pp r1.y, r2, r2.x, c51
mul r2.xyz, r2.z, c62
mad r2.xyz, r1.x, c63, r2
mad r2.xyz, r2.w, c64, r2
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
max r8.xyz, r2, c51.z
frc r2.w, r1.y
add_pp r1.x, r3, c60.w
add r3.x, r1.y, -r2.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
mul r1.y, r2.w, c61.w
add r1.x, r1, r3
mul r1.x, r1, c61.z
add r2.w, -r1.x, -r1.y
rcp r2.y, r1.y
add r2.x, r2.w, c51.w
mul r1.y, r3.z, r2.x
mul r3.x, r1.y, r2.y
mul r1.y, r3.z, r1.x
mul r3.y, r2, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r3.w, r1.y, -r2
exp_pp r1.y, -r3.w
mad_pp r1.x, r1, r1.y, c51.y
mul_pp r1.y, r1.x, c61.x
abs_pp r1.x, r0.w
mul r4.w, r1.y, c61.y
frc r5.w, r4
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r1.y, r1, -r2.w
exp_pp r2.w, -r1.y
mad_pp r1.x, r1, r2.w, c51.y
mul r2.xyz, r3.z, c62
mad r2.xyz, r3.y, c63, r2
mad r2.xyz, r3.x, c64, r2
max r2.xyz, r2, c51.z
add r3.xyz, r8, -r2
add_pp r3.w, r3, c60
add r4.w, r4, -r5
mad r2.xyz, r0.x, r3, r2
mul_pp r3.w, r3, c59.z
cmp_pp r1.w, -r1, c51, c51.z
mad_pp r1.w, r1, c58, r3
add r1.w, r1, r4
mul r3.w, r1, c61.z
mul r4.w, r5, c61
mul_pp r1.x, r1, c61
mul r1.w, r1.x, c61.y
add_pp r1.x, r1.y, c60.w
frc r2.w, r1
add r1.y, r1.w, -r2.w
add r5.w, -r3, -r4
mul r8.x, r1.z, r3.w
rcp r3.w, r4.w
mul r4.w, r3, r8.x
mul r1.w, r2, c61
mul_pp r1.x, r1, c59.z
cmp_pp r0.w, -r0, c51, c51.z
mad_pp r0.w, r0, c58, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c61.z
add r1.x, -r0.w, -r1.w
add r1.y, r5.w, c51.w
add r2.w, r1.x, c51
mul r5.w, r1.z, r1.y
mul r1.xyz, r1.z, c62
mul r3.w, r5, r3
mad r1.xyz, r4.w, c63, r1
mad r1.xyz, r3.w, c64, r1
mul r3.w, r0.z, r0
mul r2.w, r0.z, r2
rcp r0.w, r1.w
mul r8.xyz, r0.z, c62
mul r0.z, r0.w, r3.w
mad r8.xyz, r0.z, c63, r8
mul r0.z, r2.w, r0.w
mad r8.xyz, r0.z, c64, r8
max r1.xyz, r1, c51.z
max r8.xyz, r8, c51.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r3.xyz, r1, -r2
add r5.xyz, r5, -r4
mad r1.xyz, r0.y, r5, r4
mad r2.xyz, r0.y, r3, r2
endif
mov r0.x, c8.w
mul r0.x, c52.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s6
else
mov r0.xyz, c51.z
endif
mul r2.xyz, r2, r6.w
mad r0.xyz, r0, r2, r6
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r1.xyz, r0.z, c58, r1
add r0.x, r1, r1.y
add r0.x, r1.z, r0
rcp r0.x, r0.x
mul r0.zw, r1.xyxy, r0.x
mul r0.x, r0.z, c56.w
frc r0.y, r0.x
add r0.x, r0, -r0.y
min r0.x, r0, c56.w
add r0.y, r0.x, c57.w
cmp r1.x, r0.y, c51.w, c51.z
mul_pp r0.y, r1.x, c58.w
add r1.z, r0.x, -r0.y
mul r0.x, r1.z, c59
frc r0.y, r0.x
add r1.w, r0.x, -r0.y
mul r3.xyz, r2.y, c56
mad r0.xyz, r2.x, c57, r3
mad r0.xyz, r2.z, c58, r0
add_pp r2.x, r1.w, c59.y
add r2.y, r0.x, r0
add r2.y, r0.z, r2
exp_pp r2.x, r2.x
mad_pp r1.x, -r1, c51, c51.w
mul_pp r0.z, r1.x, r2.x
rcp r2.x, r2.y
mul_pp r1.x, r1.w, c59.z
mul r2.xy, r0, r2.x
add r0.x, r1.z, -r1
mul r1.z, r2.x, c56.w
mul r0.w, r0, c55.x
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r0.w, r0, c59
mad r0.x, r0, c60, r0.w
mad r0.x, r0, c60.y, c60.z
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c56.w
add r1.z, r1.x, c57.w
cmp r0.w, r1.z, c51, c51.z
mov_pp oC0.x, r1.y
mul_pp r1.z, r0.w, c58.w
mul_pp oC0.y, r0.z, r0.x
add r0.x, r1, -r1.z
mul r0.z, r0.x, c59.x
frc r1.x, r0.z
add r0.z, r0, -r1.x
mul_pp r1.x, r0.z, c59.z
mul r1.y, r2, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.z, c59.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r0.w, c51, c51.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r1.x
mov_pp oC0.z, r0.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 compose sky with 2 cloud layers
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
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 2 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 5 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 4 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 7 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 3 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 6 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[65] = { program.local[0..50],
		{ 1, 0, 2, -1 },
		{ -1000000, 0.995, 1000000, 0.001 },
		{ 0.75, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625, 1024, 0.00390625 },
		{ 0.0047619049, 0.63999999, 0 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 } };
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
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[9];
MOVR  R3.x, c[52];
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].z, -R0;
MOVR  R0.z, c[51].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[13].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[51].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.w, R2, R1;
MOVR  R0, c[24];
MULR  R3.z, R3.w, R3.w;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.w, R1.w;
RSQR  R0.z, R1.y;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.w, R1;
MOVR  R1.x, R8.w;
MOVR  R1.zw, c[51].x;
MOVR  R0.x, c[52];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.w, R0.y;
MOVR  R0.y, c[52].x;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.w, R0.z;
MOVR  R0.z, c[52].x;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.w, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[35];
SGER  H0.x, c[51].y, R0;
MOVR  R0, c[41];
ADDR  R0, -R0, c[37];
MADR  R7, H0.x, R0, c[41];
MOVR  R0, c[40];
ADDR  R0, -R0, c[36];
MADR  R6, H0.x, R0, c[40];
TEX   R0, fragment.texcoord[0], texture[1], 2D;
MOVR  R1.y, R0.w;
MOVR  R3, c[42];
ADDR  R3, -R3, c[38];
MADR  R5, H0.x, R3, c[42];
MOVR  R3, c[43];
ADDR  R3, -R3, c[39];
MADR  R4, H0.x, R3, c[43];
DP4R  R2.z, R1, R5;
DP4R  R2.w, R1, R4;
DP4R  R2.y, R1, R7;
DP4R  R2.x, R1, R6;
DP4R  R1.w, R4, R4;
DP4R  R1.z, R5, R5;
DP4R  R1.y, R7, R7;
DP4R  R1.x, R6, R6;
MADR  R1, R2, R1, -R1;
ADDR  R3, R1, c[51].x;
MOVR  R2.y, R0.x;
MOVR  R1.y, R0;
MULR  R0.w, R3.x, R3.y;
MOVR  R2.zw, c[51].y;
MOVR  R2.x, R8;
DP4R  R8.x, R4, R2;
MOVR  R1.x, R8.y;
MOVR  R1.zw, c[51].y;
DP4R  R8.y, R4, R1;
MOVR  R0.y, R0.z;
MULR  R8.w, R0, R3.z;
MOVR  R0.x, R8.z;
MOVR  R0.zw, c[51].y;
DP4R  R8.z, R4, R0;
DP4R  R4.x, R5, R2;
DP4R  R4.y, R5, R1;
DP4R  R4.z, R5, R0;
DP4R  R5.x, R7, R2;
DP4R  R2.x, R6, R2;
DP4R  R5.y, R7, R1;
DP4R  R2.y, R6, R1;
DP4R  R5.z, R7, R0;
MADR  R4.xyz, R3.z, R8, R4;
DP4R  R2.z, R6, R0;
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[49].xyxz;
ADDR  R0.xy, R1.zwzw, c[49].zyzw;
ADDR  R0.zw, R0.xyxy, -c[49].xyxz;
MADR  R4.xyz, R3.y, R4, R5;
MADR  R2.xyz, R3.x, R4, R2;
TEX   R0.x, R0, texture[3], 2D;
TEX   R1.x, R0.zwzw, texture[3], 2D;
ADDR  R0.y, R1.x, -R0.x;
ADDR  R15.xy, R0.zwzw, -c[49].zyzw;
MULR  R0.zw, R15.xyxy, c[50].xyxy;
FRCR  R0.zw, R0;
MADR  R0.x, R0.z, R0.y, R0;
TEX   R1.x, fragment.texcoord[0], texture[3], 2D;
TEX   R3.x, R1.zwzw, texture[3], 2D;
ADDR  R1.y, R3.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[8].w, -c[8];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[8].w;
TEX   R0.x, fragment.texcoord[0], texture[2], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[8];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R7.w, R0.z, R0.x;
ADDR  R0.x, R7.w, -R0.y;
SGTRC HC.x, |R0|, c[47];
MULR  R2.w, R8, R3;
IF    NE.x;
MOVR  R5.w, c[52].x;
MOVR  R5.x, c[52];
MOVR  R5.z, c[52].x;
MOVR  R5.y, c[52].x;
MOVR  R4.x, c[52].z;
MULR  R1.xy, R15, c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].z, -R0;
MOVR  R0.z, c[51].w;
DP3R  R0.w, R0, R0;
RSQR  R8.x, R0.w;
MULR  R0.xyz, R8.x, R0;
MOVR  R0.w, c[51].y;
DP4R  R6.z, R0, c[2];
DP4R  R6.y, R0, c[1];
DP4R  R6.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R1.x, c[0].w;
MOVR  R1.z, c[2].w;
MOVR  R1.y, c[1].w;
MULR  R9.xyz, R1, c[13].x;
ADDR  R7.xyz, R9, -c[9];
DP3R  R4.z, R6, R7;
MULR  R4.y, R4.z, R4.z;
DP3R  R4.w, R7, R7;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R5.x(EQ), R9.w;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R5.x(NE.z), -R4.z, R1;
MOVXC RC.z, R3;
MOVR  R5.z(EQ), R9.w;
MOVXC RC.z, R3.w;
RCPR  R0.x, R0.x;
ADDR  R5.z(NE.y), -R4, R0.x;
MOVXC RC.y, R3;
RSQR  R0.x, R1.w;
MOVR  R5.w(EQ.z), R9;
RCPR  R0.x, R0.x;
ADDR  R5.w(NE), -R4.z, R0.x;
RSQR  R0.x, R1.y;
MOVR  R5.y(EQ), R9.w;
RCPR  R0.x, R0.x;
ADDR  R5.y(NE.x), -R4.z, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R4.x(EQ), R9.w;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
MADR  R3.x, -c[12], c[12], R4.w;
ADDR  R0.z, R4.y, -R3.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R4.z, -R1;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R1.x, c[52].z;
MOVXC RC.z, R3;
MOVR  R1.x(EQ.z), R9.w;
RCPR  R0.x, R0.x;
ADDR  R1.x(NE.y), -R4.z, -R0;
RSQR  R0.x, R1.w;
MOVXC RC.y, R3;
MOVR  R1.w, c[52].z;
MOVR  R1.z, c[52];
MOVXC RC.z, R3.w;
ADDR  R0.w, -R4.z, -R0.z;
ADDR  R3.y, -R4.z, R0.z;
MAXR  R0.z, R0.w, c[51].y;
MAXR  R0.w, R3.y, c[51].y;
MOVR  R1.z(EQ), R9.w;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R4, -R0.x;
RSQR  R0.x, R1.y;
MOVR  R1.y, c[52].z;
MOVR  R1.w(EQ.y), R9;
RCPR  R0.x, R0.x;
ADDR  R1.w(NE.x), -R4.z, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R4.w;
SLTRC HC.x, R4.y, R0;
MOVR  R1.y(EQ.x), R9.w;
ADDR  R0.y, R4, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R4.w, R1.z;
SGERC HC.x, R4.y, R0;
RCPR  R0.y, R0.y;
ADDR  R1.y(NE.x), -R4.z, -R0;
MOVR  R4.z, R1.x;
MOVXC RC.x, R1.y;
DP4R  R1.x, R5, c[35];
SGER  R6.w, c[51].y, R1.x;
MOVR  R1.y(LT.x), c[52].z;
MOVR  R1.x, c[52].y;
MULR  R1.x, R1, c[8].w;
MOVR  R0.xy, c[51].y;
SLTRC HC.x, R4.y, R3;
MOVR  R0.xy(EQ.x), R10;
SGERC HC.x, R4.y, R3;
MOVR  R0.xy(NE.x), R0.zwzw;
MOVR  R4.y, R1.w;
MAXR  R1.w, R0.x, c[52];
SGER  H0.x, R7.w, R1;
DP4R  R0.z, R4, c[40];
DP4R  R0.w, R5, c[36];
ADDR  R0.w, R0, -R0.z;
MADR  R0.z, R6.w, R0.w, R0;
RCPR  R0.w, R8.x;
MULR  R0.w, R7, R0;
MADR  R1.y, -R0.w, c[13].x, R1;
MULR  R0.w, R0, c[13].x;
MADR  R0.w, H0.x, R1.y, R0;
MINR  R3.w, R0.y, R0;
ADDR  R1.z, R3.w, -R1.w;
RCPR  R0.x, R1.z;
MINR  R0.y, R3.w, R0.z;
MAXR  R11.y, R1.w, R0;
MULR  R8.w, R0.x, c[32].x;
ADDR  R1.y, R11, -R1.w;
MULR  R1.x, R8.w, R1.y;
RCPR  R3.y, c[32].x;
MULR  R11.w, R1.z, R3.y;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R6.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MOVR  R10.x, R0;
MOVR  R11.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R6.w, R0, c[46].y;
SLTR  H0.y, R1.x, R0.w;
SGTR  H0.x, R1, c[51].y;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R1.x;
RCPR  R3.x, R0.w;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R1.y, R3.x;
MOVR  R14.w(NE.x), R0;
MULR  R1.xyz, R7.zxyw, c[16].yzxw;
MADR  R1.xyz, R7.yzxw, c[16].zxyw, -R1;
DP3R  R0.w, R1, R1;
MULR  R3.xyz, R6.zxyw, c[16].yzxw;
MADR  R3.xyz, R6.yzxw, c[16].zxyw, -R3;
DP3R  R1.y, R1, R3;
DP3R  R1.x, R3, R3;
DP3R  R3.y, R7, c[16];
MADR  R0.w, -c[11].x, c[11].x, R0;
SLER  H0.y, R3, c[51];
MULR  R3.x, R1, R0.w;
MULR  R1.z, R1.y, R1.y;
ADDR  R0.w, R1.z, -R3.x;
SGTR  H0.z, R1, R3.x;
RCPR  R3.x, R1.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.z, -R1.y, R0.w;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVR  R1.z, c[52].x;
MOVR  R1.x, c[52].z;
ADDR  R0.w, -R1.y, -R0;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0.y;
MULR  R1.z(NE.x), R3.x, R3;
MULR  R1.x(NE), R0.w, R3;
MOVR  R1.y, R1.z;
MOVR  R16.xy, R1;
MADR  R1.xyz, R6, R1.x, R9;
ADDR  R1.xyz, R1, -c[9];
DP3R  R0.w, R1, c[16];
SGTR  H0.z, R0.w, c[51].y;
MULXC HC.x, H0.y, H0.z;
MOVR  R16.xy(NE.x), c[52].zxzw;
MOVXC RC.x, H0;
DP4R  R1.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R12.y, R11, R0.w;
DP4R  R1.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R13.y, R12, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R1.x, R5, c[39];
ADDR  R1.x, R1, -R0.w;
MADR  R0.w, R6, R1.x, R0;
MINR  R0.w, R3, R0;
DP3R  R0.y, R6, c[16];
MULR  R13.x, R0, c[33];
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[51].z;
MADR  R0.x, c[30], c[30], R0;
MADR  R15.z, R0.y, c[53].x, c[53].x;
ADDR  R0.y, R0.x, c[51].x;
MOVR  R0.x, c[51];
POWR  R0.y, R0.y, c[53].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R5.w, R13.y, R0;
MOVR  R12.x, R0.z;
MOVR  R12.w, R3;
MULR  R15.w, R0.x, R0.y;
MOVR  R8.xyz, c[51].x;
MOVR  R7.xyz, c[51].y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.y, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R11.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R13.y, -R12.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R12.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R5.w, -R13.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R12.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R12.x;
RCPR  R0.z, R12.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R12.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R13.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.w, -R5.w;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R13.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R13.x;
RCPR  R0.z, R13.x;
MOVR  R13.w, R11;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R13.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R5;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[4], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R9.w;
MOVR  R9.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[5], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R9.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R9.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
MOVR  R1, c[41];
ADDR  R1, -R1, c[37];
MADR  R4, R6.w, R1, c[41];
MOVR  R0, c[40];
ADDR  R0, -R0, c[36];
MADR  R3, R6.w, R0, c[40];
TEX   R1.w, R15, texture[1], 2D;
MOVR  R0.y, R1.w;
TEX   R0.w, R15, texture[0], 2D;
MOVR  R0.x, R0.w;
MOVR  R0.zw, c[51].x;
MOVR  R5, c[42];
MOVR  R1, c[43];
ADDR  R5, -R5, c[38];
MADR  R5, R6.w, R5, c[42];
ADDR  R1, -R1, c[39];
MADR  R1, R6.w, R1, c[43];
DP4R  R6.w, R0, R1;
DP4R  R6.x, R0, R3;
DP4R  R6.y, R0, R4;
DP4R  R6.z, R0, R5;
DP4R  R0.w, R1, R1;
DP4R  R0.x, R3, R3;
DP4R  R0.y, R4, R4;
DP4R  R0.z, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[51].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R12;
MADR  R1.xyz, R1, R0.y, R11;
MADR  R1.xyz, R1, R0.x, R10;
MULR  R0.xyz, R1.y, c[59];
MADR  R0.xyz, R1.x, c[58], R0;
MADR  R0.xyz, R1.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].z;
SGER  H0.x, R0, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[57].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[59].w;
ADDH  H0.y, H0, -c[58].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R8.y, c[59];
MADR  R1.xyz, R8.x, c[58], R1;
MADR  R1.xyz, R8.z, c[57], R1;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0.w, c[54].x;
MADR  R0.z, R0.x, c[60].x, R0;
MOVR  R0.x, c[51];
MADR  H0.z, R0, c[60].y, R0.x;
MADH  H0.x, H0, c[51].z, H0.y;
MULH  H0.x, H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
LG2H  H0.z, |H0.x|;
FLRH  H0.z, H0;
ADDH  H0.w, H0.z, c[58];
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R1.z, R0, c[56];
SGEH  H0.y, c[51], H0.x;
EX2H  H0.z, -H0.z;
MULH  H0.x, |H0|, H0.z;
MADH  H0.x, H0, c[60].z, -c[60].z;
MULR  R1.x, H0, c[60].w;
FLRR  R0.z, R1.x;
MULH  H0.w, H0, c[59];
MADH  H0.y, H0, c[56].w, H0.w;
ADDR  R0.z, H0.y, R0;
SGER  H0.x, R1.z, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R1.w, R1.z, -H0.y;
MULR  R1.z, R1.w, c[57].w;
FLRR  H0.y, R1.z;
MULH  H0.z, H0.y, c[59].w;
FRCR  R1.x, R1;
ADDH  H0.y, H0, -c[58].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.x, R1, c[61].y;
MULR  R0.z, R0, c[61].x;
ADDR  R1.z, -R0, -R1.x;
MADR  R1.z, R1, R0.y, R0.y;
MADH  H0.x, H0, c[51].z, H0.y;
ADDR  R1.w, R1, -H0.z;
MINR  R0.w, R0, c[54].x;
MADR  R0.w, R1, c[60].x, R0;
MADR  H0.z, R0.w, c[60].y, R0.x;
MULH  H0.x, H0, H0.z;
RCPR  R0.x, R1.x;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MULR  R0.z, R0, R0.y;
ADDH  H0.y, H0, c[58].w;
MULR  R0.w, R1.z, R0.x;
MULR  R1.x, R0, R0.z;
MULR  R0.xyz, R0.y, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R3.xyz, R0, c[51].y;
MADH  H0.z, H0, c[60], -c[60];
MULR  R1.x, H0.z, c[60].w;
FRCR  R0.w, R1.x;
MULR  R0.w, R0, c[61].y;
MULR  R0.xyz, R1.y, c[64];
FLRR  R1.x, R1;
MULH  H0.y, H0, c[59].w;
SGEH  H0.x, c[51].y, H0;
MADH  H0.x, H0, c[56].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.z, R1.x, c[61].x;
ADDR  R1.x, -R1.z, -R0.w;
MADR  R1.x, R1, R1.y, R1.y;
MULR  R1.z, R1, R1.y;
RCPR  R0.w, R0.w;
MULR  R1.y, R0.w, R1.z;
MADR  R0.xyz, R1.y, c[63], R0;
MULR  R0.w, R1.x, R0;
ADDR  R1.xyz, -R3, c[51].xyyw;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R0.xyz, R0, c[51].y;
MADR  R3.xyz, R1, c[48].x, R3;
MADR  R1.xyz, -R0, c[48].x, R0;
ELSE;
ADDR  R6.xy, R15, c[49].xzzw;
ADDR  R0.xy, R6, c[49].zyzw;
TEX   R4, R0, texture[6], 2D;
ADDR  R7.xy, R0, -c[49].xzzw;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R4|, H0;
MADH  H0.y, H0, c[60].z, -c[60].z;
MULR  R0.z, H0.y, c[60].w;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[61].y;
ADDH  H0.x, H0, c[58].w;
MULH  H0.z, H0.x, c[59].w;
SGEH  H0.xy, c[51].y, R4.ywzw;
TEX   R3, R7, texture[6], 2D;
MADH  H0.x, H0, c[56].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[61].x;
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[58].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R4.x;
MADR  R0.w, R0, R4.x, R4.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R4.x, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
MAXR  R1.xyz, R0, c[51].y;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[51].y, R3.xyyw;
MULR  R0.z, R0.x, c[61].y;
MULH  H0.x, H0, c[59].w;
RCPR  R3.y, R0.z;
MADH  H0.x, H0.z, c[56].w, H0;
FLRR  R0.y, R0.w;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[61];
MULR  R0.w, R0.x, R3.x;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R3.x, R3.x;
MULR  R1.w, R0.y, R3.y;
MULR  R0.xyz, R3.x, c[64];
MULR  R0.w, R3.y, R0;
MADR  R5.xyz, R0.w, c[63], R0;
TEX   R0, R6, texture[6], 2D;
MADR  R5.xyz, R1.w, c[62], R5;
MAXR  R6.xyz, R5, c[51].y;
ADDR  R5.xyz, R1, -R6;
TEX   R1, R15, texture[6], 2D;
ADDR  R15.xy, R7, -c[49].zyzw;
MULR  R3.xy, R15, c[50];
FRCR  R8.xy, R3;
MADR  R5.xyz, R8.x, R5, R6;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R4.x, H0.z, c[60].w;
ADDH  H0.x, H0, c[58].w;
SGEH  H1.xy, c[51].y, R0.ywzw;
MULH  H0.x, H0, c[59].w;
SGEH  H1.zw, c[51].y, R1.xyyw;
FRCR  R3.x, R4;
FLRR  R3.y, R4.x;
MADH  H0.x, H1, c[56].w, H0;
ADDR  R0.y, H0.x, R3;
MULR  R3.y, R3.x, c[61];
MULR  R3.x, R0.y, c[61];
ADDR  R0.y, -R3.x, -R3;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
RCPR  R3.y, R3.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R3.x, R3, R0;
MULR  R0.y, R0, R3;
MULR  R3.x, R3.y, R3;
MULR  R6.xyz, R0.x, c[64];
MADR  R6.xyz, R3.x, c[63], R6;
MADH  H0.z, H0, c[60], -c[60];
MADR  R6.xyz, R0.y, c[62], R6;
MULR  R0.x, H0.z, c[60].w;
FRCR  R0.y, R0.x;
MULR  R1.y, R0, c[61];
MADH  H0.x, H1.z, c[56].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.y, R0.x, c[61].x;
ADDR  R0.x, -R0.y, -R1.y;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
RCPR  R1.y, R1.y;
MADR  R0.x, R0, R1, R1;
MULR  R0.y, R0, R1.x;
MULR  R0.x, R0, R1.y;
MULR  R0.y, R1, R0;
MULR  R7.xyz, R1.x, c[64];
MADR  R7.xyz, R0.y, c[63], R7;
MADR  R7.xyz, R0.x, c[62], R7;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.x, H0.z, c[60].w;
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[51].y;
MAXR  R6.xyz, R6, c[51].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R8.x, R6, R7;
MADH  H0.x, H1.y, c[56].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
MULR  R0.y, R0, c[61];
MULR  R0.x, R0, c[61];
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
FRCR  R1.x, R0.w;
MULR  R1.y, R1.x, c[61];
RCPR  R3.x, R1.y;
MADH  H0.x, H1.w, c[56].w, H0;
FLRR  R0.w, R0;
ADDR  R0.w, H0.x, R0;
MULR  R1.x, R0.w, c[61];
ADDR  R0.w, -R1.x, -R1.y;
MADR  R0.w, R1.z, R0, R1.z;
MULR  R1.w, R1.z, R1.x;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULR  R0.w, R0, R3.x;
MULR  R1.w, R3.x, R1;
MULR  R1.xyz, R1.z, c[64];
MADR  R1.xyz, R1.w, c[63], R1;
MADR  R1.xyz, R0.w, c[62], R1;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
MULH  H0.x, H0, c[59].w;
MADH  H0.z, H0.w, c[56].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULH  H0.z, |R4.w|, H0;
MULR  R3.y, R1.w, c[61].x;
MULR  R3.x, R0.w, c[61].y;
ADDR  R4.x, -R3.y, -R3;
MADR  R4.y, R3.z, R4.x, R3.z;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
MULR  R3.w, R1, c[61].y;
MAXR  R1.xyz, R1, c[51].y;
MAXR  R0.xyz, R0, c[51].y;
ADDR  R0.xyz, R0, -R1;
RCPR  R4.x, R3.x;
MULR  R4.w, R3.z, R3.y;
MULR  R4.w, R4.x, R4;
MULR  R3.xyz, R3.z, c[64];
MADR  R0.xyz, R8.x, R0, R1;
MADR  R3.xyz, R4.w, c[63], R3;
MULR  R4.x, R4.y, R4;
MADR  R3.xyz, R4.x, c[62], R3;
MAXR  R3.xyz, R3, c[51].y;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[56].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R1.w, R0, c[61].x;
ADDR  R0.w, -R1, -R3;
MULR  R4.w, R4.z, R1;
MADR  R0.w, R4.z, R0, R4.z;
RCPR  R1.w, R3.w;
MULR  R4.xyz, R4.z, c[64];
MULR  R3.w, R1, R4;
MADR  R4.xyz, R3.w, c[63], R4;
MULR  R0.w, R0, R1;
MADR  R4.xyz, R0.w, c[62], R4;
MAXR  R4.xyz, R4, c[51].y;
ADDR  R4.xyz, R4, -R3;
MADR  R1.xyz, R8.x, R4, R3;
ADDR  R1.xyz, R1, -R0;
MADR  R3.xyz, R8.y, R5, R6;
MADR  R1.xyz, R8.y, R1, R0;
ENDIF;
MOVR  R0.x, c[52].y;
MULR  R0.x, R0, c[8].w;
SGTRC HC.x, R7.w, R0;
IF    NE.x;
TEX   R0.xyz, R15, texture[7], 2D;
ELSE;
MOVR  R0.xyz, c[51].y;
ENDIF;
MULR  R1.xyz, R1, R2.w;
MADR  R0.xyz, R0, R1, R2;
ADDR  R2.xyz, R0, R3;
MULR  R0.xyz, R2.y, c[59];
MADR  R0.xyz, R2.x, c[58], R0;
MADR  R0.xyz, R2.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[59];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].z;
SGER  H0.x, R0, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[57].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[58].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[59].w;
MADR  R2.xyz, R1.x, c[58], R2;
MADR  R1.xyz, R1.z, c[57], R2;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[56].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[51].z, H0.z;
MINR  R0.z, R1, c[56];
SGER  H0.z, R0, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[56].w;
MINR  R0.w, R0, c[54].x;
MADR  R0.x, R0, c[60], R0.w;
ADDR  R0.z, R0, -H0.y;
MOVR  R1.x, c[51];
MADR  H0.y, R0.x, c[60], R1.x;
MULR  R0.w, R0.z, c[57];
FLRR  H0.w, R0;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[59].w;
ADDR  R0.x, R0.z, -H0;
ADDH  H0.x, H0.w, -c[58].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[54].x;
MADR  R0.x, R0, c[60], R0.y;
MADR  H0.z, R0.x, c[60].y, R1.x;
MADH  H0.x, H0.y, c[51].z, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 2 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 5 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 4 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 7 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 3 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 6 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c51, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c52, -1000000.00000000, 0.99500000, 1000000.00000000, 0.00100000
def c53, 0.75000000, 1.50000000, 0.50000000, 2.71828198
defi i0, 255, 0, 1, 0
def c54, 2.00000000, 3.00000000, 1000.00000000, 10.00000000
def c55, 400.00000000, 5.60204458, 9.47328472, 19.64380264
def c56, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c57, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c58, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c59, 0.25000000, -15.00000000, 4.00000000, 255.00000000
def c60, 256.00000000, 0.00097656, 1.00000000, 15.00000000
def c61, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c62, -1.02170002, 1.97770000, 0.04390000, 0
def c63, 2.56509995, -1.16649997, -0.39860001, 0
def c64, 0.07530000, -0.25430000, 1.18920004, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c51.x, c51.y
mov r6, c39
mov r3, c38
texldl r8, v0, s0
add r3, -c42, r3
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c51.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
add r0.y, c24, r0
add r6, -c43, r6
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c13.x
add r2.xyz, r2, -c9
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c24, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
cmp r0.x, r0, r1.w, c52
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c51.w, c51.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c52.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c11.x
add r1.y, c24.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c51, c51.z
cmp r1.z, r1, r1.w, c52.x
cmp_pp r0.z, r1.x, c51.w, c51
cmp r1.x, r1, r1.w, c52
cmp r0.w, -r0, r1.z, r2.x
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c35
cmp r2.z, -r0.x, c51.w, c51
mad r7, r2.z, r6, c43
mad r6, r2.z, r3, c42
mov r1, c37
add r1, -c41, r1
mad r5, r2.z, r1, c41
texldl r1, v0, s1
mov r3.y, r1.x
mov r0, c36
add r0, -c40, r0
mad r4, r2.z, r0, c40
mov r0.y, r1.w
mov r0.zw, c51.w
mov r0.x, r8.w
dp4 r2.w, r7, r0
dp4 r2.z, r6, r0
dp4 r2.y, r5, r0
dp4 r2.x, r4, r0
dp4 r0.w, r7, r7
add r2, r2, c51.y
mov r1.x, r8.z
dp4 r0.z, r6, r6
mov r3.zw, c51.z
mov r3.x, r8
dp4 r8.x, r7, r3
dp4 r0.y, r5, r5
dp4 r0.x, r4, r4
mad r0, r0, r2, c51.w
mov r2.y, r1
mov r1.y, r1.z
mov r1.zw, c51.z
dp4 r8.z, r7, r1
mov r2.x, r8.y
mov r2.zw, c51.z
dp4 r8.y, r7, r2
dp4 r7.x, r6, r3
dp4 r7.z, r6, r1
dp4 r7.y, r6, r2
mad r6.xyz, r0.z, r8, r7
dp4 r7.x, r5, r3
dp4 r3.x, r4, r3
dp4 r7.z, r5, r1
dp4 r7.y, r5, r2
dp4 r3.y, r4, r2
mad r5.xyz, r0.y, r6, r7
dp4 r3.z, r4, r1
mad r6.xyz, r0.x, r5, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r2.xy, v0, c49.xzzw
add r0.xy, r2, c49.zyzw
add r3.xy, r0, -c49.xzzw
mov r0.z, v0.w
mov r3.z, v0.w
mov r2.z, v0.w
add r7.xy, r3, -c49.zyzw
mul r1.zw, r7.xyxy, c50.xyxy
texldl r0.x, r0.xyzz, s3
texldl r1.x, r3.xyzz, s3
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s3
texldl r2.x, r2.xyzz, s3
add r0.z, r2.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c8.w, -c8.z
rcp r0.y, r0.x
mul r0.y, r0, c8.w
texldl r0.x, v0, s2
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c8.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r6.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c47.x
mad r0.xy, r7, c51.x, c51.y
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.x, r0.w
mul r0.xyz, r2.x, r0
mov r0.w, c51.z
dp4 r8.z, r0, c2
dp4 r8.y, r0, c1
dp4 r8.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
mul r11.xyz, r8.zxyw, c16.yzxw
mad r11.xyz, r8.yzxw, c16.zxyw, -r11
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r9.xyz, r1, c13.x
add r5.xyz, r9, -c9
dp3 r2.y, r8, r5
dp3 r2.z, r5, r5
add r0.y, c25, r0
mad r0.z, -r0.y, r0.y, r2
mad r0.w, r2.y, r2.y, -r0.z
rsq r1.x, r0.w
add r0.x, c25, r0
mad r0.x, -r0, r0, r2.z
mad r0.x, r2.y, r2.y, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2.y, -r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
rcp r1.x, r1.x
cmp r0.x, r0, r9.w, c52.z
cmp r0.x, -r0.y, r0, r0.z
cmp_pp r0.y, r0.w, c51.w, c51.z
add r1.x, -r2.y, -r1
cmp r0.w, r0, r9, c52.z
cmp r0.y, -r0, r0.w, r1.x
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.x, c25.w, r0.z
mad r0.w, -r0, r0, r2.z
mad r0.z, r2.y, r2.y, -r0.w
mad r1.x, -r1, r1, r2.z
mad r1.y, r2, r2, -r1.x
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r2.y, -r0.w
cmp_pp r0.w, r0.z, c51, c51.z
rsq r1.z, r1.y
rcp r1.z, r1.z
cmp r0.z, r0, r9.w, c52
cmp r0.z, -r0.w, r0, r1.x
add r1.z, -r2.y, -r1
cmp r1.x, r1.y, r9.w, c52.z
cmp_pp r0.w, r1.y, c51, c51.z
cmp r0.w, -r0, r1.x, r1.z
mov r1.x, c11
add r1.y, c24.x, r1.x
mov r1.x, c11
add r1.z, c24.y, r1.x
mad r1.y, -r1, r1, r2.z
mad r1.x, r2.y, r2.y, -r1.y
mad r1.z, -r1, r1, r2
mad r1.w, r2.y, r2.y, -r1.z
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r2.y, r1.y
cmp_pp r1.y, r1.x, c51.w, c51.z
rsq r3.x, r1.w
rcp r3.x, r3.x
cmp r1.x, r1, r9.w, c52
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c51.w, c51.z
dp4 r2.w, r0, c41
dp4 r3.w, r0, c40
add r3.x, -r2.y, r3
cmp r1.w, r1, r9, c52.x
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c11.x
add r1.w, c24, r1.z
mad r1.w, -r1, r1, r2.z
mad r3.y, r2, r2, -r1.w
rsq r1.w, r3.y
rcp r3.x, r1.w
mov r1.z, c11.x
add r1.z, c24, r1
mad r1.z, -r1, r1, r2
mad r1.z, r2.y, r2.y, -r1
add r3.z, -r2.y, r3.x
rsq r1.w, r1.z
rcp r3.x, r1.w
cmp_pp r1.w, r3.y, c51, c51.z
cmp r3.y, r3, r9.w, c52.x
cmp r1.w, -r1, r3.y, r3.z
add r3.y, -r2, r3.x
cmp_pp r3.x, r1.z, c51.w, c51.z
cmp r1.z, r1, r9.w, c52.x
cmp r1.z, -r3.x, r1, r3.y
dp4 r3.x, r1, c37
dp4 r3.y, r1, c35
add r3.z, r3.x, -r2.w
cmp r8.w, -r3.y, c51, c51.z
mad r3.y, r8.w, r3.z, r2.w
dp4 r3.z, r1, c36
add r4.x, r3.z, -r3.w
mov r3.x, c11
add r3.x, c31, r3
mad r3.x, -r3, r3, r2.z
mad r2.w, r2.y, r2.y, -r3.x
rsq r3.x, r2.w
rcp r3.x, r3.x
add r3.z, -r2.y, -r3.x
cmp_pp r3.x, r2.w, c51.w, c51.z
cmp r2.w, r2, r9, c52.z
cmp r2.w, -r3.x, r2, r3.z
rcp r2.x, r2.x
mul r3.x, r7.w, r2
cmp r2.w, r2, r2, c52.z
mad r3.z, -r3.x, c13.x, r2.w
mad r2.z, -c12.x, c12.x, r2
mad r2.z, r2.y, r2.y, -r2
rsq r2.w, r2.z
mov r2.x, c8.w
mad r2.x, c52.y, -r2, r7.w
mad r3.w, r8, r4.x, r3
rcp r2.w, r2.w
mul r3.x, r3, c13
cmp r2.x, r2, c51.w, c51.z
mad r3.z, r2.x, r3, r3.x
add r2.x, -r2.y, -r2.w
add r2.y, -r2, r2.w
cmp_pp r3.x, r2.z, c51.w, c51.z
cmp r2.zw, r2.z, r10.xyxy, c51.z
mul r10.xyz, r5.zxyw, c16.yzxw
mad r10.xyz, r5.yzxw, c16.zxyw, -r10
max r2.x, r2, c51.z
max r2.y, r2, c51.z
cmp r2.xy, -r3.x, r2.zwzw, r2
min r3.x, r2.y, r3.z
dp4 r2.z, r0, c42
dp4 r0.y, r0, c43
dp4 r0.x, r1, c39
max r14.x, r2, c52.w
add r0.z, r0.x, -r0.y
min r2.y, r3.x, r3.w
max r4.x, r14, r2.y
dp4 r2.y, r1, c38
add r2.y, r2, -r2.z
mad r2.y, r8.w, r2, r2.z
min r2.x, r3, r3.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
min r0.x, r3, r2.y
max r2.x, r4, r2
mad r0.y, r8.w, r0.z, r0
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r8, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r14.x
rcp r0.z, r0.y
rcp r2.z, r1.w
add r1.y, r4.x, -r14.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c51.z, c51.w
cmp r0.w, -r1.z, c51.z, c51
mul_pp r2.y, r0.w, r2
cmp r11.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r14.w, -r2.y, r0, r1.y
dp3 r0.y, r10, r10
dp3 r1.y, r10, r11
dp3 r1.z, r11, r11
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
rsq r2.z, r1.w
dp3 r0.y, r5, c16
cmp r0.y, -r0, c51.w, c51.z
cmp r1.w, -r1, c51.z, c51
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c52, r1
mad r5.xyz, r8, r1.z, r9
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c52.x, r1
cmp r1.y, -r1, c51.z, c51.w
mul_pp r0.y, r0, r1
cmp r15.xy, -r0.y, r1.zwzw, c52.zxzw
mad r2.w, r8, r2, c45.y
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r8.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r8.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r8.w, r0, c46
dp3 r2.z, r8, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c51.w
mul r2.w, r2, c51.x
mad r2.w, c30.x, c30.x, r2
mul r15.z, r2, c53.x
mov r2.z, c30.x
add r2.z, c51.w, r2
add r2.w, r2, c51
mov r16.x, r3
pow r3, r2.w, c53.y
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r11.w, c51.z, c51.w
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r15.w, r2.z, r2
mov r11.xyz, c51.w
mov r10.xyz, c51.z
if_gt r2.y, c51.z
frc r2.y, r11.w
add r2.y, r11.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r16.y, r2, r2.z, -r2.z
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r16.z, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r16, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s4
mul r2.y, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r2.y
pow r13, c53.w, r17.x
pow r3, c53.w, r17.y
mov r13.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.w, -r14.x, r15.y
rcp r2.z, r14.w
add r2.y, r3.x, -r15.x
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r3
mul r13.xyz, r13, r2.y
mov r2.y, c51.z
mul r14.xyz, r13, c15
if_gt c34.x, r2.y
add r3.y, r16.z, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r12
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r10.w, r2.y, c51, r10
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s5
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r13.x, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c54.x, c54
mul r2.w, r2, r2
add r3.z, r13.w, c51.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c51
mul r2.y, r2, r2.z
mul r10.w, r2.y, r2
endif
mul r14.xyz, r14, r10.w
endif
add r13.xyz, -r12, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
add r13.xyz, -c21, r13
dp3 r3.z, r13, r13
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r12.xyz, -r12, c18
dp3 r3.y, r12, r12
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r12.xyz, r3.y, r12
dp3 r2.y, r12, r8
mul r3.z, r3, c54
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r12.xyz, c19
add r2.y, r2, c51.w
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c54.z
add r12.xyz, -c18, r12
dp3 r2.z, r12, r12
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c54.z
min r2.w, r2.y, c51
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c54.z
mul r2.z, r5.y, c28.x
min r2.y, r2, c51.w
mul r12.xyz, r2.w, c23
mad r12.xyz, r2.y, c20, r12
mul r2.y, r5, c29.x
mad r13.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r12.xyz, r12, c54.w
mul r12.xyz, r2.z, r12
mul r12.xyz, r12, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r5.xyz, r2.y, c55.yzww, r2.z
mad r5.xyz, r14, r5, r12
mul r12.xyz, r14.w, -r13
add r13.xyz, r5, c17
pow r5, c53.w, r12.x
mul r13.xyz, r13, r14.w
mad r10.xyz, r13, r11, r10
mov r12.x, r5
pow r13, c53.w, r12.y
pow r5, c53.w, r12.z
mov r12.y, r13
mov r12.z, r5
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r5.w, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r5.w, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s4
mul r2.y, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r2.y
pow r13, c53.w, r17.x
add r2.y, r11.w, -r16
mul r11.w, r2.y, r14
pow r12, c53.w, r17.y
add r2.y, r11.w, r14.x
mov r13.y, r12
pow r12, c53.w, r17.z
rcp r2.z, r11.w
add r2.y, r2, -r15.x
add r2.w, -r14.x, r15.y
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r12
mul r12.xyz, r13, r2.y
mov r2.y, c51.z
mul r12.xyz, r12, c15
if_gt c34.x, r2.y
add r5.w, r5, -c11.x
add r2.y, r5.w, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r5
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r9.w, r2.y, c51, r9
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r5.w, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s5
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r3.z, r13.x, c51.y
mad r2.z, r2, r3, c51.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r5.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.w, r2.y, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.y, c24.z
add r3.z, -c25, r2.y
mul r2.y, r2.z, r2.w
rcp r2.w, r3.z
add r2.z, r5.w, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25
mul_sat r2.w, r2, r3.z
mad r3.z, -r2.w, c54.x, c54.y
mul r2.w, r2, r2
add r3.w, r13, c51.y
mul r2.w, r2, r3.z
mad r2.w, r2, r3, c51
mul r2.y, r2, r2.z
mul r9.w, r2.y, r2
endif
mul r12.xyz, r12, r9.w
endif
add r13.xyz, -r5, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.z, r2, r2.w
mul r3.w, r3.z, r2
add r13.xyz, -c21, r13
add r5.xyz, -r5, c18
dp3 r3.z, r13, r13
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.z, r3.z
rcp r3.z, r3.z
mul r3.z, r3, r3.w
rcp r3.w, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r8
mul r3.w, r3, c54.z
mul r2.y, r2, c30.x
mul r3.w, r3, r3
rcp r3.w, r3.w
mul r3.z, r3, r3.w
add r2.y, r2, c51.w
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c54.z
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.z, r3, c54
min r2.z, r3, c51.w
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c54.z
min r2.y, r2, c51.w
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r13.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c54.w
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r3.xyz, r2.y, c55.yzww, r2.z
mad r3.xyz, r12, r3, r5
add r5.xyz, r3, c17
mul r12.xyz, r11.w, -r13
pow r3, c53.w, r12.x
mul r5.xyz, r5, r11.w
mad r10.xyz, r5, r11, r10
mov r12.x, r3
pow r5, c53.w, r12.y
pow r3, c53.w, r12.z
mov r12.y, r5
mov r12.z, r3
mul r11.xyz, r11, r12
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r13.xyz, r10
cmp r2.w, -r2.z, c51.z, c51
cmp r3.x, r3, c51.z, c51.w
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r11.w, -r2, r2.z, r1
cmp_pp r1.w, -r11, c51.z, c51
cmp r14.w, -r2, r0, r2.y
mov r14.x, r4
mov r10.xyz, c51.z
if_gt r1.w, c51.z
frc r1.w, r11
add r1.w, r11, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r16.y, r1.w, r2, -r2
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r16.z, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r16.z, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s4
mul r1.w, r5, c29.x
mad r17.xyz, r5.z, -c27, -r1.w
pow r4, c53.w, r17.x
pow r3, c53.w, r17.y
mov r4.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.z, -r14.x, r15.y
rcp r2.y, r14.w
add r1.w, r3.x, -r15.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c51.z
mul r14.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r12
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r10.w, r1, c51, r10
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s5
add r2.w, r4.x, c51.y
mad r1.w, r2.y, r2, c51
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.y, r4.w, c51
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c51.w
mul r1.w, r1, r2.y
mul r10.w, r1, r2.z
endif
mul r14.xyz, r14, r10.w
endif
add r4.xyz, -r12, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r12.xyz, -r12, c18
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r12, r12
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r12
dp3 r1.w, r4, r8
mul r3.y, r3, c54.z
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c51
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c54.z
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c51.w
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c54.z
mul r2.y, r5, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r12.xyz, r14.w, -r12
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r5.xyz, r1.w, c55.yzww, r2.y
mad r4.xyz, r14, r5, r4
add r5.xyz, r4, c17
pow r4, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r4
pow r5, c53.w, r12.y
pow r4, c53.w, r12.z
mov r12.y, r5
mov r12.z, r4
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r5.w, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r5.w, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s4
mul r1.w, r3, c29.x
mad r17.xyz, r3.z, -c27, -r1.w
pow r12, c53.w, r17.x
add r1.w, r11, -r16.y
mul r11.w, r1, r14
pow r4, c53.w, r17.y
add r1.w, r11, r14.x
mov r12.y, r4
pow r4, c53.w, r17.z
mov r12.z, r4
rcp r2.y, r11.w
add r1.w, r1, -r15.x
add r2.z, -r14.x, r15.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mul r4.xyz, r12, r1.w
mov r1.w, c51.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r5
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r9.w, r1, c51, r9
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r5, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c54.x, c54.y
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s5
add r2.w, r4.x, c51.y
mad r2.y, r2, r2.w, c51.w
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r1.w, c24.z
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r5.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r5.w, -c25.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.z, r4.w, c51.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3, c51.w
mul r1.w, r1, r2.y
mul r9.w, r1, r2.z
endif
mul r12.xyz, r12, r9.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.z, r4, r4
rsq r3.z, r3.z
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.z, r3.z
mul r3.z, r3, r2.w
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r8
mul r2.w, r2, c54.z
mul r2.w, r2, r2
mul r1.w, r1, c30.x
mov r4.xyz, c19
rcp r3.w, r2.w
add r1.w, r1, c51
rcp r2.w, r1.w
mul r2.y, r2, r2.w
mul r1.w, r3.z, r3
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c54
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c51.w
mul r1.w, r2.y, c54.z
mul r2.y, r3, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r5.xyz, r11.w, -r5
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r3.xyz, r1.w, c55.yzww, r2.y
mad r3.xyz, r12, r3, r4
add r4.xyz, r3, c17
pow r3, c53.w, r5.x
mul r4.xyz, r4, r11.w
mad r10.xyz, r4, r11, r10
mov r5.x, r3
pow r4, c53.w, r5.y
pow r3, c53.w, r5.z
mov r5.y, r4
mov r5.z, r3
mul r11.xyz, r11, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r10
cmp r2.z, -r2.y, c51, c51.w
cmp r2.w, r2, c51.z, c51
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r11.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r11.w, c51, c51.w
cmp r14.w, -r2.z, r0, r1
mov r14.x, r2
mov r10.xyz, c51.z
if_gt r1.z, c51.z
frc r1.z, r11.w
add r1.z, r11.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r16.y, r1.z, r1.w, -r1.w
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r2.xyz, r12, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r16.z, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r16.z, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c51.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r5, r2.xyzz, s4
mul r1.z, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r1.z
pow r2, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r2
pow r2, c53.w, r17.z
add r3.x, r14, r14.w
add r2.x, -r14, r15.y
rcp r1.w, r14.w
add r1.z, r3.x, -r15.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mov r17.z, r2
mul r2.xyz, r17, r1.z
mov r1.z, c51
mul r14.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r16.z, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r12
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r10.w, r1.z, c51, r10
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s5
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c51.w
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c54, c54.y
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r10.w, r1.z, r2.x
endif
mul r14.xyz, r14, r10.w
endif
add r2.xyz, -r12, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r12.xyz, -r12, c18
dp3 r2.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r12
rcp r3.z, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.z, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c54.z
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c54
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r12.xyz, r14.w, -r12
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.z, r2
mul r2.w, r15, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r15
mad r5.xyz, r1.z, c55.yzww, r2.w
mul r2.xyz, r2, c55.x
mad r2.xyz, r14, r5, r2
add r5.xyz, r2, c17
pow r2, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r2
pow r5, c53.w, r12.y
pow r2, c53.w, r12.z
mov r12.y, r5
mov r12.z, r2
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r2.xyz, r5, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r5.w, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r5, -c11.x
add r1.z, -r1, c51.w
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r3, r2.xyzz, s4
mul r1.z, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r1.z
pow r12, c53.w, r17.x
add r1.z, r11.w, -r16.y
mul r11.w, r1.z, r14
pow r2, c53.w, r17.y
add r1.z, r11.w, r14.x
mov r12.y, r2
pow r2, c53.w, r17.z
mov r12.z, r2
rcp r1.w, r11.w
add r1.z, r1, -r15.x
add r2.x, -r14, r15.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mul r2.xyz, r12, r1.z
mov r1.z, c51
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r5.w, r5, -c11.x
add r1.z, r5.w, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r5
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r9.w, r1.z, c51, r9
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r5.w, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s5
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r5.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c54, c54.y
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r3.z, c51
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r5, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r5.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r9.w, r1.z, r2.x
endif
mul r12.xyz, r12, r9.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.z, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.z, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r3.w, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.w, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r3, r2.y
mul r1.w, r1, r2.x
mul r3.z, r1.w, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c54.z
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3.z
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c54
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r3.y, c28.x
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.w, r2
mul r5.xyz, r11.w, -r5
mul r2.xyz, r2, c55.x
mul r1.w, r15, r1
mul r1.z, r1, r15
mad r3.xyz, r1.z, c55.yzww, r1.w
mad r2.xyz, r12, r3, r2
add r3.xyz, r2, c17
pow r2, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r2
pow r3, c53.w, r5.y
pow r2, c53.w, r5.z
mov r5.y, r3
mov r5.z, r2
mul r11.xyz, r11, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c51.z, c51.w
cmp r2.x, -r1.w, c51.z, c51.w
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r11.w, -r2.x, r1, r1.y
cmp r14.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r11.w, c51.z, c51.w
mov r2.xyz, r10
mov r14.x, r1
mov r10.xyz, c51.z
if_gt r1.y, c51.z
frc r1.x, r11.w
add r1.x, r11.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r16.y, r1.x, r1, -r1
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r1.xyz, r12, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r16.z, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r16.z, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r5, r1.xyzz, s4
mul r1.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r1.x
pow r1, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r1
pow r1, c53.w, r17.z
add r3.x, r14, r14.w
rcp r1.y, r14.w
add r1.w, -r14.x, r15.y
add r1.x, r3, -r15
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r17.z, r1
mul r1.xyz, r17, r1.x
mov r1.w, c51.z
mul r14.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r12
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r10.w, r2, c51, r10
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s5
add r3.w, r1.x, c51.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r10.w, r1.x, r1.z
endif
mul r14.xyz, r14, r10.w
endif
add r1.xyz, -r12, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
add r2.w, r1.x, c51
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r12.xyz, -r12, c18
dp3 r1.x, r12, r12
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r12
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c54.z
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r12.xyz, r14.w, -r12
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r15.w, r1.w
mul r1.w, r2, r15.z
mad r5.xyz, r1.w, c55.yzww, r3.y
mul r1.xyz, r1, c55.x
mad r1.xyz, r14, r5, r1
add r5.xyz, r1, c17
pow r1, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r1
pow r5, c53.w, r12.y
pow r1, c53.w, r12.z
mov r12.y, r5
mov r12.z, r1
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r3, r1.xyzz, s4
mul r1.x, r3.w, c29
mad r17.xyz, r3.z, -c27, -r1.x
pow r12, c53.w, r17.x
pow r1, c53.w, r17.y
add r1.x, r11.w, -r16.y
mov r12.y, r1
mul r11.w, r1.x, r14
pow r1, c53.w, r17.z
add r1.x, r11.w, r14
rcp r1.y, r11.w
add r1.x, r1, -r15
add r1.w, -r14.x, r15.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r12.z, r1
mul r1.xyz, r12, r1.x
mov r1.w, c51.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r2.w, r5, -c25
mov r1.xyz, r5
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r9.w, r2, c51, r9
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s5
add r3.w, r1.x, c51.y
add r2.w, r5, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r5.w, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r5.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r9.w, r1.x, r1.z
endif
mul r12.xyz, r12, r9.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
rcp r3.z, r1.y
add r2.w, r1.x, c51
mul r3.w, r2, r3.z
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r3.w, r3, r3.z
dp3 r1.x, r5, r5
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.w, r1.x, r3
mul r1.xyz, r3.z, r5
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.w, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.z, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.z, r3, c54
mul r1.y, r3.z, r3.z
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r2.w, r3.y, c28.x
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r2.w, r1
mul r5.xyz, r11.w, -r5
mul r1.w, r1, r15.z
mul r2.w, r15, r2
mad r3.xyz, r1.w, c55.yzww, r2.w
mul r1.xyz, r1, c55.x
mad r1.xyz, r12, r3, r1
add r3.xyz, r1, c17
pow r1, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r1
pow r3, c53.w, r5.y
pow r1, c53.w, r5.z
mov r5.y, r3
mov r5.z, r1
mul r11.xyz, r11, r5
endif
add r1.x, r16, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c51, c51.w
cmp r1.y, -r0.z, c51.z, c51.w
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r11.w, -r1.y, r0.z, r0.y
cmp r14.w, -r1.y, r0, r1.x
mov r1.xyz, r10
cmp_pp r0.y, -r11.w, c51.z, c51.w
mov r14.x, r0
mov r10.xyz, c51.z
if_gt r0.y, c51.z
frc r0.x, r11.w
add r0.x, r11.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r16.y, r0.x, r0, -r0
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r0.xyz, r12, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r16.z, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r16.z, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r5, r0.xyzz, s4
mul r0.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r0.x
pow r0, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r0
pow r0, c53.w, r17.z
add r3.x, r14, r14.w
rcp r0.y, r14.w
add r0.w, -r14.x, r15.y
add r0.x, r3, -r15
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r17.z, r0
mul r0.xyz, r17, r0.x
mov r0.w, c51.z
mul r14.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r12
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r10.w, r1, c51, r10
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s5
add r3.z, r0.x, c51.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c51.w
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c51.y
mad r2.w, -r1, c54.x, c54.y
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c51
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.y, c54.x, c54.y
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0, r0.y
mul r10.w, r0.x, r0.z
endif
mul r14.xyz, r14, r10.w
endif
add r0.xyz, -r12, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
add r1.w, r0.x, c51
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r12.xyz, -r12, c18
dp3 r0.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r12
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c54.z
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c54.z
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c51.w
mul r0.w, r0.x, c54.z
mul r1.w, r5.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r12.xyz, r14.w, -r12
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r5.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r14, r5, r0
add r5.xyz, r0, c17
pow r0, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r0
pow r5, c53.w, r12.y
pow r0, c53.w, r12.z
mov r12.y, r5
mov r12.z, r0
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r3, r0.xyzz, s4
mul r0.x, r3.w, c29
mad r9.xyz, r3.z, -c27, -r0.x
pow r0, c53.w, r9.y
pow r12, c53.w, r9.x
add r0.x, r11.w, -r16.y
mul r11.w, r0.x, r14
mov r9.y, r0
pow r0, c53.w, r9.z
add r0.x, r11.w, r14
rcp r0.y, r11.w
add r0.x, r0, -r15
add r0.w, -r14.x, r15.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r9.x, r12
mov r9.z, r0
mul r0.xyz, r9, r0.x
mov r0.w, c51.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
mov r0.xyz, r5
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r9.w, r1, c51, r9
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s5
add r3.z, r0.x, c51.y
mul r1.w, r2, r1
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r5.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c51.y
mad r0.y, -r0.x, c54.x, c54
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c51.w
mad r1.w, r1, r3.z, c51
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r5.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.x, c54.x, c54.y
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r5.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0.y, r0
mul r9.w, r0.x, r0.z
endif
mul r12.xyz, r12, r9.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c51
mul r3.z, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.z, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.z, r0, c54
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c54.z
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c54.z
min r0.y, r3.z, c51.w
mul r1.w, r3.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r5.xyz, r11.w, -r5
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r3.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r12, r3, r0
add r3.xyz, r0, c17
pow r0, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r0
pow r3, c53.w, r5.y
pow r0, c53.w, r5.z
mov r5.y, r3
mov r5.z, r0
mul r11.xyz, r11, r5
endif
mov r0, c37
add r3, -c41, r0
mov r9, c39
mov r14, c38
add r9, -c43, r9
mov r0, c36
mad r5, r8.w, r3, c41
add r3, -c40, r0
texldl r0.w, r7.xyzz, s1
mov r0.y, r0.w
texldl r1.w, r7.xyzz, s0
mad r3, r8.w, r3, c40
mov r0.x, r1.w
mov r0.zw, c51.w
dp4 r12.x, r3, r0
dp4 r3.x, r3, r3
mad r9, r8.w, r9, c43
add r14, -c42, r14
mad r8, r8.w, r14, c42
dp4 r12.y, r5, r0
dp4 r12.w, r9, r0
dp4 r12.z, r8, r0
add r0, r12, c51.y
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r3.w, r9, r9
mad r0, r3, r0, c51.w
mad r1.xyz, r10, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r13
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r0.xyz, r0.z, c58, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c56.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul r1.y, r0.w, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
min r0.x, r0, c56.w
add r0.z, r0.x, c57.w
cmp r0.z, r0, c51.w, c51
mul_pp r1.x, r0.z, c58.w
add r0.x, r0, -r1
mul r1.x, r0, c59
frc r0.w, r1.x
add r0.w, r1.x, -r0
mul_pp r1.x, r0.w, c59.z
mul r2.xyz, r11.y, c56
mad r2.xyz, r11.x, c57, r2
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.w, c59.y
exp_pp r0.w, r0.x
mad_pp r0.x, -r0.z, c51, c51.w
mul_pp r0.x, r0, r0.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r1
abs_pp r0.z, r0.x
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
mad r1.xyz, r11.z, c58, r2
add r2.x, r1, r1.y
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c51.y
add r1.z, r1, r2.x
mul_pp r0.z, r0, c61.x
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r2.x, r1.z, c56.w
mul r0.z, r0, c61.y
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c60.w
frc r2.y, r2.x
add r0.w, r2.x, -r2.y
min r0.w, r0, c56
add r2.x, r0.w, c57.w
mul r1.w, r1, c55.x
frc r2.y, r1.w
add r1.w, r1, -r2.y
cmp r2.x, r2, c51.w, c51.z
mul_pp r0.z, r0, c59
cmp_pp r0.x, -r0, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r2.x, c58.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c61.w
mul r1.x, r0.w, c59
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c59
add r0.w, r0, -r1.z
min r1.w, r1, c59
mad r1.z, r0.w, c60.x, r1.w
add_pp r0.w, r1.x, c59.y
exp_pp r1.x, r0.w
mad_pp r0.w, -r2.x, c51.x, c51
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c60.y, c60
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r2.x, r1.w
add_pp r1.w, r1, -r2.x
exp_pp r2.x, -r1.w
mad_pp r1.z, r1, r2.x, c51.y
mul r0.x, r0, c61.z
add r0.w, -r0.x, -r0.z
add r0.w, r0, c51
mul r2.xyz, r0.y, c62
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c61.x
mul r2.w, r0.z, c61.y
mad r0.xyz, r0.x, c63, r2
add_pp r1.z, r1.w, c60.w
frc r2.x, r2.w
mad r0.xyz, r0.w, c64, r0
add r1.w, r2, -r2.x
mul_pp r1.z, r1, c59
cmp_pp r1.x, -r1, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.z
mul r1.z, r2.x, c61.w
add r1.x, r1, r1.w
mul r1.x, r1, c61.z
add r1.w, -r1.x, -r1.z
add r0.w, r1, c51
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r2.xyz, r1.y, c62
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c51.z
mad r2.xyz, r1.y, c63, r2
mul r0.w, r0, r1.x
mad r2.xyz, r0.w, c64, r2
add r1.xyz, -r0, c51.wzzw
max r2.xyz, r2, c51.z
mad r1.xyz, r1, c48.x, r0
mad r2.xyz, -r2, c48.x, r2
else
add r2.xy, r7, c49.xzzw
add r1.xy, r2, c49.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s6
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r2.z, r1.w
add_pp r1.w, r1, -r2.z
exp_pp r2.z, -r1.w
mad_pp r1.z, r1, r2, c51.y
mul_pp r1.z, r1, c61.x
mul r2.z, r1, c61.y
add_pp r1.z, r1.w, c60.w
frc r2.w, r2.z
add r1.w, r2.z, -r2
add r8.xy, r1, -c49.xzzw
mul r2.z, r2.w, c61.w
mul_pp r1.z, r1, c59
cmp_pp r0.y, -r0, c51.w, c51.z
mad_pp r0.y, r0, c58.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c61.z
add r2.w, -r0.y, -r2.z
mov r8.z, r7
texldl r1, r8.xyzz, s6
abs_pp r3.x, r1.y
log_pp r3.y, r3.x
frc_pp r3.z, r3.y
add_pp r3.w, r3.y, -r3.z
add r2.w, r2, c51
mul r2.w, r2, r0.x
rcp r2.z, r2.z
mul r0.y, r0, r0.x
mul r2.w, r2, r2.z
exp_pp r3.y, -r3.w
mul r0.y, r2.z, r0
mad_pp r2.z, r3.x, r3.y, c51.y
mul r3.xyz, r0.x, c62
mad r3.xyz, r0.y, c63, r3
mul_pp r0.x, r2.z, c61
mul r0.y, r0.x, c61
mad r3.xyz, r2.w, c64, r3
frc r2.z, r0.y
add r2.w, r0.y, -r2.z
add_pp r0.x, r3.w, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r1.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r2.w
mul r0.y, r2.z, c61.w
mul r0.x, r0, c61.z
add r1.y, -r0.x, -r0
add r1.y, r1, c51.w
mov r2.z, r7
texldl r2, r2.xyzz, s6
abs_pp r3.w, r2.y
log_pp r4.x, r3.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r4.y, r4.x
add_pp r0.y, r4.x, -r4
mul r4.xyz, r1.x, c62
mad r4.xyz, r0.x, c63, r4
exp_pp r1.x, -r0.y
mad_pp r0.x, r3.w, r1, c51.y
mad r4.xyz, r1.y, c64, r4
mul_pp r0.x, r0, c61
mul r1.x, r0, c61.y
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r2.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r1
max r4.xyz, r4, c51.z
max r3.xyz, r3, c51.z
add r5.xyz, r3, -r4
texldl r3, r7.xyzz, s6
add r7.xy, r8, -c49.zyzw
mul r1.x, r0, c61.z
mul r1.y, r1, c61.w
add r2.y, -r1.x, -r1
mul r0.xy, r7, c50
frc r0.xy, r0
mad r5.xyz, r0.x, r5, r4
abs_pp r4.x, r3.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r2.y, r2, c51.w
mul r2.y, r2, r2.x
rcp r1.y, r1.y
mul r1.x, r1, r2
mul r2.y, r2, r1
exp_pp r4.y, -r4.w
mul r1.x, r1.y, r1
mad_pp r1.y, r4.x, r4, c51
mul r4.xyz, r2.x, c62
mad r4.xyz, r1.x, c63, r4
mad r4.xyz, r2.y, c64, r4
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
frc r2.x, r1.y
add r2.y, r1, -r2.x
add_pp r1.x, r4.w, c60.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.y, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
rcp r2.y, r1.y
mul r1.x, r1, r3
add r2.x, r2, c51.w
mul r1.y, r2.x, r3.x
abs_pp r2.x, r2.w
mul r1.y, r1, r2
log_pp r3.y, r2.x
mul r1.x, r2.y, r1
frc_pp r2.y, r3
mul r8.xyz, r3.x, c62
mad r8.xyz, r1.x, c63, r8
add_pp r2.y, r3, -r2
exp_pp r1.x, -r2.y
mad r8.xyz, r1.y, c64, r8
mad_pp r1.x, r2, r1, c51.y
mul_pp r1.x, r1, c61
mul r1.y, r1.x, c61
frc r2.x, r1.y
add_pp r1.x, r2.y, c60.w
add r2.y, r1, -r2.x
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r2.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
abs_pp r2.y, r3.w
log_pp r3.x, r2.y
frc_pp r3.y, r3.x
add_pp r3.x, r3, -r3.y
max r8.xyz, r8, c51.z
max r4.xyz, r4, c51.z
add r4.xyz, r4, -r8
mad r4.xyz, r0.x, r4, r8
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
add r2.x, r2, c51.w
mul r2.x, r2.z, r2
rcp r1.y, r1.y
mul r2.w, r2.x, r1.y
mul r1.x, r2.z, r1
exp_pp r2.x, -r3.x
mul r1.x, r1.y, r1
mad_pp r1.y, r2, r2.x, c51
mul r2.xyz, r2.z, c62
mad r2.xyz, r1.x, c63, r2
mad r2.xyz, r2.w, c64, r2
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
max r8.xyz, r2, c51.z
frc r2.w, r1.y
add_pp r1.x, r3, c60.w
add r3.x, r1.y, -r2.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
mul r1.y, r2.w, c61.w
add r1.x, r1, r3
mul r1.x, r1, c61.z
add r2.w, -r1.x, -r1.y
rcp r2.y, r1.y
add r2.x, r2.w, c51.w
mul r1.y, r3.z, r2.x
mul r3.x, r1.y, r2.y
mul r1.y, r3.z, r1.x
mul r3.y, r2, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r3.w, r1.y, -r2
exp_pp r1.y, -r3.w
mad_pp r1.x, r1, r1.y, c51.y
mul_pp r1.y, r1.x, c61.x
abs_pp r1.x, r0.w
mul r4.w, r1.y, c61.y
frc r5.w, r4
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r1.y, r1, -r2.w
exp_pp r2.w, -r1.y
mad_pp r1.x, r1, r2.w, c51.y
mul r2.xyz, r3.z, c62
mad r2.xyz, r3.y, c63, r2
mad r2.xyz, r3.x, c64, r2
max r2.xyz, r2, c51.z
add r3.xyz, r8, -r2
add_pp r3.w, r3, c60
add r4.w, r4, -r5
mad r2.xyz, r0.x, r3, r2
mul_pp r3.w, r3, c59.z
cmp_pp r1.w, -r1, c51, c51.z
mad_pp r1.w, r1, c58, r3
add r1.w, r1, r4
mul r3.w, r1, c61.z
mul r4.w, r5, c61
mul_pp r1.x, r1, c61
mul r1.w, r1.x, c61.y
add_pp r1.x, r1.y, c60.w
frc r2.w, r1
add r1.y, r1.w, -r2.w
add r5.w, -r3, -r4
mul r8.x, r1.z, r3.w
rcp r3.w, r4.w
mul r4.w, r3, r8.x
mul r1.w, r2, c61
mul_pp r1.x, r1, c59.z
cmp_pp r0.w, -r0, c51, c51.z
mad_pp r0.w, r0, c58, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c61.z
add r1.x, -r0.w, -r1.w
add r1.y, r5.w, c51.w
add r2.w, r1.x, c51
mul r5.w, r1.z, r1.y
mul r1.xyz, r1.z, c62
mul r3.w, r5, r3
mad r1.xyz, r4.w, c63, r1
mad r1.xyz, r3.w, c64, r1
mul r3.w, r0.z, r0
mul r2.w, r0.z, r2
rcp r0.w, r1.w
mul r8.xyz, r0.z, c62
mul r0.z, r0.w, r3.w
mad r8.xyz, r0.z, c63, r8
mul r0.z, r2.w, r0.w
mad r8.xyz, r0.z, c64, r8
max r1.xyz, r1, c51.z
max r8.xyz, r8, c51.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r3.xyz, r1, -r2
add r5.xyz, r5, -r4
mad r1.xyz, r0.y, r5, r4
mad r2.xyz, r0.y, r3, r2
endif
mov r0.x, c8.w
mul r0.x, c52.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s7
else
mov r0.xyz, c51.z
endif
mul r2.xyz, r2, r6.w
mad r0.xyz, r0, r2, r6
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r1.xyz, r0.z, c58, r1
add r0.x, r1, r1.y
add r0.x, r1.z, r0
rcp r0.x, r0.x
mul r0.zw, r1.xyxy, r0.x
mul r0.x, r0.z, c56.w
frc r0.y, r0.x
add r0.x, r0, -r0.y
min r0.x, r0, c56.w
add r0.y, r0.x, c57.w
cmp r1.x, r0.y, c51.w, c51.z
mul_pp r0.y, r1.x, c58.w
add r1.z, r0.x, -r0.y
mul r0.x, r1.z, c59
frc r0.y, r0.x
add r1.w, r0.x, -r0.y
mul r3.xyz, r2.y, c56
mad r0.xyz, r2.x, c57, r3
mad r0.xyz, r2.z, c58, r0
add_pp r2.x, r1.w, c59.y
add r2.y, r0.x, r0
add r2.y, r0.z, r2
exp_pp r2.x, r2.x
mad_pp r1.x, -r1, c51, c51.w
mul_pp r0.z, r1.x, r2.x
rcp r2.x, r2.y
mul_pp r1.x, r1.w, c59.z
mul r2.xy, r0, r2.x
add r0.x, r1.z, -r1
mul r1.z, r2.x, c56.w
mul r0.w, r0, c55.x
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r0.w, r0, c59
mad r0.x, r0, c60, r0.w
mad r0.x, r0, c60.y, c60.z
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c56.w
add r1.z, r1.x, c57.w
cmp r0.w, r1.z, c51, c51.z
mov_pp oC0.x, r1.y
mul_pp r1.z, r0.w, c58.w
mul_pp oC0.y, r0.z, r0.x
add r0.x, r1, -r1.z
mul r0.z, r0.x, c59.x
frc r1.x, r0.z
add r0.z, r0, -r1.x
mul_pp r1.x, r0.z, c59.z
mul r1.y, r2, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.z, c59.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r0.w, c51, c51.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r1.x
mov_pp oC0.z, r0.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 compose sky with 3 cloud layers
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
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 3 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 6 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 5 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 8 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 4 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 7 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[65] = { program.local[0..50],
		{ 1, 0, 2, -1 },
		{ -1000000, 0.995, 1000000, 0.001 },
		{ 0.75, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625, 1024, 0.00390625 },
		{ 0.0047619049, 0.63999999, 0 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 } };
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
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[2], 2D;
TEX   R6, fragment.texcoord[0], texture[1], 2D;
TEX   R7, fragment.texcoord[0], texture[0], 2D;
MOVR  R9.z, R8.y;
MOVR  R9.y, R6;
MOVR  R8.y, R6.z;
MOVR  R2.xyz, c[9];
MOVR  R3.x, c[52];
MOVR  R9.w, c[51].y;
MOVR  R9.x, R7.y;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].z, -R0;
MOVR  R0.z, c[51].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[13].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[51].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.w, R2, R1;
MOVR  R0, c[24];
MULR  R3.z, R3.w, R3.w;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.w, R1;
MOVR  R0.x, c[52];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.w, R0.y;
MOVR  R0.y, c[52].x;
MOVXC RC.y, R2;
MOVXC RC.z, R2.w;
MOVR  R2, c[42];
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.w, R0.z;
MOVR  R0.z, c[52].x;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.w, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[35];
SGER  H0.x, c[51].y, R0;
ADDR  R2, -R2, c[38];
MADR  R3, H0.x, R2, c[42];
MOVR  R0, c[41];
ADDR  R0, -R0, c[37];
MADR  R5, H0.x, R0, c[41];
MOVR  R0, c[40];
ADDR  R0, -R0, c[36];
MADR  R4, H0.x, R0, c[40];
MOVR  R0.z, R8.w;
MOVR  R2, c[43];
ADDR  R2, -R2, c[39];
MADR  R2, H0.x, R2, c[43];
MOVR  R0.y, R6.w;
MOVR  R0.x, R7.w;
MOVR  R0.w, c[51].x;
DP4R  R1.w, R0, R2;
DP4R  R1.z, R0, R3;
DP4R  R1.x, R0, R4;
DP4R  R1.y, R0, R5;
DP4R  R0.w, R2, R2;
DP4R  R0.z, R3, R3;
DP4R  R6.y, R2, R9;
MOVR  R8.w, c[51].y;
DP4R  R0.x, R4, R4;
DP4R  R0.y, R5, R5;
MADR  R0, R1, R0, -R0;
ADDR  R0, R0, c[51].x;
MOVR  R1.z, R8.x;
MOVR  R8.x, R7.z;
MULR  R1.x, R0, R0.y;
MULR  R6.w, R1.x, R0.z;
MOVR  R1.y, R6.x;
MOVR  R1.w, c[51].y;
MOVR  R1.x, R7;
DP4R  R6.x, R2, R1;
DP4R  R6.z, R2, R8;
DP4R  R2.x, R3, R1;
DP4R  R2.z, R3, R8;
DP4R  R2.y, R3, R9;
DP4R  R3.x, R5, R1;
DP4R  R1.x, R4, R1;
MADR  R2.xyz, R0.z, R6, R2;
DP4R  R1.z, R4, R8;
DP4R  R1.y, R4, R9;
DP4R  R3.z, R5, R8;
DP4R  R3.y, R5, R9;
MADR  R2.xyz, R0.y, R2, R3;
MADR  R2.xyz, R0.x, R2, R1;
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[49].xyxz;
ADDR  R0.xy, R1.zwzw, c[49].zyzw;
MULR  R2.w, R6, R0;
ADDR  R0.zw, R0.xyxy, -c[49].xyxz;
TEX   R0.x, R0, texture[4], 2D;
TEX   R1.x, R0.zwzw, texture[4], 2D;
ADDR  R0.y, R1.x, -R0.x;
ADDR  R15.xy, R0.zwzw, -c[49].zyzw;
MULR  R0.zw, R15.xyxy, c[50].xyxy;
FRCR  R0.zw, R0;
MADR  R0.x, R0.z, R0.y, R0;
TEX   R1.x, fragment.texcoord[0], texture[4], 2D;
TEX   R3.x, R1.zwzw, texture[4], 2D;
ADDR  R1.y, R3.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[8].w, -c[8];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[8].w;
TEX   R0.x, fragment.texcoord[0], texture[3], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[8];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R7.w, R0.z, R0.x;
ADDR  R0.x, R7.w, -R0.y;
SGTRC HC.x, |R0|, c[47];
IF    NE.x;
MOVR  R5.w, c[52].x;
MOVR  R5.x, c[52];
MOVR  R5.z, c[52].x;
MOVR  R5.y, c[52].x;
MOVR  R4.x, c[52].z;
MULR  R1.xy, R15, c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].z, -R0;
MOVR  R0.z, c[51].w;
DP3R  R0.w, R0, R0;
RSQR  R8.x, R0.w;
MULR  R0.xyz, R8.x, R0;
MOVR  R0.w, c[51].y;
DP4R  R6.z, R0, c[2];
DP4R  R6.y, R0, c[1];
DP4R  R6.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R1.x, c[0].w;
MOVR  R1.z, c[2].w;
MOVR  R1.y, c[1].w;
MULR  R9.xyz, R1, c[13].x;
ADDR  R7.xyz, R9, -c[9];
DP3R  R4.z, R6, R7;
MULR  R4.y, R4.z, R4.z;
DP3R  R4.w, R7, R7;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R5.x(EQ), R10;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R5.x(NE.z), -R4.z, R1;
MOVXC RC.z, R3;
MOVR  R5.z(EQ), R10.x;
MOVXC RC.z, R3.w;
RCPR  R0.x, R0.x;
ADDR  R5.z(NE.y), -R4, R0.x;
MOVXC RC.y, R3;
RSQR  R0.x, R1.w;
MOVR  R5.w(EQ.z), R10.x;
RCPR  R0.x, R0.x;
ADDR  R5.w(NE), -R4.z, R0.x;
RSQR  R0.x, R1.y;
MOVR  R5.y(EQ), R10.x;
RCPR  R0.x, R0.x;
ADDR  R5.y(NE.x), -R4.z, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R4.x(EQ), R10;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
MADR  R3.x, -c[12], c[12], R4.w;
ADDR  R0.z, R4.y, -R3.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R4.z, -R1;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R1.x, c[52].z;
MOVXC RC.z, R3;
MOVR  R1.x(EQ.z), R10;
RCPR  R0.x, R0.x;
ADDR  R1.x(NE.y), -R4.z, -R0;
RSQR  R0.x, R1.w;
MOVXC RC.y, R3;
MOVR  R1.w, c[52].z;
MOVR  R1.z, c[52];
MOVXC RC.z, R3.w;
MOVR  R1.z(EQ), R10.x;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R4, -R0.x;
RSQR  R0.x, R1.y;
MOVR  R1.y, c[52].z;
MOVR  R1.w(EQ.y), R10.x;
RCPR  R0.x, R0.x;
ADDR  R1.w(NE.x), -R4.z, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R4.w;
SLTRC HC.x, R4.y, R0;
MOVR  R1.y(EQ.x), R10.x;
ADDR  R0.y, R4, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R4.w, R1.z;
SGERC HC.x, R4.y, R0;
RCPR  R0.y, R0.y;
ADDR  R1.y(NE.x), -R4.z, -R0;
MOVXC RC.x, R1.y;
MOVR  R1.y(LT.x), c[52].z;
MOVR  R0.xy, c[51].y;
SLTRC HC.x, R4.y, R3;
MOVR  R0.xy(EQ.x), R10;
SGERC HC.x, R4.y, R3;
MOVR  R4.y, R1.w;
ADDR  R0.w, -R4.z, -R0.z;
ADDR  R3.y, -R4.z, R0.z;
MOVR  R4.z, R1.x;
MAXR  R0.z, R0.w, c[51].y;
MAXR  R0.w, R3.y, c[51].y;
MOVR  R0.xy(NE.x), R0.zwzw;
DP4R  R1.x, R5, c[35];
SGER  R6.w, c[51].y, R1.x;
MOVR  R1.x, c[52].y;
MULR  R1.x, R1, c[8].w;
MAXR  R1.w, R0.x, c[52];
SGER  H0.x, R7.w, R1;
DP4R  R0.z, R4, c[40];
DP4R  R0.w, R5, c[36];
ADDR  R0.w, R0, -R0.z;
MADR  R0.z, R6.w, R0.w, R0;
RCPR  R0.w, R8.x;
MULR  R0.w, R7, R0;
MADR  R1.y, -R0.w, c[13].x, R1;
MULR  R0.w, R0, c[13].x;
MADR  R0.w, H0.x, R1.y, R0;
MINR  R3.w, R0.y, R0;
ADDR  R1.z, R3.w, -R1.w;
RCPR  R0.x, R1.z;
MINR  R0.y, R3.w, R0.z;
MAXR  R11.y, R1.w, R0;
MULR  R8.w, R0.x, c[32].x;
ADDR  R1.y, R11, -R1.w;
MULR  R1.x, R8.w, R1.y;
RCPR  R3.y, c[32].x;
MULR  R9.w, R1.z, R3.y;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R6.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MOVR  R10.x, R0;
MOVR  R11.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R6.w, R0, c[46].y;
SLTR  H0.y, R1.x, R0.w;
SGTR  H0.x, R1, c[51].y;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R1.x;
RCPR  R3.x, R0.w;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R1.y, R3.x;
MOVR  R14.w(NE.x), R0;
MULR  R1.xyz, R7.zxyw, c[16].yzxw;
MADR  R1.xyz, R7.yzxw, c[16].zxyw, -R1;
DP3R  R0.w, R1, R1;
MULR  R3.xyz, R6.zxyw, c[16].yzxw;
MADR  R3.xyz, R6.yzxw, c[16].zxyw, -R3;
DP3R  R1.y, R1, R3;
DP3R  R1.x, R3, R3;
DP3R  R3.y, R7, c[16];
MADR  R0.w, -c[11].x, c[11].x, R0;
SLER  H0.y, R3, c[51];
MULR  R3.x, R1, R0.w;
MULR  R1.z, R1.y, R1.y;
ADDR  R0.w, R1.z, -R3.x;
SGTR  H0.z, R1, R3.x;
RCPR  R3.x, R1.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.z, -R1.y, R0.w;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVR  R1.z, c[52].x;
MOVR  R1.x, c[52].z;
ADDR  R0.w, -R1.y, -R0;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0.y;
MULR  R1.z(NE.x), R3.x, R3;
MULR  R1.x(NE), R0.w, R3;
MOVR  R1.y, R1.z;
MOVR  R16.xy, R1;
MADR  R1.xyz, R6, R1.x, R9;
ADDR  R1.xyz, R1, -c[9];
DP3R  R0.w, R1, c[16];
SGTR  H0.z, R0.w, c[51].y;
MULXC HC.x, H0.y, H0.z;
MOVR  R16.xy(NE.x), c[52].zxzw;
MOVXC RC.x, H0;
DP4R  R1.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R12.y, R11, R0.w;
DP4R  R1.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R13.y, R12, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R1.x, R5, c[39];
ADDR  R1.x, R1, -R0.w;
MADR  R0.w, R6, R1.x, R0;
MINR  R0.w, R3, R0;
DP3R  R0.y, R6, c[16];
MULR  R13.x, R0, c[33];
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[51].z;
MADR  R0.x, c[30], c[30], R0;
MADR  R15.z, R0.y, c[53].x, c[53].x;
ADDR  R0.y, R0.x, c[51].x;
MOVR  R0.x, c[51];
POWR  R0.y, R0.y, c[53].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R5.w, R13.y, R0;
MOVR  R12.x, R0.z;
MOVR  R12.w, R3;
MULR  R15.w, R0.x, R0.y;
MOVR  R8.xyz, c[51].x;
MOVR  R7.xyz, c[51].y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.y, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R11.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R13.y, -R12.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R12.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R5.w, -R13.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R12.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R12.x;
RCPR  R0.z, R12.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R12.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R13.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.w, -R5.w;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51].y;
SLTR  H0.y, R0, R13.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R13.x;
RCPR  R0.z, R13.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R13.xyz, R7;
MOVX  H0.x, c[51].y;
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[51];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].y;
MOVR  R1.w, R5;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].y;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[51].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].z, c[53].z;
TEX   R4, R0, texture[5], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[53].w, R0.x;
POWR  R0.y, c[53].w, R0.y;
POWR  R0.z, c[53].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[51];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R10.w;
MOVR  R10.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[51].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[54].w;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51], R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[6], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].z, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[51];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].z, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51].z, R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R10.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R10.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[51];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[55];
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[55].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[55].w;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[55];
MINR  R0.y, R1.x, c[51].x;
MINR  R0.w, R0, c[51].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].x;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].y;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55], R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[53].w, R1.x;
POWR  R0.y, c[53].w, R1.y;
POWR  R0.z, c[53].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
MOVR  R0, c[41];
ADDR  R1, -R0, c[37];
MOVR  R5, c[42];
ADDR  R5, -R5, c[38];
MOVR  R0, c[40];
MADR  R4, R6.w, R1, c[41];
ADDR  R1, -R0, c[36];
MADR  R3, R6.w, R1, c[40];
TEX   R0.w, R15, texture[2], 2D;
MOVR  R0.z, R0.w;
TEX   R1.w, R15, texture[1], 2D;
MOVR  R0.y, R1.w;
TEX   R0.w, R15, texture[0], 2D;
MOVR  R0.x, R0.w;
MOVR  R0.w, c[51].x;
MADR  R5, R6.w, R5, c[42];
MOVR  R1, c[43];
ADDR  R1, -R1, c[39];
MADR  R1, R6.w, R1, c[43];
DP4R  R6.w, R0, R1;
DP4R  R6.x, R0, R3;
DP4R  R6.y, R0, R4;
DP4R  R6.z, R0, R5;
DP4R  R0.w, R1, R1;
DP4R  R0.x, R3, R3;
DP4R  R0.y, R4, R4;
DP4R  R0.z, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[51].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R12;
MADR  R1.xyz, R1, R0.y, R11;
MADR  R1.xyz, R1, R0.x, R10;
MULR  R0.xyz, R1.y, c[59];
MADR  R0.xyz, R1.x, c[58], R0;
MADR  R0.xyz, R1.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].z;
SGER  H0.x, R0, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[57].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[59].w;
ADDH  H0.y, H0, -c[58].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R8.y, c[59];
MADR  R1.xyz, R8.x, c[58], R1;
MADR  R1.xyz, R8.z, c[57], R1;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0.w, c[54].x;
MADR  R0.z, R0.x, c[60].x, R0;
MOVR  R0.x, c[51];
MADR  H0.z, R0, c[60].y, R0.x;
MADH  H0.x, H0, c[51].z, H0.y;
MULH  H0.x, H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
LG2H  H0.z, |H0.x|;
FLRH  H0.z, H0;
ADDH  H0.w, H0.z, c[58];
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R1.z, R0, c[56];
SGEH  H0.y, c[51], H0.x;
EX2H  H0.z, -H0.z;
MULH  H0.x, |H0|, H0.z;
MADH  H0.x, H0, c[60].z, -c[60].z;
MULR  R1.x, H0, c[60].w;
FLRR  R0.z, R1.x;
MULH  H0.w, H0, c[59];
MADH  H0.y, H0, c[56].w, H0.w;
ADDR  R0.z, H0.y, R0;
SGER  H0.x, R1.z, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R1.w, R1.z, -H0.y;
MULR  R1.z, R1.w, c[57].w;
FLRR  H0.y, R1.z;
MULH  H0.z, H0.y, c[59].w;
FRCR  R1.x, R1;
ADDH  H0.y, H0, -c[58].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.x, R1, c[61].y;
MULR  R0.z, R0, c[61].x;
ADDR  R1.z, -R0, -R1.x;
MADR  R1.z, R1, R0.y, R0.y;
MADH  H0.x, H0, c[51].z, H0.y;
ADDR  R1.w, R1, -H0.z;
MINR  R0.w, R0, c[54].x;
MADR  R0.w, R1, c[60].x, R0;
MADR  H0.z, R0.w, c[60].y, R0.x;
MULH  H0.x, H0, H0.z;
RCPR  R0.x, R1.x;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MULR  R0.z, R0, R0.y;
ADDH  H0.y, H0, c[58].w;
MULR  R0.w, R1.z, R0.x;
MULR  R1.x, R0, R0.z;
MULR  R0.xyz, R0.y, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R3.xyz, R0, c[51].y;
MADH  H0.z, H0, c[60], -c[60];
MULR  R1.x, H0.z, c[60].w;
FRCR  R0.w, R1.x;
MULR  R0.w, R0, c[61].y;
MULR  R0.xyz, R1.y, c[64];
FLRR  R1.x, R1;
MULH  H0.y, H0, c[59].w;
SGEH  H0.x, c[51].y, H0;
MADH  H0.x, H0, c[56].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.z, R1.x, c[61].x;
ADDR  R1.x, -R1.z, -R0.w;
MADR  R1.x, R1, R1.y, R1.y;
MULR  R1.z, R1, R1.y;
RCPR  R0.w, R0.w;
MULR  R1.y, R0.w, R1.z;
MADR  R0.xyz, R1.y, c[63], R0;
MULR  R0.w, R1.x, R0;
ADDR  R1.xyz, -R3, c[51].xyyw;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R0.xyz, R0, c[51].y;
MADR  R3.xyz, R1, c[48].x, R3;
MADR  R1.xyz, -R0, c[48].x, R0;
ELSE;
ADDR  R6.xy, R15, c[49].xzzw;
ADDR  R0.xy, R6, c[49].zyzw;
TEX   R4, R0, texture[7], 2D;
ADDR  R7.xy, R0, -c[49].xzzw;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R4|, H0;
MADH  H0.y, H0, c[60].z, -c[60].z;
MULR  R0.z, H0.y, c[60].w;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[61].y;
ADDH  H0.x, H0, c[58].w;
MULH  H0.z, H0.x, c[59].w;
SGEH  H0.xy, c[51].y, R4.ywzw;
TEX   R3, R7, texture[7], 2D;
MADH  H0.x, H0, c[56].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[61].x;
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[58].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R4.x;
MADR  R0.w, R0, R4.x, R4.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R4.x, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
MAXR  R1.xyz, R0, c[51].y;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[51].y, R3.xyyw;
MULR  R0.z, R0.x, c[61].y;
MULH  H0.x, H0, c[59].w;
RCPR  R3.y, R0.z;
MADH  H0.x, H0.z, c[56].w, H0;
FLRR  R0.y, R0.w;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[61];
MULR  R0.w, R0.x, R3.x;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R3.x, R3.x;
MULR  R1.w, R0.y, R3.y;
MULR  R0.xyz, R3.x, c[64];
MULR  R0.w, R3.y, R0;
MADR  R5.xyz, R0.w, c[63], R0;
TEX   R0, R6, texture[7], 2D;
MADR  R5.xyz, R1.w, c[62], R5;
MAXR  R6.xyz, R5, c[51].y;
ADDR  R5.xyz, R1, -R6;
TEX   R1, R15, texture[7], 2D;
ADDR  R15.xy, R7, -c[49].zyzw;
MULR  R3.xy, R15, c[50];
FRCR  R8.xy, R3;
MADR  R5.xyz, R8.x, R5, R6;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R4.x, H0.z, c[60].w;
ADDH  H0.x, H0, c[58].w;
SGEH  H1.xy, c[51].y, R0.ywzw;
MULH  H0.x, H0, c[59].w;
SGEH  H1.zw, c[51].y, R1.xyyw;
FRCR  R3.x, R4;
FLRR  R3.y, R4.x;
MADH  H0.x, H1, c[56].w, H0;
ADDR  R0.y, H0.x, R3;
MULR  R3.y, R3.x, c[61];
MULR  R3.x, R0.y, c[61];
ADDR  R0.y, -R3.x, -R3;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
RCPR  R3.y, R3.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R3.x, R3, R0;
MULR  R0.y, R0, R3;
MULR  R3.x, R3.y, R3;
MULR  R6.xyz, R0.x, c[64];
MADR  R6.xyz, R3.x, c[63], R6;
MADH  H0.z, H0, c[60], -c[60];
MADR  R6.xyz, R0.y, c[62], R6;
MULR  R0.x, H0.z, c[60].w;
FRCR  R0.y, R0.x;
MULR  R1.y, R0, c[61];
MADH  H0.x, H1.z, c[56].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.y, R0.x, c[61].x;
ADDR  R0.x, -R0.y, -R1.y;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
RCPR  R1.y, R1.y;
MADR  R0.x, R0, R1, R1;
MULR  R0.y, R0, R1.x;
MULR  R0.x, R0, R1.y;
MULR  R0.y, R1, R0;
MULR  R7.xyz, R1.x, c[64];
MADR  R7.xyz, R0.y, c[63], R7;
MADR  R7.xyz, R0.x, c[62], R7;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.x, H0.z, c[60].w;
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[51].y;
MAXR  R6.xyz, R6, c[51].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R8.x, R6, R7;
MADH  H0.x, H1.y, c[56].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
MULR  R0.y, R0, c[61];
MULR  R0.x, R0, c[61];
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
FRCR  R1.x, R0.w;
MULR  R1.y, R1.x, c[61];
RCPR  R3.x, R1.y;
MADH  H0.x, H1.w, c[56].w, H0;
FLRR  R0.w, R0;
ADDR  R0.w, H0.x, R0;
MULR  R1.x, R0.w, c[61];
ADDR  R0.w, -R1.x, -R1.y;
MADR  R0.w, R1.z, R0, R1.z;
MULR  R1.w, R1.z, R1.x;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[58].w;
MULR  R0.w, R0, R3.x;
MULR  R1.w, R3.x, R1;
MULR  R1.xyz, R1.z, c[64];
MADR  R1.xyz, R1.w, c[63], R1;
MADR  R1.xyz, R0.w, c[62], R1;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
MULH  H0.x, H0, c[59].w;
MADH  H0.z, H0.w, c[56].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULH  H0.z, |R4.w|, H0;
MULR  R3.y, R1.w, c[61].x;
MULR  R3.x, R0.w, c[61].y;
ADDR  R4.x, -R3.y, -R3;
MADR  R4.y, R3.z, R4.x, R3.z;
MADH  H0.z, H0, c[60], -c[60];
MULR  R0.w, H0.z, c[60];
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[58].w;
MULH  H0.x, H0, c[59].w;
MULR  R3.w, R1, c[61].y;
MAXR  R1.xyz, R1, c[51].y;
MAXR  R0.xyz, R0, c[51].y;
ADDR  R0.xyz, R0, -R1;
RCPR  R4.x, R3.x;
MULR  R4.w, R3.z, R3.y;
MULR  R4.w, R4.x, R4;
MULR  R3.xyz, R3.z, c[64];
MADR  R0.xyz, R8.x, R0, R1;
MADR  R3.xyz, R4.w, c[63], R3;
MULR  R4.x, R4.y, R4;
MADR  R3.xyz, R4.x, c[62], R3;
MAXR  R3.xyz, R3, c[51].y;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[56].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R1.w, R0, c[61].x;
ADDR  R0.w, -R1, -R3;
MULR  R4.w, R4.z, R1;
MADR  R0.w, R4.z, R0, R4.z;
RCPR  R1.w, R3.w;
MULR  R4.xyz, R4.z, c[64];
MULR  R3.w, R1, R4;
MADR  R4.xyz, R3.w, c[63], R4;
MULR  R0.w, R0, R1;
MADR  R4.xyz, R0.w, c[62], R4;
MAXR  R4.xyz, R4, c[51].y;
ADDR  R4.xyz, R4, -R3;
MADR  R1.xyz, R8.x, R4, R3;
ADDR  R1.xyz, R1, -R0;
MADR  R3.xyz, R8.y, R5, R6;
MADR  R1.xyz, R8.y, R1, R0;
ENDIF;
MOVR  R0.x, c[52].y;
MULR  R0.x, R0, c[8].w;
SGTRC HC.x, R7.w, R0;
IF    NE.x;
TEX   R0.xyz, R15, texture[8], 2D;
ELSE;
MOVR  R0.xyz, c[51].y;
ENDIF;
MULR  R1.xyz, R1, R2.w;
MADR  R0.xyz, R0, R1, R2;
ADDR  R2.xyz, R0, R3;
MULR  R0.xyz, R2.y, c[59];
MADR  R0.xyz, R2.x, c[58], R0;
MADR  R0.xyz, R2.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[59];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].z;
SGER  H0.x, R0, c[56].w;
MULH  H0.y, H0.x, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[57].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[58].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[59].w;
MADR  R2.xyz, R1.x, c[58], R2;
MADR  R1.xyz, R1.z, c[57], R2;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[56].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[51].z, H0.z;
MINR  R0.z, R1, c[56];
SGER  H0.z, R0, c[56].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[56].w;
MINR  R0.w, R0, c[54].x;
MADR  R0.x, R0, c[60], R0.w;
ADDR  R0.z, R0, -H0.y;
MOVR  R1.x, c[51];
MADR  H0.y, R0.x, c[60], R1.x;
MULR  R0.w, R0.z, c[57];
FLRR  H0.w, R0;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[59].w;
ADDR  R0.x, R0.z, -H0;
ADDH  H0.x, H0.w, -c[58].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[54].x;
MADR  R0.x, R0, c[60], R0.y;
MADR  H0.z, R0.x, c[60].y, R1.x;
MADH  H0.x, H0.y, c[51].z, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 3 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 6 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 5 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 8 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 4 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 7 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

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
def c51, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c52, -1000000.00000000, 0.99500000, 1000000.00000000, 0.00100000
def c53, 0.75000000, 1.50000000, 0.50000000, 2.71828198
defi i0, 255, 0, 1, 0
def c54, 2.00000000, 3.00000000, 1000.00000000, 10.00000000
def c55, 400.00000000, 5.60204458, 9.47328472, 19.64380264
def c56, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c57, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c58, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c59, 0.25000000, -15.00000000, 4.00000000, 255.00000000
def c60, 256.00000000, 0.00097656, 1.00000000, 15.00000000
def c61, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c62, -1.02170002, 1.97770000, 0.04390000, 0
def c63, 2.56509995, -1.16649997, -0.39860001, 0
def c64, 0.07530000, -0.25430000, 1.18920004, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c51.x, c51.y
mov r6, c39
mov r3, c38
add r3, -c42, r3
texldl r8, v0, s0
texldl r11, v0, s1
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c51.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
add r0.y, c24, r0
add r6, -c43, r6
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c13.x
add r2.xyz, r2, -c9
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c24, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
cmp r0.x, r0, r1.w, c52
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c51.w, c51.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c52.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c11.x
add r1.y, c24.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c51, c51.z
cmp r1.z, r1, r1.w, c52.x
cmp_pp r0.z, r1.x, c51.w, c51
cmp r1.x, r1, r1.w, c52
cmp r0.w, -r0, r1.z, r2.x
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c35
cmp r2.z, -r0.x, c51.w, c51
mad r7, r2.z, r6, c43
mad r6, r2.z, r3, c42
mov r1, c37
add r1, -c41, r1
mad r5, r2.z, r1, c41
texldl r1, v0, s2
mov r3.z, r1.x
mov r0, c36
add r0, -c40, r0
mad r4, r2.z, r0, c40
mov r0.z, r1.w
mov r1.x, r8.z
mov r0.y, r11.w
mov r0.w, c51
mov r0.x, r8.w
dp4 r2.w, r7, r0
dp4 r2.z, r6, r0
dp4 r2.y, r5, r0
dp4 r2.x, r4, r0
add r2, r2, c51.y
dp4 r0.w, r7, r7
dp4 r0.z, r6, r6
mov r3.y, r11.x
mov r3.x, r8
mov r3.w, c51.z
dp4 r8.x, r7, r3
mov r1.w, c51.z
dp4 r0.y, r5, r5
dp4 r0.x, r4, r4
mad r0, r0, r2, c51.w
mov r2.z, r1.y
mov r1.y, r11.z
dp4 r8.z, r7, r1
mov r2.x, r8.y
mov r2.y, r11
mov r2.w, c51.z
dp4 r8.y, r7, r2
dp4 r7.x, r6, r3
dp4 r7.z, r6, r1
dp4 r7.y, r6, r2
mad r6.xyz, r0.z, r8, r7
dp4 r7.x, r5, r3
dp4 r3.x, r4, r3
dp4 r7.z, r5, r1
dp4 r7.y, r5, r2
dp4 r3.y, r4, r2
mad r5.xyz, r0.y, r6, r7
dp4 r3.z, r4, r1
mad r6.xyz, r0.x, r5, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r2.xy, v0, c49.xzzw
add r0.xy, r2, c49.zyzw
add r3.xy, r0, -c49.xzzw
mov r0.z, v0.w
mov r3.z, v0.w
mov r2.z, v0.w
add r7.xy, r3, -c49.zyzw
mul r1.zw, r7.xyxy, c50.xyxy
texldl r0.x, r0.xyzz, s4
texldl r1.x, r3.xyzz, s4
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s4
texldl r2.x, r2.xyzz, s4
add r0.z, r2.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c8.w, -c8.z
rcp r0.y, r0.x
mul r0.y, r0, c8.w
texldl r0.x, v0, s3
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c8.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r6.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c47.x
mad r0.xy, r7, c51.x, c51.y
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.x, r0.w
mul r0.xyz, r2.x, r0
mov r0.w, c51.z
dp4 r8.z, r0, c2
dp4 r8.y, r0, c1
dp4 r8.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
mul r11.xyz, r8.zxyw, c16.yzxw
mad r11.xyz, r8.yzxw, c16.zxyw, -r11
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r9.xyz, r1, c13.x
add r5.xyz, r9, -c9
dp3 r2.y, r8, r5
dp3 r2.z, r5, r5
add r0.y, c25, r0
mad r0.z, -r0.y, r0.y, r2
mad r0.w, r2.y, r2.y, -r0.z
rsq r1.x, r0.w
add r0.x, c25, r0
mad r0.x, -r0, r0, r2.z
mad r0.x, r2.y, r2.y, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2.y, -r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
rcp r1.x, r1.x
cmp r0.x, r0, r9.w, c52.z
cmp r0.x, -r0.y, r0, r0.z
cmp_pp r0.y, r0.w, c51.w, c51.z
add r1.x, -r2.y, -r1
cmp r0.w, r0, r9, c52.z
cmp r0.y, -r0, r0.w, r1.x
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.x, c25.w, r0.z
mad r0.w, -r0, r0, r2.z
mad r0.z, r2.y, r2.y, -r0.w
mad r1.x, -r1, r1, r2.z
mad r1.y, r2, r2, -r1.x
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r2.y, -r0.w
cmp_pp r0.w, r0.z, c51, c51.z
rsq r1.z, r1.y
rcp r1.z, r1.z
cmp r0.z, r0, r9.w, c52
cmp r0.z, -r0.w, r0, r1.x
add r1.z, -r2.y, -r1
cmp r1.x, r1.y, r9.w, c52.z
cmp_pp r0.w, r1.y, c51, c51.z
cmp r0.w, -r0, r1.x, r1.z
mov r1.x, c11
add r1.y, c24.x, r1.x
mov r1.x, c11
add r1.z, c24.y, r1.x
mad r1.y, -r1, r1, r2.z
mad r1.x, r2.y, r2.y, -r1.y
mad r1.z, -r1, r1, r2
mad r1.w, r2.y, r2.y, -r1.z
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r2.y, r1.y
cmp_pp r1.y, r1.x, c51.w, c51.z
rsq r3.x, r1.w
rcp r3.x, r3.x
cmp r1.x, r1, r9.w, c52
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c51.w, c51.z
dp4 r2.w, r0, c41
dp4 r3.w, r0, c40
add r3.x, -r2.y, r3
cmp r1.w, r1, r9, c52.x
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c11.x
add r1.w, c24, r1.z
mad r1.w, -r1, r1, r2.z
mad r3.y, r2, r2, -r1.w
rsq r1.w, r3.y
rcp r3.x, r1.w
mov r1.z, c11.x
add r1.z, c24, r1
mad r1.z, -r1, r1, r2
mad r1.z, r2.y, r2.y, -r1
add r3.z, -r2.y, r3.x
rsq r1.w, r1.z
rcp r3.x, r1.w
cmp_pp r1.w, r3.y, c51, c51.z
cmp r3.y, r3, r9.w, c52.x
cmp r1.w, -r1, r3.y, r3.z
add r3.y, -r2, r3.x
cmp_pp r3.x, r1.z, c51.w, c51.z
cmp r1.z, r1, r9.w, c52.x
cmp r1.z, -r3.x, r1, r3.y
dp4 r3.x, r1, c37
dp4 r3.y, r1, c35
add r3.z, r3.x, -r2.w
cmp r8.w, -r3.y, c51, c51.z
mad r3.y, r8.w, r3.z, r2.w
dp4 r3.z, r1, c36
add r4.x, r3.z, -r3.w
mov r3.x, c11
add r3.x, c31, r3
mad r3.x, -r3, r3, r2.z
mad r2.w, r2.y, r2.y, -r3.x
rsq r3.x, r2.w
rcp r3.x, r3.x
add r3.z, -r2.y, -r3.x
cmp_pp r3.x, r2.w, c51.w, c51.z
cmp r2.w, r2, r9, c52.z
cmp r2.w, -r3.x, r2, r3.z
rcp r2.x, r2.x
mul r3.x, r7.w, r2
cmp r2.w, r2, r2, c52.z
mad r3.z, -r3.x, c13.x, r2.w
mad r2.z, -c12.x, c12.x, r2
mad r2.z, r2.y, r2.y, -r2
rsq r2.w, r2.z
mov r2.x, c8.w
mad r2.x, c52.y, -r2, r7.w
mad r3.w, r8, r4.x, r3
rcp r2.w, r2.w
mul r3.x, r3, c13
cmp r2.x, r2, c51.w, c51.z
mad r3.z, r2.x, r3, r3.x
add r2.x, -r2.y, -r2.w
add r2.y, -r2, r2.w
cmp_pp r3.x, r2.z, c51.w, c51.z
cmp r2.zw, r2.z, r10.xyxy, c51.z
mul r10.xyz, r5.zxyw, c16.yzxw
mad r10.xyz, r5.yzxw, c16.zxyw, -r10
max r2.x, r2, c51.z
max r2.y, r2, c51.z
cmp r2.xy, -r3.x, r2.zwzw, r2
min r3.x, r2.y, r3.z
dp4 r2.z, r0, c42
dp4 r0.y, r0, c43
dp4 r0.x, r1, c39
max r14.x, r2, c52.w
add r0.z, r0.x, -r0.y
min r2.y, r3.x, r3.w
max r4.x, r14, r2.y
dp4 r2.y, r1, c38
add r2.y, r2, -r2.z
mad r2.y, r8.w, r2, r2.z
min r2.x, r3, r3.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
min r0.x, r3, r2.y
max r2.x, r4, r2
mad r0.y, r8.w, r0.z, r0
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r8, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r14.x
rcp r0.z, r0.y
rcp r2.z, r1.w
add r1.y, r4.x, -r14.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c51.z, c51.w
cmp r0.w, -r1.z, c51.z, c51
mul_pp r2.y, r0.w, r2
cmp r11.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r14.w, -r2.y, r0, r1.y
dp3 r0.y, r10, r10
dp3 r1.y, r10, r11
dp3 r1.z, r11, r11
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
rsq r2.z, r1.w
dp3 r0.y, r5, c16
cmp r0.y, -r0, c51.w, c51.z
cmp r1.w, -r1, c51.z, c51
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c52, r1
mad r5.xyz, r8, r1.z, r9
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c52.x, r1
cmp r1.y, -r1, c51.z, c51.w
mul_pp r0.y, r0, r1
cmp r15.xy, -r0.y, r1.zwzw, c52.zxzw
mad r2.w, r8, r2, c45.y
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r8.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r8.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r8.w, r0, c46
dp3 r2.z, r8, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c51.w
mul r2.w, r2, c51.x
mad r2.w, c30.x, c30.x, r2
mul r15.z, r2, c53.x
mov r2.z, c30.x
add r2.z, c51.w, r2
add r2.w, r2, c51
mov r16.x, r3
pow r3, r2.w, c53.y
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r11.w, c51.z, c51.w
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r15.w, r2.z, r2
mov r11.xyz, c51.w
mov r10.xyz, c51.z
if_gt r2.y, c51.z
frc r2.y, r11.w
add r2.y, r11.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r16.y, r2, r2.z, -r2.z
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r16.z, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r16, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s5
mul r2.y, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r2.y
pow r13, c53.w, r17.x
pow r3, c53.w, r17.y
mov r13.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.w, -r14.x, r15.y
rcp r2.z, r14.w
add r2.y, r3.x, -r15.x
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r3
mul r13.xyz, r13, r2.y
mov r2.y, c51.z
mul r14.xyz, r13, c15
if_gt c34.x, r2.y
add r3.y, r16.z, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r12
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r10.w, r2.y, c51, r10
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s6
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r13.x, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c54.x, c54
mul r2.w, r2, r2
add r3.z, r13.w, c51.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c51
mul r2.y, r2, r2.z
mul r10.w, r2.y, r2
endif
mul r14.xyz, r14, r10.w
endif
add r13.xyz, -r12, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
add r13.xyz, -c21, r13
dp3 r3.z, r13, r13
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r12.xyz, -r12, c18
dp3 r3.y, r12, r12
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r12.xyz, r3.y, r12
dp3 r2.y, r12, r8
mul r3.z, r3, c54
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r12.xyz, c19
add r2.y, r2, c51.w
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c54.z
add r12.xyz, -c18, r12
dp3 r2.z, r12, r12
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c54.z
min r2.w, r2.y, c51
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c54.z
mul r2.z, r5.y, c28.x
min r2.y, r2, c51.w
mul r12.xyz, r2.w, c23
mad r12.xyz, r2.y, c20, r12
mul r2.y, r5, c29.x
mad r13.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r12.xyz, r12, c54.w
mul r12.xyz, r2.z, r12
mul r12.xyz, r12, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r5.xyz, r2.y, c55.yzww, r2.z
mad r5.xyz, r14, r5, r12
mul r12.xyz, r14.w, -r13
add r13.xyz, r5, c17
pow r5, c53.w, r12.x
mul r13.xyz, r13, r14.w
mad r10.xyz, r13, r11, r10
mov r12.x, r5
pow r13, c53.w, r12.y
pow r5, c53.w, r12.z
mov r12.y, r13
mov r12.z, r5
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r5.w, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r5.w, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s5
mul r2.y, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r2.y
pow r13, c53.w, r17.x
add r2.y, r11.w, -r16
mul r11.w, r2.y, r14
pow r12, c53.w, r17.y
add r2.y, r11.w, r14.x
mov r13.y, r12
pow r12, c53.w, r17.z
rcp r2.z, r11.w
add r2.y, r2, -r15.x
add r2.w, -r14.x, r15.y
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r12
mul r12.xyz, r13, r2.y
mov r2.y, c51.z
mul r12.xyz, r12, c15
if_gt c34.x, r2.y
add r5.w, r5, -c11.x
add r2.y, r5.w, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r5
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r9.w, r2.y, c51, r9
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r5.w, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s6
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r3.z, r13.x, c51.y
mad r2.z, r2, r3, c51.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r5.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.w, r2.y, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.y, c24.z
add r3.z, -c25, r2.y
mul r2.y, r2.z, r2.w
rcp r2.w, r3.z
add r2.z, r5.w, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25
mul_sat r2.w, r2, r3.z
mad r3.z, -r2.w, c54.x, c54.y
mul r2.w, r2, r2
add r3.w, r13, c51.y
mul r2.w, r2, r3.z
mad r2.w, r2, r3, c51
mul r2.y, r2, r2.z
mul r9.w, r2.y, r2
endif
mul r12.xyz, r12, r9.w
endif
add r13.xyz, -r5, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.z, r2, r2.w
mul r3.w, r3.z, r2
add r13.xyz, -c21, r13
add r5.xyz, -r5, c18
dp3 r3.z, r13, r13
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.z, r3.z
rcp r3.z, r3.z
mul r3.z, r3, r3.w
rcp r3.w, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r8
mul r3.w, r3, c54.z
mul r2.y, r2, c30.x
mul r3.w, r3, r3
rcp r3.w, r3.w
mul r3.z, r3, r3.w
add r2.y, r2, c51.w
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c54.z
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.z, r3, c54
min r2.z, r3, c51.w
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c54.z
min r2.y, r2, c51.w
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r13.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c54.w
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r3.xyz, r2.y, c55.yzww, r2.z
mad r3.xyz, r12, r3, r5
add r5.xyz, r3, c17
mul r12.xyz, r11.w, -r13
pow r3, c53.w, r12.x
mul r5.xyz, r5, r11.w
mad r10.xyz, r5, r11, r10
mov r12.x, r3
pow r5, c53.w, r12.y
pow r3, c53.w, r12.z
mov r12.y, r5
mov r12.z, r3
mul r11.xyz, r11, r12
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r13.xyz, r10
cmp r2.w, -r2.z, c51.z, c51
cmp r3.x, r3, c51.z, c51.w
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r11.w, -r2, r2.z, r1
cmp_pp r1.w, -r11, c51.z, c51
cmp r14.w, -r2, r0, r2.y
mov r14.x, r4
mov r10.xyz, c51.z
if_gt r1.w, c51.z
frc r1.w, r11
add r1.w, r11, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r16.y, r1.w, r2, -r2
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r16.z, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r16.z, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s5
mul r1.w, r5, c29.x
mad r17.xyz, r5.z, -c27, -r1.w
pow r4, c53.w, r17.x
pow r3, c53.w, r17.y
mov r4.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.z, -r14.x, r15.y
rcp r2.y, r14.w
add r1.w, r3.x, -r15.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c51.z
mul r14.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r12
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r10.w, r1, c51, r10
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s6
add r2.w, r4.x, c51.y
mad r1.w, r2.y, r2, c51
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.y, r4.w, c51
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c51.w
mul r1.w, r1, r2.y
mul r10.w, r1, r2.z
endif
mul r14.xyz, r14, r10.w
endif
add r4.xyz, -r12, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r12.xyz, -r12, c18
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r12, r12
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r12
dp3 r1.w, r4, r8
mul r3.y, r3, c54.z
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c51
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c54.z
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c51.w
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c54.z
mul r2.y, r5, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r12.xyz, r14.w, -r12
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r5.xyz, r1.w, c55.yzww, r2.y
mad r4.xyz, r14, r5, r4
add r5.xyz, r4, c17
pow r4, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r4
pow r5, c53.w, r12.y
pow r4, c53.w, r12.z
mov r12.y, r5
mov r12.z, r4
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r5.w, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r5.w, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s5
mul r1.w, r3, c29.x
mad r17.xyz, r3.z, -c27, -r1.w
pow r12, c53.w, r17.x
add r1.w, r11, -r16.y
mul r11.w, r1, r14
pow r4, c53.w, r17.y
add r1.w, r11, r14.x
mov r12.y, r4
pow r4, c53.w, r17.z
mov r12.z, r4
rcp r2.y, r11.w
add r1.w, r1, -r15.x
add r2.z, -r14.x, r15.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mul r4.xyz, r12, r1.w
mov r1.w, c51.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r5
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r9.w, r1, c51, r9
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r5, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c54.x, c54.y
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s6
add r2.w, r4.x, c51.y
mad r2.y, r2, r2.w, c51.w
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r1.w, c24.z
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r5.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r5.w, -c25.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.z, r4.w, c51.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3, c51.w
mul r1.w, r1, r2.y
mul r9.w, r1, r2.z
endif
mul r12.xyz, r12, r9.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.z, r4, r4
rsq r3.z, r3.z
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.z, r3.z
mul r3.z, r3, r2.w
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r8
mul r2.w, r2, c54.z
mul r2.w, r2, r2
mul r1.w, r1, c30.x
mov r4.xyz, c19
rcp r3.w, r2.w
add r1.w, r1, c51
rcp r2.w, r1.w
mul r2.y, r2, r2.w
mul r1.w, r3.z, r3
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c54
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c51.w
mul r1.w, r2.y, c54.z
mul r2.y, r3, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r5.xyz, r11.w, -r5
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r3.xyz, r1.w, c55.yzww, r2.y
mad r3.xyz, r12, r3, r4
add r4.xyz, r3, c17
pow r3, c53.w, r5.x
mul r4.xyz, r4, r11.w
mad r10.xyz, r4, r11, r10
mov r5.x, r3
pow r4, c53.w, r5.y
pow r3, c53.w, r5.z
mov r5.y, r4
mov r5.z, r3
mul r11.xyz, r11, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r10
cmp r2.z, -r2.y, c51, c51.w
cmp r2.w, r2, c51.z, c51
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r11.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r11.w, c51, c51.w
cmp r14.w, -r2.z, r0, r1
mov r14.x, r2
mov r10.xyz, c51.z
if_gt r1.z, c51.z
frc r1.z, r11.w
add r1.z, r11.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r16.y, r1.z, r1.w, -r1.w
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r2.xyz, r12, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r16.z, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r16.z, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c51.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r5, r2.xyzz, s5
mul r1.z, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r1.z
pow r2, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r2
pow r2, c53.w, r17.z
add r3.x, r14, r14.w
add r2.x, -r14, r15.y
rcp r1.w, r14.w
add r1.z, r3.x, -r15.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mov r17.z, r2
mul r2.xyz, r17, r1.z
mov r1.z, c51
mul r14.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r16.z, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r12
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r10.w, r1.z, c51, r10
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s6
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c51.w
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c54, c54.y
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r10.w, r1.z, r2.x
endif
mul r14.xyz, r14, r10.w
endif
add r2.xyz, -r12, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r12.xyz, -r12, c18
dp3 r2.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r12
rcp r3.z, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.z, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c54.z
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c54
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r12.xyz, r14.w, -r12
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.z, r2
mul r2.w, r15, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r15
mad r5.xyz, r1.z, c55.yzww, r2.w
mul r2.xyz, r2, c55.x
mad r2.xyz, r14, r5, r2
add r5.xyz, r2, c17
pow r2, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r2
pow r5, c53.w, r12.y
pow r2, c53.w, r12.z
mov r12.y, r5
mov r12.z, r2
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r2.xyz, r5, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r5.w, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r5, -c11.x
add r1.z, -r1, c51.w
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r3, r2.xyzz, s5
mul r1.z, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r1.z
pow r12, c53.w, r17.x
add r1.z, r11.w, -r16.y
mul r11.w, r1.z, r14
pow r2, c53.w, r17.y
add r1.z, r11.w, r14.x
mov r12.y, r2
pow r2, c53.w, r17.z
mov r12.z, r2
rcp r1.w, r11.w
add r1.z, r1, -r15.x
add r2.x, -r14, r15.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mul r2.xyz, r12, r1.z
mov r1.z, c51
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r5.w, r5, -c11.x
add r1.z, r5.w, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r5
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r9.w, r1.z, c51, r9
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r5.w, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s6
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r5.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c54, c54.y
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r3.z, c51
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r5, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r5.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r9.w, r1.z, r2.x
endif
mul r12.xyz, r12, r9.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.z, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.z, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r3.w, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.w, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r3, r2.y
mul r1.w, r1, r2.x
mul r3.z, r1.w, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c54.z
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3.z
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c54
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r3.y, c28.x
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.w, r2
mul r5.xyz, r11.w, -r5
mul r2.xyz, r2, c55.x
mul r1.w, r15, r1
mul r1.z, r1, r15
mad r3.xyz, r1.z, c55.yzww, r1.w
mad r2.xyz, r12, r3, r2
add r3.xyz, r2, c17
pow r2, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r2
pow r3, c53.w, r5.y
pow r2, c53.w, r5.z
mov r5.y, r3
mov r5.z, r2
mul r11.xyz, r11, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c51.z, c51.w
cmp r2.x, -r1.w, c51.z, c51.w
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r11.w, -r2.x, r1, r1.y
cmp r14.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r11.w, c51.z, c51.w
mov r2.xyz, r10
mov r14.x, r1
mov r10.xyz, c51.z
if_gt r1.y, c51.z
frc r1.x, r11.w
add r1.x, r11.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r16.y, r1.x, r1, -r1
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r1.xyz, r12, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r16.z, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r16.z, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r5, r1.xyzz, s5
mul r1.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r1.x
pow r1, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r1
pow r1, c53.w, r17.z
add r3.x, r14, r14.w
rcp r1.y, r14.w
add r1.w, -r14.x, r15.y
add r1.x, r3, -r15
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r17.z, r1
mul r1.xyz, r17, r1.x
mov r1.w, c51.z
mul r14.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r12
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r10.w, r2, c51, r10
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s6
add r3.w, r1.x, c51.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r10.w, r1.x, r1.z
endif
mul r14.xyz, r14, r10.w
endif
add r1.xyz, -r12, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
add r2.w, r1.x, c51
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r12.xyz, -r12, c18
dp3 r1.x, r12, r12
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r12
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c54.z
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r12.xyz, r14.w, -r12
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r15.w, r1.w
mul r1.w, r2, r15.z
mad r5.xyz, r1.w, c55.yzww, r3.y
mul r1.xyz, r1, c55.x
mad r1.xyz, r14, r5, r1
add r5.xyz, r1, c17
pow r1, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r1
pow r5, c53.w, r12.y
pow r1, c53.w, r12.z
mov r12.y, r5
mov r12.z, r1
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r3, r1.xyzz, s5
mul r1.x, r3.w, c29
mad r17.xyz, r3.z, -c27, -r1.x
pow r12, c53.w, r17.x
pow r1, c53.w, r17.y
add r1.x, r11.w, -r16.y
mov r12.y, r1
mul r11.w, r1.x, r14
pow r1, c53.w, r17.z
add r1.x, r11.w, r14
rcp r1.y, r11.w
add r1.x, r1, -r15
add r1.w, -r14.x, r15.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r12.z, r1
mul r1.xyz, r12, r1.x
mov r1.w, c51.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r2.w, r5, -c25
mov r1.xyz, r5
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r9.w, r2, c51, r9
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s6
add r3.w, r1.x, c51.y
add r2.w, r5, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r5.w, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r5.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r9.w, r1.x, r1.z
endif
mul r12.xyz, r12, r9.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
rcp r3.z, r1.y
add r2.w, r1.x, c51
mul r3.w, r2, r3.z
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r3.w, r3, r3.z
dp3 r1.x, r5, r5
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.w, r1.x, r3
mul r1.xyz, r3.z, r5
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.w, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.z, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.z, r3, c54
mul r1.y, r3.z, r3.z
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r2.w, r3.y, c28.x
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r2.w, r1
mul r5.xyz, r11.w, -r5
mul r1.w, r1, r15.z
mul r2.w, r15, r2
mad r3.xyz, r1.w, c55.yzww, r2.w
mul r1.xyz, r1, c55.x
mad r1.xyz, r12, r3, r1
add r3.xyz, r1, c17
pow r1, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r1
pow r3, c53.w, r5.y
pow r1, c53.w, r5.z
mov r5.y, r3
mov r5.z, r1
mul r11.xyz, r11, r5
endif
add r1.x, r16, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c51, c51.w
cmp r1.y, -r0.z, c51.z, c51.w
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r11.w, -r1.y, r0.z, r0.y
cmp r14.w, -r1.y, r0, r1.x
mov r1.xyz, r10
cmp_pp r0.y, -r11.w, c51.z, c51.w
mov r14.x, r0
mov r10.xyz, c51.z
if_gt r0.y, c51.z
frc r0.x, r11.w
add r0.x, r11.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r16.y, r0.x, r0, -r0
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r0.xyz, r12, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r16.z, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r16.z, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r5, r0.xyzz, s5
mul r0.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r0.x
pow r0, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r0
pow r0, c53.w, r17.z
add r3.x, r14, r14.w
rcp r0.y, r14.w
add r0.w, -r14.x, r15.y
add r0.x, r3, -r15
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r17.z, r0
mul r0.xyz, r17, r0.x
mov r0.w, c51.z
mul r14.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r12
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r10.w, r1, c51, r10
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s6
add r3.z, r0.x, c51.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c51.w
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c51.y
mad r2.w, -r1, c54.x, c54.y
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c51
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.y, c54.x, c54.y
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0, r0.y
mul r10.w, r0.x, r0.z
endif
mul r14.xyz, r14, r10.w
endif
add r0.xyz, -r12, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
add r1.w, r0.x, c51
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r12.xyz, -r12, c18
dp3 r0.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r12
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c54.z
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c54.z
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c51.w
mul r0.w, r0.x, c54.z
mul r1.w, r5.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r12.xyz, r14.w, -r12
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r5.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r14, r5, r0
add r5.xyz, r0, c17
pow r0, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r0
pow r5, c53.w, r12.y
pow r0, c53.w, r12.z
mov r12.y, r5
mov r12.z, r0
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r3, r0.xyzz, s5
mul r0.x, r3.w, c29
mad r9.xyz, r3.z, -c27, -r0.x
pow r0, c53.w, r9.y
pow r12, c53.w, r9.x
add r0.x, r11.w, -r16.y
mul r11.w, r0.x, r14
mov r9.y, r0
pow r0, c53.w, r9.z
add r0.x, r11.w, r14
rcp r0.y, r11.w
add r0.x, r0, -r15
add r0.w, -r14.x, r15.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r9.x, r12
mov r9.z, r0
mul r0.xyz, r9, r0.x
mov r0.w, c51.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
mov r0.xyz, r5
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r9.w, r1, c51, r9
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s6
add r3.z, r0.x, c51.y
mul r1.w, r2, r1
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r5.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c51.y
mad r0.y, -r0.x, c54.x, c54
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c51.w
mad r1.w, r1, r3.z, c51
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r5.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.x, c54.x, c54.y
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r5.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0.y, r0
mul r9.w, r0.x, r0.z
endif
mul r12.xyz, r12, r9.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c51
mul r3.z, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.z, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.z, r0, c54
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c54.z
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c54.z
min r0.y, r3.z, c51.w
mul r1.w, r3.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r5.xyz, r11.w, -r5
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r3.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r12, r3, r0
add r3.xyz, r0, c17
pow r0, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r0
pow r3, c53.w, r5.y
pow r0, c53.w, r5.z
mov r5.y, r3
mov r5.z, r0
mul r11.xyz, r11, r5
endif
mov r3, c37
add r3, -c41, r3
mov r0, c36
mov r9, c39
mov r14, c38
add r9, -c43, r9
add r0, -c40, r0
mad r5, r8.w, r3, c41
mad r3, r8.w, r0, c40
texldl r1.w, r7.xyzz, s2
mov r0.z, r1.w
texldl r0.w, r7.xyzz, s1
mov r0.y, r0.w
texldl r1.w, r7.xyzz, s0
mov r0.x, r1.w
mov r0.w, c51
dp4 r12.x, r3, r0
dp4 r3.x, r3, r3
mad r9, r8.w, r9, c43
add r14, -c42, r14
mad r8, r8.w, r14, c42
dp4 r12.y, r5, r0
dp4 r12.w, r9, r0
dp4 r12.z, r8, r0
add r0, r12, c51.y
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r3.w, r9, r9
mad r0, r3, r0, c51.w
mad r1.xyz, r10, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r13
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r0.xyz, r0.z, c58, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c56.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul r1.y, r0.w, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
min r0.x, r0, c56.w
add r0.z, r0.x, c57.w
cmp r0.z, r0, c51.w, c51
mul_pp r1.x, r0.z, c58.w
add r0.x, r0, -r1
mul r1.x, r0, c59
frc r0.w, r1.x
add r0.w, r1.x, -r0
mul_pp r1.x, r0.w, c59.z
mul r2.xyz, r11.y, c56
mad r2.xyz, r11.x, c57, r2
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.w, c59.y
exp_pp r0.w, r0.x
mad_pp r0.x, -r0.z, c51, c51.w
mul_pp r0.x, r0, r0.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r1
abs_pp r0.z, r0.x
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
mad r1.xyz, r11.z, c58, r2
add r2.x, r1, r1.y
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c51.y
add r1.z, r1, r2.x
mul_pp r0.z, r0, c61.x
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r2.x, r1.z, c56.w
mul r0.z, r0, c61.y
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c60.w
frc r2.y, r2.x
add r0.w, r2.x, -r2.y
min r0.w, r0, c56
add r2.x, r0.w, c57.w
mul r1.w, r1, c55.x
frc r2.y, r1.w
add r1.w, r1, -r2.y
cmp r2.x, r2, c51.w, c51.z
mul_pp r0.z, r0, c59
cmp_pp r0.x, -r0, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r2.x, c58.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c61.w
mul r1.x, r0.w, c59
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c59
add r0.w, r0, -r1.z
min r1.w, r1, c59
mad r1.z, r0.w, c60.x, r1.w
add_pp r0.w, r1.x, c59.y
exp_pp r1.x, r0.w
mad_pp r0.w, -r2.x, c51.x, c51
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c60.y, c60
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r2.x, r1.w
add_pp r1.w, r1, -r2.x
exp_pp r2.x, -r1.w
mad_pp r1.z, r1, r2.x, c51.y
mul r0.x, r0, c61.z
add r0.w, -r0.x, -r0.z
add r0.w, r0, c51
mul r2.xyz, r0.y, c62
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c61.x
mul r2.w, r0.z, c61.y
mad r0.xyz, r0.x, c63, r2
add_pp r1.z, r1.w, c60.w
frc r2.x, r2.w
mad r0.xyz, r0.w, c64, r0
add r1.w, r2, -r2.x
mul_pp r1.z, r1, c59
cmp_pp r1.x, -r1, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.z
mul r1.z, r2.x, c61.w
add r1.x, r1, r1.w
mul r1.x, r1, c61.z
add r1.w, -r1.x, -r1.z
add r0.w, r1, c51
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r2.xyz, r1.y, c62
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c51.z
mad r2.xyz, r1.y, c63, r2
mul r0.w, r0, r1.x
mad r2.xyz, r0.w, c64, r2
add r1.xyz, -r0, c51.wzzw
max r2.xyz, r2, c51.z
mad r1.xyz, r1, c48.x, r0
mad r2.xyz, -r2, c48.x, r2
else
add r2.xy, r7, c49.xzzw
add r1.xy, r2, c49.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s7
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r2.z, r1.w
add_pp r1.w, r1, -r2.z
exp_pp r2.z, -r1.w
mad_pp r1.z, r1, r2, c51.y
mul_pp r1.z, r1, c61.x
mul r2.z, r1, c61.y
add_pp r1.z, r1.w, c60.w
frc r2.w, r2.z
add r1.w, r2.z, -r2
add r8.xy, r1, -c49.xzzw
mul r2.z, r2.w, c61.w
mul_pp r1.z, r1, c59
cmp_pp r0.y, -r0, c51.w, c51.z
mad_pp r0.y, r0, c58.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c61.z
add r2.w, -r0.y, -r2.z
mov r8.z, r7
texldl r1, r8.xyzz, s7
abs_pp r3.x, r1.y
log_pp r3.y, r3.x
frc_pp r3.z, r3.y
add_pp r3.w, r3.y, -r3.z
add r2.w, r2, c51
mul r2.w, r2, r0.x
rcp r2.z, r2.z
mul r0.y, r0, r0.x
mul r2.w, r2, r2.z
exp_pp r3.y, -r3.w
mul r0.y, r2.z, r0
mad_pp r2.z, r3.x, r3.y, c51.y
mul r3.xyz, r0.x, c62
mad r3.xyz, r0.y, c63, r3
mul_pp r0.x, r2.z, c61
mul r0.y, r0.x, c61
mad r3.xyz, r2.w, c64, r3
frc r2.z, r0.y
add r2.w, r0.y, -r2.z
add_pp r0.x, r3.w, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r1.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r2.w
mul r0.y, r2.z, c61.w
mul r0.x, r0, c61.z
add r1.y, -r0.x, -r0
add r1.y, r1, c51.w
mov r2.z, r7
texldl r2, r2.xyzz, s7
abs_pp r3.w, r2.y
log_pp r4.x, r3.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r4.y, r4.x
add_pp r0.y, r4.x, -r4
mul r4.xyz, r1.x, c62
mad r4.xyz, r0.x, c63, r4
exp_pp r1.x, -r0.y
mad_pp r0.x, r3.w, r1, c51.y
mad r4.xyz, r1.y, c64, r4
mul_pp r0.x, r0, c61
mul r1.x, r0, c61.y
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r2.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r1
max r4.xyz, r4, c51.z
max r3.xyz, r3, c51.z
add r5.xyz, r3, -r4
texldl r3, r7.xyzz, s7
add r7.xy, r8, -c49.zyzw
mul r1.x, r0, c61.z
mul r1.y, r1, c61.w
add r2.y, -r1.x, -r1
mul r0.xy, r7, c50
frc r0.xy, r0
mad r5.xyz, r0.x, r5, r4
abs_pp r4.x, r3.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r2.y, r2, c51.w
mul r2.y, r2, r2.x
rcp r1.y, r1.y
mul r1.x, r1, r2
mul r2.y, r2, r1
exp_pp r4.y, -r4.w
mul r1.x, r1.y, r1
mad_pp r1.y, r4.x, r4, c51
mul r4.xyz, r2.x, c62
mad r4.xyz, r1.x, c63, r4
mad r4.xyz, r2.y, c64, r4
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
frc r2.x, r1.y
add r2.y, r1, -r2.x
add_pp r1.x, r4.w, c60.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.y, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
rcp r2.y, r1.y
mul r1.x, r1, r3
add r2.x, r2, c51.w
mul r1.y, r2.x, r3.x
abs_pp r2.x, r2.w
mul r1.y, r1, r2
log_pp r3.y, r2.x
mul r1.x, r2.y, r1
frc_pp r2.y, r3
mul r8.xyz, r3.x, c62
mad r8.xyz, r1.x, c63, r8
add_pp r2.y, r3, -r2
exp_pp r1.x, -r2.y
mad r8.xyz, r1.y, c64, r8
mad_pp r1.x, r2, r1, c51.y
mul_pp r1.x, r1, c61
mul r1.y, r1.x, c61
frc r2.x, r1.y
add_pp r1.x, r2.y, c60.w
add r2.y, r1, -r2.x
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r2.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
abs_pp r2.y, r3.w
log_pp r3.x, r2.y
frc_pp r3.y, r3.x
add_pp r3.x, r3, -r3.y
max r8.xyz, r8, c51.z
max r4.xyz, r4, c51.z
add r4.xyz, r4, -r8
mad r4.xyz, r0.x, r4, r8
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
add r2.x, r2, c51.w
mul r2.x, r2.z, r2
rcp r1.y, r1.y
mul r2.w, r2.x, r1.y
mul r1.x, r2.z, r1
exp_pp r2.x, -r3.x
mul r1.x, r1.y, r1
mad_pp r1.y, r2, r2.x, c51
mul r2.xyz, r2.z, c62
mad r2.xyz, r1.x, c63, r2
mad r2.xyz, r2.w, c64, r2
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
max r8.xyz, r2, c51.z
frc r2.w, r1.y
add_pp r1.x, r3, c60.w
add r3.x, r1.y, -r2.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
mul r1.y, r2.w, c61.w
add r1.x, r1, r3
mul r1.x, r1, c61.z
add r2.w, -r1.x, -r1.y
rcp r2.y, r1.y
add r2.x, r2.w, c51.w
mul r1.y, r3.z, r2.x
mul r3.x, r1.y, r2.y
mul r1.y, r3.z, r1.x
mul r3.y, r2, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r3.w, r1.y, -r2
exp_pp r1.y, -r3.w
mad_pp r1.x, r1, r1.y, c51.y
mul_pp r1.y, r1.x, c61.x
abs_pp r1.x, r0.w
mul r4.w, r1.y, c61.y
frc r5.w, r4
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r1.y, r1, -r2.w
exp_pp r2.w, -r1.y
mad_pp r1.x, r1, r2.w, c51.y
mul r2.xyz, r3.z, c62
mad r2.xyz, r3.y, c63, r2
mad r2.xyz, r3.x, c64, r2
max r2.xyz, r2, c51.z
add r3.xyz, r8, -r2
add_pp r3.w, r3, c60
add r4.w, r4, -r5
mad r2.xyz, r0.x, r3, r2
mul_pp r3.w, r3, c59.z
cmp_pp r1.w, -r1, c51, c51.z
mad_pp r1.w, r1, c58, r3
add r1.w, r1, r4
mul r3.w, r1, c61.z
mul r4.w, r5, c61
mul_pp r1.x, r1, c61
mul r1.w, r1.x, c61.y
add_pp r1.x, r1.y, c60.w
frc r2.w, r1
add r1.y, r1.w, -r2.w
add r5.w, -r3, -r4
mul r8.x, r1.z, r3.w
rcp r3.w, r4.w
mul r4.w, r3, r8.x
mul r1.w, r2, c61
mul_pp r1.x, r1, c59.z
cmp_pp r0.w, -r0, c51, c51.z
mad_pp r0.w, r0, c58, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c61.z
add r1.x, -r0.w, -r1.w
add r1.y, r5.w, c51.w
add r2.w, r1.x, c51
mul r5.w, r1.z, r1.y
mul r1.xyz, r1.z, c62
mul r3.w, r5, r3
mad r1.xyz, r4.w, c63, r1
mad r1.xyz, r3.w, c64, r1
mul r3.w, r0.z, r0
mul r2.w, r0.z, r2
rcp r0.w, r1.w
mul r8.xyz, r0.z, c62
mul r0.z, r0.w, r3.w
mad r8.xyz, r0.z, c63, r8
mul r0.z, r2.w, r0.w
mad r8.xyz, r0.z, c64, r8
max r1.xyz, r1, c51.z
max r8.xyz, r8, c51.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r3.xyz, r1, -r2
add r5.xyz, r5, -r4
mad r1.xyz, r0.y, r5, r4
mad r2.xyz, r0.y, r3, r2
endif
mov r0.x, c8.w
mul r0.x, c52.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s8
else
mov r0.xyz, c51.z
endif
mul r2.xyz, r2, r6.w
mad r0.xyz, r0, r2, r6
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r1.xyz, r0.z, c58, r1
add r0.x, r1, r1.y
add r0.x, r1.z, r0
rcp r0.x, r0.x
mul r0.zw, r1.xyxy, r0.x
mul r0.x, r0.z, c56.w
frc r0.y, r0.x
add r0.x, r0, -r0.y
min r0.x, r0, c56.w
add r0.y, r0.x, c57.w
cmp r1.x, r0.y, c51.w, c51.z
mul_pp r0.y, r1.x, c58.w
add r1.z, r0.x, -r0.y
mul r0.x, r1.z, c59
frc r0.y, r0.x
add r1.w, r0.x, -r0.y
mul r3.xyz, r2.y, c56
mad r0.xyz, r2.x, c57, r3
mad r0.xyz, r2.z, c58, r0
add_pp r2.x, r1.w, c59.y
add r2.y, r0.x, r0
add r2.y, r0.z, r2
exp_pp r2.x, r2.x
mad_pp r1.x, -r1, c51, c51.w
mul_pp r0.z, r1.x, r2.x
rcp r2.x, r2.y
mul_pp r1.x, r1.w, c59.z
mul r2.xy, r0, r2.x
add r0.x, r1.z, -r1
mul r1.z, r2.x, c56.w
mul r0.w, r0, c55.x
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r0.w, r0, c59
mad r0.x, r0, c60, r0.w
mad r0.x, r0, c60.y, c60.z
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c56.w
add r1.z, r1.x, c57.w
cmp r0.w, r1.z, c51, c51.z
mov_pp oC0.x, r1.y
mul_pp r1.z, r0.w, c58.w
mul_pp oC0.y, r0.z, r0.x
add r0.x, r1, -r1.z
mul r0.z, r0.x, c59.x
frc r1.x, r0.z
add r0.z, r0, -r1.x
mul_pp r1.x, r0.z, c59.z
mul r1.y, r2, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.z, c59.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r0.w, c51, c51.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r1.x
mov_pp oC0.z, r0.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 compose sky with 4 cloud layers
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
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 4 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 7 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 6 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 9 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 5 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 8 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[65] = { program.local[0..50],
		{ 0, 2, -1, -1000000 },
		{ 1, 0.995, 1000000, -1000000 },
		{ 0.001, 0.75, 1.5, 0.5 },
		{ 255, 0, 1, 2.718282 },
		{ 3, 5.6020446, 9.4732847, 19.643803 },
		{ 1000, 10, 400, 210 },
		{ 0.0241188, 0.1228178, 0.84442663, 128 },
		{ 0.51413637, 0.32387859, 0.16036376, 0.25 },
		{ 0.26506799, 0.67023426, 0.064091571, 15 },
		{ 4, 256, 0.0009765625, 1024 },
		{ 0.00390625, 0.0047619049, 0.63999999, 0 },
		{ 0.075300001, -0.2543, 1.1892 },
		{ 2.5651, -1.1665, -0.39860001 },
		{ -1.0217, 1.9777, 0.043900002 } };
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
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[2], 2D;
TEX   R9, fragment.texcoord[0], texture[3], 2D;
MOVR  R4.z, R8.w;
MOVR  R5, c[42];
MOVR  R4.w, R9;
MOVR  R10.z, R8.y;
MOVR  R2.xyz, c[9];
MOVR  R3.x, c[51].w;
MOVR  R10.w, R9.y;
MOVR  R8.w, R9.z;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].y, -R0;
MOVR  R0.z, c[51];
DP3R  R0.w, R0, R0;
ADDR  R5, -R5, c[38];
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[13].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[51].x;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.w, R2, R1;
MOVR  R0, c[24];
MULR  R3.z, R3.w, R3.w;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.w, R1;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
MOVR  R4.y, R1.w;
MOVR  R10.y, R1;
MOVR  R8.y, R1.z;
MOVR  R0.x, c[51].w;
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.w, R0.y;
MOVR  R0.y, c[51].w;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.w, R0.z;
MOVR  R0.z, c[51].w;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.w, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[35];
SGER  H0.x, c[51], R0;
MADR  R6, H0.x, R5, c[42];
MOVR  R0, c[41];
ADDR  R0, -R0, c[37];
MADR  R3, H0.x, R0, c[41];
MOVR  R0, c[40];
ADDR  R0, -R0, c[36];
MADR  R2, H0.x, R0, c[40];
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MOVR  R4.x, R0.w;
MOVR  R10.x, R0.y;
MOVR  R5, c[43];
ADDR  R5, -R5, c[39];
MADR  R5, H0.x, R5, c[43];
DP4R  R7.x, R4, R2;
DP4R  R7.y, R4, R3;
DP4R  R7.z, R4, R6;
DP4R  R7.w, R4, R5;
DP4R  R4.x, R2, R2;
DP4R  R4.y, R3, R3;
DP4R  R1.y, R6, R10;
DP4R  R4.w, R5, R5;
DP4R  R4.z, R6, R6;
MADR  R4, R7, R4, -R4;
ADDR  R4, R4, c[52].x;
MOVR  R7.z, R8.x;
MOVR  R8.x, R0.z;
MULR  R0.w, R4.x, R4.y;
MOVR  R7.w, R9.x;
MOVR  R7.x, R0;
MOVR  R7.y, R1.x;
DP4R  R1.x, R6, R7;
MULR  R0.w, R0, R4.z;
DP4R  R0.x, R5, R7;
DP4R  R1.z, R6, R8;
DP4R  R0.y, R5, R10;
DP4R  R0.z, R5, R8;
MADR  R0.xyz, R4.z, R0, R1;
DP4R  R1.x, R3, R7;
DP4R  R1.z, R3, R8;
DP4R  R1.y, R3, R10;
MADR  R0.xyz, R4.y, R0, R1;
DP4R  R1.x, R2, R7;
DP4R  R1.z, R2, R8;
DP4R  R1.y, R2, R10;
MADR  R2.xyz, R4.x, R0, R1;
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[49].xyxz;
ADDR  R0.xy, R1.zwzw, c[49].zyzw;
MULR  R2.w, R0, R4;
ADDR  R0.zw, R0.xyxy, -c[49].xyxz;
TEX   R0.x, R0, texture[5], 2D;
TEX   R1.x, R0.zwzw, texture[5], 2D;
ADDR  R0.y, R1.x, -R0.x;
ADDR  R15.xy, R0.zwzw, -c[49].zyzw;
MULR  R0.zw, R15.xyxy, c[50].xyxy;
FRCR  R0.zw, R0;
MADR  R0.x, R0.z, R0.y, R0;
TEX   R1.x, fragment.texcoord[0], texture[5], 2D;
TEX   R3.x, R1.zwzw, texture[5], 2D;
ADDR  R1.y, R3.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[8].w, -c[8];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[8].w;
TEX   R0.x, fragment.texcoord[0], texture[4], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[8];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R7.w, R0.z, R0.x;
ADDR  R0.x, R7.w, -R0.y;
SGTRC HC.x, |R0|, c[47];
IF    NE.x;
MOVR  R5.w, c[51];
MOVR  R5.x, c[51].w;
MOVR  R5.z, c[51].w;
MOVR  R5.y, c[51].w;
MOVR  R4.x, c[52].z;
MULR  R1.xy, R15, c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[51].y, -R0;
MOVR  R0.z, c[51];
DP3R  R0.w, R0, R0;
RSQR  R8.x, R0.w;
MULR  R0.xyz, R8.x, R0;
MOVR  R0.w, c[51].x;
DP4R  R6.z, R0, c[2];
DP4R  R6.y, R0, c[1];
DP4R  R6.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R1.x, c[0].w;
MOVR  R1.z, c[2].w;
MOVR  R1.y, c[1].w;
MULR  R9.xyz, R1, c[13].x;
ADDR  R7.xyz, R9, -c[9];
DP3R  R4.z, R6, R7;
MULR  R4.y, R4.z, R4.z;
DP3R  R4.w, R7, R7;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R5.x(EQ), R11;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R5.x(NE.z), -R4.z, R1;
MOVXC RC.z, R3;
MOVR  R5.z(EQ), R11.x;
MOVXC RC.z, R3.w;
RCPR  R0.x, R0.x;
ADDR  R5.z(NE.y), -R4, R0.x;
MOVXC RC.y, R3;
RSQR  R0.x, R1.w;
MOVR  R5.w(EQ.z), R11.x;
RCPR  R0.x, R0.x;
ADDR  R5.w(NE), -R4.z, R0.x;
RSQR  R0.x, R1.y;
MOVR  R5.y(EQ), R11.x;
RCPR  R0.x, R0.x;
ADDR  R5.y(NE.x), -R4.z, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R4.w;
ADDR  R1, R4.y, -R0;
SLTR  R3, R4.y, R0;
MOVXC RC.x, R3;
MOVR  R4.x(EQ), R11;
SGERC HC, R4.y, R0.yzxw;
RSQR  R0.x, R1.z;
MADR  R3.x, -c[12], c[12], R4.w;
ADDR  R0.z, R4.y, -R3.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R4.z, -R1;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R1.x, c[52].z;
MOVXC RC.z, R3;
MOVR  R1.x(EQ.z), R11;
RCPR  R0.x, R0.x;
ADDR  R1.x(NE.y), -R4.z, -R0;
RSQR  R0.x, R1.w;
MOVXC RC.y, R3;
MOVR  R1.w, c[52].z;
MOVR  R1.z, c[52];
MOVXC RC.z, R3.w;
MOVR  R1.z(EQ), R11.x;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R4, -R0.x;
RSQR  R0.x, R1.y;
MOVR  R1.y, c[52].z;
MOVR  R1.w(EQ.y), R11.x;
RCPR  R0.x, R0.x;
ADDR  R1.w(NE.x), -R4.z, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R4.w;
SLTRC HC.x, R4.y, R0;
MOVR  R1.y(EQ.x), R11.x;
ADDR  R0.y, R4, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R4.w, R1.z;
SGERC HC.x, R4.y, R0;
RCPR  R0.y, R0.y;
ADDR  R1.y(NE.x), -R4.z, -R0;
MOVXC RC.x, R1.y;
MOVR  R1.y(LT.x), c[52].z;
MOVR  R0.xy, c[51].x;
SLTRC HC.x, R4.y, R3;
MOVR  R0.xy(EQ.x), R11;
SGERC HC.x, R4.y, R3;
MOVR  R4.y, R1.w;
ADDR  R0.w, -R4.z, -R0.z;
ADDR  R3.y, -R4.z, R0.z;
MOVR  R4.z, R1.x;
MAXR  R0.z, R0.w, c[51].x;
MAXR  R0.w, R3.y, c[51].x;
MOVR  R0.xy(NE.x), R0.zwzw;
DP4R  R1.x, R5, c[35];
SGER  R6.w, c[51].x, R1.x;
MAXR  R1.w, R0.x, c[53].x;
DP4R  R0.z, R4, c[40];
DP4R  R0.w, R5, c[36];
ADDR  R0.w, R0, -R0.z;
MADR  R0.z, R6.w, R0.w, R0;
RCPR  R0.w, R8.x;
MULR  R0.w, R7, R0;
MADR  R1.x, -R0.w, c[13], R1.y;
MOVR  R8.xy, c[52];
MULR  R1.y, R8, c[8].w;
SGER  H0.x, R7.w, R1.y;
MULR  R0.w, R0, c[13].x;
MADR  R0.w, H0.x, R1.x, R0;
MINR  R3.w, R0.y, R0;
ADDR  R1.z, R3.w, -R1.w;
RCPR  R0.x, R1.z;
MINR  R0.y, R3.w, R0.z;
MAXR  R11.y, R1.w, R0;
MULR  R8.w, R0.x, c[32].x;
ADDR  R1.y, R11, -R1.w;
MULR  R1.x, R8.w, R1.y;
RCPR  R3.y, c[32].x;
MULR  R9.w, R1.z, R3.y;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R6.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MOVR  R10.x, R0;
MOVR  R11.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R6.w, R0, c[46].y;
SLTR  H0.y, R1.x, R0.w;
SGTR  H0.x, R1, c[51];
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R1.x;
RCPR  R3.x, R0.w;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R1.y, R3.x;
MOVR  R14.w(NE.x), R0;
MULR  R1.xyz, R7.zxyw, c[16].yzxw;
MADR  R1.xyz, R7.yzxw, c[16].zxyw, -R1;
DP3R  R0.w, R1, R1;
MULR  R3.xyz, R6.zxyw, c[16].yzxw;
MADR  R3.xyz, R6.yzxw, c[16].zxyw, -R3;
DP3R  R1.y, R1, R3;
DP3R  R1.x, R3, R3;
DP3R  R3.y, R7, c[16];
MADR  R0.w, -c[11].x, c[11].x, R0;
SLER  H0.y, R3, c[51].x;
MULR  R3.x, R1, R0.w;
MULR  R1.z, R1.y, R1.y;
ADDR  R0.w, R1.z, -R3.x;
SGTR  H0.z, R1, R3.x;
RCPR  R3.x, R1.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.z, -R1.y, R0.w;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVR  R1.z, c[52].w;
MOVR  R1.x, c[52].z;
ADDR  R0.w, -R1.y, -R0;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0.y;
MULR  R1.z(NE.x), R3.x, R3;
MULR  R1.x(NE), R0.w, R3;
MOVR  R1.y, R1.z;
MOVR  R16.xy, R1;
MADR  R1.xyz, R6, R1.x, R9;
ADDR  R1.xyz, R1, -c[9];
DP3R  R0.w, R1, c[16];
SGTR  H0.z, R0.w, c[51].x;
MULXC HC.x, H0.y, H0.z;
MOVR  R16.xy(NE.x), c[52].zwzw;
MOVXC RC.x, H0;
DP4R  R1.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R12.y, R11, R0.w;
DP4R  R1.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R1.x;
MADR  R0.w, R6, R0, R1.x;
MINR  R0.w, R3, R0;
MAXR  R13.y, R12, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R1.x, R5, c[39];
ADDR  R1.x, R1, -R0.w;
MADR  R0.w, R6, R1.x, R0;
MINR  R0.w, R3, R0;
DP3R  R0.y, R6, c[16];
MULR  R13.x, R0, c[33];
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[51].y;
MADR  R0.x, c[30], c[30], R0;
ADDR  R0.x, R0, c[52];
MADR  R15.z, R0.y, c[53].y, c[53].y;
ADDR  R0.y, R8.x, c[30].x;
POWR  R0.x, R0.x, c[53].z;
RCPR  R0.x, R0.x;
MULR  R0.y, R0, R0;
MAXR  R5.w, R13.y, R0;
MOVR  R12.x, R0.z;
MOVR  R10.w, R3;
MULR  R15.w, R0.y, R0.x;
MOVR  R8.xyz, c[52].x;
MOVR  R7.xyz, c[51].x;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R12.w;
MOVR  R12.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R12.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R12.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R12.y, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R11.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R12.w;
MOVR  R12.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R12.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R12.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R13.y, -R12.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R12.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R12.w;
MOVR  R12.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R12.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R12.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R5.w, -R13.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R12.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R12.x;
RCPR  R0.z, R12.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R12.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R13.y;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R12.w;
MOVR  R12.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R12.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R12.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
ADDR  R0.x, R10.w, -R5.w;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[51];
SLTR  H0.y, R0, R13.x;
MULXC HC.x, H0, H0.y;
MOVR  R14.w, R0.y;
MOVR  R14.w(NE.x), R13.x;
RCPR  R0.z, R13.x;
MOVR  R13.w, R9;
MULR  R13.w(NE.x), R0.x, R0.z;
MOVR  R13.xyz, R7;
MOVX  H0.x, c[51];
MOVXC RC.x, R14.w;
MOVX  H0.x(GT), c[52];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[51].x;
MOVR  R1.w, R5;
IF    NE.x;
FLRR  R16.z, R14.w;
MOVR  R16.w, c[51].x;
LOOP c[54];
SLTRC HC.x, R16.w, R16.z;
BRK   (EQ.x);
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R4.z, R1.w, R13.w;
RCPR  R1.z, R13.w;
ADDR  R1.x, R4.z, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R12.w;
MOVR  R12.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R12.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R12.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
MULR  R1.w, R1, R1.z;
DP3R  R3.x, R0, R0;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R13.w;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R13.w, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
MOVR  R1.w, R4.z;
ADDR  R16.w, R16, c[52].x;
ENDLOOP;
MADR  R5.xyz, R1.w, R6, R9;
ADDR  R0.xyz, R5, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
MOVR  R0.x, c[11];
ADDR  R1.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R1.y, R0.w, -c[11].x;
RCPR  R1.x, R1.x;
MULR  R0.y, R1, R1.x;
MADR  R0.x, -R0, c[53].w, c[53].w;
TEX   R4, R0, texture[6], 2D;
MULR  R0.x, R4.w, c[29];
MADR  R0.xyz, R4.z, -c[27], -R0.x;
ADDR  R1.x, R14.w, -R16.z;
MULR  R4.z, R1.x, R13.w;
ADDR  R1.x, R4.z, R1.w;
RCPR  R1.z, R4.z;
ADDR  R1.x, R1, -R16;
ADDR  R1.y, -R1.w, R16;
POWR  R0.x, c[54].w, R0.x;
POWR  R0.y, c[54].w, R0.y;
POWR  R0.z, c[54].w, R0.z;
MULR_SAT R1.y, R1.z, R1;
MULR_SAT R1.x, R1, R1.z;
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, -R1.x, R0, R0;
MULR  R14.xyz, R0, c[15];
IF    NE.x;
ADDR  R1.x, R0.w, -c[11];
MOVR  R0.x, c[52];
SGERC HC.x, R1, c[25].w;
MOVR  R0.x(EQ), R11.w;
MOVR  R11.w, R0.x;
SLTRC HC.x, R1, c[25].w;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R5;
DP4R  R3.y, R0, c[5];
DP4R  R3.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[25];
ADDR  R0, -R0, c[24];
ADDR  R1, R1.x, -c[25];
RCPR  R0.y, R0.y;
MULR_SAT R1.y, R1, R0;
MOVR  R0.y, c[55].x;
RCPR  R0.z, R0.z;
MADR  R3.z, -R1.y, c[51].y, R0.y;
MULR  R3.w, R1.y, R1.y;
RCPR  R1.y, R0.x;
MULR  R0.x, R3.w, R3.z;
MULR_SAT R1.x, R1, R1.y;
TEX   R3, R3, texture[7], 2D;
MADR  R1.y, R3, R0.x, -R0.x;
MADR  R0.x, -R1, c[51].y, R0.y;
MULR  R1.x, R1, R1;
MULR  R0.x, R1, R0;
ADDR  R1.x, R1.y, c[52];
MADR  R0.x, R3, R0, -R0;
MADR  R0.x, R0, R1, R1;
RCPR  R0.w, R0.w;
MULR_SAT R1.x, R0.w, R1.w;
MULR_SAT R0.z, R0, R1;
MADR  R0.w, -R0.z, c[51].y, R0.y;
MULR  R0.z, R0, R0;
MULR  R0.z, R0, R0.w;
MADR  R0.z, R3, R0, -R0;
MADR  R0.y, -R1.x, c[51], R0;
MULR  R0.w, R1.x, R1.x;
MULR  R0.y, R0.w, R0;
MADR  R0.x, R0.z, R0, R0;
MADR  R0.y, R3.w, R0, -R0;
MADR  R11.w, R0.y, R0.x, R0.x;
ENDIF;
MULR  R14.xyz, R14, R11.w;
ENDIF;
ADDR  R0.xyz, -R5, c[21];
DP3R  R0.w, R0, R0;
RSQR  R0.w, R0.w;
MULR  R0.xyz, R0.w, R0;
RCPR  R0.w, R0.w;
MOVR  R1.x, c[52];
DP3R  R0.x, R6, R0;
MADR  R0.x, R0, c[30], R1;
RCPR  R1.z, R0.x;
MULR  R1.y, c[30].x, c[30].x;
MADR  R1.w, -R1.y, R1.z, R1.z;
MOVR  R0.xyz, c[21];
MULR  R1.z, R1.w, R1;
ADDR  R0.xyz, -R0, c[22];
DP3R  R1.w, R0, R0;
ADDR  R0.xyz, -R5, c[18];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
DP3R  R3.x, R0, R0;
MULR  R1.w, R1, R1.z;
RSQR  R1.z, R3.x;
MULR  R0.xyz, R1.z, R0;
DP3R  R0.x, R0, R6;
MADR  R0.x, R0, c[30], R1;
MULR  R0.w, R0, c[56].x;
MULR  R0.y, R0.w, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.z, R1.w, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R1, R0.x, R0.x;
RCPR  R1.y, R1.z;
MULR  R1.x, R0.z, c[56];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[18];
ADDR  R0.xyz, -R0, c[19];
DP3R  R0.x, R0, R0;
MULR  R1.y, R1, c[56].x;
MULR  R0.y, R1, R1;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.w, R0.x, c[56].x;
MINR  R0.y, R1.x, c[52].x;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[23];
MADR  R0.xyz, R0.w, c[20], R0;
MULR  R0.w, R4.y, c[28].x;
MULR  R0.xyz, R0, c[56].y;
MULR  R0.xyz, R0.w, R0;
MULR  R1.xyz, R0, c[56].z;
MULR  R0.y, R15.w, R0.w;
MULR  R0.x, R4, c[26];
MULR  R0.x, R0, R15.z;
MADR  R0.xyz, R0.x, c[55].yzww, R0.y;
MADR  R0.xyz, R14, R0, R1;
MULR  R0.w, R4.y, c[29].x;
ADDR  R0.xyz, R0, c[17];
MULR  R0.xyz, R0, R4.z;
MADR  R1.xyz, R4.x, c[27], R0.w;
MADR  R7.xyz, R0, R8, R7;
MULR  R1.xyz, R4.z, -R1;
POWR  R0.x, c[54].w, R1.x;
POWR  R0.y, c[54].w, R1.y;
POWR  R0.z, c[54].w, R1.z;
MULR  R8.xyz, R8, R0;
ENDIF;
MOVR  R1, c[41];
ADDR  R1, -R1, c[37];
MADR  R4, R6.w, R1, c[41];
TEX   R1.w, R15, texture[1], 2D;
MOVR  R5.y, R1.w;
MOVR  R0, c[40];
ADDR  R0, -R0, c[36];
MADR  R3, R6.w, R0, c[40];
TEX   R0.w, R15, texture[2], 2D;
MOVR  R5.z, R0.w;
TEX   R0.w, R15, texture[0], 2D;
MOVR  R5.x, R0.w;
TEX   R5.w, R15, texture[3], 2D;
DP4R  R6.x, R5, R3;
DP4R  R3.x, R3, R3;
MOVR  R1, c[42];
MOVR  R0, c[43];
ADDR  R1, -R1, c[38];
MADR  R1, R6.w, R1, c[42];
ADDR  R0, -R0, c[39];
MADR  R0, R6.w, R0, c[43];
DP4R  R3.z, R1, R1;
DP4R  R6.z, R5, R1;
DP4R  R3.y, R4, R4;
DP4R  R6.y, R5, R4;
DP4R  R6.w, R5, R0;
DP4R  R3.w, R0, R0;
MADR  R0, R6, R3, -R3;
ADDR  R0, R0, c[52].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R12;
MADR  R1.xyz, R1, R0.y, R11;
MADR  R1.xyz, R1, R0.x, R10;
MULR  R0.xyz, R1.y, c[59];
MADR  R0.xyz, R1.x, c[58], R0;
MADR  R0.xyz, R1.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xywz;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].w;
SGER  H0.x, R0, c[57].w;
MULH  H0.y, H0.x, c[57].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[58].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[60].x;
ADDH  H0.y, H0, -c[59].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R8.y, c[59];
MADR  R1.xyz, R8.x, c[58], R1;
MADR  R1.xyz, R8.z, c[57], R1;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0.w, c[54].x;
MADR  R0.z, R0.x, c[60].y, R0;
MOVR  R0.x, c[52];
MADR  H0.z, R0, c[60], R0.x;
MADH  H0.x, H0, c[51].y, H0.y;
MULH  H0.x, H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
LG2H  H0.z, |H0.x|;
FLRH  H0.z, H0;
ADDH  H0.w, H0.z, c[59];
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xywz;
FLRR  R0.zw, R0;
MINR  R1.z, R0, c[56].w;
SGEH  H0.y, c[51].x, H0.x;
EX2H  H0.z, -H0.z;
MULH  H0.x, |H0|, H0.z;
MADH  H0.x, H0, c[60].w, -c[60].w;
MULR  R1.x, H0, c[61];
FLRR  R0.z, R1.x;
MULH  H0.w, H0, c[60].x;
MADH  H0.y, H0, c[57].w, H0.w;
ADDR  R0.z, H0.y, R0;
SGER  H0.x, R1.z, c[57].w;
MULH  H0.y, H0.x, c[57].w;
ADDR  R1.w, R1.z, -H0.y;
MULR  R1.z, R1.w, c[58].w;
FLRR  H0.y, R1.z;
MULH  H0.z, H0.y, c[60].x;
FRCR  R1.x, R1;
ADDH  H0.y, H0, -c[59].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.x, R1, c[61].z;
MULR  R0.z, R0, c[61].y;
ADDR  R1.z, -R0, -R1.x;
MADR  R1.z, R1, R0.y, R0.y;
MADH  H0.x, H0, c[51].y, H0.y;
ADDR  R1.w, R1, -H0.z;
MINR  R0.w, R0, c[54].x;
MADR  R0.w, R1, c[60].y, R0;
MADR  H0.z, R0.w, c[60], R0.x;
MULH  H0.x, H0, H0.z;
RCPR  R0.x, R1.x;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MULR  R0.z, R0, R0.y;
ADDH  H0.y, H0, c[59].w;
MULR  R0.w, R1.z, R0.x;
MULR  R1.x, R0, R0.z;
MULR  R0.xyz, R0.y, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R3.xyz, R0, c[51].x;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R1.x, H0.z, c[61];
FRCR  R0.w, R1.x;
MULR  R0.w, R0, c[61].z;
MULR  R0.xyz, R1.y, c[64];
FLRR  R1.x, R1;
MULH  H0.y, H0, c[60].x;
SGEH  H0.x, c[51], H0;
MADH  H0.x, H0, c[57].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.z, R1.x, c[61].y;
ADDR  R1.x, -R1.z, -R0.w;
MADR  R1.x, R1, R1.y, R1.y;
MULR  R1.z, R1, R1.y;
RCPR  R0.w, R0.w;
MULR  R1.y, R0.w, R1.z;
MADR  R0.xyz, R1.y, c[63], R0;
MULR  R0.w, R1.x, R0;
ADDR  R1.xyz, -R3, c[54].zyyw;
MADR  R0.xyz, R0.w, c[62], R0;
MAXR  R0.xyz, R0, c[51].x;
MADR  R3.xyz, R1, c[48].x, R3;
MADR  R1.xyz, -R0, c[48].x, R0;
ELSE;
ADDR  R6.xy, R15, c[49].xzzw;
ADDR  R0.xy, R6, c[49].zyzw;
TEX   R4, R0, texture[8], 2D;
ADDR  R7.xy, R0, -c[49].xzzw;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R4|, H0;
MADH  H0.y, H0, c[60].w, -c[60].w;
MULR  R0.z, H0.y, c[61].x;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[61].z;
ADDH  H0.x, H0, c[59].w;
MULH  H0.z, H0.x, c[60].x;
SGEH  H0.xy, c[51].x, R4.ywzw;
TEX   R3, R7, texture[8], 2D;
MADH  H0.x, H0, c[57].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[61].y;
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[59].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R4.x;
MADR  R0.w, R0, R4.x, R4.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R4.x, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
MAXR  R1.xyz, R0, c[51].x;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[51].x, R3.xyyw;
MULR  R0.z, R0.x, c[61];
MULH  H0.x, H0, c[60];
RCPR  R3.y, R0.z;
MADH  H0.x, H0.z, c[57].w, H0;
FLRR  R0.y, R0.w;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[61].y;
MULR  R0.w, R0.x, R3.x;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R3.x, R3.x;
MULR  R1.w, R0.y, R3.y;
MULR  R0.xyz, R3.x, c[64];
MULR  R0.w, R3.y, R0;
MADR  R5.xyz, R0.w, c[63], R0;
TEX   R0, R6, texture[8], 2D;
MADR  R5.xyz, R1.w, c[62], R5;
MAXR  R6.xyz, R5, c[51].x;
ADDR  R5.xyz, R1, -R6;
TEX   R1, R15, texture[8], 2D;
ADDR  R15.xy, R7, -c[49].zyzw;
MULR  R3.xy, R15, c[50];
FRCR  R8.xy, R3;
MADR  R5.xyz, R8.x, R5, R6;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R4.x, H0.z, c[61];
ADDH  H0.x, H0, c[59].w;
SGEH  H1.xy, c[51].x, R0.ywzw;
MULH  H0.x, H0, c[60];
SGEH  H1.zw, c[51].x, R1.xyyw;
FRCR  R3.x, R4;
FLRR  R3.y, R4.x;
MADH  H0.x, H1, c[57].w, H0;
ADDR  R0.y, H0.x, R3;
MULR  R3.y, R3.x, c[61].z;
MULR  R3.x, R0.y, c[61].y;
ADDR  R0.y, -R3.x, -R3;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
RCPR  R3.y, R3.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R3.x, R3, R0;
MULR  R0.y, R0, R3;
MULR  R3.x, R3.y, R3;
MULR  R6.xyz, R0.x, c[64];
MADR  R6.xyz, R3.x, c[63], R6;
MADH  H0.z, H0, c[60].w, -c[60].w;
MADR  R6.xyz, R0.y, c[62], R6;
MULR  R0.x, H0.z, c[61];
FRCR  R0.y, R0.x;
MULR  R1.y, R0, c[61].z;
MADH  H0.x, H1.z, c[57].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.y, R0.x, c[61];
ADDR  R0.x, -R0.y, -R1.y;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
RCPR  R1.y, R1.y;
MADR  R0.x, R0, R1, R1;
MULR  R0.y, R0, R1.x;
MULR  R0.x, R0, R1.y;
MULR  R0.y, R1, R0;
MULR  R7.xyz, R1.x, c[64];
MADR  R7.xyz, R0.y, c[63], R7;
MADR  R7.xyz, R0.x, c[62], R7;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.x, H0.z, c[61];
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[51].x;
MAXR  R6.xyz, R6, c[51].x;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R8.x, R6, R7;
MADH  H0.x, H1.y, c[57].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
MULR  R0.y, R0, c[61].z;
MULR  R0.x, R0, c[61].y;
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[64];
MADR  R0.xyz, R1.x, c[63], R0;
MADR  R0.xyz, R0.w, c[62], R0;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
FRCR  R1.x, R0.w;
MULR  R1.y, R1.x, c[61].z;
RCPR  R3.x, R1.y;
MADH  H0.x, H1.w, c[57].w, H0;
FLRR  R0.w, R0;
ADDR  R0.w, H0.x, R0;
MULR  R1.x, R0.w, c[61].y;
ADDR  R0.w, -R1.x, -R1.y;
MADR  R0.w, R1.z, R0, R1.z;
MULR  R1.w, R1.z, R1.x;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[59].w;
MULR  R0.w, R0, R3.x;
MULR  R1.w, R3.x, R1;
MULR  R1.xyz, R1.z, c[64];
MADR  R1.xyz, R1.w, c[63], R1;
MADR  R1.xyz, R0.w, c[62], R1;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
MULH  H0.x, H0, c[60];
MADH  H0.z, H0.w, c[57].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULH  H0.z, |R4.w|, H0;
MULR  R3.y, R1.w, c[61];
MULR  R3.x, R0.w, c[61].z;
ADDR  R4.x, -R3.y, -R3;
MADR  R4.y, R3.z, R4.x, R3.z;
MADH  H0.z, H0, c[60].w, -c[60].w;
MULR  R0.w, H0.z, c[61].x;
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[59].w;
MULH  H0.x, H0, c[60];
MULR  R3.w, R1, c[61].z;
MAXR  R1.xyz, R1, c[51].x;
MAXR  R0.xyz, R0, c[51].x;
ADDR  R0.xyz, R0, -R1;
RCPR  R4.x, R3.x;
MULR  R4.w, R3.z, R3.y;
MULR  R4.w, R4.x, R4;
MULR  R3.xyz, R3.z, c[64];
MADR  R0.xyz, R8.x, R0, R1;
MADR  R3.xyz, R4.w, c[63], R3;
MULR  R4.x, R4.y, R4;
MADR  R3.xyz, R4.x, c[62], R3;
MAXR  R3.xyz, R3, c[51].x;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[57].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R1.w, R0, c[61].y;
ADDR  R0.w, -R1, -R3;
MULR  R4.w, R4.z, R1;
MADR  R0.w, R4.z, R0, R4.z;
RCPR  R1.w, R3.w;
MULR  R4.xyz, R4.z, c[64];
MULR  R3.w, R1, R4;
MADR  R4.xyz, R3.w, c[63], R4;
MULR  R0.w, R0, R1;
MADR  R4.xyz, R0.w, c[62], R4;
MAXR  R4.xyz, R4, c[51].x;
ADDR  R4.xyz, R4, -R3;
MADR  R1.xyz, R8.x, R4, R3;
ADDR  R1.xyz, R1, -R0;
MADR  R3.xyz, R8.y, R5, R6;
MADR  R1.xyz, R8.y, R1, R0;
ENDIF;
MOVR  R0.x, c[52].y;
MULR  R0.x, R0, c[8].w;
SGTRC HC.x, R7.w, R0;
IF    NE.x;
TEX   R0.xyz, R15, texture[9], 2D;
ELSE;
MOVR  R0.xyz, c[51].x;
ENDIF;
MULR  R1.xyz, R1, R2.w;
MADR  R0.xyz, R0, R1, R2;
ADDR  R2.xyz, R0, R3;
MULR  R0.xyz, R2.y, c[59];
MADR  R0.xyz, R2.x, c[58], R0;
MADR  R0.xyz, R2.z, c[57], R0;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[59];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[56].xywz;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[56].w;
SGER  H0.x, R0, c[57].w;
MULH  H0.y, H0.x, c[57].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[58].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[59].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[60].x;
MADR  R2.xyz, R1.x, c[58], R2;
MADR  R1.xyz, R1.z, c[57], R2;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[56].xywz;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[51].y, H0.z;
MINR  R0.z, R1, c[56].w;
SGER  H0.z, R0, c[57].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[57].w;
MINR  R0.w, R0, c[54].x;
MADR  R0.x, R0, c[60].y, R0.w;
ADDR  R0.z, R0, -H0.y;
MOVR  R1.x, c[52];
MADR  H0.y, R0.x, c[60].z, R1.x;
MULR  R0.w, R0.z, c[58];
FLRR  H0.w, R0;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[60];
ADDR  R0.x, R0.z, -H0;
ADDH  H0.x, H0.w, -c[59].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[54].x;
MADR  R0.x, R0, c[60].y, R0.y;
MADR  H0.z, R0.x, c[60], R1.x;
MADH  H0.x, H0.y, c[51].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 4 [_CameraDepthTexture] 2D
Vector 9 [_PlanetCenterKm]
Vector 10 [_PlanetNormal]
Float 11 [_PlanetRadiusKm]
Float 12 [_PlanetAtmosphereRadiusKm]
Float 13 [_WorldUnit2Kilometer]
Float 14 [_bComputePlanetShadow]
Vector 15 [_SunColor]
Vector 16 [_SunDirection]
Vector 17 [_AmbientNightSky]
Vector 18 [_NuajLightningPosition00]
Vector 19 [_NuajLightningPosition01]
Vector 20 [_NuajLightningColor0]
Vector 21 [_NuajLightningPosition10]
Vector 22 [_NuajLightningPosition11]
Vector 23 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 24 [_ShadowAltitudesMinKm]
Vector 25 [_ShadowAltitudesMaxKm]
SetTexture 7 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 6 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 9 [_TexBackground] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 5 [_TexDownScaledZBuffer] 2D
Vector 35 [_CaseSwizzle]
Vector 36 [_SwizzleExitUp0]
Vector 37 [_SwizzleExitUp1]
Vector 38 [_SwizzleExitUp2]
Vector 39 [_SwizzleExitUp3]
Vector 40 [_SwizzleEnterDown0]
Vector 41 [_SwizzleEnterDown1]
Vector 42 [_SwizzleEnterDown2]
Vector 43 [_SwizzleEnterDown3]
Vector 44 [_IsGodRaysLayerUp]
Vector 45 [_IsGodRaysLayerDown]
Vector 46 [_IsGodRaysLayerUpDown]
SetTexture 8 [_MainTex] 2D
Float 47 [_ZBufferDiscrepancyThreshold]
Float 48 [_ShowZBufferDiscrepancies]
Vector 49 [_dUV]
Vector 50 [_InvdUV]

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
dcl_2d s9
def c51, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c52, -1000000.00000000, 0.99500000, 1000000.00000000, 0.00100000
def c53, 0.75000000, 1.50000000, 0.50000000, 2.71828198
defi i0, 255, 0, 1, 0
def c54, 2.00000000, 3.00000000, 1000.00000000, 10.00000000
def c55, 400.00000000, 5.60204458, 9.47328472, 19.64380264
def c56, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c57, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c58, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c59, 0.25000000, -15.00000000, 4.00000000, 255.00000000
def c60, 256.00000000, 0.00097656, 1.00000000, 15.00000000
def c61, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c62, -1.02170002, 1.97770000, 0.04390000, 0
def c63, 2.56509995, -1.16649997, -0.39860001, 0
def c64, 0.07530000, -0.25430000, 1.18920004, 0
dcl_texcoord0 v0.xyzw
texldl r7, v0, s2
texldl r6, v0, s3
texldl r11, v0, s0
texldl r8, v0, s1
mov r12.w, r6.y
mad r0.xy, v0, c51.x, c51.y
mov r4, c39
mov r12.z, r7.y
mov r6.y, r8.z
mov r12.x, r11.y
mov r12.y, r8
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c51.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
add r0.y, c24, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c13.x
add r2.xyz, r2, -c9
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c24, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
cmp r0.x, r0, r1.w, c52
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c51.w, c51.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c52.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c11.x
add r1.y, c24.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c51, c51.z
cmp r1.z, r1, r1.w, c52.x
cmp_pp r0.z, r1.x, c51.w, c51
cmp r1.x, r1, r1.w, c52
cmp r0.w, -r0, r1.z, r2.x
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c35
cmp r5.z, -r0.x, c51.w, c51
mov r1, c37
add r1, -c41, r1
mad r3, r5.z, r1, c41
mov r0, c36
add r0, -c40, r0
mad r2, r5.z, r0, c40
mov r0.w, r6
mov r6.w, r6.z
mov r1, c38
add r4, -c43, r4
mad r4, r5.z, r4, c43
add r1, -c42, r1
mad r1, r5.z, r1, c42
mov r0.z, r7.w
mov r6.z, r7
mov r0.x, r11.w
mov r0.y, r8.w
dp4 r5.y, r3, r0
dp4 r5.w, r4, r0
dp4 r5.x, r2, r0
dp4 r5.z, r1, r0
add r5, r5, c51.y
dp4 r0.y, r3, r3
dp4 r0.w, r4, r4
dp4 r0.x, r2, r2
dp4 r0.z, r1, r1
mad r0, r0, r5, c51.w
mov r5.w, r6.x
mov r6.x, r11.z
dp4 r7.z, r4, r6
mov r5.z, r7.x
dp4 r7.y, r4, r12
mov r5.x, r11
mov r5.y, r8.x
dp4 r7.x, r4, r5
dp4 r4.z, r1, r6
dp4 r4.x, r1, r5
dp4 r4.y, r1, r12
mad r1.xyz, r0.z, r7, r4
dp4 r4.z, r3, r6
dp4 r4.x, r3, r5
dp4 r4.y, r3, r12
mad r1.xyz, r0.y, r1, r4
dp4 r3.z, r2, r6
dp4 r3.x, r2, r5
dp4 r3.y, r2, r12
mad r6.xyz, r0.x, r1, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r2.xy, v0, c49.xzzw
add r0.xy, r2, c49.zyzw
add r3.xy, r0, -c49.xzzw
mov r0.z, v0.w
mov r3.z, v0.w
mov r2.z, v0.w
add r7.xy, r3, -c49.zyzw
mul r1.zw, r7.xyxy, c50.xyxy
texldl r0.x, r0.xyzz, s5
texldl r1.x, r3.xyzz, s5
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s5
texldl r2.x, r2.xyzz, s5
add r0.z, r2.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c8.w, -c8.z
rcp r0.y, r0.x
mul r0.y, r0, c8.w
texldl r0.x, v0, s4
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c8.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r6.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c47.x
mad r0.xy, r7, c51.x, c51.y
mov r0.z, c51.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.x, r0.w
mul r0.xyz, r2.x, r0
mov r0.w, c51.z
dp4 r8.z, r0, c2
dp4 r8.y, r0, c1
dp4 r8.x, r0, c0
mov r0.x, c11
mov r0.y, c11.x
mul r11.xyz, r8.zxyw, c16.yzxw
mad r11.xyz, r8.yzxw, c16.zxyw, -r11
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r9.xyz, r1, c13.x
add r5.xyz, r9, -c9
dp3 r2.y, r8, r5
dp3 r2.z, r5, r5
add r0.y, c25, r0
mad r0.z, -r0.y, r0.y, r2
mad r0.w, r2.y, r2.y, -r0.z
rsq r1.x, r0.w
add r0.x, c25, r0
mad r0.x, -r0, r0, r2.z
mad r0.x, r2.y, r2.y, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2.y, -r0.y
cmp_pp r0.y, r0.x, c51.w, c51.z
rcp r1.x, r1.x
cmp r0.x, r0, r9.w, c52.z
cmp r0.x, -r0.y, r0, r0.z
cmp_pp r0.y, r0.w, c51.w, c51.z
add r1.x, -r2.y, -r1
cmp r0.w, r0, r9, c52.z
cmp r0.y, -r0, r0.w, r1.x
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.x, c25.w, r0.z
mad r0.w, -r0, r0, r2.z
mad r0.z, r2.y, r2.y, -r0.w
mad r1.x, -r1, r1, r2.z
mad r1.y, r2, r2, -r1.x
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r2.y, -r0.w
cmp_pp r0.w, r0.z, c51, c51.z
rsq r1.z, r1.y
rcp r1.z, r1.z
cmp r0.z, r0, r9.w, c52
cmp r0.z, -r0.w, r0, r1.x
add r1.z, -r2.y, -r1
cmp r1.x, r1.y, r9.w, c52.z
cmp_pp r0.w, r1.y, c51, c51.z
cmp r0.w, -r0, r1.x, r1.z
mov r1.x, c11
add r1.y, c24.x, r1.x
mov r1.x, c11
add r1.z, c24.y, r1.x
mad r1.y, -r1, r1, r2.z
mad r1.x, r2.y, r2.y, -r1.y
mad r1.z, -r1, r1, r2
mad r1.w, r2.y, r2.y, -r1.z
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r2.y, r1.y
cmp_pp r1.y, r1.x, c51.w, c51.z
rsq r3.x, r1.w
rcp r3.x, r3.x
cmp r1.x, r1, r9.w, c52
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c51.w, c51.z
dp4 r2.w, r0, c41
dp4 r3.w, r0, c40
add r3.x, -r2.y, r3
cmp r1.w, r1, r9, c52.x
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c11.x
add r1.w, c24, r1.z
mad r1.w, -r1, r1, r2.z
mad r3.y, r2, r2, -r1.w
rsq r1.w, r3.y
rcp r3.x, r1.w
mov r1.z, c11.x
add r1.z, c24, r1
mad r1.z, -r1, r1, r2
mad r1.z, r2.y, r2.y, -r1
add r3.z, -r2.y, r3.x
rsq r1.w, r1.z
rcp r3.x, r1.w
cmp_pp r1.w, r3.y, c51, c51.z
cmp r3.y, r3, r9.w, c52.x
cmp r1.w, -r1, r3.y, r3.z
add r3.y, -r2, r3.x
cmp_pp r3.x, r1.z, c51.w, c51.z
cmp r1.z, r1, r9.w, c52.x
cmp r1.z, -r3.x, r1, r3.y
dp4 r3.x, r1, c37
dp4 r3.y, r1, c35
add r3.z, r3.x, -r2.w
cmp r8.w, -r3.y, c51, c51.z
mad r3.y, r8.w, r3.z, r2.w
dp4 r3.z, r1, c36
add r4.x, r3.z, -r3.w
mov r3.x, c11
add r3.x, c31, r3
mad r3.x, -r3, r3, r2.z
mad r2.w, r2.y, r2.y, -r3.x
rsq r3.x, r2.w
rcp r3.x, r3.x
add r3.z, -r2.y, -r3.x
cmp_pp r3.x, r2.w, c51.w, c51.z
cmp r2.w, r2, r9, c52.z
cmp r2.w, -r3.x, r2, r3.z
rcp r2.x, r2.x
mul r3.x, r7.w, r2
cmp r2.w, r2, r2, c52.z
mad r3.z, -r3.x, c13.x, r2.w
mad r2.z, -c12.x, c12.x, r2
mad r2.z, r2.y, r2.y, -r2
rsq r2.w, r2.z
mov r2.x, c8.w
mad r2.x, c52.y, -r2, r7.w
mad r3.w, r8, r4.x, r3
rcp r2.w, r2.w
mul r3.x, r3, c13
cmp r2.x, r2, c51.w, c51.z
mad r3.z, r2.x, r3, r3.x
add r2.x, -r2.y, -r2.w
add r2.y, -r2, r2.w
cmp_pp r3.x, r2.z, c51.w, c51.z
cmp r2.zw, r2.z, r10.xyxy, c51.z
mul r10.xyz, r5.zxyw, c16.yzxw
mad r10.xyz, r5.yzxw, c16.zxyw, -r10
max r2.x, r2, c51.z
max r2.y, r2, c51.z
cmp r2.xy, -r3.x, r2.zwzw, r2
min r3.x, r2.y, r3.z
dp4 r2.z, r0, c42
dp4 r0.y, r0, c43
dp4 r0.x, r1, c39
max r14.x, r2, c52.w
add r0.z, r0.x, -r0.y
min r2.y, r3.x, r3.w
max r4.x, r14, r2.y
dp4 r2.y, r1, c38
add r2.y, r2, -r2.z
mad r2.y, r8.w, r2, r2.z
min r2.x, r3, r3.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
min r0.x, r3, r2.y
max r2.x, r4, r2
mad r0.y, r8.w, r0.z, r0
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r8, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r14.x
rcp r0.z, r0.y
rcp r2.z, r1.w
add r1.y, r4.x, -r14.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c51.z, c51.w
cmp r0.w, -r1.z, c51.z, c51
mul_pp r2.y, r0.w, r2
cmp r11.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r14.w, -r2.y, r0, r1.y
dp3 r0.y, r10, r10
dp3 r1.y, r10, r11
dp3 r1.z, r11, r11
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
rsq r2.z, r1.w
dp3 r0.y, r5, c16
cmp r0.y, -r0, c51.w, c51.z
cmp r1.w, -r1, c51.z, c51
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c52, r1
mad r5.xyz, r8, r1.z, r9
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c52.x, r1
cmp r1.y, -r1, c51.z, c51.w
mul_pp r0.y, r0, r1
cmp r15.xy, -r0.y, r1.zwzw, c52.zxzw
mad r2.w, r8, r2, c45.y
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r8.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r8.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r8.w, r0, c46
dp3 r2.z, r8, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c51.w
mul r2.w, r2, c51.x
mad r2.w, c30.x, c30.x, r2
mul r15.z, r2, c53.x
mov r2.z, c30.x
add r2.z, c51.w, r2
add r2.w, r2, c51
mov r16.x, r3
pow r3, r2.w, c53.y
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r11.w, c51.z, c51.w
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r15.w, r2.z, r2
mov r11.xyz, c51.w
mov r10.xyz, c51.z
if_gt r2.y, c51.z
frc r2.y, r11.w
add r2.y, r11.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r16.y, r2, r2.z, -r2.z
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r16.z, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r16, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s6
mul r2.y, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r2.y
pow r13, c53.w, r17.x
pow r3, c53.w, r17.y
mov r13.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.w, -r14.x, r15.y
rcp r2.z, r14.w
add r2.y, r3.x, -r15.x
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r3
mul r13.xyz, r13, r2.y
mov r2.y, c51.z
mul r14.xyz, r13, c15
if_gt c34.x, r2.y
add r3.y, r16.z, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r12
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r10.w, r2.y, c51, r10
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s7
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r13.x, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c54.x, c54
mul r2.w, r2, r2
add r3.z, r13.w, c51.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c51
mul r2.y, r2, r2.z
mul r10.w, r2.y, r2
endif
mul r14.xyz, r14, r10.w
endif
add r13.xyz, -r12, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
add r13.xyz, -c21, r13
dp3 r3.z, r13, r13
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r12.xyz, -r12, c18
dp3 r3.y, r12, r12
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r12.xyz, r3.y, r12
dp3 r2.y, r12, r8
mul r3.z, r3, c54
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r12.xyz, c19
add r2.y, r2, c51.w
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c54.z
add r12.xyz, -c18, r12
dp3 r2.z, r12, r12
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c54.z
min r2.w, r2.y, c51
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c54.z
mul r2.z, r5.y, c28.x
min r2.y, r2, c51.w
mul r12.xyz, r2.w, c23
mad r12.xyz, r2.y, c20, r12
mul r2.y, r5, c29.x
mad r13.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r12.xyz, r12, c54.w
mul r12.xyz, r2.z, r12
mul r12.xyz, r12, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r5.xyz, r2.y, c55.yzww, r2.z
mad r5.xyz, r14, r5, r12
mul r12.xyz, r14.w, -r13
add r13.xyz, r5, c17
pow r5, c53.w, r12.x
mul r13.xyz, r13, r14.w
mad r10.xyz, r13, r11, r10
mov r12.x, r5
pow r13, c53.w, r12.y
pow r5, c53.w, r12.z
mov r12.y, r13
mov r12.z, r5
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r5.w, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r5.w, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c51.w
mul r3.x, r2.y, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s6
mul r2.y, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r2.y
pow r13, c53.w, r17.x
add r2.y, r11.w, -r16
mul r11.w, r2.y, r14
pow r12, c53.w, r17.y
add r2.y, r11.w, r14.x
mov r13.y, r12
pow r12, c53.w, r17.z
rcp r2.z, r11.w
add r2.y, r2, -r15.x
add r2.w, -r14.x, r15.y
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c51.w
mov r13.z, r12
mul r12.xyz, r13, r2.y
mov r2.y, c51.z
mul r12.xyz, r12, c15
if_gt c34.x, r2.y
add r5.w, r5, -c11.x
add r2.y, r5.w, -c25.w
cmp_pp r2.z, r2.y, c51, c51.w
mov r13.xyz, r5
mov r13.w, c51
dp4 r3.w, r13, c5
dp4 r3.z, r13, c4
cmp r9.w, r2.y, c51, r9
if_gt r2.z, c51.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r5.w, -c25.x
mul_sat r2.y, r2, r2.z
mov r13.xy, r3.zwzw
mov r13.z, c51
texldl r13, r13.xyzz, s7
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r3.z, r13.x, c51.y
mad r2.z, r2, r3, c51.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r5.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.w, r2.y, r2
add r3.z, r13.y, c51.y
mad r2.w, r2, r3.z, c51
mov r2.y, c24.z
add r3.z, -c25, r2.y
mul r2.y, r2.z, r2.w
rcp r2.w, r3.z
add r2.z, r5.w, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c54.x, c54.y
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r13.z, c51.y
mad r2.z, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25
mul_sat r2.w, r2, r3.z
mad r3.z, -r2.w, c54.x, c54.y
mul r2.w, r2, r2
add r3.w, r13, c51.y
mul r2.w, r2, r3.z
mad r2.w, r2, r3, c51
mul r2.y, r2, r2.z
mul r9.w, r2.y, r2
endif
mul r12.xyz, r12, r9.w
endif
add r13.xyz, -r5, c21
dp3 r2.y, r13, r13
rsq r2.y, r2.y
mul r13.xyz, r2.y, r13
dp3 r2.z, r8, r13
mul r2.z, r2, c30.x
add r2.w, r2.z, c51
mul r2.z, -c30.x, c30.x
mov r13.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c51.w
mul r3.z, r2, r2.w
mul r3.w, r3.z, r2
add r13.xyz, -c21, r13
add r5.xyz, -r5, c18
dp3 r3.z, r13, r13
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.z, r3.z
rcp r3.z, r3.z
mul r3.z, r3, r3.w
rcp r3.w, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r8
mul r3.w, r3, c54.z
mul r2.y, r2, c30.x
mul r3.w, r3, r3
rcp r3.w, r3.w
mul r3.z, r3, r3.w
add r2.y, r2, c51.w
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c54.z
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.z, r3, c54
min r2.z, r3, c51.w
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c54.z
min r2.y, r2, c51.w
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r13.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c54.w
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c55.x
mul r2.z, r15.w, r2
mul r2.y, r2, r15.z
mad r3.xyz, r2.y, c55.yzww, r2.z
mad r3.xyz, r12, r3, r5
add r5.xyz, r3, c17
mul r12.xyz, r11.w, -r13
pow r3, c53.w, r12.x
mul r5.xyz, r5, r11.w
mad r10.xyz, r5, r11, r10
mov r12.x, r3
pow r5, c53.w, r12.y
pow r3, c53.w, r12.z
mov r12.y, r5
mov r12.z, r3
mul r11.xyz, r11, r12
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r13.xyz, r10
cmp r2.w, -r2.z, c51.z, c51
cmp r3.x, r3, c51.z, c51.w
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r11.w, -r2, r2.z, r1
cmp_pp r1.w, -r11, c51.z, c51
cmp r14.w, -r2, r0, r2.y
mov r14.x, r4
mov r10.xyz, c51.z
if_gt r1.w, c51.z
frc r1.w, r11
add r1.w, r11, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r16.y, r1.w, r2, -r2
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r3.xyz, r12, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r16.z, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r16.z, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r5, r3.xyzz, s6
mul r1.w, r5, c29.x
mad r17.xyz, r5.z, -c27, -r1.w
pow r4, c53.w, r17.x
pow r3, c53.w, r17.y
mov r4.y, r3
pow r3, c53.w, r17.z
add r3.x, r14, r14.w
add r2.z, -r14.x, r15.y
rcp r2.y, r14.w
add r1.w, r3.x, -r15.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c51.z
mul r14.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r12
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r10.w, r1, c51, r10
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s7
add r2.w, r4.x, c51.y
mad r1.w, r2.y, r2, c51
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c54.x, c54.y
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.y, r4.w, c51
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c51.w
mul r1.w, r1, r2.y
mul r10.w, r1, r2.z
endif
mul r14.xyz, r14, r10.w
endif
add r4.xyz, -r12, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r12.xyz, -r12, c18
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r12, r12
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r12
dp3 r1.w, r4, r8
mul r3.y, r3, c54.z
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c51
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c54.z
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c51.w
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c54.z
mul r2.y, r5, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r12.xyz, r14.w, -r12
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r5.xyz, r1.w, c55.yzww, r2.y
mad r4.xyz, r14, r5, r4
add r5.xyz, r4, c17
pow r4, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r4
pow r5, c53.w, r12.y
pow r4, c53.w, r12.z
mov r12.y, r5
mov r12.z, r4
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r3.xyz, r5, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r5.w, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r5.w, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c51
mul r3.x, r1.w, c53.z
mov r3.z, c51
texldl r3, r3.xyzz, s6
mul r1.w, r3, c29.x
mad r17.xyz, r3.z, -c27, -r1.w
pow r12, c53.w, r17.x
add r1.w, r11, -r16.y
mul r11.w, r1, r14
pow r4, c53.w, r17.y
add r1.w, r11, r14.x
mov r12.y, r4
pow r4, c53.w, r17.z
mov r12.z, r4
rcp r2.y, r11.w
add r1.w, r1, -r15.x
add r2.z, -r14.x, r15.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c51
mul r4.xyz, r12, r1.w
mov r1.w, c51.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
cmp_pp r2.y, r1.w, c51.z, c51.w
mov r4.xyz, r5
mov r4.w, c51
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r9.w, r1, c51, r9
if_gt r2.y, c51.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c54.x, c54.y
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r5, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c54.x, c54.y
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r4.xy, r3.zwzw
mov r4.z, c51
texldl r4, r4.xyzz, s7
add r2.w, r4.x, c51.y
mad r2.y, r2, r2.w, c51.w
add r2.w, r4.y, c51.y
mad r2.z, r2, r2.w, c51.w
mov r1.w, c24.z
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r5.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c54.x, c54.y
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c51.y
mad r2.y, r2.z, r3.z, c51.w
rcp r2.w, r2.w
add r2.z, r5.w, -c25.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c54.x, c54.y
mul r2.z, r2, r2
add r3.z, r4.w, c51.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3, c51.w
mul r1.w, r1, r2.y
mul r9.w, r1, r2.z
endif
mul r12.xyz, r12, r9.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r8, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c51.w
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.z, r4, r4
rsq r3.z, r3.z
rcp r2.z, r2.z
add r2.y, r2, c51.w
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.z, r3.z
mul r3.z, r3, r2.w
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r8
mul r2.w, r2, c54.z
mul r2.w, r2, r2
mul r1.w, r1, c30.x
mov r4.xyz, c19
rcp r3.w, r2.w
add r1.w, r1, c51
rcp r2.w, r1.w
mul r2.y, r2, r2.w
mul r1.w, r3.z, r3
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c54
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c54.z
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c51.w
mul r1.w, r2.y, c54.z
mul r2.y, r3, c28.x
min r1.w, r1, c51
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c54.w
mul r4.xyz, r2.y, r4
mul r5.xyz, r11.w, -r5
mul r4.xyz, r4, c55.x
mul r2.y, r15.w, r2
mul r1.w, r1, r15.z
mad r3.xyz, r1.w, c55.yzww, r2.y
mad r3.xyz, r12, r3, r4
add r4.xyz, r3, c17
pow r3, c53.w, r5.x
mul r4.xyz, r4, r11.w
mad r10.xyz, r4, r11, r10
mov r5.x, r3
pow r4, c53.w, r5.y
pow r3, c53.w, r5.z
mov r5.y, r4
mov r5.z, r3
mul r11.xyz, r11, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r10
cmp r2.z, -r2.y, c51, c51.w
cmp r2.w, r2, c51.z, c51
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r11.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r11.w, c51, c51.w
cmp r14.w, -r2.z, r0, r1
mov r14.x, r2
mov r10.xyz, c51.z
if_gt r1.z, c51.z
frc r1.z, r11.w
add r1.z, r11.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r16.y, r1.z, r1.w, -r1.w
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r2.xyz, r12, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r16.z, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r16.z, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c51.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r5, r2.xyzz, s6
mul r1.z, r5.w, c29.x
mad r17.xyz, r5.z, -c27, -r1.z
pow r2, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r2
pow r2, c53.w, r17.z
add r3.x, r14, r14.w
add r2.x, -r14, r15.y
rcp r1.w, r14.w
add r1.z, r3.x, -r15.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mov r17.z, r2
mul r2.xyz, r17, r1.z
mov r1.z, c51
mul r14.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r16.z, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r12
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r10.w, r1.z, c51, r10
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s7
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c51.w
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c54, c54.y
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r10.w, r1.z, r2.x
endif
mul r14.xyz, r14, r10.w
endif
add r2.xyz, -r12, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r12.xyz, -r12, c18
dp3 r2.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r12
rcp r3.z, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.z, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c54.z
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c54
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r1.w
mul r12.xyz, r14.w, -r12
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.z, r2
mul r2.w, r15, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r15
mad r5.xyz, r1.z, c55.yzww, r2.w
mul r2.xyz, r2, c55.x
mad r2.xyz, r14, r5, r2
add r5.xyz, r2, c17
pow r2, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r2
pow r5, c53.w, r12.y
pow r2, c53.w, r12.z
mov r12.y, r5
mov r12.z, r2
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r2.xyz, r5, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r5.w, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r5, -c11.x
add r1.z, -r1, c51.w
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c53.z
mov r2.z, c51
texldl r3, r2.xyzz, s6
mul r1.z, r3.w, c29.x
mad r17.xyz, r3.z, -c27, -r1.z
pow r12, c53.w, r17.x
add r1.z, r11.w, -r16.y
mul r11.w, r1.z, r14
pow r2, c53.w, r17.y
add r1.z, r11.w, r14.x
mov r12.y, r2
pow r2, c53.w, r17.z
mov r12.z, r2
rcp r1.w, r11.w
add r1.z, r1, -r15.x
add r2.x, -r14, r15.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c51.w
mul r2.xyz, r12, r1.z
mov r1.z, c51
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r5.w, r5, -c11.x
add r1.z, r5.w, -c25.w
cmp_pp r1.w, r1.z, c51.z, c51
mov r2.xyz, r5
mov r2.w, c51
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r9.w, r1.z, c51, r9
if_gt r1.w, c51.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r5.w, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c51
texldl r2, r2.xyzz, s7
add r3.z, r2.x, c51.y
mad r2.x, -r1.z, c54, c54.y
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r5.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c54, c54.y
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c51
mad r2.x, r2, r2.y, c51.w
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r3.z, c51
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r5, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c54.x, c54
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c51.y
mad r1.w, r2.x, r2.z, c51
rcp r2.y, r2.y
add r2.x, r5.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c54.x, c54
mul r2.x, r2, r2
add r2.z, r2.w, c51.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c51.w
mul r1.z, r1, r1.w
mul r9.w, r1.z, r2.x
endif
mul r12.xyz, r12, r9.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r8, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c51.w
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c51
mul r3.z, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.z, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r3.w, r1.z
dp3 r1.z, r2, r8
mul r2.x, r3.w, c54.z
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c51.w
rcp r2.x, r1.z
mul r1.z, r3, r2.y
mul r1.w, r1, r2.x
mul r3.z, r1.w, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c54.z
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3.z
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c54
min r2.x, r1.z, c51.w
mul r1.z, r1.w, c54
mul r1.w, r3.y, c28.x
min r1.z, r1, c51.w
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c54.w
mul r2.xyz, r1.w, r2
mul r5.xyz, r11.w, -r5
mul r2.xyz, r2, c55.x
mul r1.w, r15, r1
mul r1.z, r1, r15
mad r3.xyz, r1.z, c55.yzww, r1.w
mad r2.xyz, r12, r3, r2
add r3.xyz, r2, c17
pow r2, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r2
pow r3, c53.w, r5.y
pow r2, c53.w, r5.z
mov r5.y, r3
mov r5.z, r2
mul r11.xyz, r11, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c51.z, c51.w
cmp r2.x, -r1.w, c51.z, c51.w
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r11.w, -r2.x, r1, r1.y
cmp r14.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r11.w, c51.z, c51.w
mov r2.xyz, r10
mov r14.x, r1
mov r10.xyz, c51.z
if_gt r1.y, c51.z
frc r1.x, r11.w
add r1.x, r11.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r16.y, r1.x, r1, -r1
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r1.xyz, r12, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r16.z, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r16.z, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r5, r1.xyzz, s6
mul r1.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r1.x
pow r1, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r1
pow r1, c53.w, r17.z
add r3.x, r14, r14.w
rcp r1.y, r14.w
add r1.w, -r14.x, r15.y
add r1.x, r3, -r15
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r17.z, r1
mul r1.xyz, r17, r1.x
mov r1.w, c51.z
mul r14.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r16.z, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r12
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r10.w, r2, c51, r10
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s7
add r3.w, r1.x, c51.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r10.w, r1.x, r1.z
endif
mul r14.xyz, r14, r10.w
endif
add r1.xyz, -r12, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
add r2.w, r1.x, c51
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r12.xyz, -r12, c18
dp3 r1.x, r12, r12
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r12
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c54.z
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r12.xyz, r14.w, -r12
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r15.w, r1.w
mul r1.w, r2, r15.z
mad r5.xyz, r1.w, c55.yzww, r3.y
mul r1.xyz, r1, c55.x
mad r1.xyz, r14, r5, r1
add r5.xyz, r1, c17
pow r1, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r1
pow r5, c53.w, r12.y
pow r1, c53.w, r12.z
mov r12.y, r5
mov r12.z, r1
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c51.w
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c51
mul r1.x, r1, c53.z
texldl r3, r1.xyzz, s6
mul r1.x, r3.w, c29
mad r17.xyz, r3.z, -c27, -r1.x
pow r12, c53.w, r17.x
pow r1, c53.w, r17.y
add r1.x, r11.w, -r16.y
mov r12.y, r1
mul r11.w, r1.x, r14
pow r1, c53.w, r17.z
add r1.x, r11.w, r14
rcp r1.y, r11.w
add r1.x, r1, -r15
add r1.w, -r14.x, r15.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c51.w
mov r12.z, r1
mul r1.xyz, r12, r1.x
mov r1.w, c51.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r5.w, r5, -c11.x
add r2.w, r5, -c25
mov r1.xyz, r5
mov r1.w, c51
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c51.z, c51.w
cmp r9.w, r2, c51, r9
if_gt r1.x, c51.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c51
texldl r1, r1.xyzz, s7
add r3.w, r1.x, c51.y
add r2.w, r5, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c54.x, c54.y
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c51.w
rcp r3.z, r3.z
add r2.w, r5, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c51.y
mad r3.z, -r2.w, c54.x, c54.y
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c51
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r5.w, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c51.y
mad r2.w, -r1.y, c54.x, c54.y
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c51.w
rcp r2.w, r2.w
add r1.z, r5.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c51.y
mad r1.w, -r1.z, c54.x, c54.y
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c51.w
mul r1.x, r1, r1.y
mul r9.w, r1.x, r1.z
endif
mul r12.xyz, r12, r9.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c30
add r1.y, r1.x, c51.w
mul r1.x, -c30, c30
rcp r3.z, r1.y
add r2.w, r1.x, c51
mul r3.w, r2, r3.z
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r3.w, r3, r3.z
dp3 r1.x, r5, r5
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.w, r1.x, r3
mul r1.xyz, r3.z, r5
dp3 r1.x, r1, r8
rcp r1.w, r1.w
mul r1.y, r1.w, c54.z
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.w, r1.y
add r1.x, r1, c51.w
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.z, r3.z
mul r1.w, r1.z, c54.z
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.z, r3, c54
mul r1.y, r3.z, r3.z
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c51.w
mul r1.w, r1.x, c54.z
mul r2.w, r3.y, c28.x
min r1.w, r1, c51
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c54.w
mul r1.xyz, r2.w, r1
mul r5.xyz, r11.w, -r5
mul r1.w, r1, r15.z
mul r2.w, r15, r2
mad r3.xyz, r1.w, c55.yzww, r2.w
mul r1.xyz, r1, c55.x
mad r1.xyz, r12, r3, r1
add r3.xyz, r1, c17
pow r1, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r1
pow r3, c53.w, r5.y
pow r1, c53.w, r5.z
mov r5.y, r3
mov r5.z, r1
mul r11.xyz, r11, r5
endif
add r1.x, r16, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c51, c51.w
cmp r1.y, -r0.z, c51.z, c51.w
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r11.w, -r1.y, r0.z, r0.y
cmp r14.w, -r1.y, r0, r1.x
mov r1.xyz, r10
cmp_pp r0.y, -r11.w, c51.z, c51.w
mov r14.x, r0
mov r10.xyz, c51.z
if_gt r0.y, c51.z
frc r0.x, r11.w
add r0.x, r11.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r16.y, r0.x, r0, -r0
mov r12.w, c51.z
loop aL, i0
break_ge r12.w, r16.y
mad r12.xyz, r14.x, r8, r9
add r0.xyz, r12, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r16.z, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r16.z, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r5, r0.xyzz, s6
mul r0.x, r5.w, c29
mad r17.xyz, r5.z, -c27, -r0.x
pow r0, c53.w, r17.y
pow r3, c53.w, r17.x
mov r17.x, r3
mov r17.y, r0
pow r0, c53.w, r17.z
add r3.x, r14, r14.w
rcp r0.y, r14.w
add r0.w, -r14.x, r15.y
add r0.x, r3, -r15
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r17.z, r0
mul r0.xyz, r17, r0.x
mov r0.w, c51.z
mul r14.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r16.z, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r12
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r10.w, r1, c51, r10
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s7
add r3.z, r0.x, c51.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c51.w
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c51.y
mad r2.w, -r1, c54.x, c54.y
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c51
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.y, c54.x, c54.y
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0, r0.y
mul r10.w, r0.x, r0.z
endif
mul r14.xyz, r14, r10.w
endif
add r0.xyz, -r12, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
add r1.w, r0.x, c51
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r12.xyz, -r12, c18
dp3 r0.x, r12, r12
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r12
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c54.z
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c54.z
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c51.w
mul r0.w, r0.x, c54.z
mul r1.w, r5.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r12.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r12.xyz, r14.w, -r12
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r5.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r14, r5, r0
add r5.xyz, r0, c17
pow r0, c53.w, r12.x
mul r5.xyz, r5, r14.w
mad r10.xyz, r5, r11, r10
mov r12.x, r0
pow r5, c53.w, r12.y
pow r0, c53.w, r12.z
mov r12.y, r5
mov r12.z, r0
mul r11.xyz, r11, r12
mov r14.x, r3
add r12.w, r12, c51
endloop
mad r5.xyz, r14.x, r8, r9
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c51.w
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c51
mul r0.x, r0, c53.z
texldl r3, r0.xyzz, s6
mul r0.x, r3.w, c29
mad r9.xyz, r3.z, -c27, -r0.x
pow r0, c53.w, r9.y
pow r12, c53.w, r9.x
add r0.x, r11.w, -r16.y
mul r11.w, r0.x, r14
mov r9.y, r0
pow r0, c53.w, r9.z
add r0.x, r11.w, r14
rcp r0.y, r11.w
add r0.x, r0, -r15
add r0.w, -r14.x, r15.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c51.w
mov r9.x, r12
mov r9.z, r0
mul r0.xyz, r9, r0.x
mov r0.w, c51.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r5.w, r5, -c11.x
add r1.w, r5, -c25
mov r0.xyz, r5
mov r0.w, c51
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c51.z, c51.w
cmp r9.w, r1, c51, r9
if_gt r0.x, c51.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r5, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c54.x, c54.y
mov r0.xy, r3.zwzw
mov r0.z, c51
texldl r0, r0.xyzz, s7
add r3.z, r0.x, c51.y
mul r1.w, r2, r1
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r5.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c51.y
mad r0.y, -r0.x, c54.x, c54
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c51.w
mad r1.w, r1, r3.z, c51
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r5.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c51.y
mad r1.w, -r0.x, c54.x, c54.y
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c51.w
rcp r1.w, r1.w
add r0.z, r5.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c51.y
mad r0.w, -r0.z, c54.x, c54.y
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c51.w
mul r0.x, r0.y, r0
mul r9.w, r0.x, r0.z
endif
mul r12.xyz, r12, r9.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c30
add r0.y, r0.x, c51.w
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c51
mul r3.z, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.z, r3, r2.w
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.z, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c54.z
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3, r0.y
add r0.x, r0, c51.w
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.z, r0, c54
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c54.z
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c54.z
min r0.y, r3.z, c51.w
mul r1.w, r3.y, c28.x
min r0.w, r0, c51
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c54.w
mul r0.xyz, r1.w, r0
mul r5.xyz, r11.w, -r5
mul r0.w, r0, r15.z
mul r1.w, r15, r1
mad r3.xyz, r0.w, c55.yzww, r1.w
mul r0.xyz, r0, c55.x
mad r0.xyz, r12, r3, r0
add r3.xyz, r0, c17
pow r0, c53.w, r5.x
mul r3.xyz, r3, r11.w
mad r10.xyz, r3, r11, r10
mov r5.x, r0
pow r3, c53.w, r5.y
pow r0, c53.w, r5.z
mov r5.y, r3
mov r5.z, r0
mul r11.xyz, r11, r5
endif
mov r3, c37
add r3, -c41, r3
mov r0, c36
mov r9, c39
mov r14, c38
add r9, -c43, r9
add r0, -c40, r0
mad r5, r8.w, r3, c41
mad r3, r8.w, r0, c40
texldl r1.w, r7.xyzz, s2
mov r0.z, r1.w
texldl r2.w, r7.xyzz, s0
texldl r1.w, r7.xyzz, s1
mov r0.x, r2.w
mov r0.y, r1.w
texldl r0.w, r7.xyzz, s3
dp4 r12.x, r3, r0
dp4 r3.x, r3, r3
mad r9, r8.w, r9, c43
add r14, -c42, r14
mad r8, r8.w, r14, c42
dp4 r12.y, r5, r0
dp4 r12.w, r9, r0
dp4 r12.z, r8, r0
add r0, r12, c51.y
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r3.w, r9, r9
mad r0, r3, r0, c51.w
mad r1.xyz, r10, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r13
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r0.xyz, r0.z, c58, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c56.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul r1.y, r0.w, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
min r0.x, r0, c56.w
add r0.z, r0.x, c57.w
cmp r0.z, r0, c51.w, c51
mul_pp r1.x, r0.z, c58.w
add r0.x, r0, -r1
mul r1.x, r0, c59
frc r0.w, r1.x
add r0.w, r1.x, -r0
mul_pp r1.x, r0.w, c59.z
mul r2.xyz, r11.y, c56
mad r2.xyz, r11.x, c57, r2
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.w, c59.y
exp_pp r0.w, r0.x
mad_pp r0.x, -r0.z, c51, c51.w
mul_pp r0.x, r0, r0.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r1
abs_pp r0.z, r0.x
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
mad r1.xyz, r11.z, c58, r2
add r2.x, r1, r1.y
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c51.y
add r1.z, r1, r2.x
mul_pp r0.z, r0, c61.x
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r2.x, r1.z, c56.w
mul r0.z, r0, c61.y
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c60.w
frc r2.y, r2.x
add r0.w, r2.x, -r2.y
min r0.w, r0, c56
add r2.x, r0.w, c57.w
mul r1.w, r1, c55.x
frc r2.y, r1.w
add r1.w, r1, -r2.y
cmp r2.x, r2, c51.w, c51.z
mul_pp r0.z, r0, c59
cmp_pp r0.x, -r0, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r2.x, c58.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c61.w
mul r1.x, r0.w, c59
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c59
add r0.w, r0, -r1.z
min r1.w, r1, c59
mad r1.z, r0.w, c60.x, r1.w
add_pp r0.w, r1.x, c59.y
exp_pp r1.x, r0.w
mad_pp r0.w, -r2.x, c51.x, c51
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c60.y, c60
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r2.x, r1.w
add_pp r1.w, r1, -r2.x
exp_pp r2.x, -r1.w
mad_pp r1.z, r1, r2.x, c51.y
mul r0.x, r0, c61.z
add r0.w, -r0.x, -r0.z
add r0.w, r0, c51
mul r2.xyz, r0.y, c62
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c61.x
mul r2.w, r0.z, c61.y
mad r0.xyz, r0.x, c63, r2
add_pp r1.z, r1.w, c60.w
frc r2.x, r2.w
mad r0.xyz, r0.w, c64, r0
add r1.w, r2, -r2.x
mul_pp r1.z, r1, c59
cmp_pp r1.x, -r1, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.z
mul r1.z, r2.x, c61.w
add r1.x, r1, r1.w
mul r1.x, r1, c61.z
add r1.w, -r1.x, -r1.z
add r0.w, r1, c51
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r2.xyz, r1.y, c62
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c51.z
mad r2.xyz, r1.y, c63, r2
mul r0.w, r0, r1.x
mad r2.xyz, r0.w, c64, r2
add r1.xyz, -r0, c51.wzzw
max r2.xyz, r2, c51.z
mad r1.xyz, r1, c48.x, r0
mad r2.xyz, -r2, c48.x, r2
else
add r2.xy, r7, c49.xzzw
add r1.xy, r2, c49.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s8
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r2.z, r1.w
add_pp r1.w, r1, -r2.z
exp_pp r2.z, -r1.w
mad_pp r1.z, r1, r2, c51.y
mul_pp r1.z, r1, c61.x
mul r2.z, r1, c61.y
add_pp r1.z, r1.w, c60.w
frc r2.w, r2.z
add r1.w, r2.z, -r2
add r8.xy, r1, -c49.xzzw
mul r2.z, r2.w, c61.w
mul_pp r1.z, r1, c59
cmp_pp r0.y, -r0, c51.w, c51.z
mad_pp r0.y, r0, c58.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c61.z
add r2.w, -r0.y, -r2.z
mov r8.z, r7
texldl r1, r8.xyzz, s8
abs_pp r3.x, r1.y
log_pp r3.y, r3.x
frc_pp r3.z, r3.y
add_pp r3.w, r3.y, -r3.z
add r2.w, r2, c51
mul r2.w, r2, r0.x
rcp r2.z, r2.z
mul r0.y, r0, r0.x
mul r2.w, r2, r2.z
exp_pp r3.y, -r3.w
mul r0.y, r2.z, r0
mad_pp r2.z, r3.x, r3.y, c51.y
mul r3.xyz, r0.x, c62
mad r3.xyz, r0.y, c63, r3
mul_pp r0.x, r2.z, c61
mul r0.y, r0.x, c61
mad r3.xyz, r2.w, c64, r3
frc r2.z, r0.y
add r2.w, r0.y, -r2.z
add_pp r0.x, r3.w, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r1.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r2.w
mul r0.y, r2.z, c61.w
mul r0.x, r0, c61.z
add r1.y, -r0.x, -r0
add r1.y, r1, c51.w
mov r2.z, r7
texldl r2, r2.xyzz, s8
abs_pp r3.w, r2.y
log_pp r4.x, r3.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r4.y, r4.x
add_pp r0.y, r4.x, -r4
mul r4.xyz, r1.x, c62
mad r4.xyz, r0.x, c63, r4
exp_pp r1.x, -r0.y
mad_pp r0.x, r3.w, r1, c51.y
mad r4.xyz, r1.y, c64, r4
mul_pp r0.x, r0, c61
mul r1.x, r0, c61.y
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c60.w
mul_pp r0.y, r0.x, c59.z
cmp_pp r0.x, -r2.y, c51.w, c51.z
mad_pp r0.x, r0, c58.w, r0.y
add r0.x, r0, r1
max r4.xyz, r4, c51.z
max r3.xyz, r3, c51.z
add r5.xyz, r3, -r4
texldl r3, r7.xyzz, s8
add r7.xy, r8, -c49.zyzw
mul r1.x, r0, c61.z
mul r1.y, r1, c61.w
add r2.y, -r1.x, -r1
mul r0.xy, r7, c50
frc r0.xy, r0
mad r5.xyz, r0.x, r5, r4
abs_pp r4.x, r3.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r2.y, r2, c51.w
mul r2.y, r2, r2.x
rcp r1.y, r1.y
mul r1.x, r1, r2
mul r2.y, r2, r1
exp_pp r4.y, -r4.w
mul r1.x, r1.y, r1
mad_pp r1.y, r4.x, r4, c51
mul r4.xyz, r2.x, c62
mad r4.xyz, r1.x, c63, r4
mad r4.xyz, r2.y, c64, r4
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
frc r2.x, r1.y
add r2.y, r1, -r2.x
add_pp r1.x, r4.w, c60.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.y, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
rcp r2.y, r1.y
mul r1.x, r1, r3
add r2.x, r2, c51.w
mul r1.y, r2.x, r3.x
abs_pp r2.x, r2.w
mul r1.y, r1, r2
log_pp r3.y, r2.x
mul r1.x, r2.y, r1
frc_pp r2.y, r3
mul r8.xyz, r3.x, c62
mad r8.xyz, r1.x, c63, r8
add_pp r2.y, r3, -r2
exp_pp r1.x, -r2.y
mad r8.xyz, r1.y, c64, r8
mad_pp r1.x, r2, r1, c51.y
mul_pp r1.x, r1, c61
mul r1.y, r1.x, c61
frc r2.x, r1.y
add_pp r1.x, r2.y, c60.w
add r2.y, r1, -r2.x
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r2.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
add r1.x, r1, r2.y
abs_pp r2.y, r3.w
log_pp r3.x, r2.y
frc_pp r3.y, r3.x
add_pp r3.x, r3, -r3.y
max r8.xyz, r8, c51.z
max r4.xyz, r4, c51.z
add r4.xyz, r4, -r8
mad r4.xyz, r0.x, r4, r8
mul r1.y, r2.x, c61.w
mul r1.x, r1, c61.z
add r2.x, -r1, -r1.y
add r2.x, r2, c51.w
mul r2.x, r2.z, r2
rcp r1.y, r1.y
mul r2.w, r2.x, r1.y
mul r1.x, r2.z, r1
exp_pp r2.x, -r3.x
mul r1.x, r1.y, r1
mad_pp r1.y, r2, r2.x, c51
mul r2.xyz, r2.z, c62
mad r2.xyz, r1.x, c63, r2
mad r2.xyz, r2.w, c64, r2
mul_pp r1.y, r1, c61.x
mul r1.y, r1, c61
max r8.xyz, r2, c51.z
frc r2.w, r1.y
add_pp r1.x, r3, c60.w
add r3.x, r1.y, -r2.w
mul_pp r1.y, r1.x, c59.z
cmp_pp r1.x, -r3.w, c51.w, c51.z
mad_pp r1.x, r1, c58.w, r1.y
mul r1.y, r2.w, c61.w
add r1.x, r1, r3
mul r1.x, r1, c61.z
add r2.w, -r1.x, -r1.y
rcp r2.y, r1.y
add r2.x, r2.w, c51.w
mul r1.y, r3.z, r2.x
mul r3.x, r1.y, r2.y
mul r1.y, r3.z, r1.x
mul r3.y, r2, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r3.w, r1.y, -r2
exp_pp r1.y, -r3.w
mad_pp r1.x, r1, r1.y, c51.y
mul_pp r1.y, r1.x, c61.x
abs_pp r1.x, r0.w
mul r4.w, r1.y, c61.y
frc r5.w, r4
log_pp r1.y, r1.x
frc_pp r2.w, r1.y
add_pp r1.y, r1, -r2.w
exp_pp r2.w, -r1.y
mad_pp r1.x, r1, r2.w, c51.y
mul r2.xyz, r3.z, c62
mad r2.xyz, r3.y, c63, r2
mad r2.xyz, r3.x, c64, r2
max r2.xyz, r2, c51.z
add r3.xyz, r8, -r2
add_pp r3.w, r3, c60
add r4.w, r4, -r5
mad r2.xyz, r0.x, r3, r2
mul_pp r3.w, r3, c59.z
cmp_pp r1.w, -r1, c51, c51.z
mad_pp r1.w, r1, c58, r3
add r1.w, r1, r4
mul r3.w, r1, c61.z
mul r4.w, r5, c61
mul_pp r1.x, r1, c61
mul r1.w, r1.x, c61.y
add_pp r1.x, r1.y, c60.w
frc r2.w, r1
add r1.y, r1.w, -r2.w
add r5.w, -r3, -r4
mul r8.x, r1.z, r3.w
rcp r3.w, r4.w
mul r4.w, r3, r8.x
mul r1.w, r2, c61
mul_pp r1.x, r1, c59.z
cmp_pp r0.w, -r0, c51, c51.z
mad_pp r0.w, r0, c58, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c61.z
add r1.x, -r0.w, -r1.w
add r1.y, r5.w, c51.w
add r2.w, r1.x, c51
mul r5.w, r1.z, r1.y
mul r1.xyz, r1.z, c62
mul r3.w, r5, r3
mad r1.xyz, r4.w, c63, r1
mad r1.xyz, r3.w, c64, r1
mul r3.w, r0.z, r0
mul r2.w, r0.z, r2
rcp r0.w, r1.w
mul r8.xyz, r0.z, c62
mul r0.z, r0.w, r3.w
mad r8.xyz, r0.z, c63, r8
mul r0.z, r2.w, r0.w
mad r8.xyz, r0.z, c64, r8
max r1.xyz, r1, c51.z
max r8.xyz, r8, c51.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r3.xyz, r1, -r2
add r5.xyz, r5, -r4
mad r1.xyz, r0.y, r5, r4
mad r2.xyz, r0.y, r3, r2
endif
mov r0.x, c8.w
mul r0.x, c52.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s9
else
mov r0.xyz, c51.z
endif
mul r2.xyz, r2, r6.w
mad r0.xyz, r0, r2, r6
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c56
mad r1.xyz, r0.x, c57, r1
mad r1.xyz, r0.z, c58, r1
add r0.x, r1, r1.y
add r0.x, r1.z, r0
rcp r0.x, r0.x
mul r0.zw, r1.xyxy, r0.x
mul r0.x, r0.z, c56.w
frc r0.y, r0.x
add r0.x, r0, -r0.y
min r0.x, r0, c56.w
add r0.y, r0.x, c57.w
cmp r1.x, r0.y, c51.w, c51.z
mul_pp r0.y, r1.x, c58.w
add r1.z, r0.x, -r0.y
mul r0.x, r1.z, c59
frc r0.y, r0.x
add r1.w, r0.x, -r0.y
mul r3.xyz, r2.y, c56
mad r0.xyz, r2.x, c57, r3
mad r0.xyz, r2.z, c58, r0
add_pp r2.x, r1.w, c59.y
add r2.y, r0.x, r0
add r2.y, r0.z, r2
exp_pp r2.x, r2.x
mad_pp r1.x, -r1, c51, c51.w
mul_pp r0.z, r1.x, r2.x
rcp r2.x, r2.y
mul_pp r1.x, r1.w, c59.z
mul r2.xy, r0, r2.x
add r0.x, r1.z, -r1
mul r1.z, r2.x, c56.w
mul r0.w, r0, c55.x
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r0.w, r0, c59
mad r0.x, r0, c60, r0.w
mad r0.x, r0, c60.y, c60.z
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c56.w
add r1.z, r1.x, c57.w
cmp r0.w, r1.z, c51, c51.z
mov_pp oC0.x, r1.y
mul_pp r1.z, r0.w, c58.w
mul_pp oC0.y, r0.z, r0.x
add r0.x, r1, -r1.z
mul r0.z, r0.x, c59.x
frc r1.x, r0.z
add r0.z, r0, -r1.x
mul_pp r1.x, r0.z, c59.z
mul r1.y, r2, c55.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
add r0.x, r0, -r1
min r1.y, r1, c59.w
mad r1.x, r0, c60, r1.y
add_pp r0.x, r0.z, c59.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r0.w, c51, c51.w
mad r1.x, r1, c60.y, c60.z
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r1.x
mov_pp oC0.z, r0.y

"
}

}

		}

//// THIS IS THE SECOND SET OF SHADERS THAT USE SMART REFINEMENT

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 compose sky with NO cloud layer
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 2 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 1 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[30] = { program.local[0..19],
		{ 0, 2, -1, -1000000 },
		{ 1, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.995 },
		{ 0.63999999, 0, 210, 0.25 },
		{ 0.075300001, -0.2543, 1.1892, 256 },
		{ 2.5651, -1.1665, -0.39860001, 400 },
		{ -1.0217, 1.9777, 0.043900002, 255 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.0009765625 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 } };
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
SHORT OUTPUT oCol = result.color;
MOVR  R2.xyz, c[5];
MOVR  R4.x, c[20].w;
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[20].y, -R0;
MOVR  R0.z, c[20];
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[7].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[20].x;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.y, R2, R1;
MOVR  R0, c[8];
MULR  R3.z, R3.y, R3.y;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[6].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R4.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R3.y, R1;
MOVR  R0.x, c[20].w;
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.y, R0.y;
MOVR  R0.y, c[20].w;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3.x;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3, R0.z;
MOVR  R0.z, c[20].w;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.x;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.y, R0.w;
MOVR  R4.y, R0;
MOVR  R4.w, R0.z;
MOVR  R4.z, R0.x;
DP4R  R0.x, R4, c[9];
SGER  H0.x, c[20], R0;
MOVR  R0, c[14];
ADDR  R0, -R0, c[10];
MADR  R2, H0.x, R0, c[14];
MOVR  R0, c[15];
ADDR  R0, -R0, c[11];
MADR  R3, H0.x, R0, c[15];
MOVR  R0, c[16];
ADDR  R0, -R0, c[12];
MADR  R4, H0.x, R0, c[16];
MOVR  R0, c[17];
ADDR  R0, -R0, c[13];
MADR  R5, H0.x, R0, c[17];
DP4R  R0.y, R3, R3;
DP4R  R0.x, R2, R2;
DP4R  R0.z, R4, R4;
DP4R  R1.y, R3, c[21].x;
DP4R  R1.x, R2, c[21].x;
DP4R  R1.z, R4, c[21].x;
DP4R  R0.w, R5, R5;
DP4R  R1.w, R5, c[21].x;
MADR  R0, R1, R0, -R0;
ADDR  R0, R0, c[21].x;
MULR  R1.x, R0, R0.y;
MULR  R1.x, R1, R0.z;
MULR  R0.w, R1.x, R0;
DP4R  R1.x, R4, c[20].x;
DP4R  R1.y, R5, c[20].x;
MADR  R0.z, R0, R1.y, R1.x;
DP4R  R1.x, R3, c[20].x;
MADR  R0.y, R0, R0.z, R1.x;
DP4R  R0.z, R2, c[20].x;
ADDR  R1.xy, fragment.texcoord[0], c[18].xzzw;
ADDR  R1.xy, R1, c[18].zyzw;
ADDR  R1.xy, R1, -c[18].xzzw;
ADDR  R6.xy, R1, -c[18].zyzw;
ADDR  R4.xy, R6, c[18].xzzw;
ADDR  R2.xy, R4, c[18].zyzw;
TEX   R1, R2, texture[1], 2D;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R1|, H0;
MADH  H0.y, H0, c[22].x, -c[22].x;
MULR  R2.z, H0.y, c[22].y;
FRCR  R2.w, R2.z;
ADDH  H0.x, H0, c[21].z;
MULH  H0.z, H0.x, c[21].w;
SGEH  H0.xy, c[20].x, R1.ywzw;
ADDR  R6.zw, R2.xyxy, -c[18].xyxz;
MADH  H0.x, H0, c[21].y, H0.z;
FLRR  R2.z, R2;
ADDR  R1.y, H0.x, R2.z;
MULR  R2.z, R2.w, c[23].x;
MULR  R3.x, R1.y, c[22].z;
ADDR  R1.y, -R3.x, -R2.z;
RCPR  R3.y, R2.z;
TEX   R2, R6.zwzw, texture[1], 2D;
MULR  R3.x, R3, R1;
MADR  R1.y, R1, R1.x, R1.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULR  R1.y, R1, R3;
MULR  R3.w, R3.y, R3.x;
MULR  R3.xyz, R1.x, c[26];
MADR  R3.xyz, R3.w, c[25], R3;
MADR  R3.xyz, R1.y, c[24], R3;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R1.x, H0.z, c[22].y;
FRCR  R1.y, R1.x;
SGEH  H0.zw, c[20].x, R2.xyyw;
MAXR  R5.xyz, R3, c[20].x;
TEX   R3, R4, texture[1], 2D;
MULH  H0.x, H0, c[21].w;
SGEH  H1.xy, c[20].x, R3.ywzw;
MADH  H0.x, H0.z, c[21].y, H0;
FLRR  R1.x, R1;
ADDR  R1.x, H0, R1;
MULR  R2.y, R1, c[23].x;
MULR  R1.y, R1.x, c[22].z;
ADDR  R1.x, -R1.y, -R2.y;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
RCPR  R2.y, R2.y;
MADR  R1.x, R1, R2, R2;
MULR  R1.y, R1, R2.x;
MULR  R1.x, R1, R2.y;
MULR  R1.y, R2, R1;
MULR  R4.xyz, R2.x, c[26];
MADR  R4.xyz, R1.y, c[25], R4;
MADR  R4.xyz, R1.x, c[24], R4;
MAXR  R4.xyz, R4, c[20].x;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R1.x, H0.z, c[22].y;
FRCR  R2.x, R1;
MULR  R5.w, R2.x, c[23].x;
ADDR  R5.xyz, R5, -R4;
FLRR  R1.y, R1.x;
MADH  H0.x, H1, c[21].y, H0;
ADDR  R1.y, H0.x, R1;
MULR  R3.y, R1, c[22].z;
ADDR  R4.w, -R3.y, -R5;
ADDR  R1.xy, R6.zwzw, -c[18].zyzw;
MULR  R2.xy, R1, c[19];
FRCR  R2.xy, R2;
MADR  R5.xyz, R2.x, R5, R4;
MADR  R6.z, R4.w, R3.x, R3.x;
TEX   R4, R6, texture[1], 2D;
RCPR  R6.x, R5.w;
MULR  R3.y, R3, R3.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[21].z;
SGEH  H1.zw, c[20].x, R4.xyyw;
MULH  H0.x, H0, c[21].w;
MULR  R5.w, R6.z, R6.x;
MULR  R3.y, R6.x, R3;
MULR  R6.xyz, R3.x, c[26];
MADH  H0.z, H0, c[22].x, -c[22].x;
MADR  R6.xyz, R3.y, c[25], R6;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MADR  R6.xyz, R5.w, c[24], R6;
MADH  H0.x, H1.z, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R4.y, R3.x, c[22].z;
MULR  R3.y, R3, c[23].x;
ADDR  R3.x, -R4.y, -R3.y;
MULR  R4.y, R4, R4.x;
MADR  R3.x, R3, R4, R4;
RCPR  R3.y, R3.y;
MULR  R7.xyz, R4.x, c[26];
MULR  R4.x, R3.y, R4.y;
MULR  R3.x, R3, R3.y;
MADR  R7.xyz, R4.x, c[25], R7;
MADR  R7.xyz, R3.x, c[24], R7;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MAXR  R7.xyz, R7, c[20].x;
MAXR  R6.xyz, R6, c[20].x;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R2.x, R6, R7;
ADDR  R5.xyz, R5, -R6;
MADR  R5.xyz, R2.y, R5, R6;
MADH  H0.x, H1.y, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R3.y, R3, c[23].x;
MULR  R3.x, R3, c[22].z;
ADDR  R3.w, -R3.x, -R3.y;
MADR  R3.w, R3.z, R3, R3.z;
RCPR  R3.y, R3.y;
MULR  R3.x, R3.z, R3;
MULR  R3.w, R3, R3.y;
MULR  R4.x, R3.y, R3;
MULR  R3.xyz, R3.z, c[26];
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
MAXR  R6.xyz, R3, c[20].x;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MULR  R3.z, R3.y, c[23].x;
RCPR  R4.x, R3.z;
MADH  H0.x, H1.w, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
MULR  R3.x, R3, c[22].z;
ADDR  R3.y, -R3.x, -R3.z;
MADR  R3.y, R4.z, R3, R4.z;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
ADDH  H0.x, H0, c[21].z;
MULR  R3.w, R3.y, R4.x;
MULR  R4.y, R4.z, R3.x;
MULR  R2.w, H0.z, c[22].y;
MULH  H0.x, H0, c[21].w;
MADH  H0.z, H0.w, c[21].y, H0.x;
LG2H  H0.x, |R1.w|;
MULR  R3.xyz, R4.z, c[26];
MULR  R4.x, R4, R4.y;
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
FLRR  R3.w, R2;
ADDR  R3.w, H0.z, R3;
MULR  R5.w, R3, c[22].z;
MAXR  R3.xyz, R3, c[20].x;
ADDR  R4.xyz, R6, -R3;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R2.w, R2;
MULR  R6.x, R2.w, c[23];
ADDR  R4.w, -R5, -R6.x;
MULR  R6.w, R2.z, R5;
RCPR  R5.w, R6.x;
MULH  H0.z, |R1.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R1.w, H0.z, c[22].y;
FRCR  R2.w, R1;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MADR  R3.xyz, R2.x, R4, R3;
MULR  R2.w, R2, c[23].x;
MADR  R4.w, R2.z, R4, R2.z;
MULR  R6.xyz, R2.z, c[26];
MULR  R2.z, R5.w, R6.w;
MADR  R6.xyz, R2.z, c[25], R6;
MULR  R2.z, R4.w, R5.w;
MADR  R6.xyz, R2.z, c[24], R6;
MULR  R7.xyz, R1.z, c[26];
MAXR  R6.xyz, R6, c[20].x;
FLRR  R1.w, R1;
MADH  H0.x, H0.y, c[21].y, H0;
ADDR  R1.w, H0.x, R1;
MULR  R1.w, R1, c[22].z;
ADDR  R3.w, -R1, -R2;
MADR  R2.z, R1, R3.w, R1;
MULR  R3.w, R1.z, R1;
RCPR  R1.w, R2.w;
MULR  R1.z, R1.w, R3.w;
MADR  R7.xyz, R1.z, c[25], R7;
MULR  R1.z, R2, R1.w;
MADR  R7.xyz, R1.z, c[24], R7;
MAXR  R7.xyz, R7, c[20].x;
ADDR  R7.xyz, R7, -R6;
MADR  R4.xyz, R2.x, R7, R6;
ADDR  R4.xyz, R4, -R3;
ADDR  R1.z, c[4].w, -c[4];
RCPR  R1.z, R1.z;
MULR  R1.w, R1.z, c[4];
MADR  R2.xyz, R2.y, R4, R3;
TEX   R3.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R2.w, R1, -R3.x;
MOVR  R1.z, c[22].w;
RCPR  R2.w, R2.w;
MULR  R1.w, R1, c[4].z;
MULR  R1.z, R1, c[4].w;
MULR  R1.w, R1, R2;
SGTRC HC.x, R1.w, R1.z;
MADR  R0.xyz, R0.x, R0.y, R0.z;
IF    NE.x;
TEX   R1.xyz, R1, texture[2], 2D;
ELSE;
MOVR  R1.xyz, c[20].x;
ENDIF;
MULR  R2.xyz, R2, R0.w;
MADR  R0.xyz, R1, R2, R0;
ADDR  R0.xyz, R0, R5;
MULR  R1.xyz, R0.y, c[29];
MADR  R1.xyz, R0.x, c[28], R1;
MADR  R0.xyz, R0.z, c[27], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[23].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[23].z;
SGER  H0.x, R0, c[21].y;
MULH  H0.y, H0.x, c[21];
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[23].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[21];
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[21].w;
MULR  R1.xyz, R2.y, c[29];
MADR  R1.xyz, R2.x, c[28], R1;
MADR  R1.xyz, R2.z, c[27], R1;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[23];
MULR  R0.w, R0, c[25];
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[25].w;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[20].y, H0.z;
MINR  R0.z, R0, c[23];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[21].y;
MULH  H0.y, H0.z, c[21];
MINR  R0.w, R0, c[26];
MADR  R0.w, R0.x, c[24], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[21];
MADR  H0.y, R0.w, c[27].w, R0.x;
MULR  R0.w, R0.z, c[23];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[21].w;
ADDH  H0.x, H0, -c[21].z;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[26].w;
MADR  R0.y, R0.z, c[24].w, R0;
MADR  H0.z, R0.y, c[27].w, R0.x;
MADH  H0.x, H0.y, c[20].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 2 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 1 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c20, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c21, -1000000.00000000, 128.00000000, 15.00000000, 4.00000000
def c22, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c23, 0.07530000, -0.25430000, 1.18920004, 0.99500000
def c24, 2.56509995, -1.16649997, -0.39860001, 210.00000000
def c25, -1.02170002, 1.97770000, 0.04390000, -128.00000000
def c26, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c27, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c28, 0.02411880, 0.12281780, 0.84442663, 400.00000000
def c29, 255.00000000, 256.00000000, 0.00097656, 1.00000000
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c20.x, c20.y
mov r4, c13
mov r3, c12
add r6.xy, v0, c18.xzzw
add r6.xy, r6, c18.zyzw
add r6.xy, r6, -c18.xzzw
add r7.xy, r6, -c18.zyzw
add r8.xy, r7, c18.xzzw
add r6.xy, r8, c18.zyzw
mov r0.z, c20.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c20.z
dp4 r2.z, r0, c2
dp4 r2.y, r0, c1
dp4 r2.x, r0, c0
mov r0.y, c6.x
mov r0.z, c6.x
add r0.z, c8.y, r0
mov r6.z, v0.w
mov r7.z, v0.w
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r1.xyz, r1, c7.x
add r1.xyz, r1, -c5
dp3 r0.x, r2, r1
dp3 r0.w, r1, r1
mad r1.x, -r0.z, r0.z, r0.w
mad r1.y, r0.x, r0.x, -r1.x
rsq r1.z, r1.y
add r0.y, c8.x, r0
mad r0.y, -r0, r0, r0.w
mad r0.y, r0.x, r0.x, -r0
rsq r0.z, r0.y
rcp r0.z, r0.z
add r1.x, -r0, r0.z
cmp_pp r0.z, r0.y, c20.w, c20
cmp r0.y, r0, r1.w, c21.x
cmp r2.x, -r0.z, r0.y, r1
rcp r1.z, r1.z
cmp r1.x, r1.y, r1.w, c21
add r1.z, -r0.x, r1
cmp_pp r0.z, r1.y, c20.w, c20
cmp r2.y, -r0.z, r1.x, r1.z
mov r0.y, c6.x
add r0.z, c8.w, r0.y
mad r0.z, -r0, r0, r0.w
mad r1.x, r0, r0, -r0.z
mov r0.y, c6.x
add r0.y, c8.z, r0
mad r0.y, -r0, r0, r0.w
rsq r0.z, r1.x
rcp r0.w, r0.z
mad r0.y, r0.x, r0.x, -r0
add r1.y, -r0.x, r0.w
cmp_pp r0.w, r1.x, c20, c20.z
rsq r0.z, r0.y
cmp r1.x, r1, r1.w, c21
rcp r0.z, r0.z
add r0.z, -r0.x, r0
cmp_pp r0.x, r0.y, c20.w, c20.z
cmp r0.y, r0, r1.w, c21.x
cmp r2.w, -r0, r1.x, r1.y
cmp r2.z, -r0.x, r0.y, r0
dp4 r0.x, r2, c9
mov r1, c10
mov r2, c11
cmp r0.z, -r0.x, c20.w, c20
add r1, -c14, r1
mad r1, r0.z, r1, c14
add r2, -c15, r2
mad r2, r0.z, r2, c15
add r4, -c17, r4
mad r4, r0.z, r4, c17
add r3, -c16, r3
mad r3, r0.z, r3, c16
dp4 r0.x, r1, c20.w
dp4 r0.y, r2, c20.w
dp4 r0.w, r4, c20.w
dp4 r0.z, r3, c20.w
add r5, r0, c20.y
dp4 r0.x, r1, r1
dp4 r0.y, r2, r2
dp4 r0.z, r3, r3
dp4 r0.w, r4, r4
mad r5, r0, r5, c20.w
texldl r0, r6.xyzz, s1
dp4 r4.x, r4, c20.z
dp4 r3.y, r3, c20.z
abs_pp r6.z, r0.y
mul r6.w, r5.x, r5.y
mul r6.w, r6, r5.z
mul r5.w, r6, r5
log_pp r6.w, r6.z
frc_pp r4.y, r6.w
add_pp r3.x, r6.w, -r4.y
mad r3.y, r5.z, r4.x, r3
dp4 r2.x, r2, c20.z
exp_pp r3.z, -r3.x
mad_pp r2.y, r6.z, r3.z, c20
dp4 r1.x, r1, c20.z
mad r2.x, r5.y, r3.y, r2
mul_pp r2.y, r2, c22.x
mul r1.y, r2, c22
frc r1.z, r1.y
mad r5.xyz, r5.x, r2.x, r1.x
add_pp r1.x, r3, c21.z
add r4.xy, r6, -c18.xzzw
mul r2.y, r1.z, c22.w
add r1.y, r1, -r1.z
mul_pp r1.x, r1, c21.w
cmp_pp r0.y, -r0, c20.w, c20.z
mad_pp r0.y, r0, c21, r1.x
add r0.y, r0, r1
mul r2.x, r0.y, c22.z
add r0.y, -r2.x, -r2
mov r4.z, v0.w
texldl r1, r4.xyzz, s1
abs_pp r2.z, r1.y
log_pp r3.x, r2.z
add r0.y, r0, c20.w
mul r0.y, r0, r0.x
rcp r2.y, r2.y
mul r2.w, r0.y, r2.y
frc_pp r3.y, r3.x
add_pp r0.y, r3.x, -r3
mul r2.x, r2, r0
exp_pp r3.y, -r0.y
mul r3.x, r2.y, r2
mad_pp r3.y, r2.z, r3, c20
mul r2.xyz, r0.x, c25
mad r2.xyz, r3.x, c24, r2
mul_pp r0.x, r3.y, c22
mul r3.x, r0, c22.y
mad r2.xyz, r2.w, c23, r2
frc r2.w, r3.x
add_pp r0.x, r0.y, c21.z
mul_pp r0.y, r0.x, c21.w
cmp_pp r0.x, -r1.y, c20.w, c20.z
mad_pp r0.x, r0, c21.y, r0.y
add r3.x, r3, -r2.w
add r0.x, r0, r3
mul r0.y, r2.w, c22.w
mul r0.x, r0, c22.z
add r1.y, -r0.x, -r0
add r1.y, r1, c20.w
mul r0.x, r0, r1
mul r1.y, r1, r1.x
rcp r3.w, r0.y
mul r1.y, r1, r3.w
mul r3.w, r3, r0.x
mul r6.xyz, r1.x, c25
mad r6.xyz, r3.w, c24, r6
mad r6.xyz, r1.y, c23, r6
max r6.xyz, r6, c20.z
max r3.xyz, r2, c20.z
mov r8.z, v0.w
texldl r2, r8.xyzz, s1
abs_pp r0.y, r2
log_pp r4.z, r0.y
frc_pp r4.w, r4.z
add_pp r0.x, r4.z, -r4.w
exp_pp r1.x, -r0.x
mad_pp r0.y, r0, r1.x, c20
add_pp r0.x, r0, c21.z
mul_pp r0.y, r0, c22.x
mul r0.y, r0, c22
frc r3.w, r0.y
add r3.xyz, r3, -r6
add r4.z, r0.y, -r3.w
mul_pp r1.y, r0.x, c21.w
cmp_pp r1.x, -r2.y, c20.w, c20.z
mad_pp r2.y, r1.x, c21, r1
add r2.y, r2, r4.z
add r0.xy, r4, -c18.zyzw
mul r4.w, r2.y, c22.z
mul r1.xy, r0, c19
frc r1.xy, r1
mad r4.xyz, r1.x, r3, r6
mul r2.y, r3.w, c22.w
add r6.x, -r4.w, -r2.y
add r6.y, r6.x, c20.w
texldl r3, r7.xyzz, s1
abs_pp r6.x, r3.y
mul r6.y, r6, r2.x
rcp r6.z, r2.y
log_pp r7.x, r6.x
mul r4.w, r4, r2.x
frc_pp r2.y, r7.x
mul r6.w, r6.y, r6.z
add_pp r2.y, r7.x, -r2
exp_pp r6.y, -r2.y
mul r4.w, r6.z, r4
mad_pp r7.x, r6, r6.y, c20.y
mul r6.xyz, r2.x, c25
mul_pp r2.x, r7, c22
mad r6.xyz, r4.w, c24, r6
mul r4.w, r2.x, c22.y
mad r6.xyz, r6.w, c23, r6
frc r2.x, r4.w
add r6.w, r4, -r2.x
add_pp r2.y, r2, c21.z
mul_pp r4.w, r2.y, c21
cmp_pp r2.y, -r3, c20.w, c20.z
mad_pp r2.y, r2, c21, r4.w
mul r3.y, r2.x, c22.w
add r2.y, r2, r6.w
mul r2.x, r2.y, c22.z
add r2.y, -r2.x, -r3
add r2.y, r2, c20.w
mul r2.y, r2, r3.x
rcp r4.w, r3.y
mul r3.y, r2, r4.w
mul r2.x, r2, r3
abs_pp r2.y, r0.w
mul r4.w, r4, r2.x
mul r7.xyz, r3.x, c25
log_pp r2.x, r2.y
frc_pp r3.x, r2
add_pp r2.x, r2, -r3
exp_pp r3.x, -r2.x
mad_pp r2.y, r2, r3.x, c20
mad r7.xyz, r4.w, c24, r7
mad r7.xyz, r3.y, c23, r7
abs_pp r3.y, r1.w
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.x, r2.y
add_pp r2.x, r2, c21.z
add r2.y, r2, -r3.x
log_pp r4.w, r3.y
max r7.xyz, r7, c20.z
max r6.xyz, r6, c20.z
add r6.xyz, r6, -r7
mad r6.xyz, r1.x, r6, r7
add r4.xyz, r4, -r6
mad r4.xyz, r1.y, r4, r6
frc_pp r6.x, r4.w
mul_pp r2.x, r2, c21.w
cmp_pp r0.w, -r0, c20, c20.z
mad_pp r0.w, r0, c21.y, r2.x
add r0.w, r0, r2.y
mul r2.y, r3.x, c22.w
mul r2.x, r0.w, c22.z
add r0.w, -r2.x, -r2.y
add r0.w, r0, c20
rcp r3.x, r2.y
mul r0.w, r0.z, r0
mul r2.y, r0.w, r3.x
add_pp r0.w, r4, -r6.x
mul r2.x, r0.z, r2
mul r2.x, r3, r2
exp_pp r4.w, -r0.w
mul r6.xyz, r0.z, c25
mad_pp r3.x, r3.y, r4.w, c20.y
mad r6.xyz, r2.x, c24, r6
mul_pp r0.z, r3.x, c22.x
mul r2.x, r0.z, c22.y
mad r6.xyz, r2.y, c23, r6
frc r2.y, r2.x
add_pp r0.z, r0.w, c21
mul_pp r0.w, r0.z, c21
cmp_pp r0.z, -r1.w, c20.w, c20
mad_pp r0.z, r0, c21.y, r0.w
add r2.x, r2, -r2.y
add r0.z, r0, r2.x
mul r0.w, r2.y, c22
mul r0.z, r0, c22
add r1.w, -r0.z, -r0
max r7.xyz, r6, c20.z
rcp r2.x, r0.w
add r1.w, r1, c20
mul r0.w, r1.z, r1
mul r1.w, r0, r2.x
mul r0.w, r1.z, r0.z
mul r0.w, r2.x, r0
abs_pp r0.z, r3.w
mul r6.xyz, r1.z, c25
log_pp r2.x, r0.z
mad r6.xyz, r0.w, c24, r6
mad r6.xyz, r1.w, c23, r6
frc_pp r1.z, r2.x
add_pp r0.w, r2.x, -r1.z
exp_pp r1.z, -r0.w
mad_pp r0.z, r0, r1, c20.y
max r6.xyz, r6, c20.z
mul_pp r0.z, r0, c22.x
mul r2.x, r0.z, c22.y
abs_pp r1.w, r2
frc r1.z, r2.x
log_pp r0.z, r1.w
frc_pp r2.y, r0.z
add_pp r0.z, r0, -r2.y
add_pp r2.y, r0.w, c21.z
exp_pp r0.w, -r0.z
mul_pp r3.x, r2.y, c21.w
mad_pp r0.w, r1, r0, c20.y
add r7.xyz, r7, -r6
cmp_pp r2.y, -r3.w, c20.w, c20.z
mul_pp r0.w, r0, c22.x
mad_pp r2.y, r2, c21, r3.x
add r2.x, r2, -r1.z
add r2.x, r2.y, r2
mul r1.w, r2.x, c22.z
mul r2.x, r1.z, c22.w
mul r0.w, r0, c22.y
add r2.y, -r1.w, -r2.x
frc r1.z, r0.w
add r3.x, r0.w, -r1.z
add_pp r0.z, r0, c21
mul_pp r0.w, r0.z, c21
cmp_pp r0.z, -r2.w, c20.w, c20
mad_pp r0.z, r0, c21.y, r0.w
add r0.z, r0, r3.x
mul r2.w, r3.z, r1
rcp r1.w, r2.x
add r2.y, r2, c20.w
mul r2.y, r3.z, r2
mul r2.x, r1.w, r2.w
mul r3.xyz, r3.z, c25
mul r0.w, r0.z, c22.z
mul r1.z, r1, c22.w
add r0.z, -r0.w, -r1
add r0.z, r0, c20.w
mul r1.w, r2.y, r1
mad r3.xyz, r2.x, c24, r3
mad r3.xyz, r1.w, c23, r3
mul r1.w, r2.z, r0
rcp r0.w, r1.z
mul r0.z, r2, r0
mul r1.z, r0.w, r1.w
mul r2.xyz, r2.z, c25
mul r0.z, r0, r0.w
mad r2.xyz, r1.z, c24, r2
mad r2.xyz, r0.z, c23, r2
add r0.z, c4.w, -c4
rcp r0.z, r0.z
max r3.xyz, r3, c20.z
max r2.xyz, r2, c20.z
add r2.xyz, r2, -r3
mad r2.xyz, r1.x, r2, r3
mad r6.xyz, r1.x, r7, r6
mul r0.w, r0.z, c4
texldl r1.x, v0, s0
add r0.z, r0.w, -r1.x
rcp r1.w, r0.z
add r3.xyz, r6, -r2
mul r0.w, r0, c4.z
mov r0.z, c4.w
mul r0.w, r0, r1
mul r1.w, c23, r0.z
mad r1.xyz, r1.y, r3, r2
mov r0.z, v0.w
if_gt r0.w, r1.w
texldl r0.xyz, r0.xyzz, s2
else
mov r0.xyz, c20.z
endif
mul r1.xyz, r1, r5.w
mad r0.xyz, r0, r1, r5
add r0.xyz, r0, r4
mul r2.xyz, r0.y, c26
mad r2.xyz, r0.x, c27, r2
mad r0.xyz, r0.z, c28, r2
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
mul r3.xyz, r1.y, c26
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c24.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c24.w
add r0.z, r0.x, c25.w
cmp r0.z, r0, c20.w, c20
mul_pp r1.w, r0.z, c21.y
add r1.w, r0.x, -r1
mul r0.x, r1.w, c26.w
frc r2.x, r0
add r2.x, r0, -r2
add_pp r0.x, r2, c27.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c20, c20.w
mad r3.xyz, r1.x, c27, r3
mad r1.xyz, r1.z, c28, r3
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.x, c21.w
mul_pp r0.x, r0, r2.y
mul r2.xy, r1, r1.z
mul r0.w, r0, c28
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c24.w
min r0.w, r0, c29.x
mad r0.z, r0, c29.y, r0.w
mad r0.z, r0, c29, c29.w
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c24.w
add r1.z, r1.x, c25.w
cmp r0.w, r1.z, c20, c20.z
mul_pp r1.z, r0.w, c21.y
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c28.w
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c26.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c21.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c29
mad r0.z, r0.x, c29.y, r1.x
add_pp r0.x, r0.y, c27.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c20, c20.w
mad r0.z, r0, c29, c29.w
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 compose sky with 1 cloud layer
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 1 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 3 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 2 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[30] = { program.local[0..19],
		{ 1, 0, 2, -1 },
		{ -1000000, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.995 },
		{ 0.63999999, 0, 210, 0.25 },
		{ 0.075300001, -0.2543, 1.1892, 256 },
		{ 2.5651, -1.1665, -0.39860001, 400 },
		{ -1.0217, 1.9777, 0.043900002, 255 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.0009765625 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
TEMP R8;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[5];
MOVR  R4.x, c[21];
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[20].z, -R0;
MOVR  R0.z, c[20].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[7].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[20].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.y, R2, R1;
MOVR  R0, c[8];
MULR  R3.z, R3.y, R3.y;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[6].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R4.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R3.y, R1;
MOVR  R0.x, c[21];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.y, R0.y;
MOVR  R0.y, c[21].x;
MOVXC RC.y, R2;
MOVXC RC.z, R2.w;
MOVR  R2, c[16];
MOVR  R0.y(EQ), R3.x;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3, R0.z;
MOVR  R0.z, c[21].x;
MOVR  R0.z(EQ), R3.x;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.y, R0.w;
MOVR  R4.y, R0;
MOVR  R4.w, R0.z;
MOVR  R4.z, R0.x;
DP4R  R0.x, R4, c[9];
SGER  H0.x, c[20].y, R0;
ADDR  R2, -R2, c[12];
MADR  R5, H0.x, R2, c[16];
MOVR  R0, c[15];
ADDR  R0, -R0, c[11];
MADR  R4, H0.x, R0, c[15];
MOVR  R0, c[14];
ADDR  R0, -R0, c[10];
MADR  R3, H0.x, R0, c[14];
MOVR  R2, c[17];
ADDR  R2, -R2, c[13];
MADR  R6, H0.x, R2, c[17];
MOVR  R0.yzw, c[20].x;
MOVR  R0.x, R8.w;
DP4R  R1.x, R0, R3;
DP4R  R1.w, R0, R6;
DP4R  R1.y, R0, R4;
DP4R  R1.z, R0, R5;
DP4R  R0.x, R3, R3;
DP4R  R0.w, R6, R6;
MOVR  R2.yzw, c[20].y;
MOVR  R2.x, R8;
DP4R  R8.x, R6, R2;
DP4R  R0.y, R4, R4;
DP4R  R0.z, R5, R5;
MADR  R0, R1, R0, -R0;
ADDR  R7, R0, c[20].x;
MULR  R0.x, R7, R7.y;
MULR  R8.w, R0.x, R7.z;
MOVR  R1.yzw, c[20].y;
MOVR  R1.x, R8.y;
DP4R  R8.y, R6, R1;
MOVR  R0.yzw, c[20].y;
MOVR  R0.x, R8.z;
DP4R  R8.z, R6, R0;
DP4R  R6.x, R5, R2;
DP4R  R6.z, R5, R0;
DP4R  R6.y, R5, R1;
MADR  R5.xyz, R7.z, R8, R6;
DP4R  R6.x, R4, R2;
DP4R  R2.x, R3, R2;
DP4R  R2.z, R3, R0;
DP4R  R6.z, R4, R0;
DP4R  R6.y, R4, R1;
DP4R  R2.y, R3, R1;
MADR  R4.xyz, R7.y, R5, R6;
ADDR  R0.xy, fragment.texcoord[0], c[18].xzzw;
ADDR  R0.xy, R0, c[18].zyzw;
ADDR  R0.xy, R0, -c[18].xzzw;
MADR  R1.xyz, R7.x, R4, R2;
ADDR  R6.xy, R0, -c[18].zyzw;
ADDR  R4.xy, R6, c[18].xzzw;
ADDR  R2.xy, R4, c[18].zyzw;
TEX   R0, R2, texture[2], 2D;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R0|, H0;
MADH  H0.y, H0, c[22].x, -c[22].x;
MULR  R2.z, H0.y, c[22].y;
FRCR  R2.w, R2.z;
ADDH  H0.x, H0, c[21].z;
MULH  H0.z, H0.x, c[21].w;
SGEH  H0.xy, c[20].y, R0.ywzw;
ADDR  R6.zw, R2.xyxy, -c[18].xyxz;
MADH  H0.x, H0, c[21].y, H0.z;
FLRR  R2.z, R2;
ADDR  R0.y, H0.x, R2.z;
MULR  R2.z, R2.w, c[23].x;
MULR  R3.x, R0.y, c[22].z;
ADDR  R0.y, -R3.x, -R2.z;
RCPR  R3.y, R2.z;
TEX   R2, R6.zwzw, texture[2], 2D;
MULR  R3.x, R3, R0;
MADR  R0.y, R0, R0.x, R0.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULR  R0.y, R0, R3;
MULR  R3.w, R3.y, R3.x;
MULR  R3.xyz, R0.x, c[26];
MADR  R3.xyz, R3.w, c[25], R3;
MADR  R3.xyz, R0.y, c[24], R3;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R0.y, R0.x;
SGEH  H0.zw, c[20].y, R2.xyyw;
MAXR  R5.xyz, R3, c[20].y;
TEX   R3, R4, texture[2], 2D;
MULH  H0.x, H0, c[21].w;
SGEH  H1.xy, c[20].y, R3.ywzw;
MADH  H0.x, H0.z, c[21].y, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R2.y, R0, c[23].x;
MULR  R0.y, R0.x, c[22].z;
ADDR  R0.x, -R0.y, -R2.y;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
RCPR  R2.y, R2.y;
MADR  R0.x, R0, R2, R2;
MULR  R0.y, R0, R2.x;
MULR  R0.x, R0, R2.y;
MULR  R0.y, R2, R0;
MULR  R4.xyz, R2.x, c[26];
MADR  R4.xyz, R0.y, c[25], R4;
MADR  R4.xyz, R0.x, c[24], R4;
MAXR  R4.xyz, R4, c[20].y;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R2.x, R0;
MULR  R5.w, R2.x, c[23].x;
ADDR  R5.xyz, R5, -R4;
FLRR  R0.y, R0.x;
MADH  H0.x, H1, c[21].y, H0;
ADDR  R0.y, H0.x, R0;
MULR  R3.y, R0, c[22].z;
ADDR  R4.w, -R3.y, -R5;
ADDR  R0.xy, R6.zwzw, -c[18].zyzw;
MULR  R2.xy, R0, c[19];
FRCR  R2.xy, R2;
MADR  R5.xyz, R2.x, R5, R4;
MADR  R6.z, R4.w, R3.x, R3.x;
TEX   R4, R6, texture[2], 2D;
RCPR  R6.x, R5.w;
MULR  R3.y, R3, R3.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[21].z;
SGEH  H1.zw, c[20].y, R4.xyyw;
MULH  H0.x, H0, c[21].w;
MULR  R5.w, R6.z, R6.x;
MULR  R3.y, R6.x, R3;
MULR  R6.xyz, R3.x, c[26];
MADH  H0.z, H0, c[22].x, -c[22].x;
MADR  R6.xyz, R3.y, c[25], R6;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MADR  R6.xyz, R5.w, c[24], R6;
MADH  H0.x, H1.z, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R4.y, R3.x, c[22].z;
MULR  R3.y, R3, c[23].x;
ADDR  R3.x, -R4.y, -R3.y;
MULR  R4.y, R4, R4.x;
MADR  R3.x, R3, R4, R4;
RCPR  R3.y, R3.y;
MULR  R7.xyz, R4.x, c[26];
MULR  R4.x, R3.y, R4.y;
MULR  R3.x, R3, R3.y;
MADR  R7.xyz, R4.x, c[25], R7;
MADR  R7.xyz, R3.x, c[24], R7;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MAXR  R7.xyz, R7, c[20].y;
MAXR  R6.xyz, R6, c[20].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R2.x, R6, R7;
ADDR  R5.xyz, R5, -R6;
MADR  R5.xyz, R2.y, R5, R6;
MADH  H0.x, H1.y, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R3.y, R3, c[23].x;
MULR  R3.x, R3, c[22].z;
ADDR  R3.w, -R3.x, -R3.y;
MADR  R3.w, R3.z, R3, R3.z;
RCPR  R3.y, R3.y;
MULR  R3.x, R3.z, R3;
MULR  R3.w, R3, R3.y;
MULR  R4.x, R3.y, R3;
MULR  R3.xyz, R3.z, c[26];
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
MAXR  R6.xyz, R3, c[20].y;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MULR  R3.z, R3.y, c[23].x;
RCPR  R4.x, R3.z;
MADH  H0.x, H1.w, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
MULR  R3.x, R3, c[22].z;
ADDR  R3.y, -R3.x, -R3.z;
MADR  R3.y, R4.z, R3, R4.z;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
ADDH  H0.x, H0, c[21].z;
MULR  R3.w, R3.y, R4.x;
MULR  R4.y, R4.z, R3.x;
MULR  R2.w, H0.z, c[22].y;
MULH  H0.x, H0, c[21].w;
MADH  H0.z, H0.w, c[21].y, H0.x;
LG2H  H0.x, |R0.w|;
MULR  R3.xyz, R4.z, c[26];
MULR  R4.x, R4, R4.y;
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
FLRR  R3.w, R2;
ADDR  R3.w, H0.z, R3;
MULR  R5.w, R3, c[22].z;
MAXR  R3.xyz, R3, c[20].y;
ADDR  R4.xyz, R6, -R3;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R2.w, R2;
MULR  R6.x, R2.w, c[23];
ADDR  R4.w, -R5, -R6.x;
MULR  R6.w, R2.z, R5;
RCPR  R5.w, R6.x;
MULH  H0.z, |R0.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.w, H0.z, c[22].y;
FRCR  R2.w, R0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MADR  R3.xyz, R2.x, R4, R3;
MULR  R2.w, R2, c[23].x;
MADR  R4.w, R2.z, R4, R2.z;
MULR  R6.xyz, R2.z, c[26];
MULR  R2.z, R5.w, R6.w;
MADR  R6.xyz, R2.z, c[25], R6;
MULR  R2.z, R4.w, R5.w;
MADR  R6.xyz, R2.z, c[24], R6;
MULR  R7.xyz, R0.z, c[26];
MAXR  R6.xyz, R6, c[20].y;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[21].y, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[22].z;
ADDR  R3.w, -R0, -R2;
MADR  R2.z, R0, R3.w, R0;
MULR  R3.w, R0.z, R0;
RCPR  R0.w, R2.w;
MULR  R0.z, R0.w, R3.w;
MADR  R7.xyz, R0.z, c[25], R7;
MULR  R0.z, R2, R0.w;
MADR  R7.xyz, R0.z, c[24], R7;
MAXR  R7.xyz, R7, c[20].y;
ADDR  R7.xyz, R7, -R6;
MADR  R4.xyz, R2.x, R7, R6;
ADDR  R4.xyz, R4, -R3;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.w, R0.z, c[4];
MADR  R2.xyz, R2.y, R4, R3;
TEX   R3.x, fragment.texcoord[0], texture[1], 2D;
ADDR  R2.w, R0, -R3.x;
MOVR  R0.z, c[22].w;
RCPR  R2.w, R2.w;
MULR  R0.w, R0, c[4].z;
MULR  R0.z, R0, c[4].w;
MULR  R0.w, R0, R2;
SGTRC HC.x, R0.w, R0.z;
MULR  R1.w, R8, R7;
IF    NE.x;
TEX   R0.xyz, R0, texture[3], 2D;
ELSE;
MOVR  R0.xyz, c[20].y;
ENDIF;
MULR  R2.xyz, R2, R1.w;
MADR  R0.xyz, R0, R2, R1;
ADDR  R0.xyz, R0, R5;
MULR  R1.xyz, R0.y, c[29];
MADR  R1.xyz, R0.x, c[28], R1;
MADR  R0.xyz, R0.z, c[27], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[23].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[23].z;
SGER  H0.x, R0, c[21].y;
MULH  H0.y, H0.x, c[21];
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[23].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[21];
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[21].w;
MULR  R1.xyz, R2.y, c[29];
MADR  R1.xyz, R2.x, c[28], R1;
MADR  R1.xyz, R2.z, c[27], R1;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[23];
MULR  R0.w, R0, c[25];
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[25].w;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[20].z, H0.z;
MINR  R0.z, R0, c[23];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[21].y;
MULH  H0.y, H0.z, c[21];
MINR  R0.w, R0, c[26];
MADR  R0.w, R0.x, c[24], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[20];
MADR  H0.y, R0.w, c[27].w, R0.x;
MULR  R0.w, R0.z, c[23];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[21].w;
ADDH  H0.x, H0, -c[21].z;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[26].w;
MADR  R0.y, R0.z, c[24].w, R0;
MADR  H0.z, R0.y, c[27].w, R0.x;
MADH  H0.x, H0.y, c[20].z, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 1 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 3 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 2 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c20, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c21, -1000000.00000000, 128.00000000, 15.00000000, 4.00000000
def c22, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c23, 0.07530000, -0.25430000, 1.18920004, 0.99500000
def c24, 2.56509995, -1.16649997, -0.39860001, 210.00000000
def c25, -1.02170002, 1.97770000, 0.04390000, -128.00000000
def c26, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c27, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c28, 0.02411880, 0.12281780, 0.84442663, 400.00000000
def c29, 255.00000000, 256.00000000, 0.00097656, 1.00000000
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c20.x, c20.y
mov r5, c13
texldl r8, v0, s0
add r9.xy, v0, c18.xzzw
mov r0.z, c20.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.y, r0.w
mul r0.xyz, r1.y, r0
mov r0.w, c20.z
dp4 r3.z, r0, c2
dp4 r3.y, r0, c1
dp4 r3.x, r0, c0
mov r0.x, c6
mov r0.y, c6.x
add r0.y, c8, r0
add r5, -c17, r5
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c7.x
add r2.xyz, r2, -c5
dp3 r1.y, r2, r2
add r0.x, c8, r0
dp3 r0.z, r3, r2
mad r0.w, -r0.y, r0.y, r1.y
mad r1.z, r0, r0, -r0.w
mad r0.x, -r0, r0, r1.y
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c20.w, c20.z
cmp r0.x, r0, r1, c21
cmp r0.x, -r0.y, r0, r0.w
rsq r1.w, r1.z
cmp_pp r0.y, r1.z, c20.w, c20.z
rcp r1.w, r1.w
cmp r1.z, r1, r1.x, c21.x
add r1.w, -r0.z, r1
cmp r0.y, -r0, r1.z, r1.w
mov r0.w, c6.x
add r1.z, c8.w, r0.w
mad r1.z, -r1, r1, r1.y
mad r1.w, r0.z, r0.z, -r1.z
rsq r1.z, r1.w
rcp r1.z, r1.z
mov r0.w, c6.x
add r0.w, c8.z, r0
mad r0.w, -r0, r0, r1.y
mad r1.y, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.z
rsq r0.w, r1.y
rcp r1.z, r0.w
add r1.z, -r0, r1
cmp_pp r0.w, r1, c20, c20.z
cmp r1.w, r1, r1.x, c21.x
cmp r0.w, -r0, r1, r2.x
mov r2, c11
cmp r1.x, r1.y, r1, c21
cmp_pp r0.z, r1.y, c20.w, c20
cmp r0.z, -r0, r1.x, r1
dp4 r0.x, r0, c9
cmp r1.z, -r0.x, c20.w, c20
add r2, -c15, r2
mad r4, r1.z, r2, c15
mov r0, c10
add r0, -c14, r0
mad r3, r1.z, r0, c14
mov r2, c12
mad r6, r1.z, r5, c17
add r2, -c16, r2
mad r5, r1.z, r2, c16
mov r0.yzw, c20.w
mov r0.x, r8.w
dp4 r1.x, r3, r0
dp4 r1.w, r6, r0
dp4 r1.y, r4, r0
dp4 r1.z, r5, r0
dp4 r0.x, r3, r3
dp4 r0.w, r6, r6
mov r2.yzw, c20.z
mov r2.x, r8
dp4 r8.x, r6, r2
dp4 r0.y, r4, r4
dp4 r0.z, r5, r5
add r1, r1, c20.y
mad r7, r0, r1, c20.w
mov r1.yzw, c20.z
mov r1.x, r8.y
dp4 r8.y, r6, r1
mov r0.yzw, c20.z
mov r0.x, r8.z
dp4 r8.z, r6, r0
dp4 r6.x, r5, r2
dp4 r6.y, r5, r1
dp4 r6.z, r5, r0
add r5.xy, r9, c18.zyzw
mad r6.xyz, r7.z, r8, r6
dp4 r9.x, r4, r2
dp4 r2.x, r3, r2
add r5.xy, r5, -c18.xzzw
add r10.xy, r5, -c18.zyzw
add r11.xy, r10, c18.xzzw
dp4 r2.y, r3, r1
dp4 r9.y, r4, r1
dp4 r9.z, r4, r0
mad r4.xyz, r7.y, r6, r9
add r8.xy, r11, c18.zyzw
mov r8.z, v0.w
texldl r5, r8.xyzz, s2
abs_pp r4.w, r5.y
log_pp r6.x, r4.w
frc_pp r2.z, r6.x
add_pp r1.x, r6, -r2.z
dp4 r2.z, r3, r0
mad r0.xyz, r7.x, r4, r2
exp_pp r0.w, -r1.x
mad_pp r1.y, r4.w, r0.w, c20
mul r0.w, r7.x, r7.y
mul r0.w, r0, r7.z
mul_pp r1.y, r1, c22.x
mul r1.y, r1, c22
frc r1.z, r1.y
add r1.w, r1.y, -r1.z
add_pp r1.x, r1, c21.z
mul_pp r1.y, r1.x, c21.w
cmp_pp r1.x, -r5.y, c20.w, c20.z
mad_pp r1.x, r1, c21.y, r1.y
add r1.x, r1, r1.w
mul r2.y, r1.z, c22.w
mul r2.x, r1, c22.z
add r2.z, -r2.x, -r2.y
add r2.z, r2, c20.w
mul r2.z, r2, r5.x
rcp r2.y, r2.y
mul r2.w, r2.z, r2.y
mul r2.x, r2, r5
add r4.xy, r8, -c18.xzzw
mov r4.z, v0.w
texldl r1, r4.xyzz, s2
abs_pp r3.y, r1
log_pp r3.x, r3.y
frc_pp r3.z, r3.x
add_pp r3.z, r3.x, -r3
exp_pp r2.z, -r3.z
mad_pp r3.y, r3, r2.z, c20
mul r3.x, r2.y, r2
mul r2.xyz, r5.x, c25
mad r2.xyz, r3.x, c24, r2
mad r2.xyz, r2.w, c23, r2
mul_pp r3.y, r3, c22.x
mul r3.x, r3.y, c22.y
frc r3.y, r3.x
add_pp r2.w, r3.z, c21.z
mul r3.w, r3.y, c22
add r3.x, r3, -r3.y
mul_pp r2.w, r2, c21
cmp_pp r1.y, -r1, c20.w, c20.z
mad_pp r1.y, r1, c21, r2.w
add r1.y, r1, r3.x
mul r1.y, r1, c22.z
add r2.w, -r1.y, -r3
max r3.xyz, r2, c20.z
add r2.x, r2.w, c20.w
mul r1.y, r1, r1.x
mul r4.z, r2.x, r1.x
rcp r3.w, r3.w
mul r4.z, r4, r3.w
mov r11.z, v0.w
texldl r2, r11.xyzz, s2
abs_pp r4.w, r2.y
log_pp r5.x, r4.w
mul r3.w, r3, r1.y
frc_pp r5.y, r5.x
mul r6.xyz, r1.x, c25
add_pp r1.y, r5.x, -r5
exp_pp r1.x, -r1.y
mad r6.xyz, r3.w, c24, r6
mad_pp r1.x, r4.w, r1, c20.y
mad r6.xyz, r4.z, c23, r6
max r6.xyz, r6, c20.z
mul_pp r1.x, r1, c22
mul r4.z, r1.x, c22.y
frc r3.w, r4.z
add r3.xyz, r3, -r6
add r4.w, r4.z, -r3
add_pp r1.x, r1.y, c21.z
mul_pp r4.z, r1.x, c21.w
cmp_pp r2.y, -r2, c20.w, c20.z
mad_pp r2.y, r2, c21, r4.z
add r1.xy, r4, -c18.zyzw
mul r4.xy, r1, c19
frc r5.xy, r4
mad r4.xyz, r5.x, r3, r6
add r2.y, r2, r4.w
mul r6.x, r2.y, c22.z
mul r2.y, r3.w, c22.w
add r4.w, -r6.x, -r2.y
mov r10.z, v0.w
texldl r3, r10.xyzz, s2
abs_pp r6.z, r3.y
add r4.w, r4, c20
log_pp r6.w, r6.z
rcp r6.y, r2.y
mul r4.w, r4, r2.x
frc_pp r2.y, r6.w
add_pp r2.y, r6.w, -r2
mul r6.x, r6, r2
exp_pp r7.x, -r2.y
mul r4.w, r4, r6.y
mul r6.w, r6.y, r6.x
mad_pp r7.x, r6.z, r7, c20.y
mul r6.xyz, r2.x, c25
mul_pp r2.x, r7, c22
mad r6.xyz, r6.w, c24, r6
mul r6.w, r2.x, c22.y
mad r6.xyz, r4.w, c23, r6
frc r4.w, r6
add_pp r2.x, r2.y, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r3.y, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r6.w, r6, -r4
mul r2.y, r4.w, c22.w
add r2.x, r2, r6.w
mul r2.x, r2, c22.z
add r3.y, -r2.x, -r2
rcp r4.w, r2.y
mul r2.x, r2, r3
add r3.y, r3, c20.w
mul r2.y, r3, r3.x
mul r3.y, r2, r4.w
abs_pp r2.y, r5.w
mul r2.x, r4.w, r2
mul r7.xyz, r3.x, c25
log_pp r4.w, r2.y
mad r7.xyz, r2.x, c24, r7
frc_pp r3.x, r4.w
add_pp r2.x, r4.w, -r3
exp_pp r3.x, -r2.x
mad_pp r2.y, r2, r3.x, c20
mad r7.xyz, r3.y, c23, r7
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.x, r2.y
add r3.y, r2, -r3.x
add_pp r2.x, r2, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r5.w, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r2.x, r2, r3.y
abs_pp r3.y, r1.w
log_pp r4.w, r3.y
frc_pp r5.w, r4
add_pp r4.w, r4, -r5
max r7.xyz, r7, c20.z
max r6.xyz, r6, c20.z
add r6.xyz, r6, -r7
mad r6.xyz, r5.x, r6, r7
add r4.xyz, r4, -r6
mad r4.xyz, r5.y, r4, r6
mul r2.y, r3.x, c22.w
mul r2.x, r2, c22.z
add r3.x, -r2, -r2.y
add r3.x, r3, c20.w
rcp r2.y, r2.y
mul r3.x, r5.z, r3
mul r2.x, r5.z, r2
mul r3.x, r3, r2.y
mul r2.x, r2.y, r2
exp_pp r5.w, -r4.w
mad_pp r2.y, r3, r5.w, c20
mul r6.xyz, r5.z, c25
mad r6.xyz, r2.x, c24, r6
mad r6.xyz, r3.x, c23, r6
add_pp r2.x, r4.w, c21.z
max r7.xyz, r6, c20.z
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.x, r2.y
add r2.y, r2, -r3.x
mul_pp r2.x, r2, c21.w
cmp_pp r1.w, -r1, c20, c20.z
mad_pp r1.w, r1, c21.y, r2.x
mul r2.x, r3, c22.w
add r1.w, r1, r2.y
mul r1.w, r1, c22.z
add r2.y, -r1.w, -r2.x
rcp r3.x, r2.x
add r2.y, r2, c20.w
mul r2.x, r1.z, r2.y
mul r1.w, r1.z, r1
mul r2.x, r2, r3
abs_pp r2.y, r3.w
mul r1.w, r3.x, r1
mul r6.xyz, r1.z, c25
log_pp r3.x, r2.y
frc_pp r1.z, r3.x
mad r6.xyz, r1.w, c24, r6
add_pp r1.z, r3.x, -r1
mad r6.xyz, r2.x, c23, r6
exp_pp r1.w, -r1.z
mad_pp r1.w, r2.y, r1, c20.y
mul_pp r2.x, r1.w, c22
mul r3.x, r2, c22.y
abs_pp r1.w, r2
log_pp r2.x, r1.w
frc r3.y, r3.x
frc_pp r2.y, r2.x
add_pp r2.x, r2, -r2.y
add r4.w, r3.x, -r3.y
add_pp r2.y, r1.z, c21.z
exp_pp r1.z, -r2.x
mul_pp r3.x, r2.y, c21.w
mad_pp r1.w, r1, r1.z, c20.y
max r6.xyz, r6, c20.z
cmp_pp r2.y, -r3.w, c20.w, c20.z
mad_pp r2.y, r2, c21, r3.x
add r2.y, r2, r4.w
add r7.xyz, r7, -r6
mul r1.z, r2.y, c22
mul r3.y, r3, c22.w
mul_pp r1.w, r1, c22.x
mul r2.y, r1.w, c22
frc r3.x, r2.y
add_pp r1.w, r2.x, c21.z
mul_pp r2.x, r1.w, c21.w
cmp_pp r1.w, -r2, c20, c20.z
add r3.w, -r1.z, -r3.y
add r2.w, r3, c20
mul r3.w, r3.z, r1.z
rcp r1.z, r3.y
add r2.y, r2, -r3.x
mad_pp r1.w, r1, c21.y, r2.x
add r2.x, r1.w, r2.y
mul r1.w, r3.x, c22
mul r2.x, r2, c22.z
add r2.y, -r2.x, -r1.w
mul r2.w, r3.z, r2
mul r3.w, r1.z, r3
mul r1.z, r2.w, r1
mul r3.xyz, r3.z, c25
mad r3.xyz, r3.w, c24, r3
mad r3.xyz, r1.z, c23, r3
add r2.y, r2, c20.w
rcp r1.w, r1.w
mul r1.z, r2, r2.y
mul r2.w, r2.z, r2.x
mul r1.z, r1, r1.w
mul r2.w, r1, r2
mul r2.xyz, r2.z, c25
mad r2.xyz, r2.w, c24, r2
mad r2.xyz, r1.z, c23, r2
add r1.z, c4.w, -c4
rcp r1.z, r1.z
max r3.xyz, r3, c20.z
max r2.xyz, r2, c20.z
add r2.xyz, r2, -r3
mad r2.xyz, r5.x, r2, r3
mad r6.xyz, r5.x, r7, r6
add r3.xyz, r6, -r2
mul r1.w, r1.z, c4
texldl r5.x, v0, s1
add r1.z, r1.w, -r5.x
rcp r2.w, r1.z
mul r1.w, r1, c4.z
mov r1.z, c4.w
mul r1.w, r1, r2
mul r2.w, c23, r1.z
mul r0.w, r0, r7
mad r2.xyz, r5.y, r3, r2
mov r1.z, v0.w
if_gt r1.w, r2.w
texldl r1.xyz, r1.xyzz, s3
else
mov r1.xyz, c20.z
endif
mul r2.xyz, r2, r0.w
mad r0.xyz, r1, r2, r0
add r0.xyz, r0, r4
mul r1.xyz, r0.y, c26
mad r1.xyz, r0.x, c27, r1
mad r0.xyz, r0.z, c28, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c24.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c24.w
add r0.z, r0.x, c25.w
cmp r0.z, r0, c20.w, c20
mul_pp r1.x, r0.z, c21.y
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c26.w
frc r1.x, r0
mul r3.xyz, r2.y, c26
add r2.y, r0.x, -r1.x
mad r1.xyz, r2.x, c27, r3
mad r1.xyz, r2.z, c28, r1
add_pp r0.x, r2.y, c27.w
exp_pp r2.x, r0.x
mad_pp r0.x, -r0.z, c20, c20.w
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.y, c21.w
mul_pp r0.x, r0, r2
mul r2.xy, r1, r1.z
mul r0.w, r0, c28
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c24.w
min r0.w, r0, c29.x
mad r0.z, r0, c29.y, r0.w
mad r0.z, r0, c29, c29.w
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c24.w
add r1.z, r1.x, c25.w
cmp r0.w, r1.z, c20, c20.z
mul_pp r1.z, r0.w, c21.y
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c28.w
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c26.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c21.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c29
mad r0.z, r0.x, c29.y, r1.x
add_pp r0.x, r0.y, c27.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c20, c20.w
mad r0.z, r0, c29, c29.w
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 compose sky with 2 cloud layers
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 2 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 4 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 3 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[30] = { program.local[0..19],
		{ 1, 0, 2, -1 },
		{ -1000000, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.995 },
		{ 0.63999999, 0, 210, 0.25 },
		{ 0.075300001, -0.2543, 1.1892, 256 },
		{ 2.5651, -1.1665, -0.39860001, 400 },
		{ -1.0217, 1.9777, 0.043900002, 255 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.0009765625 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
TEMP R8;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R5, c[16];
MOVR  R6, c[17];
TEX   R8, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[5];
MOVR  R4.x, c[21];
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[20].z, -R0;
MOVR  R0.z, c[20].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[7].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[20].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.y, R2, R1;
MOVR  R0, c[8];
MULR  R3.z, R3.y, R3.y;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[6].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R4.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.w, R1.w;
RSQR  R0.z, R1.y;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R3.y, R1;
MOVR  R1.x, R8.w;
MOVR  R1.zw, c[20].x;
MOVR  R0.x, c[21];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.y, R0.y;
MOVR  R0.y, c[21].x;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3.x;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3, R0.z;
MOVR  R0.z, c[21].x;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.x;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.y, R0.w;
MOVR  R4.y, R0;
MOVR  R4.w, R0.z;
MOVR  R4.z, R0.x;
DP4R  R0.x, R4, c[9];
SGER  H0.x, c[20].y, R0;
MOVR  R0, c[15];
ADDR  R0, -R0, c[11];
MADR  R4, H0.x, R0, c[15];
MOVR  R0, c[14];
ADDR  R0, -R0, c[10];
MADR  R3, H0.x, R0, c[14];
TEX   R0, fragment.texcoord[0], texture[1], 2D;
MOVR  R1.y, R0.w;
ADDR  R5, -R5, c[12];
MADR  R5, H0.x, R5, c[16];
ADDR  R6, -R6, c[13];
MADR  R6, H0.x, R6, c[17];
DP4R  R2.x, R1, R3;
DP4R  R2.w, R1, R6;
DP4R  R2.y, R1, R4;
DP4R  R2.z, R1, R5;
DP4R  R1.x, R3, R3;
DP4R  R1.w, R6, R6;
DP4R  R1.y, R4, R4;
DP4R  R1.z, R5, R5;
MADR  R1, R2, R1, -R1;
ADDR  R7, R1, c[20].x;
MOVR  R2.y, R0.x;
MOVR  R1.y, R0;
MULR  R0.w, R7.x, R7.y;
MOVR  R2.zw, c[20].y;
MOVR  R2.x, R8;
DP4R  R8.x, R6, R2;
MOVR  R1.zw, c[20].y;
MOVR  R1.x, R8.y;
DP4R  R8.y, R6, R1;
MOVR  R0.y, R0.z;
MULR  R8.w, R0, R7.z;
MOVR  R0.x, R8.z;
MOVR  R0.zw, c[20].y;
DP4R  R8.z, R6, R0;
DP4R  R6.x, R5, R2;
DP4R  R6.z, R5, R0;
DP4R  R6.y, R5, R1;
MADR  R5.xyz, R7.z, R8, R6;
DP4R  R6.x, R4, R2;
DP4R  R2.x, R3, R2;
DP4R  R2.z, R3, R0;
DP4R  R6.z, R4, R0;
DP4R  R6.y, R4, R1;
DP4R  R2.y, R3, R1;
MADR  R4.xyz, R7.y, R5, R6;
ADDR  R0.xy, fragment.texcoord[0], c[18].xzzw;
ADDR  R0.xy, R0, c[18].zyzw;
ADDR  R0.xy, R0, -c[18].xzzw;
MADR  R1.xyz, R7.x, R4, R2;
ADDR  R6.xy, R0, -c[18].zyzw;
ADDR  R4.xy, R6, c[18].xzzw;
ADDR  R2.xy, R4, c[18].zyzw;
TEX   R0, R2, texture[3], 2D;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R0|, H0;
MADH  H0.y, H0, c[22].x, -c[22].x;
MULR  R2.z, H0.y, c[22].y;
FRCR  R2.w, R2.z;
ADDH  H0.x, H0, c[21].z;
MULH  H0.z, H0.x, c[21].w;
SGEH  H0.xy, c[20].y, R0.ywzw;
ADDR  R6.zw, R2.xyxy, -c[18].xyxz;
MADH  H0.x, H0, c[21].y, H0.z;
FLRR  R2.z, R2;
ADDR  R0.y, H0.x, R2.z;
MULR  R2.z, R2.w, c[23].x;
MULR  R3.x, R0.y, c[22].z;
ADDR  R0.y, -R3.x, -R2.z;
RCPR  R3.y, R2.z;
TEX   R2, R6.zwzw, texture[3], 2D;
MULR  R3.x, R3, R0;
MADR  R0.y, R0, R0.x, R0.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULR  R0.y, R0, R3;
MULR  R3.w, R3.y, R3.x;
MULR  R3.xyz, R0.x, c[26];
MADR  R3.xyz, R3.w, c[25], R3;
MADR  R3.xyz, R0.y, c[24], R3;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R0.y, R0.x;
SGEH  H0.zw, c[20].y, R2.xyyw;
MAXR  R5.xyz, R3, c[20].y;
TEX   R3, R4, texture[3], 2D;
MULH  H0.x, H0, c[21].w;
SGEH  H1.xy, c[20].y, R3.ywzw;
MADH  H0.x, H0.z, c[21].y, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R2.y, R0, c[23].x;
MULR  R0.y, R0.x, c[22].z;
ADDR  R0.x, -R0.y, -R2.y;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
RCPR  R2.y, R2.y;
MADR  R0.x, R0, R2, R2;
MULR  R0.y, R0, R2.x;
MULR  R0.x, R0, R2.y;
MULR  R0.y, R2, R0;
MULR  R4.xyz, R2.x, c[26];
MADR  R4.xyz, R0.y, c[25], R4;
MADR  R4.xyz, R0.x, c[24], R4;
MAXR  R4.xyz, R4, c[20].y;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R2.x, R0;
MULR  R5.w, R2.x, c[23].x;
ADDR  R5.xyz, R5, -R4;
FLRR  R0.y, R0.x;
MADH  H0.x, H1, c[21].y, H0;
ADDR  R0.y, H0.x, R0;
MULR  R3.y, R0, c[22].z;
ADDR  R4.w, -R3.y, -R5;
ADDR  R0.xy, R6.zwzw, -c[18].zyzw;
MULR  R2.xy, R0, c[19];
FRCR  R2.xy, R2;
MADR  R5.xyz, R2.x, R5, R4;
MADR  R6.z, R4.w, R3.x, R3.x;
TEX   R4, R6, texture[3], 2D;
RCPR  R6.x, R5.w;
MULR  R3.y, R3, R3.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[21].z;
SGEH  H1.zw, c[20].y, R4.xyyw;
MULH  H0.x, H0, c[21].w;
MULR  R5.w, R6.z, R6.x;
MULR  R3.y, R6.x, R3;
MULR  R6.xyz, R3.x, c[26];
MADH  H0.z, H0, c[22].x, -c[22].x;
MADR  R6.xyz, R3.y, c[25], R6;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MADR  R6.xyz, R5.w, c[24], R6;
MADH  H0.x, H1.z, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R4.y, R3.x, c[22].z;
MULR  R3.y, R3, c[23].x;
ADDR  R3.x, -R4.y, -R3.y;
MULR  R4.y, R4, R4.x;
MADR  R3.x, R3, R4, R4;
RCPR  R3.y, R3.y;
MULR  R7.xyz, R4.x, c[26];
MULR  R4.x, R3.y, R4.y;
MULR  R3.x, R3, R3.y;
MADR  R7.xyz, R4.x, c[25], R7;
MADR  R7.xyz, R3.x, c[24], R7;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MAXR  R7.xyz, R7, c[20].y;
MAXR  R6.xyz, R6, c[20].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R2.x, R6, R7;
ADDR  R5.xyz, R5, -R6;
MADR  R5.xyz, R2.y, R5, R6;
MADH  H0.x, H1.y, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R3.y, R3, c[23].x;
MULR  R3.x, R3, c[22].z;
ADDR  R3.w, -R3.x, -R3.y;
MADR  R3.w, R3.z, R3, R3.z;
RCPR  R3.y, R3.y;
MULR  R3.x, R3.z, R3;
MULR  R3.w, R3, R3.y;
MULR  R4.x, R3.y, R3;
MULR  R3.xyz, R3.z, c[26];
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
MAXR  R6.xyz, R3, c[20].y;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MULR  R3.z, R3.y, c[23].x;
RCPR  R4.x, R3.z;
MADH  H0.x, H1.w, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
MULR  R3.x, R3, c[22].z;
ADDR  R3.y, -R3.x, -R3.z;
MADR  R3.y, R4.z, R3, R4.z;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
ADDH  H0.x, H0, c[21].z;
MULR  R3.w, R3.y, R4.x;
MULR  R4.y, R4.z, R3.x;
MULR  R2.w, H0.z, c[22].y;
MULH  H0.x, H0, c[21].w;
MADH  H0.z, H0.w, c[21].y, H0.x;
LG2H  H0.x, |R0.w|;
MULR  R3.xyz, R4.z, c[26];
MULR  R4.x, R4, R4.y;
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
FLRR  R3.w, R2;
ADDR  R3.w, H0.z, R3;
MULR  R5.w, R3, c[22].z;
MAXR  R3.xyz, R3, c[20].y;
ADDR  R4.xyz, R6, -R3;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R2.w, R2;
MULR  R6.x, R2.w, c[23];
ADDR  R4.w, -R5, -R6.x;
MULR  R6.w, R2.z, R5;
RCPR  R5.w, R6.x;
MULH  H0.z, |R0.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.w, H0.z, c[22].y;
FRCR  R2.w, R0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MADR  R3.xyz, R2.x, R4, R3;
MULR  R2.w, R2, c[23].x;
MADR  R4.w, R2.z, R4, R2.z;
MULR  R6.xyz, R2.z, c[26];
MULR  R2.z, R5.w, R6.w;
MADR  R6.xyz, R2.z, c[25], R6;
MULR  R2.z, R4.w, R5.w;
MADR  R6.xyz, R2.z, c[24], R6;
MULR  R7.xyz, R0.z, c[26];
MAXR  R6.xyz, R6, c[20].y;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[21].y, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[22].z;
ADDR  R3.w, -R0, -R2;
MADR  R2.z, R0, R3.w, R0;
MULR  R3.w, R0.z, R0;
RCPR  R0.w, R2.w;
MULR  R0.z, R0.w, R3.w;
MADR  R7.xyz, R0.z, c[25], R7;
MULR  R0.z, R2, R0.w;
MADR  R7.xyz, R0.z, c[24], R7;
MAXR  R7.xyz, R7, c[20].y;
ADDR  R7.xyz, R7, -R6;
MADR  R4.xyz, R2.x, R7, R6;
ADDR  R4.xyz, R4, -R3;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.w, R0.z, c[4];
MADR  R2.xyz, R2.y, R4, R3;
TEX   R3.x, fragment.texcoord[0], texture[2], 2D;
ADDR  R2.w, R0, -R3.x;
MOVR  R0.z, c[22].w;
RCPR  R2.w, R2.w;
MULR  R0.w, R0, c[4].z;
MULR  R0.z, R0, c[4].w;
MULR  R0.w, R0, R2;
SGTRC HC.x, R0.w, R0.z;
MULR  R1.w, R8, R7;
IF    NE.x;
TEX   R0.xyz, R0, texture[4], 2D;
ELSE;
MOVR  R0.xyz, c[20].y;
ENDIF;
MULR  R2.xyz, R2, R1.w;
MADR  R0.xyz, R0, R2, R1;
ADDR  R0.xyz, R0, R5;
MULR  R1.xyz, R0.y, c[29];
MADR  R1.xyz, R0.x, c[28], R1;
MADR  R0.xyz, R0.z, c[27], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[23].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[23].z;
SGER  H0.x, R0, c[21].y;
MULH  H0.y, H0.x, c[21];
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[23].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[21];
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[21].w;
MULR  R1.xyz, R2.y, c[29];
MADR  R1.xyz, R2.x, c[28], R1;
MADR  R1.xyz, R2.z, c[27], R1;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[23];
MULR  R0.w, R0, c[25];
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[25].w;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[20].z, H0.z;
MINR  R0.z, R0, c[23];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[21].y;
MULH  H0.y, H0.z, c[21];
MINR  R0.w, R0, c[26];
MADR  R0.w, R0.x, c[24], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[20];
MADR  H0.y, R0.w, c[27].w, R0.x;
MULR  R0.w, R0.z, c[23];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[21].w;
ADDH  H0.x, H0, -c[21].z;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[26].w;
MADR  R0.y, R0.z, c[24].w, R0;
MADR  H0.z, R0.y, c[27].w, R0.x;
MADH  H0.x, H0.y, c[20].z, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 2 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 4 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 3 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c20, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c21, -1000000.00000000, 128.00000000, 15.00000000, 4.00000000
def c22, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c23, 0.07530000, -0.25430000, 1.18920004, 0.99500000
def c24, 2.56509995, -1.16649997, -0.39860001, 210.00000000
def c25, -1.02170002, 1.97770000, 0.04390000, -128.00000000
def c26, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c27, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c28, 0.02411880, 0.12281780, 0.84442663, 400.00000000
def c29, 255.00000000, 256.00000000, 0.00097656, 1.00000000
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c20.x, c20.y
mov r6, c13
mov r5, c12
texldl r8, v0, s0
add r9.xy, v0, c18.xzzw
mov r0.z, c20.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.y, r0.w
mul r0.xyz, r1.y, r0
mov r0.w, c20.z
dp4 r3.z, r0, c2
dp4 r3.y, r0, c1
dp4 r3.x, r0, c0
mov r0.x, c6
mov r0.y, c6.x
add r0.y, c8, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c7.x
add r2.xyz, r2, -c5
dp3 r1.y, r2, r2
add r0.x, c8, r0
dp3 r0.z, r3, r2
mad r0.w, -r0.y, r0.y, r1.y
mad r1.z, r0, r0, -r0.w
mad r0.x, -r0, r0, r1.y
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c20.w, c20.z
cmp r0.x, r0, r1, c21
cmp r0.x, -r0.y, r0, r0.w
rsq r1.w, r1.z
cmp_pp r0.y, r1.z, c20.w, c20.z
rcp r1.w, r1.w
cmp r1.z, r1, r1.x, c21.x
add r1.w, -r0.z, r1
cmp r0.y, -r0, r1.z, r1.w
mov r0.w, c6.x
add r1.z, c8.w, r0.w
mad r1.z, -r1, r1, r1.y
mad r1.w, r0.z, r0.z, -r1.z
rsq r1.z, r1.w
rcp r1.z, r1.z
mov r0.w, c6.x
add r0.w, c8.z, r0
mad r0.w, -r0, r0, r1.y
mad r1.y, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.z
rsq r0.w, r1.y
rcp r1.z, r0.w
add r1.z, -r0, r1
cmp_pp r0.w, r1, c20, c20.z
cmp r1.w, r1, r1.x, c21.x
cmp r0.w, -r0, r1, r2.x
cmp_pp r0.z, r1.y, c20.w, c20
cmp r1.x, r1.y, r1, c21
cmp r0.z, -r0, r1.x, r1
dp4 r0.x, r0, c9
cmp r2.z, -r0.x, c20.w, c20
mov r1, c11
add r1, -c15, r1
add r6, -c17, r6
add r5, -c16, r5
mad r6, r2.z, r6, c17
mad r4, r2.z, r1, c15
mov r0, c10
add r1, -c14, r0
mad r3, r2.z, r1, c14
texldl r0, v0, s1
mad r5, r2.z, r5, c16
mov r1.y, r0.w
mov r1.zw, c20.w
mov r1.x, r8.w
dp4 r2.x, r3, r1
dp4 r2.w, r6, r1
dp4 r2.y, r4, r1
dp4 r2.z, r5, r1
dp4 r1.x, r3, r3
dp4 r1.w, r6, r6
add r2, r2, c20.y
dp4 r1.y, r4, r4
dp4 r1.z, r5, r5
mad r7, r1, r2, c20.w
mov r2.y, r0.x
mov r1.y, r0
mov r0.y, r0.z
mov r2.zw, c20.z
mov r2.x, r8
dp4 r8.x, r6, r2
mov r1.zw, c20.z
mov r1.x, r8.y
dp4 r8.y, r6, r1
mov r0.zw, c20.z
mov r0.x, r8.z
dp4 r8.z, r6, r0
dp4 r6.x, r5, r2
dp4 r6.y, r5, r1
dp4 r6.z, r5, r0
add r5.xy, r9, c18.zyzw
mad r6.xyz, r7.z, r8, r6
dp4 r9.x, r4, r2
dp4 r2.x, r3, r2
add r5.xy, r5, -c18.xzzw
add r10.xy, r5, -c18.zyzw
add r11.xy, r10, c18.xzzw
dp4 r2.y, r3, r1
dp4 r9.y, r4, r1
dp4 r9.z, r4, r0
mad r4.xyz, r7.y, r6, r9
add r8.xy, r11, c18.zyzw
mov r8.z, v0.w
texldl r5, r8.xyzz, s3
abs_pp r4.w, r5.y
log_pp r6.x, r4.w
frc_pp r2.z, r6.x
add_pp r1.x, r6, -r2.z
dp4 r2.z, r3, r0
mad r0.xyz, r7.x, r4, r2
exp_pp r0.w, -r1.x
mad_pp r1.y, r4.w, r0.w, c20
mul r0.w, r7.x, r7.y
mul r0.w, r0, r7.z
mul_pp r1.y, r1, c22.x
mul r1.y, r1, c22
frc r1.z, r1.y
add r1.w, r1.y, -r1.z
add_pp r1.x, r1, c21.z
mul_pp r1.y, r1.x, c21.w
cmp_pp r1.x, -r5.y, c20.w, c20.z
mad_pp r1.x, r1, c21.y, r1.y
add r1.x, r1, r1.w
mul r2.y, r1.z, c22.w
mul r2.x, r1, c22.z
add r2.z, -r2.x, -r2.y
add r2.z, r2, c20.w
mul r2.z, r2, r5.x
rcp r2.y, r2.y
mul r2.w, r2.z, r2.y
mul r2.x, r2, r5
add r4.xy, r8, -c18.xzzw
mov r4.z, v0.w
texldl r1, r4.xyzz, s3
abs_pp r3.y, r1
log_pp r3.x, r3.y
frc_pp r3.z, r3.x
add_pp r3.z, r3.x, -r3
exp_pp r2.z, -r3.z
mad_pp r3.y, r3, r2.z, c20
mul r3.x, r2.y, r2
mul r2.xyz, r5.x, c25
mad r2.xyz, r3.x, c24, r2
mad r2.xyz, r2.w, c23, r2
mul_pp r3.y, r3, c22.x
mul r3.x, r3.y, c22.y
frc r3.y, r3.x
add_pp r2.w, r3.z, c21.z
mul r3.w, r3.y, c22
add r3.x, r3, -r3.y
mul_pp r2.w, r2, c21
cmp_pp r1.y, -r1, c20.w, c20.z
mad_pp r1.y, r1, c21, r2.w
add r1.y, r1, r3.x
mul r1.y, r1, c22.z
add r2.w, -r1.y, -r3
max r3.xyz, r2, c20.z
add r2.x, r2.w, c20.w
mul r1.y, r1, r1.x
mul r4.z, r2.x, r1.x
rcp r3.w, r3.w
mul r4.z, r4, r3.w
mov r11.z, v0.w
texldl r2, r11.xyzz, s3
abs_pp r4.w, r2.y
log_pp r5.x, r4.w
mul r3.w, r3, r1.y
frc_pp r5.y, r5.x
mul r6.xyz, r1.x, c25
add_pp r1.y, r5.x, -r5
exp_pp r1.x, -r1.y
mad r6.xyz, r3.w, c24, r6
mad_pp r1.x, r4.w, r1, c20.y
mad r6.xyz, r4.z, c23, r6
max r6.xyz, r6, c20.z
mul_pp r1.x, r1, c22
mul r4.z, r1.x, c22.y
frc r3.w, r4.z
add r3.xyz, r3, -r6
add r4.w, r4.z, -r3
add_pp r1.x, r1.y, c21.z
mul_pp r4.z, r1.x, c21.w
cmp_pp r2.y, -r2, c20.w, c20.z
mad_pp r2.y, r2, c21, r4.z
add r1.xy, r4, -c18.zyzw
mul r4.xy, r1, c19
frc r5.xy, r4
mad r4.xyz, r5.x, r3, r6
add r2.y, r2, r4.w
mul r6.x, r2.y, c22.z
mul r2.y, r3.w, c22.w
add r4.w, -r6.x, -r2.y
mov r10.z, v0.w
texldl r3, r10.xyzz, s3
abs_pp r6.z, r3.y
add r4.w, r4, c20
log_pp r6.w, r6.z
rcp r6.y, r2.y
mul r4.w, r4, r2.x
frc_pp r2.y, r6.w
add_pp r2.y, r6.w, -r2
mul r6.x, r6, r2
exp_pp r7.x, -r2.y
mul r4.w, r4, r6.y
mul r6.w, r6.y, r6.x
mad_pp r7.x, r6.z, r7, c20.y
mul r6.xyz, r2.x, c25
mul_pp r2.x, r7, c22
mad r6.xyz, r6.w, c24, r6
mul r6.w, r2.x, c22.y
mad r6.xyz, r4.w, c23, r6
frc r4.w, r6
add_pp r2.x, r2.y, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r3.y, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r6.w, r6, -r4
mul r2.y, r4.w, c22.w
add r2.x, r2, r6.w
mul r2.x, r2, c22.z
add r3.y, -r2.x, -r2
rcp r4.w, r2.y
mul r2.x, r2, r3
add r3.y, r3, c20.w
mul r2.y, r3, r3.x
mul r3.y, r2, r4.w
abs_pp r2.y, r5.w
mul r2.x, r4.w, r2
mul r7.xyz, r3.x, c25
log_pp r4.w, r2.y
mad r7.xyz, r2.x, c24, r7
frc_pp r3.x, r4.w
add_pp r2.x, r4.w, -r3
exp_pp r3.x, -r2.x
mad_pp r2.y, r2, r3.x, c20
mad r7.xyz, r3.y, c23, r7
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.x, r2.y
add r3.y, r2, -r3.x
add_pp r2.x, r2, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r5.w, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r2.x, r2, r3.y
abs_pp r3.y, r1.w
log_pp r4.w, r3.y
frc_pp r5.w, r4
add_pp r4.w, r4, -r5
max r7.xyz, r7, c20.z
max r6.xyz, r6, c20.z
add r6.xyz, r6, -r7
mad r6.xyz, r5.x, r6, r7
add r4.xyz, r4, -r6
mad r4.xyz, r5.y, r4, r6
mul r2.y, r3.x, c22.w
mul r2.x, r2, c22.z
add r3.x, -r2, -r2.y
add r3.x, r3, c20.w
rcp r2.y, r2.y
mul r3.x, r5.z, r3
mul r2.x, r5.z, r2
mul r3.x, r3, r2.y
mul r2.x, r2.y, r2
exp_pp r5.w, -r4.w
mad_pp r2.y, r3, r5.w, c20
mul r6.xyz, r5.z, c25
mad r6.xyz, r2.x, c24, r6
mad r6.xyz, r3.x, c23, r6
add_pp r2.x, r4.w, c21.z
max r7.xyz, r6, c20.z
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.x, r2.y
add r2.y, r2, -r3.x
mul_pp r2.x, r2, c21.w
cmp_pp r1.w, -r1, c20, c20.z
mad_pp r1.w, r1, c21.y, r2.x
mul r2.x, r3, c22.w
add r1.w, r1, r2.y
mul r1.w, r1, c22.z
add r2.y, -r1.w, -r2.x
rcp r3.x, r2.x
add r2.y, r2, c20.w
mul r2.x, r1.z, r2.y
mul r1.w, r1.z, r1
mul r2.x, r2, r3
abs_pp r2.y, r3.w
mul r1.w, r3.x, r1
mul r6.xyz, r1.z, c25
log_pp r3.x, r2.y
frc_pp r1.z, r3.x
mad r6.xyz, r1.w, c24, r6
add_pp r1.z, r3.x, -r1
mad r6.xyz, r2.x, c23, r6
exp_pp r1.w, -r1.z
mad_pp r1.w, r2.y, r1, c20.y
mul_pp r2.x, r1.w, c22
mul r3.x, r2, c22.y
abs_pp r1.w, r2
log_pp r2.x, r1.w
frc r3.y, r3.x
frc_pp r2.y, r2.x
add_pp r2.x, r2, -r2.y
add r4.w, r3.x, -r3.y
add_pp r2.y, r1.z, c21.z
exp_pp r1.z, -r2.x
mul_pp r3.x, r2.y, c21.w
mad_pp r1.w, r1, r1.z, c20.y
max r6.xyz, r6, c20.z
cmp_pp r2.y, -r3.w, c20.w, c20.z
mad_pp r2.y, r2, c21, r3.x
add r2.y, r2, r4.w
add r7.xyz, r7, -r6
mul r1.z, r2.y, c22
mul r3.y, r3, c22.w
mul_pp r1.w, r1, c22.x
mul r2.y, r1.w, c22
frc r3.x, r2.y
add_pp r1.w, r2.x, c21.z
mul_pp r2.x, r1.w, c21.w
cmp_pp r1.w, -r2, c20, c20.z
add r3.w, -r1.z, -r3.y
add r2.w, r3, c20
mul r3.w, r3.z, r1.z
rcp r1.z, r3.y
add r2.y, r2, -r3.x
mad_pp r1.w, r1, c21.y, r2.x
add r2.x, r1.w, r2.y
mul r1.w, r3.x, c22
mul r2.x, r2, c22.z
add r2.y, -r2.x, -r1.w
mul r2.w, r3.z, r2
mul r3.w, r1.z, r3
mul r1.z, r2.w, r1
mul r3.xyz, r3.z, c25
mad r3.xyz, r3.w, c24, r3
mad r3.xyz, r1.z, c23, r3
add r2.y, r2, c20.w
rcp r1.w, r1.w
mul r1.z, r2, r2.y
mul r2.w, r2.z, r2.x
mul r1.z, r1, r1.w
mul r2.w, r1, r2
mul r2.xyz, r2.z, c25
mad r2.xyz, r2.w, c24, r2
mad r2.xyz, r1.z, c23, r2
add r1.z, c4.w, -c4
rcp r1.z, r1.z
max r3.xyz, r3, c20.z
max r2.xyz, r2, c20.z
add r2.xyz, r2, -r3
mad r2.xyz, r5.x, r2, r3
mad r6.xyz, r5.x, r7, r6
add r3.xyz, r6, -r2
mul r1.w, r1.z, c4
texldl r5.x, v0, s2
add r1.z, r1.w, -r5.x
rcp r2.w, r1.z
mul r1.w, r1, c4.z
mov r1.z, c4.w
mul r1.w, r1, r2
mul r2.w, c23, r1.z
mul r0.w, r0, r7
mad r2.xyz, r5.y, r3, r2
mov r1.z, v0.w
if_gt r1.w, r2.w
texldl r1.xyz, r1.xyzz, s4
else
mov r1.xyz, c20.z
endif
mul r2.xyz, r2, r0.w
mad r0.xyz, r1, r2, r0
add r0.xyz, r0, r4
mul r1.xyz, r0.y, c26
mad r1.xyz, r0.x, c27, r1
mad r0.xyz, r0.z, c28, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c24.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c24.w
add r0.z, r0.x, c25.w
cmp r0.z, r0, c20.w, c20
mul_pp r1.x, r0.z, c21.y
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c26.w
frc r1.x, r0
mul r3.xyz, r2.y, c26
add r2.y, r0.x, -r1.x
mad r1.xyz, r2.x, c27, r3
mad r1.xyz, r2.z, c28, r1
add_pp r0.x, r2.y, c27.w
exp_pp r2.x, r0.x
mad_pp r0.x, -r0.z, c20, c20.w
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.y, c21.w
mul_pp r0.x, r0, r2
mul r2.xy, r1, r1.z
mul r0.w, r0, c28
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c24.w
min r0.w, r0, c29.x
mad r0.z, r0, c29.y, r0.w
mad r0.z, r0, c29, c29.w
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c24.w
add r1.z, r1.x, c25.w
cmp r0.w, r1.z, c20, c20.z
mul_pp r1.z, r0.w, c21.y
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c28.w
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c26.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c21.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c29
mad r0.z, r0.x, c29.y, r1.x
add_pp r0.x, r0.y, c27.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c20, c20.w
mad r0.z, r0, c29, c29.w
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 compose sky with 3 cloud layers
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 3 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 5 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 4 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[30] = { program.local[0..19],
		{ 1, 0, 2, -1 },
		{ -1000000, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.995 },
		{ 0.63999999, 0, 210, 0.25 },
		{ 0.075300001, -0.2543, 1.1892, 256 },
		{ 2.5651, -1.1665, -0.39860001, 400 },
		{ -1.0217, 1.9777, 0.043900002, 255 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.0009765625 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 } };
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
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R5, c[16];
MOVR  R6, c[17];
TEX   R8, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[5];
MOVR  R4.x, c[21];
TEX   R9, fragment.texcoord[0], texture[1], 2D;
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[20].z, -R0;
MOVR  R0.z, c[20].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[7].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[20].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.y, R2, R1;
MOVR  R0, c[8];
MULR  R3.z, R3.y, R3.y;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[6].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R4.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R0.y, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R3.y, R1;
MOVR  R1.x, R8.w;
MOVR  R1.y, R9.w;
MOVR  R1.w, c[20].x;
MOVR  R0.x, c[21];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.y, R0.y;
MOVR  R0.y, c[21].x;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3.x;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3, R0.z;
MOVR  R0.z, c[21].x;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.x;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.y, R0.w;
MOVR  R4.y, R0;
MOVR  R4.w, R0.z;
MOVR  R4.z, R0.x;
DP4R  R0.x, R4, c[9];
SGER  H0.x, c[20].y, R0;
MOVR  R0, c[15];
ADDR  R0, -R0, c[11];
MADR  R4, H0.x, R0, c[15];
MOVR  R0, c[14];
ADDR  R0, -R0, c[10];
MADR  R3, H0.x, R0, c[14];
TEX   R0, fragment.texcoord[0], texture[2], 2D;
MOVR  R1.z, R0.w;
ADDR  R5, -R5, c[12];
MADR  R5, H0.x, R5, c[16];
ADDR  R6, -R6, c[13];
MADR  R6, H0.x, R6, c[17];
DP4R  R2.x, R1, R3;
DP4R  R2.w, R1, R6;
DP4R  R2.y, R1, R4;
DP4R  R2.z, R1, R5;
DP4R  R1.x, R3, R3;
DP4R  R1.w, R6, R6;
DP4R  R1.y, R4, R4;
DP4R  R1.z, R5, R5;
MADR  R1, R2, R1, -R1;
ADDR  R7, R1, c[20].x;
MOVR  R2.z, R0.x;
MOVR  R1.z, R0.y;
MULR  R0.w, R7.x, R7.y;
MULR  R8.w, R0, R7.z;
MOVR  R1.x, R8.y;
MOVR  R0.x, R8.z;
MOVR  R2.y, R9.x;
MOVR  R2.w, c[20].y;
MOVR  R2.x, R8;
DP4R  R8.x, R6, R2;
MOVR  R1.y, R9;
MOVR  R1.w, c[20].y;
DP4R  R8.y, R6, R1;
MOVR  R0.y, R9.z;
MOVR  R0.w, c[20].y;
DP4R  R8.z, R6, R0;
DP4R  R6.x, R5, R2;
DP4R  R6.z, R5, R0;
DP4R  R6.y, R5, R1;
MADR  R5.xyz, R7.z, R8, R6;
DP4R  R6.x, R4, R2;
DP4R  R2.x, R3, R2;
DP4R  R2.z, R3, R0;
DP4R  R6.z, R4, R0;
DP4R  R6.y, R4, R1;
DP4R  R2.y, R3, R1;
MADR  R4.xyz, R7.y, R5, R6;
ADDR  R0.xy, fragment.texcoord[0], c[18].xzzw;
ADDR  R0.xy, R0, c[18].zyzw;
ADDR  R0.xy, R0, -c[18].xzzw;
MADR  R1.xyz, R7.x, R4, R2;
ADDR  R6.xy, R0, -c[18].zyzw;
ADDR  R4.xy, R6, c[18].xzzw;
ADDR  R2.xy, R4, c[18].zyzw;
TEX   R0, R2, texture[4], 2D;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R0|, H0;
MADH  H0.y, H0, c[22].x, -c[22].x;
MULR  R2.z, H0.y, c[22].y;
FRCR  R2.w, R2.z;
ADDH  H0.x, H0, c[21].z;
MULH  H0.z, H0.x, c[21].w;
SGEH  H0.xy, c[20].y, R0.ywzw;
ADDR  R6.zw, R2.xyxy, -c[18].xyxz;
MADH  H0.x, H0, c[21].y, H0.z;
FLRR  R2.z, R2;
ADDR  R0.y, H0.x, R2.z;
MULR  R2.z, R2.w, c[23].x;
MULR  R3.x, R0.y, c[22].z;
ADDR  R0.y, -R3.x, -R2.z;
RCPR  R3.y, R2.z;
TEX   R2, R6.zwzw, texture[4], 2D;
MULR  R3.x, R3, R0;
MADR  R0.y, R0, R0.x, R0.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULR  R0.y, R0, R3;
MULR  R3.w, R3.y, R3.x;
MULR  R3.xyz, R0.x, c[26];
MADR  R3.xyz, R3.w, c[25], R3;
MADR  R3.xyz, R0.y, c[24], R3;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R0.y, R0.x;
SGEH  H0.zw, c[20].y, R2.xyyw;
MAXR  R5.xyz, R3, c[20].y;
TEX   R3, R4, texture[4], 2D;
MULH  H0.x, H0, c[21].w;
SGEH  H1.xy, c[20].y, R3.ywzw;
MADH  H0.x, H0.z, c[21].y, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R2.y, R0, c[23].x;
MULR  R0.y, R0.x, c[22].z;
ADDR  R0.x, -R0.y, -R2.y;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
RCPR  R2.y, R2.y;
MADR  R0.x, R0, R2, R2;
MULR  R0.y, R0, R2.x;
MULR  R0.x, R0, R2.y;
MULR  R0.y, R2, R0;
MULR  R4.xyz, R2.x, c[26];
MADR  R4.xyz, R0.y, c[25], R4;
MADR  R4.xyz, R0.x, c[24], R4;
MAXR  R4.xyz, R4, c[20].y;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R2.x, R0;
MULR  R5.w, R2.x, c[23].x;
ADDR  R5.xyz, R5, -R4;
FLRR  R0.y, R0.x;
MADH  H0.x, H1, c[21].y, H0;
ADDR  R0.y, H0.x, R0;
MULR  R3.y, R0, c[22].z;
ADDR  R4.w, -R3.y, -R5;
ADDR  R0.xy, R6.zwzw, -c[18].zyzw;
MULR  R2.xy, R0, c[19];
FRCR  R2.xy, R2;
MADR  R5.xyz, R2.x, R5, R4;
MADR  R6.z, R4.w, R3.x, R3.x;
TEX   R4, R6, texture[4], 2D;
RCPR  R6.x, R5.w;
MULR  R3.y, R3, R3.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[21].z;
SGEH  H1.zw, c[20].y, R4.xyyw;
MULH  H0.x, H0, c[21].w;
MULR  R5.w, R6.z, R6.x;
MULR  R3.y, R6.x, R3;
MULR  R6.xyz, R3.x, c[26];
MADH  H0.z, H0, c[22].x, -c[22].x;
MADR  R6.xyz, R3.y, c[25], R6;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MADR  R6.xyz, R5.w, c[24], R6;
MADH  H0.x, H1.z, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R4.y, R3.x, c[22].z;
MULR  R3.y, R3, c[23].x;
ADDR  R3.x, -R4.y, -R3.y;
MULR  R4.y, R4, R4.x;
MADR  R3.x, R3, R4, R4;
RCPR  R3.y, R3.y;
MULR  R7.xyz, R4.x, c[26];
MULR  R4.x, R3.y, R4.y;
MULR  R3.x, R3, R3.y;
MADR  R7.xyz, R4.x, c[25], R7;
MADR  R7.xyz, R3.x, c[24], R7;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MAXR  R7.xyz, R7, c[20].y;
MAXR  R6.xyz, R6, c[20].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R2.x, R6, R7;
ADDR  R5.xyz, R5, -R6;
MADR  R5.xyz, R2.y, R5, R6;
MADH  H0.x, H1.y, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R3.y, R3, c[23].x;
MULR  R3.x, R3, c[22].z;
ADDR  R3.w, -R3.x, -R3.y;
MADR  R3.w, R3.z, R3, R3.z;
RCPR  R3.y, R3.y;
MULR  R3.x, R3.z, R3;
MULR  R3.w, R3, R3.y;
MULR  R4.x, R3.y, R3;
MULR  R3.xyz, R3.z, c[26];
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
MAXR  R6.xyz, R3, c[20].y;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MULR  R3.z, R3.y, c[23].x;
RCPR  R4.x, R3.z;
MADH  H0.x, H1.w, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
MULR  R3.x, R3, c[22].z;
ADDR  R3.y, -R3.x, -R3.z;
MADR  R3.y, R4.z, R3, R4.z;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
ADDH  H0.x, H0, c[21].z;
MULR  R3.w, R3.y, R4.x;
MULR  R4.y, R4.z, R3.x;
MULR  R2.w, H0.z, c[22].y;
MULH  H0.x, H0, c[21].w;
MADH  H0.z, H0.w, c[21].y, H0.x;
LG2H  H0.x, |R0.w|;
MULR  R3.xyz, R4.z, c[26];
MULR  R4.x, R4, R4.y;
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
FLRR  R3.w, R2;
ADDR  R3.w, H0.z, R3;
MULR  R5.w, R3, c[22].z;
MAXR  R3.xyz, R3, c[20].y;
ADDR  R4.xyz, R6, -R3;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R2.w, R2;
MULR  R6.x, R2.w, c[23];
ADDR  R4.w, -R5, -R6.x;
MULR  R6.w, R2.z, R5;
RCPR  R5.w, R6.x;
MULH  H0.z, |R0.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.w, H0.z, c[22].y;
FRCR  R2.w, R0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MADR  R3.xyz, R2.x, R4, R3;
MULR  R2.w, R2, c[23].x;
MADR  R4.w, R2.z, R4, R2.z;
MULR  R6.xyz, R2.z, c[26];
MULR  R2.z, R5.w, R6.w;
MADR  R6.xyz, R2.z, c[25], R6;
MULR  R2.z, R4.w, R5.w;
MADR  R6.xyz, R2.z, c[24], R6;
MULR  R7.xyz, R0.z, c[26];
MAXR  R6.xyz, R6, c[20].y;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[21].y, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[22].z;
ADDR  R3.w, -R0, -R2;
MADR  R2.z, R0, R3.w, R0;
MULR  R3.w, R0.z, R0;
RCPR  R0.w, R2.w;
MULR  R0.z, R0.w, R3.w;
MADR  R7.xyz, R0.z, c[25], R7;
MULR  R0.z, R2, R0.w;
MADR  R7.xyz, R0.z, c[24], R7;
MAXR  R7.xyz, R7, c[20].y;
ADDR  R7.xyz, R7, -R6;
MADR  R4.xyz, R2.x, R7, R6;
ADDR  R4.xyz, R4, -R3;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.w, R0.z, c[4];
MADR  R2.xyz, R2.y, R4, R3;
TEX   R3.x, fragment.texcoord[0], texture[3], 2D;
ADDR  R2.w, R0, -R3.x;
MOVR  R0.z, c[22].w;
RCPR  R2.w, R2.w;
MULR  R0.w, R0, c[4].z;
MULR  R0.z, R0, c[4].w;
MULR  R0.w, R0, R2;
SGTRC HC.x, R0.w, R0.z;
MULR  R1.w, R8, R7;
IF    NE.x;
TEX   R0.xyz, R0, texture[5], 2D;
ELSE;
MOVR  R0.xyz, c[20].y;
ENDIF;
MULR  R2.xyz, R2, R1.w;
MADR  R0.xyz, R0, R2, R1;
ADDR  R0.xyz, R0, R5;
MULR  R1.xyz, R0.y, c[29];
MADR  R1.xyz, R0.x, c[28], R1;
MADR  R0.xyz, R0.z, c[27], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[23].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[23].z;
SGER  H0.x, R0, c[21].y;
MULH  H0.y, H0.x, c[21];
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[23].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[21];
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[21].w;
MULR  R1.xyz, R2.y, c[29];
MADR  R1.xyz, R2.x, c[28], R1;
MADR  R1.xyz, R2.z, c[27], R1;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[23];
MULR  R0.w, R0, c[25];
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[25].w;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[20].z, H0.z;
MINR  R0.z, R0, c[23];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[21].y;
MULH  H0.y, H0.z, c[21];
MINR  R0.w, R0, c[26];
MADR  R0.w, R0.x, c[24], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[20];
MADR  H0.y, R0.w, c[27].w, R0.x;
MULR  R0.w, R0.z, c[23];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[21].w;
ADDH  H0.x, H0, -c[21].z;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[26].w;
MADR  R0.y, R0.z, c[24].w, R0;
MADR  H0.z, R0.y, c[27].w, R0.x;
MADH  H0.x, H0.y, c[20].z, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 3 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 5 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 4 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c20, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c21, -1000000.00000000, 128.00000000, 15.00000000, 4.00000000
def c22, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c23, 0.07530000, -0.25430000, 1.18920004, 0.99500000
def c24, 2.56509995, -1.16649997, -0.39860001, 210.00000000
def c25, -1.02170002, 1.97770000, 0.04390000, -128.00000000
def c26, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c27, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c28, 0.02411880, 0.12281780, 0.84442663, 400.00000000
def c29, 255.00000000, 256.00000000, 0.00097656, 1.00000000
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c20.x, c20.y
mov r6, c13
mov r5, c12
texldl r8, v0, s0
texldl r9, v0, s1
mov r0.z, c20.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.y, r0.w
mul r0.xyz, r1.y, r0
mov r0.w, c20.z
dp4 r3.z, r0, c2
dp4 r3.y, r0, c1
dp4 r3.x, r0, c0
mov r0.x, c6
mov r0.y, c6.x
add r0.y, c8, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c7.x
add r2.xyz, r2, -c5
dp3 r1.y, r2, r2
add r0.x, c8, r0
dp3 r0.z, r3, r2
mad r0.w, -r0.y, r0.y, r1.y
mad r1.z, r0, r0, -r0.w
mad r0.x, -r0, r0, r1.y
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c20.w, c20.z
cmp r0.x, r0, r1, c21
cmp r0.x, -r0.y, r0, r0.w
rsq r1.w, r1.z
cmp_pp r0.y, r1.z, c20.w, c20.z
rcp r1.w, r1.w
cmp r1.z, r1, r1.x, c21.x
add r1.w, -r0.z, r1
cmp r0.y, -r0, r1.z, r1.w
mov r0.w, c6.x
add r1.z, c8.w, r0.w
mad r1.z, -r1, r1, r1.y
mad r1.w, r0.z, r0.z, -r1.z
rsq r1.z, r1.w
rcp r1.z, r1.z
mov r0.w, c6.x
add r0.w, c8.z, r0
mad r0.w, -r0, r0, r1.y
mad r1.y, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.z
rsq r0.w, r1.y
rcp r1.z, r0.w
add r1.z, -r0, r1
cmp_pp r0.w, r1, c20, c20.z
cmp r1.w, r1, r1.x, c21.x
cmp r0.w, -r0, r1, r2.x
cmp_pp r0.z, r1.y, c20.w, c20
cmp r1.x, r1.y, r1, c21
cmp r0.z, -r0, r1.x, r1
dp4 r0.x, r0, c9
cmp r2.z, -r0.x, c20.w, c20
mov r1, c11
add r1, -c15, r1
mad r4, r2.z, r1, c15
mov r0, c10
add r0, -c14, r0
mad r3, r2.z, r0, c14
texldl r0, v0, s2
mov r1.z, r0.w
add r6, -c17, r6
add r5, -c16, r5
mad r6, r2.z, r6, c17
mad r5, r2.z, r5, c16
mov r1.y, r9.w
mov r1.w, c20
mov r1.x, r8.w
dp4 r2.x, r3, r1
dp4 r2.w, r6, r1
dp4 r2.y, r4, r1
dp4 r2.z, r5, r1
dp4 r1.x, r3, r3
dp4 r1.w, r6, r6
add r2, r2, c20.y
dp4 r1.y, r4, r4
dp4 r1.z, r5, r5
mad r7, r1, r2, c20.w
mov r2.z, r0.x
mov r1.z, r0.y
mov r2.y, r9.x
mov r1.y, r9
mov r1.x, r8.y
mov r1.w, c20.z
dp4 r8.y, r6, r1
mov r0.y, r9.z
mov r0.x, r8.z
mov r0.w, c20.z
dp4 r8.z, r6, r0
mov r2.w, c20.z
mov r2.x, r8
dp4 r8.x, r6, r2
dp4 r6.x, r5, r2
dp4 r6.y, r5, r1
dp4 r6.z, r5, r0
mad r6.xyz, r7.z, r8, r6
add r9.xy, v0, c18.xzzw
add r5.xy, r9, c18.zyzw
dp4 r9.x, r4, r2
dp4 r2.x, r3, r2
add r5.xy, r5, -c18.xzzw
add r10.xy, r5, -c18.zyzw
add r11.xy, r10, c18.xzzw
dp4 r2.y, r3, r1
dp4 r9.y, r4, r1
dp4 r9.z, r4, r0
mad r4.xyz, r7.y, r6, r9
add r8.xy, r11, c18.zyzw
mov r8.z, v0.w
texldl r5, r8.xyzz, s4
abs_pp r4.w, r5.y
log_pp r6.x, r4.w
frc_pp r2.z, r6.x
add_pp r1.x, r6, -r2.z
dp4 r2.z, r3, r0
mad r0.xyz, r7.x, r4, r2
exp_pp r0.w, -r1.x
mad_pp r1.y, r4.w, r0.w, c20
mul r0.w, r7.x, r7.y
mul r0.w, r0, r7.z
mul_pp r1.y, r1, c22.x
mul r1.y, r1, c22
frc r1.z, r1.y
add r1.w, r1.y, -r1.z
add_pp r1.x, r1, c21.z
mul_pp r1.y, r1.x, c21.w
cmp_pp r1.x, -r5.y, c20.w, c20.z
mad_pp r1.x, r1, c21.y, r1.y
add r1.x, r1, r1.w
mul r2.y, r1.z, c22.w
mul r2.x, r1, c22.z
add r2.z, -r2.x, -r2.y
add r2.z, r2, c20.w
mul r2.z, r2, r5.x
rcp r2.y, r2.y
mul r2.w, r2.z, r2.y
mul r2.x, r2, r5
add r4.xy, r8, -c18.xzzw
mov r4.z, v0.w
texldl r1, r4.xyzz, s4
abs_pp r3.y, r1
log_pp r3.x, r3.y
frc_pp r3.z, r3.x
add_pp r3.z, r3.x, -r3
exp_pp r2.z, -r3.z
mad_pp r3.y, r3, r2.z, c20
mul r3.x, r2.y, r2
mul r2.xyz, r5.x, c25
mad r2.xyz, r3.x, c24, r2
mad r2.xyz, r2.w, c23, r2
mul_pp r3.y, r3, c22.x
mul r3.x, r3.y, c22.y
frc r3.y, r3.x
add_pp r2.w, r3.z, c21.z
mul r3.w, r3.y, c22
add r3.x, r3, -r3.y
mul_pp r2.w, r2, c21
cmp_pp r1.y, -r1, c20.w, c20.z
mad_pp r1.y, r1, c21, r2.w
add r1.y, r1, r3.x
mul r1.y, r1, c22.z
add r2.w, -r1.y, -r3
max r3.xyz, r2, c20.z
add r2.x, r2.w, c20.w
mul r1.y, r1, r1.x
mul r4.z, r2.x, r1.x
rcp r3.w, r3.w
mul r4.z, r4, r3.w
mov r11.z, v0.w
texldl r2, r11.xyzz, s4
abs_pp r4.w, r2.y
log_pp r5.x, r4.w
mul r3.w, r3, r1.y
frc_pp r5.y, r5.x
mul r6.xyz, r1.x, c25
add_pp r1.y, r5.x, -r5
exp_pp r1.x, -r1.y
mad r6.xyz, r3.w, c24, r6
mad_pp r1.x, r4.w, r1, c20.y
mad r6.xyz, r4.z, c23, r6
max r6.xyz, r6, c20.z
mul_pp r1.x, r1, c22
mul r4.z, r1.x, c22.y
frc r3.w, r4.z
add r3.xyz, r3, -r6
add r4.w, r4.z, -r3
add_pp r1.x, r1.y, c21.z
mul_pp r4.z, r1.x, c21.w
cmp_pp r2.y, -r2, c20.w, c20.z
mad_pp r2.y, r2, c21, r4.z
add r1.xy, r4, -c18.zyzw
mul r4.xy, r1, c19
frc r5.xy, r4
mad r4.xyz, r5.x, r3, r6
add r2.y, r2, r4.w
mul r6.x, r2.y, c22.z
mul r2.y, r3.w, c22.w
add r4.w, -r6.x, -r2.y
mov r10.z, v0.w
texldl r3, r10.xyzz, s4
abs_pp r6.z, r3.y
add r4.w, r4, c20
log_pp r6.w, r6.z
rcp r6.y, r2.y
mul r4.w, r4, r2.x
frc_pp r2.y, r6.w
add_pp r2.y, r6.w, -r2
mul r6.x, r6, r2
exp_pp r7.x, -r2.y
mul r4.w, r4, r6.y
mul r6.w, r6.y, r6.x
mad_pp r7.x, r6.z, r7, c20.y
mul r6.xyz, r2.x, c25
mul_pp r2.x, r7, c22
mad r6.xyz, r6.w, c24, r6
mul r6.w, r2.x, c22.y
mad r6.xyz, r4.w, c23, r6
frc r4.w, r6
add_pp r2.x, r2.y, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r3.y, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r6.w, r6, -r4
mul r2.y, r4.w, c22.w
add r2.x, r2, r6.w
mul r2.x, r2, c22.z
add r3.y, -r2.x, -r2
rcp r4.w, r2.y
mul r2.x, r2, r3
add r3.y, r3, c20.w
mul r2.y, r3, r3.x
mul r3.y, r2, r4.w
abs_pp r2.y, r5.w
mul r2.x, r4.w, r2
mul r7.xyz, r3.x, c25
log_pp r4.w, r2.y
mad r7.xyz, r2.x, c24, r7
frc_pp r3.x, r4.w
add_pp r2.x, r4.w, -r3
exp_pp r3.x, -r2.x
mad_pp r2.y, r2, r3.x, c20
mad r7.xyz, r3.y, c23, r7
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.x, r2.y
add r3.y, r2, -r3.x
add_pp r2.x, r2, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r5.w, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r2.x, r2, r3.y
abs_pp r3.y, r1.w
log_pp r4.w, r3.y
frc_pp r5.w, r4
add_pp r4.w, r4, -r5
max r7.xyz, r7, c20.z
max r6.xyz, r6, c20.z
add r6.xyz, r6, -r7
mad r6.xyz, r5.x, r6, r7
add r4.xyz, r4, -r6
mad r4.xyz, r5.y, r4, r6
mul r2.y, r3.x, c22.w
mul r2.x, r2, c22.z
add r3.x, -r2, -r2.y
add r3.x, r3, c20.w
rcp r2.y, r2.y
mul r3.x, r5.z, r3
mul r2.x, r5.z, r2
mul r3.x, r3, r2.y
mul r2.x, r2.y, r2
exp_pp r5.w, -r4.w
mad_pp r2.y, r3, r5.w, c20
mul r6.xyz, r5.z, c25
mad r6.xyz, r2.x, c24, r6
mad r6.xyz, r3.x, c23, r6
add_pp r2.x, r4.w, c21.z
max r7.xyz, r6, c20.z
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.x, r2.y
add r2.y, r2, -r3.x
mul_pp r2.x, r2, c21.w
cmp_pp r1.w, -r1, c20, c20.z
mad_pp r1.w, r1, c21.y, r2.x
mul r2.x, r3, c22.w
add r1.w, r1, r2.y
mul r1.w, r1, c22.z
add r2.y, -r1.w, -r2.x
rcp r3.x, r2.x
add r2.y, r2, c20.w
mul r2.x, r1.z, r2.y
mul r1.w, r1.z, r1
mul r2.x, r2, r3
abs_pp r2.y, r3.w
mul r1.w, r3.x, r1
mul r6.xyz, r1.z, c25
log_pp r3.x, r2.y
frc_pp r1.z, r3.x
mad r6.xyz, r1.w, c24, r6
add_pp r1.z, r3.x, -r1
mad r6.xyz, r2.x, c23, r6
exp_pp r1.w, -r1.z
mad_pp r1.w, r2.y, r1, c20.y
mul_pp r2.x, r1.w, c22
mul r3.x, r2, c22.y
abs_pp r1.w, r2
log_pp r2.x, r1.w
frc r3.y, r3.x
frc_pp r2.y, r2.x
add_pp r2.x, r2, -r2.y
add r4.w, r3.x, -r3.y
add_pp r2.y, r1.z, c21.z
exp_pp r1.z, -r2.x
mul_pp r3.x, r2.y, c21.w
mad_pp r1.w, r1, r1.z, c20.y
max r6.xyz, r6, c20.z
cmp_pp r2.y, -r3.w, c20.w, c20.z
mad_pp r2.y, r2, c21, r3.x
add r2.y, r2, r4.w
add r7.xyz, r7, -r6
mul r1.z, r2.y, c22
mul r3.y, r3, c22.w
mul_pp r1.w, r1, c22.x
mul r2.y, r1.w, c22
frc r3.x, r2.y
add_pp r1.w, r2.x, c21.z
mul_pp r2.x, r1.w, c21.w
cmp_pp r1.w, -r2, c20, c20.z
add r3.w, -r1.z, -r3.y
add r2.w, r3, c20
mul r3.w, r3.z, r1.z
rcp r1.z, r3.y
add r2.y, r2, -r3.x
mad_pp r1.w, r1, c21.y, r2.x
add r2.x, r1.w, r2.y
mul r1.w, r3.x, c22
mul r2.x, r2, c22.z
add r2.y, -r2.x, -r1.w
mul r2.w, r3.z, r2
mul r3.w, r1.z, r3
mul r1.z, r2.w, r1
mul r3.xyz, r3.z, c25
mad r3.xyz, r3.w, c24, r3
mad r3.xyz, r1.z, c23, r3
add r2.y, r2, c20.w
rcp r1.w, r1.w
mul r1.z, r2, r2.y
mul r2.w, r2.z, r2.x
mul r1.z, r1, r1.w
mul r2.w, r1, r2
mul r2.xyz, r2.z, c25
mad r2.xyz, r2.w, c24, r2
mad r2.xyz, r1.z, c23, r2
add r1.z, c4.w, -c4
rcp r1.z, r1.z
max r3.xyz, r3, c20.z
max r2.xyz, r2, c20.z
add r2.xyz, r2, -r3
mad r2.xyz, r5.x, r2, r3
mad r6.xyz, r5.x, r7, r6
add r3.xyz, r6, -r2
mul r1.w, r1.z, c4
texldl r5.x, v0, s3
add r1.z, r1.w, -r5.x
rcp r2.w, r1.z
mul r1.w, r1, c4.z
mov r1.z, c4.w
mul r1.w, r1, r2
mul r2.w, c23, r1.z
mul r0.w, r0, r7
mad r2.xyz, r5.y, r3, r2
mov r1.z, v0.w
if_gt r1.w, r2.w
texldl r1.xyz, r1.xyzz, s5
else
mov r1.xyz, c20.z
endif
mul r2.xyz, r2, r0.w
mad r0.xyz, r1, r2, r0
add r0.xyz, r0, r4
mul r1.xyz, r0.y, c26
mad r1.xyz, r0.x, c27, r1
mad r0.xyz, r0.z, c28, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c24.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c24.w
add r0.z, r0.x, c25.w
cmp r0.z, r0, c20.w, c20
mul_pp r1.x, r0.z, c21.y
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c26.w
frc r1.x, r0
mul r3.xyz, r2.y, c26
add r2.y, r0.x, -r1.x
mad r1.xyz, r2.x, c27, r3
mad r1.xyz, r2.z, c28, r1
add_pp r0.x, r2.y, c27.w
exp_pp r2.x, r0.x
mad_pp r0.x, -r0.z, c20, c20.w
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.y, c21.w
mul_pp r0.x, r0, r2
mul r2.xy, r1, r1.z
mul r0.w, r0, c28
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c24.w
min r0.w, r0, c29.x
mad r0.z, r0, c29.y, r0.w
mad r0.z, r0, c29, c29.w
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c24.w
add r1.z, r1.x, c25.w
cmp r0.w, r1.z, c20, c20.z
mul_pp r1.z, r0.w, c21.y
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c28.w
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c26.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c21.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c29
mad r0.z, r0.x, c29.y, r1.x
add_pp r0.x, r0.y, c27.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c20, c20.w
mad r0.z, r0, c29, c29.w
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 compose sky with 4 cloud layers
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 4 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 6 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 5 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[30] = { program.local[0..19],
		{ 0, 2, -1, -1000000 },
		{ 1, 128, 15, 4 },
		{ 1024, 0.00390625, 0.0047619049, 0.995 },
		{ 0.63999999, 0, 210, 0.25 },
		{ 0.075300001, -0.2543, 1.1892, 256 },
		{ 2.5651, -1.1665, -0.39860001, 400 },
		{ -1.0217, 1.9777, 0.043900002, 255 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.0009765625 },
		{ 0.51413637, 0.32387859, 0.16036376 },
		{ 0.26506799, 0.67023426, 0.064091571 } };
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
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[2], 2D;
TEX   R9, fragment.texcoord[0], texture[3], 2D;
MOVR  R5, c[16];
MOVR  R6, c[17];
MOVR  R10.z, R8.y;
MOVR  R2.xyz, c[5];
MOVR  R4.x, c[20].w;
MOVR  R10.w, R9.y;
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[20].y, -R0;
MOVR  R0.z, c[20];
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[7].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[20].x;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.y, R2, R1;
MOVR  R0, c[8];
MULR  R3.z, R3.y, R3.y;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[6].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.z, R0;
MOVXC RC.x, R2;
MOVR  R4.x(EQ), R1.w;
ADDR  R1, R3.z, -R0;
SGERC HC, R3.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R3.y, R1;
TEX   R1, fragment.texcoord[0], texture[0], 2D;
MOVR  R10.x, R1.y;
MOVR  R0.x, c[20].w;
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.y, R0.y;
MOVR  R0.y, c[20].w;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3.x;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3, R0.z;
MOVR  R0.z, c[20].w;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.x;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.y, R0.w;
MOVR  R4.y, R0;
MOVR  R4.w, R0.z;
MOVR  R4.z, R0.x;
DP4R  R0.x, R4, c[9];
SGER  H0.x, c[20], R0;
MOVR  R4.z, R8.w;
MOVR  R0, c[15];
ADDR  R0, -R0, c[11];
MADR  R3, H0.x, R0, c[15];
MOVR  R0, c[14];
ADDR  R0, -R0, c[10];
MADR  R2, H0.x, R0, c[14];
TEX   R0, fragment.texcoord[0], texture[1], 2D;
ADDR  R5, -R5, c[12];
ADDR  R6, -R6, c[13];
MADR  R6, H0.x, R6, c[17];
MOVR  R10.y, R0;
MADR  R5, H0.x, R5, c[16];
MOVR  R4.y, R0.w;
MOVR  R4.x, R1.w;
MOVR  R4.w, R9;
DP4R  R7.y, R4, R3;
DP4R  R7.x, R4, R2;
DP4R  R7.z, R4, R5;
DP4R  R7.w, R4, R6;
DP4R  R4.y, R3, R3;
DP4R  R4.x, R2, R2;
DP4R  R4.w, R6, R6;
DP4R  R4.z, R5, R5;
MADR  R4, R7, R4, -R4;
ADDR  R4, R4, c[21].x;
MOVR  R7.z, R8.x;
MULR  R0.w, R4.x, R4.y;
MULR  R0.w, R0, R4.z;
MOVR  R7.x, R1;
MOVR  R7.y, R0.x;
MOVR  R7.w, R9.x;
MOVR  R8.x, R1.z;
MOVR  R8.y, R0.z;
MOVR  R8.w, R9.z;
DP4R  R1.x, R5, R7;
DP4R  R0.x, R6, R7;
DP4R  R1.z, R5, R8;
DP4R  R1.y, R5, R10;
DP4R  R0.y, R6, R10;
DP4R  R0.z, R6, R8;
MADR  R0.xyz, R4.z, R0, R1;
DP4R  R1.x, R3, R7;
DP4R  R1.z, R3, R8;
DP4R  R1.y, R3, R10;
MADR  R0.xyz, R4.y, R0, R1;
DP4R  R1.x, R2, R7;
DP4R  R1.z, R2, R8;
DP4R  R1.y, R2, R10;
MADR  R1.xyz, R4.x, R0, R1;
ADDR  R0.xy, fragment.texcoord[0], c[18].xzzw;
ADDR  R0.xy, R0, c[18].zyzw;
ADDR  R0.xy, R0, -c[18].xzzw;
ADDR  R6.xy, R0, -c[18].zyzw;
ADDR  R4.xy, R6, c[18].xzzw;
ADDR  R2.xy, R4, c[18].zyzw;
MULR  R1.w, R0, R4;
TEX   R0, R2, texture[5], 2D;
LG2H  H0.x, |R0.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R0|, H0;
MADH  H0.y, H0, c[22].x, -c[22].x;
MULR  R2.z, H0.y, c[22].y;
FRCR  R2.w, R2.z;
ADDH  H0.x, H0, c[21].z;
MULH  H0.z, H0.x, c[21].w;
SGEH  H0.xy, c[20].x, R0.ywzw;
ADDR  R6.zw, R2.xyxy, -c[18].xyxz;
MADH  H0.x, H0, c[21].y, H0.z;
FLRR  R2.z, R2;
ADDR  R0.y, H0.x, R2.z;
MULR  R2.z, R2.w, c[23].x;
MULR  R3.x, R0.y, c[22].z;
ADDR  R0.y, -R3.x, -R2.z;
RCPR  R3.y, R2.z;
TEX   R2, R6.zwzw, texture[5], 2D;
MULR  R3.x, R3, R0;
MADR  R0.y, R0, R0.x, R0.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULR  R0.y, R0, R3;
MULR  R3.w, R3.y, R3.x;
MULR  R3.xyz, R0.x, c[26];
MADR  R3.xyz, R3.w, c[25], R3;
MADR  R3.xyz, R0.y, c[24], R3;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R0.y, R0.x;
SGEH  H0.zw, c[20].x, R2.xyyw;
MAXR  R5.xyz, R3, c[20].x;
TEX   R3, R4, texture[5], 2D;
MULH  H0.x, H0, c[21].w;
SGEH  H1.xy, c[20].x, R3.ywzw;
MADH  H0.x, H0.z, c[21].y, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R2.y, R0, c[23].x;
MULR  R0.y, R0.x, c[22].z;
ADDR  R0.x, -R0.y, -R2.y;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.y|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
RCPR  R2.y, R2.y;
MADR  R0.x, R0, R2, R2;
MULR  R0.y, R0, R2.x;
MULR  R0.x, R0, R2.y;
MULR  R0.y, R2, R0;
MULR  R4.xyz, R2.x, c[26];
MADR  R4.xyz, R0.y, c[25], R4;
MADR  R4.xyz, R0.x, c[24], R4;
MAXR  R4.xyz, R4, c[20].x;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.x, H0.z, c[22].y;
FRCR  R2.x, R0;
MULR  R5.w, R2.x, c[23].x;
ADDR  R5.xyz, R5, -R4;
FLRR  R0.y, R0.x;
MADH  H0.x, H1, c[21].y, H0;
ADDR  R0.y, H0.x, R0;
MULR  R3.y, R0, c[22].z;
ADDR  R4.w, -R3.y, -R5;
ADDR  R0.xy, R6.zwzw, -c[18].zyzw;
MULR  R2.xy, R0, c[19];
FRCR  R2.xy, R2;
MADR  R5.xyz, R2.x, R5, R4;
MADR  R6.z, R4.w, R3.x, R3.x;
TEX   R4, R6, texture[5], 2D;
RCPR  R6.x, R5.w;
MULR  R3.y, R3, R3.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[21].z;
SGEH  H1.zw, c[20].x, R4.xyyw;
MULH  H0.x, H0, c[21].w;
MULR  R5.w, R6.z, R6.x;
MULR  R3.y, R6.x, R3;
MULR  R6.xyz, R3.x, c[26];
MADH  H0.z, H0, c[22].x, -c[22].x;
MADR  R6.xyz, R3.y, c[25], R6;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MADR  R6.xyz, R5.w, c[24], R6;
MADH  H0.x, H1.z, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R3.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R4.y, R3.x, c[22].z;
MULR  R3.y, R3, c[23].x;
ADDR  R3.x, -R4.y, -R3.y;
MULR  R4.y, R4, R4.x;
MADR  R3.x, R3, R4, R4;
RCPR  R3.y, R3.y;
MULR  R7.xyz, R4.x, c[26];
MULR  R4.x, R3.y, R4.y;
MULR  R3.x, R3, R3.y;
MADR  R7.xyz, R4.x, c[25], R7;
MADR  R7.xyz, R3.x, c[24], R7;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MAXR  R7.xyz, R7, c[20].x;
MAXR  R6.xyz, R6, c[20].x;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R2.x, R6, R7;
ADDR  R5.xyz, R5, -R6;
MADR  R5.xyz, R2.y, R5, R6;
MADH  H0.x, H1.y, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MULR  R3.y, R3, c[23].x;
MULR  R3.x, R3, c[22].z;
ADDR  R3.w, -R3.x, -R3.y;
MADR  R3.w, R3.z, R3, R3.z;
RCPR  R3.y, R3.y;
MULR  R3.x, R3.z, R3;
MULR  R3.w, R3, R3.y;
MULR  R4.x, R3.y, R3;
MULR  R3.xyz, R3.z, c[26];
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
MAXR  R6.xyz, R3, c[20].x;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R3.x, H0.z, c[22].y;
FRCR  R3.y, R3.x;
MULR  R3.z, R3.y, c[23].x;
RCPR  R4.x, R3.z;
MADH  H0.x, H1.w, c[21].y, H0;
FLRR  R3.x, R3;
ADDR  R3.x, H0, R3;
MULR  R3.x, R3, c[22].z;
ADDR  R3.y, -R3.x, -R3.z;
MADR  R3.y, R4.z, R3, R4.z;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
ADDH  H0.x, H0, c[21].z;
MULR  R3.w, R3.y, R4.x;
MULR  R4.y, R4.z, R3.x;
MULR  R2.w, H0.z, c[22].y;
MULH  H0.x, H0, c[21].w;
MADH  H0.z, H0.w, c[21].y, H0.x;
LG2H  H0.x, |R0.w|;
MULR  R3.xyz, R4.z, c[26];
MULR  R4.x, R4, R4.y;
MADR  R3.xyz, R4.x, c[25], R3;
MADR  R3.xyz, R3.w, c[24], R3;
FLRR  R3.w, R2;
ADDR  R3.w, H0.z, R3;
MULR  R5.w, R3, c[22].z;
MAXR  R3.xyz, R3, c[20].x;
ADDR  R4.xyz, R6, -R3;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R2.w, R2;
MULR  R6.x, R2.w, c[23];
ADDR  R4.w, -R5, -R6.x;
MULR  R6.w, R2.z, R5;
RCPR  R5.w, R6.x;
MULH  H0.z, |R0.w|, H0;
MADH  H0.z, H0, c[22].x, -c[22].x;
MULR  R0.w, H0.z, c[22].y;
FRCR  R2.w, R0;
ADDH  H0.x, H0, c[21].z;
MULH  H0.x, H0, c[21].w;
MADR  R3.xyz, R2.x, R4, R3;
MULR  R2.w, R2, c[23].x;
MADR  R4.w, R2.z, R4, R2.z;
MULR  R6.xyz, R2.z, c[26];
MULR  R2.z, R5.w, R6.w;
MADR  R6.xyz, R2.z, c[25], R6;
MULR  R2.z, R4.w, R5.w;
MADR  R6.xyz, R2.z, c[24], R6;
MULR  R7.xyz, R0.z, c[26];
MAXR  R6.xyz, R6, c[20].x;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[21].y, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[22].z;
ADDR  R3.w, -R0, -R2;
MADR  R2.z, R0, R3.w, R0;
MULR  R3.w, R0.z, R0;
RCPR  R0.w, R2.w;
MULR  R0.z, R0.w, R3.w;
MADR  R7.xyz, R0.z, c[25], R7;
MULR  R0.z, R2, R0.w;
MADR  R7.xyz, R0.z, c[24], R7;
MAXR  R7.xyz, R7, c[20].x;
ADDR  R7.xyz, R7, -R6;
MADR  R4.xyz, R2.x, R7, R6;
ADDR  R4.xyz, R4, -R3;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.w, R0.z, c[4];
MADR  R2.xyz, R2.y, R4, R3;
TEX   R3.x, fragment.texcoord[0], texture[4], 2D;
ADDR  R2.w, R0, -R3.x;
MOVR  R0.z, c[22].w;
RCPR  R2.w, R2.w;
MULR  R0.w, R0, c[4].z;
MULR  R0.z, R0, c[4].w;
MULR  R0.w, R0, R2;
SGTRC HC.x, R0.w, R0.z;
IF    NE.x;
TEX   R0.xyz, R0, texture[6], 2D;
ELSE;
MOVR  R0.xyz, c[20].x;
ENDIF;
MULR  R2.xyz, R2, R1.w;
MADR  R0.xyz, R0, R2, R1;
ADDR  R0.xyz, R0, R5;
MULR  R1.xyz, R0.y, c[29];
MADR  R1.xyz, R0.x, c[28], R1;
MADR  R0.xyz, R0.z, c[27], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[23].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[23].z;
SGER  H0.x, R0, c[21].y;
MULH  H0.y, H0.x, c[21];
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[23].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[21];
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[21].w;
MULR  R1.xyz, R2.y, c[29];
MADR  R1.xyz, R2.x, c[28], R1;
MADR  R1.xyz, R2.z, c[27], R1;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[23];
MULR  R0.w, R0, c[25];
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[25].w;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[20].y, H0.z;
MINR  R0.z, R0, c[23];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[21].y;
MULH  H0.y, H0.z, c[21];
MINR  R0.w, R0, c[26];
MADR  R0.w, R0.x, c[24], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[21];
MADR  H0.y, R0.w, c[27].w, R0.x;
MULR  R0.w, R0.z, c[23];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[21].w;
ADDH  H0.x, H0, -c[21].z;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[26].w;
MADR  R0.y, R0.z, c[24].w, R0;
MADR  H0.z, R0.y, c[27].w, R0.x;
MADH  H0.x, H0.y, c[20].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 4 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 6 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]
SetTexture 5 [_MainTex] 2D
Vector 18 [_dUV]
Vector 19 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c20, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c21, -1000000.00000000, 128.00000000, 15.00000000, 4.00000000
def c22, 1024.00000000, 0.00390625, 0.00476190, 0.63999999
def c23, 0.07530000, -0.25430000, 1.18920004, 0.99500000
def c24, 2.56509995, -1.16649997, -0.39860001, 210.00000000
def c25, -1.02170002, 1.97770000, 0.04390000, -128.00000000
def c26, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c27, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c28, 0.02411880, 0.12281780, 0.84442663, 400.00000000
def c29, 255.00000000, 256.00000000, 0.00097656, 1.00000000
dcl_texcoord0 v0.xyzw
texldl r6, v0, s3
texldl r7, v0, s2
texldl r9, v0, s0
texldl r8, v0, s1
mov r10.w, r6.y
mad r0.xy, v0, c20.x, c20.y
mov r4, c13
mov r6.y, r8.z
mov r10.z, r7.y
mov r10.x, r9.y
mov r10.y, r8
mov r0.z, c20.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.y, r0.w
mul r0.xyz, r1.y, r0
mov r0.w, c20.z
dp4 r3.z, r0, c2
dp4 r3.y, r0, c1
dp4 r3.x, r0, c0
mov r0.x, c6
mov r0.y, c6.x
add r0.y, c8, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c7.x
add r2.xyz, r2, -c5
dp3 r0.z, r3, r2
dp3 r1.y, r2, r2
mad r0.w, -r0.y, r0.y, r1.y
mad r1.z, r0, r0, -r0.w
rsq r1.w, r1.z
add r0.x, c8, r0
mad r0.x, -r0, r0, r1.y
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c20.w, c20.z
cmp r0.x, r0, r1, c21
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1.z, c20.w, c20.z
rcp r1.w, r1.w
mov r3, c12
cmp r1.z, r1, r1.x, c21.x
add r1.w, -r0.z, r1
cmp r0.y, -r0, r1.z, r1.w
mov r0.w, c6.x
add r1.z, c8.w, r0.w
mad r1.z, -r1, r1, r1.y
mad r1.w, r0.z, r0.z, -r1.z
rsq r1.z, r1.w
rcp r1.z, r1.z
mov r0.w, c6.x
add r0.w, c8.z, r0
mad r0.w, -r0, r0, r1.y
mad r1.y, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.z
rsq r0.w, r1.y
rcp r1.z, r0.w
add r1.z, -r0, r1
cmp_pp r0.w, r1, c20, c20.z
cmp r1.w, r1, r1.x, c21.x
cmp r0.w, -r0, r1, r2.x
cmp_pp r0.z, r1.y, c20.w, c20
cmp r1.x, r1.y, r1, c21
cmp r0.z, -r0, r1.x, r1
dp4 r0.x, r0, c9
cmp r5.z, -r0.x, c20.w, c20
mov r1, c11
add r1, -c15, r1
mov r0, c10
add r4, -c17, r4
mad r4, r5.z, r4, c17
add r3, -c16, r3
add r0, -c14, r0
mad r2, r5.z, r1, c15
mad r1, r5.z, r0, c14
mov r0.w, r6
mov r6.w, r6.z
mad r3, r5.z, r3, c16
dp4 r7.y, r4, r10
mov r6.z, r7
mov r0.z, r7.w
mov r0.x, r9.w
mov r0.y, r8.w
dp4 r5.w, r4, r0
dp4 r5.x, r1, r0
dp4 r5.y, r2, r0
dp4 r5.z, r3, r0
add r5, r5, c20.y
dp4 r0.w, r4, r4
dp4 r0.x, r1, r1
dp4 r0.y, r2, r2
dp4 r0.z, r3, r3
mad r0, r0, r5, c20.w
mov r5.w, r6.x
mov r6.x, r9.z
mov r5.y, r8.x
dp4 r7.z, r4, r6
mov r5.z, r7.x
mov r5.x, r9
dp4 r7.x, r4, r5
dp4 r4.x, r3, r5
dp4 r4.z, r3, r6
dp4 r4.y, r3, r10
mad r4.xyz, r0.z, r7, r4
add r8.xy, v0, c18.xzzw
add r3.xy, r8, c18.zyzw
add r3.xy, r3, -c18.xzzw
add r9.xy, r3, -c18.zyzw
add r11.xy, r9, c18.xzzw
dp4 r8.x, r2, r5
dp4 r8.z, r2, r6
dp4 r8.y, r2, r10
mad r2.xyz, r0.y, r4, r8
dp4 r4.x, r1, r5
add r7.xy, r11, c18.zyzw
mov r7.z, v0.w
texldl r3, r7.xyzz, s5
abs_pp r2.w, r3.y
log_pp r4.z, r2.w
frc_pp r4.w, r4.z
add_pp r4.w, r4.z, -r4
dp4 r4.z, r1, r6
dp4 r4.y, r1, r10
mad r1.xyz, r0.x, r2, r4
mul r0.x, r0, r0.y
exp_pp r1.w, -r4.w
mad_pp r1.w, r2, r1, c20.y
mul_pp r0.y, r1.w, c22.x
mul r0.x, r0, r0.z
mul r0.y, r0, c22
frc r0.z, r0.y
mul r1.w, r0.x, r0
add r5.xy, r7, -c18.xzzw
add_pp r0.x, r4.w, c21.z
add r0.w, r0.y, -r0.z
mul_pp r0.y, r0.x, c21.w
cmp_pp r0.x, -r3.y, c20.w, c20.z
mad_pp r0.x, r0, c21.y, r0.y
add r0.x, r0, r0.w
mul r2.y, r0.z, c22.w
mul r2.x, r0, c22.z
add r2.z, -r2.x, -r2.y
mov r5.z, v0.w
texldl r0, r5.xyzz, s5
abs_pp r4.x, r0.y
log_pp r3.y, r4.x
frc_pp r4.y, r3
add r2.z, r2, c20.w
mul r2.z, r2, r3.x
rcp r2.y, r2.y
mul r2.w, r2.z, r2.y
add_pp r4.y, r3, -r4
mul r2.x, r2, r3
exp_pp r2.z, -r4.y
mad_pp r4.x, r4, r2.z, c20.y
mul r3.y, r2, r2.x
mul r2.xyz, r3.x, c25
mul_pp r3.x, r4, c22
mad r2.xyz, r3.y, c24, r2
mad r2.xyz, r2.w, c23, r2
add_pp r2.w, r4.y, c21.z
mul r3.x, r3, c22.y
frc r3.y, r3.x
add r3.x, r3, -r3.y
max r4.xyz, r2, c20.z
mul_pp r2.w, r2, c21
cmp_pp r0.y, -r0, c20.w, c20.z
mad_pp r0.y, r0, c21, r2.w
add r0.y, r0, r3.x
mul r3.x, r3.y, c22.w
mul r0.y, r0, c22.z
add r2.w, -r0.y, -r3.x
add r2.x, r2.w, c20.w
mul r0.y, r0, r0.x
mul r3.y, r2.x, r0.x
rcp r3.x, r3.x
mul r3.y, r3, r3.x
mov r11.z, v0.w
texldl r2, r11.xyzz, s5
abs_pp r4.w, r2.y
log_pp r5.z, r4.w
mul r3.x, r3, r0.y
frc_pp r5.w, r5.z
mul r6.xyz, r0.x, c25
add_pp r0.y, r5.z, -r5.w
exp_pp r0.x, -r0.y
mad r6.xyz, r3.x, c24, r6
mad_pp r0.x, r4.w, r0, c20.y
mad r6.xyz, r3.y, c23, r6
max r6.xyz, r6, c20.z
mul_pp r0.x, r0, c22
mul r3.x, r0, c22.y
frc r4.w, r3.x
add r4.xyz, r4, -r6
add r5.z, r3.x, -r4.w
add_pp r0.x, r0.y, c21.z
mul_pp r3.x, r0, c21.w
cmp_pp r2.y, -r2, c20.w, c20.z
mad_pp r2.y, r2, c21, r3.x
add r0.xy, r5, -c18.zyzw
mul r3.xy, r0, c19
frc r3.xy, r3
add r2.y, r2, r5.z
mad r5.xyz, r3.x, r4, r6
mul r6.x, r2.y, c22.z
mul r2.y, r4.w, c22.w
add r5.w, -r6.x, -r2.y
mov r9.z, v0.w
texldl r4, r9.xyzz, s5
abs_pp r6.z, r4.y
add r5.w, r5, c20
log_pp r6.w, r6.z
rcp r6.y, r2.y
mul r5.w, r5, r2.x
frc_pp r2.y, r6.w
add_pp r2.y, r6.w, -r2
mul r6.x, r6, r2
exp_pp r7.x, -r2.y
mul r5.w, r5, r6.y
mul r6.w, r6.y, r6.x
mad_pp r7.x, r6.z, r7, c20.y
mul r6.xyz, r2.x, c25
mul_pp r2.x, r7, c22
mad r6.xyz, r6.w, c24, r6
mul r6.w, r2.x, c22.y
mad r6.xyz, r5.w, c23, r6
frc r5.w, r6
add_pp r2.x, r2.y, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r4.y, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r6.w, r6, -r5
mul r2.y, r5.w, c22.w
add r2.x, r2, r6.w
mul r2.x, r2, c22.z
add r4.y, -r2.x, -r2
rcp r5.w, r2.y
mul r2.x, r2, r4
add r4.y, r4, c20.w
mul r2.y, r4, r4.x
mul r4.y, r2, r5.w
abs_pp r2.y, r3.w
mul r2.x, r5.w, r2
mul r7.xyz, r4.x, c25
log_pp r5.w, r2.y
mad r7.xyz, r2.x, c24, r7
frc_pp r4.x, r5.w
add_pp r2.x, r5.w, -r4
exp_pp r4.x, -r2.x
mad_pp r2.y, r2, r4.x, c20
mad r7.xyz, r4.y, c23, r7
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r4.x, r2.y
add r4.y, r2, -r4.x
add_pp r2.x, r2, c21.z
mul_pp r2.y, r2.x, c21.w
cmp_pp r2.x, -r3.w, c20.w, c20.z
mad_pp r2.x, r2, c21.y, r2.y
add r2.x, r2, r4.y
mul r2.y, r4.x, c22.w
abs_pp r4.x, r0.w
log_pp r4.y, r4.x
frc_pp r5.w, r4.y
add_pp r4.y, r4, -r5.w
mul r2.x, r2, c22.z
add r3.w, -r2.x, -r2.y
add r3.w, r3, c20
max r7.xyz, r7, c20.z
max r6.xyz, r6, c20.z
add r6.xyz, r6, -r7
mad r6.xyz, r3.x, r6, r7
add r5.xyz, r5, -r6
mad r5.xyz, r3.y, r5, r6
rcp r2.y, r2.y
mul r3.w, r3.z, r3
mul r2.x, r3.z, r2
mul r3.w, r3, r2.y
mul r2.x, r2.y, r2
exp_pp r5.w, -r4.y
mad_pp r2.y, r4.x, r5.w, c20
mul r6.xyz, r3.z, c25
mad r6.xyz, r2.x, c24, r6
mad r6.xyz, r3.w, c23, r6
add_pp r2.x, r4.y, c21.z
max r7.xyz, r6, c20.z
mul_pp r2.y, r2, c22.x
mul r2.y, r2, c22
frc r3.z, r2.y
add r2.y, r2, -r3.z
mul_pp r2.x, r2, c21.w
cmp_pp r0.w, -r0, c20, c20.z
mad_pp r0.w, r0, c21.y, r2.x
mul r2.x, r3.z, c22.w
add r0.w, r0, r2.y
mul r0.w, r0, c22.z
add r2.y, -r0.w, -r2.x
rcp r3.z, r2.x
add r2.y, r2, c20.w
mul r2.x, r0.z, r2.y
mul r0.w, r0.z, r0
mul r2.x, r2, r3.z
abs_pp r2.y, r4.w
mul r0.w, r3.z, r0
mul r6.xyz, r0.z, c25
log_pp r3.z, r2.y
frc_pp r0.z, r3
mad r6.xyz, r0.w, c24, r6
add_pp r0.z, r3, -r0
mad r6.xyz, r2.x, c23, r6
exp_pp r0.w, -r0.z
mad_pp r0.w, r2.y, r0, c20.y
mul_pp r2.x, r0.w, c22
mul r3.z, r2.x, c22.y
abs_pp r0.w, r2
log_pp r2.x, r0.w
frc r3.w, r3.z
add r4.x, r3.z, -r3.w
frc_pp r2.y, r2.x
add_pp r2.x, r2, -r2.y
add_pp r2.y, r0.z, c21.z
exp_pp r0.z, -r2.x
mul_pp r3.z, r2.y, c21.w
mad_pp r0.w, r0, r0.z, c20.y
max r6.xyz, r6, c20.z
add r7.xyz, r7, -r6
cmp_pp r2.y, -r4.w, c20.w, c20.z
mad_pp r2.y, r2, c21, r3.z
add r2.y, r2, r4.x
mul r0.z, r2.y, c22
mul_pp r0.w, r0, c22.x
mul r2.y, r0.w, c22
frc r3.z, r2.y
add_pp r0.w, r2.x, c21.z
mul_pp r2.x, r0.w, c21.w
mul r3.w, r3, c22
cmp_pp r0.w, -r2, c20, c20.z
add r4.x, -r0.z, -r3.w
add r2.w, r4.x, c20
add r2.y, r2, -r3.z
mad_pp r0.w, r0, c21.y, r2.x
add r2.x, r0.w, r2.y
mul r0.w, r3.z, c22
mul r2.x, r2, c22.z
add r2.y, -r2.x, -r0.w
mul r3.z, r4, r0
mul r2.w, r4.z, r2
rcp r0.z, r3.w
mul r3.z, r0, r3
mul r0.z, r2.w, r0
mul r4.xyz, r4.z, c25
mad r4.xyz, r3.z, c24, r4
mad r4.xyz, r0.z, c23, r4
add r2.y, r2, c20.w
rcp r0.w, r0.w
mul r0.z, r2, r2.y
mul r2.w, r2.z, r2.x
mul r0.z, r0, r0.w
mul r2.w, r0, r2
mul r2.xyz, r2.z, c25
mad r2.xyz, r2.w, c24, r2
mad r2.xyz, r0.z, c23, r2
add r0.z, c4.w, -c4
rcp r0.z, r0.z
max r4.xyz, r4, c20.z
max r2.xyz, r2, c20.z
add r2.xyz, r2, -r4
mad r2.xyz, r3.x, r2, r4
mad r6.xyz, r3.x, r7, r6
add r4.xyz, r6, -r2
mul r0.w, r0.z, c4
texldl r3.x, v0, s4
add r0.z, r0.w, -r3.x
rcp r2.w, r0.z
mul r0.w, r0, c4.z
mov r0.z, c4.w
mul r0.w, r0, r2
mul r2.w, c23, r0.z
mad r2.xyz, r3.y, r4, r2
mov r0.z, v0.w
if_gt r0.w, r2.w
texldl r0.xyz, r0.xyzz, s6
else
mov r0.xyz, c20.z
endif
mul r2.xyz, r2, r1.w
mad r0.xyz, r0, r2, r1
add r0.xyz, r0, r5
mul r1.xyz, r0.y, c26
mad r1.xyz, r0.x, c27, r1
mad r0.xyz, r0.z, c28, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c24.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c24.w
add r0.z, r0.x, c25.w
cmp r0.z, r0, c20.w, c20
mul_pp r1.x, r0.z, c21.y
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c26.w
frc r1.x, r0
mul r3.xyz, r2.y, c26
add r2.y, r0.x, -r1.x
mad r1.xyz, r2.x, c27, r3
mad r1.xyz, r2.z, c28, r1
add_pp r0.x, r2.y, c27.w
exp_pp r2.x, r0.x
mad_pp r0.x, -r0.z, c20, c20.w
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.y, c21.w
mul_pp r0.x, r0, r2
mul r2.xy, r1, r1.z
mul r0.w, r0, c28
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c24.w
min r0.w, r0, c29.x
mad r0.z, r0, c29.y, r0.w
mad r0.z, r0, c29, c29.w
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c24.w
add r1.z, r1.x, c25.w
cmp r0.w, r1.z, c20, c20.z
mul_pp r1.z, r0.w, c21.y
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c28.w
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c26.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c21.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c29
mad r0.z, r0.x, c29.y, r1.x
add_pp r0.x, r0.y, c27.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c20, c20.w
mad r0.z, r0, c29, c29.w
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}
	}
	Fallback off
}
