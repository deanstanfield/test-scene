// Performs aerial perspective computations taking up to 4 cloud layers into account
//
Shader "Hidden/Nuaj/AerialPerspectiveSimple"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownScaledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[36] = { program.local[0..27],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.1, 0.75 },
		{ 1, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625 } };
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
SHORT OUTPUT oCol = result.color;
MOVR  R2.x, c[29].y;
MOVR  R4.w, c[29].y;
MOVR  R7.w, c[29].y;
MOVR  R16.zw, c[30].xyxw;
MOVR  R8.x, c[0].w;
MOVR  R8.z, c[2].w;
MOVR  R8.y, c[1].w;
MULR  R7.xyz, R8, c[9].x;
ADDR  R4.xyz, R7, -c[5];
DP3R  R6.x, R4, R4;
MULR  R1.zw, fragment.texcoord[0].xyxy, c[4].xyxy;
MOVR  R0.xy, c[4];
MADR  R0.xy, R1.zwzw, c[28].x, -R0;
MOVR  R0.z, c[28].y;
DP3R  R0.w, R0, R0;
RSQR  R3.w, R0.w;
MULR  R0.xyz, R3.w, R0;
MOVR  R0.w, c[28].z;
DP4R  R3.z, R0, c[2];
DP4R  R3.y, R0, c[1];
DP4R  R3.x, R0, c[0];
DP3R  R8.w, R3, R4;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
MULR  R9.x, R8.w, R8.w;
SLTR  R5, R9.x, R0;
MOVXC RC.x, R5;
MOVR  R2.x(EQ), R1;
ADDR  R1, R9.x, -R0;
SGERC HC, R9.x, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R2.x(NE.z), -R8.w, R1;
MOVXC RC.z, R5;
MOVR  R4.w(EQ.z), R2.y;
MOVXC RC.z, R5.w;
MOVR  R7.w(EQ.z), R2.y;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE.y), -R8, R0.x;
RSQR  R0.x, R1.w;
RCPR  R0.x, R0.x;
ADDR  R7.w(NE), -R8, R0.x;
RSQR  R0.x, R1.y;
MOVR  R2.y, c[29];
MOVXC RC.y, R5;
MOVR  R2.y(EQ), R2.z;
RCPR  R0.x, R0.x;
ADDR  R2.y(NE.x), -R8.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
ADDR  R5, R9.x, -R0;
RSQR  R1.y, R5.x;
SLTR  R6, R9.x, R0;
MOVR  R5.x, c[18];
MOVR  R1.x, c[29];
MOVXC RC.x, R6;
MOVR  R1.x(EQ), R2.z;
SGERC HC, R9.x, R0.yzxw;
RCPR  R1.y, R1.y;
ADDR  R1.x(NE.z), -R8.w, -R1.y;
RSQR  R0.x, R5.z;
MOVR  R1.y, c[29].x;
MOVR  R0.w, c[29].x;
MOVXC RC.z, R6;
MOVR  R0.w(EQ.z), R2.z;
RCPR  R0.x, R0.x;
ADDR  R0.w(NE.y), -R8, -R0.x;
RSQR  R0.x, R5.w;
MOVXC RC.y, R6;
MULR  R6.xyz, R3.zxyw, c[12].yzxw;
MADR  R6.xyz, R3.yzxw, c[12].zxyw, -R6;
MOVR  R1.y(EQ), R2.z;
MOVR  R5.w, c[29].x;
MOVR  R1.z, c[29].x;
MOVXC RC.z, R6.w;
MOVR  R1.z(EQ), R2;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R8.w, -R0.x;
RSQR  R0.x, R5.y;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R8.w, -R0.x;
MOVR  R0.xyz, c[5];
MADR  R0.xyz, R8, c[9].x, -R0;
DP3R  R1.w, R0, R3;
DP3R  R8.x, R0, R0;
ADDR  R5.x, R5, c[7];
MULR  R6.w, R1, R1;
MADR  R5.x, -R5, R5, R8;
SLTRC HC.x, R6.w, R5;
MOVR  R5.w(EQ.x), R2.z;
ADDR  R5.y, R6.w, -R5.x;
RSQR  R5.y, R5.y;
SGERC HC.x, R6.w, R5;
RCPR  R5.y, R5.y;
ADDR  R5.w(NE.x), -R1, -R5.y;
MOVXC RC.x, R5.w;
MULR  R5.xyz, R0.zxyw, c[12].yzxw;
MADR  R5.xyz, R0.yzxw, c[12].zxyw, -R5;
DP3R  R0.x, R0, c[12];
SLER  H0.x, R0, c[28].z;
DP3R  R8.y, R5, R5;
DP3R  R5.x, R5, R6;
DP3R  R5.z, R6, R6;
MADR  R5.y, -c[7].x, c[7].x, R8;
MULR  R6.y, R5.z, R5;
MULR  R6.x, R5, R5;
ADDR  R5.y, R6.x, -R6;
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MOVR  R5.w(LT.x), c[29].x;
ADDR  R0.y, -R5.x, R5;
SGTR  H0.y, R6.x, R6;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R5.z, R5.z;
MOVR  R0.z, c[29].y;
MULR  R0.z(NE.x), R5, R0.y;
ADDR  R0.y, -R5.x, -R5;
MOVR  R0.x, c[29];
MULR  R0.x(NE), R0.y, R5.z;
MOVR  R0.y, R0.z;
MOVR  R16.xy, R0;
MADR  R0.xyz, R3, R0.x, R7;
ADDR  R0.xyz, R0, -c[5];
DP3R  R0.x, R0, c[12];
SGTR  H0.y, R0.x, c[28].z;
MADR  R0.z, -c[8].x, c[8].x, R8.x;
MULXC HC.x, H0, H0.y;
MOVR  R16.xy(NE.x), c[29];
ADDR  R0.x, R6.w, -R0.z;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, -R1.w, -R0.x;
ADDR  R1.w, -R1, R0.x;
MAXR  R0.x, R0.y, c[28].z;
MAXR  R0.y, R1.w, c[28].z;
MOVR  R1.w, R1.z;
MOVR  R1.z, R0.w;
RCPR  R0.w, R3.w;
MOVR  R3.w, c[28];
MOVR  R5.xy, c[28].z;
SLTRC HC.x, R6.w, R0.z;
MOVR  R5.xy(EQ.x), R2.zwzw;
SGERC HC.x, R6.w, R0.z;
MOVR  R5.xy(NE.x), R0;
MOVR  R2.w, R7;
MOVR  R2.z, R4.w;
DP4R  R0.x, R1, c[24];
DP4R  R0.y, R2, c[20];
ADDR  R0.z, R0.y, -R0.x;
DP4R  R0.y, R2, c[19];
SGER  H0.y, c[28].z, R0;
MADR  R0.y, H0, R0.z, R0.x;
DP4R  R0.z, R1, c[25];
DP4R  R0.x, R2, c[21];
ADDR  R0.x, R0, -R0.z;
MADR  R0.z, H0.y, R0.x, R0;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
MULR  R0.w, R0.x, R0;
MADR  R4.w, -R0, c[9].x, R5;
MULR  R3.w, R3, c[4];
MAXR  R6.w, R5.x, c[28].z;
SGER  H0.x, R0, R3.w;
MULR  R0.w, R0, c[9].x;
MADR  R0.x, H0, R4.w, R0.w;
MINR  R3.w, R5.y, R0.x;
MINR  R0.y, R3.w, R0;
MAXR  R7.w, R6, R0.y;
MINR  R0.x, R3.w, R0.z;
MAXR  R8.w, R7, R0.x;
DP4R  R0.y, R1, c[26];
DP4R  R0.x, R2, c[22];
ADDR  R0.x, R0, -R0.y;
MADR  R0.x, H0.y, R0, R0.y;
MINR  R0.x, R3.w, R0;
MAXR  R4.w, R8, R0.x;
ADDR  R5.x, R4.w, -R8.w;
ADDR  R6.xy, R16.yxzw, -R4.w;
RCPR  R0.x, R5.x;
ADDR  R5.zw, R16.xyyx, -R8.w;
MULR_SAT R0.y, R0.x, R5.z;
MULR_SAT R0.x, -R6.y, R0;
MULR  R0.w, R0.x, R0.y;
DP3R  R0.x, R3, c[12];
MULR  R0.y, R0.x, c[17].x;
MULR  R0.y, R0, c[28].x;
MADR  R0.y, c[17].x, c[17].x, R0;
ADDR  R0.y, R0, c[30].x;
POWR  R0.z, R0.y, c[30].y;
MULR  R0.x, R0, R0;
ADDR  R0.y, R16.z, c[17].x;
MADR  R3.xyz, R3, R6.w, R4;
MULR  R5.z, R16.w, c[16].x;
RCPR  R0.z, R0.z;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R0.z;
MADR  R0.x, R0, c[29].w, c[29].w;
MULR  R7.xy, R0, c[30].z;
MOVR  R0.x, c[29].z;
MULR  R0.xyz, R0.x, c[15];
ADDR  R9.xyz, R0, R5.z;
MULR  R5.y, R7, R5.z;
MADR  R0.xyz, R0, R7.x, R5.y;
RCPR  R8.x, R9.x;
RCPR  R8.z, R9.z;
RCPR  R8.y, R9.y;
MULR  R10.xyz, R0, R8;
MADR  R0.xyz, R10, -R0.w, R10;
DP3R  R0.w, R3, R3;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.x, R0.w, -c[7];
MOVR  R0.w, c[7].x;
ADDR  R0.w, -R0, c[8].x;
RCPR  R0.w, R0.w;
MULR  R4.y, R3.x, R0.w;
MOVR  R3.xyz, c[6];
DP3R  R0.w, R3, c[12];
MADR  R4.x, -R0.w, c[31].y, c[31].y;
TEX   R11.zw, R4, texture[1], 2D;
MULR  R4.xyz, -R9, |R5.x|;
RCPR  R5.y, |R5.x|;
MULR  R0.w, R11, c[16].x;
MADR  R3.xyz, R11.z, -c[15], -R0.w;
MULR  R0.xyz, R8, R0;
POWR  R5.x, c[31].x, R4.x;
POWR  R5.z, c[31].x, R4.z;
TEX   R0.w, c[31].y, texture[2], 2D;
POWR  R3.x, c[31].x, R3.x;
POWR  R3.z, c[31].x, R3.z;
POWR  R3.y, c[31].x, R3.y;
MULR  R3.xyz, R3, c[11];
MULR  R11.xyz, R3, R0.w;
ADDR  R12.xyz, R11, -R11;
MULR  R3.xyz, R12, R5.y;
POWR  R5.y, c[31].x, R4.y;
MADR  R3.xyz, R9, R11, R3;
MADR  R3.xyz, -R5, R3, R3;
MULR  R15.xyz, R0, R3;
DP4R  R0.x, R1, c[27];
DP4R  R0.y, R2, c[23];
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R3.w, R0;
MAXR  R0.w, R4, R0.x;
ADDR  R1.w, R0, -R4;
MULR  R2.xyz, -R9, |R1.w|;
ADDR  R3.xy, R16.yxzw, -R0.w;
RCPR  R0.x, R1.w;
MULR_SAT R0.y, R0.x, R6.x;
MULR_SAT R0.x, -R3.y, R0;
RCPR  R1.x, |R1.w|;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R10, -R0.x, R10;
MULR  R1.xyz, R12, R1.x;
MOVR  R4, c[27];
ADDR  R4, -R4, c[23];
MULR  R0.xyz, R8, R0;
ADDR  R0.w, R3, -R0;
MADR  R4, H0.y, R4, c[27];
POWR  R6.x, c[31].x, R2.x;
POWR  R6.y, c[31].x, R2.y;
POWR  R6.z, c[31].x, R2.z;
MULR  R2.xyz, |R0.w|, -R9;
MADR  R1.xyz, R9, R11, R1;
MADR  R1.xyz, -R6, R1, R1;
MULR  R14.xyz, R0, R1;
RCPR  R0.x, R0.w;
RCPR  R1.x, |R0.w|;
MULR  R1.xyz, R12, R1.x;
MULR_SAT R0.y, R0.x, R3.x;
ADDR  R0.z, R3.w, -R16.x;
MULR_SAT R0.x, R0.z, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R10, R10;
MOVR  R3, c[26];
ADDR  R3, -R3, c[22];
MADR  R3, H0.y, R3, c[26];
POWR  R7.x, c[31].x, R2.x;
POWR  R7.y, c[31].x, R2.y;
POWR  R7.z, c[31].x, R2.z;
MADR  R1.xyz, R9, R11, R1;
MADR  R1.xyz, -R7, R1, R1;
MULR  R0.xyz, R0, R8;
MULR  R13.xyz, R0, R1;
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R1, H0.y, R0, c[24];
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R2, H0.y, R0, c[25];
DP4R  R0.x, R1, c[30].x;
DP4R  R1.x, R1, R1;
DP4R  R1.y, R2, R2;
DP4R  R0.y, R2, c[30].x;
DP4R  R1.w, R4, R4;
DP4R  R1.z, R3, R3;
DP4R  R0.z, R3, c[30].x;
DP4R  R0.w, R4, c[30].x;
MADR  R0, R0, R1, -R1;
ADDR  R0, R0, c[30].x;
ADDR  R1.w, R8, -R7;
RCPR  R2.x, R1.w;
MADR  R1.xyz, R13, R0.w, R14;
MADR  R1.xyz, R1, R0.z, R15;
ADDR  R0.zw, R16.xyyx, -R7.w;
MULR_SAT R2.y, -R5.w, R2.x;
MULR_SAT R0.z, R2.x, R0;
MULR  R0.z, R2.y, R0;
MULR  R2.xyz, -R9, |R1.w|;
MADR  R3.xyz, R10, -R0.z, R10;
RCPR  R0.z, |R1.w|;
MULR  R4.xyz, R12, R0.z;
POWR  R2.x, c[31].x, R2.x;
POWR  R2.y, c[31].x, R2.y;
POWR  R2.z, c[31].x, R2.z;
MADR  R4.xyz, R9, R11, R4;
MADR  R4.xyz, -R2, R4, R4;
MULR  R3.xyz, R8, R3;
MULR  R3.xyz, R3, R4;
MADR  R1.xyz, R1, R0.y, R3;
ADDR  R0.y, R7.w, -R6.w;
MULR  R4.xyz, -R9, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R16.y, -R6;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R3.xyz, R10, -R0.z, R10;
RCPR  R0.z, |R0.y|;
MULR  R10.xyz, R12, R0.z;
POWR  R4.x, c[31].x, R4.x;
POWR  R4.y, c[31].x, R4.y;
POWR  R4.z, c[31].x, R4.z;
MADR  R9.xyz, R9, R11, R10;
MADR  R9.xyz, -R4, R9, R9;
MULR  R3.xyz, R8, R3;
MULR  R3.xyz, R3, R9;
MADR  R0.xyz, R1, R0.x, R3;
MULR  R1.xyz, R0.y, c[34];
MADR  R1.xyz, R0.x, c[33], R1;
MADR  R0.xyz, R0.z, c[32], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R1.xyz, R2, R4;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R5, R1;
MULR  R1.xyz, R6, R1;
MULR  R1.xyz, R7, R1;
MULR  R2.xyz, R1.y, c[34];
MADR  R2.xyz, R1.x, c[33], R2;
MADR  R1.xyz, R1.z, c[32], R2;
MADH  H0.x, H0, c[28], H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R16;
ADDR  R0.x, R1, R1.y;
ADDR  R0.x, R1.z, R0;
RCPR  R0.x, R0.x;
MULR  R0.zw, R1.xyxy, R0.x;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MULH  oCol.y, H0.x, H0.z;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R16;
MADH  H0.x, H0, c[28], H0.y;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c28, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c29, 0.99500000, 1000000.00000000, -1000000.00000000, 0.10000000
def c30, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c31, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c32, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c33, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c34, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c35, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c36, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c28.x, c28.y
mul r0.xy, r0, c4
mov r0.z, c28.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c28.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mul r7.xyz, r0.zxyw, c12.yzxw
mad r7.xyz, r0.yzxw, c12.zxyw, -r7
mov r1.z, c7.x
mov r1.w, c7.x
dp3 r9.y, r7, r7
add r1.w, c14.y, r1
rcp r0.w, r0.w
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r3.xyz, r3, c9.x
add r4.xyz, r3, -c5
dp3 r1.x, r4, r4
add r1.z, c14.x, r1
dp3 r1.y, r4, r0
mad r4.w, -r1, r1, r1.x
mad r5.z, r1.y, r1.y, -r4.w
mad r1.z, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2.x, c29.y
cmp r2.x, -r1.w, r1.z, r4.w
rsq r5.w, r5.z
rcp r5.w, r5.w
add r4.w, -r1.y, -r5
cmp_pp r1.w, r5.z, c28, c28.z
cmp r2.y, r5.z, r2, c29
cmp r2.y, -r1.w, r2, r4.w
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r4.w, c14, r1.z
mad r1.w, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1.w
mad r4.w, -r4, r4, r1.x
mad r5.z, r1.y, r1.y, -r4.w
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2, c29.y
cmp r2.z, -r1.w, r1, r4.w
rsq r5.w, r5.z
rcp r5.w, r5.w
add r4.w, -r1.y, -r5
cmp r1.w, r5.z, r2, c29.y
cmp_pp r1.z, r5, c28.w, c28
cmp r2.w, -r1.z, r1, r4
mov r1.w, c7.x
add r4.w, c13.x, r1
mov r1.w, c7.x
add r5.z, c13.y, r1.w
mad r4.w, -r4, r4, r1.x
mad r1.w, r1.y, r1.y, -r4
mad r5.z, -r5, r5, r1.x
mad r5.w, r1.y, r1.y, -r5.z
rsq r4.w, r1.w
rcp r4.w, r4.w
add r5.z, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r8.x, -r4.w, r1.w, r5.z
rsq r6.x, r5.w
rcp r6.x, r6.x
dp4 r1.z, r2, c24
cmp r5.z, r5.w, r3.w, c29
add r6.x, -r1.y, r6
cmp_pp r4.w, r5, c28, c28.z
cmp r8.y, -r4.w, r5.z, r6.x
mov r1.w, c7.x
add r4.w, c13, r1
mad r4.w, -r4, r4, r1.x
mad r5.z, r1.y, r1.y, -r4.w
rsq r4.w, r5.z
rcp r5.w, r4.w
add r6.x, -r1.y, r5.w
cmp_pp r5.w, r5.z, c28, c28.z
cmp r5.z, r5, r3.w, c29
cmp r8.w, -r5, r5.z, r6.x
mov r1.w, c7.x
add r1.w, c13.z, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
rcp r4.w, r4.w
add r5.z, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r8.z, -r4.w, r1.w, r5
dp4 r1.w, r8, c20
add r5.z, r1.w, -r1
dp4 r4.w, r8, c19
cmp r9.w, -r4, c28, c28.z
mad r1.z, r9.w, r5, r1
mov r1.w, c7.x
add r1.w, c18.x, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
dp4 r5.w, r2, c25
dp4 r5.z, r8, c21
add r5.z, r5, -r5.w
mad r5.w, r9, r5.z, r5
rcp r4.w, r4.w
add r5.z, -r1.y, -r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.y
cmp r1.w, -r4, r1, r5.z
cmp r3.w, r1, r1, c29.y
mad r1.x, -c8, c8, r1
mad r1.w, r1.y, r1.y, -r1.x
texldl r1.x, v0, s0
mul r4.w, r1.x, r0
mad r5.z, -r4.w, c9.x, r3.w
rsq r3.w, r1.w
mov r0.w, c4
mad r0.w, c29.x, -r0, r1.x
rcp r3.w, r3.w
mul r1.x, r4.w, c9
cmp r0.w, r0, c28, c28.z
mad r4.w, r0, r5.z, r1.x
add r0.w, -r1.y, -r3
add r1.y, -r1, r3.w
max r1.x, r0.w, c28.z
cmp_pp r0.w, r1, c28, c28.z
cmp r5.xy, r1.w, r5, c28.z
max r1.y, r1, c28.z
cmp r1.xy, -r0.w, r5, r1
min r3.w, r1.y, r4
min r1.y, r3.w, r5.w
max r5.w, r1.x, c28.z
min r0.w, r3, r1.z
max r6.w, r5, r0
max r7.w, r6, r1.y
mad r6.xyz, r0, r5.w, r4
dp4 r1.x, r2, c26
dp4 r0.w, r8, c22
add r0.w, r0, -r1.x
mad r0.w, r9, r0, r1.x
dp4 r1.z, r2, c27
dp4 r1.y, r8, c23
min r0.w, r3, r0
max r8.w, r7, r0
add r1.y, r1, -r1.z
mad r1.x, r9.w, r1.y, r1.z
min r1.x, r3.w, r1
max r4.w, r8, r1.x
add r9.x, r4.w, -r8.w
mov r0.w, c16.x
mul r1.w, c30, r0
dp3 r0.w, r6, r6
mov r1.xyz, c15
mul r1.xyz, c29.w, r1
add r8.xyz, r1, r1.w
abs r2.x, r9
mul r5.xyz, -r8, r2.x
pow r2, c31.x, r5.x
pow r10, c31.x, r5.z
mov r5.x, r2
pow r2, c31.x, r5.y
rsq r0.w, r0.w
rcp r2.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r6.xyz, c12
rcp r2.z, r0.w
dp3 r0.w, c6, r6
add r2.x, r2, -c7
add r0.w, -r0, c28
mul r6.y, r2.x, r2.z
mul r6.x, r0.w, c31.y
mov r6.z, c28
texldl r2.zw, r6.xyzz, s1
mul r0.w, r2, c16.x
mad r6.xyz, r2.z, -c15, -r0.w
mov r5.y, r2
pow r2, c31.x, r6.x
mov r5.z, r10
pow r10, c31.x, r6.y
mov r6.x, r2
pow r2, c31.x, r6.z
mov r6.z, r2
mov r6.y, r10
mul r2.xyz, r4.zxyw, c12.yzxw
mad r2.xyz, r4.yzxw, c12.zxyw, -r2
dp3 r2.w, r2, r7
dp3 r0.w, r2, r2
mad r0.w, -c7.x, c7.x, r0
mul r0.w, r9.y, r0
mad r2.x, r2.w, r2.w, -r0.w
rsq r2.y, r2.x
mul r6.xyz, r6, c11
texldl r0.w, c31.yyzz, s2
mul r10.xyz, r6, r0.w
rcp r6.y, r2.y
add r2.y, -r2.w, -r6
rcp r6.z, r9.y
dp3 r0.w, r4, c12
mul r11.xyz, r8, r10
cmp r0.w, -r0, c28, c28.z
rcp r7.x, r8.x
rcp r7.z, r8.z
rcp r7.y, r8.y
mul r2.y, r2, r6.z
add r2.w, -r2, r6.y
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r2.x
cmp r6.x, -r0.w, c29.y, r2.y
mad r2.xyz, r0, r6.x, r3
add r2.xyz, r2, -c5
dp3 r2.x, r2, c12
mul r2.y, r6.z, r2.w
cmp r6.y, -r0.w, c29.z, r2
mul r4.xyz, r11, r5
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, r2.x
cmp r15.xy, -r0.w, r6, c29.yzzw
dp3 r2.x, r0, c12
mul r0.x, r2, c17
mul r0.x, r0, c28
add r2.w, r3, -r4
rcp r2.y, r9.x
add r0.w, -r15.x, r4
add r2.z, r15.y, -r8.w
mul_sat r0.w, r0, r2.y
mul_sat r0.y, r2, r2.z
mad r2.z, -r0.w, r0.y, c28.w
mad r0.x, c17, c17, r0
mad r3.xyz, r8, r10, -r4
abs r0.y, r2.w
mul r4.xyz, -r8, r0.y
add r2.y, r0.x, c28.w
pow r0, r2.y, c30.y
mad r0.z, r2.x, r2.x, c28.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c28.w, r0.y
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c30
mul r2.xy, r0, c30.z
pow r0, c31.x, r4.x
mul r0.y, r2, r1.w
mad r1.xyz, r1, r2.x, r0.y
mul r9.xyz, r1, r7
pow r1, c31.x, r4.z
mov r6.x, r0
pow r0, c31.x, r4.y
add r10.w, r8, -r7
abs r0.w, r10
mul r14.xyz, -r8, r0.w
mov r6.z, r1
mov r6.y, r0
mul r2.xyz, r9, r2.z
mul r1.xyz, r7, r2
mul r0.xyz, r6, r11
mul r13.xyz, r1, r3
mad r1.xyz, r8, r10, -r0
add r0.z, r15.y, -r4.w
rcp r0.y, r2.w
add r0.x, r3.w, -r15
mov r4, c23
add r4, -c27, r4
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c28.w
mul r0.xyz, r0.x, r9
mul r0.xyz, r0, r7
mul r12.xyz, r0, r1
mov r1, c20
add r1, -c24, r1
mad r3, r9.w, r1, c24
mov r0, c21
add r0, -c25, r0
mad r2, r9.w, r0, c25
dp4 r0.x, r3, c28.w
dp4 r3.x, r3, r3
mad r4, r9.w, r4, c27
mov r1, c22
add r1, -c26, r1
mad r1, r9.w, r1, c26
dp4 r3.y, r2, r2
dp4 r0.y, r2, c28.w
pow r2, c31.x, r14.y
dp4 r3.z, r1, r1
dp4 r0.w, r4, c28.w
dp4 r0.z, r1, c28.w
add r0, r0, c28.y
dp4 r3.w, r4, r4
mad r1, r3, r0, c28.w
pow r0, c31.x, r14.x
mad r4.xyz, r12, r1.w, r13
mov r3.x, r0
mov r3.y, r2
rcp r0.z, r10.w
add r0.w, r15.y, -r7
add r0.y, -r15.x, r8.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c28
pow r0, c31.x, r14.z
mov r3.z, r0
mul r2.xyz, r11, r3
mul r0.xyz, r9, r1.w
mad r2.xyz, r8, r10, -r2
mul r0.xyz, r7, r0
mul r0.xyz, r0, r2
mad r12.xyz, r4, r1.z, r0
add r0.w, r7, -r6
abs r0.y, r0.w
mul r4.xyz, -r8, r0.y
rcp r1.z, r0.w
add r0.x, -r15, r7.w
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r4.x
add r2.x, r15.y, -r6.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r4.z
mad r1.z, -r1.w, r0.y, c28.w
mov r4.x, r0
pow r0, c31.x, r4.y
mov r4.y, r0
mov r4.z, r2
mul r0.xyz, r9, r1.z
mul r2.xyz, r11, r4
mul r0.xyz, r7, r0
mad r2.xyz, r8, r10, -r2
mul r13.xyz, r0, r2
add r0.y, r6.w, -r5.w
rcp r1.z, r0.y
add r0.x, -r15, r6.w
abs r0.y, r0
mul r14.xyz, -r8, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r14.x
add r2.x, r15.y, -r5.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r14.y
mad r1.z, -r1.w, r0.y, c28.w
mov r14.x, r0
pow r0, c31.x, r14.z
mov r14.y, r2
mov r14.z, r0
mul r2.xyz, r9, r1.z
mul r0.xyz, r11, r14
mul r2.xyz, r7, r2
mad r0.xyz, r8, r10, -r0
mul r0.xyz, r2, r0
mad r2.xyz, r12, r1.y, r13
mad r0.xyz, r2, r1.x, r0
mul r1.xyz, r0.y, c34
mad r1.xyz, r0.x, c33, r1
mad r0.xyz, r0.z, c32, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
mul r1.xyz, r4, r14
mul r2.xyz, r3, r1
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c31.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c31.w
add r0.z, r0.x, c32.w
cmp r0.z, r0, c28.w, c28
mul_pp r1.x, r0.z, c33.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c30.w
mul r2.xyz, r5, r2
mul r2.xyz, r6, r2
mul r3.xyz, r2.y, c34
frc r1.x, r0
mad r3.xyz, r2.x, c33, r3
add r2.x, r0, -r1
mad r1.xyz, r2.z, c32, r3
add r2.z, r1.x, r1.y
add_pp r0.x, r2, c34.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c28, c28.w
add r1.z, r1, r2
rcp r0.z, r1.z
mul r2.zw, r1.xyxy, r0.z
mul r1.x, r2.z, c31.w
frc r1.z, r1.x
add r1.z, r1.x, -r1
mul r0.w, r0, c35.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r1.z, r1, c31.w
add r1.x, r1.z, c32.w
mul_pp r0.z, r2.x, c35.x
mul_pp r0.x, r0, r2.y
add r0.z, r1.w, -r0
min r0.w, r0, c35
mad r0.z, r0, c35.y, r0.w
cmp r1.x, r1, c28.w, c28.z
mad r0.z, r0, c36.x, c36.y
mul_pp r0.w, r1.x, c33
add r0.w, r1.z, -r0
mul_pp oC0.y, r0.x, r0.z
mul r0.x, r0.w, c30.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul_pp r0.z, r0.x, c35.x
mul r1.z, r2.w, c35
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0.w, -r0
min r1.z, r1, c35.w
mad r0.z, r0, c35.y, r1
add_pp r0.x, r0, c34.w
mad r0.w, r0.z, c36.x, c36.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c28, c28.w
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[36] = { program.local[0..27],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.1, 0.75 },
		{ 1, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625 } };
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
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R2.x, c[29].y;
MOVR  R4.w, c[29].y;
MOVR  R7.w, c[29].y;
MOVR  R17.zw, c[30].xyxw;
MOVR  R8.x, c[0].w;
MOVR  R8.z, c[2].w;
MOVR  R8.y, c[1].w;
MULR  R7.xyz, R8, c[9].x;
ADDR  R4.xyz, R7, -c[5];
DP3R  R6.x, R4, R4;
MULR  R1.zw, fragment.texcoord[0].xyxy, c[4].xyxy;
MOVR  R0.xy, c[4];
MADR  R0.xy, R1.zwzw, c[28].x, -R0;
MOVR  R0.z, c[28].y;
DP3R  R0.w, R0, R0;
RSQR  R3.w, R0.w;
MULR  R0.xyz, R3.w, R0;
MOVR  R0.w, c[28].z;
DP4R  R3.z, R0, c[2];
DP4R  R3.y, R0, c[1];
DP4R  R3.x, R0, c[0];
DP3R  R8.w, R3, R4;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
MULR  R9.x, R8.w, R8.w;
SLTR  R5, R9.x, R0;
MOVXC RC.x, R5;
MOVR  R2.x(EQ), R1;
ADDR  R1, R9.x, -R0;
SGERC HC, R9.x, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R2.x(NE.z), -R8.w, R1;
MOVXC RC.z, R5;
MOVR  R4.w(EQ.z), R2.y;
MOVXC RC.z, R5.w;
MOVR  R7.w(EQ.z), R2.y;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE.y), -R8, R0.x;
RSQR  R0.x, R1.w;
RCPR  R0.x, R0.x;
ADDR  R7.w(NE), -R8, R0.x;
RSQR  R0.x, R1.y;
MOVR  R2.y, c[29];
MOVXC RC.y, R5;
MOVR  R2.y(EQ), R2.z;
RCPR  R0.x, R0.x;
ADDR  R2.y(NE.x), -R8.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
ADDR  R5, R9.x, -R0;
RSQR  R1.y, R5.x;
SLTR  R6, R9.x, R0;
MOVR  R5.x, c[18];
MOVR  R1.x, c[29];
MOVXC RC.x, R6;
MOVR  R1.x(EQ), R2.z;
SGERC HC, R9.x, R0.yzxw;
RCPR  R1.y, R1.y;
ADDR  R1.x(NE.z), -R8.w, -R1.y;
RSQR  R0.x, R5.z;
MOVR  R1.y, c[29].x;
MOVR  R0.w, c[29].x;
MOVXC RC.z, R6;
MOVR  R0.w(EQ.z), R2.z;
RCPR  R0.x, R0.x;
ADDR  R0.w(NE.y), -R8, -R0.x;
RSQR  R0.x, R5.w;
MOVXC RC.y, R6;
MULR  R6.xyz, R3.zxyw, c[12].yzxw;
MADR  R6.xyz, R3.yzxw, c[12].zxyw, -R6;
MOVR  R1.y(EQ), R2.z;
MOVR  R5.w, c[29].x;
MOVR  R1.z, c[29].x;
MOVXC RC.z, R6.w;
MOVR  R1.z(EQ), R2;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R8.w, -R0.x;
RSQR  R0.x, R5.y;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R8.w, -R0.x;
MOVR  R0.xyz, c[5];
MADR  R0.xyz, R8, c[9].x, -R0;
DP3R  R1.w, R0, R3;
DP3R  R8.x, R0, R0;
ADDR  R5.x, R5, c[7];
MULR  R6.w, R1, R1;
MADR  R5.x, -R5, R5, R8;
SLTRC HC.x, R6.w, R5;
MOVR  R5.w(EQ.x), R2.z;
ADDR  R5.y, R6.w, -R5.x;
RSQR  R5.y, R5.y;
SGERC HC.x, R6.w, R5;
RCPR  R5.y, R5.y;
ADDR  R5.w(NE.x), -R1, -R5.y;
MOVXC RC.x, R5.w;
MULR  R5.xyz, R0.zxyw, c[12].yzxw;
MADR  R5.xyz, R0.yzxw, c[12].zxyw, -R5;
DP3R  R0.x, R0, c[12];
SLER  H0.x, R0, c[28].z;
DP3R  R8.y, R5, R5;
DP3R  R5.x, R5, R6;
DP3R  R5.z, R6, R6;
MADR  R5.y, -c[7].x, c[7].x, R8;
MULR  R6.y, R5.z, R5;
MULR  R6.x, R5, R5;
ADDR  R5.y, R6.x, -R6;
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MOVR  R5.w(LT.x), c[29].x;
ADDR  R0.y, -R5.x, R5;
SGTR  H0.y, R6.x, R6;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R5.z, R5.z;
MOVR  R0.z, c[29].y;
MULR  R0.z(NE.x), R5, R0.y;
ADDR  R0.y, -R5.x, -R5;
MOVR  R0.x, c[29];
MULR  R0.x(NE), R0.y, R5.z;
MOVR  R0.y, R0.z;
MOVR  R17.xy, R0;
MADR  R0.xyz, R3, R0.x, R7;
ADDR  R0.xyz, R0, -c[5];
DP3R  R0.x, R0, c[12];
SGTR  H0.y, R0.x, c[28].z;
MADR  R0.z, -c[8].x, c[8].x, R8.x;
MULXC HC.x, H0, H0.y;
MOVR  R17.xy(NE.x), c[29];
ADDR  R0.x, R6.w, -R0.z;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, -R1.w, -R0.x;
ADDR  R1.w, -R1, R0.x;
MAXR  R0.x, R0.y, c[28].z;
MAXR  R0.y, R1.w, c[28].z;
MOVR  R1.w, R1.z;
MOVR  R1.z, R0.w;
RCPR  R0.w, R3.w;
MOVR  R3.w, c[28];
MOVR  R5.xy, c[28].z;
SLTRC HC.x, R6.w, R0.z;
MOVR  R5.xy(EQ.x), R2.zwzw;
SGERC HC.x, R6.w, R0.z;
MOVR  R5.xy(NE.x), R0;
MOVR  R2.w, R7;
MOVR  R2.z, R4.w;
DP4R  R0.x, R1, c[24];
DP4R  R0.y, R2, c[20];
ADDR  R0.z, R0.y, -R0.x;
DP4R  R0.y, R2, c[19];
SGER  H0.y, c[28].z, R0;
MADR  R0.y, H0, R0.z, R0.x;
DP4R  R0.z, R1, c[25];
DP4R  R0.x, R2, c[21];
ADDR  R0.x, R0, -R0.z;
MADR  R0.z, H0.y, R0.x, R0;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
MULR  R0.w, R0.x, R0;
MADR  R4.w, -R0, c[9].x, R5;
MULR  R3.w, R3, c[4];
MAXR  R7.w, R5.x, c[28].z;
SGER  H0.x, R0, R3.w;
MULR  R0.w, R0, c[9].x;
MADR  R0.x, H0, R4.w, R0.w;
MINR  R3.w, R5.y, R0.x;
MINR  R0.y, R3.w, R0;
MAXR  R8.w, R7, R0.y;
MINR  R0.x, R3.w, R0.z;
MAXR  R9.w, R8, R0.x;
DP4R  R0.y, R1, c[26];
DP4R  R0.x, R2, c[22];
ADDR  R0.x, R0, -R0.y;
MADR  R0.x, H0.y, R0, R0.y;
MINR  R0.x, R3.w, R0;
MAXR  R4.w, R9, R0.x;
ADDR  R5.z, R4.w, -R9.w;
ADDR  R5.xy, R17.yxzw, -R4.w;
RCPR  R0.x, R5.z;
ADDR  R6.zw, R17.xyyx, -R9.w;
MULR_SAT R0.y, R0.x, R6.z;
MULR_SAT R0.x, -R5.y, R0;
MULR  R0.w, R0.x, R0.y;
DP3R  R0.x, R3, c[12];
MULR  R0.y, R0.x, c[17].x;
MULR  R0.y, R0, c[28].x;
MADR  R0.y, c[17].x, c[17].x, R0;
ADDR  R0.y, R0, c[30].x;
POWR  R0.z, R0.y, c[30].y;
MULR  R0.x, R0, R0;
ADDR  R0.y, R17.z, c[17].x;
MADR  R3.xyz, R3, R7.w, R4;
MULR  R5.w, R17, c[16].x;
RCPR  R0.z, R0.z;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R0.z;
MADR  R0.x, R0, c[29].w, c[29].w;
MULR  R6.xy, R0, c[30].z;
MOVR  R0.x, c[29].z;
MULR  R0.xyz, R0.x, c[15];
ADDR  R10.xyz, R0, R5.w;
MULR  R5.y, R6, R5.w;
MADR  R0.xyz, R0, R6.x, R5.y;
RCPR  R9.x, R10.x;
RCPR  R9.z, R10.z;
RCPR  R9.y, R10.y;
MULR  R11.xyz, R0, R9;
MADR  R0.xyz, R11, -R0.w, R11;
DP3R  R0.w, R3, R3;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.x, R0.w, -c[7];
MOVR  R0.w, c[7].x;
ADDR  R0.w, -R0, c[8].x;
RCPR  R0.w, R0.w;
MULR  R4.y, R3.x, R0.w;
MOVR  R3.xyz, c[6];
DP3R  R0.w, R3, c[12];
MADR  R4.x, -R0.w, c[31].y, c[31].y;
TEX   R12.zw, R4, texture[1], 2D;
MULR  R4.xyz, -R10, |R5.z|;
MULR  R0.w, R12, c[16].x;
MADR  R3.xyz, R12.z, -c[15], -R0.w;
MULR  R0.xyz, R9, R0;
RCPR  R5.y, |R5.z|;
POWR  R6.x, c[31].x, R4.x;
POWR  R6.y, c[31].x, R4.y;
POWR  R6.z, c[31].x, R4.z;
TEX   R0.w, c[31].y, texture[2], 2D;
POWR  R3.x, c[31].x, R3.x;
POWR  R3.z, c[31].x, R3.z;
POWR  R3.y, c[31].x, R3.y;
MULR  R3.xyz, R3, c[11];
MULR  R12.xyz, R3, R0.w;
ADDR  R13.xyz, R12, -R12;
MULR  R3.xyz, R13, R5.y;
MADR  R3.xyz, R10, R12, R3;
MADR  R3.xyz, -R6, R3, R3;
MULR  R16.xyz, R0, R3;
DP4R  R0.x, R1, c[27];
DP4R  R0.y, R2, c[23];
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R3.w, R0;
MAXR  R0.w, R4, R0.x;
ADDR  R1.w, R0, -R4;
MULR  R2.xyz, -R10, |R1.w|;
ADDR  R3.xy, R17.yxzw, -R0.w;
RCPR  R0.x, R1.w;
MULR_SAT R0.y, R0.x, R5.x;
MULR_SAT R0.x, -R3.y, R0;
RCPR  R1.x, |R1.w|;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R11, -R0.x, R11;
MULR  R1.xyz, R13, R1.x;
MOVR  R4, c[27];
ADDR  R4, -R4, c[23];
MULR  R0.xyz, R9, R0;
ADDR  R0.w, R3, -R0;
MADR  R4, H0.y, R4, c[27];
POWR  R7.x, c[31].x, R2.x;
POWR  R7.y, c[31].x, R2.y;
POWR  R7.z, c[31].x, R2.z;
MULR  R2.xyz, |R0.w|, -R10;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R7, R1, R1;
MULR  R15.xyz, R0, R1;
RCPR  R0.x, R0.w;
ADDR  R0.z, R3.w, -R17.x;
MULR_SAT R0.y, R0.x, R3.x;
MULR_SAT R0.x, R0.z, R0;
RCPR  R1.x, |R0.w|;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R11, R11;
MULR  R1.xyz, R13, R1.x;
MOVR  R3.yzw, c[30].x;
POWR  R8.x, c[31].x, R2.x;
POWR  R8.y, c[31].x, R2.y;
POWR  R8.z, c[31].x, R2.z;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R8, R1, R1;
MULR  R0.xyz, R0, R9;
MULR  R14.xyz, R0, R1;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R2, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R1, H0.y, R0, c[24];
TEX   R0.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R3.x, R0.w;
DP4R  R5.x, R3, R1;
DP4R  R1.x, R1, R1;
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R0, H0.y, R0, c[26];
DP4R  R1.y, R2, R2;
DP4R  R5.y, R3, R2;
DP4R  R5.z, R3, R0;
DP4R  R5.w, R3, R4;
DP4R  R1.w, R4, R4;
DP4R  R1.z, R0, R0;
MADR  R0, R5, R1, -R1;
ADDR  R0, R0, c[30].x;
ADDR  R1.w, R9, -R8;
RCPR  R2.x, R1.w;
MADR  R1.xyz, R14, R0.w, R15;
MADR  R1.xyz, R1, R0.z, R16;
ADDR  R0.zw, R17.xyyx, -R8.w;
MULR_SAT R2.y, -R6.w, R2.x;
MULR_SAT R0.z, R2.x, R0;
MULR  R0.z, R2.y, R0;
MULR  R2.xyz, -R10, |R1.w|;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R1.w|;
MULR  R4.xyz, R13, R0.z;
POWR  R2.x, c[31].x, R2.x;
POWR  R2.y, c[31].x, R2.y;
POWR  R2.z, c[31].x, R2.z;
MADR  R4.xyz, R10, R12, R4;
MADR  R4.xyz, -R2, R4, R4;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R4;
MADR  R1.xyz, R1, R0.y, R3;
ADDR  R0.y, R8.w, -R7.w;
MULR  R4.xyz, -R10, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R17.y, -R7;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R0.y|;
MULR  R5.xyz, R13, R0.z;
POWR  R4.x, c[31].x, R4.x;
POWR  R4.y, c[31].x, R4.y;
POWR  R4.z, c[31].x, R4.z;
MADR  R5.xyz, R10, R12, R5;
MADR  R5.xyz, -R4, R5, R5;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R5;
MADR  R0.xyz, R1, R0.x, R3;
MULR  R1.xyz, R0.y, c[34];
MADR  R1.xyz, R0.x, c[33], R1;
MADR  R0.xyz, R0.z, c[32], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R1.xyz, R2, R4;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R6, R1;
MULR  R1.xyz, R7, R1;
MULR  R1.xyz, R8, R1;
MULR  R2.xyz, R1.y, c[34];
MADR  R2.xyz, R1.x, c[33], R2;
MADR  R1.xyz, R1.z, c[32], R2;
MADH  H0.x, H0, c[28], H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
ADDR  R0.x, R1, R1.y;
ADDR  R0.x, R1.z, R0;
RCPR  R0.x, R0.x;
MULR  R0.zw, R1.xyxy, R0.x;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MULH  oCol.y, H0.x, H0.z;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
MADH  H0.x, H0, c[28], H0.y;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c28, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c29, 0.99500000, 1000000.00000000, -1000000.00000000, 0.10000000
def c30, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c31, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c32, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c33, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c34, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c35, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c36, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c28.x, c28.y
mul r0.xy, r0, c4
mov r0.z, c28.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c28.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.z, c7.x
mov r1.w, c7.x
add r1.w, c14.y, r1
rcp r0.w, r0.w
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r3.xyz, r3, c9.x
add r4.xyz, r3, -c5
dp3 r1.x, r4, r4
add r1.z, c14.x, r1
dp3 r1.y, r4, r0
mad r4.w, -r1, r1, r1.x
mad r5.x, r1.y, r1.y, -r4.w
mad r1.z, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2.x, c29.y
cmp r2.x, -r1.w, r1.z, r4.w
rsq r5.y, r5.x
rcp r5.y, r5.y
add r4.w, -r1.y, -r5.y
cmp_pp r1.w, r5.x, c28, c28.z
cmp r2.y, r5.x, r2, c29
cmp r2.y, -r1.w, r2, r4.w
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r4.w, c14, r1.z
mad r1.w, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1.w
mad r4.w, -r4, r4, r1.x
mad r5.x, r1.y, r1.y, -r4.w
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2, c29.y
cmp r2.z, -r1.w, r1, r4.w
rsq r5.y, r5.x
rcp r5.y, r5.y
add r4.w, -r1.y, -r5.y
cmp r1.w, r5.x, r2, c29.y
cmp_pp r1.z, r5.x, c28.w, c28
cmp r2.w, -r1.z, r1, r4
mov r1.w, c7.x
add r4.w, c13.x, r1
mov r1.w, c7.x
add r5.x, c13.y, r1.w
mad r4.w, -r4, r4, r1.x
mad r1.w, r1.y, r1.y, -r4
mad r5.x, -r5, r5, r1
mad r5.y, r1, r1, -r5.x
rsq r4.w, r1.w
rcp r4.w, r4.w
add r5.x, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r5.x, -r4.w, r1.w, r5
rsq r5.z, r5.y
cmp_pp r4.w, r5.y, c28, c28.z
rcp r5.z, r5.z
dp4 r1.z, r2, c24
dp4 r6.w, r2, c25
add r5.z, -r1.y, r5
cmp r5.y, r5, r3.w, c29.z
cmp r5.y, -r4.w, r5, r5.z
mov r1.w, c7.x
add r4.w, c13, r1
mad r4.w, -r4, r4, r1.x
mad r5.z, r1.y, r1.y, -r4.w
rsq r4.w, r5.z
rcp r5.w, r4.w
add r6.z, -r1.y, r5.w
cmp_pp r5.w, r5.z, c28, c28.z
cmp r5.z, r5, r3.w, c29
mov r1.w, c7.x
add r1.w, c13.z, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
cmp r5.w, -r5, r5.z, r6.z
rcp r4.w, r4.w
add r5.z, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r5.z, -r4.w, r1.w, r5
dp4 r1.w, r5, c20
add r6.z, r1.w, -r1
dp4 r4.w, r5, c19
cmp r11.w, -r4, c28, c28.z
mad r1.z, r11.w, r6, r1
dp4 r6.z, r5, c21
add r6.z, r6, -r6.w
mov r1.w, c7.x
add r1.w, c18.x, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
mad r6.w, r11, r6.z, r6
rcp r4.w, r4.w
add r6.z, -r1.y, -r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.y
cmp r1.w, -r4, r1, r6.z
cmp r3.w, r1, r1, c29.y
mad r1.x, -c8, c8, r1
mad r1.w, r1.y, r1.y, -r1.x
texldl r1.x, v0, s0
mul r4.w, r1.x, r0
mad r6.z, -r4.w, c9.x, r3.w
rsq r3.w, r1.w
mov r0.w, c4
mad r0.w, c29.x, -r0, r1.x
rcp r3.w, r3.w
mul r1.x, r4.w, c9
cmp r0.w, r0, c28, c28.z
mad r4.w, r0, r6.z, r1.x
add r0.w, -r1.y, -r3
add r1.y, -r1, r3.w
max r1.x, r0.w, c28.z
cmp_pp r0.w, r1, c28, c28.z
cmp r6.xy, r1.w, r6, c28.z
max r1.y, r1, c28.z
cmp r1.xy, -r0.w, r6, r1
min r3.w, r1.y, r4
min r1.y, r3.w, r6.w
max r6.w, r1.x, c28.z
min r0.w, r3, r1.z
max r7.w, r6, r0
max r8.w, r7, r1.y
dp4 r1.x, r2, c26
dp4 r0.w, r5, c22
add r0.w, r0, -r1.x
dp4 r1.y, r5, c23
dp4 r1.z, r2, c27
mad r0.w, r11, r0, r1.x
min r0.w, r3, r0
max r9.w, r8, r0
add r1.y, r1, -r1.z
mad r1.x, r11.w, r1.y, r1.z
min r1.x, r3.w, r1
max r4.w, r9, r1.x
add r8.x, r4.w, -r9.w
mov r0.w, c16.x
mov r1.xyz, c15
mad r5.xyz, r0, r6.w, r4
mul r1.w, c30, r0
dp3 r0.w, r5, r5
mul r1.xyz, c29.w, r1
add r9.xyz, r1, r1.w
abs r2.x, r8
mul r6.xyz, -r9, r2.x
pow r2, c31.x, r6.x
mov r6.x, r2
rcp r8.z, r9.z
rcp r8.y, r9.y
pow r2, c31.x, r6.y
rsq r0.w, r0.w
rcp r2.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r5.xyz, c12
rcp r2.z, r0.w
dp3 r0.w, c6, r5
add r2.x, r2, -c7
add r0.w, -r0, c28
mul r5.y, r2.x, r2.z
mul r5.x, r0.w, c31.y
mov r5.z, c28
texldl r2.zw, r5.xyzz, s1
mul r0.w, r2, c16.x
pow r5, c31.x, r6.z
mad r7.xyz, r2.z, -c15, -r0.w
mov r6.y, r2
pow r2, c31.x, r7.x
mov r6.z, r5
pow r5, c31.x, r7.y
mov r7.x, r2
pow r2, c31.x, r7.z
mov r7.z, r2
mov r7.y, r5
mul r5.xyz, r7, c11
mul r7.xyz, r0.zxyw, c12.yzxw
mad r7.xyz, r0.yzxw, c12.zxyw, -r7
mul r2.xyz, r4.zxyw, c12.yzxw
mad r2.xyz, r4.yzxw, c12.zxyw, -r2
dp3 r0.w, r2, r2
dp3 r5.w, r7, r7
mad r0.w, -c7.x, c7.x, r0
dp3 r2.w, r2, r7
mul r0.w, r5, r0
mad r2.x, r2.w, r2.w, -r0.w
rsq r2.y, r2.x
texldl r0.w, c31.yyzz, s2
mul r11.xyz, r5, r0.w
rcp r5.y, r2.y
add r2.y, -r2.w, -r5
rcp r5.z, r5.w
dp3 r0.w, r4, c12
mul r12.xyz, r9, r11
cmp r0.w, -r0, c28, c28.z
mul r2.y, r2, r5.z
add r2.w, -r2, r5.y
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r2.x
cmp r5.x, -r0.w, c29.y, r2.y
mad r2.xyz, r0, r5.x, r3
add r2.xyz, r2, -c5
dp3 r2.x, r2, c12
mul r2.y, r5.z, r2.w
cmp r5.y, -r0.w, c29.z, r2
rcp r2.y, r8.x
mul r4.xyz, r12, r6
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, r2.x
cmp r16.xy, -r0.w, r5, c29.yzzw
dp3 r2.x, r0, c12
add r0.w, -r16.x, r4
add r2.z, r16.y, -r9.w
mul r0.x, r2, c17
mul r0.x, r0, c28
rcp r8.x, r9.x
add r2.w, r3, -r4
mov r5.yzw, c28.w
mul_sat r0.w, r0, r2.y
mul_sat r0.y, r2, r2.z
mad r2.z, -r0.w, r0.y, c28.w
mad r0.x, c17, c17, r0
mad r3.xyz, r9, r11, -r4
abs r0.y, r2.w
mul r4.xyz, -r9, r0.y
add r2.y, r0.x, c28.w
pow r0, r2.y, c30.y
mad r0.z, r2.x, r2.x, c28.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c28.w, r0.y
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c30
mul r2.xy, r0, c30.z
pow r0, c31.x, r4.x
mul r0.y, r2, r1.w
mad r1.xyz, r1, r2.x, r0.y
mul r10.xyz, r1, r8
pow r1, c31.x, r4.z
mov r7.x, r0
pow r0, c31.x, r4.y
add r10.w, r9, -r8
abs r0.w, r10
mul r15.xyz, -r9, r0.w
mov r7.z, r1
mov r7.y, r0
mul r2.xyz, r10, r2.z
mul r1.xyz, r8, r2
mul r0.xyz, r7, r12
mul r14.xyz, r1, r3
mad r1.xyz, r9, r11, -r0
add r0.z, r16.y, -r4.w
rcp r0.y, r2.w
add r0.x, r3.w, -r16
mov r4, c23
add r4, -c27, r4
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c28.w
mul r0.xyz, r0.x, r10
mul r0.xyz, r0, r8
mul r13.xyz, r0, r1
mov r1, c21
add r1, -c25, r1
mad r2, r11.w, r1, c25
mov r0, c20
add r0, -c24, r0
mad r3, r11.w, r0, c24
texldl r0.w, v0, s3
mov r5.x, r0.w
dp4 r0.x, r3, r5
dp4 r3.x, r3, r3
mad r4, r11.w, r4, c27
mov r1, c22
add r1, -c26, r1
mad r1, r11.w, r1, c26
dp4 r0.y, r2, r5
dp4 r3.y, r2, r2
pow r2, c31.x, r15.y
dp4 r0.w, r4, r5
dp4 r0.z, r1, r5
dp4 r3.z, r1, r1
add r0, r0, c28.y
dp4 r3.w, r4, r4
mad r1, r3, r0, c28.w
pow r0, c31.x, r15.x
mad r4.xyz, r13, r1.w, r14
mov r3.x, r0
mov r3.y, r2
rcp r0.z, r10.w
add r0.w, r16.y, -r8
add r0.y, -r16.x, r9.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c28
pow r0, c31.x, r15.z
mov r3.z, r0
mul r2.xyz, r12, r3
mul r0.xyz, r10, r1.w
mad r2.xyz, r9, r11, -r2
mul r0.xyz, r8, r0
mul r0.xyz, r0, r2
mad r5.xyz, r4, r1.z, r0
add r0.w, r8, -r7
abs r0.y, r0.w
mul r4.xyz, -r9, r0.y
rcp r1.z, r0.w
add r0.x, -r16, r8.w
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r4.x
add r2.x, r16.y, -r7.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r4.z
mad r1.z, -r1.w, r0.y, c28.w
mov r4.x, r0
pow r0, c31.x, r4.y
mov r4.y, r0
mov r4.z, r2
mul r0.xyz, r10, r1.z
mul r2.xyz, r12, r4
mul r0.xyz, r8, r0
mad r2.xyz, r9, r11, -r2
mul r13.xyz, r0, r2
add r0.y, r7.w, -r6.w
rcp r1.z, r0.y
add r0.x, -r16, r7.w
abs r0.y, r0
mul r14.xyz, -r9, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r14.x
add r2.x, r16.y, -r6.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r14.y
mad r1.z, -r1.w, r0.y, c28.w
mov r14.x, r0
pow r0, c31.x, r14.z
mov r14.y, r2
mov r14.z, r0
mul r2.xyz, r10, r1.z
mul r0.xyz, r12, r14
mul r2.xyz, r8, r2
mad r0.xyz, r9, r11, -r0
mul r0.xyz, r2, r0
mad r2.xyz, r5, r1.y, r13
mad r0.xyz, r2, r1.x, r0
mul r1.xyz, r0.y, c34
mad r1.xyz, r0.x, c33, r1
mad r0.xyz, r0.z, c32, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
mul r1.xyz, r4, r14
mul r2.xyz, r3, r1
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c31.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c31.w
add r0.z, r0.x, c32.w
cmp r0.z, r0, c28.w, c28
mul_pp r1.x, r0.z, c33.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c30.w
mul r2.xyz, r6, r2
mul r2.xyz, r7, r2
mul r3.xyz, r2.y, c34
frc r1.x, r0
mad r3.xyz, r2.x, c33, r3
add r2.x, r0, -r1
mad r1.xyz, r2.z, c32, r3
add r2.z, r1.x, r1.y
add_pp r0.x, r2, c34.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c28, c28.w
add r1.z, r1, r2
rcp r0.z, r1.z
mul r2.zw, r1.xyxy, r0.z
mul r1.x, r2.z, c31.w
frc r1.z, r1.x
add r1.z, r1.x, -r1
mul r0.w, r0, c35.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r1.z, r1, c31.w
add r1.x, r1.z, c32.w
mul_pp r0.z, r2.x, c35.x
mul_pp r0.x, r0, r2.y
add r0.z, r1.w, -r0
min r0.w, r0, c35
mad r0.z, r0, c35.y, r0.w
cmp r1.x, r1, c28.w, c28.z
mad r0.z, r0, c36.x, c36.y
mul_pp r0.w, r1.x, c33
add r0.w, r1.z, -r0
mul_pp oC0.y, r0.x, r0.z
mul r0.x, r0.w, c30.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul_pp r0.z, r0.x, c35.x
mul r1.z, r2.w, c35
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0.w, -r0
min r1.z, r1, c35.w
mad r0.z, r0, c35.y, r1
add_pp r0.x, r0, c34.w
mad r0.w, r0.z, c36.x, c36.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c28, c28.w
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[36] = { program.local[0..27],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.1, 0.75 },
		{ 1, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625 } };
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
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R2.x, c[29].y;
MOVR  R4.w, c[29].y;
MOVR  R7.w, c[29].y;
MOVR  R17.zw, c[30].xyxw;
MOVR  R8.x, c[0].w;
MOVR  R8.z, c[2].w;
MOVR  R8.y, c[1].w;
MULR  R7.xyz, R8, c[9].x;
ADDR  R4.xyz, R7, -c[5];
DP3R  R6.x, R4, R4;
MULR  R1.zw, fragment.texcoord[0].xyxy, c[4].xyxy;
MOVR  R0.xy, c[4];
MADR  R0.xy, R1.zwzw, c[28].x, -R0;
MOVR  R0.z, c[28].y;
DP3R  R0.w, R0, R0;
RSQR  R3.w, R0.w;
MULR  R0.xyz, R3.w, R0;
MOVR  R0.w, c[28].z;
DP4R  R3.z, R0, c[2];
DP4R  R3.y, R0, c[1];
DP4R  R3.x, R0, c[0];
DP3R  R8.w, R3, R4;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
MULR  R9.x, R8.w, R8.w;
SLTR  R5, R9.x, R0;
MOVXC RC.x, R5;
MOVR  R2.x(EQ), R1;
ADDR  R1, R9.x, -R0;
SGERC HC, R9.x, R0.yzxw;
RSQR  R0.x, R1.z;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R2.x(NE.z), -R8.w, R1;
MOVXC RC.z, R5;
MOVR  R4.w(EQ.z), R2.y;
MOVXC RC.z, R5.w;
MOVR  R7.w(EQ.z), R2.y;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE.y), -R8, R0.x;
RSQR  R0.x, R1.w;
RCPR  R0.x, R0.x;
ADDR  R7.w(NE), -R8, R0.x;
RSQR  R0.x, R1.y;
MOVR  R2.y, c[29];
MOVXC RC.y, R5;
MOVR  R2.y(EQ), R2.z;
RCPR  R0.x, R0.x;
ADDR  R2.y(NE.x), -R8.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
ADDR  R5, R9.x, -R0;
RSQR  R1.y, R5.x;
SLTR  R6, R9.x, R0;
MOVR  R5.x, c[18];
MOVR  R1.x, c[29];
MOVXC RC.x, R6;
MOVR  R1.x(EQ), R2.z;
SGERC HC, R9.x, R0.yzxw;
RCPR  R1.y, R1.y;
ADDR  R1.x(NE.z), -R8.w, -R1.y;
RSQR  R0.x, R5.z;
MOVR  R1.y, c[29].x;
MOVR  R0.w, c[29].x;
MOVXC RC.z, R6;
MOVR  R0.w(EQ.z), R2.z;
RCPR  R0.x, R0.x;
ADDR  R0.w(NE.y), -R8, -R0.x;
RSQR  R0.x, R5.w;
MOVXC RC.y, R6;
MULR  R6.xyz, R3.zxyw, c[12].yzxw;
MADR  R6.xyz, R3.yzxw, c[12].zxyw, -R6;
MOVR  R1.y(EQ), R2.z;
MOVR  R5.w, c[29].x;
MOVR  R1.z, c[29].x;
MOVXC RC.z, R6.w;
MOVR  R1.z(EQ), R2;
RCPR  R0.x, R0.x;
ADDR  R1.z(NE.w), -R8.w, -R0.x;
RSQR  R0.x, R5.y;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R8.w, -R0.x;
MOVR  R0.xyz, c[5];
MADR  R0.xyz, R8, c[9].x, -R0;
DP3R  R1.w, R0, R3;
DP3R  R8.x, R0, R0;
ADDR  R5.x, R5, c[7];
MULR  R6.w, R1, R1;
MADR  R5.x, -R5, R5, R8;
SLTRC HC.x, R6.w, R5;
MOVR  R5.w(EQ.x), R2.z;
ADDR  R5.y, R6.w, -R5.x;
RSQR  R5.y, R5.y;
SGERC HC.x, R6.w, R5;
RCPR  R5.y, R5.y;
ADDR  R5.w(NE.x), -R1, -R5.y;
MOVXC RC.x, R5.w;
MULR  R5.xyz, R0.zxyw, c[12].yzxw;
MADR  R5.xyz, R0.yzxw, c[12].zxyw, -R5;
DP3R  R0.x, R0, c[12];
SLER  H0.x, R0, c[28].z;
DP3R  R8.y, R5, R5;
DP3R  R5.x, R5, R6;
DP3R  R5.z, R6, R6;
MADR  R5.y, -c[7].x, c[7].x, R8;
MULR  R6.y, R5.z, R5;
MULR  R6.x, R5, R5;
ADDR  R5.y, R6.x, -R6;
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
MOVR  R5.w(LT.x), c[29].x;
ADDR  R0.y, -R5.x, R5;
SGTR  H0.y, R6.x, R6;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R5.z, R5.z;
MOVR  R0.z, c[29].y;
MULR  R0.z(NE.x), R5, R0.y;
ADDR  R0.y, -R5.x, -R5;
MOVR  R0.x, c[29];
MULR  R0.x(NE), R0.y, R5.z;
MOVR  R0.y, R0.z;
MOVR  R17.xy, R0;
MADR  R0.xyz, R3, R0.x, R7;
ADDR  R0.xyz, R0, -c[5];
DP3R  R0.x, R0, c[12];
SGTR  H0.y, R0.x, c[28].z;
MADR  R0.z, -c[8].x, c[8].x, R8.x;
MULXC HC.x, H0, H0.y;
MOVR  R17.xy(NE.x), c[29];
ADDR  R0.x, R6.w, -R0.z;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, -R1.w, -R0.x;
ADDR  R1.w, -R1, R0.x;
MAXR  R0.x, R0.y, c[28].z;
MAXR  R0.y, R1.w, c[28].z;
MOVR  R1.w, R1.z;
MOVR  R1.z, R0.w;
RCPR  R0.w, R3.w;
MOVR  R3.w, c[28];
MOVR  R5.xy, c[28].z;
SLTRC HC.x, R6.w, R0.z;
MOVR  R5.xy(EQ.x), R2.zwzw;
SGERC HC.x, R6.w, R0.z;
MOVR  R5.xy(NE.x), R0;
MOVR  R2.w, R7;
MOVR  R2.z, R4.w;
DP4R  R0.x, R1, c[24];
DP4R  R0.y, R2, c[20];
ADDR  R0.z, R0.y, -R0.x;
DP4R  R0.y, R2, c[19];
SGER  H0.y, c[28].z, R0;
MADR  R0.y, H0, R0.z, R0.x;
DP4R  R0.z, R1, c[25];
DP4R  R0.x, R2, c[21];
ADDR  R0.x, R0, -R0.z;
MADR  R0.z, H0.y, R0.x, R0;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
MULR  R0.w, R0.x, R0;
MADR  R4.w, -R0, c[9].x, R5;
MULR  R3.w, R3, c[4];
MAXR  R7.w, R5.x, c[28].z;
SGER  H0.x, R0, R3.w;
MULR  R0.w, R0, c[9].x;
MADR  R0.x, H0, R4.w, R0.w;
MINR  R3.w, R5.y, R0.x;
MINR  R0.y, R3.w, R0;
MAXR  R8.w, R7, R0.y;
MINR  R0.x, R3.w, R0.z;
MAXR  R9.w, R8, R0.x;
DP4R  R0.y, R1, c[26];
DP4R  R0.x, R2, c[22];
ADDR  R0.x, R0, -R0.y;
MADR  R0.x, H0.y, R0, R0.y;
MINR  R0.x, R3.w, R0;
MAXR  R4.w, R9, R0.x;
ADDR  R5.z, R4.w, -R9.w;
ADDR  R5.xy, R17.yxzw, -R4.w;
RCPR  R0.x, R5.z;
ADDR  R6.zw, R17.xyyx, -R9.w;
MULR_SAT R0.y, R0.x, R6.z;
MULR_SAT R0.x, -R5.y, R0;
MULR  R0.w, R0.x, R0.y;
DP3R  R0.x, R3, c[12];
MULR  R0.y, R0.x, c[17].x;
MULR  R0.y, R0, c[28].x;
MADR  R0.y, c[17].x, c[17].x, R0;
ADDR  R0.y, R0, c[30].x;
POWR  R0.z, R0.y, c[30].y;
MULR  R0.x, R0, R0;
ADDR  R0.y, R17.z, c[17].x;
MADR  R3.xyz, R3, R7.w, R4;
MULR  R5.w, R17, c[16].x;
RCPR  R0.z, R0.z;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R0.z;
MADR  R0.x, R0, c[29].w, c[29].w;
MULR  R6.xy, R0, c[30].z;
MOVR  R0.x, c[29].z;
MULR  R0.xyz, R0.x, c[15];
ADDR  R10.xyz, R0, R5.w;
MULR  R5.y, R6, R5.w;
MADR  R0.xyz, R0, R6.x, R5.y;
RCPR  R9.x, R10.x;
RCPR  R9.z, R10.z;
RCPR  R9.y, R10.y;
MULR  R11.xyz, R0, R9;
MADR  R0.xyz, R11, -R0.w, R11;
DP3R  R0.w, R3, R3;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.x, R0.w, -c[7];
MOVR  R0.w, c[7].x;
ADDR  R0.w, -R0, c[8].x;
RCPR  R0.w, R0.w;
MULR  R4.y, R3.x, R0.w;
MOVR  R3.xyz, c[6];
DP3R  R0.w, R3, c[12];
MADR  R4.x, -R0.w, c[31].y, c[31].y;
TEX   R12.zw, R4, texture[1], 2D;
MULR  R4.xyz, -R10, |R5.z|;
MULR  R0.w, R12, c[16].x;
MADR  R3.xyz, R12.z, -c[15], -R0.w;
MULR  R0.xyz, R9, R0;
RCPR  R5.y, |R5.z|;
POWR  R6.x, c[31].x, R4.x;
POWR  R6.y, c[31].x, R4.y;
POWR  R6.z, c[31].x, R4.z;
TEX   R0.w, c[31].y, texture[2], 2D;
POWR  R3.x, c[31].x, R3.x;
POWR  R3.z, c[31].x, R3.z;
POWR  R3.y, c[31].x, R3.y;
MULR  R3.xyz, R3, c[11];
MULR  R12.xyz, R3, R0.w;
ADDR  R13.xyz, R12, -R12;
MULR  R3.xyz, R13, R5.y;
MADR  R3.xyz, R10, R12, R3;
MADR  R3.xyz, -R6, R3, R3;
MULR  R16.xyz, R0, R3;
DP4R  R0.x, R1, c[27];
DP4R  R0.y, R2, c[23];
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R3.w, R0;
MAXR  R0.w, R4, R0.x;
ADDR  R1.w, R0, -R4;
MULR  R2.xyz, -R10, |R1.w|;
ADDR  R3.xy, R17.yxzw, -R0.w;
RCPR  R0.x, R1.w;
RCPR  R1.x, |R1.w|;
MULR_SAT R0.y, R0.x, R5.x;
MULR_SAT R0.x, -R3.y, R0;
TEX   R1.w, fragment.texcoord[0], texture[4], 2D;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R11, -R0.x, R11;
MULR  R1.xyz, R13, R1.x;
MULR  R0.xyz, R9, R0;
MOVR  R4.y, R1.w;
ADDR  R0.w, R3, -R0;
MOVR  R4.zw, c[30].x;
POWR  R7.x, c[31].x, R2.x;
POWR  R7.y, c[31].x, R2.y;
POWR  R7.z, c[31].x, R2.z;
MULR  R2.xyz, |R0.w|, -R10;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R7, R1, R1;
MULR  R15.xyz, R0, R1;
RCPR  R0.x, R0.w;
RCPR  R1.x, |R0.w|;
MULR  R1.xyz, R13, R1.x;
MULR_SAT R0.y, R0.x, R3.x;
ADDR  R0.z, R3.w, -R17.x;
MULR_SAT R0.x, R0.z, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R11, R11;
POWR  R8.x, c[31].x, R2.x;
POWR  R8.y, c[31].x, R2.y;
POWR  R8.z, c[31].x, R2.z;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R8, R1, R1;
MULR  R0.xyz, R0, R9;
MULR  R14.xyz, R0, R1;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R3, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R2, H0.y, R0, c[24];
TEX   R0.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R4.x, R0.w;
DP4R  R5.x, R4, R2;
DP4R  R2.x, R2, R2;
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R0, H0.y, R0, c[26];
MOVR  R1, c[27];
ADDR  R1, -R1, c[23];
MADR  R1, H0.y, R1, c[27];
DP4R  R2.w, R1, R1;
DP4R  R5.w, R4, R1;
DP4R  R5.y, R4, R3;
DP4R  R5.z, R4, R0;
ADDR  R1.w, R9, -R8;
DP4R  R2.y, R3, R3;
DP4R  R2.z, R0, R0;
MADR  R0, R5, R2, -R2;
ADDR  R0, R0, c[30].x;
RCPR  R2.x, R1.w;
MADR  R1.xyz, R14, R0.w, R15;
MADR  R1.xyz, R1, R0.z, R16;
ADDR  R0.zw, R17.xyyx, -R8.w;
MULR_SAT R2.y, -R6.w, R2.x;
MULR_SAT R0.z, R2.x, R0;
MULR  R0.z, R2.y, R0;
MULR  R2.xyz, -R10, |R1.w|;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R1.w|;
MULR  R4.xyz, R13, R0.z;
POWR  R2.x, c[31].x, R2.x;
POWR  R2.y, c[31].x, R2.y;
POWR  R2.z, c[31].x, R2.z;
MADR  R4.xyz, R10, R12, R4;
MADR  R4.xyz, -R2, R4, R4;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R4;
MADR  R1.xyz, R1, R0.y, R3;
ADDR  R0.y, R8.w, -R7.w;
MULR  R4.xyz, -R10, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R17.y, -R7;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R0.y|;
MULR  R5.xyz, R13, R0.z;
POWR  R4.x, c[31].x, R4.x;
POWR  R4.y, c[31].x, R4.y;
POWR  R4.z, c[31].x, R4.z;
MADR  R5.xyz, R10, R12, R5;
MADR  R5.xyz, -R4, R5, R5;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R5;
MADR  R0.xyz, R1, R0.x, R3;
MULR  R1.xyz, R0.y, c[34];
MADR  R1.xyz, R0.x, c[33], R1;
MADR  R0.xyz, R0.z, c[32], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R1.xyz, R2, R4;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R6, R1;
MULR  R1.xyz, R7, R1;
MULR  R1.xyz, R8, R1;
MULR  R2.xyz, R1.y, c[34];
MADR  R2.xyz, R1.x, c[33], R2;
MADR  R1.xyz, R1.z, c[32], R2;
MADH  H0.x, H0, c[28], H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
ADDR  R0.x, R1, R1.y;
ADDR  R0.x, R1.z, R0;
RCPR  R0.x, R0.x;
MULR  R0.zw, R1.xyxy, R0.x;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MULH  oCol.y, H0.x, H0.z;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
MADH  H0.x, H0, c[28], H0.y;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
def c28, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c29, 0.99500000, 1000000.00000000, -1000000.00000000, 0.10000000
def c30, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c31, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c32, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c33, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c34, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c35, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c36, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c28.x, c28.y
mul r0.xy, r0, c4
mov r0.z, c28.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c28.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.z, c7.x
mov r1.w, c7.x
add r1.w, c14.y, r1
rcp r0.w, r0.w
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r3.xyz, r3, c9.x
add r4.xyz, r3, -c5
dp3 r1.x, r4, r4
add r1.z, c14.x, r1
dp3 r1.y, r4, r0
mad r4.w, -r1, r1, r1.x
mad r5.x, r1.y, r1.y, -r4.w
mad r1.z, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2.x, c29.y
cmp r2.x, -r1.w, r1.z, r4.w
rsq r5.y, r5.x
rcp r5.y, r5.y
add r4.w, -r1.y, -r5.y
cmp_pp r1.w, r5.x, c28, c28.z
cmp r2.y, r5.x, r2, c29
cmp r2.y, -r1.w, r2, r4.w
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r4.w, c14, r1.z
mad r1.w, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1.w
mad r4.w, -r4, r4, r1.x
mad r5.x, r1.y, r1.y, -r4.w
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2, c29.y
cmp r2.z, -r1.w, r1, r4.w
rsq r5.y, r5.x
rcp r5.y, r5.y
add r4.w, -r1.y, -r5.y
cmp r1.w, r5.x, r2, c29.y
cmp_pp r1.z, r5.x, c28.w, c28
cmp r2.w, -r1.z, r1, r4
mov r1.w, c7.x
add r4.w, c13.x, r1
mov r1.w, c7.x
add r5.x, c13.y, r1.w
mad r4.w, -r4, r4, r1.x
mad r1.w, r1.y, r1.y, -r4
mad r5.x, -r5, r5, r1
mad r5.y, r1, r1, -r5.x
rsq r4.w, r1.w
rcp r4.w, r4.w
add r5.x, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r5.x, -r4.w, r1.w, r5
rsq r5.z, r5.y
cmp_pp r4.w, r5.y, c28, c28.z
rcp r5.z, r5.z
dp4 r1.z, r2, c24
dp4 r6.w, r2, c25
add r5.z, -r1.y, r5
cmp r5.y, r5, r3.w, c29.z
cmp r5.y, -r4.w, r5, r5.z
mov r1.w, c7.x
add r4.w, c13, r1
mad r4.w, -r4, r4, r1.x
mad r5.z, r1.y, r1.y, -r4.w
rsq r4.w, r5.z
rcp r5.w, r4.w
add r6.z, -r1.y, r5.w
cmp_pp r5.w, r5.z, c28, c28.z
cmp r5.z, r5, r3.w, c29
mov r1.w, c7.x
add r1.w, c13.z, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
cmp r5.w, -r5, r5.z, r6.z
rcp r4.w, r4.w
add r5.z, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r5.z, -r4.w, r1.w, r5
dp4 r1.w, r5, c20
add r6.z, r1.w, -r1
dp4 r4.w, r5, c19
cmp r11.w, -r4, c28, c28.z
mad r1.z, r11.w, r6, r1
dp4 r6.z, r5, c21
add r6.z, r6, -r6.w
mov r1.w, c7.x
add r1.w, c18.x, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
mad r6.w, r11, r6.z, r6
rcp r4.w, r4.w
add r6.z, -r1.y, -r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.y
cmp r1.w, -r4, r1, r6.z
cmp r3.w, r1, r1, c29.y
mad r1.x, -c8, c8, r1
mad r1.w, r1.y, r1.y, -r1.x
texldl r1.x, v0, s0
mul r4.w, r1.x, r0
mad r6.z, -r4.w, c9.x, r3.w
rsq r3.w, r1.w
mov r0.w, c4
mad r0.w, c29.x, -r0, r1.x
rcp r3.w, r3.w
mul r1.x, r4.w, c9
cmp r0.w, r0, c28, c28.z
mad r4.w, r0, r6.z, r1.x
add r0.w, -r1.y, -r3
add r1.y, -r1, r3.w
max r1.x, r0.w, c28.z
cmp_pp r0.w, r1, c28, c28.z
cmp r6.xy, r1.w, r6, c28.z
max r1.y, r1, c28.z
cmp r1.xy, -r0.w, r6, r1
min r3.w, r1.y, r4
min r1.y, r3.w, r6.w
max r6.w, r1.x, c28.z
min r0.w, r3, r1.z
max r7.w, r6, r0
max r8.w, r7, r1.y
dp4 r1.x, r2, c26
dp4 r0.w, r5, c22
add r0.w, r0, -r1.x
dp4 r1.y, r5, c23
dp4 r1.z, r2, c27
mad r0.w, r11, r0, r1.x
min r0.w, r3, r0
max r9.w, r8, r0
add r1.y, r1, -r1.z
mad r1.x, r11.w, r1.y, r1.z
min r1.x, r3.w, r1
max r4.w, r9, r1.x
add r8.x, r4.w, -r9.w
mov r0.w, c16.x
mov r1.xyz, c15
mad r5.xyz, r0, r6.w, r4
mul r1.w, c30, r0
dp3 r0.w, r5, r5
mul r1.xyz, c29.w, r1
add r9.xyz, r1, r1.w
abs r2.x, r8
mul r6.xyz, -r9, r2.x
pow r2, c31.x, r6.x
mov r6.x, r2
rcp r8.z, r9.z
rcp r8.y, r9.y
pow r2, c31.x, r6.y
rsq r0.w, r0.w
rcp r2.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r5.xyz, c12
rcp r2.z, r0.w
dp3 r0.w, c6, r5
add r2.x, r2, -c7
add r0.w, -r0, c28
mul r5.y, r2.x, r2.z
mul r5.x, r0.w, c31.y
mov r5.z, c28
texldl r2.zw, r5.xyzz, s1
mul r0.w, r2, c16.x
pow r5, c31.x, r6.z
mad r7.xyz, r2.z, -c15, -r0.w
mov r6.y, r2
pow r2, c31.x, r7.x
mov r6.z, r5
pow r5, c31.x, r7.y
mov r7.x, r2
pow r2, c31.x, r7.z
mov r7.z, r2
mov r7.y, r5
mul r5.xyz, r7, c11
mul r7.xyz, r0.zxyw, c12.yzxw
mad r7.xyz, r0.yzxw, c12.zxyw, -r7
mul r2.xyz, r4.zxyw, c12.yzxw
mad r2.xyz, r4.yzxw, c12.zxyw, -r2
dp3 r0.w, r2, r2
dp3 r5.w, r7, r7
mad r0.w, -c7.x, c7.x, r0
dp3 r2.w, r2, r7
mul r0.w, r5, r0
mad r2.x, r2.w, r2.w, -r0.w
rsq r2.y, r2.x
texldl r0.w, c31.yyzz, s2
mul r11.xyz, r5, r0.w
rcp r5.y, r2.y
add r2.y, -r2.w, -r5
rcp r5.z, r5.w
dp3 r0.w, r4, c12
mul r12.xyz, r9, r11
cmp r0.w, -r0, c28, c28.z
mul r2.y, r2, r5.z
add r2.w, -r2, r5.y
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r2.x
cmp r5.x, -r0.w, c29.y, r2.y
mad r2.xyz, r0, r5.x, r3
add r2.xyz, r2, -c5
dp3 r2.x, r2, c12
mul r2.y, r5.z, r2.w
cmp r5.y, -r0.w, c29.z, r2
rcp r2.y, r8.x
mul r4.xyz, r12, r6
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, r2.x
cmp r16.xy, -r0.w, r5, c29.yzzw
dp3 r2.x, r0, c12
add r0.w, -r16.x, r4
add r2.z, r16.y, -r9.w
mul r0.x, r2, c17
mul r0.x, r0, c28
rcp r8.x, r9.x
add r2.w, r3, -r4
mov r5.zw, c28.w
mul_sat r0.w, r0, r2.y
mul_sat r0.y, r2, r2.z
mad r2.z, -r0.w, r0.y, c28.w
mad r0.x, c17, c17, r0
mad r3.xyz, r9, r11, -r4
abs r0.y, r2.w
mul r4.xyz, -r9, r0.y
add r2.y, r0.x, c28.w
pow r0, r2.y, c30.y
mad r0.z, r2.x, r2.x, c28.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c28.w, r0.y
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c30
mul r2.xy, r0, c30.z
pow r0, c31.x, r4.x
mul r0.y, r2, r1.w
mad r1.xyz, r1, r2.x, r0.y
mul r10.xyz, r1, r8
pow r1, c31.x, r4.z
mov r7.x, r0
pow r0, c31.x, r4.y
add r10.w, r9, -r8
abs r0.w, r10
mul r15.xyz, -r9, r0.w
mov r7.z, r1
mov r7.y, r0
mul r2.xyz, r10, r2.z
mul r1.xyz, r8, r2
mul r0.xyz, r7, r12
mul r14.xyz, r1, r3
mad r1.xyz, r9, r11, -r0
add r0.z, r16.y, -r4.w
rcp r0.y, r2.w
add r0.x, r3.w, -r16
mov r4, c23
add r4, -c27, r4
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c28.w
mul r0.xyz, r0.x, r10
mul r0.xyz, r0, r8
mul r13.xyz, r0, r1
mov r1, c21
add r1, -c25, r1
mad r2, r11.w, r1, c25
texldl r1.w, v0, s4
mov r5.y, r1.w
mov r0, c20
add r0, -c24, r0
mad r3, r11.w, r0, c24
texldl r0.w, v0, s3
mov r5.x, r0.w
dp4 r0.x, r3, r5
dp4 r3.x, r3, r3
mad r4, r11.w, r4, c27
mov r1, c22
add r1, -c26, r1
mad r1, r11.w, r1, c26
dp4 r0.y, r2, r5
dp4 r3.y, r2, r2
pow r2, c31.x, r15.y
dp4 r0.w, r4, r5
dp4 r0.z, r1, r5
dp4 r3.z, r1, r1
add r0, r0, c28.y
dp4 r3.w, r4, r4
mad r1, r3, r0, c28.w
pow r0, c31.x, r15.x
mad r4.xyz, r13, r1.w, r14
mov r3.x, r0
mov r3.y, r2
rcp r0.z, r10.w
add r0.w, r16.y, -r8
add r0.y, -r16.x, r9.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c28
pow r0, c31.x, r15.z
mov r3.z, r0
mul r2.xyz, r12, r3
mul r0.xyz, r10, r1.w
mad r2.xyz, r9, r11, -r2
mul r0.xyz, r8, r0
mul r0.xyz, r0, r2
mad r5.xyz, r4, r1.z, r0
add r0.w, r8, -r7
abs r0.y, r0.w
mul r4.xyz, -r9, r0.y
rcp r1.z, r0.w
add r0.x, -r16, r8.w
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r4.x
add r2.x, r16.y, -r7.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r4.z
mad r1.z, -r1.w, r0.y, c28.w
mov r4.x, r0
pow r0, c31.x, r4.y
mov r4.y, r0
mov r4.z, r2
mul r0.xyz, r10, r1.z
mul r2.xyz, r12, r4
mul r0.xyz, r8, r0
mad r2.xyz, r9, r11, -r2
mul r13.xyz, r0, r2
add r0.y, r7.w, -r6.w
rcp r1.z, r0.y
add r0.x, -r16, r7.w
abs r0.y, r0
mul r14.xyz, -r9, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r14.x
add r2.x, r16.y, -r6.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r14.y
mad r1.z, -r1.w, r0.y, c28.w
mov r14.x, r0
pow r0, c31.x, r14.z
mov r14.y, r2
mov r14.z, r0
mul r2.xyz, r10, r1.z
mul r0.xyz, r12, r14
mul r2.xyz, r8, r2
mad r0.xyz, r9, r11, -r0
mul r0.xyz, r2, r0
mad r2.xyz, r5, r1.y, r13
mad r0.xyz, r2, r1.x, r0
mul r1.xyz, r0.y, c34
mad r1.xyz, r0.x, c33, r1
mad r0.xyz, r0.z, c32, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
mul r1.xyz, r4, r14
mul r2.xyz, r3, r1
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c31.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c31.w
add r0.z, r0.x, c32.w
cmp r0.z, r0, c28.w, c28
mul_pp r1.x, r0.z, c33.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c30.w
mul r2.xyz, r6, r2
mul r2.xyz, r7, r2
mul r3.xyz, r2.y, c34
frc r1.x, r0
mad r3.xyz, r2.x, c33, r3
add r2.x, r0, -r1
mad r1.xyz, r2.z, c32, r3
add r2.z, r1.x, r1.y
add_pp r0.x, r2, c34.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c28, c28.w
add r1.z, r1, r2
rcp r0.z, r1.z
mul r2.zw, r1.xyxy, r0.z
mul r1.x, r2.z, c31.w
frc r1.z, r1.x
add r1.z, r1.x, -r1
mul r0.w, r0, c35.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r1.z, r1, c31.w
add r1.x, r1.z, c32.w
mul_pp r0.z, r2.x, c35.x
mul_pp r0.x, r0, r2.y
add r0.z, r1.w, -r0
min r0.w, r0, c35
mad r0.z, r0, c35.y, r0.w
cmp r1.x, r1, c28.w, c28.z
mad r0.z, r0, c36.x, c36.y
mul_pp r0.w, r1.x, c33
add r0.w, r1.z, -r0
mul_pp oC0.y, r0.x, r0.z
mul r0.x, r0.w, c30.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul_pp r0.z, r0.x, c35.x
mul r1.z, r2.w, c35
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0.w, -r0
min r1.z, r1, c35.w
mad r0.z, r0, c35.y, r1
add_pp r0.x, r0, c34.w
mad r0.w, r0.z, c36.x, c36.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c28, c28.w
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[36] = { program.local[0..27],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.1, 0.75 },
		{ 1, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625 } };
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
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R1.x, c[29].y;
MOVR  R4.w, c[29].y;
MOVR  R7.w, c[29].y;
MOVR  R17.zw, c[30].xyxw;
MOVR  R8.x, c[0].w;
MOVR  R8.z, c[2].w;
MOVR  R8.y, c[1].w;
MULR  R7.xyz, R8, c[9].x;
ADDR  R4.xyz, R7, -c[5];
DP3R  R6.x, R4, R4;
MULR  R2.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R2, c[28].x, -R0;
MOVR  R0.z, c[28].y;
DP3R  R0.w, R0, R0;
RSQR  R3.w, R0.w;
MULR  R0.xyz, R3.w, R0;
MOVR  R0.w, c[28].z;
DP4R  R3.z, R0, c[2];
DP4R  R3.y, R0, c[1];
DP4R  R3.x, R0, c[0];
DP3R  R8.w, R3, R4;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
MULR  R9.x, R8.w, R8.w;
ADDR  R2, R9.x, -R0;
SLTR  R5, R9.x, R0;
MOVXC RC.x, R5;
MOVR  R1.x(EQ), R1.y;
SGERC HC, R9.x, R0.yzxw;
RSQR  R0.x, R2.z;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
ADDR  R1.x(NE.z), -R8.w, R2;
MOVXC RC.z, R5;
MOVR  R4.w(EQ.z), R1.y;
MOVXC RC.z, R5.w;
MOVR  R7.w(EQ.z), R1.y;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE.y), -R8, R0.x;
RSQR  R0.x, R2.w;
RCPR  R0.x, R0.x;
ADDR  R7.w(NE), -R8, R0.x;
RSQR  R0.x, R2.y;
MOVR  R1.y, c[29];
MOVXC RC.y, R5;
MOVR  R1.y(EQ), R1.z;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R8.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R2, -R0, R0, R6.x;
ADDR  R5, R9.x, -R2;
RSQR  R0.y, R5.x;
SLTR  R6, R9.x, R2;
MOVR  R5.x, c[18];
MOVR  R0.z, c[29].x;
MOVR  R0.w, c[29].x;
MOVR  R0.x, c[29];
MOVXC RC.x, R6;
MOVR  R0.x(EQ), R1.z;
SGERC HC, R9.x, R2.yzxw;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.z), -R8.w, -R0.y;
MOVXC RC.z, R6;
MOVR  R0.z(EQ), R1;
RSQR  R0.y, R5.z;
RCPR  R0.y, R0.y;
ADDR  R0.z(NE.y), -R8.w, -R0.y;
RSQR  R0.y, R5.w;
MOVXC RC.z, R6.w;
MOVXC RC.y, R6;
RSQR  R2.x, R5.y;
MULR  R6.xyz, R3.zxyw, c[12].yzxw;
MADR  R6.xyz, R3.yzxw, c[12].zxyw, -R6;
MOVR  R0.w(EQ.z), R1.z;
RCPR  R0.y, R0.y;
ADDR  R0.w(NE), -R8, -R0.y;
MOVR  R0.y, c[29].x;
MOVR  R0.y(EQ), R1.z;
RCPR  R2.x, R2.x;
ADDR  R0.y(NE.x), -R8.w, -R2.x;
MOVR  R2.xyz, c[5];
MADR  R2.xyz, R8, c[9].x, -R2;
DP3R  R6.w, R2, R3;
DP3R  R2.w, R2, R2;
ADDR  R5.x, R5, c[7];
MULR  R8.x, R6.w, R6.w;
MADR  R5.x, -R5, R5, R2.w;
ADDR  R5.y, R8.x, -R5.x;
RSQR  R5.y, R5.y;
MOVR  R5.w, c[29].x;
SLTRC HC.x, R8, R5;
MOVR  R5.w(EQ.x), R1.z;
SGERC HC.x, R8, R5;
RCPR  R5.y, R5.y;
ADDR  R5.w(NE.x), -R6, -R5.y;
MOVXC RC.x, R5.w;
MULR  R5.xyz, R2.zxyw, c[12].yzxw;
MADR  R5.xyz, R2.yzxw, c[12].zxyw, -R5;
DP3R  R2.x, R2, c[12];
SLER  H0.x, R2, c[28].z;
DP3R  R8.y, R5, R5;
DP3R  R5.x, R5, R6;
DP3R  R5.z, R6, R6;
MADR  R5.y, -c[7].x, c[7].x, R8;
MULR  R6.y, R5.z, R5;
MULR  R6.x, R5, R5;
ADDR  R5.y, R6.x, -R6;
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
ADDR  R2.y, -R5.x, R5;
MOVR  R5.w(LT.x), c[29].x;
SGTR  H0.y, R6.x, R6;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R5.z, R5.z;
MOVR  R2.z, c[29].y;
MULR  R2.z(NE.x), R5, R2.y;
ADDR  R2.y, -R5.x, -R5;
MOVR  R2.x, c[29];
MULR  R2.x(NE), R2.y, R5.z;
MOVR  R2.y, R2.z;
MOVR  R17.xy, R2;
MADR  R2.xyz, R3, R2.x, R7;
ADDR  R2.xyz, R2, -c[5];
DP3R  R2.x, R2, c[12];
SGTR  H0.y, R2.x, c[28].z;
MADR  R2.x, -c[8], c[8], R2.w;
MULXC HC.x, H0, H0.y;
MOVR  R17.xy(NE.x), c[29];
MOVR  R5.x, c[28].w;
MOVR  R2.zw, c[28].z;
SLTRC HC.x, R8, R2;
MOVR  R2.zw(EQ.x), R1;
ADDR  R1.z, R8.x, -R2.x;
SGERC HC.x, R8, R2;
RSQR  R1.z, R1.z;
RCPR  R1.z, R1.z;
DP4R  R2.x, R0, c[24];
ADDR  R1.w, -R6, -R1.z;
ADDR  R2.y, -R6.w, R1.z;
MAXR  R1.z, R1.w, c[28];
MAXR  R1.w, R2.y, c[28].z;
MOVR  R2.zw(NE.x), R1;
MOVR  R1.w, R7;
MOVR  R1.z, R4.w;
DP4R  R2.y, R1, c[20];
ADDR  R4.w, R2.y, -R2.x;
DP4R  R2.y, R1, c[19];
SGER  H0.y, c[28].z, R2;
MADR  R2.y, H0, R4.w, R2.x;
DP4R  R4.w, R0, c[25];
DP4R  R2.x, R1, c[21];
ADDR  R2.x, R2, -R4.w;
MADR  R4.w, H0.y, R2.x, R4;
MAXR  R7.w, R2.z, c[28].z;
TEX   R2.x, fragment.texcoord[0], texture[0], 2D;
MULR  R5.x, R5, c[4].w;
RCPR  R3.w, R3.w;
MULR  R3.w, R2.x, R3;
MADR  R5.y, -R3.w, c[9].x, R5.w;
SGER  H0.x, R2, R5;
MULR  R3.w, R3, c[9].x;
MADR  R2.x, H0, R5.y, R3.w;
MINR  R3.w, R2, R2.x;
MINR  R2.y, R3.w, R2;
MAXR  R8.w, R7, R2.y;
DP4R  R2.y, R0, c[26];
DP4R  R0.x, R0, c[27];
MINR  R2.x, R3.w, R4.w;
MAXR  R9.w, R8, R2.x;
DP4R  R2.x, R1, c[22];
DP4R  R0.y, R1, c[23];
ADDR  R0.y, R0, -R0.x;
ADDR  R2.x, R2, -R2.y;
MADR  R2.x, H0.y, R2, R2.y;
MINR  R2.x, R3.w, R2;
MAXR  R4.w, R9, R2.x;
ADDR  R5.z, R4.w, -R9.w;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R3.w, R0;
MAXR  R0.w, R4, R0.x;
ADDR  R1.w, R0, -R4;
ADDR  R5.xy, R17.yxzw, -R4.w;
RCPR  R0.x, R1.w;
MULR_SAT R0.y, R0.x, R5.x;
RCPR  R2.x, R5.z;
ADDR  R6.zw, R17.xyyx, -R9.w;
MULR_SAT R2.y, R2.x, R6.z;
MULR_SAT R2.x, -R5.y, R2;
MULR  R2.w, R2.x, R2.y;
DP3R  R2.x, R3, c[12];
MULR  R2.y, R2.x, c[17].x;
MULR  R2.y, R2, c[28].x;
MADR  R2.y, c[17].x, c[17].x, R2;
ADDR  R2.y, R2, c[30].x;
POWR  R2.z, R2.y, c[30].y;
MULR  R2.x, R2, R2;
ADDR  R2.y, R17.z, c[17].x;
MADR  R3.xyz, R3, R7.w, R4;
MULR  R5.w, R17, c[16].x;
RCPR  R2.z, R2.z;
MULR  R2.y, R2, R2;
MULR  R2.y, R2, R2.z;
MADR  R2.x, R2, c[29].w, c[29].w;
MULR  R6.xy, R2, c[30].z;
MOVR  R2.x, c[29].z;
MULR  R2.xyz, R2.x, c[15];
ADDR  R10.xyz, R2, R5.w;
MULR  R5.y, R6, R5.w;
MADR  R2.xyz, R2, R6.x, R5.y;
RCPR  R9.x, R10.x;
RCPR  R9.z, R10.z;
RCPR  R9.y, R10.y;
MULR  R11.xyz, R2, R9;
MADR  R2.xyz, R11, -R2.w, R11;
DP3R  R2.w, R3, R3;
RSQR  R2.w, R2.w;
RCPR  R2.w, R2.w;
ADDR  R3.x, R2.w, -c[7];
MOVR  R2.w, c[7].x;
ADDR  R2.w, -R2, c[8].x;
RCPR  R2.w, R2.w;
MULR  R4.y, R3.x, R2.w;
MOVR  R3.xyz, c[6];
DP3R  R2.w, R3, c[12];
MADR  R4.x, -R2.w, c[31].y, c[31].y;
TEX   R12.zw, R4, texture[1], 2D;
MULR  R4.xyz, -R10, |R5.z|;
MULR  R2.w, R12, c[16].x;
MADR  R3.xyz, R12.z, -c[15], -R2.w;
RCPR  R5.y, |R5.z|;
POWR  R6.x, c[31].x, R4.x;
POWR  R6.y, c[31].x, R4.y;
POWR  R6.z, c[31].x, R4.z;
MOVR  R4, c[27];
ADDR  R4, -R4, c[23];
MADR  R4, H0.y, R4, c[27];
TEX   R2.w, c[31].y, texture[2], 2D;
MULR  R2.xyz, R9, R2;
RCPR  R1.x, |R1.w|;
POWR  R3.x, c[31].x, R3.x;
POWR  R3.z, c[31].x, R3.z;
POWR  R3.y, c[31].x, R3.y;
MULR  R3.xyz, R3, c[11];
MULR  R12.xyz, R3, R2.w;
ADDR  R13.xyz, R12, -R12;
MULR  R3.xyz, R13, R5.y;
MADR  R3.xyz, R10, R12, R3;
MADR  R3.xyz, -R6, R3, R3;
MULR  R16.xyz, R2, R3;
MULR  R2.xyz, -R10, |R1.w|;
ADDR  R3.xy, R17.yxzw, -R0.w;
MULR_SAT R0.x, -R3.y, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R11, -R0.x, R11;
MULR  R1.xyz, R13, R1.x;
MULR  R0.xyz, R9, R0;
ADDR  R0.w, R3, -R0;
POWR  R7.x, c[31].x, R2.x;
POWR  R7.y, c[31].x, R2.y;
POWR  R7.z, c[31].x, R2.z;
MULR  R2.xyz, |R0.w|, -R10;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R7, R1, R1;
MULR  R15.xyz, R0, R1;
RCPR  R0.x, R0.w;
RCPR  R1.x, |R0.w|;
MULR  R1.xyz, R13, R1.x;
MULR_SAT R0.y, R0.x, R3.x;
ADDR  R0.z, R3.w, -R17.x;
MULR_SAT R0.x, R0.z, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R11, R11;
POWR  R8.x, c[31].x, R2.x;
POWR  R8.y, c[31].x, R2.y;
POWR  R8.z, c[31].x, R2.z;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R8, R1, R1;
MULR  R0.xyz, R0, R9;
MULR  R14.xyz, R0, R1;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R3, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R2, H0.y, R0, c[24];
TEX   R0.w, fragment.texcoord[0], texture[5], 2D;
MOVR  R0.z, R0.w;
TEX   R1.w, fragment.texcoord[0], texture[4], 2D;
MOVR  R0.y, R1.w;
TEX   R0.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R0.x, R0.w;
MOVR  R0.w, c[30].x;
MOVR  R1, c[26];
ADDR  R1, -R1, c[22];
MADR  R1, H0.y, R1, c[26];
DP4R  R5.x, R0, R2;
DP4R  R5.z, R0, R1;
DP4R  R5.y, R0, R3;
DP4R  R5.w, R0, R4;
DP4R  R0.z, R1, R1;
DP4R  R0.x, R2, R2;
ADDR  R1.w, R9, -R8;
RCPR  R2.x, R1.w;
DP4R  R0.y, R3, R3;
DP4R  R0.w, R4, R4;
MADR  R0, R5, R0, -R0;
ADDR  R0, R0, c[30].x;
MADR  R1.xyz, R14, R0.w, R15;
MADR  R1.xyz, R1, R0.z, R16;
ADDR  R0.zw, R17.xyyx, -R8.w;
MULR_SAT R2.y, -R6.w, R2.x;
MULR_SAT R0.z, R2.x, R0;
MULR  R0.z, R2.y, R0;
MULR  R2.xyz, -R10, |R1.w|;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R1.w|;
MULR  R4.xyz, R13, R0.z;
POWR  R2.x, c[31].x, R2.x;
POWR  R2.y, c[31].x, R2.y;
POWR  R2.z, c[31].x, R2.z;
MADR  R4.xyz, R10, R12, R4;
MADR  R4.xyz, -R2, R4, R4;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R4;
MADR  R1.xyz, R1, R0.y, R3;
ADDR  R0.y, R8.w, -R7.w;
MULR  R4.xyz, -R10, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R17.y, -R7;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R0.y|;
MULR  R5.xyz, R13, R0.z;
POWR  R4.x, c[31].x, R4.x;
POWR  R4.y, c[31].x, R4.y;
POWR  R4.z, c[31].x, R4.z;
MADR  R5.xyz, R10, R12, R5;
MADR  R5.xyz, -R4, R5, R5;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R5;
MADR  R0.xyz, R1, R0.x, R3;
MULR  R1.xyz, R0.y, c[34];
MADR  R1.xyz, R0.x, c[33], R1;
MADR  R0.xyz, R0.z, c[32], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R1.xyz, R2, R4;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R6, R1;
MULR  R1.xyz, R7, R1;
MULR  R1.xyz, R8, R1;
MULR  R2.xyz, R1.y, c[34];
MADR  R2.xyz, R1.x, c[33], R2;
MADR  R1.xyz, R1.z, c[32], R2;
MADH  H0.x, H0, c[28], H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
ADDR  R0.x, R1, R1.y;
ADDR  R0.x, R1.z, R0;
RCPR  R0.x, R0.x;
MULR  R0.zw, R1.xyxy, R0.x;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MULH  oCol.y, H0.x, H0.z;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
MADH  H0.x, H0, c[28], H0.y;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c28, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c29, 0.99500000, 1000000.00000000, -1000000.00000000, 0.10000000
def c30, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c31, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c32, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c33, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c34, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c35, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c36, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c28.x, c28.y
mul r0.xy, r0, c4
mov r0.z, c28.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c28.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mov r1.z, c7.x
mov r1.w, c7.x
add r1.w, c14.y, r1
rcp r0.w, r0.w
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r3.xyz, r3, c9.x
add r4.xyz, r3, -c5
dp3 r1.x, r4, r4
add r1.z, c14.x, r1
dp3 r1.y, r4, r0
mad r4.w, -r1, r1, r1.x
mad r5.x, r1.y, r1.y, -r4.w
mad r1.z, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2.x, c29.y
cmp r2.x, -r1.w, r1.z, r4.w
rsq r5.y, r5.x
rcp r5.y, r5.y
add r4.w, -r1.y, -r5.y
cmp_pp r1.w, r5.x, c28, c28.z
cmp r2.y, r5.x, r2, c29
cmp r2.y, -r1.w, r2, r4.w
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r4.w, c14, r1.z
mad r1.w, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1.w
mad r4.w, -r4, r4, r1.x
mad r5.x, r1.y, r1.y, -r4.w
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2, c29.y
cmp r2.z, -r1.w, r1, r4.w
rsq r5.y, r5.x
rcp r5.y, r5.y
add r4.w, -r1.y, -r5.y
cmp r1.w, r5.x, r2, c29.y
cmp_pp r1.z, r5.x, c28.w, c28
cmp r2.w, -r1.z, r1, r4
mov r1.w, c7.x
add r4.w, c13.x, r1
mov r1.w, c7.x
add r5.x, c13.y, r1.w
mad r4.w, -r4, r4, r1.x
mad r1.w, r1.y, r1.y, -r4
mad r5.x, -r5, r5, r1
mad r5.y, r1, r1, -r5.x
rsq r4.w, r1.w
rcp r4.w, r4.w
add r5.x, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r5.x, -r4.w, r1.w, r5
rsq r5.z, r5.y
cmp_pp r4.w, r5.y, c28, c28.z
rcp r5.z, r5.z
dp4 r1.z, r2, c24
dp4 r6.w, r2, c25
add r5.z, -r1.y, r5
cmp r5.y, r5, r3.w, c29.z
cmp r5.y, -r4.w, r5, r5.z
mov r1.w, c7.x
add r4.w, c13, r1
mad r4.w, -r4, r4, r1.x
mad r5.z, r1.y, r1.y, -r4.w
rsq r4.w, r5.z
rcp r5.w, r4.w
add r6.z, -r1.y, r5.w
cmp_pp r5.w, r5.z, c28, c28.z
cmp r5.z, r5, r3.w, c29
mov r1.w, c7.x
add r1.w, c13.z, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
cmp r5.w, -r5, r5.z, r6.z
rcp r4.w, r4.w
add r5.z, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r5.z, -r4.w, r1.w, r5
dp4 r1.w, r5, c20
add r6.z, r1.w, -r1
dp4 r4.w, r5, c19
cmp r11.w, -r4, c28, c28.z
mad r1.z, r11.w, r6, r1
dp4 r6.z, r5, c21
add r6.z, r6, -r6.w
mov r1.w, c7.x
add r1.w, c18.x, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
mad r6.w, r11, r6.z, r6
rcp r4.w, r4.w
add r6.z, -r1.y, -r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.y
cmp r1.w, -r4, r1, r6.z
cmp r3.w, r1, r1, c29.y
mad r1.x, -c8, c8, r1
mad r1.w, r1.y, r1.y, -r1.x
texldl r1.x, v0, s0
mul r4.w, r1.x, r0
mad r6.z, -r4.w, c9.x, r3.w
rsq r3.w, r1.w
mov r0.w, c4
mad r0.w, c29.x, -r0, r1.x
rcp r3.w, r3.w
mul r1.x, r4.w, c9
cmp r0.w, r0, c28, c28.z
mad r4.w, r0, r6.z, r1.x
add r0.w, -r1.y, -r3
add r1.y, -r1, r3.w
max r1.x, r0.w, c28.z
cmp_pp r0.w, r1, c28, c28.z
cmp r6.xy, r1.w, r6, c28.z
max r1.y, r1, c28.z
cmp r1.xy, -r0.w, r6, r1
min r3.w, r1.y, r4
min r1.y, r3.w, r6.w
max r6.w, r1.x, c28.z
min r0.w, r3, r1.z
max r7.w, r6, r0
max r8.w, r7, r1.y
dp4 r1.x, r2, c26
dp4 r0.w, r5, c22
add r0.w, r0, -r1.x
dp4 r1.y, r5, c23
dp4 r1.z, r2, c27
mad r0.w, r11, r0, r1.x
min r0.w, r3, r0
max r9.w, r8, r0
add r1.y, r1, -r1.z
mad r1.x, r11.w, r1.y, r1.z
min r1.x, r3.w, r1
max r4.w, r9, r1.x
add r8.x, r4.w, -r9.w
mov r0.w, c16.x
mov r1.xyz, c15
mad r5.xyz, r0, r6.w, r4
mul r1.w, c30, r0
dp3 r0.w, r5, r5
mul r1.xyz, c29.w, r1
add r9.xyz, r1, r1.w
abs r2.x, r8
mul r6.xyz, -r9, r2.x
pow r2, c31.x, r6.x
mov r6.x, r2
rcp r8.z, r9.z
rcp r8.y, r9.y
pow r2, c31.x, r6.y
rsq r0.w, r0.w
rcp r2.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r5.xyz, c12
rcp r2.z, r0.w
dp3 r0.w, c6, r5
add r2.x, r2, -c7
add r0.w, -r0, c28
mul r5.y, r2.x, r2.z
mul r5.x, r0.w, c31.y
mov r5.z, c28
texldl r2.zw, r5.xyzz, s1
mul r0.w, r2, c16.x
pow r5, c31.x, r6.z
mad r7.xyz, r2.z, -c15, -r0.w
mov r6.y, r2
pow r2, c31.x, r7.x
mov r6.z, r5
pow r5, c31.x, r7.y
mov r7.x, r2
pow r2, c31.x, r7.z
mov r7.z, r2
mov r7.y, r5
mul r5.xyz, r7, c11
mul r7.xyz, r0.zxyw, c12.yzxw
mad r7.xyz, r0.yzxw, c12.zxyw, -r7
mul r2.xyz, r4.zxyw, c12.yzxw
mad r2.xyz, r4.yzxw, c12.zxyw, -r2
dp3 r0.w, r2, r2
dp3 r5.w, r7, r7
mad r0.w, -c7.x, c7.x, r0
dp3 r2.w, r2, r7
mul r0.w, r5, r0
mad r2.x, r2.w, r2.w, -r0.w
rsq r2.y, r2.x
texldl r0.w, c31.yyzz, s2
mul r11.xyz, r5, r0.w
rcp r5.y, r2.y
rcp r5.z, r5.w
add r2.y, -r2.w, -r5
dp3 r0.w, r4, c12
mul r12.xyz, r9, r11
cmp r0.w, -r0, c28, c28.z
mul r2.y, r2, r5.z
add r2.w, -r2, r5.y
mov r5.w, c28
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r2.x
cmp r5.x, -r0.w, c29.y, r2.y
mad r2.xyz, r0, r5.x, r3
add r2.xyz, r2, -c5
dp3 r2.x, r2, c12
mul r2.y, r5.z, r2.w
cmp r5.y, -r0.w, c29.z, r2
rcp r2.y, r8.x
mul r4.xyz, r12, r6
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, r2.x
cmp r16.xy, -r0.w, r5, c29.yzzw
dp3 r2.x, r0, c12
add r0.w, -r16.x, r4
add r2.z, r16.y, -r9.w
mul r0.x, r2, c17
mul r0.x, r0, c28
rcp r8.x, r9.x
add r2.w, r3, -r4
mul_sat r0.w, r0, r2.y
mul_sat r0.y, r2, r2.z
mad r2.z, -r0.w, r0.y, c28.w
mad r0.x, c17, c17, r0
mad r3.xyz, r9, r11, -r4
abs r0.y, r2.w
mul r4.xyz, -r9, r0.y
add r2.y, r0.x, c28.w
pow r0, r2.y, c30.y
mad r0.z, r2.x, r2.x, c28.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c28.w, r0.y
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c30
mul r2.xy, r0, c30.z
pow r0, c31.x, r4.x
mul r0.y, r2, r1.w
mad r1.xyz, r1, r2.x, r0.y
mul r10.xyz, r1, r8
pow r1, c31.x, r4.z
mov r7.x, r0
pow r0, c31.x, r4.y
add r10.w, r9, -r8
abs r0.w, r10
mul r15.xyz, -r9, r0.w
mov r7.z, r1
mov r7.y, r0
mul r2.xyz, r10, r2.z
mul r1.xyz, r8, r2
mul r0.xyz, r7, r12
mul r14.xyz, r1, r3
mad r1.xyz, r9, r11, -r0
add r0.z, r16.y, -r4.w
rcp r0.y, r2.w
add r0.x, r3.w, -r16
mov r4, c23
add r4, -c27, r4
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c28.w
mul r0.xyz, r0.x, r10
mul r0.xyz, r0, r8
mul r13.xyz, r0, r1
mov r1, c21
add r1, -c25, r1
mad r2, r11.w, r1, c25
texldl r1.w, v0, s5
mov r5.z, r1.w
mov r0, c20
add r0, -c24, r0
mad r3, r11.w, r0, c24
texldl r0.w, v0, s4
mov r5.y, r0.w
texldl r0.w, v0, s3
mov r5.x, r0.w
dp4 r0.x, r3, r5
dp4 r3.x, r3, r3
mad r4, r11.w, r4, c27
mov r1, c22
add r1, -c26, r1
mad r1, r11.w, r1, c26
dp4 r0.y, r2, r5
dp4 r3.y, r2, r2
pow r2, c31.x, r15.y
dp4 r0.w, r4, r5
dp4 r0.z, r1, r5
dp4 r3.z, r1, r1
add r0, r0, c28.y
dp4 r3.w, r4, r4
mad r1, r3, r0, c28.w
pow r0, c31.x, r15.x
mad r4.xyz, r13, r1.w, r14
mov r3.x, r0
mov r3.y, r2
rcp r0.z, r10.w
add r0.w, r16.y, -r8
add r0.y, -r16.x, r9.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c28
pow r0, c31.x, r15.z
mov r3.z, r0
mul r2.xyz, r12, r3
mul r0.xyz, r10, r1.w
mad r2.xyz, r9, r11, -r2
mul r0.xyz, r8, r0
mul r0.xyz, r0, r2
mad r5.xyz, r4, r1.z, r0
add r0.w, r8, -r7
abs r0.y, r0.w
mul r4.xyz, -r9, r0.y
rcp r1.z, r0.w
add r0.x, -r16, r8.w
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r4.x
add r2.x, r16.y, -r7.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r4.z
mad r1.z, -r1.w, r0.y, c28.w
mov r4.x, r0
pow r0, c31.x, r4.y
mov r4.y, r0
mov r4.z, r2
mul r0.xyz, r10, r1.z
mul r2.xyz, r12, r4
mul r0.xyz, r8, r0
mad r2.xyz, r9, r11, -r2
mul r13.xyz, r0, r2
add r0.y, r7.w, -r6.w
rcp r1.z, r0.y
add r0.x, -r16, r7.w
abs r0.y, r0
mul r14.xyz, -r9, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r14.x
add r2.x, r16.y, -r6.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r14.y
mad r1.z, -r1.w, r0.y, c28.w
mov r14.x, r0
pow r0, c31.x, r14.z
mov r14.y, r2
mov r14.z, r0
mul r2.xyz, r10, r1.z
mul r0.xyz, r12, r14
mul r2.xyz, r8, r2
mad r0.xyz, r9, r11, -r0
mul r0.xyz, r2, r0
mad r2.xyz, r5, r1.y, r13
mad r0.xyz, r2, r1.x, r0
mul r1.xyz, r0.y, c34
mad r1.xyz, r0.x, c33, r1
mad r0.xyz, r0.z, c32, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
mul r1.xyz, r4, r14
mul r2.xyz, r3, r1
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c31.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c31.w
add r0.z, r0.x, c32.w
cmp r0.z, r0, c28.w, c28
mul_pp r1.x, r0.z, c33.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c30.w
mul r2.xyz, r6, r2
mul r2.xyz, r7, r2
mul r3.xyz, r2.y, c34
frc r1.x, r0
mad r3.xyz, r2.x, c33, r3
add r2.x, r0, -r1
mad r1.xyz, r2.z, c32, r3
add r2.z, r1.x, r1.y
add_pp r0.x, r2, c34.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c28, c28.w
add r1.z, r1, r2
rcp r0.z, r1.z
mul r2.zw, r1.xyxy, r0.z
mul r1.x, r2.z, c31.w
frc r1.z, r1.x
add r1.z, r1.x, -r1
mul r0.w, r0, c35.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r1.z, r1, c31.w
add r1.x, r1.z, c32.w
mul_pp r0.z, r2.x, c35.x
mul_pp r0.x, r0, r2.y
add r0.z, r1.w, -r0
min r0.w, r0, c35
mad r0.z, r0, c35.y, r0.w
cmp r1.x, r1, c28.w, c28.z
mad r0.z, r0, c36.x, c36.y
mul_pp r0.w, r1.x, c33
add r0.w, r1.z, -r0
mul_pp oC0.y, r0.x, r0.z
mul r0.x, r0.w, c30.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul_pp r0.z, r0.x, c35.x
mul r1.z, r2.w, c35
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0.w, -r0
min r1.z, r1, c35.w
mad r0.z, r0, c35.y, r1
add_pp r0.x, r0, c34.w
mad r0.w, r0.z, c36.x, c36.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c28, c28.w
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
SetTexture 6 [_TexCloudLayer3] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[36] = { program.local[0..27],
		{ 2, -1, 0, 0.995 },
		{ 1000000, -1000000, 0.1, 0.75 },
		{ 1, 1.5, 0.079577468, 0.25 },
		{ 2.718282, 0.5, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 15 },
		{ 0.51413637, 0.32387859, 0.16036376, 4 },
		{ 0.26506799, 0.67023426, 0.064091571, 256 },
		{ 400, 255, 0.0009765625 } };
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
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R1.x, c[29].y;
MOVR  R4.w, c[29].y;
MOVR  R7.w, c[29].y;
MOVR  R17.zw, c[30].xyxw;
MOVR  R8.x, c[0].w;
MOVR  R8.z, c[2].w;
MOVR  R8.y, c[1].w;
MULR  R7.xyz, R8, c[9].x;
ADDR  R4.xyz, R7, -c[5];
DP3R  R6.x, R4, R4;
MULR  R2.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R2, c[28].x, -R0;
MOVR  R0.z, c[28].y;
DP3R  R0.w, R0, R0;
RSQR  R3.w, R0.w;
MULR  R0.xyz, R3.w, R0;
MOVR  R0.w, c[28].z;
DP4R  R3.z, R0, c[2];
DP4R  R3.y, R0, c[1];
DP4R  R3.x, R0, c[0];
DP3R  R8.w, R3, R4;
MOVR  R0, c[13];
ADDR  R0, R0, c[7].x;
MADR  R0, -R0, R0, R6.x;
MULR  R9.x, R8.w, R8.w;
ADDR  R2, R9.x, -R0;
SLTR  R5, R9.x, R0;
MOVXC RC.x, R5;
MOVR  R1.x(EQ), R1.y;
SGERC HC, R9.x, R0.yzxw;
RSQR  R0.x, R2.z;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
ADDR  R1.x(NE.z), -R8.w, R2;
MOVXC RC.z, R5;
MOVR  R4.w(EQ.z), R1.y;
MOVXC RC.z, R5.w;
MOVR  R7.w(EQ.z), R1.y;
RCPR  R0.x, R0.x;
ADDR  R4.w(NE.y), -R8, R0.x;
RSQR  R0.x, R2.w;
RCPR  R0.x, R0.x;
ADDR  R7.w(NE), -R8, R0.x;
RSQR  R0.x, R2.y;
MOVR  R1.y, c[29];
MOVXC RC.y, R5;
MOVR  R1.y(EQ), R1.z;
RCPR  R0.x, R0.x;
ADDR  R1.y(NE.x), -R8.w, R0.x;
MOVR  R0, c[14];
ADDR  R0, R0, c[7].x;
MADR  R2, -R0, R0, R6.x;
ADDR  R5, R9.x, -R2;
RSQR  R0.y, R5.x;
SLTR  R6, R9.x, R2;
MOVR  R5.x, c[18];
MOVR  R0.z, c[29].x;
MOVR  R0.w, c[29].x;
MOVR  R0.x, c[29];
MOVXC RC.x, R6;
MOVR  R0.x(EQ), R1.z;
SGERC HC, R9.x, R2.yzxw;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.z), -R8.w, -R0.y;
MOVXC RC.z, R6;
MOVR  R0.z(EQ), R1;
RSQR  R0.y, R5.z;
RCPR  R0.y, R0.y;
ADDR  R0.z(NE.y), -R8.w, -R0.y;
RSQR  R0.y, R5.w;
MOVXC RC.z, R6.w;
MOVXC RC.y, R6;
RSQR  R2.x, R5.y;
MULR  R6.xyz, R3.zxyw, c[12].yzxw;
MADR  R6.xyz, R3.yzxw, c[12].zxyw, -R6;
MOVR  R0.w(EQ.z), R1.z;
RCPR  R0.y, R0.y;
ADDR  R0.w(NE), -R8, -R0.y;
MOVR  R0.y, c[29].x;
MOVR  R0.y(EQ), R1.z;
RCPR  R2.x, R2.x;
ADDR  R0.y(NE.x), -R8.w, -R2.x;
MOVR  R2.xyz, c[5];
MADR  R2.xyz, R8, c[9].x, -R2;
DP3R  R6.w, R2, R3;
DP3R  R2.w, R2, R2;
ADDR  R5.x, R5, c[7];
MULR  R8.x, R6.w, R6.w;
MADR  R5.x, -R5, R5, R2.w;
ADDR  R5.y, R8.x, -R5.x;
RSQR  R5.y, R5.y;
MOVR  R5.w, c[29].x;
SLTRC HC.x, R8, R5;
MOVR  R5.w(EQ.x), R1.z;
SGERC HC.x, R8, R5;
RCPR  R5.y, R5.y;
ADDR  R5.w(NE.x), -R6, -R5.y;
MOVXC RC.x, R5.w;
MULR  R5.xyz, R2.zxyw, c[12].yzxw;
MADR  R5.xyz, R2.yzxw, c[12].zxyw, -R5;
DP3R  R2.x, R2, c[12];
SLER  H0.x, R2, c[28].z;
DP3R  R8.y, R5, R5;
DP3R  R5.x, R5, R6;
DP3R  R5.z, R6, R6;
MADR  R5.y, -c[7].x, c[7].x, R8;
MULR  R6.y, R5.z, R5;
MULR  R6.x, R5, R5;
ADDR  R5.y, R6.x, -R6;
RSQR  R5.y, R5.y;
RCPR  R5.y, R5.y;
ADDR  R2.y, -R5.x, R5;
MOVR  R5.w(LT.x), c[29].x;
SGTR  H0.y, R6.x, R6;
MULX  H0.x, H0, c[10];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R5.z, R5.z;
MOVR  R2.z, c[29].y;
MULR  R2.z(NE.x), R5, R2.y;
ADDR  R2.y, -R5.x, -R5;
MOVR  R2.x, c[29];
MULR  R2.x(NE), R2.y, R5.z;
MOVR  R2.y, R2.z;
MOVR  R17.xy, R2;
MADR  R2.xyz, R3, R2.x, R7;
ADDR  R2.xyz, R2, -c[5];
DP3R  R2.x, R2, c[12];
SGTR  H0.y, R2.x, c[28].z;
MADR  R2.x, -c[8], c[8], R2.w;
MULXC HC.x, H0, H0.y;
MOVR  R17.xy(NE.x), c[29];
MOVR  R5.x, c[28].w;
MOVR  R2.zw, c[28].z;
SLTRC HC.x, R8, R2;
MOVR  R2.zw(EQ.x), R1;
ADDR  R1.z, R8.x, -R2.x;
SGERC HC.x, R8, R2;
RSQR  R1.z, R1.z;
RCPR  R1.z, R1.z;
DP4R  R2.x, R0, c[24];
ADDR  R1.w, -R6, -R1.z;
ADDR  R2.y, -R6.w, R1.z;
MAXR  R1.z, R1.w, c[28];
MAXR  R1.w, R2.y, c[28].z;
MOVR  R2.zw(NE.x), R1;
MOVR  R1.w, R7;
MOVR  R1.z, R4.w;
DP4R  R2.y, R1, c[20];
ADDR  R4.w, R2.y, -R2.x;
DP4R  R2.y, R1, c[19];
SGER  H0.y, c[28].z, R2;
MADR  R2.y, H0, R4.w, R2.x;
DP4R  R4.w, R0, c[25];
DP4R  R2.x, R1, c[21];
ADDR  R2.x, R2, -R4.w;
MADR  R4.w, H0.y, R2.x, R4;
MAXR  R7.w, R2.z, c[28].z;
TEX   R2.x, fragment.texcoord[0], texture[0], 2D;
MULR  R5.x, R5, c[4].w;
RCPR  R3.w, R3.w;
MULR  R3.w, R2.x, R3;
MADR  R5.y, -R3.w, c[9].x, R5.w;
SGER  H0.x, R2, R5;
MULR  R3.w, R3, c[9].x;
MADR  R2.x, H0, R5.y, R3.w;
MINR  R3.w, R2, R2.x;
MINR  R2.y, R3.w, R2;
MAXR  R8.w, R7, R2.y;
DP4R  R2.y, R0, c[26];
DP4R  R0.x, R0, c[27];
MINR  R2.x, R3.w, R4.w;
MAXR  R9.w, R8, R2.x;
DP4R  R2.x, R1, c[22];
DP4R  R0.y, R1, c[23];
ADDR  R0.y, R0, -R0.x;
ADDR  R2.x, R2, -R2.y;
MADR  R2.x, H0.y, R2, R2.y;
MINR  R2.x, R3.w, R2;
MAXR  R4.w, R9, R2.x;
ADDR  R5.z, R4.w, -R9.w;
MADR  R0.x, H0.y, R0.y, R0;
MINR  R0.x, R3.w, R0;
MAXR  R0.w, R4, R0.x;
ADDR  R1.w, R0, -R4;
ADDR  R5.xy, R17.yxzw, -R4.w;
RCPR  R0.x, R1.w;
MULR_SAT R0.y, R0.x, R5.x;
RCPR  R2.x, R5.z;
ADDR  R6.zw, R17.xyyx, -R9.w;
MULR_SAT R2.y, R2.x, R6.z;
MULR_SAT R2.x, -R5.y, R2;
MULR  R2.w, R2.x, R2.y;
DP3R  R2.x, R3, c[12];
MULR  R2.y, R2.x, c[17].x;
MULR  R2.y, R2, c[28].x;
MADR  R2.y, c[17].x, c[17].x, R2;
ADDR  R2.y, R2, c[30].x;
POWR  R2.z, R2.y, c[30].y;
MULR  R2.x, R2, R2;
ADDR  R2.y, R17.z, c[17].x;
MADR  R3.xyz, R3, R7.w, R4;
MULR  R5.w, R17, c[16].x;
RCPR  R2.z, R2.z;
MULR  R2.y, R2, R2;
MULR  R2.y, R2, R2.z;
MADR  R2.x, R2, c[29].w, c[29].w;
MULR  R6.xy, R2, c[30].z;
MOVR  R2.x, c[29].z;
MULR  R2.xyz, R2.x, c[15];
ADDR  R10.xyz, R2, R5.w;
MULR  R5.y, R6, R5.w;
MADR  R2.xyz, R2, R6.x, R5.y;
RCPR  R9.x, R10.x;
RCPR  R9.z, R10.z;
RCPR  R9.y, R10.y;
MULR  R11.xyz, R2, R9;
MADR  R2.xyz, R11, -R2.w, R11;
DP3R  R2.w, R3, R3;
RSQR  R2.w, R2.w;
RCPR  R2.w, R2.w;
ADDR  R3.x, R2.w, -c[7];
MOVR  R2.w, c[7].x;
ADDR  R2.w, -R2, c[8].x;
RCPR  R2.w, R2.w;
MULR  R4.y, R3.x, R2.w;
MOVR  R3.xyz, c[6];
DP3R  R2.w, R3, c[12];
MADR  R4.x, -R2.w, c[31].y, c[31].y;
TEX   R12.zw, R4, texture[1], 2D;
MULR  R4.xyz, -R10, |R5.z|;
MULR  R2.w, R12, c[16].x;
MADR  R3.xyz, R12.z, -c[15], -R2.w;
RCPR  R5.y, |R5.z|;
POWR  R6.x, c[31].x, R4.x;
POWR  R6.y, c[31].x, R4.y;
POWR  R6.z, c[31].x, R4.z;
TEX   R2.w, c[31].y, texture[2], 2D;
MULR  R2.xyz, R9, R2;
RCPR  R1.x, |R1.w|;
POWR  R3.x, c[31].x, R3.x;
POWR  R3.z, c[31].x, R3.z;
POWR  R3.y, c[31].x, R3.y;
MULR  R3.xyz, R3, c[11];
MULR  R12.xyz, R3, R2.w;
ADDR  R13.xyz, R12, -R12;
MULR  R3.xyz, R13, R5.y;
MADR  R3.xyz, R10, R12, R3;
MADR  R3.xyz, -R6, R3, R3;
MULR  R16.xyz, R2, R3;
MULR  R2.xyz, -R10, |R1.w|;
ADDR  R3.xy, R17.yxzw, -R0.w;
MULR_SAT R0.x, -R3.y, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R11, -R0.x, R11;
MULR  R1.xyz, R13, R1.x;
MULR  R0.xyz, R9, R0;
ADDR  R0.w, R3, -R0;
TEX   R2.w, fragment.texcoord[0], texture[6], 2D;
POWR  R7.x, c[31].x, R2.x;
POWR  R7.y, c[31].x, R2.y;
POWR  R7.z, c[31].x, R2.z;
MULR  R2.xyz, |R0.w|, -R10;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R7, R1, R1;
MULR  R15.xyz, R0, R1;
RCPR  R0.x, R0.w;
RCPR  R1.x, |R0.w|;
MULR  R1.xyz, R13, R1.x;
MULR_SAT R0.y, R0.x, R3.x;
ADDR  R0.z, R3.w, -R17.x;
MULR_SAT R0.x, R0.z, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R11, R11;
POWR  R8.x, c[31].x, R2.x;
POWR  R8.y, c[31].x, R2.y;
TEX   R1.w, fragment.texcoord[0], texture[4], 2D;
MOVR  R2.y, R1.w;
POWR  R8.z, c[31].x, R2.z;
MADR  R1.xyz, R10, R12, R1;
MADR  R1.xyz, -R8, R1, R1;
MULR  R0.xyz, R0, R9;
MULR  R14.xyz, R0, R1;
MOVR  R0, c[25];
ADDR  R0, -R0, c[21];
MADR  R4, H0.y, R0, c[25];
MOVR  R0, c[24];
ADDR  R0, -R0, c[20];
MADR  R3, H0.y, R0, c[24];
TEX   R0.w, fragment.texcoord[0], texture[5], 2D;
MOVR  R2.z, R0.w;
TEX   R0.w, fragment.texcoord[0], texture[3], 2D;
MOVR  R2.x, R0.w;
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R0, H0.y, R0, c[26];
MOVR  R1, c[27];
ADDR  R1, -R1, c[23];
MADR  R1, H0.y, R1, c[27];
DP4R  R5.x, R2, R3;
DP4R  R5.y, R2, R4;
DP4R  R5.z, R2, R0;
DP4R  R5.w, R2, R1;
DP4R  R2.w, R1, R1;
ADDR  R1.w, R9, -R8;
DP4R  R2.x, R3, R3;
DP4R  R2.y, R4, R4;
DP4R  R2.z, R0, R0;
MADR  R0, R5, R2, -R2;
ADDR  R0, R0, c[30].x;
RCPR  R2.x, R1.w;
MADR  R1.xyz, R14, R0.w, R15;
MADR  R1.xyz, R1, R0.z, R16;
ADDR  R0.zw, R17.xyyx, -R8.w;
MULR_SAT R2.y, -R6.w, R2.x;
MULR_SAT R0.z, R2.x, R0;
MULR  R0.z, R2.y, R0;
MULR  R2.xyz, -R10, |R1.w|;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R1.w|;
MULR  R4.xyz, R13, R0.z;
POWR  R2.x, c[31].x, R2.x;
POWR  R2.y, c[31].x, R2.y;
POWR  R2.z, c[31].x, R2.z;
MADR  R4.xyz, R10, R12, R4;
MADR  R4.xyz, -R2, R4, R4;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R4;
MADR  R1.xyz, R1, R0.y, R3;
ADDR  R0.y, R8.w, -R7.w;
MULR  R4.xyz, -R10, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
ADDR  R1.w, R17.y, -R7;
MULR_SAT R0.z, R0, R1.w;
MULR  R0.z, R0.w, R0;
MADR  R3.xyz, R11, -R0.z, R11;
RCPR  R0.z, |R0.y|;
MULR  R5.xyz, R13, R0.z;
POWR  R4.x, c[31].x, R4.x;
POWR  R4.y, c[31].x, R4.y;
POWR  R4.z, c[31].x, R4.z;
MADR  R5.xyz, R10, R12, R5;
MADR  R5.xyz, -R4, R5, R5;
MULR  R3.xyz, R9, R3;
MULR  R3.xyz, R3, R5;
MADR  R0.xyz, R1, R0.x, R3;
MULR  R1.xyz, R0.y, c[34];
MADR  R1.xyz, R0.x, c[33], R1;
MADR  R0.xyz, R0.z, c[32], R1;
ADDR  R0.w, R0.x, R0.y;
ADDR  R0.z, R0, R0.w;
MULR  R1.xyz, R2, R4;
RCPR  R0.z, R0.z;
MULR  R0.zw, R0.xyxy, R0.z;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
MULR  R1.xyz, R6, R1;
MULR  R1.xyz, R7, R1;
MULR  R1.xyz, R8, R1;
MULR  R2.xyz, R1.y, c[34];
MADR  R2.xyz, R1.x, c[33], R2;
MADR  R1.xyz, R1.z, c[32], R2;
MADH  H0.x, H0, c[28], H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
ADDR  R0.x, R1, R1.y;
ADDR  R0.x, R1.z, R0;
RCPR  R0.x, R0.x;
MULR  R0.zw, R1.xyxy, R0.x;
MULR  R0.x, R0.z, c[31].z;
FLRR  R0.x, R0;
MULH  oCol.y, H0.x, H0.z;
MINR  R0.x, R0, c[31].z;
SGER  H0.x, R0, c[31].w;
MULH  H0.y, H0.x, c[31].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[30].w;
FLRR  H0.y, R0.z;
MULH  H0.z, H0.y, c[33].w;
MULR  R0.z, R0.w, c[35].x;
FLRR  R0.z, R0;
ADDH  H0.y, H0, -c[32].w;
EX2H  H0.y, H0.y;
MULH  H0.x, -H0, H0.y;
ADDR  R0.x, R0, -H0.z;
MINR  R0.z, R0, c[35].y;
MADR  R0.x, R0, c[34].w, R0.z;
MADR  H0.z, R0.x, c[35], R17;
MADH  H0.x, H0, c[28], H0.y;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 4 [_CameraData]
Matrix 0 [_Camera2World]
Vector 5 [_PlanetCenterKm]
Vector 6 [_PlanetNormal]
Float 7 [_PlanetRadiusKm]
Float 8 [_PlanetAtmosphereRadiusKm]
Float 9 [_WorldUnit2Kilometer]
Float 10 [_bComputePlanetShadow]
Vector 11 [_SunColor]
Vector 12 [_SunDirection]
SetTexture 2 [_TexShadowEnvMapSun] 2D
Vector 13 [_ShadowAltitudesMinKm]
Vector 14 [_ShadowAltitudesMaxKm]
Vector 15 [_Sigma_Rayleigh]
Float 16 [_Sigma_Mie]
Float 17 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDensity] 2D
SetTexture 3 [_TexCloudLayer0] 2D
SetTexture 4 [_TexCloudLayer1] 2D
SetTexture 5 [_TexCloudLayer2] 2D
SetTexture 6 [_TexCloudLayer3] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
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

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c28, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c29, 0.99500000, 1000000.00000000, -1000000.00000000, 0.10000000
def c30, 0.75000000, 1.50000000, 0.07957747, 0.25000000
def c31, 2.71828198, 0.50000000, 0.00000000, 210.00000000
def c32, 0.02411880, 0.12281780, 0.84442663, -128.00000000
def c33, 0.51413637, 0.32387859, 0.16036376, 128.00000000
def c34, 0.26506799, 0.67023426, 0.06409157, -15.00000000
def c35, 4.00000000, 256.00000000, 400.00000000, 255.00000000
def c36, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c28.x, c28.y
mul r0.xy, r0, c4
mov r0.z, c28.y
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r1.xyz, r0.w, r0
mov r1.w, c28.z
dp4 r0.z, r1, c2
dp4 r0.y, r1, c1
dp4 r0.x, r1, c0
mul r8.xyz, r0.zxyw, c12.yzxw
mov r1.z, c7.x
mov r1.w, c7.x
mad r8.xyz, r0.yzxw, c12.zxyw, -r8
add r1.w, c14.y, r1
rcp r0.w, r0.w
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r3.xyz, r3, c9.x
add r4.xyz, r3, -c5
dp3 r1.x, r4, r4
add r1.z, c14.x, r1
dp3 r1.y, r4, r0
mad r4.w, -r1, r1, r1.x
mad r5.z, r1.y, r1.y, -r4.w
mad r1.z, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2.x, c29.y
cmp r2.x, -r1.w, r1.z, r4.w
rsq r5.w, r5.z
rcp r5.w, r5.w
add r4.w, -r1.y, -r5
cmp_pp r1.w, r5.z, c28, c28.z
cmp r2.y, r5.z, r2, c29
cmp r2.y, -r1.w, r2, r4.w
mov r1.z, c7.x
add r1.w, c14.z, r1.z
mov r1.z, c7.x
add r4.w, c14, r1.z
mad r1.w, -r1, r1, r1.x
mad r1.z, r1.y, r1.y, -r1.w
mad r4.w, -r4, r4, r1.x
mad r5.z, r1.y, r1.y, -r4.w
rsq r1.w, r1.z
rcp r1.w, r1.w
add r4.w, -r1.y, -r1
cmp_pp r1.w, r1.z, c28, c28.z
cmp r1.z, r1, r2, c29.y
cmp r2.z, -r1.w, r1, r4.w
rsq r5.w, r5.z
rcp r5.w, r5.w
add r4.w, -r1.y, -r5
cmp r1.w, r5.z, r2, c29.y
cmp_pp r1.z, r5, c28.w, c28
cmp r2.w, -r1.z, r1, r4
mov r1.w, c7.x
add r4.w, c13.x, r1
mov r1.w, c7.x
add r5.z, c13.y, r1.w
mad r4.w, -r4, r4, r1.x
mad r1.w, r1.y, r1.y, -r4
mad r5.z, -r5, r5, r1.x
mad r5.w, r1.y, r1.y, -r5.z
rsq r4.w, r1.w
rcp r4.w, r4.w
add r5.z, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r9.x, -r4.w, r1.w, r5.z
rsq r6.x, r5.w
rcp r6.x, r6.x
dp4 r1.z, r2, c24
cmp r5.z, r5.w, r3.w, c29
add r6.x, -r1.y, r6
cmp_pp r4.w, r5, c28, c28.z
cmp r9.y, -r4.w, r5.z, r6.x
mov r1.w, c7.x
add r4.w, c13, r1
mad r4.w, -r4, r4, r1.x
mad r5.z, r1.y, r1.y, -r4.w
rsq r4.w, r5.z
rcp r5.w, r4.w
add r6.x, -r1.y, r5.w
cmp_pp r5.w, r5.z, c28, c28.z
cmp r5.z, r5, r3.w, c29
cmp r9.w, -r5, r5.z, r6.x
mov r1.w, c7.x
add r1.w, c13.z, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
rcp r4.w, r4.w
add r5.z, -r1.y, r4.w
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.z
cmp r9.z, -r4.w, r1.w, r5
dp4 r1.w, r9, c20
add r5.w, r1, -r1.z
dp4 r4.w, r9, c19
cmp r5.z, -r4.w, c28.w, c28
mad r1.z, r5, r5.w, r1
mov r1.w, c7.x
add r1.w, c18.x, r1
mad r1.w, -r1, r1, r1.x
mad r1.w, r1.y, r1.y, -r1
rsq r4.w, r1.w
dp4 r6.x, r2, c25
dp4 r5.w, r9, c21
add r5.w, r5, -r6.x
mad r6.x, r5.z, r5.w, r6
rcp r4.w, r4.w
add r5.w, -r1.y, -r4
cmp_pp r4.w, r1, c28, c28.z
cmp r1.w, r1, r3, c29.y
cmp r1.w, -r4, r1, r5
cmp r3.w, r1, r1, c29.y
mad r1.x, -c8, c8, r1
mad r1.w, r1.y, r1.y, -r1.x
texldl r1.x, v0, s0
mul r4.w, r1.x, r0
mad r5.w, -r4, c9.x, r3
rsq r3.w, r1.w
mov r0.w, c4
mad r0.w, c29.x, -r0, r1.x
cmp r5.xy, r1.w, r5, c28.z
rcp r3.w, r3.w
mul r1.x, r4.w, c9
cmp r0.w, r0, c28, c28.z
mad r4.w, r0, r5, r1.x
add r0.w, -r1.y, -r3
add r1.y, -r1, r3.w
max r1.x, r0.w, c28.z
cmp_pp r0.w, r1, c28, c28.z
max r1.y, r1, c28.z
cmp r1.xy, -r0.w, r5, r1
min r3.w, r1.y, r4
max r6.w, r1.x, c28.z
min r0.w, r3, r1.z
max r7.w, r6, r0
min r1.y, r3.w, r6.x
max r8.w, r7, r1.y
dp3 r5.y, r8, r8
mad r7.xyz, r0, r6.w, r4
dp4 r1.x, r2, c26
dp4 r0.w, r9, c22
add r0.w, r0, -r1.x
mad r0.w, r5.z, r0, r1.x
dp4 r1.z, r2, c27
dp4 r1.y, r9, c23
min r0.w, r3, r0
max r9.w, r8, r0
add r1.y, r1, -r1.z
mad r1.x, r5.z, r1.y, r1.z
min r1.x, r3.w, r1
max r4.w, r9, r1.x
add r5.x, r4.w, -r9.w
mov r0.w, c16.x
mul r1.w, c30, r0
dp3 r0.w, r7, r7
mov r1.xyz, c15
mul r1.xyz, c29.w, r1
add r9.xyz, r1, r1.w
abs r2.x, r5
mul r6.xyz, -r9, r2.x
pow r2, c31.x, r6.x
pow r10, c31.x, r6.z
mov r6.x, r2
pow r2, c31.x, r6.y
rsq r0.w, r0.w
rcp r2.x, r0.w
mov r0.w, c8.x
add r0.w, -c7.x, r0
mov r7.xyz, c12
rcp r2.z, r0.w
dp3 r0.w, c6, r7
add r2.x, r2, -c7
add r0.w, -r0, c28
mul r7.y, r2.x, r2.z
mul r7.x, r0.w, c31.y
mov r7.z, c28
texldl r2.zw, r7.xyzz, s1
mul r0.w, r2, c16.x
mad r7.xyz, r2.z, -c15, -r0.w
mov r6.y, r2
pow r2, c31.x, r7.x
mov r6.z, r10
pow r10, c31.x, r7.y
mov r7.x, r2
pow r2, c31.x, r7.z
mov r7.z, r2
mov r7.y, r10
mul r2.xyz, r4.zxyw, c12.yzxw
mad r2.xyz, r4.yzxw, c12.zxyw, -r2
dp3 r2.w, r2, r8
dp3 r0.w, r2, r2
mad r0.w, -c7.x, c7.x, r0
mul r0.w, r5.y, r0
mad r2.x, r2.w, r2.w, -r0.w
rsq r2.y, r2.x
rcp r5.w, r2.y
add r2.y, -r2.w, -r5.w
rcp r5.y, r5.y
mul r7.xyz, r7, c11
texldl r0.w, c31.yyzz, s2
mul r11.xyz, r7, r0.w
dp3 r0.w, r4, c12
mul r12.xyz, r9, r11
cmp r0.w, -r0, c28, c28.z
rcp r8.x, r9.x
rcp r8.z, r9.z
rcp r8.y, r9.y
mul r2.y, r2, r5
add r2.w, -r2, r5
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, c10.x
mul_pp r0.w, r0, r2.x
cmp r7.x, -r0.w, c29.y, r2.y
mad r2.xyz, r0, r7.x, r3
add r2.xyz, r2, -c5
dp3 r2.x, r2, c12
mul r2.y, r5, r2.w
cmp r7.y, -r0.w, c29.z, r2
mul r4.xyz, r12, r6
cmp r2.x, -r2, c28.z, c28.w
mul_pp r0.w, r0, r2.x
cmp r16.xy, -r0.w, r7, c29.yzzw
dp3 r2.x, r0, c12
mul r0.x, r2, c17
mul r0.x, r0, c28
add r2.w, r3, -r4
rcp r2.y, r5.x
add r0.w, -r16.x, r4
add r2.z, r16.y, -r9.w
mul_sat r0.w, r0, r2.y
mul_sat r0.y, r2, r2.z
mad r2.z, -r0.w, r0.y, c28.w
mad r0.x, c17, c17, r0
mad r3.xyz, r9, r11, -r4
abs r0.y, r2.w
mul r4.xyz, -r9, r0.y
add r2.y, r0.x, c28.w
pow r0, r2.y, c30.y
mad r0.z, r2.x, r2.x, c28.w
mov r0.w, r0.x
mov r0.y, c17.x
add r0.x, c28.w, r0.y
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c30
mul r2.xy, r0, c30.z
pow r0, c31.x, r4.x
mul r0.y, r2, r1.w
mad r1.xyz, r1, r2.x, r0.y
mul r10.xyz, r1, r8
pow r1, c31.x, r4.z
mov r7.x, r0
pow r0, c31.x, r4.y
add r10.w, r9, -r8
abs r0.w, r10
mul r15.xyz, -r9, r0.w
mov r7.z, r1
mov r7.y, r0
mul r2.xyz, r10, r2.z
mul r1.xyz, r8, r2
mul r0.xyz, r7, r12
mul r14.xyz, r1, r3
mad r1.xyz, r9, r11, -r0
add r0.z, r16.y, -r4.w
rcp r0.y, r2.w
add r0.x, r3.w, -r16
mul_sat r0.x, r0, r0.y
mul_sat r0.z, r0.y, r0
mad r0.x, -r0, r0.z, c28.w
mul r0.xyz, r0.x, r10
mul r0.xyz, r0, r8
mul r13.xyz, r0, r1
mov r1, c21
add r1, -c25, r1
mad r2, r5.z, r1, c25
mov r0, c20
add r0, -c24, r0
mad r3, r5.z, r0, c24
texldl r1.w, v0, s5
mov r0.z, r1.w
texldl r4.w, v0, s3
mov r0.x, r4.w
texldl r1.w, v0, s4
mov r0.y, r1.w
texldl r0.w, v0, s6
dp4 r5.x, r3, r0
dp4 r3.x, r3, r3
mov r4, c23
mov r1, c22
add r4, -c27, r4
mad r4, r5.z, r4, c27
add r1, -c26, r1
mad r1, r5.z, r1, c26
dp4 r5.y, r2, r0
dp4 r3.y, r2, r2
pow r2, c31.x, r15.y
dp4 r5.z, r1, r0
dp4 r5.w, r4, r0
add r0, r5, c28.y
dp4 r3.z, r1, r1
dp4 r3.w, r4, r4
mad r1, r3, r0, c28.w
pow r0, c31.x, r15.x
mad r4.xyz, r13, r1.w, r14
mov r3.x, r0
mov r3.y, r2
rcp r0.z, r10.w
add r0.w, r16.y, -r8
add r0.y, -r16.x, r9.w
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r1.w, -r0.y, r0, c28
pow r0, c31.x, r15.z
mov r3.z, r0
mul r2.xyz, r12, r3
mul r0.xyz, r10, r1.w
mad r2.xyz, r9, r11, -r2
mul r0.xyz, r8, r0
mul r0.xyz, r0, r2
mad r5.xyz, r4, r1.z, r0
add r0.w, r8, -r7
abs r0.y, r0.w
mul r4.xyz, -r9, r0.y
rcp r1.z, r0.w
add r0.x, -r16, r8.w
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r4.x
add r2.x, r16.y, -r7.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r4.z
mad r1.z, -r1.w, r0.y, c28.w
mov r4.x, r0
pow r0, c31.x, r4.y
mov r4.y, r0
mov r4.z, r2
mul r0.xyz, r10, r1.z
mul r2.xyz, r12, r4
mul r0.xyz, r8, r0
mad r2.xyz, r9, r11, -r2
mul r13.xyz, r0, r2
add r0.y, r7.w, -r6.w
rcp r1.z, r0.y
add r0.x, -r16, r7.w
abs r0.y, r0
mul r14.xyz, -r9, r0.y
mul_sat r1.w, r0.x, r1.z
pow r0, c31.x, r14.x
add r2.x, r16.y, -r6.w
mul_sat r0.y, r1.z, r2.x
pow r2, c31.x, r14.y
mad r1.z, -r1.w, r0.y, c28.w
mov r14.x, r0
pow r0, c31.x, r14.z
mov r14.y, r2
mov r14.z, r0
mul r2.xyz, r10, r1.z
mul r0.xyz, r12, r14
mul r2.xyz, r8, r2
mad r0.xyz, r9, r11, -r0
mul r0.xyz, r2, r0
mad r2.xyz, r5, r1.y, r13
mad r0.xyz, r2, r1.x, r0
mul r1.xyz, r0.y, c34
mad r1.xyz, r0.x, c33, r1
mad r0.xyz, r0.z, c32, r1
add r0.w, r0.x, r0.y
add r0.z, r0, r0.w
mul r1.xyz, r4, r14
mul r2.xyz, r3, r1
rcp r0.z, r0.z
mul r0.zw, r0.xyxy, r0.z
mul r0.x, r0.z, c31.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c31.w
add r0.z, r0.x, c32.w
cmp r0.z, r0, c28.w, c28
mul_pp r1.x, r0.z, c33.w
add r1.w, r0.x, -r1.x
mul r0.x, r1.w, c30.w
mul r2.xyz, r6, r2
mul r2.xyz, r7, r2
mul r3.xyz, r2.y, c34
frc r1.x, r0
mad r3.xyz, r2.x, c33, r3
add r2.x, r0, -r1
mad r1.xyz, r2.z, c32, r3
add r2.z, r1.x, r1.y
add_pp r0.x, r2, c34.w
exp_pp r2.y, r0.x
mad_pp r0.x, -r0.z, c28, c28.w
add r1.z, r1, r2
rcp r0.z, r1.z
mul r2.zw, r1.xyxy, r0.z
mul r1.x, r2.z, c31.w
frc r1.z, r1.x
add r1.z, r1.x, -r1
mul r0.w, r0, c35.z
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r1.z, r1, c31.w
add r1.x, r1.z, c32.w
mul_pp r0.z, r2.x, c35.x
mul_pp r0.x, r0, r2.y
add r0.z, r1.w, -r0
min r0.w, r0, c35
mad r0.z, r0, c35.y, r0.w
cmp r1.x, r1, c28.w, c28.z
mad r0.z, r0, c36.x, c36.y
mul_pp r0.w, r1.x, c33
add r0.w, r1.z, -r0
mul_pp oC0.y, r0.x, r0.z
mul r0.x, r0.w, c30.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul_pp r0.z, r0.x, c35.x
mul r1.z, r2.w, c35
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0.w, -r0
min r1.z, r1, c35.w
mad r0.z, r0, c35.y, r1
add_pp r0.x, r0, c34.w
mad r0.w, r0.z, c36.x, c36.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c28, c28.w
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
mov_pp oC0.z, r1.y

"
}

}

		}
	}
	Fallback off
}
