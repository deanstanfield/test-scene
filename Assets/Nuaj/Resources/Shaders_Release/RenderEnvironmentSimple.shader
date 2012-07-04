// This shader is responsible for rendering 3 tiny environment maps
// . The first map renders the sky without the clouds and is used to compute the ambient sky light for clouds
// . The second map renders the sky with the clouds and is used to compute the ambient sky light for the scene
// . The third map renders the sun with the clouds and is used to compute the directional sun light to use for the scene
//
Shader "Hidden/Nuaj/RenderSkyEnvironmentSimple"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
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
Matrix 0 [_Camera2World]
Vector 4 [_PlanetCenterKm]
Vector 5 [_PlanetNormal]
Vector 6 [_PlanetTangent]
Vector 7 [_PlanetBiTangent]
Float 8 [_PlanetRadiusKm]
Float 9 [_PlanetAtmosphereRadiusKm]
Float 10 [_WorldUnit2Kilometer]
Float 11 [_bComputePlanetShadow]
Vector 12 [_SunColor]
Vector 13 [_SunDirection]
Vector 14 [_EnvironmentAngles]
SetTexture 1 [_TexShadowEnvMapSun] 2D
Vector 15 [_ShadowAltitudesMinKm]
Vector 16 [_ShadowAltitudesMaxKm]
Vector 17 [_Sigma_Rayleigh]
Float 18 [_Sigma_Mie]
Float 19 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexBackground] 2D
Float 20 [_LuminanceScale]
Vector 21 [_CaseSwizzle]
Vector 22 [_SwizzleExitUp0]
Vector 23 [_SwizzleExitUp1]
Vector 24 [_SwizzleExitUp2]
Vector 25 [_SwizzleExitUp3]
Vector 26 [_SwizzleEnterDown0]
Vector 27 [_SwizzleEnterDown1]
Vector 28 [_SwizzleEnterDown2]
Vector 29 [_SwizzleEnterDown3]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[34] = { program.local[0..29],
		{ 9.9999997e-005, 2.718282, 0.1, 0.25 },
		{ 0, -1000000, 1000000, 0.75 },
		{ 1, 2, 1.5, 0.079577468 },
		{ 0.5 } };
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
MADR  R2.xy, fragment.texcoord[0], c[14].zwzw, c[14];
MOVR  R16.zw, c[31].x;
MOVR  R4.w, c[31].y;
MOVR  R6.w, c[31].y;
SINR  R1.y, R2.x;
SINR  R0.y, R2.y;
COSR  R1.x, R2.y;
MULR  R2.y, R0, R1;
COSR  R1.w, R2.x;
MULR  R1.xyz, R1.x, c[5];
MADR  R1.xyz, R2.y, c[6], R1;
MULR  R0.y, R0, R1.w;
MADR  R6.xyz, R0.y, c[7], R1;
MOVR  R2, c[15];
MOVR  R7.y, c[31].x;
MOVR  R1.y, c[2].w;
MOVR  R1.x, c[0].w;
MULR  R7.xz, R1.xyyw, c[10].x;
ADDR  R4.xyz, R7, -c[4];
DP3R  R0.y, R4, R6;
MULR  R1.y, R0, R0;
MOVR  R1.x, c[31].y;
DP3R  R1.w, R4, R4;
ADDR  R2, R2, c[8].x;
MADR  R2, -R2, R2, R1.w;
ADDR  R3, R1.y, -R2;
SLTR  R5, R1.y, R2;
MOVXC RC.x, R5;
MOVR  R1.x(EQ), R0;
SGERC HC, R1.y, R2.yzxw;
RSQR  R1.z, R3.x;
RCPR  R1.z, R1.z;
ADDR  R1.x(NE.z), -R0.y, R1.z;
RSQR  R2.x, R3.z;
MOVR  R1.z, c[31].y;
MOVXC RC.z, R5;
MOVR  R1.z(EQ), R0.x;
MOVXC RC.z, R5.w;
RCPR  R2.x, R2.x;
ADDR  R1.z(NE.y), -R0.y, R2.x;
MOVXC RC.y, R5;
RSQR  R2.x, R3.w;
MOVR  R4.w(EQ.z), R0.x;
MOVR  R6.w(EQ.y), R0.x;
RCPR  R2.x, R2.x;
ADDR  R4.w(NE), -R0.y, R2.x;
RSQR  R0.x, R3.y;
RCPR  R0.x, R0.x;
ADDR  R6.w(NE.x), -R0.y, R0.x;
MOVR  R2, c[16];
ADDR  R2, R2, c[8].x;
MADR  R2, -R2, R2, R1.w;
SLTR  R5, R1.y, R2;
ADDR  R3, R1.y, -R2;
MOVXC RC.x, R5;
MOVR  R0.x, c[31].z;
MOVR  R0.x(EQ), R0.z;
SGERC HC, R1.y, R2.yzxw;
RSQR  R2.x, R3.z;
RSQR  R3.x, R3.x;
RCPR  R3.x, R3.x;
ADDR  R0.x(NE.z), -R0.y, -R3;
MOVR  R2.w, c[31].z;
MOVXC RC.z, R5;
MOVR  R2.w(EQ.z), R0.z;
RCPR  R2.x, R2.x;
ADDR  R2.w(NE.y), -R0.y, -R2.x;
RSQR  R2.x, R3.w;
MOVR  R5.x, c[31].z;
MOVXC RC.z, R5.w;
MOVR  R5.x(EQ.z), R0.z;
RCPR  R2.x, R2.x;
ADDR  R5.x(NE.w), -R0.y, -R2;
RSQR  R2.x, R3.y;
MULR  R3.xyz, R6.zxyw, c[13].yzxw;
MADR  R3.xyz, R6.yzxw, c[13].zxyw, -R3;
MOVR  R3.w, c[31].z;
MOVXC RC.y, R5;
MOVR  R3.w(EQ.y), R0.z;
RCPR  R2.x, R2.x;
ADDR  R3.w(NE.x), -R0.y, -R2.x;
MULR  R2.xyz, R4.zxyw, c[13].yzxw;
MADR  R2.xyz, R4.yzxw, c[13].zxyw, -R2;
DP3R  R5.y, R2, R2;
DP3R  R2.y, R2, R3;
DP3R  R3.y, R3, R3;
MADR  R2.x, -c[8], c[8], R5.y;
MULR  R3.z, R3.y, R2.x;
MULR  R3.x, R2.y, R2.y;
ADDR  R2.x, R3, -R3.z;
SGTR  H1.y, R3.x, R3.z;
RSQR  R2.x, R2.x;
RCPR  R2.z, R2.x;
ADDR  R5.y, -R2, R2.z;
DP3R  R2.x, R4, c[13];
SLER  H1.x, R2, c[31];
MULX  H1.x, H1, c[11];
MULX  H1.x, H1, H1.y;
MOVXC RC.x, H1;
ADDR  R2.y, -R2, -R2.z;
MADR  R1.w, -c[9].x, c[9].x, R1;
RCPR  R3.y, R3.y;
MOVR  R3.x, c[31].y;
MOVR  R2.x, c[31].z;
MULR  R3.x(NE), R3.y, R5.y;
MULR  R2.x(NE), R2.y, R3.y;
MOVR  R2.y, R3.x;
MOVR  R16.xy, R2;
MADR  R2.xyz, R6, R2.x, R7;
ADDR  R2.xyz, R2, -c[4];
DP3R  R2.x, R2, c[13];
SGTR  H1.y, R2.x, c[31].x;
MULXC HC.x, H1, H1.y;
MOVR  R16.xy(NE.x), c[31].zyzw;
SLTRC HC.x, R1.y, R1.w;
MOVR  R16.zw(EQ.x), R0;
ADDR  R0.z, R1.y, -R1.w;
SGERC HC.x, R1.y, R1.w;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
ADDR  R0.w, -R0.y, -R0.z;
ADDR  R0.y, -R0, R0.z;
MAXR  R0.z, R0.w, c[31].x;
MAXR  R0.w, R0.y, c[31].x;
MOVR  R16.zw(NE.x), R0;
MOVR  R0.w, R5.x;
MOVR  R5.xyw, c[30].zwzx;
MOVR  R1.w, R4;
MOVR  R1.y, R6.w;
MADR  R4.xyz, R16.z, R6, R4;
MOVR  R0.y, R3.w;
MOVR  R0.z, R2.w;
DP4R  R2.x, R0, c[26];
DP4R  R2.y, R1, c[22];
ADDR  R2.z, R2.y, -R2.x;
DP4R  R2.y, R1, c[21];
SGER  H1.x, c[31], R2.y;
MADR  R2.x, H1, R2.z, R2;
MINR  R2.x, R16.w, R2;
MAXR  R8.w, R16.z, R2.x;
DP4R  R2.z, R0, c[27];
DP4R  R2.y, R1, c[23];
ADDR  R2.y, R2, -R2.z;
MADR  R2.y, H1.x, R2, R2.z;
MINR  R2.y, R16.w, R2;
MAXR  R9.w, R8, R2.y;
DP4R  R2.y, R0, c[28];
DP4R  R0.x, R0, c[29];
DP4R  R2.x, R1, c[24];
DP4R  R0.y, R1, c[25];
ADDR  R0.y, R0, -R0.x;
ADDR  R2.x, R2, -R2.y;
MADR  R2.x, H1, R2, R2.y;
MADR  R0.x, H1, R0.y, R0;
MINR  R2.x, R16.w, R2;
MAXR  R2.w, R9, R2.x;
ADDR  R3.w, -R9, R2;
MINR  R0.x, R16.w, R0;
MAXR  R0.w, R2, R0.x;
ADDR  R1.x, -R2.w, R0.w;
ADDR  R7.xy, -R2.w, R16.yxzw;
RCPR  R0.x, R1.x;
MULR  R4.w, R5.y, c[18].x;
MULR_SAT R0.y, R0.x, R7.x;
RCPR  R2.x, R3.w;
ADDR  R7.zw, -R9.w, R16.xyyx;
MULR_SAT R2.y, R2.x, R7.z;
MULR_SAT R2.x, -R7.y, R2;
MULR  R3.z, R2.x, R2.y;
DP3R  R2.x, R6, c[13];
MULR  R2.y, R2.x, c[19].x;
MULR  R2.y, R2, c[32];
MADR  R2.y, c[19].x, c[19].x, R2;
ADDR  R2.z, R2.y, c[32].x;
MULR  R2.x, R2, R2;
MOVR  R2.y, c[32].x;
POWR  R2.z, R2.z, c[32].z;
ADDR  R2.y, R2, c[19].x;
ADDR  R6.zw, R16.xywz, -R16.xyxy;
MADR  R2.x, R2, c[31].w, c[31].w;
RCPR  R2.z, R2.z;
MULR  R2.y, R2, R2;
MULR  R2.y, R2, R2.z;
MULR  R3.xy, R2, c[32].w;
MULR  R2.xyz, R5.x, c[17];
ADDR  R9.xyz, R2, R4.w;
MULR  R3.y, R4.w, R3;
RCPR  R5.x, R9.x;
RCPR  R5.z, R9.z;
RCPR  R5.y, R9.y;
MADR  R2.xyz, R2, R3.x, R3.y;
MULR  R10.xyz, R2, R5;
MADR  R2.xyz, R10, -R3.z, R10;
MULR  R3.xyz, -R9, |R3.w|;
POWR  R8.x, c[30].y, R3.x;
RCPR  R3.x, |R3.w|;
DP3R  R3.w, R4, R4;
RSQR  R3.w, R3.w;
RCPR  R3.w, R3.w;
ADDR  R4.x, R3.w, -c[8];
MOVR  R3.w, c[8].x;
ADDR  R3.w, -R3, c[9].x;
RCPR  R3.w, R3.w;
MULR  R4.w, R4.x, R3;
MOVR  R4.xyz, c[5];
DP3R  R3.w, R4, c[13];
MADR  R4.z, -R3.w, c[33].x, c[33].x;
TEX   R4.zw, R4.zwzw, texture[0], 2D;
MULR  R3.w, R4, c[18].x;
MADR  R4.xyz, R4.z, -c[17], -R3.w;
POWR  R8.y, c[30].y, R3.y;
POWR  R8.z, c[30].y, R3.z;
TEX   R3.w, c[33].x, texture[1], 2D;
MULR  R2.xyz, R5, R2;
SLTRC HC.x, c[20], R5.w;
POWR  R4.x, c[30].y, R4.x;
POWR  R4.z, c[30].y, R4.z;
POWR  R4.y, c[30].y, R4.y;
MULR  R4.xyz, R4, c[12];
MULR  R11.xyz, R4, R3.w;
ADDR  R12.xyz, R11, -R11;
MULR  R4.xyz, R12, R3.x;
MADR  R4.xyz, R9, R11, R4;
MADR  R3.xyz, -R8, R4, R4;
MULR  R15.xyz, R2, R3;
MULR  R2.xyz, -R9, |R1.x|;
ADDR  R3.xy, -R0.w, R16.yxzw;
MULR_SAT R0.x, -R3.y, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R10, -R0.x, R10;
RCPR  R1.x, |R1.x|;
MULR  R1.xyz, R12, R1.x;
MOVR  R4, c[29];
ADDR  R4, -R4, c[25];
MULR  R0.xyz, R5, R0;
ADDR  R0.w, R16, -R0;
MADR  R4, H1.x, R4, c[29];
POWR  R7.x, c[30].y, R2.x;
POWR  R7.y, c[30].y, R2.y;
POWR  R7.z, c[30].y, R2.z;
MULR  R2.xyz, -R9, |R0.w|;
MADR  R1.xyz, R9, R11, R1;
MADR  R1.xyz, -R7, R1, R1;
MULR  R14.xyz, R0, R1;
RCPR  R0.x, R0.w;
MULR_SAT R0.y, R0.x, R3.x;
MULR_SAT R0.x, R6.z, R0;
RCPR  R1.x, |R0.w|;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R10, R10;
MULR  R1.xyz, R12, R1.x;
MOVR  R3, c[28];
ADDR  R3, -R3, c[24];
MADR  R3, H1.x, R3, c[28];
POWR  R6.x, c[30].y, R2.x;
POWR  R6.y, c[30].y, R2.y;
POWR  R6.z, c[30].y, R2.z;
MADR  R1.xyz, R9, R11, R1;
MADR  R1.xyz, -R6, R1, R1;
MULR  R0.xyz, R0, R5;
MULR  R13.xyz, R0, R1;
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R1, H1.x, R0, c[26];
MOVR  R0, c[27];
ADDR  R0, -R0, c[23];
MADR  R2, H1.x, R0, c[27];
DP4R  R0.x, R1, c[32].x;
DP4R  R1.x, R1, R1;
DP4R  R1.y, R2, R2;
DP4R  R0.y, R2, c[32].x;
DP4R  R1.w, R4, R4;
DP4R  R1.z, R3, R3;
DP4R  R0.z, R3, c[32].x;
DP4R  R0.w, R4, c[32].x;
MADR  R0, R0, R1, -R1;
ADDR  R0, R0, c[32].x;
ADDR  R1.w, -R8, R9;
RCPR  R2.x, R1.w;
MADR  R1.xyz, R13, R0.w, R14;
MADR  R1.xyz, R1, R0.z, R15;
ADDR  R0.zw, -R8.w, R16.xyyx;
MULR_SAT R2.y, -R7.w, R2.x;
MULR_SAT R0.z, R2.x, R0;
MULR  R0.z, R2.y, R0;
MULR  R2.xyz, -R9, |R1.w|;
MADR  R3.xyz, R10, -R0.z, R10;
RCPR  R0.z, |R1.w|;
MULR  R4.xyz, R12, R0.z;
POWR  R2.x, c[30].y, R2.x;
POWR  R2.y, c[30].y, R2.y;
POWR  R2.z, c[30].y, R2.z;
MADR  R4.xyz, R9, R11, R4;
MADR  R4.xyz, -R2, R4, R4;
MULR  R3.xyz, R5, R3;
MULR  R3.xyz, R3, R4;
MADR  R1.xyz, R1, R0.y, R3;
ADDR  R0.y, R8.w, -R16.z;
MULR  R4.xyz, -R9, |R0.y|;
RCPR  R0.z, R0.y;
MULR_SAT R0.w, -R0, R0.z;
MULR_SAT R0.z, -R6.w, R0;
MULR  R0.z, R0.w, R0;
MADR  R3.xyz, R10, -R0.z, R10;
RCPR  R0.z, |R0.y|;
MULR  R10.xyz, R12, R0.z;
POWR  R4.x, c[30].y, R4.x;
POWR  R4.y, c[30].y, R4.y;
POWR  R4.z, c[30].y, R4.z;
MADR  R9.xyz, R9, R11, R10;
MADR  R9.xyz, -R4, R9, R9;
MULR  R3.xyz, R5, R3;
MULR  R3.xyz, R3, R9;
MADR  R0.xyz, R1, R0.x, R3;
MULR  R1.xyz, R4, R2;
MULR  R1.xyz, R1, R8;
MULR  R1.xyz, R1, R7;
MULR  R2.xyz, R1, R6;
TEX   R1.xyz, fragment.texcoord[0], texture[2], 2D;
MADR  H1.xyz, R1, R2, R0;
MOVH  H1.w, c[32].x;
MOVH  oCol, H1;
MOVH  oCol(EQ.x), H0;
MAXR  R0.x, H1, H1.y;
MAXR  R0.x, H1.z, R0;
MAXR  R0.x, R0, c[30];
RCPR  R0.y, R0.x;
MULR  H0.xyz, H1, R0.y;
MULR  H0.w, R0.x, c[20].x;
SGERC HC.x, c[20], R5.w;
MOVH  oCol(NE.x), H0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 4 [_PlanetCenterKm]
Vector 5 [_PlanetNormal]
Vector 6 [_PlanetTangent]
Vector 7 [_PlanetBiTangent]
Float 8 [_PlanetRadiusKm]
Float 9 [_PlanetAtmosphereRadiusKm]
Float 10 [_WorldUnit2Kilometer]
Float 11 [_bComputePlanetShadow]
Vector 12 [_SunColor]
Vector 13 [_SunDirection]
Vector 14 [_EnvironmentAngles]
SetTexture 1 [_TexShadowEnvMapSun] 2D
Vector 15 [_ShadowAltitudesMinKm]
Vector 16 [_ShadowAltitudesMaxKm]
Vector 17 [_Sigma_Rayleigh]
Float 18 [_Sigma_Mie]
Float 19 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexBackground] 2D
Float 20 [_LuminanceScale]
Vector 21 [_CaseSwizzle]
Vector 22 [_SwizzleExitUp0]
Vector 23 [_SwizzleExitUp1]
Vector 24 [_SwizzleExitUp2]
Vector 25 [_SwizzleExitUp3]
Vector 26 [_SwizzleEnterDown0]
Vector 27 [_SwizzleEnterDown1]
Vector 28 [_SwizzleEnterDown2]
Vector 29 [_SwizzleEnterDown3]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c30, -0.00010000, 0.10000000, 0.25000000, 0.00000000
def c31, 0.15915491, 0.50000000, 6.28318501, -3.14159298
def c32, -1000000.00000000, 1000000.00000000, 2.71828198, 0.75000000
def c33, 0.00000000, 1.00000000, 2.00000000, 1.50000000
def c34, 0.07957747, 0.50000000, 0.00000000, -1.00000000
def c35, 0.00010000, 0, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c14.zwzw, c14
mad r0.z, r0.x, c31.x, c31.y
mad r0.y, r0, c31.x, c31
frc r0.x, r0.y
frc r0.y, r0.z
mad r0.x, r0, c31.z, c31.w
sincos r2.xy, r0.x
mad r3.x, r0.y, c31.z, c31.w
sincos r0.xy, r3.x
mul r0.y, r2, r0
mul r3.xyz, r2.x, c5
mad r3.xyz, r0.y, c6, r3
mul r0.x, r2.y, r0
mad r5.xyz, r0.x, c7, r3
mov r0.y, c2.w
mov r0.x, c0.w
mul r6.xz, r0.xyyw, c10.x
mov r6.y, c30.w
add r7.xyz, r6, -c4
mov r0.x, c8
mov r0.y, c8.x
dp3 r3.x, r7, r5
dp3 r3.y, r7, r7
add r0.y, c15, r0
mad r0.z, -r0.y, r0.y, r3.y
mad r0.w, r3.x, r3.x, -r0.z
rsq r2.x, r0.w
rcp r2.y, r2.x
add r0.x, c15, r0
mad r0.x, -r0, r0, r3.y
mad r0.x, r3, r3, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r3.x, r0.y
cmp_pp r0.y, r0.x, c33, c33.x
cmp r0.x, r0, r1, c32
cmp r2.x, -r0.y, r0, r0.z
cmp r0.z, r0.w, r1.x, c32.x
cmp_pp r0.y, r0.w, c33, c33.x
add r2.y, -r3.x, r2
cmp r2.y, -r0, r0.z, r2
mov r0.x, c8
add r0.y, c15.z, r0.x
mov r0.x, c8
add r0.z, c15.w, r0.x
mad r0.y, -r0, r0, r3
mad r0.x, r3, r3, -r0.y
mad r0.z, -r0, r0, r3.y
mad r0.w, r3.x, r3.x, -r0.z
rsq r2.z, r0.w
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r3.x, r0.y
cmp_pp r0.y, r0.x, c33, c33.x
cmp r0.x, r0, r1, c32
rcp r2.w, r2.z
cmp r2.z, -r0.y, r0.x, r0
add r0.z, -r3.x, r2.w
cmp r0.y, r0.w, r1.x, c32.x
cmp_pp r0.x, r0.w, c33.y, c33
cmp r2.w, -r0.x, r0.y, r0.z
mov r0.x, c8
add r0.y, c16.x, r0.x
mov r0.x, c8
add r0.z, c16.y, r0.x
mad r0.y, -r0, r0, r3
mad r0.x, r3, r3, -r0.y
mad r0.z, -r0, r0, r3.y
mad r0.w, r3.x, r3.x, -r0.z
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r3.x, -r0.y
cmp_pp r0.y, r0.x, c33, c33.x
cmp r0.x, r0, r1, c32.y
cmp r0.x, -r0.y, r0, r0.z
rsq r3.w, r0.w
cmp_pp r0.y, r0.w, c33, c33.x
rcp r3.w, r3.w
dp4 r3.z, r2, c24
cmp r0.w, r0, r1.x, c32.y
add r3.w, -r3.x, -r3
cmp r0.y, -r0, r0.w, r3.w
mov r0.z, c8.x
add r0.w, c16, r0.z
mad r0.w, -r0, r0, r3.y
mad r4.x, r3, r3, -r0.w
rsq r0.w, r4.x
rcp r3.w, r0.w
mov r0.z, c8.x
add r0.z, c16, r0
mad r0.z, -r0, r0, r3.y
mad r0.z, r3.x, r3.x, -r0
add r4.y, -r3.x, -r3.w
rsq r0.w, r0.z
rcp r3.w, r0.w
cmp_pp r0.w, r4.x, c33.y, c33.x
cmp r4.x, r4, r1, c32.y
cmp r0.w, -r0, r4.x, r4.y
add r4.x, -r3, -r3.w
cmp_pp r3.w, r0.z, c33.y, c33.x
cmp r0.z, r0, r1.x, c32.y
cmp r0.z, -r3.w, r0, r4.x
dp4 r4.x, r0, c28
dp4 r3.w, r2, c21
cmp r9.w, -r3, c33.y, c33.x
add r4.y, r3.z, -r4.x
mad r3.y, -c9.x, c9.x, r3
mad r3.z, r3.x, r3.x, -r3.y
mad r4.z, r9.w, r4.y, r4.x
rsq r3.y, r3.z
rcp r3.y, r3.y
add r3.w, -r3.x, -r3.y
add r3.y, -r3.x, r3
max r3.x, r3.w, c30.w
cmp r4.xy, r3.z, r1, c30.w
cmp_pp r3.w, r3.z, c33.y, c33.x
max r3.y, r3, c30.w
cmp r17.zw, -r3.w, r4.xyxy, r3.xyxy
dp4 r3.y, r0, c26
dp4 r3.w, r0, c27
dp4 r3.x, r2, c22
dp4 r3.z, r2, c23
dp4 r2.x, r2, c25
dp4 r0.x, r0, c29
dp3 r2.y, r5, c13
add r0.y, r2.x, -r0.x
add r3.x, r3, -r3.y
mad r3.x, r9.w, r3, r3.y
add r3.z, r3, -r3.w
mad r3.y, r9.w, r3.z, r3.w
min r3.x, r17.w, r3
mov r3.w, c18.x
mad r0.x, r9.w, r0.y, r0
mul r0.z, r2.y, c19.x
mul r0.y, r0.z, c33.z
mad r0.y, c19.x, c19.x, r0
max r6.w, r17.z, r3.x
min r3.y, r17.w, r3
max r7.w, r6, r3.y
min r4.x, r17.w, r4.z
max r4.w, r7, r4.x
add r10.w, -r7, r4
mov r3.xyz, c17
mul r5.w, c30.z, r3
mul r4.xyz, c30.y, r3
add r10.xyz, r4, r5.w
abs r8.x, r10.w
mul r9.xyz, -r10, r8.x
pow r3, c32.z, r9.x
mad r8.xyz, r17.z, r5, r7
dp3 r3.y, r8, r8
mov r9.x, r3
rsq r8.x, r3.y
pow r3, c32.z, r9.y
rcp r3.z, r8.x
mov r3.x, c9
add r3.x, -c8, r3
mov r8.xyz, c13
rcp r3.w, r3.x
dp3 r3.x, c5, r8
add r3.x, -r3, c33.y
add r3.z, r3, -c8.x
mul r8.y, r3.z, r3.w
mul r8.x, r3, c34.y
mov r8.z, c30.w
texldl r3.zw, r8.xyzz, s0
pow r8, c32.z, r9.z
mul r3.x, r3.w, c18
mad r11.xyz, r3.z, -c17, -r3.x
mov r9.y, r3
pow r3, c32.z, r11.x
mov r9.z, r8
pow r8, c32.z, r11.y
mov r11.x, r3
pow r3, c32.z, r11.z
mov r11.z, r3
mul r3.xyz, r7.zxyw, c13.yzxw
mad r3.xyz, r7.yzxw, c13.zxyw, -r3
dp3 r3.w, r3, r3
mov r11.y, r8
mul r8.xyz, r11, c12
mul r11.xyz, r5.zxyw, c13.yzxw
mad r11.xyz, r5.yzxw, c13.zxyw, -r11
dp3 r8.w, r3, r11
dp3 r11.w, r11, r11
mad r3.w, -c8.x, c8.x, r3
mul r3.w, r11, r3
mad r3.y, r8.w, r8.w, -r3.w
rsq r3.x, r3.y
texldl r3.w, c34.yyzz, s1
mul r12.xyz, r8, r3.w
rcp r3.w, r3.x
dp3 r3.x, r7, c13
cmp r3.x, -r3, c33.y, c33
mul r13.xyz, r10, r12
rcp r8.x, r11.w
add r3.z, -r8.w, -r3.w
mul r3.z, r3, r8.x
add r7.y, -r8.w, r3.w
add r2.x, r0.y, c33.y
cmp r3.y, -r3, c33.x, c33
mul_pp r3.x, r3, c11
mul_pp r7.z, r3.x, r3.y
cmp r7.x, -r7.z, c32.y, r3.z
mad r6.xyz, r5, r7.x, r6
add r6.xyz, r6, -c4
dp3 r3.w, r6, c13
mul r6.x, r8, r7.y
cmp r7.y, -r7.z, c32.x, r6.x
mul r3.xyz, r9, r13
cmp r3.w, -r3, c33.x, c33.y
mul_pp r3.w, r7.z, r3
cmp r17.xy, -r3.w, r7, c32.yxzw
rcp r6.z, r10.z
rcp r6.x, r10.w
add r3.w, r4, -r17.x
add r6.y, -r7.w, r17
mul_sat r3.w, r3, r6.x
mul_sat r6.y, r6.x, r6
mad r7.y, -r3.w, r6, c33
min r0.x, r17.w, r0
max r3.w, r4, r0.x
pow r0, r2.x, c33.w
mad r0.z, r2.y, r2.y, c33.y
rcp r6.x, r10.x
rcp r6.y, r10.y
add r7.x, -r4.w, r3.w
mov r0.w, r0.x
mov r0.y, c19.x
add r0.x, c33.y, r0.y
mad r3.xyz, r10, r12, -r3
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c32.w
mul r0.xy, r0, c34.x
abs r0.z, r7.x
mul r5.xyz, -r10, r0.z
mul r0.y, r5.w, r0
mad r0.xyz, r4, r0.x, r0.y
mul r11.xyz, r0, r6
pow r0, c32.z, r5.x
mul r2.xyz, r11, r7.y
mul r2.xyz, r6, r2
mul r16.xyz, r2, r3
pow r2, c32.z, r5.z
mov r8.x, r0
pow r0, c32.z, r5.y
add r2.y, -r4.w, r17
rcp r2.x, r7.x
add r0.w, r3, -r17.x
mov r5, c25
mov r4, c24
add r5, -c29, r5
add r4, -c28, r4
mov r8.z, r2
mov r8.y, r0
mul_sat r0.w, r0, r2.x
mul_sat r2.y, r2.x, r2
mad r0.w, -r0, r2.y, c33.y
mul r0.xyz, r8, r13
mad r2.xyz, r10, r12, -r0
mul r0.xyz, r11, r0.w
add r0.w, r17, -r3
mul r0.xyz, r6, r0
mul r15.xyz, r0, r2
abs r2.w, r0
mul r3.xyz, -r10, r2.w
rcp r2.x, r0.w
add r0.x, -r3.w, r17.y
mul_sat r2.y, r2.x, r0.x
pow r0, c32.z, r3.x
add r0.y, r17.w, -r17.x
mul_sat r0.y, r0, r2.x
mad r3.x, -r0.y, r2.y, c33.y
pow r2, c32.z, r3.z
mov r7.x, r0
pow r0, c32.z, r3.y
mov r7.y, r0
mov r7.z, r2
mul r0.xyz, r3.x, r11
mul r2.xyz, r7, r13
mad r5, r9.w, r5, c29
mad r4, r9.w, r4, c28
mad r2.xyz, r10, r12, -r2
mul r0.xyz, r0, r6
mul r14.xyz, r0, r2
mov r2, c22
add r2, -c26, r2
mov r0, c23
add r0, -c27, r0
mad r3, r9.w, r2, c26
mad r2, r9.w, r0, c27
dp4 r0.x, r3, c33.y
dp4 r3.x, r3, r3
dp4 r3.y, r2, r2
dp4 r0.y, r2, c33.y
dp4 r3.z, r4, r4
dp4 r3.w, r5, r5
dp4 r0.w, r5, c33.y
dp4 r0.z, r4, c33.y
add r0, r0, c34.w
mad r0, r3, r0, c33.y
mad r2.xyz, r14, r0.w, r15
mad r4.xyz, r2, r0.z, r16
add r0.z, -r6.w, r7.w
rcp r2.x, r0.z
abs r0.z, r0
mul r14.xyz, -r10, r0.z
pow r3, c32.z, r14.x
add r0.w, r7, -r17.x
add r2.y, -r6.w, r17
mul_sat r0.w, r0, r2.x
mul_sat r2.y, r2.x, r2
mad r0.w, -r0, r2.y, c33.y
mul r2.xyz, r11, r0.w
mul r5.xyz, r6, r2
pow r2, c32.z, r14.y
mov r14.y, r2
pow r2, c32.z, r14.z
add r0.z, r6.w, -r17
abs r0.w, r0.z
mul r15.xyz, -r10, r0.w
mov r14.z, r2
mov r14.x, r3
pow r2, c32.z, r15.x
mov r15.x, r2
pow r2, c32.z, r15.z
mul r3.xyz, r14, r13
mad r3.xyz, r10, r12, -r3
mul r5.xyz, r5, r3
pow r3, c32.z, r15.y
mov r15.y, r3
mad r3.xyz, r4, r0.y, r5
mov r15.z, r2
mul r2.xyz, r15, r14
mul r2.xyz, r2, r9
mul r4.xyz, r15, r13
mul r2.xyz, r2, r8
rcp r0.z, r0.z
add r0.y, r6.w, -r17.x
add r0.w, -r17.z, r17.y
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r0.y, -r0, r0.w, c33
mul r5.xyz, r11, r0.y
mad r4.xyz, r10, r12, -r4
mul r5.xyz, r6, r5
mul r4.xyz, r5, r4
mad r3.xyz, r3, r0.x, r4
texldl r0.xyz, v0, s2
mul r2.xyz, r2, r7
mad r2.xyz, r0, r2, r3
max r0.x, r2, r2.y
max r0.x, r2.z, r0
max r0.w, r0.x, c35.x
rcp r0.x, r0.w
mov r3.x, c20
mul r0.xyz, r2, r0.x
add r3.x, c30, r3
mov r2.w, c33.y
cmp_pp r2, r3.x, r1, r2
mul r0.w, r0, c20.x
cmp_pp r1.x, r3, c33.y, c33
cmp_pp oC0, -r1.x, r2, r0

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
Matrix 0 [_Camera2World]
Vector 4 [_PlanetCenterKm]
Vector 5 [_PlanetNormal]
Vector 6 [_PlanetTangent]
Vector 7 [_PlanetBiTangent]
Float 8 [_PlanetRadiusKm]
Float 9 [_PlanetAtmosphereRadiusKm]
Float 10 [_WorldUnit2Kilometer]
Float 11 [_bComputePlanetShadow]
Vector 12 [_SunColor]
Vector 13 [_SunDirection]
Vector 14 [_EnvironmentAngles]
SetTexture 1 [_TexShadowEnvMapSun] 2D
Vector 15 [_ShadowAltitudesMinKm]
Vector 16 [_ShadowAltitudesMaxKm]
Vector 17 [_Sigma_Rayleigh]
Float 18 [_Sigma_Mie]
Float 19 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexCloudLayer0] 2D
SetTexture 3 [_TexCloudLayer1] 2D
SetTexture 4 [_TexCloudLayer2] 2D
SetTexture 5 [_TexCloudLayer3] 2D
SetTexture 6 [_TexBackground] 2D
Float 20 [_LuminanceScale]
Vector 21 [_CaseSwizzle]
Vector 22 [_SwizzleExitUp0]
Vector 23 [_SwizzleExitUp1]
Vector 24 [_SwizzleExitUp2]
Vector 25 [_SwizzleExitUp3]
Vector 26 [_SwizzleEnterDown0]
Vector 27 [_SwizzleEnterDown1]
Vector 28 [_SwizzleEnterDown2]
Vector 29 [_SwizzleEnterDown3]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[34] = { program.local[0..29],
		{ 9.9999997e-005, 2.718282, 0.1, 0.25 },
		{ 0, -1000000, 1000000, 0.75 },
		{ 1, 2, 1.5, 0.079577468 },
		{ 0.5 } };
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
TEMP R19;
TEMP R20;
TEMP R21;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MADR  R2.xy, fragment.texcoord[0], c[14].zwzw, c[14];
MOVR  R8, c[29];
MOVR  R21.zw, c[31].x;
MOVR  R10.xyw, c[30].zwzx;
MOVR  R4.w, c[31].y;
MOVR  R5.w, c[31].y;
SINR  R1.y, R2.x;
SINR  R0.y, R2.y;
COSR  R1.x, R2.y;
MULR  R2.y, R0, R1;
COSR  R1.w, R2.x;
MULR  R1.xyz, R1.x, c[5];
MADR  R1.xyz, R2.y, c[6], R1;
MULR  R0.y, R0, R1.w;
MADR  R5.xyz, R0.y, c[7], R1;
MOVR  R2, c[15];
MOVR  R7.y, c[31].x;
MOVR  R1.y, c[2].w;
MOVR  R1.x, c[0].w;
MULR  R7.xz, R1.xyyw, c[10].x;
ADDR  R4.xyz, R7, -c[4];
DP3R  R0.y, R4, R5;
MULR  R1.y, R0, R0;
MOVR  R1.x, c[31].y;
DP3R  R1.w, R4, R4;
ADDR  R2, R2, c[8].x;
MADR  R2, -R2, R2, R1.w;
ADDR  R3, R1.y, -R2;
SLTR  R6, R1.y, R2;
MOVXC RC.x, R6;
MOVR  R1.x(EQ), R0;
SGERC HC, R1.y, R2.yzxw;
RSQR  R1.z, R3.x;
RCPR  R1.z, R1.z;
ADDR  R1.x(NE.z), -R0.y, R1.z;
RSQR  R2.x, R3.z;
MOVR  R1.z, c[31].y;
MOVXC RC.z, R6;
MOVR  R1.z(EQ), R0.x;
MOVXC RC.z, R6.w;
RCPR  R2.x, R2.x;
ADDR  R1.z(NE.y), -R0.y, R2.x;
MOVXC RC.y, R6;
RSQR  R2.x, R3.w;
MOVR  R4.w(EQ.z), R0.x;
MOVR  R5.w(EQ.y), R0.x;
RCPR  R2.x, R2.x;
ADDR  R4.w(NE), -R0.y, R2.x;
RSQR  R0.x, R3.y;
RCPR  R0.x, R0.x;
ADDR  R5.w(NE.x), -R0.y, R0.x;
MOVR  R2, c[16];
ADDR  R2, R2, c[8].x;
MADR  R2, -R2, R2, R1.w;
ADDR  R3, R1.y, -R2;
SLTR  R6, R1.y, R2;
MOVXC RC.x, R6;
MOVR  R0.x, c[31].z;
MOVR  R0.x(EQ), R0.z;
SGERC HC, R1.y, R2.yzxw;
RSQR  R2.x, R3.z;
RSQR  R3.x, R3.x;
RCPR  R3.x, R3.x;
ADDR  R0.x(NE.z), -R0.y, -R3;
MOVR  R2.w, c[31].z;
MOVXC RC.z, R6;
MOVR  R2.w(EQ.z), R0.z;
RCPR  R2.x, R2.x;
ADDR  R2.w(NE.y), -R0.y, -R2.x;
RSQR  R2.x, R3.w;
MOVR  R6.x, c[31].z;
MOVXC RC.z, R6.w;
MOVR  R6.x(EQ.z), R0.z;
RCPR  R2.x, R2.x;
ADDR  R6.x(NE.w), -R0.y, -R2;
RSQR  R2.x, R3.y;
MULR  R3.xyz, R5.zxyw, c[13].yzxw;
MADR  R3.xyz, R5.yzxw, c[13].zxyw, -R3;
MOVR  R3.w, c[31].z;
MOVXC RC.y, R6;
MOVR  R3.w(EQ.y), R0.z;
RCPR  R2.x, R2.x;
ADDR  R3.w(NE.x), -R0.y, -R2.x;
MULR  R2.xyz, R4.zxyw, c[13].yzxw;
MADR  R2.xyz, R4.yzxw, c[13].zxyw, -R2;
DP3R  R6.y, R2, R2;
DP3R  R2.y, R2, R3;
DP3R  R3.y, R3, R3;
MADR  R2.x, -c[8], c[8], R6.y;
MULR  R3.z, R3.y, R2.x;
MULR  R3.x, R2.y, R2.y;
ADDR  R2.x, R3, -R3.z;
SGTR  H1.y, R3.x, R3.z;
RSQR  R2.x, R2.x;
RCPR  R2.z, R2.x;
ADDR  R6.y, -R2, R2.z;
DP3R  R2.x, R4, c[13];
SLER  H1.x, R2, c[31];
MULX  H1.x, H1, c[11];
MULX  H1.x, H1, H1.y;
MOVXC RC.x, H1;
ADDR  R2.y, -R2, -R2.z;
MADR  R1.w, -c[9].x, c[9].x, R1;
RCPR  R3.y, R3.y;
MOVR  R3.x, c[31].y;
MOVR  R2.x, c[31].z;
MULR  R3.x(NE), R3.y, R6.y;
MULR  R2.x(NE), R2.y, R3.y;
MOVR  R2.y, R3.x;
MOVR  R21.xy, R2;
MADR  R2.xyz, R5, R2.x, R7;
ADDR  R2.xyz, R2, -c[4];
DP3R  R2.x, R2, c[13];
SGTR  H1.y, R2.x, c[31].x;
MULXC HC.x, H1, H1.y;
MOVR  R21.xy(NE.x), c[31].zyzw;
SLTRC HC.x, R1.y, R1.w;
MOVR  R21.zw(EQ.x), R0;
ADDR  R0.z, R1.y, -R1.w;
SGERC HC.x, R1.y, R1.w;
MOVR  R1.w, R4;
MOVR  R1.y, R5.w;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
ADDR  R0.w, -R0.y, -R0.z;
ADDR  R0.y, -R0, R0.z;
MAXR  R0.z, R0.w, c[31].x;
MAXR  R0.w, R0.y, c[31].x;
MOVR  R21.zw(NE.x), R0;
MOVR  R7, c[28];
MOVR  R0.y, R3.w;
MOVR  R0.w, R6.x;
MOVR  R0.z, R2.w;
DP4R  R2.x, R0, c[26];
DP4R  R2.y, R1, c[22];
ADDR  R2.z, R2.y, -R2.x;
DP4R  R2.y, R1, c[21];
SGER  H1.x, c[31], R2.y;
MADR  R2.x, H1, R2.z, R2;
MINR  R2.x, R21.w, R2;
MAXR  R12.w, R21.z, R2.x;
ADDR  R7, -R7, c[24];
ADDR  R8, -R8, c[25];
DP4R  R2.z, R0, c[27];
DP4R  R2.y, R1, c[23];
ADDR  R2.y, R2, -R2.z;
MADR  R2.y, H1.x, R2, R2.z;
MINR  R2.y, R21.w, R2;
MAXR  R14.w, R12, R2.y;
DP4R  R2.y, R0, c[28];
DP4R  R0.x, R0, c[29];
DP4R  R2.x, R1, c[24];
DP4R  R0.y, R1, c[25];
ADDR  R0.y, R0, -R0.x;
ADDR  R2.x, R2, -R2.y;
MADR  R2.x, H1, R2, R2.y;
MADR  R0.x, H1, R0.y, R0;
MINR  R2.x, R21.w, R2;
MAXR  R2.w, R14, R2.x;
ADDR  R3.w, -R14, R2;
MINR  R0.x, R21.w, R0;
MAXR  R0.w, R2, R0.x;
ADDR  R1.x, -R2.w, R0.w;
MADR  R4.xyz, R21.z, R5, R4;
ADDR  R6.xy, -R2.w, R21.yxzw;
RCPR  R0.x, R1.x;
MULR  R4.w, R10.y, c[18].x;
MULR_SAT R0.y, R0.x, R6.x;
MADR  R7, H1.x, R7, c[28];
MADR  R8, H1.x, R8, c[29];
RCPR  R2.x, R3.w;
ADDR  R13.zw, -R14.w, R21.xyyx;
MULR_SAT R2.y, R2.x, R13.z;
MULR_SAT R2.x, -R6.y, R2;
MULR  R3.z, R2.x, R2.y;
DP3R  R2.x, R5, c[13];
MULR  R2.y, R2.x, c[19].x;
MULR  R2.y, R2, c[32];
MADR  R2.y, c[19].x, c[19].x, R2;
ADDR  R2.z, R2.y, c[32].x;
MULR  R2.x, R2, R2;
MOVR  R2.y, c[32].x;
POWR  R2.z, R2.z, c[32].z;
ADDR  R2.y, R2, c[19].x;
ADDR  R11.zw, R21.xywz, -R21.xyxy;
MADR  R2.x, R2, c[31].w, c[31].w;
RCPR  R2.z, R2.z;
MULR  R2.y, R2, R2;
MULR  R2.y, R2, R2.z;
MULR  R3.xy, R2, c[32].w;
MULR  R2.xyz, R10.x, c[17];
ADDR  R14.xyz, R2, R4.w;
MULR  R3.y, R4.w, R3;
RCPR  R10.x, R14.x;
RCPR  R10.z, R14.z;
RCPR  R10.y, R14.y;
MADR  R2.xyz, R2, R3.x, R3.y;
MULR  R15.xyz, R2, R10;
MADR  R2.xyz, R15, -R3.z, R15;
MULR  R3.xyz, -R14, |R3.w|;
POWR  R13.x, c[30].y, R3.x;
RCPR  R3.x, |R3.w|;
DP3R  R3.w, R4, R4;
RSQR  R3.w, R3.w;
RCPR  R3.w, R3.w;
ADDR  R4.x, R3.w, -c[8];
MOVR  R3.w, c[8].x;
ADDR  R3.w, -R3, c[9].x;
RCPR  R3.w, R3.w;
MULR  R4.w, R4.x, R3;
MOVR  R4.xyz, c[5];
DP3R  R3.w, R4, c[13];
MADR  R4.z, -R3.w, c[33].x, c[33].x;
TEX   R4.zw, R4.zwzw, texture[0], 2D;
MULR  R3.w, R4, c[18].x;
MADR  R4.xyz, R4.z, -c[17], -R3.w;
POWR  R13.y, c[30].y, R3.y;
POWR  R13.z, c[30].y, R3.z;
TEX   R3.w, c[33].x, texture[1], 2D;
MULR  R2.xyz, R10, R2;
SLTRC HC.x, c[20], R10.w;
POWR  R4.x, c[30].y, R4.x;
POWR  R4.z, c[30].y, R4.z;
POWR  R4.y, c[30].y, R4.y;
MULR  R4.xyz, R4, c[12];
MULR  R16.xyz, R4, R3.w;
ADDR  R17.xyz, R16, -R16;
MULR  R4.xyz, R17, R3.x;
MADR  R4.xyz, R14, R16, R4;
MADR  R3.xyz, -R13, R4, R4;
MULR  R20.xyz, R2, R3;
MULR  R2.xyz, -R14, |R1.x|;
ADDR  R3.xy, -R0.w, R21.yxzw;
MULR_SAT R0.x, -R3.y, R0;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, R15, -R0.x, R15;
RCPR  R1.x, |R1.x|;
MULR  R1.xyz, R17, R1.x;
MULR  R0.xyz, R10, R0;
ADDR  R0.w, R21, -R0;
POWR  R12.x, c[30].y, R2.x;
POWR  R12.y, c[30].y, R2.y;
POWR  R12.z, c[30].y, R2.z;
MULR  R2.xyz, -R14, |R0.w|;
MADR  R1.xyz, R14, R16, R1;
MADR  R1.xyz, -R12, R1, R1;
MULR  R19.xyz, R0, R1;
RCPR  R0.x, R0.w;
MULR_SAT R0.y, R0.x, R3.x;
MULR_SAT R0.x, R11.z, R0;
TEX   R3, fragment.texcoord[0], texture[5], 2D;
RCPR  R1.x, |R0.w|;
MULR  R0.x, R0, R0.y;
MADR  R0.xyz, -R0.x, R15, R15;
MULR  R1.xyz, R17, R1.x;
MOVR  R9.w, R3;
POWR  R11.x, c[30].y, R2.x;
POWR  R11.y, c[30].y, R2.y;
POWR  R11.z, c[30].y, R2.z;
TEX   R2, fragment.texcoord[0], texture[4], 2D;
MADR  R1.xyz, R14, R16, R1;
MOVR  R9.z, R2.w;
MADR  R1.xyz, -R11, R1, R1;
MULR  R0.xyz, R0, R10;
MULR  R18.xyz, R0, R1;
TEX   R1, fragment.texcoord[0], texture[3], 2D;
MADR  R2.xyz, R2.w, R3, R2;
MOVR  R0, c[27];
ADDR  R0, -R0, c[23];
MADR  R6, H1.x, R0, c[27];
MOVR  R0, c[26];
ADDR  R0, -R0, c[22];
MADR  R5, H1.x, R0, c[26];
TEX   R0, fragment.texcoord[0], texture[2], 2D;
MADR  R1.xyz, R1.w, R2, R1;
MADR  R1.xyz, R0.w, R1, R0;
MOVR  R9.y, R1.w;
MOVR  R9.x, R0.w;
DP4R  R4.x, R9, R5;
DP4R  R5.x, R5, R5;
MULR  R3.x, R0.w, R1.w;
MULR  R1.w, R3.x, R2;
DP4R  R5.y, R6, R6;
DP4R  R4.y, R9, R6;
DP4R  R4.z, R9, R7;
DP4R  R4.w, R9, R8;
DP4R  R5.w, R8, R8;
DP4R  R5.z, R7, R7;
MADR  R4, R4, R5, -R5;
ADDR  R4, R4, c[32].x;
ADDR  R5.w, -R12, R14;
RCPR  R6.x, R5.w;
MADR  R5.xyz, R18, R4.w, R19;
MADR  R5.xyz, R5, R4.z, R20;
ADDR  R4.zw, -R12.w, R21.xyyx;
MULR_SAT R6.y, -R13.w, R6.x;
MULR_SAT R4.z, R6.x, R4;
MULR  R4.z, R6.y, R4;
MULR  R6.xyz, -R14, |R5.w|;
MADR  R7.xyz, R15, -R4.z, R15;
RCPR  R4.z, |R5.w|;
MULR  R8.xyz, R17, R4.z;
POWR  R6.x, c[30].y, R6.x;
POWR  R6.y, c[30].y, R6.y;
POWR  R6.z, c[30].y, R6.z;
MADR  R8.xyz, R14, R16, R8;
MADR  R8.xyz, -R6, R8, R8;
MULR  R7.xyz, R10, R7;
MULR  R7.xyz, R7, R8;
MADR  R5.xyz, R5, R4.y, R7;
ADDR  R4.y, R12.w, -R21.z;
MULR  R8.xyz, -R14, |R4.y|;
RCPR  R4.z, R4.y;
MULR_SAT R4.w, -R4, R4.z;
MULR_SAT R4.z, -R11.w, R4;
MULR  R4.z, R4.w, R4;
MADR  R7.xyz, R15, -R4.z, R15;
RCPR  R4.z, |R4.y|;
MULR  R9.xyz, R17, R4.z;
POWR  R8.x, c[30].y, R8.x;
POWR  R8.y, c[30].y, R8.y;
POWR  R8.z, c[30].y, R8.z;
MADR  R9.xyz, R14, R16, R9;
MADR  R9.xyz, -R8, R9, R9;
MULR  R7.xyz, R10, R7;
MULR  R7.xyz, R7, R9;
MADR  R4.xyz, R5, R4.x, R7;
MULR  R5.xyz, R8, R6;
MULR  R5.xyz, R5, R13;
MULR  R5.xyz, R5, R12;
MULR  R5.xyz, R5, R11;
MULR  R0.w, R1, R3;
TEX   R0.xyz, fragment.texcoord[0], texture[6], 2D;
MULR  R0.xyz, R0, R0.w;
MADR  R0.xyz, R0, R5, R1;
ADDR  H1.xyz, R0, R4;
MOVH  H1.w, c[32].x;
MOVH  oCol, H1;
MOVH  oCol(EQ.x), H0;
MAXR  R0.x, H1, H1.y;
MAXR  R0.x, H1.z, R0;
MAXR  R0.x, R0, c[30];
RCPR  R0.y, R0.x;
MULR  H0.xyz, H1, R0.y;
MULR  H0.w, R0.x, c[20].x;
SGERC HC.x, c[20], R10.w;
MOVH  oCol(NE.x), H0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 4 [_PlanetCenterKm]
Vector 5 [_PlanetNormal]
Vector 6 [_PlanetTangent]
Vector 7 [_PlanetBiTangent]
Float 8 [_PlanetRadiusKm]
Float 9 [_PlanetAtmosphereRadiusKm]
Float 10 [_WorldUnit2Kilometer]
Float 11 [_bComputePlanetShadow]
Vector 12 [_SunColor]
Vector 13 [_SunDirection]
Vector 14 [_EnvironmentAngles]
SetTexture 1 [_TexShadowEnvMapSun] 2D
Vector 15 [_ShadowAltitudesMinKm]
Vector 16 [_ShadowAltitudesMaxKm]
Vector 17 [_Sigma_Rayleigh]
Float 18 [_Sigma_Mie]
Float 19 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexCloudLayer0] 2D
SetTexture 3 [_TexCloudLayer1] 2D
SetTexture 4 [_TexCloudLayer2] 2D
SetTexture 5 [_TexCloudLayer3] 2D
SetTexture 6 [_TexBackground] 2D
Float 20 [_LuminanceScale]
Vector 21 [_CaseSwizzle]
Vector 22 [_SwizzleExitUp0]
Vector 23 [_SwizzleExitUp1]
Vector 24 [_SwizzleExitUp2]
Vector 25 [_SwizzleExitUp3]
Vector 26 [_SwizzleEnterDown0]
Vector 27 [_SwizzleEnterDown1]
Vector 28 [_SwizzleEnterDown2]
Vector 29 [_SwizzleEnterDown3]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c30, -0.00010000, 0.10000000, 0.25000000, 0.00000000
def c31, 0.15915491, 0.50000000, 6.28318501, -3.14159298
def c32, -1000000.00000000, 1000000.00000000, 2.71828198, 0.75000000
def c33, 0.00000000, 1.00000000, 2.00000000, 1.50000000
def c34, 0.07957747, 0.50000000, 0.00000000, -1.00000000
def c35, 0.00010000, 0, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c14.zwzw, c14
mad r0.z, r0.x, c31.x, c31.y
mad r0.y, r0, c31.x, c31
frc r0.x, r0.y
frc r0.y, r0.z
mad r0.x, r0, c31.z, c31.w
sincos r1.xy, r0.x
mad r2.z, r0.y, c31, c31.w
sincos r0.xy, r2.z
mul r0.y, r1, r0
mul r3.xyz, r1.x, c5
mad r3.xyz, r0.y, c6, r3
mul r0.x, r1.y, r0
mad r6.xyz, r0.x, c7, r3
mov r8.y, c30.w
mov r0.y, c2.w
mov r0.x, c0.w
mul r8.xz, r0.xyyw, c10.x
add r9.xyz, r8, -c4
mov r0.x, c8
mov r0.y, c8.x
dp3 r2.z, r9, r6
dp3 r2.w, r9, r9
add r0.y, c15, r0
mad r0.z, -r0.y, r0.y, r2.w
mad r0.w, r2.z, r2.z, -r0.z
rsq r1.x, r0.w
rcp r1.y, r1.x
add r0.x, c15, r0
mad r0.x, -r0, r0, r2.w
mad r0.x, r2.z, r2.z, -r0
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2, r0.y
cmp_pp r0.y, r0.x, c33, c33.x
cmp r0.x, r0, r2, c32
cmp r1.x, -r0.y, r0, r0.z
cmp r0.z, r0.w, r2.x, c32.x
cmp_pp r0.y, r0.w, c33, c33.x
add r1.y, -r2.z, r1
cmp r1.y, -r0, r0.z, r1
mov r0.x, c8
add r0.y, c15.z, r0.x
mov r0.x, c8
add r0.z, c15.w, r0.x
mad r0.y, -r0, r0, r2.w
mad r0.x, r2.z, r2.z, -r0.y
mad r0.z, -r0, r0, r2.w
mad r0.w, r2.z, r2.z, -r0.z
rsq r1.z, r0.w
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2, r0.y
cmp_pp r0.y, r0.x, c33, c33.x
cmp r0.x, r0, r2, c32
rcp r1.w, r1.z
cmp r1.z, -r0.y, r0.x, r0
add r0.z, -r2, r1.w
cmp r0.y, r0.w, r2.x, c32.x
cmp_pp r0.x, r0.w, c33.y, c33
cmp r1.w, -r0.x, r0.y, r0.z
mov r0.x, c8
add r0.y, c16.x, r0.x
mov r0.x, c8
add r0.z, c16.y, r0.x
mad r0.y, -r0, r0, r2.w
mad r0.x, r2.z, r2.z, -r0.y
mad r0.z, -r0, r0, r2.w
mad r0.w, r2.z, r2.z, -r0.z
rsq r0.y, r0.x
rcp r0.y, r0.y
add r0.z, -r2, -r0.y
cmp_pp r0.y, r0.x, c33, c33.x
cmp r0.x, r0, r2, c32.y
cmp r0.x, -r0.y, r0, r0.z
rsq r3.x, r0.w
cmp_pp r0.y, r0.w, c33, c33.x
rcp r3.x, r3.x
dp4 r3.w, r1, c24
cmp r0.w, r0, r2.x, c32.y
add r3.x, -r2.z, -r3
cmp r0.y, -r0, r0.w, r3.x
mov r0.z, c8.x
add r0.w, c16, r0.z
mad r0.w, -r0, r0, r2
mad r3.y, r2.z, r2.z, -r0.w
rsq r0.w, r3.y
rcp r3.x, r0.w
mov r0.z, c8.x
add r0.z, c16, r0
mad r0.z, -r0, r0, r2.w
mad r0.z, r2, r2, -r0
add r3.z, -r2, -r3.x
rsq r0.w, r0.z
rcp r3.x, r0.w
cmp_pp r0.w, r3.y, c33.y, c33.x
cmp r3.y, r3, r2.x, c32
cmp r0.w, -r0, r3.y, r3.z
add r3.y, -r2.z, -r3.x
cmp_pp r3.x, r0.z, c33.y, c33
cmp r0.z, r0, r2.x, c32.y
cmp r0.z, -r3.x, r0, r3.y
dp4 r3.z, r0, c28
dp4 r3.y, r1, c21
mad r2.w, -c9.x, c9.x, r2
mad r3.x, r2.z, r2.z, -r2.w
rsq r2.w, r3.x
cmp r4.z, -r3.y, c33.y, c33.x
add r3.w, r3, -r3.z
rcp r2.w, r2.w
add r3.y, -r2.z, -r2.w
add r2.w, -r2.z, r2
max r2.z, r3.y, c30.w
cmp r2.xy, r3.x, r2, c30.w
mad r3.z, r4, r3.w, r3
cmp_pp r3.y, r3.x, c33, c33.x
max r2.w, r2, c30
cmp r22.zw, -r3.y, r2.xyxy, r2
dp4 r2.y, r0, c26
dp4 r2.w, r0, c27
dp4 r2.x, r1, c22
dp4 r2.z, r1, c23
dp4 r1.x, r1, c25
dp4 r0.x, r0, c29
dp3 r1.y, r6, c13
add r0.y, r1.x, -r0.x
add r2.x, r2, -r2.y
mad r2.x, r4.z, r2, r2.y
add r2.z, r2, -r2.w
mad r2.y, r4.z, r2.z, r2.w
mad r0.x, r4.z, r0.y, r0
mul r0.z, r1.y, c19.x
min r2.x, r22.w, r2
mov r2.w, c18.x
mul r0.y, r0.z, c33.z
mad r0.y, c19.x, c19.x, r0
max r11.w, r22.z, r2.x
min r2.y, r22.w, r2
max r12.w, r11, r2.y
min r3.x, r22.w, r3.z
max r3.w, r12, r3.x
add r4.y, -r12.w, r3.w
abs r4.w, r4.y
mov r2.xyz, c17
mad r7.xyz, r22.z, r6, r9
mul r4.x, c30.z, r2.w
mul r3.xyz, c30.y, r2
add r15.xyz, r3, r4.x
mul r11.xyz, -r15, r4.w
pow r2, c32.z, r11.x
dp3 r2.y, r7, r7
rcp r11.x, r15.x
mov r7.xyz, c13
mov r14.x, r2
rsq r4.w, r2.y
pow r2, c32.z, r11.y
rcp r2.z, r4.w
mov r2.x, c9
add r2.x, -c8, r2
rcp r2.w, r2.x
dp3 r2.x, c5, r7
add r2.x, -r2, c33.y
add r2.z, r2, -c8.x
rcp r11.y, r15.y
mul r7.y, r2.z, r2.w
mul r7.x, r2, c34.y
mov r7.z, c30.w
texldl r2.zw, r7.xyzz, s0
pow r7, c32.z, r11.z
mul r2.x, r2.w, c18
mad r10.xyz, r2.z, -c17, -r2.x
mov r14.y, r2
pow r2, c32.z, r10.x
mov r14.z, r7
pow r7, c32.z, r10.y
mov r10.x, r2
pow r2, c32.z, r10.z
mov r10.z, r2
mul r2.xyz, r9.zxyw, c13.yzxw
mad r2.xyz, r9.yzxw, c13.zxyw, -r2
dp3 r2.w, r2, r2
mov r10.y, r7
mul r7.xyz, r10, c12
mul r10.xyz, r6.zxyw, c13.yzxw
mad r10.xyz, r6.yzxw, c13.zxyw, -r10
dp3 r4.w, r2, r10
dp3 r6.w, r10, r10
mad r2.w, -c8.x, c8.x, r2
mul r2.w, r6, r2
mad r2.y, r4.w, r4.w, -r2.w
rsq r2.x, r2.y
rcp r7.w, r2.x
dp3 r2.x, r9, c13
add r2.z, -r4.w, -r7.w
texldl r2.w, c34.yyzz, s1
mul r17.xyz, r7, r2.w
rcp r6.w, r6.w
cmp r2.x, -r2, c33.y, c33
rcp r11.z, r15.z
mul r18.xyz, r15, r17
mul r2.z, r2, r6.w
add r7.w, -r4, r7
mul r6.w, r6, r7
rcp r4.y, r4.y
add r1.x, r0.y, c33.y
cmp r2.y, -r2, c33.x, c33
mul_pp r2.x, r2, c11
mul_pp r2.w, r2.x, r2.y
cmp r9.x, -r2.w, c32.y, r2.z
mad r7.xyz, r6, r9.x, r8
add r7.xyz, r7, -c4
dp3 r4.w, r7, c13
mul r2.xyz, r14, r18
mov r8, c24
add r8, -c28, r8
cmp r9.y, -r2.w, c32.x, r6.w
cmp r4.w, -r4, c33.x, c33.y
mul_pp r2.w, r2, r4
cmp r22.xy, -r2.w, r9, c32.yxzw
add r2.w, r3, -r22.x
add r4.w, -r12, r22.y
mov r9, c25
add r9, -c29, r9
mul_sat r2.w, r2, r4.y
mul_sat r4.w, r4.y, r4
mad r9, r4.z, r9, c29
mad r8, r4.z, r8, c28
mad r4.w, -r2, r4, c33.y
min r0.x, r22.w, r0
max r2.w, r3, r0.x
pow r0, r1.x, c33.w
mad r0.z, r1.y, r1.y, c33.y
add r4.y, -r3.w, r2.w
mov r0.w, r0.x
mov r0.y, c19.x
add r0.x, c33.y, r0.y
mad r2.xyz, r15, r17, -r2
rcp r0.y, r0.w
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mul r0.x, r0.z, c32.w
mul r0.zw, r0.xyxy, c34.x
abs r0.x, r4.y
mul r6.xyz, -r15, r0.x
mul r0.y, r4.x, r0.w
mad r0.xyz, r3, r0.z, r0.y
mul r16.xyz, r0, r11
pow r0, c32.z, r6.x
mul r1.xyz, r16, r4.w
mul r1.xyz, r11, r1
mul r21.xyz, r1, r2
pow r1, c32.z, r6.z
mov r13.x, r0
pow r0, c32.z, r6.y
add r1.y, -r3.w, r22
rcp r1.x, r4.y
texldl r3, v0, s5
add r0.w, r2, -r22.x
mov r10.w, r3
mov r13.z, r1
mov r13.y, r0
mul_sat r0.w, r0, r1.x
mul_sat r1.y, r1.x, r1
mad r0.w, -r0, r1.y, c33.y
mul r0.xyz, r13, r18
mad r1.xyz, r15, r17, -r0
mul r0.xyz, r16, r0.w
add r0.w, r22, -r2
mul r0.xyz, r11, r0
mul r20.xyz, r0, r1
abs r1.w, r0
mul r2.xyz, -r15, r1.w
rcp r1.x, r0.w
add r0.x, -r2.w, r22.y
mul_sat r1.y, r1.x, r0.x
pow r0, c32.z, r2.x
add r0.y, r22.w, -r22.x
mul_sat r0.y, r0, r1.x
mad r2.x, -r0.y, r1.y, c33.y
pow r1, c32.z, r2.z
mov r12.x, r0
pow r0, c32.z, r2.y
mov r12.y, r0
mul r0.xyz, r2.x, r16
texldl r2, v0, s4
mov r12.z, r1
mul r1.xyz, r12, r18
mov r10.z, r2.w
mad r3.xyz, r2.w, r3, r2
mad r1.xyz, r15, r17, -r1
mul r0.xyz, r0, r11
mul r19.xyz, r0, r1
mov r1, c23
add r1, -c27, r1
mad r7, r4.z, r1, c27
texldl r1, v0, s2
mov r0, c22
add r0, -c26, r0
mad r6, r4.z, r0, c26
texldl r0, v0, s3
mad r3.xyz, r0.w, r3, r0
mul r2.x, r1.w, r0.w
mul r0.x, r2, r2.w
mov r10.y, r0.w
mov r10.x, r1.w
dp4 r4.x, r6, r10
dp4 r6.x, r6, r6
mad r1.xyz, r1.w, r3, r1
mul r0.w, r0.x, r3
texldl r0.xyz, v0, s6
mov r2.x, c20
dp4 r4.y, r7, r10
dp4 r4.w, r9, r10
dp4 r4.z, r8, r10
dp4 r6.y, r7, r7
dp4 r6.z, r8, r8
dp4 r6.w, r9, r9
add r4, r4, c34.w
mad r4, r6, r4, c33.y
mad r6.xyz, r19, r4.w, r20
mad r8.xyz, r6, r4.z, r21
add r4.z, -r11.w, r12.w
rcp r6.x, r4.z
abs r4.z, r4
mul r10.xyz, -r15, r4.z
pow r7, c32.z, r10.x
add r4.w, r12, -r22.x
add r6.y, -r11.w, r22
mul_sat r4.w, r4, r6.x
mul_sat r6.y, r6.x, r6
mad r4.w, -r4, r6.y, c33.y
mul r6.xyz, r16, r4.w
mul r9.xyz, r11, r6
pow r6, c32.z, r10.y
mov r10.y, r6
pow r6, c32.z, r10.z
add r4.z, r11.w, -r22
abs r4.w, r4.z
mul r19.xyz, -r15, r4.w
mov r10.z, r6
mov r10.x, r7
pow r6, c32.z, r19.x
mov r19.x, r6
pow r6, c32.z, r19.z
mul r7.xyz, r10, r18
mad r7.xyz, r15, r17, -r7
mul r9.xyz, r9, r7
pow r7, c32.z, r19.y
mov r19.y, r7
mad r7.xyz, r8, r4.y, r9
mov r19.z, r6
mul r6.xyz, r19, r10
mul r6.xyz, r6, r14
mul r8.xyz, r19, r18
mul r6.xyz, r6, r13
rcp r4.z, r4.z
add r4.y, r11.w, -r22.x
add r4.w, -r22.z, r22.y
mul_sat r4.y, r4, r4.z
mul_sat r4.w, r4.z, r4
mad r4.y, -r4, r4.w, c33
mul r9.xyz, r16, r4.y
mul r0.xyz, r0, r0.w
mul r6.xyz, r6, r12
mad r0.xyz, r0, r6, r1
add r2.x, c30, r2
mad r8.xyz, r15, r17, -r8
mul r9.xyz, r11, r9
mul r8.xyz, r9, r8
mad r4.xyz, r7, r4.x, r8
add r1.xyz, r0, r4
max r0.x, r1, r1.y
max r0.x, r1.z, r0
max r0.w, r0.x, c35.x
rcp r0.x, r0.w
mov r1.w, c33.y
mul r0.xyz, r1, r0.x
cmp_pp r3, r2.x, r5, r1
mul r0.w, r0, c20.x
cmp_pp r1.x, r2, c33.y, c33
cmp_pp oC0, -r1.x, r3, r0

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
Matrix 0 [_Camera2World]
Vector 4 [_PlanetCenterKm]
Float 5 [_PlanetRadiusKm]
Float 6 [_PlanetAtmosphereRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_SunColor]
Vector 9 [_SunDirection]
Vector 10 [_ShadowAltitudesMinKm]
Vector 11 [_ShadowAltitudesMaxKm]
Vector 12 [_Sigma_Rayleigh]
Float 13 [_Sigma_Mie]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
Float 14 [_LuminanceScale]
Vector 15 [_CaseSwizzle]
Vector 16 [_SwizzleExitUp0]
Vector 17 [_SwizzleExitUp1]
Vector 18 [_SwizzleExitUp2]
Vector 19 [_SwizzleExitUp3]
Vector 20 [_SwizzleEnterDown0]
Vector 21 [_SwizzleEnterDown1]
Vector 22 [_SwizzleEnterDown2]
Vector 23 [_SwizzleEnterDown3]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[26] = { program.local[0..23],
		{ 9.9999997e-005, 2.718282, 0.1, 0.25 },
		{ 0, -1000000, 1000000, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R2, c[10];
MOVR  R5.x, c[25].y;
MOVR  R5.y, c[25];
MOVR  R1.y, c[2].w;
MOVR  R1.x, c[0].w;
MULR  R1.xz, R1.xyyw, c[7].x;
MOVR  R1.y, c[25].x;
ADDR  R1.xyz, R1, -c[4];
DP3R  R0.y, R1, c[9];
DP3R  R1.w, R1, R1;
ADDR  R2, R2, c[5].x;
MULR  R1.y, R0, R0;
MADR  R2, -R2, R2, R1.w;
ADDR  R3, R1.y, -R2;
SLTR  R4, R1.y, R2;
RSQR  R1.z, R3.x;
MOVR  R1.x, c[25].y;
MOVXC RC.x, R4;
MOVR  R1.x(EQ), R0;
SGERC HC, R1.y, R2.yzxw;
RCPR  R1.z, R1.z;
ADDR  R1.x(NE.z), -R0.y, R1.z;
RSQR  R2.x, R3.z;
MOVR  R1.z, c[25].y;
MOVXC RC.z, R4;
MOVR  R1.z(EQ), R0.x;
MOVXC RC.z, R4.w;
RCPR  R2.x, R2.x;
ADDR  R1.z(NE.y), -R0.y, R2.x;
MOVXC RC.y, R4;
RSQR  R2.x, R3.w;
MOVR  R5.x(EQ.z), R0;
MOVR  R5.y(EQ), R0.x;
RCPR  R2.x, R2.x;
ADDR  R5.x(NE.w), -R0.y, R2;
RSQR  R0.x, R3.y;
RCPR  R0.x, R0.x;
ADDR  R5.y(NE.x), -R0, R0.x;
MOVR  R2, c[11];
ADDR  R2, R2, c[5].x;
MADR  R2, -R2, R2, R1.w;
ADDR  R3, R1.y, -R2;
SLTR  R4, R1.y, R2;
RSQR  R3.x, R3.x;
MOVR  R0.x, c[25].z;
MOVXC RC.x, R4;
MOVR  R0.x(EQ), R0.z;
SGERC HC, R1.y, R2.yzxw;
RCPR  R3.x, R3.x;
ADDR  R0.x(NE.z), -R0.y, -R3;
RSQR  R2.y, R3.z;
RSQR  R2.z, R3.w;
RSQR  R2.w, R3.y;
MOVR  R3.zw, c[25].x;
MOVR  R2.x, c[25].z;
MOVXC RC.z, R4;
MOVR  R2.x(EQ.z), R0.z;
RCPR  R2.y, R2.y;
ADDR  R2.x(NE.y), -R0.y, -R2.y;
MOVR  R2.y, c[25].z;
MOVXC RC.z, R4.w;
MOVR  R2.y(EQ.z), R0.z;
RCPR  R2.z, R2.z;
ADDR  R2.y(NE.w), -R0, -R2.z;
MOVR  R2.z, c[25];
MOVXC RC.y, R4;
MOVR  R2.z(EQ.y), R0;
RCPR  R2.w, R2.w;
ADDR  R2.z(NE.x), -R0.y, -R2.w;
MADR  R1.w, -c[6].x, c[6].x, R1;
SLTRC HC.x, R1.y, R1.w;
MOVR  R3.zw(EQ.x), R0;
ADDR  R0.z, R1.y, -R1.w;
SGERC HC.x, R1.y, R1.w;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
ADDR  R0.w, -R0.y, -R0.z;
ADDR  R0.y, -R0, R0.z;
MAXR  R0.z, R0.w, c[25].x;
MAXR  R0.w, R0.y, c[25].x;
MOVR  R3.zw(NE.x), R0;
MOVR  R1.y, R5;
MOVR  R1.w, R5.x;
MOVR  R0.w, R2.y;
MOVR  R0.y, R2.z;
MOVR  R0.z, R2.x;
DP4R  R2.x, R0, c[20];
DP4R  R2.y, R1, c[16];
ADDR  R2.z, R2.y, -R2.x;
DP4R  R2.y, R1, c[15];
SGER  H1.x, c[25], R2.y;
MADR  R2.x, H1, R2.z, R2;
MINR  R2.x, R3.w, R2;
MAXR  R3.x, R3.z, R2;
DP4R  R2.z, R0, c[21];
DP4R  R2.y, R1, c[17];
ADDR  R2.y, R2, -R2.z;
MADR  R2.y, H1.x, R2, R2.z;
MINR  R2.y, R3.w, R2;
MAXR  R2.z, R3.x, R2.y;
DP4R  R2.y, R0, c[22];
DP4R  R0.x, R0, c[23];
DP4R  R2.x, R1, c[18];
DP4R  R0.y, R1, c[19];
ADDR  R0.y, R0, -R0.x;
ADDR  R2.x, R2, -R2.y;
MADR  R2.x, H1, R2, R2.y;
MADR  R0.x, H1, R0.y, R0;
MINR  R2.x, R3.w, R2;
MAXR  R4.w, R2.z, R2.x;
MOVR  R2.xyw, c[24].wzzx;
MULR  R2.x, R2, c[13];
MADR  R4.xyz, R2.y, c[12], R2.x;
ADDR  R3.y, -R2.z, R4.w;
ADDR  R2.x, -R3, R2.z;
MULR  R2.xyz, -R4, |R2.x|;
MINR  R0.x, R3.w, R0;
MAXR  R0.w, R4, R0.x;
ADDR  R0.x, -R4.w, R0.w;
MULR  R0.xyz, -R4, |R0.x|;
ADDR  R0.w, R3, -R0;
MULR  R1.xyz, -R4, |R0.w|;
MULR  R5.xyz, -R4, |R3.y|;
ADDR  R3.x, R3, -R3.z;
MULR  R3.xyz, -R4, |R3.x|;
POWR  R3.x, c[24].y, R3.x;
POWR  R3.y, c[24].y, R3.y;
POWR  R3.z, c[24].y, R3.z;
POWR  R1.x, c[24].y, R1.x;
POWR  R1.z, c[24].y, R1.z;
POWR  R1.y, c[24].y, R1.y;
TEX   R1.w, fragment.texcoord[0], texture[1], 2D;
TEX   R0.w, fragment.texcoord[0], texture[0], 2D;
SLTRC HC.x, c[14], R2.w;
POWR  R2.x, c[24].y, R2.x;
POWR  R2.y, c[24].y, R2.y;
POWR  R2.z, c[24].y, R2.z;
MULR  R2.xyz, R3, R2;
POWR  R3.x, c[24].y, R5.x;
POWR  R3.z, c[24].y, R5.z;
POWR  R3.y, c[24].y, R5.y;
MULR  R2.xyz, R2, R3;
POWR  R0.x, c[24].y, R0.x;
POWR  R0.z, c[24].y, R0.z;
POWR  R0.y, c[24].y, R0.y;
MULR  R0.xyz, R2, R0;
MULR  R0.xyz, R0, R1;
MULR  R1.x, R0.w, R1.w;
TEX   R1.w, fragment.texcoord[0], texture[2], 2D;
MULR  R1.x, R1, R1.w;
TEX   R0.w, fragment.texcoord[0], texture[3], 2D;
MULR  R0.w, R1.x, R0;
MULR  R1.xyz, R0.w, c[8];
MULR  H1.xyz, R1, R0;
MOVH  H1.w, c[25];
MOVH  oCol, H1;
MOVH  oCol(EQ.x), H0;
MAXR  R0.x, H1, H1.y;
MAXR  R0.x, H1.z, R0;
MAXR  R0.x, R0, c[24];
RCPR  R0.y, R0.x;
MULR  H0.xyz, H1, R0.y;
MULR  H0.w, R0.x, c[14].x;
SGERC HC.x, c[14], R2.w;
MOVH  oCol(NE.x), H0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 4 [_PlanetCenterKm]
Float 5 [_PlanetRadiusKm]
Float 6 [_PlanetAtmosphereRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_SunColor]
Vector 9 [_SunDirection]
Vector 10 [_ShadowAltitudesMinKm]
Vector 11 [_ShadowAltitudesMaxKm]
Vector 12 [_Sigma_Rayleigh]
Float 13 [_Sigma_Mie]
SetTexture 0 [_TexCloudLayer0] 2D
SetTexture 1 [_TexCloudLayer1] 2D
SetTexture 2 [_TexCloudLayer2] 2D
SetTexture 3 [_TexCloudLayer3] 2D
Float 14 [_LuminanceScale]
Vector 15 [_CaseSwizzle]
Vector 16 [_SwizzleExitUp0]
Vector 17 [_SwizzleExitUp1]
Vector 18 [_SwizzleExitUp2]
Vector 19 [_SwizzleExitUp3]
Vector 20 [_SwizzleEnterDown0]
Vector 21 [_SwizzleEnterDown1]
Vector 22 [_SwizzleEnterDown2]
Vector 23 [_SwizzleEnterDown3]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c24, -0.00010000, 1.00000000, 0.00000000, 0.25000000
def c25, 0.10000000, -1000000.00000000, 1000000.00000000, 2.71828198
def c26, 0.00010000, 0, 0, 0
dcl_texcoord0 v0.xyzw
mov r2.w, c5.x
mov r0.w, c2
mov r0.z, c0.w
mul r2.xz, r0.zyww, c7.x
mov r2.y, c24.z
add r2.xyz, r2, -c4
mov r0.z, c5.x
dp3 r0.w, r2, r2
add r2.w, c10.y, r2
mad r3.x, -r2.w, r2.w, r0.w
add r0.z, c10.x, r0
mad r2.w, -r0.z, r0.z, r0
dp3 r0.z, r2, c9
mad r2.x, r0.z, r0.z, -r2.w
mad r2.w, r0.z, r0.z, -r3.x
rsq r2.y, r2.x
rcp r2.z, r2.y
cmp_pp r2.y, r2.x, c24, c24.z
cmp r2.x, r2, r0, c25.y
add r2.z, -r0, r2
cmp r3.x, -r2.y, r2, r2.z
rsq r3.y, r2.w
rcp r2.y, r3.y
add r2.z, -r0, r2.y
cmp r2.y, r2.w, r0.x, c25
cmp_pp r2.x, r2.w, c24.y, c24.z
cmp r3.y, -r2.x, r2, r2.z
mov r2.y, c5.x
mov r2.x, c5
add r2.y, c10.w, r2
mad r2.y, -r2, r2, r0.w
mad r2.z, r0, r0, -r2.y
rsq r2.w, r2.z
rcp r3.z, r2.w
cmp_pp r2.w, r2.z, c24.y, c24.z
add r2.x, c10.z, r2
mad r2.x, -r2, r2, r0.w
mad r2.x, r0.z, r0.z, -r2
cmp r2.z, r2, r0.x, c25.y
add r3.z, -r0, r3
cmp r3.w, -r2, r2.z, r3.z
rsq r2.y, r2.x
rcp r2.z, r2.y
cmp_pp r2.y, r2.x, c24, c24.z
cmp r2.x, r2, r0, c25.y
add r2.z, -r0, r2
cmp r3.z, -r2.y, r2.x, r2
dp4 r4.x, r3, c15
mov r2.x, c5
mov r2.y, c5.x
add r2.x, c11, r2
mad r2.x, -r2, r2, r0.w
add r2.y, c11, r2
mad r2.y, -r2, r2, r0.w
mad r2.w, r0.z, r0.z, -r2.y
mad r2.x, r0.z, r0.z, -r2
rsq r2.y, r2.x
rcp r2.z, r2.y
cmp_pp r2.y, r2.x, c24, c24.z
cmp r5.w, -r4.x, c24.y, c24.z
rsq r4.y, r2.w
add r2.z, -r0, -r2
cmp r2.x, r2, r0, c25.z
cmp r2.x, -r2.y, r2, r2.z
rcp r2.z, r4.y
add r4.y, -r0.z, -r2.z
cmp r2.z, r2.w, r0.x, c25
cmp_pp r2.y, r2.w, c24, c24.z
cmp r2.y, -r2, r2.z, r4
mov r2.w, c5.x
mov r2.z, c5.x
add r2.w, c11, r2
mad r2.w, -r2, r2, r0
mad r2.w, r0.z, r0.z, -r2
rsq r4.z, r2.w
rcp r4.w, r4.z
cmp_pp r4.z, r2.w, c24.y, c24
add r2.z, c11, r2
mad r2.z, -r2, r2, r0.w
mad r2.z, r0, r0, -r2
mad r0.w, -c6.x, c6.x, r0
mad r0.w, r0.z, r0.z, -r0
rsq r4.y, r2.z
add r4.w, -r0.z, -r4
cmp r2.w, r2, r0.x, c25.z
cmp r2.w, -r4.z, r2, r4
rcp r4.z, r4.y
cmp_pp r4.y, r2.z, c24, c24.z
cmp r2.z, r2, r0.x, c25
add r4.z, -r0, -r4
cmp r2.z, -r4.y, r2, r4
dp4 r4.z, r2, c21
dp4 r4.y, r3, c17
add r4.y, r4, -r4.z
mad r4.x, r5.w, r4.y, r4.z
dp4 r4.z, r2, c20
dp4 r4.y, r3, c16
add r4.y, r4, -r4.z
mad r4.w, r5, r4.y, r4.z
rsq r4.z, r0.w
cmp r0.xy, r0.w, r0, c24.z
cmp_pp r4.y, r0.w, c24, c24.z
rcp r4.z, r4.z
add r0.w, -r0.z, r4.z
add r0.z, -r0, -r4
max r0.w, r0, c24.z
max r0.z, r0, c24
cmp r6.zw, -r4.y, r0.xyxy, r0
min r0.x, r6.w, r4.w
max r4.w, r6.z, r0.x
min r0.y, r6.w, r4.x
max r7.w, r4, r0.y
add r0.y, -r4.w, r7.w
mov r0.x, c13
mul r0.w, c24, r0.x
abs r4.x, r0.y
mov r0.xyz, c12
mad r5.xyz, c25.x, r0, r0.w
mul r4.xyz, -r5, r4.x
pow r0, c25.w, r4.x
mov r7.x, r0
pow r0, c25.w, r4.y
add r0.x, r4.w, -r6.z
abs r0.x, r0
mul r6.xyz, -r5, r0.x
mov r7.y, r0
pow r0, c25.w, r4.z
pow r4, c25.w, r6.x
mov r7.z, r0
pow r0, c25.w, r6.y
dp4 r0.w, r2, c22
dp4 r2.y, r2, c23
mov r6.x, r4
pow r4, c25.w, r6.z
dp4 r0.x, r3, c18
add r4.x, r0, -r0.w
mad r0.w, r5, r4.x, r0
dp4 r2.x, r3, c19
add r2.x, r2, -r2.y
mad r2.x, r5.w, r2, r2.y
min r0.w, r6, r0
mov r6.y, r0
mov r6.z, r4
mul r0.xyz, r6, r7
max r0.w, r7, r0
min r2.y, r6.w, r2.x
add r2.x, -r7.w, r0.w
max r5.w, r0, r2.y
abs r2.x, r2
mul r7.xyz, -r5, r2.x
pow r3, c25.w, r7.x
pow r4, c25.w, r7.y
mov r7.x, r3
pow r3, c25.w, r7.z
add r0.w, -r0, r5
abs r0.w, r0
mul r6.xyz, -r5, r0.w
pow r2, c25.w, r6.x
mov r7.y, r4
mov r7.z, r3
mul r3.xyz, r0, r7
pow r0, c25.w, r6.y
add r0.x, r6.w, -r5.w
abs r2.z, r0.x
mul r5.xyz, -r5, r2.z
pow r4, c25.w, r5.x
mov r2.y, r0
pow r0, c25.w, r6.z
mov r2.z, r0
pow r0, c25.w, r5.y
mul r2.xyz, r3, r2
pow r3, c25.w, r5.z
mov r3.x, c14
mov r4.y, r0
mov r4.z, r3
texldl r2.w, v0, s1
texldl r0.w, v0, s0
mul r0.x, r0.w, r2.w
texldl r2.w, v0, s2
mul r0.x, r0, r2.w
texldl r0.w, v0, s3
mul r0.x, r0, r0.w
mul r0.xyz, r0.x, c8
mul r2.xyz, r2, r4
mul r2.xyz, r0, r2
max r0.x, r2, r2.y
max r0.x, r2.z, r0
max r0.w, r0.x, c26.x
rcp r0.x, r0.w
mul r0.xyz, r2, r0.x
add r3.x, c24, r3
mov r2.w, c24.y
cmp_pp r2, r3.x, r1, r2
mul r0.w, r0, c14.x
cmp_pp r1.x, r3, c24.y, c24.z
cmp_pp oC0, -r1.x, r2, r0

"
}

}

		}
	}
	Fallback off
}
