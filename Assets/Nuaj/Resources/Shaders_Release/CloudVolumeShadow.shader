// This shader renders the volume clouds deep shadow maps
//
Shader "Hidden/Nuaj/CloudVolumeShadow"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D0( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D1( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D2( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D3( "Base (RGB)", 2D ) = "white" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSky( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSun( "Base (RGB)", 2D ) = "white" {}
		_TexDeepShadowMapPreviousLayer( "Base (RGB)", 2D ) = "white" {}
	}

	SubShader
	{
		Tags { "Queue" = "Overlay-1" }
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend Off


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 is the initial step that takes into account any previous shadowing from clouds above our own cloud
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
Vector 16 [_PlanetCenterKm]
Float 17 [_PlanetRadiusKm]
Float 18 [_WorldUnit2Kilometer]
Float 19 [_Kilometer2WorldUnit]
Vector 20 [_SunDirection]
Matrix 4 [_NuajShadow2World]
Matrix 8 [_NuajWorld2Shadow]
Vector 21 [_ShadowAltitudesMinKm]
Vector 22 [_ShadowAltitudesMaxKm]
SetTexture 0 [_TexShadowMap] 2D
Vector 23 [_NuajLocalCoverageOffset]
Vector 24 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 12 [_NuajLocalCoverageTransform]
SetTexture 2 [_NuajTexNoise3D0] 2D
Vector 25 [_BufferInvSize]
Float 26 [_CloudAltitudeKm]
Vector 27 [_CloudThicknessKm]
Float 28 [_CloudLayerIndex]
Float 29 [_NoiseTiling]
Float 30 [_Coverage]
Vector 31 [_HorizonBlend]
Vector 32 [_CloudPosition]
Float 33 [_FrequencyFactor]
Vector 34 [_AmplitudeFactor]
Float 35 [_CloudSigma_t]
Float 36 [_IsotropicDensity]
Float 37 [_ShadowStepsCount]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[42] = { program.local[0..37],
		{ 1, 2, 0.5, 3 },
		{ 0, 1, 2.718282, 1000 },
		{ 16, 0.0625, 17, 0.25 },
		{ 0.0036764706 } };
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
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
ADDR  R1.xy, fragment.texcoord[0], -c[38].z;
MOVR  R1.z, c[38].w;
MADR  R1.xy, -|R1|, |c[38].y|, c[38].x;
MULR  R1.z, R1, c[25].x;
MINR  R1.x, R1, R1.y;
SLTRC HC.x, R1, R1.z;
MOVR  oCol, c[38].x;
MOVR  oCol(EQ.x), R0;
SGERC HC.x, R1, R1.z;
IF    NE.x;
MOVR  R0.y, c[26].x;
MOVR  R2.zw, c[39].xyxy;
MOVR  R2.xy, fragment.texcoord[0];
DP4R  R1.z, R2, c[6];
DP4R  R1.x, R2, c[4];
DP4R  R1.y, R2, c[5];
ADDR  R2.xyz, R1, -c[16];
DP3R  R2.w, R2, c[20];
DP3R  R2.x, R2, R2;
ADDR  R0.y, R0, c[17].x;
ADDR  R2.y, R0, c[27].x;
MADR  R2.x, -R2.y, R2.y, R2;
MULR  R0.z, R2.w, R2.w;
SGER  H0.z, R0, R2.x;
ADDR  R2.z, R0, -R2.x;
RSQR  R2.z, R2.z;
RCPR  R2.z, R2.z;
MOVR  R2.y, c[39].x;
SLTRC HC.x, R0.z, R2;
MOVR  R2.y(EQ.x), R0.x;
SLTR  H0.x, -R2.w, -R2.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[39].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R2.y(NE.x), c[39].x;
SLTR  H0.z, -R2.w, R2;
MULXC HC.x, H0.y, H0.z;
ADDR  R2.y(NE.x), -R2.w, R2.z;
MOVX  H0.x(NE), c[39];
MULXC HC.x, H0.y, H0;
ADDR  R2.y(NE.x), -R2.w, -R2.z;
MADR  R3.xyz, R2.y, c[20], R1;
ADDR  R1.xyz, R3, -c[16];
DP3R  R0.z, R1, R1;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
ADDR  R3.w, R0.z, -c[17].x;
MOVR  R0.z, c[38].x;
SGERC HC.x, R3.w, c[22].w;
MOVR  R0.z(EQ.x), R0.w;
SLTRC HC.x, R3.w, c[22].w;
MOVR  R0.w, R0.z;
IF    NE.x;
MOVR  R0.z, c[38].x;
SGERC HC.x, R3.w, c[22].w;
MOVR  R0.z(EQ.x), R1.w;
SLTRC HC.x, R3.w, c[22].w;
MOVR  R2.w, c[38].x;
MOVR  R2.xyz, R3;
MOVR  R1.w, R0.z;
DP4R  R0.w, R2, c[9];
DP4R  R0.z, R2, c[8];
IF    NE.x;
MOVR  R1, c[22];
ADDR  R4, -R1, c[21];
ADDR  R2, R3.w, -c[22];
RCPR  R1.x, R4.y;
MULR_SAT R1.y, R2, R1.x;
MULR  R1.x, R1.y, R1.y;
MADR  R1.y, -R1, c[38], c[38].w;
RCPR  R1.z, R4.x;
MULR_SAT R2.x, R2, R1.z;
MULR  R2.y, R1.x, R1;
TEX   R1, R0.zwzw, texture[0], 2D;
MADR  R0.z, R1.y, R2.y, -R2.y;
MULR  R1.y, R2.x, R2.x;
MADR  R0.w, -R2.x, c[38].y, c[38];
MULR  R0.w, R1.y, R0;
MADR  R0.w, R1.x, R0, -R0;
ADDR  R0.z, R0, c[38].x;
MADR  R0.z, R0.w, R0, R0;
RCPR  R1.x, R4.z;
MULR_SAT R1.x, R1, R2.z;
MADR  R1.y, -R1.x, c[38], c[38].w;
RCPR  R0.w, R4.w;
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1.y;
MULR_SAT R0.w, R0, R2;
MADR  R1.y, -R0.w, c[38], c[38].w;
MULR  R0.w, R0, R0;
MULR  R0.w, R0, R1.y;
MADR  R1.x, R1.z, R1, -R1;
MADR  R0.z, R1.x, R0, R0;
MADR  R0.w, R1, R0, -R0;
MADR  R1.w, R0, R0.z, R0.z;
ENDIF;
MOVR  R0.w, R1;
ENDIF;
ADDR  R1.xyz, R3, -c[16];
DP3R  R0.z, R1, -c[20];
DP3R  R1.y, R1, R1;
MADR  R0.y, -R0, R0, R1;
MULR  R1.x, R0.z, R0.z;
SGER  H0.z, R1.x, R0.y;
MOVR  R1.w, c[39].x;
SLTRC HC.x, R1, R0.y;
MOVR  R1.w(EQ.x), R0.x;
ADDR  R0.x, R1, -R0.y;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
SLTR  H0.x, -R0.z, -R0;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[39].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.w(NE.x), c[39].x;
SLTR  H0.z, -R0, R0.x;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.w(NE.x), -R0.z, R0.x;
MOVX  H0.x(NE), c[39];
MULXC HC.x, H0.y, H0;
ADDR  R1.w(NE.x), -R0.z, -R0.x;
MOVR  R4.w, c[39].x;
SEQR  H0.x, c[28], R4.w;
MULR  R8.xyz, R1.w, c[20];
RCPR  R2.w, c[37].x;
MULR  R0.xyz, -R8, R2.w;
MADR  R1.xyz, R0, c[38].z, R3;
ADDR  R4.xyz, R1, R0;
ADDR  R2.xyz, R0, R4;
ADDR  R0.xyz, R0, R2;
MULR  R5.xyz, R0.xzyw, c[29].x;
ADDR  R0.xyz, R0, -c[16];
DP3R  R0.x, R0, R0;
MADR  R8.xyz, -R8, c[38].z, R3;
MULR  R1.w, R1, R2;
RSQR  R0.x, R0.x;
ADDR  R6.xy, R5, c[32];
MOVR  R6.z, R5;
MULR  R5.xyz, R6, c[33].x;
ADDR  R6.zw, R6.xyxz, c[39].w;
ADDR  R6.x, c[31].y, -c[31];
ADDR  R7.xy, R5, c[32].zwzw;
MOVR  R7.z, R5;
MULR  R5.xyz, R7, c[33].x;
ADDR  R10.xy, R5, c[32].zwzw;
MOVR  R10.z, R5;
MULR  R5.xyz, R10, c[33].x;
ADDR  R9.zw, R5.xyxy, c[32];
MULR  R8.xyz, R8, c[19].x;
MULR  R1.w, R1, c[39];
ADDR  R7.zw, R7.xyxz, c[39].w;
MOVR  R8.w, c[38].x;
MOVR  R5.y, R5.z;
MOVR  R5.x, R9.z;
ADDR  R5.xy, R5, c[39].w;
MULR  R5.zw, R5.xyxy, c[40].x;
MULR  R5.xy, R5.zwzw, c[40].y;
FRCR  R5.xy, |R5|;
MULR  R9.xy, R5, c[40].x;
MOVR  R5.xy, R9;
MOVXC RC.xy, R5.zwzw;
MOVR  R5.xy(LT), -R9;
MULR  R9.xyz, R2.xzyw, c[29].x;
ADDR  R2.xyz, R2, -c[16];
DP3R  R2.x, R2, R2;
ADDR  R9.xy, R9, c[32];
MULR  R11.xyz, R9, c[33].x;
ADDR  R11.xy, R11, c[32].zwzw;
MULR  R12.xyz, R11, c[33].x;
ADDR  R11.zw, R11.xyxz, c[39].w;
RSQR  R2.x, R2.x;
MOVR  R18.z, R12;
ADDR  R18.xy, R12, c[32].zwzw;
MULR  R12.xyz, R18, c[33].x;
ADDR  R17.zw, R12.xyxy, c[32];
MULR  R11.zw, R11, c[40].x;
MOVR  R5.w, R12.z;
MOVR  R5.z, R17;
ADDR  R5.zw, R5, c[39].w;
MULR  R5.zw, R5, c[40].x;
MULR  R12.xy, R5.zwzw, c[40].y;
FRCR  R12.xy, |R12|;
MULR  R12.xy, R12, c[40].x;
MOVR  R14.xy, R12;
MOVXC RC.xy, R5.zwzw;
MOVR  R14.xy(LT), -R12;
MULR  R12.xyz, R4.xzyw, c[29].x;
ADDR  R4.xyz, R4, -c[16];
DP3R  R4.x, R4, R4;
RSQR  R4.x, R4.x;
RCPR  R4.y, R4.x;
MOVR  R4.x, c[26];
ADDR  R4.x, R4, c[17];
ADDR  R4.y, -R4.x, R4;
MULR  R4.y, R4, c[27];
MADR  R4.y, R4, c[38], -c[38].x;
MULR  R4.y, |R4|, |R4|;
MULR  R4.z, R4.y, R4.y;
MULR  R4.y, R4.z, R4.z;
RCPR  R2.x, R2.x;
ADDR  R2.x, -R4, R2;
MULR  R2.x, R2, c[27].y;
MADR  R2.x, R2, c[38].y, -c[38];
MULR  R2.x, |R2|, |R2|;
MULR  R2.y, R2.x, R2.x;
MULR  R2.x, R2.y, R2.y;
RCPR  R0.x, R0.x;
ADDR  R0.x, -R4, R0;
MULR  R0.x, R0, c[27].y;
MADR  R0.x, R0, c[38].y, -c[38];
MULR  R0.x, |R0|, |R0|;
MULR  R0.y, R0.x, R0.x;
MULR  R0.x, R0.y, R0.y;
ADDR  R13.xy, R12, c[32];
MOVR  R13.z, R12;
MULR  R12.xyz, R13, c[33].x;
ADDR  R13.zw, R13.xyxz, c[39].w;
MOVR  R16.z, R12;
ADDR  R16.xy, R12, c[32].zwzw;
MULR  R12.xyz, R16, c[33].x;
ADDR  R15.xw, R12.xyzy, c[32].zyzw;
MOVR  R15.y, R12.z;
MULR  R12.xyz, R15.xwyw, c[33].x;
ADDR  R20.zw, R12.xyxy, c[32];
MULR  R13.zw, R13, c[40].x;
MULR  R4.y, R4, R4.z;
MULR  R2.x, R2, R2.y;
MULR  R0.x, R0, R0.y;
MOVR  R5.w, R12.z;
MOVR  R5.z, R20;
ADDR  R5.zw, R5, c[39].w;
MULR  R5.zw, R5, c[40].x;
MULR  R12.xy, R5.zwzw, c[40].y;
MOVXC RC.xy, R5.zwzw;
ADDR  R5.zw, R10.xyxz, c[39].w;
MULR  R10.zw, R5, c[40].x;
MULR  R5.zw, R10, c[40].y;
FRCR  R12.xy, |R12|;
MULR  R12.xy, R12, c[40].x;
MOVR  R19.xy, R12;
MOVR  R19.xy(LT), -R12;
MOVXC RC.xy, R10.zwzw;
FRCR  R5.zw, |R5|;
MULR  R12.xy, R5.zwzw, c[40].x;
MOVR  R5.zw, R12.xyxy;
ADDR  R10.zw, R18.xyxz, c[39].w;
MOVR  R5.zw(LT.xyxy), -R12.xyxy;
MULR  R10.zw, R10, c[40].x;
MULR  R12.xy, R10.zwzw, c[40].y;
MOVXC RC.xy, R10.zwzw;
ADDR  R10.zw, R15.xyxy, c[39].w;
FRCR  R12.xy, |R12|;
MULR  R12.xy, R12, c[40].x;
MOVR  R14.zw, R12.xyxy;
MULR  R10.zw, R10, c[40].x;
MOVR  R14.zw(LT.xyxy), -R12.xyxy;
MULR  R12.xy, R10.zwzw, c[40].y;
FRCR  R12.xy, |R12|;
MULR  R12.xy, R12, c[40].x;
MOVR  R19.zw, R12.xyxy;
MOVXC RC.xy, R10.zwzw;
MOVR  R19.zw(LT.xyxy), -R12.xyxy;
MULR  R12.xyz, R1.xzyw, c[29].x;
ADDR  R1.xyz, R1, -c[16];
DP3R  R1.x, R1, R1;
ADDR  R12.xy, R12, c[32];
MULR  R15.xyz, R12, c[33].x;
ADDR  R15.xy, R15, c[32].zwzw;
MULR  R17.xyz, R15, c[33].x;
ADDR  R17.xy, R17, c[32].zwzw;
MULR  R20.xyz, R17, c[33].x;
ADDR  R10.xz, R20.yyxw, c[32].wyzw;
MOVR  R10.w, R20.z;
ADDR  R10.zw, R10, c[39].w;
MULR  R18.zw, R10, c[40].x;
MULR  R10.zw, R18, c[40].y;
MOVXC RC.xy, R18.zwzw;
MULR  R18.zw, R7, c[40].x;
FRCR  R10.zw, |R10|;
MULR  R20.xy, R10.zwzw, c[40].x;
MOVR  R10.zw, R20.xyxy;
MOVR  R10.zw(LT.xyxy), -R20.xyxy;
MULR  R7.zw, R18, c[40].y;
MOVXC RC.xy, R18.zwzw;
FRCR  R7.zw, |R7|;
MULR  R20.xy, R7.zwzw, c[40].x;
MOVR  R7.zw, R20.xyxy;
MOVR  R7.zw(LT.xyxy), -R20.xyxy;
MULR  R18.zw, R11, c[40].y;
MOVXC RC.xy, R11.zwzw;
FRCR  R18.zw, |R18|;
MULR  R20.xy, R18.zwzw, c[40].x;
MOVR  R18.zw, R20.xyxy;
ADDR  R11.zw, R16.xyxz, c[39].w;
MULR  R11.zw, R11, c[40].x;
MOVR  R18.zw(LT.xyxy), -R20.xyxy;
MULR  R16.zw, R11, c[40].y;
MOVXC RC.xy, R11.zwzw;
FRCR  R16.zw, |R16|;
MULR  R16.zw, R16, c[40].x;
MOVR  R20.xy, R16.zwzw;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R1.x, R1, -R4;
MULR  R1.x, R1, c[27].y;
MADR  R1.x, R1, c[38].y, -c[38];
MULR  R1.x, |R1|, |R1|;
MULR  R1.y, R1.x, R1.x;
MULR  R1.x, R1.y, R1.y;
MOVR  R20.xy(LT), -R16.zwzw;
ADDR  R11.zw, R17.xyxz, c[39].w;
MULR  R16.zw, R11, c[40].x;
MULR  R11.zw, R16, c[40].y;
MOVXC RC.xy, R16.zwzw;
MULR  R16.zw, R6, c[40].x;
FRCR  R11.zw, |R11|;
MULR  R21.xy, R11.zwzw, c[40].x;
MOVR  R11.zw, R21.xyxy;
MOVR  R11.zw(LT.xyxy), -R21.xyxy;
MULR  R6.zw, R16, c[40].y;
MOVXC RC.xy, R16.zwzw;
FRCR  R6.zw, |R6|;
MULR  R21.xy, R6.zwzw, c[40].x;
MOVR  R6.zw, R21.xyxy;
MOVR  R6.zw(LT.xyxy), -R21.xyxy;
ADDR  R16.zw, R9.xyxz, c[39].w;
MULR  R21.xy, R16.zwzw, c[40].x;
MULR  R16.zw, R21.xyxy, c[40].y;
MOVXC RC.xy, R21;
FRCR  R16.zw, |R16|;
MULR  R21.zw, R16, c[40].x;
MOVR  R16.zw, R21;
MOVR  R16.zw(LT.xyxy), -R21;
MULR  R21.xy, R13.zwzw, c[40].y;
MOVXC RC.xy, R13.zwzw;
FRCR  R21.xy, |R21|;
MULR  R21.xy, R21, c[40].x;
MOVR  R9.xz, R21.xyyw;
MOVR  R9.xz(LT.xyyw), -R21.xyyw;
ADDR  R13.zw, R15.xyxz, c[39].w;
MULR  R21.xy, R13.zwzw, c[40].x;
MULR  R13.zw, R21.xyxy, c[40].y;
FRCR  R13.zw, |R13|;
MULR  R21.zw, R13, c[40].x;
MOVR  R13.zw, R21;
MOVXC RC.xy, R21;
ADDR  R12.zw, R12.xyxz, c[39].w;
MULR  R21.xy, R12.zwzw, c[40].x;
MOVR  R13.zw(LT.xyxy), -R21;
MULR  R12.zw, R21.xyxy, c[40].y;
MOVXC RC.xy, R21;
FRCR  R12.zw, |R12|;
MULR  R21.zw, R12, c[40].x;
MOVR  R12.zw, R21;
MOVR  R12.zw(LT.xyxy), -R21;
DP4R  R21.x, R8, c[12];
DP4R  R21.y, R8, c[14];
MADR  R8.xy, R21, c[38].z, c[38].z;
MULR  R1.x, R1, R1.y;
MOVR  R21, c[23];
TEX   R8, R8, texture[1], 2D;
MADR  R8, R8, c[24], R21;
MOVR  R21.xyz, c[38].xyww;
MOVR  R3.w, R8.x;
SEQR  H0.zw, c[28].x, R21.xyxy;
SEQX  H0.x, H0, c[39];
MULXC HC.x, H0, H0.z;
MOVR  R3.w(NE.x), R8.y;
SEQX  H0.yz, H0.xzww, c[39].x;
MULX  H0.x, H0, H0.y;
MULXC HC.x, H0, H0.w;
MOVR  R3.w(NE.x), R8.z;
MULXC HC.x, H0, H0.z;
MOVR  R3.w(NE.x), R8;
MOVR  R8.x, c[0].w;
MOVR  R8.z, c[2].w;
MOVR  R8.y, c[1].w;
MADR  R3.xyz, -R8, c[18].x, R3;
DP3R  R3.x, R3, R3;
RSQR  R3.x, R3.x;
RCPR  R3.x, R3.x;
ADDR  R3.z, R3.x, -c[31].x;
ADDR  R3.xy, fragment.texcoord[0], -c[38].z;
MADR  R3.xy, -|R3|, |c[38].y|, c[38].x;
MINR  R3.y, R3.x, R3;
MULR  R4.w, R21.z, c[25].x;
SLTRC HC.x, R3.y, R4.w;
MOVR  R3.x, c[38];
RCPR  R6.x, R6.x;
MULR_SAT R3.x(EQ), R3.z, R6;
FLRR  R3.y, R19;
MADR  R3.z, R3.y, c[40], R19.x;
ADDR  R3.z, R3, c[40].w;
MULR  R8.x, R3.z, c[41];
MOVR  R8.y, R20.w;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R3.z, R8.y, -R8.x;
ADDR  R3.y, R19, -R3;
MADR  R4.w, R3.y, R3.z, R8.x;
FLRR  R3.y, R19.w;
MADR  R3.z, R3.y, c[40], R19;
ADDR  R3.z, R3, c[40].w;
MULR  R8.x, R3.z, c[41];
MOVR  R8.y, R15.w;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R3.z, R8.y, -R8.x;
ADDR  R3.y, R19.w, -R3;
MADR  R3.z, R3.y, R3, R8.x;
FLRR  R3.y, R20;
MADR  R6.x, R3.y, c[40].z, R20;
ADDR  R6.x, R6, c[40].w;
MULR  R8.x, R6, c[41];
MOVR  R8.y, R16;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R6.x, R8.y, -R8;
ADDR  R3.y, R20, -R3;
MADR  R3.y, R3, R6.x, R8.x;
FLRR  R6.x, R9.z;
MADR  R7.x, R6, c[40].z, R9;
ADDR  R7.x, R7, c[40].w;
MULR  R8.x, R7, c[41];
MOVR  R8.y, R13;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R7.x, R8.y, -R8;
ADDR  R6.x, R9.z, -R6;
MADR  R6.x, R6, R7, R8;
MADR  R6.x, R3.y, c[34], R6;
MULR  R3.y, c[34].x, c[34].x;
MADR  R6.x, R3.y, R3.z, R6;
MULR  R3.z, R3.y, c[34].x;
MADR  R4.w, R3.z, R4, R6.x;
MULR  R4.w, R4, c[34].y;
MADR  R4.y, -R4, R4.w, R4.w;
ADDR  R4.y, R4, c[30].x;
MULR_SAT R4.w, R3, R4.y;
ADDR_SAT R4.y, -R3.w, c[31].z;
ADDR  R4.z, R4.y, -R4.w;
MADR  R4.z, R3.x, R4, R4.w;
FLRR  R4.w, R14.y;
MADR  R6.x, R4.w, c[40].z, R14;
ADDR  R6.x, R6, c[40].w;
MULR  R8.x, R6, c[41];
MOVR  R8.y, R17.w;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R6.x, R8.y, -R8;
ADDR  R4.w, R14.y, -R4;
MADR  R4.w, R4, R6.x, R8.x;
FLRR  R6.x, R14.w;
MADR  R7.x, R6, c[40].z, R14.z;
ADDR  R7.x, R7, c[40].w;
MULR  R8.x, R7, c[41];
MOVR  R8.y, R18;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R7.x, R8.y, -R8;
ADDR  R6.x, R14.w, -R6;
MADR  R6.x, R6, R7, R8;
FLRR  R7.x, R18.w;
MADR  R8.x, R7, c[40].z, R18.z;
ADDR  R8.x, R8, c[40].w;
FLRR  R8.z, R16.w;
MOVR  R2.w, R10.x;
MULR  R8.x, R8, c[41];
MOVR  R8.y, R11;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R8.y, R8, -R8.x;
ADDR  R7.x, R18.w, -R7;
MADR  R7.x, R7, R8.y, R8;
MADR  R8.x, R8.z, c[40].z, R16.z;
ADDR  R8.x, R8, c[40].w;
MULR  R8.x, R8, c[41];
MOVR  R8.y, R9;
TEX   R8.xy, R8, texture[2], 2D;
ADDR  R8.y, R8, -R8.x;
ADDR  R8.z, R16.w, -R8;
MADR  R8.x, R8.z, R8.y, R8;
MADR  R7.x, R7, c[34], R8;
MADR  R6.x, R3.y, R6, R7;
MADR  R4.w, R3.z, R4, R6.x;
MULR  R4.w, R4, c[34].y;
MADR  R2.x, -R2, R4.w, R4.w;
ADDR  R2.x, R2, c[30];
MULR_SAT R2.y, R3.w, R2.x;
ADDR  R2.x, R4.y, -R2.y;
MADR  R2.y, R3.x, R2.x, R2;
MULR  R2.x, R4.z, -c[35];
MULR  R2.y, R2, -c[35].x;
MULR  R2.z, R1.w, R2.x;
MULR  R2.y, R1.w, R2;
POWR  R2.x, c[39].z, R2.y;
POWR  R2.y, c[39].z, R2.z;
FLRR  R4.z, R10.w;
MADR  R2.z, R4, c[40], R10;
ADDR  R2.z, R2, c[40].w;
MULR  R2.z, R2, c[41].x;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.w, R10, -R4.z;
MADR  R4.z, R2.w, R2, R8.x;
FLRR  R4.w, R11;
MADR  R2.z, R4.w, c[40], R11;
ADDR  R2.z, R2, c[40].w;
FLRR  R6.x, R13.w;
MULR  R2.z, R2, c[41].x;
MOVR  R2.w, R17.y;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.w, R11, -R4;
MADR  R4.w, R2, R2.z, R8.x;
MADR  R2.z, R6.x, c[40], R13;
ADDR  R2.z, R2, c[40].w;
MULR  R2.z, R2, c[41].x;
MOVR  R2.w, R15.y;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.w, R13, -R6.x;
MADR  R6.x, R2.w, R2.z, R8;
FLRR  R7.x, R12.w;
MADR  R2.z, R7.x, c[40], R12;
ADDR  R2.z, R2, c[40].w;
MULR  R2.z, R2, c[41].x;
MOVR  R2.w, R12.y;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.w, R12, -R7.x;
ADDR  R2.z, R8.y, -R8.x;
MADR  R2.z, R2.w, R2, R8.x;
MADR  R2.z, R6.x, c[34].x, R2;
MADR  R2.z, R3.y, R4.w, R2;
MADR  R2.z, R3, R4, R2;
MULR  R2.z, R2, c[34].y;
MADR  R1.x, -R1, R2.z, R2.z;
ADDR  R1.x, R1, c[30];
MULR_SAT R1.y, R3.w, R1.x;
ADDR  R1.x, R4.y, -R1.y;
MADR  R1.x, R3, R1, R1.y;
MULR  R1.x, R1, -c[35];
MULR  R1.x, R1, R1.w;
POWR  R1.x, c[39].z, R1.x;
MULR  R1.x, R1, R0.w;
MULR  R0.w, R1.x, R2.y;
MULR  R1.y, R0.w, R2.x;
FLRR  R2.z, R5.y;
MADR  R2.x, R2.z, c[40].z, R5;
ADDR  R2.x, R2, c[40].w;
ADDR  R2.z, R5.y, -R2;
FLRR  R4.z, R7.w;
MOVR  R1.z, R1.y;
MOVR  R2.w, R10.y;
FLRR  R4.w, R6;
MULR  R2.x, R2, c[41];
MOVR  R2.y, R9.w;
TEX   R2.xy, R2, texture[2], 2D;
ADDR  R2.y, R2, -R2.x;
MADR  R2.x, R2.z, R2.y, R2;
FLRR  R2.y, R5.w;
MADR  R2.z, R2.y, c[40], R5;
ADDR  R2.z, R2, c[40].w;
MULR  R2.z, R2, c[41].x;
TEX   R5.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R5.y, -R5.x;
ADDR  R2.y, R5.w, -R2;
MADR  R2.y, R2, R2.z, R5.x;
MADR  R2.z, R4, c[40], R7;
ADDR  R2.z, R2, c[40].w;
MULR  R2.z, R2, c[41].x;
MOVR  R2.w, R7.y;
TEX   R5.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R5.y, -R5.x;
ADDR  R2.w, R7, -R4.z;
MADR  R4.z, R2.w, R2, R5.x;
MADR  R2.z, R4.w, c[40], R6;
ADDR  R2.z, R2, c[40].w;
MULR  R2.z, R2, c[41].x;
MOVR  R2.w, R6.y;
TEX   R5.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R5.y, -R5.x;
ADDR  R2.w, R6, -R4;
MADR  R2.z, R2.w, R2, R5.x;
MADR  R2.z, R4, c[34].x, R2;
MADR  R2.y, R3, R2, R2.z;
MADR  R2.x, R3.z, R2, R2.y;
MULR  R2.x, R2, c[34].y;
MADR  R0.x, -R0, R2, R2;
ADDR  R0.x, R0, c[30];
MULR_SAT R0.x, R3.w, R0;
ADDR  R0.y, R4, -R0.x;
MADR  R0.x, R3, R0.y, R0;
MULR  R0.x, R0, -c[35];
MULR  R0.x, R1.w, R0;
POWR  R0.x, c[39].z, R0.x;
MULR  R1.w, R1.y, R0.x;
MOVR  R1.y, R0.w;
MOVR  oCol, R1;
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 16 [_PlanetCenterKm]
Float 17 [_PlanetRadiusKm]
Float 18 [_WorldUnit2Kilometer]
Float 19 [_Kilometer2WorldUnit]
Vector 20 [_SunDirection]
Matrix 4 [_NuajShadow2World]
Matrix 8 [_NuajWorld2Shadow]
Vector 21 [_ShadowAltitudesMinKm]
Vector 22 [_ShadowAltitudesMaxKm]
SetTexture 0 [_TexShadowMap] 2D
Vector 23 [_NuajLocalCoverageOffset]
Vector 24 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 12 [_NuajLocalCoverageTransform]
SetTexture 2 [_NuajTexNoise3D0] 2D
Vector 25 [_BufferInvSize]
Float 26 [_CloudAltitudeKm]
Vector 27 [_CloudThicknessKm]
Float 28 [_CloudLayerIndex]
Float 29 [_NoiseTiling]
Float 30 [_Coverage]
Vector 31 [_HorizonBlend]
Vector 32 [_CloudPosition]
Float 33 [_FrequencyFactor]
Vector 34 [_AmplitudeFactor]
Float 35 [_CloudSigma_t]
Float 36 [_ShadowStepsCount]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c37, -0.50000000, 2.00000000, 1.00000000, 0.00000000
def c38, 3.00000000, 2.00000000, -1.00000000, 2.71828198
def c39, -2.00000000, 0.50000000, 1000.00000000, 16.00000000
def c40, 0.06250000, 17.00000000, 0.25000000, 0.00367647
dcl_texcoord0 v0.xy
add r1.xy, v0, c37.x
mul r1.xy, r1, c37.y
abs r1.xy, r1
add r1.xy, -r1, c37.z
min r1.x, r1, r1.y
mov r1.y, c25.x
mad r1.x, c38, -r1.y, r1
cmp_pp r1.y, r1.x, c37.z, c37.w
cmp oC0, r1.x, r0, c37.z
if_gt r1.y, c37.w
mov r0.y, c17.x
add r2.y, c26.x, r0
mov r3.zw, c37.xywz
mov r3.xy, v0
dp4 r1.z, r3, c6
dp4 r1.y, r3, c5
dp4 r1.x, r3, c4
add r3.xyz, r1, -c16
dp3 r0.z, r3, r3
add r0.y, r2, c27.x
mad r0.z, -r0.y, r0.y, r0
dp3 r0.y, r3, c20
mad r0.z, r0.y, r0.y, -r0
rsq r0.w, r0.z
rcp r2.z, r0.w
add r2.w, -r0.y, r2.z
cmp_pp r0.w, r0.z, c37.z, c37
cmp r3.x, r2.w, c37.w, c37.z
mul_pp r3.x, r0.w, r3
cmp_pp r3.y, -r3.x, r0.w, c37.w
add r2.z, -r0.y, -r2
mul_pp r0.y, r0.w, r3
cmp r3.z, r0, r0.x, c37.w
cmp r0.w, r2.z, c37, c37.z
mul_pp r0.z, r0.y, r0.w
cmp_pp r0.w, -r0.z, r3.y, c37
cmp r3.x, -r3, r3.z, c37.w
cmp r0.z, -r0, r3.x, r2.w
mul_pp r0.y, r0, r0.w
cmp r0.y, -r0, r0.z, r2.z
mad r1.xyz, r0.y, c20, r1
add r3.xyz, r1, -c16
dp3 r0.y, r3, r3
rsq r0.y, r0.y
rcp r0.y, r0.y
add r2.z, r0.y, -c17.x
add r0.y, r2.z, -c22.w
cmp_pp r0.z, r0.y, c37.w, c37
cmp r1.w, r0.y, c37.z, r1
if_gt r0.z, c37.w
add r0.y, r2.z, -c22.w
mov r3.w, c37.z
mov r3.xyz, r1
cmp_pp r1.w, r0.y, c37, c37.z
cmp r0.x, r0.y, c37.z, r0
dp4 r0.w, r3, c9
dp4 r0.z, r3, c8
if_gt r1.w, c37.w
mov r0.xy, r0.zwzw
mov r0.w, c21.x
add r1.w, -c22.x, r0
rcp r2.w, r1.w
mov r0.z, c37.w
texldl r0, r0.xyzz, s0
add r3.x, r0, c38.z
add r1.w, r2.z, -c22.x
mul_sat r1.w, r1, r2
mul r2.w, r1, r1
mad r1.w, -r1, c38.y, c38.x
mul r1.w, r2, r1
mov r0.x, c21.y
add r0.x, -c22.y, r0
rcp r2.w, r0.x
add r0.x, r2.z, -c22.y
mul_sat r0.x, r0, r2.w
add r2.w, r0.y, c38.z
mad r0.y, -r0.x, c38, c38.x
mul r0.x, r0, r0
mul r0.y, r0.x, r0
mad r0.y, r0, r2.w, c37.z
mad r1.w, r1, r3.x, c37.z
mov r0.x, c21.z
add r0.x, -c22.z, r0
mul r0.y, r1.w, r0
rcp r1.w, r0.x
add r0.x, r2.z, -c22.z
mul_sat r0.x, r0, r1.w
add r2.w, r0.z, c38.z
mad r1.w, -r0.x, c38.y, c38.x
mul r0.z, r0.x, r0.x
mul r0.z, r0, r1.w
mov r0.x, c21.w
add r1.w, -c22, r0.x
mad r0.x, r0.z, r2.w, c37.z
rcp r1.w, r1.w
add r0.z, r2, -c22.w
mul_sat r0.z, r0, r1.w
add r1.w, r0, c38.z
mad r0.w, -r0.z, c38.y, c38.x
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.w, c37
mul r0.x, r0.y, r0
mul r0.x, r0, r0.z
endif
mov r1.w, r0.x
endif
add r0.xyz, r1, -c16
dp3 r0.w, r0, r0
dp3 r0.x, r0, -c20
mad r0.w, -r2.y, r2.y, r0
mad r0.y, r0.x, r0.x, -r0.w
rsq r0.z, r0.y
rcp r0.w, r0.z
add r2.y, -r0.x, r0.w
cmp_pp r0.z, r0.y, c37, c37.w
cmp r2.z, r2.y, c37.w, c37
mul_pp r2.z, r0, r2
cmp r2.x, r0.y, r2, c37.w
cmp_pp r2.w, -r2.z, r0.z, c37
add r0.w, -r0.x, -r0
mul_pp r0.x, r0.z, r2.w
cmp r0.z, r0.w, c37.w, c37
mul_pp r0.y, r0.x, r0.z
cmp_pp r0.z, -r0.y, r2.w, c37.w
cmp r2.x, -r2.z, r2, c37.w
cmp r0.y, -r0, r2.x, r2
mul_pp r0.x, r0, r0.z
cmp r2.w, -r0.x, r0.y, r0
rcp r3.w, c36.x
mul r0.xyz, r2.w, c20
mul r2.xyz, -r0, r3.w
mad r5.xyz, r2, c39.y, r1
add r6.xyz, r5, r2
add r7.xyz, r2, r6
add r8.xyz, r2, r7
mul r2.xyz, r8.xzyw, c29.x
mad r0.xyz, -r0, c39.y, r1
add r4.xy, r2, c32
mov r4.z, r2
mul r2.xyz, r4, c33.x
add r3.xy, r2, c32.zwzw
mov r3.z, r2
mul r2.xyz, r3, c33.x
add r2.xy, r2, c32.zwzw
mul r9.xyz, r2, c33.x
add r10.zw, r2.xyxz, c39.z
mul r10.zw, r10, c39.w
mul r0.xyz, r0, c19.x
add r9.xy, r9, c32.zwzw
mov r9.w, r9.z
mov r9.z, r9.x
add r9.zw, r9, c39.z
mul r9.zw, r9, c39.w
mul r10.xy, r9.zwzw, c40.x
abs r10.xy, r10
frc r10.xy, r10
mul r10.xy, r10, c39.w
cmp r9.zw, r9, r10.xyxy, -r10.xyxy
mul r2.xz, r10.zyww, c40.x
abs r10.xy, r2.xzzw
frc r0.w, r9
add r2.x, -r0.w, r9.w
mad r2.x, r2, c40.y, r9.z
add r2.x, r2, c40.z
frc r10.xy, r10
mul r10.xy, r10, c39.w
cmp r10.xy, r10.zwzw, r10, -r10
frc r4.w, r10.y
mul r9.x, r2, c40.w
add r2.x, -r4.w, r10.y
mad r2.z, r2.x, c40.y, r10.x
mov r9.z, c37.w
texldl r9.xy, r9.xyzz, s2
add r2.x, r9.y, -r9
mad r0.w, r0, r2.x, r9.x
add r9.xy, r3.xzzw, c39.z
mul r9.xy, r9, c39.w
add r2.z, r2, c40
mul r2.x, r2.z, c40.w
mov r2.z, c37.w
texldl r2.xy, r2.xyzz, s2
add r2.y, r2, -r2.x
mad r5.w, r4, r2.y, r2.x
mul r9.zw, r9.xyxy, c40.x
abs r2.xy, r9.zwzw
add r4.zw, r4.xyxz, c39.z
mul r4.zw, r4, c39.w
frc r2.xy, r2
mul r2.xy, r2, c39.w
cmp r2.xy, r9, r2, -r2
mul r9.zw, r4, c40.x
frc r3.x, r2.y
abs r9.xy, r9.zwzw
add r2.y, -r3.x, r2
mad r2.x, r2.y, c40.y, r2
frc r9.xy, r9
mul r9.xy, r9, c39.w
cmp r4.zw, r4, r9.xyxy, -r9.xyxy
frc r4.x, r4.w
add r3.z, -r4.x, r4.w
add r2.x, r2, c40.z
mul r4.w, c34.x, c34.x
mov r2.z, c37.w
mov r2.y, r3
mul r2.x, r2, c40.w
texldl r2.xy, r2.xyzz, s2
mad r2.z, r3, c40.y, r4
add r2.y, r2, -r2.x
mad r4.z, r3.x, r2.y, r2.x
add r3.xyz, r8, -c16
dp3 r3.x, r3, r3
add r2.z, r2, c40
mul r2.x, r2.z, c40.w
rsq r3.x, r3.x
mov r2.z, c37.w
mov r2.y, r4
texldl r2.xy, r2.xyzz, s2
add r2.z, r2.y, -r2.x
mad r2.x, r4, r2.z, r2
mov r2.y, c17.x
mad r2.x, r4.z, c34, r2
mad r2.x, r4.w, r5.w, r2
mul r5.w, r4, c34.x
mad r0.w, r5, r0, r2.x
add r6.w, c26.x, r2.y
rcp r3.x, r3.x
add r2.y, -r6.w, r3.x
mul r2.y, r2, c27
mad r2.y, r2, c38, c38.z
abs r2.y, r2
mul r2.x, r2.y, r2.y
mul r4.x, r2, r2
mul r2.xyz, r7.xzyw, c29.x
add r2.xy, r2, c32
mul r3.xyz, r2, c33.x
mul r4.y, r4.x, r4.x
mad r7.w, -r4.y, r4.x, c37.z
mul r0.w, r0, c34.y
mad r8.w, r0, r7, c30.x
mov r0.w, c37.z
mov r7.w, c28.x
add r4.xy, r3, c32.zwzw
mov r4.z, r3
mul r3.xyz, r4, c33.x
add r3.xy, r3, c32.zwzw
dp4 r8.x, r0, c12
dp4 r8.y, r0, c14
add r0.xy, r8, c37.z
mul r8.xyz, r3, c33.x
add r9.y, c38.z, r7.w
abs r9.x, c28
cmp r7.w, -r9.x, c37.z, c37
abs r9.x, r9.y
abs_pp r7.w, r7
mov r9.y, c28.x
cmp r9.x, -r9, c37.z, c37.w
cmp_pp r7.w, -r7, c37.z, c37
mul_pp r9.z, r7.w, r9.x
add r9.y, c39.x, r9
mov r0.z, c37.w
mul r0.xy, r0, c39.y
texldl r0, r0.xyzz, s1
mul r0, r0, c24
add r0, r0, c23
cmp r0.x, -r9.z, r0, r0.y
abs_pp r0.y, r9.x
abs r9.x, r9.y
cmp_pp r0.y, -r0, c37.z, c37.w
mul_pp r0.y, r7.w, r0
cmp r9.x, -r9, c37.z, c37.w
abs_pp r7.w, r9.x
mul_pp r9.x, r0.y, r9
cmp r0.z, -r9.x, r0.x, r0
add r9.xy, r8, c32.zwzw
cmp_pp r7.w, -r7, c37.z, c37
mul_pp r0.x, r0.y, r7.w
cmp r7.w, -r0.x, r0.z, r0
mul_sat r9.z, r7.w, r8.w
add_sat r8.w, -r7, c31.z
mov r8.x, r9
add r9.w, r8, -r9.z
mov r8.y, r8.z
mov r0.x, c0.w
mov r0.z, c2.w
mov r0.y, c1.w
mad r0.xyz, -r0, c18.x, r1
add r1.xy, r8, c39.z
dp3 r0.z, r0, r0
mul r0.xy, r1, c39.w
rsq r1.x, r0.z
mul r0.zw, r0.xyxy, c40.x
rcp r1.x, r1.x
add r1.z, r1.x, -c31.x
abs r0.zw, r0
add r8.x, c31.y, -c31
rcp r8.x, r8.x
mul_sat r1.z, r1, r8.x
add r1.xy, v0, c37.x
mul r1.xy, r1, c37.y
abs r1.xy, r1
add r1.xy, -r1, c37.z
mov r8.x, c25
frc r0.zw, r0
min r1.x, r1, r1.y
mul r8.x, c38, r8
add_pp r1.x, r1, -r8
cmp r8.x, r1, r1.z, c37.z
mul r1.z, r2.w, r3.w
mad r1.x, r8, r9.w, r9.z
mul r3.w, r1.z, c39.z
mul r8.y, r1.x, -c35.x
mul r0.zw, r0, c39.w
cmp r1.xy, r0, r0.zwzw, -r0.zwzw
mul r1.z, r3.w, r8.y
pow r0, c38.w, r1.z
frc r2.w, r1.y
add r0.y, -r2.w, r1
add r0.zw, r3.xyxz, c39.z
mad r0.y, r0, c40, r1.x
mul r0.zw, r0, c39.w
add r0.y, r0, c40.z
mul r9.zw, r0, c40.x
mul r1.x, r0.y, c40.w
abs r9.zw, r9
mov r1.y, r9
mov r1.z, c37.w
texldl r1.xy, r1.xyzz, s2
frc r9.xy, r9.zwzw
add r0.y, r1, -r1.x
mad r0.y, r2.w, r0, r1.x
mul r9.xy, r9, c39.w
cmp r1.xy, r0.zwzw, r9, -r9
frc r2.w, r1.y
add r0.zw, r4.xyxz, c39.z
add r1.y, -r2.w, r1
mul r0.zw, r0, c39.w
mad r1.z, r1.y, c40.y, r1.x
mul r9.xy, r0.zwzw, c40.x
abs r1.xy, r9
frc r9.xy, r1
add r1.z, r1, c40
mul r1.x, r1.z, c40.w
mul r9.xy, r9, c39.w
cmp r0.zw, r0, r9.xyxy, -r9.xyxy
mov r1.y, r3
frc r3.y, r0.w
mov r1.z, c37.w
texldl r1.xy, r1.xyzz, s2
add r0.w, -r3.y, r0
add r1.y, r1, -r1.x
mad r3.x, r2.w, r1.y, r1
add r1.xy, r2.xzzw, c39.z
mad r1.z, r0.w, c40.y, r0
mul r0.zw, r1.xyxy, c39.w
add r1.x, r1.z, c40.z
mul r2.zw, r0, c40.x
abs r2.zw, r2
frc r2.zw, r2
mul r2.zw, r2, c39.w
cmp r0.zw, r0, r2, -r2
frc r2.z, r0.w
add r0.w, -r2.z, r0
mad r0.z, r0.w, c40.y, r0
mov r1.z, c37.w
mov r1.y, r4
mul r1.x, r1, c40.w
texldl r1.xy, r1.xyzz, s2
add r1.y, r1, -r1.x
mad r2.x, r3.y, r1.y, r1
add r1.xyz, r7, -c16
dp3 r1.x, r1, r1
rsq r1.x, r1.x
rcp r0.w, r1.x
add r0.z, r0, c40
add r0.w, -r6, r0
mul r1.x, r0.z, c40.w
mul r0.z, r0.w, c27.y
mad r0.w, r0.z, c38.y, c38.z
abs r0.w, r0
mul r0.w, r0, r0
mul r0.w, r0, r0
mov r1.z, c37.w
mov r1.y, r2
texldl r1.xy, r1.xyzz, s2
add r0.z, r1.y, -r1.x
mad r0.z, r2, r0, r1.x
mad r0.z, r2.x, c34.x, r0
mad r0.z, r4.w, r3.x, r0
mad r0.y, r5.w, r0, r0.z
mul r1.x, r0.w, r0.w
mad r0.z, -r1.x, r0.w, c37
mul r1.xyz, r6.xzyw, c29.x
mul r0.y, r0, c34
mad r0.y, r0, r0.z, c30.x
mul_sat r0.y, r7.w, r0
add r0.z, r8.w, -r0.y
mad r0.y, r8.x, r0.z, r0
mul r0.y, r0, -c35.x
add r4.xy, r1, c32
mov r4.z, r1
mul r1.xyz, r4, c33.x
add r3.xy, r1, c32.zwzw
mov r3.z, r1
mul r1.xyz, r3, c33.x
add r1.xy, r1, c32.zwzw
mul r2.xyz, r1, c33.x
add r0.zw, r2.xyxy, c32
mul r0.y, r3.w, r0
mov r2.x, r0.z
mov r2.y, r2.z
add r7.xy, r2, c39.z
pow r2, c38.w, r0.y
mul r2.zw, r7.xyxy, c39.w
mul r7.xy, r2.zwzw, c40.x
mov r0.y, r2.x
abs r2.xy, r7
add r7.xy, r1.xzzw, c39.z
mul r7.xy, r7, c39.w
frc r2.xy, r2
mul r2.xy, r2, c39.w
cmp r2.xy, r2.zwzw, r2, -r2
frc r0.z, r2.y
add r1.x, -r0.z, r2.y
mul r9.xy, r7, c40.x
mad r1.x, r1, c40.y, r2
abs r2.zw, r9.xyxy
add r1.x, r1, c40.z
frc r2.zw, r2
mul r2.zw, r2, c39.w
cmp r7.xy, r7, r2.zwzw, -r2.zwzw
frc r7.z, r7.y
mul r2.x, r1, c40.w
add r1.x, -r7.z, r7.y
mad r1.x, r1, c40.y, r7
add r1.x, r1, c40.z
mov r2.z, c37.w
mov r2.y, r0.w
texldl r2.xy, r2.xyzz, s2
add r0.w, r2.y, -r2.x
mad r2.w, r0.z, r0, r2.x
add r0.zw, r3.xyxz, c39.z
mul r2.xy, r0.zwzw, c39.w
mul r7.xy, r2, c40.x
mov r1.z, c37.w
mul r1.x, r1, c40.w
texldl r1.xy, r1.xyzz, s2
add r0.z, r1.y, -r1.x
mad r0.z, r7, r0, r1.x
abs r1.xy, r7
add r7.xy, r4.xzzw, c39.z
mul r7.xy, r7, c39.w
frc r1.xy, r1
mul r1.xy, r1, c39.w
cmp r1.xy, r2, r1, -r1
mul r9.xy, r7, c40.x
frc r2.z, r1.y
add r0.w, -r2.z, r1.y
mad r0.w, r0, c40.y, r1.x
abs r2.xy, r9
add r1.x, r0.w, c40.z
frc r2.xy, r2
mul r2.xy, r2, c39.w
cmp r2.xy, r7, r2, -r2
frc r0.w, r2.y
add r2.y, -r0.w, r2
mov r1.z, c37.w
mov r1.y, r3
mul r1.x, r1, c40.w
texldl r1.xy, r1.xyzz, s2
add r1.y, r1, -r1.x
mad r4.x, r2.z, r1.y, r1
mad r1.z, r2.y, c40.y, r2.x
add r1.z, r1, c40
mul r1.x, r1.z, c40.w
mov r1.y, r4
mov r1.z, c37.w
texldl r2.xy, r1.xyzz, s2
mul r1.xyz, r5.xzyw, c29.x
add r2.y, r2, -r2.x
mad r0.w, r0, r2.y, r2.x
mad r0.w, r4.x, c34.x, r0
add r3.xy, r1, c32
mov r3.z, r1
mul r1.xyz, r3, c33.x
add r2.xy, r1, c32.zwzw
mov r2.z, r1
mul r1.xyz, r2, c33.x
add r1.xy, r1, c32.zwzw
add r9.xy, r1.xzzw, c39.z
mul r9.xy, r9, c39.w
mul r9.zw, r9.xyxy, c40.x
abs r9.zw, r9
mul r4.xyz, r1, c33.x
mad r7.x, r4.w, r0.z, r0.w
add r0.zw, r4.xyxy, c32
mov r4.y, r4.z
mov r4.x, r0.z
mad r0.z, r5.w, r2.w, r7.x
add r4.xy, r4, c39.z
mul r4.xy, r4, c39.w
mul r7.xy, r4, c40.x
abs r7.xy, r7
frc r7.xy, r7
mul r7.xy, r7, c39.w
cmp r4.xy, r4, r7, -r7
frc r2.w, r4.y
add r1.x, -r2.w, r4.y
mad r1.x, r1, c40.y, r4
frc r9.zw, r9
mul r7.xy, r9.zwzw, c39.w
cmp r7.xy, r9, r7, -r7
add r9.xy, r3.xzzw, c39.z
frc r7.z, r7.y
mul r9.zw, r9.xyxy, c39.w
add r1.z, -r7, r7.y
add r1.x, r1, c40.z
mul r10.xy, r9.zwzw, c40.x
abs r10.xy, r10
frc r10.xy, r10
mad r1.z, r1, c40.y, r7.x
mul r4.x, r1, c40.w
add r1.x, r1.z, c40.z
mov r4.y, r0.w
mov r4.z, c37.w
texldl r4.xy, r4.xyzz, s2
add r0.w, r4.y, -r4.x
mul r1.x, r1, c40.w
mov r1.z, c37.w
texldl r7.xy, r1.xyzz, s2
add r1.xy, r2.xzzw, c39.z
mul r1.xy, r1, c39.w
mul r9.xy, r1, c40.x
abs r9.xy, r9
frc r9.xy, r9
mul r9.xy, r9, c39.w
cmp r1.xy, r1, r9, -r9
frc r3.x, r1.y
add r1.y, -r3.x, r1
mad r1.x, r1.y, c40.y, r1
add r1.x, r1, c40.z
mul r10.xy, r10, c39.w
cmp r9.xy, r9.zwzw, r10, -r10
frc r3.z, r9.y
add r1.z, -r3, r9.y
mad r1.y, r1.z, c40, r9.x
add r1.y, r1, c40.z
mul r2.x, r1, c40.w
mul r1.x, r1.y, c40.w
mov r2.z, c37.w
texldl r2.xy, r2.xyzz, s2
mov r1.z, c37.w
mov r1.y, r3
texldl r1.xy, r1.xyzz, s2
add r1.z, r1.y, -r1.x
mad r1.z, r3, r1, r1.x
add r1.y, r2, -r2.x
mad r1.x, r3, r1.y, r2
mad r1.y, r1.x, c34.x, r1.z
add r4.y, r7, -r7.x
mad r1.x, r7.z, r4.y, r7
add r2.xyz, r6, -c16
mad r1.x, r4.w, r1, r1.y
mad r0.w, r2, r0, r4.x
mad r0.w, r5, r0, r1.x
add r1.xyz, r5, -c16
dp3 r1.x, r1, r1
dp3 r1.y, r2, r2
rsq r1.x, r1.x
rsq r1.y, r1.y
rcp r1.x, r1.x
rcp r1.y, r1.y
add r1.x, r1, -r6.w
add r1.y, -r6.w, r1
mul r1.x, r1, c27.y
mul r1.y, r1, c27
mad r1.x, r1, c38.y, c38.z
mad r1.y, r1, c38, c38.z
abs r1.x, r1
abs r1.y, r1
mul r1.y, r1, r1
mul r1.z, r1.y, r1.y
mul r1.x, r1, r1
mul r1.x, r1, r1
mul r1.y, r1.x, r1.x
mul r2.x, r1.z, r1.z
mad r1.x, -r1.y, r1, c37.z
mul r0.w, r0, c34.y
mad r1.y, -r2.x, r1.z, c37.z
mad r0.w, r0, r1.x, c30.x
mul r0.z, r0, c34.y
mad r1.x, r0.z, r1.y, c30
mul_sat r0.z, r7.w, r0.w
mul_sat r1.x, r7.w, r1
add r0.w, r8, -r0.z
mad r0.z, r8.x, r0.w, r0
add r1.y, r8.w, -r1.x
mad r0.w, r8.x, r1.y, r1.x
mul r0.z, r0, -c35.x
mul r0.w, r0, -c35.x
mul r0.w, r3, r0
mul r0.z, r0, r3.w
pow r3, c38.w, r0.z
pow r2, c38.w, r0.w
mov r0.z, r3.x
mul r1.x, r0.z, r1.w
mov r0.w, r2.x
mul r0.z, r1.x, r0.w
mul r0.y, r0.z, r0
mov r1.z, r0.y
mul r1.w, r0.y, r0.x
mov r1.y, r0.z
mov oC0, r1
endif

"
}

}

		}


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 is the for following steps for deep shadow maps that have more than one layer.
		// It samples the previous layer of the deep shadow map for initial shadowing
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
Vector 12 [_PlanetCenterKm]
Float 13 [_PlanetRadiusKm]
Float 14 [_WorldUnit2Kilometer]
Float 15 [_Kilometer2WorldUnit]
Vector 16 [_SunDirection]
Matrix 4 [_NuajShadow2World]
Vector 17 [_NuajLocalCoverageOffset]
Vector 18 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
SetTexture 2 [_NuajTexNoise3D0] 2D
Vector 19 [_BufferInvSize]
Float 20 [_CloudAltitudeKm]
Vector 21 [_CloudThicknessKm]
Float 22 [_CloudLayerIndex]
Float 23 [_NoiseTiling]
Float 24 [_Coverage]
Vector 25 [_HorizonBlend]
Vector 26 [_CloudPosition]
Float 27 [_FrequencyFactor]
Vector 28 [_AmplitudeFactor]
Float 29 [_CloudSigma_t]
Float 30 [_IsotropicDensity]
Float 31 [_ShadowStepsCount]
Float 32 [_ShadowStepOffset]
SetTexture 0 [_TexDeepShadowMapPreviousLayer] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[37] = { program.local[0..32],
		{ 2.718282, 0.5, 2, 1 },
		{ 3, 0, 1, 1000 },
		{ 16, 0.0625, 17, 0.25 },
		{ 0.0036764706 } };
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
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.w, c[20].x;
ADDR  R0.w, R0, c[13].x;
MOVR  R2.zw, c[34].xyyz;
MOVR  R2.xy, fragment.texcoord[0];
DP4R  R0.z, R2, c[6];
DP4R  R0.x, R2, c[4];
DP4R  R0.y, R2, c[5];
ADDR  R2.xyz, R0, -c[12];
DP3R  R1.z, R2, c[16];
DP3R  R1.w, R2, R2;
ADDR  R2.x, R0.w, c[21];
MADR  R1.w, -R2.x, R2.x, R1;
MULR  R1.y, R1.z, R1.z;
SGER  H0.z, R1.y, R1.w;
ADDR  R2.y, R1, -R1.w;
SLTRC HC.x, R1.y, R1.w;
MOVR  R2.x, c[34].y;
RSQR  R2.y, R2.y;
RCPR  R2.y, R2.y;
MOVR  R2.x(EQ), R1;
SLTR  H0.x, -R1.z, -R2.y;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[34];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.w, c[34].y;
MOVR  R2.x(NE), c[34].y;
SLTR  H0.z, -R1, R2.y;
MULXC HC.x, H0.y, H0.z;
ADDR  R2.x(NE), -R1.z, R2.y;
MOVX  H0.x(NE), c[34].y;
MULXC HC.x, H0.y, H0;
ADDR  R2.x(NE), -R1.z, -R2.y;
MADR  R6.xyz, R2.x, c[16], R0;
ADDR  R0.xyz, R6, -c[12];
DP3R  R1.y, R0, -c[16];
DP3R  R0.y, R0, R0;
MULR  R0.x, R1.y, R1.y;
MADR  R0.y, -R0.w, R0.w, R0;
SGER  H0.z, R0.x, R0.y;
SLTRC HC.x, R0, R0.y;
ADDR  R0.z, R0.x, -R0.y;
RSQR  R0.z, R0.z;
RCPR  R0.z, R0.z;
MOVR  R1.w(EQ.x), R1.x;
SLTR  H0.x, -R1.y, -R0.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[34];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R16.xyz, c[33].zyww;
MOVR  R1.w(NE.x), c[34].y;
SLTR  H0.z, -R1.y, R0;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.w(NE.x), -R1.y, R0.z;
MOVX  H0.x(NE), c[34].y;
MULXC HC.x, H0.y, H0;
ADDR  R1.w(NE.x), -R1.y, -R0.z;
MULR  R8.xyz, R1.w, c[16];
RCPR  R2.w, c[31].x;
MULR  R0.xyz, -R8, R2.w;
MADR  R8.xyz, -R8, c[33].y, R6;
MULR  R1.w, R1, R2;
ADDR  R1.x, R16.y, c[32];
MADR  R1.xyz, R1.x, R0, R6;
ADDR  R3.xyz, R1, R0;
ADDR  R2.xyz, R0, R3;
ADDR  R0.xyz, R0, R2;
MULR  R4.xyz, R0.xzyw, c[23].x;
ADDR  R0.xyz, R0, -c[12];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.x, -R0.w, R0;
MULR  R0.x, R0, c[21].y;
MADR  R0.x, R0, c[33].z, -c[33].w;
MULR  R0.x, |R0|, |R0|;
MULR  R0.y, R0.x, R0.x;
MULR  R0.x, R0.y, R0.y;
ADDR  R5.xy, R4, c[26];
MOVR  R5.z, R4;
MULR  R4.xyz, R5, c[27].x;
ADDR  R7.xy, R4, c[26].zwzw;
MOVR  R7.z, R4;
MULR  R4.xyz, R7, c[27].x;
ADDR  R10.xy, R4, c[26].zwzw;
MOVR  R10.z, R4;
MULR  R4.xyz, R10, c[27].x;
ADDR  R9.zw, R4.xyxy, c[26];
MULR  R8.xyz, R8, c[15].x;
MULR  R1.w, R1, c[34];
ADDR  R7.zw, R7.xyxz, c[34].w;
ADDR  R5.zw, R5.xyxz, c[34].w;
MOVR  R8.w, c[33];
SEQR  H0.zw, c[22].x, R16.xyzx;
MULR  R0.x, R0, R0.y;
MOVR  R4.y, R4.z;
MOVR  R4.x, R9.z;
ADDR  R4.xy, R4, c[34].w;
MULR  R4.zw, R4.xyxy, c[35].x;
MULR  R4.xy, R4.zwzw, c[35].y;
FRCR  R4.xy, |R4|;
MULR  R9.xy, R4, c[35].x;
MOVR  R4.xy, R9;
MOVXC RC.xy, R4.zwzw;
MOVR  R4.xy(LT), -R9;
MULR  R9.xyz, R2.xzyw, c[23].x;
ADDR  R2.xyz, R2, -c[12];
DP3R  R2.x, R2, R2;
ADDR  R9.xy, R9, c[26];
MULR  R11.xyz, R9, c[27].x;
ADDR  R11.xy, R11, c[26].zwzw;
MULR  R13.xyz, R11, c[27].x;
ADDR  R11.zw, R11.xyxz, c[34].w;
RSQR  R2.x, R2.x;
RCPR  R2.x, R2.x;
ADDR  R2.x, -R0.w, R2;
MULR  R2.x, R2, c[21].y;
MADR  R2.x, R2, c[33].z, -c[33].w;
MULR  R2.x, |R2|, |R2|;
MULR  R2.y, R2.x, R2.x;
MULR  R2.x, R2.y, R2.y;
ADDR  R12.xw, R13.xyzy, c[26].zyzw;
MOVR  R12.y, R13.z;
MULR  R13.xyz, R12.xwyw, c[27].x;
ADDR  R20.xy, R13, c[26].zwzw;
MULR  R11.zw, R11, c[35].x;
MULR  R2.x, R2, R2.y;
MOVR  R4.w, R13.z;
MOVR  R4.z, R20.x;
ADDR  R4.zw, R4, c[34].w;
MULR  R4.zw, R4, c[35].x;
MULR  R13.xy, R4.zwzw, c[35].y;
FRCR  R13.xy, |R13|;
MULR  R13.xy, R13, c[35].x;
MOVR  R14.xy, R13;
MOVXC RC.xy, R4.zwzw;
MOVR  R14.xy(LT), -R13;
MULR  R13.xyz, R3.xzyw, c[23].x;
ADDR  R3.xyz, R3, -c[12];
DP3R  R3.x, R3, R3;
ADDR  R13.xy, R13, c[26];
MULR  R15.xyz, R13, c[27].x;
ADDR  R13.zw, R13.xyxz, c[34].w;
RSQR  R3.x, R3.x;
RCPR  R3.x, R3.x;
ADDR  R3.x, -R0.w, R3;
MULR  R3.x, R3, c[21].y;
MADR  R3.x, R3, c[33].z, -c[33].w;
MULR  R3.x, |R3|, |R3|;
MULR  R3.y, R3.x, R3.x;
MULR  R3.x, R3.y, R3.y;
MOVR  R17.z, R15;
ADDR  R17.xy, R15, c[26].zwzw;
MULR  R15.xyz, R17, c[27].x;
ADDR  R18.xw, R15.xyzy, c[26].zyzw;
MOVR  R18.y, R15.z;
MULR  R15.xyz, R18.xwyw, c[27].x;
ADDR  R20.xz, R15.yyxw, c[26].wyzw;
MULR  R13.zw, R13, c[35].x;
MULR  R3.x, R3, R3.y;
MOVR  R4.w, R15.z;
MOVR  R4.z, R20;
ADDR  R4.zw, R4, c[34].w;
MULR  R4.zw, R4, c[35].x;
MULR  R14.zw, R4, c[35].y;
MOVXC RC.xy, R4.zwzw;
ADDR  R4.zw, R10.xyxz, c[34].w;
MULR  R10.zw, R4, c[35].x;
MULR  R4.zw, R10, c[35].y;
FRCR  R14.zw, |R14|;
MULR  R14.zw, R14, c[35].x;
MOVR  R19.xy, R14.zwzw;
MOVR  R19.xy(LT), -R14.zwzw;
MOVXC RC.xy, R10.zwzw;
FRCR  R4.zw, |R4|;
MULR  R14.zw, R4, c[35].x;
MOVR  R4.zw, R14;
ADDR  R10.zw, R12.xyxy, c[34].w;
MULR  R10.zw, R10, c[35].x;
MOVR  R4.zw(LT.xyxy), -R14;
MULR  R12.xy, R10.zwzw, c[35].y;
MOVXC RC.xy, R10.zwzw;
ADDR  R10.zw, R18.xyxy, c[34].w;
FRCR  R12.xy, |R12|;
MULR  R12.xy, R12, c[35].x;
MOVR  R14.zw, R12.xyxy;
MULR  R10.zw, R10, c[35].x;
MOVR  R14.zw(LT.xyxy), -R12.xyxy;
MULR  R12.xy, R10.zwzw, c[35].y;
FRCR  R12.xy, |R12|;
MULR  R12.xy, R12, c[35].x;
MOVR  R19.zw, R12.xyxy;
MOVXC RC.xy, R10.zwzw;
MOVR  R19.zw(LT.xyxy), -R12.xyxy;
MULR  R12.xyz, R1.xzyw, c[23].x;
ADDR  R1.xyz, R1, -c[12];
DP3R  R1.x, R1, R1;
ADDR  R12.xy, R12, c[26];
MULR  R15.xyz, R12, c[27].x;
ADDR  R15.xy, R15, c[26].zwzw;
MULR  R18.xyz, R15, c[27].x;
ADDR  R18.xy, R18, c[26].zwzw;
MULR  R21.xyz, R18, c[27].x;
ADDR  R10.xz, R21.yyxw, c[26].wyzw;
MOVR  R10.w, R21.z;
ADDR  R10.zw, R10, c[34].w;
MULR  R20.zw, R10, c[35].x;
MULR  R10.zw, R20, c[35].y;
MOVXC RC.xy, R20.zwzw;
MULR  R20.zw, R7, c[35].x;
FRCR  R10.zw, |R10|;
MULR  R21.xy, R10.zwzw, c[35].x;
MOVR  R10.zw, R21.xyxy;
MOVR  R10.zw(LT.xyxy), -R21.xyxy;
MULR  R7.zw, R20, c[35].y;
MOVXC RC.xy, R20.zwzw;
FRCR  R7.zw, |R7|;
MULR  R21.xy, R7.zwzw, c[35].x;
MOVR  R7.zw, R21.xyxy;
MOVR  R7.zw(LT.xyxy), -R21.xyxy;
MULR  R20.zw, R11, c[35].y;
MOVXC RC.xy, R11.zwzw;
ADDR  R11.zw, R17.xyxz, c[34].w;
MULR  R11.zw, R11, c[35].x;
MULR  R17.zw, R11, c[35].y;
FRCR  R20.zw, |R20|;
MULR  R20.zw, R20, c[35].x;
MOVR  R16.yw, R20.xzzw;
MOVR  R16.yw(LT.xxzy), -R20.xzzw;
MOVXC RC.xy, R11.zwzw;
FRCR  R17.zw, |R17|;
MULR  R17.zw, R17, c[35].x;
MOVR  R20.zw, R17;
MOVR  R20.zw(LT.xyxy), -R17;
ADDR  R11.zw, R18.xyxz, c[34].w;
MULR  R17.zw, R11, c[35].x;
MULR  R11.zw, R17, c[35].y;
MOVXC RC.xy, R17.zwzw;
MULR  R17.zw, R5, c[35].x;
FRCR  R11.zw, |R11|;
MULR  R21.xy, R11.zwzw, c[35].x;
MOVR  R11.zw, R21.xyxy;
MOVR  R11.zw(LT.xyxy), -R21.xyxy;
MULR  R5.zw, R17, c[35].y;
MOVXC RC.xy, R17.zwzw;
FRCR  R5.zw, |R5|;
MULR  R21.xy, R5.zwzw, c[35].x;
MOVR  R5.zw, R21.xyxy;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R1.x, -R0.w, R1;
MULR  R1.x, R1, c[21].y;
MADR  R1.x, R1, c[33].z, -c[33].w;
MULR  R1.x, |R1|, |R1|;
MULR  R1.y, R1.x, R1.x;
MULR  R1.x, R1.y, R1.y;
MOVR  R5.zw(LT.xyxy), -R21.xyxy;
ADDR  R17.zw, R9.xyxz, c[34].w;
MULR  R21.xy, R17.zwzw, c[35].x;
MULR  R17.zw, R21.xyxy, c[35].y;
MOVXC RC.xy, R21;
FRCR  R17.zw, |R17|;
MULR  R21.zw, R17, c[35].x;
MOVR  R17.zw, R21;
MOVR  R17.zw(LT.xyxy), -R21;
MULR  R21.xy, R13.zwzw, c[35].y;
MOVXC RC.xy, R13.zwzw;
ADDR  R13.zw, R15.xyxz, c[34].w;
MULR  R15.zw, R13, c[35].x;
MULR  R13.zw, R15, c[35].y;
FRCR  R21.xy, |R21|;
MULR  R21.xy, R21, c[35].x;
MOVR  R9.xz, R21.xyyw;
MOVR  R9.xz(LT.xyyw), -R21.xyyw;
MOVXC RC.xy, R15.zwzw;
FRCR  R13.zw, |R13|;
MULR  R21.xy, R13.zwzw, c[35].x;
MOVR  R13.zw, R21.xyxy;
MOVR  R13.zw(LT.xyxy), -R21.xyxy;
ADDR  R15.zw, R12.xyxz, c[34].w;
MULR  R21.xy, R15.zwzw, c[35].x;
MULR  R15.zw, R21.xyxy, c[35].y;
MOVXC RC.xy, R21;
FRCR  R15.zw, |R15|;
MULR  R21.zw, R15, c[35].x;
MOVR  R15.zw, R21;
MOVR  R15.zw(LT.xyxy), -R21;
DP4R  R21.x, R8, c[8];
DP4R  R21.y, R8, c[10];
MADR  R8.xy, R21, c[33].y, c[33].y;
MULR  R1.x, R1, R1.y;
MOVR  R21, c[17];
TEX   R8, R8, texture[1], 2D;
MADR  R8, R8, c[18], R21;
MOVR  R3.w, R8.x;
MOVR  R21.xy, c[34];
SEQR  H0.x, c[22], R21.y;
SEQX  H0.x, H0, c[34].y;
MULXC HC.x, H0, H0.z;
MOVR  R3.w(NE.x), R8.y;
SEQX  H0.yz, H0.xzww, c[34].y;
MULX  H0.x, H0, H0.y;
MULXC HC.x, H0, H0.w;
MOVR  R3.w(NE.x), R8.z;
MULXC HC.x, H0, H0.z;
MOVR  R3.w(NE.x), R8;
MOVR  R8.x, c[0].w;
MOVR  R8.z, c[2].w;
MOVR  R8.y, c[1].w;
MADR  R6.xyz, -R8, c[14].x, R6;
DP3R  R5.x, R6, R6;
RSQR  R5.x, R5.x;
RCPR  R5.x, R5.x;
ADDR  R6.z, R5.x, -c[25].x;
ADDR  R5.x, c[25].y, -c[25];
RCPR  R6.w, R5.x;
ADDR  R6.xy, fragment.texcoord[0], -c[33].y;
MADR  R6.xy, -|R6|, |c[33].z|, c[33].w;
MINR  R6.x, R6, R6.y;
MULR  R6.y, R21.x, c[19].x;
SLTRC HC.x, R6, R6.y;
MOVR  R5.x, c[33].w;
MULR_SAT R5.x(EQ), R6.z, R6.w;
FLRR  R6.z, R19.y;
MADR  R6.x, R6.z, c[35].z, R19;
ADDR  R6.x, R6, c[35].w;
FLRR  R8.z, R16.w;
FLRR  R6.w, R19;
FLRR  R7.x, R20.w;
FLRR  R8.x, R9.z;
FLRR  R8.w, R17;
MOVR  R2.w, R10.x;
MULR  R6.x, R6, c[36];
MOVR  R6.y, R20.x;
TEX   R6.xy, R6, texture[2], 2D;
ADDR  R6.y, R6, -R6.x;
ADDR  R6.z, R19.y, -R6;
MADR  R6.z, R6, R6.y, R6.x;
MADR  R6.x, R6.w, c[35].z, R19.z;
ADDR  R6.x, R6, c[35].w;
MULR  R6.x, R6, c[36];
MOVR  R6.y, R18.w;
TEX   R6.xy, R6, texture[2], 2D;
ADDR  R6.y, R6, -R6.x;
ADDR  R6.w, R19, -R6;
MADR  R6.w, R6, R6.y, R6.x;
MADR  R6.x, R7, c[35].z, R20.z;
ADDR  R6.x, R6, c[35].w;
MULR  R6.x, R6, c[36];
MOVR  R6.y, R17;
TEX   R6.xy, R6, texture[2], 2D;
ADDR  R6.y, R6, -R6.x;
ADDR  R7.x, R20.w, -R7;
MADR  R7.x, R7, R6.y, R6;
MADR  R6.x, R8, c[35].z, R9;
ADDR  R6.x, R6, c[35].w;
ADDR  R8.x, R9.z, -R8;
MULR  R6.x, R6, c[36];
MOVR  R6.y, R13;
TEX   R6.xy, R6, texture[2], 2D;
ADDR  R6.y, R6, -R6.x;
MADR  R6.x, R8, R6.y, R6;
MADR  R6.y, R7.x, c[28].x, R6.x;
MULR  R6.x, c[28], c[28];
MADR  R6.w, R6.x, R6, R6.y;
MULR  R6.y, R6.x, c[28].x;
MADR  R6.z, R6.y, R6, R6.w;
MULR  R6.z, R6, c[28].y;
MADR  R3.x, -R3, R6.z, R6.z;
ADDR  R3.x, R3, c[24];
MULR_SAT R3.z, R3.w, R3.x;
ADDR_SAT R3.x, -R3.w, c[25].z;
ADDR  R3.y, R3.x, -R3.z;
MADR  R3.y, R5.x, R3, R3.z;
FLRR  R3.z, R14.y;
MADR  R6.z, R3, c[35], R14.x;
ADDR  R6.z, R6, c[35].w;
FLRR  R7.x, R14.w;
MULR  R6.z, R6, c[36].x;
MOVR  R6.w, R20.y;
TEX   R8.xy, R6.zwzw, texture[2], 2D;
ADDR  R6.z, R8.y, -R8.x;
ADDR  R3.z, R14.y, -R3;
MADR  R3.z, R3, R6, R8.x;
MADR  R6.z, R7.x, c[35], R14;
ADDR  R6.z, R6, c[35].w;
MULR  R6.z, R6, c[36].x;
MOVR  R6.w, R12;
TEX   R8.xy, R6.zwzw, texture[2], 2D;
ADDR  R6.z, R8.y, -R8.x;
ADDR  R6.w, R14, -R7.x;
MADR  R7.x, R6.w, R6.z, R8;
MADR  R6.z, R8, c[35], R16.y;
ADDR  R6.z, R6, c[35].w;
MULR  R6.z, R6, c[36].x;
MOVR  R6.w, R11.y;
TEX   R8.xy, R6.zwzw, texture[2], 2D;
ADDR  R6.z, R8.y, -R8.x;
ADDR  R6.w, R16, -R8.z;
MADR  R8.z, R6.w, R6, R8.x;
MADR  R6.z, R8.w, c[35], R17;
ADDR  R6.z, R6, c[35].w;
MULR  R6.z, R6, c[36].x;
MOVR  R6.w, R9.y;
TEX   R8.xy, R6.zwzw, texture[2], 2D;
ADDR  R6.z, R8.y, -R8.x;
ADDR  R6.w, R17, -R8;
MADR  R6.z, R6.w, R6, R8.x;
MADR  R6.z, R8, c[28].x, R6;
MADR  R6.z, R6.x, R7.x, R6;
MADR  R3.z, R6.y, R3, R6;
MULR  R3.z, R3, c[28].y;
MADR  R2.x, -R2, R3.z, R3.z;
ADDR  R2.x, R2, c[24];
MULR_SAT R2.y, R3.w, R2.x;
ADDR  R2.x, R3, -R2.y;
MADR  R2.y, R5.x, R2.x, R2;
MULR  R2.x, R3.y, -c[29];
MULR  R2.y, R2, -c[29].x;
MULR  R2.z, R1.w, R2.x;
MULR  R2.y, R1.w, R2;
POWR  R2.x, c[33].x, R2.y;
POWR  R2.y, c[33].x, R2.z;
FLRR  R3.y, R10.w;
MADR  R2.z, R3.y, c[35], R10;
ADDR  R2.z, R2, c[35].w;
MULR  R2.z, R2, c[36].x;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.w, R10, -R3.y;
MADR  R3.y, R2.w, R2.z, R8.x;
FLRR  R3.z, R11.w;
MADR  R2.z, R3, c[35], R11;
ADDR  R2.z, R2, c[35].w;
FLRR  R6.z, R13.w;
MULR  R2.z, R2, c[36].x;
MOVR  R2.w, R18.y;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.w, R11, -R3.z;
MADR  R3.z, R2.w, R2, R8.x;
MADR  R2.z, R6, c[35], R13;
ADDR  R2.z, R2, c[35].w;
MULR  R2.z, R2, c[36].x;
MOVR  R2.w, R15.y;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.w, R13, -R6.z;
MADR  R6.z, R2.w, R2, R8.x;
FLRR  R6.w, R15;
MADR  R2.z, R6.w, c[35], R15;
ADDR  R2.z, R2, c[35].w;
MULR  R2.z, R2, c[36].x;
MOVR  R2.w, R12.y;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.w, R15, -R6;
MADR  R2.z, R2.w, R2, R8.x;
MADR  R2.z, R6, c[28].x, R2;
MADR  R2.z, R6.x, R3, R2;
MADR  R2.z, R6.y, R3.y, R2;
MULR  R2.z, R2, c[28].y;
MADR  R1.x, -R1, R2.z, R2.z;
ADDR  R1.x, R1, c[24];
MULR_SAT R1.y, R3.w, R1.x;
ADDR  R1.x, R3, -R1.y;
MADR  R1.x, R5, R1, R1.y;
MULR  R1.x, R1, -c[29];
MULR  R1.x, R1, R1.w;
FLRR  R3.y, R4.w;
FLRR  R3.z, R7.w;
TEX   R2.w, fragment.texcoord[0], texture[0], 2D;
POWR  R1.x, c[33].x, R1.x;
MULR  R1.x, R1, R2.w;
MULR  R1.y, R1.x, R2;
FLRR  R2.y, R4;
MADR  R2.z, R2.y, c[35], R4.x;
MULR  R2.x, R1.y, R2;
ADDR  R2.z, R2, c[35].w;
MULR  R2.z, R2, c[36].x;
MOVR  R2.w, R9;
TEX   R8.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R8.y, -R8.x;
ADDR  R2.y, R4, -R2;
MADR  R2.y, R2, R2.z, R8.x;
MADR  R2.z, R3.y, c[35], R4;
ADDR  R2.z, R2, c[35].w;
MULR  R2.z, R2, c[36].x;
MOVR  R2.w, R10.y;
TEX   R4.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R4.y, -R4.x;
ADDR  R2.w, R4, -R3.y;
MADR  R3.y, R2.w, R2.z, R4.x;
MADR  R2.z, R3, c[35], R7;
ADDR  R2.z, R2, c[35].w;
MULR  R2.z, R2, c[36].x;
MOVR  R2.w, R7.y;
TEX   R4.xy, R2.zwzw, texture[2], 2D;
ADDR  R2.z, R4.y, -R4.x;
ADDR  R2.w, R7, -R3.z;
MADR  R3.z, R2.w, R2, R4.x;
FLRR  R4.z, R5.w;
MADR  R2.z, R4, c[35], R5;
ADDR  R2.z, R2, c[35].w;
MULR  R2.z, R2, c[36].x;
MOVR  R2.w, R5.y;
TEX   R4.xy, R2.zwzw, texture[2], 2D;
MOVR  R1.z, R2.x;
ADDR  R2.z, R4.y, -R4.x;
ADDR  R2.w, R5, -R4.z;
MADR  R2.z, R2.w, R2, R4.x;
MADR  R2.z, R3, c[28].x, R2;
MADR  R2.z, R6.x, R3.y, R2;
MADR  R2.y, R6, R2, R2.z;
MULR  R2.y, R2, c[28];
MADR  R0.x, -R0, R2.y, R2.y;
ADDR  R0.x, R0, c[24];
MULR_SAT R0.x, R3.w, R0;
ADDR  R0.y, R3.x, -R0.x;
MADR  R0.x, R5, R0.y, R0;
MULR  R0.x, R0, -c[29];
MULR  R0.x, R1.w, R0;
POWR  R0.x, c[33].x, R0.x;
MULR  R1.w, R2.x, R0.x;
MOVR  oCol, R1;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 12 [_PlanetCenterKm]
Float 13 [_PlanetRadiusKm]
Float 14 [_WorldUnit2Kilometer]
Float 15 [_Kilometer2WorldUnit]
Vector 16 [_SunDirection]
Matrix 4 [_NuajShadow2World]
Vector 17 [_NuajLocalCoverageOffset]
Vector 18 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
SetTexture 2 [_NuajTexNoise3D0] 2D
Vector 19 [_BufferInvSize]
Float 20 [_CloudAltitudeKm]
Vector 21 [_CloudThicknessKm]
Float 22 [_CloudLayerIndex]
Float 23 [_NoiseTiling]
Float 24 [_Coverage]
Vector 25 [_HorizonBlend]
Vector 26 [_CloudPosition]
Float 27 [_FrequencyFactor]
Vector 28 [_AmplitudeFactor]
Float 29 [_CloudSigma_t]
Float 30 [_ShadowStepsCount]
Float 31 [_ShadowStepOffset]
SetTexture 0 [_TexDeepShadowMapPreviousLayer] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c32, 2.71828198, -0.50000000, 2.00000000, 3.00000000
def c33, 1.00000000, 0.00000000, -1.00000000, -2.00000000
def c34, 0.50000000, 1000.00000000, 16.00000000, 0.06250000
def c35, 17.00000000, 0.25000000, 0.00367647, 0
def c36, 2.00000000, -1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mov r1.zw, c33.xyyx
mov r1.xy, v0
dp4 r0.z, r1, c6
dp4 r0.y, r1, c5
dp4 r0.x, r1, c4
add r1.xyz, r0, -c12
dp3 r2.y, r1, r1
mov r1.w, c13.x
add r1.w, c20.x, r1
add r2.x, r1.w, c21
dp3 r1.x, r1, c16
mad r2.x, -r2, r2, r2.y
mad r1.y, r1.x, r1.x, -r2.x
rsq r1.z, r1.y
rcp r2.x, r1.z
add r2.y, -r1.x, r2.x
cmp_pp r1.z, r1.y, c33.x, c33.y
cmp r2.z, r2.y, c33.y, c33.x
mul_pp r2.z, r1, r2
cmp_pp r2.w, -r2.z, r1.z, c33.y
add r2.x, -r1, -r2
mul_pp r1.x, r1.z, r2.w
cmp r3.x, r1.y, r0.w, c33.y
cmp r1.z, r2.x, c33.y, c33.x
mul_pp r1.y, r1.x, r1.z
cmp_pp r1.z, -r1.y, r2.w, c33.y
cmp r2.z, -r2, r3.x, c33.y
cmp r1.y, -r1, r2.z, r2
mul_pp r1.x, r1, r1.z
cmp r1.x, -r1, r1.y, r2
mad r2.xyz, r1.x, c16, r0
add r0.xyz, r2, -c12
dp3 r1.x, r0, r0
dp3 r0.x, r0, -c16
mad r1.x, -r1.w, r1.w, r1
mad r0.y, r0.x, r0.x, -r1.x
rsq r0.z, r0.y
rcp r1.x, r0.z
add r1.y, -r0.x, r1.x
cmp_pp r0.z, r0.y, c33.x, c33.y
cmp r1.z, r1.y, c33.y, c33.x
mul_pp r1.z, r0, r1
cmp r0.w, r0.y, r0, c33.y
cmp_pp r2.w, -r1.z, r0.z, c33.y
add r1.x, -r0, -r1
mul_pp r0.x, r0.z, r2.w
cmp r0.z, r1.x, c33.y, c33.x
mul_pp r0.y, r0.x, r0.z
cmp_pp r0.z, -r0.y, r2.w, c33.y
cmp r0.w, -r1.z, r0, c33.y
cmp r0.y, -r0, r0.w, r1
mul_pp r0.x, r0, r0.z
cmp r2.w, -r0.x, r0.y, r1.x
mov r0.w, c31.x
mul r0.xyz, r2.w, c16
rcp r3.w, c30.x
mul r1.xyz, -r0, r3.w
mad r0.xyz, -r0, c34.x, r2
add r0.w, c34.x, r0
mad r5.xyz, r0.w, r1, r2
add r6.xyz, r5, r1
add r7.xyz, r1, r6
add r8.xyz, r1, r7
mul r1.xyz, r8.xzyw, c23.x
add r4.xy, r1, c26
mov r4.z, r1
mul r1.xyz, r4, c27.x
add r3.xy, r1, c26.zwzw
mov r3.z, r1
mul r1.xyz, r3, c27.x
add r1.xy, r1, c26.zwzw
mul r9.xyz, r1, c27.x
mul r0.xyz, r0, c15.x
add r9.xy, r9, c26.zwzw
mov r9.w, r9.z
mov r9.z, r9.x
add r9.zw, r9, c34.y
mul r9.zw, r9, c34.z
mul r10.xy, r9.zwzw, c34.w
abs r10.xy, r10
frc r10.xy, r10
mul r10.xy, r10, c34.z
cmp r9.zw, r9, r10.xyxy, -r10.xyxy
add r10.zw, r1.xyxz, c34.y
mul r10.xy, r10.zwzw, c34.z
frc r0.w, r9
add r1.x, -r0.w, r9.w
mad r1.x, r1, c35, r9.z
mul r10.zw, r10.xyxy, c34.w
add r1.x, r1, c35.y
abs r10.zw, r10
frc r9.zw, r10
mul r9.zw, r9, c34.z
cmp r10.xy, r10, r9.zwzw, -r9.zwzw
frc r4.w, r10.y
add r1.z, -r4.w, r10.y
mul r9.x, r1, c35.z
mov r9.z, c33.y
texldl r9.xy, r9.xyzz, s2
add r1.x, r9.y, -r9
mad r0.w, r0, r1.x, r9.x
mad r1.x, r1.z, c35, r10
add r9.xy, r3.xzzw, c34.y
mul r9.xy, r9, c34.z
mul r9.zw, r9.xyxy, c34.w
add r1.x, r1, c35.y
abs r9.zw, r9
mov r1.z, c33.y
mul r1.x, r1, c35.z
texldl r1.xy, r1.xyzz, s2
add r1.y, r1, -r1.x
mad r3.x, r4.w, r1.y, r1
add r4.zw, r4.xyxz, c34.y
frc r9.zw, r9
mul r1.xy, r9.zwzw, c34.z
cmp r1.xy, r9, r1, -r1
frc r3.z, r1.y
add r1.y, -r3.z, r1
mul r4.zw, r4, c34.z
mul r9.xy, r4.zwzw, c34.w
mad r1.z, r1.y, c35.x, r1.x
abs r9.xy, r9
frc r1.xy, r9
mul r9.xy, r1, c34.z
add r1.z, r1, c35.y
mul r1.x, r1.z, c35.z
cmp r4.zw, r4, r9.xyxy, -r9.xyxy
mov r1.y, r3
mov r1.z, c33.y
texldl r1.xy, r1.xyzz, s2
frc r3.y, r4.w
add r1.z, -r3.y, r4.w
mul r4.w, c28.x, c28.x
mad r4.x, r1.z, c35, r4.z
add r1.y, r1, -r1.x
mad r3.z, r3, r1.y, r1.x
add r1.xyz, r8, -c12
dp3 r1.y, r1, r1
add r4.x, r4, c35.y
mul r1.x, r4, c35.z
rsq r4.x, r1.y
mul r5.w, r4, c28.x
mov r1.z, c33.y
mov r1.y, r4
texldl r1.xy, r1.xyzz, s2
add r1.y, r1, -r1.x
mad r1.x, r3.y, r1.y, r1
rcp r1.z, r4.x
add r1.z, -r1.w, r1
mul r1.y, r1.z, c21
mad r1.x, r3.z, c28, r1
mad r1.x, r4.w, r3, r1
mad r0.w, r5, r0, r1.x
mad r1.y, r1, c36.x, c36
abs r1.y, r1
mul r1.x, r1.y, r1.y
mul r4.x, r1, r1
mul r1.xyz, r7.xzyw, c23.x
mul r4.y, r4.x, r4.x
add r3.xy, r1, c26
mov r3.z, r1
mul r1.xyz, r3, c27.x
add r1.xy, r1, c26.zwzw
mad r6.w, -r4.y, r4.x, c33.x
mul r4.xyz, r1, c27.x
mul r0.w, r0, c28.y
mad r7.w, r0, r6, c24.x
mov r0.w, c33.x
mov r6.w, c22.x
add r4.xy, r4, c26.zwzw
dp4 r8.x, r0, c8
dp4 r8.y, r0, c10
add r0.xy, r8, c33.x
mul r8.xyz, r4, c27.x
add r9.x, c33.z, r6.w
abs r8.w, c22.x
cmp r6.w, -r8, c33.x, c33.y
abs r8.w, r9.x
abs_pp r6.w, r6
mov r9.x, c22
cmp r8.w, -r8, c33.x, c33.y
cmp_pp r6.w, -r6, c33.x, c33.y
mul_pp r9.y, r6.w, r8.w
add r9.x, c33.w, r9
mov r0.z, c33.y
mul r0.xy, r0, c34.x
texldl r0, r0.xyzz, s1
mul r0, r0, c18
add r0, r0, c17
cmp r0.x, -r9.y, r0, r0.y
abs_pp r0.y, r8.w
abs r8.w, r9.x
cmp_pp r0.y, -r0, c33.x, c33
mul_pp r0.y, r6.w, r0
cmp r8.w, -r8, c33.x, c33.y
abs_pp r6.w, r8
mul_pp r8.w, r0.y, r8
cmp r0.z, -r8.w, r0.x, r0
cmp_pp r6.w, -r6, c33.x, c33.y
mul_pp r0.x, r0.y, r6.w
cmp r6.w, -r0.x, r0.z, r0
add r0.zw, r8.xyxy, c26
mov r0.y, r8.z
mov r0.x, r0.z
add r0.xy, r0, c34.y
mul r8.xy, r0, c34.z
add_sat r8.z, -r6.w, c25
mul_sat r7.w, r6, r7
add r9.x, r8.z, -r7.w
mov r0.x, c0.w
mov r0.z, c2.w
mov r0.y, c1.w
mad r0.xyz, -r0, c14.x, r2
dp3 r0.z, r0, r0
mul r2.xy, r8, c34.w
abs r0.xy, r2
rsq r0.z, r0.z
frc r0.xy, r0
rcp r0.z, r0.z
mul r0.xy, r0, c34.z
add r2.z, c25.y, -c25.x
add r2.xy, v0, c32.y
mul r2.xy, r2, c32.z
abs r2.xy, r2
add r2.xy, -r2, c33.x
cmp r0.xy, r8, r0, -r0
min r2.x, r2, r2.y
rcp r2.z, r2.z
add r0.z, r0, -c25.x
mul_sat r0.z, r0, r2
mov r2.z, c19.x
mul r2.z, c32.w, r2
add_pp r2.x, r2, -r2.z
cmp r8.w, r2.x, r0.z, c33.x
mad r0.z, r8.w, r9.x, r7.w
frc r7.w, r0.y
add r2.xy, r4.xzzw, c34.y
mul r2.z, r0, -c29.x
add r0.y, -r7.w, r0
mad r0.z, r0.y, c35.x, r0.x
mul r2.xy, r2, c34.z
mul r0.xy, r2, c34.w
abs r8.xy, r0
add r0.z, r0, c35.y
mul r0.x, r0.z, c35.z
frc r8.xy, r8
mov r0.z, c33.y
mov r0.y, r0.w
texldl r0.xy, r0.xyzz, s2
mul r0.zw, r8.xyxy, c34.z
cmp r0.zw, r2.xyxy, r0, -r0
frc r4.x, r0.w
add r0.w, -r4.x, r0
add r0.y, r0, -r0.x
mad r4.z, r7.w, r0.y, r0.x
add r0.xy, r1.xzzw, c34.y
mul r2.xy, r0, c34.z
mad r0.z, r0.w, c35.x, r0
mul r0.xy, r2, c34.w
add r1.x, r0.z, c35.y
abs r0.zw, r0.xyxy
frc r8.xy, r0.zwzw
mul r0.x, r1, c35.z
mov r0.z, c33.y
mov r0.y, r4
texldl r0.xy, r0.xyzz, s2
mul r0.zw, r8.xyxy, c34.z
cmp r0.zw, r2.xyxy, r0, -r0
frc r7.w, r0
add r0.w, -r7, r0
add r0.y, r0, -r0.x
mad r1.z, r4.x, r0.y, r0.x
add r0.xy, r3.xzzw, c34.y
mul r2.xy, r0, c34.z
mad r0.z, r0.w, c35.x, r0
mul r0.xy, r2, c34.w
add r1.x, r0.z, c35.y
abs r0.zw, r0.xyxy
frc r4.xy, r0.zwzw
mul r0.x, r1, c35.z
mov r0.z, c33.y
mov r0.y, r1
texldl r0.xy, r0.xyzz, s2
mul r0.zw, r4.xyxy, c34.z
cmp r1.xy, r2, r0.zwzw, -r0.zwzw
frc r2.x, r1.y
add r0.y, r0, -r0.x
mad r0.w, r7, r0.y, r0.x
add r0.xyz, r7, -c12
dp3 r0.y, r0, r0
add r1.y, -r2.x, r1
mad r0.x, r1.y, c35, r1
rsq r0.y, r0.y
rcp r0.y, r0.y
add r1.x, -r1.w, r0.y
add r0.x, r0, c35.y
mov r0.z, c33.y
mov r0.y, r3
mul r0.x, r0, c35.z
texldl r0.xy, r0.xyzz, s2
add r0.y, r0, -r0.x
mad r0.x, r2, r0.y, r0
mul r0.z, r1.x, c21.y
mad r0.z, r0, c36.x, c36.y
abs r0.y, r0.z
mad r0.x, r0.w, c28, r0
mul r0.y, r0, r0
mul r0.z, r0.y, r0.y
mul r0.w, r0.z, r0.z
mad r0.x, r4.w, r1.z, r0
mad r0.x, r5.w, r4.z, r0
mul r0.y, r0.x, c28
mul r0.x, r2.w, r3.w
mad r0.z, -r0.w, r0, c33.x
mul r2.w, r0.x, c34.y
mad r0.y, r0, r0.z, c24.x
mul_sat r0.x, r6.w, r0.y
mul r0.z, r2.w, r2
pow r7, c32.x, r0.z
add r0.y, r8.z, -r0.x
mad r0.w, r8, r0.y, r0.x
mul r0.xyz, r6.xzyw, c23.x
mul r0.w, r0, -c29.x
add r2.xy, r0, c26
mov r2.z, r0
mul r0.xyz, r2, c27.x
add r1.xy, r0, c26.zwzw
mov r1.z, r0
mul r3.xyz, r1, c27.x
add r3.xy, r3, c26.zwzw
mul r3.w, r2, r0
pow r0, c32.x, r3.w
mul r4.xyz, r3, c27.x
add r0.zw, r4.xyxy, c26
mov r4.y, r4.z
mov r4.x, r0.z
add r4.xy, r4, c34.y
mov r4.z, r0.x
mul r0.xy, r4, c34.z
add r4.xy, r3.xzzw, c34.y
mul r4.xy, r4, c34.z
mul r3.zw, r0.xyxy, c34.w
mul r7.zw, r4.xyxy, c34.w
abs r3.zw, r3
frc r3.zw, r3
mul r3.zw, r3, c34.z
cmp r0.xy, r0, r3.zwzw, -r3.zwzw
frc r7.y, r0
add r0.y, -r7, r0
mad r0.x, r0.y, c35, r0
abs r7.zw, r7
frc r7.zw, r7
mul r3.zw, r7, c34.z
cmp r3.zw, r4.xyxy, r3, -r3
frc r8.x, r3.w
add r0.y, -r8.x, r3.w
mad r0.y, r0, c35.x, r3.z
add r3.x, r0.y, c35.y
add r0.x, r0, c35.y
mov r0.y, r0.w
mul r0.x, r0, c35.z
mov r0.z, c33.y
texldl r4.xy, r0.xyzz, s2
add r4.y, r4, -r4.x
mul r0.x, r3, c35.z
mov r0.y, r3
mov r0.z, c33.y
texldl r3.xy, r0.xyzz, s2
add r0.xy, r1.xzzw, c34.y
add r0.zw, r2.xyxz, c34.y
mul r3.zw, r0, c34.z
mul r7.zw, r3, c34.w
mul r0.xy, r0, c34.z
mul r0.zw, r0.xyxy, c34.w
abs r0.zw, r0
abs r7.zw, r7
frc r0.zw, r0
mul r0.zw, r0, c34.z
cmp r0.xy, r0, r0.zwzw, -r0.zwzw
frc r2.x, r0.y
add r0.y, -r2.x, r0
mad r0.x, r0.y, c35, r0
add r0.x, r0, c35.y
frc r7.zw, r7
mul r7.zw, r7, c34.z
cmp r0.zw, r3, r7, -r7
frc r2.z, r0.w
add r0.w, -r2.z, r0
mad r0.y, r0.w, c35.x, r0.z
add r3.y, r3, -r3.x
add r0.y, r0, c35
mul r1.x, r0, c35.z
mul r0.x, r0.y, c35.z
mov r1.z, c33.y
texldl r1.xy, r1.xyzz, s2
mov r0.z, c33.y
mov r0.y, r2
texldl r0.xy, r0.xyzz, s2
add r0.z, r0.y, -r0.x
mad r0.z, r2, r0, r0.x
add r0.y, r1, -r1.x
mad r0.x, r2, r0.y, r1
mad r0.y, r0.x, c28.x, r0.z
mad r0.x, r8, r3.y, r3
mad r0.y, r4.w, r0.x, r0
mad r0.x, r7.y, r4.y, r4
mad r0.w, r5, r0.x, r0.y
add r0.xyz, r6, -c12
dp3 r1.x, r0, r0
mul r0.xyz, r5.xzyw, c23.x
rsq r1.x, r1.x
rcp r3.x, r1.x
add r3.w, -r1, r3.x
add r2.xy, r0, c26
mov r2.z, r0
mul r0.xyz, r2, c27.x
add r1.xy, r0, c26.zwzw
mov r1.z, r0
mul r0.xyz, r1, c27.x
add r0.xy, r0, c26.zwzw
mul r3.xyz, r0, c27.x
mul r4.x, r3.w, c21.y
add r3.xy, r3, c26.zwzw
mov r3.w, r3.z
mov r3.z, r3.x
mad r3.x, r4, c36, c36.y
add r3.zw, r3, c34.y
mul r3.zw, r3, c34.z
mul r4.xy, r3.zwzw, c34.w
abs r3.x, r3
mul r3.x, r3, r3
mul r3.x, r3, r3
mul r6.x, r3, r3
abs r4.xy, r4
frc r4.xy, r4
mul r4.xy, r4, c34.z
cmp r3.zw, r3, r4.xyxy, -r4.xyxy
mad r3.x, -r6, r3, c33
mul r0.w, r0, c28.y
mad r0.w, r0, r3.x, c24.x
frc r6.y, r3.w
mul_sat r6.x, r6.w, r0.w
add r0.zw, r0.xyxz, c34.y
add r3.x, -r6.y, r3.w
mad r0.x, r3, c35, r3.z
mul r0.zw, r0, c34.z
mul r3.zw, r0, c34.w
abs r4.xy, r3.zwzw
add r0.x, r0, c35.y
mul r3.x, r0, c35.z
mov r3.z, c33.y
texldl r3.xy, r3.xyzz, s2
frc r3.zw, r4.xyxy
add r0.x, r3.y, -r3
mad r4.x, r6.y, r0, r3
add r3.xy, r1.xzzw, c34.y
mul r3.zw, r3, c34.z
cmp r0.zw, r0, r3, -r3
frc r1.x, r0.w
mul r3.xy, r3, c34.z
add r0.x, -r1, r0.w
mad r0.x, r0, c35, r0.z
mul r3.zw, r3.xyxy, c34.w
abs r0.zw, r3
frc r0.zw, r0
mul r3.zw, r0, c34.z
add r0.x, r0, c35.y
mov r0.z, c33.y
mul r0.x, r0, c35.z
texldl r0.xy, r0.xyzz, s2
cmp r0.zw, r3.xyxy, r3, -r3
frc r1.z, r0.w
add r0.w, -r1.z, r0
add r0.y, r0, -r0.x
mad r1.x, r1, r0.y, r0
add r0.xy, r2.xzzw, c34.y
mul r3.xy, r0, c34.z
mad r0.z, r0.w, c35.x, r0
add r0.x, r0.z, c35.y
mul r0.zw, r3.xyxy, c34.w
abs r3.zw, r0
mov r0.z, c33.y
mov r0.y, r1
mul r0.x, r0, c35.z
texldl r0.xy, r0.xyzz, s2
add r0.y, r0, -r0.x
frc r0.zw, r3
mul r0.zw, r0, c34.z
cmp r3.xy, r3, r0.zwzw, -r0.zwzw
mad r1.y, r1.z, r0, r0.x
add r0.xyz, r5, -c12
dp3 r0.y, r0, r0
frc r0.w, r3.y
add r0.x, -r0.w, r3.y
rsq r0.y, r0.y
mad r0.x, r0, c35, r3
rcp r0.y, r0.y
add r0.y, -r1.w, r0
mul r1.z, r0.y, c21.y
add r0.x, r0, c35.y
mov r0.z, c33.y
mul r0.x, r0, c35.z
mov r0.y, r2
texldl r0.xy, r0.xyzz, s2
add r0.y, r0, -r0.x
mad r0.x, r0.w, r0.y, r0
mad r0.z, r1, c36.x, c36.y
abs r0.z, r0
mul r0.y, r0.z, r0.z
mad r0.x, r1.y, c28, r0
mul r0.y, r0, r0
mul r0.z, r0.y, r0.y
mad r0.x, r4.w, r1, r0
mad r0.x, r5.w, r4, r0
mad r0.y, -r0.z, r0, c33.x
mul r0.x, r0, c28.y
mad r0.x, r0, r0.y, c24
add r0.y, r8.z, -r6.x
mad r0.z, r8.w, r0.y, r6.x
mul_sat r0.x, r6.w, r0
add r0.y, r8.z, -r0.x
mul r0.z, r0, -c29.x
mad r0.x, r8.w, r0.y, r0
mul r1.y, r2.w, r0.z
mul r1.x, r0, -c29
pow r0, c32.x, r1.y
mul r0.y, r1.x, r2.w
pow r1, c32.x, r0.y
mov r0.y, r0.x
mov r0.x, r1
texldl r0.w, v0, s0
mul r0.x, r0, r0.w
mul r0.y, r0.x, r0
mul r0.w, r0.y, r4.z
mov r0.z, r0.w
mov r1.x, r7
mul r0.w, r0, r1.x
mov oC0, r0

"
}

}

		}

		// Pass #2 This is used to smooth out the shadow map using a simple gaussian blur
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
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 0.0625, 6, 4 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
ADDR  R1.xy, fragment.texcoord[0], -c[0];
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[0].xyxy;
TEX   R2, R1.zwzw, texture[0], 2D;
TEX   R0, R1, texture[0], 2D;
ADDR  R0, R2, R0;
MULR  R2, R0, c[1].z;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MADR  R0, R0, c[1].y, R2;
ADDR  R1.zw, R1, c[0].xyxy;
TEX   R2, R1.zwzw, texture[0], 2D;
ADDR  R1.xy, R1, -c[0];
TEX   R1, R1, texture[0], 2D;
ADDR  R0, R0, R2;
ADDR  R0, R0, R1;
MULR  oCol, R0, c[1].x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 0 [_dUV]
SetTexture 0 [_MainTex] 2D

