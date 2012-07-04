// This shader is responsible for rendering 3 tiny environment maps
// . The first map renders the sky without the clouds and is used to compute the ambient sky light for clouds
// . The second map renders the sky with the clouds and is used to compute the ambient sky light for the scene
// . The third map renders the sun with the clouds and is used to compute the directional sun light to use for the scene
//
Shader "Hidden/Nuaj/RenderSkyEnvironmentComplex"
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
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Vector 10 [_PlanetTangent]
Vector 11 [_PlanetBiTangent]
Float 12 [_PlanetRadiusKm]
Float 13 [_PlanetAtmosphereRadiusKm]
Float 14 [_WorldUnit2Kilometer]
Float 15 [_bComputePlanetShadow]
Vector 16 [_SunColor]
Vector 17 [_SunDirection]
Vector 18 [_AmbientNightSky]
Vector 19 [_EnvironmentAngles]
Vector 20 [_NuajLightningPosition00]
Vector 21 [_NuajLightningPosition01]
Vector 22 [_NuajLightningColor0]
Vector 23 [_NuajLightningPosition10]
Vector 24 [_NuajLightningPosition11]
Vector 25 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 26 [_ShadowAltitudesMinKm]
Vector 27 [_ShadowAltitudesMaxKm]
SetTexture 1 [_TexShadowMap] 2D
Float 28 [_DensitySeaLevel_Rayleigh]
Vector 29 [_Sigma_Rayleigh]
Float 30 [_DensitySeaLevel_Mie]
Float 31 [_Sigma_Mie]
Float 32 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexBackground] 2D
Float 33 [_bGodRays]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[41] = { program.local[0..33],
		{ 0, -1000000, 0.75, 1 },
		{ 2, 1.5, 1000000, -1000000 },
		{ 32, 0.03125, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400 },
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
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MADR  R1.xy, fragment.texcoord[0], c[19].zwzw, c[19];
COSR  R0.x, R1.y;
MOVR  R4.w, c[34].y;
SINR  R1.z, R1.x;
SINR  R2.x, R1.y;
COSR  R2.y, R1.x;
MULR  R1.y, R2.x, R1.z;
MULR  R0.xyz, R0.x, c[9];
MADR  R0.xyz, R1.y, c[10], R0;
MULR  R2.x, R2, R2.y;
MADR  R0.xyz, R2.x, c[11], R0;
MOVR  R2, c[26];
MOVR  R1.y, c[2].w;
MOVR  R1.x, c[0].w;
MULR  R3.xz, R1.xyyw, c[14].x;
MOVR  R3.y, c[34].x;
ADDR  R1.xyz, R3, -c[8];
DP3R  R4.x, R0, R1;
DP3R  R4.z, R1, R1;
ADDR  R2, R2, c[12].x;
MADR  R2, -R2, R2, R4.z;
MULR  R4.y, R4.x, R4.x;
SLTR  R5, R4.y, R2;
MOVXC RC.x, R5;
ADDR  R6, R4.y, -R2;
MOVR  R4.w(EQ.x), R0;
SGERC HC, R4.y, R2.yzwx;
RSQR  R5.x, R6.x;
RCPR  R5.x, R5.x;
ADDR  R4.w(NE), -R4.x, R5.x;
MADR  R2.x, -c[13], c[13], R4.z;
MOVR  R2.w, c[34].x;
SLTRC HC.w, R4.y, R2.x;
MOVR  R2.w(EQ), R0;
ADDR  R0.w, R4.y, -R2.x;
SGERC HC.w, R4.y, R2.x;
RSQR  R2.x, R6.w;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R0.w, -R4.x, R0;
MAXR  R2.w(NE), R0, c[34].x;
MINR  R0.w, R2, R4;
MAXR  R6.x, R0.w, c[34];
RCPR  R0.w, R2.w;
MULR  R4.w, R0, c[36].x;
MULR  R8.w, R6.x, R4;
MOVR  R5.x, c[34].y;
MOVR  R0.w, c[34].y;
MOVX  H0.x, c[34];
MOVXC RC.w, R8;
MOVX  H0.x(GT.w), c[34].w;
MOVXC RC.w, R5;
MOVR  R0.w(EQ), R1;
RCPR  R2.x, R2.x;
ADDR  R0.w(NE.z), -R4.x, R2.x;
RSQR  R2.x, R6.z;
MOVXC RC.z, R5;
MINR  R0.w, R2, R0;
MAXR  R6.w, R0, c[34].x;
MOVR  R5.x(EQ.z), R1.w;
RCPR  R2.x, R2.x;
ADDR  R5.x(NE.y), -R4, R2;
RSQR  R2.x, R6.y;
MOVR  R6.z, c[34].y;
MOVXC RC.y, R5;
MOVR  R6.z(EQ.y), R1.w;
RCPR  R2.x, R2.x;
ADDR  R6.z(NE.x), -R4.x, R2.x;
MULR  R2.xyz, R1.zxyw, c[17].yzxw;
MADR  R2.xyz, R1.yzxw, c[17].zxyw, -R2;
DP3R  R1.y, R1, c[17];
SLER  H0.y, R1, c[34].x;
MULR  R4.xyz, R0.zxyw, c[17].yzxw;
DP3R  R5.y, R2, R2;
MADR  R4.xyz, R0.yzxw, c[17].zxyw, -R4;
DP3R  R2.x, R2, R4;
DP3R  R2.z, R4, R4;
MADR  R2.y, -c[12].x, c[12].x, R5;
MULR  R4.x, R2.z, R2.y;
MULR  R4.y, R2.x, R2.x;
ADDR  R2.y, R4, -R4.x;
RSQR  R2.y, R2.y;
RCPR  R2.y, R2.y;
ADDR  R1.x, -R2, R2.y;
RCPR  R1.y, R2.z;
MOVR  R1.z, c[35].w;
SGTR  H0.z, R4.y, R4.x;
MULX  H0.y, H0, c[15].x;
MULX  H0.y, H0, H0.z;
MOVXC RC.x, H0.y;
MULR  R1.z(NE.x), R1.y, R1.x;
MOVR  R1.x, c[35].z;
ADDR  R2.x, -R2, -R2.y;
MULR  R1.x(NE), R2, R1.y;
MOVR  R1.y, R1.z;
MOVR  R5.zw, R1.xyxy;
MADR  R1.xyz, R0, R1.x, R3;
ADDR  R1.xyz, R1, -c[8];
DP3R  R1.x, R1, c[17];
SGTR  H0.z, R1.x, c[34].x;
MULXC HC.x, H0.y, H0.z;
MINR  R1.x, R2.w, R6.z;
MOVR  R5.zw(NE.x), c[35];
MAXR  R7.x, R1, c[34];
MINR  R1.x, R2.w, R5;
MAXR  R7.w, R1.x, c[34].x;
DP3R  R1.x, R0, c[17];
MULR  R1.y, R1.x, c[32].x;
MULR  R1.x, R1, R1;
MULR  R1.y, R1, c[35].x;
MOVXC RC.x, H0;
MADR  R1.y, c[32].x, c[32].x, R1;
MADR  R5.x, R1, c[34].z, c[34].z;
ADDR  R1.x, R1.y, c[34].w;
MOVR  R1.y, c[34].w;
POWR  R1.x, R1.x, c[35].y;
ADDR  R1.y, R1, c[32].x;
RCPR  R1.x, R1.x;
MULR  R1.y, R1, R1;
MULR  R5.y, R1, R1.x;
MULR  R0.w, R2, c[36].y;
MOVR  R1.xyz, c[34].w;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, c[34];
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R4.xyz, R10, -c[8];
DP3R  R4.x, R4, R4;
RSQR  R4.x, R4.x;
RCPR  R12.x, R4.x;
MOVR  R4.x, c[12];
ADDR  R6.z, -R4.x, c[13].x;
MOVR  R4.xyz, c[9];
DP3R  R4.x, R4, c[17];
MOVXC RC.x, c[33];
ADDR  R6.y, R12.x, -c[12].x;
RCPR  R6.z, R6.z;
MULR  R4.y, R6, R6.z;
MADR  R4.x, -R4, c[36].z, c[36].z;
TEX   R9, R4, texture[0], 2D;
MULR  R4.x, R9.w, c[31];
MADR  R4.xyz, R9.z, -c[29], -R4.x;
ADDR  R9.z, R8.x, R0.w;
ADDR  R6.z, -R8.x, R5.w;
RCPR  R7.y, R0.w;
ADDR  R6.y, R9.z, -R5.z;
POWR  R4.x, c[36].w, R4.x;
POWR  R4.y, c[36].w, R4.y;
POWR  R4.z, c[36].w, R4.z;
MULR_SAT R6.z, R7.y, R6;
MULR_SAT R6.y, R6, R7;
MULR  R6.y, R6, R6.z;
MADR  R4.xyz, -R6.y, R4, R4;
MULR  R8.xyz, R4, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R4.x, c[34].w;
SGERC HC.x, R9.w, c[27].w;
MOVR  R4.x(EQ), R3.w;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R4.x;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R4.y, R13, R3.w;
MOVR  R3.w, c[37];
MULR  R4.x, R4.y, R4.y;
MADR  R4.y, -R4, c[35].x, R3.w;
TEX   R12, R12, texture[1], 2D;
MULR  R4.y, R4.x, R4;
RCPR  R4.z, R14.x;
MULR_SAT R4.x, R13, R4.z;
MADR  R4.z, -R4.x, c[35].x, R3.w;
MULR  R4.x, R4, R4;
MULR  R4.z, R4.x, R4;
MADR  R4.y, R12, R4, -R4;
ADDR  R4.x, R4.y, c[34].w;
MADR  R4.y, R12.x, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
RCPR  R4.z, R14.z;
MULR_SAT R4.z, R4, R13;
MADR  R6.y, -R4.z, c[35].x, R3.w;
RCPR  R4.y, R14.w;
MULR_SAT R4.y, R4, R13.w;
MADR  R3.w, -R4.y, c[35].x, R3;
MULR  R4.y, R4, R4;
MULR  R3.w, R4.y, R3;
MULR  R4.z, R4, R4;
MULR  R4.z, R4, R6.y;
MADR  R4.y, R12.z, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R4.x, R4.x;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R4.xyz, -R10, c[23];
DP3R  R6.y, R4, R4;
RSQR  R7.y, R6.y;
MULR  R4.xyz, R7.y, R4;
RCPR  R7.y, R7.y;
MOVR  R6.y, c[34].w;
DP3R  R4.x, R0, R4;
MADR  R4.x, R4, c[32], R6.y;
RCPR  R9.w, R4.x;
MULR  R6.z, c[32].x, c[32].x;
MADR  R7.z, -R6, R9.w, R9.w;
MOVR  R4.xyz, c[23];
MULR  R7.z, R7, R9.w;
ADDR  R4.xyz, -R4, c[24];
DP3R  R9.w, R4, R4;
ADDR  R4.xyz, -R10, c[20];
RSQR  R9.w, R9.w;
RCPR  R9.w, R9.w;
DP3R  R10.x, R4, R4;
MULR  R9.w, R9, R7.z;
RSQR  R7.z, R10.x;
MULR  R4.xyz, R7.z, R4;
DP3R  R4.y, R4, R0;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
MADR  R4.z, R4.y, c[32].x, R6.y;
RCPR  R4.y, R4.x;
RCPR  R4.x, R4.z;
MADR  R4.z, -R6, R4.x, R4.x;
MULR  R4.y, R9.w, R4;
RCPR  R7.y, R7.z;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R4, R4.x;
MOVR  R4.xyz, c[20];
ADDR  R4.xyz, -R4, c[21];
DP3R  R4.y, R4, R4;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
RSQR  R4.y, R4.y;
RCPR  R4.y, R4.y;
MULR  R4.y, R4, R6.z;
RCPR  R4.x, R4.x;
MULR  R4.y, R4, R4.x;
MINR  R4.x, R6.y, c[34].w;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R9.x, c[28].x;
MINR  R6.y, R6, c[34].w;
MULR  R4.xyz, R4.x, c[25];
MADR  R4.xyz, R6.y, c[22], R4;
MULR  R6.y, R9, c[30].x;
MULR  R4.xyz, R4, c[39].x;
MULR  R4.xyz, R6.y, R4;
MULR  R6.y, R5, R6;
MULR  R6.z, R6, R5.x;
MADR  R10.xyz, R6.z, c[38], R6.y;
MULR  R4.xyz, R4, c[39].y;
MADR  R4.xyz, R8, R10, R4;
MULR  R6.y, R9, c[31].x;
ADDR  R4.xyz, R4, c[18];
MULR  R4.xyz, R4, R0.w;
MADR  R8.xyz, R9.x, c[29], R6.y;
MULR  R8.xyz, R0.w, -R8;
MADR  R2.xyz, R4, R1, R2;
POWR  R4.x, c[36].w, R8.x;
POWR  R4.y, c[36].w, R8.y;
POWR  R4.z, c[36].w, R8.z;
MULR  R1.xyz, R1, R4;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R4.xyz, R10, -c[8];
DP3R  R4.x, R4, R4;
RSQR  R4.x, R4.x;
RCPR  R11.w, R4.x;
MOVR  R4.x, c[12];
ADDR  R6.z, -R4.x, c[13].x;
MOVR  R4.xyz, c[9];
DP3R  R4.x, R4, c[17];
MOVXC RC.x, c[33];
ADDR  R6.y, R11.w, -c[12].x;
RCPR  R6.z, R6.z;
MULR  R4.y, R6, R6.z;
ADDR  R6.y, R8.w, -R10.w;
MULR  R8.w, R6.y, R0;
MADR  R4.x, -R4, c[36].z, c[36].z;
TEX   R9, R4, texture[0], 2D;
ADDR  R6.y, R8.w, R8.x;
MULR  R4.x, R9.w, c[31];
MADR  R4.xyz, R9.z, -c[29], -R4.x;
ADDR  R6.z, -R8.x, R5.w;
RCPR  R7.y, R8.w;
ADDR  R6.y, R6, -R5.z;
POWR  R4.x, c[36].w, R4.x;
POWR  R4.y, c[36].w, R4.y;
POWR  R4.z, c[36].w, R4.z;
MULR_SAT R6.z, R7.y, R6;
MULR_SAT R6.y, R6, R7;
MULR  R6.y, R6, R6.z;
MADR  R4.xyz, -R6.y, R4, R4;
MULR  R8.xyz, R4, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R4.x, c[34].w;
SGERC HC.x, R10.w, c[27].w;
MOVR  R4.x(EQ), R1.w;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R4.x;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R4.y, R12, R1.w;
MOVR  R1.w, c[37];
MULR  R4.x, R4.y, R4.y;
MADR  R4.y, -R4, c[35].x, R1.w;
TEX   R11, R9.zwzw, texture[1], 2D;
MULR  R4.y, R4.x, R4;
RCPR  R4.z, R13.x;
MULR_SAT R4.x, R12, R4.z;
MADR  R4.z, -R4.x, c[35].x, R1.w;
MULR  R4.x, R4, R4;
MULR  R4.z, R4.x, R4;
MADR  R4.y, R11, R4, -R4;
ADDR  R4.x, R4.y, c[34].w;
MADR  R4.y, R11.x, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
RCPR  R4.z, R13.z;
MULR_SAT R4.z, R4, R12;
MADR  R6.y, -R4.z, c[35].x, R1.w;
RCPR  R4.y, R13.w;
MULR_SAT R4.y, R4, R12.w;
MADR  R1.w, -R4.y, c[35].x, R1;
MULR  R4.y, R4, R4;
MULR  R1.w, R4.y, R1;
MULR  R4.z, R4, R4;
MULR  R4.z, R4, R6.y;
MADR  R4.y, R11.z, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R4.x, R4.x;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R4.xyz, -R10, c[23];
DP3R  R6.y, R4, R4;
RSQR  R7.y, R6.y;
MULR  R4.xyz, R7.y, R4;
RCPR  R7.y, R7.y;
MOVR  R6.y, c[34].w;
DP3R  R4.x, R0, R4;
MADR  R4.x, R4, c[32], R6.y;
RCPR  R9.z, R4.x;
MULR  R6.z, c[32].x, c[32].x;
MADR  R7.z, -R6, R9, R9;
MOVR  R4.xyz, c[23];
MULR  R7.z, R7, R9;
ADDR  R4.xyz, -R4, c[24];
DP3R  R9.z, R4, R4;
ADDR  R4.xyz, -R10, c[20];
RSQR  R9.z, R9.z;
RCPR  R9.z, R9.z;
DP3R  R9.w, R4, R4;
MULR  R9.z, R9, R7;
RSQR  R7.z, R9.w;
MULR  R4.xyz, R7.z, R4;
DP3R  R4.y, R4, R0;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
MADR  R4.z, R4.y, c[32].x, R6.y;
RCPR  R4.y, R4.x;
RCPR  R4.x, R4.z;
MADR  R4.z, -R6, R4.x, R4.x;
MULR  R4.y, R9.z, R4;
RCPR  R7.y, R7.z;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R4, R4.x;
MOVR  R4.xyz, c[20];
ADDR  R4.xyz, -R4, c[21];
DP3R  R4.y, R4, R4;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
RSQR  R4.y, R4.y;
RCPR  R4.y, R4.y;
MULR  R4.y, R4, R6.z;
RCPR  R4.x, R4.x;
MULR  R4.y, R4, R4.x;
MINR  R4.x, R6.y, c[34].w;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R9.x, c[28].x;
MINR  R6.y, R6, c[34].w;
MULR  R4.xyz, R4.x, c[25];
MADR  R4.xyz, R6.y, c[22], R4;
MULR  R6.y, R9, c[30].x;
MULR  R4.xyz, R4, c[39].x;
MULR  R4.xyz, R6.y, R4;
MULR  R6.y, R5, R6;
MULR  R6.z, R6, R5.x;
MADR  R10.xyz, R6.z, c[38], R6.y;
MULR  R4.xyz, R4, c[39].y;
MADR  R4.xyz, R8, R10, R4;
MULR  R6.y, R9, c[31].x;
ADDR  R4.xyz, R4, c[18];
MULR  R4.xyz, R4, R8.w;
MADR  R8.xyz, R9.x, c[29], R6.y;
MADR  R2.xyz, R4, R1, R2;
MULR  R8.xyz, R8.w, -R8;
POWR  R4.x, c[36].w, R8.x;
POWR  R4.y, c[36].w, R8.y;
POWR  R4.z, c[36].w, R8.z;
MULR  R1.xyz, R1, R4;
ENDIF;
ADDR  R4.x, R7, -R6;
MULR  R8.w, R4.x, R4;
MOVR  R4.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R6;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R6.xyz, R10, -c[8];
DP3R  R6.x, R6, R6;
RSQR  R6.x, R6.x;
RCPR  R12.x, R6.x;
MOVR  R6.x, c[12];
ADDR  R7.z, -R6.x, c[13].x;
MOVR  R6.xyz, c[9];
DP3R  R6.x, R6, c[17];
MOVXC RC.x, c[33];
ADDR  R7.y, R12.x, -c[12].x;
RCPR  R7.z, R7.z;
MULR  R6.y, R7, R7.z;
MADR  R6.x, -R6, c[36].z, c[36].z;
TEX   R9, R6, texture[0], 2D;
MULR  R6.x, R9.w, c[31];
MADR  R6.xyz, R9.z, -c[29], -R6.x;
ADDR  R9.z, R8.x, R0.w;
ADDR  R7.z, -R8.x, R5.w;
RCPR  R8.x, R0.w;
ADDR  R7.y, R9.z, -R5.z;
MULR_SAT R7.y, R7, R8.x;
MULR_SAT R7.z, R8.x, R7;
POWR  R6.x, c[36].w, R6.x;
POWR  R6.y, c[36].w, R6.y;
POWR  R6.z, c[36].w, R6.z;
MULR  R7.y, R7, R7.z;
MADR  R6.xyz, -R7.y, R6, R6;
MULR  R8.xyz, R6, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R6.x, c[34].w;
SGERC HC.x, R9.w, c[27].w;
MOVR  R6.x(EQ), R3.w;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R6.x;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R6.y, R13, R3.w;
MOVR  R3.w, c[37];
MULR  R6.x, R6.y, R6.y;
MADR  R6.y, -R6, c[35].x, R3.w;
TEX   R12, R12, texture[1], 2D;
MULR  R6.y, R6.x, R6;
RCPR  R6.z, R14.x;
MULR_SAT R6.x, R13, R6.z;
MADR  R6.z, -R6.x, c[35].x, R3.w;
MULR  R6.x, R6, R6;
MULR  R6.z, R6.x, R6;
MADR  R6.y, R12, R6, -R6;
ADDR  R6.x, R6.y, c[34].w;
MADR  R6.y, R12.x, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
RCPR  R6.z, R14.z;
MULR_SAT R6.z, R6, R13;
MADR  R7.y, -R6.z, c[35].x, R3.w;
RCPR  R6.y, R14.w;
MULR_SAT R6.y, R6, R13.w;
MADR  R3.w, -R6.y, c[35].x, R3;
MULR  R6.y, R6, R6;
MULR  R3.w, R6.y, R3;
MULR  R6.z, R6, R6;
MULR  R6.z, R6, R7.y;
MADR  R6.y, R12.z, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R6.x, R6.x;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R6.xyz, -R10, c[23];
DP3R  R7.y, R6, R6;
RSQR  R9.w, R7.y;
MULR  R6.xyz, R9.w, R6;
RCPR  R9.w, R9.w;
MOVR  R7.y, c[34].w;
DP3R  R6.x, R0, R6;
MADR  R6.x, R6, c[32], R7.y;
RCPR  R11.y, R6.x;
MULR  R7.z, c[32].x, c[32].x;
MADR  R11.x, -R7.z, R11.y, R11.y;
MOVR  R6.xyz, c[23];
ADDR  R6.xyz, -R6, c[24];
MULR  R11.x, R11, R11.y;
DP3R  R11.y, R6, R6;
ADDR  R6.xyz, -R10, c[20];
DP3R  R10.x, R6, R6;
RSQR  R10.x, R10.x;
MULR  R6.xyz, R10.x, R6;
DP3R  R6.y, R6, R0;
MULR  R9.w, R9, c[38];
MULR  R6.x, R9.w, R9.w;
MADR  R6.z, R6.y, c[32].x, R7.y;
RCPR  R6.y, R6.x;
RCPR  R6.x, R6.z;
MADR  R6.z, -R7, R6.x, R6.x;
RCPR  R9.w, R10.x;
RSQR  R10.y, R11.y;
RCPR  R10.y, R10.y;
MULR  R10.y, R10, R11.x;
MULR  R6.y, R10, R6;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R6, R6.x;
MOVR  R6.xyz, c[20];
ADDR  R6.xyz, -R6, c[21];
DP3R  R6.y, R6, R6;
MULR  R9.w, R9, c[38];
MULR  R6.x, R9.w, R9.w;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
MULR  R6.y, R6, R7.z;
RCPR  R6.x, R6.x;
MULR  R6.y, R6, R6.x;
MINR  R6.x, R7.y, c[34].w;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R9.x, c[28].x;
MINR  R7.y, R7, c[34].w;
MULR  R6.xyz, R6.x, c[25];
MADR  R6.xyz, R7.y, c[22], R6;
MULR  R7.y, R9, c[30].x;
MULR  R6.xyz, R6, c[39].x;
MULR  R6.xyz, R7.y, R6;
MULR  R7.y, R5, R7;
MULR  R7.z, R7, R5.x;
MADR  R10.xyz, R7.z, c[38], R7.y;
MULR  R6.xyz, R6, c[39].y;
MADR  R6.xyz, R8, R10, R6;
MULR  R7.y, R9, c[31].x;
ADDR  R6.xyz, R6, c[18];
MULR  R6.xyz, R6, R0.w;
MADR  R8.xyz, R9.x, c[29], R7.y;
MULR  R8.xyz, R0.w, -R8;
MADR  R2.xyz, R6, R1, R2;
POWR  R6.x, c[36].w, R8.x;
POWR  R6.y, c[36].w, R8.y;
POWR  R6.z, c[36].w, R8.z;
MULR  R1.xyz, R1, R6;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R6.xyz, R10, -c[8];
DP3R  R6.x, R6, R6;
RSQR  R6.x, R6.x;
RCPR  R11.w, R6.x;
MOVR  R6.x, c[12];
ADDR  R7.z, -R6.x, c[13].x;
MOVR  R6.xyz, c[9];
DP3R  R6.x, R6, c[17];
MOVXC RC.x, c[33];
ADDR  R7.y, R11.w, -c[12].x;
RCPR  R7.z, R7.z;
MULR  R6.y, R7, R7.z;
ADDR  R7.y, R8.w, -R10.w;
MULR  R8.w, R7.y, R0;
MADR  R6.x, -R6, c[36].z, c[36].z;
TEX   R9, R6, texture[0], 2D;
ADDR  R7.y, R8.w, R8.x;
ADDR  R7.z, -R8.x, R5.w;
RCPR  R8.x, R8.w;
MULR  R6.x, R9.w, c[31];
MADR  R6.xyz, R9.z, -c[29], -R6.x;
ADDR  R7.y, R7, -R5.z;
MULR_SAT R7.y, R7, R8.x;
MULR_SAT R7.z, R8.x, R7;
POWR  R6.x, c[36].w, R6.x;
POWR  R6.y, c[36].w, R6.y;
POWR  R6.z, c[36].w, R6.z;
MULR  R7.y, R7, R7.z;
MADR  R6.xyz, -R7.y, R6, R6;
MULR  R8.xyz, R6, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R6.x, c[34].w;
SGERC HC.x, R10.w, c[27].w;
MOVR  R6.x(EQ), R1.w;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R6.x;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R6.y, R12, R1.w;
MOVR  R1.w, c[37];
MULR  R6.x, R6.y, R6.y;
MADR  R6.y, -R6, c[35].x, R1.w;
TEX   R11, R9.zwzw, texture[1], 2D;
MULR  R6.y, R6.x, R6;
RCPR  R6.z, R13.x;
MULR_SAT R6.x, R12, R6.z;
MADR  R6.z, -R6.x, c[35].x, R1.w;
MULR  R6.x, R6, R6;
MULR  R6.z, R6.x, R6;
MADR  R6.y, R11, R6, -R6;
ADDR  R6.x, R6.y, c[34].w;
MADR  R6.y, R11.x, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
RCPR  R6.z, R13.z;
MULR_SAT R6.z, R6, R12;
MADR  R7.y, -R6.z, c[35].x, R1.w;
RCPR  R6.y, R13.w;
MULR_SAT R6.y, R6, R12.w;
MADR  R1.w, -R6.y, c[35].x, R1;
MULR  R6.y, R6, R6;
MULR  R1.w, R6.y, R1;
MULR  R6.z, R6, R6;
MULR  R6.z, R6, R7.y;
MADR  R6.y, R11.z, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R6.x, R6.x;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R6.xyz, -R10, c[23];
DP3R  R7.y, R6, R6;
RSQR  R9.z, R7.y;
MULR  R6.xyz, R9.z, R6;
RCPR  R9.z, R9.z;
MOVR  R7.y, c[34].w;
DP3R  R6.x, R0, R6;
MADR  R6.x, R6, c[32], R7.y;
RCPR  R10.w, R6.x;
MULR  R7.z, c[32].x, c[32].x;
MADR  R9.w, -R7.z, R10, R10;
MOVR  R6.xyz, c[23];
MULR  R9.w, R9, R10;
ADDR  R6.xyz, -R6, c[24];
DP3R  R10.w, R6, R6;
ADDR  R6.xyz, -R10, c[20];
RSQR  R10.x, R10.w;
RCPR  R10.x, R10.x;
MULR  R10.x, R10, R9.w;
DP3R  R10.y, R6, R6;
RSQR  R9.w, R10.y;
MULR  R6.xyz, R9.w, R6;
DP3R  R6.y, R6, R0;
MULR  R9.z, R9, c[38].w;
MULR  R6.x, R9.z, R9.z;
MADR  R6.z, R6.y, c[32].x, R7.y;
RCPR  R6.y, R6.x;
RCPR  R6.x, R6.z;
MULR  R6.y, R10.x, R6;
MADR  R6.z, -R7, R6.x, R6.x;
RCPR  R9.z, R9.w;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R6, R6.x;
MOVR  R6.xyz, c[20];
ADDR  R6.xyz, -R6, c[21];
DP3R  R6.y, R6, R6;
MULR  R9.z, R9, c[38].w;
MULR  R6.x, R9.z, R9.z;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
MULR  R6.y, R6, R7.z;
RCPR  R6.x, R6.x;
MULR  R6.y, R6, R6.x;
MINR  R6.x, R7.y, c[34].w;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R9.x, c[28].x;
MINR  R7.y, R7, c[34].w;
MULR  R6.xyz, R6.x, c[25];
MADR  R6.xyz, R7.y, c[22], R6;
MULR  R7.y, R9, c[30].x;
MULR  R6.xyz, R6, c[39].x;
MULR  R6.xyz, R7.y, R6;
MULR  R7.y, R5, R7;
MULR  R7.z, R7, R5.x;
MADR  R10.xyz, R7.z, c[38], R7.y;
MULR  R6.xyz, R6, c[39].y;
MADR  R6.xyz, R8, R10, R6;
MULR  R7.y, R9, c[31].x;
ADDR  R6.xyz, R6, c[18];
MULR  R6.xyz, R6, R8.w;
MADR  R8.xyz, R9.x, c[29], R7.y;
MADR  R2.xyz, R6, R1, R2;
MULR  R8.xyz, R8.w, -R8;
POWR  R6.x, c[36].w, R8.x;
POWR  R6.y, c[36].w, R8.y;
POWR  R6.z, c[36].w, R8.z;
MULR  R1.xyz, R1, R6;
ENDIF;
ADDR  R6.x, R7.w, -R7;
MULR  R8.w, R6.x, R4;
MOVR  R6.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R7;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R7.xyz, R10, -c[8];
DP3R  R7.x, R7, R7;
RSQR  R7.x, R7.x;
RCPR  R12.x, R7.x;
MOVR  R7.x, c[12];
ADDR  R8.z, -R7.x, c[13].x;
MOVR  R7.xyz, c[9];
DP3R  R7.x, R7, c[17];
MOVXC RC.x, c[33];
ADDR  R8.y, R12.x, -c[12].x;
RCPR  R8.z, R8.z;
MULR  R7.y, R8, R8.z;
MADR  R7.x, -R7, c[36].z, c[36].z;
TEX   R9, R7, texture[0], 2D;
MULR  R7.x, R9.w, c[31];
MADR  R7.xyz, R9.z, -c[29], -R7.x;
ADDR  R9.z, R8.x, R0.w;
RCPR  R8.z, R0.w;
ADDR  R8.y, R9.z, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R8.x, R8.z, R8;
MULR_SAT R8.y, R8, R8.z;
MULR  R8.x, R8.y, R8;
POWR  R7.x, c[36].w, R7.x;
POWR  R7.y, c[36].w, R7.y;
POWR  R7.z, c[36].w, R7.z;
MADR  R7.xyz, -R8.x, R7, R7;
MULR  R8.xyz, R7, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R7.x, c[34].w;
SGERC HC.x, R9.w, c[27].w;
MOVR  R7.x(EQ), R3.w;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R7.x;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R7.y, R13, R3.w;
MOVR  R3.w, c[37];
MULR  R7.x, R7.y, R7.y;
MADR  R7.y, -R7, c[35].x, R3.w;
TEX   R12, R12, texture[1], 2D;
MULR  R7.y, R7.x, R7;
RCPR  R7.z, R14.x;
MULR_SAT R7.x, R13, R7.z;
MADR  R7.z, -R7.x, c[35].x, R3.w;
MULR  R7.x, R7, R7;
MULR  R7.z, R7.x, R7;
MADR  R7.y, R12, R7, -R7;
ADDR  R7.x, R7.y, c[34].w;
MADR  R7.y, R12.x, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
RCPR  R7.z, R14.z;
MULR_SAT R7.z, R7, R13;
MADR  R9.w, -R7.z, c[35].x, R3;
RCPR  R7.y, R14.w;
MULR_SAT R7.y, R7, R13.w;
MADR  R3.w, -R7.y, c[35].x, R3;
MULR  R7.y, R7, R7;
MULR  R3.w, R7.y, R3;
MULR  R7.z, R7, R7;
MULR  R7.z, R7, R9.w;
MADR  R7.y, R12.z, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R7.x, R7.x;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R7.xyz, -R10, c[23];
DP3R  R9.w, R7, R7;
RSQR  R11.y, R9.w;
MULR  R7.xyz, R11.y, R7;
MOVR  R9.w, c[34];
DP3R  R7.x, R0, R7;
MADR  R7.x, R7, c[32], R9.w;
RCPR  R12.x, R7.x;
MULR  R11.x, c[32], c[32];
MADR  R11.z, -R11.x, R12.x, R12.x;
MOVR  R7.xyz, c[23];
ADDR  R7.xyz, -R7, c[24];
MULR  R11.z, R11, R12.x;
DP3R  R12.x, R7, R7;
ADDR  R7.xyz, -R10, c[20];
DP3R  R10.x, R7, R7;
RSQR  R10.x, R10.x;
MULR  R7.xyz, R10.x, R7;
DP3R  R7.y, R7, R0;
RSQR  R10.y, R12.x;
RCPR  R10.y, R10.y;
RCPR  R10.z, R11.y;
MULR  R10.z, R10, c[38].w;
RCPR  R10.x, R10.x;
MADR  R7.z, R7.y, c[32].x, R9.w;
MULR  R7.x, R10.z, R10.z;
RCPR  R7.y, R7.x;
RCPR  R7.x, R7.z;
MULR  R10.y, R10, R11.z;
MULR  R7.y, R10, R7;
MADR  R7.z, -R11.x, R7.x, R7.x;
MULR  R9.w, R7.y, c[38];
MULR  R10.y, R7.z, R7.x;
MOVR  R7.xyz, c[20];
ADDR  R7.xyz, -R7, c[21];
DP3R  R7.y, R7, R7;
MULR  R10.x, R10, c[38].w;
MULR  R7.x, R10, R10;
RSQR  R7.y, R7.y;
RCPR  R7.y, R7.y;
MULR  R10.x, R9, c[28];
MULR  R7.y, R7, R10;
RCPR  R7.x, R7.x;
MULR  R7.y, R7, R7.x;
MINR  R7.x, R9.w, c[34].w;
MULR  R9.w, R7.y, c[38];
MINR  R9.w, R9, c[34];
MULR  R7.xyz, R7.x, c[25];
MADR  R7.xyz, R9.w, c[22], R7;
MULR  R9.w, R9.y, c[30].x;
MULR  R7.xyz, R7, c[39].x;
MULR  R7.xyz, R9.w, R7;
MULR  R7.xyz, R7, c[39].y;
MULR  R9.w, R5.y, R9;
MULR  R10.x, R10, R5;
MADR  R10.xyz, R10.x, c[38], R9.w;
MADR  R7.xyz, R8, R10, R7;
MULR  R8.x, R9.y, c[31];
ADDR  R7.xyz, R7, c[18];
MULR  R7.xyz, R7, R0.w;
MADR  R8.xyz, R9.x, c[29], R8.x;
MULR  R8.xyz, R0.w, -R8;
MADR  R2.xyz, R7, R1, R2;
POWR  R7.x, c[36].w, R8.x;
POWR  R7.y, c[36].w, R8.y;
POWR  R7.z, c[36].w, R8.z;
MULR  R1.xyz, R1, R7;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R7.xyz, R10, -c[8];
DP3R  R7.x, R7, R7;
RSQR  R7.x, R7.x;
RCPR  R11.w, R7.x;
MOVR  R7.x, c[12];
ADDR  R8.z, -R7.x, c[13].x;
MOVR  R7.xyz, c[9];
DP3R  R7.x, R7, c[17];
MOVXC RC.x, c[33];
ADDR  R8.y, R11.w, -c[12].x;
RCPR  R8.z, R8.z;
MULR  R7.y, R8, R8.z;
ADDR  R8.y, R8.w, -R10.w;
MULR  R8.w, R8.y, R0;
ADDR  R8.y, R8.w, R8.x;
MADR  R7.x, -R7, c[36].z, c[36].z;
TEX   R9, R7, texture[0], 2D;
MULR  R7.x, R9.w, c[31];
MADR  R7.xyz, R9.z, -c[29], -R7.x;
RCPR  R8.z, R8.w;
ADDR  R8.y, R8, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R8.x, R8.z, R8;
MULR_SAT R8.y, R8, R8.z;
MULR  R8.x, R8.y, R8;
POWR  R7.x, c[36].w, R7.x;
POWR  R7.y, c[36].w, R7.y;
POWR  R7.z, c[36].w, R7.z;
MADR  R7.xyz, -R8.x, R7, R7;
MULR  R8.xyz, R7, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R7.x, c[34].w;
SGERC HC.x, R10.w, c[27].w;
MOVR  R7.x(EQ), R1.w;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R7.x;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
TEX   R11, R9.zwzw, texture[1], 2D;
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R7.y, R12, R1.w;
MOVR  R1.w, c[37];
MULR  R7.x, R7.y, R7.y;
MADR  R7.y, -R7, c[35].x, R1.w;
MULR  R7.y, R7.x, R7;
RCPR  R7.z, R13.x;
MULR_SAT R7.x, R12, R7.z;
MADR  R7.z, -R7.x, c[35].x, R1.w;
MULR  R7.x, R7, R7;
MULR  R7.z, R7.x, R7;
MADR  R7.y, R11, R7, -R7;
ADDR  R7.x, R7.y, c[34].w;
MADR  R7.y, R11.x, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
RCPR  R7.z, R13.z;
MULR_SAT R7.z, R7, R12;
MADR  R9.z, -R7, c[35].x, R1.w;
RCPR  R7.y, R13.w;
MULR_SAT R7.y, R7, R12.w;
MADR  R1.w, -R7.y, c[35].x, R1;
MULR  R7.y, R7, R7;
MULR  R1.w, R7.y, R1;
MULR  R7.z, R7, R7;
MULR  R7.z, R7, R9;
MADR  R7.y, R11.z, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R7.x, R7.x;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R7.xyz, -R10, c[23];
DP3R  R9.z, R7, R7;
RSQR  R10.w, R9.z;
MULR  R7.xyz, R10.w, R7;
MOVR  R9.z, c[34].w;
DP3R  R7.x, R0, R7;
MADR  R7.x, R7, c[32], R9.z;
RCPR  R11.y, R7.x;
MULR  R9.w, c[32].x, c[32].x;
MADR  R11.x, -R9.w, R11.y, R11.y;
MOVR  R7.xyz, c[23];
ADDR  R7.xyz, -R7, c[24];
MULR  R11.x, R11, R11.y;
DP3R  R11.y, R7, R7;
ADDR  R7.xyz, -R10, c[20];
DP3R  R10.x, R7, R7;
RSQR  R10.x, R10.x;
MULR  R7.xyz, R10.x, R7;
DP3R  R7.y, R7, R0;
RSQR  R10.y, R11.y;
RCPR  R10.y, R10.y;
RCPR  R10.z, R10.w;
MULR  R10.z, R10, c[38].w;
RCPR  R10.x, R10.x;
MADR  R7.z, R7.y, c[32].x, R9;
MULR  R7.x, R10.z, R10.z;
RCPR  R7.y, R7.x;
RCPR  R7.x, R7.z;
MADR  R7.z, -R9.w, R7.x, R7.x;
MULR  R10.y, R10, R11.x;
MULR  R7.y, R10, R7;
MULR  R9.z, R7.y, c[38].w;
MULR  R9.w, R7.z, R7.x;
MOVR  R7.xyz, c[20];
ADDR  R7.xyz, -R7, c[21];
DP3R  R7.y, R7, R7;
MULR  R10.x, R10, c[38].w;
MULR  R7.x, R10, R10;
RSQR  R7.y, R7.y;
RCPR  R7.y, R7.y;
MULR  R7.y, R7, R9.w;
RCPR  R7.x, R7.x;
MULR  R7.y, R7, R7.x;
MINR  R7.x, R9.z, c[34].w;
MULR  R9.z, R7.y, c[38].w;
MULR  R9.w, R9.x, c[28].x;
MINR  R9.z, R9, c[34].w;
MULR  R7.xyz, R7.x, c[25];
MADR  R7.xyz, R9.z, c[22], R7;
MULR  R9.z, R9.y, c[30].x;
MULR  R7.xyz, R7, c[39].x;
MULR  R7.xyz, R9.z, R7;
MULR  R7.xyz, R7, c[39].y;
MULR  R9.z, R5.y, R9;
MULR  R9.w, R9, R5.x;
MADR  R10.xyz, R9.w, c[38], R9.z;
MADR  R7.xyz, R8, R10, R7;
MULR  R8.x, R9.y, c[31];
ADDR  R7.xyz, R7, c[18];
MULR  R7.xyz, R7, R8.w;
MADR  R8.xyz, R9.x, c[29], R8.x;
MADR  R2.xyz, R7, R1, R2;
MULR  R8.xyz, R8.w, -R8;
POWR  R7.x, c[36].w, R8.x;
POWR  R7.y, c[36].w, R8.y;
POWR  R7.z, c[36].w, R8.z;
MULR  R1.xyz, R1, R7;
ENDIF;
ADDR  R7.x, R6.w, -R7.w;
MULR  R8.w, R7.x, R4;
MOVR  R7.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R7.w;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R9.xyz, R10, -c[8];
DP3R  R7.w, R9, R9;
MOVR  R9.xyz, c[9];
DP3R  R8.z, R9, c[17];
RSQR  R7.w, R7.w;
RCPR  R12.x, R7.w;
MOVR  R8.y, c[12].x;
ADDR  R8.y, -R8, c[13].x;
MOVXC RC.x, c[33];
ADDR  R7.w, R12.x, -c[12].x;
RCPR  R8.y, R8.y;
MULR  R9.y, R7.w, R8;
MADR  R9.x, -R8.z, c[36].z, c[36].z;
TEX   R9, R9, texture[0], 2D;
MULR  R7.w, R9, c[31].x;
MADR  R11.xyz, R9.z, -c[29], -R7.w;
ADDR  R9.z, R8.x, R0.w;
RCPR  R8.y, R0.w;
ADDR  R7.w, R9.z, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R7.w, R7, R8.y;
MULR_SAT R8.x, R8.y, R8;
POWR  R11.x, c[36].w, R11.x;
POWR  R11.y, c[36].w, R11.y;
POWR  R11.z, c[36].w, R11.z;
MULR  R7.w, R7, R8.x;
MADR  R8.xyz, -R7.w, R11, R11;
MULR  R8.xyz, R8, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R7.w, c[34];
SGERC HC.x, R9.w, c[27].w;
MOVR  R7.w(EQ.x), R3;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R7;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R9.w, R13.y, R3;
MOVR  R3.w, c[37];
MULR  R7.w, R9, R9;
MADR  R9.w, -R9, c[35].x, R3;
TEX   R12, R12, texture[1], 2D;
MULR  R9.w, R7, R9;
RCPR  R11.x, R14.x;
MULR_SAT R7.w, R13.x, R11.x;
MADR  R11.x, -R7.w, c[35], R3.w;
MULR  R7.w, R7, R7;
MULR  R11.x, R7.w, R11;
MADR  R9.w, R12.y, R9, -R9;
ADDR  R7.w, R9, c[34];
MADR  R9.w, R12.x, R11.x, -R11.x;
MADR  R7.w, R9, R7, R7;
RCPR  R11.x, R14.z;
MULR_SAT R11.x, R11, R13.z;
MADR  R11.y, -R11.x, c[35].x, R3.w;
RCPR  R9.w, R14.w;
MULR_SAT R9.w, R9, R13;
MADR  R3.w, -R9, c[35].x, R3;
MULR  R9.w, R9, R9;
MULR  R3.w, R9, R3;
MULR  R11.x, R11, R11;
MULR  R11.x, R11, R11.y;
MADR  R9.w, R12.z, R11.x, -R11.x;
MADR  R7.w, R9, R7, R7;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R7, R7;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R11.xyz, -R10, c[23];
DP3R  R7.w, R11, R11;
RSQR  R12.x, R7.w;
MULR  R11.xyz, R12.x, R11;
DP3R  R9.w, R0, R11;
MOVR  R7.w, c[34];
MADR  R9.w, R9, c[32].x, R7;
RCPR  R12.z, R9.w;
MULR  R9.w, c[32].x, c[32].x;
MADR  R12.y, -R9.w, R12.z, R12.z;
MOVR  R11.xyz, c[23];
ADDR  R11.xyz, -R11, c[24];
DP3R  R11.x, R11, R11;
RSQR  R11.y, R11.x;
ADDR  R10.xyz, -R10, c[20];
DP3R  R11.x, R10, R10;
RSQR  R11.x, R11.x;
MULR  R10.xyz, R11.x, R10;
DP3R  R10.y, R10, R0;
RCPR  R11.z, R12.x;
MULR  R11.z, R11, c[38].w;
RCPR  R11.x, R11.x;
MADR  R10.y, R10, c[32].x, R7.w;
MULR  R10.x, R11.z, R11.z;
RCPR  R7.w, R10.x;
RCPR  R10.x, R10.y;
MADR  R9.w, -R9, R10.x, R10.x;
MULR  R9.w, R9, R10.x;
MOVR  R10.xyz, c[20];
ADDR  R10.xyz, -R10, c[21];
DP3R  R10.y, R10, R10;
MULR  R11.x, R11, c[38].w;
MULR  R10.x, R11, R11;
RSQR  R10.y, R10.y;
RCPR  R10.y, R10.y;
MULR  R9.w, R10.y, R9;
RCPR  R10.x, R10.x;
MULR  R10.x, R9.w, R10;
MULR  R12.y, R12, R12.z;
RCPR  R11.y, R11.y;
MULR  R11.y, R11, R12;
MULR  R7.w, R11.y, R7;
MULR  R7.w, R7, c[38];
MINR  R9.w, R7, c[34];
MULR  R7.w, R10.x, c[38];
MULR  R10.xyz, R9.w, c[25];
MINR  R7.w, R7, c[34];
MADR  R10.xyz, R7.w, c[22], R10;
MULR  R9.w, R9.x, c[28].x;
MULR  R7.w, R9.y, c[30].x;
MULR  R10.xyz, R10, c[39].x;
MULR  R10.xyz, R7.w, R10;
MULR  R10.xyz, R10, c[39].y;
MULR  R7.w, R5.y, R7;
MULR  R9.w, R9, R5.x;
MADR  R11.xyz, R9.w, c[38], R7.w;
MADR  R8.xyz, R8, R11, R10;
MULR  R7.w, R9.y, c[31].x;
ADDR  R8.xyz, R8, c[18];
MULR  R8.xyz, R8, R0.w;
MADR  R10.xyz, R9.x, c[29], R7.w;
MADR  R2.xyz, R8, R1, R2;
MULR  R10.xyz, R0.w, -R10;
POWR  R8.x, c[36].w, R10.x;
POWR  R8.y, c[36].w, R10.y;
POWR  R8.z, c[36].w, R10.z;
MULR  R1.xyz, R1, R8;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R9.xyz, R10, -c[8];
DP3R  R7.w, R9, R9;
MOVR  R9.xyz, c[9];
DP3R  R8.z, R9, c[17];
RSQR  R7.w, R7.w;
RCPR  R11.w, R7.w;
MOVR  R8.y, c[12].x;
ADDR  R8.y, -R8, c[13].x;
MOVXC RC.x, c[33];
ADDR  R7.w, R11, -c[12].x;
RCPR  R8.y, R8.y;
MULR  R9.y, R7.w, R8;
MADR  R9.x, -R8.z, c[36].z, c[36].z;
TEX   R9, R9, texture[0], 2D;
MULR  R7.w, R9, c[31].x;
MADR  R11.xyz, R9.z, -c[29], -R7.w;
ADDR  R7.w, R8, -R10;
MULR  R8.w, R7, R0;
ADDR  R7.w, R8, R8.x;
RCPR  R8.y, R8.w;
ADDR  R7.w, R7, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R7.w, R7, R8.y;
MULR_SAT R8.x, R8.y, R8;
POWR  R11.x, c[36].w, R11.x;
POWR  R11.y, c[36].w, R11.y;
POWR  R11.z, c[36].w, R11.z;
MULR  R7.w, R7, R8.x;
MADR  R8.xyz, -R7.w, R11, R11;
MULR  R8.xyz, R8, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R7.w, c[34];
SGERC HC.x, R10.w, c[27].w;
MOVR  R7.w(EQ.x), R1;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R7;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R10.w, R12.y, R1;
MOVR  R1.w, c[37];
MULR  R7.w, R10, R10;
MADR  R10.w, -R10, c[35].x, R1;
MULR  R10.w, R7, R10;
RCPR  R11.x, R13.x;
MULR_SAT R7.w, R12.x, R11.x;
TEX   R11, R9.zwzw, texture[1], 2D;
MADR  R9.w, -R7, c[35].x, R1;
MULR  R7.w, R7, R7;
MADR  R9.z, R11.y, R10.w, -R10.w;
MULR  R9.w, R7, R9;
ADDR  R7.w, R9.z, c[34];
MADR  R9.z, R11.x, R9.w, -R9.w;
MADR  R7.w, R9.z, R7, R7;
RCPR  R9.w, R13.z;
MULR_SAT R9.w, R9, R12.z;
MADR  R10.w, -R9, c[35].x, R1;
RCPR  R9.z, R13.w;
MULR_SAT R9.z, R9, R12.w;
MADR  R1.w, -R9.z, c[35].x, R1;
MULR  R9.z, R9, R9;
MULR  R1.w, R9.z, R1;
MULR  R9.w, R9, R9;
MULR  R9.w, R9, R10;
MADR  R9.z, R11, R9.w, -R9.w;
MADR  R7.w, R9.z, R7, R7;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R7, R7;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R11.xyz, -R10, c[23];
DP3R  R7.w, R11, R11;
RSQR  R9.w, R7.w;
MULR  R11.xyz, R9.w, R11;
DP3R  R9.z, R0, R11;
MOVR  R7.w, c[34];
MADR  R9.z, R9, c[32].x, R7.w;
RCPR  R11.w, R9.z;
MULR  R9.z, c[32].x, c[32].x;
MADR  R10.w, -R9.z, R11, R11;
MOVR  R11.xyz, c[23];
ADDR  R11.xyz, -R11, c[24];
DP3R  R11.x, R11, R11;
ADDR  R10.xyz, -R10, c[20];
RSQR  R11.x, R11.x;
RCPR  R9.w, R9.w;
MULR  R9.w, R9, c[38];
DP3R  R11.y, R10, R10;
MULR  R10.w, R10, R11;
RCPR  R11.x, R11.x;
MULR  R11.x, R11, R10.w;
RSQR  R10.w, R11.y;
MULR  R10.xyz, R10.w, R10;
DP3R  R10.x, R10, R0;
MADR  R10.x, R10, c[32], R7.w;
MULR  R9.w, R9, R9;
RCPR  R7.w, R9.w;
RCPR  R9.w, R10.x;
MADR  R9.z, -R9, R9.w, R9.w;
MULR  R9.z, R9, R9.w;
MULR  R7.w, R11.x, R7;
MOVR  R10.xyz, c[20];
ADDR  R10.xyz, -R10, c[21];
DP3R  R10.x, R10, R10;
RCPR  R9.w, R10.w;
MULR  R9.w, R9, c[38];
MULR  R9.w, R9, R9;
RSQR  R10.x, R10.x;
RCPR  R10.x, R10.x;
MULR  R9.z, R10.x, R9;
RCPR  R9.w, R9.w;
MULR  R7.w, R7, c[38];
MULR  R9.w, R9.z, R9;
MINR  R9.z, R7.w, c[34].w;
MULR  R10.xyz, R9.z, c[25];
MULR  R9.z, R9.x, c[28].x;
MULR  R7.w, R9, c[38];
MINR  R7.w, R7, c[34];
MADR  R10.xyz, R7.w, c[22], R10;
MULR  R7.w, R9.y, c[30].x;
MULR  R10.xyz, R10, c[39].x;
MULR  R10.xyz, R7.w, R10;
MULR  R7.w, R5.y, R7;
MULR  R9.z, R9, R5.x;
MADR  R11.xyz, R9.z, c[38], R7.w;
MULR  R10.xyz, R10, c[39].y;
MADR  R8.xyz, R8, R11, R10;
MULR  R7.w, R9.y, c[31].x;
ADDR  R8.xyz, R8, c[18];
MULR  R8.xyz, R8, R8.w;
MADR  R9.xyz, R9.x, c[29], R7.w;
MADR  R2.xyz, R8, R1, R2;
MULR  R9.xyz, R8.w, -R9;
POWR  R8.x, c[36].w, R9.x;
POWR  R8.y, c[36].w, R9.y;
POWR  R8.z, c[36].w, R9.z;
MULR  R1.xyz, R1, R8;
ENDIF;
ADDR  R2.w, R2, -R6;
MULR  R8.w, R2, R4;
MOVR  R11.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R6.w;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R9.xyz, R10, -c[8];
DP3R  R2.w, R9, R9;
MOVR  R9.xyz, c[9];
DP3R  R6.w, R9, c[17];
RSQR  R2.w, R2.w;
MADR  R9.x, -R6.w, c[36].z, c[36].z;
RCPR  R12.x, R2.w;
MOVR  R4.w, c[12].x;
ADDR  R4.w, -R4, c[13].x;
MOVXC RC.x, c[33];
ADDR  R2.w, R12.x, -c[12].x;
RCPR  R4.w, R4.w;
MULR  R9.y, R2.w, R4.w;
TEX   R9, R9, texture[0], 2D;
MULR  R2.w, R9, c[31].x;
MADR  R13.xyz, R9.z, -c[29], -R2.w;
ADDR  R9.z, R8.x, R0.w;
ADDR  R4.w, -R8.x, R5;
RCPR  R6.w, R0.w;
ADDR  R2.w, R9.z, -R5.z;
POWR  R13.x, c[36].w, R13.x;
POWR  R13.y, c[36].w, R13.y;
POWR  R13.z, c[36].w, R13.z;
MULR_SAT R4.w, R6, R4;
MULR_SAT R2.w, R2, R6;
MULR  R2.w, R2, R4;
MADR  R8.xyz, -R2.w, R13, R13;
MULR  R8.xyz, R8, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R2.w, c[34];
SGERC HC.x, R9.w, c[27].w;
MOVR  R2.w(EQ.x), R3;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R2;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R2.w, R14.y;
MULR_SAT R4.w, R13.y, R2;
MOVR  R2.w, c[37];
MULR  R3.w, R4, R4;
MADR  R4.w, -R4, c[35].x, R2;
TEX   R12, R12, texture[1], 2D;
MULR  R4.w, R3, R4;
RCPR  R6.w, R14.x;
MULR_SAT R3.w, R13.x, R6;
MADR  R6.w, -R3, c[35].x, R2;
MULR  R3.w, R3, R3;
MULR  R6.w, R3, R6;
MADR  R4.w, R12.y, R4, -R4;
ADDR  R3.w, R4, c[34];
MADR  R4.w, R12.x, R6, -R6;
MADR  R3.w, R4, R3, R3;
RCPR  R6.w, R14.z;
MULR_SAT R6.w, R6, R13.z;
MADR  R7.w, -R6, c[35].x, R2;
RCPR  R4.w, R14.w;
MULR_SAT R4.w, R4, R13;
MADR  R2.w, -R4, c[35].x, R2;
MULR  R4.w, R4, R4;
MULR  R2.w, R4, R2;
MULR  R6.w, R6, R6;
MULR  R6.w, R6, R7;
MADR  R4.w, R12.z, R6, -R6;
MADR  R3.w, R4, R3, R3;
MADR  R2.w, R12, R2, -R2;
MADR  R3.w, R2, R3, R3;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R12.xyz, -R10, c[23];
DP3R  R2.w, R12, R12;
RSQR  R6.w, R2.w;
MULR  R12.xyz, R6.w, R12;
DP3R  R4.w, R0, R12;
MOVR  R2.w, c[34];
MADR  R4.w, R4, c[32].x, R2;
RCPR  R9.w, R4.w;
MULR  R4.w, c[32].x, c[32].x;
MADR  R7.w, -R4, R9, R9;
MOVR  R12.xyz, c[23];
RCPR  R6.w, R6.w;
MULR  R6.w, R6, c[38];
ADDR  R12.xyz, -R12, c[24];
MULR  R7.w, R7, R9;
DP3R  R9.w, R12, R12;
ADDR  R10.xyz, -R10, c[20];
RSQR  R9.w, R9.w;
RCPR  R9.w, R9.w;
DP3R  R12.x, R10, R10;
MULR  R9.w, R9, R7;
RSQR  R7.w, R12.x;
MULR  R10.xyz, R7.w, R10;
DP3R  R10.x, R10, R0;
MADR  R10.x, R10, c[32], R2.w;
MULR  R6.w, R6, R6;
RCPR  R2.w, R6.w;
RCPR  R6.w, R10.x;
MADR  R4.w, -R4, R6, R6;
MULR  R4.w, R4, R6;
RCPR  R6.w, R7.w;
MULR  R2.w, R9, R2;
MOVR  R10.xyz, c[20];
ADDR  R10.xyz, -R10, c[21];
DP3R  R7.w, R10, R10;
MULR  R6.w, R6, c[38];
MULR  R6.w, R6, R6;
RSQR  R7.w, R7.w;
RCPR  R7.w, R7.w;
MULR  R2.w, R2, c[38];
MULR  R4.w, R7, R4;
RCPR  R6.w, R6.w;
MULR  R6.w, R4, R6;
MINR  R4.w, R2, c[34];
MULR  R10.xyz, R4.w, c[25];
MULR  R2.w, R6, c[38];
MINR  R2.w, R2, c[34];
MADR  R10.xyz, R2.w, c[22], R10;
MULR  R4.w, R9.x, c[28].x;
MULR  R2.w, R9.y, c[30].x;
MULR  R10.xyz, R10, c[39].x;
MULR  R10.xyz, R2.w, R10;
MULR  R10.xyz, R10, c[39].y;
MULR  R2.w, R5.y, R2;
MULR  R4.w, R4, R5.x;
MADR  R12.xyz, R4.w, c[38], R2.w;
MADR  R8.xyz, R8, R12, R10;
MULR  R2.w, R9.y, c[31].x;
ADDR  R8.xyz, R8, c[18];
MULR  R8.xyz, R8, R0.w;
MADR  R10.xyz, R9.x, c[29], R2.w;
MADR  R2.xyz, R8, R1, R2;
MULR  R10.xyz, R0.w, -R10;
POWR  R8.x, c[36].w, R10.x;
POWR  R8.y, c[36].w, R10.y;
POWR  R8.z, c[36].w, R10.z;
MULR  R1.xyz, R1, R8;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R0, R3;
ADDR  R3.xyz, R10, -c[8];
DP3R  R2.w, R3, R3;
RSQR  R2.w, R2.w;
MOVR  R3.x, c[12];
ADDR  R3.w, -R3.x, c[13].x;
MOVR  R3.xyz, c[9];
DP3R  R3.x, R3, c[17];
RCPR  R11.w, R2.w;
MOVXC RC.x, c[33];
ADDR  R2.w, R11, -c[12].x;
RCPR  R3.w, R3.w;
MULR  R3.y, R2.w, R3.w;
MADR  R3.x, -R3, c[36].z, c[36].z;
TEX   R9, R3, texture[0], 2D;
MULR  R2.w, R9, c[31].x;
MADR  R3.xyz, R9.z, -c[29], -R2.w;
ADDR  R2.w, R8, -R10;
MULR  R8.w, R2, R0;
ADDR  R0.w, R8, R8.x;
ADDR  R2.w, -R8.x, R5;
RCPR  R3.w, R8.w;
ADDR  R0.w, R0, -R5.z;
POWR  R3.x, c[36].w, R3.x;
POWR  R3.y, c[36].w, R3.y;
POWR  R3.z, c[36].w, R3.z;
MULR_SAT R2.w, R3, R2;
MULR_SAT R0.w, R0, R3;
MULR  R0.w, R0, R2;
MADR  R3.xyz, -R0.w, R3, R3;
MULR  R8.xyz, R3, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R0.w, c[34];
SGERC HC.x, R10.w, c[27].w;
MOVR  R0.w(EQ.x), R1;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R3.w, c[34];
MOVR  R3.xyz, R10;
MOVR  R1.w, R0;
DP4R  R9.w, R3, c[5];
DP4R  R9.z, R3, c[4];
IF    NE.x;
MOVR  R3, c[27];
ADDR  R13, -R3, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R0.w, R13.y;
MULR_SAT R2.w, R12.y, R0;
MOVR  R0.w, c[37];
MULR  R1.w, R2, R2;
MADR  R2.w, -R2, c[35].x, R0;
RCPR  R3.x, R13.x;
MULR  R2.w, R1, R2;
MULR_SAT R1.w, R12.x, R3.x;
TEX   R3, R9.zwzw, texture[1], 2D;
MADR  R2.w, R3.y, R2, -R2;
MADR  R3.y, -R1.w, c[35].x, R0.w;
MULR  R1.w, R1, R1;
MULR  R3.y, R1.w, R3;
ADDR  R1.w, R2, c[34];
MADR  R2.w, R3.x, R3.y, -R3.y;
MADR  R1.w, R2, R1, R1;
RCPR  R3.x, R13.z;
MULR_SAT R3.x, R3, R12.z;
MADR  R3.y, -R3.x, c[35].x, R0.w;
RCPR  R2.w, R13.w;
MULR_SAT R2.w, R2, R12;
MADR  R0.w, -R2, c[35].x, R0;
MULR  R2.w, R2, R2;
MULR  R0.w, R2, R0;
MULR  R3.x, R3, R3;
MULR  R3.x, R3, R3.y;
MADR  R2.w, R3.z, R3.x, -R3.x;
MADR  R1.w, R2, R1, R1;
MADR  R0.w, R3, R0, -R0;
MADR  R1.w, R0, R1, R1;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R3.xyz, -R10, c[23];
DP3R  R0.w, R3, R3;
RSQR  R2.w, R0.w;
MULR  R3.xyz, R2.w, R3;
DP3R  R1.w, R0, R3;
MOVR  R0.w, c[34];
MADR  R1.w, R1, c[32].x, R0;
RCPR  R4.w, R1.w;
MULR  R1.w, c[32].x, c[32].x;
MADR  R3.w, -R1, R4, R4;
MOVR  R3.xyz, c[23];
RCPR  R2.w, R2.w;
MULR  R3.w, R3, R4;
ADDR  R3.xyz, -R3, c[24];
DP3R  R4.w, R3, R3;
ADDR  R3.xyz, -R10, c[20];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
DP3R  R5.z, R3, R3;
MULR  R4.w, R4, R3;
RSQR  R3.w, R5.z;
MULR  R3.xyz, R3.w, R3;
DP3R  R0.y, R3, R0;
MULR  R2.w, R2, c[38];
MULR  R0.x, R2.w, R2.w;
MADR  R0.z, R0.y, c[32].x, R0.w;
RCPR  R0.y, R0.x;
RCPR  R0.x, R0.z;
MADR  R0.z, -R1.w, R0.x, R0.x;
MULR  R0.y, R4.w, R0;
RCPR  R2.w, R3.w;
MULR  R0.w, R0.y, c[38];
MULR  R1.w, R0.z, R0.x;
MOVR  R0.xyz, c[20];
ADDR  R0.xyz, -R0, c[21];
DP3R  R0.y, R0, R0;
MULR  R2.w, R2, c[38];
MULR  R0.x, R2.w, R2.w;
RSQR  R0.y, R0.y;
RCPR  R0.y, R0.y;
MULR  R0.y, R0, R1.w;
RCPR  R0.x, R0.x;
MULR  R0.y, R0, R0.x;
MINR  R0.x, R0.w, c[34].w;
MULR  R0.w, R0.y, c[38];
MULR  R1.w, R9.x, c[28].x;
MINR  R0.w, R0, c[34];
MULR  R0.xyz, R0.x, c[25];
MADR  R0.xyz, R0.w, c[22], R0;
MULR  R0.w, R9.y, c[30].x;
MULR  R0.xyz, R0, c[39].x;
MULR  R0.xyz, R0.w, R0;
MULR  R0.w, R5.y, R0;
MULR  R1.w, R1, R5.x;
MADR  R3.xyz, R1.w, c[38], R0.w;
MULR  R0.xyz, R0, c[39].y;
MADR  R0.xyz, R8, R3, R0;
MULR  R0.w, R9.y, c[31].x;
ADDR  R0.xyz, R0, c[18];
MULR  R0.xyz, R0, R8.w;
MADR  R3.xyz, R9.x, c[29], R0.w;
MADR  R2.xyz, R0, R1, R2;
MULR  R3.xyz, R8.w, -R3;
POWR  R0.x, c[36].w, R3.x;
POWR  R0.y, c[36].w, R3.y;
POWR  R0.z, c[36].w, R3.z;
MULR  R1.xyz, R1, R0;
ENDIF;
ADDR  R0.xyz, R4, R6;
ADDR  R0.xyz, R0, R7;
ADDR  R0.xyz, R0, R11;
ADDR  R2.xyz, R0, R2;
TEX   R0.xyz, fragment.texcoord[0], texture[2], 2D;
MADR  oCol.xyz, R0, R1, R2;
DP3R  oCol.w, R1, c[40];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Vector 10 [_PlanetTangent]
Vector 11 [_PlanetBiTangent]
Float 12 [_PlanetRadiusKm]
Float 13 [_PlanetAtmosphereRadiusKm]
Float 14 [_WorldUnit2Kilometer]
Float 15 [_bComputePlanetShadow]
Vector 16 [_SunColor]
Vector 17 [_SunDirection]
Vector 18 [_AmbientNightSky]
Vector 19 [_EnvironmentAngles]
Vector 20 [_NuajLightningPosition00]
Vector 21 [_NuajLightningPosition01]
Vector 22 [_NuajLightningColor0]
Vector 23 [_NuajLightningPosition10]
Vector 24 [_NuajLightningPosition11]
Vector 25 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 26 [_ShadowAltitudesMinKm]
Vector 27 [_ShadowAltitudesMaxKm]
SetTexture 1 [_TexShadowMap] 2D
Float 28 [_DensitySeaLevel_Rayleigh]
Vector 29 [_Sigma_Rayleigh]
Float 30 [_DensitySeaLevel_Mie]
Float 31 [_Sigma_Mie]
Float 32 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexBackground] 2D
Float 33 [_bGodRays]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c34, 0.00000000, 0.15915491, 0.50000000, -1000000.00000000
def c35, 6.28318501, -3.14159298, 0.75000000, 2.00000000
def c36, 1.00000000, 0.00000000, 1.50000000, 1000000.00000000
def c37, 1000000.00000000, -1000000.00000000, 32.00000000, 0.03125000
defi i0, 255, 0, 1, 0
def c38, 2.71828198, 2.00000000, 3.00000000, -1.00000000
def c39, 1000.00000000, 10.00000000, 400.00000000, 0
def c40, 5.60204458, 9.47328472, 19.64380264, 0
def c41, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c19.zwzw, c19
mad r0.z, r0.x, c34.y, c34
mad r0.x, r0.y, c34.y, c34.z
frc r0.y, r0.z
frc r0.x, r0
mad r1.x, r0.y, c35, c35.y
mad r2.x, r0, c35, c35.y
sincos r0.xy, r1.x
sincos r1.xy, r2.x
mul r0.w, r1.y, r0.x
mul r1.y, r1, r0
mul r2.xyz, r1.x, c9
mad r2.xyz, r1.y, c10, r2
mad r8.xyz, r0.w, c11, r2
mul r2.xyz, r8.zxyw, c17.yzxw
mad r2.xyz, r8.yzxw, c17.zxyw, -r2
mov r0.y, c2.w
mov r0.x, c0.w
mul r7.xz, r0.xyyw, c14.x
mov r7.y, c34.x
add r0.xyz, r7, -c8
mul r1.xyz, r0.zxyw, c17.yzxw
mad r1.xyz, r0.yzxw, c17.zxyw, -r1
dp3 r0.w, r1, r1
mad r1.w, -c12.x, c12.x, r0
dp3 r0.w, r2, r2
mul r3.x, r0.w, r1.w
dp3 r1.w, r1, r2
mad r1.x, r1.w, r1.w, -r3
rsq r1.y, r1.x
rcp r3.x, r0.w
dp3 r0.w, r0, c17
rcp r2.z, r1.y
add r1.y, -r1.w, -r2.z
cmp r0.w, -r0, c36.x, c36.y
mul r1.y, r1, r3.x
cmp r1.x, -r1, c36.y, c36
mul_pp r0.w, r0, c15.x
mul_pp r2.y, r0.w, r1.x
cmp r2.x, -r2.y, c36.w, r1.y
mad r1.xyz, r8, r2.x, r7
add r1.xyz, r1, -c8
dp3 r0.w, r1, c17
cmp r1.x, -r0.w, c36.y, c36
dp3 r0.w, r0, r0
mul_pp r1.y, r2, r1.x
dp3 r0.x, r8, r0
mad r1.x, -c13, c13, r0.w
mad r0.y, r0.x, r0.x, -r1.x
add r1.x, -r1.w, r2.z
mul r1.x, r3, r1
rsq r0.z, r0.y
cmp r2.y, -r2, c34.w, r1.x
cmp r13.zw, -r1.y, r2.xyxy, c37.xyxy
rcp r0.z, r0.z
add r0.z, -r0.x, r0
max r1.x, r0.z, c34
cmp_pp r0.z, r0.y, c36.x, c36.y
mov r1.y, c12.x
cmp r0.y, r0, r2.w, c34.x
cmp r0.y, -r0.z, r0, r1.x
add r1.y, c26, r1
mad r1.x, -r1.y, r1.y, r0.w
mov r0.z, c12.x
add r1.y, c26.z, r0.z
mad r1.x, r0, r0, -r1
mad r1.y, -r1, r1, r0.w
mad r1.z, r0.x, r0.x, -r1.y
rsq r0.z, r1.x
rcp r0.z, r0.z
add r1.y, -r0.x, r0.z
cmp_pp r0.z, r1.x, c36.x, c36.y
cmp r1.x, r1, r2.w, c34.w
cmp r0.z, -r0, r1.x, r1.y
rsq r1.w, r1.z
rcp r1.x, r1.w
add r1.w, -r0.x, r1.x
min r0.z, r0.y, r0
max r2.x, r0.z, c34
cmp r1.y, r1.z, r2.w, c34.w
cmp_pp r1.x, r1.z, c36, c36.y
cmp r1.x, -r1, r1.y, r1.w
mov r0.z, c12.x
add r1.y, c26.w, r0.z
mad r1.y, -r1, r1, r0.w
min r1.x, r0.y, r1
mov r0.z, c12.x
add r0.z, c26.x, r0
mad r0.z, -r0, r0, r0.w
mad r1.y, r0.x, r0.x, -r1
rsq r0.w, r1.y
rcp r1.z, r0.w
mad r0.z, r0.x, r0.x, -r0
add r1.w, -r0.x, r1.z
cmp_pp r1.z, r1.y, c36.x, c36.y
rsq r0.w, r0.z
rcp r0.w, r0.w
add r0.w, -r0.x, r0
cmp_pp r0.x, r0.z, c36, c36.y
cmp r0.z, r0, r2.w, c34.w
cmp r0.x, -r0, r0.z, r0.w
min r0.z, r0.y, r0.x
max r4.x, r0.z, c34
cmp r1.y, r1, r2.w, c34.w
cmp r1.y, -r1.z, r1, r1.w
min r0.w, r0.y, r1.y
max r0.x, r0.w, c34
dp3 r0.w, r8, c17
mul r1.y, r0.w, c32.x
mad r0.w, r0, r0, c36.x
rcp r0.z, r0.y
mul r0.z, r0, c37
mul r9.w, r4.x, r0.z
mul r1.y, r1, c35.w
cmp_pp r1.z, -r9.w, c36.y, c36.x
mad r1.y, c32.x, c32.x, r1
add r1.y, r1, c36.x
pow r3, r1.y, c36.z
mul r13.x, r0.w, c35.z
mov r0.w, c32.x
mov r1.y, r3.x
add r0.w, c36.x, r0
rcp r1.y, r1.y
mul r0.w, r0, r0
max r1.x, r1, c34
mul r6.w, r0.y, c37
mul r13.y, r0.w, r1
mov r9.xyz, c36.x
mov r6.xyz, c34.x
mov r12.x, c34
if_gt r1.z, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.y, r0.w
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r0, r1.y, -r1.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r3.xyz, r10, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r12.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r5, r3.xyzz, s0
mul r0.w, r5, c31.x
mad r11.xyz, r5.z, -c29, -r0.w
pow r3, c38.x, r11.y
pow r14, c38.x, r11.x
mov r11.y, r3
pow r3, c38.x, r11.z
add r3.x, r12, r6.w
add r1.z, -r12.x, r13.w
rcp r1.y, r6.w
add r0.w, r3.x, -r13.z
mov r11.x, r14
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r11.z, r3
mul r11.xyz, r11, r0.w
mov r0.w, c34.x
mul r12.xyz, r11, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r14.xyz, r10
mov r14.w, c36.x
dp4 r3.w, r14, c5
dp4 r3.z, r14, c4
cmp r8.w, r0, c36.x, r8
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3.y, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mov r0.w, c26.y
mul r1.y, r1, r1.z
add r0.w, -c27.y, r0
rcp r1.z, r0.w
add r0.w, r3.y, -c27.y
mul_sat r0.w, r0, r1.z
mad r1.z, -r0.w, c38.y, c38
mul r0.w, r0, r0
mul r1.z, r0.w, r1
mov r0.w, c26.z
mov r11.xy, r3.zwzw
mov r11.z, c34.x
texldl r14, r11.xyzz, s1
add r1.w, r14.x, c38
mad r1.y, r1, r1.w, c36.x
add r1.w, r14.y, c38
mad r1.z, r1, r1.w, c36.x
add r1.w, -c27.z, r0
mul r0.w, r1.y, r1.z
rcp r1.z, r1.w
add r1.y, r3, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r14.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.y, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r14.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r8.w, r0, r1.z
endif
mul r12.xyz, r12, r8.w
endif
add r11.xyz, -r10, c23
dp3 r0.w, r11, r11
rsq r0.w, r0.w
mul r11.xyz, r0.w, r11
dp3 r1.y, r8, r11
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r11.xyz, c24
add r11.xyz, -c23, r11
dp3 r2.y, r11, r11
rsq r2.y, r2.y
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.w, r1, r1.z
add r10.xyz, -r10, c20
dp3 r1.z, r10, r10
rsq r1.z, r1.z
rcp r2.y, r2.y
mul r2.y, r2, r1.w
rcp r1.w, r0.w
mul r10.xyz, r1.z, r10
dp3 r0.w, r10, r8
mul r1.w, r1, c39.x
mul r1.w, r1, r1
mul r0.w, r0, c32.x
mov r10.xyz, c21
add r0.w, r0, c36.x
rcp r2.z, r1.w
rcp r1.w, r0.w
mul r1.y, r1, r1.w
mul r1.w, r1.y, r1
rcp r1.y, r1.z
mul r1.z, r1.y, c39.x
add r10.xyz, -c20, r10
dp3 r1.y, r10, r10
mul r0.w, r2.y, r2.z
mul r1.z, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r0.w, r0, c39.x
rcp r1.z, r1.z
mul r1.y, r1, r1.w
mul r1.y, r1, r1.z
min r1.z, r0.w, c36.x
mul r0.w, r1.y, c39.x
mul r1.y, r5, c30.x
min r0.w, r0, c36.x
mul r10.xyz, r1.z, c25
mad r10.xyz, r0.w, c22, r10
mul r0.w, r5.y, c31.x
mad r11.xyz, r5.x, c29, r0.w
mul r0.w, r5.x, c28.x
mul r10.xyz, r10, c39.y
mul r10.xyz, r1.y, r10
mul r10.xyz, r10, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r5.xyz, r0.w, c40, r1.y
mad r5.xyz, r12, r5, r10
mul r10.xyz, r6.w, -r11
add r11.xyz, r5, c18
pow r5, c38.x, r10.x
pow r12, c38.x, r10.y
mov r10.x, r5
pow r5, c38.x, r10.z
mul r11.xyz, r11, r6.w
mad r6.xyz, r11, r9, r6
mov r10.y, r12
mov r10.z, r5
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r3.xyz, r5, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r5.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r3, r3.xyzz, s0
mul r0.w, r3, c31.x
mad r11.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r11.y
pow r14, c38.x, r11.x
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
mov r11.y, r10
pow r10, c38.x, r11.z
add r0.w, r3.z, r12.x
rcp r1.y, r3.z
add r0.w, r0, -r13.z
add r1.z, -r12.x, r13.w
mov r11.x, r14
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r11.z, r10
mul r10.xyz, r11, r0.w
mov r0.w, c34.x
mul r10.xyz, r10, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r11.xyz, r5
mov r11.w, c36.x
dp4 r12.y, r11, c5
dp4 r12.x, r11, c4
cmp r7.w, r0, c36.x, r7
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mov r0.w, c26.y
mul r1.y, r1, r1.z
add r0.w, -c27.y, r0
rcp r1.z, r0.w
add r0.w, r3, -c27.y
mul_sat r0.w, r0, r1.z
mad r1.z, -r0.w, c38.y, c38
mul r0.w, r0, r0
mul r1.z, r0.w, r1
mov r0.w, c26.z
mov r11.xy, r12
mov r11.z, c34.x
texldl r11, r11.xyzz, s1
add r1.w, r11.x, c38
mad r1.y, r1, r1.w, c36.x
add r1.w, r11.y, c38
mad r1.z, r1, r1.w, c36.x
add r1.w, -c27.z, r0
mul r0.w, r1.y, r1.z
rcp r1.z, r1.w
add r1.y, r3.w, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r11.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.w, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r11.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r7.w, r0, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r11.xyz, -r5, c23
dp3 r0.w, r11, r11
rsq r0.w, r0.w
mul r11.xyz, r0.w, r11
dp3 r1.y, r8, r11
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r11.xyz, c24
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r2.y, r1.w, r1.z
add r11.xyz, -c23, r11
add r5.xyz, -r5, c20
dp3 r1.w, r11, r11
dp3 r1.z, r5, r5
rsq r1.z, r1.z
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r2.y
rcp r2.y, r0.w
mul r5.xyz, r1.z, r5
dp3 r0.w, r5, r8
mul r2.y, r2, c39.x
mul r0.w, r0, c32.x
mul r2.y, r2, r2
add r0.w, r0, c36.x
rcp r0.w, r0.w
mul r1.y, r1, r0.w
mul r1.y, r1, r0.w
rcp r0.w, r1.z
mul r1.z, r0.w, c39.x
rcp r2.y, r2.y
mul r1.w, r1, r2.y
mov r5.xyz, c21
add r5.xyz, -c20, r5
dp3 r0.w, r5, r5
mul r1.z, r1, r1
rsq r0.w, r0.w
rcp r0.w, r0.w
mul r0.w, r0, r1.y
mul r1.w, r1, c39.x
min r1.y, r1.w, c36.x
mul r5.xyz, r1.y, c25
rcp r1.z, r1.z
mul r0.w, r0, r1.z
mul r0.w, r0, c39.x
min r0.w, r0, c36.x
mad r5.xyz, r0.w, c22, r5
mul r0.w, r3.y, c31.x
mad r11.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r1.y, r3, c30.x
mul r5.xyz, r5, c39.y
mul r5.xyz, r1.y, r5
mul r5.xyz, r5, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.y
mad r5.xyz, r10, r12, r5
mul r10.xyz, r3.z, -r11
add r11.xyz, r5, c18
pow r5, c38.x, r10.x
mul r3.xyz, r11, r3.z
mad r6.xyz, r3, r9, r6
mov r10.x, r5
pow r5, c38.x, r10.y
pow r3, c38.x, r10.z
mov r10.y, r5
mov r10.z, r3
mul r9.xyz, r9, r10
endif
add r0.w, r2.x, -r4.x
mul r9.w, r0, r0.z
cmp_pp r0.w, -r9, c36.y, c36.x
mov r11.xyz, r6
mov r12.x, r4
mov r6.xyz, c34.x
if_gt r0.w, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.y, r0.w
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r0, r1.y, -r1.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r3.xyz, r10, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r12.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r5, r3.xyzz, s0
mul r0.w, r5, c31.x
mad r14.xyz, r5.z, -c29, -r0.w
pow r4, c38.x, r14.x
pow r3, c38.x, r14.y
mov r4.y, r3
pow r3, c38.x, r14.z
add r3.x, r12, r6.w
add r1.z, -r12.x, r13.w
rcp r1.y, r6.w
add r0.w, r3.x, -r13.z
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r4.z, r3
mul r4.xyz, r4, r0.w
mov r0.w, c34.x
mul r12.xyz, r4, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r4.xyz, r10
mov r4.w, c36.x
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r8.w, r0, c36.x, r8
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3.y, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mul r1.y, r1, r1.z
mov r0.w, c26.y
add r1.z, -c27.y, r0.w
rcp r1.z, r1.z
mov r4.xy, r3.zwzw
mov r4.z, c34.x
texldl r4, r4.xyzz, s1
add r1.w, r4.x, c38
mad r0.w, r1.y, r1, c36.x
add r1.y, r3, -c27
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
mul r1.z, r1.y, r1
add r1.w, r4.y, c38
mad r1.z, r1, r1.w, c36.x
mov r1.y, c26.z
mul r0.w, r0, r1.z
add r1.y, -c27.z, r1
rcp r1.z, r1.y
add r1.y, r3, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r4.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.y, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r4.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r8.w, r0, r1.z
endif
mul r12.xyz, r12, r8.w
endif
add r4.xyz, -r10, c23
dp3 r0.w, r4, r4
rsq r0.w, r0.w
mul r4.xyz, r0.w, r4
dp3 r1.y, r8, r4
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r4.xyz, c24
add r4.xyz, -c23, r4
dp3 r2.y, r4, r4
rsq r2.y, r2.y
add r10.xyz, -r10, c20
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.z, r1.w, r1
dp3 r1.w, r10, r10
rsq r1.w, r1.w
rcp r2.y, r2.y
mul r1.z, r2.y, r1
rcp r2.y, r0.w
mul r4.xyz, r1.w, r10
dp3 r0.w, r4, r8
mul r2.y, r2, c39.x
mul r2.y, r2, r2
mul r0.w, r0, c32.x
mov r4.xyz, c21
add r0.w, r0, c36.x
rcp r2.z, r2.y
rcp r2.y, r0.w
mul r0.w, r1.z, r2.z
mul r1.y, r1, r2
mul r1.z, r1.y, r2.y
rcp r1.y, r1.w
mul r1.w, r1.y, c39.x
add r4.xyz, -c20, r4
dp3 r1.y, r4, r4
mul r1.w, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r1.y, r1, r1.z
mul r0.w, r0, c39.x
min r1.z, r0.w, c36.x
rcp r1.w, r1.w
mul r1.y, r1, r1.w
mul r0.w, r1.y, c39.x
mul r1.y, r5, c30.x
min r0.w, r0, c36.x
mul r4.xyz, r1.z, c25
mad r4.xyz, r0.w, c22, r4
mul r0.w, r5.y, c31.x
mad r10.xyz, r5.x, c29, r0.w
mul r0.w, r5.x, c28.x
mul r4.xyz, r4, c39.y
mul r4.xyz, r1.y, r4
mul r10.xyz, r6.w, -r10
mul r4.xyz, r4, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r5.xyz, r0.w, c40, r1.y
mad r4.xyz, r12, r5, r4
add r5.xyz, r4, c18
pow r4, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r4
pow r5, c38.x, r10.y
pow r4, c38.x, r10.z
mov r10.y, r5
mov r10.z, r4
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r3.xyz, r5, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r5.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r3, r3.xyzz, s0
mul r0.w, r3, c31.x
mad r14.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r14.x
pow r4, c38.x, r14.y
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
add r0.w, r3.z, r12.x
mov r10.y, r4
pow r4, c38.x, r14.z
mov r10.z, r4
rcp r1.y, r3.z
add r0.w, r0, -r13.z
add r1.z, -r12.x, r13.w
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mul r4.xyz, r10, r0.w
mov r0.w, c34.x
mul r10.xyz, r4, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r4.xyz, r5
mov r4.w, c36.x
dp4 r12.y, r4, c5
dp4 r12.x, r4, c4
cmp r7.w, r0, c36.x, r7
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mov r0.w, c26.y
mul r1.y, r1, r1.z
add r0.w, -c27.y, r0
rcp r1.z, r0.w
add r0.w, r3, -c27.y
mul_sat r0.w, r0, r1.z
mad r1.z, -r0.w, c38.y, c38
mul r0.w, r0, r0
mul r1.z, r0.w, r1
mov r0.w, c26.z
mov r4.xy, r12
mov r4.z, c34.x
texldl r4, r4.xyzz, s1
add r1.w, r4.x, c38
mad r1.y, r1, r1.w, c36.x
add r1.w, r4.y, c38
mad r1.z, r1, r1.w, c36.x
add r1.w, -c27.z, r0
mul r0.w, r1.y, r1.z
rcp r1.z, r1.w
add r1.y, r3.w, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r4.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.w, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r4.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r7.w, r0, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r4.xyz, -r5, c23
dp3 r0.w, r4, r4
rsq r0.w, r0.w
mul r4.xyz, r0.w, r4
dp3 r1.y, r8, r4
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r4.xyz, c24
add r4.xyz, -c23, r4
dp3 r2.y, r4, r4
rsq r2.y, r2.y
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.w, r1, r1.z
add r5.xyz, -r5, c20
dp3 r1.z, r5, r5
rsq r1.z, r1.z
rcp r2.y, r2.y
mul r2.y, r2, r1.w
rcp r1.w, r0.w
mul r4.xyz, r1.z, r5
dp3 r0.w, r4, r8
mul r1.w, r1, c39.x
mul r1.w, r1, r1
mul r0.w, r0, c32.x
mov r4.xyz, c21
add r0.w, r0, c36.x
rcp r2.z, r1.w
rcp r1.w, r0.w
mul r1.y, r1, r1.w
mul r1.w, r1.y, r1
rcp r1.y, r1.z
mul r1.z, r1.y, c39.x
add r4.xyz, -c20, r4
dp3 r1.y, r4, r4
mul r0.w, r2.y, r2.z
mul r1.z, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r0.w, r0, c39.x
rcp r1.z, r1.z
mul r1.y, r1, r1.w
mul r1.y, r1, r1.z
min r1.z, r0.w, c36.x
mul r0.w, r1.y, c39.x
mul r1.y, r3, c30.x
min r0.w, r0, c36.x
mul r4.xyz, r1.z, c25
mad r4.xyz, r0.w, c22, r4
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r4.xyz, r4, c39.y
mul r4.xyz, r1.y, r4
mul r5.xyz, r3.z, -r5
mul r4.xyz, r4, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.y
mad r4.xyz, r10, r12, r4
add r10.xyz, r4, c18
pow r4, c38.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r4
pow r4, c38.x, r5.y
pow r3, c38.x, r5.z
mov r5.y, r4
mov r5.z, r3
mul r9.xyz, r9, r5
endif
add r0.w, r1.x, -r2.x
mul r9.w, r0, r0.z
cmp_pp r0.w, -r9, c36.y, c36.x
mov r4.xyz, r6
mov r12.x, r2
mov r6.xyz, c34.x
if_gt r0.w, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.y, r0.w
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r0, r1.y, -r1.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r2.xyz, r10, -c8
dp3 r0.w, r2, r2
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r2.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r2
add r1.y, r12.w, -c12.x
mul r2.y, r1, r1.z
add r0.w, -r0, c36.x
mul r2.x, r0.w, c34.z
mov r2.z, c34.x
texldl r5, r2.xyzz, s0
mul r0.w, r5, c31.x
mad r14.xyz, r5.z, -c29, -r0.w
pow r2, c38.x, r14.y
pow r3, c38.x, r14.x
mov r14.x, r3
mov r14.y, r2
pow r2, c38.x, r14.z
add r3.x, r12, r6.w
add r1.z, -r12.x, r13.w
rcp r1.y, r6.w
add r0.w, r3.x, -r13.z
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r14.z, r2
mul r2.xyz, r14, r0.w
mov r0.w, c34.x
mul r12.xyz, r2, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r2.xyz, r10
mov r2.w, c36.x
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r8.w, r0, c36.x, r8
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3.y, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mul r1.y, r1, r1.z
mov r0.w, c26.y
add r1.z, -c27.y, r0.w
rcp r1.z, r1.z
mov r2.xy, r3.zwzw
mov r2.z, c34.x
texldl r2, r2.xyzz, s1
add r1.w, r2.x, c38
mad r0.w, r1.y, r1, c36.x
add r1.y, r3, -c27
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
mul r1.z, r1.y, r1
add r1.w, r2.y, c38
mad r1.z, r1, r1.w, c36.x
mov r1.y, c26.z
mul r0.w, r0, r1.z
add r1.y, -c27.z, r1
rcp r1.z, r1.y
add r1.y, r3, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.x, r2.z, c38.w
mad r1.y, r1.z, r2.x, c36.x
rcp r1.w, r1.w
add r1.z, r3.y, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.x, r2.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.x, c36.x
mul r0.w, r0, r1.y
mul r8.w, r0, r1.z
endif
mul r12.xyz, r12, r8.w
endif
add r2.xyz, -r10, c23
dp3 r0.w, r2, r2
rsq r0.w, r0.w
mul r2.xyz, r0.w, r2
dp3 r1.y, r8, r2
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r2.xyz, c24
add r2.xyz, -c23, r2
dp3 r2.x, r2, r2
rsq r2.x, r2.x
add r10.xyz, -r10, c20
rcp r2.w, r0.w
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.z, r1.w, r1
dp3 r1.w, r10, r10
rcp r2.x, r2.x
rsq r1.w, r1.w
mul r1.z, r2.x, r1
mul r2.xyz, r1.w, r10
dp3 r0.w, r2, r8
mul r2.x, r2.w, c39
mul r2.x, r2, r2
mul r0.w, r0, c32.x
rcp r2.y, r2.x
add r0.w, r0, c36.x
rcp r2.x, r0.w
mul r0.w, r1.z, r2.y
mul r1.y, r1, r2.x
mul r1.y, r1, r2.x
rcp r1.z, r1.w
mul r1.w, r1.z, c39.x
mov r2.xyz, c21
add r2.xyz, -c20, r2
dp3 r1.z, r2, r2
mul r1.w, r1, r1
rsq r1.z, r1.z
rcp r1.z, r1.z
mul r0.w, r0, c39.x
mul r1.y, r1.z, r1
min r1.z, r0.w, c36.x
rcp r1.w, r1.w
mul r1.y, r1, r1.w
mul r0.w, r1.y, c39.x
mul r1.y, r5, c31.x
mad r10.xyz, r5.x, c29, r1.y
mul r10.xyz, r6.w, -r10
mul r2.xyz, r1.z, c25
min r0.w, r0, c36.x
mad r2.xyz, r0.w, c22, r2
mul r0.w, r5.y, c30.x
mul r2.xyz, r2, c39.y
mul r2.xyz, r0.w, r2
mul r1.y, r5.x, c28.x
mul r1.z, r13.y, r0.w
mul r0.w, r1.y, r13.x
mad r5.xyz, r0.w, c40, r1.z
mul r2.xyz, r2, c39.z
mad r2.xyz, r12, r5, r2
add r5.xyz, r2, c18
pow r2, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r2
pow r5, c38.x, r10.y
pow r2, c38.x, r10.z
mov r10.y, r5
mov r10.z, r2
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r2.xyz, r5, -c8
dp3 r0.w, r2, r2
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r2.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r2
add r1.y, r5.w, -c12.x
mul r2.y, r1, r1.z
add r0.w, -r0, c36.x
mul r2.x, r0.w, c34.z
mov r2.z, c34.x
texldl r3, r2.xyzz, s0
mul r0.w, r3, c31.x
mad r14.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r14.x
pow r2, c38.x, r14.y
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
add r0.w, r3.z, r12.x
mov r10.y, r2
pow r2, c38.x, r14.z
mov r10.z, r2
rcp r1.y, r3.z
add r0.w, r0, -r13.z
add r1.z, -r12.x, r13.w
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mul r2.xyz, r10, r0.w
mov r0.w, c34.x
mul r10.xyz, r2, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r2.xyz, r5
mov r2.w, c36.x
dp4 r12.y, r2, c5
dp4 r12.x, r2, c4
cmp r7.w, r0, c36.x, r7
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mul r1.y, r1, r1.z
mov r0.w, c26.y
add r1.z, -c27.y, r0.w
rcp r1.z, r1.z
mov r2.xy, r12
mov r2.z, c34.x
texldl r2, r2.xyzz, s1
add r1.w, r2.x, c38
mad r0.w, r1.y, r1, c36.x
add r1.y, r3.w, -c27
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
mul r1.z, r1.y, r1
add r1.w, r2.y, c38
mad r1.z, r1, r1.w, c36.x
mov r1.y, c26.z
mul r0.w, r0, r1.z
add r1.y, -c27.z, r1
rcp r1.z, r1.y
add r1.y, r3.w, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.x, r2.z, c38.w
mad r1.y, r1.z, r2.x, c36.x
rcp r1.w, r1.w
add r1.z, r3.w, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.x, r2.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.x, c36.x
mul r0.w, r0, r1.y
mul r7.w, r0, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r2.xyz, -r5, c23
dp3 r0.w, r2, r2
rsq r0.w, r0.w
mul r2.xyz, r0.w, r2
dp3 r1.y, r8, r2
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r2.xyz, c24
add r2.xyz, -c23, r2
dp3 r2.x, r2, r2
rsq r2.x, r2.x
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.w, r1, r1.z
add r5.xyz, -r5, c20
dp3 r1.z, r5, r5
rcp r2.x, r2.x
rsq r1.z, r1.z
mul r1.w, r2.x, r1
mul r2.xyz, r1.z, r5
rcp r2.w, r0.w
dp3 r0.w, r2, r8
mul r2.x, r2.w, c39
mul r2.x, r2, r2
mul r0.w, r0, c32.x
rcp r2.y, r2.x
add r0.w, r0, c36.x
rcp r2.x, r0.w
mul r0.w, r1, r2.y
mul r1.y, r1, r2.x
mul r1.w, r1.y, r2.x
rcp r1.y, r1.z
mul r1.z, r1.y, c39.x
mov r2.xyz, c21
add r2.xyz, -c20, r2
dp3 r1.y, r2, r2
mul r1.z, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r0.w, r0, c39.x
rcp r1.z, r1.z
mul r1.y, r1, r1.w
mul r1.y, r1, r1.z
min r1.z, r0.w, c36.x
mul r0.w, r1.y, c39.x
mul r1.y, r3, c30.x
min r0.w, r0, c36.x
mul r2.xyz, r1.z, c25
mad r2.xyz, r0.w, c22, r2
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r2.xyz, r2, c39.y
mul r2.xyz, r1.y, r2
mul r5.xyz, r3.z, -r5
mul r2.xyz, r2, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.y
mad r2.xyz, r10, r12, r2
add r10.xyz, r2, c18
pow r2, c38.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r2
pow r3, c38.x, r5.y
pow r2, c38.x, r5.z
mov r5.y, r3
mov r5.z, r2
mul r9.xyz, r9, r5
endif
add r0.w, r0.x, -r1.x
mul r9.w, r0, r0.z
cmp_pp r0.w, -r9, c36.y, c36.x
mov r2.xyz, r6
mov r12.x, r1
mov r6.xyz, c34.x
if_gt r0.w, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.x, r0.w
frc r1.y, r1.x
add r1.x, r1, -r1.y
cmp r11.w, r0, r1.x, -r1.x
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r1.xyz, r10, -c8
dp3 r0.w, r1, r1
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r1.xyz, c17
rcp r2.w, r0.w
dp3 r0.w, c9, r1
add r1.w, r12, -c12.x
add r0.w, -r0, c36.x
mul r1.x, r0.w, c34.z
mul r1.y, r1.w, r2.w
mov r1.z, c34.x
texldl r5, r1.xyzz, s0
mul r0.w, r5, c31.x
mad r14.xyz, r5.z, -c29, -r0.w
pow r1, c38.x, r14.y
pow r3, c38.x, r14.x
mov r14.x, r3
mov r14.y, r1
pow r1, c38.x, r14.z
add r3.x, r12, r6.w
rcp r1.x, r6.w
add r1.y, -r12.x, r13.w
add r0.w, r3.x, -r13.z
mul_sat r0.w, r0, r1.x
mul_sat r1.y, r1.x, r1
mad r0.w, -r0, r1.y, c36.x
mov r14.z, r1
mul r1.xyz, r14, r0.w
mov r0.w, c34.x
mul r12.xyz, r1, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
mov r1.xyz, r10
mov r1.w, c36.x
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r0.w, c36.y, c36
cmp r8.w, r0, c36.x, r8
if_gt r1.x, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r2.w, r0.w
add r0.w, r3.y, -c27.x
mul_sat r2.w, r0, r2
mov r1.xy, r3.zwzw
mul r3.z, r2.w, r2.w
mov r1.z, c34.x
texldl r1, r1.xyzz, s1
add r0.w, r1.x, c38
mad r2.w, -r2, c38.y, c38.z
mul r2.w, r3.z, r2
mov r1.x, c26.y
add r1.x, -c27.y, r1
mad r0.w, r2, r0, c36.x
rcp r2.w, r1.x
add r1.x, r3.y, -c27.y
mul_sat r1.x, r1, r2.w
add r2.w, r1.y, c38
mad r1.y, -r1.x, c38, c38.z
mul r1.x, r1, r1
mul r1.y, r1.x, r1
mad r1.y, r1, r2.w, c36.x
mov r1.x, c26.z
mul r0.w, r0, r1.y
add r1.x, -c27.z, r1
rcp r1.y, r1.x
add r1.x, r3.y, -c27.z
mul_sat r1.x, r1, r1.y
add r2.w, r1.z, c38
mad r1.z, -r1.x, c38.y, c38
mul r1.y, r1.x, r1.x
mul r1.y, r1, r1.z
mov r1.x, c26.w
add r1.z, -c27.w, r1.x
mad r1.x, r1.y, r2.w, c36
rcp r1.z, r1.z
add r1.y, r3, -c27.w
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
add r1.w, r1, c38
mul r1.y, r1, r1.z
mad r1.y, r1, r1.w, c36.x
mul r0.w, r0, r1.x
mul r8.w, r0, r1.y
endif
mul r12.xyz, r12, r8.w
endif
add r1.xyz, -r10, c23
dp3 r0.w, r1, r1
rsq r0.w, r0.w
mul r1.xyz, r0.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c32
add r1.y, r1.x, c36.x
mul r1.x, -c32, c32
add r1.w, r1.x, c36.x
rcp r2.w, r1.y
mul r3.y, r1.w, r2.w
mov r1.xyz, c24
add r1.xyz, -c23, r1
dp3 r1.y, r1, r1
add r10.xyz, -r10, c20
dp3 r1.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r2.w, r1.x, r2
mul r1.xyz, r3.y, r10
rcp r3.z, r0.w
dp3 r0.w, r1, r8
mul r1.x, r3.z, c39
mul r1.x, r1, r1
mul r0.w, r0, c32.x
rcp r1.y, r1.x
add r0.w, r0, c36.x
rcp r1.x, r0.w
mul r0.w, r2, r1.y
mul r1.y, r1.w, r1.x
mul r1.w, r1.y, r1.x
mov r1.xyz, c21
add r1.xyz, -c20, r1
dp3 r1.x, r1, r1
rcp r2.w, r3.y
mul r2.w, r2, c39.x
mul r1.y, r2.w, r2.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r1.w
mul r1.w, r5.y, c31.x
mad r10.xyz, r5.x, c29, r1.w
rcp r1.y, r1.y
mul r10.xyz, r6.w, -r10
mul r1.x, r1, r1.y
mul r0.w, r0, c39.x
min r1.y, r0.w, c36.x
mul r0.w, r1.x, c39.x
mul r1.w, r5.x, c28.x
min r0.w, r0, c36.x
mul r1.xyz, r1.y, c25
mad r1.xyz, r0.w, c22, r1
mul r0.w, r5.y, c30.x
mul r1.xyz, r1, c39.y
mul r1.xyz, r0.w, r1
mul r2.w, r13.y, r0
mul r0.w, r1, r13.x
mad r5.xyz, r0.w, c40, r2.w
mul r1.xyz, r1, c39.z
mad r1.xyz, r12, r5, r1
add r5.xyz, r1, c18
pow r1, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r1
pow r5, c38.x, r10.y
pow r1, c38.x, r10.z
mov r10.y, r5
mov r10.z, r1
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r1.xyz, r5, -c8
dp3 r0.w, r1, r1
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r1.xyz, c17
rcp r2.w, r0.w
dp3 r0.w, c9, r1
add r1.w, r5, -c12.x
add r0.w, -r0, c36.x
mul r1.x, r0.w, c34.z
mul r1.y, r1.w, r2.w
mov r1.z, c34.x
texldl r3, r1.xyzz, s0
mul r0.w, r3, c31.x
mad r14.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r14.x
pow r1, c38.x, r14.y
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
add r0.w, r3.z, r12.x
mov r10.y, r1
pow r1, c38.x, r14.z
rcp r1.x, r3.z
add r0.w, r0, -r13.z
add r1.y, -r12.x, r13.w
mul_sat r0.w, r0, r1.x
mul_sat r1.y, r1.x, r1
mad r0.w, -r0, r1.y, c36.x
mov r10.z, r1
mul r1.xyz, r10, r0.w
mov r0.w, c34.x
mul r10.xyz, r1, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
mov r1.xyz, r5
mov r1.w, c36.x
dp4 r12.y, r1, c5
dp4 r12.x, r1, c4
cmp_pp r1.x, r0.w, c36.y, c36
cmp r7.w, r0, c36.x, r7
if_gt r1.x, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r2.w, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r2
mad r2.w, -r0, c38.y, c38.z
mov r1.xy, r12
mov r1.z, c34.x
texldl r1, r1.xyzz, s1
add r4.w, r1.x, c38
mul r1.x, r0.w, r0.w
mul r1.x, r1, r2.w
mov r0.w, c26.y
add r2.w, -c27.y, r0
mad r0.w, r1.x, r4, c36.x
rcp r2.w, r2.w
add r1.x, r3.w, -c27.y
mul_sat r1.x, r1, r2.w
add r2.w, r1.y, c38
mad r1.y, -r1.x, c38, c38.z
mul r1.x, r1, r1
mul r1.y, r1.x, r1
mad r1.y, r1, r2.w, c36.x
mov r1.x, c26.z
mul r0.w, r0, r1.y
add r1.x, -c27.z, r1
rcp r1.y, r1.x
add r1.x, r3.w, -c27.z
mul_sat r1.x, r1, r1.y
add r2.w, r1.z, c38
mad r1.z, -r1.x, c38.y, c38
mul r1.y, r1.x, r1.x
mul r1.y, r1, r1.z
mov r1.x, c26.w
add r1.z, -c27.w, r1.x
mad r1.x, r1.y, r2.w, c36
rcp r1.z, r1.z
add r1.y, r3.w, -c27.w
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
add r1.w, r1, c38
mul r1.y, r1, r1.z
mad r1.y, r1, r1.w, c36.x
mul r0.w, r0, r1.x
mul r7.w, r0, r1.y
endif
mul r10.xyz, r10, r7.w
endif
add r1.xyz, -r5, c23
dp3 r0.w, r1, r1
rsq r0.w, r0.w
mul r1.xyz, r0.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c32
add r1.y, r1.x, c36.x
mul r1.x, -c32, c32
add r1.w, r1.x, c36.x
rcp r2.w, r1.y
mul r3.w, r1, r2
mov r1.xyz, c24
add r1.xyz, -c23, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c20
dp3 r1.x, r5, r5
mul r2.w, r3, r2
rsq r3.w, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r2.w, r1.x, r2
mul r1.xyz, r3.w, r5
rcp r4.w, r0.w
dp3 r0.w, r1, r8
mul r1.x, r4.w, c39
mul r1.x, r1, r1
mul r0.w, r0, c32.x
rcp r1.y, r1.x
add r0.w, r0, c36.x
rcp r1.x, r0.w
mul r0.w, r2, r1.y
mul r1.y, r1.w, r1.x
mul r1.w, r1.y, r1.x
rcp r2.w, r3.w
mov r1.xyz, c21
add r1.xyz, -c20, r1
dp3 r1.x, r1, r1
mul r2.w, r2, c39.x
mul r1.y, r2.w, r2.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r1.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
mul r0.w, r0, c39.x
min r1.y, r0.w, c36.x
mul r0.w, r1.x, c39.x
mul r1.w, r3.y, c30.x
min r0.w, r0, c36.x
mul r1.xyz, r1.y, c25
mad r1.xyz, r0.w, c22, r1
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r1.xyz, r1, c39.y
mul r1.xyz, r1.w, r1
mul r5.xyz, r3.z, -r5
mul r1.w, r13.y, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.w
mul r1.xyz, r1, c39.z
mad r1.xyz, r10, r12, r1
add r10.xyz, r1, c18
pow r1, c38.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r1
pow r3, c38.x, r5.y
pow r1, c38.x, r5.z
mov r5.y, r3
mov r5.z, r1
mul r9.xyz, r9, r5
endif
add r0.y, r0, -r0.x
mov r1.xyz, r6
mov r12.x, r0
mul r9.w, r0.y, r0.z
cmp_pp r0.x, -r9.w, c36.y, c36
mov r6.xyz, c34.x
if_gt r0.x, c34.x
frc r0.x, r9.w
add r0.x, r9.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r11.w, r0.x, r0.y, -r0.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r0.xyz, r10, -c8
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r12.w, r0.x
mov r0.x, c13
add r1.w, -c12.x, r0.x
mov r0.xyz, c17
dp3 r0.x, c9, r0
add r0.x, -r0, c36
add r0.w, r12, -c12.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c34.x
mul r0.x, r0, c34.z
texldl r5, r0.xyzz, s0
mul r0.x, r5.w, c31
mad r14.xyz, r5.z, -c29, -r0.x
pow r0, c38.x, r14.y
pow r3, c38.x, r14.x
mov r14.x, r3
mov r14.y, r0
pow r0, c38.x, r14.z
add r3.x, r12, r6.w
rcp r0.y, r6.w
add r0.w, -r12.x, r13
add r0.x, r3, -r13.z
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c36
mov r14.z, r0
mul r0.xyz, r14, r0.x
mov r0.w, c34.x
mul r12.xyz, r0, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r1.w, r3.y, -c27
mov r0.xyz, r10
mov r0.w, c36.x
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c36.y, c36
cmp r8.w, r1, c36.x, r8
if_gt r0.x, c34.x
mov r0.w, c26.x
add r1.w, -c27.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c27.x
mul_sat r1.w, r1, r2
mov r0.xy, r3.zwzw
mov r0.z, c34.x
texldl r0, r0.xyzz, s1
mad r3.z, -r1.w, c38.y, c38
mul r2.w, r1, r1
mul r2.w, r2, r3.z
add r0.x, r0, c38.w
mov r1.w, c26.y
add r1.w, -c27.y, r1
mad r0.x, r2.w, r0, c36
rcp r2.w, r1.w
add r1.w, r3.y, -c27.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c38.w
mad r2.w, -r1, c38.y, c38.z
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c36.x
mov r0.y, c26.z
mul r0.x, r0, r1.w
add r0.y, -c27.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c27.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c38
mad r1.w, -r0.y, c38.y, c38.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c26.w
add r1.w, -c27, r0.y
mad r0.y, r0.z, r2.w, c36.x
rcp r1.w, r1.w
add r0.z, r3.y, -c27.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c38
mad r0.w, -r0.z, c38.y, c38.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c36.x
mul r0.x, r0, r0.y
mul r8.w, r0.x, r0.z
endif
mul r12.xyz, r12, r8.w
endif
add r0.xyz, -r10, c23
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c32
add r0.y, r0.x, c36.x
mul r0.x, -c32, c32
add r1.w, r0.x, c36.x
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c24
add r0.xyz, -c23, r0
dp3 r0.y, r0, r0
add r10.xyz, -r10, c20
dp3 r0.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r10
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c39.x
mul r0.x, r0, c32
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c36
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c39.x
mul r1.w, r0.y, r0.x
mov r0.xyz, c21
add r0.xyz, -c20, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c39.x
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
mul r1.w, r5.y, c31.x
mad r10.xyz, r5.x, c29, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c36.x
mul r0.w, r0.x, c39.x
mul r10.xyz, r6.w, -r10
min r0.w, r0, c36.x
mul r0.xyz, r0.y, c25
mad r0.xyz, r0.w, c22, r0
mul r0.w, r5.y, c30.x
mul r0.xyz, r0, c39.y
mul r0.xyz, r0.w, r0
mul r1.w, r5.x, c28.x
mul r2.w, r13.y, r0
mul r0.w, r1, r13.x
mad r5.xyz, r0.w, c40, r2.w
mul r0.xyz, r0, c39.z
mad r0.xyz, r12, r5, r0
add r5.xyz, r0, c18
pow r0, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r0
pow r5, c38.x, r10.y
pow r0, c38.x, r10.z
mov r10.y, r5
mov r10.z, r0
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r0.xyz, r5, -c8
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c13
add r1.w, -c12.x, r0.x
mov r0.xyz, c17
dp3 r0.x, c9, r0
add r0.x, -r0, c36
add r0.w, r5, -c12.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c34.x
mul r0.x, r0, c34.z
texldl r3, r0.xyzz, s0
mul r0.x, r3.w, c31
mad r7.xyz, r3.z, -c29, -r0.x
pow r0, c38.x, r7.y
pow r10, c38.x, r7.x
add r0.x, r9.w, -r11.w
mul r3.z, r0.x, r6.w
mov r7.y, r0
pow r0, c38.x, r7.z
add r0.x, r3.z, r12
rcp r0.y, r3.z
add r0.x, r0, -r13.z
add r0.w, -r12.x, r13
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c36
mov r7.x, r10
mov r7.z, r0
mul r0.xyz, r7, r0.x
mov r0.w, c34.x
mul r10.xyz, r0, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r1.w, r3, -c27
mov r0.xyz, r5
mov r0.w, c36.x
dp4 r12.y, r0, c5
dp4 r12.x, r0, c4
cmp_pp r0.x, r1.w, c36.y, c36
cmp r7.w, r1, c36.x, r7
if_gt r0.x, c34.x
mov r0.w, c26.x
add r1.w, -c27.x, r0
rcp r2.w, r1.w
add r1.w, r3, -c27.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c38.y, c38.z
mul r1.w, r2, r1
mov r0.xy, r12
mov r0.z, c34.x
texldl r0, r0.xyzz, s1
add r4.w, r0.x, c38
mov r0.x, c26.y
add r0.x, -c27.y, r0
rcp r2.w, r0.x
add r0.x, r3.w, -c27.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c38
mad r0.y, -r0.x, c38, c38.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c36.x
mov r0.x, c26.z
add r2.w, -c27.z, r0.x
mad r1.w, r1, r4, c36.x
mul r0.x, r1.w, r0.y
rcp r1.w, r2.w
add r0.y, r3.w, -c27.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c38
mad r1.w, -r0.y, c38.y, c38.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c26.w
add r1.w, -c27, r0.y
mad r0.y, r0.z, r2.w, c36.x
rcp r1.w, r1.w
add r0.z, r3.w, -c27.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c38
mad r0.w, -r0.z, c38.y, c38.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c36.x
mul r0.x, r0, r0.y
mul r7.w, r0.x, r0.z
endif
mul r10.xyz, r10, r7.w
endif
add r0.xyz, -r5, c23
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c32
add r0.y, r0.x, c36.x
mul r0.x, -c32, c32
rcp r2.w, r0.y
add r1.w, r0.x, c36.x
mul r3.w, r1, r2
mov r0.xyz, c24
add r0.xyz, -c23, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c20
mul r3.w, r3, r2
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.w, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c39.x
mul r0.x, r0, c32
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3.w, r0.y
add r0.x, r0, c36
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.w, r0.z, c39.x
mul r0.w, r0.y, r0.x
mov r0.xyz, c21
add r0.xyz, -c20, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c39.x
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c39.x
min r0.y, r3.w, c36.x
mul r1.w, r3.y, c30.x
min r0.w, r0, c36.x
mul r0.xyz, r0.y, c25
mad r0.xyz, r0.w, c22, r0
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r0.xyz, r0, c39.y
mul r0.xyz, r1.w, r0
mul r5.xyz, r3.z, -r5
mul r0.w, r0, r13.x
mul r1.w, r13.y, r1
mad r7.xyz, r0.w, c40, r1.w
mul r0.xyz, r0, c39.z
mad r0.xyz, r10, r7, r0
add r7.xyz, r0, c18
pow r0, c38.x, r5.x
mul r3.xyz, r7, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r0
pow r3, c38.x, r5.y
pow r0, c38.x, r5.z
mov r5.y, r3
mov r5.z, r0
mul r9.xyz, r9, r5
endif
add r0.xyz, r11, r4
add r0.xyz, r0, r2
add r0.xyz, r0, r1
add r1.xyz, r0, r6
texldl r0.xyz, v0, s2
mad oC0.xyz, r0, r9, r1
dp3 oC0.w, r9, c41

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
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Vector 10 [_PlanetTangent]
Vector 11 [_PlanetBiTangent]
Float 12 [_PlanetRadiusKm]
Float 13 [_PlanetAtmosphereRadiusKm]
Float 14 [_WorldUnit2Kilometer]
Float 15 [_bComputePlanetShadow]
Vector 16 [_SunColor]
Vector 17 [_SunDirection]
Vector 18 [_AmbientNightSky]
Vector 19 [_EnvironmentAngles]
Vector 20 [_NuajLightningPosition00]
Vector 21 [_NuajLightningPosition01]
Vector 22 [_NuajLightningColor0]
Vector 23 [_NuajLightningPosition10]
Vector 24 [_NuajLightningPosition11]
Vector 25 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 26 [_ShadowAltitudesMinKm]
Vector 27 [_ShadowAltitudesMaxKm]
SetTexture 1 [_TexShadowMap] 2D
Float 28 [_DensitySeaLevel_Rayleigh]
Vector 29 [_Sigma_Rayleigh]
Float 30 [_DensitySeaLevel_Mie]
Float 31 [_Sigma_Mie]
Float 32 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexCloudLayer0] 2D
SetTexture 3 [_TexCloudLayer1] 2D
SetTexture 4 [_TexCloudLayer2] 2D
SetTexture 5 [_TexCloudLayer3] 2D
SetTexture 6 [_TexBackground] 2D
Float 33 [_bGodRays]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[41] = { program.local[0..33],
		{ 0, -1000000, 0.75, 1 },
		{ 2, 1.5, 1000000, -1000000 },
		{ 32, 0.03125, 0.5, 2.718282 },
		{ 255, 0, 1, 3 },
		{ 5.6020446, 9.4732847, 19.643803, 1000 },
		{ 10, 400 },
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
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MADR  R2.xy, fragment.texcoord[0], c[19].zwzw, c[19];
COSR  R0.x, R2.y;
SINR  R1.x, R2.x;
SINR  R2.y, R2.y;
COSR  R2.x, R2.x;
MULR  R0.xyz, R0.x, c[9];
MULR  R1.x, R2.y, R1;
MADR  R1.xyz, R1.x, c[10], R0;
MULR  R2.x, R2.y, R2;
MADR  R1.xyz, R2.x, c[11], R1;
MOVR  R2, c[26];
MOVR  R4.w, c[34].y;
MOVR  R0.y, c[2].w;
MOVR  R0.x, c[0].w;
MULR  R3.xz, R0.xyyw, c[14].x;
MOVR  R3.y, c[34].x;
ADDR  R0.xyz, R3, -c[8];
DP3R  R4.x, R1, R0;
DP3R  R4.z, R0, R0;
ADDR  R2, R2, c[12].x;
MADR  R2, -R2, R2, R4.z;
MULR  R4.y, R4.x, R4.x;
SLTR  R5, R4.y, R2;
MOVXC RC.x, R5;
ADDR  R6, R4.y, -R2;
MOVR  R4.w(EQ.x), R0;
SGERC HC, R4.y, R2.yzwx;
RSQR  R5.x, R6.x;
RCPR  R5.x, R5.x;
ADDR  R4.w(NE), -R4.x, R5.x;
MADR  R2.x, -c[13], c[13], R4.z;
MOVR  R2.w, c[34].x;
SLTRC HC.w, R4.y, R2.x;
MOVR  R2.w(EQ), R0;
ADDR  R0.w, R4.y, -R2.x;
SGERC HC.w, R4.y, R2.x;
RSQR  R2.x, R6.w;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R0.w, -R4.x, R0;
MAXR  R2.w(NE), R0, c[34].x;
MINR  R0.w, R2, R4;
MAXR  R6.x, R0.w, c[34];
RCPR  R0.w, R2.w;
MULR  R4.w, R0, c[36].x;
MULR  R8.w, R6.x, R4;
MOVR  R0.w, c[34].y;
MOVR  R5.x, c[34].y;
MOVX  H0.x, c[34];
MOVXC RC.w, R8;
MOVX  H0.x(GT.w), c[34].w;
MOVXC RC.w, R5;
MOVR  R0.w(EQ), R1;
RCPR  R2.x, R2.x;
ADDR  R0.w(NE.z), -R4.x, R2.x;
RSQR  R2.x, R6.z;
MOVXC RC.z, R5;
MOVR  R5.x(EQ.z), R1.w;
RCPR  R2.x, R2.x;
ADDR  R5.x(NE.y), -R4, R2;
RSQR  R2.x, R6.y;
MOVR  R6.z, c[34].y;
MOVXC RC.y, R5;
MOVR  R6.z(EQ.y), R1.w;
RCPR  R2.x, R2.x;
ADDR  R6.z(NE.x), -R4.x, R2.x;
MULR  R2.xyz, R0.zxyw, c[17].yzxw;
MADR  R2.xyz, R0.yzxw, c[17].zxyw, -R2;
DP3R  R0.y, R0, c[17];
SLER  H0.y, R0, c[34].x;
MULR  R4.xyz, R1.zxyw, c[17].yzxw;
DP3R  R5.y, R2, R2;
MADR  R4.xyz, R1.yzxw, c[17].zxyw, -R4;
DP3R  R2.x, R2, R4;
DP3R  R2.z, R4, R4;
MADR  R2.y, -c[12].x, c[12].x, R5;
MULR  R4.x, R2.z, R2.y;
MULR  R4.y, R2.x, R2.x;
ADDR  R2.y, R4, -R4.x;
RSQR  R2.y, R2.y;
RCPR  R2.y, R2.y;
ADDR  R0.x, -R2, R2.y;
RCPR  R0.y, R2.z;
MOVR  R0.z, c[35].w;
SGTR  H0.z, R4.y, R4.x;
MULX  H0.y, H0, c[15].x;
MULX  H0.y, H0, H0.z;
MOVXC RC.x, H0.y;
MULR  R0.z(NE.x), R0.y, R0.x;
MOVR  R0.x, c[35].z;
ADDR  R2.x, -R2, -R2.y;
MULR  R0.x(NE), R2, R0.y;
MOVR  R0.y, R0.z;
MOVR  R5.zw, R0.xyxy;
MADR  R0.xyz, R1, R0.x, R3;
ADDR  R0.xyz, R0, -c[8];
DP3R  R0.x, R0, c[17];
SGTR  H0.z, R0.x, c[34].x;
MINR  R0.y, R2.w, R5.x;
MULXC HC.x, H0.y, H0.z;
MINR  R0.x, R2.w, R6.z;
MOVR  R5.zw(NE.x), c[35];
MAXR  R7.x, R0, c[34];
MINR  R0.x, R2.w, R0.w;
MAXR  R6.w, R0.x, c[34].x;
MOVXC RC.x, H0;
DP3R  R0.x, R1, c[17];
MAXR  R7.w, R0.y, c[34].x;
MULR  R0.y, R0.x, c[32].x;
MULR  R0.x, R0, R0;
MULR  R0.y, R0, c[35].x;
MADR  R0.y, c[32].x, c[32].x, R0;
MADR  R5.x, R0, c[34].z, c[34].z;
ADDR  R0.x, R0.y, c[34].w;
MOVR  R0.y, c[34].w;
POWR  R0.x, R0.x, c[35].y;
ADDR  R0.y, R0, c[32].x;
RCPR  R0.x, R0.x;
MULR  R0.y, R0, R0;
MULR  R5.y, R0, R0.x;
MULR  R0.w, R2, c[36].y;
MOVR  R0.xyz, c[34].w;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, c[34];
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R4.xyz, R10, -c[8];
DP3R  R4.x, R4, R4;
RSQR  R4.x, R4.x;
RCPR  R12.x, R4.x;
MOVR  R4.x, c[12];
ADDR  R6.z, -R4.x, c[13].x;
MOVR  R4.xyz, c[9];
DP3R  R4.x, R4, c[17];
MOVXC RC.x, c[33];
ADDR  R6.y, R12.x, -c[12].x;
RCPR  R6.z, R6.z;
MULR  R4.y, R6, R6.z;
MADR  R4.x, -R4, c[36].z, c[36].z;
TEX   R9, R4, texture[0], 2D;
MULR  R4.x, R9.w, c[31];
MADR  R4.xyz, R9.z, -c[29], -R4.x;
ADDR  R9.z, R8.x, R0.w;
ADDR  R6.z, -R8.x, R5.w;
RCPR  R7.y, R0.w;
ADDR  R6.y, R9.z, -R5.z;
POWR  R4.x, c[36].w, R4.x;
POWR  R4.y, c[36].w, R4.y;
POWR  R4.z, c[36].w, R4.z;
MULR_SAT R6.z, R7.y, R6;
MULR_SAT R6.y, R6, R7;
MULR  R6.y, R6, R6.z;
MADR  R4.xyz, -R6.y, R4, R4;
MULR  R8.xyz, R4, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R4.x, c[34].w;
SGERC HC.x, R9.w, c[27].w;
MOVR  R4.x(EQ), R3.w;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R4.x;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R4.y, R13, R3.w;
MOVR  R3.w, c[37];
MULR  R4.x, R4.y, R4.y;
MADR  R4.y, -R4, c[35].x, R3.w;
TEX   R12, R12, texture[1], 2D;
MULR  R4.y, R4.x, R4;
RCPR  R4.z, R14.x;
MULR_SAT R4.x, R13, R4.z;
MADR  R4.z, -R4.x, c[35].x, R3.w;
MULR  R4.x, R4, R4;
MULR  R4.z, R4.x, R4;
MADR  R4.y, R12, R4, -R4;
ADDR  R4.x, R4.y, c[34].w;
MADR  R4.y, R12.x, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
RCPR  R4.z, R14.z;
MULR_SAT R4.z, R4, R13;
MADR  R6.y, -R4.z, c[35].x, R3.w;
RCPR  R4.y, R14.w;
MULR_SAT R4.y, R4, R13.w;
MADR  R3.w, -R4.y, c[35].x, R3;
MULR  R4.y, R4, R4;
MULR  R3.w, R4.y, R3;
MULR  R4.z, R4, R4;
MULR  R4.z, R4, R6.y;
MADR  R4.y, R12.z, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R4.x, R4.x;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R4.xyz, -R10, c[23];
DP3R  R6.y, R4, R4;
RSQR  R7.y, R6.y;
MULR  R4.xyz, R7.y, R4;
RCPR  R7.y, R7.y;
MOVR  R6.y, c[34].w;
DP3R  R4.x, R1, R4;
MADR  R4.x, R4, c[32], R6.y;
RCPR  R9.w, R4.x;
MULR  R6.z, c[32].x, c[32].x;
MADR  R7.z, -R6, R9.w, R9.w;
MOVR  R4.xyz, c[23];
MULR  R7.z, R7, R9.w;
ADDR  R4.xyz, -R4, c[24];
DP3R  R9.w, R4, R4;
ADDR  R4.xyz, -R10, c[20];
RSQR  R9.w, R9.w;
RCPR  R9.w, R9.w;
DP3R  R10.x, R4, R4;
MULR  R9.w, R9, R7.z;
RSQR  R7.z, R10.x;
MULR  R4.xyz, R7.z, R4;
DP3R  R4.y, R4, R1;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
MADR  R4.z, R4.y, c[32].x, R6.y;
RCPR  R4.y, R4.x;
RCPR  R4.x, R4.z;
MADR  R4.z, -R6, R4.x, R4.x;
MULR  R4.y, R9.w, R4;
RCPR  R7.y, R7.z;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R4, R4.x;
MOVR  R4.xyz, c[20];
ADDR  R4.xyz, -R4, c[21];
DP3R  R4.y, R4, R4;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
RSQR  R4.y, R4.y;
RCPR  R4.y, R4.y;
MULR  R4.y, R4, R6.z;
RCPR  R4.x, R4.x;
MULR  R4.y, R4, R4.x;
MINR  R4.x, R6.y, c[34].w;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R9.x, c[28].x;
MINR  R6.y, R6, c[34].w;
MULR  R4.xyz, R4.x, c[25];
MADR  R4.xyz, R6.y, c[22], R4;
MULR  R6.y, R9, c[30].x;
MULR  R4.xyz, R4, c[39].x;
MULR  R4.xyz, R6.y, R4;
MULR  R6.y, R5, R6;
MULR  R6.z, R6, R5.x;
MADR  R10.xyz, R6.z, c[38], R6.y;
MULR  R4.xyz, R4, c[39].y;
MADR  R4.xyz, R8, R10, R4;
MULR  R6.y, R9, c[31].x;
ADDR  R4.xyz, R4, c[18];
MULR  R4.xyz, R4, R0.w;
MADR  R8.xyz, R9.x, c[29], R6.y;
MULR  R8.xyz, R0.w, -R8;
MADR  R2.xyz, R4, R0, R2;
POWR  R4.x, c[36].w, R8.x;
POWR  R4.y, c[36].w, R8.y;
POWR  R4.z, c[36].w, R8.z;
MULR  R0.xyz, R0, R4;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R4.xyz, R10, -c[8];
DP3R  R4.x, R4, R4;
RSQR  R4.x, R4.x;
RCPR  R11.w, R4.x;
MOVR  R4.x, c[12];
ADDR  R6.z, -R4.x, c[13].x;
MOVR  R4.xyz, c[9];
DP3R  R4.x, R4, c[17];
MOVXC RC.x, c[33];
ADDR  R6.y, R11.w, -c[12].x;
RCPR  R6.z, R6.z;
MULR  R4.y, R6, R6.z;
ADDR  R6.y, R8.w, -R10.w;
MULR  R8.w, R6.y, R0;
MADR  R4.x, -R4, c[36].z, c[36].z;
TEX   R9, R4, texture[0], 2D;
ADDR  R6.y, R8.w, R8.x;
MULR  R4.x, R9.w, c[31];
MADR  R4.xyz, R9.z, -c[29], -R4.x;
ADDR  R6.z, -R8.x, R5.w;
RCPR  R7.y, R8.w;
ADDR  R6.y, R6, -R5.z;
POWR  R4.x, c[36].w, R4.x;
POWR  R4.y, c[36].w, R4.y;
POWR  R4.z, c[36].w, R4.z;
MULR_SAT R6.z, R7.y, R6;
MULR_SAT R6.y, R6, R7;
MULR  R6.y, R6, R6.z;
MADR  R4.xyz, -R6.y, R4, R4;
MULR  R8.xyz, R4, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R4.x, c[34].w;
SGERC HC.x, R10.w, c[27].w;
MOVR  R4.x(EQ), R1.w;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R4.x;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R4.y, R12, R1.w;
MOVR  R1.w, c[37];
MULR  R4.x, R4.y, R4.y;
MADR  R4.y, -R4, c[35].x, R1.w;
TEX   R11, R9.zwzw, texture[1], 2D;
MULR  R4.y, R4.x, R4;
RCPR  R4.z, R13.x;
MULR_SAT R4.x, R12, R4.z;
MADR  R4.z, -R4.x, c[35].x, R1.w;
MULR  R4.x, R4, R4;
MULR  R4.z, R4.x, R4;
MADR  R4.y, R11, R4, -R4;
ADDR  R4.x, R4.y, c[34].w;
MADR  R4.y, R11.x, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
RCPR  R4.z, R13.z;
MULR_SAT R4.z, R4, R12;
MADR  R6.y, -R4.z, c[35].x, R1.w;
RCPR  R4.y, R13.w;
MULR_SAT R4.y, R4, R12.w;
MADR  R1.w, -R4.y, c[35].x, R1;
MULR  R4.y, R4, R4;
MULR  R1.w, R4.y, R1;
MULR  R4.z, R4, R4;
MULR  R4.z, R4, R6.y;
MADR  R4.y, R11.z, R4.z, -R4.z;
MADR  R4.x, R4.y, R4, R4;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R4.x, R4.x;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R4.xyz, -R10, c[23];
DP3R  R6.y, R4, R4;
RSQR  R7.y, R6.y;
MULR  R4.xyz, R7.y, R4;
RCPR  R7.y, R7.y;
MOVR  R6.y, c[34].w;
DP3R  R4.x, R1, R4;
MADR  R4.x, R4, c[32], R6.y;
RCPR  R9.z, R4.x;
MULR  R6.z, c[32].x, c[32].x;
MADR  R7.z, -R6, R9, R9;
MOVR  R4.xyz, c[23];
MULR  R7.z, R7, R9;
ADDR  R4.xyz, -R4, c[24];
DP3R  R9.z, R4, R4;
ADDR  R4.xyz, -R10, c[20];
RSQR  R9.z, R9.z;
RCPR  R9.z, R9.z;
DP3R  R9.w, R4, R4;
MULR  R9.z, R9, R7;
RSQR  R7.z, R9.w;
MULR  R4.xyz, R7.z, R4;
DP3R  R4.y, R4, R1;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
MADR  R4.z, R4.y, c[32].x, R6.y;
RCPR  R4.y, R4.x;
RCPR  R4.x, R4.z;
MADR  R4.z, -R6, R4.x, R4.x;
MULR  R4.y, R9.z, R4;
RCPR  R7.y, R7.z;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R4, R4.x;
MOVR  R4.xyz, c[20];
ADDR  R4.xyz, -R4, c[21];
DP3R  R4.y, R4, R4;
MULR  R7.y, R7, c[38].w;
MULR  R4.x, R7.y, R7.y;
RSQR  R4.y, R4.y;
RCPR  R4.y, R4.y;
MULR  R4.y, R4, R6.z;
RCPR  R4.x, R4.x;
MULR  R4.y, R4, R4.x;
MINR  R4.x, R6.y, c[34].w;
MULR  R6.y, R4, c[38].w;
MULR  R6.z, R9.x, c[28].x;
MINR  R6.y, R6, c[34].w;
MULR  R4.xyz, R4.x, c[25];
MADR  R4.xyz, R6.y, c[22], R4;
MULR  R6.y, R9, c[30].x;
MULR  R4.xyz, R4, c[39].x;
MULR  R4.xyz, R6.y, R4;
MULR  R6.y, R5, R6;
MULR  R6.z, R6, R5.x;
MADR  R10.xyz, R6.z, c[38], R6.y;
MULR  R4.xyz, R4, c[39].y;
MADR  R4.xyz, R8, R10, R4;
MULR  R6.y, R9, c[31].x;
ADDR  R4.xyz, R4, c[18];
MULR  R4.xyz, R4, R8.w;
MADR  R8.xyz, R9.x, c[29], R6.y;
MADR  R2.xyz, R4, R0, R2;
MULR  R8.xyz, R8.w, -R8;
POWR  R4.x, c[36].w, R8.x;
POWR  R4.y, c[36].w, R8.y;
POWR  R4.z, c[36].w, R8.z;
MULR  R0.xyz, R0, R4;
ENDIF;
ADDR  R4.x, R7, -R6;
MULR  R8.w, R4.x, R4;
MOVR  R4.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R6;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R6.xyz, R10, -c[8];
DP3R  R6.x, R6, R6;
RSQR  R6.x, R6.x;
RCPR  R12.x, R6.x;
MOVR  R6.x, c[12];
ADDR  R7.z, -R6.x, c[13].x;
MOVR  R6.xyz, c[9];
DP3R  R6.x, R6, c[17];
MOVXC RC.x, c[33];
ADDR  R7.y, R12.x, -c[12].x;
RCPR  R7.z, R7.z;
MULR  R6.y, R7, R7.z;
MADR  R6.x, -R6, c[36].z, c[36].z;
TEX   R9, R6, texture[0], 2D;
MULR  R6.x, R9.w, c[31];
MADR  R6.xyz, R9.z, -c[29], -R6.x;
ADDR  R9.z, R8.x, R0.w;
ADDR  R7.z, -R8.x, R5.w;
RCPR  R8.x, R0.w;
ADDR  R7.y, R9.z, -R5.z;
MULR_SAT R7.y, R7, R8.x;
MULR_SAT R7.z, R8.x, R7;
POWR  R6.x, c[36].w, R6.x;
POWR  R6.y, c[36].w, R6.y;
POWR  R6.z, c[36].w, R6.z;
MULR  R7.y, R7, R7.z;
MADR  R6.xyz, -R7.y, R6, R6;
MULR  R8.xyz, R6, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R6.x, c[34].w;
SGERC HC.x, R9.w, c[27].w;
MOVR  R6.x(EQ), R3.w;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R6.x;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R6.y, R13, R3.w;
MOVR  R3.w, c[37];
MULR  R6.x, R6.y, R6.y;
MADR  R6.y, -R6, c[35].x, R3.w;
TEX   R12, R12, texture[1], 2D;
MULR  R6.y, R6.x, R6;
RCPR  R6.z, R14.x;
MULR_SAT R6.x, R13, R6.z;
MADR  R6.z, -R6.x, c[35].x, R3.w;
MULR  R6.x, R6, R6;
MULR  R6.z, R6.x, R6;
MADR  R6.y, R12, R6, -R6;
ADDR  R6.x, R6.y, c[34].w;
MADR  R6.y, R12.x, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
RCPR  R6.z, R14.z;
MULR_SAT R6.z, R6, R13;
MADR  R7.y, -R6.z, c[35].x, R3.w;
RCPR  R6.y, R14.w;
MULR_SAT R6.y, R6, R13.w;
MADR  R3.w, -R6.y, c[35].x, R3;
MULR  R6.y, R6, R6;
MULR  R3.w, R6.y, R3;
MULR  R6.z, R6, R6;
MULR  R6.z, R6, R7.y;
MADR  R6.y, R12.z, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R6.x, R6.x;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R6.xyz, -R10, c[23];
DP3R  R7.y, R6, R6;
RSQR  R9.w, R7.y;
MULR  R6.xyz, R9.w, R6;
RCPR  R9.w, R9.w;
MOVR  R7.y, c[34].w;
DP3R  R6.x, R1, R6;
MADR  R6.x, R6, c[32], R7.y;
RCPR  R11.y, R6.x;
MULR  R7.z, c[32].x, c[32].x;
MADR  R11.x, -R7.z, R11.y, R11.y;
MOVR  R6.xyz, c[23];
ADDR  R6.xyz, -R6, c[24];
MULR  R11.x, R11, R11.y;
DP3R  R11.y, R6, R6;
ADDR  R6.xyz, -R10, c[20];
DP3R  R10.x, R6, R6;
RSQR  R10.x, R10.x;
MULR  R6.xyz, R10.x, R6;
DP3R  R6.y, R6, R1;
MULR  R9.w, R9, c[38];
MULR  R6.x, R9.w, R9.w;
MADR  R6.z, R6.y, c[32].x, R7.y;
RCPR  R6.y, R6.x;
RCPR  R6.x, R6.z;
MADR  R6.z, -R7, R6.x, R6.x;
RCPR  R9.w, R10.x;
RSQR  R10.y, R11.y;
RCPR  R10.y, R10.y;
MULR  R10.y, R10, R11.x;
MULR  R6.y, R10, R6;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R6, R6.x;
MOVR  R6.xyz, c[20];
ADDR  R6.xyz, -R6, c[21];
DP3R  R6.y, R6, R6;
MULR  R9.w, R9, c[38];
MULR  R6.x, R9.w, R9.w;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
MULR  R6.y, R6, R7.z;
RCPR  R6.x, R6.x;
MULR  R6.y, R6, R6.x;
MINR  R6.x, R7.y, c[34].w;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R9.x, c[28].x;
MINR  R7.y, R7, c[34].w;
MULR  R6.xyz, R6.x, c[25];
MADR  R6.xyz, R7.y, c[22], R6;
MULR  R7.y, R9, c[30].x;
MULR  R6.xyz, R6, c[39].x;
MULR  R6.xyz, R7.y, R6;
MULR  R7.y, R5, R7;
MULR  R7.z, R7, R5.x;
MADR  R10.xyz, R7.z, c[38], R7.y;
MULR  R6.xyz, R6, c[39].y;
MADR  R6.xyz, R8, R10, R6;
MULR  R7.y, R9, c[31].x;
ADDR  R6.xyz, R6, c[18];
MULR  R6.xyz, R6, R0.w;
MADR  R8.xyz, R9.x, c[29], R7.y;
MULR  R8.xyz, R0.w, -R8;
MADR  R2.xyz, R6, R0, R2;
POWR  R6.x, c[36].w, R8.x;
POWR  R6.y, c[36].w, R8.y;
POWR  R6.z, c[36].w, R8.z;
MULR  R0.xyz, R0, R6;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R6.xyz, R10, -c[8];
DP3R  R6.x, R6, R6;
RSQR  R6.x, R6.x;
RCPR  R11.w, R6.x;
MOVR  R6.x, c[12];
ADDR  R7.z, -R6.x, c[13].x;
MOVR  R6.xyz, c[9];
DP3R  R6.x, R6, c[17];
MOVXC RC.x, c[33];
ADDR  R7.y, R11.w, -c[12].x;
RCPR  R7.z, R7.z;
MULR  R6.y, R7, R7.z;
ADDR  R7.y, R8.w, -R10.w;
MULR  R8.w, R7.y, R0;
MADR  R6.x, -R6, c[36].z, c[36].z;
TEX   R9, R6, texture[0], 2D;
ADDR  R7.y, R8.w, R8.x;
ADDR  R7.z, -R8.x, R5.w;
RCPR  R8.x, R8.w;
MULR  R6.x, R9.w, c[31];
MADR  R6.xyz, R9.z, -c[29], -R6.x;
ADDR  R7.y, R7, -R5.z;
MULR_SAT R7.y, R7, R8.x;
MULR_SAT R7.z, R8.x, R7;
POWR  R6.x, c[36].w, R6.x;
POWR  R6.y, c[36].w, R6.y;
POWR  R6.z, c[36].w, R6.z;
MULR  R7.y, R7, R7.z;
MADR  R6.xyz, -R7.y, R6, R6;
MULR  R8.xyz, R6, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R6.x, c[34].w;
SGERC HC.x, R10.w, c[27].w;
MOVR  R6.x(EQ), R1.w;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R6.x;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R6.y, R12, R1.w;
MOVR  R1.w, c[37];
MULR  R6.x, R6.y, R6.y;
MADR  R6.y, -R6, c[35].x, R1.w;
TEX   R11, R9.zwzw, texture[1], 2D;
MULR  R6.y, R6.x, R6;
RCPR  R6.z, R13.x;
MULR_SAT R6.x, R12, R6.z;
MADR  R6.z, -R6.x, c[35].x, R1.w;
MULR  R6.x, R6, R6;
MULR  R6.z, R6.x, R6;
MADR  R6.y, R11, R6, -R6;
ADDR  R6.x, R6.y, c[34].w;
MADR  R6.y, R11.x, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
RCPR  R6.z, R13.z;
MULR_SAT R6.z, R6, R12;
MADR  R7.y, -R6.z, c[35].x, R1.w;
RCPR  R6.y, R13.w;
MULR_SAT R6.y, R6, R12.w;
MADR  R1.w, -R6.y, c[35].x, R1;
MULR  R6.y, R6, R6;
MULR  R1.w, R6.y, R1;
MULR  R6.z, R6, R6;
MULR  R6.z, R6, R7.y;
MADR  R6.y, R11.z, R6.z, -R6.z;
MADR  R6.x, R6.y, R6, R6;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R6.x, R6.x;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R6.xyz, -R10, c[23];
DP3R  R7.y, R6, R6;
RSQR  R9.z, R7.y;
MULR  R6.xyz, R9.z, R6;
RCPR  R9.z, R9.z;
MOVR  R7.y, c[34].w;
DP3R  R6.x, R1, R6;
MADR  R6.x, R6, c[32], R7.y;
RCPR  R10.w, R6.x;
MULR  R7.z, c[32].x, c[32].x;
MADR  R9.w, -R7.z, R10, R10;
MOVR  R6.xyz, c[23];
MULR  R9.w, R9, R10;
ADDR  R6.xyz, -R6, c[24];
DP3R  R10.w, R6, R6;
ADDR  R6.xyz, -R10, c[20];
RSQR  R10.x, R10.w;
RCPR  R10.x, R10.x;
MULR  R10.x, R10, R9.w;
DP3R  R10.y, R6, R6;
RSQR  R9.w, R10.y;
MULR  R6.xyz, R9.w, R6;
DP3R  R6.y, R6, R1;
MULR  R9.z, R9, c[38].w;
MULR  R6.x, R9.z, R9.z;
MADR  R6.z, R6.y, c[32].x, R7.y;
RCPR  R6.y, R6.x;
RCPR  R6.x, R6.z;
MULR  R6.y, R10.x, R6;
MADR  R6.z, -R7, R6.x, R6.x;
RCPR  R9.z, R9.w;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R6, R6.x;
MOVR  R6.xyz, c[20];
ADDR  R6.xyz, -R6, c[21];
DP3R  R6.y, R6, R6;
MULR  R9.z, R9, c[38].w;
MULR  R6.x, R9.z, R9.z;
RSQR  R6.y, R6.y;
RCPR  R6.y, R6.y;
MULR  R6.y, R6, R7.z;
RCPR  R6.x, R6.x;
MULR  R6.y, R6, R6.x;
MINR  R6.x, R7.y, c[34].w;
MULR  R7.y, R6, c[38].w;
MULR  R7.z, R9.x, c[28].x;
MINR  R7.y, R7, c[34].w;
MULR  R6.xyz, R6.x, c[25];
MADR  R6.xyz, R7.y, c[22], R6;
MULR  R7.y, R9, c[30].x;
MULR  R6.xyz, R6, c[39].x;
MULR  R6.xyz, R7.y, R6;
MULR  R7.y, R5, R7;
MULR  R7.z, R7, R5.x;
MADR  R10.xyz, R7.z, c[38], R7.y;
MULR  R6.xyz, R6, c[39].y;
MADR  R6.xyz, R8, R10, R6;
MULR  R7.y, R9, c[31].x;
ADDR  R6.xyz, R6, c[18];
MULR  R6.xyz, R6, R8.w;
MADR  R8.xyz, R9.x, c[29], R7.y;
MADR  R2.xyz, R6, R0, R2;
MULR  R8.xyz, R8.w, -R8;
POWR  R6.x, c[36].w, R8.x;
POWR  R6.y, c[36].w, R8.y;
POWR  R6.z, c[36].w, R8.z;
MULR  R0.xyz, R0, R6;
ENDIF;
ADDR  R6.x, R7.w, -R7;
MULR  R8.w, R6.x, R4;
MOVR  R6.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R7;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R7.xyz, R10, -c[8];
DP3R  R7.x, R7, R7;
RSQR  R7.x, R7.x;
RCPR  R12.x, R7.x;
MOVR  R7.x, c[12];
ADDR  R8.z, -R7.x, c[13].x;
MOVR  R7.xyz, c[9];
DP3R  R7.x, R7, c[17];
MOVXC RC.x, c[33];
ADDR  R8.y, R12.x, -c[12].x;
RCPR  R8.z, R8.z;
MULR  R7.y, R8, R8.z;
MADR  R7.x, -R7, c[36].z, c[36].z;
TEX   R9, R7, texture[0], 2D;
MULR  R7.x, R9.w, c[31];
MADR  R7.xyz, R9.z, -c[29], -R7.x;
ADDR  R9.z, R8.x, R0.w;
RCPR  R8.z, R0.w;
ADDR  R8.y, R9.z, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R8.x, R8.z, R8;
MULR_SAT R8.y, R8, R8.z;
MULR  R8.x, R8.y, R8;
POWR  R7.x, c[36].w, R7.x;
POWR  R7.y, c[36].w, R7.y;
POWR  R7.z, c[36].w, R7.z;
MADR  R7.xyz, -R8.x, R7, R7;
MULR  R8.xyz, R7, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R7.x, c[34].w;
SGERC HC.x, R9.w, c[27].w;
MOVR  R7.x(EQ), R3.w;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R7.x;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R7.y, R13, R3.w;
MOVR  R3.w, c[37];
MULR  R7.x, R7.y, R7.y;
MADR  R7.y, -R7, c[35].x, R3.w;
TEX   R12, R12, texture[1], 2D;
MULR  R7.y, R7.x, R7;
RCPR  R7.z, R14.x;
MULR_SAT R7.x, R13, R7.z;
MADR  R7.z, -R7.x, c[35].x, R3.w;
MULR  R7.x, R7, R7;
MULR  R7.z, R7.x, R7;
MADR  R7.y, R12, R7, -R7;
ADDR  R7.x, R7.y, c[34].w;
MADR  R7.y, R12.x, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
RCPR  R7.z, R14.z;
MULR_SAT R7.z, R7, R13;
MADR  R9.w, -R7.z, c[35].x, R3;
RCPR  R7.y, R14.w;
MULR_SAT R7.y, R7, R13.w;
MADR  R3.w, -R7.y, c[35].x, R3;
MULR  R7.y, R7, R7;
MULR  R3.w, R7.y, R3;
MULR  R7.z, R7, R7;
MULR  R7.z, R7, R9.w;
MADR  R7.y, R12.z, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R7.x, R7.x;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R7.xyz, -R10, c[23];
DP3R  R9.w, R7, R7;
RSQR  R11.y, R9.w;
MULR  R7.xyz, R11.y, R7;
MOVR  R9.w, c[34];
DP3R  R7.x, R1, R7;
MADR  R7.x, R7, c[32], R9.w;
RCPR  R12.x, R7.x;
MULR  R11.x, c[32], c[32];
MADR  R11.z, -R11.x, R12.x, R12.x;
MOVR  R7.xyz, c[23];
ADDR  R7.xyz, -R7, c[24];
MULR  R11.z, R11, R12.x;
DP3R  R12.x, R7, R7;
ADDR  R7.xyz, -R10, c[20];
DP3R  R10.x, R7, R7;
RSQR  R10.x, R10.x;
MULR  R7.xyz, R10.x, R7;
DP3R  R7.y, R7, R1;
RSQR  R10.y, R12.x;
RCPR  R10.y, R10.y;
RCPR  R10.z, R11.y;
MULR  R10.z, R10, c[38].w;
RCPR  R10.x, R10.x;
MADR  R7.z, R7.y, c[32].x, R9.w;
MULR  R7.x, R10.z, R10.z;
RCPR  R7.y, R7.x;
RCPR  R7.x, R7.z;
MULR  R10.y, R10, R11.z;
MULR  R7.y, R10, R7;
MADR  R7.z, -R11.x, R7.x, R7.x;
MULR  R9.w, R7.y, c[38];
MULR  R10.y, R7.z, R7.x;
MOVR  R7.xyz, c[20];
ADDR  R7.xyz, -R7, c[21];
DP3R  R7.y, R7, R7;
MULR  R10.x, R10, c[38].w;
MULR  R7.x, R10, R10;
RSQR  R7.y, R7.y;
RCPR  R7.y, R7.y;
MULR  R10.x, R9, c[28];
MULR  R7.y, R7, R10;
RCPR  R7.x, R7.x;
MULR  R7.y, R7, R7.x;
MINR  R7.x, R9.w, c[34].w;
MULR  R9.w, R7.y, c[38];
MINR  R9.w, R9, c[34];
MULR  R7.xyz, R7.x, c[25];
MADR  R7.xyz, R9.w, c[22], R7;
MULR  R9.w, R9.y, c[30].x;
MULR  R7.xyz, R7, c[39].x;
MULR  R7.xyz, R9.w, R7;
MULR  R7.xyz, R7, c[39].y;
MULR  R9.w, R5.y, R9;
MULR  R10.x, R10, R5;
MADR  R10.xyz, R10.x, c[38], R9.w;
MADR  R7.xyz, R8, R10, R7;
MULR  R8.x, R9.y, c[31];
ADDR  R7.xyz, R7, c[18];
MULR  R7.xyz, R7, R0.w;
MADR  R8.xyz, R9.x, c[29], R8.x;
MULR  R8.xyz, R0.w, -R8;
MADR  R2.xyz, R7, R0, R2;
POWR  R7.x, c[36].w, R8.x;
POWR  R7.y, c[36].w, R8.y;
POWR  R7.z, c[36].w, R8.z;
MULR  R0.xyz, R0, R7;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R7.xyz, R10, -c[8];
DP3R  R7.x, R7, R7;
RSQR  R7.x, R7.x;
RCPR  R11.w, R7.x;
MOVR  R7.x, c[12];
ADDR  R8.z, -R7.x, c[13].x;
MOVR  R7.xyz, c[9];
DP3R  R7.x, R7, c[17];
MOVXC RC.x, c[33];
ADDR  R8.y, R11.w, -c[12].x;
RCPR  R8.z, R8.z;
MULR  R7.y, R8, R8.z;
ADDR  R8.y, R8.w, -R10.w;
MULR  R8.w, R8.y, R0;
ADDR  R8.y, R8.w, R8.x;
MADR  R7.x, -R7, c[36].z, c[36].z;
TEX   R9, R7, texture[0], 2D;
MULR  R7.x, R9.w, c[31];
MADR  R7.xyz, R9.z, -c[29], -R7.x;
RCPR  R8.z, R8.w;
ADDR  R8.y, R8, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R8.x, R8.z, R8;
MULR_SAT R8.y, R8, R8.z;
MULR  R8.x, R8.y, R8;
POWR  R7.x, c[36].w, R7.x;
POWR  R7.y, c[36].w, R7.y;
POWR  R7.z, c[36].w, R7.z;
MADR  R7.xyz, -R8.x, R7, R7;
MULR  R8.xyz, R7, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R7.x, c[34].w;
SGERC HC.x, R10.w, c[27].w;
MOVR  R7.x(EQ), R1.w;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R7.x;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
TEX   R11, R9.zwzw, texture[1], 2D;
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R7.y, R12, R1.w;
MOVR  R1.w, c[37];
MULR  R7.x, R7.y, R7.y;
MADR  R7.y, -R7, c[35].x, R1.w;
MULR  R7.y, R7.x, R7;
RCPR  R7.z, R13.x;
MULR_SAT R7.x, R12, R7.z;
MADR  R7.z, -R7.x, c[35].x, R1.w;
MULR  R7.x, R7, R7;
MULR  R7.z, R7.x, R7;
MADR  R7.y, R11, R7, -R7;
ADDR  R7.x, R7.y, c[34].w;
MADR  R7.y, R11.x, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
RCPR  R7.z, R13.z;
MULR_SAT R7.z, R7, R12;
MADR  R9.z, -R7, c[35].x, R1.w;
RCPR  R7.y, R13.w;
MULR_SAT R7.y, R7, R12.w;
MADR  R1.w, -R7.y, c[35].x, R1;
MULR  R7.y, R7, R7;
MULR  R1.w, R7.y, R1;
MULR  R7.z, R7, R7;
MULR  R7.z, R7, R9;
MADR  R7.y, R11.z, R7.z, -R7.z;
MADR  R7.x, R7.y, R7, R7;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R7.x, R7.x;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R7.xyz, -R10, c[23];
DP3R  R9.z, R7, R7;
RSQR  R10.w, R9.z;
MULR  R7.xyz, R10.w, R7;
MOVR  R9.z, c[34].w;
DP3R  R7.x, R1, R7;
MADR  R7.x, R7, c[32], R9.z;
RCPR  R11.y, R7.x;
MULR  R9.w, c[32].x, c[32].x;
MADR  R11.x, -R9.w, R11.y, R11.y;
MOVR  R7.xyz, c[23];
ADDR  R7.xyz, -R7, c[24];
MULR  R11.x, R11, R11.y;
DP3R  R11.y, R7, R7;
ADDR  R7.xyz, -R10, c[20];
DP3R  R10.x, R7, R7;
RSQR  R10.x, R10.x;
MULR  R7.xyz, R10.x, R7;
DP3R  R7.y, R7, R1;
RSQR  R10.y, R11.y;
RCPR  R10.y, R10.y;
RCPR  R10.z, R10.w;
MULR  R10.z, R10, c[38].w;
RCPR  R10.x, R10.x;
MADR  R7.z, R7.y, c[32].x, R9;
MULR  R7.x, R10.z, R10.z;
RCPR  R7.y, R7.x;
RCPR  R7.x, R7.z;
MADR  R7.z, -R9.w, R7.x, R7.x;
MULR  R10.y, R10, R11.x;
MULR  R7.y, R10, R7;
MULR  R9.z, R7.y, c[38].w;
MULR  R9.w, R7.z, R7.x;
MOVR  R7.xyz, c[20];
ADDR  R7.xyz, -R7, c[21];
DP3R  R7.y, R7, R7;
MULR  R10.x, R10, c[38].w;
MULR  R7.x, R10, R10;
RSQR  R7.y, R7.y;
RCPR  R7.y, R7.y;
MULR  R7.y, R7, R9.w;
RCPR  R7.x, R7.x;
MULR  R7.y, R7, R7.x;
MINR  R7.x, R9.z, c[34].w;
MULR  R9.z, R7.y, c[38].w;
MULR  R9.w, R9.x, c[28].x;
MINR  R9.z, R9, c[34].w;
MULR  R7.xyz, R7.x, c[25];
MADR  R7.xyz, R9.z, c[22], R7;
MULR  R9.z, R9.y, c[30].x;
MULR  R7.xyz, R7, c[39].x;
MULR  R7.xyz, R9.z, R7;
MULR  R7.xyz, R7, c[39].y;
MULR  R9.z, R5.y, R9;
MULR  R9.w, R9, R5.x;
MADR  R10.xyz, R9.w, c[38], R9.z;
MADR  R7.xyz, R8, R10, R7;
MULR  R8.x, R9.y, c[31];
ADDR  R7.xyz, R7, c[18];
MULR  R7.xyz, R7, R8.w;
MADR  R8.xyz, R9.x, c[29], R8.x;
MADR  R2.xyz, R7, R0, R2;
MULR  R8.xyz, R8.w, -R8;
POWR  R7.x, c[36].w, R8.x;
POWR  R7.y, c[36].w, R8.y;
POWR  R7.z, c[36].w, R8.z;
MULR  R0.xyz, R0, R7;
ENDIF;
ADDR  R7.x, R6.w, -R7.w;
MULR  R8.w, R7.x, R4;
MOVR  R7.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R7.w;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R9.xyz, R10, -c[8];
DP3R  R7.w, R9, R9;
MOVR  R9.xyz, c[9];
DP3R  R8.z, R9, c[17];
RSQR  R7.w, R7.w;
RCPR  R12.x, R7.w;
MOVR  R8.y, c[12].x;
ADDR  R8.y, -R8, c[13].x;
MOVXC RC.x, c[33];
ADDR  R7.w, R12.x, -c[12].x;
RCPR  R8.y, R8.y;
MULR  R9.y, R7.w, R8;
MADR  R9.x, -R8.z, c[36].z, c[36].z;
TEX   R9, R9, texture[0], 2D;
MULR  R7.w, R9, c[31].x;
MADR  R11.xyz, R9.z, -c[29], -R7.w;
ADDR  R9.z, R8.x, R0.w;
RCPR  R8.y, R0.w;
ADDR  R7.w, R9.z, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R7.w, R7, R8.y;
MULR_SAT R8.x, R8.y, R8;
POWR  R11.x, c[36].w, R11.x;
POWR  R11.y, c[36].w, R11.y;
POWR  R11.z, c[36].w, R11.z;
MULR  R7.w, R7, R8.x;
MADR  R8.xyz, -R7.w, R11, R11;
MULR  R8.xyz, R8, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R7.w, c[34];
SGERC HC.x, R9.w, c[27].w;
MOVR  R7.w(EQ.x), R3;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R7;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R3.w, R14.y;
MULR_SAT R9.w, R13.y, R3;
MOVR  R3.w, c[37];
MULR  R7.w, R9, R9;
MADR  R9.w, -R9, c[35].x, R3;
TEX   R12, R12, texture[1], 2D;
MULR  R9.w, R7, R9;
RCPR  R11.x, R14.x;
MULR_SAT R7.w, R13.x, R11.x;
MADR  R11.x, -R7.w, c[35], R3.w;
MULR  R7.w, R7, R7;
MULR  R11.x, R7.w, R11;
MADR  R9.w, R12.y, R9, -R9;
ADDR  R7.w, R9, c[34];
MADR  R9.w, R12.x, R11.x, -R11.x;
MADR  R7.w, R9, R7, R7;
RCPR  R11.x, R14.z;
MULR_SAT R11.x, R11, R13.z;
MADR  R11.y, -R11.x, c[35].x, R3.w;
RCPR  R9.w, R14.w;
MULR_SAT R9.w, R9, R13;
MADR  R3.w, -R9, c[35].x, R3;
MULR  R9.w, R9, R9;
MULR  R3.w, R9, R3;
MULR  R11.x, R11, R11;
MULR  R11.x, R11, R11.y;
MADR  R9.w, R12.z, R11.x, -R11.x;
MADR  R7.w, R9, R7, R7;
MADR  R3.w, R12, R3, -R3;
MADR  R3.w, R3, R7, R7;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R11.xyz, -R10, c[23];
DP3R  R7.w, R11, R11;
RSQR  R12.x, R7.w;
MULR  R11.xyz, R12.x, R11;
DP3R  R9.w, R1, R11;
MOVR  R7.w, c[34];
MADR  R9.w, R9, c[32].x, R7;
RCPR  R12.z, R9.w;
MULR  R9.w, c[32].x, c[32].x;
MADR  R12.y, -R9.w, R12.z, R12.z;
MOVR  R11.xyz, c[23];
ADDR  R11.xyz, -R11, c[24];
DP3R  R11.x, R11, R11;
RSQR  R11.y, R11.x;
ADDR  R10.xyz, -R10, c[20];
DP3R  R11.x, R10, R10;
RSQR  R11.x, R11.x;
MULR  R10.xyz, R11.x, R10;
DP3R  R10.y, R10, R1;
RCPR  R11.z, R12.x;
MULR  R11.z, R11, c[38].w;
RCPR  R11.x, R11.x;
MADR  R10.y, R10, c[32].x, R7.w;
MULR  R10.x, R11.z, R11.z;
RCPR  R7.w, R10.x;
RCPR  R10.x, R10.y;
MADR  R9.w, -R9, R10.x, R10.x;
MULR  R9.w, R9, R10.x;
MOVR  R10.xyz, c[20];
ADDR  R10.xyz, -R10, c[21];
DP3R  R10.y, R10, R10;
MULR  R11.x, R11, c[38].w;
MULR  R10.x, R11, R11;
RSQR  R10.y, R10.y;
RCPR  R10.y, R10.y;
MULR  R9.w, R10.y, R9;
RCPR  R10.x, R10.x;
MULR  R10.x, R9.w, R10;
MULR  R12.y, R12, R12.z;
RCPR  R11.y, R11.y;
MULR  R11.y, R11, R12;
MULR  R7.w, R11.y, R7;
MULR  R7.w, R7, c[38];
MINR  R9.w, R7, c[34];
MULR  R7.w, R10.x, c[38];
MULR  R10.xyz, R9.w, c[25];
MINR  R7.w, R7, c[34];
MADR  R10.xyz, R7.w, c[22], R10;
MULR  R9.w, R9.x, c[28].x;
MULR  R7.w, R9.y, c[30].x;
MULR  R10.xyz, R10, c[39].x;
MULR  R10.xyz, R7.w, R10;
MULR  R10.xyz, R10, c[39].y;
MULR  R7.w, R5.y, R7;
MULR  R9.w, R9, R5.x;
MADR  R11.xyz, R9.w, c[38], R7.w;
MADR  R8.xyz, R8, R11, R10;
MULR  R7.w, R9.y, c[31].x;
ADDR  R8.xyz, R8, c[18];
MULR  R8.xyz, R8, R0.w;
MADR  R10.xyz, R9.x, c[29], R7.w;
MADR  R2.xyz, R8, R0, R2;
MULR  R10.xyz, R0.w, -R10;
POWR  R8.x, c[36].w, R10.x;
POWR  R8.y, c[36].w, R10.y;
POWR  R8.z, c[36].w, R10.z;
MULR  R0.xyz, R0, R8;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R9.xyz, R10, -c[8];
DP3R  R7.w, R9, R9;
MOVR  R9.xyz, c[9];
DP3R  R8.z, R9, c[17];
RSQR  R7.w, R7.w;
RCPR  R11.w, R7.w;
MOVR  R8.y, c[12].x;
ADDR  R8.y, -R8, c[13].x;
MOVXC RC.x, c[33];
ADDR  R7.w, R11, -c[12].x;
RCPR  R8.y, R8.y;
MULR  R9.y, R7.w, R8;
MADR  R9.x, -R8.z, c[36].z, c[36].z;
TEX   R9, R9, texture[0], 2D;
MULR  R7.w, R9, c[31].x;
MADR  R11.xyz, R9.z, -c[29], -R7.w;
ADDR  R7.w, R8, -R10;
MULR  R8.w, R7, R0;
ADDR  R7.w, R8, R8.x;
RCPR  R8.y, R8.w;
ADDR  R7.w, R7, -R5.z;
ADDR  R8.x, -R8, R5.w;
MULR_SAT R7.w, R7, R8.y;
MULR_SAT R8.x, R8.y, R8;
POWR  R11.x, c[36].w, R11.x;
POWR  R11.y, c[36].w, R11.y;
POWR  R11.z, c[36].w, R11.z;
MULR  R7.w, R7, R8.x;
MADR  R8.xyz, -R7.w, R11, R11;
MULR  R8.xyz, R8, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R7.w, c[34];
SGERC HC.x, R10.w, c[27].w;
MOVR  R7.w(EQ.x), R1;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R11.w, c[34];
MOVR  R11.xyz, R10;
MOVR  R1.w, R7;
DP4R  R9.w, R11, c[5];
DP4R  R9.z, R11, c[4];
IF    NE.x;
MOVR  R11, c[27];
ADDR  R13, -R11, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R1.w, R13.y;
MULR_SAT R10.w, R12.y, R1;
MOVR  R1.w, c[37];
MULR  R7.w, R10, R10;
MADR  R10.w, -R10, c[35].x, R1;
MULR  R10.w, R7, R10;
RCPR  R11.x, R13.x;
MULR_SAT R7.w, R12.x, R11.x;
TEX   R11, R9.zwzw, texture[1], 2D;
MADR  R9.w, -R7, c[35].x, R1;
MULR  R7.w, R7, R7;
MADR  R9.z, R11.y, R10.w, -R10.w;
MULR  R9.w, R7, R9;
ADDR  R7.w, R9.z, c[34];
MADR  R9.z, R11.x, R9.w, -R9.w;
MADR  R7.w, R9.z, R7, R7;
RCPR  R9.w, R13.z;
MULR_SAT R9.w, R9, R12.z;
MADR  R10.w, -R9, c[35].x, R1;
RCPR  R9.z, R13.w;
MULR_SAT R9.z, R9, R12.w;
MADR  R1.w, -R9.z, c[35].x, R1;
MULR  R9.z, R9, R9;
MULR  R1.w, R9.z, R1;
MULR  R9.w, R9, R9;
MULR  R9.w, R9, R10;
MADR  R9.z, R11, R9.w, -R9.w;
MADR  R7.w, R9.z, R7, R7;
MADR  R1.w, R11, R1, -R1;
MADR  R1.w, R1, R7, R7;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R11.xyz, -R10, c[23];
DP3R  R7.w, R11, R11;
RSQR  R9.w, R7.w;
MULR  R11.xyz, R9.w, R11;
DP3R  R9.z, R1, R11;
MOVR  R7.w, c[34];
MADR  R9.z, R9, c[32].x, R7.w;
RCPR  R11.w, R9.z;
MULR  R9.z, c[32].x, c[32].x;
MADR  R10.w, -R9.z, R11, R11;
MOVR  R11.xyz, c[23];
ADDR  R11.xyz, -R11, c[24];
DP3R  R11.x, R11, R11;
ADDR  R10.xyz, -R10, c[20];
RSQR  R11.x, R11.x;
RCPR  R9.w, R9.w;
MULR  R9.w, R9, c[38];
DP3R  R11.y, R10, R10;
MULR  R10.w, R10, R11;
RCPR  R11.x, R11.x;
MULR  R11.x, R11, R10.w;
RSQR  R10.w, R11.y;
MULR  R10.xyz, R10.w, R10;
DP3R  R10.x, R10, R1;
MADR  R10.x, R10, c[32], R7.w;
MULR  R9.w, R9, R9;
RCPR  R7.w, R9.w;
RCPR  R9.w, R10.x;
MADR  R9.z, -R9, R9.w, R9.w;
MULR  R9.z, R9, R9.w;
MULR  R7.w, R11.x, R7;
MOVR  R10.xyz, c[20];
ADDR  R10.xyz, -R10, c[21];
DP3R  R10.x, R10, R10;
RCPR  R9.w, R10.w;
MULR  R9.w, R9, c[38];
MULR  R9.w, R9, R9;
RSQR  R10.x, R10.x;
RCPR  R10.x, R10.x;
MULR  R9.z, R10.x, R9;
RCPR  R9.w, R9.w;
MULR  R7.w, R7, c[38];
MULR  R9.w, R9.z, R9;
MINR  R9.z, R7.w, c[34].w;
MULR  R10.xyz, R9.z, c[25];
MULR  R9.z, R9.x, c[28].x;
MULR  R7.w, R9, c[38];
MINR  R7.w, R7, c[34];
MADR  R10.xyz, R7.w, c[22], R10;
MULR  R7.w, R9.y, c[30].x;
MULR  R10.xyz, R10, c[39].x;
MULR  R10.xyz, R7.w, R10;
MULR  R7.w, R5.y, R7;
MULR  R9.z, R9, R5.x;
MADR  R11.xyz, R9.z, c[38], R7.w;
MULR  R10.xyz, R10, c[39].y;
MADR  R8.xyz, R8, R11, R10;
MULR  R7.w, R9.y, c[31].x;
ADDR  R8.xyz, R8, c[18];
MULR  R8.xyz, R8, R8.w;
MADR  R9.xyz, R9.x, c[29], R7.w;
MADR  R2.xyz, R8, R0, R2;
MULR  R9.xyz, R8.w, -R9;
POWR  R8.x, c[36].w, R9.x;
POWR  R8.y, c[36].w, R9.y;
POWR  R8.z, c[36].w, R9.z;
MULR  R0.xyz, R0, R8;
ENDIF;
ADDR  R2.w, R2, -R6;
MULR  R8.w, R2, R4;
MOVR  R11.xyz, R2;
MOVX  H0.x, c[34];
MOVXC RC.x, R8.w;
MOVX  H0.x(GT), c[34].w;
MOVXC RC.x, H0;
MOVR  R2.xyz, c[34].x;
MOVR  R8.x, R6.w;
IF    NE.x;
FLRR  R10.w, R8;
MOVR  R11.w, c[34].x;
LOOP c[37];
SLTRC HC.x, R11.w, R10.w;
BRK   (EQ.x);
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R9.xyz, R10, -c[8];
DP3R  R2.w, R9, R9;
MOVR  R9.xyz, c[9];
DP3R  R6.w, R9, c[17];
RSQR  R2.w, R2.w;
MADR  R9.x, -R6.w, c[36].z, c[36].z;
RCPR  R12.x, R2.w;
MOVR  R4.w, c[12].x;
ADDR  R4.w, -R4, c[13].x;
MOVXC RC.x, c[33];
ADDR  R2.w, R12.x, -c[12].x;
RCPR  R4.w, R4.w;
MULR  R9.y, R2.w, R4.w;
TEX   R9, R9, texture[0], 2D;
MULR  R2.w, R9, c[31].x;
MADR  R13.xyz, R9.z, -c[29], -R2.w;
ADDR  R9.z, R8.x, R0.w;
ADDR  R4.w, -R8.x, R5;
RCPR  R6.w, R0.w;
ADDR  R2.w, R9.z, -R5.z;
POWR  R13.x, c[36].w, R13.x;
POWR  R13.y, c[36].w, R13.y;
POWR  R13.z, c[36].w, R13.z;
MULR_SAT R4.w, R6, R4;
MULR_SAT R2.w, R2, R6;
MULR  R2.w, R2, R4;
MADR  R8.xyz, -R2.w, R13, R13;
MULR  R8.xyz, R8, c[16];
IF    NE.x;
ADDR  R9.w, R12.x, -c[12].x;
MOVR  R2.w, c[34];
SGERC HC.x, R9.w, c[27].w;
MOVR  R2.w(EQ.x), R3;
SLTRC HC.x, R9.w, c[27].w;
MOVR  R13.w, c[34];
MOVR  R13.xyz, R10;
MOVR  R3.w, R2;
DP4R  R12.y, R13, c[5];
DP4R  R12.x, R13, c[4];
IF    NE.x;
MOVR  R13, c[27];
ADDR  R14, -R13, c[26];
ADDR  R13, R9.w, -c[27];
RCPR  R2.w, R14.y;
MULR_SAT R4.w, R13.y, R2;
MOVR  R2.w, c[37];
MULR  R3.w, R4, R4;
MADR  R4.w, -R4, c[35].x, R2;
TEX   R12, R12, texture[1], 2D;
MULR  R4.w, R3, R4;
RCPR  R6.w, R14.x;
MULR_SAT R3.w, R13.x, R6;
MADR  R6.w, -R3, c[35].x, R2;
MULR  R3.w, R3, R3;
MULR  R6.w, R3, R6;
MADR  R4.w, R12.y, R4, -R4;
ADDR  R3.w, R4, c[34];
MADR  R4.w, R12.x, R6, -R6;
MADR  R3.w, R4, R3, R3;
RCPR  R6.w, R14.z;
MULR_SAT R6.w, R6, R13.z;
MADR  R7.w, -R6, c[35].x, R2;
RCPR  R4.w, R14.w;
MULR_SAT R4.w, R4, R13;
MADR  R2.w, -R4, c[35].x, R2;
MULR  R4.w, R4, R4;
MULR  R2.w, R4, R2;
MULR  R6.w, R6, R6;
MULR  R6.w, R6, R7;
MADR  R4.w, R12.z, R6, -R6;
MADR  R3.w, R4, R3, R3;
MADR  R2.w, R12, R2, -R2;
MADR  R3.w, R2, R3, R3;
ENDIF;
MULR  R8.xyz, R8, R3.w;
ENDIF;
ADDR  R12.xyz, -R10, c[23];
DP3R  R2.w, R12, R12;
RSQR  R6.w, R2.w;
MULR  R12.xyz, R6.w, R12;
DP3R  R4.w, R1, R12;
MOVR  R2.w, c[34];
MADR  R4.w, R4, c[32].x, R2;
RCPR  R9.w, R4.w;
MULR  R4.w, c[32].x, c[32].x;
MADR  R7.w, -R4, R9, R9;
MOVR  R12.xyz, c[23];
RCPR  R6.w, R6.w;
MULR  R6.w, R6, c[38];
ADDR  R12.xyz, -R12, c[24];
MULR  R7.w, R7, R9;
DP3R  R9.w, R12, R12;
ADDR  R10.xyz, -R10, c[20];
RSQR  R9.w, R9.w;
RCPR  R9.w, R9.w;
DP3R  R12.x, R10, R10;
MULR  R9.w, R9, R7;
RSQR  R7.w, R12.x;
MULR  R10.xyz, R7.w, R10;
DP3R  R10.x, R10, R1;
MADR  R10.x, R10, c[32], R2.w;
MULR  R6.w, R6, R6;
RCPR  R2.w, R6.w;
RCPR  R6.w, R10.x;
MADR  R4.w, -R4, R6, R6;
MULR  R4.w, R4, R6;
RCPR  R6.w, R7.w;
MULR  R2.w, R9, R2;
MOVR  R10.xyz, c[20];
ADDR  R10.xyz, -R10, c[21];
DP3R  R7.w, R10, R10;
MULR  R6.w, R6, c[38];
MULR  R6.w, R6, R6;
RSQR  R7.w, R7.w;
RCPR  R7.w, R7.w;
MULR  R2.w, R2, c[38];
MULR  R4.w, R7, R4;
RCPR  R6.w, R6.w;
MULR  R6.w, R4, R6;
MINR  R4.w, R2, c[34];
MULR  R10.xyz, R4.w, c[25];
MULR  R2.w, R6, c[38];
MINR  R2.w, R2, c[34];
MADR  R10.xyz, R2.w, c[22], R10;
MULR  R4.w, R9.x, c[28].x;
MULR  R2.w, R9.y, c[30].x;
MULR  R10.xyz, R10, c[39].x;
MULR  R10.xyz, R2.w, R10;
MULR  R10.xyz, R10, c[39].y;
MULR  R2.w, R5.y, R2;
MULR  R4.w, R4, R5.x;
MADR  R12.xyz, R4.w, c[38], R2.w;
MADR  R8.xyz, R8, R12, R10;
MULR  R2.w, R9.y, c[31].x;
ADDR  R8.xyz, R8, c[18];
MULR  R8.xyz, R8, R0.w;
MADR  R10.xyz, R9.x, c[29], R2.w;
MADR  R2.xyz, R8, R0, R2;
MULR  R10.xyz, R0.w, -R10;
POWR  R8.x, c[36].w, R10.x;
POWR  R8.y, c[36].w, R10.y;
POWR  R8.z, c[36].w, R10.z;
MULR  R0.xyz, R0, R8;
MOVR  R8.x, R9.z;
ADDR  R11.w, R11, c[34];
ENDLOOP;
MADR  R10.xyz, R8.x, R1, R3;
ADDR  R3.xyz, R10, -c[8];
DP3R  R2.w, R3, R3;
RSQR  R2.w, R2.w;
MOVR  R3.x, c[12];
ADDR  R3.w, -R3.x, c[13].x;
MOVR  R3.xyz, c[9];
DP3R  R3.x, R3, c[17];
RCPR  R11.w, R2.w;
MOVXC RC.x, c[33];
ADDR  R2.w, R11, -c[12].x;
RCPR  R3.w, R3.w;
MULR  R3.y, R2.w, R3.w;
MADR  R3.x, -R3, c[36].z, c[36].z;
TEX   R9, R3, texture[0], 2D;
MULR  R2.w, R9, c[31].x;
MADR  R3.xyz, R9.z, -c[29], -R2.w;
ADDR  R2.w, R8, -R10;
MULR  R8.w, R2, R0;
ADDR  R0.w, R8, R8.x;
ADDR  R2.w, -R8.x, R5;
RCPR  R3.w, R8.w;
ADDR  R0.w, R0, -R5.z;
POWR  R3.x, c[36].w, R3.x;
POWR  R3.y, c[36].w, R3.y;
POWR  R3.z, c[36].w, R3.z;
MULR_SAT R2.w, R3, R2;
MULR_SAT R0.w, R0, R3;
MULR  R0.w, R0, R2;
MADR  R3.xyz, -R0.w, R3, R3;
MULR  R8.xyz, R3, c[16];
IF    NE.x;
ADDR  R10.w, R11, -c[12].x;
MOVR  R0.w, c[34];
SGERC HC.x, R10.w, c[27].w;
MOVR  R0.w(EQ.x), R1;
SLTRC HC.x, R10.w, c[27].w;
MOVR  R3.w, c[34];
MOVR  R3.xyz, R10;
MOVR  R1.w, R0;
DP4R  R9.w, R3, c[5];
DP4R  R9.z, R3, c[4];
IF    NE.x;
MOVR  R3, c[27];
ADDR  R13, -R3, c[26];
ADDR  R12, R10.w, -c[27];
RCPR  R0.w, R13.y;
MULR_SAT R2.w, R12.y, R0;
MOVR  R0.w, c[37];
MULR  R1.w, R2, R2;
MADR  R2.w, -R2, c[35].x, R0;
RCPR  R3.x, R13.x;
MULR  R2.w, R1, R2;
MULR_SAT R1.w, R12.x, R3.x;
TEX   R3, R9.zwzw, texture[1], 2D;
MADR  R2.w, R3.y, R2, -R2;
MADR  R3.y, -R1.w, c[35].x, R0.w;
MULR  R1.w, R1, R1;
MULR  R3.y, R1.w, R3;
ADDR  R1.w, R2, c[34];
MADR  R2.w, R3.x, R3.y, -R3.y;
MADR  R1.w, R2, R1, R1;
RCPR  R3.x, R13.z;
MULR_SAT R3.x, R3, R12.z;
MADR  R3.y, -R3.x, c[35].x, R0.w;
RCPR  R2.w, R13.w;
MULR_SAT R2.w, R2, R12;
MADR  R0.w, -R2, c[35].x, R0;
MULR  R2.w, R2, R2;
MULR  R0.w, R2, R0;
MULR  R3.x, R3, R3;
MULR  R3.x, R3, R3.y;
MADR  R2.w, R3.z, R3.x, -R3.x;
MADR  R1.w, R2, R1, R1;
MADR  R0.w, R3, R0, -R0;
MADR  R1.w, R0, R1, R1;
ENDIF;
MULR  R8.xyz, R8, R1.w;
ENDIF;
ADDR  R3.xyz, -R10, c[23];
DP3R  R0.w, R3, R3;
RSQR  R2.w, R0.w;
MULR  R3.xyz, R2.w, R3;
DP3R  R1.w, R1, R3;
MOVR  R0.w, c[34];
MADR  R1.w, R1, c[32].x, R0;
RCPR  R4.w, R1.w;
MULR  R1.w, c[32].x, c[32].x;
MADR  R3.w, -R1, R4, R4;
MOVR  R3.xyz, c[23];
RCPR  R2.w, R2.w;
MULR  R3.w, R3, R4;
ADDR  R3.xyz, -R3, c[24];
DP3R  R4.w, R3, R3;
ADDR  R3.xyz, -R10, c[20];
RSQR  R4.w, R4.w;
RCPR  R4.w, R4.w;
DP3R  R5.z, R3, R3;
MULR  R4.w, R4, R3;
RSQR  R3.w, R5.z;
MULR  R3.xyz, R3.w, R3;
DP3R  R1.y, R3, R1;
MULR  R2.w, R2, c[38];
MULR  R1.x, R2.w, R2.w;
MADR  R1.y, R1, c[32].x, R0.w;
RCPR  R0.w, R1.x;
RCPR  R1.x, R1.y;
MADR  R1.y, -R1.w, R1.x, R1.x;
MULR  R1.w, R1.y, R1.x;
MULR  R0.w, R4, R0;
MOVR  R1.xyz, c[20];
ADDR  R1.xyz, -R1, c[21];
DP3R  R1.y, R1, R1;
RCPR  R2.w, R3.w;
MULR  R2.w, R2, c[38];
MULR  R1.x, R2.w, R2.w;
RSQR  R1.y, R1.y;
RCPR  R1.y, R1.y;
MULR  R1.y, R1, R1.w;
RCPR  R1.x, R1.x;
MULR  R1.w, R9.x, c[28].x;
MULR  R1.y, R1, R1.x;
MULR  R0.w, R0, c[38];
MINR  R1.x, R0.w, c[34].w;
MULR  R0.w, R1.y, c[38];
MINR  R0.w, R0, c[34];
MULR  R1.xyz, R1.x, c[25];
MADR  R1.xyz, R0.w, c[22], R1;
MULR  R0.w, R9.y, c[30].x;
MULR  R1.xyz, R1, c[39].x;
MULR  R1.xyz, R0.w, R1;
MULR  R0.w, R5.y, R0;
MULR  R1.w, R1, R5.x;
MADR  R3.xyz, R1.w, c[38], R0.w;
MULR  R1.xyz, R1, c[39].y;
MADR  R1.xyz, R8, R3, R1;
MULR  R0.w, R9.y, c[31].x;
ADDR  R1.xyz, R1, c[18];
MULR  R1.xyz, R1, R8.w;
MADR  R3.xyz, R9.x, c[29], R0.w;
MADR  R2.xyz, R1, R0, R2;
MULR  R3.xyz, R8.w, -R3;
POWR  R1.x, c[36].w, R3.x;
POWR  R1.y, c[36].w, R3.y;
POWR  R1.z, c[36].w, R3.z;
MULR  R0.xyz, R0, R1;
ENDIF;
TEX   R1, fragment.texcoord[0], texture[5], 2D;
MADR  R3.xyz, R1.w, R2, R11;
TEX   R2, fragment.texcoord[0], texture[4], 2D;
MADR  R5.xyz, R2.w, R3, R7;
TEX   R3, fragment.texcoord[0], texture[3], 2D;
MADR  R1.xyz, R2.w, R1, R2;
MADR  R6.xyz, R3.w, R5, R6;
TEX   R5, fragment.texcoord[0], texture[2], 2D;
MULR  R0.w, R5, R3;
MULR  R0.w, R0, R2;
MADR  R1.xyz, R3.w, R1, R3;
MULR  R0.w, R0, R1;
MULR  R0.xyz, R0, R0.w;
MADR  R4.xyz, R5.w, R6, R4;
MADR  R1.xyz, R5.w, R1, R5;
TEX   R2.xyz, fragment.texcoord[0], texture[6], 2D;
MADR  R1.xyz, R2, R0, R1;
ADDR  oCol.xyz, R1, R4;
DP3R  oCol.w, R0, c[40];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Vector 10 [_PlanetTangent]
Vector 11 [_PlanetBiTangent]
Float 12 [_PlanetRadiusKm]
Float 13 [_PlanetAtmosphereRadiusKm]
Float 14 [_WorldUnit2Kilometer]
Float 15 [_bComputePlanetShadow]
Vector 16 [_SunColor]
Vector 17 [_SunDirection]
Vector 18 [_AmbientNightSky]
Vector 19 [_EnvironmentAngles]
Vector 20 [_NuajLightningPosition00]
Vector 21 [_NuajLightningPosition01]
Vector 22 [_NuajLightningColor0]
Vector 23 [_NuajLightningPosition10]
Vector 24 [_NuajLightningPosition11]
Vector 25 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 26 [_ShadowAltitudesMinKm]
Vector 27 [_ShadowAltitudesMaxKm]
SetTexture 1 [_TexShadowMap] 2D
Float 28 [_DensitySeaLevel_Rayleigh]
Vector 29 [_Sigma_Rayleigh]
Float 30 [_DensitySeaLevel_Mie]
Float 31 [_Sigma_Mie]
Float 32 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexCloudLayer0] 2D
SetTexture 3 [_TexCloudLayer1] 2D
SetTexture 4 [_TexCloudLayer2] 2D
SetTexture 5 [_TexCloudLayer3] 2D
SetTexture 6 [_TexBackground] 2D
Float 33 [_bGodRays]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c34, 0.00000000, 0.15915491, 0.50000000, -1000000.00000000
def c35, 6.28318501, -3.14159298, 0.75000000, 2.00000000
def c36, 1.00000000, 0.00000000, 1.50000000, 1000000.00000000
def c37, 1000000.00000000, -1000000.00000000, 32.00000000, 0.03125000
defi i0, 255, 0, 1, 0
def c38, 2.71828198, 2.00000000, 3.00000000, -1.00000000
def c39, 1000.00000000, 10.00000000, 400.00000000, 0
def c40, 5.60204458, 9.47328472, 19.64380264, 0
def c41, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c19.zwzw, c19
mad r0.z, r0.x, c34.y, c34
mad r0.x, r0.y, c34.y, c34.z
frc r0.y, r0.z
frc r0.x, r0
mad r1.x, r0.y, c35, c35.y
mad r2.x, r0, c35, c35.y
sincos r0.xy, r1.x
sincos r1.xy, r2.x
mul r0.w, r1.y, r0.x
mul r1.y, r1, r0
mul r2.xyz, r1.x, c9
mad r2.xyz, r1.y, c10, r2
mad r8.xyz, r0.w, c11, r2
mul r2.xyz, r8.zxyw, c17.yzxw
mad r2.xyz, r8.yzxw, c17.zxyw, -r2
mov r0.y, c2.w
mov r0.x, c0.w
mul r7.xz, r0.xyyw, c14.x
mov r7.y, c34.x
add r0.xyz, r7, -c8
mul r1.xyz, r0.zxyw, c17.yzxw
mad r1.xyz, r0.yzxw, c17.zxyw, -r1
dp3 r0.w, r1, r1
mad r1.w, -c12.x, c12.x, r0
dp3 r0.w, r2, r2
mul r3.x, r0.w, r1.w
dp3 r1.w, r1, r2
mad r1.x, r1.w, r1.w, -r3
rsq r1.y, r1.x
rcp r3.x, r0.w
dp3 r0.w, r0, c17
rcp r2.z, r1.y
add r1.y, -r1.w, -r2.z
cmp r0.w, -r0, c36.x, c36.y
mul r1.y, r1, r3.x
cmp r1.x, -r1, c36.y, c36
mul_pp r0.w, r0, c15.x
mul_pp r2.y, r0.w, r1.x
cmp r2.x, -r2.y, c36.w, r1.y
mad r1.xyz, r8, r2.x, r7
add r1.xyz, r1, -c8
dp3 r0.w, r1, c17
cmp r1.x, -r0.w, c36.y, c36
dp3 r0.w, r0, r0
mul_pp r1.y, r2, r1.x
dp3 r0.x, r8, r0
mad r1.x, -c13, c13, r0.w
mad r0.y, r0.x, r0.x, -r1.x
add r1.x, -r1.w, r2.z
mul r1.x, r3, r1
rsq r0.z, r0.y
cmp r2.y, -r2, c34.w, r1.x
cmp r13.zw, -r1.y, r2.xyxy, c37.xyxy
rcp r0.z, r0.z
add r0.z, -r0.x, r0
max r1.x, r0.z, c34
cmp_pp r0.z, r0.y, c36.x, c36.y
mov r1.y, c12.x
cmp r0.y, r0, r2.w, c34.x
cmp r0.y, -r0.z, r0, r1.x
add r1.y, c26, r1
mad r1.x, -r1.y, r1.y, r0.w
mov r0.z, c12.x
add r1.y, c26.z, r0.z
mad r1.x, r0, r0, -r1
mad r1.y, -r1, r1, r0.w
mad r1.z, r0.x, r0.x, -r1.y
rsq r0.z, r1.x
rcp r0.z, r0.z
add r1.y, -r0.x, r0.z
cmp_pp r0.z, r1.x, c36.x, c36.y
cmp r1.x, r1, r2.w, c34.w
cmp r0.z, -r0, r1.x, r1.y
rsq r1.w, r1.z
rcp r1.x, r1.w
add r1.w, -r0.x, r1.x
min r0.z, r0.y, r0
max r2.x, r0.z, c34
cmp r1.y, r1.z, r2.w, c34.w
cmp_pp r1.x, r1.z, c36, c36.y
cmp r1.x, -r1, r1.y, r1.w
mov r0.z, c12.x
add r1.y, c26.w, r0.z
mad r1.y, -r1, r1, r0.w
min r1.x, r0.y, r1
mov r0.z, c12.x
add r0.z, c26.x, r0
mad r0.z, -r0, r0, r0.w
mad r1.y, r0.x, r0.x, -r1
rsq r0.w, r1.y
rcp r1.z, r0.w
mad r0.z, r0.x, r0.x, -r0
add r1.w, -r0.x, r1.z
cmp_pp r1.z, r1.y, c36.x, c36.y
rsq r0.w, r0.z
rcp r0.w, r0.w
add r0.w, -r0.x, r0
cmp_pp r0.x, r0.z, c36, c36.y
cmp r0.z, r0, r2.w, c34.w
cmp r0.x, -r0, r0.z, r0.w
min r0.z, r0.y, r0.x
max r4.x, r0.z, c34
cmp r1.y, r1, r2.w, c34.w
cmp r1.y, -r1.z, r1, r1.w
min r0.w, r0.y, r1.y
max r0.x, r0.w, c34
dp3 r0.w, r8, c17
mul r1.y, r0.w, c32.x
mad r0.w, r0, r0, c36.x
rcp r0.z, r0.y
mul r0.z, r0, c37
mul r9.w, r4.x, r0.z
mul r1.y, r1, c35.w
cmp_pp r1.z, -r9.w, c36.y, c36.x
mad r1.y, c32.x, c32.x, r1
add r1.y, r1, c36.x
pow r3, r1.y, c36.z
mul r13.x, r0.w, c35.z
mov r0.w, c32.x
mov r1.y, r3.x
add r0.w, c36.x, r0
rcp r1.y, r1.y
mul r0.w, r0, r0
max r1.x, r1, c34
mul r6.w, r0.y, c37
mul r13.y, r0.w, r1
mov r9.xyz, c36.x
mov r6.xyz, c34.x
mov r12.x, c34
if_gt r1.z, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.y, r0.w
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r0, r1.y, -r1.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r3.xyz, r10, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r12.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r5, r3.xyzz, s0
mul r0.w, r5, c31.x
mad r11.xyz, r5.z, -c29, -r0.w
pow r3, c38.x, r11.y
pow r14, c38.x, r11.x
mov r11.y, r3
pow r3, c38.x, r11.z
add r3.x, r12, r6.w
add r1.z, -r12.x, r13.w
rcp r1.y, r6.w
add r0.w, r3.x, -r13.z
mov r11.x, r14
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r11.z, r3
mul r11.xyz, r11, r0.w
mov r0.w, c34.x
mul r12.xyz, r11, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r14.xyz, r10
mov r14.w, c36.x
dp4 r3.w, r14, c5
dp4 r3.z, r14, c4
cmp r8.w, r0, c36.x, r8
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3.y, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mov r0.w, c26.y
mul r1.y, r1, r1.z
add r0.w, -c27.y, r0
rcp r1.z, r0.w
add r0.w, r3.y, -c27.y
mul_sat r0.w, r0, r1.z
mad r1.z, -r0.w, c38.y, c38
mul r0.w, r0, r0
mul r1.z, r0.w, r1
mov r0.w, c26.z
mov r11.xy, r3.zwzw
mov r11.z, c34.x
texldl r14, r11.xyzz, s1
add r1.w, r14.x, c38
mad r1.y, r1, r1.w, c36.x
add r1.w, r14.y, c38
mad r1.z, r1, r1.w, c36.x
add r1.w, -c27.z, r0
mul r0.w, r1.y, r1.z
rcp r1.z, r1.w
add r1.y, r3, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r14.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.y, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r14.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r8.w, r0, r1.z
endif
mul r12.xyz, r12, r8.w
endif
add r11.xyz, -r10, c23
dp3 r0.w, r11, r11
rsq r0.w, r0.w
mul r11.xyz, r0.w, r11
dp3 r1.y, r8, r11
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r11.xyz, c24
add r11.xyz, -c23, r11
dp3 r2.y, r11, r11
rsq r2.y, r2.y
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.w, r1, r1.z
add r10.xyz, -r10, c20
dp3 r1.z, r10, r10
rsq r1.z, r1.z
rcp r2.y, r2.y
mul r2.y, r2, r1.w
rcp r1.w, r0.w
mul r10.xyz, r1.z, r10
dp3 r0.w, r10, r8
mul r1.w, r1, c39.x
mul r1.w, r1, r1
mul r0.w, r0, c32.x
mov r10.xyz, c21
add r0.w, r0, c36.x
rcp r2.z, r1.w
rcp r1.w, r0.w
mul r1.y, r1, r1.w
mul r1.w, r1.y, r1
rcp r1.y, r1.z
mul r1.z, r1.y, c39.x
add r10.xyz, -c20, r10
dp3 r1.y, r10, r10
mul r0.w, r2.y, r2.z
mul r1.z, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r0.w, r0, c39.x
rcp r1.z, r1.z
mul r1.y, r1, r1.w
mul r1.y, r1, r1.z
min r1.z, r0.w, c36.x
mul r0.w, r1.y, c39.x
mul r1.y, r5, c30.x
min r0.w, r0, c36.x
mul r10.xyz, r1.z, c25
mad r10.xyz, r0.w, c22, r10
mul r0.w, r5.y, c31.x
mad r11.xyz, r5.x, c29, r0.w
mul r0.w, r5.x, c28.x
mul r10.xyz, r10, c39.y
mul r10.xyz, r1.y, r10
mul r10.xyz, r10, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r5.xyz, r0.w, c40, r1.y
mad r5.xyz, r12, r5, r10
mul r10.xyz, r6.w, -r11
add r11.xyz, r5, c18
pow r5, c38.x, r10.x
pow r12, c38.x, r10.y
mov r10.x, r5
pow r5, c38.x, r10.z
mul r11.xyz, r11, r6.w
mad r6.xyz, r11, r9, r6
mov r10.y, r12
mov r10.z, r5
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r3.xyz, r5, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r5.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r3, r3.xyzz, s0
mul r0.w, r3, c31.x
mad r11.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r11.y
pow r14, c38.x, r11.x
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
mov r11.y, r10
pow r10, c38.x, r11.z
add r0.w, r3.z, r12.x
rcp r1.y, r3.z
add r0.w, r0, -r13.z
add r1.z, -r12.x, r13.w
mov r11.x, r14
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r11.z, r10
mul r10.xyz, r11, r0.w
mov r0.w, c34.x
mul r10.xyz, r10, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r11.xyz, r5
mov r11.w, c36.x
dp4 r12.y, r11, c5
dp4 r12.x, r11, c4
cmp r7.w, r0, c36.x, r7
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mov r0.w, c26.y
mul r1.y, r1, r1.z
add r0.w, -c27.y, r0
rcp r1.z, r0.w
add r0.w, r3, -c27.y
mul_sat r0.w, r0, r1.z
mad r1.z, -r0.w, c38.y, c38
mul r0.w, r0, r0
mul r1.z, r0.w, r1
mov r0.w, c26.z
mov r11.xy, r12
mov r11.z, c34.x
texldl r11, r11.xyzz, s1
add r1.w, r11.x, c38
mad r1.y, r1, r1.w, c36.x
add r1.w, r11.y, c38
mad r1.z, r1, r1.w, c36.x
add r1.w, -c27.z, r0
mul r0.w, r1.y, r1.z
rcp r1.z, r1.w
add r1.y, r3.w, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r11.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.w, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r11.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r7.w, r0, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r11.xyz, -r5, c23
dp3 r0.w, r11, r11
rsq r0.w, r0.w
mul r11.xyz, r0.w, r11
dp3 r1.y, r8, r11
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r11.xyz, c24
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r2.y, r1.w, r1.z
add r11.xyz, -c23, r11
add r5.xyz, -r5, c20
dp3 r1.w, r11, r11
dp3 r1.z, r5, r5
rsq r1.z, r1.z
rsq r1.w, r1.w
rcp r1.w, r1.w
mul r1.w, r1, r2.y
rcp r2.y, r0.w
mul r5.xyz, r1.z, r5
dp3 r0.w, r5, r8
mul r2.y, r2, c39.x
mul r0.w, r0, c32.x
mul r2.y, r2, r2
add r0.w, r0, c36.x
rcp r0.w, r0.w
mul r1.y, r1, r0.w
mul r1.y, r1, r0.w
rcp r0.w, r1.z
mul r1.z, r0.w, c39.x
rcp r2.y, r2.y
mul r1.w, r1, r2.y
mov r5.xyz, c21
add r5.xyz, -c20, r5
dp3 r0.w, r5, r5
mul r1.z, r1, r1
rsq r0.w, r0.w
rcp r0.w, r0.w
mul r0.w, r0, r1.y
mul r1.w, r1, c39.x
min r1.y, r1.w, c36.x
mul r5.xyz, r1.y, c25
rcp r1.z, r1.z
mul r0.w, r0, r1.z
mul r0.w, r0, c39.x
min r0.w, r0, c36.x
mad r5.xyz, r0.w, c22, r5
mul r0.w, r3.y, c31.x
mad r11.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r1.y, r3, c30.x
mul r5.xyz, r5, c39.y
mul r5.xyz, r1.y, r5
mul r5.xyz, r5, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.y
mad r5.xyz, r10, r12, r5
mul r10.xyz, r3.z, -r11
add r11.xyz, r5, c18
pow r5, c38.x, r10.x
mul r3.xyz, r11, r3.z
mad r6.xyz, r3, r9, r6
mov r10.x, r5
pow r5, c38.x, r10.y
pow r3, c38.x, r10.z
mov r10.y, r5
mov r10.z, r3
mul r9.xyz, r9, r10
endif
add r0.w, r2.x, -r4.x
mul r9.w, r0, r0.z
cmp_pp r0.w, -r9, c36.y, c36.x
mov r11.xyz, r6
mov r12.x, r4
mov r6.xyz, c34.x
if_gt r0.w, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.y, r0.w
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r0, r1.y, -r1.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r3.xyz, r10, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r12.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r5, r3.xyzz, s0
mul r0.w, r5, c31.x
mad r14.xyz, r5.z, -c29, -r0.w
pow r4, c38.x, r14.x
pow r3, c38.x, r14.y
mov r4.y, r3
pow r3, c38.x, r14.z
add r3.x, r12, r6.w
add r1.z, -r12.x, r13.w
rcp r1.y, r6.w
add r0.w, r3.x, -r13.z
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r4.z, r3
mul r4.xyz, r4, r0.w
mov r0.w, c34.x
mul r12.xyz, r4, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r4.xyz, r10
mov r4.w, c36.x
dp4 r3.w, r4, c5
dp4 r3.z, r4, c4
cmp r8.w, r0, c36.x, r8
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3.y, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mul r1.y, r1, r1.z
mov r0.w, c26.y
add r1.z, -c27.y, r0.w
rcp r1.z, r1.z
mov r4.xy, r3.zwzw
mov r4.z, c34.x
texldl r4, r4.xyzz, s1
add r1.w, r4.x, c38
mad r0.w, r1.y, r1, c36.x
add r1.y, r3, -c27
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
mul r1.z, r1.y, r1
add r1.w, r4.y, c38
mad r1.z, r1, r1.w, c36.x
mov r1.y, c26.z
mul r0.w, r0, r1.z
add r1.y, -c27.z, r1
rcp r1.z, r1.y
add r1.y, r3, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r4.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.y, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r4.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r8.w, r0, r1.z
endif
mul r12.xyz, r12, r8.w
endif
add r4.xyz, -r10, c23
dp3 r0.w, r4, r4
rsq r0.w, r0.w
mul r4.xyz, r0.w, r4
dp3 r1.y, r8, r4
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r4.xyz, c24
add r4.xyz, -c23, r4
dp3 r2.y, r4, r4
rsq r2.y, r2.y
add r10.xyz, -r10, c20
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.z, r1.w, r1
dp3 r1.w, r10, r10
rsq r1.w, r1.w
rcp r2.y, r2.y
mul r1.z, r2.y, r1
rcp r2.y, r0.w
mul r4.xyz, r1.w, r10
dp3 r0.w, r4, r8
mul r2.y, r2, c39.x
mul r2.y, r2, r2
mul r0.w, r0, c32.x
mov r4.xyz, c21
add r0.w, r0, c36.x
rcp r2.z, r2.y
rcp r2.y, r0.w
mul r0.w, r1.z, r2.z
mul r1.y, r1, r2
mul r1.z, r1.y, r2.y
rcp r1.y, r1.w
mul r1.w, r1.y, c39.x
add r4.xyz, -c20, r4
dp3 r1.y, r4, r4
mul r1.w, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r1.y, r1, r1.z
mul r0.w, r0, c39.x
min r1.z, r0.w, c36.x
rcp r1.w, r1.w
mul r1.y, r1, r1.w
mul r0.w, r1.y, c39.x
mul r1.y, r5, c30.x
min r0.w, r0, c36.x
mul r4.xyz, r1.z, c25
mad r4.xyz, r0.w, c22, r4
mul r0.w, r5.y, c31.x
mad r10.xyz, r5.x, c29, r0.w
mul r0.w, r5.x, c28.x
mul r4.xyz, r4, c39.y
mul r4.xyz, r1.y, r4
mul r10.xyz, r6.w, -r10
mul r4.xyz, r4, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r5.xyz, r0.w, c40, r1.y
mad r4.xyz, r12, r5, r4
add r5.xyz, r4, c18
pow r4, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r4
pow r5, c38.x, r10.y
pow r4, c38.x, r10.z
mov r10.y, r5
mov r10.z, r4
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r3.xyz, r5, -c8
dp3 r0.w, r3, r3
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r3.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r3
add r1.y, r5.w, -c12.x
mul r3.y, r1, r1.z
add r0.w, -r0, c36.x
mul r3.x, r0.w, c34.z
mov r3.z, c34.x
texldl r3, r3.xyzz, s0
mul r0.w, r3, c31.x
mad r14.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r14.x
pow r4, c38.x, r14.y
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
add r0.w, r3.z, r12.x
mov r10.y, r4
pow r4, c38.x, r14.z
mov r10.z, r4
rcp r1.y, r3.z
add r0.w, r0, -r13.z
add r1.z, -r12.x, r13.w
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mul r4.xyz, r10, r0.w
mov r0.w, c34.x
mul r10.xyz, r4, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r4.xyz, r5
mov r4.w, c36.x
dp4 r12.y, r4, c5
dp4 r12.x, r4, c4
cmp r7.w, r0, c36.x, r7
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mov r0.w, c26.y
mul r1.y, r1, r1.z
add r0.w, -c27.y, r0
rcp r1.z, r0.w
add r0.w, r3, -c27.y
mul_sat r0.w, r0, r1.z
mad r1.z, -r0.w, c38.y, c38
mul r0.w, r0, r0
mul r1.z, r0.w, r1
mov r0.w, c26.z
mov r4.xy, r12
mov r4.z, c34.x
texldl r4, r4.xyzz, s1
add r1.w, r4.x, c38
mad r1.y, r1, r1.w, c36.x
add r1.w, r4.y, c38
mad r1.z, r1, r1.w, c36.x
add r1.w, -c27.z, r0
mul r0.w, r1.y, r1.z
rcp r1.z, r1.w
add r1.y, r3.w, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.y, r4.z, c38.w
mad r1.y, r1.z, r2, c36.x
rcp r1.w, r1.w
add r1.z, r3.w, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.y, r4.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.y, c36.x
mul r0.w, r0, r1.y
mul r7.w, r0, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r4.xyz, -r5, c23
dp3 r0.w, r4, r4
rsq r0.w, r0.w
mul r4.xyz, r0.w, r4
dp3 r1.y, r8, r4
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r4.xyz, c24
add r4.xyz, -c23, r4
dp3 r2.y, r4, r4
rsq r2.y, r2.y
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.w, r1, r1.z
add r5.xyz, -r5, c20
dp3 r1.z, r5, r5
rsq r1.z, r1.z
rcp r2.y, r2.y
mul r2.y, r2, r1.w
rcp r1.w, r0.w
mul r4.xyz, r1.z, r5
dp3 r0.w, r4, r8
mul r1.w, r1, c39.x
mul r1.w, r1, r1
mul r0.w, r0, c32.x
mov r4.xyz, c21
add r0.w, r0, c36.x
rcp r2.z, r1.w
rcp r1.w, r0.w
mul r1.y, r1, r1.w
mul r1.w, r1.y, r1
rcp r1.y, r1.z
mul r1.z, r1.y, c39.x
add r4.xyz, -c20, r4
dp3 r1.y, r4, r4
mul r0.w, r2.y, r2.z
mul r1.z, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r0.w, r0, c39.x
rcp r1.z, r1.z
mul r1.y, r1, r1.w
mul r1.y, r1, r1.z
min r1.z, r0.w, c36.x
mul r0.w, r1.y, c39.x
mul r1.y, r3, c30.x
min r0.w, r0, c36.x
mul r4.xyz, r1.z, c25
mad r4.xyz, r0.w, c22, r4
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r4.xyz, r4, c39.y
mul r4.xyz, r1.y, r4
mul r5.xyz, r3.z, -r5
mul r4.xyz, r4, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.y
mad r4.xyz, r10, r12, r4
add r10.xyz, r4, c18
pow r4, c38.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r4
pow r4, c38.x, r5.y
pow r3, c38.x, r5.z
mov r5.y, r4
mov r5.z, r3
mul r9.xyz, r9, r5
endif
add r0.w, r1.x, -r2.x
mul r9.w, r0, r0.z
cmp_pp r0.w, -r9, c36.y, c36.x
mov r4.xyz, r6
mov r12.x, r2
mov r6.xyz, c34.x
if_gt r0.w, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.y, r0.w
frc r1.z, r1.y
add r1.y, r1, -r1.z
cmp r11.w, r0, r1.y, -r1.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r2.xyz, r10, -c8
dp3 r0.w, r2, r2
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r2.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r2
add r1.y, r12.w, -c12.x
mul r2.y, r1, r1.z
add r0.w, -r0, c36.x
mul r2.x, r0.w, c34.z
mov r2.z, c34.x
texldl r5, r2.xyzz, s0
mul r0.w, r5, c31.x
mad r14.xyz, r5.z, -c29, -r0.w
pow r2, c38.x, r14.y
pow r3, c38.x, r14.x
mov r14.x, r3
mov r14.y, r2
pow r2, c38.x, r14.z
add r3.x, r12, r6.w
add r1.z, -r12.x, r13.w
rcp r1.y, r6.w
add r0.w, r3.x, -r13.z
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mov r14.z, r2
mul r2.xyz, r14, r0.w
mov r0.w, c34.x
mul r12.xyz, r2, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r2.xyz, r10
mov r2.w, c36.x
dp4 r3.w, r2, c5
dp4 r3.z, r2, c4
cmp r8.w, r0, c36.x, r8
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3.y, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mul r1.y, r1, r1.z
mov r0.w, c26.y
add r1.z, -c27.y, r0.w
rcp r1.z, r1.z
mov r2.xy, r3.zwzw
mov r2.z, c34.x
texldl r2, r2.xyzz, s1
add r1.w, r2.x, c38
mad r0.w, r1.y, r1, c36.x
add r1.y, r3, -c27
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
mul r1.z, r1.y, r1
add r1.w, r2.y, c38
mad r1.z, r1, r1.w, c36.x
mov r1.y, c26.z
mul r0.w, r0, r1.z
add r1.y, -c27.z, r1
rcp r1.z, r1.y
add r1.y, r3, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.x, r2.z, c38.w
mad r1.y, r1.z, r2.x, c36.x
rcp r1.w, r1.w
add r1.z, r3.y, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.x, r2.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.x, c36.x
mul r0.w, r0, r1.y
mul r8.w, r0, r1.z
endif
mul r12.xyz, r12, r8.w
endif
add r2.xyz, -r10, c23
dp3 r0.w, r2, r2
rsq r0.w, r0.w
mul r2.xyz, r0.w, r2
dp3 r1.y, r8, r2
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r2.xyz, c24
add r2.xyz, -c23, r2
dp3 r2.x, r2, r2
rsq r2.x, r2.x
add r10.xyz, -r10, c20
rcp r2.w, r0.w
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.z, r1.w, r1
dp3 r1.w, r10, r10
rcp r2.x, r2.x
rsq r1.w, r1.w
mul r1.z, r2.x, r1
mul r2.xyz, r1.w, r10
dp3 r0.w, r2, r8
mul r2.x, r2.w, c39
mul r2.x, r2, r2
mul r0.w, r0, c32.x
rcp r2.y, r2.x
add r0.w, r0, c36.x
rcp r2.x, r0.w
mul r0.w, r1.z, r2.y
mul r1.y, r1, r2.x
mul r1.y, r1, r2.x
rcp r1.z, r1.w
mul r1.w, r1.z, c39.x
mov r2.xyz, c21
add r2.xyz, -c20, r2
dp3 r1.z, r2, r2
mul r1.w, r1, r1
rsq r1.z, r1.z
rcp r1.z, r1.z
mul r0.w, r0, c39.x
mul r1.y, r1.z, r1
min r1.z, r0.w, c36.x
rcp r1.w, r1.w
mul r1.y, r1, r1.w
mul r0.w, r1.y, c39.x
mul r1.y, r5, c31.x
mad r10.xyz, r5.x, c29, r1.y
mul r10.xyz, r6.w, -r10
mul r2.xyz, r1.z, c25
min r0.w, r0, c36.x
mad r2.xyz, r0.w, c22, r2
mul r0.w, r5.y, c30.x
mul r2.xyz, r2, c39.y
mul r2.xyz, r0.w, r2
mul r1.y, r5.x, c28.x
mul r1.z, r13.y, r0.w
mul r0.w, r1.y, r13.x
mad r5.xyz, r0.w, c40, r1.z
mul r2.xyz, r2, c39.z
mad r2.xyz, r12, r5, r2
add r5.xyz, r2, c18
pow r2, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r2
pow r5, c38.x, r10.y
pow r2, c38.x, r10.z
mov r10.y, r5
mov r10.z, r2
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r2.xyz, r5, -c8
dp3 r0.w, r2, r2
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r2.xyz, c17
rcp r1.z, r0.w
dp3 r0.w, c9, r2
add r1.y, r5.w, -c12.x
mul r2.y, r1, r1.z
add r0.w, -r0, c36.x
mul r2.x, r0.w, c34.z
mov r2.z, c34.x
texldl r3, r2.xyzz, s0
mul r0.w, r3, c31.x
mad r14.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r14.x
pow r2, c38.x, r14.y
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
add r0.w, r3.z, r12.x
mov r10.y, r2
pow r2, c38.x, r14.z
mov r10.z, r2
rcp r1.y, r3.z
add r0.w, r0, -r13.z
add r1.z, -r12.x, r13.w
mul_sat r1.z, r1.y, r1
mul_sat r0.w, r0, r1.y
mad r0.w, -r0, r1.z, c36.x
mul r2.xyz, r10, r0.w
mov r0.w, c34.x
mul r10.xyz, r2, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
cmp_pp r1.y, r0.w, c36, c36.x
mov r2.xyz, r5
mov r2.w, c36.x
dp4 r12.y, r2, c5
dp4 r12.x, r2, c4
cmp r7.w, r0, c36.x, r7
if_gt r1.y, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r1.y, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r1.y
mad r1.z, -r0.w, c38.y, c38
mul r1.y, r0.w, r0.w
mul r1.y, r1, r1.z
mov r0.w, c26.y
add r1.z, -c27.y, r0.w
rcp r1.z, r1.z
mov r2.xy, r12
mov r2.z, c34.x
texldl r2, r2.xyzz, s1
add r1.w, r2.x, c38
mad r0.w, r1.y, r1, c36.x
add r1.y, r3.w, -c27
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
mul r1.z, r1.y, r1
add r1.w, r2.y, c38
mad r1.z, r1, r1.w, c36.x
mov r1.y, c26.z
mul r0.w, r0, r1.z
add r1.y, -c27.z, r1
rcp r1.z, r1.y
add r1.y, r3.w, -c27.z
mul_sat r1.y, r1, r1.z
mad r1.w, -r1.y, c38.y, c38.z
mul r1.z, r1.y, r1.y
mul r1.z, r1, r1.w
mov r1.y, c26.w
add r1.w, -c27, r1.y
add r2.x, r2.z, c38.w
mad r1.y, r1.z, r2.x, c36.x
rcp r1.w, r1.w
add r1.z, r3.w, -c27.w
mul_sat r1.z, r1, r1.w
mad r1.w, -r1.z, c38.y, c38.z
mul r1.z, r1, r1
add r2.x, r2.w, c38.w
mul r1.z, r1, r1.w
mad r1.z, r1, r2.x, c36.x
mul r0.w, r0, r1.y
mul r7.w, r0, r1.z
endif
mul r10.xyz, r10, r7.w
endif
add r2.xyz, -r5, c23
dp3 r0.w, r2, r2
rsq r0.w, r0.w
mul r2.xyz, r0.w, r2
dp3 r1.y, r8, r2
mul r1.y, r1, c32.x
add r1.z, r1.y, c36.x
mul r1.y, -c32.x, c32.x
mov r2.xyz, c24
add r2.xyz, -c23, r2
dp3 r2.x, r2, r2
rsq r2.x, r2.x
rcp r1.z, r1.z
add r1.y, r1, c36.x
mul r1.w, r1.y, r1.z
mul r1.w, r1, r1.z
add r5.xyz, -r5, c20
dp3 r1.z, r5, r5
rcp r2.x, r2.x
rsq r1.z, r1.z
mul r1.w, r2.x, r1
mul r2.xyz, r1.z, r5
rcp r2.w, r0.w
dp3 r0.w, r2, r8
mul r2.x, r2.w, c39
mul r2.x, r2, r2
mul r0.w, r0, c32.x
rcp r2.y, r2.x
add r0.w, r0, c36.x
rcp r2.x, r0.w
mul r0.w, r1, r2.y
mul r1.y, r1, r2.x
mul r1.w, r1.y, r2.x
rcp r1.y, r1.z
mul r1.z, r1.y, c39.x
mov r2.xyz, c21
add r2.xyz, -c20, r2
dp3 r1.y, r2, r2
mul r1.z, r1, r1
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r0.w, r0, c39.x
rcp r1.z, r1.z
mul r1.y, r1, r1.w
mul r1.y, r1, r1.z
min r1.z, r0.w, c36.x
mul r0.w, r1.y, c39.x
mul r1.y, r3, c30.x
min r0.w, r0, c36.x
mul r2.xyz, r1.z, c25
mad r2.xyz, r0.w, c22, r2
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r2.xyz, r2, c39.y
mul r2.xyz, r1.y, r2
mul r5.xyz, r3.z, -r5
mul r2.xyz, r2, c39.z
mul r1.y, r13, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.y
mad r2.xyz, r10, r12, r2
add r10.xyz, r2, c18
pow r2, c38.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r2
pow r3, c38.x, r5.y
pow r2, c38.x, r5.z
mov r5.y, r3
mov r5.z, r2
mul r9.xyz, r9, r5
endif
add r0.w, r0.x, -r1.x
mul r9.w, r0, r0.z
cmp_pp r0.w, -r9, c36.y, c36.x
mov r2.xyz, r6
mov r12.x, r1
mov r6.xyz, c34.x
if_gt r0.w, c34.x
frc r0.w, r9
add r0.w, r9, -r0
abs r1.x, r0.w
frc r1.y, r1.x
add r1.x, r1, -r1.y
cmp r11.w, r0, r1.x, -r1.x
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r1.xyz, r10, -c8
dp3 r0.w, r1, r1
rsq r0.w, r0.w
rcp r12.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r1.xyz, c17
rcp r2.w, r0.w
dp3 r0.w, c9, r1
add r1.w, r12, -c12.x
add r0.w, -r0, c36.x
mul r1.x, r0.w, c34.z
mul r1.y, r1.w, r2.w
mov r1.z, c34.x
texldl r5, r1.xyzz, s0
mul r0.w, r5, c31.x
mad r14.xyz, r5.z, -c29, -r0.w
pow r1, c38.x, r14.y
pow r3, c38.x, r14.x
mov r14.x, r3
mov r14.y, r1
pow r1, c38.x, r14.z
add r3.x, r12, r6.w
rcp r1.x, r6.w
add r1.y, -r12.x, r13.w
add r0.w, r3.x, -r13.z
mul_sat r0.w, r0, r1.x
mul_sat r1.y, r1.x, r1
mad r0.w, -r0, r1.y, c36.x
mov r14.z, r1
mul r1.xyz, r14, r0.w
mov r0.w, c34.x
mul r12.xyz, r1, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r0.w, r3.y, -c27
mov r1.xyz, r10
mov r1.w, c36.x
dp4 r3.w, r1, c5
dp4 r3.z, r1, c4
cmp_pp r1.x, r0.w, c36.y, c36
cmp r8.w, r0, c36.x, r8
if_gt r1.x, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r2.w, r0.w
add r0.w, r3.y, -c27.x
mul_sat r2.w, r0, r2
mov r1.xy, r3.zwzw
mul r3.z, r2.w, r2.w
mov r1.z, c34.x
texldl r1, r1.xyzz, s1
add r0.w, r1.x, c38
mad r2.w, -r2, c38.y, c38.z
mul r2.w, r3.z, r2
mov r1.x, c26.y
add r1.x, -c27.y, r1
mad r0.w, r2, r0, c36.x
rcp r2.w, r1.x
add r1.x, r3.y, -c27.y
mul_sat r1.x, r1, r2.w
add r2.w, r1.y, c38
mad r1.y, -r1.x, c38, c38.z
mul r1.x, r1, r1
mul r1.y, r1.x, r1
mad r1.y, r1, r2.w, c36.x
mov r1.x, c26.z
mul r0.w, r0, r1.y
add r1.x, -c27.z, r1
rcp r1.y, r1.x
add r1.x, r3.y, -c27.z
mul_sat r1.x, r1, r1.y
add r2.w, r1.z, c38
mad r1.z, -r1.x, c38.y, c38
mul r1.y, r1.x, r1.x
mul r1.y, r1, r1.z
mov r1.x, c26.w
add r1.z, -c27.w, r1.x
mad r1.x, r1.y, r2.w, c36
rcp r1.z, r1.z
add r1.y, r3, -c27.w
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
add r1.w, r1, c38
mul r1.y, r1, r1.z
mad r1.y, r1, r1.w, c36.x
mul r0.w, r0, r1.x
mul r8.w, r0, r1.y
endif
mul r12.xyz, r12, r8.w
endif
add r1.xyz, -r10, c23
dp3 r0.w, r1, r1
rsq r0.w, r0.w
mul r1.xyz, r0.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c32
add r1.y, r1.x, c36.x
mul r1.x, -c32, c32
add r1.w, r1.x, c36.x
rcp r2.w, r1.y
mul r3.y, r1.w, r2.w
mov r1.xyz, c24
add r1.xyz, -c23, r1
dp3 r1.y, r1, r1
add r10.xyz, -r10, c20
dp3 r1.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r2.w, r1.x, r2
mul r1.xyz, r3.y, r10
rcp r3.z, r0.w
dp3 r0.w, r1, r8
mul r1.x, r3.z, c39
mul r1.x, r1, r1
mul r0.w, r0, c32.x
rcp r1.y, r1.x
add r0.w, r0, c36.x
rcp r1.x, r0.w
mul r0.w, r2, r1.y
mul r1.y, r1.w, r1.x
mul r1.w, r1.y, r1.x
mov r1.xyz, c21
add r1.xyz, -c20, r1
dp3 r1.x, r1, r1
rcp r2.w, r3.y
mul r2.w, r2, c39.x
mul r1.y, r2.w, r2.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r1.w
mul r1.w, r5.y, c31.x
mad r10.xyz, r5.x, c29, r1.w
rcp r1.y, r1.y
mul r10.xyz, r6.w, -r10
mul r1.x, r1, r1.y
mul r0.w, r0, c39.x
min r1.y, r0.w, c36.x
mul r0.w, r1.x, c39.x
mul r1.w, r5.x, c28.x
min r0.w, r0, c36.x
mul r1.xyz, r1.y, c25
mad r1.xyz, r0.w, c22, r1
mul r0.w, r5.y, c30.x
mul r1.xyz, r1, c39.y
mul r1.xyz, r0.w, r1
mul r2.w, r13.y, r0
mul r0.w, r1, r13.x
mad r5.xyz, r0.w, c40, r2.w
mul r1.xyz, r1, c39.z
mad r1.xyz, r12, r5, r1
add r5.xyz, r1, c18
pow r1, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r1
pow r5, c38.x, r10.y
pow r1, c38.x, r10.z
mov r10.y, r5
mov r10.z, r1
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r1.xyz, r5, -c8
dp3 r0.w, r1, r1
rsq r0.w, r0.w
rcp r5.w, r0.w
mov r0.w, c13.x
add r0.w, -c12.x, r0
mov r1.xyz, c17
rcp r2.w, r0.w
dp3 r0.w, c9, r1
add r1.w, r5, -c12.x
add r0.w, -r0, c36.x
mul r1.x, r0.w, c34.z
mul r1.y, r1.w, r2.w
mov r1.z, c34.x
texldl r3, r1.xyzz, s0
mul r0.w, r3, c31.x
mad r14.xyz, r3.z, -c29, -r0.w
pow r10, c38.x, r14.x
pow r1, c38.x, r14.y
add r0.w, r9, -r11
mul r3.z, r0.w, r6.w
add r0.w, r3.z, r12.x
mov r10.y, r1
pow r1, c38.x, r14.z
rcp r1.x, r3.z
add r0.w, r0, -r13.z
add r1.y, -r12.x, r13.w
mul_sat r0.w, r0, r1.x
mul_sat r1.y, r1.x, r1
mad r0.w, -r0, r1.y, c36.x
mov r10.z, r1
mul r1.xyz, r10, r0.w
mov r0.w, c34.x
mul r10.xyz, r1, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r0.w, r3, -c27
mov r1.xyz, r5
mov r1.w, c36.x
dp4 r12.y, r1, c5
dp4 r12.x, r1, c4
cmp_pp r1.x, r0.w, c36.y, c36
cmp r7.w, r0, c36.x, r7
if_gt r1.x, c34.x
mov r0.w, c26.x
add r0.w, -c27.x, r0
rcp r2.w, r0.w
add r0.w, r3, -c27.x
mul_sat r0.w, r0, r2
mad r2.w, -r0, c38.y, c38.z
mov r1.xy, r12
mov r1.z, c34.x
texldl r1, r1.xyzz, s1
add r4.w, r1.x, c38
mul r1.x, r0.w, r0.w
mul r1.x, r1, r2.w
mov r0.w, c26.y
add r2.w, -c27.y, r0
mad r0.w, r1.x, r4, c36.x
rcp r2.w, r2.w
add r1.x, r3.w, -c27.y
mul_sat r1.x, r1, r2.w
add r2.w, r1.y, c38
mad r1.y, -r1.x, c38, c38.z
mul r1.x, r1, r1
mul r1.y, r1.x, r1
mad r1.y, r1, r2.w, c36.x
mov r1.x, c26.z
mul r0.w, r0, r1.y
add r1.x, -c27.z, r1
rcp r1.y, r1.x
add r1.x, r3.w, -c27.z
mul_sat r1.x, r1, r1.y
add r2.w, r1.z, c38
mad r1.z, -r1.x, c38.y, c38
mul r1.y, r1.x, r1.x
mul r1.y, r1, r1.z
mov r1.x, c26.w
add r1.z, -c27.w, r1.x
mad r1.x, r1.y, r2.w, c36
rcp r1.z, r1.z
add r1.y, r3.w, -c27.w
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c38.y, c38
mul r1.y, r1, r1
add r1.w, r1, c38
mul r1.y, r1, r1.z
mad r1.y, r1, r1.w, c36.x
mul r0.w, r0, r1.x
mul r7.w, r0, r1.y
endif
mul r10.xyz, r10, r7.w
endif
add r1.xyz, -r5, c23
dp3 r0.w, r1, r1
rsq r0.w, r0.w
mul r1.xyz, r0.w, r1
dp3 r1.x, r8, r1
mul r1.x, r1, c32
add r1.y, r1.x, c36.x
mul r1.x, -c32, c32
add r1.w, r1.x, c36.x
rcp r2.w, r1.y
mul r3.w, r1, r2
mov r1.xyz, c24
add r1.xyz, -c23, r1
dp3 r1.y, r1, r1
add r5.xyz, -r5, c20
dp3 r1.x, r5, r5
mul r2.w, r3, r2
rsq r3.w, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.y
mul r2.w, r1.x, r2
mul r1.xyz, r3.w, r5
rcp r4.w, r0.w
dp3 r0.w, r1, r8
mul r1.x, r4.w, c39
mul r1.x, r1, r1
mul r0.w, r0, c32.x
rcp r1.y, r1.x
add r0.w, r0, c36.x
rcp r1.x, r0.w
mul r0.w, r2, r1.y
mul r1.y, r1.w, r1.x
mul r1.w, r1.y, r1.x
rcp r2.w, r3.w
mov r1.xyz, c21
add r1.xyz, -c20, r1
dp3 r1.x, r1, r1
mul r2.w, r2, c39.x
mul r1.y, r2.w, r2.w
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r1.w
rcp r1.y, r1.y
mul r1.x, r1, r1.y
mul r0.w, r0, c39.x
min r1.y, r0.w, c36.x
mul r0.w, r1.x, c39.x
mul r1.w, r3.y, c30.x
min r0.w, r0, c36.x
mul r1.xyz, r1.y, c25
mad r1.xyz, r0.w, c22, r1
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r1.xyz, r1, c39.y
mul r1.xyz, r1.w, r1
mul r5.xyz, r3.z, -r5
mul r1.w, r13.y, r1
mul r0.w, r0, r13.x
mad r12.xyz, r0.w, c40, r1.w
mul r1.xyz, r1, c39.z
mad r1.xyz, r10, r12, r1
add r10.xyz, r1, c18
pow r1, c38.x, r5.x
mul r3.xyz, r10, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r1
pow r3, c38.x, r5.y
pow r1, c38.x, r5.z
mov r5.y, r3
mov r5.z, r1
mul r9.xyz, r9, r5
endif
add r0.y, r0, -r0.x
mov r1.xyz, r6
mov r12.x, r0
mul r9.w, r0.y, r0.z
cmp_pp r0.x, -r9.w, c36.y, c36
mov r6.xyz, c34.x
if_gt r0.x, c34.x
frc r0.x, r9.w
add r0.x, r9.w, -r0
abs r0.y, r0.x
frc r0.z, r0.y
add r0.y, r0, -r0.z
cmp r11.w, r0.x, r0.y, -r0.y
mov r10.w, c34.x
loop aL, i0
break_ge r10.w, r11.w
mad r10.xyz, r12.x, r8, r7
add r0.xyz, r10, -c8
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r12.w, r0.x
mov r0.x, c13
add r1.w, -c12.x, r0.x
mov r0.xyz, c17
dp3 r0.x, c9, r0
add r0.x, -r0, c36
add r0.w, r12, -c12.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c34.x
mul r0.x, r0, c34.z
texldl r5, r0.xyzz, s0
mul r0.x, r5.w, c31
mad r14.xyz, r5.z, -c29, -r0.x
pow r0, c38.x, r14.y
pow r3, c38.x, r14.x
mov r14.x, r3
mov r14.y, r0
pow r0, c38.x, r14.z
add r3.x, r12, r6.w
rcp r0.y, r6.w
add r0.w, -r12.x, r13
add r0.x, r3, -r13.z
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c36
mov r14.z, r0
mul r0.xyz, r14, r0.x
mov r0.w, c34.x
mul r12.xyz, r0, c16
if_gt c33.x, r0.w
add r3.y, r12.w, -c12.x
add r1.w, r3.y, -c27
mov r0.xyz, r10
mov r0.w, c36.x
dp4 r3.w, r0, c5
dp4 r3.z, r0, c4
cmp_pp r0.x, r1.w, c36.y, c36
cmp r8.w, r1, c36.x, r8
if_gt r0.x, c34.x
mov r0.w, c26.x
add r1.w, -c27.x, r0
rcp r2.w, r1.w
add r1.w, r3.y, -c27.x
mul_sat r1.w, r1, r2
mov r0.xy, r3.zwzw
mov r0.z, c34.x
texldl r0, r0.xyzz, s1
mad r3.z, -r1.w, c38.y, c38
mul r2.w, r1, r1
mul r2.w, r2, r3.z
add r0.x, r0, c38.w
mov r1.w, c26.y
add r1.w, -c27.y, r1
mad r0.x, r2.w, r0, c36
rcp r2.w, r1.w
add r1.w, r3.y, -c27.y
mul_sat r1.w, r1, r2
add r3.z, r0.y, c38.w
mad r2.w, -r1, c38.y, c38.z
mul r0.y, r1.w, r1.w
mul r1.w, r0.y, r2
mad r1.w, r1, r3.z, c36.x
mov r0.y, c26.z
mul r0.x, r0, r1.w
add r0.y, -c27.z, r0
rcp r1.w, r0.y
add r0.y, r3, -c27.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c38
mad r1.w, -r0.y, c38.y, c38.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c26.w
add r1.w, -c27, r0.y
mad r0.y, r0.z, r2.w, c36.x
rcp r1.w, r1.w
add r0.z, r3.y, -c27.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c38
mad r0.w, -r0.z, c38.y, c38.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c36.x
mul r0.x, r0, r0.y
mul r8.w, r0.x, r0.z
endif
mul r12.xyz, r12, r8.w
endif
add r0.xyz, -r10, c23
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c32
add r0.y, r0.x, c36.x
mul r0.x, -c32, c32
add r1.w, r0.x, c36.x
rcp r2.w, r0.y
mul r3.y, r1.w, r2.w
mov r0.xyz, c24
add r0.xyz, -c23, r0
dp3 r0.y, r0, r0
add r10.xyz, -r10, c20
dp3 r0.x, r10, r10
mul r2.w, r3.y, r2
rsq r3.y, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r2.w, r0.x, r2
mul r0.xyz, r3.y, r10
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c39.x
mul r0.x, r0, c32
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r2.w, r0.y
add r0.x, r0, c36
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r2.w, r3.y
mul r0.w, r0.z, c39.x
mul r1.w, r0.y, r0.x
mov r0.xyz, c21
add r0.xyz, -c20, r0
dp3 r0.x, r0, r0
mul r2.w, r2, c39.x
mul r0.y, r2.w, r2.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r1.w
mul r1.w, r5.y, c31.x
mad r10.xyz, r5.x, c29, r1.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
min r0.y, r0.w, c36.x
mul r0.w, r0.x, c39.x
mul r10.xyz, r6.w, -r10
min r0.w, r0, c36.x
mul r0.xyz, r0.y, c25
mad r0.xyz, r0.w, c22, r0
mul r0.w, r5.y, c30.x
mul r0.xyz, r0, c39.y
mul r0.xyz, r0.w, r0
mul r1.w, r5.x, c28.x
mul r2.w, r13.y, r0
mul r0.w, r1, r13.x
mad r5.xyz, r0.w, c40, r2.w
mul r0.xyz, r0, c39.z
mad r0.xyz, r12, r5, r0
add r5.xyz, r0, c18
pow r0, c38.x, r10.x
mul r5.xyz, r5, r6.w
mad r6.xyz, r5, r9, r6
mov r10.x, r0
pow r5, c38.x, r10.y
pow r0, c38.x, r10.z
mov r10.y, r5
mov r10.z, r0
mul r9.xyz, r9, r10
mov r12.x, r3
add r10.w, r10, c36.x
endloop
mad r5.xyz, r12.x, r8, r7
add r0.xyz, r5, -c8
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r5.w, r0.x
mov r0.x, c13
add r1.w, -c12.x, r0.x
mov r0.xyz, c17
dp3 r0.x, c9, r0
add r0.x, -r0, c36
add r0.w, r5, -c12.x
rcp r1.w, r1.w
mul r0.y, r0.w, r1.w
mov r0.z, c34.x
mul r0.x, r0, c34.z
texldl r3, r0.xyzz, s0
mul r0.x, r3.w, c31
mad r7.xyz, r3.z, -c29, -r0.x
pow r0, c38.x, r7.y
pow r10, c38.x, r7.x
add r0.x, r9.w, -r11.w
mul r3.z, r0.x, r6.w
mov r7.y, r0
pow r0, c38.x, r7.z
add r0.x, r3.z, r12
rcp r0.y, r3.z
add r0.x, r0, -r13.z
add r0.w, -r12.x, r13
mul_sat r0.w, r0.y, r0
mul_sat r0.x, r0, r0.y
mad r0.x, -r0, r0.w, c36
mov r7.x, r10
mov r7.z, r0
mul r0.xyz, r7, r0.x
mov r0.w, c34.x
mul r10.xyz, r0, c16
if_gt c33.x, r0.w
add r3.w, r5, -c12.x
add r1.w, r3, -c27
mov r0.xyz, r5
mov r0.w, c36.x
dp4 r12.y, r0, c5
dp4 r12.x, r0, c4
cmp_pp r0.x, r1.w, c36.y, c36
cmp r7.w, r1, c36.x, r7
if_gt r0.x, c34.x
mov r0.w, c26.x
add r1.w, -c27.x, r0
rcp r2.w, r1.w
add r1.w, r3, -c27.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c38.y, c38.z
mul r1.w, r2, r1
mov r0.xy, r12
mov r0.z, c34.x
texldl r0, r0.xyzz, s1
add r4.w, r0.x, c38
mov r0.x, c26.y
add r0.x, -c27.y, r0
rcp r2.w, r0.x
add r0.x, r3.w, -c27.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c38
mad r0.y, -r0.x, c38, c38.z
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c36.x
mov r0.x, c26.z
add r2.w, -c27.z, r0.x
mad r1.w, r1, r4, c36.x
mul r0.x, r1.w, r0.y
rcp r1.w, r2.w
add r0.y, r3.w, -c27.z
mul_sat r0.y, r0, r1.w
add r2.w, r0.z, c38
mad r1.w, -r0.y, c38.y, c38.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r1.w
mov r0.y, c26.w
add r1.w, -c27, r0.y
mad r0.y, r0.z, r2.w, c36.x
rcp r1.w, r1.w
add r0.z, r3.w, -c27.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c38
mad r0.w, -r0.z, c38.y, c38.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c36.x
mul r0.x, r0, r0.y
mul r7.w, r0.x, r0.z
endif
mul r10.xyz, r10, r7.w
endif
add r0.xyz, -r5, c23
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r8, r0
mul r0.x, r0, c32
add r0.y, r0.x, c36.x
mul r0.x, -c32, c32
rcp r2.w, r0.y
add r1.w, r0.x, c36.x
mul r3.w, r1, r2
mov r0.xyz, c24
add r0.xyz, -c23, r0
dp3 r0.y, r0, r0
add r5.xyz, -r5, c20
mul r3.w, r3, r2
dp3 r0.x, r5, r5
rsq r2.w, r0.x
rsq r0.y, r0.y
rcp r0.x, r0.y
mul r3.w, r0.x, r3
mul r0.xyz, r2.w, r5
dp3 r0.x, r0, r8
rcp r0.w, r0.w
mul r0.y, r0.w, c39.x
mul r0.x, r0, c32
mul r0.y, r0, r0
rcp r0.y, r0.y
mul r0.z, r3.w, r0.y
add r0.x, r0, c36
rcp r0.x, r0.x
mul r0.y, r1.w, r0.x
rcp r1.w, r2.w
mul r3.w, r0.z, c39.x
mul r0.w, r0.y, r0.x
mov r0.xyz, c21
add r0.xyz, -c20, r0
dp3 r0.x, r0, r0
mul r1.w, r1, c39.x
mul r0.y, r1.w, r1.w
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c39.x
min r0.y, r3.w, c36.x
mul r1.w, r3.y, c30.x
min r0.w, r0, c36.x
mul r0.xyz, r0.y, c25
mad r0.xyz, r0.w, c22, r0
mul r0.w, r3.y, c31.x
mad r5.xyz, r3.x, c29, r0.w
mul r0.w, r3.x, c28.x
mul r0.xyz, r0, c39.y
mul r0.xyz, r1.w, r0
mul r5.xyz, r3.z, -r5
mul r0.w, r0, r13.x
mul r1.w, r13.y, r1
mad r7.xyz, r0.w, c40, r1.w
mul r0.xyz, r0, c39.z
mad r0.xyz, r10, r7, r0
add r7.xyz, r0, c18
pow r0, c38.x, r5.x
mul r3.xyz, r7, r3.z
mad r6.xyz, r3, r9, r6
mov r5.x, r0
pow r3, c38.x, r5.y
pow r0, c38.x, r5.z
mov r5.y, r3
mov r5.z, r0
mul r9.xyz, r9, r5
endif
texldl r0, v0, s5
mad r3.xyz, r0.w, r6, r1
texldl r1, v0, s4
mad r3.xyz, r1.w, r3, r2
texldl r2, v0, s3
mad r0.xyz, r1.w, r0, r1
mad r4.xyz, r2.w, r3, r4
texldl r3, v0, s2
mad r2.xyz, r2.w, r0, r2
mul r4.w, r3, r2
mul r1.x, r4.w, r1.w
mul r0.x, r1, r0.w
mul r1.xyz, r9, r0.x
mad r4.xyz, r3.w, r4, r11
mad r2.xyz, r3.w, r2, r3
texldl r0.xyz, v0, s6
mad r0.xyz, r0, r1, r2
add oC0.xyz, r0, r4
dp3 oC0.w, r1, c41

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
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_PlanetAtmosphereRadiusKm]
Float 12 [_WorldUnit2Kilometer]
Float 13 [_bComputePlanetShadow]
Vector 14 [_SunColor]
Vector 15 [_SunDirection]
Vector 16 [_AmbientNightSky]
Vector 17 [_NuajLightningPosition00]
Vector 18 [_NuajLightningPosition01]
Vector 19 [_NuajLightningColor0]
Vector 20 [_NuajLightningPosition10]
Vector 21 [_NuajLightningPosition11]
Vector 22 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 23 [_ShadowAltitudesMinKm]
Vector 24 [_ShadowAltitudesMaxKm]
SetTexture 1 [_TexShadowMap] 2D
Float 25 [_DensitySeaLevel_Rayleigh]
Vector 26 [_Sigma_Rayleigh]
Float 27 [_DensitySeaLevel_Mie]
Float 28 [_Sigma_Mie]
Float 29 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexCloudLayer0] 2D
SetTexture 3 [_TexCloudLayer1] 2D
SetTexture 4 [_TexCloudLayer2] 2D
SetTexture 5 [_TexCloudLayer3] 2D
Float 30 [_bGodRays]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[35] = { program.local[0..30],
		{ 0, -1000000, 32, 0.03125 },
		{ 1, 0.5, 2.718282 },
		{ 255, 0, 1 },
		{ 0.21259999, 0.71520001, 0.0722 } };
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
MOVR  R1, c[23];
MOVR  R4.z, c[31].y;
MOVR  R0.y, c[2].w;
MOVR  R0.x, c[0].w;
MULR  R0.xz, R0.xyyw, c[12].x;
MOVR  R0.y, c[31].x;
ADDR  R2.xyz, R0, -c[8];
DP3R  R4.y, R2, c[15];
MULR  R4.w, R4.y, R4.y;
DP3R  R0.w, R2, R2;
ADDR  R1, R1, c[10].x;
MADR  R3, -R1, R1, R0.w;
ADDR  R1, R4.w, -R3;
SLTR  R2, R4.w, R3;
MOVXC RC.x, R2;
MOVR  R4.z(EQ.x), R4.x;
RSQR  R1.x, R1.x;
RSQR  R1.w, R1.w;
RSQR  R1.y, R1.y;
RSQR  R1.z, R1.z;
SGERC HC, R4.w, R3.yzwx;
RCPR  R1.x, R1.x;
ADDR  R4.z(NE.w), -R4.y, R1.x;
MADR  R1.x, -c[11], c[11], R0.w;
ADDR  R2.x, R4.w, -R1;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
MOVR  R0.w, c[31].x;
SLTRC HC.w, R4, R1.x;
MOVR  R0.w(EQ), R4.x;
SGERC HC.w, R4, R1.x;
ADDR  R2.x, -R4.y, R2;
MAXR  R0.w(NE), R2.x, c[31].x;
MINR  R1.x, R0.w, R4.z;
MAXR  R4.w, R1.x, c[31].x;
RCPR  R1.x, R0.w;
MULR  R3.y, R1.x, c[31].z;
MULR  R3.w, R4, R3.y;
MOVR  R1.x, c[31].y;
MOVX  H0.x, c[31];
MOVXC RC.w, R3;
MOVX  H0.x(GT.w), c[32];
MOVXC RC.w, R2;
MOVR  R1.x(EQ.w), R4;
RCPR  R1.w, R1.w;
ADDR  R1.x(NE.z), -R4.y, R1.w;
MINR  R1.x, R0.w, R1;
MOVR  R1.w, c[31].y;
MOVXC RC.z, R2.y;
MOVR  R1.w(EQ.z), R4.x;
RCPR  R1.y, R1.y;
ADDR  R1.w(NE.x), -R4.y, R1.y;
MOVXC RC.x, H0;
MOVR  R1.y, c[31];
MOVXC RC.z, R2;
MOVR  R1.y(EQ.z), R4.x;
RCPR  R1.z, R1.z;
ADDR  R1.y(NE), -R4, R1.z;
MINR  R1.z, R0.w, R1.w;
MINR  R1.y, R0.w, R1;
MAXR  R1.w, R1.z, c[31].x;
MAXR  R2.w, R1.y, c[31].x;
MAXR  R3.x, R1, c[31];
MULR  R3.z, R0.w, c[31].w;
MOVR  R1.xyz, c[32].x;
MOVR  R4.z, c[31].x;
IF    NE.x;
FLRR  R4.x, R3.w;
MOVR  R4.y, c[31].x;
LOOP c[33];
SLTRC HC.x, R4.y, R4;
BRK   (EQ.x);
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R2.x, R2, R2;
RSQR  R2.x, R2.x;
RCPR  R5.x, R2.x;
MOVR  R2.x, c[10];
ADDR  R5.z, -R2.x, c[11].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
MOVXC RC.x, c[30];
ADDR  R5.y, R5.x, -c[10].x;
RCPR  R5.z, R5.z;
MULR  R2.y, R5, R5.z;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
ADDR  R4.z, R4, R3;
IF    NE.x;
ADDR  R2.z, R5.x, -c[10].x;
SLTRC HC.x, R2.z, c[24].w;
IF    NE.x;
ENDIF;
ENDIF;
MULR  R2.y, R2, c[28].x;
MADR  R2.xyz, R2.x, c[26], R2.y;
MULR  R2.xyz, -R2, R3.z;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ADDR  R4.y, R4, c[32].x;
ENDLOOP;
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R2.x, R2, R2;
RSQR  R2.x, R2.x;
RCPR  R2.y, R2.x;
MOVR  R2.x, c[10];
ADDR  R4.z, -R2.x, c[11].x;
ADDR  R4.y, R2, -c[10].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
ADDR  R2.z, R3.w, -R4.x;
RCPR  R4.z, R4.z;
MULR  R3.w, R2.z, R3.z;
MULR  R2.y, R4, R4.z;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
MULR  R2.y, R2, c[28].x;
MADR  R2.xyz, R2.x, c[26], R2.y;
MULR  R2.xyz, -R2, R3.w;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ENDIF;
ADDR  R2.x, R1.w, -R4.w;
MULR  R3.w, R2.x, R3.y;
MOVX  H0.x, c[31];
MOVXC RC.x, R3.w;
MOVX  H0.x(GT), c[32];
MOVXC RC.x, H0;
MOVR  R4.z, R4.w;
IF    NE.x;
FLRR  R4.x, R3.w;
MOVR  R4.y, c[31].x;
LOOP c[33];
SLTRC HC.x, R4.y, R4;
BRK   (EQ.x);
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R2.x, R2, R2;
RSQR  R2.x, R2.x;
RCPR  R5.x, R2.x;
MOVR  R2.x, c[10];
ADDR  R5.y, -R2.x, c[11].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
MOVXC RC.x, c[30];
ADDR  R4.w, R5.x, -c[10].x;
RCPR  R5.y, R5.y;
MULR  R2.y, R4.w, R5;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
ADDR  R4.z, R4, R3;
IF    NE.x;
ADDR  R2.z, R5.x, -c[10].x;
SLTRC HC.x, R2.z, c[24].w;
IF    NE.x;
ENDIF;
ENDIF;
MULR  R2.y, R2, c[28].x;
MADR  R2.xyz, R2.x, c[26], R2.y;
MULR  R2.xyz, -R2, R3.z;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ADDR  R4.y, R4, c[32].x;
ENDLOOP;
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R2.x, R2, R2;
RSQR  R2.x, R2.x;
RCPR  R2.y, R2.x;
MOVR  R2.x, c[10];
ADDR  R4.z, -R2.x, c[11].x;
ADDR  R4.y, R2, -c[10].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
ADDR  R2.z, R3.w, -R4.x;
RCPR  R4.z, R4.z;
MULR  R3.w, R2.z, R3.z;
MULR  R2.y, R4, R4.z;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
MULR  R2.y, R2, c[28].x;
MADR  R2.xyz, R2.x, c[26], R2.y;
MULR  R2.xyz, -R2, R3.w;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ENDIF;
ADDR  R2.x, R2.w, -R1.w;
MULR  R3.w, R2.x, R3.y;
MOVX  H0.x, c[31];
MOVXC RC.x, R3.w;
MOVX  H0.x(GT), c[32];
MOVXC RC.x, H0;
MOVR  R4.z, R1.w;
IF    NE.x;
FLRR  R4.x, R3.w;
MOVR  R4.y, c[31].x;
LOOP c[33];
SLTRC HC.x, R4.y, R4;
BRK   (EQ.x);
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R1.w, R2, R2;
RSQR  R1.w, R1.w;
MOVR  R2.x, c[10];
ADDR  R4.w, -R2.x, c[11].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
RCPR  R5.x, R1.w;
MOVXC RC.x, c[30];
ADDR  R1.w, R5.x, -c[10].x;
RCPR  R4.w, R4.w;
MULR  R2.y, R1.w, R4.w;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
ADDR  R4.z, R4, R3;
IF    NE.x;
ADDR  R1.w, R5.x, -c[10].x;
SLTRC HC.x, R1.w, c[24].w;
IF    NE.x;
ENDIF;
ENDIF;
MULR  R1.w, R2.y, c[28].x;
MADR  R2.xyz, R2.x, c[26], R1.w;
MULR  R2.xyz, -R2, R3.z;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ADDR  R4.y, R4, c[32].x;
ENDLOOP;
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R1.w, R2, R2;
MOVR  R2.x, c[10];
ADDR  R4.y, -R2.x, c[11].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
ADDR  R1.w, R1, -c[10].x;
RCPR  R4.y, R4.y;
MULR  R2.y, R1.w, R4;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
ADDR  R1.w, R3, -R4.x;
MULR  R2.y, R2, c[28].x;
MULR  R1.w, R1, R3.z;
MADR  R2.xyz, R2.x, c[26], R2.y;
MULR  R2.xyz, -R2, R1.w;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ENDIF;
ADDR  R1.w, R3.x, -R2;
MULR  R3.w, R1, R3.y;
MOVX  H0.x, c[31];
MOVXC RC.x, R3.w;
MOVX  H0.x(GT), c[32];
MOVXC RC.x, H0;
MOVR  R4.z, R2.w;
IF    NE.x;
FLRR  R4.x, R3.w;
MOVR  R4.y, c[31].x;
LOOP c[33];
SLTRC HC.x, R4.y, R4;
BRK   (EQ.x);
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R1.w, R2, R2;
RSQR  R1.w, R1.w;
MOVR  R2.x, c[10];
ADDR  R2.w, -R2.x, c[11].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
RCPR  R5.x, R1.w;
MOVXC RC.x, c[30];
ADDR  R1.w, R5.x, -c[10].x;
RCPR  R2.w, R2.w;
MULR  R2.y, R1.w, R2.w;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
ADDR  R4.z, R4, R3;
IF    NE.x;
ADDR  R1.w, R5.x, -c[10].x;
SLTRC HC.x, R1.w, c[24].w;
IF    NE.x;
ENDIF;
ENDIF;
MULR  R1.w, R2.y, c[28].x;
MADR  R2.xyz, R2.x, c[26], R1.w;
MULR  R2.xyz, -R2, R3.z;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ADDR  R4.y, R4, c[32].x;
ENDLOOP;
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R1.w, R2, R2;
MOVR  R2.x, c[10];
ADDR  R2.w, -R2.x, c[11].x;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
ADDR  R1.w, R1, -c[10].x;
RCPR  R2.w, R2.w;
MULR  R2.y, R1.w, R2.w;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
ADDR  R1.w, R3, -R4.x;
MULR  R2.y, R2, c[28].x;
MULR  R1.w, R1, R3.z;
MADR  R2.xyz, R2.x, c[26], R2.y;
MULR  R2.xyz, -R2, R1.w;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ENDIF;
ADDR  R0.w, R0, -R3.x;
MULR  R3.w, R0, R3.y;
MOVX  H0.x, c[31];
MOVXC RC.x, R3.w;
MOVX  H0.x(GT), c[32];
MOVXC RC.x, H0;
MOVR  R4.z, R3.x;
IF    NE.x;
FLRR  R4.x, R3.w;
MOVR  R4.y, c[31].x;
LOOP c[33];
SLTRC HC.x, R4.y, R4;
BRK   (EQ.x);
MADR  R2.xyz, R4.z, c[15], R0;
ADDR  R2.xyz, R2, -c[8];
DP3R  R0.w, R2, R2;
RSQR  R0.w, R0.w;
MOVR  R2.xyz, c[9];
DP3R  R2.x, R2, c[15];
RCPR  R5.x, R0.w;
MOVR  R1.w, c[10].x;
ADDR  R1.w, -R1, c[11].x;
MOVXC RC.x, c[30];
ADDR  R0.w, R5.x, -c[10].x;
RCPR  R1.w, R1.w;
MULR  R2.y, R0.w, R1.w;
MADR  R2.x, -R2, c[32].y, c[32].y;
TEX   R2.xy, R2, texture[0], 2D;
ADDR  R4.z, R4, R3;
IF    NE.x;
ADDR  R0.w, R5.x, -c[10].x;
SLTRC HC.x, R0.w, c[24].w;
IF    NE.x;
ENDIF;
ENDIF;
MULR  R0.w, R2.y, c[28].x;
MADR  R2.xyz, R2.x, c[26], R0.w;
MULR  R2.xyz, -R2, R3.z;
POWR  R2.x, c[32].z, R2.x;
POWR  R2.z, c[32].z, R2.z;
POWR  R2.y, c[32].z, R2.y;
MULR  R1.xyz, R1, R2;
ADDR  R4.y, R4, c[32].x;
ENDLOOP;
MADR  R0.xyz, R4.z, c[15], R0;
ADDR  R0.xyz, R0, -c[8];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.y, R0.x;
MOVR  R0.x, c[10];
ADDR  R1.w, -R0.x, c[11].x;
ADDR  R0.w, R0.y, -c[10].x;
MOVR  R0.xyz, c[9];
DP3R  R0.x, R0, c[15];
RCPR  R1.w, R1.w;
MULR  R0.y, R0.w, R1.w;
ADDR  R0.z, R3.w, -R4.x;
MADR  R0.x, -R0, c[32].y, c[32].y;
TEX   R0.xy, R0, texture[0], 2D;
MULR  R0.w, R0.z, R3.z;
MULR  R0.y, R0, c[28].x;
MADR  R0.xyz, R0.x, c[26], R0.y;
MULR  R0.xyz, -R0, R0.w;
POWR  R0.x, c[32].z, R0.x;
POWR  R0.z, c[32].z, R0.z;
POWR  R0.y, c[32].z, R0.y;
MULR  R1.xyz, R1, R0;
ENDIF;
TEX   R1.w, fragment.texcoord[0], texture[3], 2D;
TEX   R0.w, fragment.texcoord[0], texture[2], 2D;
MULR  R0.x, R0.w, R1.w;
TEX   R1.w, fragment.texcoord[0], texture[4], 2D;
TEX   R0.w, fragment.texcoord[0], texture[5], 2D;
MULR  R0.x, R0, R1.w;
MULR  R0.x, R0, R0.w;
MULR  R0.xyz, R1, R0.x;
MULR  oCol.xyz, R0, c[14];
DP3R  oCol.w, R0, c[34];
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_PlanetAtmosphereRadiusKm]
Float 12 [_WorldUnit2Kilometer]
Vector 13 [_SunColor]
Vector 14 [_SunDirection]
Matrix 4 [_NuajWorld2Shadow]
Vector 15 [_ShadowAltitudesMinKm]
Vector 16 [_ShadowAltitudesMaxKm]
SetTexture 1 [_TexShadowMap] 2D
Vector 17 [_Sigma_Rayleigh]
Float 18 [_Sigma_Mie]
SetTexture 0 [_TexDensity] 2D
SetTexture 2 [_TexCloudLayer0] 2D
SetTexture 3 [_TexCloudLayer1] 2D
SetTexture 4 [_TexCloudLayer2] 2D
SetTexture 5 [_TexCloudLayer3] 2D
Float 19 [_bGodRays]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c20, 0.00000000, 1.00000000, -1000000.00000000, 32.00000000
def c21, 0.03125000, 0.50000000, 2.71828198, 0
defi i0, 255, 0, 1, 0
def c22, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
mov r0.y, c2.w
mov r0.x, c0.w
mov r1.w, c10.x
mul r6.xz, r0.xyyw, c12.x
mov r6.y, c20.x
add r0.xyz, r6, -c8
dp3 r0.w, r0, r0
dp3 r0.x, r0, c14
mad r1.z, -c11.x, c11.x, r0.w
mad r0.y, r0.x, r0.x, -r1.z
rsq r0.z, r0.y
rcp r1.z, r0.z
cmp_pp r0.z, r0.y, c20.y, c20.x
add r1.z, -r0.x, r1
cmp r0.y, r0, r1.x, c20.x
max r1.z, r1, c20.x
cmp r2.y, -r0.z, r0, r1.z
add r0.z, c15.y, r1.w
mov r0.y, c10.x
add r1.z, c15, r0.y
mad r0.z, -r0, r0, r0.w
mad r0.y, r0.x, r0.x, -r0.z
mad r1.z, -r1, r1, r0.w
mad r1.w, r0.x, r0.x, -r1.z
rsq r0.z, r0.y
rcp r1.z, r0.z
cmp_pp r0.z, r0.y, c20.y, c20.x
cmp r0.y, r0, r1.x, c20.z
add r1.z, -r0.x, r1
cmp r0.y, -r0.z, r0, r1.z
rsq r0.z, r1.w
rcp r1.z, r0.z
min r0.y, r2, r0
max r2.x, r0.y, c20
add r1.z, -r0.x, r1
cmp r1.x, r1.w, r1, c20.z
cmp_pp r0.z, r1.w, c20.y, c20.x
cmp r0.z, -r0, r1.x, r1
min r0.z, r2.y, r0
mov r0.y, c10.x
max r1.x, r0.z, c20
add r0.z, c15.w, r0.y
mad r0.z, -r0, r0, r0.w
mov r0.y, c10.x
add r0.y, c15.x, r0
mad r0.y, -r0, r0, r0.w
mad r0.z, r0.x, r0.x, -r0
rsq r0.w, r0.z
rcp r1.z, r0.w
cmp_pp r0.w, r0.z, c20.y, c20.x
mad r0.y, r0.x, r0.x, -r0
cmp r0.z, r0, r1.y, c20
add r1.z, -r0.x, r1
cmp r0.w, -r0, r0.z, r1.z
rsq r0.z, r0.y
min r1.z, r2.y, r0.w
rcp r0.w, r0.z
add r0.w, -r0.x, r0
cmp r0.x, r0.y, r1.y, c20.z
cmp_pp r0.z, r0.y, c20.y, c20.x
cmp r0.x, -r0.z, r0, r0.w
rcp r0.y, r2.y
min r0.x, r2.y, r0
mul r2.z, r0.y, c20.w
max r4.x, r0, c20
max r0.x, r1.z, c20
mul r3.y, r4.x, r2.z
cmp_pp r1.z, -r3.y, c20.x, c20.y
mul r2.w, r2.y, c21.x
mov r0.yzw, c20.y
mov r1.y, c20.x
if_gt r1.z, c20.x
frc r1.z, r3.y
add r1.z, r3.y, -r1
abs r1.w, r1.z
frc r3.x, r1.w
add r1.w, r1, -r3.x
cmp r3.z, r1, r1.w, -r1.w
mov r3.w, c20.x
loop aL, i0
break_ge r3.w, r3.z
mad r5.xyz, r1.y, c14, r6
add r5.xyz, r5, -c8
dp3 r1.z, r5, r5
mov r5.xyz, c14
dp3 r4.y, c9, r5
rsq r1.z, r1.z
rcp r1.z, r1.z
mov r3.x, c11
add r3.x, -c10, r3
add r1.w, r1.z, -c10.x
rcp r3.x, r3.x
mul r5.y, r1.w, r3.x
add r1.w, -r4.y, c20.y
mul r5.x, r1.w, c21.y
mov r5.z, c20.x
mov r1.w, c20.x
texldl r5.xy, r5.xyzz, s0
add r3.x, r1.y, r2.w
if_gt c19.x, r1.w
add r1.y, r1.z, -c10.x
add r1.y, r1, -c16.w
cmp_pp r1.y, r1, c20.x, c20
if_gt r1.y, c20.x
endif
endif
mul r1.y, r5, c18.x
mad r5.xyz, r5.x, c17, r1.y
mul r1.yzw, -r5.xxyz, r2.w
pow r5, c21.z, r1.y
mov r1.y, r5.x
pow r5, c21.z, r1.w
pow r7, c21.z, r1.z
mov r1.w, r5.z
mov r1.z, r7.y
mul r0.yzw, r0, r1
mov r1.y, r3.x
add r3.w, r3, c20.y
endloop
mad r5.xyz, r1.y, c14, r6
add r5.xyz, r5, -c8
dp3 r1.y, r5, r5
rsq r1.y, r1.y
rcp r1.y, r1.y
mov r5.xyz, c14
add r1.z, r1.y, -c10.x
mov r1.w, c11.x
add r1.y, -c10.x, r1.w
rcp r1.w, r1.y
dp3 r1.y, c9, r5
mul r5.y, r1.z, r1.w
add r1.y, -r1, c20
add r1.z, r3.y, -r3
mov r5.z, c20.x
mul r5.x, r1.y, c21.y
texldl r5.xy, r5.xyzz, s0
mul r1.y, r5, c18.x
mad r3.xyz, r5.x, c17, r1.y
mul r1.z, r1, r2.w
mul r7.xyz, -r3, r1.z
pow r3, c21.z, r7.x
mov r7.x, r3
pow r3, c21.z, r7.z
pow r5, c21.z, r7.y
mov r7.z, r3
mov r7.y, r5
mul r0.yzw, r0, r7.xxyz
endif
add r1.y, r2.x, -r4.x
mul r3.y, r1, r2.z
cmp_pp r1.z, -r3.y, c20.x, c20.y
mov r1.y, r4.x
if_gt r1.z, c20.x
frc r1.z, r3.y
add r1.z, r3.y, -r1
abs r1.w, r1.z
frc r3.x, r1.w
add r1.w, r1, -r3.x
cmp r3.z, r1, r1.w, -r1.w
mov r3.w, c20.x
loop aL, i0
break_ge r3.w, r3.z
mad r4.xyz, r1.y, c14, r6
add r4.xyz, r4, -c8
dp3 r1.z, r4, r4
mov r4.xyz, c14
dp3 r4.x, c9, r4
rsq r1.z, r1.z
rcp r1.z, r1.z
mov r3.x, c11
add r3.x, -c10, r3
add r1.w, r1.z, -c10.x
rcp r3.x, r3.x
mul r4.y, r1.w, r3.x
add r1.w, -r4.x, c20.y
mul r4.x, r1.w, c21.y
mov r4.z, c20.x
mov r1.w, c20.x
texldl r5.xy, r4.xyzz, s0
add r3.x, r1.y, r2.w
if_gt c19.x, r1.w
add r1.y, r1.z, -c10.x
add r1.y, r1, -c16.w
cmp_pp r1.y, r1, c20.x, c20
if_gt r1.y, c20.x
endif
endif
mul r1.y, r5, c18.x
mad r4.xyz, r5.x, c17, r1.y
mul r5.xyz, -r4, r2.w
pow r4, c21.z, r5.x
mov r5.x, r4
pow r4, c21.z, r5.z
pow r7, c21.z, r5.y
mov r5.z, r4
mov r5.y, r7
mul r0.yzw, r0, r5.xxyz
mov r1.y, r3.x
add r3.w, r3, c20.y
endloop
mad r4.xyz, r1.y, c14, r6
add r4.xyz, r4, -c8
dp3 r1.y, r4, r4
rsq r1.y, r1.y
rcp r1.y, r1.y
mov r4.xyz, c14
add r1.z, r1.y, -c10.x
mov r1.w, c11.x
add r1.y, -c10.x, r1.w
rcp r1.w, r1.y
dp3 r1.y, c9, r4
mul r4.y, r1.z, r1.w
add r1.y, -r1, c20
add r1.z, r3.y, -r3
mov r4.z, c20.x
mul r4.x, r1.y, c21.y
texldl r4.xy, r4.xyzz, s0
mul r1.y, r4, c18.x
mad r3.xyz, r4.x, c17, r1.y
mul r1.z, r1, r2.w
mul r5.xyz, -r3, r1.z
pow r3, c21.z, r5.x
mov r5.x, r3
pow r3, c21.z, r5.z
pow r4, c21.z, r5.y
mov r5.z, r3
mov r5.y, r4
mul r0.yzw, r0, r5.xxyz
endif
add r1.y, r1.x, -r2.x
mul r3.y, r1, r2.z
cmp_pp r1.z, -r3.y, c20.x, c20.y
mov r1.y, r2.x
if_gt r1.z, c20.x
frc r1.z, r3.y
add r1.z, r3.y, -r1
abs r1.w, r1.z
frc r2.x, r1.w
add r1.w, r1, -r2.x
cmp r3.z, r1, r1.w, -r1.w
mov r3.w, c20.x
loop aL, i0
break_ge r3.w, r3.z
mad r4.xyz, r1.y, c14, r6
add r4.xyz, r4, -c8
dp3 r1.z, r4, r4
mov r4.xyz, c14
dp3 r3.x, c9, r4
rsq r1.z, r1.z
rcp r1.z, r1.z
mov r2.x, c11
add r2.x, -c10, r2
add r1.w, r1.z, -c10.x
rcp r2.x, r2.x
mul r4.y, r1.w, r2.x
add r1.w, -r3.x, c20.y
mul r4.x, r1.w, c21.y
mov r4.z, c20.x
mov r1.w, c20.x
texldl r5.xy, r4.xyzz, s0
add r3.x, r1.y, r2.w
if_gt c19.x, r1.w
add r1.y, r1.z, -c10.x
add r1.y, r1, -c16.w
cmp_pp r1.y, r1, c20.x, c20
if_gt r1.y, c20.x
endif
endif
mul r1.y, r5, c18.x
mad r4.xyz, r5.x, c17, r1.y
mul r5.xyz, -r4, r2.w
pow r4, c21.z, r5.x
mov r5.x, r4
pow r4, c21.z, r5.z
pow r7, c21.z, r5.y
mov r5.z, r4
mov r5.y, r7
mul r0.yzw, r0, r5.xxyz
mov r1.y, r3.x
add r3.w, r3, c20.y
endloop
mad r4.xyz, r1.y, c14, r6
add r4.xyz, r4, -c8
dp3 r1.y, r4, r4
rsq r1.y, r1.y
rcp r1.y, r1.y
mov r4.xyz, c14
add r1.z, r1.y, -c10.x
mov r1.w, c11.x
add r1.y, -c10.x, r1.w
rcp r1.w, r1.y
dp3 r1.y, c9, r4
mul r4.y, r1.z, r1.w
add r1.y, -r1, c20
add r1.z, r3.y, -r3
mov r4.z, c20.x
mul r4.x, r1.y, c21.y
texldl r4.xy, r4.xyzz, s0
mul r1.y, r4, c18.x
mad r3.xyz, r4.x, c17, r1.y
mul r1.z, r1, r2.w
mul r4.xyz, -r3, r1.z
pow r3, c21.z, r4.x
mov r4.x, r3
pow r3, c21.z, r4.z
pow r5, c21.z, r4.y
mov r4.z, r3
mov r4.y, r5
mul r0.yzw, r0, r4.xxyz
endif
add r1.y, r0.x, -r1.x
mul r3.y, r1, r2.z
cmp_pp r1.z, -r3.y, c20.x, c20.y
mov r1.y, r1.x
if_gt r1.z, c20.x
frc r1.x, r3.y
add r1.x, r3.y, -r1
abs r1.z, r1.x
frc r1.w, r1.z
add r1.z, r1, -r1.w
cmp r3.z, r1.x, r1, -r1
mov r3.w, c20.x
loop aL, i0
break_ge r3.w, r3.z
mad r4.xyz, r1.y, c14, r6
add r4.xyz, r4, -c8
dp3 r1.x, r4, r4
mov r4.xyz, c14
dp3 r2.x, c9, r4
rsq r1.x, r1.x
rcp r1.z, r1.x
mov r1.w, c11.x
add r1.w, -c10.x, r1
add r1.x, r1.z, -c10
rcp r1.w, r1.w
mul r4.y, r1.x, r1.w
add r1.x, -r2, c20.y
mul r4.x, r1, c21.y
mov r4.z, c20.x
mov r1.x, c20
texldl r5.xy, r4.xyzz, s0
add r3.x, r1.y, r2.w
if_gt c19.x, r1.x
add r1.x, r1.z, -c10
add r1.x, r1, -c16.w
cmp_pp r1.x, r1, c20, c20.y
if_gt r1.x, c20.x
endif
endif
mul r1.x, r5.y, c18
mad r1.xyz, r5.x, c17, r1.x
mul r5.xyz, -r1, r2.w
pow r1, c21.z, r5.x
mov r5.x, r1
pow r1, c21.z, r5.z
pow r4, c21.z, r5.y
mov r5.z, r1
mov r5.y, r4
mul r0.yzw, r0, r5.xxyz
mov r1.y, r3.x
add r3.w, r3, c20.y
endloop
mad r1.xyz, r1.y, c14, r6
add r1.xyz, r1, -c8
dp3 r1.x, r1, r1
mov r1.y, c11.x
add r2.x, -c10, r1.y
rsq r1.x, r1.x
rcp r1.x, r1.x
add r1.w, r1.x, -c10.x
mov r1.xyz, c14
dp3 r1.x, c9, r1
rcp r2.x, r2.x
add r1.x, -r1, c20.y
mul r1.y, r1.w, r2.x
mov r1.z, c20.x
mul r1.x, r1, c21.y
texldl r1.xy, r1.xyzz, s0
add r1.z, r3.y, -r3
mul r1.w, r1.z, r2
mul r1.y, r1, c18.x
mad r1.xyz, r1.x, c17, r1.y
mul r3.xyz, -r1, r1.w
pow r1, c21.z, r3.x
mov r3.x, r1
pow r1, c21.z, r3.z
pow r4, c21.z, r3.y
mov r3.z, r1
mov r3.y, r4
mul r0.yzw, r0, r3.xxyz
endif
add r1.x, r2.y, -r0
mul r3.y, r1.x, r2.z
cmp_pp r1.x, -r3.y, c20, c20.y
mov r1.y, r0.x
if_gt r1.x, c20.x
frc r0.x, r3.y
add r0.x, r3.y, -r0
abs r1.x, r0
frc r1.z, r1.x
add r1.x, r1, -r1.z
cmp r3.z, r0.x, r1.x, -r1.x
mov r3.w, c20.x
loop aL, i0
break_ge r3.w, r3.z
mad r2.xyz, r1.y, c14, r6
add r2.xyz, r2, -c8
dp3 r0.x, r2, r2
mov r2.xyz, c14
dp3 r1.w, c9, r2
rsq r0.x, r0.x
rcp r1.z, r0.x
mov r1.x, c11
add r1.x, -c10, r1
add r0.x, r1.z, -c10
rcp r1.x, r1.x
mul r2.y, r0.x, r1.x
add r0.x, -r1.w, c20.y
mul r2.x, r0, c21.y
mov r2.z, c20.x
mov r0.x, c20
texldl r5.xy, r2.xyzz, s0
add r3.x, r1.y, r2.w
if_gt c19.x, r0.x
add r0.x, r1.z, -c10
add r0.x, r0, -c16.w
cmp_pp r0.x, r0, c20, c20.y
if_gt r0.x, c20.x
endif
endif
mul r0.x, r5.y, c18
mad r1.xyz, r5.x, c17, r0.x
mul r2.xyz, -r1, r2.w
pow r1, c21.z, r2.x
mov r2.x, r1
pow r1, c21.z, r2.z
pow r4, c21.z, r2.y
mov r2.z, r1
mov r2.y, r4
mul r0.yzw, r0, r2.xxyz
mov r1.y, r3.x
add r3.w, r3, c20.y
endloop
mad r1.xyz, r1.y, c14, r6
add r1.xyz, r1, -c8
dp3 r0.x, r1, r1
rsq r0.x, r0.x
rcp r0.x, r0.x
add r1.w, r0.x, -c10.x
mov r1.x, c11
add r0.x, -c10, r1
mov r1.xyz, c14
rcp r2.x, r0.x
dp3 r0.x, c9, r1
add r0.x, -r0, c20.y
mul r1.y, r1.w, r2.x
mov r1.z, c20.x
mul r1.x, r0, c21.y
texldl r1.xy, r1.xyzz, s0
add r1.z, r3.y, -r3
mul r1.w, r1.z, r2
mul r0.x, r1.y, c18
mad r1.xyz, r1.x, c17, r0.x
mul r2.xyz, -r1, r1.w
pow r1, c21.z, r2.x
mov r2.x, r1
pow r1, c21.z, r2.z
pow r3, c21.z, r2.y
mov r2.z, r1
mov r2.y, r3
mul r0.yzw, r0, r2.xxyz
endif
texldl r2.w, v0, s3
texldl r1.w, v0, s2
mul r0.x, r1.w, r2.w
texldl r2.w, v0, s4
texldl r1.w, v0, s5
mul r0.x, r0, r2.w
mul r0.x, r0, r1.w
mul r0.xyz, r0.yzww, r0.x
mul oC0.xyz, r0, c13
dp3 oC0.w, r0, c22

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 is used to compute a simple downscale for the envmaps
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
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D
Vector 1 [_EnvironmentAngles]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[3] = { program.local[0..1],
		{ 0.5, 0.89999998, 0.1, 0.25 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R0.x, c[2];
MADR  R0.xy, R0.x, -c[0], fragment.texcoord[0];
ADDR  R2.xy, R0, c[0].xzzw;
MADR  R0.z, R2.y, c[1].w, c[1].y;
TEX   R1, R2, texture[0], 2D;
MADR  R2.z, R0.y, c[1].w, c[1].y;
COSR  R0.z, R0.z;
MADR  R0.z, R0, c[2].y, c[2];
MULR  R1, R0.z, R1;
COSR  R2.z, R2.z;
ADDR  R2.xy, R2, c[0].zyzw;
TEX   R0, R0, texture[0], 2D;
MADR  R2.z, R2, c[2].y, c[2];
MADR  R1, R2.z, R0, R1;
MADR  R2.z, R2.y, c[1].w, c[1].y;
TEX   R0, R2, texture[0], 2D;
COSR  R2.w, R2.z;
ADDR  R2.xy, R2, -c[0].xzzw;
MADR  R2.z, R2.y, c[1].w, c[1].y;
MADR  R2.w, R2, c[2].y, c[2].z;
MADR  R0, R2.w, R0, R1;
TEX   R1, R2, texture[0], 2D;
COSR  R2.z, R2.z;
MADR  R2.x, R2.z, c[2].y, c[2].z;
MADR  R0, R2.x, R1, R0;
MULR  oCol, R0, c[2].w;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D
Vector 1 [_EnvironmentAngles]

"ps_3_0
dcl_2d s0
def c2, 0.50000000, 0.15915491, 6.28318501, -3.14159298
def c3, 0.89999998, 0.10000000, 0.25000000, 0
dcl_texcoord0 v0.xyzw
mov r0.xy, c0
mad r0.xy, c2.x, -r0, v0
mov r0.z, v0.w
add r2.xyz, r0, c0.xzzw
mad r0.w, r0.y, c1, c1.y
mad r1.x, r2.y, c1.w, c1.y
mad r0.w, r0, c2.y, c2.x
mad r1.x, r1, c2.y, c2
frc r1.x, r1
mad r2.w, r1.x, c2.z, c2
sincos r1.xy, r2.w
frc r0.w, r0
mad r0.w, r0, c2.z, c2
sincos r3.xy, r0.w
mad r2.w, r3.x, c3.x, c3.y
add r3.xyz, r2, c0.zyzw
texldl r4, r2.xyzz, s0
mad r0.w, r1.x, c3.x, c3.y
mul r1, r0.w, r4
texldl r0, r0.xyzz, s0
mad r1, r2.w, r0, r1
add r4.xyz, r3, -c0.xzzw
mad r0.y, r3, c1.w, c1
mad r0.x, r4.y, c1.w, c1.y
mad r0.y, r0, c2, c2.x
frc r0.y, r0
mad r0.x, r0, c2.y, c2
frc r0.x, r0
mad r2.x, r0.y, c2.z, c2.w
mad r3.w, r0.x, c2.z, c2
sincos r0.xy, r2.x
sincos r2.xy, r3.w
mad r2.y, r0.x, c3.x, c3
texldl r0, r3.xyzz, s0
mad r0, r2.y, r0, r1
mad r2.x, r2, c3, c3.y
texldl r1, r4.xyzz, s0
mad r0, r2.x, r1, r0
mul oC0, r0, c3.z

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 (i.e. Final Downscale Pass) is used to compute a simple downscale for the envmaps but also combines it in MODULATE mode with existing value (extinction component W only)
		Pass
		{
			Blend DstColor Zero		// Multiplicative

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
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D
Vector 1 [_EnvironmentAngles]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[3] = { program.local[0..1],
		{ 0.5, 0.89999998, 0.1, 0.25 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R0.x, c[2];
MADR  R0.xy, R0.x, -c[0], fragment.texcoord[0];
ADDR  R2.xy, R0, c[0].xzzw;
MADR  R0.z, R2.y, c[1].w, c[1].y;
TEX   R1, R2, texture[0], 2D;
MADR  R2.z, R0.y, c[1].w, c[1].y;
COSR  R0.z, R0.z;
MADR  R0.z, R0, c[2].y, c[2];
MULR  R1, R0.z, R1;
COSR  R2.z, R2.z;
ADDR  R2.xy, R2, c[0].zyzw;
TEX   R0, R0, texture[0], 2D;
MADR  R2.z, R2, c[2].y, c[2];
MADR  R1, R2.z, R0, R1;
MADR  R2.z, R2.y, c[1].w, c[1].y;
TEX   R0, R2, texture[0], 2D;
COSR  R2.w, R2.z;
ADDR  R2.xy, R2, -c[0].xzzw;
MADR  R2.z, R2.y, c[1].w, c[1].y;
MADR  R2.w, R2, c[2].y, c[2].z;
MADR  R0, R2.w, R0, R1;
TEX   R1, R2, texture[0], 2D;
COSR  R2.z, R2.z;
MADR  R2.x, R2.z, c[2].y, c[2].z;
MADR  R0, R2.x, R1, R0;
MULR  oCol, R0, c[2].w;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D
Vector 1 [_EnvironmentAngles]

"ps_3_0
dcl_2d s0
def c2, 0.50000000, 0.15915491, 6.28318501, -3.14159298
def c3, 0.89999998, 0.10000000, 0.25000000, 0
dcl_texcoord0 v0.xyzw
mov r0.xy, c0
mad r0.xy, c2.x, -r0, v0
mov r0.z, v0.w
add r2.xyz, r0, c0.xzzw
mad r0.w, r0.y, c1, c1.y
mad r1.x, r2.y, c1.w, c1.y
mad r0.w, r0, c2.y, c2.x
mad r1.x, r1, c2.y, c2
frc r1.x, r1
mad r2.w, r1.x, c2.z, c2
sincos r1.xy, r2.w
frc r0.w, r0
mad r0.w, r0, c2.z, c2
sincos r3.xy, r0.w
mad r2.w, r3.x, c3.x, c3.y
add r3.xyz, r2, c0.zyzw
texldl r4, r2.xyzz, s0
mad r0.w, r1.x, c3.x, c3.y
mul r1, r0.w, r4
texldl r0, r0.xyzz, s0
mad r1, r2.w, r0, r1
add r4.xyz, r3, -c0.xzzw
mad r0.y, r3, c1.w, c1
mad r0.x, r4.y, c1.w, c1.y
mad r0.y, r0, c2, c2.x
frc r0.y, r0
mad r0.x, r0, c2.y, c2
frc r0.x, r0
mad r2.x, r0.y, c2.z, c2.w
mad r3.w, r0.x, c2.z, c2
sincos r0.xy, r2.x
sincos r2.xy, r3.w
mad r2.y, r0.x, c3.x, c3
texldl r0, r3.xyzz, s0
mad r0, r2.y, r0, r1
mad r2.x, r2, c3, c3.y
texldl r1, r4.xyzz, s0
mad r0, r2.x, r1, r0
mul oC0, r0, c3.z

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 (i.e. Final Downscale Pass for CPU) is used to compute a simple downscale for the envmaps AND pack it into a RGBA32 LDR target for CPU readback
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
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D
Vector 1 [_EnvironmentAngles]
Float 2 [_LuminanceScale]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[5] = { program.local[0..2],
		{ 0.5, 0.89999998, 0.1, 0.25 },
		{ 9.9999997e-005 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVR  R0.x, c[3];
MADR  R0.xy, R0.x, -c[0], fragment.texcoord[0];
ADDR  R2.xy, R0, c[0].xzzw;
MADR  R0.z, R2.y, c[1].w, c[1].y;
TEX   R1.xyz, R2, texture[0], 2D;
MADR  R0.w, R0.y, c[1], c[1].y;
COSR  R0.z, R0.z;
MADR  R0.z, R0, c[3].y, c[3];
MULR  R1.xyz, R0.z, R1;
COSR  R0.w, R0.w;
ADDR  R2.xy, R2, c[0].zyzw;
TEX   R0.xyz, R0, texture[0], 2D;
MADR  R0.w, R0, c[3].y, c[3].z;
MADR  R1.xyz, R0.w, R0, R1;
MADR  R0.w, R2.y, c[1], c[1].y;
TEX   R0.xyz, R2, texture[0], 2D;
COSR  R1.w, R0.w;
ADDR  R2.xy, R2, -c[0].xzzw;
MADR  R0.w, R2.y, c[1], c[1].y;
MADR  R1.w, R1, c[3].y, c[3].z;
MADR  R0.xyz, R1.w, R0, R1;
COSR  R0.w, R0.w;
TEX   R1.xyz, R2, texture[0], 2D;
MADR  R0.w, R0, c[3].y, c[3].z;
MADR  R0.xyz, R0.w, R1, R0;
MULR  R0.xyz, R0, c[3].w;
MAXR  R0.w, R0.x, R0.y;
MAXR  R0.w, R0.z, R0;
MAXR  R0.w, R0, c[4].x;
RCPR  R1.x, R0.w;
MULR  oCol.xyz, R0, R1.x;
MULR  oCol.w, R0, c[2].x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D
Vector 1 [_EnvironmentAngles]
Float 2 [_LuminanceScale]

"ps_3_0
dcl_2d s0
def c3, 0.50000000, 0.15915491, 6.28318501, -3.14159298
def c4, 0.89999998, 0.10000000, 0.25000000, 0.00010000
dcl_texcoord0 v0.xyzw
mov r0.xy, c0
mad r0.xy, c3.x, -r0, v0
mov r0.z, v0.w
add r2.xyz, r0, c0.xzzw
mad r0.w, r0.y, c1, c1.y
mad r1.x, r2.y, c1.w, c1.y
mad r0.w, r0, c3.y, c3.x
frc r0.w, r0
mad r0.w, r0, c3.z, c3
sincos r3.xy, r0.w
mad r1.x, r1, c3.y, c3
frc r1.x, r1
mad r0.w, r1.x, c3.z, c3
sincos r1.xy, r0.w
mad r0.w, r3.x, c4.x, c4.y
texldl r0.xyz, r0.xyzz, s0
texldl r3.xyz, r2.xyzz, s0
mad r1.x, r1, c4, c4.y
mul r3.xyz, r1.x, r3
add r1.xyz, r2, c0.zyzw
mad r4.xyz, r0.w, r0, r3
add r2.xyz, r1, -c0.xzzw
mad r0.y, r1, c1.w, c1
mad r0.x, r2.y, c1.w, c1.y
mad r0.y, r0, c3, c3.x
frc r0.y, r0
mad r0.x, r0, c3.y, c3
frc r0.x, r0
mad r1.w, r0.x, c3.z, c3
mad r2.w, r0.y, c3.z, c3
sincos r0.xy, r2.w
mad r0.w, r0.x, c4.x, c4.y
texldl r0.xyz, r1.xyzz, s0
sincos r3.xy, r1.w
mad r0.xyz, r0.w, r0, r4
mad r0.w, r3.x, c4.x, c4.y
texldl r1.xyz, r2.xyzz, s0
mad r0.xyz, r0.w, r1, r0
mul r0.xyz, r0, c4.z
max r0.w, r0.x, r0.y
max r0.w, r0.z, r0
max r0.w, r0, c4
rcp r1.x, r0.w
mul oC0.xyz, r0, r1.x
mul oC0.w, r0, c2.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #6 is used to combine the Sun rendering (extinction component W only) in MODULATE mode with existing value
		Pass
		{
			Blend DstColor Zero		// Multiplicative

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

"!!ARBfp1.0
OPTION NV_fragment_program2;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   oCol, fragment.texcoord[0], texture[0], 2D;
END

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D

"ps_3_0
dcl_2d s0
dcl_texcoord0 v0.xyzw
texldl oC0, v0, s0

"
}

}

		}
	}
	Fallback off
}
