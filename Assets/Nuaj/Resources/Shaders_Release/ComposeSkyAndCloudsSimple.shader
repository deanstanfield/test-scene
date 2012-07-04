// This composes the previously computed downscaled sky buffer with cloud buffers
// It also computes more accurately the pixels that have too much discrepancy between the fullscale and downscaled versions
//
Shader "Hidden/Nuaj/ComposeSkyAndCloudsSimple"
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 3 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 2 [_TexDensity] 2D
SetTexture 5 [_TexBackground] 2D
SetTexture 1 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 4 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[45] = { program.local[0..31],
		{ 0, 2, -1, -1000000 },
		{ 1, 0.995, 1000000, -1000000 },
		{ 0.1, 0.75, 1.5, 0.079577468 },
		{ 0.25, 2.718282, 0.5, 210 },
		{ 0.0241188, 0.1228178, 0.84442663, 128 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 400, 255, 0.0009765625 },
		{ 1024, 0.00390625, 0.0047619049 },
		{ 0.63999999, 0, 1 },
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
TEMP R17;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R2.xyz, c[5];
MOVR  R4.x, c[32].w;
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].y, -R0;
MOVR  R0.z, c[32];
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[9].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[32].x;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R4.y, R2, R1;
MOVR  R0, c[13];
MULR  R4.z, R4.y, R4.y;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R4.z, R0;
MOVXC RC.x, R2;
MOVR  R4.x(EQ), R1.w;
ADDR  R1, R4.z, -R0;
SGERC HC, R4.z, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R4.x(NE.z), -R4.y, R1;
MOVR  R0.x, c[32].w;
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R4.y, R0.y;
MOVR  R0.y, c[32].w;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3.x;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R4, R0.z;
MOVR  R0.z, c[32].w;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.x;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R4.y, R0.w;
MOVR  R4.y, R0;
MOVR  R4.w, R0.z;
MOVR  R4.z, R0.x;
DP4R  R0.x, R4, c[19];
SGER  H0.x, c[32], R0;
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R1, H0.x, R0, c[24];
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R2, H0.x, R0, c[25];
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R4, H0.x, R0, c[26];
MOVR  R0, c[27];
ADDR  R0, -R0, c[23];
MADR  R5, H0.x, R0, c[27];
DP4R  R0.y, R2, R2;
DP4R  R6.y, R2, c[33].x;
DP4R  R0.x, R1, R1;
DP4R  R6.x, R1, c[33].x;
DP4R  R2.x, R2, c[32].x;
DP4R  R6.z, R4, c[33].x;
DP4R  R0.z, R4, R4;
DP4R  R6.w, R5, c[33].x;
DP4R  R0.w, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[33].x;
MULR  R3.x, R0, R0.y;
MULR  R3.x, R3, R0.z;
MULR  R0.w, R3.x, R0;
DP4R  R3.x, R4, c[32].x;
DP4R  R4.x, R5, c[32].x;
MADR  R0.z, R0, R4.x, R3.x;
MADR  R0.y, R0, R0.z, R2.x;
DP4R  R0.z, R1, c[32].x;
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[30].xyxz;
ADDR  R1.xy, R1.zwzw, c[30].zyzw;
ADDR  R2.xy, R1, -c[30].xzzw;
ADDR  R17.xy, R2, -c[30].zyzw;
TEX   R1.x, R1, texture[1], 2D;
TEX   R2.x, R2, texture[1], 2D;
ADDR  R1.y, R2.x, -R1.x;
TEX   R2.x, fragment.texcoord[0], texture[1], 2D;
TEX   R3.x, R1.zwzw, texture[1], 2D;
MULR  R2.zw, R17.xyxy, c[31].xyxy;
FRCR  R1.zw, R2;
MADR  R1.x, R1.z, R1.y, R1;
ADDR  R2.y, R3.x, -R2.x;
MADR  R1.y, R1.z, R2, R2.x;
ADDR  R2.x, R1, -R1.y;
ADDR  R1.z, c[4].w, -c[4];
RCPR  R1.z, R1.z;
MULR  R1.z, R1, c[4].w;
TEX   R1.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R1.x, R1.z, -R1;
RCPR  R1.x, R1.x;
MULR  R1.z, R1, c[4];
MADR  R1.y, R1.w, R2.x, R1;
MULR  R8.w, R1.z, R1.x;
ADDR  R1.x, R8.w, -R1.y;
SGTRC HC.x, |R1|, c[28];
MADR  R0.xyz, R0.x, R0.y, R0.z;
IF    NE.x;
MOVR  R3.x, c[32].w;
MOVR  R5.w, c[32];
MOVR  R9.w, c[32];
MOVR  R10.x, c[32].w;
MOVR  R9.x, c[0].w;
MOVR  R9.z, c[2].w;
MOVR  R9.y, c[1].w;
MULR  R8.xyz, R9, c[9].x;
ADDR  R5.xyz, R8, -c[5];
DP3R  R7.x, R5, R5;
MULR  R2.xy, R17, c[4];
MOVR  R1.xy, c[4];
MADR  R1.xy, R2, c[32].y, -R1;
MOVR  R1.z, c[32];
DP3R  R1.w, R1, R1;
RSQR  R4.w, R1.w;
MULR  R1.xyz, R4.w, R1;
MOVR  R1.w, c[32].x;
RCPR  R4.w, R4.w;
DP4R  R4.z, R1, c[2];
DP4R  R4.y, R1, c[1];
DP4R  R4.x, R1, c[0];
DP3R  R10.y, R4, R5;
MOVR  R1, c[13];
ADDR  R1, R1, c[7].x;
MADR  R1, -R1, R1, R7.x;
MULR  R10.z, R10.y, R10.y;
ADDR  R2, R10.z, -R1;
SLTR  R6, R10.z, R1;
MOVXC RC.x, R6;
MOVR  R3.x(EQ), R3.y;
SGERC HC, R10.z, R1.yzxw;
RSQR  R1.x, R2.z;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
ADDR  R3.x(NE.z), -R10.y, R2;
MOVXC RC.z, R6;
MOVR  R5.w(EQ.z), R3.y;
MOVXC RC.z, R6.w;
RCPR  R1.x, R1.x;
ADDR  R5.w(NE.y), -R10.y, R1.x;
MOVXC RC.y, R6;
RSQR  R1.x, R2.w;
MOVR  R2.x, c[33].z;
MOVR  R9.w(EQ.z), R3.y;
RCPR  R1.x, R1.x;
ADDR  R9.w(NE), -R10.y, R1.x;
RSQR  R1.x, R2.y;
MOVR  R10.x(EQ.y), R3.y;
RCPR  R1.x, R1.x;
ADDR  R10.x(NE), -R10.y, R1;
MOVR  R1, c[14];
ADDR  R1, R1, c[7].x;
MADR  R1, -R1, R1, R7.x;
ADDR  R6, R10.z, -R1;
RSQR  R2.y, R6.x;
SLTR  R7, R10.z, R1;
MOVXC RC.x, R7;
MOVR  R2.x(EQ), R3.y;
SGERC HC, R10.z, R1.yzxw;
RCPR  R2.y, R2.y;
ADDR  R2.x(NE.z), -R10.y, -R2.y;
RSQR  R1.x, R6.z;
MOVR  R6.x, c[18];
MOVR  R2.y, c[33].z;
MOVR  R1.w, c[33].z;
MOVXC RC.z, R7;
MOVR  R1.w(EQ.z), R3.y;
RCPR  R1.x, R1.x;
ADDR  R1.w(NE.y), -R10.y, -R1.x;
RSQR  R1.x, R6.w;
MOVXC RC.y, R7;
MULR  R7.xyz, R4.zxyw, c[12].yzxw;
MADR  R7.xyz, R4.yzxw, c[12].zxyw, -R7;
MOVR  R2.y(EQ), R3;
MOVR  R6.w, c[33].z;
MOVR  R2.z, c[33];
MOVXC RC.z, R7.w;
MOVR  R2.z(EQ), R3.y;
RCPR  R1.x, R1.x;
ADDR  R2.z(NE.w), -R10.y, -R1.x;
RSQR  R1.x, R6.y;
RCPR  R1.x, R1.x;
ADDR  R2.y(NE.x), -R10, -R1.x;
MOVR  R1.xyz, c[5];
MADR  R1.xyz, R9, c[9].x, -R1;
DP3R  R2.w, R1, R4;
DP3R  R9.x, R1, R1;
ADDR  R6.x, R6, c[7];
MULR  R7.w, R2, R2;
MADR  R6.x, -R6, R6, R9;
SLTRC HC.x, R7.w, R6;
MOVR  R6.w(EQ.x), R3.y;
ADDR  R3.y, R7.w, -R6.x;
SGERC HC.x, R7.w, R6;
MULR  R6.xyz, R1.zxyw, c[12].yzxw;
MADR  R6.xyz, R1.yzxw, c[12].zxyw, -R6;
DP3R  R1.x, R1, c[12];
SLER  H0.x, R1, c[32];
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
ADDR  R6.w(NE.x), -R2, -R3.y;
DP3R  R3.y, R6, R6;
DP3R  R6.x, R6, R7;
MOVXC RC.x, R6.w;
DP3R  R6.y, R7, R7;
MADR  R3.y, -c[7].x, c[7].x, R3;
MULR  R7.x, R6.y, R3.y;
MULR  R6.z, R6.x, R6.x;
ADDR  R3.y, R6.z, -R7.x;
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
ADDR  R1.y, -R6.x, R3;
SGTR  H0.y, R6.z, R7.x;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVR  R6.w(LT.x), c[33].z;
MOVXC RC.x, H0;
RCPR  R6.y, R6.y;
MOVR  R1.z, c[33].w;
MULR  R1.z(NE.x), R6.y, R1.y;
ADDR  R1.y, -R6.x, -R3;
MOVR  R1.x, c[33].z;
MULR  R1.x(NE), R1.y, R6.y;
MOVR  R1.y, R1.z;
MOVR  R17.zw, R1.xyxy;
MADR  R1.xyz, R4, R1.x, R8;
ADDR  R1.xyz, R1, -c[5];
DP3R  R1.x, R1, c[12];
SGTR  H0.y, R1.x, c[32].x;
MADR  R1.z, -c[8].x, c[8].x, R9.x;
MULXC HC.x, H0, H0.y;
MOVR  R17.zw(NE.x), c[33];
ADDR  R3.y, R7.w, -R1.z;
RSQR  R3.y, R3.y;
MOVR  R1.xy, c[32].x;
SLTRC HC.x, R7.w, R1.z;
MOVR  R1.xy(EQ.x), R3.zwzw;
RCPR  R3.y, R3.y;
ADDR  R3.z, -R2.w, -R3.y;
ADDR  R2.w, -R2, R3.y;
MAXR  R3.w, R2, c[32].x;
MOVR  R2.w, R2.z;
MOVR  R3.y, R10.x;
MOVR  R2.z, R1.w;
SGERC HC.x, R7.w, R1.z;
MAXR  R3.z, R3, c[32].x;
MOVR  R1.xy(NE.x), R3.zwzw;
MOVR  R3.w, R9;
MOVR  R3.z, R5.w;
MAXR  R9.w, R1.x, c[32].x;
DP4R  R1.z, R2, c[24];
DP4R  R1.w, R3, c[20];
ADDR  R5.w, R1, -R1.z;
DP4R  R1.w, R3, c[19];
SGER  H0.y, c[32].x, R1.w;
MADR  R1.z, H0.y, R5.w, R1;
DP4R  R5.w, R2, c[25];
DP4R  R1.w, R3, c[21];
ADDR  R1.w, R1, -R5;
MADR  R1.w, H0.y, R1, R5;
MULR  R4.w, R8, R4;
MADR  R5.w, -R4, c[9].x, R6;
MOVR  R6.xw, c[33].yyzx;
MULR  R6.x, R6, c[4].w;
SGER  H0.x, R8.w, R6;
MULR  R4.w, R4, c[9].x;
MADR  R4.w, H0.x, R5, R4;
MINR  R4.w, R1.y, R4;
MINR  R1.z, R4.w, R1;
MAXR  R10.w, R9, R1.z;
MINR  R1.y, R4.w, R1.w;
MAXR  R11.w, R10, R1.y;
DP4R  R1.y, R2, c[26];
DP4R  R1.x, R3, c[22];
ADDR  R1.x, R1, -R1.y;
MADR  R1.x, H0.y, R1, R1.y;
MINR  R1.x, R4.w, R1;
MAXR  R5.w, R11, R1.x;
ADDR  R6.x, R5.w, -R11.w;
ADDR  R7.xy, R17.wzzw, -R5.w;
RCPR  R1.x, R6.x;
ADDR  R7.zw, R17.xywz, -R11.w;
MULR_SAT R1.y, R1.x, R7.z;
MULR_SAT R1.x, -R7.y, R1;
MULR  R1.w, R1.x, R1.y;
DP3R  R1.x, R4, c[12];
MULR  R1.y, R1.x, c[17].x;
MULR  R1.y, R1, c[32];
MADR  R1.y, c[17].x, c[17].x, R1;
ADDR  R1.y, R1, c[33].x;
POWR  R1.z, R1.y, c[34].z;
MULR  R1.x, R1, R1;
ADDR  R1.y, R6.w, c[17].x;
MADR  R4.xyz, R4, R9.w, R5;
RCPR  R1.z, R1.z;
MULR  R1.y, R1, R1;
MULR  R1.y, R1, R1.z;
MADR  R1.x, R1, c[34].y, c[34].y;
MULR  R8.xy, R1, c[34].w;
MOVR  R1.y, c[35].x;
MULR  R6.z, R1.y, c[16].x;
MOVR  R1.x, c[34];
MULR  R1.xyz, R1.x, c[15];
ADDR  R10.xyz, R1, R6.z;
MULR  R6.y, R8, R6.z;
MADR  R1.xyz, R1, R8.x, R6.y;
RCPR  R9.x, R10.x;
RCPR  R9.z, R10.z;
RCPR  R9.y, R10.y;
MULR  R11.xyz, R1, R9;
MADR  R1.xyz, R11, -R1.w, R11;
DP3R  R1.w, R4, R4;
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
ADDR  R4.x, R1.w, -c[7];
MOVR  R1.w, c[7].x;
ADDR  R1.w, -R1, c[8].x;
RCPR  R1.w, R1.w;
MULR  R5.y, R4.x, R1.w;
MOVR  R4.xyz, c[6];
DP3R  R1.w, R4, c[12];
MADR  R5.x, -R1.w, c[35].z, c[35].z;
TEX   R12.zw, R5, texture[2], 2D;
MULR  R5.xyz, -R10, |R6.x|;
RCPR  R6.y, |R6.x|;
MULR  R1.w, R12, c[16].x;
MADR  R4.xyz, R12.z, -c[15], -R1.w;
MULR  R1.xyz, R9, R1;
POWR  R6.x, c[35].y, R5.x;
POWR  R6.z, c[35].y, R5.z;
TEX   R1.w, c[35].z, texture[3], 2D;
POWR  R4.x, c[35].y, R4.x;
POWR  R4.z, c[35].y, R4.z;
POWR  R4.y, c[35].y, R4.y;
MULR  R4.xyz, R4, c[11];
MULR  R12.xyz, R4, R1.w;
ADDR  R13.xyz, R12, -R12;
MULR  R4.xyz, R13, R6.y;
POWR  R6.y, c[35].y, R5.y;
MADR  R4.xyz, R10, R12, R4;
MADR  R4.xyz, -R6, R4, R4;
MULR  R16.xyz, R1, R4;
DP4R  R1.x, R2, c[27];
DP4R  R1.y, R3, c[23];
ADDR  R1.y, R1, -R1.x;
MADR  R1.x, H0.y, R1.y, R1;
MINR  R1.x, R4.w, R1;
MAXR  R1.w, R5, R1.x;
ADDR  R2.w, R1, -R5;
MULR  R3.xyz, -R10, |R2.w|;
ADDR  R4.xy, R17.wzzw, -R1.w;
RCPR  R1.x, R2.w;
MULR_SAT R1.y, R1.x, R7.x;
MULR_SAT R1.x, -R4.y, R1;
RCPR  R2.x, |R2.w|;
MULR  R1.x, R1, R1.y;
MADR  R1.xyz, R11, -R1.x, R11;
MULR  R2.xyz, R13, R2.x;
MOVR  R5, c[27];
ADDR  R5, -R5, c[23];
MULR  R1.xyz, R9, R1;
ADDR  R1.w, R4, -R1;
MADR  R5, H0.y, R5, c[27];
POWR  R7.x, c[35].y, R3.x;
POWR  R7.y, c[35].y, R3.y;
POWR  R7.z, c[35].y, R3.z;
MULR  R3.xyz, |R1.w|, -R10;
MADR  R2.xyz, R10, R12, R2;
MADR  R2.xyz, -R7, R2, R2;
MULR  R15.xyz, R1, R2;
RCPR  R1.x, R1.w;
RCPR  R2.x, |R1.w|;
MULR  R2.xyz, R13, R2.x;
MULR_SAT R1.y, R1.x, R4.x;
ADDR  R1.z, R4.w, -R17;
MULR_SAT R1.x, R1.z, R1;
MULR  R1.x, R1, R1.y;
MADR  R1.xyz, -R1.x, R11, R11;
MOVR  R4, c[26];
ADDR  R4, -R4, c[22];
MADR  R4, H0.y, R4, c[26];
POWR  R8.x, c[35].y, R3.x;
POWR  R8.y, c[35].y, R3.y;
POWR  R8.z, c[35].y, R3.z;
MADR  R2.xyz, R10, R12, R2;
MADR  R2.xyz, -R8, R2, R2;
MULR  R1.xyz, R1, R9;
MULR  R14.xyz, R1, R2;
MOVR  R1, c[24];
ADDR  R1, -R1, c[20];
MADR  R2, H0.y, R1, c[24];
MOVR  R1, c[25];
ADDR  R1, -R1, c[21];
MADR  R3, H0.y, R1, c[25];
DP4R  R1.x, R2, c[33].x;
DP4R  R2.x, R2, R2;
DP4R  R2.y, R3, R3;
DP4R  R1.y, R3, c[33].x;
DP4R  R2.w, R5, R5;
DP4R  R2.z, R4, R4;
DP4R  R1.z, R4, c[33].x;
DP4R  R1.w, R5, c[33].x;
MADR  R1, R1, R2, -R2;
ADDR  R1, R1, c[33].x;
ADDR  R2.w, R11, -R10;
RCPR  R3.x, R2.w;
MADR  R2.xyz, R14, R1.w, R15;
MADR  R2.xyz, R2, R1.z, R16;
ADDR  R1.zw, R17.xywz, -R10.w;
MULR_SAT R3.y, -R7.w, R3.x;
MULR_SAT R1.z, R3.x, R1;
MULR  R1.z, R3.y, R1;
MULR  R3.xyz, -R10, |R2.w|;
MADR  R4.xyz, R11, -R1.z, R11;
RCPR  R1.z, |R2.w|;
MULR  R5.xyz, R13, R1.z;
POWR  R3.x, c[35].y, R3.x;
POWR  R3.y, c[35].y, R3.y;
POWR  R3.z, c[35].y, R3.z;
MADR  R5.xyz, R10, R12, R5;
MADR  R5.xyz, -R3, R5, R5;
MULR  R4.xyz, R9, R4;
MULR  R4.xyz, R4, R5;
MADR  R2.xyz, R2, R1.y, R4;
ADDR  R1.y, R10.w, -R9.w;
MULR  R5.xyz, -R10, |R1.y|;
RCPR  R1.z, R1.y;
MULR_SAT R1.w, -R1, R1.z;
ADDR  R2.w, R17, -R9;
MULR_SAT R1.z, R1, R2.w;
MULR  R1.z, R1.w, R1;
MADR  R4.xyz, R11, -R1.z, R11;
RCPR  R1.z, |R1.y|;
MULR  R11.xyz, R13, R1.z;
POWR  R5.x, c[35].y, R5.x;
POWR  R5.y, c[35].y, R5.y;
POWR  R5.z, c[35].y, R5.z;
MADR  R10.xyz, R10, R12, R11;
MADR  R10.xyz, -R5, R10, R10;
MULR  R4.xyz, R9, R4;
MULR  R4.xyz, R4, R10;
MADR  R1.xyz, R2, R1.x, R4;
MULR  R2.xyz, R1.y, c[38];
MADR  R2.xyz, R1.x, c[37], R2;
MADR  R1.xyz, R1.z, c[36], R2;
ADDR  R1.w, R1.x, R1.y;
ADDR  R1.z, R1, R1.w;
RCPR  R1.z, R1.z;
MULR  R1.zw, R1.xyxy, R1.z;
MULR  R1.x, R1.z, c[35].w;
FLRR  R1.x, R1;
MINR  R1.x, R1, c[35].w;
SGER  H0.x, R1, c[36].w;
MULH  H0.y, H0.x, c[36].w;
ADDR  R1.x, R1, -H0.y;
MULR  R1.z, R1.x, c[35].x;
FLRR  H0.y, R1.z;
MULH  H0.z, H0.y, c[38].w;
MULR  R1.z, R1.w, c[39].y;
FLRR  R1.z, R1;
ADDH  H0.y, H0, -c[37].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R1.x, R1, -H0.z;
MINR  R1.z, R1, c[39];
MADR  R1.x, R1, c[39], R1.z;
MADR  H0.z, R1.x, c[39].w, R6.w;
MADH  H0.x, H0, c[32].y, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R1.z, H0, c[40].y;
FLRR  R1.x, R1.z;
ADDH  H0.y, H0, c[37].w;
FRCR  R1.z, R1;
MULR  R1.z, R1, c[41].x;
RCPR  R2.x, R1.z;
MULH  H0.y, H0, c[38].w;
SGEH  H0.x, c[32], H0;
MADH  H0.x, H0, c[36].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.x, R1, c[40].z;
ADDR  R1.w, -R1.x, -R1.z;
MADR  R1.w, R1, R1.y, R1.y;
MULR  R1.x, R1, R1.y;
MULR  R2.y, R2.x, R1.x;
MULR  R1.xyz, R1.y, c[44];
MULR  R1.w, R1, R2.x;
MADR  R1.xyz, R2.y, c[43], R1;
MADR  R1.xyz, R1.w, c[42], R1;
MAXR  R1.xyz, R1, c[32].x;
ADDR  R2.xyz, -R1, c[41].zyyw;
MADR  R1.xyz, R2, c[29].x, R1;
MULR  R2.xyz, R3, R5;
MULR  R2.xyz, R6, R2;
MULR  R2.xyz, R7, R2;
MULR  R2.xyz, R8, R2;
MULR  R3.xyz, R2.y, c[38];
MADR  R3.xyz, R2.x, c[37], R3;
MADR  R2.xyz, R2.z, c[36], R3;
ADDR  R1.w, R2.x, R2.y;
ADDR  R1.w, R2.z, R1;
RCPR  R1.w, R1.w;
MULR  R2.zw, R2.xyxy, R1.w;
MULR  R1.w, R2.z, c[35];
FLRR  R1.w, R1;
MINR  R1.w, R1, c[35];
SGER  H0.x, R1.w, c[36].w;
MULH  H0.y, H0.x, c[36].w;
ADDR  R1.w, R1, -H0.y;
MULR  R2.x, R1.w, c[35];
FLRR  H0.y, R2.x;
MULH  H0.z, H0.y, c[38].w;
MULR  R2.x, R2.w, c[39].y;
FLRR  R2.x, R2;
ADDH  H0.y, H0, -c[37].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R1.w, R1, -H0.z;
MINR  R2.x, R2, c[39].z;
MADR  R1.w, R1, c[39].x, R2.x;
MADR  H0.z, R1.w, c[39].w, R6.w;
MADH  H0.x, H0, c[32].y, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R1.w, H0.z, c[40].y;
FLRR  R2.x, R1.w;
FRCR  R1.w, R1;
MULR  R2.z, R1.w, c[41].x;
ADDH  H0.y, H0, c[37].w;
RCPR  R2.w, R2.z;
MULH  H0.y, H0, c[38].w;
SGEH  H0.x, c[32], H0;
MADH  H0.x, H0, c[36].w, H0.y;
ADDR  R2.x, H0, R2;
MULR  R2.x, R2, c[40].z;
ADDR  R1.w, -R2.x, -R2.z;
MADR  R1.w, R1, R2.y, R2.y;
MULR  R2.x, R2, R2.y;
MULR  R3.x, R2.w, R2;
MULR  R2.xyz, R2.y, c[44];
MADR  R2.xyz, R3.x, c[43], R2;
MULR  R1.w, R1, R2;
MADR  R2.xyz, R1.w, c[42], R2;
MAXR  R2.xyz, R2, c[32].x;
MADR  R2.xyz, -R2, c[29].x, R2;
ELSE;
ADDR  R6.xy, R17, c[30].xzzw;
ADDR  R1.xy, R6, c[30].zyzw;
TEX   R3, R1, texture[4], 2D;
ADDR  R7.xy, R1, -c[30].xzzw;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R3|, H0;
MADH  H0.y, H0, c[40].x, -c[40].x;
MULR  R1.z, H0.y, c[40].y;
FRCR  R1.w, R1.z;
MULR  R2.x, R1.w, c[41];
ADDH  H0.x, H0, c[37].w;
MULH  H0.z, H0.x, c[38].w;
SGEH  H0.xy, c[32].x, R3.ywzw;
TEX   R4, R7, texture[4], 2D;
MADH  H0.x, H0, c[36].w, H0.z;
FLRR  R1.z, R1;
ADDR  R1.z, H0.x, R1;
MULR  R1.z, R1, c[40];
ADDR  R1.w, -R1.z, -R2.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[37].w;
RCPR  R1.x, R2.x;
MULR  R1.y, R1.z, R3.x;
MADR  R1.w, R1, R3.x, R3.x;
MULR  R1.w, R1, R1.x;
MULR  R2.x, R1, R1.y;
MULR  R1.xyz, R3.x, c[44];
MADR  R1.xyz, R2.x, c[43], R1;
MADR  R1.xyz, R1.w, c[42], R1;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R1.w, H0.z, c[40].y;
MAXR  R2.xyz, R1, c[32].x;
FRCR  R1.x, R1.w;
SGEH  H0.zw, c[32].x, R4.xyyw;
MULH  H0.x, H0, c[38].w;
MULR  R1.z, R1.x, c[41].x;
FLRR  R1.y, R1.w;
MADH  H0.x, H0.z, c[36].w, H0;
ADDR  R1.y, H0.x, R1;
MULR  R1.x, R1.y, c[40].z;
ADDR  R1.y, -R1.x, -R1.z;
MADR  R1.y, R1, R4.x, R4.x;
RCPR  R1.w, R1.z;
MULR  R2.w, R1.y, R1;
MULR  R3.x, R1, R4;
MULR  R1.w, R1, R3.x;
MULR  R1.xyz, R4.x, c[44];
MADR  R5.xyz, R1.w, c[43], R1;
TEX   R1, R6, texture[4], 2D;
MADR  R5.xyz, R2.w, c[42], R5;
LG2H  H0.x, |R1.y|;
MAXR  R5.xyz, R5, c[32].x;
ADDR  R6.xyz, R2, -R5;
TEX   R2, R17, texture[4], 2D;
ADDR  R17.xy, R7, -c[30].zyzw;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R4.x, H0.z, c[40].y;
FRCR  R4.y, R4.x;
MULR  R3.xy, R17, c[31];
FRCR  R3.xy, R3;
MADR  R5.xyz, R3.x, R6, R5;
ADDH  H0.x, H0, c[37].w;
SGEH  H1.xy, c[32].x, R1.ywzw;
MULH  H0.x, H0, c[38].w;
SGEH  H1.zw, c[32].x, R2.xyyw;
FLRR  R4.x, R4;
MADH  H0.x, H1, c[36].w, H0;
ADDR  R1.y, H0.x, R4.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MULR  R4.x, R1.y, c[40].z;
MULR  R4.y, R4, c[41].x;
ADDR  R1.y, -R4.x, -R4;
RCPR  R4.y, R4.y;
MADR  R1.y, R1, R1.x, R1.x;
MULR  R4.x, R4, R1;
MULR  R1.y, R1, R4;
MULR  R4.x, R4.y, R4;
MULR  R6.xyz, R1.x, c[44];
MADR  R6.xyz, R4.x, c[43], R6;
MADH  H0.z, H0, c[40].x, -c[40].x;
MADR  R6.xyz, R1.y, c[42], R6;
MULR  R1.x, H0.z, c[40].y;
FRCR  R1.y, R1.x;
MADH  H0.x, H1.z, c[36].w, H0;
FLRR  R1.x, R1;
ADDR  R1.x, H0, R1;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MULR  R2.y, R1.x, c[40].z;
MULR  R1.y, R1, c[41].x;
ADDR  R1.x, -R2.y, -R1.y;
MULR  R2.y, R2, R2.x;
MADR  R1.x, R1, R2, R2;
RCPR  R1.y, R1.y;
MULR  R1.x, R1, R1.y;
MULR  R1.y, R1, R2;
MULR  R7.xyz, R2.x, c[44];
MADR  R7.xyz, R1.y, c[43], R7;
MADR  R7.xyz, R1.x, c[42], R7;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R1.x, H0.z, c[40].y;
FRCR  R1.y, R1.x;
MAXR  R7.xyz, R7, c[32].x;
MAXR  R6.xyz, R6, c[32].x;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R3.x, R6, R7;
MADH  H0.x, H1.y, c[36].w, H0;
FLRR  R1.x, R1;
ADDR  R1.x, H0, R1;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MULR  R1.y, R1, c[41].x;
MULR  R1.x, R1, c[40].z;
ADDR  R1.w, -R1.x, -R1.y;
MADR  R1.w, R1.z, R1, R1.z;
RCPR  R1.y, R1.y;
MULR  R1.x, R1.z, R1;
MULR  R1.w, R1, R1.y;
MULR  R2.x, R1.y, R1;
MULR  R1.xyz, R1.z, c[44];
MADR  R1.xyz, R2.x, c[43], R1;
MADR  R1.xyz, R1.w, c[42], R1;
MAXR  R7.xyz, R1, c[32].x;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R1.x, H0.z, c[40].y;
FRCR  R1.y, R1.x;
MULR  R1.z, R1.y, c[41].x;
RCPR  R2.x, R1.z;
MADH  H0.x, H1.w, c[36].w, H0;
FLRR  R1.x, R1;
ADDR  R1.x, H0, R1;
MULR  R1.x, R1, c[40].z;
ADDR  R1.y, -R1.x, -R1.z;
MADR  R1.y, R2.z, R1, R2.z;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[37].w;
MULR  R1.w, R1.y, R2.x;
MULR  R2.y, R2.z, R1.x;
MULR  R1.xyz, R2.z, c[44];
MULR  R2.x, R2, R2.y;
MADR  R1.xyz, R2.x, c[43], R1;
MADR  R1.xyz, R1.w, c[42], R1;
MAXR  R1.xyz, R1, c[32].x;
ADDR  R2.xyz, R7, -R1;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R1.w, H0.z, c[40].y;
MULH  H0.x, H0, c[38].w;
MADH  H0.z, H0.w, c[36].w, H0.x;
FLRR  R2.w, R1;
ADDR  R2.w, H0.z, R2;
MULR  R4.x, R2.w, c[40].z;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R1.w, R1;
MULR  R4.y, R1.w, c[41].x;
MULH  H0.z, |R3.w|, H0;
ADDR  R4.w, -R4.x, -R4.y;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R1.w, H0.z, c[40].y;
FRCR  R2.w, R1;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MADR  R4.w, R4.z, R4, R4.z;
RCPR  R5.w, R4.y;
MULR  R6.w, R4.z, R4.x;
MADR  R2.xyz, R3.x, R2, R1;
MULR  R2.w, R2, c[41].x;
MULR  R4.w, R4, R5;
ADDR  R5.xyz, R5, -R6;
FLRR  R1.w, R1;
MADH  H0.x, H0.y, c[36].w, H0;
ADDR  R1.w, H0.x, R1;
MULR  R1.w, R1, c[40].z;
ADDR  R3.w, -R1, -R2;
MULR  R4.xyz, R4.z, c[44];
MULR  R6.w, R5, R6;
MADR  R4.xyz, R6.w, c[43], R4;
MADR  R4.xyz, R4.w, c[42], R4;
MULR  R4.w, R3.z, R1;
RCPR  R1.w, R2.w;
MAXR  R4.xyz, R4, c[32].x;
MULR  R2.w, R1, R4;
MADR  R3.w, R3.z, R3, R3.z;
MULR  R7.xyz, R3.z, c[44];
MADR  R7.xyz, R2.w, c[43], R7;
MULR  R1.w, R3, R1;
MADR  R7.xyz, R1.w, c[42], R7;
MAXR  R7.xyz, R7, c[32].x;
ADDR  R7.xyz, R7, -R4;
MADR  R1.xyz, R3.x, R7, R4;
ADDR  R4.xyz, R1, -R2;
MADR  R1.xyz, R3.y, R5, R6;
MADR  R2.xyz, R3.y, R4, R2;
ENDIF;
MOVR  R1.w, c[33].y;
MULR  R1.w, R1, c[4];
SGTRC HC.x, R8.w, R1.w;
IF    NE.x;
TEX   R3.xyz, R17, texture[5], 2D;
ELSE;
MOVR  R3.xyz, c[32].x;
ENDIF;
MULR  R2.xyz, R2, R0.w;
MADR  R0.xyz, R3, R2, R0;
ADDR  R0.xyz, R0, R1;
MULR  R1.xyz, R0.y, c[38];
MADR  R1.xyz, R0.x, c[37], R1;
MADR  R0.xyz, R0.z, c[36], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].w;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].w;
SGER  H0.x, R0, c[36].w;
MULH  H0.y, H0.x, c[36].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[35].x;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[37].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[38].w;
MULR  R1.xyz, R2.y, c[38];
MADR  R1.xyz, R2.x, c[37], R1;
MADR  R1.xyz, R2.z, c[36], R1;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[35].w;
MULR  R0.w, R0, c[39].y;
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[39];
FLRR  R0.y, R0;
MADH  H0.x, H0, c[32].y, H0.z;
MINR  R0.z, R0, c[35].w;
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[36].w;
MULH  H0.y, H0.z, c[36].w;
MINR  R0.w, R0, c[39].z;
MADR  R0.w, R0.x, c[39].x, R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[33];
MADR  H0.y, R0.w, c[39].w, R0.x;
MULR  R0.w, R0.z, c[35].x;
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[38].w;
ADDH  H0.x, H0, -c[37].w;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[39].z;
MADR  R0.y, R0.z, c[39].x, R0;
MADR  H0.z, R0.y, c[39].w, R0.x;
MADH  H0.x, H0.y, c[32].y, H0;
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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 3 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 2 [_TexDensity] 2D
SetTexture 5 [_TexBackground] 2D
SetTexture 1 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 4 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c32, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c33, -1000000.00000000, 0.99500000, 1000000.00000000, 0.10000000
def c34, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c35, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c36, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c37, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c38, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c39, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c40, 0.00097656, 1.00000000, 15.00000000, 1024.00000000
def c41, 0.00390625, 0.00476190, 0.63999999, 0
def c42, 0.07530000, -0.25430000, 1.18920004, 0
def c43, 2.56509995, -1.16649997, -0.39860001, 0
def c44, -1.02170002, 1.97770000, 0.04390000, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c32.x, c32.y
mov r5, c23
mov r3, c22
mov r0.z, c32.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c32.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c7
mov r0.y, c7.x
add r0.y, c13, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c9.x
add r2.xyz, r2, -c5
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c13, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c32.w, c32.z
cmp r0.x, r0, r1.w, c33
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c32.w, c32.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c33.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c7.x
add r1.y, c13.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c7.x
add r0.w, c13.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c32, c32.z
cmp r1.z, r1, r1.w, c33.x
cmp_pp r0.z, r1.x, c32.w, c32
cmp r1.x, r1, r1.w, c33
cmp r0.w, -r0, r1.z, r2.x
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c19
cmp r2.z, -r0.x, c32.w, c32
mov r0, c20
mov r1, c21
add r0, -c24, r0
mad r0, r2.z, r0, c24
add r1, -c25, r1
mad r1, r2.z, r1, c25
add r5, -c27, r5
mad r5, r2.z, r5, c27
add r3, -c26, r3
mad r3, r2.z, r3, c26
dp4 r2.y, r1, c32.w
dp4 r2.x, r0, c32.w
dp4 r2.z, r3, c32.w
dp4 r2.w, r5, c32.w
add r6, r2, c32.y
dp4 r2.y, r1, r1
dp4 r2.x, r0, r0
dp4 r2.z, r3, r3
dp4 r3.y, r3, c32.z
dp4 r2.w, r5, r5
mad r2, r2, r6, c32.w
dp4 r3.x, r5, c32.z
mul r4.z, r2.x, r2.y
mul r4.z, r4, r2
mad r2.z, r2, r3.x, r3.y
dp4 r1.x, r1, c32.z
add r3.xy, v0, c30.xzzw
add r5.xy, r3, c30.zyzw
mov r3.z, v0.w
mad r1.y, r2, r2.z, r1.x
dp4 r0.y, r0, c32.z
mov r5.z, v0.w
texldl r0.x, r5.xyzz, s1
add r6.xy, r5, -c30.xzzw
mov r6.z, v0.w
texldl r1.x, r6.xyzz, s1
add r1.z, r1.x, -r0.x
add r6.xy, r6, -c30.zyzw
mul r0.zw, r6.xyxy, c31.xyxy
frc r0.zw, r0
mad r1.z, r0, r1, r0.x
texldl r1.x, v0, s1
texldl r3.x, r3.xyzz, s1
add r1.w, r3.x, -r1.x
mad r1.x, r0.z, r1.w, r1
add r0.x, c4.w, -c4.z
rcp r0.z, r0.x
add r1.z, r1, -r1.x
mul r0.z, r0, c4.w
texldl r0.x, v0, s0
add r0.x, r0.z, -r0
mad r1.x, r0.w, r1.z, r1
rcp r0.w, r0.x
mul r0.x, r0.z, c4.z
mul r6.w, r0.x, r0
add r0.x, r6.w, -r1
abs r0.x, r0
mul r2.w, r4.z, r2
mad r2.xyz, r2.x, r1.y, r0.y
mov r6.z, v0.w
if_gt r0.x, c28.x
mad r0.xy, r6, c32.x, c32.y
mul r0.xy, r0, c4
mov r0.z, c32.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c32.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.x, c7
mov r1.y, c7.x
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r5.xyz, r3, c9.x
add r8.xyz, r5, -c5
dp3 r4.z, r8, r0
dp3 r4.w, r8, r8
add r1.y, c14, r1
mad r1.z, -r1.y, r1.y, r4.w
mad r1.w, r4.z, r4.z, -r1.z
rsq r3.x, r1.w
add r1.x, c14, r1
mad r1.x, -r1, r1, r4.w
mad r1.x, r4.z, r4.z, -r1
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r4, -r1.y
cmp_pp r1.y, r1.x, c32.w, c32.z
cmp r1.x, r1, r4, c33.z
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c32.w, c32.z
rcp r3.x, r3.x
cmp r1.w, r1, r4.x, c33.z
add r3.x, -r4.z, -r3
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r3.x, c14.w, r1.z
mad r1.w, -r1, r1, r4
mad r1.z, r4, r4, -r1.w
mad r3.x, -r3, r3, r4.w
mad r3.y, r4.z, r4.z, -r3.x
rsq r1.w, r1.z
rcp r1.w, r1.w
add r3.x, -r4.z, -r1.w
cmp_pp r1.w, r1.z, c32, c32.z
cmp r1.z, r1, r4.x, c33
cmp r1.z, -r1.w, r1, r3.x
rsq r3.z, r3.y
rcp r3.z, r3.z
cmp r3.x, r3.y, r4, c33.z
add r3.z, -r4, -r3
cmp_pp r1.w, r3.y, c32, c32.z
cmp r1.w, -r1, r3.x, r3.z
mov r3.x, c7
add r3.y, c13.x, r3.x
mov r3.x, c7
add r3.z, c13.y, r3.x
mad r3.y, -r3, r3, r4.w
mad r3.x, r4.z, r4.z, -r3.y
mad r3.z, -r3, r3, r4.w
mad r3.w, r4.z, r4.z, -r3.z
rsq r3.y, r3.x
rcp r3.y, r3.y
add r3.z, -r4, r3.y
cmp_pp r3.y, r3.x, c32.w, c32.z
cmp r3.x, r3, r4, c33
cmp r3.x, -r3.y, r3, r3.z
rsq r7.x, r3.w
cmp_pp r3.y, r3.w, c32.w, c32.z
rcp r7.x, r7.x
dp4 r5.w, r1, c24
dp4 r7.w, r1, c25
cmp r3.w, r3, r4.x, c33.x
add r7.x, -r4.z, r7
cmp r3.y, -r3, r3.w, r7.x
mov r3.z, c7.x
add r3.w, c13, r3.z
mad r3.w, -r3, r3, r4
mad r7.y, r4.z, r4.z, -r3.w
rsq r3.w, r7.y
rcp r7.x, r3.w
mov r3.z, c7.x
add r3.z, c13, r3
mad r3.z, -r3, r3, r4.w
mad r3.z, r4, r4, -r3
add r7.z, -r4, r7.x
rsq r3.w, r3.z
rcp r7.x, r3.w
cmp_pp r3.w, r7.y, c32, c32.z
cmp r7.y, r7, r4.x, c33.x
cmp r3.w, -r3, r7.y, r7.z
add r7.y, -r4.z, r7.x
cmp_pp r7.x, r3.z, c32.w, c32.z
cmp r3.z, r3, r4.x, c33.x
cmp r3.z, -r7.x, r3, r7.y
dp4 r7.x, r3, c20
add r7.z, r7.x, -r5.w
dp4 r7.y, r3, c19
mov r7.x, c7
cmp r11.w, -r7.y, c32, c32.z
add r7.x, c18, r7
mad r7.y, -r7.x, r7.x, r4.w
mad r7.x, r11.w, r7.z, r5.w
mad r5.w, r4.z, r4.z, -r7.y
dp4 r7.z, r3, c21
add r8.w, r7.z, -r7
rsq r7.y, r5.w
rcp r7.y, r7.y
add r7.z, -r4, -r7.y
cmp_pp r7.y, r5.w, c32.w, c32.z
cmp r5.w, r5, r4.x, c33.z
cmp r5.w, -r7.y, r5, r7.z
rcp r0.w, r0.w
mul r7.y, r6.w, r0.w
cmp r7.z, r5.w, r5.w, c33
mad r7.z, -r7.y, c9.x, r7
mad r4.w, -c8.x, c8.x, r4
mad r5.w, r4.z, r4.z, -r4
rsq r4.w, r5.w
mov r0.w, c4
mad r0.w, c33.y, -r0, r6
mad r7.w, r11, r8, r7
rcp r4.w, r4.w
cmp r0.w, r0, c32, c32.z
mul r7.y, r7, c9.x
mad r7.y, r0.w, r7.z, r7
add r0.w, -r4.z, -r4
add r4.w, -r4.z, r4
max r4.z, r0.w, c32
cmp_pp r0.w, r5, c32, c32.z
max r4.w, r4, c32.z
cmp r4.xy, r5.w, r4, c32.z
cmp r4.xy, -r0.w, r4, r4.zwzw
min r5.w, r4.y, r7.y
min r4.y, r5.w, r7.w
max r7.w, r4.x, c32.z
dp4 r4.x, r1, c26
dp4 r1.y, r1, c27
min r0.w, r5, r7.x
max r8.w, r7, r0
dp4 r0.w, r3, c22
add r0.w, r0, -r4.x
dp4 r1.x, r3, c23
add r1.x, r1, -r1.y
mad r0.w, r11, r0, r4.x
max r9.w, r8, r4.y
mad r1.x, r11.w, r1, r1.y
min r0.w, r5, r0
max r10.w, r9, r0
min r1.x, r5.w, r1
max r12.w, r10, r1.x
add r11.x, r12.w, -r10.w
mov r0.w, c16.x
mov r1.xyz, c15
mad r4.xyz, r0, r7.w, r8
mul r1.w, c34, r0
dp3 r0.w, r4, r4
mul r1.xyz, c33.w, r1
add r10.xyz, r1, r1.w
abs r3.x, r11
mul r7.xyz, -r10, r3.x
pow r3, c35.x, r7.x
mov r7.x, r3
pow r3, c35.x, r7.y
rsq r0.w, r0.w
rcp r3.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r4.xyz, c12
rcp r3.z, r0.w
dp3 r0.w, c6, r4
add r3.x, r3, -c7
add r0.w, -r0, c32
mul r4.y, r3.x, r3.z
mul r4.x, r0.w, c35.y
mov r4.z, c32
texldl r3.zw, r4.xyzz, s2
mul r0.w, r3, c16.x
pow r4, c35.x, r7.z
mad r9.xyz, r3.z, -c15, -r0.w
mov r7.y, r3
pow r3, c35.x, r9.x
mov r7.z, r4
pow r4, c35.x, r9.y
mov r9.x, r3
pow r3, c35.x, r9.z
mov r9.z, r3
mul r3.xyz, r8.zxyw, c12.yzxw
mad r3.xyz, r8.yzxw, c12.zxyw, -r3
dp3 r0.w, r3, r3
mov r9.y, r4
mul r4.xyz, r9, c11
mul r9.xyz, r0.zxyw, c12.yzxw
mad r9.xyz, r0.yzxw, c12.zxyw, -r9
dp3 r3.w, r3, r9
dp3 r4.w, r9, r9
mad r0.w, -c7.x, c7.x, r0
mul r0.w, r4, r0
mad r3.x, r3.w, r3.w, -r0.w
rsq r3.y, r3.x
rcp r9.x, r3.y
add r3.y, -r3.w, -r9.x
add r3.w, -r3, r9.x
rcp r4.w, r4.w
texldl r0.w, c35.yyzz, s3
mul r12.xyz, r4, r0.w
mul r13.xyz, r10, r12
dp3 r0.w, r8, c12
cmp r0.w, -r0, c32, c32.z
mul r4.xyz, r13, r7
rcp r9.x, r10.x
rcp r9.z, r10.z
rcp r9.y, r10.y
mul r3.y, r3, r4.w
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r3.x
cmp r8.x, -r0.w, c33.z, r3.y
mad r3.xyz, r0, r8.x, r5
add r3.xyz, r3, -c5
dp3 r3.x, r3, c12
mul r3.y, r4.w, r3.w
cmp r8.y, -r0.w, c33.x, r3
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, r3.x
cmp r17.xy, -r0.w, r8, c33.zxzw
dp3 r3.x, r0, c12
mul r0.x, r3, c17
mul r0.x, r0, c32
add r3.w, r5, -r12
rcp r3.y, r11.x
add r0.w, -r17.x, r12
add r3.z, r17.y, -r10.w
mul_sat r0.w, r0, r3.y
mul_sat r0.y, r3, r3.z
mad r3.z, -r0.w, r0.y, c32.w
abs r0.y, r3.w
mad r0.x, c17, c17, r0
mul r5.xyz, -r10, r0.y
add r3.y, r0.x, c32.w
pow r0, r3.y, c34.y
mad r0.z, r3.x, r3.x, c32.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c32.w, r0.y
mad r4.xyz, r10, r12, -r4
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c34
mul r3.xy, r0, c34.z
pow r0, c35.x, r5.x
mul r0.y, r3, r1.w
mad r1.xyz, r1, r3.x, r0.y
mul r11.xyz, r1, r9
pow r1, c35.x, r5.z
mov r8.x, r0
pow r0, c35.x, r5.y
mov r8.z, r1
mov r8.y, r0
mul r3.xyz, r11, r3.z
mul r1.xyz, r9, r3
mul r0.xyz, r8, r13
mul r15.xyz, r1, r4
mad r1.xyz, r10, r12, -r0
add r0.z, r17.y, -r12.w
rcp r0.y, r3.w
add r0.x, r5.w, -r17
add r12.w, r10, -r9
abs r0.w, r12
mov r5, c23
add r5, -c27, r5
mul r16.xyz, -r10, r0.w
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c32.w
mul r0.xyz, r0.x, r11
mul r0.xyz, r0, r9
mul r14.xyz, r0, r1
mov r1, c20
add r1, -c24, r1
mad r4, r11.w, r1, c24
mov r0, c21
add r0, -c25, r0
mad r3, r11.w, r0, c25
dp4 r0.x, r4, c32.w
dp4 r4.x, r4, r4
mad r5, r11.w, r5, c27
mov r1, c22
add r1, -c26, r1
mad r1, r11.w, r1, c26
dp4 r4.y, r3, r3
dp4 r0.y, r3, c32.w
pow r3, c35.x, r16.y
dp4 r4.z, r1, r1
dp4 r0.w, r5, c32.w
dp4 r0.z, r1, c32.w
add r0, r0, c32.y
dp4 r4.w, r5, r5
mad r1, r4, r0, c32.w
pow r0, c35.x, r16.x
mad r5.xyz, r14, r1.w, r15
mov r4.x, r0
mov r4.y, r3
rcp r0.z, r12.w
add r0.w, r17.y, -r9
add r0.y, -r17.x, r10.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c32
pow r0, c35.x, r16.z
mov r4.z, r0
mul r3.xyz, r13, r4
mul r0.xyz, r11, r1.w
mad r3.xyz, r10, r12, -r3
mul r0.xyz, r9, r0
mul r0.xyz, r0, r3
mad r5.xyz, r5, r1.z, r0
add r0.w, r9, -r8
abs r0.y, r0.w
mul r14.xyz, -r10, r0.y
rcp r1.z, r0.w
add r0.x, -r17, r9.w
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r14.x
add r3.x, r17.y, -r8.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r14.y
mad r1.z, -r1.w, r0.y, c32.w
mov r14.x, r0
pow r0, c35.x, r14.z
mov r14.z, r0
mov r14.y, r3
mul r0.xyz, r11, r1.z
mul r3.xyz, r13, r14
mul r0.xyz, r9, r0
mad r3.xyz, r10, r12, -r3
mul r15.xyz, r0, r3
add r0.y, r8.w, -r7.w
rcp r1.z, r0.y
add r0.x, -r17, r8.w
abs r0.y, r0
mul r16.xyz, -r10, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r16.x
add r3.x, r17.y, -r7.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r16.y
mad r1.z, -r1.w, r0.y, c32.w
mov r16.x, r0
pow r0, c35.x, r16.z
mov r16.y, r3
mov r16.z, r0
mul r3.xyz, r11, r1.z
mul r0.xyz, r13, r16
mul r3.xyz, r9, r3
mad r0.xyz, r10, r12, -r0
mul r0.xyz, r3, r0
mad r3.xyz, r5, r1.y, r15
mad r0.xyz, r3, r1.x, r0
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r0.w, r0, c39.z
frc r0.z, r0.w
add r0.w, r0, -r0.z
mul_pp r0.z, r1.y, c39.x
mul_pp r0.x, r0, r1.z
add r0.z, r1.x, -r0
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.z
abs_pp r0.z, r0.x
mul r1.xyz, r14, r16
mul r1.xyz, r4, r1
mul r1.xyz, r7, r1
mul r3.xyz, r8, r1
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c32.y
mul r4.xyz, r3.y, c38
mad r4.xyz, r3.x, c37, r4
mad r1.xyz, r3.z, c36, r4
add r3.x, r1, r1.y
add r1.z, r1, r3.x
mul_pp r0.z, r0, c40.w
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r3.x, r1.z, c35.w
mul r0.z, r0, c41.x
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c40
frc r3.y, r3.x
add r0.w, r3.x, -r3.y
min r0.w, r0, c35
add r3.x, r0.w, c36.w
mul r1.w, r1, c39.z
frc r3.y, r1.w
add r1.w, r1, -r3.y
cmp r3.x, r3, c32.w, c32.z
mul_pp r0.z, r0, c39.x
cmp_pp r0.x, -r0, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r3.x, c37.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c41
mul r1.x, r0.w, c34.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c39.x
add r0.w, r0, -r1.z
min r1.w, r1, c39
mad r1.z, r0.w, c39.y, r1.w
add_pp r0.w, r1.x, c38
exp_pp r1.x, r0.w
mad_pp r0.w, -r3.x, c32.x, c32
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c40.x, c40.y
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r3.x, r1.w
add_pp r1.w, r1, -r3.x
exp_pp r3.x, -r1.w
mad_pp r1.z, r1, r3.x, c32.y
mul r0.x, r0, c41.y
add r0.w, -r0.x, -r0.z
add r0.w, r0, c32
mul r3.xyz, r0.y, c44
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c40.w
mul r3.w, r0.z, c41.x
mad r0.xyz, r0.x, c43, r3
add_pp r1.z, r1.w, c40
frc r3.x, r3.w
mad r0.xyz, r0.w, c42, r0
add r1.w, r3, -r3.x
mul_pp r1.z, r1, c39.x
cmp_pp r1.x, -r1, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.z
mul r1.z, r3.x, c41
add r1.x, r1, r1.w
mul r1.x, r1, c41.y
add r1.w, -r1.x, -r1.z
add r0.w, r1, c32
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r3.xyz, r1.y, c44
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c32.z
mad r3.xyz, r1.y, c43, r3
mul r0.w, r0, r1.x
mad r3.xyz, r0.w, c42, r3
add r1.xyz, -r0, c32.wzzw
max r3.xyz, r3, c32.z
mad r1.xyz, r1, c29.x, r0
mad r3.xyz, -r3, c29.x, r3
else
add r3.xy, r6, c30.xzzw
add r1.xy, r3, c30.zyzw
mov r1.z, r6
texldl r0, r1.xyzz, s4
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r3.z, r1.w
add_pp r1.w, r1, -r3.z
exp_pp r3.z, -r1.w
mad_pp r1.z, r1, r3, c32.y
mul_pp r1.z, r1, c40.w
mul r3.z, r1, c41.x
add_pp r1.z, r1.w, c40
frc r3.w, r3.z
add r1.w, r3.z, -r3
add r8.xy, r1, -c30.xzzw
mul r3.z, r3.w, c41
mul_pp r1.z, r1, c39.x
cmp_pp r0.y, -r0, c32.w, c32.z
mad_pp r0.y, r0, c37.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c41
add r3.w, -r0.y, -r3.z
mov r8.z, r6
texldl r1, r8.xyzz, s4
abs_pp r4.x, r1.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r3.w, r3, c32
mul r3.w, r3, r0.x
rcp r3.z, r3.z
mul r0.y, r0, r0.x
mul r3.w, r3, r3.z
exp_pp r4.y, -r4.w
mul r0.y, r3.z, r0
mad_pp r3.z, r4.x, r4.y, c32.y
mul r4.xyz, r0.x, c44
mad r4.xyz, r0.y, c43, r4
mul_pp r0.x, r3.z, c40.w
mul r0.y, r0.x, c41.x
mad r4.xyz, r3.w, c42, r4
frc r3.z, r0.y
add r3.w, r0.y, -r3.z
add_pp r0.x, r4.w, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r1.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r3.w
mul r0.y, r3.z, c41.z
mul r0.x, r0, c41.y
add r1.y, -r0.x, -r0
add r1.y, r1, c32.w
mov r3.z, r6
texldl r3, r3.xyzz, s4
abs_pp r4.w, r3.y
log_pp r5.x, r4.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r5.y, r5.x
add_pp r0.y, r5.x, -r5
mul r5.xyz, r1.x, c44
mad r5.xyz, r0.x, c43, r5
exp_pp r1.x, -r0.y
mad_pp r0.x, r4.w, r1, c32.y
mad r5.xyz, r1.y, c42, r5
mul_pp r0.x, r0, c40.w
mul r1.x, r0, c41
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r3.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r1
max r5.xyz, r5, c32.z
max r4.xyz, r4, c32.z
add r7.xyz, r4, -r5
texldl r4, r6.xyzz, s4
add r6.xy, r8, -c30.zyzw
mul r1.x, r0, c41.y
mul r1.y, r1, c41.z
add r3.y, -r1.x, -r1
mul r0.xy, r6, c31
frc r0.xy, r0
mad r7.xyz, r0.x, r7, r5
abs_pp r5.x, r4.y
log_pp r5.y, r5.x
frc_pp r5.z, r5.y
add_pp r5.w, r5.y, -r5.z
add r3.y, r3, c32.w
mul r3.y, r3, r3.x
rcp r1.y, r1.y
mul r1.x, r1, r3
mul r3.y, r3, r1
exp_pp r5.y, -r5.w
mul r1.x, r1.y, r1
mad_pp r1.y, r5.x, r5, c32
mul r5.xyz, r3.x, c44
mad r5.xyz, r1.x, c43, r5
mad r5.xyz, r3.y, c42, r5
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r5.w, c40.z
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.y, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
rcp r3.y, r1.y
mul r1.x, r1, r4
add r3.x, r3, c32.w
mul r1.y, r3.x, r4.x
abs_pp r3.x, r3.w
mul r1.y, r1, r3
log_pp r4.y, r3.x
mul r1.x, r3.y, r1
frc_pp r3.y, r4
mul r8.xyz, r4.x, c44
mad r8.xyz, r1.x, c43, r8
add_pp r3.y, r4, -r3
exp_pp r1.x, -r3.y
mad r8.xyz, r1.y, c42, r8
mad_pp r1.x, r3, r1, c32.y
mul_pp r1.x, r1, c40.w
mul r1.y, r1.x, c41.x
frc r3.x, r1.y
add_pp r1.x, r3.y, c40.z
add r3.y, r1, -r3.x
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r3.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
abs_pp r3.y, r4.w
log_pp r4.x, r3.y
frc_pp r4.y, r4.x
add_pp r4.x, r4, -r4.y
max r8.xyz, r8, c32.z
max r5.xyz, r5, c32.z
add r5.xyz, r5, -r8
mad r5.xyz, r0.x, r5, r8
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
add r3.x, r3, c32.w
mul r3.x, r3.z, r3
rcp r1.y, r1.y
mul r3.w, r3.x, r1.y
mul r1.x, r3.z, r1
exp_pp r3.x, -r4.x
mul r1.x, r1.y, r1
mad_pp r1.y, r3, r3.x, c32
mul r3.xyz, r3.z, c44
mad r3.xyz, r1.x, c43, r3
mad r3.xyz, r3.w, c42, r3
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
max r8.xyz, r3, c32.z
frc r3.w, r1.y
add_pp r1.x, r4, c40.z
add r4.x, r1.y, -r3.w
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
mul r1.y, r3.w, c41.z
add r1.x, r1, r4
mul r1.x, r1, c41.y
add r3.w, -r1.x, -r1.y
rcp r3.y, r1.y
add r3.x, r3.w, c32.w
mul r1.y, r4.z, r3.x
mul r4.x, r1.y, r3.y
mul r1.y, r4.z, r1.x
mul r4.y, r3, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r4.w, r1.y, -r3
exp_pp r1.y, -r4.w
mad_pp r1.x, r1, r1.y, c32.y
mul_pp r1.y, r1.x, c40.w
abs_pp r1.x, r0.w
mul r5.w, r1.y, c41.x
frc r7.w, r5
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r1.y, r1, -r3.w
exp_pp r3.w, -r1.y
mad_pp r1.x, r1, r3.w, c32.y
mul r3.xyz, r4.z, c44
mad r3.xyz, r4.y, c43, r3
mad r3.xyz, r4.x, c42, r3
max r3.xyz, r3, c32.z
add r4.xyz, r8, -r3
add_pp r4.w, r4, c40.z
add r5.w, r5, -r7
mad r3.xyz, r0.x, r4, r3
mul_pp r4.w, r4, c39.x
cmp_pp r1.w, -r1, c32, c32.z
mad_pp r1.w, r1, c37, r4
add r1.w, r1, r5
mul r4.w, r1, c41.y
mul r5.w, r7, c41.z
mul_pp r1.x, r1, c40.w
mul r1.w, r1.x, c41.x
add_pp r1.x, r1.y, c40.z
frc r3.w, r1
add r1.y, r1.w, -r3.w
add r7.w, -r4, -r5
mul r8.x, r1.z, r4.w
rcp r4.w, r5.w
mul r5.w, r4, r8.x
mul r1.w, r3, c41.z
mul_pp r1.x, r1, c39
cmp_pp r0.w, -r0, c32, c32.z
mad_pp r0.w, r0, c37, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c41.y
add r1.x, -r0.w, -r1.w
add r1.y, r7.w, c32.w
add r3.w, r1.x, c32
mul r7.w, r1.z, r1.y
mul r1.xyz, r1.z, c44
mul r4.w, r7, r4
mad r1.xyz, r5.w, c43, r1
mad r1.xyz, r4.w, c42, r1
mul r4.w, r0.z, r0
mul r3.w, r0.z, r3
rcp r0.w, r1.w
mul r8.xyz, r0.z, c44
mul r0.z, r0.w, r4.w
mad r8.xyz, r0.z, c43, r8
mul r0.z, r3.w, r0.w
mad r8.xyz, r0.z, c42, r8
max r1.xyz, r1, c32.z
max r8.xyz, r8, c32.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r4.xyz, r1, -r3
add r7.xyz, r7, -r5
mad r1.xyz, r0.y, r7, r5
mad r3.xyz, r0.y, r4, r3
endif
mov r0.x, c4.w
mul r0.x, c33.y, r0
if_gt r6.w, r0.x
texldl r0.xyz, r6.xyzz, s5
else
mov r0.xyz, c32.z
endif
mul r3.xyz, r3, r2.w
mad r0.xyz, r0, r3, r2
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r2.xyz, r3.y, c38
mad r2.xyz, r3.x, c37, r2
mad r2.xyz, r3.z, c36, r2
add r1.w, r2.x, r2.y
mul_pp r0.x, r0, r1.z
add r0.z, r2, r1.w
rcp r1.z, r0.z
mul_pp r0.z, r1.y, c39.x
mul r1.zw, r2.xyxy, r1.z
mul r1.y, r1.z, c35.w
frc r1.z, r1.y
add r0.z, r1.x, -r0
mul r0.w, r0, c39.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r1.y, r1, -r1.z
min r1.x, r1.y, c35.w
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
add r1.y, r1.x, c36.w
cmp r0.w, r1.y, c32, c32.z
mad r0.z, r0, c40.x, c40.y
mul_pp r1.y, r0.w, c37.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.y
mul r1.x, r1.w, c39.z
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c34.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c39.x
frc r1.y, r1.x
add r1.x, r1, -r1.y
add r0.x, r0, -r0.z
min r1.x, r1, c39.w
mad r0.z, r0.x, c39.y, r1.x
add_pp r0.x, r0.y, c38.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c32, c32.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r2.y

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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 4 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 3 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 6 [_TexBackground] 2D
SetTexture 2 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 5 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[44] = { program.local[0..31],
		{ 1, 0, 2, -1 },
		{ -1000000, 0.995, 1000000, 0.1 },
		{ 0.75, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625, 1024 },
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
TEMP R17;
TEMP R18;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R9, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[5];
MOVR  R3.x, c[33];
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].z, -R0;
MOVR  R0.z, c[32].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[9].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[32].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.z, R2, R1;
MOVR  R0, c[13];
MULR  R3.w, R3.z, R3.z;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.w, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.z, R1;
MOVR  R0.x, c[33];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.z, R0.y;
MOVR  R0.y, c[33].x;
MOVXC RC.y, R2;
MOVXC RC.z, R2.w;
MOVR  R2, c[26];
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.z, R0.z;
MOVR  R0.z, c[33].x;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[19];
SGER  H0.x, c[32].y, R0;
ADDR  R2, -R2, c[22];
MADR  R6, H0.x, R2, c[26];
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R5, H0.x, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R4, H0.x, R0, c[24];
MOVR  R2, c[27];
ADDR  R2, -R2, c[23];
MADR  R7, H0.x, R2, c[27];
MOVR  R0.yzw, c[32].x;
MOVR  R0.x, R9.w;
DP4R  R1.w, R0, R7;
DP4R  R1.y, R0, R5;
DP4R  R1.z, R0, R6;
DP4R  R1.x, R0, R4;
DP4R  R0.w, R7, R7;
MOVR  R3.yzw, c[32].y;
MOVR  R3.x, R9;
DP4R  R9.x, R7, R3;
MOVR  R2.yzw, c[32].y;
MOVR  R2.x, R9.y;
DP4R  R9.y, R7, R2;
DP4R  R0.y, R5, R5;
DP4R  R0.z, R6, R6;
DP4R  R0.x, R4, R4;
MADR  R0, R1, R0, -R0;
ADDR  R0, R0, c[32].x;
MULR  R1.x, R0, R0.y;
MULR  R8.z, R1.x, R0;
MOVR  R1.yzw, c[32].y;
MOVR  R1.x, R9.z;
DP4R  R9.z, R7, R1;
DP4R  R7.x, R6, R3;
DP4R  R7.z, R6, R1;
DP4R  R7.y, R6, R2;
MADR  R6.xyz, R0.z, R9, R7;
DP4R  R7.x, R5, R3;
DP4R  R3.x, R4, R3;
DP4R  R7.z, R5, R1;
DP4R  R7.y, R5, R2;
DP4R  R3.z, R4, R1;
MULR  R1.w, R8.z, R0;
DP4R  R3.y, R4, R2;
MADR  R5.xyz, R0.y, R6, R7;
ADDR  R0.zw, fragment.texcoord[0].xyxy, c[30].xyxz;
MADR  R1.xyz, R0.x, R5, R3;
ADDR  R0.xy, R0.zwzw, c[30].zyzw;
ADDR  R2.xy, R0, -c[30].xzzw;
ADDR  R18.xy, R2, -c[30].zyzw;
TEX   R0.x, R0, texture[2], 2D;
TEX   R2.x, R2, texture[2], 2D;
ADDR  R0.y, R2.x, -R0.x;
TEX   R2.x, fragment.texcoord[0], texture[2], 2D;
TEX   R3.x, R0.zwzw, texture[2], 2D;
MULR  R2.zw, R18.xyxy, c[31].xyxy;
FRCR  R0.zw, R2;
MADR  R0.x, R0.z, R0.y, R0;
ADDR  R2.y, R3.x, -R2.x;
MADR  R0.y, R0.z, R2, R2.x;
ADDR  R2.x, R0, -R0.y;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[4].w;
TEX   R0.x, fragment.texcoord[0], texture[1], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[4];
MADR  R0.y, R0.w, R2.x, R0;
MULR  R8.w, R0.z, R0.x;
ADDR  R0.x, R8.w, -R0.y;
SGTRC HC.x, |R0|, c[28];
IF    NE.x;
MOVR  R3.x, c[33];
MOVR  R3.z, c[33].x;
MOVR  R3.w, c[33].x;
MOVR  R3.y, c[33].x;
MOVR  R10.x, c[0].w;
MOVR  R10.z, c[2].w;
MOVR  R10.y, c[1].w;
MULR  R9.xyz, R10, c[9].x;
ADDR  R5.xyz, R9, -c[5];
DP3R  R7.x, R5, R5;
MOVR  R12.w, c[32].x;
MULR  R2.xy, R18, c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R2, c[32].z, -R0;
MOVR  R0.z, c[32].w;
DP3R  R0.w, R0, R0;
RSQR  R4.w, R0.w;
MULR  R0.xyz, R4.w, R0;
MOVR  R0.w, c[32].y;
DP4R  R4.z, R0, c[2];
DP4R  R4.y, R0, c[1];
DP4R  R4.x, R0, c[0];
DP3R  R5.w, R4, R5;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
MULR  R8.z, R5.w, R5.w;
ADDR  R2, R8.z, -R0;
SLTR  R6, R8.z, R0;
MOVXC RC.x, R6;
MOVR  R3.x(EQ), R8;
SGERC HC, R8.z, R0.yzxw;
RSQR  R0.x, R2.z;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
ADDR  R3.x(NE.z), -R5.w, R2;
MOVXC RC.z, R6;
MOVR  R3.z(EQ), R8.x;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R3.z(NE.y), -R5.w, R0.x;
MOVXC RC.y, R6;
RSQR  R0.x, R2.w;
MOVR  R3.w(EQ.z), R8.x;
RCPR  R0.x, R0.x;
ADDR  R3.w(NE), -R5, R0.x;
RSQR  R0.x, R2.y;
MOVR  R3.y(EQ), R8.x;
RCPR  R0.x, R0.x;
ADDR  R3.y(NE.x), -R5.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
ADDR  R6, R8.z, -R0;
SLTR  R7, R8.z, R0;
RSQR  R2.y, R6.x;
MOVR  R2.x, c[33].z;
MOVXC RC.x, R7;
MOVR  R2.x(EQ), R8;
SGERC HC, R8.z, R0.yzxw;
RCPR  R2.y, R2.y;
ADDR  R2.x(NE.z), -R5.w, -R2.y;
RSQR  R0.x, R6.z;
MOVR  R2.y, c[33].z;
MOVR  R0.w, c[33].z;
MOVXC RC.z, R7;
MOVR  R0.w(EQ.z), R8.x;
RCPR  R0.x, R0.x;
ADDR  R0.w(NE.y), -R5, -R0.x;
MOVXC RC.y, R7;
RSQR  R0.x, R6.w;
MULR  R7.xyz, R4.zxyw, c[12].yzxw;
MADR  R7.xyz, R4.yzxw, c[12].zxyw, -R7;
MOVR  R2.y(EQ), R8.x;
MOVR  R2.z, c[33];
MOVXC RC.z, R7.w;
MOVR  R2.z(EQ), R8.x;
RCPR  R0.x, R0.x;
ADDR  R2.z(NE.w), -R5.w, -R0.x;
RSQR  R0.x, R6.y;
RCPR  R0.x, R0.x;
ADDR  R2.y(NE.x), -R5.w, -R0.x;
MOVR  R0.xyz, c[5];
MADR  R0.xyz, R10, c[9].x, -R0;
DP3R  R2.w, R0, R4;
MOVR  R5.w, c[18].x;
DP3R  R7.w, R0, R0;
ADDR  R5.w, R5, c[7].x;
MADR  R6.x, -R5.w, R5.w, R7.w;
MULR  R6.w, R2, R2;
ADDR  R6.y, R6.w, -R6.x;
RSQR  R6.y, R6.y;
MOVR  R5.w, c[33].z;
SLTRC HC.x, R6.w, R6;
MOVR  R5.w(EQ.x), R8.x;
SGERC HC.x, R6.w, R6;
RCPR  R6.y, R6.y;
ADDR  R5.w(NE.x), -R2, -R6.y;
MOVXC RC.x, R5.w;
MULR  R6.xyz, R0.zxyw, c[12].yzxw;
MADR  R6.xyz, R0.yzxw, c[12].zxyw, -R6;
DP3R  R0.x, R0, c[12];
SLER  H0.x, R0, c[32].y;
DP3R  R8.z, R6, R6;
DP3R  R6.x, R6, R7;
DP3R  R6.z, R7, R7;
MADR  R6.y, -c[7].x, c[7].x, R8.z;
MULR  R7.y, R6.z, R6;
MULR  R7.x, R6, R6;
ADDR  R6.y, R7.x, -R7;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
ADDR  R0.y, -R6.x, R6;
SGTR  H0.y, R7.x, R7;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVR  R5.w(LT.x), c[33].z;
MOVXC RC.x, H0;
RCPR  R6.z, R6.z;
MOVR  R0.z, c[33].x;
MULR  R0.z(NE.x), R6, R0.y;
ADDR  R0.y, -R6.x, -R6;
MOVR  R0.x, c[33].z;
MULR  R0.x(NE), R0.y, R6.z;
MOVR  R0.y, R0.z;
MOVR  R18.zw, R0.xyxy;
MADR  R0.xyz, R4, R0.x, R9;
ADDR  R0.xyz, R0, -c[5];
DP3R  R0.x, R0, c[12];
SGTR  H0.y, R0.x, c[32];
MADR  R0.z, -c[8].x, c[8].x, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R18.zw(NE.x), c[33].xyzx;
ADDR  R6.x, R6.w, -R0.z;
RSQR  R6.x, R6.x;
RCPR  R6.x, R6.x;
ADDR  R6.y, -R2.w, -R6.x;
ADDR  R2.w, -R2, R6.x;
MAXR  R6.x, R6.y, c[32].y;
MAXR  R6.y, R2.w, c[32];
MOVR  R2.w, R2.z;
MOVR  R2.z, R0.w;
MOVR  R0.xy, c[32].y;
SLTRC HC.x, R6.w, R0.z;
MOVR  R0.xy(EQ.x), R8;
SGERC HC.x, R6.w, R0.z;
MOVR  R0.xy(NE.x), R6;
MAXR  R9.w, R0.x, c[32].y;
DP4R  R0.z, R2, c[24];
DP4R  R0.w, R3, c[20];
ADDR  R6.x, R0.w, -R0.z;
DP4R  R0.w, R3, c[19];
SGER  H0.y, c[32], R0.w;
MADR  R6.x, H0.y, R6, R0.z;
DP4R  R0.w, R2, c[25];
DP4R  R0.z, R3, c[21];
ADDR  R0.z, R0, -R0.w;
MADR  R6.y, H0, R0.z, R0.w;
RCPR  R0.z, R4.w;
MULR  R4.w, R8, R0.z;
MADR  R5.w, -R4, c[9].x, R5;
MOVR  R0.zw, c[33].xywy;
MULR  R0.w, R0, c[4];
SGER  H0.x, R8.w, R0.w;
MULR  R4.w, R4, c[9].x;
MADR  R0.w, H0.x, R5, R4;
MINR  R4.w, R0.y, R0;
MINR  R0.w, R4, R6.x;
MAXR  R10.w, R9, R0;
MINR  R0.y, R4.w, R6;
MAXR  R11.w, R10, R0.y;
DP4R  R0.y, R2, c[26];
DP4R  R0.x, R3, c[22];
ADDR  R0.x, R0, -R0.y;
MADR  R0.x, H0.y, R0, R0.y;
MINR  R0.x, R4.w, R0;
MAXR  R5.w, R11, R0.x;
ADDR  R6.z, R5.w, -R11.w;
ADDR  R6.xy, R18.wzzw, -R5.w;
RCPR  R0.x, R6.z;
ADDR  R7.zw, R18.xywz, -R11.w;
MULR_SAT R0.y, R0.x, R7.z;
MULR_SAT R0.x, -R6.y, R0;
MULR  R0.w, R0.x, R0.y;
DP3R  R0.x, R4, c[12];
MULR  R0.y, R0.x, c[17].x;
MULR  R0.y, R0, c[32].z;
MULR  R0.x, R0, R0;
MADR  R0.y, c[17].x, c[17].x, R0;
ADDR  R0.y, R0, c[32].x;
POWR  R6.y, R0.y, c[34].y;
ADDR  R0.y, R12.w, c[17].x;
MADR  R4.xyz, R4, R9.w, R5;
MADR  R0.x, R0, c[34], c[34];
RCPR  R6.y, R6.y;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R6;
MULR  R7.xy, R0, c[34].z;
MOVR  R6.y, c[34].w;
MULR  R6.w, R6.y, c[16].x;
MULR  R0.xyz, R0.z, c[15];
ADDR  R11.xyz, R0, R6.w;
MULR  R6.y, R7, R6.w;
MADR  R0.xyz, R0, R7.x, R6.y;
RCPR  R10.x, R11.x;
RCPR  R10.z, R11.z;
RCPR  R10.y, R11.y;
MULR  R12.xyz, R0, R10;
MADR  R0.xyz, R12, -R0.w, R12;
DP3R  R0.w, R4, R4;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R4.x, R0.w, -c[7];
MOVR  R0.w, c[7].x;
ADDR  R0.w, -R0, c[8].x;
RCPR  R0.w, R0.w;
MULR  R5.y, R4.x, R0.w;
MOVR  R4.xyz, c[6];
DP3R  R0.w, R4, c[12];
MADR  R5.x, -R0.w, c[35].y, c[35].y;
TEX   R13.zw, R5, texture[3], 2D;
MULR  R5.xyz, -R11, |R6.z|;
MULR  R0.w, R13, c[16].x;
MADR  R4.xyz, R13.z, -c[15], -R0.w;
MULR  R0.xyz, R10, R0;
RCPR  R6.y, |R6.z|;
POWR  R7.x, c[35].x, R5.x;
POWR  R7.y, c[35].x, R5.y;
POWR  R7.z, c[35].x, R5.z;
TEX   R0.w, c[35].y, texture[4], 2D;
POWR  R4.x, c[35].x, R4.x;
POWR  R4.z, c[35].x, R4.z;
POWR  R4.y, c[35].x, R4.y;
MULR  R4.xyz, R4, c[11];
MULR  R13.xyz, R4, R0.w;
ADDR  R14.xyz, R13, -R13;
MULR  R4.xyz, R14, R6.y;
MADR  R4.xyz, R11, R13, R4;
MADR  R4.xyz, -R7, R4, R4;
MULR  R17.xyz, R0, R4;
DP4R  R0.x, R2, c[27];
DP4R  R0.y, R3, c[23];
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R4.w, R0;
MAXR  R0.w, R5, R0.x;
ADDR  R2.w, R0, -R5;
MULR  R3.xyz, -R11, |R2.w|;
ADDR  R4.xy, R18.wzzw, -R0.w;
RCPR  R0.x, R2.w;
MULR_SAT R0.y, R0.x, R6.x;
MULR_SAT R0.x, -R4.y, R0;
RCPR  R2.x, |R2.w|;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R12, -R0.x, R12;
MULR  R2.xyz, R14, R2.x;
MOVR  R5, c[27];
ADDR  R5, -R5, c[23];
MULR  R0.xyz, R10, R0;
ADDR  R0.w, R4, -R0;
MADR  R5, H0.y, R5, c[27];
POWR  R8.x, c[35].x, R3.x;
POWR  R8.y, c[35].x, R3.y;
POWR  R8.z, c[35].x, R3.z;
MULR  R3.xyz, |R0.w|, -R11;
MADR  R2.xyz, R11, R13, R2;
MADR  R2.xyz, -R8, R2, R2;
MULR  R16.xyz, R0, R2;
RCPR  R0.x, R0.w;
ADDR  R0.z, R4.w, -R18;
MULR_SAT R0.y, R0.x, R4.x;
MULR_SAT R0.x, R0.z, R0;
RCPR  R2.x, |R0.w|;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R12, R12;
MULR  R2.xyz, R14, R2.x;
MOVR  R4.yzw, c[32].x;
POWR  R9.x, c[35].x, R3.x;
POWR  R9.y, c[35].x, R3.y;
POWR  R9.z, c[35].x, R3.z;
MADR  R2.xyz, R11, R13, R2;
MADR  R2.xyz, -R9, R2, R2;
MULR  R0.xyz, R0, R10;
MULR  R15.xyz, R0, R2;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R3, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R2, H0.y, R0, c[24];
TEX   R0.w, R18, texture[0], 2D;
MOVR  R4.x, R0.w;
DP4R  R6.x, R4, R2;
DP4R  R2.x, R2, R2;
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R0, H0.y, R0, c[26];
DP4R  R2.y, R3, R3;
DP4R  R6.y, R4, R3;
DP4R  R6.z, R4, R0;
DP4R  R6.w, R4, R5;
DP4R  R2.w, R5, R5;
DP4R  R2.z, R0, R0;
MADR  R0, R6, R2, -R2;
ADDR  R0, R0, c[32].x;
ADDR  R2.w, R11, -R10;
RCPR  R3.x, R2.w;
MADR  R2.xyz, R15, R0.w, R16;
MADR  R2.xyz, R2, R0.z, R17;
ADDR  R0.zw, R18.xywz, -R10.w;
MULR_SAT R3.y, -R7.w, R3.x;
MULR_SAT R0.z, R3.x, R0;
MULR  R0.z, R3.y, R0;
MULR  R3.xyz, -R11, |R2.w|;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R2.w|;
MULR  R5.xyz, R14, R0.z;
POWR  R3.x, c[35].x, R3.x;
POWR  R3.y, c[35].x, R3.y;
POWR  R3.z, c[35].x, R3.z;
MADR  R5.xyz, R11, R13, R5;
MADR  R5.xyz, -R3, R5, R5;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R5;
MADR  R2.xyz, R2, R0.y, R4;
ADDR  R0.y, R10.w, -R9.w;
MULR  R5.xyz, -R11, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R2.w, R18, -R9;
MULR_SAT R0.z, R0, R2.w;
MULR  R0.z, R0.w, R0;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R0.y|;
MULR  R6.xyz, R14, R0.z;
POWR  R5.x, c[35].x, R5.x;
POWR  R5.y, c[35].x, R5.y;
POWR  R5.z, c[35].x, R5.z;
MADR  R6.xyz, R11, R13, R6;
MADR  R6.xyz, -R5, R6, R6;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R6;
MADR  R0.xyz, R2, R0.x, R4;
MULR  R2.xyz, R0.y, c[38];
MADR  R2.xyz, R0.x, c[37], R2;
MADR  R0.xyz, R0.z, c[36], R2;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].z;
SGER  H0.x, R0, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[34].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[37].w;
MULR  R0.z, R0.w, c[39].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[36].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[39].y;
MADR  R0.x, R0, c[38].w, R0.z;
MADR  H0.z, R0.x, c[39], R12.w;
MADH  H0.x, H0, c[32].z, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.z, H0, c[40].x;
FLRR  R0.x, R0.z;
ADDH  H0.y, H0, c[36].w;
FRCR  R0.z, R0;
MULR  R0.z, R0, c[40];
RCPR  R2.x, R0.z;
MULH  H0.y, H0, c[37].w;
SGEH  H0.x, c[32].y, H0;
MADH  H0.x, H0, c[35].w, H0.y;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].y;
ADDR  R0.w, -R0.x, -R0.z;
MADR  R0.w, R0, R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R2.y, R2.x, R0.x;
MULR  R0.xyz, R0.y, c[43];
MULR  R0.w, R0, R2.x;
MADR  R0.xyz, R2.y, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R0.xyz, R0, c[32].y;
ADDR  R2.xyz, -R0, c[32].xyyw;
MADR  R0.xyz, R2, c[29].x, R0;
MULR  R2.xyz, R3, R5;
MULR  R2.xyz, R7, R2;
MULR  R2.xyz, R8, R2;
MULR  R2.xyz, R9, R2;
MULR  R3.xyz, R2.y, c[38];
MADR  R3.xyz, R2.x, c[37], R3;
MADR  R2.xyz, R2.z, c[36], R3;
ADDR  R0.w, R2.x, R2.y;
ADDR  R0.w, R2.z, R0;
RCPR  R0.w, R0.w;
MULR  R2.zw, R2.xyxy, R0.w;
MULR  R0.w, R2.z, c[35].z;
FLRR  R0.w, R0;
MINR  R0.w, R0, c[35].z;
SGER  H0.x, R0.w, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.w, R0, -H0.y;
MULR  R2.x, R0.w, c[34].w;
FLRR  H0.y, R2.x;
MULH  H0.z, H0.y, c[37].w;
MULR  R2.x, R2.w, c[39];
FLRR  R2.x, R2;
ADDH  H0.y, H0, -c[36].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.w, R0, -H0.z;
MINR  R2.x, R2, c[39].y;
MADR  R0.w, R0, c[38], R2.x;
MADR  H0.z, R0.w, c[39], R12.w;
MADH  H0.x, H0, c[32].z, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
FLRR  R2.x, R0.w;
FRCR  R0.w, R0;
MULR  R2.z, R0.w, c[40];
ADDH  H0.y, H0, c[36].w;
RCPR  R2.w, R2.z;
MULH  H0.y, H0, c[37].w;
SGEH  H0.x, c[32].y, H0;
MADH  H0.x, H0, c[35].w, H0.y;
ADDR  R2.x, H0, R2;
MULR  R2.x, R2, c[40].y;
ADDR  R0.w, -R2.x, -R2.z;
MADR  R0.w, R0, R2.y, R2.y;
MULR  R2.x, R2, R2.y;
MULR  R3.x, R2.w, R2;
MULR  R2.xyz, R2.y, c[43];
MADR  R2.xyz, R3.x, c[42], R2;
MULR  R0.w, R0, R2;
MADR  R2.xyz, R0.w, c[41], R2;
MAXR  R2.xyz, R2, c[32].y;
MADR  R2.xyz, -R2, c[29].x, R2;
ELSE;
ADDR  R6.xy, R18, c[30].xzzw;
ADDR  R0.xy, R6, c[30].zyzw;
TEX   R3, R0, texture[5], 2D;
ADDR  R7.xy, R0, -c[30].xzzw;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R3|, H0;
MADH  H0.y, H0, c[39].w, -c[39].w;
MULR  R0.z, H0.y, c[40].x;
FRCR  R0.w, R0.z;
MULR  R2.x, R0.w, c[40].z;
ADDH  H0.x, H0, c[36].w;
MULH  H0.z, H0.x, c[37].w;
SGEH  H0.xy, c[32].y, R3.ywzw;
TEX   R4, R7, texture[5], 2D;
MADH  H0.x, H0, c[35].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[40].y;
ADDR  R0.w, -R0.z, -R2.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[36].w;
RCPR  R0.x, R2.x;
MULR  R0.y, R0.z, R3.x;
MADR  R0.w, R0, R3.x, R3.x;
MULR  R0.w, R0, R0.x;
MULR  R2.x, R0, R0.y;
MULR  R0.xyz, R3.x, c[43];
MADR  R0.xyz, R2.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
MAXR  R2.xyz, R0, c[32].y;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[32].y, R4.xyyw;
MULH  H0.x, H0, c[37].w;
MULR  R0.z, R0.x, c[40];
FLRR  R0.y, R0.w;
MADH  H0.x, H0.z, c[35].w, H0;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[40].y;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R4.x, R4.x;
RCPR  R0.w, R0.z;
MULR  R2.w, R0.y, R0;
MULR  R3.x, R0, R4;
MULR  R0.w, R0, R3.x;
MULR  R0.xyz, R4.x, c[43];
MADR  R5.xyz, R0.w, c[42], R0;
TEX   R0, R6, texture[5], 2D;
MADR  R5.xyz, R2.w, c[41], R5;
LG2H  H0.x, |R0.y|;
MAXR  R5.xyz, R5, c[32].y;
ADDR  R6.xyz, R2, -R5;
TEX   R2, R18, texture[5], 2D;
ADDR  R18.xy, R7, -c[30].zyzw;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R4.x, H0.z, c[40];
FRCR  R4.y, R4.x;
MULR  R3.xy, R18, c[31];
FRCR  R3.xy, R3;
MADR  R5.xyz, R3.x, R6, R5;
ADDH  H0.x, H0, c[36].w;
SGEH  H1.xy, c[32].y, R0.ywzw;
MULH  H0.x, H0, c[37].w;
SGEH  H1.zw, c[32].y, R2.xyyw;
FLRR  R4.x, R4;
MADH  H0.x, H1, c[35].w, H0;
ADDR  R0.y, H0.x, R4.x;
LG2H  H0.x, |R2.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.y|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R4.x, R0.y, c[40].y;
MULR  R4.y, R4, c[40].z;
ADDR  R0.y, -R4.x, -R4;
RCPR  R4.y, R4.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R4.x, R4, R0;
MULR  R0.y, R0, R4;
MULR  R4.x, R4.y, R4;
MULR  R6.xyz, R0.x, c[43];
MADR  R6.xyz, R4.x, c[42], R6;
MADH  H0.z, H0, c[39].w, -c[39].w;
MADR  R6.xyz, R0.y, c[41], R6;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MADH  H0.x, H1.z, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R2.y, R0.x, c[40];
MULR  R0.y, R0, c[40].z;
ADDR  R0.x, -R2.y, -R0.y;
MULR  R2.y, R2, R2.x;
MADR  R0.x, R0, R2, R2;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.y, R0, R2;
MULR  R7.xyz, R2.x, c[43];
MADR  R7.xyz, R0.y, c[42], R7;
MADR  R7.xyz, R0.x, c[41], R7;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[32].y;
MAXR  R6.xyz, R6, c[32].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R3.x, R6, R7;
MADH  H0.x, H1.y, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R2.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R2.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R0.y, R0, c[40].z;
MULR  R0.x, R0, c[40].y;
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R2.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[43];
MADR  R0.xyz, R2.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R7.xyz, R0, c[32].y;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MULR  R0.z, R0.y, c[40];
RCPR  R2.x, R0.z;
MADH  H0.x, H1.w, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].y;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R2.z, R0, R2.z;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULR  R0.w, R0.y, R2.x;
MULR  R2.y, R2.z, R0.x;
MULR  R0.xyz, R2.z, c[43];
MULR  R2.x, R2, R2.y;
MADR  R0.xyz, R2.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R0.xyz, R0, c[32].y;
ADDR  R2.xyz, R7, -R0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
MULH  H0.x, H0, c[37].w;
MADH  H0.z, H0.w, c[35].w, H0.x;
FLRR  R2.w, R0;
ADDR  R2.w, H0.z, R2;
MULR  R4.x, R2.w, c[40].y;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULR  R4.y, R0.w, c[40].z;
MULH  H0.z, |R3.w|, H0;
ADDR  R4.w, -R4.x, -R4.y;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
FRCR  R2.w, R0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MADR  R4.w, R4.z, R4, R4.z;
RCPR  R5.w, R4.y;
MULR  R6.w, R4.z, R4.x;
MADR  R2.xyz, R3.x, R2, R0;
MULR  R2.w, R2, c[40].z;
MULR  R4.w, R4, R5;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[35].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[40].y;
ADDR  R3.w, -R0, -R2;
MULR  R4.xyz, R4.z, c[43];
MULR  R6.w, R5, R6;
MADR  R4.xyz, R6.w, c[42], R4;
MADR  R4.xyz, R4.w, c[41], R4;
MULR  R4.w, R3.z, R0;
RCPR  R0.w, R2.w;
MAXR  R4.xyz, R4, c[32].y;
MULR  R2.w, R0, R4;
MADR  R3.w, R3.z, R3, R3.z;
MULR  R7.xyz, R3.z, c[43];
MADR  R7.xyz, R2.w, c[42], R7;
MULR  R0.w, R3, R0;
MADR  R7.xyz, R0.w, c[41], R7;
MAXR  R7.xyz, R7, c[32].y;
ADDR  R7.xyz, R7, -R4;
MADR  R0.xyz, R3.x, R7, R4;
ADDR  R4.xyz, R0, -R2;
MADR  R0.xyz, R3.y, R5, R6;
MADR  R2.xyz, R3.y, R4, R2;
ENDIF;
MOVR  R0.w, c[33].y;
MULR  R0.w, R0, c[4];
SGTRC HC.x, R8.w, R0.w;
IF    NE.x;
TEX   R3.xyz, R18, texture[6], 2D;
ELSE;
MOVR  R3.xyz, c[32].y;
ENDIF;
MULR  R2.xyz, R2, R1.w;
MADR  R1.xyz, R3, R2, R1;
ADDR  R0.xyz, R1, R0;
MULR  R1.xyz, R0.y, c[38];
MADR  R1.xyz, R0.x, c[37], R1;
MADR  R0.xyz, R0.z, c[36], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].z;
SGER  H0.x, R0, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[34].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[36].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[37].w;
MULR  R1.xyz, R2.y, c[38];
MADR  R1.xyz, R2.x, c[37], R1;
MADR  R1.xyz, R2.z, c[36], R1;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[35];
MULR  R0.w, R0, c[39].x;
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[39].x;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[32].z, H0.z;
MINR  R0.z, R0, c[35];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[35].w;
MULH  H0.y, H0.z, c[35].w;
MINR  R0.w, R0, c[39].y;
MADR  R0.w, R0.x, c[38], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[32];
MADR  H0.y, R0.w, c[39].z, R0.x;
MULR  R0.w, R0.z, c[34];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[37].w;
ADDH  H0.x, H0, -c[36].w;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[39];
MADR  R0.y, R0.z, c[38].w, R0;
MADR  H0.z, R0.y, c[39], R0.x;
MADH  H0.x, H0.y, c[32].z, H0;
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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 4 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 3 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 6 [_TexBackground] 2D
SetTexture 2 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 5 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c32, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c33, -1000000.00000000, 0.99500000, 1000000.00000000, 0.10000000
def c34, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c35, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c36, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c37, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c38, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c39, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c40, 0.00097656, 1.00000000, 15.00000000, 1024.00000000
def c41, 0.00390625, 0.00476190, 0.63999999, 0
def c42, 0.07530000, -0.25430000, 1.18920004, 0
def c43, 2.56509995, -1.16649997, -0.39860001, 0
def c44, -1.02170002, 1.97770000, 0.04390000, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c32.x, c32.y
mov r3, c23
texldl r9, v0, s0
add r3, -c27, r3
mov r0.z, c32.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c32.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c7
mov r0.y, c7.x
add r0.y, c13, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c9.x
add r2.xyz, r2, -c5
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c13, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c32.w, c32.z
cmp r0.x, r0, r1.w, c33
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c32.w, c32.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c33.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c7.x
add r1.y, c13.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c7.x
add r0.w, c13.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c32, c32.z
cmp r1.z, r1, r1.w, c33.x
cmp r0.w, -r0, r1.z, r2.x
cmp_pp r0.z, r1.x, c32.w, c32
cmp r1.x, r1, r1.w, c33
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c19
cmp r6.x, -r0, c32.w, c32.z
mad r7, r6.x, r3, c27
mov r1, c21
add r1, -c25, r1
mov r0, c20
add r0, -c24, r0
mad r4, r6.x, r0, c24
mov r2, c22
mad r5, r6.x, r1, c25
add r2, -c26, r2
mad r6, r6.x, r2, c26
mov r0.yzw, c32.w
mov r0.x, r9.w
dp4 r1.w, r7, r0
dp4 r1.x, r4, r0
dp4 r1.y, r5, r0
dp4 r1.z, r6, r0
dp4 r0.w, r7, r7
mov r3.yzw, c32.z
mov r3.x, r9
dp4 r9.x, r7, r3
mov r2.yzw, c32.z
mov r2.x, r9.y
dp4 r9.y, r7, r2
dp4 r0.x, r4, r4
add r1, r1, c32.y
dp4 r0.y, r5, r5
dp4 r0.z, r6, r6
mad r0, r0, r1, c32.w
mov r1.yzw, c32.z
mov r1.x, r9.z
dp4 r9.z, r7, r1
dp4 r7.x, r6, r3
dp4 r7.z, r6, r1
dp4 r7.y, r6, r2
mad r6.xyz, r0.z, r9, r7
dp4 r7.x, r5, r3
dp4 r3.x, r4, r3
dp4 r3.z, r4, r1
dp4 r7.z, r5, r1
dp4 r3.y, r4, r2
dp4 r7.y, r5, r2
mad r5.xyz, r0.y, r6, r7
mad r2.xyz, r0.x, r5, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r3.xy, v0, c30.xzzw
add r0.xy, r3, c30.zyzw
add r4.xy, r0, -c30.xzzw
mov r0.z, v0.w
mov r4.z, v0.w
mov r3.z, v0.w
add r7.xy, r4, -c30.zyzw
mul r1.zw, r7.xyxy, c31.xyxy
texldl r0.x, r0.xyzz, s2
texldl r1.x, r4.xyzz, s2
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s2
texldl r3.x, r3.xyzz, s2
add r0.z, r3.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c4.w, -c4.z
rcp r0.y, r0.x
mul r0.y, r0, c4.w
texldl r0.x, v0, s1
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c4.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r2.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c28.x
mad r0.xy, r7, c32.x, c32.y
mul r0.xy, r0, c4
mov r0.z, c32.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c32.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.x, c7
mov r1.y, c7.x
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r5.xyz, r3, c9.x
add r6.xyz, r5, -c5
dp3 r4.x, r6, r0
dp3 r4.y, r6, r6
add r1.y, c14, r1
mad r1.z, -r1.y, r1.y, r4.y
mad r1.w, r4.x, r4.x, -r1.z
rsq r3.x, r1.w
add r1.x, c14, r1
mad r1.x, -r1, r1, r4.y
mad r1.x, r4, r4, -r1
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r4.x, -r1.y
cmp_pp r1.y, r1.x, c32.w, c32.z
cmp r1.x, r1, r8, c33.z
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c32.w, c32.z
rcp r3.x, r3.x
cmp r1.w, r1, r8.x, c33.z
add r3.x, -r4, -r3
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r3.x, c14.w, r1.z
mad r1.w, -r1, r1, r4.y
mad r1.z, r4.x, r4.x, -r1.w
mad r3.x, -r3, r3, r4.y
mad r3.y, r4.x, r4.x, -r3.x
rsq r1.w, r1.z
rcp r1.w, r1.w
add r3.x, -r4, -r1.w
cmp_pp r1.w, r1.z, c32, c32.z
cmp r1.z, r1, r8.x, c33
cmp r1.z, -r1.w, r1, r3.x
rsq r3.z, r3.y
rcp r3.z, r3.z
cmp r3.x, r3.y, r8, c33.z
add r3.z, -r4.x, -r3
cmp_pp r1.w, r3.y, c32, c32.z
cmp r1.w, -r1, r3.x, r3.z
mov r3.x, c7
add r3.y, c13.x, r3.x
mov r3.x, c7
add r3.z, c13.y, r3.x
mad r3.y, -r3, r3, r4
mad r3.x, r4, r4, -r3.y
mad r3.z, -r3, r3, r4.y
mad r3.w, r4.x, r4.x, -r3.z
rsq r3.y, r3.x
rcp r3.y, r3.y
add r3.z, -r4.x, r3.y
cmp_pp r3.y, r3.x, c32.w, c32.z
cmp r3.x, r3, r8, c33
cmp r3.x, -r3.y, r3, r3.z
rsq r4.w, r3.w
cmp_pp r3.y, r3.w, c32.w, c32.z
rcp r4.w, r4.w
dp4 r4.z, r1, c24
dp4 r8.z, r1, c25
cmp r3.w, r3, r8.x, c33.x
add r4.w, -r4.x, r4
cmp r3.y, -r3, r3.w, r4.w
mov r3.z, c7.x
add r3.w, c13, r3.z
mad r3.w, -r3, r3, r4.y
mad r5.w, r4.x, r4.x, -r3
rsq r3.w, r5.w
rcp r4.w, r3.w
mov r3.z, c7.x
add r3.z, c13, r3
mad r3.z, -r3, r3, r4.y
mad r3.z, r4.x, r4.x, -r3
add r6.w, -r4.x, r4
rsq r3.w, r3.z
rcp r4.w, r3.w
cmp_pp r3.w, r5, c32, c32.z
cmp r5.w, r5, r8.x, c33.x
cmp r3.w, -r3, r5, r6
add r5.w, -r4.x, r4
cmp_pp r4.w, r3.z, c32, c32.z
cmp r3.z, r3, r8.x, c33.x
cmp r3.z, -r4.w, r3, r5.w
dp4 r4.w, r3, c20
add r6.w, r4, -r4.z
dp4 r5.w, r3, c19
cmp r12.w, -r5, c32, c32.z
mad r4.z, r12.w, r6.w, r4
dp4 r6.w, r3, c21
add r8.w, r6, -r8.z
mov r4.w, c7.x
add r4.w, c18.x, r4
mad r4.w, -r4, r4, r4.y
mad r4.w, r4.x, r4.x, -r4
rsq r5.w, r4.w
rcp r5.w, r5.w
add r6.w, -r4.x, -r5
cmp_pp r5.w, r4, c32, c32.z
cmp r4.w, r4, r8.x, c33.z
cmp r4.w, -r5, r4, r6
rcp r0.w, r0.w
mul r5.w, r7, r0
cmp r6.w, r4, r4, c33.z
mad r6.w, -r5, c9.x, r6
mad r4.y, -c8.x, c8.x, r4
mad r4.w, r4.x, r4.x, -r4.y
rsq r4.y, r4.w
mov r0.w, c4
mad r0.w, c33.y, -r0, r7
mad r8.z, r12.w, r8.w, r8
cmp r8.xy, r4.w, r8, c32.z
rcp r4.y, r4.y
cmp r0.w, r0, c32, c32.z
mul r5.w, r5, c9.x
mad r5.w, r0, r6, r5
add r0.w, -r4.x, -r4.y
add r4.y, -r4.x, r4
max r4.x, r0.w, c32.z
cmp_pp r0.w, r4, c32, c32.z
max r4.y, r4, c32.z
cmp r4.xy, -r0.w, r8, r4
min r5.w, r4.y, r5
max r8.w, r4.x, c32.z
dp4 r4.x, r1, c26
dp4 r1.y, r1, c27
min r0.w, r5, r4.z
max r9.w, r8, r0
min r4.y, r5.w, r8.z
dp4 r0.w, r3, c22
add r0.w, r0, -r4.x
dp4 r1.x, r3, c23
add r1.x, r1, -r1.y
mad r0.w, r12, r0, r4.x
max r10.w, r9, r4.y
mad r1.x, r12.w, r1, r1.y
min r0.w, r5, r0
max r11.w, r10, r0
min r1.x, r5.w, r1
max r6.w, r11, r1.x
add r10.x, r6.w, -r11.w
mov r0.w, c16.x
mov r1.xyz, c15
mad r4.xyz, r0, r8.w, r6
mul r1.w, c34, r0
dp3 r0.w, r4, r4
mul r1.xyz, c33.w, r1
add r11.xyz, r1, r1.w
abs r3.x, r10
mul r8.xyz, -r11, r3.x
pow r3, c35.x, r8.x
mov r8.x, r3
rcp r10.z, r11.z
rcp r10.y, r11.y
pow r3, c35.x, r8.y
rsq r0.w, r0.w
rcp r3.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r4.xyz, c12
rcp r3.z, r0.w
dp3 r0.w, c6, r4
add r3.x, r3, -c7
add r0.w, -r0, c32
mul r4.y, r3.x, r3.z
mul r4.x, r0.w, c35.y
mov r4.z, c32
texldl r3.zw, r4.xyzz, s3
mul r0.w, r3, c16.x
pow r4, c35.x, r8.z
mad r9.xyz, r3.z, -c15, -r0.w
mov r8.y, r3
pow r3, c35.x, r9.x
mov r8.z, r4
pow r4, c35.x, r9.y
mov r9.x, r3
pow r3, c35.x, r9.z
mov r9.z, r3
mul r3.xyz, r6.zxyw, c12.yzxw
mad r3.xyz, r6.yzxw, c12.zxyw, -r3
dp3 r0.w, r3, r3
mov r9.y, r4
mul r4.xyz, r9, c11
mul r9.xyz, r0.zxyw, c12.yzxw
mad r9.xyz, r0.yzxw, c12.zxyw, -r9
dp3 r3.w, r3, r9
dp3 r4.w, r9, r9
mad r0.w, -c7.x, c7.x, r0
mul r0.w, r4, r0
mad r3.x, r3.w, r3.w, -r0.w
rsq r3.y, r3.x
rcp r9.x, r3.y
add r3.y, -r3.w, -r9.x
rcp r4.w, r4.w
texldl r0.w, c35.yyzz, s4
mul r13.xyz, r4, r0.w
mul r14.xyz, r11, r13
dp3 r0.w, r6, c12
cmp r0.w, -r0, c32, c32.z
mul r4.xyz, r14, r8
mul r3.y, r3, r4.w
add r3.w, -r3, r9.x
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r3.x
cmp r6.x, -r0.w, c33.z, r3.y
mad r3.xyz, r0, r6.x, r5
add r3.xyz, r3, -c5
dp3 r3.x, r3, c12
mul r3.y, r4.w, r3.w
cmp r6.y, -r0.w, c33.x, r3
rcp r3.y, r10.x
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, r3.x
cmp r18.xy, -r0.w, r6, c33.zxzw
dp3 r3.x, r0, c12
add r0.w, -r18.x, r6
add r3.z, r18.y, -r11.w
mul r0.x, r3, c17
mul r0.x, r0, c32
rcp r10.x, r11.x
add r3.w, r5, -r6
mul_sat r0.w, r0, r3.y
mul_sat r0.y, r3, r3.z
mad r3.z, -r0.w, r0.y, c32.w
abs r0.y, r3.w
mad r0.x, c17, c17, r0
mul r5.xyz, -r11, r0.y
add r3.y, r0.x, c32.w
pow r0, r3.y, c34.y
mad r0.z, r3.x, r3.x, c32.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c32.w, r0.y
mad r4.xyz, r11, r13, -r4
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c34
mul r3.xy, r0, c34.z
pow r0, c35.x, r5.x
mul r0.y, r3, r1.w
mad r1.xyz, r1, r3.x, r0.y
mul r12.xyz, r1, r10
pow r1, c35.x, r5.z
mov r9.x, r0
pow r0, c35.x, r5.y
add r13.w, r11, -r10
abs r0.w, r13
mul r17.xyz, -r11, r0.w
mov r9.z, r1
mov r9.y, r0
mul r3.xyz, r12, r3.z
mul r1.xyz, r10, r3
mul r0.xyz, r9, r14
mul r16.xyz, r1, r4
mad r1.xyz, r11, r13, -r0
add r0.z, r18.y, -r6.w
rcp r0.y, r3.w
add r0.x, r5.w, -r18
mov r5, c23
add r5, -c27, r5
mov r6.yzw, c32.w
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c32.w
mul r0.xyz, r0.x, r12
mul r0.xyz, r0, r10
mul r15.xyz, r0, r1
mov r1, c21
add r1, -c25, r1
mad r3, r12.w, r1, c25
mov r0, c20
add r0, -c24, r0
mad r4, r12.w, r0, c24
texldl r0.w, r7.xyzz, s0
mov r6.x, r0.w
dp4 r0.x, r4, r6
dp4 r4.x, r4, r4
mad r5, r12.w, r5, c27
mov r1, c22
add r1, -c26, r1
mad r1, r12.w, r1, c26
dp4 r0.y, r3, r6
dp4 r4.y, r3, r3
pow r3, c35.x, r17.y
dp4 r0.w, r5, r6
dp4 r0.z, r1, r6
dp4 r4.z, r1, r1
add r0, r0, c32.y
dp4 r4.w, r5, r5
mad r1, r4, r0, c32.w
pow r0, c35.x, r17.x
mad r5.xyz, r15, r1.w, r16
mov r4.x, r0
mov r4.y, r3
rcp r0.z, r13.w
add r0.w, r18.y, -r10
add r0.y, -r18.x, r11.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c32
pow r0, c35.x, r17.z
mov r4.z, r0
mul r3.xyz, r14, r4
mul r0.xyz, r12, r1.w
mad r3.xyz, r11, r13, -r3
mul r0.xyz, r10, r0
mul r0.xyz, r0, r3
mad r5.xyz, r5, r1.z, r0
add r0.w, r10, -r9
abs r0.y, r0.w
mul r6.xyz, -r11, r0.y
rcp r1.z, r0.w
add r0.x, -r18, r10.w
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r6.x
add r3.x, r18.y, -r9.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r6.y
mad r1.z, -r1.w, r0.y, c32.w
mov r6.x, r0
pow r0, c35.x, r6.z
mov r6.z, r0
mov r6.y, r3
mul r0.xyz, r12, r1.z
mul r3.xyz, r14, r6
mul r0.xyz, r10, r0
mad r3.xyz, r11, r13, -r3
mul r15.xyz, r0, r3
add r0.y, r9.w, -r8.w
rcp r1.z, r0.y
add r0.x, -r18, r9.w
abs r0.y, r0
mul r16.xyz, -r11, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r16.x
add r3.x, r18.y, -r8.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r16.y
mad r1.z, -r1.w, r0.y, c32.w
mov r16.x, r0
pow r0, c35.x, r16.z
mov r16.y, r3
mov r16.z, r0
mul r3.xyz, r12, r1.z
mul r0.xyz, r14, r16
mul r3.xyz, r10, r3
mad r0.xyz, r11, r13, -r0
mul r0.xyz, r3, r0
mad r3.xyz, r5, r1.y, r15
mad r0.xyz, r3, r1.x, r0
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r0.w, r0, c39.z
frc r0.z, r0.w
add r0.w, r0, -r0.z
mul_pp r0.z, r1.y, c39.x
mul_pp r0.x, r0, r1.z
add r0.z, r1.x, -r0
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.z
abs_pp r0.z, r0.x
mul r1.xyz, r6, r16
mul r1.xyz, r4, r1
mul r1.xyz, r8, r1
mul r3.xyz, r9, r1
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c32.y
mul r4.xyz, r3.y, c38
mad r4.xyz, r3.x, c37, r4
mad r1.xyz, r3.z, c36, r4
add r3.x, r1, r1.y
add r1.z, r1, r3.x
mul_pp r0.z, r0, c40.w
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r3.x, r1.z, c35.w
mul r0.z, r0, c41.x
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c40
frc r3.y, r3.x
add r0.w, r3.x, -r3.y
min r0.w, r0, c35
add r3.x, r0.w, c36.w
mul r1.w, r1, c39.z
frc r3.y, r1.w
add r1.w, r1, -r3.y
cmp r3.x, r3, c32.w, c32.z
mul_pp r0.z, r0, c39.x
cmp_pp r0.x, -r0, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r3.x, c37.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c41
mul r1.x, r0.w, c34.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c39.x
add r0.w, r0, -r1.z
min r1.w, r1, c39
mad r1.z, r0.w, c39.y, r1.w
add_pp r0.w, r1.x, c38
exp_pp r1.x, r0.w
mad_pp r0.w, -r3.x, c32.x, c32
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c40.x, c40.y
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r3.x, r1.w
add_pp r1.w, r1, -r3.x
exp_pp r3.x, -r1.w
mad_pp r1.z, r1, r3.x, c32.y
mul r0.x, r0, c41.y
add r0.w, -r0.x, -r0.z
add r0.w, r0, c32
mul r3.xyz, r0.y, c44
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c40.w
mul r3.w, r0.z, c41.x
mad r0.xyz, r0.x, c43, r3
add_pp r1.z, r1.w, c40
frc r3.x, r3.w
mad r0.xyz, r0.w, c42, r0
add r1.w, r3, -r3.x
mul_pp r1.z, r1, c39.x
cmp_pp r1.x, -r1, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.z
mul r1.z, r3.x, c41
add r1.x, r1, r1.w
mul r1.x, r1, c41.y
add r1.w, -r1.x, -r1.z
add r0.w, r1, c32
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r3.xyz, r1.y, c44
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c32.z
mad r3.xyz, r1.y, c43, r3
mul r0.w, r0, r1.x
mad r3.xyz, r0.w, c42, r3
add r1.xyz, -r0, c32.wzzw
max r3.xyz, r3, c32.z
mad r1.xyz, r1, c29.x, r0
mad r3.xyz, -r3, c29.x, r3
else
add r3.xy, r7, c30.xzzw
add r1.xy, r3, c30.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s5
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r3.z, r1.w
add_pp r1.w, r1, -r3.z
exp_pp r3.z, -r1.w
mad_pp r1.z, r1, r3, c32.y
mul_pp r1.z, r1, c40.w
mul r3.z, r1, c41.x
add_pp r1.z, r1.w, c40
frc r3.w, r3.z
add r1.w, r3.z, -r3
add r8.xy, r1, -c30.xzzw
mul r3.z, r3.w, c41
mul_pp r1.z, r1, c39.x
cmp_pp r0.y, -r0, c32.w, c32.z
mad_pp r0.y, r0, c37.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c41
add r3.w, -r0.y, -r3.z
mov r8.z, r7
texldl r1, r8.xyzz, s5
abs_pp r4.x, r1.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r3.w, r3, c32
mul r3.w, r3, r0.x
rcp r3.z, r3.z
mul r0.y, r0, r0.x
mul r3.w, r3, r3.z
exp_pp r4.y, -r4.w
mul r0.y, r3.z, r0
mad_pp r3.z, r4.x, r4.y, c32.y
mul r4.xyz, r0.x, c44
mad r4.xyz, r0.y, c43, r4
mul_pp r0.x, r3.z, c40.w
mul r0.y, r0.x, c41.x
mad r4.xyz, r3.w, c42, r4
frc r3.z, r0.y
add r3.w, r0.y, -r3.z
add_pp r0.x, r4.w, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r1.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r3.w
mul r0.y, r3.z, c41.z
mul r0.x, r0, c41.y
add r1.y, -r0.x, -r0
add r1.y, r1, c32.w
mov r3.z, r7
texldl r3, r3.xyzz, s5
abs_pp r4.w, r3.y
log_pp r5.x, r4.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r5.y, r5.x
add_pp r0.y, r5.x, -r5
mul r5.xyz, r1.x, c44
mad r5.xyz, r0.x, c43, r5
exp_pp r1.x, -r0.y
mad_pp r0.x, r4.w, r1, c32.y
mad r5.xyz, r1.y, c42, r5
mul_pp r0.x, r0, c40.w
mul r1.x, r0, c41
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r3.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r1
max r5.xyz, r5, c32.z
max r4.xyz, r4, c32.z
add r6.xyz, r4, -r5
texldl r4, r7.xyzz, s5
add r7.xy, r8, -c30.zyzw
mul r1.x, r0, c41.y
mul r1.y, r1, c41.z
add r3.y, -r1.x, -r1
mul r0.xy, r7, c31
frc r0.xy, r0
mad r6.xyz, r0.x, r6, r5
abs_pp r5.x, r4.y
log_pp r5.y, r5.x
frc_pp r5.z, r5.y
add_pp r5.w, r5.y, -r5.z
add r3.y, r3, c32.w
mul r3.y, r3, r3.x
rcp r1.y, r1.y
mul r1.x, r1, r3
mul r3.y, r3, r1
exp_pp r5.y, -r5.w
mul r1.x, r1.y, r1
mad_pp r1.y, r5.x, r5, c32
mul r5.xyz, r3.x, c44
mad r5.xyz, r1.x, c43, r5
mad r5.xyz, r3.y, c42, r5
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r5.w, c40.z
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.y, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
rcp r3.y, r1.y
mul r1.x, r1, r4
add r3.x, r3, c32.w
mul r1.y, r3.x, r4.x
abs_pp r3.x, r3.w
mul r1.y, r1, r3
log_pp r4.y, r3.x
mul r1.x, r3.y, r1
frc_pp r3.y, r4
mul r8.xyz, r4.x, c44
mad r8.xyz, r1.x, c43, r8
add_pp r3.y, r4, -r3
exp_pp r1.x, -r3.y
mad r8.xyz, r1.y, c42, r8
mad_pp r1.x, r3, r1, c32.y
mul_pp r1.x, r1, c40.w
mul r1.y, r1.x, c41.x
frc r3.x, r1.y
add_pp r1.x, r3.y, c40.z
add r3.y, r1, -r3.x
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r3.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
abs_pp r3.y, r4.w
log_pp r4.x, r3.y
frc_pp r4.y, r4.x
add_pp r4.x, r4, -r4.y
max r8.xyz, r8, c32.z
max r5.xyz, r5, c32.z
add r5.xyz, r5, -r8
mad r5.xyz, r0.x, r5, r8
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
add r3.x, r3, c32.w
mul r3.x, r3.z, r3
rcp r1.y, r1.y
mul r3.w, r3.x, r1.y
mul r1.x, r3.z, r1
exp_pp r3.x, -r4.x
mul r1.x, r1.y, r1
mad_pp r1.y, r3, r3.x, c32
mul r3.xyz, r3.z, c44
mad r3.xyz, r1.x, c43, r3
mad r3.xyz, r3.w, c42, r3
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
max r8.xyz, r3, c32.z
frc r3.w, r1.y
add_pp r1.x, r4, c40.z
add r4.x, r1.y, -r3.w
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
mul r1.y, r3.w, c41.z
add r1.x, r1, r4
mul r1.x, r1, c41.y
add r3.w, -r1.x, -r1.y
rcp r3.y, r1.y
add r3.x, r3.w, c32.w
mul r1.y, r4.z, r3.x
mul r4.x, r1.y, r3.y
mul r1.y, r4.z, r1.x
mul r4.y, r3, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r4.w, r1.y, -r3
exp_pp r1.y, -r4.w
mad_pp r1.x, r1, r1.y, c32.y
mul_pp r1.y, r1.x, c40.w
abs_pp r1.x, r0.w
mul r5.w, r1.y, c41.x
frc r6.w, r5
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r1.y, r1, -r3.w
exp_pp r3.w, -r1.y
mad_pp r1.x, r1, r3.w, c32.y
mul r3.xyz, r4.z, c44
mad r3.xyz, r4.y, c43, r3
mad r3.xyz, r4.x, c42, r3
max r3.xyz, r3, c32.z
add r4.xyz, r8, -r3
add_pp r4.w, r4, c40.z
add r5.w, r5, -r6
mad r3.xyz, r0.x, r4, r3
mul_pp r4.w, r4, c39.x
cmp_pp r1.w, -r1, c32, c32.z
mad_pp r1.w, r1, c37, r4
add r1.w, r1, r5
mul r4.w, r1, c41.y
mul r5.w, r6, c41.z
mul_pp r1.x, r1, c40.w
mul r1.w, r1.x, c41.x
add_pp r1.x, r1.y, c40.z
frc r3.w, r1
add r1.y, r1.w, -r3.w
add r6.w, -r4, -r5
mul r8.x, r1.z, r4.w
rcp r4.w, r5.w
mul r5.w, r4, r8.x
mul r1.w, r3, c41.z
mul_pp r1.x, r1, c39
cmp_pp r0.w, -r0, c32, c32.z
mad_pp r0.w, r0, c37, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c41.y
add r1.x, -r0.w, -r1.w
add r1.y, r6.w, c32.w
add r3.w, r1.x, c32
mul r6.w, r1.z, r1.y
mul r1.xyz, r1.z, c44
mul r4.w, r6, r4
mad r1.xyz, r5.w, c43, r1
mad r1.xyz, r4.w, c42, r1
mul r4.w, r0.z, r0
mul r3.w, r0.z, r3
rcp r0.w, r1.w
mul r8.xyz, r0.z, c44
mul r0.z, r0.w, r4.w
mad r8.xyz, r0.z, c43, r8
mul r0.z, r3.w, r0.w
mad r8.xyz, r0.z, c42, r8
max r1.xyz, r1, c32.z
max r8.xyz, r8, c32.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r4.xyz, r1, -r3
add r6.xyz, r6, -r5
mad r1.xyz, r0.y, r6, r5
mad r3.xyz, r0.y, r4, r3
endif
mov r0.x, c4.w
mul r0.x, c33.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s6
else
mov r0.xyz, c32.z
endif
mul r3.xyz, r3, r2.w
mad r0.xyz, r0, r3, r2
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r2.xyz, r3.y, c38
mad r2.xyz, r3.x, c37, r2
mad r2.xyz, r3.z, c36, r2
add r1.w, r2.x, r2.y
mul_pp r0.x, r0, r1.z
add r0.z, r2, r1.w
rcp r1.z, r0.z
mul_pp r0.z, r1.y, c39.x
mul r1.zw, r2.xyxy, r1.z
mul r1.y, r1.z, c35.w
frc r1.z, r1.y
add r0.z, r1.x, -r0
mul r0.w, r0, c39.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r1.y, r1, -r1.z
min r1.x, r1.y, c35.w
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
add r1.y, r1.x, c36.w
cmp r0.w, r1.y, c32, c32.z
mad r0.z, r0, c40.x, c40.y
mul_pp r1.y, r0.w, c37.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.y
mul r1.x, r1.w, c39.z
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c34.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c39.x
frc r1.y, r1.x
add r1.x, r1, -r1.y
add r0.x, r0, -r0.z
min r1.x, r1, c39.w
mad r0.z, r0.x, c39.y, r1.x
add_pp r0.x, r0.y, c38.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c32, c32.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r2.y

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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 5 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 4 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 7 [_TexBackground] 2D
SetTexture 3 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 6 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[44] = { program.local[0..31],
		{ 1, 0, 2, -1 },
		{ -1000000, 0.995, 1000000, 0.1 },
		{ 0.75, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625, 1024 },
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
TEMP R17;
TEMP R18;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R9, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[5];
MOVR  R3.x, c[33];
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].z, -R0;
MOVR  R0.z, c[32].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[9].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[32].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.z, R2, R1;
MOVR  R0, c[13];
MULR  R3.w, R3.z, R3.z;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.w, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.z, R1;
TEX   R1, fragment.texcoord[0], texture[1], 2D;
MOVR  R0.x, c[33];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.z, R0.y;
MOVR  R0.y, c[33].x;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.z, R0.z;
MOVR  R0.z, c[33].x;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[19];
SGER  H0.x, c[32].y, R0;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R5, H0.x, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R4, H0.x, R0, c[24];
MOVR  R3, c[26];
ADDR  R3, -R3, c[22];
MADR  R6, H0.x, R3, c[26];
MOVR  R3, c[27];
ADDR  R3, -R3, c[23];
MADR  R7, H0.x, R3, c[27];
MOVR  R3.y, R1.x;
MOVR  R0.y, R1.w;
MOVR  R0.zw, c[32].x;
MOVR  R0.x, R9.w;
DP4R  R2.w, R0, R7;
DP4R  R2.y, R0, R5;
DP4R  R2.z, R0, R6;
DP4R  R2.x, R0, R4;
DP4R  R0.w, R7, R7;
MOVR  R1.x, R9.z;
MOVR  R3.zw, c[32].y;
MOVR  R3.x, R9;
DP4R  R9.x, R7, R3;
DP4R  R0.y, R5, R5;
DP4R  R0.z, R6, R6;
DP4R  R0.x, R4, R4;
MADR  R0, R2, R0, -R0;
ADDR  R0, R0, c[32].x;
MOVR  R2.y, R1;
MULR  R1.w, R0.x, R0.y;
MOVR  R2.zw, c[32].y;
MOVR  R2.x, R9.y;
DP4R  R9.y, R7, R2;
MOVR  R1.y, R1.z;
MULR  R8.z, R1.w, R0;
MOVR  R1.zw, c[32].y;
DP4R  R9.z, R7, R1;
DP4R  R7.x, R6, R3;
DP4R  R7.z, R6, R1;
DP4R  R7.y, R6, R2;
MADR  R6.xyz, R0.z, R9, R7;
DP4R  R7.x, R5, R3;
DP4R  R3.x, R4, R3;
DP4R  R7.z, R5, R1;
DP4R  R7.y, R5, R2;
DP4R  R3.y, R4, R2;
MULR  R2.w, R8.z, R0;
DP4R  R3.z, R4, R1;
MADR  R5.xyz, R0.y, R6, R7;
ADDR  R0.zw, fragment.texcoord[0].xyxy, c[30].xyxz;
MADR  R2.xyz, R0.x, R5, R3;
ADDR  R0.xy, R0.zwzw, c[30].zyzw;
ADDR  R1.xy, R0, -c[30].xzzw;
ADDR  R18.xy, R1, -c[30].zyzw;
TEX   R0.x, R0, texture[3], 2D;
TEX   R1.x, R1, texture[3], 2D;
ADDR  R0.y, R1.x, -R0.x;
TEX   R1.x, fragment.texcoord[0], texture[3], 2D;
TEX   R3.x, R0.zwzw, texture[3], 2D;
MULR  R1.zw, R18.xyxy, c[31].xyxy;
FRCR  R0.zw, R1;
MADR  R0.x, R0.z, R0.y, R0;
ADDR  R1.y, R3.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[4].w;
TEX   R0.x, fragment.texcoord[0], texture[2], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[4];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R8.w, R0.z, R0.x;
ADDR  R0.x, R8.w, -R0.y;
SGTRC HC.x, |R0|, c[28];
IF    NE.x;
MOVR  R3.x, c[33];
MOVR  R3.z, c[33].x;
MOVR  R3.w, c[33].x;
MOVR  R3.y, c[33].x;
MOVR  R10.x, c[0].w;
MOVR  R10.z, c[2].w;
MOVR  R10.y, c[1].w;
MULR  R9.xyz, R10, c[9].x;
ADDR  R5.xyz, R9, -c[5];
DP3R  R7.x, R5, R5;
MOVR  R12.w, c[32].x;
MULR  R1.xy, R18, c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].z, -R0;
MOVR  R0.z, c[32].w;
DP3R  R0.w, R0, R0;
RSQR  R4.w, R0.w;
MULR  R0.xyz, R4.w, R0;
MOVR  R0.w, c[32].y;
DP4R  R4.z, R0, c[2];
DP4R  R4.y, R0, c[1];
DP4R  R4.x, R0, c[0];
DP3R  R5.w, R4, R5;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
MULR  R8.z, R5.w, R5.w;
ADDR  R1, R8.z, -R0;
SLTR  R6, R8.z, R0;
MOVXC RC.x, R6;
MOVR  R3.x(EQ), R8;
SGERC HC, R8.z, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R5.w, R1;
MOVXC RC.z, R6;
MOVR  R3.z(EQ), R8.x;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R3.z(NE.y), -R5.w, R0.x;
MOVXC RC.y, R6;
RSQR  R0.x, R1.w;
MOVR  R3.w(EQ.z), R8.x;
RCPR  R0.x, R0.x;
ADDR  R3.w(NE), -R5, R0.x;
RSQR  R0.x, R1.y;
MOVR  R3.y(EQ), R8.x;
RCPR  R0.x, R0.x;
ADDR  R3.y(NE.x), -R5.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
ADDR  R6, R8.z, -R0;
SLTR  R7, R8.z, R0;
RSQR  R1.y, R6.x;
MOVR  R1.x, c[33].z;
MOVXC RC.x, R7;
MOVR  R1.x(EQ), R8;
SGERC HC, R8.z, R0.yzxw;
RCPR  R1.y, R1.y;
ADDR  R1.x(NE.z), -R5.w, -R1.y;
RSQR  R0.x, R6.z;
MOVR  R1.y, c[33].z;
MOVR  R0.w, c[33].z;
MOVXC RC.z, R7;
MOVR  R0.w(EQ.z), R8.x;
RCPR  R0.x, R0.x;
ADDR  R0.w(NE.y), -R5, -R0.x;
MOVXC RC.y, R7;
RSQR  R0.x, R6.w;
MULR  R7.xyz, R4.zxyw, c[12].yzxw;
MADR  R7.xyz, R4.yzxw, c[12].zxyw, -R7;
MOVR  R1.y(EQ), R8.x;
MOVR  R1.z, c[33];
MOVXC RC.z, R7.w;
MOVR  R1.z(EQ), R8.x;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R5.w, -R0.x;
RSQR  R0.x, R6.y;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R5.w, -R0.x;
MOVR  R0.xyz, c[5];
MADR  R0.xyz, R10, c[9].x, -R0;
DP3R  R1.w, R0, R4;
MOVR  R5.w, c[18].x;
DP3R  R7.w, R0, R0;
ADDR  R5.w, R5, c[7].x;
MADR  R6.x, -R5.w, R5.w, R7.w;
MULR  R6.w, R1, R1;
ADDR  R6.y, R6.w, -R6.x;
RSQR  R6.y, R6.y;
MOVR  R5.w, c[33].z;
SLTRC HC.x, R6.w, R6;
MOVR  R5.w(EQ.x), R8.x;
SGERC HC.x, R6.w, R6;
RCPR  R6.y, R6.y;
ADDR  R5.w(NE.x), -R1, -R6.y;
MOVXC RC.x, R5.w;
MULR  R6.xyz, R0.zxyw, c[12].yzxw;
MADR  R6.xyz, R0.yzxw, c[12].zxyw, -R6;
DP3R  R0.x, R0, c[12];
SLER  H0.x, R0, c[32].y;
DP3R  R8.z, R6, R6;
DP3R  R6.x, R6, R7;
DP3R  R6.z, R7, R7;
MADR  R6.y, -c[7].x, c[7].x, R8.z;
MULR  R7.y, R6.z, R6;
MULR  R7.x, R6, R6;
ADDR  R6.y, R7.x, -R7;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
ADDR  R0.y, -R6.x, R6;
SGTR  H0.y, R7.x, R7;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVR  R5.w(LT.x), c[33].z;
MOVXC RC.x, H0;
RCPR  R6.z, R6.z;
MOVR  R0.z, c[33].x;
MULR  R0.z(NE.x), R6, R0.y;
ADDR  R0.y, -R6.x, -R6;
MOVR  R0.x, c[33].z;
MULR  R0.x(NE), R0.y, R6.z;
MOVR  R0.y, R0.z;
MOVR  R18.zw, R0.xyxy;
MADR  R0.xyz, R4, R0.x, R9;
ADDR  R0.xyz, R0, -c[5];
DP3R  R0.x, R0, c[12];
SGTR  H0.y, R0.x, c[32];
MADR  R0.z, -c[8].x, c[8].x, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R18.zw(NE.x), c[33].xyzx;
ADDR  R6.x, R6.w, -R0.z;
RSQR  R6.x, R6.x;
RCPR  R6.x, R6.x;
ADDR  R6.y, -R1.w, -R6.x;
ADDR  R1.w, -R1, R6.x;
MAXR  R6.x, R6.y, c[32].y;
MAXR  R6.y, R1.w, c[32];
MOVR  R1.w, R1.z;
MOVR  R1.z, R0.w;
MOVR  R0.xy, c[32].y;
SLTRC HC.x, R6.w, R0.z;
MOVR  R0.xy(EQ.x), R8;
SGERC HC.x, R6.w, R0.z;
MOVR  R0.xy(NE.x), R6;
MAXR  R9.w, R0.x, c[32].y;
DP4R  R0.z, R1, c[24];
DP4R  R0.w, R3, c[20];
ADDR  R6.x, R0.w, -R0.z;
DP4R  R0.w, R3, c[19];
SGER  H0.y, c[32], R0.w;
MADR  R6.x, H0.y, R6, R0.z;
DP4R  R0.w, R1, c[25];
DP4R  R0.z, R3, c[21];
ADDR  R0.z, R0, -R0.w;
MADR  R6.y, H0, R0.z, R0.w;
RCPR  R0.z, R4.w;
MULR  R4.w, R8, R0.z;
MADR  R5.w, -R4, c[9].x, R5;
MOVR  R0.zw, c[33].xywy;
MULR  R0.w, R0, c[4];
SGER  H0.x, R8.w, R0.w;
MULR  R4.w, R4, c[9].x;
MADR  R0.w, H0.x, R5, R4;
MINR  R4.w, R0.y, R0;
MINR  R0.w, R4, R6.x;
MAXR  R10.w, R9, R0;
MINR  R0.y, R4.w, R6;
MAXR  R11.w, R10, R0.y;
DP4R  R0.y, R1, c[26];
DP4R  R0.x, R3, c[22];
ADDR  R0.x, R0, -R0.y;
MADR  R0.x, H0.y, R0, R0.y;
MINR  R0.x, R4.w, R0;
MAXR  R5.w, R11, R0.x;
ADDR  R6.z, R5.w, -R11.w;
ADDR  R6.xy, R18.wzzw, -R5.w;
RCPR  R0.x, R6.z;
ADDR  R7.zw, R18.xywz, -R11.w;
MULR_SAT R0.y, R0.x, R7.z;
MULR_SAT R0.x, -R6.y, R0;
MULR  R0.w, R0.x, R0.y;
DP3R  R0.x, R4, c[12];
MULR  R0.y, R0.x, c[17].x;
MULR  R0.y, R0, c[32].z;
MULR  R0.x, R0, R0;
MADR  R0.y, c[17].x, c[17].x, R0;
ADDR  R0.y, R0, c[32].x;
POWR  R6.y, R0.y, c[34].y;
ADDR  R0.y, R12.w, c[17].x;
MADR  R4.xyz, R4, R9.w, R5;
MADR  R0.x, R0, c[34], c[34];
RCPR  R6.y, R6.y;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R6;
MULR  R7.xy, R0, c[34].z;
MOVR  R6.y, c[34].w;
MULR  R6.w, R6.y, c[16].x;
MULR  R0.xyz, R0.z, c[15];
ADDR  R11.xyz, R0, R6.w;
MULR  R6.y, R7, R6.w;
MADR  R0.xyz, R0, R7.x, R6.y;
RCPR  R10.x, R11.x;
RCPR  R10.z, R11.z;
RCPR  R10.y, R11.y;
MULR  R12.xyz, R0, R10;
MADR  R0.xyz, R12, -R0.w, R12;
DP3R  R0.w, R4, R4;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R4.x, R0.w, -c[7];
MOVR  R0.w, c[7].x;
ADDR  R0.w, -R0, c[8].x;
RCPR  R0.w, R0.w;
MULR  R5.y, R4.x, R0.w;
MOVR  R4.xyz, c[6];
DP3R  R0.w, R4, c[12];
MADR  R5.x, -R0.w, c[35].y, c[35].y;
TEX   R13.zw, R5, texture[4], 2D;
MULR  R5.xyz, -R11, |R6.z|;
MULR  R0.w, R13, c[16].x;
MADR  R4.xyz, R13.z, -c[15], -R0.w;
MULR  R0.xyz, R10, R0;
RCPR  R6.y, |R6.z|;
POWR  R7.x, c[35].x, R5.x;
POWR  R7.y, c[35].x, R5.y;
POWR  R7.z, c[35].x, R5.z;
TEX   R0.w, c[35].y, texture[5], 2D;
POWR  R4.x, c[35].x, R4.x;
POWR  R4.z, c[35].x, R4.z;
POWR  R4.y, c[35].x, R4.y;
MULR  R4.xyz, R4, c[11];
MULR  R13.xyz, R4, R0.w;
ADDR  R14.xyz, R13, -R13;
MULR  R4.xyz, R14, R6.y;
MADR  R4.xyz, R11, R13, R4;
MADR  R4.xyz, -R7, R4, R4;
MULR  R17.xyz, R0, R4;
DP4R  R0.x, R1, c[27];
DP4R  R0.y, R3, c[23];
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R4.w, R0;
MAXR  R0.w, R5, R0.x;
ADDR  R1.w, R0, -R5;
MULR  R3.xyz, -R11, |R1.w|;
ADDR  R4.xy, R18.wzzw, -R0.w;
RCPR  R0.x, R1.w;
RCPR  R1.x, |R1.w|;
MULR_SAT R0.y, R0.x, R6.x;
MULR_SAT R0.x, -R4.y, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R12, -R0.x, R12;
MULR  R1.xyz, R14, R1.x;
MOVR  R5, c[27];
ADDR  R5, -R5, c[23];
MULR  R0.xyz, R10, R0;
ADDR  R0.w, R4, -R0;
MADR  R5, H0.y, R5, c[27];
POWR  R8.x, c[35].x, R3.x;
POWR  R8.y, c[35].x, R3.y;
POWR  R8.z, c[35].x, R3.z;
MULR  R3.xyz, |R0.w|, -R11;
MADR  R1.xyz, R11, R13, R1;
MADR  R1.xyz, -R8, R1, R1;
MULR  R16.xyz, R0, R1;
RCPR  R0.x, R0.w;
RCPR  R1.x, |R0.w|;
MULR  R1.xyz, R14, R1.x;
MULR_SAT R0.y, R0.x, R4.x;
ADDR  R0.z, R4.w, -R18;
MULR_SAT R0.x, R0.z, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R12, R12;
POWR  R9.x, c[35].x, R3.x;
POWR  R9.y, c[35].x, R3.y;
POWR  R9.z, c[35].x, R3.z;
MADR  R1.xyz, R11, R13, R1;
MADR  R1.xyz, -R9, R1, R1;
MULR  R0.xyz, R0, R10;
MULR  R15.xyz, R0, R1;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R4, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R3, H0.y, R0, c[24];
TEX   R1.w, R18, texture[1], 2D;
MOVR  R0.y, R1.w;
TEX   R0.w, R18, texture[0], 2D;
MOVR  R0.x, R0.w;
MOVR  R0.zw, c[32].x;
MOVR  R1, c[26];
ADDR  R1, -R1, c[22];
MADR  R1, H0.y, R1, c[26];
DP4R  R6.x, R0, R3;
DP4R  R6.z, R0, R1;
DP4R  R6.y, R0, R4;
DP4R  R6.w, R0, R5;
DP4R  R0.z, R1, R1;
DP4R  R0.x, R3, R3;
ADDR  R1.w, R11, -R10;
RCPR  R3.x, R1.w;
DP4R  R0.y, R4, R4;
DP4R  R0.w, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[32].x;
MADR  R1.xyz, R15, R0.w, R16;
MADR  R1.xyz, R1, R0.z, R17;
ADDR  R0.zw, R18.xywz, -R10.w;
MULR_SAT R3.y, -R7.w, R3.x;
MULR_SAT R0.z, R3.x, R0;
MULR  R0.z, R3.y, R0;
MULR  R3.xyz, -R11, |R1.w|;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R1.w|;
MULR  R5.xyz, R14, R0.z;
POWR  R3.x, c[35].x, R3.x;
POWR  R3.y, c[35].x, R3.y;
POWR  R3.z, c[35].x, R3.z;
MADR  R5.xyz, R11, R13, R5;
MADR  R5.xyz, -R3, R5, R5;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R5;
MADR  R1.xyz, R1, R0.y, R4;
ADDR  R0.y, R10.w, -R9.w;
MULR  R5.xyz, -R11, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R18, -R9;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R0.y|;
MULR  R6.xyz, R14, R0.z;
POWR  R5.x, c[35].x, R5.x;
POWR  R5.y, c[35].x, R5.y;
POWR  R5.z, c[35].x, R5.z;
MADR  R6.xyz, R11, R13, R6;
MADR  R6.xyz, -R5, R6, R6;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R6;
MADR  R0.xyz, R1, R0.x, R4;
MULR  R1.xyz, R0.y, c[38];
MADR  R1.xyz, R0.x, c[37], R1;
MADR  R0.xyz, R0.z, c[36], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].z;
SGER  H0.x, R0, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[34].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[37].w;
MULR  R0.z, R0.w, c[39].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[36].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[39].y;
MADR  R0.x, R0, c[38].w, R0.z;
MADR  H0.z, R0.x, c[39], R12.w;
MADH  H0.x, H0, c[32].z, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.z, H0, c[40].x;
FLRR  R0.x, R0.z;
ADDH  H0.y, H0, c[36].w;
FRCR  R0.z, R0;
MULR  R0.z, R0, c[40];
RCPR  R1.x, R0.z;
MULH  H0.y, H0, c[37].w;
SGEH  H0.x, c[32].y, H0;
MADH  H0.x, H0, c[35].w, H0.y;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].y;
ADDR  R0.w, -R0.x, -R0.z;
MADR  R0.w, R0, R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R1.y, R1.x, R0.x;
MULR  R0.xyz, R0.y, c[43];
MULR  R0.w, R0, R1.x;
MADR  R0.xyz, R1.y, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R0.xyz, R0, c[32].y;
ADDR  R1.xyz, -R0, c[32].xyyw;
MADR  R0.xyz, R1, c[29].x, R0;
MULR  R1.xyz, R3, R5;
MULR  R1.xyz, R7, R1;
MULR  R1.xyz, R8, R1;
MULR  R1.xyz, R9, R1;
MULR  R3.xyz, R1.y, c[38];
MADR  R3.xyz, R1.x, c[37], R3;
MADR  R1.xyz, R1.z, c[36], R3;
ADDR  R0.w, R1.x, R1.y;
ADDR  R0.w, R1.z, R0;
RCPR  R0.w, R0.w;
MULR  R1.zw, R1.xyxy, R0.w;
MULR  R0.w, R1.z, c[35].z;
FLRR  R0.w, R0;
MINR  R0.w, R0, c[35].z;
SGER  H0.x, R0.w, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.w, R0, -H0.y;
MULR  R1.x, R0.w, c[34].w;
FLRR  H0.y, R1.x;
MULH  H0.z, H0.y, c[37].w;
MULR  R1.x, R1.w, c[39];
FLRR  R1.x, R1;
ADDH  H0.y, H0, -c[36].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.w, R0, -H0.z;
MINR  R1.x, R1, c[39].y;
MADR  R0.w, R0, c[38], R1.x;
MADR  H0.z, R0.w, c[39], R12.w;
MADH  H0.x, H0, c[32].z, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
FLRR  R1.x, R0.w;
FRCR  R0.w, R0;
MULR  R1.z, R0.w, c[40];
ADDH  H0.y, H0, c[36].w;
RCPR  R1.w, R1.z;
MULH  H0.y, H0, c[37].w;
SGEH  H0.x, c[32].y, H0;
MADH  H0.x, H0, c[35].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.x, R1, c[40].y;
ADDR  R0.w, -R1.x, -R1.z;
MADR  R0.w, R0, R1.y, R1.y;
MULR  R1.x, R1, R1.y;
MULR  R3.x, R1.w, R1;
MULR  R1.xyz, R1.y, c[43];
MADR  R1.xyz, R3.x, c[42], R1;
MULR  R0.w, R0, R1;
MADR  R1.xyz, R0.w, c[41], R1;
MAXR  R1.xyz, R1, c[32].y;
MADR  R1.xyz, -R1, c[29].x, R1;
ELSE;
ADDR  R6.xy, R18, c[30].xzzw;
ADDR  R0.xy, R6, c[30].zyzw;
TEX   R3, R0, texture[6], 2D;
ADDR  R7.xy, R0, -c[30].xzzw;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R3|, H0;
MADH  H0.y, H0, c[39].w, -c[39].w;
MULR  R0.z, H0.y, c[40].x;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[40].z;
ADDH  H0.x, H0, c[36].w;
MULH  H0.z, H0.x, c[37].w;
SGEH  H0.xy, c[32].y, R3.ywzw;
TEX   R4, R7, texture[6], 2D;
MADH  H0.x, H0, c[35].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[40].y;
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[36].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R3.x;
MADR  R0.w, R0, R3.x, R3.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R3.x, c[43];
MADR  R0.xyz, R1.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
MAXR  R1.xyz, R0, c[32].y;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[32].y, R4.xyyw;
MULH  H0.x, H0, c[37].w;
MULR  R0.z, R0.x, c[40];
FLRR  R0.y, R0.w;
MADH  H0.x, H0.z, c[35].w, H0;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[40].y;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R4.x, R4.x;
RCPR  R0.w, R0.z;
MULR  R1.w, R0.y, R0;
MULR  R3.x, R0, R4;
MULR  R0.w, R0, R3.x;
MULR  R0.xyz, R4.x, c[43];
MADR  R5.xyz, R0.w, c[42], R0;
TEX   R0, R6, texture[6], 2D;
MADR  R5.xyz, R1.w, c[41], R5;
LG2H  H0.x, |R0.y|;
MAXR  R5.xyz, R5, c[32].y;
ADDR  R6.xyz, R1, -R5;
TEX   R1, R18, texture[6], 2D;
ADDR  R18.xy, R7, -c[30].zyzw;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R4.x, H0.z, c[40];
FRCR  R4.y, R4.x;
MULR  R3.xy, R18, c[31];
FRCR  R3.xy, R3;
MADR  R5.xyz, R3.x, R6, R5;
ADDH  H0.x, H0, c[36].w;
SGEH  H1.xy, c[32].y, R0.ywzw;
MULH  H0.x, H0, c[37].w;
SGEH  H1.zw, c[32].y, R1.xyyw;
FLRR  R4.x, R4;
MADH  H0.x, H1, c[35].w, H0;
ADDR  R0.y, H0.x, R4.x;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R4.x, R0.y, c[40].y;
MULR  R4.y, R4, c[40].z;
ADDR  R0.y, -R4.x, -R4;
RCPR  R4.y, R4.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R4.x, R4, R0;
MULR  R0.y, R0, R4;
MULR  R4.x, R4.y, R4;
MULR  R6.xyz, R0.x, c[43];
MADR  R6.xyz, R4.x, c[42], R6;
MADH  H0.z, H0, c[39].w, -c[39].w;
MADR  R6.xyz, R0.y, c[41], R6;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MADH  H0.x, H1.z, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R1.y, R0.x, c[40];
MULR  R0.y, R0, c[40].z;
ADDR  R0.x, -R1.y, -R0.y;
MULR  R1.y, R1, R1.x;
MADR  R0.x, R0, R1, R1;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.y, R0, R1;
MULR  R7.xyz, R1.x, c[43];
MADR  R7.xyz, R0.y, c[42], R7;
MADR  R7.xyz, R0.x, c[41], R7;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[32].y;
MAXR  R6.xyz, R6, c[32].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R3.x, R6, R7;
MADH  H0.x, H1.y, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R0.y, R0, c[40].z;
MULR  R0.x, R0, c[40].y;
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[43];
MADR  R0.xyz, R1.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R7.xyz, R0, c[32].y;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MULR  R0.z, R0.y, c[40];
RCPR  R1.x, R0.z;
MADH  H0.x, H1.w, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].y;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R1.z, R0, R1.z;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULR  R0.w, R0.y, R1.x;
MULR  R1.y, R1.z, R0.x;
MULR  R0.xyz, R1.z, c[43];
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, R1.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R0.xyz, R0, c[32].y;
ADDR  R1.xyz, R7, -R0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
MULH  H0.x, H0, c[37].w;
MADH  H0.z, H0.w, c[35].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
MULR  R4.x, R1.w, c[40].y;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULR  R4.y, R0.w, c[40].z;
MULH  H0.z, |R3.w|, H0;
ADDR  R4.w, -R4.x, -R4.y;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MADR  R4.w, R4.z, R4, R4.z;
RCPR  R5.w, R4.y;
MULR  R6.w, R4.z, R4.x;
MADR  R1.xyz, R3.x, R1, R0;
MULR  R1.w, R1, c[40].z;
MULR  R4.w, R4, R5;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[35].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[40].y;
ADDR  R3.w, -R0, -R1;
MULR  R4.xyz, R4.z, c[43];
MULR  R6.w, R5, R6;
MADR  R4.xyz, R6.w, c[42], R4;
MADR  R4.xyz, R4.w, c[41], R4;
MULR  R4.w, R3.z, R0;
RCPR  R0.w, R1.w;
MAXR  R4.xyz, R4, c[32].y;
MULR  R1.w, R0, R4;
MADR  R3.w, R3.z, R3, R3.z;
MULR  R7.xyz, R3.z, c[43];
MADR  R7.xyz, R1.w, c[42], R7;
MULR  R0.w, R3, R0;
MADR  R7.xyz, R0.w, c[41], R7;
MAXR  R7.xyz, R7, c[32].y;
ADDR  R7.xyz, R7, -R4;
MADR  R0.xyz, R3.x, R7, R4;
ADDR  R4.xyz, R0, -R1;
MADR  R0.xyz, R3.y, R5, R6;
MADR  R1.xyz, R3.y, R4, R1;
ENDIF;
MOVR  R0.w, c[33].y;
MULR  R0.w, R0, c[4];
SGTRC HC.x, R8.w, R0.w;
IF    NE.x;
TEX   R3.xyz, R18, texture[7], 2D;
ELSE;
MOVR  R3.xyz, c[32].y;
ENDIF;
MULR  R1.xyz, R1, R2.w;
MADR  R2.xyz, R3, R1, R2;
ADDR  R0.xyz, R2, R0;
MULR  R2.xyz, R0.y, c[38];
MADR  R2.xyz, R0.x, c[37], R2;
MADR  R0.xyz, R0.z, c[36], R2;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[38];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].z;
SGER  H0.x, R0, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[34].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[36].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[37].w;
MADR  R2.xyz, R1.x, c[37], R2;
MADR  R1.xyz, R1.z, c[36], R2;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[35];
MULR  R0.w, R0, c[39].x;
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[39].x;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[32].z, H0.z;
MINR  R0.z, R0, c[35];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[35].w;
MULH  H0.y, H0.z, c[35].w;
MINR  R0.w, R0, c[39].y;
MADR  R0.w, R0.x, c[38], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[32];
MADR  H0.y, R0.w, c[39].z, R0.x;
MULR  R0.w, R0.z, c[34];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[37].w;
ADDH  H0.x, H0, -c[36].w;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[39];
MADR  R0.y, R0.z, c[38].w, R0;
MADR  H0.z, R0.y, c[39], R0.x;
MADH  H0.x, H0.y, c[32].z, H0;
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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 5 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 4 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 7 [_TexBackground] 2D
SetTexture 3 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 6 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
dcl_2d s7
def c32, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c33, -1000000.00000000, 0.99500000, 1000000.00000000, 0.10000000
def c34, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c35, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c36, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c37, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c38, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c39, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c40, 0.00097656, 1.00000000, 15.00000000, 1024.00000000
def c41, 0.00390625, 0.00476190, 0.63999999, 0
def c42, 0.07530000, -0.25430000, 1.18920004, 0
def c43, 2.56509995, -1.16649997, -0.39860001, 0
def c44, -1.02170002, 1.97770000, 0.04390000, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c32.x, c32.y
mov r6, c23
mov r3, c22
texldl r9, v0, s0
add r3, -c26, r3
mov r0.z, c32.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c32.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c7
mov r0.y, c7.x
add r0.y, c13, r0
add r6, -c27, r6
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c9.x
add r2.xyz, r2, -c5
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c13, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c32.w, c32.z
cmp r0.x, r0, r1.w, c33
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c32.w, c32.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c33.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c7.x
add r1.y, c13.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c7.x
add r0.w, c13.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c32, c32.z
cmp r1.z, r1, r1.w, c33.x
cmp_pp r0.z, r1.x, c32.w, c32
cmp r1.x, r1, r1.w, c33
cmp r0.w, -r0, r1.z, r2.x
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c19
cmp r2.z, -r0.x, c32.w, c32
mad r7, r2.z, r6, c27
mad r6, r2.z, r3, c26
mov r1, c21
add r1, -c25, r1
mad r5, r2.z, r1, c25
texldl r1, v0, s1
mov r3.y, r1.x
mov r0, c20
add r0, -c24, r0
mad r4, r2.z, r0, c24
mov r0.y, r1.w
mov r0.zw, c32.w
mov r0.x, r9.w
dp4 r2.w, r7, r0
dp4 r2.x, r4, r0
dp4 r2.y, r5, r0
dp4 r2.z, r6, r0
dp4 r0.w, r7, r7
add r2, r2, c32.y
mov r1.x, r9.z
dp4 r0.x, r4, r4
mov r3.zw, c32.z
mov r3.x, r9
dp4 r9.x, r7, r3
dp4 r0.y, r5, r5
dp4 r0.z, r6, r6
mad r0, r0, r2, c32.w
mov r2.y, r1
mov r1.y, r1.z
mov r1.zw, c32.z
dp4 r9.z, r7, r1
mov r2.zw, c32.z
mov r2.x, r9.y
dp4 r9.y, r7, r2
dp4 r7.x, r6, r3
dp4 r7.z, r6, r1
dp4 r7.y, r6, r2
mad r6.xyz, r0.z, r9, r7
dp4 r7.x, r5, r3
dp4 r3.x, r4, r3
dp4 r3.z, r4, r1
dp4 r7.z, r5, r1
dp4 r3.y, r4, r2
dp4 r7.y, r5, r2
mad r5.xyz, r0.y, r6, r7
mad r2.xyz, r0.x, r5, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r3.xy, v0, c30.xzzw
add r0.xy, r3, c30.zyzw
add r4.xy, r0, -c30.xzzw
mov r0.z, v0.w
mov r4.z, v0.w
mov r3.z, v0.w
add r7.xy, r4, -c30.zyzw
mul r1.zw, r7.xyxy, c31.xyxy
texldl r0.x, r0.xyzz, s3
texldl r1.x, r4.xyzz, s3
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s3
texldl r3.x, r3.xyzz, s3
add r0.z, r3.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c4.w, -c4.z
rcp r0.y, r0.x
mul r0.y, r0, c4.w
texldl r0.x, v0, s2
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c4.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r2.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c28.x
mad r0.xy, r7, c32.x, c32.y
mul r0.xy, r0, c4
mov r0.z, c32.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c32.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.x, c7
mov r1.y, c7.x
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r5.xyz, r3, c9.x
add r6.xyz, r5, -c5
dp3 r4.x, r6, r0
dp3 r4.y, r6, r6
add r1.y, c14, r1
mad r1.z, -r1.y, r1.y, r4.y
mad r1.w, r4.x, r4.x, -r1.z
rsq r3.x, r1.w
add r1.x, c14, r1
mad r1.x, -r1, r1, r4.y
mad r1.x, r4, r4, -r1
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r4.x, -r1.y
cmp_pp r1.y, r1.x, c32.w, c32.z
cmp r1.x, r1, r8, c33.z
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c32.w, c32.z
rcp r3.x, r3.x
cmp r1.w, r1, r8.x, c33.z
add r3.x, -r4, -r3
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r3.x, c14.w, r1.z
mad r1.w, -r1, r1, r4.y
mad r1.z, r4.x, r4.x, -r1.w
mad r3.x, -r3, r3, r4.y
mad r3.y, r4.x, r4.x, -r3.x
rsq r1.w, r1.z
rcp r1.w, r1.w
add r3.x, -r4, -r1.w
cmp_pp r1.w, r1.z, c32, c32.z
cmp r1.z, r1, r8.x, c33
cmp r1.z, -r1.w, r1, r3.x
rsq r3.z, r3.y
rcp r3.z, r3.z
cmp r3.x, r3.y, r8, c33.z
add r3.z, -r4.x, -r3
cmp_pp r1.w, r3.y, c32, c32.z
cmp r1.w, -r1, r3.x, r3.z
mov r3.x, c7
add r3.y, c13.x, r3.x
mov r3.x, c7
add r3.z, c13.y, r3.x
mad r3.y, -r3, r3, r4
mad r3.x, r4, r4, -r3.y
mad r3.z, -r3, r3, r4.y
mad r3.w, r4.x, r4.x, -r3.z
rsq r3.y, r3.x
rcp r3.y, r3.y
add r3.z, -r4.x, r3.y
cmp_pp r3.y, r3.x, c32.w, c32.z
cmp r3.x, r3, r8, c33
cmp r3.x, -r3.y, r3, r3.z
rsq r4.w, r3.w
cmp_pp r3.y, r3.w, c32.w, c32.z
rcp r4.w, r4.w
dp4 r4.z, r1, c24
dp4 r8.z, r1, c25
cmp r3.w, r3, r8.x, c33.x
add r4.w, -r4.x, r4
cmp r3.y, -r3, r3.w, r4.w
mov r3.z, c7.x
add r3.w, c13, r3.z
mad r3.w, -r3, r3, r4.y
mad r5.w, r4.x, r4.x, -r3
rsq r3.w, r5.w
rcp r4.w, r3.w
mov r3.z, c7.x
add r3.z, c13, r3
mad r3.z, -r3, r3, r4.y
mad r3.z, r4.x, r4.x, -r3
add r6.w, -r4.x, r4
rsq r3.w, r3.z
rcp r4.w, r3.w
cmp_pp r3.w, r5, c32, c32.z
cmp r5.w, r5, r8.x, c33.x
cmp r3.w, -r3, r5, r6
add r5.w, -r4.x, r4
cmp_pp r4.w, r3.z, c32, c32.z
cmp r3.z, r3, r8.x, c33.x
cmp r3.z, -r4.w, r3, r5.w
dp4 r4.w, r3, c20
add r6.w, r4, -r4.z
dp4 r5.w, r3, c19
cmp r12.w, -r5, c32, c32.z
mad r4.z, r12.w, r6.w, r4
dp4 r6.w, r3, c21
add r8.w, r6, -r8.z
mov r4.w, c7.x
add r4.w, c18.x, r4
mad r4.w, -r4, r4, r4.y
mad r4.w, r4.x, r4.x, -r4
rsq r5.w, r4.w
rcp r5.w, r5.w
add r6.w, -r4.x, -r5
cmp_pp r5.w, r4, c32, c32.z
cmp r4.w, r4, r8.x, c33.z
cmp r4.w, -r5, r4, r6
rcp r0.w, r0.w
mul r5.w, r7, r0
cmp r6.w, r4, r4, c33.z
mad r6.w, -r5, c9.x, r6
mad r4.y, -c8.x, c8.x, r4
mad r4.w, r4.x, r4.x, -r4.y
rsq r4.y, r4.w
mov r0.w, c4
mad r0.w, c33.y, -r0, r7
mad r8.z, r12.w, r8.w, r8
cmp r8.xy, r4.w, r8, c32.z
rcp r4.y, r4.y
cmp r0.w, r0, c32, c32.z
mul r5.w, r5, c9.x
mad r5.w, r0, r6, r5
add r0.w, -r4.x, -r4.y
add r4.y, -r4.x, r4
max r4.x, r0.w, c32.z
cmp_pp r0.w, r4, c32, c32.z
max r4.y, r4, c32.z
cmp r4.xy, -r0.w, r8, r4
min r4.w, r4.y, r5
max r8.w, r4.x, c32.z
dp4 r4.x, r1, c26
dp4 r1.y, r1, c27
min r0.w, r4, r4.z
max r9.w, r8, r0
min r4.y, r4.w, r8.z
dp4 r0.w, r3, c22
dp4 r1.x, r3, c23
add r0.w, r0, -r4.x
add r1.x, r1, -r1.y
mad r0.w, r12, r0, r4.x
mad r1.x, r12.w, r1, r1.y
mad r3.xyz, r0, r8.w, r6
max r10.w, r9, r4.y
min r0.w, r4, r0
max r11.w, r10, r0
min r1.x, r4.w, r1
max r5.w, r11, r1.x
add r10.x, r5.w, -r11.w
mov r0.w, c16.x
mul r6.w, c34, r0
dp3 r0.w, r3, r3
mov r1.xyz, c15
mul r4.xyz, c33.w, r1
add r11.xyz, r4, r6.w
abs r1.w, r10.x
mul r8.xyz, -r11, r1.w
pow r1, c35.x, r8.x
mov r8.x, r1
rcp r10.z, r11.z
rcp r10.y, r11.y
pow r1, c35.x, r8.y
rsq r0.w, r0.w
rcp r1.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r3.xyz, c12
rcp r1.z, r0.w
dp3 r0.w, c6, r3
add r1.x, r1, -c7
add r0.w, -r0, c32
mul r3.y, r1.x, r1.z
mul r3.x, r0.w, c35.y
mov r3.z, c32
texldl r1.zw, r3.xyzz, s4
mul r0.w, r1, c16.x
pow r3, c35.x, r8.z
mad r9.xyz, r1.z, -c15, -r0.w
mov r8.y, r1
pow r1, c35.x, r9.x
mov r8.z, r3
pow r3, c35.x, r9.y
mov r9.x, r1
pow r1, c35.x, r9.z
mov r9.z, r1
mul r1.xyz, r6.zxyw, c12.yzxw
mad r1.xyz, r6.yzxw, c12.zxyw, -r1
dp3 r0.w, r1, r1
mov r9.y, r3
mul r3.xyz, r9, c11
mul r9.xyz, r0.zxyw, c12.yzxw
mad r9.xyz, r0.yzxw, c12.zxyw, -r9
dp3 r1.w, r1, r9
dp3 r3.w, r9, r9
mad r0.w, -c7.x, c7.x, r0
mul r0.w, r3, r0
mad r1.x, r1.w, r1.w, -r0.w
rsq r1.y, r1.x
rcp r9.x, r1.y
texldl r0.w, c35.yyzz, s5
mul r13.xyz, r3, r0.w
dp3 r0.w, r6, c12
cmp r0.w, -r0, c32, c32.z
mul r14.xyz, r11, r13
add r1.y, -r1.w, -r9.x
rcp r3.w, r3.w
mul r1.y, r1, r3.w
cmp r1.x, -r1, c32.z, c32.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r1.x
cmp r6.x, -r0.w, c33.z, r1.y
mad r3.xyz, r0, r6.x, r5
mul r1.xyz, r14, r8
add r3.xyz, r3, -c5
add r5.x, -r1.w, r9
dp3 r1.w, r3, c12
mul r3.x, r3.w, r5
cmp r6.y, -r0.w, c33.x, r3.x
dp3 r3.x, r0, c12
cmp r1.w, -r1, c32.z, c32
mul_pp r0.w, r0, r1
cmp r18.xy, -r0.w, r6, c33.zxzw
rcp r1.w, r10.x
add r0.w, -r18.x, r5
mul r0.x, r3, c17
add r0.z, r18.y, -r11.w
mul r0.x, r0, c32
mad r0.x, c17, c17, r0
rcp r10.x, r11.x
add r3.w, r4, -r5
mul_sat r0.y, r0.w, r1.w
mul_sat r0.z, r1.w, r0
mad r1.w, -r0.y, r0.z, c32
add r3.y, r0.x, c32.w
pow r0, r3.y, c34.y
mad r0.z, r3.x, r3.x, c32.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c32.w, r0.y
mad r1.xyz, r11, r13, -r1
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c34
mul r0.xy, r0, c34.z
abs r0.z, r3.w
mul r0.y, r0, r6.w
mul r3.xyz, -r11, r0.z
mad r0.xyz, r4, r0.x, r0.y
mul r12.xyz, r0, r10
pow r0, c35.x, r3.x
mul r4.xyz, r12, r1.w
mul r4.xyz, r10, r4
mul r16.xyz, r4, r1
pow r1, c35.x, r3.z
mov r9.x, r0
pow r0, c35.x, r3.y
add r1.y, r18, -r5.w
rcp r1.x, r3.w
add r0.w, r4, -r18.x
mov r5, c23
add r5, -c27, r5
mov r6.zw, c32.w
mov r9.z, r1
mov r9.y, r0
mul_sat r0.w, r0, r1.x
mul_sat r1.y, r1.x, r1
mad r0.w, -r0, r1.y, c32
mul r0.xyz, r9, r14
mad r1.xyz, r11, r13, -r0
mul r0.xyz, r0.w, r12
mul r0.xyz, r0, r10
mul r15.xyz, r0, r1
add r13.w, r11, -r10
abs r1.x, r13.w
mul r17.xyz, -r11, r1.x
mov r0, c21
add r1, -c25, r0
mov r0, c20
mad r3, r12.w, r1, c25
add r1, -c24, r0
mad r4, r12.w, r1, c24
texldl r0.w, r7.xyzz, s1
mov r6.y, r0.w
texldl r0.w, r7.xyzz, s0
mov r6.x, r0.w
dp4 r0.x, r4, r6
dp4 r4.x, r4, r4
mad r5, r12.w, r5, c27
mov r1, c22
add r1, -c26, r1
mad r1, r12.w, r1, c26
dp4 r0.y, r3, r6
dp4 r4.y, r3, r3
pow r3, c35.x, r17.y
dp4 r0.w, r5, r6
dp4 r0.z, r1, r6
dp4 r4.z, r1, r1
add r0, r0, c32.y
dp4 r4.w, r5, r5
mad r1, r4, r0, c32.w
pow r0, c35.x, r17.x
mad r5.xyz, r15, r1.w, r16
mov r4.x, r0
mov r4.y, r3
rcp r0.z, r13.w
add r0.w, r18.y, -r10
add r0.y, -r18.x, r11.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c32
pow r0, c35.x, r17.z
mov r4.z, r0
mul r3.xyz, r14, r4
mul r0.xyz, r12, r1.w
mad r3.xyz, r11, r13, -r3
mul r0.xyz, r10, r0
mul r0.xyz, r0, r3
mad r5.xyz, r5, r1.z, r0
add r0.w, r10, -r9
abs r0.y, r0.w
mul r6.xyz, -r11, r0.y
rcp r1.z, r0.w
add r0.x, -r18, r10.w
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r6.x
add r3.x, r18.y, -r9.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r6.y
mad r1.z, -r1.w, r0.y, c32.w
mov r6.x, r0
pow r0, c35.x, r6.z
mov r6.z, r0
mov r6.y, r3
mul r0.xyz, r12, r1.z
mul r3.xyz, r14, r6
mul r0.xyz, r10, r0
mad r3.xyz, r11, r13, -r3
mul r15.xyz, r0, r3
add r0.y, r9.w, -r8.w
rcp r1.z, r0.y
add r0.x, -r18, r9.w
abs r0.y, r0
mul r16.xyz, -r11, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r16.x
add r3.x, r18.y, -r8.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r16.y
mad r1.z, -r1.w, r0.y, c32.w
mov r16.x, r0
pow r0, c35.x, r16.z
mov r16.y, r3
mov r16.z, r0
mul r3.xyz, r12, r1.z
mul r0.xyz, r14, r16
mul r3.xyz, r10, r3
mad r0.xyz, r11, r13, -r0
mul r0.xyz, r3, r0
mad r3.xyz, r5, r1.y, r15
mad r0.xyz, r3, r1.x, r0
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r0.w, r0, c39.z
frc r0.z, r0.w
add r0.w, r0, -r0.z
mul_pp r0.z, r1.y, c39.x
mul_pp r0.x, r0, r1.z
add r0.z, r1.x, -r0
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.z
abs_pp r0.z, r0.x
mul r1.xyz, r6, r16
mul r1.xyz, r4, r1
mul r1.xyz, r8, r1
mul r3.xyz, r9, r1
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c32.y
mul r4.xyz, r3.y, c38
mad r4.xyz, r3.x, c37, r4
mad r1.xyz, r3.z, c36, r4
add r3.x, r1, r1.y
add r1.z, r1, r3.x
mul_pp r0.z, r0, c40.w
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r3.x, r1.z, c35.w
mul r0.z, r0, c41.x
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c40
frc r3.y, r3.x
add r0.w, r3.x, -r3.y
min r0.w, r0, c35
add r3.x, r0.w, c36.w
mul r1.w, r1, c39.z
frc r3.y, r1.w
add r1.w, r1, -r3.y
cmp r3.x, r3, c32.w, c32.z
mul_pp r0.z, r0, c39.x
cmp_pp r0.x, -r0, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r3.x, c37.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c41
mul r1.x, r0.w, c34.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c39.x
add r0.w, r0, -r1.z
min r1.w, r1, c39
mad r1.z, r0.w, c39.y, r1.w
add_pp r0.w, r1.x, c38
exp_pp r1.x, r0.w
mad_pp r0.w, -r3.x, c32.x, c32
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c40.x, c40.y
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r3.x, r1.w
add_pp r1.w, r1, -r3.x
exp_pp r3.x, -r1.w
mad_pp r1.z, r1, r3.x, c32.y
mul r0.x, r0, c41.y
add r0.w, -r0.x, -r0.z
add r0.w, r0, c32
mul r3.xyz, r0.y, c44
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c40.w
mul r3.w, r0.z, c41.x
mad r0.xyz, r0.x, c43, r3
add_pp r1.z, r1.w, c40
frc r3.x, r3.w
mad r0.xyz, r0.w, c42, r0
add r1.w, r3, -r3.x
mul_pp r1.z, r1, c39.x
cmp_pp r1.x, -r1, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.z
mul r1.z, r3.x, c41
add r1.x, r1, r1.w
mul r1.x, r1, c41.y
add r1.w, -r1.x, -r1.z
add r0.w, r1, c32
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r3.xyz, r1.y, c44
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c32.z
mad r3.xyz, r1.y, c43, r3
mul r0.w, r0, r1.x
mad r3.xyz, r0.w, c42, r3
add r1.xyz, -r0, c32.wzzw
max r3.xyz, r3, c32.z
mad r1.xyz, r1, c29.x, r0
mad r3.xyz, -r3, c29.x, r3
else
add r3.xy, r7, c30.xzzw
add r1.xy, r3, c30.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s6
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r3.z, r1.w
add_pp r1.w, r1, -r3.z
exp_pp r3.z, -r1.w
mad_pp r1.z, r1, r3, c32.y
mul_pp r1.z, r1, c40.w
mul r3.z, r1, c41.x
add_pp r1.z, r1.w, c40
frc r3.w, r3.z
add r1.w, r3.z, -r3
add r8.xy, r1, -c30.xzzw
mul r3.z, r3.w, c41
mul_pp r1.z, r1, c39.x
cmp_pp r0.y, -r0, c32.w, c32.z
mad_pp r0.y, r0, c37.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c41
add r3.w, -r0.y, -r3.z
mov r8.z, r7
texldl r1, r8.xyzz, s6
abs_pp r4.x, r1.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r3.w, r3, c32
mul r3.w, r3, r0.x
rcp r3.z, r3.z
mul r0.y, r0, r0.x
mul r3.w, r3, r3.z
exp_pp r4.y, -r4.w
mul r0.y, r3.z, r0
mad_pp r3.z, r4.x, r4.y, c32.y
mul r4.xyz, r0.x, c44
mad r4.xyz, r0.y, c43, r4
mul_pp r0.x, r3.z, c40.w
mul r0.y, r0.x, c41.x
mad r4.xyz, r3.w, c42, r4
frc r3.z, r0.y
add r3.w, r0.y, -r3.z
add_pp r0.x, r4.w, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r1.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r3.w
mul r0.y, r3.z, c41.z
mul r0.x, r0, c41.y
add r1.y, -r0.x, -r0
add r1.y, r1, c32.w
mov r3.z, r7
texldl r3, r3.xyzz, s6
abs_pp r4.w, r3.y
log_pp r5.x, r4.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r5.y, r5.x
add_pp r0.y, r5.x, -r5
mul r5.xyz, r1.x, c44
mad r5.xyz, r0.x, c43, r5
exp_pp r1.x, -r0.y
mad_pp r0.x, r4.w, r1, c32.y
mad r5.xyz, r1.y, c42, r5
mul_pp r0.x, r0, c40.w
mul r1.x, r0, c41
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r3.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r1
max r5.xyz, r5, c32.z
max r4.xyz, r4, c32.z
add r6.xyz, r4, -r5
texldl r4, r7.xyzz, s6
add r7.xy, r8, -c30.zyzw
mul r1.x, r0, c41.y
mul r1.y, r1, c41.z
add r3.y, -r1.x, -r1
mul r0.xy, r7, c31
frc r0.xy, r0
mad r6.xyz, r0.x, r6, r5
abs_pp r5.x, r4.y
log_pp r5.y, r5.x
frc_pp r5.z, r5.y
add_pp r5.w, r5.y, -r5.z
add r3.y, r3, c32.w
mul r3.y, r3, r3.x
rcp r1.y, r1.y
mul r1.x, r1, r3
mul r3.y, r3, r1
exp_pp r5.y, -r5.w
mul r1.x, r1.y, r1
mad_pp r1.y, r5.x, r5, c32
mul r5.xyz, r3.x, c44
mad r5.xyz, r1.x, c43, r5
mad r5.xyz, r3.y, c42, r5
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r5.w, c40.z
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.y, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
rcp r3.y, r1.y
mul r1.x, r1, r4
add r3.x, r3, c32.w
mul r1.y, r3.x, r4.x
abs_pp r3.x, r3.w
mul r1.y, r1, r3
log_pp r4.y, r3.x
mul r1.x, r3.y, r1
frc_pp r3.y, r4
mul r8.xyz, r4.x, c44
mad r8.xyz, r1.x, c43, r8
add_pp r3.y, r4, -r3
exp_pp r1.x, -r3.y
mad r8.xyz, r1.y, c42, r8
mad_pp r1.x, r3, r1, c32.y
mul_pp r1.x, r1, c40.w
mul r1.y, r1.x, c41.x
frc r3.x, r1.y
add_pp r1.x, r3.y, c40.z
add r3.y, r1, -r3.x
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r3.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
abs_pp r3.y, r4.w
log_pp r4.x, r3.y
frc_pp r4.y, r4.x
add_pp r4.x, r4, -r4.y
max r8.xyz, r8, c32.z
max r5.xyz, r5, c32.z
add r5.xyz, r5, -r8
mad r5.xyz, r0.x, r5, r8
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
add r3.x, r3, c32.w
mul r3.x, r3.z, r3
rcp r1.y, r1.y
mul r3.w, r3.x, r1.y
mul r1.x, r3.z, r1
exp_pp r3.x, -r4.x
mul r1.x, r1.y, r1
mad_pp r1.y, r3, r3.x, c32
mul r3.xyz, r3.z, c44
mad r3.xyz, r1.x, c43, r3
mad r3.xyz, r3.w, c42, r3
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
max r8.xyz, r3, c32.z
frc r3.w, r1.y
add_pp r1.x, r4, c40.z
add r4.x, r1.y, -r3.w
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
mul r1.y, r3.w, c41.z
add r1.x, r1, r4
mul r1.x, r1, c41.y
add r3.w, -r1.x, -r1.y
rcp r3.y, r1.y
add r3.x, r3.w, c32.w
mul r1.y, r4.z, r3.x
mul r4.x, r1.y, r3.y
mul r1.y, r4.z, r1.x
mul r4.y, r3, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r4.w, r1.y, -r3
exp_pp r1.y, -r4.w
mad_pp r1.x, r1, r1.y, c32.y
mul_pp r1.y, r1.x, c40.w
abs_pp r1.x, r0.w
mul r5.w, r1.y, c41.x
frc r6.w, r5
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r1.y, r1, -r3.w
exp_pp r3.w, -r1.y
mad_pp r1.x, r1, r3.w, c32.y
mul r3.xyz, r4.z, c44
mad r3.xyz, r4.y, c43, r3
mad r3.xyz, r4.x, c42, r3
max r3.xyz, r3, c32.z
add r4.xyz, r8, -r3
add_pp r4.w, r4, c40.z
add r5.w, r5, -r6
mad r3.xyz, r0.x, r4, r3
mul_pp r4.w, r4, c39.x
cmp_pp r1.w, -r1, c32, c32.z
mad_pp r1.w, r1, c37, r4
add r1.w, r1, r5
mul r4.w, r1, c41.y
mul r5.w, r6, c41.z
mul_pp r1.x, r1, c40.w
mul r1.w, r1.x, c41.x
add_pp r1.x, r1.y, c40.z
frc r3.w, r1
add r1.y, r1.w, -r3.w
add r6.w, -r4, -r5
mul r8.x, r1.z, r4.w
rcp r4.w, r5.w
mul r5.w, r4, r8.x
mul r1.w, r3, c41.z
mul_pp r1.x, r1, c39
cmp_pp r0.w, -r0, c32, c32.z
mad_pp r0.w, r0, c37, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c41.y
add r1.x, -r0.w, -r1.w
add r1.y, r6.w, c32.w
add r3.w, r1.x, c32
mul r6.w, r1.z, r1.y
mul r1.xyz, r1.z, c44
mul r4.w, r6, r4
mad r1.xyz, r5.w, c43, r1
mad r1.xyz, r4.w, c42, r1
mul r4.w, r0.z, r0
mul r3.w, r0.z, r3
rcp r0.w, r1.w
mul r8.xyz, r0.z, c44
mul r0.z, r0.w, r4.w
mad r8.xyz, r0.z, c43, r8
mul r0.z, r3.w, r0.w
mad r8.xyz, r0.z, c42, r8
max r1.xyz, r1, c32.z
max r8.xyz, r8, c32.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r4.xyz, r1, -r3
add r6.xyz, r6, -r5
mad r1.xyz, r0.y, r6, r5
mad r3.xyz, r0.y, r4, r3
endif
mov r0.x, c4.w
mul r0.x, c33.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s7
else
mov r0.xyz, c32.z
endif
mul r3.xyz, r3, r2.w
mad r0.xyz, r0, r3, r2
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r2.xyz, r3.y, c38
mad r2.xyz, r3.x, c37, r2
mad r2.xyz, r3.z, c36, r2
add r1.w, r2.x, r2.y
mul_pp r0.x, r0, r1.z
add r0.z, r2, r1.w
rcp r1.z, r0.z
mul_pp r0.z, r1.y, c39.x
mul r1.zw, r2.xyxy, r1.z
mul r1.y, r1.z, c35.w
frc r1.z, r1.y
add r0.z, r1.x, -r0
mul r0.w, r0, c39.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r1.y, r1, -r1.z
min r1.x, r1.y, c35.w
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
add r1.y, r1.x, c36.w
cmp r0.w, r1.y, c32, c32.z
mad r0.z, r0, c40.x, c40.y
mul_pp r1.y, r0.w, c37.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.y
mul r1.x, r1.w, c39.z
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c34.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c39.x
frc r1.y, r1.x
add r1.x, r1, -r1.y
add r0.x, r0, -r0.z
min r1.x, r1, c39.w
mad r0.z, r0.x, c39.y, r1.x
add_pp r0.x, r0.y, c38.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c32, c32.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r2.y

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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 6 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 5 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 8 [_TexBackground] 2D
SetTexture 4 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 7 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[44] = { program.local[0..31],
		{ 1, 0, 2, -1 },
		{ -1000000, 0.995, 1000000, 0.1 },
		{ 0.75, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625, 1024 },
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
TEMP R17;
TEMP R18;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[0], 2D;
MOVR  R2.xyz, c[5];
MOVR  R3.x, c[33];
TEX   R9, fragment.texcoord[0], texture[1], 2D;
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].z, -R0;
MOVR  R0.z, c[32].w;
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[9].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[32].y;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.z, R2, R1;
MOVR  R0, c[13];
MULR  R3.w, R3.z, R3.z;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.w, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.z, R1;
TEX   R1, fragment.texcoord[0], texture[2], 2D;
MOVR  R0.x, c[33];
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.z, R0.y;
MOVR  R0.y, c[33].x;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.z, R0.z;
MOVR  R0.z, c[33].x;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[19];
SGER  H0.x, c[32].y, R0;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R5, H0.x, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R4, H0.x, R0, c[24];
MOVR  R3, c[26];
ADDR  R3, -R3, c[22];
MADR  R6, H0.x, R3, c[26];
MOVR  R3, c[27];
ADDR  R3, -R3, c[23];
MADR  R7, H0.x, R3, c[27];
MOVR  R3.z, R1.x;
MOVR  R0.z, R1.w;
MOVR  R0.x, R8.w;
MOVR  R1.x, R8.z;
MOVR  R0.y, R9.w;
MOVR  R0.w, c[32].x;
DP4R  R2.w, R0, R7;
DP4R  R2.y, R0, R5;
DP4R  R2.z, R0, R6;
DP4R  R2.x, R0, R4;
DP4R  R0.w, R7, R7;
MOVR  R3.y, R9.x;
MOVR  R3.x, R8;
MOVR  R3.w, c[32].y;
DP4R  R8.x, R7, R3;
DP4R  R0.y, R5, R5;
DP4R  R0.z, R6, R6;
DP4R  R0.x, R4, R4;
MADR  R0, R2, R0, -R0;
ADDR  R0, R0, c[32].x;
MOVR  R2.z, R1.y;
MULR  R1.w, R0.x, R0.y;
MULR  R8.w, R1, R0.z;
MOVR  R2.x, R8.y;
MOVR  R2.y, R9;
MOVR  R2.w, c[32].y;
DP4R  R8.y, R7, R2;
MOVR  R1.y, R9.z;
MOVR  R1.w, c[32].y;
DP4R  R8.z, R7, R1;
DP4R  R7.x, R6, R3;
DP4R  R7.z, R6, R1;
DP4R  R7.y, R6, R2;
MADR  R6.xyz, R0.z, R8, R7;
DP4R  R7.x, R5, R3;
DP4R  R3.x, R4, R3;
DP4R  R7.z, R5, R1;
DP4R  R7.y, R5, R2;
DP4R  R3.y, R4, R2;
MULR  R2.w, R8, R0;
DP4R  R3.z, R4, R1;
MADR  R5.xyz, R0.y, R6, R7;
ADDR  R0.zw, fragment.texcoord[0].xyxy, c[30].xyxz;
MADR  R2.xyz, R0.x, R5, R3;
ADDR  R0.xy, R0.zwzw, c[30].zyzw;
ADDR  R1.xy, R0, -c[30].xzzw;
ADDR  R18.xy, R1, -c[30].zyzw;
TEX   R0.x, R0, texture[4], 2D;
TEX   R1.x, R1, texture[4], 2D;
ADDR  R0.y, R1.x, -R0.x;
TEX   R1.x, fragment.texcoord[0], texture[4], 2D;
TEX   R3.x, R0.zwzw, texture[4], 2D;
MULR  R1.zw, R18.xyxy, c[31].xyxy;
FRCR  R0.zw, R1;
MADR  R0.x, R0.z, R0.y, R0;
ADDR  R1.y, R3.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[4].w;
TEX   R0.x, fragment.texcoord[0], texture[3], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[4];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R8.w, R0.z, R0.x;
ADDR  R0.x, R8.w, -R0.y;
SGTRC HC.x, |R0|, c[28];
IF    NE.x;
MOVR  R3.x, c[33];
MOVR  R3.z, c[33].x;
MOVR  R3.w, c[33].x;
MOVR  R3.y, c[33].x;
MOVR  R9.x, c[0].w;
MOVR  R9.z, c[2].w;
MOVR  R9.y, c[1].w;
MULR  R8.xyz, R9, c[9].x;
ADDR  R5.xyz, R8, -c[5];
DP3R  R7.x, R5, R5;
MOVR  R12.w, c[32].x;
MULR  R1.xy, R18, c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].z, -R0;
MOVR  R0.z, c[32].w;
DP3R  R0.w, R0, R0;
RSQR  R4.w, R0.w;
MULR  R0.xyz, R4.w, R0;
MOVR  R0.w, c[32].y;
DP4R  R4.z, R0, c[2];
DP4R  R4.y, R0, c[1];
DP4R  R4.x, R0, c[0];
DP3R  R5.w, R4, R5;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
MULR  R9.w, R5, R5;
ADDR  R1, R9.w, -R0;
SLTR  R6, R9.w, R0;
MOVXC RC.x, R6;
MOVR  R3.x(EQ), R10;
SGERC HC, R9.w, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R5.w, R1;
MOVXC RC.z, R6;
MOVR  R3.z(EQ), R10.x;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R3.z(NE.y), -R5.w, R0.x;
MOVXC RC.y, R6;
RSQR  R0.x, R1.w;
MOVR  R3.w(EQ.z), R10.x;
RCPR  R0.x, R0.x;
ADDR  R3.w(NE), -R5, R0.x;
RSQR  R0.x, R1.y;
MOVR  R3.y(EQ), R10.x;
RCPR  R0.x, R0.x;
ADDR  R3.y(NE.x), -R5.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
ADDR  R6, R9.w, -R0;
SLTR  R7, R9.w, R0;
RSQR  R1.y, R6.x;
MOVR  R1.x, c[33].z;
MOVXC RC.x, R7;
MOVR  R1.x(EQ), R10;
SGERC HC, R9.w, R0.yzxw;
RCPR  R1.y, R1.y;
ADDR  R1.x(NE.z), -R5.w, -R1.y;
RSQR  R0.x, R6.z;
MOVR  R1.y, c[33].z;
MOVR  R0.w, c[33].z;
MOVXC RC.z, R7;
MOVR  R0.w(EQ.z), R10.x;
RCPR  R0.x, R0.x;
ADDR  R0.w(NE.y), -R5, -R0.x;
MOVXC RC.y, R7;
RSQR  R0.x, R6.w;
MULR  R7.xyz, R4.zxyw, c[12].yzxw;
MADR  R7.xyz, R4.yzxw, c[12].zxyw, -R7;
MOVR  R1.y(EQ), R10.x;
MOVR  R1.z, c[33];
MOVXC RC.z, R7.w;
MOVR  R1.z(EQ), R10.x;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R5.w, -R0.x;
RSQR  R0.x, R6.y;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R5.w, -R0.x;
MOVR  R0.xyz, c[5];
MADR  R0.xyz, R9, c[9].x, -R0;
DP3R  R1.w, R0, R4;
MOVR  R5.w, c[18].x;
DP3R  R7.w, R0, R0;
ADDR  R5.w, R5, c[7].x;
MADR  R6.x, -R5.w, R5.w, R7.w;
MULR  R6.w, R1, R1;
ADDR  R6.y, R6.w, -R6.x;
RSQR  R6.y, R6.y;
MOVR  R5.w, c[33].z;
SLTRC HC.x, R6.w, R6;
MOVR  R5.w(EQ.x), R10.x;
SGERC HC.x, R6.w, R6;
RCPR  R6.y, R6.y;
ADDR  R5.w(NE.x), -R1, -R6.y;
MOVXC RC.x, R5.w;
MULR  R6.xyz, R0.zxyw, c[12].yzxw;
MADR  R6.xyz, R0.yzxw, c[12].zxyw, -R6;
DP3R  R0.x, R0, c[12];
SLER  H0.x, R0, c[32].y;
DP3R  R9.x, R6, R6;
DP3R  R6.x, R6, R7;
DP3R  R6.z, R7, R7;
MADR  R6.y, -c[7].x, c[7].x, R9.x;
MULR  R7.y, R6.z, R6;
MULR  R7.x, R6, R6;
ADDR  R6.y, R7.x, -R7;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
ADDR  R0.y, -R6.x, R6;
SGTR  H0.y, R7.x, R7;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVR  R5.w(LT.x), c[33].z;
MOVXC RC.x, H0;
RCPR  R6.z, R6.z;
MOVR  R0.z, c[33].x;
MULR  R0.z(NE.x), R6, R0.y;
ADDR  R0.y, -R6.x, -R6;
MOVR  R0.x, c[33].z;
MULR  R0.x(NE), R0.y, R6.z;
MOVR  R0.y, R0.z;
MOVR  R18.zw, R0.xyxy;
MADR  R0.xyz, R4, R0.x, R8;
ADDR  R0.xyz, R0, -c[5];
DP3R  R0.x, R0, c[12];
SGTR  H0.y, R0.x, c[32];
MADR  R0.z, -c[8].x, c[8].x, R7.w;
MULXC HC.x, H0, H0.y;
MOVR  R18.zw(NE.x), c[33].xyzx;
ADDR  R6.x, R6.w, -R0.z;
RSQR  R6.x, R6.x;
RCPR  R6.x, R6.x;
ADDR  R6.y, -R1.w, -R6.x;
ADDR  R1.w, -R1, R6.x;
MAXR  R6.x, R6.y, c[32].y;
MAXR  R6.y, R1.w, c[32];
MOVR  R1.w, R1.z;
MOVR  R1.z, R0.w;
MOVR  R0.xy, c[32].y;
SLTRC HC.x, R6.w, R0.z;
MOVR  R0.xy(EQ.x), R10;
SGERC HC.x, R6.w, R0.z;
MOVR  R0.xy(NE.x), R6;
MAXR  R9.w, R0.x, c[32].y;
DP4R  R0.z, R1, c[24];
DP4R  R0.w, R3, c[20];
ADDR  R6.x, R0.w, -R0.z;
DP4R  R0.w, R3, c[19];
SGER  H0.y, c[32], R0.w;
MADR  R6.x, H0.y, R6, R0.z;
DP4R  R0.w, R1, c[25];
DP4R  R0.z, R3, c[21];
ADDR  R0.z, R0, -R0.w;
MADR  R6.y, H0, R0.z, R0.w;
RCPR  R0.z, R4.w;
MULR  R4.w, R8, R0.z;
MADR  R5.w, -R4, c[9].x, R5;
MOVR  R0.zw, c[33].xywy;
MULR  R0.w, R0, c[4];
SGER  H0.x, R8.w, R0.w;
MULR  R4.w, R4, c[9].x;
MADR  R0.w, H0.x, R5, R4;
MINR  R4.w, R0.y, R0;
MINR  R0.w, R4, R6.x;
MAXR  R10.w, R9, R0;
MINR  R0.y, R4.w, R6;
MAXR  R11.w, R10, R0.y;
DP4R  R0.y, R1, c[26];
DP4R  R0.x, R3, c[22];
ADDR  R0.x, R0, -R0.y;
MADR  R0.x, H0.y, R0, R0.y;
MINR  R0.x, R4.w, R0;
MAXR  R5.w, R11, R0.x;
ADDR  R6.z, R5.w, -R11.w;
ADDR  R6.xy, R18.wzzw, -R5.w;
RCPR  R0.x, R6.z;
ADDR  R7.zw, R18.xywz, -R11.w;
MULR_SAT R0.y, R0.x, R7.z;
MULR_SAT R0.x, -R6.y, R0;
MULR  R0.w, R0.x, R0.y;
DP3R  R0.x, R4, c[12];
MULR  R0.y, R0.x, c[17].x;
MULR  R0.y, R0, c[32].z;
MULR  R0.x, R0, R0;
MADR  R0.y, c[17].x, c[17].x, R0;
ADDR  R0.y, R0, c[32].x;
POWR  R6.y, R0.y, c[34].y;
ADDR  R0.y, R12.w, c[17].x;
MADR  R4.xyz, R4, R9.w, R5;
MADR  R0.x, R0, c[34], c[34];
RCPR  R6.y, R6.y;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R6;
MULR  R7.xy, R0, c[34].z;
MOVR  R6.y, c[34].w;
MULR  R6.w, R6.y, c[16].x;
MULR  R0.xyz, R0.z, c[15];
ADDR  R11.xyz, R0, R6.w;
MULR  R6.y, R7, R6.w;
MADR  R0.xyz, R0, R7.x, R6.y;
RCPR  R10.x, R11.x;
RCPR  R10.z, R11.z;
RCPR  R10.y, R11.y;
MULR  R12.xyz, R0, R10;
MADR  R0.xyz, R12, -R0.w, R12;
DP3R  R0.w, R4, R4;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R4.x, R0.w, -c[7];
MOVR  R0.w, c[7].x;
ADDR  R0.w, -R0, c[8].x;
RCPR  R0.w, R0.w;
MULR  R5.y, R4.x, R0.w;
MOVR  R4.xyz, c[6];
DP3R  R0.w, R4, c[12];
MADR  R5.x, -R0.w, c[35].y, c[35].y;
TEX   R13.zw, R5, texture[5], 2D;
MULR  R5.xyz, -R11, |R6.z|;
MULR  R0.w, R13, c[16].x;
MADR  R4.xyz, R13.z, -c[15], -R0.w;
MULR  R0.xyz, R10, R0;
RCPR  R6.y, |R6.z|;
POWR  R7.x, c[35].x, R5.x;
POWR  R7.y, c[35].x, R5.y;
POWR  R7.z, c[35].x, R5.z;
TEX   R0.w, c[35].y, texture[6], 2D;
POWR  R4.x, c[35].x, R4.x;
POWR  R4.z, c[35].x, R4.z;
POWR  R4.y, c[35].x, R4.y;
MULR  R4.xyz, R4, c[11];
MULR  R13.xyz, R4, R0.w;
ADDR  R14.xyz, R13, -R13;
MULR  R4.xyz, R14, R6.y;
MADR  R4.xyz, R11, R13, R4;
MADR  R4.xyz, -R7, R4, R4;
MULR  R17.xyz, R0, R4;
DP4R  R0.x, R1, c[27];
DP4R  R0.y, R3, c[23];
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R4.w, R0;
MAXR  R0.w, R5, R0.x;
ADDR  R1.w, R0, -R5;
MULR  R3.xyz, -R11, |R1.w|;
ADDR  R4.xy, R18.wzzw, -R0.w;
RCPR  R0.x, R1.w;
RCPR  R1.x, |R1.w|;
MULR_SAT R0.y, R0.x, R6.x;
MULR_SAT R0.x, -R4.y, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R12, -R0.x, R12;
MULR  R1.xyz, R14, R1.x;
MOVR  R5, c[27];
ADDR  R5, -R5, c[23];
MULR  R0.xyz, R10, R0;
ADDR  R0.w, R4, -R0;
MADR  R5, H0.y, R5, c[27];
POWR  R8.x, c[35].x, R3.x;
POWR  R8.y, c[35].x, R3.y;
POWR  R8.z, c[35].x, R3.z;
MULR  R3.xyz, |R0.w|, -R11;
MADR  R1.xyz, R11, R13, R1;
MADR  R1.xyz, -R8, R1, R1;
MULR  R16.xyz, R0, R1;
RCPR  R0.x, R0.w;
RCPR  R1.x, |R0.w|;
MULR  R1.xyz, R14, R1.x;
MULR_SAT R0.y, R0.x, R4.x;
ADDR  R0.z, R4.w, -R18;
MULR_SAT R0.x, R0.z, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R12, R12;
POWR  R9.x, c[35].x, R3.x;
POWR  R9.y, c[35].x, R3.y;
POWR  R9.z, c[35].x, R3.z;
MADR  R1.xyz, R11, R13, R1;
MADR  R1.xyz, -R9, R1, R1;
MULR  R0.xyz, R0, R10;
MULR  R15.xyz, R0, R1;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R4, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R3, H0.y, R0, c[24];
TEX   R0.w, R18, texture[2], 2D;
MOVR  R0.z, R0.w;
TEX   R1.w, R18, texture[1], 2D;
MOVR  R0.y, R1.w;
TEX   R0.w, R18, texture[0], 2D;
MOVR  R0.x, R0.w;
MOVR  R0.w, c[32].x;
MOVR  R1, c[26];
ADDR  R1, -R1, c[22];
MADR  R1, H0.y, R1, c[26];
DP4R  R6.x, R0, R3;
DP4R  R6.z, R0, R1;
DP4R  R6.y, R0, R4;
DP4R  R6.w, R0, R5;
DP4R  R0.z, R1, R1;
DP4R  R0.x, R3, R3;
ADDR  R1.w, R11, -R10;
RCPR  R3.x, R1.w;
DP4R  R0.y, R4, R4;
DP4R  R0.w, R5, R5;
MADR  R0, R6, R0, -R0;
ADDR  R0, R0, c[32].x;
MADR  R1.xyz, R15, R0.w, R16;
MADR  R1.xyz, R1, R0.z, R17;
ADDR  R0.zw, R18.xywz, -R10.w;
MULR_SAT R3.y, -R7.w, R3.x;
MULR_SAT R0.z, R3.x, R0;
MULR  R0.z, R3.y, R0;
MULR  R3.xyz, -R11, |R1.w|;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R1.w|;
MULR  R5.xyz, R14, R0.z;
POWR  R3.x, c[35].x, R3.x;
POWR  R3.y, c[35].x, R3.y;
POWR  R3.z, c[35].x, R3.z;
MADR  R5.xyz, R11, R13, R5;
MADR  R5.xyz, -R3, R5, R5;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R5;
MADR  R1.xyz, R1, R0.y, R4;
ADDR  R0.y, R10.w, -R9.w;
MULR  R5.xyz, -R11, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R18, -R9;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R0.y|;
MULR  R6.xyz, R14, R0.z;
POWR  R5.x, c[35].x, R5.x;
POWR  R5.y, c[35].x, R5.y;
POWR  R5.z, c[35].x, R5.z;
MADR  R6.xyz, R11, R13, R6;
MADR  R6.xyz, -R5, R6, R6;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R6;
MADR  R0.xyz, R1, R0.x, R4;
MULR  R1.xyz, R0.y, c[38];
MADR  R1.xyz, R0.x, c[37], R1;
MADR  R0.xyz, R0.z, c[36], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].z;
SGER  H0.x, R0, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[34].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[37].w;
MULR  R0.z, R0.w, c[39].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[36].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[39].y;
MADR  R0.x, R0, c[38].w, R0.z;
MADR  H0.z, R0.x, c[39], R12.w;
MADH  H0.x, H0, c[32].z, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.z, H0, c[40].x;
FLRR  R0.x, R0.z;
ADDH  H0.y, H0, c[36].w;
FRCR  R0.z, R0;
MULR  R0.z, R0, c[40];
RCPR  R1.x, R0.z;
MULH  H0.y, H0, c[37].w;
SGEH  H0.x, c[32].y, H0;
MADH  H0.x, H0, c[35].w, H0.y;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].y;
ADDR  R0.w, -R0.x, -R0.z;
MADR  R0.w, R0, R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R1.y, R1.x, R0.x;
MULR  R0.xyz, R0.y, c[43];
MULR  R0.w, R0, R1.x;
MADR  R0.xyz, R1.y, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R0.xyz, R0, c[32].y;
ADDR  R1.xyz, -R0, c[32].xyyw;
MADR  R0.xyz, R1, c[29].x, R0;
MULR  R1.xyz, R3, R5;
MULR  R1.xyz, R7, R1;
MULR  R1.xyz, R8, R1;
MULR  R1.xyz, R9, R1;
MULR  R3.xyz, R1.y, c[38];
MADR  R3.xyz, R1.x, c[37], R3;
MADR  R1.xyz, R1.z, c[36], R3;
ADDR  R0.w, R1.x, R1.y;
ADDR  R0.w, R1.z, R0;
RCPR  R0.w, R0.w;
MULR  R1.zw, R1.xyxy, R0.w;
MULR  R0.w, R1.z, c[35].z;
FLRR  R0.w, R0;
MINR  R0.w, R0, c[35].z;
SGER  H0.x, R0.w, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.w, R0, -H0.y;
MULR  R1.x, R0.w, c[34].w;
FLRR  H0.y, R1.x;
MULH  H0.z, H0.y, c[37].w;
MULR  R1.x, R1.w, c[39];
FLRR  R1.x, R1;
ADDH  H0.y, H0, -c[36].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.w, R0, -H0.z;
MINR  R1.x, R1, c[39].y;
MADR  R0.w, R0, c[38], R1.x;
MADR  H0.z, R0.w, c[39], R12.w;
MADH  H0.x, H0, c[32].z, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
FLRR  R1.x, R0.w;
FRCR  R0.w, R0;
MULR  R1.z, R0.w, c[40];
ADDH  H0.y, H0, c[36].w;
RCPR  R1.w, R1.z;
MULH  H0.y, H0, c[37].w;
SGEH  H0.x, c[32].y, H0;
MADH  H0.x, H0, c[35].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.x, R1, c[40].y;
ADDR  R0.w, -R1.x, -R1.z;
MADR  R0.w, R0, R1.y, R1.y;
MULR  R1.x, R1, R1.y;
MULR  R3.x, R1.w, R1;
MULR  R1.xyz, R1.y, c[43];
MADR  R1.xyz, R3.x, c[42], R1;
MULR  R0.w, R0, R1;
MADR  R1.xyz, R0.w, c[41], R1;
MAXR  R1.xyz, R1, c[32].y;
MADR  R1.xyz, -R1, c[29].x, R1;
ELSE;
ADDR  R6.xy, R18, c[30].xzzw;
ADDR  R0.xy, R6, c[30].zyzw;
TEX   R3, R0, texture[7], 2D;
ADDR  R7.xy, R0, -c[30].xzzw;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R3|, H0;
MADH  H0.y, H0, c[39].w, -c[39].w;
MULR  R0.z, H0.y, c[40].x;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[40].z;
ADDH  H0.x, H0, c[36].w;
MULH  H0.z, H0.x, c[37].w;
SGEH  H0.xy, c[32].y, R3.ywzw;
TEX   R4, R7, texture[7], 2D;
MADH  H0.x, H0, c[35].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[40].y;
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[36].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R3.x;
MADR  R0.w, R0, R3.x, R3.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R3.x, c[43];
MADR  R0.xyz, R1.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
MAXR  R1.xyz, R0, c[32].y;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[32].y, R4.xyyw;
MULH  H0.x, H0, c[37].w;
MULR  R0.z, R0.x, c[40];
FLRR  R0.y, R0.w;
MADH  H0.x, H0.z, c[35].w, H0;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[40].y;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R4.x, R4.x;
RCPR  R0.w, R0.z;
MULR  R1.w, R0.y, R0;
MULR  R3.x, R0, R4;
MULR  R0.w, R0, R3.x;
MULR  R0.xyz, R4.x, c[43];
MADR  R5.xyz, R0.w, c[42], R0;
TEX   R0, R6, texture[7], 2D;
MADR  R5.xyz, R1.w, c[41], R5;
LG2H  H0.x, |R0.y|;
MAXR  R5.xyz, R5, c[32].y;
ADDR  R6.xyz, R1, -R5;
TEX   R1, R18, texture[7], 2D;
ADDR  R18.xy, R7, -c[30].zyzw;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R4.x, H0.z, c[40];
FRCR  R4.y, R4.x;
MULR  R3.xy, R18, c[31];
FRCR  R3.xy, R3;
MADR  R5.xyz, R3.x, R6, R5;
ADDH  H0.x, H0, c[36].w;
SGEH  H1.xy, c[32].y, R0.ywzw;
MULH  H0.x, H0, c[37].w;
SGEH  H1.zw, c[32].y, R1.xyyw;
FLRR  R4.x, R4;
MADH  H0.x, H1, c[35].w, H0;
ADDR  R0.y, H0.x, R4.x;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R4.x, R0.y, c[40].y;
MULR  R4.y, R4, c[40].z;
ADDR  R0.y, -R4.x, -R4;
RCPR  R4.y, R4.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R4.x, R4, R0;
MULR  R0.y, R0, R4;
MULR  R4.x, R4.y, R4;
MULR  R6.xyz, R0.x, c[43];
MADR  R6.xyz, R4.x, c[42], R6;
MADH  H0.z, H0, c[39].w, -c[39].w;
MADR  R6.xyz, R0.y, c[41], R6;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MADH  H0.x, H1.z, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R1.y, R0.x, c[40];
MULR  R0.y, R0, c[40].z;
ADDR  R0.x, -R1.y, -R0.y;
MULR  R1.y, R1, R1.x;
MADR  R0.x, R0, R1, R1;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.y, R0, R1;
MULR  R7.xyz, R1.x, c[43];
MADR  R7.xyz, R0.y, c[42], R7;
MADR  R7.xyz, R0.x, c[41], R7;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[32].y;
MAXR  R6.xyz, R6, c[32].y;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R3.x, R6, R7;
MADH  H0.x, H1.y, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MULR  R0.y, R0, c[40].z;
MULR  R0.x, R0, c[40].y;
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[43];
MADR  R0.xyz, R1.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R7.xyz, R0, c[32].y;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.x, H0.z, c[40];
FRCR  R0.y, R0.x;
MULR  R0.z, R0.y, c[40];
RCPR  R1.x, R0.z;
MADH  H0.x, H1.w, c[35].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].y;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R1.z, R0, R1.z;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[36].w;
MULR  R0.w, R0.y, R1.x;
MULR  R1.y, R1.z, R0.x;
MULR  R0.xyz, R1.z, c[43];
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, R1.x, c[42], R0;
MADR  R0.xyz, R0.w, c[41], R0;
MAXR  R0.xyz, R0, c[32].y;
ADDR  R1.xyz, R7, -R0;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
MULH  H0.x, H0, c[37].w;
MADH  H0.z, H0.w, c[35].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
MULR  R4.x, R1.w, c[40].y;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULR  R4.y, R0.w, c[40].z;
MULH  H0.z, |R3.w|, H0;
ADDR  R4.w, -R4.x, -R4.y;
MADH  H0.z, H0, c[39].w, -c[39].w;
MULR  R0.w, H0.z, c[40].x;
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[36].w;
MULH  H0.x, H0, c[37].w;
MADR  R4.w, R4.z, R4, R4.z;
RCPR  R5.w, R4.y;
MULR  R6.w, R4.z, R4.x;
MADR  R1.xyz, R3.x, R1, R0;
MULR  R1.w, R1, c[40].z;
MULR  R4.w, R4, R5;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[35].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[40].y;
ADDR  R3.w, -R0, -R1;
MULR  R4.xyz, R4.z, c[43];
MULR  R6.w, R5, R6;
MADR  R4.xyz, R6.w, c[42], R4;
MADR  R4.xyz, R4.w, c[41], R4;
MULR  R4.w, R3.z, R0;
RCPR  R0.w, R1.w;
MAXR  R4.xyz, R4, c[32].y;
MULR  R1.w, R0, R4;
MADR  R3.w, R3.z, R3, R3.z;
MULR  R7.xyz, R3.z, c[43];
MADR  R7.xyz, R1.w, c[42], R7;
MULR  R0.w, R3, R0;
MADR  R7.xyz, R0.w, c[41], R7;
MAXR  R7.xyz, R7, c[32].y;
ADDR  R7.xyz, R7, -R4;
MADR  R0.xyz, R3.x, R7, R4;
ADDR  R4.xyz, R0, -R1;
MADR  R0.xyz, R3.y, R5, R6;
MADR  R1.xyz, R3.y, R4, R1;
ENDIF;
MOVR  R0.w, c[33].y;
MULR  R0.w, R0, c[4];
SGTRC HC.x, R8.w, R0.w;
IF    NE.x;
TEX   R3.xyz, R18, texture[8], 2D;
ELSE;
MOVR  R3.xyz, c[32].y;
ENDIF;
MULR  R1.xyz, R1, R2.w;
MADR  R2.xyz, R3, R1, R2;
ADDR  R0.xyz, R2, R0;
MULR  R2.xyz, R0.y, c[38];
MADR  R2.xyz, R0.x, c[37], R2;
MADR  R0.xyz, R0.z, c[36], R2;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[38];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].z;
SGER  H0.x, R0, c[35].w;
MULH  H0.y, H0.x, c[35].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[34].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[36].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[37].w;
MADR  R2.xyz, R1.x, c[37], R2;
MADR  R1.xyz, R1.z, c[36], R2;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[35];
MULR  R0.w, R0, c[39].x;
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[39].x;
FLRR  R0.y, R0;
MADH  H0.x, H0, c[32].z, H0.z;
MINR  R0.z, R0, c[35];
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[35].w;
MULH  H0.y, H0.z, c[35].w;
MINR  R0.w, R0, c[39].y;
MADR  R0.w, R0.x, c[38], R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[32];
MADR  H0.y, R0.w, c[39].z, R0.x;
MULR  R0.w, R0.z, c[34];
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[37].w;
ADDH  H0.x, H0, -c[36].w;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[39];
MADR  R0.y, R0.z, c[38].w, R0;
MADR  H0.z, R0.y, c[39], R0.x;
MADH  H0.x, H0.y, c[32].z, H0;
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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 6 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 5 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 8 [_TexBackground] 2D
SetTexture 4 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 7 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

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
def c32, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c33, -1000000.00000000, 0.99500000, 1000000.00000000, 0.10000000
def c34, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c35, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c36, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c37, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c38, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c39, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c40, 0.00097656, 1.00000000, 15.00000000, 1024.00000000
def c41, 0.00390625, 0.00476190, 0.63999999, 0
def c42, 0.07530000, -0.25430000, 1.18920004, 0
def c43, 2.56509995, -1.16649997, -0.39860001, 0
def c44, -1.02170002, 1.97770000, 0.04390000, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c32.x, c32.y
mov r6, c23
mov r3, c22
add r3, -c26, r3
texldl r9, v0, s0
texldl r10, v0, s1
mov r0.z, c32.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c32.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c7
mov r0.y, c7.x
add r0.y, c13, r0
add r6, -c27, r6
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c9.x
add r2.xyz, r2, -c5
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c13, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c32.w, c32.z
cmp r0.x, r0, r1.w, c33
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c32.w, c32.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c33.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c7.x
add r1.y, c13.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c7.x
add r0.w, c13.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c32, c32.z
cmp r1.z, r1, r1.w, c33.x
cmp_pp r0.z, r1.x, c32.w, c32
cmp r1.x, r1, r1.w, c33
cmp r0.w, -r0, r1.z, r2.x
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c19
cmp r2.z, -r0.x, c32.w, c32
mad r7, r2.z, r6, c27
mad r6, r2.z, r3, c26
mov r1, c21
add r1, -c25, r1
mad r5, r2.z, r1, c25
texldl r1, v0, s2
mov r3.z, r1.x
mov r0, c20
add r0, -c24, r0
mad r4, r2.z, r0, c24
mov r0.z, r1.w
mov r1.x, r9.z
mov r0.y, r10.w
mov r0.w, c32
mov r0.x, r9.w
dp4 r2.w, r7, r0
dp4 r2.x, r4, r0
dp4 r2.y, r5, r0
dp4 r2.z, r6, r0
add r2, r2, c32.y
dp4 r0.w, r7, r7
dp4 r0.x, r4, r4
mov r3.y, r10.x
mov r3.x, r9
mov r3.w, c32.z
dp4 r9.x, r7, r3
mov r1.w, c32.z
dp4 r0.y, r5, r5
dp4 r0.z, r6, r6
mad r0, r0, r2, c32.w
mov r2.z, r1.y
mov r1.y, r10.z
dp4 r9.z, r7, r1
mov r2.x, r9.y
mov r2.y, r10
mov r2.w, c32.z
dp4 r9.y, r7, r2
dp4 r7.x, r6, r3
dp4 r7.z, r6, r1
dp4 r7.y, r6, r2
mad r6.xyz, r0.z, r9, r7
dp4 r7.x, r5, r3
dp4 r3.x, r4, r3
dp4 r3.z, r4, r1
dp4 r7.z, r5, r1
dp4 r3.y, r4, r2
dp4 r7.y, r5, r2
mad r5.xyz, r0.y, r6, r7
mad r2.xyz, r0.x, r5, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r3.xy, v0, c30.xzzw
add r0.xy, r3, c30.zyzw
add r4.xy, r0, -c30.xzzw
mov r0.z, v0.w
mov r4.z, v0.w
mov r3.z, v0.w
add r7.xy, r4, -c30.zyzw
mul r1.zw, r7.xyxy, c31.xyxy
texldl r0.x, r0.xyzz, s4
texldl r1.x, r4.xyzz, s4
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s4
texldl r3.x, r3.xyzz, s4
add r0.z, r3.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c4.w, -c4.z
rcp r0.y, r0.x
mul r0.y, r0, c4.w
texldl r0.x, v0, s3
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c4.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r2.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c28.x
mad r0.xy, r7, c32.x, c32.y
mul r0.xy, r0, c4
mov r0.z, c32.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c32.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.x, c7
mov r1.y, c7.x
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r5.xyz, r3, c9.x
add r6.xyz, r5, -c5
dp3 r4.x, r6, r0
dp3 r4.y, r6, r6
add r1.y, c14, r1
mad r1.z, -r1.y, r1.y, r4.y
mad r1.w, r4.x, r4.x, -r1.z
rsq r3.x, r1.w
add r1.x, c14, r1
mad r1.x, -r1, r1, r4.y
mad r1.x, r4, r4, -r1
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r4.x, -r1.y
cmp_pp r1.y, r1.x, c32.w, c32.z
cmp r1.x, r1, r8, c33.z
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c32.w, c32.z
rcp r3.x, r3.x
cmp r1.w, r1, r8.x, c33.z
add r3.x, -r4, -r3
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r3.x, c14.w, r1.z
mad r1.w, -r1, r1, r4.y
mad r1.z, r4.x, r4.x, -r1.w
mad r3.x, -r3, r3, r4.y
mad r3.y, r4.x, r4.x, -r3.x
rsq r1.w, r1.z
rcp r1.w, r1.w
add r3.x, -r4, -r1.w
cmp_pp r1.w, r1.z, c32, c32.z
cmp r1.z, r1, r8.x, c33
cmp r1.z, -r1.w, r1, r3.x
rsq r3.z, r3.y
rcp r3.z, r3.z
cmp r3.x, r3.y, r8, c33.z
add r3.z, -r4.x, -r3
cmp_pp r1.w, r3.y, c32, c32.z
cmp r1.w, -r1, r3.x, r3.z
mov r3.x, c7
add r3.y, c13.x, r3.x
mov r3.x, c7
add r3.z, c13.y, r3.x
mad r3.y, -r3, r3, r4
mad r3.x, r4, r4, -r3.y
mad r3.z, -r3, r3, r4.y
mad r3.w, r4.x, r4.x, -r3.z
rsq r3.y, r3.x
rcp r3.y, r3.y
add r3.z, -r4.x, r3.y
cmp_pp r3.y, r3.x, c32.w, c32.z
cmp r3.x, r3, r8, c33
cmp r3.x, -r3.y, r3, r3.z
rsq r4.w, r3.w
cmp_pp r3.y, r3.w, c32.w, c32.z
rcp r4.w, r4.w
dp4 r4.z, r1, c24
dp4 r8.z, r1, c25
cmp r3.w, r3, r8.x, c33.x
add r4.w, -r4.x, r4
cmp r3.y, -r3, r3.w, r4.w
mov r3.z, c7.x
add r3.w, c13, r3.z
mad r3.w, -r3, r3, r4.y
mad r5.w, r4.x, r4.x, -r3
rsq r3.w, r5.w
rcp r4.w, r3.w
mov r3.z, c7.x
add r3.z, c13, r3
mad r3.z, -r3, r3, r4.y
mad r3.z, r4.x, r4.x, -r3
add r6.w, -r4.x, r4
rsq r3.w, r3.z
rcp r4.w, r3.w
cmp_pp r3.w, r5, c32, c32.z
cmp r5.w, r5, r8.x, c33.x
cmp r3.w, -r3, r5, r6
add r5.w, -r4.x, r4
cmp_pp r4.w, r3.z, c32, c32.z
cmp r3.z, r3, r8.x, c33.x
cmp r3.z, -r4.w, r3, r5.w
dp4 r4.w, r3, c20
add r6.w, r4, -r4.z
dp4 r5.w, r3, c19
cmp r12.w, -r5, c32, c32.z
mad r4.z, r12.w, r6.w, r4
dp4 r6.w, r3, c21
add r8.w, r6, -r8.z
mov r4.w, c7.x
add r4.w, c18.x, r4
mad r4.w, -r4, r4, r4.y
mad r4.w, r4.x, r4.x, -r4
rsq r5.w, r4.w
rcp r5.w, r5.w
add r6.w, -r4.x, -r5
cmp_pp r5.w, r4, c32, c32.z
cmp r4.w, r4, r8.x, c33.z
cmp r4.w, -r5, r4, r6
rcp r0.w, r0.w
mul r5.w, r7, r0
cmp r6.w, r4, r4, c33.z
mad r6.w, -r5, c9.x, r6
mad r4.y, -c8.x, c8.x, r4
mad r4.w, r4.x, r4.x, -r4.y
rsq r4.y, r4.w
mov r0.w, c4
mad r0.w, c33.y, -r0, r7
mad r8.z, r12.w, r8.w, r8
cmp r8.xy, r4.w, r8, c32.z
rcp r4.y, r4.y
cmp r0.w, r0, c32, c32.z
mul r5.w, r5, c9.x
mad r5.w, r0, r6, r5
add r0.w, -r4.x, -r4.y
add r4.y, -r4.x, r4
max r4.x, r0.w, c32.z
cmp_pp r0.w, r4, c32, c32.z
max r4.y, r4, c32.z
cmp r4.xy, -r0.w, r8, r4
min r5.w, r4.y, r5
max r8.w, r4.x, c32.z
dp4 r4.x, r1, c26
dp4 r1.y, r1, c27
min r0.w, r5, r4.z
max r9.w, r8, r0
min r4.y, r5.w, r8.z
dp4 r0.w, r3, c22
add r0.w, r0, -r4.x
dp4 r1.x, r3, c23
add r1.x, r1, -r1.y
mad r0.w, r12, r0, r4.x
max r10.w, r9, r4.y
mad r1.x, r12.w, r1, r1.y
min r0.w, r5, r0
max r11.w, r10, r0
min r1.x, r5.w, r1
max r6.w, r11, r1.x
add r10.x, r6.w, -r11.w
mov r0.w, c16.x
mov r1.xyz, c15
mad r4.xyz, r0, r8.w, r6
mul r1.w, c34, r0
dp3 r0.w, r4, r4
mul r1.xyz, c33.w, r1
add r11.xyz, r1, r1.w
abs r3.x, r10
mul r8.xyz, -r11, r3.x
pow r3, c35.x, r8.x
mov r8.x, r3
rcp r10.z, r11.z
rcp r10.y, r11.y
pow r3, c35.x, r8.y
rsq r0.w, r0.w
rcp r3.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r4.xyz, c12
rcp r3.z, r0.w
dp3 r0.w, c6, r4
add r3.x, r3, -c7
add r0.w, -r0, c32
mul r4.y, r3.x, r3.z
mul r4.x, r0.w, c35.y
mov r4.z, c32
texldl r3.zw, r4.xyzz, s5
mul r0.w, r3, c16.x
pow r4, c35.x, r8.z
mad r9.xyz, r3.z, -c15, -r0.w
mov r8.y, r3
pow r3, c35.x, r9.x
mov r8.z, r4
pow r4, c35.x, r9.y
mov r9.x, r3
pow r3, c35.x, r9.z
mov r9.z, r3
mul r3.xyz, r6.zxyw, c12.yzxw
mad r3.xyz, r6.yzxw, c12.zxyw, -r3
dp3 r0.w, r3, r3
mov r9.y, r4
mul r4.xyz, r9, c11
mul r9.xyz, r0.zxyw, c12.yzxw
mad r9.xyz, r0.yzxw, c12.zxyw, -r9
dp3 r3.w, r3, r9
dp3 r4.w, r9, r9
mad r0.w, -c7.x, c7.x, r0
mul r0.w, r4, r0
mad r3.x, r3.w, r3.w, -r0.w
rsq r3.y, r3.x
rcp r9.x, r3.y
add r3.y, -r3.w, -r9.x
rcp r4.w, r4.w
texldl r0.w, c35.yyzz, s6
mul r13.xyz, r4, r0.w
mul r14.xyz, r11, r13
dp3 r0.w, r6, c12
cmp r0.w, -r0, c32, c32.z
mul r4.xyz, r14, r8
mul r3.y, r3, r4.w
add r3.w, -r3, r9.x
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r3.x
cmp r6.x, -r0.w, c33.z, r3.y
mad r3.xyz, r0, r6.x, r5
add r3.xyz, r3, -c5
dp3 r3.x, r3, c12
mul r3.y, r4.w, r3.w
cmp r6.y, -r0.w, c33.x, r3
rcp r3.y, r10.x
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, r3.x
cmp r18.xy, -r0.w, r6, c33.zxzw
dp3 r3.x, r0, c12
add r0.w, -r18.x, r6
add r3.z, r18.y, -r11.w
mul r0.x, r3, c17
mul r0.x, r0, c32
rcp r10.x, r11.x
add r3.w, r5, -r6
mul_sat r0.w, r0, r3.y
mul_sat r0.y, r3, r3.z
mad r3.z, -r0.w, r0.y, c32.w
abs r0.y, r3.w
mad r0.x, c17, c17, r0
mul r5.xyz, -r11, r0.y
add r3.y, r0.x, c32.w
pow r0, r3.y, c34.y
mad r0.z, r3.x, r3.x, c32.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c32.w, r0.y
mad r4.xyz, r11, r13, -r4
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c34
mul r3.xy, r0, c34.z
pow r0, c35.x, r5.x
mul r0.y, r3, r1.w
mad r1.xyz, r1, r3.x, r0.y
mul r12.xyz, r1, r10
pow r1, c35.x, r5.z
mov r9.x, r0
pow r0, c35.x, r5.y
add r13.w, r11, -r10
abs r0.w, r13
mul r17.xyz, -r11, r0.w
mov r9.z, r1
mov r9.y, r0
mul r3.xyz, r12, r3.z
mul r1.xyz, r10, r3
mul r0.xyz, r9, r14
mul r16.xyz, r1, r4
mad r1.xyz, r11, r13, -r0
add r0.z, r18.y, -r6.w
rcp r0.y, r3.w
add r0.x, r5.w, -r18
mov r5, c23
add r5, -c27, r5
mov r6.w, c32
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c32.w
mul r0.xyz, r0.x, r12
mul r0.xyz, r0, r10
mul r15.xyz, r0, r1
mov r1, c21
add r1, -c25, r1
mad r3, r12.w, r1, c25
texldl r1.w, r7.xyzz, s2
mov r6.z, r1.w
mov r0, c20
add r0, -c24, r0
mad r4, r12.w, r0, c24
texldl r0.w, r7.xyzz, s1
mov r6.y, r0.w
texldl r0.w, r7.xyzz, s0
mov r6.x, r0.w
dp4 r0.x, r4, r6
dp4 r4.x, r4, r4
mad r5, r12.w, r5, c27
mov r1, c22
add r1, -c26, r1
mad r1, r12.w, r1, c26
dp4 r0.y, r3, r6
dp4 r4.y, r3, r3
pow r3, c35.x, r17.y
dp4 r0.w, r5, r6
dp4 r0.z, r1, r6
dp4 r4.z, r1, r1
add r0, r0, c32.y
dp4 r4.w, r5, r5
mad r1, r4, r0, c32.w
pow r0, c35.x, r17.x
mad r5.xyz, r15, r1.w, r16
mov r4.x, r0
mov r4.y, r3
rcp r0.z, r13.w
add r0.w, r18.y, -r10
add r0.y, -r18.x, r11.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c32
pow r0, c35.x, r17.z
mov r4.z, r0
mul r3.xyz, r14, r4
mul r0.xyz, r12, r1.w
mad r3.xyz, r11, r13, -r3
mul r0.xyz, r10, r0
mul r0.xyz, r0, r3
mad r5.xyz, r5, r1.z, r0
add r0.w, r10, -r9
abs r0.y, r0.w
mul r6.xyz, -r11, r0.y
rcp r1.z, r0.w
add r0.x, -r18, r10.w
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r6.x
add r3.x, r18.y, -r9.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r6.y
mad r1.z, -r1.w, r0.y, c32.w
mov r6.x, r0
pow r0, c35.x, r6.z
mov r6.z, r0
mov r6.y, r3
mul r0.xyz, r12, r1.z
mul r3.xyz, r14, r6
mul r0.xyz, r10, r0
mad r3.xyz, r11, r13, -r3
mul r15.xyz, r0, r3
add r0.y, r9.w, -r8.w
rcp r1.z, r0.y
add r0.x, -r18, r9.w
abs r0.y, r0
mul r16.xyz, -r11, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r16.x
add r3.x, r18.y, -r8.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r16.y
mad r1.z, -r1.w, r0.y, c32.w
mov r16.x, r0
pow r0, c35.x, r16.z
mov r16.y, r3
mov r16.z, r0
mul r3.xyz, r12, r1.z
mul r0.xyz, r14, r16
mul r3.xyz, r10, r3
mad r0.xyz, r11, r13, -r0
mul r0.xyz, r3, r0
mad r3.xyz, r5, r1.y, r15
mad r0.xyz, r3, r1.x, r0
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r0.w, r0, c39.z
frc r0.z, r0.w
add r0.w, r0, -r0.z
mul_pp r0.z, r1.y, c39.x
mul_pp r0.x, r0, r1.z
add r0.z, r1.x, -r0
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.z
abs_pp r0.z, r0.x
mul r1.xyz, r6, r16
mul r1.xyz, r4, r1
mul r1.xyz, r8, r1
mul r3.xyz, r9, r1
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c32.y
mul r4.xyz, r3.y, c38
mad r4.xyz, r3.x, c37, r4
mad r1.xyz, r3.z, c36, r4
add r3.x, r1, r1.y
add r1.z, r1, r3.x
mul_pp r0.z, r0, c40.w
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r3.x, r1.z, c35.w
mul r0.z, r0, c41.x
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c40
frc r3.y, r3.x
add r0.w, r3.x, -r3.y
min r0.w, r0, c35
add r3.x, r0.w, c36.w
mul r1.w, r1, c39.z
frc r3.y, r1.w
add r1.w, r1, -r3.y
cmp r3.x, r3, c32.w, c32.z
mul_pp r0.z, r0, c39.x
cmp_pp r0.x, -r0, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r3.x, c37.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c41
mul r1.x, r0.w, c34.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c39.x
add r0.w, r0, -r1.z
min r1.w, r1, c39
mad r1.z, r0.w, c39.y, r1.w
add_pp r0.w, r1.x, c38
exp_pp r1.x, r0.w
mad_pp r0.w, -r3.x, c32.x, c32
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c40.x, c40.y
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r3.x, r1.w
add_pp r1.w, r1, -r3.x
exp_pp r3.x, -r1.w
mad_pp r1.z, r1, r3.x, c32.y
mul r0.x, r0, c41.y
add r0.w, -r0.x, -r0.z
add r0.w, r0, c32
mul r3.xyz, r0.y, c44
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c40.w
mul r3.w, r0.z, c41.x
mad r0.xyz, r0.x, c43, r3
add_pp r1.z, r1.w, c40
frc r3.x, r3.w
mad r0.xyz, r0.w, c42, r0
add r1.w, r3, -r3.x
mul_pp r1.z, r1, c39.x
cmp_pp r1.x, -r1, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.z
mul r1.z, r3.x, c41
add r1.x, r1, r1.w
mul r1.x, r1, c41.y
add r1.w, -r1.x, -r1.z
add r0.w, r1, c32
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r3.xyz, r1.y, c44
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c32.z
mad r3.xyz, r1.y, c43, r3
mul r0.w, r0, r1.x
mad r3.xyz, r0.w, c42, r3
add r1.xyz, -r0, c32.wzzw
max r3.xyz, r3, c32.z
mad r1.xyz, r1, c29.x, r0
mad r3.xyz, -r3, c29.x, r3
else
add r3.xy, r7, c30.xzzw
add r1.xy, r3, c30.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s7
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r3.z, r1.w
add_pp r1.w, r1, -r3.z
exp_pp r3.z, -r1.w
mad_pp r1.z, r1, r3, c32.y
mul_pp r1.z, r1, c40.w
mul r3.z, r1, c41.x
add_pp r1.z, r1.w, c40
frc r3.w, r3.z
add r1.w, r3.z, -r3
add r8.xy, r1, -c30.xzzw
mul r3.z, r3.w, c41
mul_pp r1.z, r1, c39.x
cmp_pp r0.y, -r0, c32.w, c32.z
mad_pp r0.y, r0, c37.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c41
add r3.w, -r0.y, -r3.z
mov r8.z, r7
texldl r1, r8.xyzz, s7
abs_pp r4.x, r1.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r3.w, r3, c32
mul r3.w, r3, r0.x
rcp r3.z, r3.z
mul r0.y, r0, r0.x
mul r3.w, r3, r3.z
exp_pp r4.y, -r4.w
mul r0.y, r3.z, r0
mad_pp r3.z, r4.x, r4.y, c32.y
mul r4.xyz, r0.x, c44
mad r4.xyz, r0.y, c43, r4
mul_pp r0.x, r3.z, c40.w
mul r0.y, r0.x, c41.x
mad r4.xyz, r3.w, c42, r4
frc r3.z, r0.y
add r3.w, r0.y, -r3.z
add_pp r0.x, r4.w, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r1.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r3.w
mul r0.y, r3.z, c41.z
mul r0.x, r0, c41.y
add r1.y, -r0.x, -r0
add r1.y, r1, c32.w
mov r3.z, r7
texldl r3, r3.xyzz, s7
abs_pp r4.w, r3.y
log_pp r5.x, r4.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r5.y, r5.x
add_pp r0.y, r5.x, -r5
mul r5.xyz, r1.x, c44
mad r5.xyz, r0.x, c43, r5
exp_pp r1.x, -r0.y
mad_pp r0.x, r4.w, r1, c32.y
mad r5.xyz, r1.y, c42, r5
mul_pp r0.x, r0, c40.w
mul r1.x, r0, c41
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r3.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r1
max r5.xyz, r5, c32.z
max r4.xyz, r4, c32.z
add r6.xyz, r4, -r5
texldl r4, r7.xyzz, s7
add r7.xy, r8, -c30.zyzw
mul r1.x, r0, c41.y
mul r1.y, r1, c41.z
add r3.y, -r1.x, -r1
mul r0.xy, r7, c31
frc r0.xy, r0
mad r6.xyz, r0.x, r6, r5
abs_pp r5.x, r4.y
log_pp r5.y, r5.x
frc_pp r5.z, r5.y
add_pp r5.w, r5.y, -r5.z
add r3.y, r3, c32.w
mul r3.y, r3, r3.x
rcp r1.y, r1.y
mul r1.x, r1, r3
mul r3.y, r3, r1
exp_pp r5.y, -r5.w
mul r1.x, r1.y, r1
mad_pp r1.y, r5.x, r5, c32
mul r5.xyz, r3.x, c44
mad r5.xyz, r1.x, c43, r5
mad r5.xyz, r3.y, c42, r5
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r5.w, c40.z
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.y, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
rcp r3.y, r1.y
mul r1.x, r1, r4
add r3.x, r3, c32.w
mul r1.y, r3.x, r4.x
abs_pp r3.x, r3.w
mul r1.y, r1, r3
log_pp r4.y, r3.x
mul r1.x, r3.y, r1
frc_pp r3.y, r4
mul r8.xyz, r4.x, c44
mad r8.xyz, r1.x, c43, r8
add_pp r3.y, r4, -r3
exp_pp r1.x, -r3.y
mad r8.xyz, r1.y, c42, r8
mad_pp r1.x, r3, r1, c32.y
mul_pp r1.x, r1, c40.w
mul r1.y, r1.x, c41.x
frc r3.x, r1.y
add_pp r1.x, r3.y, c40.z
add r3.y, r1, -r3.x
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r3.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
abs_pp r3.y, r4.w
log_pp r4.x, r3.y
frc_pp r4.y, r4.x
add_pp r4.x, r4, -r4.y
max r8.xyz, r8, c32.z
max r5.xyz, r5, c32.z
add r5.xyz, r5, -r8
mad r5.xyz, r0.x, r5, r8
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
add r3.x, r3, c32.w
mul r3.x, r3.z, r3
rcp r1.y, r1.y
mul r3.w, r3.x, r1.y
mul r1.x, r3.z, r1
exp_pp r3.x, -r4.x
mul r1.x, r1.y, r1
mad_pp r1.y, r3, r3.x, c32
mul r3.xyz, r3.z, c44
mad r3.xyz, r1.x, c43, r3
mad r3.xyz, r3.w, c42, r3
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
max r8.xyz, r3, c32.z
frc r3.w, r1.y
add_pp r1.x, r4, c40.z
add r4.x, r1.y, -r3.w
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
mul r1.y, r3.w, c41.z
add r1.x, r1, r4
mul r1.x, r1, c41.y
add r3.w, -r1.x, -r1.y
rcp r3.y, r1.y
add r3.x, r3.w, c32.w
mul r1.y, r4.z, r3.x
mul r4.x, r1.y, r3.y
mul r1.y, r4.z, r1.x
mul r4.y, r3, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r4.w, r1.y, -r3
exp_pp r1.y, -r4.w
mad_pp r1.x, r1, r1.y, c32.y
mul_pp r1.y, r1.x, c40.w
abs_pp r1.x, r0.w
mul r5.w, r1.y, c41.x
frc r6.w, r5
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r1.y, r1, -r3.w
exp_pp r3.w, -r1.y
mad_pp r1.x, r1, r3.w, c32.y
mul r3.xyz, r4.z, c44
mad r3.xyz, r4.y, c43, r3
mad r3.xyz, r4.x, c42, r3
max r3.xyz, r3, c32.z
add r4.xyz, r8, -r3
add_pp r4.w, r4, c40.z
add r5.w, r5, -r6
mad r3.xyz, r0.x, r4, r3
mul_pp r4.w, r4, c39.x
cmp_pp r1.w, -r1, c32, c32.z
mad_pp r1.w, r1, c37, r4
add r1.w, r1, r5
mul r4.w, r1, c41.y
mul r5.w, r6, c41.z
mul_pp r1.x, r1, c40.w
mul r1.w, r1.x, c41.x
add_pp r1.x, r1.y, c40.z
frc r3.w, r1
add r1.y, r1.w, -r3.w
add r6.w, -r4, -r5
mul r8.x, r1.z, r4.w
rcp r4.w, r5.w
mul r5.w, r4, r8.x
mul r1.w, r3, c41.z
mul_pp r1.x, r1, c39
cmp_pp r0.w, -r0, c32, c32.z
mad_pp r0.w, r0, c37, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c41.y
add r1.x, -r0.w, -r1.w
add r1.y, r6.w, c32.w
add r3.w, r1.x, c32
mul r6.w, r1.z, r1.y
mul r1.xyz, r1.z, c44
mul r4.w, r6, r4
mad r1.xyz, r5.w, c43, r1
mad r1.xyz, r4.w, c42, r1
mul r4.w, r0.z, r0
mul r3.w, r0.z, r3
rcp r0.w, r1.w
mul r8.xyz, r0.z, c44
mul r0.z, r0.w, r4.w
mad r8.xyz, r0.z, c43, r8
mul r0.z, r3.w, r0.w
mad r8.xyz, r0.z, c42, r8
max r1.xyz, r1, c32.z
max r8.xyz, r8, c32.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r4.xyz, r1, -r3
add r6.xyz, r6, -r5
mad r1.xyz, r0.y, r6, r5
mad r3.xyz, r0.y, r4, r3
endif
mov r0.x, c4.w
mul r0.x, c33.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s8
else
mov r0.xyz, c32.z
endif
mul r3.xyz, r3, r2.w
mad r0.xyz, r0, r3, r2
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r2.xyz, r3.y, c38
mad r2.xyz, r3.x, c37, r2
mad r2.xyz, r3.z, c36, r2
add r1.w, r2.x, r2.y
mul_pp r0.x, r0, r1.z
add r0.z, r2, r1.w
rcp r1.z, r0.z
mul_pp r0.z, r1.y, c39.x
mul r1.zw, r2.xyxy, r1.z
mul r1.y, r1.z, c35.w
frc r1.z, r1.y
add r0.z, r1.x, -r0
mul r0.w, r0, c39.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r1.y, r1, -r1.z
min r1.x, r1.y, c35.w
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
add r1.y, r1.x, c36.w
cmp r0.w, r1.y, c32, c32.z
mad r0.z, r0, c40.x, c40.y
mul_pp r1.y, r0.w, c37.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.y
mul r1.x, r1.w, c39.z
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c34.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c39.x
frc r1.y, r1.x
add r1.x, r1, -r1.y
add r0.x, r0, -r0.z
min r1.x, r1, c39.w
mad r0.z, r0.x, c39.y, r1.x
add_pp r0.x, r0.y, c38.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c32, c32.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r2.y

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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 7 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 6 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 9 [_TexBackground] 2D
SetTexture 5 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 8 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[45] = { program.local[0..31],
		{ 0, 2, -1, -1000000 },
		{ 1, 0.995, 1000000, -1000000 },
		{ 0.1, 0.75, 1.5, 0.079577468 },
		{ 0.25, 2.718282, 0.5, 210 },
		{ 0.0241188, 0.1228178, 0.84442663, 128 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 400, 255, 0.0009765625 },
		{ 1024, 0.00390625, 0.0047619049 },
		{ 0.63999999, 0, 1 },
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
TEMP R17;
TEMP R18;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R8, fragment.texcoord[0], texture[2], 2D;
TEX   R9, fragment.texcoord[0], texture[3], 2D;
MOVR  R4.z, R8.w;
MOVR  R5, c[26];
MOVR  R6, c[27];
MOVR  R4.w, R9;
MOVR  R11.z, R8.y;
MOVR  R2.xyz, c[5];
MOVR  R3.x, c[32].w;
MOVR  R11.w, R9.y;
MOVR  R8.w, R9.z;
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].y, -R0;
MOVR  R0.z, c[32];
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[9].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[32].x;
DP4R  R2.z, R0, c[2];
DP4R  R2.y, R0, c[1];
DP4R  R2.x, R0, c[0];
DP3R  R3.z, R2, R1;
MOVR  R0, c[13];
MULR  R3.w, R3.z, R3.z;
DP3R  R1.x, R1, R1;
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R1.x;
SLTR  R2, R3.w, R0;
MOVXC RC.x, R2;
MOVR  R3.x(EQ), R1.w;
ADDR  R1, R3.w, -R0;
SGERC HC, R3.w, R0.yzxw;
RSQR  R0.y, R1.z;
RSQR  R0.z, R1.y;
RSQR  R0.w, R1.w;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R3.z, R1;
TEX   R1, fragment.texcoord[0], texture[0], 2D;
MOVR  R4.x, R1.w;
MOVR  R11.x, R1.y;
MOVR  R0.x, c[32].w;
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3.y;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.z, R0.y;
MOVR  R0.y, c[32].w;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.z, R0.z;
MOVR  R0.z, c[32].w;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.y;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3, R0.w;
MOVR  R3.y, R0;
MOVR  R3.w, R0.z;
MOVR  R3.z, R0.x;
DP4R  R0.x, R3, c[19];
SGER  H0.x, c[32], R0;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R3, H0.x, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R2, H0.x, R0, c[24];
TEX   R0, fragment.texcoord[0], texture[1], 2D;
MOVR  R4.y, R0.w;
ADDR  R5, -R5, c[22];
MADR  R5, H0.x, R5, c[26];
MOVR  R11.y, R0;
ADDR  R6, -R6, c[23];
MADR  R6, H0.x, R6, c[27];
DP4R  R7.x, R4, R2;
DP4R  R7.y, R4, R3;
DP4R  R7.z, R4, R5;
DP4R  R7.w, R4, R6;
DP4R  R4.x, R2, R2;
MOVR  R8.y, R0.z;
DP4R  R4.y, R3, R3;
DP4R  R1.y, R5, R11;
DP4R  R4.w, R6, R6;
DP4R  R4.z, R5, R5;
MADR  R4, R7, R4, -R4;
ADDR  R4, R4, c[33].x;
MOVR  R7.z, R8.x;
MOVR  R8.x, R1.z;
MULR  R0.w, R4.x, R4.y;
MOVR  R7.x, R1;
MOVR  R7.y, R0.x;
MOVR  R7.w, R9.x;
MULR  R0.w, R0, R4.z;
DP4R  R1.x, R5, R7;
DP4R  R1.z, R5, R8;
DP4R  R0.x, R6, R7;
DP4R  R0.y, R6, R11;
DP4R  R0.z, R6, R8;
MADR  R0.xyz, R4.z, R0, R1;
DP4R  R1.x, R3, R7;
DP4R  R1.z, R3, R8;
DP4R  R1.y, R3, R11;
MADR  R0.xyz, R4.y, R0, R1;
DP4R  R1.x, R2, R7;
DP4R  R1.z, R2, R8;
DP4R  R1.y, R2, R11;
MADR  R2.xyz, R4.x, R0, R1;
MULR  R2.w, R0, R4;
ADDR  R0.zw, fragment.texcoord[0].xyxy, c[30].xyxz;
ADDR  R0.xy, R0.zwzw, c[30].zyzw;
ADDR  R1.xy, R0, -c[30].xzzw;
ADDR  R18.xy, R1, -c[30].zyzw;
TEX   R0.x, R0, texture[5], 2D;
TEX   R1.x, R1, texture[5], 2D;
ADDR  R0.y, R1.x, -R0.x;
TEX   R1.x, fragment.texcoord[0], texture[5], 2D;
TEX   R3.x, R0.zwzw, texture[5], 2D;
MULR  R1.zw, R18.xyxy, c[31].xyxy;
FRCR  R0.zw, R1;
MADR  R0.x, R0.z, R0.y, R0;
ADDR  R1.y, R3.x, -R1.x;
MADR  R0.y, R0.z, R1, R1.x;
ADDR  R1.x, R0, -R0.y;
ADDR  R0.z, c[4].w, -c[4];
RCPR  R0.z, R0.z;
MULR  R0.z, R0, c[4].w;
TEX   R0.x, fragment.texcoord[0], texture[4], 2D;
ADDR  R0.x, R0.z, -R0;
RCPR  R0.x, R0.x;
MULR  R0.z, R0, c[4];
MADR  R0.y, R0.w, R1.x, R0;
MULR  R9.w, R0.z, R0.x;
ADDR  R0.x, R9.w, -R0.y;
SGTRC HC.x, |R0|, c[28];
IF    NE.x;
MOVR  R3.x, c[32].w;
MOVR  R3.z, c[32].w;
MOVR  R3.w, c[32];
MOVR  R3.y, c[32].w;
MOVR  R9.x, c[0].w;
MOVR  R9.z, c[2].w;
MOVR  R9.y, c[1].w;
MULR  R8.xyz, R9, c[9].x;
ADDR  R5.xyz, R8, -c[5];
DP3R  R7.x, R5, R5;
MULR  R1.xy, R18, c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[32].y, -R0;
MOVR  R0.z, c[32];
DP3R  R0.w, R0, R0;
RSQR  R4.w, R0.w;
MULR  R0.xyz, R4.w, R0;
MOVR  R0.w, c[32].x;
RCPR  R4.w, R4.w;
DP4R  R4.z, R0, c[2];
DP4R  R4.y, R0, c[1];
DP4R  R4.x, R0, c[0];
DP3R  R5.w, R4, R5;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
MULR  R8.w, R5, R5;
ADDR  R1, R8.w, -R0;
SLTR  R6, R8.w, R0;
MOVXC RC.x, R6;
MOVR  R3.x(EQ), R10;
SGERC HC, R8.w, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R3.x(NE.z), -R5.w, R1;
MOVXC RC.z, R6;
MOVR  R3.z(EQ), R10.x;
MOVXC RC.z, R6.w;
RCPR  R0.x, R0.x;
ADDR  R3.z(NE.y), -R5.w, R0.x;
MOVXC RC.y, R6;
RSQR  R0.x, R1.w;
MOVR  R3.w(EQ.z), R10.x;
RCPR  R0.x, R0.x;
ADDR  R3.w(NE), -R5, R0.x;
RSQR  R0.x, R1.y;
MOVR  R3.y(EQ), R10.x;
RCPR  R0.x, R0.x;
ADDR  R3.y(NE.x), -R5.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R7.x;
ADDR  R6, R8.w, -R0;
SLTR  R7, R8.w, R0;
RSQR  R1.y, R6.x;
MOVR  R1.x, c[33].z;
MOVXC RC.x, R7;
MOVR  R1.x(EQ), R10;
SGERC HC, R8.w, R0.yzxw;
RCPR  R1.y, R1.y;
ADDR  R1.x(NE.z), -R5.w, -R1.y;
RSQR  R0.x, R6.z;
MOVR  R1.y, c[33].z;
MOVR  R0.w, c[33].z;
MOVXC RC.z, R7;
MOVR  R0.w(EQ.z), R10.x;
RCPR  R0.x, R0.x;
ADDR  R0.w(NE.y), -R5, -R0.x;
MOVXC RC.y, R7;
RSQR  R0.x, R6.w;
MULR  R7.xyz, R4.zxyw, c[12].yzxw;
MADR  R7.xyz, R4.yzxw, c[12].zxyw, -R7;
MOVR  R1.y(EQ), R10.x;
MOVR  R1.z, c[33];
MOVXC RC.z, R7.w;
MOVR  R1.z(EQ), R10.x;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R5.w, -R0.x;
RSQR  R0.x, R6.y;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R5.w, -R0.x;
MOVR  R0.xyz, c[5];
MADR  R0.xyz, R9, c[9].x, -R0;
DP3R  R1.w, R0, R4;
MOVR  R5.w, c[18].x;
DP3R  R7.w, R0, R0;
ADDR  R5.w, R5, c[7].x;
MADR  R6.x, -R5.w, R5.w, R7.w;
MULR  R6.w, R1, R1;
ADDR  R6.y, R6.w, -R6.x;
RSQR  R6.y, R6.y;
MOVR  R5.w, c[33].z;
SLTRC HC.x, R6.w, R6;
MOVR  R5.w(EQ.x), R10.x;
SGERC HC.x, R6.w, R6;
RCPR  R6.y, R6.y;
ADDR  R5.w(NE.x), -R1, -R6.y;
MOVXC RC.x, R5.w;
MULR  R6.xyz, R0.zxyw, c[12].yzxw;
MADR  R6.xyz, R0.yzxw, c[12].zxyw, -R6;
DP3R  R0.x, R0, c[12];
SLER  H0.x, R0, c[32];
DP3R  R8.w, R6, R6;
DP3R  R6.x, R6, R7;
DP3R  R6.z, R7, R7;
MADR  R6.y, -c[7].x, c[7].x, R8.w;
MULR  R7.y, R6.z, R6;
MULR  R7.x, R6, R6;
ADDR  R6.y, R7.x, -R7;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
ADDR  R0.y, -R6.x, R6;
SGTR  H0.y, R7.x, R7;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVR  R5.w(LT.x), c[33].z;
MULR  R4.w, R9, R4;
MADR  R5.w, -R4, c[9].x, R5;
MOVXC RC.x, H0;
RCPR  R6.z, R6.z;
MOVR  R0.z, c[33].w;
MULR  R0.z(NE.x), R6, R0.y;
ADDR  R0.y, -R6.x, -R6;
MOVR  R0.x, c[33].z;
MULR  R0.x(NE), R0.y, R6.z;
MOVR  R0.y, R0.z;
MOVR  R18.zw, R0.xyxy;
MADR  R0.xyz, R4, R0.x, R8;
ADDR  R0.xyz, R0, -c[5];
DP3R  R0.x, R0, c[12];
MADR  R0.z, -c[8].x, c[8].x, R7.w;
SGTR  H0.y, R0.x, c[32].x;
MULXC HC.x, H0, H0.y;
MOVR  R18.zw(NE.x), c[33];
ADDR  R6.x, R6.w, -R0.z;
RSQR  R6.x, R6.x;
RCPR  R6.x, R6.x;
ADDR  R6.y, -R1.w, -R6.x;
ADDR  R1.w, -R1, R6.x;
MAXR  R6.x, R6.y, c[32];
MAXR  R6.y, R1.w, c[32].x;
MOVR  R1.w, R1.z;
MOVR  R1.z, R0.w;
MOVR  R0.xy, c[32].x;
SLTRC HC.x, R6.w, R0.z;
MOVR  R0.xy(EQ.x), R10;
SGERC HC.x, R6.w, R0.z;
MOVR  R0.xy(NE.x), R6;
MAXR  R10.w, R0.x, c[32].x;
DP4R  R0.z, R1, c[24];
DP4R  R0.w, R3, c[20];
ADDR  R6.x, R0.w, -R0.z;
DP4R  R0.w, R3, c[19];
SGER  H0.y, c[32].x, R0.w;
MADR  R0.z, H0.y, R6.x, R0;
DP4R  R6.x, R1, c[25];
DP4R  R0.w, R3, c[21];
ADDR  R0.w, R0, -R6.x;
MADR  R0.w, H0.y, R0, R6.x;
MOVR  R7.xw, c[33].yyzx;
MULR  R6.x, R7, c[4].w;
SGER  H0.x, R9.w, R6;
MULR  R4.w, R4, c[9].x;
MADR  R4.w, H0.x, R5, R4;
MINR  R4.w, R0.y, R4;
MINR  R0.z, R4.w, R0;
MAXR  R11.w, R10, R0.z;
MINR  R0.y, R4.w, R0.w;
MAXR  R12.w, R11, R0.y;
DP4R  R0.y, R1, c[26];
DP4R  R0.x, R3, c[22];
ADDR  R0.x, R0, -R0.y;
MADR  R0.x, H0.y, R0, R0.y;
MINR  R0.x, R4.w, R0;
MAXR  R5.w, R12, R0.x;
ADDR  R6.z, R5.w, -R12.w;
ADDR  R6.xy, R18.wzzw, -R5.w;
RCPR  R0.x, R6.z;
ADDR  R8.zw, R18.xywz, -R12.w;
MULR_SAT R0.y, R0.x, R8.z;
MULR_SAT R0.x, -R6.y, R0;
MULR  R0.w, R0.x, R0.y;
DP3R  R0.x, R4, c[12];
MULR  R0.y, R0.x, c[17].x;
MULR  R0.y, R0, c[32];
MADR  R0.y, c[17].x, c[17].x, R0;
ADDR  R0.y, R0, c[33].x;
POWR  R0.z, R0.y, c[34].z;
MULR  R0.x, R0, R0;
ADDR  R0.y, R7.w, c[17].x;
MADR  R4.xyz, R4, R10.w, R5;
RCPR  R0.z, R0.z;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R0.z;
MADR  R0.x, R0, c[34].y, c[34].y;
MULR  R7.xy, R0, c[34].w;
MOVR  R0.y, c[35].x;
MULR  R6.w, R0.y, c[16].x;
MOVR  R0.x, c[34];
MULR  R0.xyz, R0.x, c[15];
ADDR  R11.xyz, R0, R6.w;
MULR  R6.y, R7, R6.w;
MADR  R0.xyz, R0, R7.x, R6.y;
RCPR  R10.x, R11.x;
RCPR  R10.z, R11.z;
RCPR  R10.y, R11.y;
MULR  R12.xyz, R0, R10;
MADR  R0.xyz, R12, -R0.w, R12;
DP3R  R0.w, R4, R4;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R4.x, R0.w, -c[7];
MOVR  R0.w, c[7].x;
ADDR  R0.w, -R0, c[8].x;
RCPR  R0.w, R0.w;
MULR  R5.y, R4.x, R0.w;
MOVR  R4.xyz, c[6];
DP3R  R0.w, R4, c[12];
MADR  R5.x, -R0.w, c[35].z, c[35].z;
TEX   R13.zw, R5, texture[6], 2D;
MULR  R5.xyz, -R11, |R6.z|;
MULR  R0.w, R13, c[16].x;
MADR  R4.xyz, R13.z, -c[15], -R0.w;
MULR  R0.xyz, R10, R0;
RCPR  R6.y, |R6.z|;
POWR  R7.x, c[35].y, R5.x;
POWR  R7.y, c[35].y, R5.y;
POWR  R7.z, c[35].y, R5.z;
TEX   R0.w, c[35].z, texture[7], 2D;
POWR  R4.x, c[35].y, R4.x;
POWR  R4.z, c[35].y, R4.z;
POWR  R4.y, c[35].y, R4.y;
MULR  R4.xyz, R4, c[11];
MULR  R13.xyz, R4, R0.w;
ADDR  R14.xyz, R13, -R13;
MULR  R4.xyz, R14, R6.y;
MADR  R4.xyz, R11, R13, R4;
MADR  R4.xyz, -R7, R4, R4;
MULR  R17.xyz, R0, R4;
DP4R  R0.x, R1, c[27];
DP4R  R0.y, R3, c[23];
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R4.w, R0;
MAXR  R0.w, R5, R0.x;
ADDR  R1.w, R0, -R5;
MULR  R3.xyz, -R11, |R1.w|;
ADDR  R4.xy, R18.wzzw, -R0.w;
RCPR  R0.x, R1.w;
RCPR  R1.x, |R1.w|;
MULR_SAT R0.y, R0.x, R6.x;
MULR_SAT R0.x, -R4.y, R0;
TEX   R1.w, R18, texture[1], 2D;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R12, -R0.x, R12;
MULR  R1.xyz, R14, R1.x;
MULR  R0.xyz, R10, R0;
MOVR  R5.y, R1.w;
ADDR  R0.w, R4, -R0;
TEX   R5.w, R18, texture[3], 2D;
POWR  R8.x, c[35].y, R3.x;
POWR  R8.y, c[35].y, R3.y;
POWR  R8.z, c[35].y, R3.z;
MULR  R3.xyz, |R0.w|, -R11;
MADR  R1.xyz, R11, R13, R1;
MADR  R1.xyz, -R8, R1, R1;
MULR  R16.xyz, R0, R1;
RCPR  R0.x, R0.w;
RCPR  R1.x, |R0.w|;
MULR  R1.xyz, R14, R1.x;
MULR_SAT R0.y, R0.x, R4.x;
ADDR  R0.z, R4.w, -R18;
MULR_SAT R0.x, R0.z, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R12, R12;
POWR  R9.x, c[35].y, R3.x;
POWR  R9.y, c[35].y, R3.y;
POWR  R9.z, c[35].y, R3.z;
MADR  R1.xyz, R11, R13, R1;
MADR  R1.xyz, -R9, R1, R1;
MULR  R0.xyz, R0, R10;
MULR  R15.xyz, R0, R1;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R4, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R3, H0.y, R0, c[24];
TEX   R0.w, R18, texture[2], 2D;
MOVR  R5.z, R0.w;
TEX   R0.w, R18, texture[0], 2D;
MOVR  R5.x, R0.w;
DP4R  R6.x, R5, R3;
DP4R  R3.x, R3, R3;
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R0, H0.y, R0, c[26];
MOVR  R1, c[27];
ADDR  R1, -R1, c[23];
MADR  R1, H0.y, R1, c[27];
DP4R  R3.w, R1, R1;
DP4R  R6.w, R5, R1;
DP4R  R6.y, R5, R4;
DP4R  R6.z, R5, R0;
ADDR  R1.w, R12, -R11;
DP4R  R3.y, R4, R4;
DP4R  R3.z, R0, R0;
MADR  R0, R6, R3, -R3;
ADDR  R0, R0, c[33].x;
RCPR  R3.x, R1.w;
MADR  R1.xyz, R15, R0.w, R16;
MADR  R1.xyz, R1, R0.z, R17;
ADDR  R0.zw, R18.xywz, -R11.w;
MULR_SAT R3.y, -R8.w, R3.x;
MULR_SAT R0.z, R3.x, R0;
MULR  R0.z, R3.y, R0;
MULR  R3.xyz, -R11, |R1.w|;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R1.w|;
MULR  R5.xyz, R14, R0.z;
POWR  R3.x, c[35].y, R3.x;
POWR  R3.y, c[35].y, R3.y;
POWR  R3.z, c[35].y, R3.z;
MADR  R5.xyz, R11, R13, R5;
MADR  R5.xyz, -R3, R5, R5;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R5;
MADR  R1.xyz, R1, R0.y, R4;
ADDR  R0.y, R11.w, -R10.w;
MULR  R5.xyz, -R11, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R18, -R10;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R4.xyz, R12, -R0.z, R12;
RCPR  R0.z, |R0.y|;
MULR  R6.xyz, R14, R0.z;
POWR  R5.x, c[35].y, R5.x;
POWR  R5.y, c[35].y, R5.y;
POWR  R5.z, c[35].y, R5.z;
MADR  R6.xyz, R11, R13, R6;
MADR  R6.xyz, -R5, R6, R6;
MULR  R4.xyz, R10, R4;
MULR  R4.xyz, R4, R6;
MADR  R0.xyz, R1, R0.x, R4;
MULR  R1.xyz, R0.y, c[38];
MADR  R1.xyz, R0.x, c[37], R1;
MADR  R0.xyz, R0.z, c[36], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].w;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].w;
SGER  H0.x, R0, c[36].w;
MULH  H0.y, H0.x, c[36].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[35].x;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[38].w;
MULR  R0.z, R0.w, c[39].y;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[37].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[39];
MADR  R0.x, R0, c[39], R0.z;
MADR  H0.z, R0.x, c[39].w, R7.w;
MADH  H0.x, H0, c[32].y, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R0.z, H0, c[40].y;
FLRR  R0.x, R0.z;
ADDH  H0.y, H0, c[37].w;
FRCR  R0.z, R0;
MULR  R0.z, R0, c[41].x;
RCPR  R1.x, R0.z;
MULH  H0.y, H0, c[38].w;
SGEH  H0.x, c[32], H0;
MADH  H0.x, H0, c[36].w, H0.y;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].z;
ADDR  R0.w, -R0.x, -R0.z;
MADR  R0.w, R0, R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R1.y, R1.x, R0.x;
MULR  R0.xyz, R0.y, c[44];
MULR  R0.w, R0, R1.x;
MADR  R0.xyz, R1.y, c[43], R0;
MADR  R0.xyz, R0.w, c[42], R0;
MAXR  R0.xyz, R0, c[32].x;
ADDR  R1.xyz, -R0, c[41].zyyw;
MADR  R0.xyz, R1, c[29].x, R0;
MULR  R1.xyz, R3, R5;
MULR  R1.xyz, R7, R1;
MULR  R1.xyz, R8, R1;
MULR  R1.xyz, R9, R1;
MULR  R3.xyz, R1.y, c[38];
MADR  R3.xyz, R1.x, c[37], R3;
MADR  R1.xyz, R1.z, c[36], R3;
ADDR  R0.w, R1.x, R1.y;
ADDR  R0.w, R1.z, R0;
RCPR  R0.w, R0.w;
MULR  R1.zw, R1.xyxy, R0.w;
MULR  R0.w, R1.z, c[35];
FLRR  R0.w, R0;
MINR  R0.w, R0, c[35];
SGER  H0.x, R0.w, c[36].w;
MULH  H0.y, H0.x, c[36].w;
ADDR  R0.w, R0, -H0.y;
MULR  R1.x, R0.w, c[35];
FLRR  H0.y, R1.x;
MULH  H0.z, H0.y, c[38].w;
MULR  R1.x, R1.w, c[39].y;
FLRR  R1.x, R1;
ADDH  H0.y, H0, -c[37].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.w, R0, -H0.z;
MINR  R1.x, R1, c[39].z;
MADR  R0.w, R0, c[39].x, R1.x;
MADR  H0.z, R0.w, c[39].w, R7.w;
MADH  H0.x, H0, c[32].y, H0.y;
MULH  H0.x, H0, H0.z;
LG2H  H0.y, |H0.x|;
FLRH  H0.y, H0;
EX2H  H0.z, -H0.y;
MULH  H0.z, |H0.x|, H0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R0.w, H0.z, c[40].y;
FLRR  R1.x, R0.w;
FRCR  R0.w, R0;
MULR  R1.z, R0.w, c[41].x;
ADDH  H0.y, H0, c[37].w;
RCPR  R1.w, R1.z;
MULH  H0.y, H0, c[38].w;
SGEH  H0.x, c[32], H0;
MADH  H0.x, H0, c[36].w, H0.y;
ADDR  R1.x, H0, R1;
MULR  R1.x, R1, c[40].z;
ADDR  R0.w, -R1.x, -R1.z;
MADR  R0.w, R0, R1.y, R1.y;
MULR  R1.x, R1, R1.y;
MULR  R3.x, R1.w, R1;
MULR  R1.xyz, R1.y, c[44];
MADR  R1.xyz, R3.x, c[43], R1;
MULR  R0.w, R0, R1;
MADR  R1.xyz, R0.w, c[42], R1;
MAXR  R1.xyz, R1, c[32].x;
MADR  R1.xyz, -R1, c[29].x, R1;
ELSE;
ADDR  R6.xy, R18, c[30].xzzw;
ADDR  R0.xy, R6, c[30].zyzw;
TEX   R3, R0, texture[8], 2D;
ADDR  R7.xy, R0, -c[30].xzzw;
LG2H  H0.x, |R3.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R3|, H0;
MADH  H0.y, H0, c[40].x, -c[40].x;
MULR  R0.z, H0.y, c[40].y;
FRCR  R0.w, R0.z;
MULR  R1.x, R0.w, c[41];
ADDH  H0.x, H0, c[37].w;
MULH  H0.z, H0.x, c[38].w;
SGEH  H0.xy, c[32].x, R3.ywzw;
TEX   R4, R7, texture[8], 2D;
MADH  H0.x, H0, c[36].w, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.x, R0;
MULR  R0.z, R0, c[40];
ADDR  R0.w, -R0.z, -R1.x;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.y|, H0;
ADDH  H0.x, H0, c[37].w;
RCPR  R0.x, R1.x;
MULR  R0.y, R0.z, R3.x;
MADR  R0.w, R0, R3.x, R3.x;
MULR  R0.w, R0, R0.x;
MULR  R1.x, R0, R0.y;
MULR  R0.xyz, R3.x, c[44];
MADR  R0.xyz, R1.x, c[43], R0;
MADR  R0.xyz, R0.w, c[42], R0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R0.w, H0.z, c[40].y;
MAXR  R1.xyz, R0, c[32].x;
FRCR  R0.x, R0.w;
SGEH  H0.zw, c[32].x, R4.xyyw;
MULH  H0.x, H0, c[38].w;
MULR  R0.z, R0.x, c[41].x;
FLRR  R0.y, R0.w;
MADH  H0.x, H0.z, c[36].w, H0;
ADDR  R0.y, H0.x, R0;
MULR  R0.x, R0.y, c[40].z;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R0, R4.x, R4.x;
RCPR  R0.w, R0.z;
MULR  R1.w, R0.y, R0;
MULR  R3.x, R0, R4;
MULR  R0.w, R0, R3.x;
MULR  R0.xyz, R4.x, c[44];
MADR  R5.xyz, R0.w, c[43], R0;
TEX   R0, R6, texture[8], 2D;
MADR  R5.xyz, R1.w, c[42], R5;
LG2H  H0.x, |R0.y|;
MAXR  R5.xyz, R5, c[32].x;
ADDR  R6.xyz, R1, -R5;
TEX   R1, R18, texture[8], 2D;
ADDR  R18.xy, R7, -c[30].zyzw;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R4.x, H0.z, c[40].y;
FRCR  R4.y, R4.x;
MULR  R3.xy, R18, c[31];
FRCR  R3.xy, R3;
MADR  R5.xyz, R3.x, R6, R5;
ADDH  H0.x, H0, c[37].w;
SGEH  H1.xy, c[32].x, R0.ywzw;
MULH  H0.x, H0, c[38].w;
SGEH  H1.zw, c[32].x, R1.xyyw;
FLRR  R4.x, R4;
MADH  H0.x, H1, c[36].w, H0;
ADDR  R0.y, H0.x, R4.x;
LG2H  H0.x, |R1.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.y|, H0;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MULR  R4.x, R0.y, c[40].z;
MULR  R4.y, R4, c[41].x;
ADDR  R0.y, -R4.x, -R4;
RCPR  R4.y, R4.y;
MADR  R0.y, R0, R0.x, R0.x;
MULR  R4.x, R4, R0;
MULR  R0.y, R0, R4;
MULR  R4.x, R4.y, R4;
MULR  R6.xyz, R0.x, c[44];
MADR  R6.xyz, R4.x, c[43], R6;
MADH  H0.z, H0, c[40].x, -c[40].x;
MADR  R6.xyz, R0.y, c[42], R6;
MULR  R0.x, H0.z, c[40].y;
FRCR  R0.y, R0.x;
MADH  H0.x, H1.z, c[36].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R0.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.w|, H0;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MULR  R1.y, R0.x, c[40].z;
MULR  R0.y, R0, c[41].x;
ADDR  R0.x, -R1.y, -R0.y;
MULR  R1.y, R1, R1.x;
MADR  R0.x, R0, R1, R1;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MULR  R0.y, R0, R1;
MULR  R7.xyz, R1.x, c[44];
MADR  R7.xyz, R0.y, c[43], R7;
MADR  R7.xyz, R0.x, c[42], R7;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R0.x, H0.z, c[40].y;
FRCR  R0.y, R0.x;
MAXR  R7.xyz, R7, c[32].x;
MAXR  R6.xyz, R6, c[32].x;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R3.x, R6, R7;
MADH  H0.x, H1.y, c[36].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
LG2H  H0.x, |R1.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R1.w|, H0;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MULR  R0.y, R0, c[41].x;
MULR  R0.x, R0, c[40].z;
ADDR  R0.w, -R0.x, -R0.y;
MADR  R0.w, R0.z, R0, R0.z;
RCPR  R0.y, R0.y;
MULR  R0.x, R0.z, R0;
MULR  R0.w, R0, R0.y;
MULR  R1.x, R0.y, R0;
MULR  R0.xyz, R0.z, c[44];
MADR  R0.xyz, R1.x, c[43], R0;
MADR  R0.xyz, R0.w, c[42], R0;
MAXR  R7.xyz, R0, c[32].x;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R0.x, H0.z, c[40].y;
FRCR  R0.y, R0.x;
MULR  R0.z, R0.y, c[41].x;
RCPR  R1.x, R0.z;
MADH  H0.x, H1.w, c[36].w, H0;
FLRR  R0.x, R0;
ADDR  R0.x, H0, R0;
MULR  R0.x, R0, c[40].z;
ADDR  R0.y, -R0.x, -R0.z;
MADR  R0.y, R1.z, R0, R1.z;
LG2H  H0.x, |R4.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R4.w|, H0;
ADDH  H0.x, H0, c[37].w;
MULR  R0.w, R0.y, R1.x;
MULR  R1.y, R1.z, R0.x;
MULR  R0.xyz, R1.z, c[44];
MULR  R1.x, R1, R1.y;
MADR  R0.xyz, R1.x, c[43], R0;
MADR  R0.xyz, R0.w, c[42], R0;
MAXR  R0.xyz, R0, c[32].x;
ADDR  R1.xyz, R7, -R0;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R0.w, H0.z, c[40].y;
MULH  H0.x, H0, c[38].w;
MADH  H0.z, H0.w, c[36].w, H0.x;
FLRR  R1.w, R0;
ADDR  R1.w, H0.z, R1;
MULR  R4.x, R1.w, c[40].z;
LG2H  H0.x, |R3.w|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
FRCR  R0.w, R0;
MULR  R4.y, R0.w, c[41].x;
MULH  H0.z, |R3.w|, H0;
ADDR  R4.w, -R4.x, -R4.y;
MADH  H0.z, H0, c[40].x, -c[40].x;
MULR  R0.w, H0.z, c[40].y;
FRCR  R1.w, R0;
ADDH  H0.x, H0, c[37].w;
MULH  H0.x, H0, c[38].w;
MADR  R4.w, R4.z, R4, R4.z;
RCPR  R5.w, R4.y;
MULR  R6.w, R4.z, R4.x;
MADR  R1.xyz, R3.x, R1, R0;
MULR  R1.w, R1, c[41].x;
MULR  R4.w, R4, R5;
ADDR  R5.xyz, R5, -R6;
FLRR  R0.w, R0;
MADH  H0.x, H0.y, c[36].w, H0;
ADDR  R0.w, H0.x, R0;
MULR  R0.w, R0, c[40].z;
ADDR  R3.w, -R0, -R1;
MULR  R4.xyz, R4.z, c[44];
MULR  R6.w, R5, R6;
MADR  R4.xyz, R6.w, c[43], R4;
MADR  R4.xyz, R4.w, c[42], R4;
MULR  R4.w, R3.z, R0;
RCPR  R0.w, R1.w;
MAXR  R4.xyz, R4, c[32].x;
MULR  R1.w, R0, R4;
MADR  R3.w, R3.z, R3, R3.z;
MULR  R7.xyz, R3.z, c[44];
MADR  R7.xyz, R1.w, c[43], R7;
MULR  R0.w, R3, R0;
MADR  R7.xyz, R0.w, c[42], R7;
MAXR  R7.xyz, R7, c[32].x;
ADDR  R7.xyz, R7, -R4;
MADR  R0.xyz, R3.x, R7, R4;
ADDR  R4.xyz, R0, -R1;
MADR  R0.xyz, R3.y, R5, R6;
MADR  R1.xyz, R3.y, R4, R1;
ENDIF;
MOVR  R0.w, c[33].y;
MULR  R0.w, R0, c[4];
SGTRC HC.x, R9.w, R0.w;
IF    NE.x;
TEX   R3.xyz, R18, texture[9], 2D;
ELSE;
MOVR  R3.xyz, c[32].x;
ENDIF;
MULR  R1.xyz, R1, R2.w;
MADR  R2.xyz, R3, R1, R2;
ADDR  R0.xyz, R2, R0;
MULR  R2.xyz, R0.y, c[38];
MADR  R2.xyz, R0.x, c[37], R2;
MADR  R0.xyz, R0.z, c[36], R2;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R2.xyz, R1.y, c[38];
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[35].w;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[35].w;
SGER  H0.x, R0, c[36].w;
MULH  H0.y, H0.x, c[36].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[35].x;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[37].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
MULH  H0.y, H0, c[38].w;
MADR  R2.xyz, R1.x, c[37], R2;
MADR  R1.xyz, R1.z, c[36], R2;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R1.zw, R1.xyxy, R0.z;
MULR  R0.z, R1, c[35].w;
MULR  R0.w, R0, c[39].y;
FLRR  R0.z, R0;
FLRR  R0.w, R0;
MOVH  oCol.x, R0.y;
MULR  R0.y, R1.w, c[39];
FLRR  R0.y, R0;
MADH  H0.x, H0, c[32].y, H0.z;
MINR  R0.z, R0, c[35].w;
ADDR  R0.x, R0, -H0.y;
SGER  H0.z, R0, c[36].w;
MULH  H0.y, H0.z, c[36].w;
MINR  R0.w, R0, c[39].z;
MADR  R0.w, R0.x, c[39].x, R0;
ADDR  R0.z, R0, -H0.y;
MOVR  R0.x, c[33];
MADR  H0.y, R0.w, c[39].w, R0.x;
MULR  R0.w, R0.z, c[35].x;
MULH  oCol.y, H0.x, H0;
FLRR  H0.x, R0.w;
MULH  H0.y, H0.x, c[38].w;
ADDH  H0.x, H0, -c[37].w;
ADDR  R0.z, R0, -H0.y;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.y, R0, c[39].z;
MADR  R0.y, R0.z, c[39].x, R0;
MADR  H0.z, R0.y, c[39].w, R0.x;
MADH  H0.x, H0.y, c[32].y, H0;
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
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 7 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 6 [_TexDensity] 2D
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
SetTexture 9 [_TexBackground] 2D
SetTexture 5 [_TexDownScaledZBuffer] 2D
Float 18 [_PlanetRadiusOffsetKm]
Vector 19 [_CaseSwizzle]
Vector 20 [_SwizzleExitUp0]
Vector 21 [_SwizzleExitUp1]
Vector 22 [_SwizzleExitUp2]
Vector 23 [_SwizzleExitUp3]
Vector 24 [_SwizzleEnterDown0]
Vector 25 [_SwizzleEnterDown1]
Vector 26 [_SwizzleEnterDown2]
Vector 27 [_SwizzleEnterDown3]
SetTexture 8 [_MainTex] 2D
Float 28 [_ZBufferDiscrepancyThreshold]
Float 29 [_ShowZBufferDiscrepancies]
Vector 30 [_dUV]
Vector 31 [_InvdUV]

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
def c32, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c33, -1000000.00000000, 0.99500000, 1000000.00000000, 0.10000000
def c34, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c35, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c36, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c37, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c38, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c39, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c40, 0.00097656, 1.00000000, 15.00000000, 1024.00000000
def c41, 0.00390625, 0.00476190, 0.63999999, 0
def c42, 0.07530000, -0.25430000, 1.18920004, 0
def c43, 2.56509995, -1.16649997, -0.39860001, 0
def c44, -1.02170002, 1.97770000, 0.04390000, 0
dcl_texcoord0 v0.xyzw
texldl r7, v0, s2
texldl r6, v0, s3
texldl r9, v0, s0
texldl r8, v0, s1
mov r11.w, r6.y
mad r0.xy, v0, c32.x, c32.y
mov r4, c22
mov r11.z, r7.y
mov r11.x, r9.y
mov r11.y, r8
mov r6.y, r8.z
mov r0.z, c32.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c32.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.x, c7
mov r0.y, c7.x
add r0.y, c13, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c9.x
add r2.xyz, r2, -c5
dp3 r0.z, r1, r2
dp3 r1.x, r2, r2
mad r0.w, -r0.y, r0.y, r1.x
mad r1.y, r0.z, r0.z, -r0.w
rsq r1.z, r1.y
add r0.x, c13, r0
mad r0.x, -r0, r0, r1
mad r0.x, r0.z, r0.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.w, -r0.z, r0.y
cmp_pp r0.y, r0.x, c32.w, c32.z
cmp r0.x, r0, r1.w, c33
cmp r0.x, -r0.y, r0, r0.w
cmp_pp r0.y, r1, c32.w, c32.z
rcp r1.z, r1.z
cmp r1.y, r1, r1.w, c33.x
add r1.z, -r0, r1
cmp r0.y, -r0, r1, r1.z
mov r0.w, c7.x
add r1.y, c13.w, r0.w
mad r1.y, -r1, r1, r1.x
mad r1.z, r0, r0, -r1.y
rsq r1.y, r1.z
rcp r1.y, r1.y
mov r0.w, c7.x
add r0.w, c13.z, r0
mad r0.w, -r0, r0, r1.x
mad r1.x, r0.z, r0.z, -r0.w
add r2.x, -r0.z, r1.y
rsq r0.w, r1.x
rcp r1.y, r0.w
add r1.y, -r0.z, r1
cmp_pp r0.w, r1.z, c32, c32.z
cmp r1.z, r1, r1.w, c33.x
cmp_pp r0.z, r1.x, c32.w, c32
cmp r1.x, r1, r1.w, c33
cmp r0.w, -r0, r1.z, r2.x
cmp r0.z, -r0, r1.x, r1.y
dp4 r0.x, r0, c19
cmp r5.z, -r0.x, c32.w, c32
mov r1, c21
add r1, -c25, r1
mad r3, r5.z, r1, c25
mov r0, c20
add r0, -c24, r0
mad r2, r5.z, r0, c24
mov r0.w, r6
mov r6.w, r6.z
mov r1, c23
add r1, -c27, r1
mad r1, r5.z, r1, c27
add r4, -c26, r4
mad r4, r5.z, r4, c26
mov r0.z, r7.w
dp4 r7.y, r1, r11
mov r0.x, r9.w
mov r0.y, r8.w
dp4 r5.w, r1, r0
dp4 r5.y, r3, r0
dp4 r5.z, r4, r0
dp4 r5.x, r2, r0
dp4 r0.w, r1, r1
add r5, r5, c32.y
dp4 r0.y, r3, r3
dp4 r0.z, r4, r4
dp4 r0.x, r2, r2
mad r0, r0, r5, c32.w
mov r5.w, r6.x
mov r5.z, r7.x
mov r6.z, r7
mov r6.x, r9.z
dp4 r7.z, r1, r6
mov r5.x, r9
mov r5.y, r8.x
dp4 r7.x, r1, r5
dp4 r1.x, r4, r5
dp4 r1.z, r4, r6
dp4 r1.y, r4, r11
mad r1.xyz, r0.z, r7, r1
dp4 r4.x, r3, r5
dp4 r4.z, r3, r6
dp4 r4.y, r3, r11
mad r1.xyz, r0.y, r1, r4
dp4 r3.x, r2, r5
dp4 r3.z, r2, r6
dp4 r3.y, r2, r11
mad r2.xyz, r0.x, r1, r3
mul r1.x, r0, r0.y
mul r1.y, r1.x, r0.z
add r3.xy, v0, c30.xzzw
add r0.xy, r3, c30.zyzw
add r4.xy, r0, -c30.xzzw
mov r0.z, v0.w
mov r4.z, v0.w
mov r3.z, v0.w
add r7.xy, r4, -c30.zyzw
mul r1.zw, r7.xyxy, c31.xyxy
texldl r0.x, r0.xyzz, s5
texldl r1.x, r4.xyzz, s5
add r0.y, r1.x, -r0.x
frc r1.zw, r1
mad r0.y, r1.z, r0, r0.x
texldl r1.x, v0, s5
texldl r3.x, r3.xyzz, s5
add r0.z, r3.x, -r1.x
mad r0.z, r1, r0, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c4.w, -c4.z
rcp r0.y, r0.x
mul r0.y, r0, c4.w
texldl r0.x, v0, s4
add r0.x, r0.y, -r0
mad r1.x, r1.w, r1, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c4.z
mul r7.w, r0.x, r0.z
add r0.x, r7.w, -r1
abs r0.x, r0
mul r2.w, r1.y, r0
mov r7.z, v0.w
if_gt r0.x, c28.x
mad r0.xy, r7, c32.x, c32.y
mul r0.xy, r0, c4
mov r0.z, c32.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c32.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.x, c7
mov r1.y, c7.x
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r4.xyz, r3, c9.x
add r5.xyz, r4, -c5
dp3 r4.w, r5, r0
dp3 r5.w, r5, r5
add r1.y, c14, r1
mad r1.z, -r1.y, r1.y, r5.w
mad r1.w, r4, r4, -r1.z
rsq r3.x, r1.w
add r1.x, c14, r1
mad r1.x, -r1, r1, r5.w
mad r1.x, r4.w, r4.w, -r1
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r4.w, -r1.y
cmp_pp r1.y, r1.x, c32.w, c32.z
cmp r1.x, r1, r10, c33.z
cmp r1.x, -r1.y, r1, r1.z
cmp_pp r1.y, r1.w, c32.w, c32.z
rcp r3.x, r3.x
cmp r1.w, r1, r10.x, c33.z
add r3.x, -r4.w, -r3
cmp r1.y, -r1, r1.w, r3.x
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r3.x, c14.w, r1.z
mad r1.w, -r1, r1, r5
mad r1.z, r4.w, r4.w, -r1.w
mad r3.x, -r3, r3, r5.w
mad r3.y, r4.w, r4.w, -r3.x
rsq r1.w, r1.z
rcp r1.w, r1.w
add r3.x, -r4.w, -r1.w
cmp_pp r1.w, r1.z, c32, c32.z
cmp r1.z, r1, r10.x, c33
cmp r1.z, -r1.w, r1, r3.x
rsq r3.z, r3.y
rcp r3.z, r3.z
cmp r3.x, r3.y, r10, c33.z
add r3.z, -r4.w, -r3
cmp_pp r1.w, r3.y, c32, c32.z
cmp r1.w, -r1, r3.x, r3.z
mov r3.x, c7
add r3.y, c13.x, r3.x
mov r3.x, c7
add r3.z, c13.y, r3.x
mad r3.y, -r3, r3, r5.w
mad r3.x, r4.w, r4.w, -r3.y
mad r3.z, -r3, r3, r5.w
mad r3.w, r4, r4, -r3.z
rsq r3.y, r3.x
rcp r3.y, r3.y
add r3.z, -r4.w, r3.y
cmp_pp r3.y, r3.x, c32.w, c32.z
cmp r3.x, r3, r10, c33
cmp r3.x, -r3.y, r3, r3.z
rsq r6.y, r3.w
cmp_pp r3.y, r3.w, c32.w, c32.z
rcp r6.y, r6.y
dp4 r6.x, r1, c24
dp4 r8.y, r1, c25
cmp r3.w, r3, r10.x, c33.x
add r6.y, -r4.w, r6
cmp r3.y, -r3, r3.w, r6
mov r3.z, c7.x
add r3.w, c13, r3.z
mad r3.w, -r3, r3, r5
mad r6.z, r4.w, r4.w, -r3.w
rsq r3.w, r6.z
rcp r6.y, r3.w
mov r3.z, c7.x
add r3.z, c13, r3
mad r3.z, -r3, r3, r5.w
mad r3.z, r4.w, r4.w, -r3
add r6.w, -r4, r6.y
rsq r3.w, r3.z
rcp r6.y, r3.w
cmp_pp r3.w, r6.z, c32, c32.z
cmp r6.z, r6, r10.x, c33.x
cmp r3.w, -r3, r6.z, r6
add r6.z, -r4.w, r6.y
cmp_pp r6.y, r3.z, c32.w, c32.z
cmp r3.z, r3, r10.x, c33.x
cmp r3.z, -r6.y, r3, r6
dp4 r6.y, r3, c20
dp4 r8.x, r3, c21
add r6.w, r6.y, -r6.x
dp4 r6.z, r3, c19
cmp r6.z, -r6, c32.w, c32
add r8.z, r8.x, -r8.y
mov r6.y, c7.x
add r6.y, c18.x, r6
mad r6.y, -r6, r6, r5.w
mad r6.w, r6.z, r6, r6.x
mad r6.x, r4.w, r4.w, -r6.y
rsq r6.y, r6.x
rcp r6.y, r6.y
add r8.x, -r4.w, -r6.y
cmp_pp r6.y, r6.x, c32.w, c32.z
cmp r6.x, r6, r10, c33.z
cmp r6.x, -r6.y, r6, r8
rcp r0.w, r0.w
mul r6.y, r7.w, r0.w
cmp r6.x, r6, r6, c33.z
mad r8.x, -r6.y, c9, r6
mad r5.w, -c8.x, c8.x, r5
mad r5.w, r4, r4, -r5
rsq r6.x, r5.w
mov r0.w, c4
mad r0.w, c33.y, -r0, r7
mad r8.w, r6.z, r8.z, r8.y
rcp r6.x, r6.x
mul r6.y, r6, c9.x
cmp r0.w, r0, c32, c32.z
mad r8.z, r0.w, r8.x, r6.y
add r0.w, -r4, -r6.x
add r4.w, -r4, r6.x
cmp r8.xy, r5.w, r10, c32.z
mul r10.xyz, r0.zxyw, c12.yzxw
max r6.x, r0.w, c32.z
mad r10.xyz, r0.yzxw, c12.zxyw, -r10
cmp_pp r0.w, r5, c32, c32.z
max r6.y, r4.w, c32.z
cmp r6.xy, -r0.w, r8, r6
min r4.w, r6.y, r8.z
min r5.w, r4, r8
max r8.w, r6.x, c32.z
min r0.w, r4, r6
max r9.w, r8, r0
max r10.w, r9, r5
dp4 r5.w, r1, c26
dp4 r1.y, r1, c27
dp4 r0.w, r3, c22
add r0.w, r0, -r5
mad r0.w, r6.z, r0, r5
dp4 r1.x, r3, c23
add r1.x, r1, -r1.y
mad r1.x, r6.z, r1, r1.y
min r0.w, r4, r0
max r11.w, r10, r0
min r1.x, r4.w, r1
max r5.w, r11, r1.x
add r6.x, r5.w, -r11.w
mov r0.w, c16.x
mov r1.xyz, c15
dp3 r6.y, r10, r10
mad r9.xyz, r0, r8.w, r5
mul r1.w, c34, r0
dp3 r0.w, r9, r9
mul r1.xyz, c33.w, r1
add r11.xyz, r1, r1.w
abs r3.x, r6
mul r8.xyz, -r11, r3.x
pow r3, c35.x, r8.x
pow r12, c35.x, r8.z
mov r8.x, r3
pow r3, c35.x, r8.y
rsq r0.w, r0.w
rcp r3.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r9.xyz, c12
rcp r3.z, r0.w
dp3 r0.w, c6, r9
add r3.x, r3, -c7
add r0.w, -r0, c32
mul r9.y, r3.x, r3.z
mul r9.x, r0.w, c35.y
mov r9.z, c32
texldl r3.zw, r9.xyzz, s6
mul r0.w, r3, c16.x
mad r9.xyz, r3.z, -c15, -r0.w
mov r8.y, r3
pow r3, c35.x, r9.x
mov r8.z, r12
pow r12, c35.x, r9.y
mov r9.x, r3
pow r3, c35.x, r9.z
mov r9.z, r3
mov r9.y, r12
mul r3.xyz, r5.zxyw, c12.yzxw
mad r3.xyz, r5.yzxw, c12.zxyw, -r3
dp3 r3.w, r3, r10
dp3 r0.w, r3, r3
mad r0.w, -c7.x, c7.x, r0
mul r0.w, r6.y, r0
mad r3.x, r3.w, r3.w, -r0.w
rsq r3.y, r3.x
rcp r6.w, r3.y
add r3.y, -r3.w, -r6.w
rcp r6.y, r6.y
mul r9.xyz, r9, c11
texldl r0.w, c35.yyzz, s7
mul r13.xyz, r9, r0.w
dp3 r0.w, r5, c12
mul r14.xyz, r11, r13
cmp r0.w, -r0, c32, c32.z
rcp r10.x, r11.x
rcp r10.z, r11.z
rcp r10.y, r11.y
mul r3.y, r3, r6
add r3.w, -r3, r6
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r3.x
cmp r9.x, -r0.w, c33.z, r3.y
mad r3.xyz, r0, r9.x, r4
add r3.xyz, r3, -c5
dp3 r3.x, r3, c12
mul r3.y, r6, r3.w
cmp r9.y, -r0.w, c33.x, r3
mul r5.xyz, r14, r8
cmp r3.x, -r3, c32.z, c32.w
mul_pp r0.w, r0, r3.x
cmp r18.xy, -r0.w, r9, c33.zxzw
dp3 r3.x, r0, c12
mul r0.x, r3, c17
mul r0.x, r0, c32
add r3.w, r4, -r5
rcp r3.y, r6.x
add r0.w, -r18.x, r5
add r3.z, r18.y, -r11.w
mul_sat r0.w, r0, r3.y
mul_sat r0.y, r3, r3.z
mad r3.z, -r0.w, r0.y, c32.w
mad r0.x, c17, c17, r0
mad r4.xyz, r11, r13, -r5
abs r0.y, r3.w
mul r5.xyz, -r11, r0.y
add r3.y, r0.x, c32.w
pow r0, r3.y, c34.y
mad r0.z, r3.x, r3.x, c32.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c32.w, r0.y
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c34
mul r3.xy, r0, c34.z
pow r0, c35.x, r5.x
mul r0.y, r3, r1.w
mad r1.xyz, r1, r3.x, r0.y
mul r12.xyz, r1, r10
pow r1, c35.x, r5.z
mov r9.x, r0
pow r0, c35.x, r5.y
add r12.w, r11, -r10
abs r0.w, r12
mul r17.xyz, -r11, r0.w
mov r9.z, r1
mov r9.y, r0
mul r3.xyz, r12, r3.z
mul r1.xyz, r10, r3
mul r0.xyz, r9, r14
mul r16.xyz, r1, r4
mad r1.xyz, r11, r13, -r0
add r0.z, r18.y, -r5.w
rcp r0.y, r3.w
add r0.x, r4.w, -r18
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c32.w
mul r0.xyz, r0.x, r12
mul r0.xyz, r0, r10
mul r15.xyz, r0, r1
mov r1, c21
add r1, -c25, r1
mad r3, r6.z, r1, c25
texldl r5.w, r7.xyzz, s0
mov r1.x, r5.w
mov r0, c20
add r0, -c24, r0
mad r4, r6.z, r0, c24
texldl r0.w, r7.xyzz, s2
mov r1.z, r0.w
texldl r0.w, r7.xyzz, s1
mov r1.y, r0.w
texldl r1.w, r7.xyzz, s3
dp4 r6.x, r4, r1
dp4 r4.x, r4, r4
mov r5, c23
mov r0, c22
add r5, -c27, r5
mad r5, r6.z, r5, c27
add r0, -c26, r0
mad r0, r6.z, r0, c26
dp4 r6.y, r3, r1
dp4 r4.y, r3, r3
pow r3, c35.x, r17.y
dp4 r6.z, r0, r1
dp4 r4.z, r0, r0
pow r0, c35.x, r17.x
dp4 r6.w, r5, r1
rcp r0.z, r12.w
add r0.w, r18.y, -r10
add r0.y, -r18.x, r11.w
add r1, r6, c32.y
dp4 r4.w, r5, r5
mad r1, r4, r1, c32.w
mad r5.xyz, r15, r1.w, r16
mov r4.x, r0
mov r4.y, r3
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c32
pow r0, c35.x, r17.z
mov r4.z, r0
mul r3.xyz, r14, r4
mul r0.xyz, r12, r1.w
mad r3.xyz, r11, r13, -r3
mul r0.xyz, r10, r0
mul r0.xyz, r0, r3
mad r5.xyz, r5, r1.z, r0
add r0.w, r10, -r9
abs r0.y, r0.w
mul r6.xyz, -r11, r0.y
rcp r1.z, r0.w
add r0.x, -r18, r10.w
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r6.x
add r3.x, r18.y, -r9.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r6.y
mad r1.z, -r1.w, r0.y, c32.w
mov r6.x, r0
pow r0, c35.x, r6.z
mov r6.z, r0
mov r6.y, r3
mul r0.xyz, r12, r1.z
mul r3.xyz, r14, r6
mul r0.xyz, r10, r0
mad r3.xyz, r11, r13, -r3
mul r15.xyz, r0, r3
add r0.y, r9.w, -r8.w
rcp r1.z, r0.y
add r0.x, -r18, r9.w
abs r0.y, r0
mul r16.xyz, -r11, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c35.x, r16.x
add r3.x, r18.y, -r8.w
mul_sat r0.y, r1.z, r3.x
pow r3, c35.x, r16.y
mad r1.z, -r1.w, r0.y, c32.w
mov r16.x, r0
pow r0, c35.x, r16.z
mov r16.y, r3
mov r16.z, r0
mul r3.xyz, r12, r1.z
mul r0.xyz, r14, r16
mul r3.xyz, r10, r3
mad r0.xyz, r11, r13, -r0
mul r0.xyz, r3, r0
mad r3.xyz, r5, r1.y, r15
mad r0.xyz, r3, r1.x, r0
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r0.w, r0, c39.z
frc r0.z, r0.w
add r0.w, r0, -r0.z
mul_pp r0.z, r1.y, c39.x
mul_pp r0.x, r0, r1.z
add r0.z, r1.x, -r0
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.z
abs_pp r0.z, r0.x
mul r1.xyz, r6, r16
mul r1.xyz, r4, r1
mul r1.xyz, r8, r1
mul r3.xyz, r9, r1
log_pp r0.w, r0.z
frc_pp r1.x, r0.w
add_pp r0.w, r0, -r1.x
exp_pp r1.w, -r0.w
mad_pp r0.z, r0, r1.w, c32.y
mul r4.xyz, r3.y, c38
mad r4.xyz, r3.x, c37, r4
mad r1.xyz, r3.z, c36, r4
add r3.x, r1, r1.y
add r1.z, r1, r3.x
mul_pp r0.z, r0, c40.w
rcp r1.z, r1.z
mul r1.zw, r1.xyxy, r1.z
mul r3.x, r1.z, c35.w
mul r0.z, r0, c41.x
frc r1.x, r0.z
add r1.z, r0, -r1.x
add_pp r0.z, r0.w, c40
frc r3.y, r3.x
add r0.w, r3.x, -r3.y
min r0.w, r0, c35
add r3.x, r0.w, c36.w
mul r1.w, r1, c39.z
frc r3.y, r1.w
add r1.w, r1, -r3.y
cmp r3.x, r3, c32.w, c32.z
mul_pp r0.z, r0, c39.x
cmp_pp r0.x, -r0, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.z
add r0.x, r0, r1.z
mul_pp r0.z, r3.x, c37.w
add r0.w, r0, -r0.z
mul r0.z, r1.x, c41
mul r1.x, r0.w, c34.w
frc r1.z, r1.x
add r1.x, r1, -r1.z
mul_pp r1.z, r1.x, c39.x
add r0.w, r0, -r1.z
min r1.w, r1, c39
mad r1.z, r0.w, c39.y, r1.w
add_pp r0.w, r1.x, c38
exp_pp r1.x, r0.w
mad_pp r0.w, -r3.x, c32.x, c32
mul_pp r0.w, r0, r1.x
mad r1.z, r1, c40.x, c40.y
mul_pp r1.x, r0.w, r1.z
abs_pp r1.z, r1.x
log_pp r1.w, r1.z
frc_pp r3.x, r1.w
add_pp r1.w, r1, -r3.x
exp_pp r3.x, -r1.w
mad_pp r1.z, r1, r3.x, c32.y
mul r0.x, r0, c41.y
add r0.w, -r0.x, -r0.z
add r0.w, r0, c32
mul r3.xyz, r0.y, c44
mul r0.w, r0, r0.y
rcp r0.z, r0.z
mul r0.x, r0, r0.y
mul r0.w, r0, r0.z
mul r0.x, r0.z, r0
mul_pp r0.z, r1, c40.w
mul r3.w, r0.z, c41.x
mad r0.xyz, r0.x, c43, r3
add_pp r1.z, r1.w, c40
frc r3.x, r3.w
mad r0.xyz, r0.w, c42, r0
add r1.w, r3, -r3.x
mul_pp r1.z, r1, c39.x
cmp_pp r1.x, -r1, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.z
mul r1.z, r3.x, c41
add r1.x, r1, r1.w
mul r1.x, r1, c41.y
add r1.w, -r1.x, -r1.z
add r0.w, r1, c32
mul r1.w, r1.x, r1.y
mul r0.w, r0, r1.y
rcp r1.x, r1.z
mul r3.xyz, r1.y, c44
mul r1.y, r1.x, r1.w
max r0.xyz, r0, c32.z
mad r3.xyz, r1.y, c43, r3
mul r0.w, r0, r1.x
mad r3.xyz, r0.w, c42, r3
add r1.xyz, -r0, c32.wzzw
max r3.xyz, r3, c32.z
mad r1.xyz, r1, c29.x, r0
mad r3.xyz, -r3, c29.x, r3
else
add r3.xy, r7, c30.xzzw
add r1.xy, r3, c30.zyzw
mov r1.z, r7
texldl r0, r1.xyzz, s8
abs_pp r1.z, r0.y
log_pp r1.w, r1.z
frc_pp r3.z, r1.w
add_pp r1.w, r1, -r3.z
exp_pp r3.z, -r1.w
mad_pp r1.z, r1, r3, c32.y
mul_pp r1.z, r1, c40.w
mul r3.z, r1, c41.x
add_pp r1.z, r1.w, c40
frc r3.w, r3.z
add r1.w, r3.z, -r3
add r8.xy, r1, -c30.xzzw
mul r3.z, r3.w, c41
mul_pp r1.z, r1, c39.x
cmp_pp r0.y, -r0, c32.w, c32.z
mad_pp r0.y, r0, c37.w, r1.z
add r0.y, r0, r1.w
mul r0.y, r0, c41
add r3.w, -r0.y, -r3.z
mov r8.z, r7
texldl r1, r8.xyzz, s8
abs_pp r4.x, r1.y
log_pp r4.y, r4.x
frc_pp r4.z, r4.y
add_pp r4.w, r4.y, -r4.z
add r3.w, r3, c32
mul r3.w, r3, r0.x
rcp r3.z, r3.z
mul r0.y, r0, r0.x
mul r3.w, r3, r3.z
exp_pp r4.y, -r4.w
mul r0.y, r3.z, r0
mad_pp r3.z, r4.x, r4.y, c32.y
mul r4.xyz, r0.x, c44
mad r4.xyz, r0.y, c43, r4
mul_pp r0.x, r3.z, c40.w
mul r0.y, r0.x, c41.x
mad r4.xyz, r3.w, c42, r4
frc r3.z, r0.y
add r3.w, r0.y, -r3.z
add_pp r0.x, r4.w, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r1.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r3.w
mul r0.y, r3.z, c41.z
mul r0.x, r0, c41.y
add r1.y, -r0.x, -r0
add r1.y, r1, c32.w
mov r3.z, r7
texldl r3, r3.xyzz, s8
abs_pp r4.w, r3.y
log_pp r5.x, r4.w
mul r1.y, r1, r1.x
rcp r0.y, r0.y
mul r0.x, r0, r1
mul r1.y, r1, r0
mul r0.x, r0.y, r0
frc_pp r5.y, r5.x
add_pp r0.y, r5.x, -r5
mul r5.xyz, r1.x, c44
mad r5.xyz, r0.x, c43, r5
exp_pp r1.x, -r0.y
mad_pp r0.x, r4.w, r1, c32.y
mad r5.xyz, r1.y, c42, r5
mul_pp r0.x, r0, c40.w
mul r1.x, r0, c41
frc r1.y, r1.x
add r1.x, r1, -r1.y
add_pp r0.x, r0.y, c40.z
mul_pp r0.y, r0.x, c39.x
cmp_pp r0.x, -r3.y, c32.w, c32.z
mad_pp r0.x, r0, c37.w, r0.y
add r0.x, r0, r1
max r5.xyz, r5, c32.z
max r4.xyz, r4, c32.z
add r6.xyz, r4, -r5
texldl r4, r7.xyzz, s8
add r7.xy, r8, -c30.zyzw
mul r1.x, r0, c41.y
mul r1.y, r1, c41.z
add r3.y, -r1.x, -r1
mul r0.xy, r7, c31
frc r0.xy, r0
mad r6.xyz, r0.x, r6, r5
abs_pp r5.x, r4.y
log_pp r5.y, r5.x
frc_pp r5.z, r5.y
add_pp r5.w, r5.y, -r5.z
add r3.y, r3, c32.w
mul r3.y, r3, r3.x
rcp r1.y, r1.y
mul r1.x, r1, r3
mul r3.y, r3, r1
exp_pp r5.y, -r5.w
mul r1.x, r1.y, r1
mad_pp r1.y, r5.x, r5, c32
mul r5.xyz, r3.x, c44
mad r5.xyz, r1.x, c43, r5
mad r5.xyz, r3.y, c42, r5
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
frc r3.x, r1.y
add r3.y, r1, -r3.x
add_pp r1.x, r5.w, c40.z
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.y, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
rcp r3.y, r1.y
mul r1.x, r1, r4
add r3.x, r3, c32.w
mul r1.y, r3.x, r4.x
abs_pp r3.x, r3.w
mul r1.y, r1, r3
log_pp r4.y, r3.x
mul r1.x, r3.y, r1
frc_pp r3.y, r4
mul r8.xyz, r4.x, c44
mad r8.xyz, r1.x, c43, r8
add_pp r3.y, r4, -r3
exp_pp r1.x, -r3.y
mad r8.xyz, r1.y, c42, r8
mad_pp r1.x, r3, r1, c32.y
mul_pp r1.x, r1, c40.w
mul r1.y, r1.x, c41.x
frc r3.x, r1.y
add_pp r1.x, r3.y, c40.z
add r3.y, r1, -r3.x
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r3.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
add r1.x, r1, r3.y
abs_pp r3.y, r4.w
log_pp r4.x, r3.y
frc_pp r4.y, r4.x
add_pp r4.x, r4, -r4.y
max r8.xyz, r8, c32.z
max r5.xyz, r5, c32.z
add r5.xyz, r5, -r8
mad r5.xyz, r0.x, r5, r8
mul r1.y, r3.x, c41.z
mul r1.x, r1, c41.y
add r3.x, -r1, -r1.y
add r3.x, r3, c32.w
mul r3.x, r3.z, r3
rcp r1.y, r1.y
mul r3.w, r3.x, r1.y
mul r1.x, r3.z, r1
exp_pp r3.x, -r4.x
mul r1.x, r1.y, r1
mad_pp r1.y, r3, r3.x, c32
mul r3.xyz, r3.z, c44
mad r3.xyz, r1.x, c43, r3
mad r3.xyz, r3.w, c42, r3
mul_pp r1.y, r1, c40.w
mul r1.y, r1, c41.x
max r8.xyz, r3, c32.z
frc r3.w, r1.y
add_pp r1.x, r4, c40.z
add r4.x, r1.y, -r3.w
mul_pp r1.y, r1.x, c39.x
cmp_pp r1.x, -r4.w, c32.w, c32.z
mad_pp r1.x, r1, c37.w, r1.y
mul r1.y, r3.w, c41.z
add r1.x, r1, r4
mul r1.x, r1, c41.y
add r3.w, -r1.x, -r1.y
rcp r3.y, r1.y
add r3.x, r3.w, c32.w
mul r1.y, r4.z, r3.x
mul r4.x, r1.y, r3.y
mul r1.y, r4.z, r1.x
mul r4.y, r3, r1
abs_pp r1.x, r1.w
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r4.w, r1.y, -r3
exp_pp r1.y, -r4.w
mad_pp r1.x, r1, r1.y, c32.y
mul_pp r1.y, r1.x, c40.w
abs_pp r1.x, r0.w
mul r5.w, r1.y, c41.x
frc r6.w, r5
log_pp r1.y, r1.x
frc_pp r3.w, r1.y
add_pp r1.y, r1, -r3.w
exp_pp r3.w, -r1.y
mad_pp r1.x, r1, r3.w, c32.y
mul r3.xyz, r4.z, c44
mad r3.xyz, r4.y, c43, r3
mad r3.xyz, r4.x, c42, r3
max r3.xyz, r3, c32.z
add r4.xyz, r8, -r3
add_pp r4.w, r4, c40.z
add r5.w, r5, -r6
mad r3.xyz, r0.x, r4, r3
mul_pp r4.w, r4, c39.x
cmp_pp r1.w, -r1, c32, c32.z
mad_pp r1.w, r1, c37, r4
add r1.w, r1, r5
mul r4.w, r1, c41.y
mul r5.w, r6, c41.z
mul_pp r1.x, r1, c40.w
mul r1.w, r1.x, c41.x
add_pp r1.x, r1.y, c40.z
frc r3.w, r1
add r1.y, r1.w, -r3.w
add r6.w, -r4, -r5
mul r8.x, r1.z, r4.w
rcp r4.w, r5.w
mul r5.w, r4, r8.x
mul r1.w, r3, c41.z
mul_pp r1.x, r1, c39
cmp_pp r0.w, -r0, c32, c32.z
mad_pp r0.w, r0, c37, r1.x
add r0.w, r0, r1.y
mul r0.w, r0, c41.y
add r1.x, -r0.w, -r1.w
add r1.y, r6.w, c32.w
add r3.w, r1.x, c32
mul r6.w, r1.z, r1.y
mul r1.xyz, r1.z, c44
mul r4.w, r6, r4
mad r1.xyz, r5.w, c43, r1
mad r1.xyz, r4.w, c42, r1
mul r4.w, r0.z, r0
mul r3.w, r0.z, r3
rcp r0.w, r1.w
mul r8.xyz, r0.z, c44
mul r0.z, r0.w, r4.w
mad r8.xyz, r0.z, c43, r8
mul r0.z, r3.w, r0.w
mad r8.xyz, r0.z, c42, r8
max r1.xyz, r1, c32.z
max r8.xyz, r8, c32.z
add r8.xyz, r8, -r1
mad r1.xyz, r0.x, r8, r1
add r4.xyz, r1, -r3
add r6.xyz, r6, -r5
mad r1.xyz, r0.y, r6, r5
mad r3.xyz, r0.y, r4, r3
endif
mov r0.x, c4.w
mul r0.x, c33.y, r0
if_gt r7.w, r0.x
texldl r0.xyz, r7.xyzz, s9
else
mov r0.xyz, c32.z
endif
mul r3.xyz, r3, r2.w
mad r0.xyz, r0, r3, r2
add r0.xyz, r0, r1
mul r1.xyz, r0.y, c38
mad r1.xyz, r0.x, c37, r1
mad r0.xyz, r0.z, c36, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c35.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c35.w
add r0.z, r0.x, c36.w
cmp r0.z, r0, c32.w, c32
mul_pp r1.x, r0.z, c37.w
add r1.x, r0, -r1
mul r0.x, r1, c34.w
frc r1.y, r0.x
add r1.y, r0.x, -r1
add_pp r0.x, r1.y, c38.w
exp_pp r1.z, r0.x
mad_pp r0.x, -r0.z, c32, c32.w
mul r2.xyz, r3.y, c38
mad r2.xyz, r3.x, c37, r2
mad r2.xyz, r3.z, c36, r2
add r1.w, r2.x, r2.y
mul_pp r0.x, r0, r1.z
add r0.z, r2, r1.w
rcp r1.z, r0.z
mul_pp r0.z, r1.y, c39.x
mul r1.zw, r2.xyxy, r1.z
mul r1.y, r1.z, c35.w
frc r1.z, r1.y
add r0.z, r1.x, -r0
mul r0.w, r0, c39.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
add r1.y, r1, -r1.z
min r1.x, r1.y, c35.w
min r0.w, r0, c39
mad r0.z, r0, c39.y, r0.w
add r1.y, r1.x, c36.w
cmp r0.w, r1.y, c32, c32.z
mad r0.z, r0, c40.x, c40.y
mul_pp r1.y, r0.w, c37.w
mul_pp oC0.y, r0.x, r0.z
add r0.x, r1, -r1.y
mul r1.x, r1.w, c39.z
mov_pp oC0.x, r0.y
mul r0.y, r0.x, c34.w
frc r0.z, r0.y
add r0.y, r0, -r0.z
mul_pp r0.z, r0.y, c39.x
frc r1.y, r1.x
add r1.x, r1, -r1.y
add r0.x, r0, -r0.z
min r1.x, r1, c39.w
mad r0.z, r0.x, c39.y, r1.x
add_pp r0.x, r0.y, c38.w
exp_pp r0.y, r0.x
mad_pp r0.x, -r0.w, c32, c32.w
mad r0.z, r0, c40.x, c40.y
mul_pp r0.x, r0, r0.y
mul_pp oC0.w, r0.x, r0.z
mov_pp oC0.z, r2.y

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