"ps_3_0
dcl_2d s0
def c1, 4.00000000, 6.00000000, 0.06250000, 0
dcl_texcoord0 v0.xyzw
add r2.xyz, v0.xyww, c0.xyww
add r3.xyz, v0.xyww, -c0.xyww
texldl r1, r3.xyzz, s0
texldl r0, r2.xyzz, s0
add r0, r0, r1
mul r1, r0, c1.x
texldl r0, v0, s0
mad r0, r0, c1.y, r1
add r1.xyz, r2, c0.xyww
add r2.xyz, r3, -c0.xyww
texldl r1, r1.xyzz, s0
texldl r2, r2.xyzz, s0
add r0, r0, r1
add r0, r0, r2
mul oC0, r0, c1.z

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 renders the deep shadow map used by the sky environment rendering
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
Float 13 [_WorldUnit2Kilometer]
Float 14 [_Kilometer2WorldUnit]
Vector 15 [_SunDirection]
Vector 16 [_EnvironmentAngles]
Vector 17 [_NuajLocalCoverageOffset]
Vector 18 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
SetTexture 1 [_NuajTexNoise3D0] 2D
Vector 19 [_BufferInvSize]
Float 20 [_CloudAltitudeKm]
Vector 21 [_CloudThicknessKm]
Float 22 [_CloudLayerIndex]
Float 23 [_NoiseTiling]
Float 24 [_Coverage]
Vector 25 [_HorizonBlend]
Vector 26 [_CloudPosition]
Float 27 [_FrequencyFactor]
Vector 28 [_AmplitudeFactor]
Float 29 [_CloudSigma_t]
Float 30 [_IsotropicDensity]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[35] = { program.local[0..30],
		{ 1, 2, 0.5, 3 },
		{ 2.718282, 0, 0.25, 1000 },
		{ 16, 0.0625, 17, 0.0036764706 },
		{ 250, 0 } };
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
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
ADDR  R1.xy, fragment.texcoord[0], -c[31].z;
MOVR  R1.z, c[31].w;
MADR  R1.xy, -|R1|, |c[31].y|, c[31].x;
MULR  R1.z, R1, c[19].x;
MINR  R1.x, R1, R1.y;
SLTRC HC.x, R1, R1.z;
MOVR  oCol, c[31].x;
MOVR  oCol(EQ.x), R0;
SGERC HC.x, R1, R1.z;
IF    NE.x;
MADR  R1.xy, fragment.texcoord[0], c[16].zwzw, c[16];
COSR  R0.x, R1.y;
MOVR  R3.w, c[32].y;
MULR  R4.w, c[28].x, c[28].x;
SINR  R1.z, R1.x;
SINR  R1.w, R1.y;
COSR  R2.w, R1.x;
MULR  R1.y, R1.w, R1.z;
MULR  R1.w, R1, R2;
MULR  R0.xyz, R0.x, c[9];
MADR  R0.xyz, R1.y, c[10], R0;
MOVR  R2.w, c[20].x;
ADDR  R2.w, R2, c[12].x;
MOVR  R2.y, c[32];
MADR  R0.xyz, R1.w, c[11], R0;
MOVR  R1.y, c[2].w;
MOVR  R1.x, c[0].w;
MULR  R2.xz, R1.xyyw, c[13].x;
ADDR  R1.xyz, R2, -c[8];
DP3R  R1.w, R0, R1;
DP3R  R1.x, R1, R1;
MADR  R1.y, -R2.w, R2.w, R1.x;
MULR  R3.x, R1.w, R1.w;
SGER  H0.z, R3.x, R1.y;
ADDR  R1.z, R3.x, -R1.y;
RSQR  R1.z, R1.z;
RCPR  R1.z, R1.z;
MOVR  R1.x, c[32].y;
SLTRC HC.x, R3, R1.y;
MOVR  R1.x(EQ), R0.w;
SLTR  H0.x, -R1.w, -R1.z;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[32];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.x(NE), c[32].y;
SLTR  H0.z, -R1.w, R1;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.x(NE), -R1.w, R1.z;
MOVX  H0.x(NE), c[32].y;
MULXC HC.x, H0.y, H0;
ADDR  R1.x(NE), -R1.w, -R1.z;
MADR  R0.xyz, R1.x, R0, R2;
ADDR  R1.xyz, R0, -c[8];
DP3R  R1.w, R1, c[15];
DP3R  R1.x, R1, R1;
MULR  R1.y, R1.w, R1.w;
MADR  R1.x, -R2.w, R2.w, R1;
SGER  H0.z, R1.y, R1.x;
SLTRC HC.x, R1.y, R1;
MOVR  R3.w(EQ.x), R0;
ADDR  R0.w, R1.y, -R1.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
SLTR  H0.x, -R1.w, -R0.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[32];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R3.w(NE.x), c[32].y;
SLTR  H0.z, -R1.w, R0.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R3.w(NE.x), -R1, R0;
MOVX  H0.x(NE), c[32].y;
MULXC HC.x, H0.y, H0;
ADDR  R3.w(NE.x), -R1, -R0;
MULR  R1.xyz, R3.w, c[15];
MADR  R2.xyz, R3.w, c[15], R0;
MULR  R0.xyz, -R1, c[32].z;
MADR  R5.xyz, R0, c[31].z, R2;
ADDR  R6.xyz, R5, R0;
ADDR  R4.xyz, R0, R6;
ADDR  R3.xyz, R0, R4;
MULR  R0.xyz, R3.xzyw, c[23].x;
MOVR  R7.z, R0;
ADDR  R7.xy, R0, c[26];
MULR  R0.xyz, R7, c[27].x;
MOVR  R8.z, R0;
ADDR  R8.xy, R0, c[26].zwzw;
MULR  R0.xyz, R8, c[27].x;
MOVR  R9.z, R0;
ADDR  R9.xy, R0, c[26].zwzw;
MULR  R0.xyz, R9, c[27].x;
ADDR  R13.zw, R0.xyxy, c[26];
MULR  R3.w, R3, c[34].x;
MOVR  R0.y, R0.z;
MOVR  R0.x, R13.z;
ADDR  R0.xy, R0, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R19.xy, R0;
MOVXC RC.xy, R0.zwzw;
MOVR  R19.xy(LT), -R0;
MULR  R0.xyz, R4.xzyw, c[23].x;
MOVR  R10.z, R0;
ADDR  R10.xy, R0, c[26];
MULR  R0.xyz, R10, c[27].x;
MOVR  R11.z, R0;
ADDR  R11.xy, R0, c[26].zwzw;
MULR  R0.xyz, R11, c[27].x;
MOVR  R12.z, R0;
ADDR  R12.xy, R0, c[26].zwzw;
MULR  R0.xyz, R12, c[27].x;
ADDR  R16.zw, R0.xyxy, c[26];
MOVR  R0.y, R0.z;
MOVR  R0.x, R16.z;
ADDR  R0.xy, R0, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R19.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R19.zw(LT.xyxy), -R0.xyxy;
MULR  R0.xyz, R6.xzyw, c[23].x;
ADDR  R13.xy, R0, c[26];
MOVR  R13.z, R0;
MULR  R0.xyz, R13, c[27].x;
MOVR  R14.z, R0;
ADDR  R14.xy, R0, c[26].zwzw;
MULR  R0.xyz, R14, c[27].x;
MOVR  R15.z, R0;
ADDR  R15.xy, R0, c[26].zwzw;
MULR  R0.xyz, R15, c[27].x;
ADDR  R21.zw, R0.xyxy, c[26];
MOVR  R0.y, R0.z;
MOVR  R0.x, R21.z;
ADDR  R0.xy, R0, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R20.xy, R0;
MOVXC RC.xy, R0.zwzw;
MOVR  R20.xy(LT), -R0;
MULR  R0.xyz, R5.xzyw, c[23].x;
ADDR  R16.xy, R0, c[26];
MOVR  R16.z, R0;
MULR  R0.xyz, R16, c[27].x;
MOVR  R17.z, R0;
ADDR  R17.xy, R0, c[26].zwzw;
MULR  R0.xyz, R17, c[27].x;
MOVR  R18.z, R0;
ADDR  R18.xy, R0, c[26].zwzw;
MULR  R0.xyz, R18, c[27].x;
ADDR  R21.xz, R0.xyyw, c[26].zyww;
MOVR  R0.y, R0.z;
MOVR  R0.x, R21;
ADDR  R0.xy, R0, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R20.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R20.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R9.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R9.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R9.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R12.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R12.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R12.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R15.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R15.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R15.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R18.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R18.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R18.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R8.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R8.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R8.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R11.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R11.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R11.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R14.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R14.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R14.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R17.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R21.xy, R0;
MOVXC RC.xy, R0.zwzw;
MOVR  R21.xy(LT), -R0;
ADDR  R0.xy, R7.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R7.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R7.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R10.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R10.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R10.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R13.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R17.zw, R0.xyxy;
MOVXC RC.xy, R0.zwzw;
MOVR  R17.zw(LT.xyxy), -R0.xyxy;
ADDR  R0.xy, R16.xzzw, c[32].w;
MULR  R0.zw, R0.xyxy, c[33].x;
MULR  R0.xy, R0.zwzw, c[33].y;
MOVXC RC.xy, R0.zwzw;
FRCR  R0.xy, |R0|;
MULR  R0.xy, R0, c[33].x;
MOVR  R13.xz, R0.xyyw;
MOVR  R13.xz(LT.xyyw), -R0.xyyw;
MADR  R0.xyz, -R1, c[31].z, R2;
MULR  R0.xyz, R0, c[14].x;
MOVR  R0.w, c[31].x;
DP4R  R1.x, R0, c[4];
DP4R  R1.y, R0, c[6];
MADR  R0.xy, R1, c[31].z, c[31].z;
MOVR  R1, c[17];
TEX   R0, R0, texture[0], 2D;
MADR  R0, R0, c[18], R1;
MOVR  R1.w, R0.x;
MOVR  R1.xy, c[31];
SEQR  H0.zw, c[22].x, R1.xyxy;
MOVR  R0.x, c[32].y;
SEQR  H0.x, c[22], R0;
SEQX  H0.x, H0, c[32].y;
MULXC HC.x, H0, H0.z;
MOVR  R1.w(NE.x), R0.y;
SEQX  H0.yz, H0.xzww, c[32].y;
MULX  H0.x, H0, H0.y;
MULXC HC.x, H0, H0.w;
MOVR  R1.w(NE.x), R0.z;
FLRR  R0.z, R20.w;
MADR  R0.x, R0.z, c[33].z, R20.z;
MULXC HC.x, H0, H0.z;
MOVR  R1.w(NE.x), R0;
ADDR  R0.x, R0, c[32].z;
FLRR  R0.w, R18;
FLRR  R1.x, R21.y;
FLRR  R1.z, R14.w;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R21.z;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R0.z, R20.w, -R0;
MADR  R0.z, R0, R0.y, R0.x;
MADR  R0.x, R0.w, c[33].z, R18.z;
ADDR  R0.x, R0, c[32].z;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R18;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R0.w, R18, -R0;
MADR  R0.w, R0, R0.y, R0.x;
MADR  R0.x, R1, c[33].z, R21;
ADDR  R0.x, R0, c[32].z;
ADDR  R1.x, R21.y, -R1;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R17;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R1.y, R1.x, R0, R0.x;
FLRR  R1.x, R13.z;
MADR  R0.x, R1, c[33].z, R13;
ADDR  R0.x, R0, c[32].z;
ADDR  R1.x, R13.z, -R1;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R16;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R1, R0.y, R0;
MADR  R0.x, R1.y, c[28], R0;
MADR  R0.x, R4.w, R0.w, R0;
MULR  R0.w, R4, c[28].x;
MADR  R0.z, R0.w, R0, R0.x;
FLRR  R1.x, R20.y;
MADR  R0.x, R1, c[33].z, R20;
ADDR  R0.x, R0, c[32].z;
FLRR  R1.y, R15.w;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R21.w;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R1.x, R20.y, -R1;
MADR  R1.x, R1, R0.y, R0;
MADR  R0.x, R1.y, c[33].z, R15.z;
ADDR  R0.x, R0, c[32].z;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R15;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R1.y, R15.w, -R1;
MADR  R1.y, R1, R0, R0.x;
MADR  R0.x, R1.z, c[33].z, R14.z;
ADDR  R0.x, R0, c[32].z;
ADDR  R1.z, R14.w, -R1;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R14;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R5.w, R1.z, R0.y, R0.x;
FLRR  R1.z, R17.w;
MADR  R0.x, R1.z, c[33].z, R17.z;
ADDR  R0.x, R0, c[32].z;
ADDR  R1.z, R17.w, -R1;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R13;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R1.z, R0.y, R0;
MADR  R0.x, R5.w, c[28], R0;
MADR  R0.x, R4.w, R1.y, R0;
MADR  R1.x, R0.w, R1, R0;
MULR  R1.y, R0.z, c[28];
ADDR  R0.xyz, R5, -c[8];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.x, -R2.w, R0;
MULR  R0.x, R0, c[21].y;
MADR  R0.x, R0, c[31].y, -c[31];
MULR  R0.x, |R0|, |R0|;
MULR  R0.x, R0, R0;
MULR  R0.y, R0.x, R0.x;
MULR  R0.x, R0.y, R0;
MADR  R1.y, -R0.x, R1, R1;
ADDR  R0.xyz, R6, -c[8];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.x, -R2.w, R0;
MULR  R0.x, R0, c[21].y;
MADR  R0.x, R0, c[31].y, -c[31];
MULR  R0.x, |R0|, |R0|;
MULR  R0.x, R0, R0;
MULR  R0.y, R0.x, R0.x;
MULR  R0.x, R0.y, R0;
MULR  R1.x, R1, c[28].y;
MADR  R0.x, -R0, R1, R1;
ADDR  R0.y, R1, c[24].x;
MULR_SAT R0.y, R1.w, R0;
ADDR  R0.x, R0, c[24];
MULR_SAT R0.x, R1.w, R0;
MULR  R0.y, R0, -c[29].x;
MULR  R0.y, R0, R3.w;
POWR  R1.x, c[32].x, R0.y;
MULR  R0.x, R0, -c[29];
MULR  R0.x, R3.w, R0;
POWR  R0.x, c[32].x, R0.x;
MULR  R1.y, R1.x, R0.x;
FLRR  R0.z, R19.w;
MADR  R0.x, R0.z, c[33].z, R19.z;
ADDR  R0.x, R0, c[32].z;
FLRR  R1.z, R12.w;
FLRR  R5.x, R11.w;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R16.w;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R0.z, R19.w, -R0;
MADR  R0.z, R0, R0.y, R0.x;
MADR  R0.x, R1.z, c[33].z, R12.z;
ADDR  R0.x, R0, c[32].z;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R12;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R1.z, R12.w, -R1;
MADR  R1.z, R1, R0.y, R0.x;
MADR  R0.x, R5, c[33].z, R11.z;
ADDR  R0.x, R0, c[32].z;
ADDR  R5.x, R11.w, -R5;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R11;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R5.y, R5.x, R0, R0.x;
FLRR  R5.x, R10.w;
MADR  R0.x, R5, c[33].z, R10.z;
ADDR  R0.x, R0, c[32].z;
ADDR  R5.x, R10.w, -R5;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R10;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R5, R0.y, R0;
MADR  R0.x, R5.y, c[28], R0;
MADR  R0.x, R4.w, R1.z, R0;
MADR  R0.x, R0.w, R0.z, R0;
MULR  R1.z, R0.x, c[28].y;
ADDR  R0.xyz, R4, -c[8];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.x, -R2.w, R0;
MULR  R0.x, R0, c[21].y;
MADR  R0.x, R0, c[31].y, -c[31];
MULR  R0.x, |R0|, |R0|;
MULR  R0.x, R0, R0;
MULR  R0.y, R0.x, R0.x;
MULR  R0.x, R0.y, R0;
MADR  R0.x, -R0, R1.z, R1.z;
ADDR  R0.x, R0, c[24];
MULR_SAT R0.x, R1.w, R0;
MULR  R0.x, R0, -c[29];
MULR  R0.x, R3.w, R0;
POWR  R0.x, c[32].x, R0.x;
MULR  R4.x, R1.y, R0;
FLRR  R0.z, R19.y;
MADR  R0.x, R0.z, c[33].z, R19;
ADDR  R0.x, R0, c[32].z;
MOVR  R1.z, R4.x;
FLRR  R4.y, R9.w;
FLRR  R4.z, R8.w;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R13.w;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R0.z, R19.y, -R0;
MADR  R0.z, R0, R0.y, R0.x;
MADR  R0.x, R4.y, c[33].z, R9.z;
ADDR  R0.x, R0, c[32].z;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R9;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R4.y, R9.w, -R4;
MADR  R4.y, R4, R0, R0.x;
MADR  R0.x, R4.z, c[33].z, R8.z;
ADDR  R0.x, R0, c[32].z;
ADDR  R4.z, R8.w, -R4;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R8;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R5.x, R4.z, R0.y, R0;
FLRR  R4.z, R7.w;
MADR  R0.x, R4.z, c[33].z, R7.z;
ADDR  R0.x, R0, c[32].z;
MULR  R0.x, R0, c[33].w;
MOVR  R0.y, R7;
TEX   R0.xy, R0, texture[1], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R4.z, R7.w, -R4;
MADR  R0.x, R4.z, R0.y, R0;
MADR  R0.x, R5, c[28], R0;
MADR  R0.x, R4.w, R4.y, R0;
MADR  R0.x, R0.w, R0.z, R0;
MULR  R0.w, R0.x, c[28].y;
ADDR  R0.xyz, R3, -c[8];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.x, -R2.w, R0;
MULR  R0.x, R0, c[21].y;
MADR  R0.x, R0, c[31].y, -c[31];
MULR  R0.x, |R0|, |R0|;
MULR  R0.x, R0, R0;
MULR  R0.y, R0.x, R0.x;
MULR  R0.x, R0.y, R0;
MADR  R0.x, -R0, R0.w, R0.w;
ADDR  R0.x, R0, c[24];
MULR_SAT R0.x, R1.w, R0;
MULR  R0.x, R0, -c[29];
MULR  R0.x, R3.w, R0;
POWR  R0.x, c[32].x, R0.x;
MULR  R1.w, R4.x, R0.x;
MOVR  R0.x, c[0].w;
MOVR  R0.z, c[2].w;
MOVR  R0.y, c[1].w;
MADR  R0.xyz, -R0, c[13].x, R2;
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
ADDR  R0.y, R0.x, -c[25].x;
ADDR  R0.x, c[25].y, -c[25];
RCPR  R0.x, R0.x;
MULR_SAT R0.x, R0.y, R0;
MADR  R0, -R1, R0.x, R0.x;
ADDR  oCol, R1, R0;
ENDIF;
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
Float 13 [_WorldUnit2Kilometer]
Float 14 [_Kilometer2WorldUnit]
Vector 15 [_SunDirection]
Vector 16 [_EnvironmentAngles]
Vector 17 [_NuajLocalCoverageOffset]
Vector 18 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
SetTexture 1 [_NuajTexNoise3D0] 2D
Vector 19 [_BufferInvSize]
Float 20 [_CloudAltitudeKm]
Vector 21 [_CloudThicknessKm]
Float 22 [_CloudLayerIndex]
Float 23 [_NoiseTiling]
Float 24 [_Coverage]
Vector 25 [_HorizonBlend]
Vector 26 [_CloudPosition]
Float 27 [_FrequencyFactor]
Vector 28 [_AmplitudeFactor]
Float 29 [_CloudSigma_t]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c30, -0.50000000, 2.00000000, 1.00000000, 0.00000000
def c31, 3.00000000, 0.15915491, 0.50000000, 2.71828198
def c32, 6.28318501, -3.14159298, -1.00000000, -2.00000000
def c33, 0.25000000, 1000.00000000, 16.00000000, 0.06250000
def c34, 17.00000000, 0.00367647, 2.00000000, -1.00000000
def c35, 250.00000000, 0, 0, 0
dcl_texcoord0 v0.xy
add r1.xy, v0, c30.x
mul r1.xy, r1, c30.y
abs r1.xy, r1
add r1.xy, -r1, c30.z
min r1.x, r1, r1.y
mov r1.y, c19.x
mad r1.x, c31, -r1.y, r1
cmp_pp r1.y, r1.x, c30.z, c30.w
cmp oC0, r1.x, r0, c30.z
if_gt r1.y, c30.w
mad r0.xy, v0, c16.zwzw, c16
mad r0.z, r0.x, c31.y, c31
mad r0.y, r0, c31, c31.z
frc r0.x, r0.y
frc r0.y, r0.z
mad r0.x, r0, c32, c32.y
sincos r1.xy, r0.x
mad r2.y, r0, c32.x, c32
sincos r0.xy, r2.y
mul r3.xyz, r1.x, c9
mul r0.y, r1, r0
mul r0.x, r1.y, r0
mad r3.xyz, r0.y, c10, r3
mov r0.w, c12.x
add r1.w, c20.x, r0
mad r0.xyz, r0.x, c11, r3
mov r1.y, c2.w
mov r1.x, c0.w
mul r1.xz, r1.xyyw, c13.x
mov r1.y, c30.w
add r3.xyz, r1, -c8
dp3 r2.y, r3, r3
dp3 r0.w, r0, r3
mad r2.y, -r1.w, r1.w, r2
mad r2.y, r0.w, r0.w, -r2
rsq r2.z, r2.y
rcp r2.w, r2.z
add r3.x, -r0.w, r2.w
cmp_pp r2.z, r2.y, c30, c30.w
cmp r3.y, r3.x, c30.w, c30.z
mul_pp r3.y, r2.z, r3
cmp_pp r3.z, -r3.y, r2, c30.w
add r2.w, -r0, -r2
mul_pp r0.w, r2.z, r3.z
cmp r3.w, r2.y, r2.x, c30
cmp r2.z, r2.w, c30.w, c30
mul_pp r2.y, r0.w, r2.z
cmp_pp r2.z, -r2.y, r3, c30.w
cmp r3.y, -r3, r3.w, c30.w
cmp r2.y, -r2, r3, r3.x
mul_pp r0.w, r0, r2.z
cmp r0.w, -r0, r2.y, r2
mad r1.xyz, r0.w, r0, r1
add r0.xyz, r1, -c8
dp3 r0.w, r0, r0
dp3 r0.x, r0, c15
mad r0.w, -r1, r1, r0
mad r0.y, r0.x, r0.x, -r0.w
rsq r0.z, r0.y
rcp r0.w, r0.z
add r2.y, -r0.x, r0.w
cmp_pp r0.z, r0.y, c30, c30.w
cmp r2.z, r2.y, c30.w, c30
mul_pp r2.z, r0, r2
cmp r2.x, r0.y, r2, c30.w
cmp_pp r2.w, -r2.z, r0.z, c30
add r0.w, -r0.x, -r0
mul_pp r0.x, r0.z, r2.w
cmp r0.z, r0.w, c30.w, c30
mul_pp r0.y, r0.x, r0.z
cmp_pp r0.z, -r0.y, r2.w, c30.w
cmp r2.x, -r2.z, r2, c30.w
cmp r0.y, -r0, r2.x, r2
mul_pp r0.x, r0, r0.z
cmp r2.w, -r0.x, r0.y, r0
mul r0.xyz, r2.w, c15
mad r4.xyz, r2.w, c15, r1
mul r5.xyz, -r0, c33.x
mad r1.xyz, r5, c31.z, r4
mul r2.xyz, r1.xzyw, c23.x
mad r0.xyz, -r0, c31.z, r4
add r6.xy, r2, c26
mov r6.z, r2
mul r2.xyz, r6, c27.x
mul r0.xyz, r0, c14.x
add r3.xy, r2, c26.zwzw
mov r3.z, r2
mul r2.xyz, r3, c27.x
add r2.xy, r2, c26.zwzw
mul r7.xyz, r2, c27.x
add r8.zw, r2.xyxz, c33.y
mul r8.zw, r8, c33.z
mul r2.xz, r8.zyww, c33.w
abs r2.xz, r2
add r7.xy, r7, c26.zwzw
mov r7.w, r7.z
mov r7.z, r7.x
add r7.zw, r7, c33.y
mul r7.zw, r7, c33.z
mul r8.xy, r7.zwzw, c33.w
abs r8.xy, r8
frc r8.xy, r8
mul r8.xy, r8, c33.z
cmp r7.zw, r7, r8.xyxy, -r8.xyxy
frc r2.xz, r2
mul r8.xy, r2.xzzw, c33.z
cmp r8.xy, r8.zwzw, r8, -r8
frc r3.w, r8.y
frc r0.w, r7
add r2.x, -r0.w, r7.w
mad r2.x, r2, c34, r7.z
add r2.z, -r3.w, r8.y
add r2.x, r2, c33
mad r2.z, r2, c34.x, r8.x
mul r7.x, r2, c34.y
add r2.x, r2.z, c33
mov r7.z, c30.w
texldl r7.xy, r7.xyzz, s1
mul r2.w, r2, c35.x
mov r2.z, c30.w
mul r2.x, r2, c34.y
texldl r2.xy, r2.xyzz, s1
add r2.z, r7.y, -r7.x
add r2.y, r2, -r2.x
mad r4.w, r3, r2.y, r2.x
add r2.xy, r3.xzzw, c33.y
add r3.zw, r6.xyxz, c33.y
mul r6.zw, r3, c33.z
mad r0.w, r0, r2.z, r7.x
mul r7.xy, r6.zwzw, c33.w
mul r2.xy, r2, c33.z
mul r3.zw, r2.xyxy, c33.w
abs r3.zw, r3
abs r7.xy, r7
frc r3.zw, r3
mul r3.zw, r3, c33.z
cmp r2.xy, r2, r3.zwzw, -r3.zwzw
frc r5.w, r2.y
add r2.y, -r5.w, r2
mad r2.x, r2.y, c34, r2
add r2.x, r2, c33
frc r7.xy, r7
mul r7.xy, r7, c33.z
cmp r3.zw, r6, r7.xyxy, -r7.xyxy
frc r6.x, r3.w
add r2.z, -r6.x, r3.w
mad r2.y, r2.z, c34.x, r3.z
mul r3.w, c28.x, c28.x
add r2.y, r2, c33.x
mul r3.x, r2, c34.y
mul r2.x, r2.y, c34.y
mov r3.z, c30.w
texldl r3.xy, r3.xyzz, s1
mov r2.z, c30.w
mov r2.y, r6
texldl r2.xy, r2.xyzz, s1
add r2.z, r2.y, -r2.x
mad r2.z, r6.x, r2, r2.x
add r2.y, r3, -r3.x
mad r2.x, r5.w, r2.y, r3
mad r2.x, r2, c28, r2.z
mad r2.x, r3.w, r4.w, r2
mul r4.w, r3, c28.x
mad r0.w, r4, r0, r2.x
add r2.xyz, r1, -c8
add r6.xyz, r1, r5
mul r1.xyz, r6.xzyw, c23.x
dp3 r3.x, r2, r2
add r1.xy, r1, c26
mul r2.xyz, r1, c27.x
rsq r3.z, r3.x
add r3.xy, r2, c26.zwzw
rcp r2.x, r3.z
add r5.w, -r1, r2.x
mov r3.z, r2
mul r2.xyz, r3, c27.x
add r2.xy, r2, c26.zwzw
mul r8.xyz, r2, c27.x
add r7.zw, r8.xyxy, c26
mov r7.x, r7.z
mov r7.y, r8.z
mul r5.w, r5, c21.y
mad r5.w, r5, c34.z, c34
abs r5.w, r5
mul r5.w, r5, r5
mul r5.w, r5, r5
mul r6.w, r5, r5
add r7.xy, r7, c33.y
mov r7.z, c22.x
add r7.z, c32, r7
mad r5.w, -r6, r5, c30.z
mul r0.w, r0, c28.y
mad r6.w, r0, r5, c24.x
mov r0.w, c30.z
abs r5.w, c22.x
dp4 r8.x, r0, c4
dp4 r8.y, r0, c6
add r0.xy, r8, c30.z
mul r7.xy, r7, c33.z
mul r8.xy, r7, c33.w
abs r8.z, r7
cmp r5.w, -r5, c30.z, c30
abs_pp r7.z, r5.w
cmp r5.w, -r8.z, c30.z, c30
cmp_pp r7.z, -r7, c30, c30.w
mov r8.z, c22.x
mul_pp r8.w, r7.z, r5
abs r8.xy, r8
add r8.z, c32.w, r8
mov r0.z, c30.w
mul r0.xy, r0, c31.z
texldl r0, r0.xyzz, s0
mul r0, r0, c18
add r0, r0, c17
cmp r0.x, -r8.w, r0, r0.y
abs_pp r0.y, r5.w
abs r5.w, r8.z
cmp_pp r0.y, -r0, c30.z, c30.w
mul_pp r0.y, r7.z, r0
cmp r5.w, -r5, c30.z, c30
mul_pp r8.z, r0.y, r5.w
abs_pp r7.z, r5.w
cmp r0.z, -r8, r0.x, r0
cmp_pp r5.w, -r7.z, c30.z, c30
mul_pp r0.x, r0.y, r5.w
cmp r5.w, -r0.x, r0.z, r0
mul_sat r0.z, r5.w, r6.w
frc r0.xy, r8
mul r0.z, r0, -c29.x
mul r0.xy, r0, c33.z
cmp r7.xy, r7, r0, -r0
mul r7.z, r0, r2.w
pow r0, c31.w, r7.z
add r0.zw, r2.xyxz, c33.y
frc r6.w, r7.y
add r0.y, -r6.w, r7
mad r0.y, r0, c34.x, r7.x
mul r0.zw, r0, c33.z
add r0.y, r0, c33.x
mul r8.xy, r0.zwzw, c33.w
mul r7.x, r0.y, c34.y
abs r8.xy, r8
mov r7.z, c30.w
mov r7.y, r7.w
texldl r7.xy, r7.xyzz, s1
frc r7.zw, r8.xyxy
add r0.y, r7, -r7.x
mad r0.y, r6.w, r0, r7.x
mul r7.zw, r7, c33.z
cmp r7.xy, r0.zwzw, r7.zwzw, -r7.zwzw
add r0.zw, r3.xyxz, c33.y
frc r3.x, r7.y
add r2.x, -r3, r7.y
mad r2.x, r2, c34, r7
mul r0.zw, r0, c33.z
mul r7.zw, r0, c33.w
abs r7.xy, r7.zwzw
add r2.x, r2, c33
frc r7.xy, r7
mul r7.xy, r7, c33.z
cmp r0.zw, r0, r7.xyxy, -r7.xyxy
frc r6.w, r0
add r0.w, -r6, r0
mov r2.z, c30.w
mul r2.x, r2, c34.y
texldl r2.xy, r2.xyzz, s1
add r2.y, r2, -r2.x
mad r3.z, r3.x, r2.y, r2.x
add r2.xy, r1.xzzw, c33.y
mad r1.x, r0.w, c34, r0.z
mul r0.zw, r2.xyxy, c33.z
add r1.x, r1, c33
mul r7.xy, r0.zwzw, c33.w
abs r7.xy, r7
mov r2.y, r3
frc r3.xy, r7
mul r3.xy, r3, c33.z
cmp r0.zw, r0, r3.xyxy, -r3.xyxy
frc r3.x, r0.w
add r0.w, -r3.x, r0
mad r0.z, r0.w, c34.x, r0
mul r2.x, r1, c34.y
mov r2.z, c30.w
texldl r2.xy, r2.xyzz, s1
add r1.x, r2.y, -r2
mad r6.w, r6, r1.x, r2.x
add r2.xyz, r6, -c8
dp3 r1.x, r2, r2
rsq r1.x, r1.x
rcp r0.w, r1.x
add r0.z, r0, c33.x
add r0.w, -r1, r0
mul r1.x, r0.z, c34.y
mul r0.z, r0.w, c21.y
mov r1.z, c30.w
mad r0.w, r0.z, c34.z, c34
texldl r1.xy, r1.xyzz, s1
add r0.z, r1.y, -r1.x
mad r0.z, r3.x, r0, r1.x
mad r0.z, r6.w, c28.x, r0
mad r0.z, r3.w, r3, r0
mad r0.y, r4.w, r0, r0.z
abs r0.w, r0
mul r0.w, r0, r0
mul r0.w, r0, r0
mul r1.x, r0.w, r0.w
add r3.xyz, r5, r6
mad r0.z, -r1.x, r0.w, c30
mul r1.xyz, r3.xzyw, c23.x
mul r0.y, r0, c28
mad r0.y, r0, r0.z, c24.x
mov r7.x, r0
mul_sat r0.y, r5.w, r0
mul r0.x, r0.y, -c29
mul r2.x, r2.w, r0
pow r0, c31.w, r2.x
mov r0.w, r0.x
mul r0.w, r7.x, r0
add r2.xy, r1, c26
mov r2.z, r1
mul r1.xyz, r2, c27.x
add r1.xy, r1, c26.zwzw
mul r6.xyz, r1, c27.x
add r0.xy, r6, c26.zwzw
mov r0.z, r6
mul r6.xyz, r0, c27.x
add r8.xy, r0.xzzw, c33.y
mul r8.xy, r8, c33.z
mul r8.zw, r8.xyxy, c33.w
abs r8.zw, r8
add r6.xy, r6, c26.zwzw
mov r6.w, r6.z
mov r6.z, r6.x
add r6.zw, r6, c33.y
mul r6.zw, r6, c33.z
mul r7.zw, r6, c33.w
abs r7.zw, r7
frc r7.zw, r7
mul r7.zw, r7, c33.z
cmp r6.zw, r6, r7, -r7
frc r8.zw, r8
mul r7.zw, r8, c33.z
frc r8.z, r6.w
add r0.x, -r8.z, r6.w
mad r0.x, r0, c34, r6.z
cmp r7.zw, r8.xyxy, r7, -r7
frc r6.w, r7
add r0.z, -r6.w, r7.w
add r0.x, r0, c33
mad r0.z, r0, c34.x, r7
mul r6.x, r0, c34.y
add r0.x, r0.z, c33
mov r6.z, c30.w
texldl r6.xy, r6.xyzz, s1
mov r7.y, r0.w
mov r0.z, c30.w
mul r0.x, r0, c34.y
texldl r0.xy, r0.xyzz, s1
add r0.z, r6.y, -r6.x
mad r8.x, r8.z, r0.z, r6
add r0.y, r0, -r0.x
mad r8.y, r6.w, r0, r0.x
add r0.xy, r1.xzzw, c33.y
add r6.xy, r2.xzzw, c33.y
mul r6.zw, r6.xyxy, c33.z
mul r0.xy, r0, c33.z
mul r6.xy, r0, c33.w
mul r7.zw, r6, c33.w
abs r6.xy, r6
abs r7.zw, r7
frc r6.xy, r6
mul r6.xy, r6, c33.z
cmp r0.xy, r0, r6, -r6
frc r2.x, r0.y
add r0.y, -r2.x, r0
mad r0.x, r0.y, c34, r0
add r0.x, r0, c33
frc r7.zw, r7
mul r7.zw, r7, c33.z
cmp r6.xy, r6.zwzw, r7.zwzw, -r7.zwzw
frc r2.z, r6.y
add r0.z, -r2, r6.y
mad r0.y, r0.z, c34.x, r6.x
add r0.y, r0, c33.x
mul r1.x, r0, c34.y
mul r0.x, r0.y, c34.y
mov r1.z, c30.w
texldl r1.xy, r1.xyzz, s1
mov r0.z, c30.w
mov r0.y, r2
texldl r0.xy, r0.xyzz, s1
add r0.z, r0.y, -r0.x
mad r0.z, r2, r0, r0.x
add r0.y, r1, -r1.x
mad r0.x, r2, r0.y, r1
add r2.xyz, r5, r3
add r3.xyz, r3, -c8
mad r0.x, r0, c28, r0.z
mad r1.x, r3.w, r8.y, r0
mul r0.xyz, r2.xzyw, c23.x
mad r5.x, r4.w, r8, r1
dp3 r3.x, r3, r3
rsq r6.x, r3.x
rcp r6.x, r6.x
add r1.xy, r0, c26
mov r1.z, r0
mul r0.xyz, r1, c27.x
add r0.xy, r0, c26.zwzw
mul r7.z, r5.x, c28.y
mul r5.xyz, r0, c27.x
add r5.xy, r5, c26.zwzw
mul r3.xyz, r5, c27.x
add r3.xy, r3, c26.zwzw
add r6.y, -r1.w, r6.x
mov r6.x, r3
mul r3.x, r6.y, c21.y
mov r6.y, r3.z
mad r3.x, r3, c34.z, c34.w
add r6.xy, r6, c33.y
mul r6.xy, r6, c33.z
mul r6.zw, r6.xyxy, c33.w
abs r3.x, r3
mul r3.x, r3, r3
mul r3.x, r3, r3
mul r3.z, r3.x, r3.x
mad r3.x, -r3.z, r3, c30.z
mad r3.x, r7.z, r3, c24
mul_sat r3.x, r5.w, r3
abs r6.zw, r6
frc r6.zw, r6
mul r6.zw, r6, c33.z
cmp r6.xy, r6, r6.zwzw, -r6.zwzw
frc r7.w, r6.y
mul r7.z, r3.x, -c29.x
add r3.x, -r7.w, r6.y
mad r3.x, r3, c34, r6
add r6.zw, r5.xyxz, c33.y
mul r6.xy, r6.zwzw, c33.z
mul r6.zw, r6.xyxy, c33.w
add r3.x, r3, c33
abs r6.zw, r6
frc r6.zw, r6
mov r3.z, c30.w
mul r3.x, r3, c34.y
texldl r3.xy, r3.xyzz, s1
add r3.y, r3, -r3.x
mad r5.x, r7.w, r3.y, r3
mul r6.zw, r6, c33.z
cmp r3.xy, r6, r6.zwzw, -r6.zwzw
add r6.xy, r0.xzzw, c33.y
frc r0.x, r3.y
add r0.z, -r0.x, r3.y
mad r0.z, r0, c34.x, r3.x
mul r6.xy, r6, c33.z
mul r6.zw, r6.xyxy, c33.w
abs r3.xy, r6.zwzw
frc r6.zw, r3.xyxy
add r0.z, r0, c33.x
mul r6.zw, r6, c33.z
cmp r6.xy, r6, r6.zwzw, -r6.zwzw
mov r3.y, r5
frc r5.y, r6
mul r3.x, r0.z, c34.y
mov r3.z, c30.w
texldl r3.xy, r3.xyzz, s1
add r0.z, r3.y, -r3.x
mad r3.z, r0.x, r0, r3.x
add r3.xy, r1.xzzw, c33.y
add r0.x, -r5.y, r6.y
mad r0.x, r0, c34, r6
mul r3.xy, r3, c33.z
mul r6.xy, r3, c33.w
add r0.x, r0, c33
abs r6.xy, r6
frc r6.xy, r6
mul r6.xy, r6, c33.z
cmp r3.xy, r3, r6, -r6
frc r1.z, r3.y
mov r0.z, c30.w
mul r0.x, r0, c34.y
texldl r0.xy, r0.xyzz, s1
add r0.y, r0, -r0.x
mad r1.x, r5.y, r0.y, r0
add r0.xyz, r2, -c8
dp3 r0.y, r0, r0
add r0.x, -r1.z, r3.y
rsq r0.y, r0.y
mad r0.x, r0, c34, r3
rcp r0.y, r0.y
add r0.y, -r1.w, r0
mul r1.w, r0.y, c21.y
add r0.x, r0, c33
mov r0.z, c30.w
mov r0.y, r1
mul r0.x, r0, c34.y
texldl r0.xy, r0.xyzz, s1
add r0.y, r0, -r0.x
mad r0.x, r1.z, r0.y, r0
mad r0.z, r1.w, c34, c34.w
abs r0.z, r0
mul r0.y, r0.z, r0.z
mad r0.x, r1, c28, r0
mul r0.y, r0, r0
mul r0.z, r0.y, r0.y
mad r0.y, -r0.z, r0, c30.z
mad r0.x, r3.w, r3.z, r0
mad r0.x, r4.w, r5, r0
mul r0.x, r0, c28.y
mad r0.y, r0.x, r0, c24.x
mul r0.x, r2.w, r7.z
pow r1, c31.w, r0.x
mul_sat r0.y, r5.w, r0
mul r0.x, r0.y, -c29
mul r0.y, r2.w, r0.x
mov r0.x, r1
mul r0.w, r0, r0.x
pow r1, c31.w, r0.y
add r1.y, c25, -c25.x
mul r7.w, r0, r1.x
mov r7.z, r0.w
mov r0.x, c0.w
mov r0.z, c2.w
mov r0.y, c1.w
mad r0.xyz, -r0, c13.x, r4
dp3 r1.x, r0, r0
rsq r1.x, r1.x
rcp r1.x, r1.x
add r0, -r7, c30.z
rcp r1.y, r1.y
add r1.x, r1, -c25
mul_sat r1.x, r1, r1.y
mad oC0, r1.x, r0, r7
endif

"
}

}

		}
	}
	Fallback off
}
