// Performs aerial perspective computations taking up to 4 cloud layers into account
//
Shader "Hidden/Nuaj/AerialPerspectiveComplex"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownScaledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
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
		// Pass #0 renders sky with NO cloud layer
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[57] = { program.local[0..46],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.001, 0.75 },
		{ 1, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625 } };
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
SHORT OUTPUT oCol = result.color;
MOVR  R5.x, c[48].y;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[47].x, -R0;
MOVR  R0.z, c[47].y;
DP3R  R0.w, R0, R0;
RSQR  R2.w, R0.w;
MULR  R0.xyz, R2.w, R0;
MOVR  R0.w, c[47].z;
DP4R  R1.z, R0, c[2];
DP4R  R1.y, R0, c[1];
DP4R  R1.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R8.x, c[48].y;
MOVR  R8.y, c[48];
MOVR  R8.z, c[48].y;
MOVR  R2.x, c[0].w;
MOVR  R2.z, c[2].w;
MOVR  R2.y, c[1].w;
MULR  R3.xyz, R2, c[13].x;
ADDR  R2.xyz, R3, -c[9];
DP3R  R1.w, R1, R2;
MULR  R3.w, R1, R1;
DP3R  R5.y, R2, R2;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
SLTR  R6, R3.w, R0;
MOVXC RC.x, R6;
MOVR  R5.x(EQ), R4;
ADDR  R4, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.x, R4.z;
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
ADDR  R5.x(NE.z), -R1.w, R4;
MOVXC RC.z, R6;
MOVR  R8.x(EQ.z), R5.z;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R8.x(NE.y), -R1.w, R0;
RSQR  R0.x, R4.w;
MOVXC RC.y, R6;
MOVR  R4.x, c[48];
MOVR  R4.z, c[48].x;
MOVR  R4.w, c[48].x;
MOVR  R8.y(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R8.y(NE.w), -R1.w, R0.x;
RSQR  R0.x, R4.y;
MOVR  R8.z(EQ.y), R5;
RCPR  R0.x, R0.x;
ADDR  R8.z(NE.x), -R1.w, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
ADDR  R6, R3.w, -R0;
RSQR  R4.y, R6.x;
SLTR  R7, R3.w, R0;
MOVXC RC.x, R7;
MOVR  R4.x(EQ), R5.z;
SGERC HC, R3.w, R0.yzxw;
RCPR  R4.y, R4.y;
ADDR  R4.x(NE.z), -R1.w, -R4.y;
MOVXC RC.z, R7;
MOVR  R4.z(EQ), R5;
RSQR  R0.x, R6.z;
RCPR  R0.x, R0.x;
ADDR  R4.z(NE.y), -R1.w, -R0.x;
MOVXC RC.z, R7.w;
RSQR  R0.x, R6.w;
MOVR  R4.w(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE), -R1, -R0.x;
RSQR  R0.x, R6.y;
MOVR  R4.y, c[48].x;
MOVXC RC.y, R7;
MOVR  R4.y(EQ), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.y(NE.x), -R1.w, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R5.y;
MADR  R5.y, -c[12].x, c[12].x, R5;
ADDR  R0.y, R3.w, -R0.x;
ADDR  R0.z, R3.w, -R5.y;
RSQR  R0.y, R0.y;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R6.x, c[48];
SLTRC HC.x, R3.w, R0;
MOVR  R6.x(EQ), R5.z;
SGERC HC.x, R3.w, R0;
RCPR  R0.y, R0.y;
ADDR  R6.x(NE), -R1.w, -R0.y;
MOVXC RC.x, R6;
ADDR  R0.w, -R1, -R0.z;
ADDR  R1.w, -R1, R0.z;
MOVR  R6.x(LT), c[48];
MAXR  R0.z, R0.w, c[47];
MOVR  R0.xy, c[47].z;
SLTRC HC.x, R3.w, R5.y;
MOVR  R0.xy(EQ.x), R5.zwzw;
SGERC HC.x, R3.w, R5.y;
MAXR  R0.w, R1, c[47].z;
MOVR  R0.xy(NE.x), R0.zwzw;
MOVR  R5.y, R8.z;
MOVR  R5.w, R8.y;
MOVR  R5.z, R8.x;
DP4R  R1.w, R5, c[35];
SGER  R1.w, c[47].z, R1;
DP4R  R0.z, R4, c[40];
DP4R  R0.w, R5, c[36];
ADDR  R0.w, R0, -R0.z;
MADR  R0.z, R1.w, R0.w, R0;
RCPR  R0.w, R2.w;
TEX   R7.x, fragment.texcoord[0], texture[0], 2D;
MULR  R0.w, R7.x, R0;
MADR  R3.w, -R0, c[13].x, R6.x;
MOVR  R2.w, c[47];
MULR  R2.w, R2, c[8];
SGER  H0.x, R7, R2.w;
MULR  R0.w, R0, c[13].x;
MADR  R0.w, H0.x, R3, R0;
MINR  R6.w, R0.y, R0;
MAXR  R2.w, R0.x, c[48].z;
ADDR  R6.y, R6.w, -R2.w;
RCPR  R0.x, R6.y;
MINR  R0.y, R6.w, R0.z;
MAXR  R10.y, R2.w, R0;
MULR  R8.w, R0.x, c[32].x;
ADDR  R3.w, R10.y, -R2;
MULR  R6.x, R8.w, R3.w;
RCPR  R7.x, c[32].x;
MULR  R9.w, R6.y, R7.x;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R1.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MULR  R7.xyz, R1.zxyw, c[16].yzxw;
MOVR  R9.x, R0;
MOVR  R10.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R1.w, R0, c[46].y;
SLTR  H0.y, R6.x, R0.w;
SGTR  H0.x, R6, c[47].z;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R6.x;
RCPR  R6.z, R0.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R3, R6.z;
MULR  R6.xyz, R2.zxyw, c[16].yzxw;
MADR  R6.xyz, R2.yzxw, c[16].zxyw, -R6;
DP3R  R2.x, R2, c[16];
MOVR  R11.w(NE.x), R0;
SLER  H0.y, R2.x, c[47].z;
DP3R  R0.w, R6, R6;
MADR  R7.xyz, R1.yzxw, c[16].zxyw, -R7;
DP3R  R3.w, R6, R7;
DP3R  R6.x, R7, R7;
MADR  R0.w, -c[11].x, c[11].x, R0;
MULR  R6.z, R6.x, R0.w;
MULR  R6.y, R3.w, R3.w;
ADDR  R0.w, R6.y, -R6.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.y, -R3.w, R0.w;
MOVR  R2.z, c[48].y;
MOVR  R2.x, c[48];
ADDR  R0.w, -R3, -R0;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
SGTR  H0.z, R6.y, R6;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVXC RC.x, H0.y;
RCPR  R6.x, R6.x;
MULR  R2.z(NE.x), R6.x, R2.y;
MULR  R2.x(NE), R0.w, R6;
MOVR  R2.y, R2.z;
MOVR  R14.xy, R2;
MADR  R2.xyz, R1, R2.x, R3;
ADDR  R2.xyz, R2, -c[9];
DP3R  R0.w, R2, c[16];
SGTR  H0.z, R0.w, c[47];
MULXC HC.x, H0.y, H0.z;
MOVR  R14.xy(NE.x), c[48];
MOVXC RC.x, H0;
DP4R  R2.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R11.y, R10, R0.w;
DP4R  R2.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R13.x, R11.y, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R2.x, R5, c[39];
ADDR  R2.x, R2, -R0.w;
MADR  R0.w, R1, R2.x, R0;
MINR  R0.w, R6, R0;
DP3R  R0.y, R1, c[16];
MULR  R7.w, R0.x, c[33].x;
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[47];
MADR  R0.x, c[30], c[30], R0;
MADR  R14.z, R0.y, c[48].w, c[48].w;
ADDR  R0.y, R0.x, c[49].x;
MOVR  R0.x, c[49];
POWR  R0.y, R0.y, c[49].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R3.w, R13.x, R0;
MOVR  R11.x, R0.z;
MOVR  R4.w, R6;
MULR  R14.w, R0.x, R0.y;
MOVR  R4.xyz, c[49].x;
MOVR  R7.xyz, c[47].z;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R11.y, -R10.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R9.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R9.x;
RCPR  R0.z, R9.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R9.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R10.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R13, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R11.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R3.w, -R13;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R13.x;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R4.w, -R3.w;
MULR  R0.y, R0.x, R8.w;
MOVR  R13.xyz, R7;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVX  H0.x, c[47].z;
RCPR  R0.z, R7.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.w(NE.x), R7;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R3;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
ADDR  R6, R6.x, -c[25];
RCPR  R2.x, R5.y;
MULR_SAT R2.x, R6.y, R2;
MOVR  R3.w, c[50];
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R3.w;
RCPR  R2.x, R5.x;
MULR_SAT R5.x, R6, R2;
MULR  R4.w, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R4, -R4;
MULR  R2.y, R5.x, R5.x;
MADR  R0.z, -R5.x, c[47].x, R3.w;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R3.w;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R3.w;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.w, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R4.w, -R2, R3, R3;
MOVR  R2.xyz, c[21];
MULR  R3.w, R4, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R4.w, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
DP3R  R5.x, R2, R2;
MULR  R4.w, R4, R3;
RSQR  R3.w, R5.x;
MULR  R2.xyz, R3.w, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R4, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
RCPR  R2.w, R3.w;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R3, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R3.y, R3, R2;
MOVR  R2.y, c[50].w;
MADR  R5.x, -R3.y, c[47], R2.y;
MULR  R4.w, R3.y, R3.y;
RCPR  R3.y, R2.x;
MULR  R2.x, R4.w, R5;
TEX   R5, R0.zwzw, texture[2], 2D;
MULR_SAT R3.x, R3, R3.y;
MADR  R0.w, R5.y, R2.x, -R2.x;
MADR  R0.z, -R3.x, c[47].x, R2.y;
MULR  R2.x, R3, R3;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R5.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R3.w;
MULR_SAT R0.w, R0, R3.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R5.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R5, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R3.y, -R2.w, R3.x, R3.x;
MOVR  R2.xyz, c[21];
MULR  R3.x, R3.y, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R3.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
DP3R  R3.z, R2, R2;
MULR  R3.y, R3, R3.x;
RSQR  R3.x, R3.z;
MULR  R2.xyz, R3.x, R2;
DP3R  R1.x, R2, R1;
MADR  R0.z, R1.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R1.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R1.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R3.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R1.xyz, c[18];
ADDR  R1.xyz, -R1, c[19];
DP3R  R1.x, R1, R1;
RCPR  R2.x, R3.x;
MULR  R2.x, R2, c[51].w;
MULR  R1.y, R2.x, R2.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
RCPR  R1.y, R1.y;
MULR  R0.z, R1.x, R0;
MULR  R0.z, R0, R1.y;
MINR  R0.w, R0, c[49].x;
MULR  R1.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R1.xyz, R0.z, c[20], R1;
MULR  R0.z, R0.y, c[28].x;
MULR  R1.xyz, R1, c[52].x;
MULR  R1.xyz, R0.z, R1;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R2.xyz, R0.w, c[51], R0.z;
MULR  R1.xyz, R1, c[52].y;
MADR  R1.xyz, R12, R2, R1;
MULR  R0.y, R0, c[29].x;
ADDR  R1.xyz, R1, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R1.xyz, R1, R11.w;
MADR  R7.xyz, R1, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
MOVR  R0, c[40];
MOVR  R2, c[41];
ADDR  R0, -R0, c[36];
MADR  R0, R1.w, R0, c[40];
DP4R  R1.x, R0, c[49].x;
ADDR  R2, -R2, c[37];
MADR  R2, R1.w, R2, c[41];
DP4R  R0.x, R0, R0;
MOVR  R3, c[42];
MOVR  R5, c[43];
ADDR  R3, -R3, c[38];
MADR  R3, R1.w, R3, c[42];
ADDR  R5, -R5, c[39];
MADR  R5, R1.w, R5, c[43];
DP4R  R1.y, R2, c[49].x;
DP4R  R1.z, R3, c[49].x;
DP4R  R1.w, R5, c[49].x;
DP4R  R0.y, R2, R2;
DP4R  R0.w, R5, R5;
DP4R  R0.z, R3, R3;
MADR  R0, R1, R0, -R0;
ADDR  R0, R0, c[49].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R11;
MADR  R1.xyz, R1, R0.y, R10;
MADR  R0.xyz, R1, R0.x, R9;
MULR  R1.xyz, R0.y, c[55];
MADR  R1.xyz, R0.x, c[54], R1;
MADR  R0.xyz, R0.z, c[53], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[52].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[52].z;
SGER  H0.x, R0, c[52].w;
MULH  H0.y, H0.x, c[52].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[53].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[54].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[55].w;
MULR  R1.xyz, R4.y, c[55];
MADR  R1.xyz, R4.x, c[54], R1;
MADR  R1.xyz, R4.z, c[53], R1;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[52].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[47], H0.z;
MINR  R0.z, R1, c[52];
SGER  H0.z, R0, c[52].w;
ADDR  R0.x, R0, -H0.y;
MINR  R0.w, R0, c[50].x;
MADR  R0.x, R0, c[56], R0.w;
MULH  H0.y, H0.z, c[52].w;
ADDR  R0.w, R0.z, -H0.y;
MOVR  R0.z, c[49].x;
MADR  H0.y, R0.x, c[56], R0.z;
MULR  R1.x, R0.w, c[53].w;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[55].w;
ADDR  R0.x, R0.w, -H0;
ADDH  H0.x, H0.w, -c[54].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[50].x;
MADR  R0.x, R0, c[56], R0.y;
MADR  H0.z, R0.x, c[56].y, R0;
MADH  H0.x, H0.y, c[47], H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c47, 2.00000000, -1.00000000, 0.00000000, 0.99500000
def c48, 1000000.00000000, 0.00000000, 1.00000000, -1000000.00000000
def c49, 0.00100000, 0.75000000, 1.50000000, 0.50000000
defi i0, 255, 0, 1, 0
def c50, 2.71828198, 2.00000000, 3.00000000, 1000.00000000
def c51, 10.00000000, 400.00000000, 210.00000000, -128.00000000
def c52, 5.60204458, 9.47328472, 19.64380264, 128.00000000
def c53, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c54, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c55, 0.02411880, 0.12281780, 0.84442663, 4.00000000
def c56, 2.00000000, 1.00000000, 255.00000000, 256.00000000
def c57, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c47.x, c47.y
mov r0.z, c47.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.z, r0.w
mul r0.xyz, r2.z, r0
mov r0.w, c47.z
dp4 r7.z, r0, c2
dp4 r7.y, r0, c1
dp4 r7.x, r0, c0
mov r0.z, c11.x
mov r0.w, c11.x
mul r9.xyz, r7.zxyw, c16.yzxw
mad r9.xyz, r7.yzxw, c16.zxyw, -r9
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r8.xyz, r1, c13.x
add r6.xyz, r8, -c9
dp3 r0.y, r7, r6
dp3 r0.x, r6, r6
add r0.w, c25.y, r0
mad r1.x, -r0.w, r0.w, r0
mad r1.y, r0, r0, -r1.x
rsq r1.z, r1.y
add r0.z, c25.x, r0
mad r0.z, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.x, -r0.w, r0.z, r1
cmp_pp r0.w, r1.y, c48.z, c48.y
rcp r1.z, r1.z
add r1.z, -r0.y, -r1
cmp r1.y, r1, r1.w, c48.x
cmp r1.y, -r0.w, r1, r1.z
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.z, c25.w, r0
mad r0.w, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0.w
mad r1.z, -r1, r1, r0.x
mad r2.w, r0.y, r0.y, -r1.z
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.z, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.z, -r0.w, r0, r1
rsq r3.x, r2.w
rcp r3.x, r3.x
cmp r0.w, r2, r1, c48.x
add r3.x, -r0.y, -r3
cmp_pp r0.z, r2.w, c48, c48.y
cmp r1.w, -r0.z, r0, r3.x
mov r0.w, c11.x
add r2.w, c24.x, r0
mov r0.w, c11.x
add r3.x, c24.y, r0.w
mad r2.w, -r2, r2, r0.x
mad r0.w, r0.y, r0.y, -r2
mad r3.x, -r3, r3, r0
mad r3.y, r0, r0, -r3.x
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.x, -r2.w, r0.w, r3
rsq r3.z, r3.y
rcp r3.z, r3.z
dp4 r0.z, r1, c41
cmp r3.x, r3.y, r2, c48.w
add r3.z, -r0.y, r3
cmp_pp r2.w, r3.y, c48.z, c48.y
cmp r5.y, -r2.w, r3.x, r3.z
mov r0.w, c11.x
add r2.w, c24, r0
mad r2.w, -r2, r2, r0.x
mad r3.x, r0.y, r0.y, -r2.w
rsq r2.w, r3.x
rcp r3.y, r2.w
add r3.z, -r0.y, r3.y
cmp_pp r3.y, r3.x, c48.z, c48
cmp r3.x, r3, r2, c48.w
cmp r5.w, -r3.y, r3.x, r3.z
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r0.x
mad r0.w, r0.y, r0.y, -r0
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.z, -r2.w, r0.w, r3.x
dp4 r0.w, r5, c37
add r3.x, r0.w, -r0.z
dp4 r2.w, r5, c35
cmp r6.w, -r2, c48.z, c48.y
mad r0.z, r6.w, r3.x, r0
mov r0.w, c11.x
add r0.w, c31.x, r0
mad r0.w, -r0, r0, r0.x
mad r2.w, r0.y, r0.y, -r0
dp4 r3.y, r1, c40
dp4 r3.x, r5, c36
add r3.z, r3.x, -r3.y
rsq r0.w, r2.w
rcp r3.x, r0.w
mad r0.w, r6, r3.z, r3.y
add r3.y, -r0, -r3.x
cmp_pp r3.x, r2.w, c48.z, c48.y
cmp r2.w, r2, r2.x, c48.x
cmp r2.w, -r3.x, r2, r3.y
cmp r3.x, r2.w, r2.w, c48
mad r0.x, -c12, c12, r0
mad r2.w, r0.y, r0.y, -r0.x
cmp r2.xy, r2.w, r2, c47.z
rcp r2.z, r2.z
texldl r0.x, v0, s0
mul r3.y, r0.x, r2.z
mad r3.z, -r3.y, c13.x, r3.x
rsq r3.x, r2.w
mov r2.z, c8.w
mad r0.x, c47.w, -r2.z, r0
rcp r3.x, r3.x
mul r2.z, r3.y, c13.x
cmp r0.x, r0, c48.z, c48.y
mad r3.y, r0.x, r3.z, r2.z
add r0.x, -r0.y, -r3
add r0.y, -r0, r3.x
cmp_pp r2.z, r2.w, c48, c48.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
mad r2.w, r6, r2, c45.y
max r0.x, r0, c47.z
max r0.y, r0, c47.z
cmp r0.xy, -r2.z, r2, r0
min r3.x, r0.y, r3.y
max r12.x, r0, c49
min r0.y, r3.x, r0.w
min r0.x, r3, r0.z
max r4.x, r12, r0.y
dp4 r0.z, r1, c42
dp4 r0.y, r5, c38
add r0.y, r0, -r0.z
max r2.x, r4, r0
mad r0.x, r6.w, r0.y, r0.z
dp4 r0.z, r1, c43
dp4 r0.y, r5, c39
add r0.y, r0, -r0.z
min r0.x, r3, r0
mul r5.xyz, r6.zxyw, c16.yzxw
mad r0.y, r6.w, r0, r0.z
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r6, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r12.x
rcp r0.z, r0.y
mad r5.xyz, r6.yzxw, c16.zxyw, -r5
rcp r2.z, r1.w
add r1.y, r4.x, -r12.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c48, c48.z
cmp r0.w, -r1.z, c48.y, c48.z
mul_pp r2.y, r0.w, r2
cmp r8.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r9.w, -r2.y, r0, r1.y
dp3 r0.y, r5, r5
dp3 r1.y, r5, r9
dp3 r1.z, r9, r9
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
dp3 r0.y, r6, c16
rsq r2.z, r1.w
cmp r0.y, -r0, c48.z, c48
cmp r1.w, -r1, c48.y, c48.z
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c48.x, r1
mad r5.xyz, r7, r1.z, r8
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c48, r1
cmp r1.y, -r1, c48, c48.z
mul_pp r0.y, r0, r1
cmp r13.xy, -r0.y, r1.zwzw, c48.xwzw
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r6.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r6.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r6.w, r0, c46
dp3 r2.z, r7, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c48
mul r2.w, r2, c47.x
mad r2.w, c30.x, c30.x, r2
mul r13.z, r2, c49.y
mov r2.z, c30.x
add r2.z, c48, r2
add r2.w, r2, c48.z
mov r15.x, r3
pow r3, r2.w, c49.z
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r8.w, c48, c48.z
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r13.w, r2.z, r2
mov r9.xyz, c48.z
mov r6.xyz, c47.z
if_gt r2.y, c47.z
frc r2.y, r8.w
add r2.y, r8.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r11.w, r2.y, r2.z, -r2.z
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r15.y, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r15.y, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r2.y, r5.w, c29.x
mad r11.xyz, r5.z, -c27, -r2.y
pow r3, c50.x, r11.y
pow r14, c50.x, r11.x
mov r11.y, r3
pow r3, c50.x, r11.z
add r3.x, r12, r9.w
add r2.w, -r12.x, r13.y
rcp r2.z, r9.w
add r2.y, r3.x, -r13.x
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r3
mul r11.xyz, r11, r2.y
mov r2.y, c47.z
mul r12.xyz, r11, c15
if_gt c34.x, r2.y
add r3.y, r15, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r14.xyz, r10
mov r14.w, c48.z
dp4 r3.w, r14, c5
dp4 r3.z, r14, c4
cmp r12.w, r2.y, c48.z, r12
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r11.xy, r3.zwzw
mov r11.z, c47
texldl r14, r11.xyzz, s2
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r14.x, c47.y
mad r2.y, r2.z, r3.z, c48.z
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r14.y, c47.y
mad r2.w, r2, r3.z, c48.z
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c50.y, c50
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r14.z, c47.y
mad r2.z, r2.w, r3.w, c48
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c50, c50.z
mul r2.w, r2, r2
add r3.z, r14.w, c47.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c48.z
mul r2.y, r2, r2.z
mul r12.w, r2.y, r2
endif
mul r12.xyz, r12, r12.w
endif
add r11.xyz, -r10, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
add r11.xyz, -c21, r11
dp3 r3.z, r11, r11
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r10.xyz, -r10, c18
dp3 r3.y, r10, r10
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r10.xyz, r3.y, r10
dp3 r2.y, r10, r7
mul r3.z, r3, c50.w
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r10.xyz, c19
add r2.y, r2, c48.z
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c50.w
add r10.xyz, -c18, r10
dp3 r2.z, r10, r10
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c50.w
min r2.w, r2.y, c48.z
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c50.w
mul r2.z, r5.y, c28.x
min r2.y, r2, c48.z
mul r10.xyz, r2.w, c23
mad r10.xyz, r2.y, c20, r10
mul r2.y, r5, c29.x
mad r11.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r10.xyz, r10, c51.x
mul r10.xyz, r2.z, r10
mul r10.xyz, r10, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r5.xyz, r2.y, c52, r2.z
mad r5.xyz, r12, r5, r10
mul r10.xyz, r9.w, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mov r10.x, r5
pow r14, c50.x, r10.y
pow r5, c50.x, r10.z
mul r11.xyz, r11, r9.w
mad r6.xyz, r11, r9, r6
mov r10.y, r14
mov r10.z, r5
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r2.y, r3.w, c29.x
mad r11.xyz, r3.z, -c27, -r2.y
pow r10, c50.x, r11.y
pow r14, c50.x, r11.x
add r2.y, r8.w, -r11.w
mul r3.z, r2.y, r9.w
mov r11.y, r10
pow r10, c50.x, r11.z
add r2.y, r3.z, r12.x
rcp r2.z, r3.z
add r2.y, r2, -r13.x
add r2.w, -r12.x, r13.y
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r10
mul r10.xyz, r11, r2.y
mov r2.y, c47.z
mul r10.xyz, r10, c15
if_gt c34.x, r2.y
add r3.w, r5, -c11.x
add r2.y, r3.w, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r11.xyz, r5
mov r11.w, c48.z
dp4 r12.y, r11, c5
dp4 r12.x, r11, c4
cmp r7.w, r2.y, c48.z, r7
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3.w, -c25.x
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r3.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c50.y, c50.z
mul r2.y, r2, r2
mul r2.w, r2.y, r2
mov r2.y, c24.z
mov r11.xy, r12
mov r11.z, c47
texldl r11, r11.xyzz, s2
add r4.y, r11.x, c47
mad r2.z, r2, r4.y, c48
add r4.y, r11, c47
mad r2.w, r2, r4.y, c48.z
add r4.y, -c25.z, r2
mul r2.y, r2.z, r2.w
rcp r2.w, r4.y
add r2.z, r3.w, -c25
mul_sat r2.z, r2, r2.w
mad r4.y, -r2.z, c50, c50.z
mul r2.w, r2.z, r2.z
mul r2.w, r2, r4.y
mov r2.z, c24.w
add r4.y, -c25.w, r2.z
add r4.z, r11, c47.y
mad r2.z, r2.w, r4, c48
rcp r4.y, r4.y
add r2.w, r3, -c25
mul_sat r2.w, r2, r4.y
mad r3.w, -r2, c50.y, c50.z
mul r2.w, r2, r2
add r4.y, r11.w, c47
mul r2.w, r2, r3
mad r2.w, r2, r4.y, c48.z
mul r2.y, r2, r2.z
mul r7.w, r2.y, r2
endif
mul r10.xyz, r10, r7.w
endif
add r11.xyz, -r5, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.w, r2.z, r2
mul r4.y, r3.w, r2.w
add r11.xyz, -c21, r11
add r5.xyz, -r5, c18
dp3 r3.w, r11, r11
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.w, r3.w
rcp r3.w, r3.w
mul r3.w, r3, r4.y
rcp r4.y, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r7
mul r4.y, r4, c50.w
mul r2.y, r2, c30.x
mul r4.y, r4, r4
add r2.y, r2, c48.z
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c50
rcp r4.y, r4.y
mul r3.w, r3, r4.y
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.w, r3, c50
min r2.z, r3.w, c48
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c50.w
min r2.y, r2, c48.z
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r11.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c51.x
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r12.xyz, r2.y, c52, r2.z
mad r5.xyz, r10, r12, r5
mul r10.xyz, r3.z, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mul r3.xyz, r11, r3.z
mad r6.xyz, r3, r9, r6
mov r10.x, r5
pow r5, c50.x, r10.y
pow r3, c50.x, r10.z
mov r10.y, r5
mov r10.z, r3
mul r9.xyz, r9, r10
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r11.xyz, r6
cmp r2.w, -r2.z, c48.y, c48.z
cmp r3.x, r3, c48.y, c48.z
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r8.w, -r2, r2.z, r1
cmp_pp r1.w, -r8, c48.y, c48.z
cmp r9.w, -r2, r0, r2.y
mov r12.x, r4
mov r6.xyz, c47.z
if_gt r1.w, c47.z
frc r1.w, r8
add r1.w, r8, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r11.w, r1, r2.y, -r2.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r15.y, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r15, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r1.w, r5, c29.x
mad r14.xyz, r5.z, -c27, -r1.w
pow r4, c50.x, r14.x
pow r3, c50.x, r14.y
mov r4.y, r3
pow r3, c50.x, r14.z
add r3.x, r12, r9.w
add r2.z, -r12.x, r13.y
rcp r2.y, r9.w
add r1.w, r3.x, -r13.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c47.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r10
mov r4.w, c48.z
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r12.w, r1, c48.z, r12
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r1.w, r2.y, r2, c48.z
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c50.y, c50
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c47.y
mad r2.y, r2.z, r3.z, c48.z
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.y, r4.w, c47
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c48
mul r1.w, r1, r2.y
mul r12.w, r1, r2.z
endif
mul r12.xyz, r12, r12.w
endif
add r4.xyz, -r10, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r10.xyz, -r10, c18
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r10, r10
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r10
dp3 r1.w, r4, r7
mul r3.y, r3, c50.w
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c48.z
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c50
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c48
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c50
mul r2.y, r5, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r10.xyz, r9.w, -r10
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r5.xyz, r1.w, c52, r2.y
mad r4.xyz, r12, r5, r4
add r5.xyz, r4, c17
pow r4, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r4
pow r5, c50.x, r10.y
pow r4, c50.x, r10.z
mov r10.y, r5
mov r10.z, r4
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r1.w, r3, c29.x
mad r14.xyz, r3.z, -c27, -r1.w
pow r10, c50.x, r14.x
pow r4, c50.x, r14.y
add r1.w, r8, -r11
mul r3.z, r1.w, r9.w
add r1.w, r3.z, r12.x
mov r10.y, r4
pow r4, c50.x, r14.z
mov r10.z, r4
rcp r2.y, r3.z
add r1.w, r1, -r13.x
add r2.z, -r12.x, r13.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mul r4.xyz, r10, r1.w
mov r1.w, c47.z
mul r10.xyz, r4, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r5
mov r4.w, c48.z
dp4 r12.y, r4, c5
dp4 r12.x, r4, c4
cmp r7.w, r1, c48.z, r7
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r3, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c50.y, c50
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r1.w, c24.z
mov r4.xy, r12
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r2.y, r2, r2.w, c48.z
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r3.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r4.x, r4.z, c47.y
mad r2.y, r2.z, r4.x, c48.z
add r2.z, r3.w, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.w, r4, c47.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3.w, c48
mul r1.w, r1, r2.y
mul r7.w, r1, r2.z
endif
mul r10.xyz, r10, r7.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.w, r4, r4
rsq r3.w, r3.w
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.w, r3.w
mul r3.w, r3, r2
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r7
mul r2.w, r2, c50
mul r2.w, r2, r2
mul r1.w, r1, c30.x
rcp r4.x, r2.w
add r1.w, r1, c48.z
rcp r2.w, r1.w
mul r1.w, r3, r4.x
mul r2.y, r2, r2.w
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c50.w
mov r4.xyz, c19
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c48
mul r1.w, r2.y, c50
mul r2.y, r3, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r5.xyz, r3.z, -r5
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r12.xyz, r1.w, c52, r2.y
mad r4.xyz, r10, r12, r4
add r10.xyz, r4, c17
pow r4, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r4
pow r4, c50.x, r5.y
pow r3, c50.x, r5.z
mov r5.y, r4
mov r5.z, r3
mul r9.xyz, r9, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r6
cmp r2.z, -r2.y, c48.y, c48
cmp r2.w, r2, c48.y, c48.z
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r8.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r8.w, c48.y, c48
cmp r9.w, -r2.z, r0, r1
mov r12.x, r2
mov r6.xyz, c47.z
if_gt r1.z, c47.z
frc r1.z, r8.w
add r1.z, r8.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r11.w, r1.z, r1, -r1
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r2.xyz, r10, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r15.y, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r15.y, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c48
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r5, r2.xyzz, s1
mul r1.z, r5.w, c29.x
mad r14.xyz, r5.z, -c27, -r1.z
pow r2, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r2
pow r2, c50.x, r14.z
add r3.x, r12, r9.w
add r2.x, -r12, r13.y
rcp r1.w, r9.w
add r1.z, r3.x, -r13.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mov r14.z, r2
mul r2.xyz, r14, r1.z
mov r1.z, c47
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r15, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r10
mov r2.w, c48.z
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r12.w, r1.z, c48.z, r12
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r3.z, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c48
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c50.y, c50.z
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r12.w, r1.z, r2.x
endif
mul r12.xyz, r12, r12.w
endif
add r2.xyz, -r10, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r10.xyz, -r10, c18
dp3 r2.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r10
rcp r3.z, r1.z
dp3 r1.z, r2, r7
mul r2.x, r3.z, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c50
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c50.w
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r10.xyz, r9.w, -r10
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.z, r2
mul r2.w, r13, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r13
mad r5.xyz, r1.z, c52, r2.w
mul r2.xyz, r2, c51.y
mad r2.xyz, r12, r5, r2
add r5.xyz, r2, c17
pow r2, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r2
pow r5, c50.x, r10.y
pow r2, c50.x, r10.z
mov r10.y, r5
mov r10.z, r2
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.z, -r1, c48
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r3, r2.xyzz, s1
mul r1.z, r3.w, c29.x
mad r14.xyz, r3.z, -c27, -r1.z
pow r10, c50.x, r14.x
pow r2, c50.x, r14.y
add r1.z, r8.w, -r11.w
mul r3.z, r1, r9.w
add r1.z, r3, r12.x
mov r10.y, r2
pow r2, c50.x, r14.z
mov r10.z, r2
rcp r1.w, r3.z
add r1.z, r1, -r13.x
add r2.x, -r12, r13.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mul r2.xyz, r10, r1.z
mov r1.z, c47
mul r10.xyz, r2, c15
if_gt c34.x, r1.z
add r3.w, r5, -c11.x
add r1.z, r3.w, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r5
mov r2.w, c48.z
dp4 r12.y, r2, c5
dp4 r12.x, r2, c4
cmp r7.w, r1.z, c48.z, r7
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.w, -c25.x
mul_sat r1.z, r1, r1.w
mul r1.w, r1.z, r1.z
mov r2.xy, r12
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r4.w, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r3.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r4, c48.z
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r3, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r7.w, r1.z, r2.x
endif
mul r10.xyz, r10, r7.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.w, r1, r2
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.w, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r4.w, r1.z
dp3 r1.z, r2, r7
mul r2.x, r4.w, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r3.w, r2.y
mul r1.w, r1, r2.x
mul r3.w, r1, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c50
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c50.w
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r3.y, c28.x
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.w, r2
mul r5.xyz, r3.z, -r5
mul r2.xyz, r2, c51.y
mul r1.w, r13, r1
mul r1.z, r1, r13
mad r12.xyz, r1.z, c52, r1.w
mad r2.xyz, r10, r12, r2
add r10.xyz, r2, c17
pow r2, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r2
pow r3, c50.x, r5.y
pow r2, c50.x, r5.z
mov r5.y, r3
mov r5.z, r2
mul r9.xyz, r9, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c48, c48.z
cmp r2.x, -r1.w, c48.y, c48.z
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r8.w, -r2.x, r1, r1.y
cmp r9.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r8.w, c48, c48.z
mov r2.xyz, r6
mov r12.x, r1
mov r6.xyz, c47.z
if_gt r1.y, c47.z
frc r1.x, r8.w
add r1.x, r8.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r1.x, r1.y, -r1.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r1.xyz, r10, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r15.y, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r15.y, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r5, r1.xyzz, s1
mul r1.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r1.x
pow r1, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r1
pow r1, c50.x, r14.z
add r3.x, r12, r9.w
rcp r1.y, r9.w
add r1.w, -r12.x, r13.y
add r1.x, r3, -r13
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r14.z, r1
mul r1.xyz, r14, r1.x
mov r1.w, c47.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r10
mov r1.w, c48.z
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r12.w, r2, c48.z, r12
if_gt r1.x, c47.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r3.w, r1.x, c47.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c48.z
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c47.y
mad r3.z, -r2.w, c50.y, c50
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c48.z
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r12.w, r1.x, r1.z
endif
mul r12.xyz, r12, r12.w
endif
add r1.xyz, -r10, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
add r2.w, r1.x, c48.z
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r10.xyz, -r10, c18
dp3 r1.x, r10, r10
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r10
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c50.w
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r10.xyz, r9.w, -r10
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r13.w, r1.w
mul r1.w, r2, r13.z
mad r5.xyz, r1.w, c52, r3.y
mul r1.xyz, r1, c51.y
mad r1.xyz, r12, r5, r1
add r5.xyz, r1, c17
pow r1, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r1
pow r5, c50.x, r10.y
pow r1, c50.x, r10.z
mov r10.y, r5
mov r10.z, r1
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r3, r1.xyzz, s1
mul r1.x, r3.w, c29
mad r14.xyz, r3.z, -c27, -r1.x
pow r10, c50.x, r14.x
pow r1, c50.x, r14.y
add r1.x, r8.w, -r11.w
mov r10.y, r1
mul r3.z, r1.x, r9.w
pow r1, c50.x, r14.z
add r1.x, r3.z, r12
rcp r1.y, r3.z
add r1.x, r1, -r13
add r1.w, -r12.x, r13.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r10.z, r1
mul r1.xyz, r10, r1.x
mov r1.w, c47.z
mul r10.xyz, r1, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r2.w, r3, -c25
mov r1.xyz, r5
mov r1.w, c48.z
dp4 r12.y, r1, c5
dp4 r12.x, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r7.w, r2, c48.z, r7
if_gt r1.x, c47.z
mov r1.w, c24.x
add r2.w, -c25.x, r1
rcp r4.w, r2.w
add r2.w, r3, -c25.x
mul_sat r2.w, r2, r4
mul r4.w, r2, r2
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r4, r2
mov r1.xy, r12
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r5.w, r1.x, c47.y
mov r1.x, c24.y
add r4.w, -c25.y, r1.x
mad r1.x, r2.w, r5.w, c48.z
rcp r4.w, r4.w
add r2.w, r3, -c25.y
mul_sat r2.w, r2, r4
add r5.w, r1.y, c47.y
mad r4.w, -r2, c50.y, c50.z
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r4
mad r2.w, r2, r5, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3.w, -c25.z
mul_sat r1.y, r1, r2.w
add r4.w, r1.z, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r4.w, c48.z
rcp r2.w, r2.w
add r1.z, r3.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r7.w, r1.x, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
rcp r3.w, r1.y
add r2.w, r1.x, c48.z
mul r4.w, r2, r3
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r4.w, r4, r3
dp3 r1.x, r5, r5
rsq r3.w, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r4.w, r1.x, r4
mul r1.xyz, r3.w, r5
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r4.w, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.w, r3.w
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.w, r3, c50
mul r1.y, r3.w, r3.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r2.w, r3.y, c28.x
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r2.w, r1
mul r5.xyz, r3.z, -r5
mul r1.w, r1, r13.z
mul r2.w, r13, r2
mad r12.xyz, r1.w, c52, r2.w
mul r1.xyz, r1, c51.y
mad r1.xyz, r10, r12, r1
add r10.xyz, r1, c17
pow r1, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r1
pow r3, c50.x, r5.y
pow r1, c50.x, r5.z
mov r5.y, r3
mov r5.z, r1
mul r9.xyz, r9, r5
endif
add r1.x, r15, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c48.y, c48
cmp r1.y, -r0.z, c48, c48.z
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r8.w, -r1.y, r0.z, r0.y
cmp r9.w, -r1.y, r0, r1.x
mov r1.xyz, r6
cmp_pp r0.y, -r8.w, c48, c48.z
mov r12.x, r0
mov r6.xyz, c47.z
if_gt r0.y, c47.z
frc r0.x, r8.w
add r0.x, r8.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r11.w, r0.x, r0.y, -r0.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r0.xyz, r10, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r15.y, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r15.y, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r5, r0.xyzz, s1
mul r0.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r0.x
pow r0, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r0
pow r0, c50.x, r14.z
add r3.x, r12, r9.w
rcp r0.y, r9.w
add r0.w, -r12.x, r13.y
add r0.x, r3, -r13
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r14.z, r0
mul r0.xyz, r14, r0.x
mov r0.w, c47.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r10
mov r0.w, c48.z
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r12.w, r1, c48.z, r12
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r3.z, r0.x, c47.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c48.z
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c47.y
mad r2.w, -r1, c50.y, c50.z
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c48.z
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.y, c50.y, c50.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0, r0.y
mul r12.w, r0.x, r0.z
endif
mul r12.xyz, r12, r12.w
endif
add r0.xyz, -r10, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
add r1.w, r0.x, c48.z
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r10.xyz, -r10, c18
dp3 r0.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r10
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c50
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c50
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c48.z
mul r0.w, r0.x, c50
mul r1.w, r5.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r10.xyz, r9.w, -r10
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r5.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r12, r5, r0
add r5.xyz, r0, c17
pow r0, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r0
pow r5, c50.x, r10.y
pow r0, c50.x, r10.z
mov r10.y, r5
mov r10.z, r0
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r3, r0.xyzz, s1
mul r0.x, r3.w, c29
mad r8.xyz, r3.z, -c27, -r0.x
pow r0, c50.x, r8.y
pow r10, c50.x, r8.x
add r0.x, r8.w, -r11.w
mul r3.z, r0.x, r9.w
mov r8.y, r0
pow r0, c50.x, r8.z
add r0.x, r3.z, r12
rcp r0.y, r3.z
add r0.x, r0, -r13
add r0.w, -r12.x, r13.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r8.x, r10
mov r8.z, r0
mul r0.xyz, r8, r0.x
mov r0.w, c47.z
mul r10.xyz, r0, c15
if_gt c34.x, r0.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
mov r0.xyz, r5
mov r0.w, c48.z
dp4 r12.y, r0, c5
dp4 r12.x, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r7.w, r1, c48.z, r7
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r12
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r4.w, r0.x, c47.y
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r3.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c47.y
mad r0.y, -r0.x, c50, c50.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c48.z
mad r1.w, r1, r4, c48.z
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r3.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.x, c50.y, c50.z
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0.y, r0
mul r7.w, r0.x, r0.z
endif
mul r10.xyz, r10, r7.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c48.z
mul r3.w, r1, r2
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.w, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.w, r0.z, c50
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c50
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c50
min r0.y, r3.w, c48.z
mul r1.w, r3.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r5.xyz, r3.z, -r5
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r7.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r10, r7, r0
add r7.xyz, r0, c17
pow r0, c50.x, r5.x
mul r3.xyz, r7, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r0
pow r3, c50.x, r5.y
pow r0, c50.x, r5.z
mov r5.y, r3
mov r5.z, r0
mul r9.xyz, r9, r5
endif
mov r0, c36
mov r3, c37
add r0, -c40, r0
mad r0, r6.w, r0, c40
dp4 r7.x, r0, c48.z
add r3, -c41, r3
mad r3, r6.w, r3, c41
dp4 r0.x, r0, r0
mov r5, c39
mov r8, c38
add r5, -c43, r5
mad r5, r6.w, r5, c43
add r8, -c42, r8
mad r8, r6.w, r8, c42
dp4 r7.y, r3, c48.z
dp4 r0.y, r3, r3
dp4 r7.w, r5, c48.z
dp4 r7.z, r8, c48.z
add r7, r7, c47.y
dp4 r0.z, r8, r8
dp4 r0.w, r5, r5
mad r0, r0, r7, c48.z
mad r1.xyz, r6, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r11
mul r1.xyz, r0.y, c53
mad r1.xyz, r0.x, c54, r1
mad r0.xyz, r0.z, c55, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c51.z
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c51.z
add r0.z, r0.x, c51.w
cmp r0.z, r0, c48, c48.y
mul_pp r1.x, r0.z, c52.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c53.w
frc r1.x, r0
add r2.x, r0, -r1
add_pp r0.x, r2, c54.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c56, c56.y
mul r3.xyz, r9.y, c53
mad r1.xyz, r9.x, c54, r3
mad r1.xyz, r9.z, c55, r1
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.x, c55.w
mul_pp r0.x, r0, r2.y
mul r2.xy, r1, r1.z
mul r0.w, r0, c51.y
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c51
min r0.w, r0, c56.z
mad r0.z, r0, c56.w, r0.w
mad r0.z, r0, c57.x, c57.y
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c51.z
add r1.z, r1.x, c51.w
cmp r0.w, r1.z, c48.z, c48.y
mul_pp r1.z, r0.w, c52.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c51.y
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c53.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c55.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c56.z
mad r0.z, r0.x, c56.w, r1.x
add_pp r0.x, r0.y, c54.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c56, c56.y
mad r0.z, r0, c57.x, c57.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 renders sky with 1 cloud layer
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[57] = { program.local[0..46],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.001, 0.75 },
		{ 1, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625 } };
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
SHORT OUTPUT oCol = result.color;
MOVR  R5.x, c[48].y;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[47].x, -R0;
MOVR  R0.z, c[47].y;
DP3R  R0.w, R0, R0;
RSQR  R2.w, R0.w;
MULR  R0.xyz, R2.w, R0;
MOVR  R0.w, c[47].z;
DP4R  R1.z, R0, c[2];
DP4R  R1.y, R0, c[1];
DP4R  R1.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R8.x, c[48].y;
MOVR  R8.y, c[48];
MOVR  R8.z, c[48].y;
MOVR  R2.x, c[0].w;
MOVR  R2.z, c[2].w;
MOVR  R2.y, c[1].w;
MULR  R3.xyz, R2, c[13].x;
ADDR  R2.xyz, R3, -c[9];
DP3R  R1.w, R1, R2;
MULR  R3.w, R1, R1;
DP3R  R5.y, R2, R2;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
SLTR  R6, R3.w, R0;
MOVXC RC.x, R6;
MOVR  R5.x(EQ), R4;
ADDR  R4, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.x, R4.z;
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
ADDR  R5.x(NE.z), -R1.w, R4;
MOVXC RC.z, R6;
MOVR  R8.x(EQ.z), R5.z;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R8.x(NE.y), -R1.w, R0;
RSQR  R0.x, R4.w;
MOVXC RC.y, R6;
MOVR  R4.x, c[48];
MOVR  R4.z, c[48].x;
MOVR  R4.w, c[48].x;
MOVR  R8.y(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R8.y(NE.w), -R1.w, R0.x;
RSQR  R0.x, R4.y;
MOVR  R8.z(EQ.y), R5;
RCPR  R0.x, R0.x;
ADDR  R8.z(NE.x), -R1.w, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
ADDR  R6, R3.w, -R0;
RSQR  R4.y, R6.x;
SLTR  R7, R3.w, R0;
MOVXC RC.x, R7;
MOVR  R4.x(EQ), R5.z;
SGERC HC, R3.w, R0.yzxw;
RCPR  R4.y, R4.y;
ADDR  R4.x(NE.z), -R1.w, -R4.y;
MOVXC RC.z, R7;
MOVR  R4.z(EQ), R5;
RSQR  R0.x, R6.z;
RCPR  R0.x, R0.x;
ADDR  R4.z(NE.y), -R1.w, -R0.x;
MOVXC RC.z, R7.w;
RSQR  R0.x, R6.w;
MOVR  R4.w(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE), -R1, -R0.x;
RSQR  R0.x, R6.y;
MOVR  R4.y, c[48].x;
MOVXC RC.y, R7;
MOVR  R4.y(EQ), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.y(NE.x), -R1.w, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R5.y;
ADDR  R0.y, R3.w, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R6.x, c[48];
SLTRC HC.x, R3.w, R0;
MOVR  R6.x(EQ), R5.z;
MOVR  R0.zw, c[47].z;
SGERC HC.x, R3.w, R0;
MADR  R5.y, -c[12].x, c[12].x, R5;
ADDR  R0.x, R3.w, -R5.y;
RCPR  R0.y, R0.y;
ADDR  R6.x(NE), -R1.w, -R0.y;
MOVXC RC.x, R6;
MOVR  R6.x(LT), c[48];
SLTRC HC.x, R3.w, R5.y;
MOVR  R0.zw(EQ.x), R5;
SGERC HC.x, R3.w, R5.y;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, -R1.w, -R0.x;
ADDR  R1.w, -R1, R0.x;
MAXR  R0.x, R0.y, c[47].z;
MAXR  R0.y, R1.w, c[47].z;
MOVR  R0.zw(NE.x), R0.xyxy;
MOVR  R3.w, c[47];
DP4R  R0.x, R4, c[40];
MOVR  R5.y, R8.z;
MOVR  R5.w, R8.y;
MOVR  R5.z, R8.x;
DP4R  R0.y, R5, c[36];
DP4R  R1.w, R5, c[35];
SGER  R1.w, c[47].z, R1;
ADDR  R0.y, R0, -R0.x;
MADR  R0.y, R1.w, R0, R0.x;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
MULR  R3.w, R3, c[8];
RCPR  R2.w, R2.w;
MULR  R2.w, R0.x, R2;
MADR  R6.x, -R2.w, c[13], R6;
SGER  H0.x, R0, R3.w;
MULR  R2.w, R2, c[13].x;
MADR  R0.x, H0, R6, R2.w;
MINR  R6.w, R0, R0.x;
MAXR  R2.w, R0.z, c[48].z;
MINR  R0.x, R6.w, R0.y;
MAXR  R10.y, R2.w, R0.x;
ADDR  R6.y, R6.w, -R2.w;
RCPR  R0.x, R6.y;
MULR  R8.w, R0.x, c[32].x;
ADDR  R3.w, R10.y, -R2;
MULR  R6.x, R8.w, R3.w;
RCPR  R7.x, c[32].x;
MULR  R9.w, R6.y, R7.x;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R1.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MULR  R7.xyz, R1.zxyw, c[16].yzxw;
MOVR  R9.x, R0;
MOVR  R10.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R1.w, R0, c[46].y;
SLTR  H0.y, R6.x, R0.w;
SGTR  H0.x, R6, c[47].z;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R6.x;
RCPR  R6.z, R0.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R3, R6.z;
MULR  R6.xyz, R2.zxyw, c[16].yzxw;
MADR  R6.xyz, R2.yzxw, c[16].zxyw, -R6;
DP3R  R2.x, R2, c[16];
MOVR  R11.w(NE.x), R0;
SLER  H0.y, R2.x, c[47].z;
DP3R  R0.w, R6, R6;
MADR  R7.xyz, R1.yzxw, c[16].zxyw, -R7;
DP3R  R3.w, R6, R7;
DP3R  R6.x, R7, R7;
MADR  R0.w, -c[11].x, c[11].x, R0;
MULR  R6.z, R6.x, R0.w;
MULR  R6.y, R3.w, R3.w;
ADDR  R0.w, R6.y, -R6.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.y, -R3.w, R0.w;
MOVR  R2.z, c[48].y;
MOVR  R2.x, c[48];
ADDR  R0.w, -R3, -R0;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
SGTR  H0.z, R6.y, R6;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVXC RC.x, H0.y;
RCPR  R6.x, R6.x;
MULR  R2.z(NE.x), R6.x, R2.y;
MULR  R2.x(NE), R0.w, R6;
MOVR  R2.y, R2.z;
MOVR  R14.xy, R2;
MADR  R2.xyz, R1, R2.x, R3;
ADDR  R2.xyz, R2, -c[9];
DP3R  R0.w, R2, c[16];
SGTR  H0.z, R0.w, c[47];
MULXC HC.x, H0.y, H0.z;
MOVR  R14.xy(NE.x), c[48];
MOVXC RC.x, H0;
DP4R  R2.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R11.y, R10, R0.w;
DP4R  R2.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R13.x, R11.y, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R2.x, R5, c[39];
ADDR  R2.x, R2, -R0.w;
MADR  R0.w, R1, R2.x, R0;
MINR  R0.w, R6, R0;
DP3R  R0.y, R1, c[16];
MULR  R7.w, R0.x, c[33].x;
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[47];
MADR  R0.x, c[30], c[30], R0;
MADR  R14.z, R0.y, c[48].w, c[48].w;
ADDR  R0.y, R0.x, c[49].x;
MOVR  R0.x, c[49];
POWR  R0.y, R0.y, c[49].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R3.w, R13.x, R0;
MOVR  R11.x, R0.z;
MOVR  R4.w, R6;
MULR  R14.w, R0.x, R0.y;
MOVR  R4.xyz, c[49].x;
MOVR  R7.xyz, c[47].z;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R11.y, -R10.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R9.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R9.x;
RCPR  R0.z, R9.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R9.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R10.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R13, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R11.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R3.w, -R13;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R13.x;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R4.w, -R3.w;
MULR  R0.y, R0.x, R8.w;
MOVR  R13.xyz, R7;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVX  H0.x, c[47].z;
RCPR  R0.z, R7.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.w(NE.x), R7;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R3;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
ADDR  R6, R6.x, -c[25];
RCPR  R2.x, R5.y;
MULR_SAT R2.x, R6.y, R2;
MOVR  R3.w, c[50];
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R3.w;
RCPR  R2.x, R5.x;
MULR_SAT R5.x, R6, R2;
MULR  R4.w, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R4, -R4;
MULR  R2.y, R5.x, R5.x;
MADR  R0.z, -R5.x, c[47].x, R3.w;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R3.w;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R3.w;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.w, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R4.w, -R2, R3, R3;
MOVR  R2.xyz, c[21];
MULR  R3.w, R4, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R4.w, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
DP3R  R5.x, R2, R2;
MULR  R4.w, R4, R3;
RSQR  R3.w, R5.x;
MULR  R2.xyz, R3.w, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R4, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
RCPR  R2.w, R3.w;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R3, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R3.y, R3, R2;
MOVR  R2.y, c[50].w;
MADR  R5.x, -R3.y, c[47], R2.y;
MULR  R4.w, R3.y, R3.y;
RCPR  R3.y, R2.x;
MULR  R2.x, R4.w, R5;
TEX   R5, R0.zwzw, texture[2], 2D;
MULR_SAT R3.x, R3, R3.y;
MADR  R0.w, R5.y, R2.x, -R2.x;
MADR  R0.z, -R3.x, c[47].x, R2.y;
MULR  R2.x, R3, R3;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R5.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R3.w;
MULR_SAT R0.w, R0, R3.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R5.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R5, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R3.y, -R2.w, R3.x, R3.x;
MOVR  R2.xyz, c[21];
MULR  R3.x, R3.y, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R3.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
DP3R  R3.z, R2, R2;
MULR  R3.y, R3, R3.x;
RSQR  R3.x, R3.z;
MULR  R2.xyz, R3.x, R2;
DP3R  R1.x, R2, R1;
MADR  R0.z, R1.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R1.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R1.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R3.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R1.xyz, c[18];
ADDR  R1.xyz, -R1, c[19];
DP3R  R1.x, R1, R1;
RCPR  R2.x, R3.x;
MULR  R2.x, R2, c[51].w;
MULR  R1.y, R2.x, R2.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
RCPR  R1.y, R1.y;
MULR  R0.z, R1.x, R0;
MULR  R0.z, R0, R1.y;
MINR  R0.w, R0, c[49].x;
MULR  R1.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R1.xyz, R0.z, c[20], R1;
MULR  R0.z, R0.y, c[28].x;
MULR  R1.xyz, R1, c[52].x;
MULR  R1.xyz, R0.z, R1;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R2.xyz, R0.w, c[51], R0.z;
MULR  R1.xyz, R1, c[52].y;
MADR  R1.xyz, R12, R2, R1;
MULR  R0.y, R0, c[29].x;
ADDR  R1.xyz, R1, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R1.xyz, R1, R11.w;
MADR  R7.xyz, R1, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
MOVR  R2, c[41];
ADDR  R2, -R2, c[37];
MOVR  R0, c[40];
MOVR  R5, c[42];
MOVR  R8, c[43];
ADDR  R5, -R5, c[38];
ADDR  R0, -R0, c[36];
MADR  R3, R1.w, R2, c[41];
MADR  R2, R1.w, R0, c[40];
TEX   R4.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R0.yzw, c[49].x;
MOVR  R0.x, R4.w;
MADR  R5, R1.w, R5, c[42];
ADDR  R8, -R8, c[39];
MADR  R1, R1.w, R8, c[43];
DP4R  R6.w, R0, R1;
DP4R  R6.x, R0, R2;
DP4R  R6.y, R0, R3;
DP4R  R6.z, R0, R5;
DP4R  R0.w, R1, R1;
DP4R  R0.x, R2, R2;
DP4R  R0.y, R3, R3;
DP4R  R0.z, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[49].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R11;
MADR  R1.xyz, R1, R0.y, R10;
MADR  R0.xyz, R1, R0.x, R9;
MULR  R1.xyz, R0.y, c[55];
MADR  R1.xyz, R0.x, c[54], R1;
MADR  R0.xyz, R0.z, c[53], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[52].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[52].z;
SGER  H0.x, R0, c[52].w;
MULH  H0.y, H0.x, c[52].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[53].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[54].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[55].w;
MULR  R1.xyz, R4.y, c[55];
MADR  R1.xyz, R4.x, c[54], R1;
MADR  R1.xyz, R4.z, c[53], R1;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[52].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[47], H0.z;
MINR  R0.z, R1, c[52];
SGER  H0.z, R0, c[52].w;
ADDR  R0.x, R0, -H0.y;
MINR  R0.w, R0, c[50].x;
MADR  R0.x, R0, c[56], R0.w;
MULH  H0.y, H0.z, c[52].w;
ADDR  R0.w, R0.z, -H0.y;
MOVR  R0.z, c[49].x;
MADR  H0.y, R0.x, c[56], R0.z;
MULR  R1.x, R0.w, c[53].w;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[55].w;
ADDR  R0.x, R0.w, -H0;
ADDH  H0.x, H0.w, -c[54].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[50].x;
MADR  R0.x, R0, c[56], R0.y;
MADR  H0.z, R0.x, c[56].y, R0;
MADH  H0.x, H0.y, c[47], H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c47, 2.00000000, -1.00000000, 0.00000000, 0.99500000
def c48, 1000000.00000000, 0.00000000, 1.00000000, -1000000.00000000
def c49, 0.00100000, 0.75000000, 1.50000000, 0.50000000
defi i0, 255, 0, 1, 0
def c50, 2.71828198, 2.00000000, 3.00000000, 1000.00000000
def c51, 10.00000000, 400.00000000, 210.00000000, -128.00000000
def c52, 5.60204458, 9.47328472, 19.64380264, 128.00000000
def c53, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c54, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c55, 0.02411880, 0.12281780, 0.84442663, 4.00000000
def c56, 2.00000000, 1.00000000, 255.00000000, 256.00000000
def c57, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c47.x, c47.y
mov r0.z, c47.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.z, r0.w
mul r0.xyz, r2.z, r0
mov r0.w, c47.z
dp4 r7.z, r0, c2
dp4 r7.y, r0, c1
dp4 r7.x, r0, c0
mov r0.z, c11.x
mov r0.w, c11.x
mul r9.xyz, r7.zxyw, c16.yzxw
mad r9.xyz, r7.yzxw, c16.zxyw, -r9
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r8.xyz, r1, c13.x
add r6.xyz, r8, -c9
dp3 r0.y, r7, r6
dp3 r0.x, r6, r6
add r0.w, c25.y, r0
mad r1.x, -r0.w, r0.w, r0
mad r1.y, r0, r0, -r1.x
rsq r1.z, r1.y
add r0.z, c25.x, r0
mad r0.z, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.x, -r0.w, r0.z, r1
cmp_pp r0.w, r1.y, c48.z, c48.y
rcp r1.z, r1.z
add r1.z, -r0.y, -r1
cmp r1.y, r1, r1.w, c48.x
cmp r1.y, -r0.w, r1, r1.z
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.z, c25.w, r0
mad r0.w, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0.w
mad r1.z, -r1, r1, r0.x
mad r2.w, r0.y, r0.y, -r1.z
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.z, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.z, -r0.w, r0, r1
rsq r3.x, r2.w
rcp r3.x, r3.x
cmp r0.w, r2, r1, c48.x
add r3.x, -r0.y, -r3
cmp_pp r0.z, r2.w, c48, c48.y
cmp r1.w, -r0.z, r0, r3.x
mov r0.w, c11.x
add r2.w, c24.x, r0
mov r0.w, c11.x
add r3.x, c24.y, r0.w
mad r2.w, -r2, r2, r0.x
mad r0.w, r0.y, r0.y, -r2
mad r3.x, -r3, r3, r0
mad r3.y, r0, r0, -r3.x
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.x, -r2.w, r0.w, r3
rsq r3.z, r3.y
rcp r3.z, r3.z
dp4 r0.z, r1, c41
cmp r3.x, r3.y, r2, c48.w
add r3.z, -r0.y, r3
cmp_pp r2.w, r3.y, c48.z, c48.y
cmp r5.y, -r2.w, r3.x, r3.z
mov r0.w, c11.x
add r2.w, c24, r0
mad r2.w, -r2, r2, r0.x
mad r3.x, r0.y, r0.y, -r2.w
rsq r2.w, r3.x
rcp r3.y, r2.w
add r3.z, -r0.y, r3.y
cmp_pp r3.y, r3.x, c48.z, c48
cmp r3.x, r3, r2, c48.w
cmp r5.w, -r3.y, r3.x, r3.z
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r0.x
mad r0.w, r0.y, r0.y, -r0
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.z, -r2.w, r0.w, r3.x
dp4 r0.w, r5, c37
add r3.x, r0.w, -r0.z
dp4 r2.w, r5, c35
cmp r6.w, -r2, c48.z, c48.y
mad r0.z, r6.w, r3.x, r0
mov r0.w, c11.x
add r0.w, c31.x, r0
mad r0.w, -r0, r0, r0.x
mad r2.w, r0.y, r0.y, -r0
dp4 r3.y, r1, c40
dp4 r3.x, r5, c36
add r3.z, r3.x, -r3.y
rsq r0.w, r2.w
rcp r3.x, r0.w
mad r0.w, r6, r3.z, r3.y
add r3.y, -r0, -r3.x
cmp_pp r3.x, r2.w, c48.z, c48.y
cmp r2.w, r2, r2.x, c48.x
cmp r2.w, -r3.x, r2, r3.y
cmp r3.x, r2.w, r2.w, c48
mad r0.x, -c12, c12, r0
mad r2.w, r0.y, r0.y, -r0.x
cmp r2.xy, r2.w, r2, c47.z
rcp r2.z, r2.z
texldl r0.x, v0, s0
mul r3.y, r0.x, r2.z
mad r3.z, -r3.y, c13.x, r3.x
rsq r3.x, r2.w
mov r2.z, c8.w
mad r0.x, c47.w, -r2.z, r0
rcp r3.x, r3.x
mul r2.z, r3.y, c13.x
cmp r0.x, r0, c48.z, c48.y
mad r3.y, r0.x, r3.z, r2.z
add r0.x, -r0.y, -r3
add r0.y, -r0, r3.x
cmp_pp r2.z, r2.w, c48, c48.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
mad r2.w, r6, r2, c45.y
max r0.x, r0, c47.z
max r0.y, r0, c47.z
cmp r0.xy, -r2.z, r2, r0
min r3.x, r0.y, r3.y
max r12.x, r0, c49
min r0.y, r3.x, r0.w
min r0.x, r3, r0.z
max r4.x, r12, r0.y
dp4 r0.z, r1, c42
dp4 r0.y, r5, c38
add r0.y, r0, -r0.z
max r2.x, r4, r0
mad r0.x, r6.w, r0.y, r0.z
dp4 r0.z, r1, c43
dp4 r0.y, r5, c39
add r0.y, r0, -r0.z
min r0.x, r3, r0
mul r5.xyz, r6.zxyw, c16.yzxw
mad r0.y, r6.w, r0, r0.z
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r6, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r12.x
rcp r0.z, r0.y
mad r5.xyz, r6.yzxw, c16.zxyw, -r5
rcp r2.z, r1.w
add r1.y, r4.x, -r12.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c48, c48.z
cmp r0.w, -r1.z, c48.y, c48.z
mul_pp r2.y, r0.w, r2
cmp r8.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r9.w, -r2.y, r0, r1.y
dp3 r0.y, r5, r5
dp3 r1.y, r5, r9
dp3 r1.z, r9, r9
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
dp3 r0.y, r6, c16
rsq r2.z, r1.w
cmp r0.y, -r0, c48.z, c48
cmp r1.w, -r1, c48.y, c48.z
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c48.x, r1
mad r5.xyz, r7, r1.z, r8
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c48, r1
cmp r1.y, -r1, c48, c48.z
mul_pp r0.y, r0, r1
cmp r13.xy, -r0.y, r1.zwzw, c48.xwzw
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r6.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r6.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r6.w, r0, c46
dp3 r2.z, r7, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c48
mul r2.w, r2, c47.x
mad r2.w, c30.x, c30.x, r2
mul r13.z, r2, c49.y
mov r2.z, c30.x
add r2.z, c48, r2
add r2.w, r2, c48.z
mov r15.x, r3
pow r3, r2.w, c49.z
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r8.w, c48, c48.z
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r13.w, r2.z, r2
mov r9.xyz, c48.z
mov r6.xyz, c47.z
if_gt r2.y, c47.z
frc r2.y, r8.w
add r2.y, r8.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r11.w, r2.y, r2.z, -r2.z
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r15.y, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r15.y, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r2.y, r5.w, c29.x
mad r11.xyz, r5.z, -c27, -r2.y
pow r3, c50.x, r11.y
pow r14, c50.x, r11.x
mov r11.y, r3
pow r3, c50.x, r11.z
add r3.x, r12, r9.w
add r2.w, -r12.x, r13.y
rcp r2.z, r9.w
add r2.y, r3.x, -r13.x
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r3
mul r11.xyz, r11, r2.y
mov r2.y, c47.z
mul r12.xyz, r11, c15
if_gt c34.x, r2.y
add r3.y, r15, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r14.xyz, r10
mov r14.w, c48.z
dp4 r3.w, r14, c5
dp4 r3.z, r14, c4
cmp r12.w, r2.y, c48.z, r12
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r11.xy, r3.zwzw
mov r11.z, c47
texldl r14, r11.xyzz, s2
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r14.x, c47.y
mad r2.y, r2.z, r3.z, c48.z
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r14.y, c47.y
mad r2.w, r2, r3.z, c48.z
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c50.y, c50
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r14.z, c47.y
mad r2.z, r2.w, r3.w, c48
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c50, c50.z
mul r2.w, r2, r2
add r3.z, r14.w, c47.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c48.z
mul r2.y, r2, r2.z
mul r12.w, r2.y, r2
endif
mul r12.xyz, r12, r12.w
endif
add r11.xyz, -r10, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
add r11.xyz, -c21, r11
dp3 r3.z, r11, r11
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r10.xyz, -r10, c18
dp3 r3.y, r10, r10
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r10.xyz, r3.y, r10
dp3 r2.y, r10, r7
mul r3.z, r3, c50.w
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r10.xyz, c19
add r2.y, r2, c48.z
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c50.w
add r10.xyz, -c18, r10
dp3 r2.z, r10, r10
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c50.w
min r2.w, r2.y, c48.z
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c50.w
mul r2.z, r5.y, c28.x
min r2.y, r2, c48.z
mul r10.xyz, r2.w, c23
mad r10.xyz, r2.y, c20, r10
mul r2.y, r5, c29.x
mad r11.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r10.xyz, r10, c51.x
mul r10.xyz, r2.z, r10
mul r10.xyz, r10, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r5.xyz, r2.y, c52, r2.z
mad r5.xyz, r12, r5, r10
mul r10.xyz, r9.w, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mov r10.x, r5
pow r14, c50.x, r10.y
pow r5, c50.x, r10.z
mul r11.xyz, r11, r9.w
mad r6.xyz, r11, r9, r6
mov r10.y, r14
mov r10.z, r5
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r2.y, r3.w, c29.x
mad r11.xyz, r3.z, -c27, -r2.y
pow r10, c50.x, r11.y
pow r14, c50.x, r11.x
add r2.y, r8.w, -r11.w
mul r3.z, r2.y, r9.w
mov r11.y, r10
pow r10, c50.x, r11.z
add r2.y, r3.z, r12.x
rcp r2.z, r3.z
add r2.y, r2, -r13.x
add r2.w, -r12.x, r13.y
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r10
mul r10.xyz, r11, r2.y
mov r2.y, c47.z
mul r10.xyz, r10, c15
if_gt c34.x, r2.y
add r3.w, r5, -c11.x
add r2.y, r3.w, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r11.xyz, r5
mov r11.w, c48.z
dp4 r12.y, r11, c5
dp4 r12.x, r11, c4
cmp r7.w, r2.y, c48.z, r7
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3.w, -c25.x
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r3.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c50.y, c50.z
mul r2.y, r2, r2
mul r2.w, r2.y, r2
mov r2.y, c24.z
mov r11.xy, r12
mov r11.z, c47
texldl r11, r11.xyzz, s2
add r4.y, r11.x, c47
mad r2.z, r2, r4.y, c48
add r4.y, r11, c47
mad r2.w, r2, r4.y, c48.z
add r4.y, -c25.z, r2
mul r2.y, r2.z, r2.w
rcp r2.w, r4.y
add r2.z, r3.w, -c25
mul_sat r2.z, r2, r2.w
mad r4.y, -r2.z, c50, c50.z
mul r2.w, r2.z, r2.z
mul r2.w, r2, r4.y
mov r2.z, c24.w
add r4.y, -c25.w, r2.z
add r4.z, r11, c47.y
mad r2.z, r2.w, r4, c48
rcp r4.y, r4.y
add r2.w, r3, -c25
mul_sat r2.w, r2, r4.y
mad r3.w, -r2, c50.y, c50.z
mul r2.w, r2, r2
add r4.y, r11.w, c47
mul r2.w, r2, r3
mad r2.w, r2, r4.y, c48.z
mul r2.y, r2, r2.z
mul r7.w, r2.y, r2
endif
mul r10.xyz, r10, r7.w
endif
add r11.xyz, -r5, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.w, r2.z, r2
mul r4.y, r3.w, r2.w
add r11.xyz, -c21, r11
add r5.xyz, -r5, c18
dp3 r3.w, r11, r11
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.w, r3.w
rcp r3.w, r3.w
mul r3.w, r3, r4.y
rcp r4.y, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r7
mul r4.y, r4, c50.w
mul r2.y, r2, c30.x
mul r4.y, r4, r4
add r2.y, r2, c48.z
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c50
rcp r4.y, r4.y
mul r3.w, r3, r4.y
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.w, r3, c50
min r2.z, r3.w, c48
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c50.w
min r2.y, r2, c48.z
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r11.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c51.x
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r12.xyz, r2.y, c52, r2.z
mad r5.xyz, r10, r12, r5
mul r10.xyz, r3.z, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mul r3.xyz, r11, r3.z
mad r6.xyz, r3, r9, r6
mov r10.x, r5
pow r5, c50.x, r10.y
pow r3, c50.x, r10.z
mov r10.y, r5
mov r10.z, r3
mul r9.xyz, r9, r10
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r11.xyz, r6
cmp r2.w, -r2.z, c48.y, c48.z
cmp r3.x, r3, c48.y, c48.z
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r8.w, -r2, r2.z, r1
cmp_pp r1.w, -r8, c48.y, c48.z
cmp r9.w, -r2, r0, r2.y
mov r12.x, r4
mov r6.xyz, c47.z
if_gt r1.w, c47.z
frc r1.w, r8
add r1.w, r8, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r11.w, r1, r2.y, -r2.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r15.y, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r15, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r1.w, r5, c29.x
mad r14.xyz, r5.z, -c27, -r1.w
pow r4, c50.x, r14.x
pow r3, c50.x, r14.y
mov r4.y, r3
pow r3, c50.x, r14.z
add r3.x, r12, r9.w
add r2.z, -r12.x, r13.y
rcp r2.y, r9.w
add r1.w, r3.x, -r13.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c47.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r10
mov r4.w, c48.z
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r12.w, r1, c48.z, r12
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r1.w, r2.y, r2, c48.z
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c50.y, c50
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c47.y
mad r2.y, r2.z, r3.z, c48.z
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.y, r4.w, c47
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c48
mul r1.w, r1, r2.y
mul r12.w, r1, r2.z
endif
mul r12.xyz, r12, r12.w
endif
add r4.xyz, -r10, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r10.xyz, -r10, c18
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r10, r10
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r10
dp3 r1.w, r4, r7
mul r3.y, r3, c50.w
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c48.z
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c50
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c48
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c50
mul r2.y, r5, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r10.xyz, r9.w, -r10
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r5.xyz, r1.w, c52, r2.y
mad r4.xyz, r12, r5, r4
add r5.xyz, r4, c17
pow r4, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r4
pow r5, c50.x, r10.y
pow r4, c50.x, r10.z
mov r10.y, r5
mov r10.z, r4
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r1.w, r3, c29.x
mad r14.xyz, r3.z, -c27, -r1.w
pow r10, c50.x, r14.x
pow r4, c50.x, r14.y
add r1.w, r8, -r11
mul r3.z, r1.w, r9.w
add r1.w, r3.z, r12.x
mov r10.y, r4
pow r4, c50.x, r14.z
mov r10.z, r4
rcp r2.y, r3.z
add r1.w, r1, -r13.x
add r2.z, -r12.x, r13.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mul r4.xyz, r10, r1.w
mov r1.w, c47.z
mul r10.xyz, r4, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r5
mov r4.w, c48.z
dp4 r12.y, r4, c5
dp4 r12.x, r4, c4
cmp r7.w, r1, c48.z, r7
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r3, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c50.y, c50
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r1.w, c24.z
mov r4.xy, r12
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r2.y, r2, r2.w, c48.z
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r3.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r4.x, r4.z, c47.y
mad r2.y, r2.z, r4.x, c48.z
add r2.z, r3.w, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.w, r4, c47.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3.w, c48
mul r1.w, r1, r2.y
mul r7.w, r1, r2.z
endif
mul r10.xyz, r10, r7.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.w, r4, r4
rsq r3.w, r3.w
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.w, r3.w
mul r3.w, r3, r2
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r7
mul r2.w, r2, c50
mul r2.w, r2, r2
mul r1.w, r1, c30.x
rcp r4.x, r2.w
add r1.w, r1, c48.z
rcp r2.w, r1.w
mul r1.w, r3, r4.x
mul r2.y, r2, r2.w
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c50.w
mov r4.xyz, c19
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c48
mul r1.w, r2.y, c50
mul r2.y, r3, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r5.xyz, r3.z, -r5
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r12.xyz, r1.w, c52, r2.y
mad r4.xyz, r10, r12, r4
add r10.xyz, r4, c17
pow r4, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r4
pow r4, c50.x, r5.y
pow r3, c50.x, r5.z
mov r5.y, r4
mov r5.z, r3
mul r9.xyz, r9, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r6
cmp r2.z, -r2.y, c48.y, c48
cmp r2.w, r2, c48.y, c48.z
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r8.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r8.w, c48.y, c48
cmp r9.w, -r2.z, r0, r1
mov r12.x, r2
mov r6.xyz, c47.z
if_gt r1.z, c47.z
frc r1.z, r8.w
add r1.z, r8.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r11.w, r1.z, r1, -r1
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r2.xyz, r10, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r15.y, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r15.y, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c48
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r5, r2.xyzz, s1
mul r1.z, r5.w, c29.x
mad r14.xyz, r5.z, -c27, -r1.z
pow r2, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r2
pow r2, c50.x, r14.z
add r3.x, r12, r9.w
add r2.x, -r12, r13.y
rcp r1.w, r9.w
add r1.z, r3.x, -r13.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mov r14.z, r2
mul r2.xyz, r14, r1.z
mov r1.z, c47
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r15, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r10
mov r2.w, c48.z
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r12.w, r1.z, c48.z, r12
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r3.z, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c48
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c50.y, c50.z
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r12.w, r1.z, r2.x
endif
mul r12.xyz, r12, r12.w
endif
add r2.xyz, -r10, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r10.xyz, -r10, c18
dp3 r2.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r10
rcp r3.z, r1.z
dp3 r1.z, r2, r7
mul r2.x, r3.z, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c50
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c50.w
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r10.xyz, r9.w, -r10
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.z, r2
mul r2.w, r13, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r13
mad r5.xyz, r1.z, c52, r2.w
mul r2.xyz, r2, c51.y
mad r2.xyz, r12, r5, r2
add r5.xyz, r2, c17
pow r2, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r2
pow r5, c50.x, r10.y
pow r2, c50.x, r10.z
mov r10.y, r5
mov r10.z, r2
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.z, -r1, c48
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r3, r2.xyzz, s1
mul r1.z, r3.w, c29.x
mad r14.xyz, r3.z, -c27, -r1.z
pow r10, c50.x, r14.x
pow r2, c50.x, r14.y
add r1.z, r8.w, -r11.w
mul r3.z, r1, r9.w
add r1.z, r3, r12.x
mov r10.y, r2
pow r2, c50.x, r14.z
mov r10.z, r2
rcp r1.w, r3.z
add r1.z, r1, -r13.x
add r2.x, -r12, r13.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mul r2.xyz, r10, r1.z
mov r1.z, c47
mul r10.xyz, r2, c15
if_gt c34.x, r1.z
add r3.w, r5, -c11.x
add r1.z, r3.w, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r5
mov r2.w, c48.z
dp4 r12.y, r2, c5
dp4 r12.x, r2, c4
cmp r7.w, r1.z, c48.z, r7
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.w, -c25.x
mul_sat r1.z, r1, r1.w
mul r1.w, r1.z, r1.z
mov r2.xy, r12
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r4.w, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r3.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r4, c48.z
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r3, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r7.w, r1.z, r2.x
endif
mul r10.xyz, r10, r7.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.w, r1, r2
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.w, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r4.w, r1.z
dp3 r1.z, r2, r7
mul r2.x, r4.w, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r3.w, r2.y
mul r1.w, r1, r2.x
mul r3.w, r1, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c50
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c50.w
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r3.y, c28.x
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.w, r2
mul r5.xyz, r3.z, -r5
mul r2.xyz, r2, c51.y
mul r1.w, r13, r1
mul r1.z, r1, r13
mad r12.xyz, r1.z, c52, r1.w
mad r2.xyz, r10, r12, r2
add r10.xyz, r2, c17
pow r2, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r2
pow r3, c50.x, r5.y
pow r2, c50.x, r5.z
mov r5.y, r3
mov r5.z, r2
mul r9.xyz, r9, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c48, c48.z
cmp r2.x, -r1.w, c48.y, c48.z
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r8.w, -r2.x, r1, r1.y
cmp r9.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r8.w, c48, c48.z
mov r2.xyz, r6
mov r12.x, r1
mov r6.xyz, c47.z
if_gt r1.y, c47.z
frc r1.x, r8.w
add r1.x, r8.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r1.x, r1.y, -r1.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r1.xyz, r10, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r15.y, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r15.y, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r5, r1.xyzz, s1
mul r1.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r1.x
pow r1, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r1
pow r1, c50.x, r14.z
add r3.x, r12, r9.w
rcp r1.y, r9.w
add r1.w, -r12.x, r13.y
add r1.x, r3, -r13
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r14.z, r1
mul r1.xyz, r14, r1.x
mov r1.w, c47.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r10
mov r1.w, c48.z
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r12.w, r2, c48.z, r12
if_gt r1.x, c47.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r3.w, r1.x, c47.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c48.z
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c47.y
mad r3.z, -r2.w, c50.y, c50
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c48.z
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r12.w, r1.x, r1.z
endif
mul r12.xyz, r12, r12.w
endif
add r1.xyz, -r10, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
add r2.w, r1.x, c48.z
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r10.xyz, -r10, c18
dp3 r1.x, r10, r10
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r10
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c50.w
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r10.xyz, r9.w, -r10
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r13.w, r1.w
mul r1.w, r2, r13.z
mad r5.xyz, r1.w, c52, r3.y
mul r1.xyz, r1, c51.y
mad r1.xyz, r12, r5, r1
add r5.xyz, r1, c17
pow r1, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r1
pow r5, c50.x, r10.y
pow r1, c50.x, r10.z
mov r10.y, r5
mov r10.z, r1
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r3, r1.xyzz, s1
mul r1.x, r3.w, c29
mad r14.xyz, r3.z, -c27, -r1.x
pow r10, c50.x, r14.x
pow r1, c50.x, r14.y
add r1.x, r8.w, -r11.w
mov r10.y, r1
mul r3.z, r1.x, r9.w
pow r1, c50.x, r14.z
add r1.x, r3.z, r12
rcp r1.y, r3.z
add r1.x, r1, -r13
add r1.w, -r12.x, r13.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r10.z, r1
mul r1.xyz, r10, r1.x
mov r1.w, c47.z
mul r10.xyz, r1, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r2.w, r3, -c25
mov r1.xyz, r5
mov r1.w, c48.z
dp4 r12.y, r1, c5
dp4 r12.x, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r7.w, r2, c48.z, r7
if_gt r1.x, c47.z
mov r1.w, c24.x
add r2.w, -c25.x, r1
rcp r4.w, r2.w
add r2.w, r3, -c25.x
mul_sat r2.w, r2, r4
mul r4.w, r2, r2
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r4, r2
mov r1.xy, r12
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r5.w, r1.x, c47.y
mov r1.x, c24.y
add r4.w, -c25.y, r1.x
mad r1.x, r2.w, r5.w, c48.z
rcp r4.w, r4.w
add r2.w, r3, -c25.y
mul_sat r2.w, r2, r4
add r5.w, r1.y, c47.y
mad r4.w, -r2, c50.y, c50.z
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r4
mad r2.w, r2, r5, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3.w, -c25.z
mul_sat r1.y, r1, r2.w
add r4.w, r1.z, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r4.w, c48.z
rcp r2.w, r2.w
add r1.z, r3.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r7.w, r1.x, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
rcp r3.w, r1.y
add r2.w, r1.x, c48.z
mul r4.w, r2, r3
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r4.w, r4, r3
dp3 r1.x, r5, r5
rsq r3.w, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r4.w, r1.x, r4
mul r1.xyz, r3.w, r5
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r4.w, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.w, r3.w
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.w, r3, c50
mul r1.y, r3.w, r3.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r2.w, r3.y, c28.x
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r2.w, r1
mul r5.xyz, r3.z, -r5
mul r1.w, r1, r13.z
mul r2.w, r13, r2
mad r12.xyz, r1.w, c52, r2.w
mul r1.xyz, r1, c51.y
mad r1.xyz, r10, r12, r1
add r10.xyz, r1, c17
pow r1, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r1
pow r3, c50.x, r5.y
pow r1, c50.x, r5.z
mov r5.y, r3
mov r5.z, r1
mul r9.xyz, r9, r5
endif
add r1.x, r15, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c48.y, c48
cmp r1.y, -r0.z, c48, c48.z
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r8.w, -r1.y, r0.z, r0.y
cmp r9.w, -r1.y, r0, r1.x
mov r1.xyz, r6
cmp_pp r0.y, -r8.w, c48, c48.z
mov r12.x, r0
mov r6.xyz, c47.z
if_gt r0.y, c47.z
frc r0.x, r8.w
add r0.x, r8.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r11.w, r0.x, r0.y, -r0.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r0.xyz, r10, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r15.y, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r15.y, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r5, r0.xyzz, s1
mul r0.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r0.x
pow r0, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r0
pow r0, c50.x, r14.z
add r3.x, r12, r9.w
rcp r0.y, r9.w
add r0.w, -r12.x, r13.y
add r0.x, r3, -r13
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r14.z, r0
mul r0.xyz, r14, r0.x
mov r0.w, c47.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r10
mov r0.w, c48.z
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r12.w, r1, c48.z, r12
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r3.z, r0.x, c47.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c48.z
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c47.y
mad r2.w, -r1, c50.y, c50.z
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c48.z
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.y, c50.y, c50.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0, r0.y
mul r12.w, r0.x, r0.z
endif
mul r12.xyz, r12, r12.w
endif
add r0.xyz, -r10, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
add r1.w, r0.x, c48.z
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r10.xyz, -r10, c18
dp3 r0.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r10
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c50
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c50
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c48.z
mul r0.w, r0.x, c50
mul r1.w, r5.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r10.xyz, r9.w, -r10
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r5.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r12, r5, r0
add r5.xyz, r0, c17
pow r0, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r0
pow r5, c50.x, r10.y
pow r0, c50.x, r10.z
mov r10.y, r5
mov r10.z, r0
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r3, r0.xyzz, s1
mul r0.x, r3.w, c29
mad r8.xyz, r3.z, -c27, -r0.x
pow r0, c50.x, r8.y
pow r10, c50.x, r8.x
add r0.x, r8.w, -r11.w
mul r3.z, r0.x, r9.w
mov r8.y, r0
pow r0, c50.x, r8.z
add r0.x, r3.z, r12
rcp r0.y, r3.z
add r0.x, r0, -r13
add r0.w, -r12.x, r13.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r8.x, r10
mov r8.z, r0
mul r0.xyz, r8, r0.x
mov r0.w, c47.z
mul r10.xyz, r0, c15
if_gt c34.x, r0.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
mov r0.xyz, r5
mov r0.w, c48.z
dp4 r12.y, r0, c5
dp4 r12.x, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r7.w, r1, c48.z, r7
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r12
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r4.w, r0.x, c47.y
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r3.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c47.y
mad r0.y, -r0.x, c50, c50.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c48.z
mad r1.w, r1, r4, c48.z
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r3.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.x, c50.y, c50.z
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0.y, r0
mul r7.w, r0.x, r0.z
endif
mul r10.xyz, r10, r7.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c48.z
mul r3.w, r1, r2
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.w, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.w, r0.z, c50
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c50
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c50
min r0.y, r3.w, c48.z
mul r1.w, r3.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r5.xyz, r3.z, -r5
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r7.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r10, r7, r0
add r7.xyz, r0, c17
pow r0, c50.x, r5.x
mul r3.xyz, r7, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r0
pow r3, c50.x, r5.y
pow r0, c50.x, r5.z
mov r5.y, r3
mov r5.z, r0
mul r9.xyz, r9, r5
endif
mov r3, c37
add r3, -c41, r3
mov r0, c36
mov r7, c39
mov r8, c38
add r7, -c43, r7
add r8, -c42, r8
add r0, -c40, r0
mad r5, r6.w, r3, c41
mad r3, r6.w, r0, c40
texldl r1.w, v0, s3
mov r0.x, r1.w
mov r0.yzw, c48.z
dp4 r10.x, r3, r0
dp4 r3.x, r3, r3
mad r7, r6.w, r7, c43
mad r8, r6.w, r8, c42
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r10.y, r5, r0
dp4 r10.w, r7, r0
dp4 r10.z, r8, r0
add r0, r10, c47.y
dp4 r3.w, r7, r7
mad r0, r3, r0, c48.z
mad r1.xyz, r6, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r11
mul r1.xyz, r0.y, c53
mad r1.xyz, r0.x, c54, r1
mad r0.xyz, r0.z, c55, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c51.z
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c51.z
add r0.z, r0.x, c51.w
cmp r0.z, r0, c48, c48.y
mul_pp r1.x, r0.z, c52.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c53.w
frc r1.x, r0
add r2.x, r0, -r1
add_pp r0.x, r2, c54.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c56, c56.y
mul r3.xyz, r9.y, c53
mad r1.xyz, r9.x, c54, r3
mad r1.xyz, r9.z, c55, r1
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.x, c55.w
mul_pp r0.x, r0, r2.y
mul r2.xy, r1, r1.z
mul r0.w, r0, c51.y
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c51
min r0.w, r0, c56.z
mad r0.z, r0, c56.w, r0.w
mad r0.z, r0, c57.x, c57.y
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c51.z
add r1.z, r1.x, c51.w
cmp r0.w, r1.z, c48.z, c48.y
mul_pp r1.z, r0.w, c52.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c51.y
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c53.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c55.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c56.z
mad r0.z, r0.x, c56.w, r1.x
add_pp r0.x, r0.y, c54.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c56, c56.y
mad r0.z, r0, c57.x, c57.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 renders sky with 2 cloud layers
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[57] = { program.local[0..46],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.001, 0.75 },
		{ 1, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625 } };
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
SHORT OUTPUT oCol = result.color;
MOVR  R5.x, c[48].y;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[47].x, -R0;
MOVR  R0.z, c[47].y;
DP3R  R0.w, R0, R0;
RSQR  R2.w, R0.w;
MULR  R0.xyz, R2.w, R0;
MOVR  R0.w, c[47].z;
DP4R  R1.z, R0, c[2];
DP4R  R1.y, R0, c[1];
DP4R  R1.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R8.x, c[48].y;
MOVR  R8.y, c[48];
MOVR  R8.z, c[48].y;
MOVR  R2.x, c[0].w;
MOVR  R2.z, c[2].w;
MOVR  R2.y, c[1].w;
MULR  R3.xyz, R2, c[13].x;
ADDR  R2.xyz, R3, -c[9];
DP3R  R1.w, R1, R2;
MULR  R3.w, R1, R1;
DP3R  R5.y, R2, R2;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
SLTR  R6, R3.w, R0;
MOVXC RC.x, R6;
MOVR  R5.x(EQ), R4;
ADDR  R4, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.x, R4.z;
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
ADDR  R5.x(NE.z), -R1.w, R4;
MOVXC RC.z, R6;
MOVR  R8.x(EQ.z), R5.z;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R8.x(NE.y), -R1.w, R0;
RSQR  R0.x, R4.w;
MOVXC RC.y, R6;
MOVR  R4.x, c[48];
MOVR  R4.z, c[48].x;
MOVR  R4.w, c[48].x;
MOVR  R8.y(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R8.y(NE.w), -R1.w, R0.x;
RSQR  R0.x, R4.y;
MOVR  R8.z(EQ.y), R5;
RCPR  R0.x, R0.x;
ADDR  R8.z(NE.x), -R1.w, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
ADDR  R6, R3.w, -R0;
RSQR  R4.y, R6.x;
SLTR  R7, R3.w, R0;
MOVXC RC.x, R7;
MOVR  R4.x(EQ), R5.z;
SGERC HC, R3.w, R0.yzxw;
RCPR  R4.y, R4.y;
ADDR  R4.x(NE.z), -R1.w, -R4.y;
MOVXC RC.z, R7;
MOVR  R4.z(EQ), R5;
RSQR  R0.x, R6.z;
RCPR  R0.x, R0.x;
ADDR  R4.z(NE.y), -R1.w, -R0.x;
MOVXC RC.z, R7.w;
RSQR  R0.x, R6.w;
MOVR  R4.w(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE), -R1, -R0.x;
RSQR  R0.x, R6.y;
MOVR  R4.y, c[48].x;
MOVXC RC.y, R7;
MOVR  R4.y(EQ), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.y(NE.x), -R1.w, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R5.y;
ADDR  R0.y, R3.w, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R6.x, c[48];
SLTRC HC.x, R3.w, R0;
MOVR  R6.x(EQ), R5.z;
MOVR  R0.zw, c[47].z;
SGERC HC.x, R3.w, R0;
MADR  R5.y, -c[12].x, c[12].x, R5;
ADDR  R0.x, R3.w, -R5.y;
RCPR  R0.y, R0.y;
ADDR  R6.x(NE), -R1.w, -R0.y;
MOVXC RC.x, R6;
MOVR  R6.x(LT), c[48];
SLTRC HC.x, R3.w, R5.y;
MOVR  R0.zw(EQ.x), R5;
SGERC HC.x, R3.w, R5.y;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, -R1.w, -R0.x;
ADDR  R1.w, -R1, R0.x;
MAXR  R0.x, R0.y, c[47].z;
MAXR  R0.y, R1.w, c[47].z;
MOVR  R0.zw(NE.x), R0.xyxy;
MOVR  R3.w, c[47];
DP4R  R0.x, R4, c[40];
MOVR  R5.y, R8.z;
MOVR  R5.w, R8.y;
MOVR  R5.z, R8.x;
DP4R  R0.y, R5, c[36];
DP4R  R1.w, R5, c[35];
SGER  R1.w, c[47].z, R1;
ADDR  R0.y, R0, -R0.x;
MADR  R0.y, R1.w, R0, R0.x;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
MULR  R3.w, R3, c[8];
RCPR  R2.w, R2.w;
MULR  R2.w, R0.x, R2;
MADR  R6.x, -R2.w, c[13], R6;
SGER  H0.x, R0, R3.w;
MULR  R2.w, R2, c[13].x;
MADR  R0.x, H0, R6, R2.w;
MINR  R6.w, R0, R0.x;
MAXR  R2.w, R0.z, c[48].z;
MINR  R0.x, R6.w, R0.y;
MAXR  R10.y, R2.w, R0.x;
ADDR  R6.y, R6.w, -R2.w;
RCPR  R0.x, R6.y;
MULR  R8.w, R0.x, c[32].x;
ADDR  R3.w, R10.y, -R2;
MULR  R6.x, R8.w, R3.w;
RCPR  R7.x, c[32].x;
MULR  R9.w, R6.y, R7.x;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R1.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MULR  R7.xyz, R1.zxyw, c[16].yzxw;
MOVR  R9.x, R0;
MOVR  R10.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R1.w, R0, c[46].y;
SLTR  H0.y, R6.x, R0.w;
SGTR  H0.x, R6, c[47].z;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R6.x;
RCPR  R6.z, R0.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R3, R6.z;
MULR  R6.xyz, R2.zxyw, c[16].yzxw;
MADR  R6.xyz, R2.yzxw, c[16].zxyw, -R6;
DP3R  R2.x, R2, c[16];
MOVR  R11.w(NE.x), R0;
SLER  H0.y, R2.x, c[47].z;
DP3R  R0.w, R6, R6;
MADR  R7.xyz, R1.yzxw, c[16].zxyw, -R7;
DP3R  R3.w, R6, R7;
DP3R  R6.x, R7, R7;
MADR  R0.w, -c[11].x, c[11].x, R0;
MULR  R6.z, R6.x, R0.w;
MULR  R6.y, R3.w, R3.w;
ADDR  R0.w, R6.y, -R6.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.y, -R3.w, R0.w;
MOVR  R2.z, c[48].y;
MOVR  R2.x, c[48];
ADDR  R0.w, -R3, -R0;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
SGTR  H0.z, R6.y, R6;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVXC RC.x, H0.y;
RCPR  R6.x, R6.x;
MULR  R2.z(NE.x), R6.x, R2.y;
MULR  R2.x(NE), R0.w, R6;
MOVR  R2.y, R2.z;
MOVR  R14.xy, R2;
MADR  R2.xyz, R1, R2.x, R3;
ADDR  R2.xyz, R2, -c[9];
DP3R  R0.w, R2, c[16];
SGTR  H0.z, R0.w, c[47];
MULXC HC.x, H0.y, H0.z;
MOVR  R14.xy(NE.x), c[48];
MOVXC RC.x, H0;
DP4R  R2.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R11.y, R10, R0.w;
DP4R  R2.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R13.x, R11.y, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R2.x, R5, c[39];
ADDR  R2.x, R2, -R0.w;
MADR  R0.w, R1, R2.x, R0;
MINR  R0.w, R6, R0;
DP3R  R0.y, R1, c[16];
MULR  R7.w, R0.x, c[33].x;
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[47];
MADR  R0.x, c[30], c[30], R0;
MADR  R14.z, R0.y, c[48].w, c[48].w;
ADDR  R0.y, R0.x, c[49].x;
MOVR  R0.x, c[49];
POWR  R0.y, R0.y, c[49].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R3.w, R13.x, R0;
MOVR  R11.x, R0.z;
MOVR  R4.w, R6;
MULR  R14.w, R0.x, R0.y;
MOVR  R4.xyz, c[49].x;
MOVR  R7.xyz, c[47].z;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R11.y, -R10.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R9.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R9.x;
RCPR  R0.z, R9.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R9.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R10.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R13, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R11.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R3.w, -R13;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R13.x;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R4.w, -R3.w;
MULR  R0.y, R0.x, R8.w;
MOVR  R13.xyz, R7;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVX  H0.x, c[47].z;
RCPR  R0.z, R7.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.w(NE.x), R7;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R3;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
ADDR  R6, R6.x, -c[25];
RCPR  R2.x, R5.y;
MULR_SAT R2.x, R6.y, R2;
MOVR  R3.w, c[50];
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R3.w;
RCPR  R2.x, R5.x;
MULR_SAT R5.x, R6, R2;
MULR  R4.w, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R4, -R4;
MULR  R2.y, R5.x, R5.x;
MADR  R0.z, -R5.x, c[47].x, R3.w;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R3.w;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R3.w;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.w, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R4.w, -R2, R3, R3;
MOVR  R2.xyz, c[21];
MULR  R3.w, R4, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R4.w, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
DP3R  R5.x, R2, R2;
MULR  R4.w, R4, R3;
RSQR  R3.w, R5.x;
MULR  R2.xyz, R3.w, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R4, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
RCPR  R2.w, R3.w;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R3, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R3.y, R3, R2;
MOVR  R2.y, c[50].w;
MADR  R5.x, -R3.y, c[47], R2.y;
MULR  R4.w, R3.y, R3.y;
RCPR  R3.y, R2.x;
MULR  R2.x, R4.w, R5;
TEX   R5, R0.zwzw, texture[2], 2D;
MULR_SAT R3.x, R3, R3.y;
MADR  R0.w, R5.y, R2.x, -R2.x;
MADR  R0.z, -R3.x, c[47].x, R2.y;
MULR  R2.x, R3, R3;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R5.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R3.w;
MULR_SAT R0.w, R0, R3.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R5.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R5, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R3.y, -R2.w, R3.x, R3.x;
MOVR  R2.xyz, c[21];
MULR  R3.x, R3.y, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R3.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
DP3R  R3.z, R2, R2;
MULR  R3.y, R3, R3.x;
RSQR  R3.x, R3.z;
MULR  R2.xyz, R3.x, R2;
DP3R  R1.x, R2, R1;
MADR  R0.z, R1.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R1.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R1.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R3.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R1.xyz, c[18];
ADDR  R1.xyz, -R1, c[19];
DP3R  R1.x, R1, R1;
RCPR  R2.x, R3.x;
MULR  R2.x, R2, c[51].w;
MULR  R1.y, R2.x, R2.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
RCPR  R1.y, R1.y;
MULR  R0.z, R1.x, R0;
MULR  R0.z, R0, R1.y;
MINR  R0.w, R0, c[49].x;
MULR  R1.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R1.xyz, R0.z, c[20], R1;
MULR  R0.z, R0.y, c[28].x;
MULR  R1.xyz, R1, c[52].x;
MULR  R1.xyz, R0.z, R1;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R2.xyz, R0.w, c[51], R0.z;
MULR  R1.xyz, R1, c[52].y;
MADR  R1.xyz, R12, R2, R1;
MULR  R0.y, R0, c[29].x;
ADDR  R1.xyz, R1, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R1.xyz, R1, R11.w;
MADR  R7.xyz, R1, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
MOVR  R2, c[41];
ADDR  R2, -R2, c[37];
MOVR  R0, c[40];
MOVR  R8, c[43];
ADDR  R0, -R0, c[36];
MADR  R3, R1.w, R2, c[41];
MADR  R2, R1.w, R0, c[40];
TEX   R5.w, fragment.texcoord[0], texture[4], 2D;
MOVR  R0.y, R5.w;
TEX   R4.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R5, c[42];
ADDR  R5, -R5, c[38];
MOVR  R0.zw, c[49].x;
MOVR  R0.x, R4.w;
MADR  R5, R1.w, R5, c[42];
ADDR  R8, -R8, c[39];
MADR  R1, R1.w, R8, c[43];
DP4R  R6.w, R0, R1;
DP4R  R6.x, R0, R2;
DP4R  R6.y, R0, R3;
DP4R  R6.z, R0, R5;
DP4R  R0.w, R1, R1;
DP4R  R0.x, R2, R2;
DP4R  R0.y, R3, R3;
DP4R  R0.z, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[49].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R11;
MADR  R1.xyz, R1, R0.y, R10;
MADR  R0.xyz, R1, R0.x, R9;
MULR  R1.xyz, R0.y, c[55];
MADR  R1.xyz, R0.x, c[54], R1;
MADR  R0.xyz, R0.z, c[53], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[52].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[52].z;
SGER  H0.x, R0, c[52].w;
MULH  H0.y, H0.x, c[52].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[53].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[54].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[55].w;
MULR  R1.xyz, R4.y, c[55];
MADR  R1.xyz, R4.x, c[54], R1;
MADR  R1.xyz, R4.z, c[53], R1;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[52].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[47], H0.z;
MINR  R0.z, R1, c[52];
SGER  H0.z, R0, c[52].w;
ADDR  R0.x, R0, -H0.y;
MINR  R0.w, R0, c[50].x;
MADR  R0.x, R0, c[56], R0.w;
MULH  H0.y, H0.z, c[52].w;
ADDR  R0.w, R0.z, -H0.y;
MOVR  R0.z, c[49].x;
MADR  H0.y, R0.x, c[56], R0.z;
MULR  R1.x, R0.w, c[53].w;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[55].w;
ADDR  R0.x, R0.w, -H0;
ADDH  H0.x, H0.w, -c[54].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[50].x;
MADR  R0.x, R0, c[56], R0.y;
MADR  H0.z, R0.x, c[56].y, R0;
MADH  H0.x, H0.y, c[47], H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c47, 2.00000000, -1.00000000, 0.00000000, 0.99500000
def c48, 1000000.00000000, 0.00000000, 1.00000000, -1000000.00000000
def c49, 0.00100000, 0.75000000, 1.50000000, 0.50000000
defi i0, 255, 0, 1, 0
def c50, 2.71828198, 2.00000000, 3.00000000, 1000.00000000
def c51, 10.00000000, 400.00000000, 210.00000000, -128.00000000
def c52, 5.60204458, 9.47328472, 19.64380264, 128.00000000
def c53, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c54, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c55, 0.02411880, 0.12281780, 0.84442663, 4.00000000
def c56, 2.00000000, 1.00000000, 255.00000000, 256.00000000
def c57, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c47.x, c47.y
mov r0.z, c47.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.z, r0.w
mul r0.xyz, r2.z, r0
mov r0.w, c47.z
dp4 r7.z, r0, c2
dp4 r7.y, r0, c1
dp4 r7.x, r0, c0
mov r0.z, c11.x
mov r0.w, c11.x
mul r9.xyz, r7.zxyw, c16.yzxw
mad r9.xyz, r7.yzxw, c16.zxyw, -r9
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r8.xyz, r1, c13.x
add r6.xyz, r8, -c9
dp3 r0.y, r7, r6
dp3 r0.x, r6, r6
add r0.w, c25.y, r0
mad r1.x, -r0.w, r0.w, r0
mad r1.y, r0, r0, -r1.x
rsq r1.z, r1.y
add r0.z, c25.x, r0
mad r0.z, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.x, -r0.w, r0.z, r1
cmp_pp r0.w, r1.y, c48.z, c48.y
rcp r1.z, r1.z
add r1.z, -r0.y, -r1
cmp r1.y, r1, r1.w, c48.x
cmp r1.y, -r0.w, r1, r1.z
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.z, c25.w, r0
mad r0.w, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0.w
mad r1.z, -r1, r1, r0.x
mad r2.w, r0.y, r0.y, -r1.z
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.z, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.z, -r0.w, r0, r1
rsq r3.x, r2.w
rcp r3.x, r3.x
cmp r0.w, r2, r1, c48.x
add r3.x, -r0.y, -r3
cmp_pp r0.z, r2.w, c48, c48.y
cmp r1.w, -r0.z, r0, r3.x
mov r0.w, c11.x
add r2.w, c24.x, r0
mov r0.w, c11.x
add r3.x, c24.y, r0.w
mad r2.w, -r2, r2, r0.x
mad r0.w, r0.y, r0.y, -r2
mad r3.x, -r3, r3, r0
mad r3.y, r0, r0, -r3.x
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.x, -r2.w, r0.w, r3
rsq r3.z, r3.y
rcp r3.z, r3.z
dp4 r0.z, r1, c41
cmp r3.x, r3.y, r2, c48.w
add r3.z, -r0.y, r3
cmp_pp r2.w, r3.y, c48.z, c48.y
cmp r5.y, -r2.w, r3.x, r3.z
mov r0.w, c11.x
add r2.w, c24, r0
mad r2.w, -r2, r2, r0.x
mad r3.x, r0.y, r0.y, -r2.w
rsq r2.w, r3.x
rcp r3.y, r2.w
add r3.z, -r0.y, r3.y
cmp_pp r3.y, r3.x, c48.z, c48
cmp r3.x, r3, r2, c48.w
cmp r5.w, -r3.y, r3.x, r3.z
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r0.x
mad r0.w, r0.y, r0.y, -r0
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.z, -r2.w, r0.w, r3.x
dp4 r0.w, r5, c37
add r3.x, r0.w, -r0.z
dp4 r2.w, r5, c35
cmp r6.w, -r2, c48.z, c48.y
mad r0.z, r6.w, r3.x, r0
mov r0.w, c11.x
add r0.w, c31.x, r0
mad r0.w, -r0, r0, r0.x
mad r2.w, r0.y, r0.y, -r0
dp4 r3.y, r1, c40
dp4 r3.x, r5, c36
add r3.z, r3.x, -r3.y
rsq r0.w, r2.w
rcp r3.x, r0.w
mad r0.w, r6, r3.z, r3.y
add r3.y, -r0, -r3.x
cmp_pp r3.x, r2.w, c48.z, c48.y
cmp r2.w, r2, r2.x, c48.x
cmp r2.w, -r3.x, r2, r3.y
cmp r3.x, r2.w, r2.w, c48
mad r0.x, -c12, c12, r0
mad r2.w, r0.y, r0.y, -r0.x
cmp r2.xy, r2.w, r2, c47.z
rcp r2.z, r2.z
texldl r0.x, v0, s0
mul r3.y, r0.x, r2.z
mad r3.z, -r3.y, c13.x, r3.x
rsq r3.x, r2.w
mov r2.z, c8.w
mad r0.x, c47.w, -r2.z, r0
rcp r3.x, r3.x
mul r2.z, r3.y, c13.x
cmp r0.x, r0, c48.z, c48.y
mad r3.y, r0.x, r3.z, r2.z
add r0.x, -r0.y, -r3
add r0.y, -r0, r3.x
cmp_pp r2.z, r2.w, c48, c48.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
mad r2.w, r6, r2, c45.y
max r0.x, r0, c47.z
max r0.y, r0, c47.z
cmp r0.xy, -r2.z, r2, r0
min r3.x, r0.y, r3.y
max r12.x, r0, c49
min r0.y, r3.x, r0.w
min r0.x, r3, r0.z
max r4.x, r12, r0.y
dp4 r0.z, r1, c42
dp4 r0.y, r5, c38
add r0.y, r0, -r0.z
max r2.x, r4, r0
mad r0.x, r6.w, r0.y, r0.z
dp4 r0.z, r1, c43
dp4 r0.y, r5, c39
add r0.y, r0, -r0.z
min r0.x, r3, r0
mul r5.xyz, r6.zxyw, c16.yzxw
mad r0.y, r6.w, r0, r0.z
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r6, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r12.x
rcp r0.z, r0.y
mad r5.xyz, r6.yzxw, c16.zxyw, -r5
rcp r2.z, r1.w
add r1.y, r4.x, -r12.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c48, c48.z
cmp r0.w, -r1.z, c48.y, c48.z
mul_pp r2.y, r0.w, r2
cmp r8.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r9.w, -r2.y, r0, r1.y
dp3 r0.y, r5, r5
dp3 r1.y, r5, r9
dp3 r1.z, r9, r9
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
dp3 r0.y, r6, c16
rsq r2.z, r1.w
cmp r0.y, -r0, c48.z, c48
cmp r1.w, -r1, c48.y, c48.z
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c48.x, r1
mad r5.xyz, r7, r1.z, r8
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c48, r1
cmp r1.y, -r1, c48, c48.z
mul_pp r0.y, r0, r1
cmp r13.xy, -r0.y, r1.zwzw, c48.xwzw
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r6.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r6.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r6.w, r0, c46
dp3 r2.z, r7, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c48
mul r2.w, r2, c47.x
mad r2.w, c30.x, c30.x, r2
mul r13.z, r2, c49.y
mov r2.z, c30.x
add r2.z, c48, r2
add r2.w, r2, c48.z
mov r15.x, r3
pow r3, r2.w, c49.z
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r8.w, c48, c48.z
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r13.w, r2.z, r2
mov r9.xyz, c48.z
mov r6.xyz, c47.z
if_gt r2.y, c47.z
frc r2.y, r8.w
add r2.y, r8.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r11.w, r2.y, r2.z, -r2.z
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r15.y, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r15.y, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r2.y, r5.w, c29.x
mad r11.xyz, r5.z, -c27, -r2.y
pow r3, c50.x, r11.y
pow r14, c50.x, r11.x
mov r11.y, r3
pow r3, c50.x, r11.z
add r3.x, r12, r9.w
add r2.w, -r12.x, r13.y
rcp r2.z, r9.w
add r2.y, r3.x, -r13.x
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r3
mul r11.xyz, r11, r2.y
mov r2.y, c47.z
mul r12.xyz, r11, c15
if_gt c34.x, r2.y
add r3.y, r15, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r14.xyz, r10
mov r14.w, c48.z
dp4 r3.w, r14, c5
dp4 r3.z, r14, c4
cmp r12.w, r2.y, c48.z, r12
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r11.xy, r3.zwzw
mov r11.z, c47
texldl r14, r11.xyzz, s2
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r14.x, c47.y
mad r2.y, r2.z, r3.z, c48.z
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r14.y, c47.y
mad r2.w, r2, r3.z, c48.z
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c50.y, c50
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r14.z, c47.y
mad r2.z, r2.w, r3.w, c48
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c50, c50.z
mul r2.w, r2, r2
add r3.z, r14.w, c47.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c48.z
mul r2.y, r2, r2.z
mul r12.w, r2.y, r2
endif
mul r12.xyz, r12, r12.w
endif
add r11.xyz, -r10, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
add r11.xyz, -c21, r11
dp3 r3.z, r11, r11
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r10.xyz, -r10, c18
dp3 r3.y, r10, r10
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r10.xyz, r3.y, r10
dp3 r2.y, r10, r7
mul r3.z, r3, c50.w
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r10.xyz, c19
add r2.y, r2, c48.z
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c50.w
add r10.xyz, -c18, r10
dp3 r2.z, r10, r10
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c50.w
min r2.w, r2.y, c48.z
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c50.w
mul r2.z, r5.y, c28.x
min r2.y, r2, c48.z
mul r10.xyz, r2.w, c23
mad r10.xyz, r2.y, c20, r10
mul r2.y, r5, c29.x
mad r11.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r10.xyz, r10, c51.x
mul r10.xyz, r2.z, r10
mul r10.xyz, r10, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r5.xyz, r2.y, c52, r2.z
mad r5.xyz, r12, r5, r10
mul r10.xyz, r9.w, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mov r10.x, r5
pow r14, c50.x, r10.y
pow r5, c50.x, r10.z
mul r11.xyz, r11, r9.w
mad r6.xyz, r11, r9, r6
mov r10.y, r14
mov r10.z, r5
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r2.y, r3.w, c29.x
mad r11.xyz, r3.z, -c27, -r2.y
pow r10, c50.x, r11.y
pow r14, c50.x, r11.x
add r2.y, r8.w, -r11.w
mul r3.z, r2.y, r9.w
mov r11.y, r10
pow r10, c50.x, r11.z
add r2.y, r3.z, r12.x
rcp r2.z, r3.z
add r2.y, r2, -r13.x
add r2.w, -r12.x, r13.y
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r10
mul r10.xyz, r11, r2.y
mov r2.y, c47.z
mul r10.xyz, r10, c15
if_gt c34.x, r2.y
add r3.w, r5, -c11.x
add r2.y, r3.w, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r11.xyz, r5
mov r11.w, c48.z
dp4 r12.y, r11, c5
dp4 r12.x, r11, c4
cmp r7.w, r2.y, c48.z, r7
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3.w, -c25.x
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r3.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c50.y, c50.z
mul r2.y, r2, r2
mul r2.w, r2.y, r2
mov r2.y, c24.z
mov r11.xy, r12
mov r11.z, c47
texldl r11, r11.xyzz, s2
add r4.y, r11.x, c47
mad r2.z, r2, r4.y, c48
add r4.y, r11, c47
mad r2.w, r2, r4.y, c48.z
add r4.y, -c25.z, r2
mul r2.y, r2.z, r2.w
rcp r2.w, r4.y
add r2.z, r3.w, -c25
mul_sat r2.z, r2, r2.w
mad r4.y, -r2.z, c50, c50.z
mul r2.w, r2.z, r2.z
mul r2.w, r2, r4.y
mov r2.z, c24.w
add r4.y, -c25.w, r2.z
add r4.z, r11, c47.y
mad r2.z, r2.w, r4, c48
rcp r4.y, r4.y
add r2.w, r3, -c25
mul_sat r2.w, r2, r4.y
mad r3.w, -r2, c50.y, c50.z
mul r2.w, r2, r2
add r4.y, r11.w, c47
mul r2.w, r2, r3
mad r2.w, r2, r4.y, c48.z
mul r2.y, r2, r2.z
mul r7.w, r2.y, r2
endif
mul r10.xyz, r10, r7.w
endif
add r11.xyz, -r5, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.w, r2.z, r2
mul r4.y, r3.w, r2.w
add r11.xyz, -c21, r11
add r5.xyz, -r5, c18
dp3 r3.w, r11, r11
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.w, r3.w
rcp r3.w, r3.w
mul r3.w, r3, r4.y
rcp r4.y, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r7
mul r4.y, r4, c50.w
mul r2.y, r2, c30.x
mul r4.y, r4, r4
add r2.y, r2, c48.z
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c50
rcp r4.y, r4.y
mul r3.w, r3, r4.y
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.w, r3, c50
min r2.z, r3.w, c48
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c50.w
min r2.y, r2, c48.z
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r11.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c51.x
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r12.xyz, r2.y, c52, r2.z
mad r5.xyz, r10, r12, r5
mul r10.xyz, r3.z, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mul r3.xyz, r11, r3.z
mad r6.xyz, r3, r9, r6
mov r10.x, r5
pow r5, c50.x, r10.y
pow r3, c50.x, r10.z
mov r10.y, r5
mov r10.z, r3
mul r9.xyz, r9, r10
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r11.xyz, r6
cmp r2.w, -r2.z, c48.y, c48.z
cmp r3.x, r3, c48.y, c48.z
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r8.w, -r2, r2.z, r1
cmp_pp r1.w, -r8, c48.y, c48.z
cmp r9.w, -r2, r0, r2.y
mov r12.x, r4
mov r6.xyz, c47.z
if_gt r1.w, c47.z
frc r1.w, r8
add r1.w, r8, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r11.w, r1, r2.y, -r2.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r15.y, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r15, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r1.w, r5, c29.x
mad r14.xyz, r5.z, -c27, -r1.w
pow r4, c50.x, r14.x
pow r3, c50.x, r14.y
mov r4.y, r3
pow r3, c50.x, r14.z
add r3.x, r12, r9.w
add r2.z, -r12.x, r13.y
rcp r2.y, r9.w
add r1.w, r3.x, -r13.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c47.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r10
mov r4.w, c48.z
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r12.w, r1, c48.z, r12
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r1.w, r2.y, r2, c48.z
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c50.y, c50
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c47.y
mad r2.y, r2.z, r3.z, c48.z
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.y, r4.w, c47
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c48
mul r1.w, r1, r2.y
mul r12.w, r1, r2.z
endif
mul r12.xyz, r12, r12.w
endif
add r4.xyz, -r10, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r10.xyz, -r10, c18
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r10, r10
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r10
dp3 r1.w, r4, r7
mul r3.y, r3, c50.w
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c48.z
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c50
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c48
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c50
mul r2.y, r5, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r10.xyz, r9.w, -r10
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r5.xyz, r1.w, c52, r2.y
mad r4.xyz, r12, r5, r4
add r5.xyz, r4, c17
pow r4, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r4
pow r5, c50.x, r10.y
pow r4, c50.x, r10.z
mov r10.y, r5
mov r10.z, r4
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r1.w, r3, c29.x
mad r14.xyz, r3.z, -c27, -r1.w
pow r10, c50.x, r14.x
pow r4, c50.x, r14.y
add r1.w, r8, -r11
mul r3.z, r1.w, r9.w
add r1.w, r3.z, r12.x
mov r10.y, r4
pow r4, c50.x, r14.z
mov r10.z, r4
rcp r2.y, r3.z
add r1.w, r1, -r13.x
add r2.z, -r12.x, r13.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mul r4.xyz, r10, r1.w
mov r1.w, c47.z
mul r10.xyz, r4, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r5
mov r4.w, c48.z
dp4 r12.y, r4, c5
dp4 r12.x, r4, c4
cmp r7.w, r1, c48.z, r7
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r3, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c50.y, c50
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r1.w, c24.z
mov r4.xy, r12
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r2.y, r2, r2.w, c48.z
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r3.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r4.x, r4.z, c47.y
mad r2.y, r2.z, r4.x, c48.z
add r2.z, r3.w, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.w, r4, c47.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3.w, c48
mul r1.w, r1, r2.y
mul r7.w, r1, r2.z
endif
mul r10.xyz, r10, r7.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.w, r4, r4
rsq r3.w, r3.w
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.w, r3.w
mul r3.w, r3, r2
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r7
mul r2.w, r2, c50
mul r2.w, r2, r2
mul r1.w, r1, c30.x
rcp r4.x, r2.w
add r1.w, r1, c48.z
rcp r2.w, r1.w
mul r1.w, r3, r4.x
mul r2.y, r2, r2.w
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c50.w
mov r4.xyz, c19
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c48
mul r1.w, r2.y, c50
mul r2.y, r3, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r5.xyz, r3.z, -r5
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r12.xyz, r1.w, c52, r2.y
mad r4.xyz, r10, r12, r4
add r10.xyz, r4, c17
pow r4, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r4
pow r4, c50.x, r5.y
pow r3, c50.x, r5.z
mov r5.y, r4
mov r5.z, r3
mul r9.xyz, r9, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r6
cmp r2.z, -r2.y, c48.y, c48
cmp r2.w, r2, c48.y, c48.z
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r8.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r8.w, c48.y, c48
cmp r9.w, -r2.z, r0, r1
mov r12.x, r2
mov r6.xyz, c47.z
if_gt r1.z, c47.z
frc r1.z, r8.w
add r1.z, r8.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r11.w, r1.z, r1, -r1
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r2.xyz, r10, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r15.y, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r15.y, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c48
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r5, r2.xyzz, s1
mul r1.z, r5.w, c29.x
mad r14.xyz, r5.z, -c27, -r1.z
pow r2, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r2
pow r2, c50.x, r14.z
add r3.x, r12, r9.w
add r2.x, -r12, r13.y
rcp r1.w, r9.w
add r1.z, r3.x, -r13.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mov r14.z, r2
mul r2.xyz, r14, r1.z
mov r1.z, c47
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r15, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r10
mov r2.w, c48.z
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r12.w, r1.z, c48.z, r12
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r3.z, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c48
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c50.y, c50.z
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r12.w, r1.z, r2.x
endif
mul r12.xyz, r12, r12.w
endif
add r2.xyz, -r10, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r10.xyz, -r10, c18
dp3 r2.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r10
rcp r3.z, r1.z
dp3 r1.z, r2, r7
mul r2.x, r3.z, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c50
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c50.w
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r10.xyz, r9.w, -r10
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.z, r2
mul r2.w, r13, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r13
mad r5.xyz, r1.z, c52, r2.w
mul r2.xyz, r2, c51.y
mad r2.xyz, r12, r5, r2
add r5.xyz, r2, c17
pow r2, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r2
pow r5, c50.x, r10.y
pow r2, c50.x, r10.z
mov r10.y, r5
mov r10.z, r2
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.z, -r1, c48
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r3, r2.xyzz, s1
mul r1.z, r3.w, c29.x
mad r14.xyz, r3.z, -c27, -r1.z
pow r10, c50.x, r14.x
pow r2, c50.x, r14.y
add r1.z, r8.w, -r11.w
mul r3.z, r1, r9.w
add r1.z, r3, r12.x
mov r10.y, r2
pow r2, c50.x, r14.z
mov r10.z, r2
rcp r1.w, r3.z
add r1.z, r1, -r13.x
add r2.x, -r12, r13.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mul r2.xyz, r10, r1.z
mov r1.z, c47
mul r10.xyz, r2, c15
if_gt c34.x, r1.z
add r3.w, r5, -c11.x
add r1.z, r3.w, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r5
mov r2.w, c48.z
dp4 r12.y, r2, c5
dp4 r12.x, r2, c4
cmp r7.w, r1.z, c48.z, r7
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.w, -c25.x
mul_sat r1.z, r1, r1.w
mul r1.w, r1.z, r1.z
mov r2.xy, r12
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r4.w, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r3.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r4, c48.z
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r3, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r7.w, r1.z, r2.x
endif
mul r10.xyz, r10, r7.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.w, r1, r2
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.w, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r4.w, r1.z
dp3 r1.z, r2, r7
mul r2.x, r4.w, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r3.w, r2.y
mul r1.w, r1, r2.x
mul r3.w, r1, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c50
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c50.w
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r3.y, c28.x
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.w, r2
mul r5.xyz, r3.z, -r5
mul r2.xyz, r2, c51.y
mul r1.w, r13, r1
mul r1.z, r1, r13
mad r12.xyz, r1.z, c52, r1.w
mad r2.xyz, r10, r12, r2
add r10.xyz, r2, c17
pow r2, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r2
pow r3, c50.x, r5.y
pow r2, c50.x, r5.z
mov r5.y, r3
mov r5.z, r2
mul r9.xyz, r9, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c48, c48.z
cmp r2.x, -r1.w, c48.y, c48.z
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r8.w, -r2.x, r1, r1.y
cmp r9.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r8.w, c48, c48.z
mov r2.xyz, r6
mov r12.x, r1
mov r6.xyz, c47.z
if_gt r1.y, c47.z
frc r1.x, r8.w
add r1.x, r8.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r1.x, r1.y, -r1.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r1.xyz, r10, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r15.y, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r15.y, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r5, r1.xyzz, s1
mul r1.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r1.x
pow r1, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r1
pow r1, c50.x, r14.z
add r3.x, r12, r9.w
rcp r1.y, r9.w
add r1.w, -r12.x, r13.y
add r1.x, r3, -r13
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r14.z, r1
mul r1.xyz, r14, r1.x
mov r1.w, c47.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r10
mov r1.w, c48.z
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r12.w, r2, c48.z, r12
if_gt r1.x, c47.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r3.w, r1.x, c47.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c48.z
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c47.y
mad r3.z, -r2.w, c50.y, c50
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c48.z
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r12.w, r1.x, r1.z
endif
mul r12.xyz, r12, r12.w
endif
add r1.xyz, -r10, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
add r2.w, r1.x, c48.z
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r10.xyz, -r10, c18
dp3 r1.x, r10, r10
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r10
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c50.w
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r10.xyz, r9.w, -r10
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r13.w, r1.w
mul r1.w, r2, r13.z
mad r5.xyz, r1.w, c52, r3.y
mul r1.xyz, r1, c51.y
mad r1.xyz, r12, r5, r1
add r5.xyz, r1, c17
pow r1, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r1
pow r5, c50.x, r10.y
pow r1, c50.x, r10.z
mov r10.y, r5
mov r10.z, r1
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r3, r1.xyzz, s1
mul r1.x, r3.w, c29
mad r14.xyz, r3.z, -c27, -r1.x
pow r10, c50.x, r14.x
pow r1, c50.x, r14.y
add r1.x, r8.w, -r11.w
mov r10.y, r1
mul r3.z, r1.x, r9.w
pow r1, c50.x, r14.z
add r1.x, r3.z, r12
rcp r1.y, r3.z
add r1.x, r1, -r13
add r1.w, -r12.x, r13.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r10.z, r1
mul r1.xyz, r10, r1.x
mov r1.w, c47.z
mul r10.xyz, r1, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r2.w, r3, -c25
mov r1.xyz, r5
mov r1.w, c48.z
dp4 r12.y, r1, c5
dp4 r12.x, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r7.w, r2, c48.z, r7
if_gt r1.x, c47.z
mov r1.w, c24.x
add r2.w, -c25.x, r1
rcp r4.w, r2.w
add r2.w, r3, -c25.x
mul_sat r2.w, r2, r4
mul r4.w, r2, r2
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r4, r2
mov r1.xy, r12
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r5.w, r1.x, c47.y
mov r1.x, c24.y
add r4.w, -c25.y, r1.x
mad r1.x, r2.w, r5.w, c48.z
rcp r4.w, r4.w
add r2.w, r3, -c25.y
mul_sat r2.w, r2, r4
add r5.w, r1.y, c47.y
mad r4.w, -r2, c50.y, c50.z
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r4
mad r2.w, r2, r5, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3.w, -c25.z
mul_sat r1.y, r1, r2.w
add r4.w, r1.z, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r4.w, c48.z
rcp r2.w, r2.w
add r1.z, r3.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r7.w, r1.x, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
rcp r3.w, r1.y
add r2.w, r1.x, c48.z
mul r4.w, r2, r3
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r4.w, r4, r3
dp3 r1.x, r5, r5
rsq r3.w, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r4.w, r1.x, r4
mul r1.xyz, r3.w, r5
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r4.w, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.w, r3.w
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.w, r3, c50
mul r1.y, r3.w, r3.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r2.w, r3.y, c28.x
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r2.w, r1
mul r5.xyz, r3.z, -r5
mul r1.w, r1, r13.z
mul r2.w, r13, r2
mad r12.xyz, r1.w, c52, r2.w
mul r1.xyz, r1, c51.y
mad r1.xyz, r10, r12, r1
add r10.xyz, r1, c17
pow r1, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r1
pow r3, c50.x, r5.y
pow r1, c50.x, r5.z
mov r5.y, r3
mov r5.z, r1
mul r9.xyz, r9, r5
endif
add r1.x, r15, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c48.y, c48
cmp r1.y, -r0.z, c48, c48.z
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r8.w, -r1.y, r0.z, r0.y
cmp r9.w, -r1.y, r0, r1.x
mov r1.xyz, r6
cmp_pp r0.y, -r8.w, c48, c48.z
mov r12.x, r0
mov r6.xyz, c47.z
if_gt r0.y, c47.z
frc r0.x, r8.w
add r0.x, r8.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r11.w, r0.x, r0.y, -r0.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r0.xyz, r10, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r15.y, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r15.y, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r5, r0.xyzz, s1
mul r0.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r0.x
pow r0, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r0
pow r0, c50.x, r14.z
add r3.x, r12, r9.w
rcp r0.y, r9.w
add r0.w, -r12.x, r13.y
add r0.x, r3, -r13
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r14.z, r0
mul r0.xyz, r14, r0.x
mov r0.w, c47.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r10
mov r0.w, c48.z
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r12.w, r1, c48.z, r12
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r3.z, r0.x, c47.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c48.z
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c47.y
mad r2.w, -r1, c50.y, c50.z
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c48.z
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.y, c50.y, c50.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0, r0.y
mul r12.w, r0.x, r0.z
endif
mul r12.xyz, r12, r12.w
endif
add r0.xyz, -r10, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
add r1.w, r0.x, c48.z
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r10.xyz, -r10, c18
dp3 r0.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r10
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c50
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c50
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c48.z
mul r0.w, r0.x, c50
mul r1.w, r5.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r10.xyz, r9.w, -r10
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r5.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r12, r5, r0
add r5.xyz, r0, c17
pow r0, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r0
pow r5, c50.x, r10.y
pow r0, c50.x, r10.z
mov r10.y, r5
mov r10.z, r0
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r3, r0.xyzz, s1
mul r0.x, r3.w, c29
mad r8.xyz, r3.z, -c27, -r0.x
pow r0, c50.x, r8.y
pow r10, c50.x, r8.x
add r0.x, r8.w, -r11.w
mul r3.z, r0.x, r9.w
mov r8.y, r0
pow r0, c50.x, r8.z
add r0.x, r3.z, r12
rcp r0.y, r3.z
add r0.x, r0, -r13
add r0.w, -r12.x, r13.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r8.x, r10
mov r8.z, r0
mul r0.xyz, r8, r0.x
mov r0.w, c47.z
mul r10.xyz, r0, c15
if_gt c34.x, r0.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
mov r0.xyz, r5
mov r0.w, c48.z
dp4 r12.y, r0, c5
dp4 r12.x, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r7.w, r1, c48.z, r7
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r12
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r4.w, r0.x, c47.y
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r3.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c47.y
mad r0.y, -r0.x, c50, c50.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c48.z
mad r1.w, r1, r4, c48.z
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r3.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.x, c50.y, c50.z
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0.y, r0
mul r7.w, r0.x, r0.z
endif
mul r10.xyz, r10, r7.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c48.z
mul r3.w, r1, r2
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.w, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.w, r0.z, c50
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c50
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c50
min r0.y, r3.w, c48.z
mul r1.w, r3.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r5.xyz, r3.z, -r5
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r7.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r10, r7, r0
add r7.xyz, r0, c17
pow r0, c50.x, r5.x
mul r3.xyz, r7, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r0
pow r3, c50.x, r5.y
pow r0, c50.x, r5.z
mov r5.y, r3
mov r5.z, r0
mul r9.xyz, r9, r5
endif
mov r3, c37
add r3, -c41, r3
mov r0, c36
mov r7, c39
mov r8, c38
add r7, -c43, r7
add r8, -c42, r8
add r0, -c40, r0
mad r5, r6.w, r3, c41
mad r3, r6.w, r0, c40
texldl r1.w, v0, s3
texldl r2.w, v0, s4
mov r0.x, r1.w
mov r0.zw, c48.z
mov r0.y, r2.w
dp4 r10.x, r3, r0
dp4 r3.x, r3, r3
mad r7, r6.w, r7, c43
mad r8, r6.w, r8, c42
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r10.y, r5, r0
dp4 r10.w, r7, r0
dp4 r10.z, r8, r0
add r0, r10, c47.y
dp4 r3.w, r7, r7
mad r0, r3, r0, c48.z
mad r1.xyz, r6, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r11
mul r1.xyz, r0.y, c53
mad r1.xyz, r0.x, c54, r1
mad r0.xyz, r0.z, c55, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c51.z
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c51.z
add r0.z, r0.x, c51.w
cmp r0.z, r0, c48, c48.y
mul_pp r1.x, r0.z, c52.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c53.w
frc r1.x, r0
add r2.x, r0, -r1
add_pp r0.x, r2, c54.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c56, c56.y
mul r3.xyz, r9.y, c53
mad r1.xyz, r9.x, c54, r3
mad r1.xyz, r9.z, c55, r1
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.x, c55.w
mul_pp r0.x, r0, r2.y
mul r2.xy, r1, r1.z
mul r0.w, r0, c51.y
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c51
min r0.w, r0, c56.z
mad r0.z, r0, c56.w, r0.w
mad r0.z, r0, c57.x, c57.y
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c51.z
add r1.z, r1.x, c51.w
cmp r0.w, r1.z, c48.z, c48.y
mul_pp r1.z, r0.w, c52.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c51.y
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c53.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c55.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c56.z
mad r0.z, r0.x, c56.w, r1.x
add_pp r0.x, r0.y, c54.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c56, c56.y
mad r0.z, r0, c57.x, c57.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 renders sky with 3 cloud layers
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[57] = { program.local[0..46],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.001, 0.75 },
		{ 1, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625 } };
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
SHORT OUTPUT oCol = result.color;
MOVR  R5.x, c[48].y;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[47].x, -R0;
MOVR  R0.z, c[47].y;
DP3R  R0.w, R0, R0;
RSQR  R2.w, R0.w;
MULR  R0.xyz, R2.w, R0;
MOVR  R0.w, c[47].z;
DP4R  R1.z, R0, c[2];
DP4R  R1.y, R0, c[1];
DP4R  R1.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R8.x, c[48].y;
MOVR  R8.y, c[48];
MOVR  R8.z, c[48].y;
MOVR  R2.x, c[0].w;
MOVR  R2.z, c[2].w;
MOVR  R2.y, c[1].w;
MULR  R3.xyz, R2, c[13].x;
ADDR  R2.xyz, R3, -c[9];
DP3R  R1.w, R1, R2;
MULR  R3.w, R1, R1;
DP3R  R5.y, R2, R2;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
SLTR  R6, R3.w, R0;
MOVXC RC.x, R6;
MOVR  R5.x(EQ), R4;
ADDR  R4, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.x, R4.z;
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
ADDR  R5.x(NE.z), -R1.w, R4;
MOVXC RC.z, R6;
MOVR  R8.x(EQ.z), R5.z;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R8.x(NE.y), -R1.w, R0;
RSQR  R0.x, R4.w;
MOVXC RC.y, R6;
MOVR  R4.x, c[48];
MOVR  R4.z, c[48].x;
MOVR  R4.w, c[48].x;
MOVR  R8.y(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R8.y(NE.w), -R1.w, R0.x;
RSQR  R0.x, R4.y;
MOVR  R8.z(EQ.y), R5;
RCPR  R0.x, R0.x;
ADDR  R8.z(NE.x), -R1.w, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
ADDR  R6, R3.w, -R0;
RSQR  R4.y, R6.x;
SLTR  R7, R3.w, R0;
MOVXC RC.x, R7;
MOVR  R4.x(EQ), R5.z;
SGERC HC, R3.w, R0.yzxw;
RCPR  R4.y, R4.y;
ADDR  R4.x(NE.z), -R1.w, -R4.y;
MOVXC RC.z, R7;
MOVR  R4.z(EQ), R5;
RSQR  R0.x, R6.z;
RCPR  R0.x, R0.x;
ADDR  R4.z(NE.y), -R1.w, -R0.x;
MOVXC RC.z, R7.w;
RSQR  R0.x, R6.w;
MOVR  R4.w(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE), -R1, -R0.x;
RSQR  R0.x, R6.y;
MOVR  R4.y, c[48].x;
MOVXC RC.y, R7;
MOVR  R4.y(EQ), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.y(NE.x), -R1.w, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R5.y;
ADDR  R0.y, R3.w, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R6.x, c[48];
SLTRC HC.x, R3.w, R0;
MOVR  R6.x(EQ), R5.z;
MOVR  R0.zw, c[47].z;
SGERC HC.x, R3.w, R0;
MADR  R5.y, -c[12].x, c[12].x, R5;
ADDR  R0.x, R3.w, -R5.y;
RCPR  R0.y, R0.y;
ADDR  R6.x(NE), -R1.w, -R0.y;
MOVXC RC.x, R6;
MOVR  R6.x(LT), c[48];
SLTRC HC.x, R3.w, R5.y;
MOVR  R0.zw(EQ.x), R5;
SGERC HC.x, R3.w, R5.y;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, -R1.w, -R0.x;
ADDR  R1.w, -R1, R0.x;
MAXR  R0.x, R0.y, c[47].z;
MAXR  R0.y, R1.w, c[47].z;
MOVR  R0.zw(NE.x), R0.xyxy;
MOVR  R3.w, c[47];
DP4R  R0.x, R4, c[40];
MOVR  R5.y, R8.z;
MOVR  R5.w, R8.y;
MOVR  R5.z, R8.x;
DP4R  R0.y, R5, c[36];
DP4R  R1.w, R5, c[35];
SGER  R1.w, c[47].z, R1;
ADDR  R0.y, R0, -R0.x;
MADR  R0.y, R1.w, R0, R0.x;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
MULR  R3.w, R3, c[8];
RCPR  R2.w, R2.w;
MULR  R2.w, R0.x, R2;
MADR  R6.x, -R2.w, c[13], R6;
SGER  H0.x, R0, R3.w;
MULR  R2.w, R2, c[13].x;
MADR  R0.x, H0, R6, R2.w;
MINR  R6.w, R0, R0.x;
MAXR  R2.w, R0.z, c[48].z;
MINR  R0.x, R6.w, R0.y;
MAXR  R10.y, R2.w, R0.x;
ADDR  R6.y, R6.w, -R2.w;
RCPR  R0.x, R6.y;
MULR  R8.w, R0.x, c[32].x;
ADDR  R3.w, R10.y, -R2;
MULR  R6.x, R8.w, R3.w;
RCPR  R7.x, c[32].x;
MULR  R9.w, R6.y, R7.x;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R1.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MULR  R7.xyz, R1.zxyw, c[16].yzxw;
MOVR  R9.x, R0;
MOVR  R10.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R1.w, R0, c[46].y;
SLTR  H0.y, R6.x, R0.w;
SGTR  H0.x, R6, c[47].z;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R6.x;
RCPR  R6.z, R0.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R3, R6.z;
MULR  R6.xyz, R2.zxyw, c[16].yzxw;
MADR  R6.xyz, R2.yzxw, c[16].zxyw, -R6;
DP3R  R2.x, R2, c[16];
MOVR  R11.w(NE.x), R0;
SLER  H0.y, R2.x, c[47].z;
DP3R  R0.w, R6, R6;
MADR  R7.xyz, R1.yzxw, c[16].zxyw, -R7;
DP3R  R3.w, R6, R7;
DP3R  R6.x, R7, R7;
MADR  R0.w, -c[11].x, c[11].x, R0;
MULR  R6.z, R6.x, R0.w;
MULR  R6.y, R3.w, R3.w;
ADDR  R0.w, R6.y, -R6.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.y, -R3.w, R0.w;
MOVR  R2.z, c[48].y;
MOVR  R2.x, c[48];
ADDR  R0.w, -R3, -R0;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
SGTR  H0.z, R6.y, R6;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVXC RC.x, H0.y;
RCPR  R6.x, R6.x;
MULR  R2.z(NE.x), R6.x, R2.y;
MULR  R2.x(NE), R0.w, R6;
MOVR  R2.y, R2.z;
MOVR  R14.xy, R2;
MADR  R2.xyz, R1, R2.x, R3;
ADDR  R2.xyz, R2, -c[9];
DP3R  R0.w, R2, c[16];
SGTR  H0.z, R0.w, c[47];
MULXC HC.x, H0.y, H0.z;
MOVR  R14.xy(NE.x), c[48];
MOVXC RC.x, H0;
DP4R  R2.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R11.y, R10, R0.w;
DP4R  R2.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R13.x, R11.y, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R2.x, R5, c[39];
ADDR  R2.x, R2, -R0.w;
MADR  R0.w, R1, R2.x, R0;
MINR  R0.w, R6, R0;
DP3R  R0.y, R1, c[16];
MULR  R7.w, R0.x, c[33].x;
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[47];
MADR  R0.x, c[30], c[30], R0;
MADR  R14.z, R0.y, c[48].w, c[48].w;
ADDR  R0.y, R0.x, c[49].x;
MOVR  R0.x, c[49];
POWR  R0.y, R0.y, c[49].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R3.w, R13.x, R0;
MOVR  R11.x, R0.z;
MOVR  R4.w, R6;
MULR  R14.w, R0.x, R0.y;
MOVR  R4.xyz, c[49].x;
MOVR  R7.xyz, c[47].z;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R11.y, -R10.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R9.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R9.x;
RCPR  R0.z, R9.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R9.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R10.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R13, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R11.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R3.w, -R13;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R13.x;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R4.w, -R3.w;
MULR  R0.y, R0.x, R8.w;
MOVR  R13.xyz, R7;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVX  H0.x, c[47].z;
RCPR  R0.z, R7.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.w(NE.x), R7;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R3;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
ADDR  R6, R6.x, -c[25];
RCPR  R2.x, R5.y;
MULR_SAT R2.x, R6.y, R2;
MOVR  R3.w, c[50];
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R3.w;
RCPR  R2.x, R5.x;
MULR_SAT R5.x, R6, R2;
MULR  R4.w, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R4, -R4;
MULR  R2.y, R5.x, R5.x;
MADR  R0.z, -R5.x, c[47].x, R3.w;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R3.w;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R3.w;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.w, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R4.w, -R2, R3, R3;
MOVR  R2.xyz, c[21];
MULR  R3.w, R4, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R4.w, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
DP3R  R5.x, R2, R2;
MULR  R4.w, R4, R3;
RSQR  R3.w, R5.x;
MULR  R2.xyz, R3.w, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R4, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
RCPR  R2.w, R3.w;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R3, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R3.y, R3, R2;
MOVR  R2.y, c[50].w;
MADR  R5.x, -R3.y, c[47], R2.y;
MULR  R4.w, R3.y, R3.y;
RCPR  R3.y, R2.x;
MULR  R2.x, R4.w, R5;
TEX   R5, R0.zwzw, texture[2], 2D;
MULR_SAT R3.x, R3, R3.y;
MADR  R0.w, R5.y, R2.x, -R2.x;
MADR  R0.z, -R3.x, c[47].x, R2.y;
MULR  R2.x, R3, R3;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R5.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R3.w;
MULR_SAT R0.w, R0, R3.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R5.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R5, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R3.y, -R2.w, R3.x, R3.x;
MOVR  R2.xyz, c[21];
MULR  R3.x, R3.y, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R3.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
DP3R  R3.z, R2, R2;
MULR  R3.y, R3, R3.x;
RSQR  R3.x, R3.z;
MULR  R2.xyz, R3.x, R2;
DP3R  R1.x, R2, R1;
MADR  R0.z, R1.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R1.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R1.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R3.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R1.xyz, c[18];
ADDR  R1.xyz, -R1, c[19];
DP3R  R1.x, R1, R1;
RCPR  R2.x, R3.x;
MULR  R2.x, R2, c[51].w;
MULR  R1.y, R2.x, R2.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
RCPR  R1.y, R1.y;
MULR  R0.z, R1.x, R0;
MULR  R0.z, R0, R1.y;
MINR  R0.w, R0, c[49].x;
MULR  R1.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R1.xyz, R0.z, c[20], R1;
MULR  R0.z, R0.y, c[28].x;
MULR  R1.xyz, R1, c[52].x;
MULR  R1.xyz, R0.z, R1;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R2.xyz, R0.w, c[51], R0.z;
MULR  R1.xyz, R1, c[52].y;
MADR  R1.xyz, R12, R2, R1;
MULR  R0.y, R0, c[29].x;
ADDR  R1.xyz, R1, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R1.xyz, R1, R11.w;
MADR  R7.xyz, R1, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
MOVR  R0, c[41];
ADDR  R2, -R0, c[37];
MOVR  R5, c[42];
MOVR  R8, c[43];
ADDR  R5, -R5, c[38];
MOVR  R0, c[40];
MADR  R3, R1.w, R2, c[41];
ADDR  R2, -R0, c[36];
TEX   R0.w, fragment.texcoord[0], texture[5], 2D;
MOVR  R0.z, R0.w;
TEX   R0.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R0.x, R0.w;
TEX   R4.w, fragment.texcoord[0], texture[4], 2D;
MOVR  R0.y, R4.w;
MOVR  R0.w, c[49].x;
MADR  R2, R1.w, R2, c[40];
MADR  R5, R1.w, R5, c[42];
ADDR  R8, -R8, c[39];
MADR  R1, R1.w, R8, c[43];
DP4R  R6.w, R0, R1;
DP4R  R6.x, R0, R2;
DP4R  R6.y, R0, R3;
DP4R  R6.z, R0, R5;
DP4R  R0.w, R1, R1;
DP4R  R0.x, R2, R2;
DP4R  R0.y, R3, R3;
DP4R  R0.z, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[49].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R11;
MADR  R1.xyz, R1, R0.y, R10;
MADR  R0.xyz, R1, R0.x, R9;
MULR  R1.xyz, R0.y, c[55];
MADR  R1.xyz, R0.x, c[54], R1;
MADR  R0.xyz, R0.z, c[53], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[52].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[52].z;
SGER  H0.x, R0, c[52].w;
MULH  H0.y, H0.x, c[52].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[53].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[54].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[55].w;
MULR  R1.xyz, R4.y, c[55];
MADR  R1.xyz, R4.x, c[54], R1;
MADR  R1.xyz, R4.z, c[53], R1;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[52].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[47], H0.z;
MINR  R0.z, R1, c[52];
SGER  H0.z, R0, c[52].w;
ADDR  R0.x, R0, -H0.y;
MINR  R0.w, R0, c[50].x;
MADR  R0.x, R0, c[56], R0.w;
MULH  H0.y, H0.z, c[52].w;
ADDR  R0.w, R0.z, -H0.y;
MOVR  R0.z, c[49].x;
MADR  H0.y, R0.x, c[56], R0.z;
MULR  R1.x, R0.w, c[53].w;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[55].w;
ADDR  R0.x, R0.w, -H0;
ADDH  H0.x, H0.w, -c[54].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[50].x;
MADR  R0.x, R0, c[56], R0.y;
MADR  H0.z, R0.x, c[56].y, R0;
MADH  H0.x, H0.y, c[47], H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c47, 2.00000000, -1.00000000, 0.00000000, 0.99500000
def c48, 1000000.00000000, 0.00000000, 1.00000000, -1000000.00000000
def c49, 0.00100000, 0.75000000, 1.50000000, 0.50000000
defi i0, 255, 0, 1, 0
def c50, 2.71828198, 2.00000000, 3.00000000, 1000.00000000
def c51, 10.00000000, 400.00000000, 210.00000000, -128.00000000
def c52, 5.60204458, 9.47328472, 19.64380264, 128.00000000
def c53, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c54, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c55, 0.02411880, 0.12281780, 0.84442663, 4.00000000
def c56, 2.00000000, 1.00000000, 255.00000000, 256.00000000
def c57, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c47.x, c47.y
mov r0.z, c47.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.z, r0.w
mul r0.xyz, r2.z, r0
mov r0.w, c47.z
dp4 r7.z, r0, c2
dp4 r7.y, r0, c1
dp4 r7.x, r0, c0
mov r0.z, c11.x
mov r0.w, c11.x
mul r9.xyz, r7.zxyw, c16.yzxw
mad r9.xyz, r7.yzxw, c16.zxyw, -r9
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r8.xyz, r1, c13.x
add r6.xyz, r8, -c9
dp3 r0.y, r7, r6
dp3 r0.x, r6, r6
add r0.w, c25.y, r0
mad r1.x, -r0.w, r0.w, r0
mad r1.y, r0, r0, -r1.x
rsq r1.z, r1.y
add r0.z, c25.x, r0
mad r0.z, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.x, -r0.w, r0.z, r1
cmp_pp r0.w, r1.y, c48.z, c48.y
rcp r1.z, r1.z
add r1.z, -r0.y, -r1
cmp r1.y, r1, r1.w, c48.x
cmp r1.y, -r0.w, r1, r1.z
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.z, c25.w, r0
mad r0.w, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0.w
mad r1.z, -r1, r1, r0.x
mad r2.w, r0.y, r0.y, -r1.z
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.z, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.z, -r0.w, r0, r1
rsq r3.x, r2.w
rcp r3.x, r3.x
cmp r0.w, r2, r1, c48.x
add r3.x, -r0.y, -r3
cmp_pp r0.z, r2.w, c48, c48.y
cmp r1.w, -r0.z, r0, r3.x
mov r0.w, c11.x
add r2.w, c24.x, r0
mov r0.w, c11.x
add r3.x, c24.y, r0.w
mad r2.w, -r2, r2, r0.x
mad r0.w, r0.y, r0.y, -r2
mad r3.x, -r3, r3, r0
mad r3.y, r0, r0, -r3.x
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.x, -r2.w, r0.w, r3
rsq r3.z, r3.y
rcp r3.z, r3.z
dp4 r0.z, r1, c41
cmp r3.x, r3.y, r2, c48.w
add r3.z, -r0.y, r3
cmp_pp r2.w, r3.y, c48.z, c48.y
cmp r5.y, -r2.w, r3.x, r3.z
mov r0.w, c11.x
add r2.w, c24, r0
mad r2.w, -r2, r2, r0.x
mad r3.x, r0.y, r0.y, -r2.w
rsq r2.w, r3.x
rcp r3.y, r2.w
add r3.z, -r0.y, r3.y
cmp_pp r3.y, r3.x, c48.z, c48
cmp r3.x, r3, r2, c48.w
cmp r5.w, -r3.y, r3.x, r3.z
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r0.x
mad r0.w, r0.y, r0.y, -r0
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.z, -r2.w, r0.w, r3.x
dp4 r0.w, r5, c37
add r3.x, r0.w, -r0.z
dp4 r2.w, r5, c35
cmp r6.w, -r2, c48.z, c48.y
mad r0.z, r6.w, r3.x, r0
mov r0.w, c11.x
add r0.w, c31.x, r0
mad r0.w, -r0, r0, r0.x
mad r2.w, r0.y, r0.y, -r0
dp4 r3.y, r1, c40
dp4 r3.x, r5, c36
add r3.z, r3.x, -r3.y
rsq r0.w, r2.w
rcp r3.x, r0.w
mad r0.w, r6, r3.z, r3.y
add r3.y, -r0, -r3.x
cmp_pp r3.x, r2.w, c48.z, c48.y
cmp r2.w, r2, r2.x, c48.x
cmp r2.w, -r3.x, r2, r3.y
cmp r3.x, r2.w, r2.w, c48
mad r0.x, -c12, c12, r0
mad r2.w, r0.y, r0.y, -r0.x
cmp r2.xy, r2.w, r2, c47.z
rcp r2.z, r2.z
texldl r0.x, v0, s0
mul r3.y, r0.x, r2.z
mad r3.z, -r3.y, c13.x, r3.x
rsq r3.x, r2.w
mov r2.z, c8.w
mad r0.x, c47.w, -r2.z, r0
rcp r3.x, r3.x
mul r2.z, r3.y, c13.x
cmp r0.x, r0, c48.z, c48.y
mad r3.y, r0.x, r3.z, r2.z
add r0.x, -r0.y, -r3
add r0.y, -r0, r3.x
cmp_pp r2.z, r2.w, c48, c48.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
mad r2.w, r6, r2, c45.y
max r0.x, r0, c47.z
max r0.y, r0, c47.z
cmp r0.xy, -r2.z, r2, r0
min r3.x, r0.y, r3.y
max r12.x, r0, c49
min r0.y, r3.x, r0.w
min r0.x, r3, r0.z
max r4.x, r12, r0.y
dp4 r0.z, r1, c42
dp4 r0.y, r5, c38
add r0.y, r0, -r0.z
max r2.x, r4, r0
mad r0.x, r6.w, r0.y, r0.z
dp4 r0.z, r1, c43
dp4 r0.y, r5, c39
add r0.y, r0, -r0.z
min r0.x, r3, r0
mul r5.xyz, r6.zxyw, c16.yzxw
mad r0.y, r6.w, r0, r0.z
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r6, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r12.x
rcp r0.z, r0.y
mad r5.xyz, r6.yzxw, c16.zxyw, -r5
rcp r2.z, r1.w
add r1.y, r4.x, -r12.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c48, c48.z
cmp r0.w, -r1.z, c48.y, c48.z
mul_pp r2.y, r0.w, r2
cmp r8.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r9.w, -r2.y, r0, r1.y
dp3 r0.y, r5, r5
dp3 r1.y, r5, r9
dp3 r1.z, r9, r9
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
dp3 r0.y, r6, c16
rsq r2.z, r1.w
cmp r0.y, -r0, c48.z, c48
cmp r1.w, -r1, c48.y, c48.z
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c48.x, r1
mad r5.xyz, r7, r1.z, r8
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c48, r1
cmp r1.y, -r1, c48, c48.z
mul_pp r0.y, r0, r1
cmp r13.xy, -r0.y, r1.zwzw, c48.xwzw
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r6.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r6.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r6.w, r0, c46
dp3 r2.z, r7, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c48
mul r2.w, r2, c47.x
mad r2.w, c30.x, c30.x, r2
mul r13.z, r2, c49.y
mov r2.z, c30.x
add r2.z, c48, r2
add r2.w, r2, c48.z
mov r15.x, r3
pow r3, r2.w, c49.z
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r8.w, c48, c48.z
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r13.w, r2.z, r2
mov r9.xyz, c48.z
mov r6.xyz, c47.z
if_gt r2.y, c47.z
frc r2.y, r8.w
add r2.y, r8.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r11.w, r2.y, r2.z, -r2.z
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r15.y, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r15.y, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r2.y, r5.w, c29.x
mad r11.xyz, r5.z, -c27, -r2.y
pow r3, c50.x, r11.y
pow r14, c50.x, r11.x
mov r11.y, r3
pow r3, c50.x, r11.z
add r3.x, r12, r9.w
add r2.w, -r12.x, r13.y
rcp r2.z, r9.w
add r2.y, r3.x, -r13.x
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r3
mul r11.xyz, r11, r2.y
mov r2.y, c47.z
mul r12.xyz, r11, c15
if_gt c34.x, r2.y
add r3.y, r15, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r14.xyz, r10
mov r14.w, c48.z
dp4 r3.w, r14, c5
dp4 r3.z, r14, c4
cmp r12.w, r2.y, c48.z, r12
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r11.xy, r3.zwzw
mov r11.z, c47
texldl r14, r11.xyzz, s2
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r14.x, c47.y
mad r2.y, r2.z, r3.z, c48.z
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r14.y, c47.y
mad r2.w, r2, r3.z, c48.z
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c50.y, c50
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r14.z, c47.y
mad r2.z, r2.w, r3.w, c48
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c50, c50.z
mul r2.w, r2, r2
add r3.z, r14.w, c47.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c48.z
mul r2.y, r2, r2.z
mul r12.w, r2.y, r2
endif
mul r12.xyz, r12, r12.w
endif
add r11.xyz, -r10, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
add r11.xyz, -c21, r11
dp3 r3.z, r11, r11
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r10.xyz, -r10, c18
dp3 r3.y, r10, r10
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r10.xyz, r3.y, r10
dp3 r2.y, r10, r7
mul r3.z, r3, c50.w
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r10.xyz, c19
add r2.y, r2, c48.z
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c50.w
add r10.xyz, -c18, r10
dp3 r2.z, r10, r10
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c50.w
min r2.w, r2.y, c48.z
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c50.w
mul r2.z, r5.y, c28.x
min r2.y, r2, c48.z
mul r10.xyz, r2.w, c23
mad r10.xyz, r2.y, c20, r10
mul r2.y, r5, c29.x
mad r11.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r10.xyz, r10, c51.x
mul r10.xyz, r2.z, r10
mul r10.xyz, r10, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r5.xyz, r2.y, c52, r2.z
mad r5.xyz, r12, r5, r10
mul r10.xyz, r9.w, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mov r10.x, r5
pow r14, c50.x, r10.y
pow r5, c50.x, r10.z
mul r11.xyz, r11, r9.w
mad r6.xyz, r11, r9, r6
mov r10.y, r14
mov r10.z, r5
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r2.y, r3.w, c29.x
mad r11.xyz, r3.z, -c27, -r2.y
pow r10, c50.x, r11.y
pow r14, c50.x, r11.x
add r2.y, r8.w, -r11.w
mul r3.z, r2.y, r9.w
mov r11.y, r10
pow r10, c50.x, r11.z
add r2.y, r3.z, r12.x
rcp r2.z, r3.z
add r2.y, r2, -r13.x
add r2.w, -r12.x, r13.y
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r10
mul r10.xyz, r11, r2.y
mov r2.y, c47.z
mul r10.xyz, r10, c15
if_gt c34.x, r2.y
add r3.w, r5, -c11.x
add r2.y, r3.w, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r11.xyz, r5
mov r11.w, c48.z
dp4 r12.y, r11, c5
dp4 r12.x, r11, c4
cmp r7.w, r2.y, c48.z, r7
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3.w, -c25.x
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r3.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c50.y, c50.z
mul r2.y, r2, r2
mul r2.w, r2.y, r2
mov r2.y, c24.z
mov r11.xy, r12
mov r11.z, c47
texldl r11, r11.xyzz, s2
add r4.y, r11.x, c47
mad r2.z, r2, r4.y, c48
add r4.y, r11, c47
mad r2.w, r2, r4.y, c48.z
add r4.y, -c25.z, r2
mul r2.y, r2.z, r2.w
rcp r2.w, r4.y
add r2.z, r3.w, -c25
mul_sat r2.z, r2, r2.w
mad r4.y, -r2.z, c50, c50.z
mul r2.w, r2.z, r2.z
mul r2.w, r2, r4.y
mov r2.z, c24.w
add r4.y, -c25.w, r2.z
add r4.z, r11, c47.y
mad r2.z, r2.w, r4, c48
rcp r4.y, r4.y
add r2.w, r3, -c25
mul_sat r2.w, r2, r4.y
mad r3.w, -r2, c50.y, c50.z
mul r2.w, r2, r2
add r4.y, r11.w, c47
mul r2.w, r2, r3
mad r2.w, r2, r4.y, c48.z
mul r2.y, r2, r2.z
mul r7.w, r2.y, r2
endif
mul r10.xyz, r10, r7.w
endif
add r11.xyz, -r5, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.w, r2.z, r2
mul r4.y, r3.w, r2.w
add r11.xyz, -c21, r11
add r5.xyz, -r5, c18
dp3 r3.w, r11, r11
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.w, r3.w
rcp r3.w, r3.w
mul r3.w, r3, r4.y
rcp r4.y, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r7
mul r4.y, r4, c50.w
mul r2.y, r2, c30.x
mul r4.y, r4, r4
add r2.y, r2, c48.z
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c50
rcp r4.y, r4.y
mul r3.w, r3, r4.y
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.w, r3, c50
min r2.z, r3.w, c48
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c50.w
min r2.y, r2, c48.z
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r11.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c51.x
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r12.xyz, r2.y, c52, r2.z
mad r5.xyz, r10, r12, r5
mul r10.xyz, r3.z, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mul r3.xyz, r11, r3.z
mad r6.xyz, r3, r9, r6
mov r10.x, r5
pow r5, c50.x, r10.y
pow r3, c50.x, r10.z
mov r10.y, r5
mov r10.z, r3
mul r9.xyz, r9, r10
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r11.xyz, r6
cmp r2.w, -r2.z, c48.y, c48.z
cmp r3.x, r3, c48.y, c48.z
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r8.w, -r2, r2.z, r1
cmp_pp r1.w, -r8, c48.y, c48.z
cmp r9.w, -r2, r0, r2.y
mov r12.x, r4
mov r6.xyz, c47.z
if_gt r1.w, c47.z
frc r1.w, r8
add r1.w, r8, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r11.w, r1, r2.y, -r2.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r15.y, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r15, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r1.w, r5, c29.x
mad r14.xyz, r5.z, -c27, -r1.w
pow r4, c50.x, r14.x
pow r3, c50.x, r14.y
mov r4.y, r3
pow r3, c50.x, r14.z
add r3.x, r12, r9.w
add r2.z, -r12.x, r13.y
rcp r2.y, r9.w
add r1.w, r3.x, -r13.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c47.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r10
mov r4.w, c48.z
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r12.w, r1, c48.z, r12
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r1.w, r2.y, r2, c48.z
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c50.y, c50
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c47.y
mad r2.y, r2.z, r3.z, c48.z
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.y, r4.w, c47
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c48
mul r1.w, r1, r2.y
mul r12.w, r1, r2.z
endif
mul r12.xyz, r12, r12.w
endif
add r4.xyz, -r10, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r10.xyz, -r10, c18
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r10, r10
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r10
dp3 r1.w, r4, r7
mul r3.y, r3, c50.w
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c48.z
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c50
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c48
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c50
mul r2.y, r5, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r10.xyz, r9.w, -r10
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r5.xyz, r1.w, c52, r2.y
mad r4.xyz, r12, r5, r4
add r5.xyz, r4, c17
pow r4, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r4
pow r5, c50.x, r10.y
pow r4, c50.x, r10.z
mov r10.y, r5
mov r10.z, r4
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r1.w, r3, c29.x
mad r14.xyz, r3.z, -c27, -r1.w
pow r10, c50.x, r14.x
pow r4, c50.x, r14.y
add r1.w, r8, -r11
mul r3.z, r1.w, r9.w
add r1.w, r3.z, r12.x
mov r10.y, r4
pow r4, c50.x, r14.z
mov r10.z, r4
rcp r2.y, r3.z
add r1.w, r1, -r13.x
add r2.z, -r12.x, r13.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mul r4.xyz, r10, r1.w
mov r1.w, c47.z
mul r10.xyz, r4, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r5
mov r4.w, c48.z
dp4 r12.y, r4, c5
dp4 r12.x, r4, c4
cmp r7.w, r1, c48.z, r7
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r3, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c50.y, c50
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r1.w, c24.z
mov r4.xy, r12
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r2.y, r2, r2.w, c48.z
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r3.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r4.x, r4.z, c47.y
mad r2.y, r2.z, r4.x, c48.z
add r2.z, r3.w, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.w, r4, c47.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3.w, c48
mul r1.w, r1, r2.y
mul r7.w, r1, r2.z
endif
mul r10.xyz, r10, r7.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.w, r4, r4
rsq r3.w, r3.w
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.w, r3.w
mul r3.w, r3, r2
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r7
mul r2.w, r2, c50
mul r2.w, r2, r2
mul r1.w, r1, c30.x
rcp r4.x, r2.w
add r1.w, r1, c48.z
rcp r2.w, r1.w
mul r1.w, r3, r4.x
mul r2.y, r2, r2.w
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c50.w
mov r4.xyz, c19
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c48
mul r1.w, r2.y, c50
mul r2.y, r3, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r5.xyz, r3.z, -r5
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r12.xyz, r1.w, c52, r2.y
mad r4.xyz, r10, r12, r4
add r10.xyz, r4, c17
pow r4, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r4
pow r4, c50.x, r5.y
pow r3, c50.x, r5.z
mov r5.y, r4
mov r5.z, r3
mul r9.xyz, r9, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r6
cmp r2.z, -r2.y, c48.y, c48
cmp r2.w, r2, c48.y, c48.z
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r8.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r8.w, c48.y, c48
cmp r9.w, -r2.z, r0, r1
mov r12.x, r2
mov r6.xyz, c47.z
if_gt r1.z, c47.z
frc r1.z, r8.w
add r1.z, r8.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r11.w, r1.z, r1, -r1
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r2.xyz, r10, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r15.y, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r15.y, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c48
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r5, r2.xyzz, s1
mul r1.z, r5.w, c29.x
mad r14.xyz, r5.z, -c27, -r1.z
pow r2, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r2
pow r2, c50.x, r14.z
add r3.x, r12, r9.w
add r2.x, -r12, r13.y
rcp r1.w, r9.w
add r1.z, r3.x, -r13.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mov r14.z, r2
mul r2.xyz, r14, r1.z
mov r1.z, c47
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r15, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r10
mov r2.w, c48.z
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r12.w, r1.z, c48.z, r12
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r3.z, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c48
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c50.y, c50.z
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r12.w, r1.z, r2.x
endif
mul r12.xyz, r12, r12.w
endif
add r2.xyz, -r10, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r10.xyz, -r10, c18
dp3 r2.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r10
rcp r3.z, r1.z
dp3 r1.z, r2, r7
mul r2.x, r3.z, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c50
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c50.w
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r10.xyz, r9.w, -r10
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.z, r2
mul r2.w, r13, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r13
mad r5.xyz, r1.z, c52, r2.w
mul r2.xyz, r2, c51.y
mad r2.xyz, r12, r5, r2
add r5.xyz, r2, c17
pow r2, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r2
pow r5, c50.x, r10.y
pow r2, c50.x, r10.z
mov r10.y, r5
mov r10.z, r2
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.z, -r1, c48
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r3, r2.xyzz, s1
mul r1.z, r3.w, c29.x
mad r14.xyz, r3.z, -c27, -r1.z
pow r10, c50.x, r14.x
pow r2, c50.x, r14.y
add r1.z, r8.w, -r11.w
mul r3.z, r1, r9.w
add r1.z, r3, r12.x
mov r10.y, r2
pow r2, c50.x, r14.z
mov r10.z, r2
rcp r1.w, r3.z
add r1.z, r1, -r13.x
add r2.x, -r12, r13.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mul r2.xyz, r10, r1.z
mov r1.z, c47
mul r10.xyz, r2, c15
if_gt c34.x, r1.z
add r3.w, r5, -c11.x
add r1.z, r3.w, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r5
mov r2.w, c48.z
dp4 r12.y, r2, c5
dp4 r12.x, r2, c4
cmp r7.w, r1.z, c48.z, r7
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.w, -c25.x
mul_sat r1.z, r1, r1.w
mul r1.w, r1.z, r1.z
mov r2.xy, r12
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r4.w, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r3.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r4, c48.z
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r3, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r7.w, r1.z, r2.x
endif
mul r10.xyz, r10, r7.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.w, r1, r2
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.w, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r4.w, r1.z
dp3 r1.z, r2, r7
mul r2.x, r4.w, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r3.w, r2.y
mul r1.w, r1, r2.x
mul r3.w, r1, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c50
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c50.w
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r3.y, c28.x
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.w, r2
mul r5.xyz, r3.z, -r5
mul r2.xyz, r2, c51.y
mul r1.w, r13, r1
mul r1.z, r1, r13
mad r12.xyz, r1.z, c52, r1.w
mad r2.xyz, r10, r12, r2
add r10.xyz, r2, c17
pow r2, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r2
pow r3, c50.x, r5.y
pow r2, c50.x, r5.z
mov r5.y, r3
mov r5.z, r2
mul r9.xyz, r9, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c48, c48.z
cmp r2.x, -r1.w, c48.y, c48.z
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r8.w, -r2.x, r1, r1.y
cmp r9.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r8.w, c48, c48.z
mov r2.xyz, r6
mov r12.x, r1
mov r6.xyz, c47.z
if_gt r1.y, c47.z
frc r1.x, r8.w
add r1.x, r8.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r1.x, r1.y, -r1.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r1.xyz, r10, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r15.y, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r15.y, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r5, r1.xyzz, s1
mul r1.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r1.x
pow r1, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r1
pow r1, c50.x, r14.z
add r3.x, r12, r9.w
rcp r1.y, r9.w
add r1.w, -r12.x, r13.y
add r1.x, r3, -r13
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r14.z, r1
mul r1.xyz, r14, r1.x
mov r1.w, c47.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r10
mov r1.w, c48.z
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r12.w, r2, c48.z, r12
if_gt r1.x, c47.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r3.w, r1.x, c47.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c48.z
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c47.y
mad r3.z, -r2.w, c50.y, c50
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c48.z
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r12.w, r1.x, r1.z
endif
mul r12.xyz, r12, r12.w
endif
add r1.xyz, -r10, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
add r2.w, r1.x, c48.z
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r10.xyz, -r10, c18
dp3 r1.x, r10, r10
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r10
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c50.w
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r10.xyz, r9.w, -r10
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r13.w, r1.w
mul r1.w, r2, r13.z
mad r5.xyz, r1.w, c52, r3.y
mul r1.xyz, r1, c51.y
mad r1.xyz, r12, r5, r1
add r5.xyz, r1, c17
pow r1, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r1
pow r5, c50.x, r10.y
pow r1, c50.x, r10.z
mov r10.y, r5
mov r10.z, r1
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r3, r1.xyzz, s1
mul r1.x, r3.w, c29
mad r14.xyz, r3.z, -c27, -r1.x
pow r10, c50.x, r14.x
pow r1, c50.x, r14.y
add r1.x, r8.w, -r11.w
mov r10.y, r1
mul r3.z, r1.x, r9.w
pow r1, c50.x, r14.z
add r1.x, r3.z, r12
rcp r1.y, r3.z
add r1.x, r1, -r13
add r1.w, -r12.x, r13.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r10.z, r1
mul r1.xyz, r10, r1.x
mov r1.w, c47.z
mul r10.xyz, r1, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r2.w, r3, -c25
mov r1.xyz, r5
mov r1.w, c48.z
dp4 r12.y, r1, c5
dp4 r12.x, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r7.w, r2, c48.z, r7
if_gt r1.x, c47.z
mov r1.w, c24.x
add r2.w, -c25.x, r1
rcp r4.w, r2.w
add r2.w, r3, -c25.x
mul_sat r2.w, r2, r4
mul r4.w, r2, r2
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r4, r2
mov r1.xy, r12
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r5.w, r1.x, c47.y
mov r1.x, c24.y
add r4.w, -c25.y, r1.x
mad r1.x, r2.w, r5.w, c48.z
rcp r4.w, r4.w
add r2.w, r3, -c25.y
mul_sat r2.w, r2, r4
add r5.w, r1.y, c47.y
mad r4.w, -r2, c50.y, c50.z
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r4
mad r2.w, r2, r5, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3.w, -c25.z
mul_sat r1.y, r1, r2.w
add r4.w, r1.z, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r4.w, c48.z
rcp r2.w, r2.w
add r1.z, r3.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r7.w, r1.x, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
rcp r3.w, r1.y
add r2.w, r1.x, c48.z
mul r4.w, r2, r3
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r4.w, r4, r3
dp3 r1.x, r5, r5
rsq r3.w, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r4.w, r1.x, r4
mul r1.xyz, r3.w, r5
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r4.w, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.w, r3.w
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.w, r3, c50
mul r1.y, r3.w, r3.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r2.w, r3.y, c28.x
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r2.w, r1
mul r5.xyz, r3.z, -r5
mul r1.w, r1, r13.z
mul r2.w, r13, r2
mad r12.xyz, r1.w, c52, r2.w
mul r1.xyz, r1, c51.y
mad r1.xyz, r10, r12, r1
add r10.xyz, r1, c17
pow r1, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r1
pow r3, c50.x, r5.y
pow r1, c50.x, r5.z
mov r5.y, r3
mov r5.z, r1
mul r9.xyz, r9, r5
endif
add r1.x, r15, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c48.y, c48
cmp r1.y, -r0.z, c48, c48.z
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r8.w, -r1.y, r0.z, r0.y
cmp r9.w, -r1.y, r0, r1.x
mov r1.xyz, r6
cmp_pp r0.y, -r8.w, c48, c48.z
mov r12.x, r0
mov r6.xyz, c47.z
if_gt r0.y, c47.z
frc r0.x, r8.w
add r0.x, r8.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r11.w, r0.x, r0.y, -r0.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r0.xyz, r10, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r15.y, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r15.y, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r5, r0.xyzz, s1
mul r0.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r0.x
pow r0, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r0
pow r0, c50.x, r14.z
add r3.x, r12, r9.w
rcp r0.y, r9.w
add r0.w, -r12.x, r13.y
add r0.x, r3, -r13
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r14.z, r0
mul r0.xyz, r14, r0.x
mov r0.w, c47.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r10
mov r0.w, c48.z
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r12.w, r1, c48.z, r12
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r3.z, r0.x, c47.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c48.z
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c47.y
mad r2.w, -r1, c50.y, c50.z
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c48.z
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.y, c50.y, c50.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0, r0.y
mul r12.w, r0.x, r0.z
endif
mul r12.xyz, r12, r12.w
endif
add r0.xyz, -r10, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
add r1.w, r0.x, c48.z
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r10.xyz, -r10, c18
dp3 r0.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r10
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c50
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c50
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c48.z
mul r0.w, r0.x, c50
mul r1.w, r5.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r10.xyz, r9.w, -r10
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r5.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r12, r5, r0
add r5.xyz, r0, c17
pow r0, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r0
pow r5, c50.x, r10.y
pow r0, c50.x, r10.z
mov r10.y, r5
mov r10.z, r0
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r3, r0.xyzz, s1
mul r0.x, r3.w, c29
mad r8.xyz, r3.z, -c27, -r0.x
pow r0, c50.x, r8.y
pow r10, c50.x, r8.x
add r0.x, r8.w, -r11.w
mul r3.z, r0.x, r9.w
mov r8.y, r0
pow r0, c50.x, r8.z
add r0.x, r3.z, r12
rcp r0.y, r3.z
add r0.x, r0, -r13
add r0.w, -r12.x, r13.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r8.x, r10
mov r8.z, r0
mul r0.xyz, r8, r0.x
mov r0.w, c47.z
mul r10.xyz, r0, c15
if_gt c34.x, r0.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
mov r0.xyz, r5
mov r0.w, c48.z
dp4 r12.y, r0, c5
dp4 r12.x, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r7.w, r1, c48.z, r7
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r12
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r4.w, r0.x, c47.y
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r3.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c47.y
mad r0.y, -r0.x, c50, c50.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c48.z
mad r1.w, r1, r4, c48.z
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r3.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.x, c50.y, c50.z
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0.y, r0
mul r7.w, r0.x, r0.z
endif
mul r10.xyz, r10, r7.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c48.z
mul r3.w, r1, r2
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.w, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.w, r0.z, c50
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c50
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c50
min r0.y, r3.w, c48.z
mul r1.w, r3.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r5.xyz, r3.z, -r5
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r7.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r10, r7, r0
add r7.xyz, r0, c17
pow r0, c50.x, r5.x
mul r3.xyz, r7, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r0
pow r3, c50.x, r5.y
pow r0, c50.x, r5.z
mov r5.y, r3
mov r5.z, r0
mul r9.xyz, r9, r5
endif
mov r3, c37
add r3, -c41, r3
mov r0, c36
mov r7, c39
mov r8, c38
add r7, -c43, r7
add r8, -c42, r8
add r0, -c40, r0
mad r5, r6.w, r3, c41
mad r3, r6.w, r0, c40
texldl r1.w, v0, s5
mov r0.z, r1.w
texldl r0.w, v0, s4
mov r0.y, r0.w
texldl r1.w, v0, s3
mov r0.x, r1.w
mov r0.w, c48.z
dp4 r10.x, r3, r0
dp4 r3.x, r3, r3
mad r7, r6.w, r7, c43
mad r8, r6.w, r8, c42
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r10.y, r5, r0
dp4 r10.w, r7, r0
dp4 r10.z, r8, r0
add r0, r10, c47.y
dp4 r3.w, r7, r7
mad r0, r3, r0, c48.z
mad r1.xyz, r6, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r11
mul r1.xyz, r0.y, c53
mad r1.xyz, r0.x, c54, r1
mad r0.xyz, r0.z, c55, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c51.z
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c51.z
add r0.z, r0.x, c51.w
cmp r0.z, r0, c48, c48.y
mul_pp r1.x, r0.z, c52.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c53.w
frc r1.x, r0
add r2.x, r0, -r1
add_pp r0.x, r2, c54.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c56, c56.y
mul r3.xyz, r9.y, c53
mad r1.xyz, r9.x, c54, r3
mad r1.xyz, r9.z, c55, r1
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.x, c55.w
mul_pp r0.x, r0, r2.y
mul r2.xy, r1, r1.z
mul r0.w, r0, c51.y
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c51
min r0.w, r0, c56.z
mad r0.z, r0, c56.w, r0.w
mad r0.z, r0, c57.x, c57.y
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c51.z
add r1.z, r1.x, c51.w
cmp r0.w, r1.z, c48.z, c48.y
mul_pp r1.z, r0.w, c52.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c51.y
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c53.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c55.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c56.z
mad r0.z, r0.x, c56.w, r1.x
add_pp r0.x, r0.y, c54.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c56, c56.y
mad r0.z, r0, c57.x, c57.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r1.y

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 renders sky with 4 cloud layers
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
SetTexture 6 [_TexCloudLayer3] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[57] = { program.local[0..46],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.001, 0.75 },
		{ 1, 1.5, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 0.0009765625 } };
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
SHORT OUTPUT oCol = result.color;
MOVR  R5.x, c[48].y;
MULR  R1.xy, fragment.texcoord[0], c[8];
MOVR  R0.xy, c[8];
MADR  R0.xy, R1, c[47].x, -R0;
MOVR  R0.z, c[47].y;
DP3R  R0.w, R0, R0;
RSQR  R2.w, R0.w;
MULR  R0.xyz, R2.w, R0;
MOVR  R0.w, c[47].z;
DP4R  R1.z, R0, c[2];
DP4R  R1.y, R0, c[1];
DP4R  R1.x, R0, c[0];
MOVR  R0, c[24];
MOVR  R8.x, c[48].y;
MOVR  R8.y, c[48];
MOVR  R8.z, c[48].y;
MOVR  R2.x, c[0].w;
MOVR  R2.z, c[2].w;
MOVR  R2.y, c[1].w;
MULR  R3.xyz, R2, c[13].x;
ADDR  R2.xyz, R3, -c[9];
DP3R  R1.w, R1, R2;
MULR  R3.w, R1, R1;
DP3R  R5.y, R2, R2;
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
SLTR  R6, R3.w, R0;
MOVXC RC.x, R6;
MOVR  R5.x(EQ), R4;
ADDR  R4, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.x, R4.z;
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
ADDR  R5.x(NE.z), -R1.w, R4;
MOVXC RC.z, R6;
MOVR  R8.x(EQ.z), R5.z;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R8.x(NE.y), -R1.w, R0;
RSQR  R0.x, R4.w;
MOVXC RC.y, R6;
MOVR  R4.x, c[48];
MOVR  R4.z, c[48].x;
MOVR  R4.w, c[48].x;
MOVR  R8.y(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R8.y(NE.w), -R1.w, R0.x;
RSQR  R0.x, R4.y;
MOVR  R8.z(EQ.y), R5;
RCPR  R0.x, R0.x;
ADDR  R8.z(NE.x), -R1.w, R0.x;
MOVR  R0, c[25];
ADDR  R0, R0, c[11].x;
MADR  R0, -R0, R0, R5.y;
ADDR  R6, R3.w, -R0;
RSQR  R4.y, R6.x;
SLTR  R7, R3.w, R0;
MOVXC RC.x, R7;
MOVR  R4.x(EQ), R5.z;
SGERC HC, R3.w, R0.yzxw;
RCPR  R4.y, R4.y;
ADDR  R4.x(NE.z), -R1.w, -R4.y;
MOVXC RC.z, R7;
MOVR  R4.z(EQ), R5;
RSQR  R0.x, R6.z;
RCPR  R0.x, R0.x;
ADDR  R4.z(NE.y), -R1.w, -R0.x;
MOVXC RC.z, R7.w;
RSQR  R0.x, R6.w;
MOVR  R4.w(EQ.z), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE), -R1, -R0.x;
RSQR  R0.x, R6.y;
MOVR  R4.y, c[48].x;
MOVXC RC.y, R7;
MOVR  R4.y(EQ), R5.z;
RCPR  R0.x, R0.x;
ADDR  R4.y(NE.x), -R1.w, -R0.x;
MOVR  R0.x, c[31];
ADDR  R0.x, R0, c[11];
MADR  R0.x, -R0, R0, R5.y;
ADDR  R0.y, R3.w, -R0.x;
RSQR  R0.y, R0.y;
MOVR  R6.x, c[48];
SLTRC HC.x, R3.w, R0;
MOVR  R6.x(EQ), R5.z;
MOVR  R0.zw, c[47].z;
SGERC HC.x, R3.w, R0;
MADR  R5.y, -c[12].x, c[12].x, R5;
ADDR  R0.x, R3.w, -R5.y;
RCPR  R0.y, R0.y;
ADDR  R6.x(NE), -R1.w, -R0.y;
MOVXC RC.x, R6;
MOVR  R6.x(LT), c[48];
SLTRC HC.x, R3.w, R5.y;
MOVR  R0.zw(EQ.x), R5;
SGERC HC.x, R3.w, R5.y;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, -R1.w, -R0.x;
ADDR  R1.w, -R1, R0.x;
MAXR  R0.x, R0.y, c[47].z;
MAXR  R0.y, R1.w, c[47].z;
MOVR  R0.zw(NE.x), R0.xyxy;
MOVR  R3.w, c[47];
DP4R  R0.x, R4, c[40];
MOVR  R5.y, R8.z;
MOVR  R5.w, R8.y;
MOVR  R5.z, R8.x;
DP4R  R0.y, R5, c[36];
DP4R  R1.w, R5, c[35];
SGER  R1.w, c[47].z, R1;
ADDR  R0.y, R0, -R0.x;
MADR  R0.y, R1.w, R0, R0.x;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
MULR  R3.w, R3, c[8];
RCPR  R2.w, R2.w;
MULR  R2.w, R0.x, R2;
MADR  R6.x, -R2.w, c[13], R6;
SGER  H0.x, R0, R3.w;
MULR  R2.w, R2, c[13].x;
MADR  R0.x, H0, R6, R2.w;
MINR  R6.w, R0, R0.x;
MAXR  R2.w, R0.z, c[48].z;
MINR  R0.x, R6.w, R0.y;
MAXR  R10.y, R2.w, R0.x;
ADDR  R6.y, R6.w, -R2.w;
RCPR  R0.x, R6.y;
MULR  R8.w, R0.x, c[32].x;
ADDR  R3.w, R10.y, -R2;
MULR  R6.x, R8.w, R3.w;
RCPR  R7.x, c[32].x;
MULR  R9.w, R6.y, R7.x;
MOVR  R0, c[45].zywx;
ADDR  R0, -R0.yxzw, c[44].yzwx;
MADR  R0, R1.w, R0, c[45].yzwx;
MULR  R0, R0, c[33].x;
MULR  R7.xyz, R1.zxyw, c[16].yzxw;
MOVR  R9.x, R0;
MOVR  R10.x, R0.y;
ADDR  R0.x, c[46], -c[46].y;
MADR  R0.x, R1.w, R0, c[46].y;
SLTR  H0.y, R6.x, R0.w;
SGTR  H0.x, R6, c[47].z;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R6.x;
RCPR  R6.z, R0.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R3, R6.z;
MULR  R6.xyz, R2.zxyw, c[16].yzxw;
MADR  R6.xyz, R2.yzxw, c[16].zxyw, -R6;
DP3R  R2.x, R2, c[16];
MOVR  R11.w(NE.x), R0;
SLER  H0.y, R2.x, c[47].z;
DP3R  R0.w, R6, R6;
MADR  R7.xyz, R1.yzxw, c[16].zxyw, -R7;
DP3R  R3.w, R6, R7;
DP3R  R6.x, R7, R7;
MADR  R0.w, -c[11].x, c[11].x, R0;
MULR  R6.z, R6.x, R0.w;
MULR  R6.y, R3.w, R3.w;
ADDR  R0.w, R6.y, -R6.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.y, -R3.w, R0.w;
MOVR  R2.z, c[48].y;
MOVR  R2.x, c[48];
ADDR  R0.w, -R3, -R0;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
SGTR  H0.z, R6.y, R6;
MULX  H0.y, H0, c[14].x;
MULX  H0.y, H0, H0.z;
MOVXC RC.x, H0.y;
RCPR  R6.x, R6.x;
MULR  R2.z(NE.x), R6.x, R2.y;
MULR  R2.x(NE), R0.w, R6;
MOVR  R2.y, R2.z;
MOVR  R14.xy, R2;
MADR  R2.xyz, R1, R2.x, R3;
ADDR  R2.xyz, R2, -c[9];
DP3R  R0.w, R2, c[16];
SGTR  H0.z, R0.w, c[47];
MULXC HC.x, H0.y, H0.z;
MOVR  R14.xy(NE.x), c[48];
MOVXC RC.x, H0;
DP4R  R2.x, R4, c[41];
DP4R  R0.w, R5, c[37];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R11.y, R10, R0.w;
DP4R  R2.x, R4, c[42];
DP4R  R0.w, R5, c[38];
ADDR  R0.w, R0, -R2.x;
MADR  R0.w, R1, R0, R2.x;
MINR  R0.w, R6, R0;
MAXR  R13.x, R11.y, R0.w;
DP4R  R0.w, R4, c[43];
DP4R  R2.x, R5, c[39];
ADDR  R2.x, R2, -R0.w;
MADR  R0.w, R1, R2.x, R0;
MINR  R0.w, R6, R0;
DP3R  R0.y, R1, c[16];
MULR  R7.w, R0.x, c[33].x;
MULR  R0.x, R0.y, c[30];
MULR  R0.y, R0, R0;
MULR  R0.x, R0, c[47];
MADR  R0.x, c[30], c[30], R0;
MADR  R14.z, R0.y, c[48].w, c[48].w;
ADDR  R0.y, R0.x, c[49].x;
MOVR  R0.x, c[49];
POWR  R0.y, R0.y, c[49].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MAXR  R3.w, R13.x, R0;
MOVR  R11.x, R0.z;
MOVR  R4.w, R6;
MULR  R14.w, R0.x, R0.y;
MOVR  R4.xyz, c[49].x;
MOVR  R7.xyz, c[47].z;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R11.y, -R10.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R9.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R9.x;
RCPR  R0.z, R9.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R9.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R10.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R5, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R5.y, R5, R2;
MOVR  R2.y, c[50].w;
MADR  R6.y, -R5, c[47].x, R2;
MULR  R6.x, R5.y, R5.y;
RCPR  R5.y, R2.x;
MULR  R2.x, R6, R6.y;
TEX   R6, R0.zwzw, texture[2], 2D;
MULR_SAT R5.x, R5, R5.y;
MADR  R0.w, R6.y, R2.x, -R2.x;
MADR  R0.z, -R5.x, c[47].x, R2.y;
MULR  R2.x, R5, R5;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R6.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R5.w;
MULR_SAT R0.w, R0, R5.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R6.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R6, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R13, -R11.y;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R10.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R10.x;
RCPR  R0.z, R10.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R10.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R11.y;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R3.w, -R13;
MULR  R0.y, R0.x, R8.w;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R11.x;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVR  R11.w(NE.x), R11.x;
RCPR  R0.z, R11.x;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.xyz, R7;
MOVX  H0.x, c[47].z;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R13.x;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
RCPR  R2.x, R5.y;
ADDR  R6, R6.x, -c[25];
MULR_SAT R2.x, R6.y, R2;
MOVR  R5.y, c[50].w;
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R5.y;
RCPR  R2.x, R5.x;
MULR_SAT R6.x, R6, R2;
MULR  R5.x, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R5.x, -R5.x;
MULR  R2.y, R6.x, R6.x;
MADR  R0.z, -R6.x, c[47].x, R5.y;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R5.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R5.y;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R5.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R5.y, -R2.w, R5.x, R5.x;
MOVR  R2.xyz, c[21];
MULR  R5.x, R5.y, R5;
ADDR  R2.xyz, -R2, c[22];
DP3R  R5.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MULR  R5.y, R5, R5.x;
DP3R  R5.z, R2, R2;
RSQR  R5.x, R5.z;
MULR  R2.xyz, R5.x, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R2.w, R5.x;
RCPR  R0.w, R0.w;
MULR  R0.w, R5.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R2.xyz, R2, R11.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
ADDR  R0.x, R4.w, -R3.w;
MULR  R0.y, R0.x, R8.w;
MOVR  R13.xyz, R7;
SGTR  H0.x, R0.y, c[47].z;
SLTR  H0.y, R0, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R11.w, R0.y;
MOVX  H0.x, c[47].z;
RCPR  R0.z, R7.w;
MOVR  R12.w, R9;
MULR  R12.w(NE.x), R0.x, R0.z;
MOVR  R11.w(NE.x), R7;
MOVXC RC.x, R11.w;
MOVX  H0.x(GT), c[49];
MOVXC RC.x, H0;
MOVR  R7.xyz, c[47].z;
MOVR  R2.w, R3;
IF    NE.x;
FLRR  R13.w, R11;
MOVR  R15.x, c[47].z;
LOOP c[50];
SLTRC HC.x, R15, R13.w;
BRK   (EQ.x);
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
ADDR  R15.y, R2.w, R12.w;
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
RCPR  R0.w, R12.w;
ADDR  R0.z, R15.y, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R15;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R15.z, R0;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R5, -R2, c[24];
ADDR  R6, R6.x, -c[25];
RCPR  R2.x, R5.y;
MULR_SAT R2.x, R6.y, R2;
MOVR  R3.w, c[50];
MULR  R2.y, R2.x, R2.x;
MADR  R2.z, -R2.x, c[47].x, R3.w;
RCPR  R2.x, R5.x;
MULR_SAT R5.x, R6, R2;
MULR  R4.w, R2.y, R2.z;
TEX   R2, R0.zwzw, texture[2], 2D;
MADR  R0.w, R2.y, R4, -R4;
MULR  R2.y, R5.x, R5.x;
MADR  R0.z, -R5.x, c[47].x, R3.w;
MULR  R0.z, R2.y, R0;
MADR  R0.z, R2.x, R0, -R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R2.x, R5.w;
RCPR  R0.w, R5.z;
MULR_SAT R2.y, R2.x, R6.w;
MULR_SAT R0.w, R0, R6.z;
MADR  R2.x, -R0.w, c[47], R3.w;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.y, c[47], R3.w;
MADR  R0.w, R2.z, R0, -R0;
MULR  R2.y, R2, R2;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R2, R2.x, -R2.x;
MADR  R15.z, R0.w, R0, R0;
ENDIF;
MULR  R12.xyz, R12, R15.z;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.w, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R4.w, -R2, R3, R3;
MOVR  R2.xyz, c[21];
MULR  R3.w, R4, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R4.w, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
DP3R  R5.x, R2, R2;
MULR  R4.w, R4, R3;
RSQR  R3.w, R5.x;
MULR  R2.xyz, R3.w, R2;
DP3R  R2.x, R2, R1;
MADR  R0.z, R2.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R2.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R2.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R4, R0;
MULR  R0.w, R0, c[51];
MOVR  R2.xyz, c[18];
ADDR  R2.xyz, -R2, c[19];
DP3R  R2.x, R2, R2;
RCPR  R2.w, R3.w;
MULR  R2.w, R2, c[51];
MULR  R2.y, R2.w, R2.w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
RCPR  R2.y, R2.y;
MULR  R0.z, R2.x, R0;
MULR  R0.z, R0, R2.y;
MINR  R0.w, R0, c[49].x;
MULR  R2.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R2.xyz, R0.z, c[20], R2;
MULR  R0.z, R0.y, c[28].x;
MULR  R2.xyz, R2, c[52].x;
MULR  R2.xyz, R0.z, R2;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R5.xyz, R0.w, c[51], R0.z;
MULR  R2.xyz, R2, c[52].y;
MADR  R2.xyz, R12, R5, R2;
MULR  R0.y, R0, c[29].x;
ADDR  R2.xyz, R2, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R12.w, -R0;
MULR  R2.xyz, R2, R12.w;
MADR  R7.xyz, R2, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
MOVR  R2.w, R15.y;
ADDR  R15.x, R15, c[49];
ENDLOOP;
MADR  R8.xyz, R2.w, R1, R3;
ADDR  R0.xyz, R8, -c[9];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R5.x, R0.x;
MOVR  R0.x, c[11];
ADDR  R2.x, -R0, c[12];
MOVR  R0.xyz, c[10];
DP3R  R0.x, R0, c[16];
MOVXC RC.x, c[34];
ADDR  R0.w, R5.x, -c[11].x;
RCPR  R2.x, R2.x;
MULR  R0.y, R0.w, R2.x;
MADR  R0.x, -R0, c[49].z, c[49].z;
TEX   R0, R0, texture[1], 2D;
MULR  R0.w, R0, c[29].x;
MADR  R2.xyz, R0.z, -c[27], -R0.w;
ADDR  R0.z, R11.w, -R13.w;
MULR  R11.w, R0.z, R12;
ADDR  R0.z, R11.w, R2.w;
RCPR  R0.w, R11.w;
ADDR  R0.z, R0, -R14.x;
ADDR  R2.w, -R2, R14.y;
POWR  R2.x, c[49].w, R2.x;
POWR  R2.y, c[49].w, R2.y;
POWR  R2.z, c[49].w, R2.z;
MULR_SAT R2.w, R0, R2;
MULR_SAT R0.z, R0, R0.w;
MULR  R0.z, R0, R2.w;
MADR  R2.xyz, -R0.z, R2, R2;
MULR  R12.xyz, R2, c[15];
IF    NE.x;
ADDR  R6.x, R5, -c[11];
MOVR  R0.z, c[49].x;
SGERC HC.x, R6, c[25].w;
MOVR  R0.z(EQ.x), R10.w;
SLTRC HC.x, R6, c[25].w;
MOVR  R2.w, c[49].x;
MOVR  R2.xyz, R8;
MOVR  R10.w, R0.z;
DP4R  R0.w, R2, c[5];
DP4R  R0.z, R2, c[4];
IF    NE.x;
MOVR  R2, c[25];
ADDR  R2, -R2, c[24];
ADDR  R3, R6.x, -c[25];
RCPR  R2.y, R2.y;
MULR_SAT R3.y, R3, R2;
MOVR  R2.y, c[50].w;
MADR  R5.x, -R3.y, c[47], R2.y;
MULR  R4.w, R3.y, R3.y;
RCPR  R3.y, R2.x;
MULR  R2.x, R4.w, R5;
TEX   R5, R0.zwzw, texture[2], 2D;
MULR_SAT R3.x, R3, R3.y;
MADR  R0.w, R5.y, R2.x, -R2.x;
MADR  R0.z, -R3.x, c[47].x, R2.y;
MULR  R2.x, R3, R3;
MULR  R0.z, R2.x, R0;
ADDR  R0.w, R0, c[49].x;
MADR  R0.z, R5.x, R0, -R0;
MADR  R0.z, R0, R0.w, R0.w;
RCPR  R0.w, R2.z;
RCPR  R2.x, R2.w;
MULR_SAT R2.z, R2.x, R3.w;
MULR_SAT R0.w, R0, R3.z;
MADR  R2.x, -R0.w, c[47], R2.y;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R2.x;
MADR  R2.x, -R2.z, c[47], R2.y;
MADR  R0.w, R5.z, R0, -R0;
MULR  R2.y, R2.z, R2.z;
MADR  R0.z, R0.w, R0, R0;
MULR  R2.x, R2.y, R2;
MADR  R0.w, R5, R2.x, -R2.x;
MADR  R10.w, R0, R0.z, R0.z;
ENDIF;
MULR  R12.xyz, R12, R10.w;
ENDIF;
ADDR  R2.xyz, -R8, c[21];
DP3R  R0.z, R2, R2;
RSQR  R0.w, R0.z;
MULR  R2.xyz, R0.w, R2;
RCPR  R0.w, R0.w;
MULR  R0.w, R0, c[51];
MULR  R0.w, R0, R0;
DP3R  R2.x, R1, R2;
MOVR  R0.z, c[49].x;
MADR  R2.x, R2, c[30], R0.z;
RCPR  R3.x, R2.x;
MULR  R2.w, c[30].x, c[30].x;
MADR  R3.y, -R2.w, R3.x, R3.x;
MOVR  R2.xyz, c[21];
MULR  R3.x, R3.y, R3;
ADDR  R2.xyz, -R2, c[22];
DP3R  R3.y, R2, R2;
ADDR  R2.xyz, -R8, c[18];
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
DP3R  R3.z, R2, R2;
MULR  R3.y, R3, R3.x;
RSQR  R3.x, R3.z;
MULR  R2.xyz, R3.x, R2;
DP3R  R1.x, R2, R1;
MADR  R0.z, R1.x, c[30].x, R0;
RCPR  R0.z, R0.z;
MADR  R1.x, -R2.w, R0.z, R0.z;
MULR  R0.z, R1.x, R0;
RCPR  R0.w, R0.w;
MULR  R0.w, R3.y, R0;
MULR  R0.w, R0, c[51];
MOVR  R1.xyz, c[18];
ADDR  R1.xyz, -R1, c[19];
DP3R  R1.x, R1, R1;
RCPR  R2.x, R3.x;
MULR  R2.x, R2, c[51].w;
MULR  R1.y, R2.x, R2.x;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
RCPR  R1.y, R1.y;
MULR  R0.z, R1.x, R0;
MULR  R0.z, R0, R1.y;
MINR  R0.w, R0, c[49].x;
MULR  R1.xyz, R0.w, c[23];
MULR  R0.w, R0.x, c[26].x;
MULR  R0.z, R0, c[51].w;
MINR  R0.z, R0, c[49].x;
MADR  R1.xyz, R0.z, c[20], R1;
MULR  R0.z, R0.y, c[28].x;
MULR  R1.xyz, R1, c[52].x;
MULR  R1.xyz, R0.z, R1;
MULR  R0.z, R14.w, R0;
MULR  R0.w, R0, R14.z;
MADR  R2.xyz, R0.w, c[51], R0.z;
MULR  R1.xyz, R1, c[52].y;
MADR  R1.xyz, R12, R2, R1;
MULR  R0.y, R0, c[29].x;
ADDR  R1.xyz, R1, c[17];
MADR  R0.xyz, R0.x, c[27], R0.y;
MULR  R0.xyz, R11.w, -R0;
MULR  R1.xyz, R1, R11.w;
MADR  R7.xyz, R1, R4, R7;
POWR  R0.x, c[49].w, R0.x;
POWR  R0.y, c[49].w, R0.y;
POWR  R0.z, c[49].w, R0.z;
MULR  R4.xyz, R4, R0;
ENDIF;
MOVR  R2, c[41];
ADDR  R2, -R2, c[37];
MOVR  R0, c[40];
MOVR  R8, c[43];
ADDR  R0, -R0, c[36];
MADR  R3, R1.w, R2, c[41];
MADR  R2, R1.w, R0, c[40];
TEX   R4.w, fragment.texcoord[0], texture[5], 2D;
MOVR  R0.z, R4.w;
TEX   R5.w, fragment.texcoord[0], texture[4], 2D;
MOVR  R0.y, R5.w;
TEX   R4.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R5, c[42];
ADDR  R5, -R5, c[38];
TEX   R0.w, fragment.texcoord[0], texture[6], 2D;
MOVR  R0.x, R4.w;
MADR  R5, R1.w, R5, c[42];
ADDR  R8, -R8, c[39];
MADR  R1, R1.w, R8, c[43];
DP4R  R6.w, R0, R1;
DP4R  R6.x, R0, R2;
DP4R  R6.y, R0, R3;
DP4R  R6.z, R0, R5;
DP4R  R0.w, R1, R1;
DP4R  R0.x, R2, R2;
DP4R  R0.y, R3, R3;
DP4R  R0.z, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[49].x;
MADR  R1.xyz, R7, R0.w, R13;
MADR  R1.xyz, R1, R0.z, R11;
MADR  R1.xyz, R1, R0.y, R10;
MADR  R0.xyz, R1, R0.x, R9;
MULR  R1.xyz, R0.y, c[55];
MADR  R1.xyz, R0.x, c[54], R1;
MADR  R0.xyz, R0.z, c[53], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.zw, R0, c[52].xyzy;
FLRR  R0.zw, R0;
MINR  R0.x, R0.z, c[52].z;
SGER  H0.x, R0, c[52].w;
MULH  H0.y, H0.x, c[52].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[53].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[54].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[55].w;
MULR  R1.xyz, R4.y, c[55];
MADR  R1.xyz, R4.x, c[54], R1;
MADR  R1.xyz, R4.z, c[53], R1;
ADDR  R1.w, R1.x, R1.y;
ADDR  R0.z, R1, R1.w;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R1.zw, R1, c[52].xyzy;
FLRR  R1.zw, R1;
MOVH  oCol.x, R0.y;
MADH  H0.x, H0, c[47], H0.z;
MINR  R0.z, R1, c[52];
SGER  H0.z, R0, c[52].w;
ADDR  R0.x, R0, -H0.y;
MINR  R0.w, R0, c[50].x;
MADR  R0.x, R0, c[56], R0.w;
MULH  H0.y, H0.z, c[52].w;
ADDR  R0.w, R0.z, -H0.y;
MOVR  R0.z, c[49].x;
MADR  H0.y, R0.x, c[56], R0.z;
MULR  R1.x, R0.w, c[53].w;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[55].w;
ADDR  R0.x, R0.w, -H0;
ADDH  H0.x, H0.w, -c[54].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R1.w, c[50].x;
MADR  R0.x, R0, c[56], R0.y;
MADR  H0.z, R0.x, c[56].y, R0;
MADH  H0.x, H0.y, c[47], H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_CameraData]
Matrix 0 [_Camera2World]
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
SetTexture 2 [_TexShadowMap] 2D
Float 26 [_DensitySeaLevel_Rayleigh]
Vector 27 [_Sigma_Rayleigh]
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
SetTexture 6 [_TexCloudLayer3] 2D
Float 31 [_PlanetRadiusOffsetKm]
Float 32 [_SkyStepsCount]
Float 33 [_UnderCloudsMinStepsCount]
Float 34 [_bGodRays]
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c47, 2.00000000, -1.00000000, 0.00000000, 0.99500000
def c48, 1000000.00000000, 0.00000000, 1.00000000, -1000000.00000000
def c49, 0.00100000, 0.75000000, 1.50000000, 0.50000000
defi i0, 255, 0, 1, 0
def c50, 2.71828198, 2.00000000, 3.00000000, 1000.00000000
def c51, 10.00000000, 400.00000000, 210.00000000, -128.00000000
def c52, 5.60204458, 9.47328472, 19.64380264, 128.00000000
def c53, 0.26506799, 0.67023426, 0.06409157, 0.25000000
def c54, 0.51413637, 0.32387859, 0.16036376, -15.00000000
def c55, 0.02411880, 0.12281780, 0.84442663, 4.00000000
def c56, 2.00000000, 1.00000000, 255.00000000, 256.00000000
def c57, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c47.x, c47.y
mov r0.z, c47.y
mul r0.xy, r0, c8
dp3 r0.w, r0, r0
rsq r2.z, r0.w
mul r0.xyz, r2.z, r0
mov r0.w, c47.z
dp4 r7.z, r0, c2
dp4 r7.y, r0, c1
dp4 r7.x, r0, c0
mov r0.z, c11.x
mov r0.w, c11.x
mul r9.xyz, r7.zxyw, c16.yzxw
mad r9.xyz, r7.yzxw, c16.zxyw, -r9
mov r1.x, c0.w
mov r1.z, c2.w
mov r1.y, c1.w
mul r8.xyz, r1, c13.x
add r6.xyz, r8, -c9
dp3 r0.y, r7, r6
dp3 r0.x, r6, r6
add r0.w, c25.y, r0
mad r1.x, -r0.w, r0.w, r0
mad r1.y, r0, r0, -r1.x
rsq r1.z, r1.y
add r0.z, c25.x, r0
mad r0.z, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.x, -r0.w, r0.z, r1
cmp_pp r0.w, r1.y, c48.z, c48.y
rcp r1.z, r1.z
add r1.z, -r0.y, -r1
cmp r1.y, r1, r1.w, c48.x
cmp r1.y, -r0.w, r1, r1.z
mov r0.z, c11.x
add r0.w, c25.z, r0.z
mov r0.z, c11.x
add r1.z, c25.w, r0
mad r0.w, -r0, r0, r0.x
mad r0.z, r0.y, r0.y, -r0.w
mad r1.z, -r1, r1, r0.x
mad r2.w, r0.y, r0.y, -r1.z
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.z, -r0.y, -r0.w
cmp_pp r0.w, r0.z, c48.z, c48.y
cmp r0.z, r0, r1.w, c48.x
cmp r1.z, -r0.w, r0, r1
rsq r3.x, r2.w
rcp r3.x, r3.x
cmp r0.w, r2, r1, c48.x
add r3.x, -r0.y, -r3
cmp_pp r0.z, r2.w, c48, c48.y
cmp r1.w, -r0.z, r0, r3.x
mov r0.w, c11.x
add r2.w, c24.x, r0
mov r0.w, c11.x
add r3.x, c24.y, r0.w
mad r2.w, -r2, r2, r0.x
mad r0.w, r0.y, r0.y, -r2
mad r3.x, -r3, r3, r0
mad r3.y, r0, r0, -r3.x
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.x, -r2.w, r0.w, r3
rsq r3.z, r3.y
rcp r3.z, r3.z
dp4 r0.z, r1, c41
cmp r3.x, r3.y, r2, c48.w
add r3.z, -r0.y, r3
cmp_pp r2.w, r3.y, c48.z, c48.y
cmp r5.y, -r2.w, r3.x, r3.z
mov r0.w, c11.x
add r2.w, c24, r0
mad r2.w, -r2, r2, r0.x
mad r3.x, r0.y, r0.y, -r2.w
rsq r2.w, r3.x
rcp r3.y, r2.w
add r3.z, -r0.y, r3.y
cmp_pp r3.y, r3.x, c48.z, c48
cmp r3.x, r3, r2, c48.w
cmp r5.w, -r3.y, r3.x, r3.z
mov r0.w, c11.x
add r0.w, c24.z, r0
mad r0.w, -r0, r0, r0.x
mad r0.w, r0.y, r0.y, -r0
rsq r2.w, r0.w
rcp r2.w, r2.w
add r3.x, -r0.y, r2.w
cmp_pp r2.w, r0, c48.z, c48.y
cmp r0.w, r0, r2.x, c48
cmp r5.z, -r2.w, r0.w, r3.x
dp4 r0.w, r5, c37
add r3.x, r0.w, -r0.z
dp4 r2.w, r5, c35
cmp r6.w, -r2, c48.z, c48.y
mad r0.z, r6.w, r3.x, r0
mov r0.w, c11.x
add r0.w, c31.x, r0
mad r0.w, -r0, r0, r0.x
mad r2.w, r0.y, r0.y, -r0
dp4 r3.y, r1, c40
dp4 r3.x, r5, c36
add r3.z, r3.x, -r3.y
rsq r0.w, r2.w
rcp r3.x, r0.w
mad r0.w, r6, r3.z, r3.y
add r3.y, -r0, -r3.x
cmp_pp r3.x, r2.w, c48.z, c48.y
cmp r2.w, r2, r2.x, c48.x
cmp r2.w, -r3.x, r2, r3.y
cmp r3.x, r2.w, r2.w, c48
mad r0.x, -c12, c12, r0
mad r2.w, r0.y, r0.y, -r0.x
cmp r2.xy, r2.w, r2, c47.z
rcp r2.z, r2.z
texldl r0.x, v0, s0
mul r3.y, r0.x, r2.z
mad r3.z, -r3.y, c13.x, r3.x
rsq r3.x, r2.w
mov r2.z, c8.w
mad r0.x, c47.w, -r2.z, r0
rcp r3.x, r3.x
mul r2.z, r3.y, c13.x
cmp r0.x, r0, c48.z, c48.y
mad r3.y, r0.x, r3.z, r2.z
add r0.x, -r0.y, -r3
add r0.y, -r0, r3.x
cmp_pp r2.z, r2.w, c48, c48.y
mov r2.w, c44.y
add r2.w, -c45.y, r2
mad r2.w, r6, r2, c45.y
max r0.x, r0, c47.z
max r0.y, r0, c47.z
cmp r0.xy, -r2.z, r2, r0
min r3.x, r0.y, r3.y
max r12.x, r0, c49
min r0.y, r3.x, r0.w
min r0.x, r3, r0.z
max r4.x, r12, r0.y
dp4 r0.z, r1, c42
dp4 r0.y, r5, c38
add r0.y, r0, -r0.z
max r2.x, r4, r0
mad r0.x, r6.w, r0.y, r0.z
dp4 r0.z, r1, c43
dp4 r0.y, r5, c39
add r0.y, r0, -r0.z
min r0.x, r3, r0
mul r5.xyz, r6.zxyw, c16.yzxw
mad r0.y, r6.w, r0, r0.z
max r1.x, r2, r0
min r0.x, r3, r0.y
mov r0.y, c44.x
add r0.z, -c45.x, r0.y
mad r0.w, r6, r0.z, c45.x
mul r1.w, r0, c33.x
add r0.y, r3.x, -r12.x
rcp r0.z, r0.y
mad r5.xyz, r6.yzxw, c16.zxyw, -r5
rcp r2.z, r1.w
add r1.y, r4.x, -r12.x
mul r0.z, r0, c32.x
mul r1.z, r0, r1.y
add r0.w, r1.z, -r1
cmp r2.y, r0.w, c48, c48.z
cmp r0.w, -r1.z, c48.y, c48.z
mul_pp r2.y, r0.w, r2
cmp r8.w, -r2.y, r1.z, r1
rcp r0.w, c32.x
mul r0.w, r0.y, r0
mul r1.y, r1, r2.z
cmp r9.w, -r2.y, r0, r1.y
dp3 r0.y, r5, r5
dp3 r1.y, r5, r9
dp3 r1.z, r9, r9
mad r0.y, -c11.x, c11.x, r0
mul r0.y, r1.z, r0
mad r1.w, r1.y, r1.y, -r0.y
dp3 r0.y, r6, c16
rsq r2.z, r1.w
cmp r0.y, -r0, c48.z, c48
cmp r1.w, -r1, c48.y, c48.z
mul_pp r0.y, r0, c14.x
mul_pp r0.y, r0, r1.w
rcp r1.w, r2.z
rcp r2.z, r1.z
add r1.z, -r1.y, -r1.w
mul r1.z, r1, r2
cmp r1.z, -r0.y, c48.x, r1
mad r5.xyz, r7, r1.z, r8
add r1.w, -r1.y, r1
mul r1.w, r2.z, r1
add r5.xyz, r5, -c9
dp3 r1.y, r5, c16
cmp r1.w, -r0.y, c48, r1
cmp r1.y, -r1, c48, c48.z
mul_pp r0.y, r0, r1
cmp r13.xy, -r0.y, r1.zwzw, c48.xwzw
mov r0.y, c44.z
mov r1.y, c44.w
add r0.y, -c45.z, r0
mad r0.y, r6.w, r0, c45.z
add r1.y, -c45.w, r1
mad r1.y, r6.w, r1, c45.w
mul r1.z, r0.y, c33.x
add r0.y, c46.x, -c46
mad r0.y, r6.w, r0, c46
dp3 r2.z, r7, c16
mul r1.w, r2, c33.x
mul r2.w, r2.z, c30.x
mad r2.z, r2, r2, c48
mul r2.w, r2, c47.x
mad r2.w, c30.x, c30.x, r2
mul r13.z, r2, c49.y
mov r2.z, c30.x
add r2.z, c48, r2
add r2.w, r2, c48.z
mov r15.x, r3
pow r3, r2.w, c49.z
mov r2.w, r3.x
max r0.x, r1, r0
cmp_pp r2.y, -r8.w, c48, c48.z
rcp r2.w, r2.w
mul r2.z, r2, r2
mul r1.y, r1, c33.x
mul r0.y, r0, c33.x
mul r13.w, r2.z, r2
mov r9.xyz, c48.z
mov r6.xyz, c47.z
if_gt r2.y, c47.z
frc r2.y, r8.w
add r2.y, r8.w, -r2
abs r2.z, r2.y
frc r2.w, r2.z
add r2.z, r2, -r2.w
cmp r11.w, r2.y, r2.z, -r2.z
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r2.y, r3, r3
rsq r2.y, r2.y
rcp r15.y, r2.y
mov r2.y, c12.x
add r2.y, -c11.x, r2
mov r3.xyz, c16
rcp r2.w, r2.y
dp3 r2.y, c10, r3
add r2.z, r15.y, -c11.x
mul r3.y, r2.z, r2.w
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r2.y, r5.w, c29.x
mad r11.xyz, r5.z, -c27, -r2.y
pow r3, c50.x, r11.y
pow r14, c50.x, r11.x
mov r11.y, r3
pow r3, c50.x, r11.z
add r3.x, r12, r9.w
add r2.w, -r12.x, r13.y
rcp r2.z, r9.w
add r2.y, r3.x, -r13.x
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r3
mul r11.xyz, r11, r2.y
mov r2.y, c47.z
mul r12.xyz, r11, c15
if_gt c34.x, r2.y
add r3.y, r15, -c11.x
add r2.y, r3, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r14.xyz, r10
mov r14.w, c48.z
dp4 r3.w, r14, c5
dp4 r3.z, r14, c4
cmp r12.w, r2.y, c48.z, r12
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.x
mul_sat r2.y, r2, r2.z
mov r11.xy, r3.zwzw
mov r11.z, c47
texldl r14, r11.xyzz, s2
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24
add r2.w, -c25.y, r2.y
add r3.z, r14.x, c47.y
mad r2.y, r2.z, r3.z, c48.z
rcp r2.w, r2.w
add r2.z, r3.y, -c25.y
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
mul r2.w, r2.z, r2
add r3.z, r14.y, c47.y
mad r2.w, r2, r3.z, c48.z
mov r2.z, c24
mul r2.y, r2, r2.w
add r2.z, -c25, r2
rcp r2.w, r2.z
add r2.z, r3.y, -c25
mul_sat r2.z, r2, r2.w
mad r3.z, -r2, c50.y, c50
mul r2.w, r2.z, r2.z
mul r2.w, r2, r3.z
mov r2.z, c24.w
add r3.z, -c25.w, r2
add r3.w, r14.z, c47.y
mad r2.z, r2.w, r3.w, c48
rcp r3.z, r3.z
add r2.w, r3.y, -c25
mul_sat r2.w, r2, r3.z
mad r3.y, -r2.w, c50, c50.z
mul r2.w, r2, r2
add r3.z, r14.w, c47.y
mul r2.w, r2, r3.y
mad r2.w, r2, r3.z, c48.z
mul r2.y, r2, r2.z
mul r12.w, r2.y, r2
endif
mul r12.xyz, r12, r12.w
endif
add r11.xyz, -r10, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
add r11.xyz, -c21, r11
dp3 r3.z, r11, r11
rsq r3.z, r3.z
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.y, r2.z, r2.w
mul r2.w, r3.y, r2
add r10.xyz, -r10, c18
dp3 r3.y, r10, r10
rsq r3.y, r3.y
rcp r3.z, r3.z
mul r2.w, r3.z, r2
rcp r3.z, r2.y
mul r10.xyz, r3.y, r10
dp3 r2.y, r10, r7
mul r3.z, r3, c50.w
mul r3.z, r3, r3
mul r2.y, r2, c30.x
mov r10.xyz, c19
add r2.y, r2, c48.z
rcp r3.w, r3.z
rcp r3.z, r2.y
mul r2.y, r2.w, r3.w
mul r2.z, r2, r3
mul r2.w, r2.z, r3.z
rcp r2.z, r3.y
mul r3.y, r2.z, c50.w
add r10.xyz, -c18, r10
dp3 r2.z, r10, r10
mul r3.y, r3, r3
rsq r2.z, r2.z
rcp r2.z, r2.z
mul r2.z, r2, r2.w
mul r2.y, r2, c50.w
min r2.w, r2.y, c48.z
rcp r3.y, r3.y
mul r2.z, r2, r3.y
mul r2.y, r2.z, c50.w
mul r2.z, r5.y, c28.x
min r2.y, r2, c48.z
mul r10.xyz, r2.w, c23
mad r10.xyz, r2.y, c20, r10
mul r2.y, r5, c29.x
mad r11.xyz, r5.x, c27, r2.y
mul r2.y, r5.x, c26.x
mul r10.xyz, r10, c51.x
mul r10.xyz, r2.z, r10
mul r10.xyz, r10, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r5.xyz, r2.y, c52, r2.z
mad r5.xyz, r12, r5, r10
mul r10.xyz, r9.w, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mov r10.x, r5
pow r14, c50.x, r10.y
pow r5, c50.x, r10.z
mul r11.xyz, r11, r9.w
mad r6.xyz, r11, r9, r6
mov r10.y, r14
mov r10.z, r5
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r2.y, -r2, c48.z
mul r3.x, r2.y, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r2.y, r3.w, c29.x
mad r11.xyz, r3.z, -c27, -r2.y
pow r10, c50.x, r11.y
pow r14, c50.x, r11.x
add r2.y, r8.w, -r11.w
mul r3.z, r2.y, r9.w
mov r11.y, r10
pow r10, c50.x, r11.z
add r2.y, r3.z, r12.x
rcp r2.z, r3.z
add r2.y, r2, -r13.x
add r2.w, -r12.x, r13.y
mov r11.x, r14
mul_sat r2.w, r2.z, r2
mul_sat r2.y, r2, r2.z
mad r2.y, -r2, r2.w, c48.z
mov r11.z, r10
mul r10.xyz, r11, r2.y
mov r2.y, c47.z
mul r10.xyz, r10, c15
if_gt c34.x, r2.y
add r3.w, r5, -c11.x
add r2.y, r3.w, -c25.w
cmp_pp r2.z, r2.y, c48.y, c48
mov r11.xyz, r5
mov r11.w, c48.z
dp4 r12.y, r11, c5
dp4 r12.x, r11, c4
cmp r7.w, r2.y, c48.z, r7
if_gt r2.z, c47.z
mov r2.y, c24.x
add r2.y, -c25.x, r2
rcp r2.z, r2.y
add r2.y, r3.w, -c25.x
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mov r2.y, c24
mul r2.z, r2, r2.w
add r2.y, -c25, r2
rcp r2.w, r2.y
add r2.y, r3.w, -c25
mul_sat r2.y, r2, r2.w
mad r2.w, -r2.y, c50.y, c50.z
mul r2.y, r2, r2
mul r2.w, r2.y, r2
mov r2.y, c24.z
mov r11.xy, r12
mov r11.z, c47
texldl r11, r11.xyzz, s2
add r4.y, r11.x, c47
mad r2.z, r2, r4.y, c48
add r4.y, r11, c47
mad r2.w, r2, r4.y, c48.z
add r4.y, -c25.z, r2
mul r2.y, r2.z, r2.w
rcp r2.w, r4.y
add r2.z, r3.w, -c25
mul_sat r2.z, r2, r2.w
mad r4.y, -r2.z, c50, c50.z
mul r2.w, r2.z, r2.z
mul r2.w, r2, r4.y
mov r2.z, c24.w
add r4.y, -c25.w, r2.z
add r4.z, r11, c47.y
mad r2.z, r2.w, r4, c48
rcp r4.y, r4.y
add r2.w, r3, -c25
mul_sat r2.w, r2, r4.y
mad r3.w, -r2, c50.y, c50.z
mul r2.w, r2, r2
add r4.y, r11.w, c47
mul r2.w, r2, r3
mad r2.w, r2, r4.y, c48.z
mul r2.y, r2, r2.z
mul r7.w, r2.y, r2
endif
mul r10.xyz, r10, r7.w
endif
add r11.xyz, -r5, c21
dp3 r2.y, r11, r11
rsq r2.y, r2.y
mul r11.xyz, r2.y, r11
dp3 r2.z, r7, r11
mul r2.z, r2, c30.x
add r2.w, r2.z, c48.z
mul r2.z, -c30.x, c30.x
mov r11.xyz, c22
rcp r2.w, r2.w
add r2.z, r2, c48
mul r3.w, r2.z, r2
mul r4.y, r3.w, r2.w
add r11.xyz, -c21, r11
add r5.xyz, -r5, c18
dp3 r3.w, r11, r11
dp3 r2.w, r5, r5
rsq r2.w, r2.w
rsq r3.w, r3.w
rcp r3.w, r3.w
mul r3.w, r3, r4.y
rcp r4.y, r2.y
mul r5.xyz, r2.w, r5
dp3 r2.y, r5, r7
mul r4.y, r4, c50.w
mul r2.y, r2, c30.x
mul r4.y, r4, r4
add r2.y, r2, c48.z
rcp r2.y, r2.y
mul r2.z, r2, r2.y
mul r2.z, r2, r2.y
rcp r2.y, r2.w
mul r2.w, r2.y, c50
rcp r4.y, r4.y
mul r3.w, r3, r4.y
mov r5.xyz, c19
add r5.xyz, -c18, r5
dp3 r2.y, r5, r5
mul r2.w, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r2.y, r2, r2.z
mul r3.w, r3, c50
min r2.z, r3.w, c48
mul r5.xyz, r2.z, c23
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r2.y, r2, c50.w
min r2.y, r2, c48.z
mad r5.xyz, r2.y, c20, r5
mul r2.y, r3, c29.x
mad r11.xyz, r3.x, c27, r2.y
mul r2.y, r3.x, c26.x
mul r2.z, r3.y, c28.x
mul r5.xyz, r5, c51.x
mul r5.xyz, r2.z, r5
mul r5.xyz, r5, c51.y
mul r2.z, r13.w, r2
mul r2.y, r2, r13.z
mad r12.xyz, r2.y, c52, r2.z
mad r5.xyz, r10, r12, r5
mul r10.xyz, r3.z, -r11
add r11.xyz, r5, c17
pow r5, c50.x, r10.x
mul r3.xyz, r11, r3.z
mad r6.xyz, r3, r9, r6
mov r10.x, r5
pow r5, c50.x, r10.y
pow r3, c50.x, r10.z
mov r10.y, r5
mov r10.z, r3
mul r9.xyz, r9, r10
endif
add r2.y, r2.x, -r4.x
mul r2.z, r2.y, r0
add r3.x, r2.z, -r1.w
rcp r3.y, r1.w
mov r11.xyz, r6
cmp r2.w, -r2.z, c48.y, c48.z
cmp r3.x, r3, c48.y, c48.z
mul_pp r2.w, r2, r3.x
mul r2.y, r2, r3
cmp r8.w, -r2, r2.z, r1
cmp_pp r1.w, -r8, c48.y, c48.z
cmp r9.w, -r2, r0, r2.y
mov r12.x, r4
mov r6.xyz, c47.z
if_gt r1.w, c47.z
frc r1.w, r8
add r1.w, r8, -r1
abs r2.y, r1.w
frc r2.z, r2.y
add r2.y, r2, -r2.z
cmp r11.w, r1, r2.y, -r2.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r3.xyz, r10, -c9
dp3 r1.w, r3, r3
rsq r1.w, r1.w
rcp r15.y, r1.w
mov r1.w, c12.x
add r1.w, -c11.x, r1
mov r3.xyz, c16
rcp r2.z, r1.w
dp3 r1.w, c10, r3
add r2.y, r15, -c11.x
mul r3.y, r2, r2.z
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r5, r3.xyzz, s1
mul r1.w, r5, c29.x
mad r14.xyz, r5.z, -c27, -r1.w
pow r4, c50.x, r14.x
pow r3, c50.x, r14.y
mov r4.y, r3
pow r3, c50.x, r14.z
add r3.x, r12, r9.w
add r2.z, -r12.x, r13.y
rcp r2.y, r9.w
add r1.w, r3.x, -r13.x
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mov r4.z, r3
mul r4.xyz, r4, r1.w
mov r1.w, c47.z
mul r12.xyz, r4, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r10
mov r4.w, c48.z
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r12.w, r1, c48.z, r12
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mul r2.y, r2, r2.z
mov r1.w, c24.y
add r2.z, -c25.y, r1.w
mov r4.xy, r3.zwzw
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r1.w, r2.y, r2, c48.z
rcp r2.z, r2.z
add r2.y, r3, -c25
mul_sat r2.y, r2, r2.z
mad r2.z, -r2.y, c50.y, c50
mul r2.y, r2, r2
mul r2.z, r2.y, r2
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
mov r2.y, c24.z
mul r1.w, r1, r2.z
add r2.y, -c25.z, r2
rcp r2.z, r2.y
add r2.y, r3, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r3.z, r4, c47.y
mad r2.y, r2.z, r3.z, c48.z
add r2.z, r3.y, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.y, r4.w, c47
mul r2.z, r2, r2.w
mad r2.z, r2, r3.y, c48
mul r1.w, r1, r2.y
mul r12.w, r1, r2.z
endif
mul r12.xyz, r12, r12.w
endif
add r4.xyz, -r10, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.y, r4, r4
rsq r3.y, r3.y
add r10.xyz, -r10, c18
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.z, r2.w, r2
dp3 r2.w, r10, r10
rsq r2.w, r2.w
rcp r3.y, r3.y
mul r2.z, r3.y, r2
rcp r3.y, r1.w
mul r4.xyz, r2.w, r10
dp3 r1.w, r4, r7
mul r3.y, r3, c50.w
mul r3.y, r3, r3
mul r1.w, r1, c30.x
mov r4.xyz, c19
add r1.w, r1, c48.z
rcp r3.z, r3.y
rcp r3.y, r1.w
mul r1.w, r2.z, r3.z
rcp r2.z, r2.w
mul r2.w, r2.z, c50
add r4.xyz, -c18, r4
dp3 r2.z, r4, r4
mul r2.y, r2, r3
mul r2.w, r2, r2
rsq r2.z, r2.z
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r3
mul r2.y, r2.z, r2
min r2.z, r1.w, c48
rcp r2.w, r2.w
mul r2.y, r2, r2.w
mul r1.w, r2.y, c50
mul r2.y, r5, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r1.w, r5.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r10.xyz, r9.w, -r10
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r5.xyz, r1.w, c52, r2.y
mad r4.xyz, r12, r5, r4
add r5.xyz, r4, c17
pow r4, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r4
pow r5, c50.x, r10.y
pow r4, c50.x, r10.z
mov r10.y, r5
mov r10.z, r4
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.w, -r1, c48.z
mul r3.x, r1.w, c49.w
mov r3.z, c47
texldl r3, r3.xyzz, s1
mul r1.w, r3, c29.x
mad r14.xyz, r3.z, -c27, -r1.w
pow r10, c50.x, r14.x
pow r4, c50.x, r14.y
add r1.w, r8, -r11
mul r3.z, r1.w, r9.w
add r1.w, r3.z, r12.x
mov r10.y, r4
pow r4, c50.x, r14.z
mov r10.z, r4
rcp r2.y, r3.z
add r1.w, r1, -r13.x
add r2.z, -r12.x, r13.y
mul_sat r2.z, r2.y, r2
mul_sat r1.w, r1, r2.y
mad r1.w, -r1, r2.z, c48.z
mul r4.xyz, r10, r1.w
mov r1.w, c47.z
mul r10.xyz, r4, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
cmp_pp r2.y, r1.w, c48, c48.z
mov r4.xyz, r5
mov r4.w, c48.z
dp4 r12.y, r4, c5
dp4 r12.x, r4, c4
cmp r7.w, r1, c48.z, r7
if_gt r2.y, c47.z
mov r1.w, c24.x
add r1.w, -c25.x, r1
rcp r2.y, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2.y
mad r2.z, -r1.w, c50.y, c50
mul r2.y, r1.w, r1.w
mov r1.w, c24.y
mul r2.y, r2, r2.z
add r1.w, -c25.y, r1
rcp r2.z, r1.w
add r1.w, r3, -c25.y
mul_sat r1.w, r1, r2.z
mad r2.z, -r1.w, c50.y, c50
mul r1.w, r1, r1
mul r2.z, r1.w, r2
mov r1.w, c24.z
mov r4.xy, r12
mov r4.z, c47
texldl r4, r4.xyzz, s2
add r2.w, r4.x, c47.y
mad r2.y, r2, r2.w, c48.z
add r2.w, r4.y, c47.y
mad r2.z, r2, r2.w, c48
add r2.w, -c25.z, r1
mul r1.w, r2.y, r2.z
rcp r2.z, r2.w
add r2.y, r3.w, -c25.z
mul_sat r2.y, r2, r2.z
mad r2.w, -r2.y, c50.y, c50.z
mul r2.z, r2.y, r2.y
mul r2.z, r2, r2.w
mov r2.y, c24.w
add r2.w, -c25, r2.y
add r4.x, r4.z, c47.y
mad r2.y, r2.z, r4.x, c48.z
add r2.z, r3.w, -c25.w
rcp r2.w, r2.w
mul_sat r2.z, r2, r2.w
mad r2.w, -r2.z, c50.y, c50.z
mul r2.z, r2, r2
add r3.w, r4, c47.y
mul r2.z, r2, r2.w
mad r2.z, r2, r3.w, c48
mul r1.w, r1, r2.y
mul r7.w, r1, r2.z
endif
mul r10.xyz, r10, r7.w
endif
add r4.xyz, -r5, c21
dp3 r1.w, r4, r4
rsq r1.w, r1.w
mul r4.xyz, r1.w, r4
dp3 r2.y, r7, r4
mul r2.y, r2, c30.x
add r2.z, r2.y, c48
mul r2.y, -c30.x, c30.x
mov r4.xyz, c22
add r4.xyz, -c21, r4
dp3 r3.w, r4, r4
rsq r3.w, r3.w
rcp r2.z, r2.z
add r2.y, r2, c48.z
mul r2.w, r2.y, r2.z
mul r2.w, r2, r2.z
add r5.xyz, -r5, c18
dp3 r2.z, r5, r5
rsq r2.z, r2.z
rcp r3.w, r3.w
mul r3.w, r3, r2
rcp r2.w, r1.w
mul r4.xyz, r2.z, r5
dp3 r1.w, r4, r7
mul r2.w, r2, c50
mul r2.w, r2, r2
mul r1.w, r1, c30.x
rcp r4.x, r2.w
add r1.w, r1, c48.z
rcp r2.w, r1.w
mul r1.w, r3, r4.x
mul r2.y, r2, r2.w
mul r2.w, r2.y, r2
rcp r2.y, r2.z
mul r2.z, r2.y, c50.w
mov r4.xyz, c19
add r4.xyz, -c18, r4
dp3 r2.y, r4, r4
mul r2.z, r2, r2
rsq r2.y, r2.y
rcp r2.y, r2.y
mul r1.w, r1, c50
rcp r2.z, r2.z
mul r2.y, r2, r2.w
mul r2.y, r2, r2.z
min r2.z, r1.w, c48
mul r1.w, r2.y, c50
mul r2.y, r3, c28.x
min r1.w, r1, c48.z
mul r4.xyz, r2.z, c23
mad r4.xyz, r1.w, c20, r4
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r4.xyz, r4, c51.x
mul r4.xyz, r2.y, r4
mul r5.xyz, r3.z, -r5
mul r4.xyz, r4, c51.y
mul r2.y, r13.w, r2
mul r1.w, r1, r13.z
mad r12.xyz, r1.w, c52, r2.y
mad r4.xyz, r10, r12, r4
add r10.xyz, r4, c17
pow r4, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r4
pow r4, c50.x, r5.y
pow r3, c50.x, r5.z
mov r5.y, r4
mov r5.z, r3
mul r9.xyz, r9, r5
endif
add r1.w, r1.x, -r2.x
mul r2.y, r1.w, r0.z
add r2.w, r2.y, -r1.z
rcp r3.x, r1.z
mov r4.xyz, r6
cmp r2.z, -r2.y, c48.y, c48
cmp r2.w, r2, c48.y, c48.z
mul_pp r2.z, r2, r2.w
mul r1.w, r1, r3.x
cmp r8.w, -r2.z, r2.y, r1.z
cmp_pp r1.z, -r8.w, c48.y, c48
cmp r9.w, -r2.z, r0, r1
mov r12.x, r2
mov r6.xyz, c47.z
if_gt r1.z, c47.z
frc r1.z, r8.w
add r1.z, r8.w, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r11.w, r1.z, r1, -r1
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r2.xyz, r10, -c9
dp3 r1.z, r2, r2
rsq r1.z, r1.z
rcp r15.y, r1.z
mov r1.z, c12.x
add r1.z, -c11.x, r1
mov r2.xyz, c16
rcp r2.w, r1.z
dp3 r1.z, c10, r2
add r1.w, r15.y, -c11.x
mul r2.y, r1.w, r2.w
add r1.z, -r1, c48
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r5, r2.xyzz, s1
mul r1.z, r5.w, c29.x
mad r14.xyz, r5.z, -c27, -r1.z
pow r2, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r2
pow r2, c50.x, r14.z
add r3.x, r12, r9.w
add r2.x, -r12, r13.y
rcp r1.w, r9.w
add r1.z, r3.x, -r13.x
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mov r14.z, r2
mul r2.xyz, r14, r1.z
mov r1.z, c47
mul r12.xyz, r2, c15
if_gt c34.x, r1.z
add r3.y, r15, -c11.x
add r1.z, r3.y, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r10
mov r2.w, c48.z
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r12.w, r1.z, c48.z, r12
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.y, -c25.x
mul_sat r1.z, r1, r1.w
mov r2.xy, r3.zwzw
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r3.z, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1.z, r1.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r2.x, -c25.y, r1.z
mad r1.z, r1.w, r3, c48
rcp r2.x, r2.x
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2.x
mad r2.x, -r1.w, c50.y, c50.z
mul r1.w, r1, r1
mul r2.x, r1.w, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.w, c24.z
mul r1.z, r1, r2.x
add r1.w, -c25.z, r1
rcp r2.x, r1.w
add r1.w, r3.y, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.y, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r12.w, r1.z, r2.x
endif
mul r12.xyz, r12, r12.w
endif
add r2.xyz, -r10, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.y, r1.w, r2.w
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r10.xyz, -r10, c18
dp3 r2.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r2.w, r2.x, r2
mul r2.xyz, r3.y, r10
rcp r3.z, r1.z
dp3 r1.z, r2, r7
mul r2.x, r3.z, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r2.w, r2.y
mul r1.w, r1, r2.x
mul r1.w, r1, r2.x
mov r2.xyz, c19
add r2.xyz, -c18, r2
dp3 r2.x, r2, r2
rcp r2.w, r3.y
mul r2.w, r2, c50
mul r2.y, r2.w, r2.w
rsq r2.x, r2.x
rcp r2.x, r2.x
mul r1.z, r1, c50.w
mul r1.w, r2.x, r1
rcp r2.y, r2.y
mul r1.w, r1, r2.y
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r1.w
mul r10.xyz, r9.w, -r10
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r5.y, c28.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.z, r2
mul r2.w, r13, r1.z
mul r1.w, r5.x, c26.x
mul r1.z, r1.w, r13
mad r5.xyz, r1.z, c52, r2.w
mul r2.xyz, r2, c51.y
mad r2.xyz, r12, r5, r2
add r5.xyz, r2, c17
pow r2, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r2
pow r5, c50.x, r10.y
pow r2, c50.x, r10.z
mov r10.y, r5
mov r10.z, r2
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
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
add r1.z, -r1, c48
mul r2.y, r1.w, r2.w
mul r2.x, r1.z, c49.w
mov r2.z, c47
texldl r3, r2.xyzz, s1
mul r1.z, r3.w, c29.x
mad r14.xyz, r3.z, -c27, -r1.z
pow r10, c50.x, r14.x
pow r2, c50.x, r14.y
add r1.z, r8.w, -r11.w
mul r3.z, r1, r9.w
add r1.z, r3, r12.x
mov r10.y, r2
pow r2, c50.x, r14.z
mov r10.z, r2
rcp r1.w, r3.z
add r1.z, r1, -r13.x
add r2.x, -r12, r13.y
mul_sat r2.x, r1.w, r2
mul_sat r1.z, r1, r1.w
mad r1.z, -r1, r2.x, c48
mul r2.xyz, r10, r1.z
mov r1.z, c47
mul r10.xyz, r2, c15
if_gt c34.x, r1.z
add r3.w, r5, -c11.x
add r1.z, r3.w, -c25.w
cmp_pp r1.w, r1.z, c48.y, c48.z
mov r2.xyz, r5
mov r2.w, c48.z
dp4 r12.y, r2, c5
dp4 r12.x, r2, c4
cmp r7.w, r1.z, c48.z, r7
if_gt r1.w, c47.z
mov r1.z, c24.x
add r1.z, -c25.x, r1
rcp r1.w, r1.z
add r1.z, r3.w, -c25.x
mul_sat r1.z, r1, r1.w
mul r1.w, r1.z, r1.z
mov r2.xy, r12
mov r2.z, c47
texldl r2, r2.xyzz, s2
add r4.w, r2.x, c47.y
mad r2.x, -r1.z, c50.y, c50.z
mul r1.w, r1, r2.x
mov r1.z, c24.y
add r1.z, -c25.y, r1
rcp r2.x, r1.z
add r1.z, r3.w, -c25.y
mul_sat r1.z, r1, r2.x
mad r2.x, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r2.x, r1.z, r2
add r2.y, r2, c47
mad r2.x, r2, r2.y, c48.z
mov r1.z, c24
add r2.y, -c25.z, r1.z
mad r1.w, r1, r4, c48.z
mul r1.z, r1.w, r2.x
rcp r2.x, r2.y
add r1.w, r3, -c25.z
mul_sat r1.w, r1, r2.x
mad r2.y, -r1.w, c50, c50.z
mul r2.x, r1.w, r1.w
mul r2.x, r2, r2.y
mov r1.w, c24
add r2.y, -c25.w, r1.w
add r2.z, r2, c47.y
mad r1.w, r2.x, r2.z, c48.z
rcp r2.y, r2.y
add r2.x, r3.w, -c25.w
mul_sat r2.x, r2, r2.y
mad r2.y, -r2.x, c50, c50.z
mul r2.x, r2, r2
add r2.z, r2.w, c47.y
mul r2.x, r2, r2.y
mad r2.x, r2, r2.z, c48.z
mul r1.z, r1, r1.w
mul r7.w, r1.z, r2.x
endif
mul r10.xyz, r10, r7.w
endif
add r2.xyz, -r5, c21
dp3 r1.z, r2, r2
rsq r1.z, r1.z
mul r2.xyz, r1.z, r2
dp3 r1.w, r7, r2
mul r1.w, r1, c30.x
add r2.x, r1.w, c48.z
rcp r2.w, r2.x
mul r1.w, -c30.x, c30.x
add r1.w, r1, c48.z
mul r3.w, r1, r2
mov r2.xyz, c22
add r2.xyz, -c21, r2
dp3 r2.y, r2, r2
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r2.x, r5, r5
rsq r2.w, r2.x
rsq r2.y, r2.y
rcp r2.x, r2.y
mul r3.w, r2.x, r3
mul r2.xyz, r2.w, r5
rcp r4.w, r1.z
dp3 r1.z, r2, r7
mul r2.x, r4.w, c50.w
mul r2.x, r2, r2
mul r1.z, r1, c30.x
rcp r2.y, r2.x
add r1.z, r1, c48
rcp r2.x, r1.z
mul r1.z, r3.w, r2.y
mul r1.w, r1, r2.x
mul r3.w, r1, r2.x
rcp r1.w, r2.w
mov r2.xyz, c19
add r2.xyz, -c18, r2
mul r2.w, r1, c50
dp3 r1.w, r2, r2
mul r2.x, r2.w, r2.w
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r3
rcp r2.x, r2.x
mul r1.w, r1, r2.x
mul r1.z, r1, c50.w
min r2.x, r1.z, c48.z
mul r1.z, r1.w, c50.w
mul r1.w, r3.y, c28.x
min r1.z, r1, c48
mul r2.xyz, r2.x, c23
mad r2.xyz, r1.z, c20, r2
mul r1.z, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.z
mul r1.z, r3.x, c26.x
mul r2.xyz, r2, c51.x
mul r2.xyz, r1.w, r2
mul r5.xyz, r3.z, -r5
mul r2.xyz, r2, c51.y
mul r1.w, r13, r1
mul r1.z, r1, r13
mad r12.xyz, r1.z, c52, r1.w
mad r2.xyz, r10, r12, r2
add r10.xyz, r2, c17
pow r2, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r2
pow r3, c50.x, r5.y
pow r2, c50.x, r5.z
mov r5.y, r3
mov r5.z, r2
mul r9.xyz, r9, r5
endif
add r1.z, r0.x, -r1.x
mul r1.w, r1.z, r0.z
rcp r2.z, r1.y
add r2.y, r1.w, -r1
cmp r2.y, r2, c48, c48.z
cmp r2.x, -r1.w, c48.y, c48.z
mul_pp r2.x, r2, r2.y
mul r1.z, r1, r2
cmp r8.w, -r2.x, r1, r1.y
cmp r9.w, -r2.x, r0, r1.z
cmp_pp r1.y, -r8.w, c48, c48.z
mov r2.xyz, r6
mov r12.x, r1
mov r6.xyz, c47.z
if_gt r1.y, c47.z
frc r1.x, r8.w
add r1.x, r8.w, -r1
abs r1.y, r1.x
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r1.x, r1.y, -r1.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r1.xyz, r10, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r15.y, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r15.y, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r5, r1.xyzz, s1
mul r1.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r1.x
pow r1, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r1
pow r1, c50.x, r14.z
add r3.x, r12, r9.w
rcp r1.y, r9.w
add r1.w, -r12.x, r13.y
add r1.x, r3, -r13
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r14.z, r1
mul r1.xyz, r14, r1.x
mov r1.w, c47.z
mul r12.xyz, r1, c15
if_gt c34.x, r1.w
add r3.y, r15, -c11.x
add r2.w, r3.y, -c25
mov r1.xyz, r10
mov r1.w, c48.z
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r12.w, r2, c48.z, r12
if_gt r1.x, c47.z
mov r1.w, c24.x
mov r1.xy, r3.zwzw
add r2.w, -c25.x, r1
rcp r3.z, r2.w
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r3.w, r1.x, c47.y
add r2.w, r3.y, -c25.x
mul_sat r2.w, r2, r3.z
mul r3.z, r2.w, r2.w
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r3.z, r2
mov r1.x, c24.y
add r3.z, -c25.y, r1.x
mad r1.x, r2.w, r3.w, c48.z
rcp r3.z, r3.z
add r2.w, r3.y, -c25.y
mul_sat r2.w, r2, r3.z
add r3.w, r1.y, c47.y
mad r3.z, -r2.w, c50.y, c50
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r3.z
mad r2.w, r2, r3, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3, -c25.z
mul_sat r1.y, r1, r2.w
add r3.z, r1, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r3.z, c48.z
rcp r2.w, r2.w
add r1.z, r3.y, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r12.w, r1.x, r1.z
endif
mul r12.xyz, r12, r12.w
endif
add r1.xyz, -r10, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
add r2.w, r1.x, c48.z
rcp r3.y, r1.y
mul r3.z, r2.w, r3.y
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r10.xyz, -r10, c18
dp3 r1.x, r10, r10
mul r3.y, r3.z, r3
rsq r3.z, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r3.y, r1.x, r3
mul r1.xyz, r3.z, r10
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r3.y, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.y, r3.z
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.y, r3, c50.w
mul r1.y, r3, r3
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
mul r2.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r10.xyz, r9.w, -r10
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r5.y, c28.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r1.w, r1
mul r2.w, r5.x, c26.x
mul r3.y, r13.w, r1.w
mul r1.w, r2, r13.z
mad r5.xyz, r1.w, c52, r3.y
mul r1.xyz, r1, c51.y
mad r1.xyz, r12, r5, r1
add r5.xyz, r1, c17
pow r1, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r1
pow r5, c50.x, r10.y
pow r1, c50.x, r10.z
mov r10.y, r5
mov r10.z, r1
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r1.xyz, r5, -c9
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r5.w, r1.x
mov r1.x, c12
add r2.w, -c11.x, r1.x
mov r1.xyz, c16
dp3 r1.x, c10, r1
add r1.x, -r1, c48.z
add r1.w, r5, -c11.x
rcp r2.w, r2.w
mul r1.y, r1.w, r2.w
mov r1.z, c47
mul r1.x, r1, c49.w
texldl r3, r1.xyzz, s1
mul r1.x, r3.w, c29
mad r14.xyz, r3.z, -c27, -r1.x
pow r10, c50.x, r14.x
pow r1, c50.x, r14.y
add r1.x, r8.w, -r11.w
mov r10.y, r1
mul r3.z, r1.x, r9.w
pow r1, c50.x, r14.z
add r1.x, r3.z, r12
rcp r1.y, r3.z
add r1.x, r1, -r13
add r1.w, -r12.x, r13.y
mul_sat r1.w, r1.y, r1
mul_sat r1.x, r1, r1.y
mad r1.x, -r1, r1.w, c48.z
mov r10.z, r1
mul r1.xyz, r10, r1.x
mov r1.w, c47.z
mul r10.xyz, r1, c15
if_gt c34.x, r1.w
add r3.w, r5, -c11.x
add r2.w, r3, -c25
mov r1.xyz, r5
mov r1.w, c48.z
dp4 r12.y, r1, c5
dp4 r12.x, r1, c4
cmp_pp r1.x, r2.w, c48.y, c48.z
cmp r7.w, r2, c48.z, r7
if_gt r1.x, c47.z
mov r1.w, c24.x
add r2.w, -c25.x, r1
rcp r4.w, r2.w
add r2.w, r3, -c25.x
mul_sat r2.w, r2, r4
mul r4.w, r2, r2
mad r2.w, -r2, c50.y, c50.z
mul r2.w, r4, r2
mov r1.xy, r12
mov r1.z, c47
texldl r1, r1.xyzz, s2
add r5.w, r1.x, c47.y
mov r1.x, c24.y
add r4.w, -c25.y, r1.x
mad r1.x, r2.w, r5.w, c48.z
rcp r4.w, r4.w
add r2.w, r3, -c25.y
mul_sat r2.w, r2, r4
add r5.w, r1.y, c47.y
mad r4.w, -r2, c50.y, c50.z
mul r1.y, r2.w, r2.w
mul r2.w, r1.y, r4
mad r2.w, r2, r5, c48.z
mov r1.y, c24.z
mul r1.x, r1, r2.w
add r1.y, -c25.z, r1
rcp r2.w, r1.y
add r1.y, r3.w, -c25.z
mul_sat r1.y, r1, r2.w
add r4.w, r1.z, c47.y
mad r2.w, -r1.y, c50.y, c50.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r2.w
mov r1.y, c24.w
add r2.w, -c25, r1.y
mad r1.y, r1.z, r4.w, c48.z
rcp r2.w, r2.w
add r1.z, r3.w, -c25.w
mul_sat r1.z, r1, r2.w
add r2.w, r1, c47.y
mad r1.w, -r1.z, c50.y, c50.z
mul r1.z, r1, r1
mul r1.z, r1, r1.w
mad r1.z, r1, r2.w, c48
mul r1.x, r1, r1.y
mul r7.w, r1.x, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r1.xyz, -r5, c21
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r1.xyz, r1.w, r1
dp3 r1.x, r7, r1
mul r1.x, r1, c30
add r1.y, r1.x, c48.z
mul r1.x, -c30, c30
rcp r3.w, r1.y
add r2.w, r1.x, c48.z
mul r4.w, r2, r3
mov r1.xyz, c22
add r1.xyz, -c21, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c18
mul r4.w, r4, r3
dp3 r1.x, r5, r5
rsq r3.w, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r4.w, r1.x, r4
mul r1.xyz, r3.w, r5
dp3 r1.x, r1, r7
rcp r1.w, r1.w
mul r1.y, r1.w, c50.w
mul r1.x, r1, c30
mul r1.y, r1, r1
rcp r1.y, r1.y
mul r1.z, r4.w, r1.y
add r1.x, r1, c48.z
rcp r1.x, r1.x
mul r1.y, r2.w, r1.x
rcp r3.w, r3.w
mul r1.w, r1.z, c50
mul r2.w, r1.y, r1.x
mov r1.xyz, c19
add r1.xyz, -c18, r1
dp3 r1.x, r1, r1
mul r3.w, r3, c50
mul r1.y, r3.w, r3.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r2.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
min r1.y, r1.w, c48.z
mul r1.w, r1.x, c50
mul r2.w, r3.y, c28.x
min r1.w, r1, c48.z
mul r1.xyz, r1.y, c23
mad r1.xyz, r1.w, c20, r1
mul r1.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r1.w
mul r1.w, r3.x, c26.x
mul r1.xyz, r1, c51.x
mul r1.xyz, r2.w, r1
mul r5.xyz, r3.z, -r5
mul r1.w, r1, r13.z
mul r2.w, r13, r2
mad r12.xyz, r1.w, c52, r2.w
mul r1.xyz, r1, c51.y
mad r1.xyz, r10, r12, r1
add r10.xyz, r1, c17
pow r1, c50.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r1
pow r3, c50.x, r5.y
pow r1, c50.x, r5.z
mov r5.y, r3
mov r5.z, r1
mul r9.xyz, r9, r5
endif
add r1.x, r15, -r0
mul r0.z, r1.x, r0
add r1.z, r0, -r0.y
rcp r1.w, r0.y
cmp r1.z, r1, c48.y, c48
cmp r1.y, -r0.z, c48, c48.z
mul_pp r1.y, r1, r1.z
mul r1.x, r1, r1.w
cmp r8.w, -r1.y, r0.z, r0.y
cmp r9.w, -r1.y, r0, r1.x
mov r1.xyz, r6
cmp_pp r0.y, -r8.w, c48, c48.z
mov r12.x, r0
mov r6.xyz, c47.z
if_gt r0.y, c47.z
frc r0.x, r8.w
add r0.x, r8.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r11.w, r0.x, r0.y, -r0.y
mov r10.w, c47.z
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r7, r8
add r0.xyz, r10, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r15.y, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r15.y, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r5, r0.xyzz, s1
mul r0.x, r5.w, c29
mad r14.xyz, r5.z, -c27, -r0.x
pow r0, c50.x, r14.y
pow r3, c50.x, r14.x
mov r14.x, r3
mov r14.y, r0
pow r0, c50.x, r14.z
add r3.x, r12, r9.w
rcp r0.y, r9.w
add r0.w, -r12.x, r13.y
add r0.x, r3, -r13
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r14.z, r0
mul r0.xyz, r14, r0.x
mov r0.w, c47.z
mul r12.xyz, r0, c15
if_gt c34.x, r0.w
add r3.y, r15, -c11.x
add r1.w, r3.y, -c25
mov r0.xyz, r10
mov r0.w, c48.z
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r12.w, r1, c48.z, r12
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r3.zwzw
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r3.z, r0.x, c47.y
mov r0.x, c24.y
add r2.w, -c25.y, r0.x
mad r0.x, r1.w, r3.z, c48.z
rcp r2.w, r2.w
add r1.w, r3.y, -c25.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c47.y
mad r2.w, -r1, c50.y, c50.z
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c48.z
mov r0.y, c24.z
mul r0.x, r0, r1.w
add r0.y, -c25.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c25.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.y, c50.y, c50.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c24.w
add r1.w, -c25, r0.y
mad r0.y, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.y, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0, r0.y
mul r12.w, r0.x, r0.z
endif
mul r12.xyz, r12, r12.w
endif
add r0.xyz, -r10, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
add r1.w, r0.x, c48.z
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r10.xyz, -r10, c18
dp3 r0.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r10
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c50
mul r1.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c50
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c48.z
mul r0.w, r0.x, c50
mul r1.w, r5.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r5.y, c29.x
mad r10.xyz, r5.x, c27, r0.w
mul r0.w, r5.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r10.xyz, r9.w, -r10
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r5.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r12, r5, r0
add r5.xyz, r0, c17
pow r0, c50.x, r10.x
mul r5.xyz, r5, r9.w
mad r6.xyz, r5, r9, r6
mov r10.x, r0
pow r5, c50.x, r10.y
pow r0, c50.x, r10.z
mov r10.y, r5
mov r10.z, r0
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c48.z
endloop
mad r5.xyz, r12.x, r7, r8
add r0.xyz, r5, -c9
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c12
add r1.w, -c11.x, r0.x
mov r0.xyz, c16
dp3 r0.x, c10, r0
add r0.x, -r0, c48.z
add r0.w, r5, -c11.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c47
mul r0.x, r0, c49.w
texldl r3, r0.xyzz, s1
mul r0.x, r3.w, c29
mad r8.xyz, r3.z, -c27, -r0.x
pow r0, c50.x, r8.y
pow r10, c50.x, r8.x
add r0.x, r8.w, -r11.w
mul r3.z, r0.x, r9.w
mov r8.y, r0
pow r0, c50.x, r8.z
add r0.x, r3.z, r12
rcp r0.y, r3.z
add r0.x, r0, -r13
add r0.w, -r12.x, r13.y
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c48.z
mov r8.x, r10
mov r8.z, r0
mul r0.xyz, r8, r0.x
mov r0.w, c47.z
mul r10.xyz, r0, c15
if_gt c34.x, r0.w
add r3.w, r5, -c11.x
add r1.w, r3, -c25
mov r0.xyz, r5
mov r0.w, c48.z
dp4 r12.y, r0, c5
dp4 r12.x, r0, c4
cmp_pp r0.x, r1.w, c48.y, c48.z
cmp r7.w, r1, c48.z, r7
if_gt r0.x, c47.z
mov r0.w, c24.x
add r1.w, -c25.x, r0
rcp r2.w, r1.w
add r1.w, r3, -c25.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c50.y, c50.z
mul r1.w, r2, r1
mov r0.xy, r12
mov r0.z, c47
texldl r0, r0.xyzz, s2
add r4.w, r0.x, c47.y
mov r0.x, c24.y
add r0.x, -c25.y, r0
rcp r2.w, r0.x
add r0.x, r3.w, -c25.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c47.y
mad r0.y, -r0.x, c50, c50.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c48.z
mad r1.w, r1, r4, c48.z
mov r0.x, c24.z
add r0.x, -c25.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r3.w, -c25.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c47.y
mad r1.w, -r0.x, c50.y, c50.z
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c24.w
add r1.w, -c25, r0.x
mad r0.x, r0.z, r2.w, c48.z
rcp r1.w, r1.w
add r0.z, r3.w, -c25.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c47.y
mad r0.w, -r0.z, c50.y, c50.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c48
mul r0.x, r0.y, r0
mul r7.w, r0.x, r0.z
endif
mul r10.xyz, r10, r7.w
endif
add r0.xyz, -r5, c21
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r7, r0
mul r0.x, r0, c30
add r0.y, r0.x, c48.z
mul r0.x, -c30, c30
rcp r2.w, r0.y
add r1.w, r0.x, c48.z
mul r3.w, r1, r2
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c18
mul r3.w, r3, r2
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.w, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r7
rcp r0.w, r0.w
mul r0.y, r0.w, c50.w
mul r0.x, r0, c30
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3.w, r0.y
add r0.x, r0, c48.z
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.w, r0.z, c50
mul r0.w, r0.y, r0.x
mov r0.xyz, c19
add r0.xyz, -c18, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c50
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c50
min r0.y, r3.w, c48.z
mul r1.w, r3.y, c28.x
min r0.w, r0, c48.z
mul r0.xyz, r0.y, c23
mad r0.xyz, r0.w, c20, r0
mul r0.w, r3.y, c29.x
mad r5.xyz, r3.x, c27, r0.w
mul r0.w, r3.x, c26.x
mul r0.xyz, r0, c51.x
mul r0.xyz, r1.w, r0
mul r5.xyz, r3.z, -r5
mul r0.w, r0, r13.z
mul r1.w, r13, r1
mad r7.xyz, r0.w, c52, r1.w
mul r0.xyz, r0, c51.y
mad r0.xyz, r10, r7, r0
add r7.xyz, r0, c17
pow r0, c50.x, r5.x
mul r3.xyz, r7, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r0
pow r3, c50.x, r5.y
pow r0, c50.x, r5.z
mov r5.y, r3
mov r5.z, r0
mul r9.xyz, r9, r5
endif
mov r3, c37
add r3, -c41, r3
mov r0, c36
mov r7, c39
mov r8, c38
add r7, -c43, r7
add r8, -c42, r8
add r0, -c40, r0
mad r5, r6.w, r3, c41
mad r3, r6.w, r0, c40
texldl r1.w, v0, s5
mov r0.z, r1.w
texldl r1.w, v0, s4
texldl r2.w, v0, s3
mov r0.y, r1.w
texldl r0.w, v0, s6
mov r0.x, r2.w
dp4 r10.x, r3, r0
dp4 r3.x, r3, r3
mad r7, r6.w, r7, c43
mad r8, r6.w, r8, c42
dp4 r3.y, r5, r5
dp4 r3.z, r8, r8
dp4 r10.y, r5, r0
dp4 r10.w, r7, r0
dp4 r10.z, r8, r0
add r0, r10, c47.y
dp4 r3.w, r7, r7
mad r0, r3, r0, c48.z
mad r1.xyz, r6, r0.w, r1
mad r1.xyz, r1, r0.z, r2
mad r1.xyz, r1, r0.y, r4
mad r0.xyz, r1, r0.x, r11
mul r1.xyz, r0.y, c53
mad r1.xyz, r0.x, c54, r1
mad r0.xyz, r0.z, c55, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c51.z
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c51.z
add r0.z, r0.x, c51.w
cmp r0.z, r0, c48, c48.y
mul_pp r1.x, r0.z, c52.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c53.w
frc r1.x, r0
add r2.x, r0, -r1
add_pp r0.x, r2, c54.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c56, c56.y
mul r3.xyz, r9.y, c53
mad r1.xyz, r9.x, c54, r3
mad r1.xyz, r9.z, c55, r1
add r2.z, r1.x, r1.y
add r0.z, r1, r2
rcp r1.z, r0.z
mul_pp r0.z, r2.x, c55.w
mul_pp r0.x, r0, r2.y
mul r2.xy, r1, r1.z
mul r0.w, r0, c51.y
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r0.z, r1.w, -r0
mul r1.z, r2.x, c51
min r0.w, r0, c56.z
mad r0.z, r0, c56.w, r0.w
mad r0.z, r0, c57.x, c57.y
frc r1.w, r1.z
add r1.z, r1, -r1.w
min r1.x, r1.z, c51.z
add r1.z, r1.x, c51.w
cmp r0.w, r1.z, c48.z, c48.y
mul_pp r1.z, r0.w, c52.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.z
mul r1.x, r2.y, c51.y
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c53.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c55.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
add r0.x, r0, -r0.z
min r1.x, r1, c56.z
mad r0.z, r0.x, c56.w, r1.x
add_pp r0.x, r0.y, c54.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c56, c56.y
mad r0.z, r0, c57.x, c57.y
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
