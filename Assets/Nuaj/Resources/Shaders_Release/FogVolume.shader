// This shader renders low-frequency volumetric fog
//
Shader "Hidden/Nuaj/Fog"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownScaledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSky( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSun( "Base (RGB)", 2D ) = "white" {}
		_TexLayeredDensity( "Base (RGB)", 2D ) = "white" {}
		_TexDensity( "Base (RGB)", 2D ) = "white" {}
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
		ColorMask RGBA		// Write ALL


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 Computes fog shadowing for layer 0
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
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 18 [_NoiseTiling]
Float 19 [_NoiseAmplitude]
Float 20 [_NoiseOffset]
Vector 21 [_NoisePosition]
Float 22 [_MieDensityFactor]
Float 23 [_DensityRatioBottom]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[26] = { program.local[0..23],
		{ 2.718282, 0, 1, 3 },
		{ 0.33329999, 0.5, 2, 0.0099999998 } };
TEMP R0;
TEMP R1;
TEMP R2;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R1.zw, c[24].xyyz;
MOVR  R1.xy, fragment.texcoord[0];
DP4R  R0.z, R1, c[2];
DP4R  R0.x, R1, c[0];
DP4R  R0.y, R1, c[1];
ADDR  R1.xyz, R0, -c[8];
DP3R  R2.x, R1, c[12];
MOVR  R1.w, c[14].x;
DP3R  R1.x, R1, R1;
ADDR  R1.w, R1, c[10].x;
MADR  R1.y, -R1.w, R1.w, R1.x;
MULR  R2.y, R2.x, R2.x;
SGER  H0.z, R2.y, R1.y;
MOVR  R1.x, c[24].y;
SLTRC HC.x, R2.y, R1.y;
MOVR  R1.x(EQ), R0.w;
ADDR  R0.w, R2.y, -R1.y;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
SLTR  H0.x, -R2, -R0.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[24];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.x(NE), c[24].y;
SLTR  H0.z, -R2.x, R0.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.x(NE), -R2, R0.w;
MOVX  H0.x(NE), c[24].y;
MULXC HC.x, H0.y, H0;
ADDR  R1.x(NE), -R2, -R0.w;
MADR  R1.xyz, R1.x, c[12], R0;
MULR  R0.xyz, R1, c[11].x;
MOVR  R0.w, c[24].z;
ADDR  R1.xyz, R1, -c[8];
DP3R  R1.x, R1, R1;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R1.w, R1.x, -R1;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[25].y, c[25].y;
RCPR  R1.x, c[15].x;
MULR_SAT R2.x, R1.w, R1;
MULR  R1.x, R2, R2;
TEX   R0, R0, texture[1], 2D;
ADDR  R0, R0, c[16];
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R0, R0, c[17];
MADR  R0, -R1.x, R0, R0;
ADDR  R1.xyz, R0.zxyw, -R0.wyzw;
MULR  R0.x, R2, c[24].w;
ADDR_SAT R2.x, -R0, c[25].z;
MULR  R1.z, R1, R2.x;
MADR  R0.z, R1, c[25].y, R0;
MULR  R0.z, R2.x, R0;
ADDR_SAT R2.xy, -R0.x, c[24].wzzw;
MULR  R1.xy, R2, R1;
MADR  R1.xy, R1.yxzw, c[25].y, R0.ywzw;
MADR  R0.y, R2, R1.x, R0.z;
MADR  R0.y, R2.x, R1, R0;
MOVR  R1.xyz, c[9];
DP3R  R0.w, R1, c[12];
MAXR  R0.w, R0, c[25];
MULR  R0.x, R0, c[25];
MADR  R0.x, R0, -c[23], R0;
ADDR  R0.x, R0, c[23];
ADDR  R0.z, -R1.w, c[15].x;
RCPR  R0.w, R0.w;
MULR  R0.z, R0, R0.w;
MULR  R0.y, R0, R0.z;
MULR  R0.x, R0, c[22];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[13];
POWR  oCol, c[24].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Float 18 [_MieDensityFactor]
Float 19 [_DensityRatioBottom]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c20, 0.00000000, 1.00000000, 3.00000000, 0.33329999
def c21, 0.50000000, 2.00000000, 0.01000000, 2.71828198
dcl_texcoord0 v0.xy
mov r0.w, c10.x
mov r1.zw, c20.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r1.w, r1, r1
add r0.w, c14.x, r0
dp3 r2.z, r1, c12
mad r1.w, -r0, r0, r1
mad r1.x, r2.z, r2.z, -r1.w
rsq r1.y, r1.x
rcp r2.w, r1.y
add r1.y, -r2.z, r2.w
add r2.z, -r2, -r2.w
cmp_pp r2.y, r1.x, c20, c20.x
cmp r1.z, r1.y, c20.x, c20.y
mul_pp r1.z, r2.y, r1
cmp_pp r1.w, -r1.z, r2.y, c20.x
cmp r2.x, r1, r2, c20
mul_pp r2.y, r2, r1.w
cmp r2.w, r2.z, c20.x, c20.y
mul_pp r1.x, r2.y, r2.w
cmp r2.x, -r1.z, r2, c20
cmp_pp r1.z, -r1.x, r1.w, c20.x
cmp r1.y, -r1.x, r2.x, r1
mul_pp r1.x, r2.y, r1.z
cmp r1.x, -r1, r1.y, r2.z
mad r0.xyz, r1.x, c12, r0
add r1.xyz, r0, -c8
dp3 r1.x, r1, r1
rsq r2.x, r1.x
mul r1.xyz, r0, c11.x
mov r1.w, c20.y
dp4 r0.x, r1, c4
dp4 r0.y, r1, c6
rcp r0.z, r2.x
add r1.x, r0.z, -r0.w
add r0.xy, r0, c20.y
rcp r1.y, c15.x
mul_sat r1.y, r1.x, r1
mul r0.w, r1.y, r1.y
mul r1.z, r0.w, r0.w
mul r1.z, r1, r1
mul r1.y, r1, c20.z
mad r1.z, -r1, r1, c20.y
mul r0.xy, r0, c21.x
mov r0.z, c20.x
texldl r0, r0.xyzz, s1
add r0, r0, c16
mul r0, r0, c17
mul r0, r0, r1.z
add r1.w, r0.y, -r0.z
add_sat r1.z, -r1.y, c21.y
mul r2.x, r1.z, r1.w
mad r2.x, r2, c21, r0.z
add r1.w, r0.x, -r0.y
add_sat r0.x, -r1.y, c20.y
mul r1.w, r0.x, r1
mad r1.w, r1, c21.x, r0.y
mul r1.z, r1, r2.x
add r0.z, r0, -r0.w
add_sat r0.y, -r1, c20.z
mad r1.z, r0.x, r1.w, r1
mul r0.z, r0.y, r0
mad r0.x, r0.z, c21, r0.w
mad r0.w, r0.y, r0.x, r1.z
mov r0.xyz, c12
dp3 r0.y, c9, r0
max r0.y, r0, c21.z
rcp r0.z, r0.y
add r0.y, -r1.x, c15.x
mul r0.y, r0, r0.z
mov r1.z, c19.x
add r1.z, c20.y, -r1
mul r0.x, r1.y, r1.z
mul r0.x, r0, c20.w
add r0.x, r0, c19
mul r0.y, r0.w, r0
mul r0.x, r0, c18
mul r0.x, r0, r0.y
mul r1.x, r0, -c13
pow r0, c21.w, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 Computes fog shadowing for layer 1
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
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 18 [_NoiseTiling]
Float 19 [_NoiseAmplitude]
Float 20 [_NoiseOffset]
Vector 21 [_NoisePosition]
Float 22 [_MieDensityFactor]
Float 23 [_DensityRatioBottom]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[26] = { program.local[0..23],
		{ 2.718282, 0, 1, 3 },
		{ 0.33329999, 0.5, 2, 0.0099999998 } };
TEMP R0;
TEMP R1;
TEMP R2;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R1.zw, c[24].xyyz;
MOVR  R1.xy, fragment.texcoord[0];
DP4R  R0.z, R1, c[2];
DP4R  R0.x, R1, c[0];
DP4R  R0.y, R1, c[1];
ADDR  R1.xyz, R0, -c[8];
DP3R  R2.x, R1, c[12];
MOVR  R1.w, c[14].x;
DP3R  R1.x, R1, R1;
ADDR  R1.w, R1, c[10].x;
MADR  R1.y, -R1.w, R1.w, R1.x;
MULR  R2.y, R2.x, R2.x;
SGER  H0.z, R2.y, R1.y;
MOVR  R1.x, c[24].y;
SLTRC HC.x, R2.y, R1.y;
MOVR  R1.x(EQ), R0.w;
ADDR  R0.w, R2.y, -R1.y;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
SLTR  H0.x, -R2, -R0.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[24];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.x(NE), c[24].y;
SLTR  H0.z, -R2.x, R0.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.x(NE), -R2, R0.w;
MOVX  H0.x(NE), c[24].y;
MULXC HC.x, H0.y, H0;
ADDR  R1.x(NE), -R2, -R0.w;
MADR  R1.xyz, R1.x, c[12], R0;
MULR  R0.xyz, R1, c[11].x;
MOVR  R0.w, c[24].z;
ADDR  R1.xyz, R1, -c[8];
DP3R  R1.x, R1, R1;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R1.w, R1.x, -R1;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[25].y, c[25].y;
RCPR  R1.x, c[15].x;
MULR_SAT R2.x, R1.w, R1;
MULR  R1.x, R2, R2;
TEX   R0, R0, texture[1], 2D;
ADDR  R0, R0, c[16];
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R0, R0, c[17];
MADR  R0, -R1.x, R0, R0;
ADDR  R1.xyz, R0.zxyw, -R0.wyzw;
MULR  R0.x, R2, c[24].w;
ADDR_SAT R2.x, -R0, c[25].z;
MULR  R1.z, R1, R2.x;
MADR  R0.z, R1, c[25].y, R0;
MULR  R0.z, R2.x, R0;
ADDR_SAT R2.xy, -R0.x, c[24].wzzw;
MULR  R1.xy, R2, R1;
MADR  R1.xy, R1.yxzw, c[25].y, R0.ywzw;
MADR  R0.y, R2, R1.x, R0.z;
MADR  R0.y, R2.x, R1, R0;
MOVR  R1.xyz, c[9];
DP3R  R0.w, R1, c[12];
MAXR  R0.w, R0, c[25];
MULR  R0.x, R0, c[25];
MADR  R0.x, R0, -c[23], R0;
ADDR  R0.x, R0, c[23];
ADDR  R0.z, -R1.w, c[15].x;
RCPR  R0.w, R0.w;
MULR  R0.z, R0, R0.w;
MULR  R0.y, R0, R0.z;
MULR  R0.x, R0, c[22];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[13];
POWR  oCol, c[24].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Float 18 [_MieDensityFactor]
Float 19 [_DensityRatioBottom]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c20, 0.00000000, 1.00000000, 3.00000000, 0.33329999
def c21, 0.50000000, 2.00000000, 0.01000000, 2.71828198
dcl_texcoord0 v0.xy
mov r0.w, c10.x
mov r1.zw, c20.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r1.w, r1, r1
add r0.w, c14.x, r0
dp3 r2.z, r1, c12
mad r1.w, -r0, r0, r1
mad r1.x, r2.z, r2.z, -r1.w
rsq r1.y, r1.x
rcp r2.w, r1.y
add r1.y, -r2.z, r2.w
add r2.z, -r2, -r2.w
cmp_pp r2.y, r1.x, c20, c20.x
cmp r1.z, r1.y, c20.x, c20.y
mul_pp r1.z, r2.y, r1
cmp_pp r1.w, -r1.z, r2.y, c20.x
cmp r2.x, r1, r2, c20
mul_pp r2.y, r2, r1.w
cmp r2.w, r2.z, c20.x, c20.y
mul_pp r1.x, r2.y, r2.w
cmp r2.x, -r1.z, r2, c20
cmp_pp r1.z, -r1.x, r1.w, c20.x
cmp r1.y, -r1.x, r2.x, r1
mul_pp r1.x, r2.y, r1.z
cmp r1.x, -r1, r1.y, r2.z
mad r0.xyz, r1.x, c12, r0
add r1.xyz, r0, -c8
dp3 r1.x, r1, r1
rsq r2.x, r1.x
mul r1.xyz, r0, c11.x
mov r1.w, c20.y
dp4 r0.x, r1, c4
dp4 r0.y, r1, c6
rcp r0.z, r2.x
add r1.x, r0.z, -r0.w
add r0.xy, r0, c20.y
rcp r1.y, c15.x
mul_sat r1.y, r1.x, r1
mul r0.w, r1.y, r1.y
mul r1.z, r0.w, r0.w
mul r1.z, r1, r1
mul r1.y, r1, c20.z
mad r1.z, -r1, r1, c20.y
mul r0.xy, r0, c21.x
mov r0.z, c20.x
texldl r0, r0.xyzz, s1
add r0, r0, c16
mul r0, r0, c17
mul r0, r0, r1.z
add r1.w, r0.y, -r0.z
add_sat r1.z, -r1.y, c21.y
mul r2.x, r1.z, r1.w
mad r2.x, r2, c21, r0.z
add r1.w, r0.x, -r0.y
add_sat r0.x, -r1.y, c20.y
mul r1.w, r0.x, r1
mad r1.w, r1, c21.x, r0.y
mul r1.z, r1, r2.x
add r0.z, r0, -r0.w
add_sat r0.y, -r1, c20.z
mad r1.z, r0.x, r1.w, r1
mul r0.z, r0.y, r0
mad r0.x, r0.z, c21, r0.w
mad r0.w, r0.y, r0.x, r1.z
mov r0.xyz, c12
dp3 r0.y, c9, r0
max r0.y, r0, c21.z
rcp r0.z, r0.y
add r0.y, -r1.x, c15.x
mul r0.y, r0, r0.z
mov r1.z, c19.x
add r1.z, c20.y, -r1
mul r0.x, r1.y, r1.z
mul r0.x, r0, c20.w
add r0.x, r0, c19
mul r0.y, r0.w, r0
mul r0.x, r0, c18
mul r0.x, r0, r0.y
mul r1.x, r0, -c13
pow r0, c21.w, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 Computes fog shadowing for layer 2
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
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 18 [_NoiseTiling]
Float 19 [_NoiseAmplitude]
Float 20 [_NoiseOffset]
Vector 21 [_NoisePosition]
Float 22 [_MieDensityFactor]
Float 23 [_DensityRatioBottom]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[26] = { program.local[0..23],
		{ 2.718282, 0, 1, 3 },
		{ 0.33329999, 0.5, 2, 0.0099999998 } };
TEMP R0;
TEMP R1;
TEMP R2;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R1.zw, c[24].xyyz;
MOVR  R1.xy, fragment.texcoord[0];
DP4R  R0.z, R1, c[2];
DP4R  R0.x, R1, c[0];
DP4R  R0.y, R1, c[1];
ADDR  R1.xyz, R0, -c[8];
DP3R  R2.x, R1, c[12];
MOVR  R1.w, c[14].x;
DP3R  R1.x, R1, R1;
ADDR  R1.w, R1, c[10].x;
MADR  R1.y, -R1.w, R1.w, R1.x;
MULR  R2.y, R2.x, R2.x;
SGER  H0.z, R2.y, R1.y;
MOVR  R1.x, c[24].y;
SLTRC HC.x, R2.y, R1.y;
MOVR  R1.x(EQ), R0.w;
ADDR  R0.w, R2.y, -R1.y;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
SLTR  H0.x, -R2, -R0.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[24];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.x(NE), c[24].y;
SLTR  H0.z, -R2.x, R0.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.x(NE), -R2, R0.w;
MOVX  H0.x(NE), c[24].y;
MULXC HC.x, H0.y, H0;
ADDR  R1.x(NE), -R2, -R0.w;
MADR  R1.xyz, R1.x, c[12], R0;
MULR  R0.xyz, R1, c[11].x;
MOVR  R0.w, c[24].z;
ADDR  R1.xyz, R1, -c[8];
DP3R  R1.x, R1, R1;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R1.w, R1.x, -R1;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[25].y, c[25].y;
RCPR  R1.x, c[15].x;
MULR_SAT R2.x, R1.w, R1;
MULR  R1.x, R2, R2;
TEX   R0, R0, texture[1], 2D;
ADDR  R0, R0, c[16];
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R0, R0, c[17];
MADR  R0, -R1.x, R0, R0;
ADDR  R1.xyz, R0.zxyw, -R0.wyzw;
MULR  R0.x, R2, c[24].w;
ADDR_SAT R2.x, -R0, c[25].z;
MULR  R1.z, R1, R2.x;
MADR  R0.z, R1, c[25].y, R0;
MULR  R0.z, R2.x, R0;
ADDR_SAT R2.xy, -R0.x, c[24].wzzw;
MULR  R1.xy, R2, R1;
MADR  R1.xy, R1.yxzw, c[25].y, R0.ywzw;
MADR  R0.y, R2, R1.x, R0.z;
MADR  R0.y, R2.x, R1, R0;
MOVR  R1.xyz, c[9];
DP3R  R0.w, R1, c[12];
MAXR  R0.w, R0, c[25];
MULR  R0.x, R0, c[25];
MADR  R0.x, R0, -c[23], R0;
ADDR  R0.x, R0, c[23];
ADDR  R0.z, -R1.w, c[15].x;
RCPR  R0.w, R0.w;
MULR  R0.z, R0, R0.w;
MULR  R0.y, R0, R0.z;
MULR  R0.x, R0, c[22];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[13];
POWR  oCol, c[24].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Float 18 [_MieDensityFactor]
Float 19 [_DensityRatioBottom]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c20, 0.00000000, 1.00000000, 3.00000000, 0.33329999
def c21, 0.50000000, 2.00000000, 0.01000000, 2.71828198
dcl_texcoord0 v0.xy
mov r0.w, c10.x
mov r1.zw, c20.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r1.w, r1, r1
add r0.w, c14.x, r0
dp3 r2.z, r1, c12
mad r1.w, -r0, r0, r1
mad r1.x, r2.z, r2.z, -r1.w
rsq r1.y, r1.x
rcp r2.w, r1.y
add r1.y, -r2.z, r2.w
add r2.z, -r2, -r2.w
cmp_pp r2.y, r1.x, c20, c20.x
cmp r1.z, r1.y, c20.x, c20.y
mul_pp r1.z, r2.y, r1
cmp_pp r1.w, -r1.z, r2.y, c20.x
cmp r2.x, r1, r2, c20
mul_pp r2.y, r2, r1.w
cmp r2.w, r2.z, c20.x, c20.y
mul_pp r1.x, r2.y, r2.w
cmp r2.x, -r1.z, r2, c20
cmp_pp r1.z, -r1.x, r1.w, c20.x
cmp r1.y, -r1.x, r2.x, r1
mul_pp r1.x, r2.y, r1.z
cmp r1.x, -r1, r1.y, r2.z
mad r0.xyz, r1.x, c12, r0
add r1.xyz, r0, -c8
dp3 r1.x, r1, r1
rsq r2.x, r1.x
mul r1.xyz, r0, c11.x
mov r1.w, c20.y
dp4 r0.x, r1, c4
dp4 r0.y, r1, c6
rcp r0.z, r2.x
add r1.x, r0.z, -r0.w
add r0.xy, r0, c20.y
rcp r1.y, c15.x
mul_sat r1.y, r1.x, r1
mul r0.w, r1.y, r1.y
mul r1.z, r0.w, r0.w
mul r1.z, r1, r1
mul r1.y, r1, c20.z
mad r1.z, -r1, r1, c20.y
mul r0.xy, r0, c21.x
mov r0.z, c20.x
texldl r0, r0.xyzz, s1
add r0, r0, c16
mul r0, r0, c17
mul r0, r0, r1.z
add r1.w, r0.y, -r0.z
add_sat r1.z, -r1.y, c21.y
mul r2.x, r1.z, r1.w
mad r2.x, r2, c21, r0.z
add r1.w, r0.x, -r0.y
add_sat r0.x, -r1.y, c20.y
mul r1.w, r0.x, r1
mad r1.w, r1, c21.x, r0.y
mul r1.z, r1, r2.x
add r0.z, r0, -r0.w
add_sat r0.y, -r1, c20.z
mad r1.z, r0.x, r1.w, r1
mul r0.z, r0.y, r0
mad r0.x, r0.z, c21, r0.w
mad r0.w, r0.y, r0.x, r1.z
mov r0.xyz, c12
dp3 r0.y, c9, r0
max r0.y, r0, c21.z
rcp r0.z, r0.y
add r0.y, -r1.x, c15.x
mul r0.y, r0, r0.z
mov r1.z, c19.x
add r1.z, c20.y, -r1
mul r0.x, r1.y, r1.z
mul r0.x, r0, c20.w
add r0.x, r0, c19
mul r0.y, r0.w, r0
mul r0.x, r0, c18
mul r0.x, r0, r0.y
mul r1.x, r0, -c13
pow r0, c21.w, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 Computes fog shadowing for layer 3
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
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 18 [_NoiseTiling]
Float 19 [_NoiseAmplitude]
Float 20 [_NoiseOffset]
Vector 21 [_NoisePosition]
Float 22 [_MieDensityFactor]
Float 23 [_DensityRatioBottom]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[26] = { program.local[0..23],
		{ 2.718282, 0, 1, 3 },
		{ 0.33329999, 0.5, 2, 0.0099999998 } };
TEMP R0;
TEMP R1;
TEMP R2;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R1.zw, c[24].xyyz;
MOVR  R1.xy, fragment.texcoord[0];
DP4R  R0.z, R1, c[2];
DP4R  R0.x, R1, c[0];
DP4R  R0.y, R1, c[1];
ADDR  R1.xyz, R0, -c[8];
DP3R  R2.x, R1, c[12];
MOVR  R1.w, c[14].x;
DP3R  R1.x, R1, R1;
ADDR  R1.w, R1, c[10].x;
MADR  R1.y, -R1.w, R1.w, R1.x;
MULR  R2.y, R2.x, R2.x;
SGER  H0.z, R2.y, R1.y;
MOVR  R1.x, c[24].y;
SLTRC HC.x, R2.y, R1.y;
MOVR  R1.x(EQ), R0.w;
ADDR  R0.w, R2.y, -R1.y;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
SLTR  H0.x, -R2, -R0.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[24];
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.x(NE), c[24].y;
SLTR  H0.z, -R2.x, R0.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.x(NE), -R2, R0.w;
MOVX  H0.x(NE), c[24].y;
MULXC HC.x, H0.y, H0;
ADDR  R1.x(NE), -R2, -R0.w;
MADR  R1.xyz, R1.x, c[12], R0;
MULR  R0.xyz, R1, c[11].x;
MOVR  R0.w, c[24].z;
ADDR  R1.xyz, R1, -c[8];
DP3R  R1.x, R1, R1;
RSQR  R1.x, R1.x;
RCPR  R1.x, R1.x;
ADDR  R1.w, R1.x, -R1;
DP4R  R2.x, R0, c[4];
DP4R  R2.y, R0, c[6];
MADR  R0.xy, R2, c[25].y, c[25].y;
RCPR  R1.x, c[15].x;
MULR_SAT R2.x, R1.w, R1;
MULR  R1.x, R2, R2;
TEX   R0, R0, texture[1], 2D;
ADDR  R0, R0, c[16];
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R1.x, R1, R1;
MULR  R0, R0, c[17];
MADR  R0, -R1.x, R0, R0;
ADDR  R1.xyz, R0.zxyw, -R0.wyzw;
MULR  R0.x, R2, c[24].w;
ADDR_SAT R2.x, -R0, c[25].z;
MULR  R1.z, R1, R2.x;
MADR  R0.z, R1, c[25].y, R0;
MULR  R0.z, R2.x, R0;
ADDR_SAT R2.xy, -R0.x, c[24].wzzw;
MULR  R1.xy, R2, R1;
MADR  R1.xy, R1.yxzw, c[25].y, R0.ywzw;
MADR  R0.y, R2, R1.x, R0.z;
MADR  R0.y, R2.x, R1, R0;
MOVR  R1.xyz, c[9];
DP3R  R0.w, R1, c[12];
MAXR  R0.w, R0, c[25];
MULR  R0.x, R0, c[25];
MADR  R0.x, R0, -c[23], R0;
ADDR  R0.x, R0, c[23];
ADDR  R0.z, -R1.w, c[15].x;
RCPR  R0.w, R0.w;
MULR  R0.z, R0, R0.w;
MULR  R0.y, R0, R0.z;
MULR  R0.x, R0, c[22];
MULR  R0.x, R0, R0.y;
MULR  R0.x, R0, -c[13];
POWR  oCol, c[24].x, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 8 [_PlanetCenterKm]
Vector 9 [_PlanetNormal]
Float 10 [_PlanetRadiusKm]
Float 11 [_Kilometer2WorldUnit]
Vector 12 [_SunDirection]
Matrix 0 [_NuajShadow2World]
Float 13 [_Sigma_Mie]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 14 [_FogAltitudeKm]
Vector 15 [_FogThicknessKm]
Vector 16 [_DensityOffset]
Vector 17 [_DensityFactor]
Matrix 4 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Float 18 [_MieDensityFactor]
Float 19 [_DensityRatioBottom]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c20, 0.00000000, 1.00000000, 3.00000000, 0.33329999
def c21, 0.50000000, 2.00000000, 0.01000000, 2.71828198
dcl_texcoord0 v0.xy
mov r0.w, c10.x
mov r1.zw, c20.xyxy
mov r1.xy, v0
dp4 r0.z, r1, c2
dp4 r0.x, r1, c0
dp4 r0.y, r1, c1
add r1.xyz, r0, -c8
dp3 r1.w, r1, r1
add r0.w, c14.x, r0
dp3 r2.z, r1, c12
mad r1.w, -r0, r0, r1
mad r1.x, r2.z, r2.z, -r1.w
rsq r1.y, r1.x
rcp r2.w, r1.y
add r1.y, -r2.z, r2.w
add r2.z, -r2, -r2.w
cmp_pp r2.y, r1.x, c20, c20.x
cmp r1.z, r1.y, c20.x, c20.y
mul_pp r1.z, r2.y, r1
cmp_pp r1.w, -r1.z, r2.y, c20.x
cmp r2.x, r1, r2, c20
mul_pp r2.y, r2, r1.w
cmp r2.w, r2.z, c20.x, c20.y
mul_pp r1.x, r2.y, r2.w
cmp r2.x, -r1.z, r2, c20
cmp_pp r1.z, -r1.x, r1.w, c20.x
cmp r1.y, -r1.x, r2.x, r1
mul_pp r1.x, r2.y, r1.z
cmp r1.x, -r1, r1.y, r2.z
mad r0.xyz, r1.x, c12, r0
add r1.xyz, r0, -c8
dp3 r1.x, r1, r1
rsq r2.x, r1.x
mul r1.xyz, r0, c11.x
mov r1.w, c20.y
dp4 r0.x, r1, c4
dp4 r0.y, r1, c6
rcp r0.z, r2.x
add r1.x, r0.z, -r0.w
add r0.xy, r0, c20.y
rcp r1.y, c15.x
mul_sat r1.y, r1.x, r1
mul r0.w, r1.y, r1.y
mul r1.z, r0.w, r0.w
mul r1.z, r1, r1
mul r1.y, r1, c20.z
mad r1.z, -r1, r1, c20.y
mul r0.xy, r0, c21.x
mov r0.z, c20.x
texldl r0, r0.xyzz, s1
add r0, r0, c16
mul r0, r0, c17
mul r0, r0, r1.z
add r1.w, r0.y, -r0.z
add_sat r1.z, -r1.y, c21.y
mul r2.x, r1.z, r1.w
mad r2.x, r2, c21, r0.z
add r1.w, r0.x, -r0.y
add_sat r0.x, -r1.y, c20.y
mul r1.w, r0.x, r1
mad r1.w, r1, c21.x, r0.y
mul r1.z, r1, r2.x
add r0.z, r0, -r0.w
add_sat r0.y, -r1, c20.z
mad r1.z, r0.x, r1.w, r1
mul r0.z, r0.y, r0
mad r0.x, r0.z, c21, r0.w
mad r0.w, r0.y, r0.x, r1.z
mov r0.xyz, c12
dp3 r0.y, c9, r0
max r0.y, r0, c21.z
rcp r0.z, r0.y
add r0.y, -r1.x, c15.x
mul r0.y, r0, r0.z
mov r1.z, c19.x
add r1.z, c20.y, -r1
mul r0.x, r1.y, r1.z
mul r0.x, r0, c20.w
add r0.x, r0, c19
mul r0.y, r0.w, r0
mul r0.x, r0, c18
mul r0.x, r0, r0.y
mul r1.x, r0, -c13
pow r0, c21.w, r1.x
mov oC0, r0.x

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 computes the actual fog lighting
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
Float 16 [_FogAltitudeKm]
Vector 17 [_FogThicknessKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c18, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
add r0.x, -r0, c18.z
mov r0.y, c9.x
mov r0.w, c10.x
add r0.y, c16.x, r0
add r0.w, -c9.x, r0
add r0.y, r0, c17.x
mul r0.x, r0, c18.y
rcp r0.w, r0.w
add r0.y, r0, -c9.x
mul r0.y, r0, r0.w
mov r0.z, c18.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c18.w, r1.x
mov r1.x, r0
pow r0, c18.w, r1.z
mov r1.z, r0
pow r2, c18.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c18.yyzx, s1
mov r1.zw, c18.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c18.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c18.x
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
Vector 12 [_CameraData]
Matrix 0 [_Camera2World]
Vector 13 [_PlanetCenterKm]
Vector 14 [_PlanetNormal]
Float 15 [_PlanetRadiusKm]
Float 16 [_PlanetAtmosphereRadiusKm]
Float 17 [_WorldUnit2Kilometer]
Float 18 [_Kilometer2WorldUnit]
Float 19 [_bComputePlanetShadow]
Vector 20 [_SunColor]
Vector 21 [_SunDirection]
SetTexture 2 [_TexAmbientSky] 2D
Vector 22 [_SoftAmbientSky]
Vector 23 [_AmbientNightSky]
SetTexture 1 [_TexShadowEnvMapSky] 2D
Vector 24 [_NuajLightningPosition00]
Vector 25 [_NuajLightningPosition01]
Vector 26 [_NuajLightningColor0]
Vector 27 [_NuajLightningPosition10]
Vector 28 [_NuajLightningPosition11]
Vector 29 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 30 [_ShadowAltitudesMinKm]
Vector 31 [_ShadowAltitudesMaxKm]
SetTexture 6 [_TexShadowMap] 2D
Vector 32 [_Sigma_Rayleigh]
Float 33 [_DensitySeaLevel_Mie]
Float 34 [_Sigma_Mie]
Float 35 [_MiePhaseAnisotropy]
SetTexture 3 [_TexDensity] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
SetTexture 4 [_NuajTexNoise3D0] 2D
Float 36 [_StepsCount]
Float 37 [_MaxStepSizeKm]
Float 38 [_FogAltitudeKm]
Vector 39 [_FogThicknessKm]
Vector 40 [_DensityOffset]
Vector 41 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 5 [_TexLayeredDensity] 2D
Vector 42 [_NoiseTiling]
Float 43 [_NoiseAmplitude]
Float 44 [_NoiseOffset]
Vector 45 [_NoisePosition]
Vector 46 [_FogColor]
Float 47 [_MieDensityFactor]
Float 48 [_DensityRatioBottom]
Float 49 [_FogMaxDistance]
Float 50 [_IsotropicSkyFactor]
Float 51 [_UseSceneZ]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[60] = { program.local[0..51],
		{ 1, 0.5, 2.718282, 2 },
		{ -1, 0, 0.995, 1000000 },
		{ 1000000, -1000000, 500000, 1.5 },
		{ 0, 1, 3, 0.33329999 },
		{ 255, 0, 1, 1000 },
		{ 16, 0.0625, 17, 0.25 },
		{ 0.0036764706, 0.0099999998, 10, 12.566371 },
		{ 0.60000002, 0.21259999, 0.71520001, 0.0722 } };
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
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R6.xyz, c[12].xyww;
MULR  R0.xy, fragment.texcoord[0], c[12];
MADR  R0.xy, R0, c[52].w, -R6;
MOVR  R0.z, c[53].x;
DP3R  R0.w, R0, R0;
RSQR  R3.z, R0.w;
MULR  R1.xyz, R3.z, R0;
MOVR  R1.w, c[53].y;
MOVR  R0.w, c[38].x;
ADDR  R6.w, R0, c[15].x;
DP4R  R5.z, R1, c[2];
DP4R  R5.y, R1, c[1];
DP4R  R5.x, R1, c[0];
MOVR  R1.xy, c[54];
ADDR  R0.w, R6, c[39].x;
MOVR  R0.x, c[0].w;
MOVR  R0.z, c[2].w;
MOVR  R0.y, c[1].w;
MULR  R0.xyz, R0, c[17].x;
ADDR  R2.xyz, R0, -c[13];
DP3R  R5.w, R5, R2;
DP3R  R6.y, R2, R2;
MULR  R6.x, R5.w, R5.w;
MADR  R2.x, -R0.w, R0.w, R6.y;
SLTRC HC.x, R6, R2;
MOVR  R1.xy(EQ.x), R3;
ADDR  R1.z, R6.x, -R2.x;
RSQR  R1.z, R1.z;
RCPR  R1.w, R1.z;
ADDR  R1.z, -R5.w, -R1.w;
MADR  R2.z, -R6.w, R6.w, R6.y;
SGERC HC.x, R6, R2;
ADDR  R1.w, -R5, R1;
MOVR  R1.xy(NE.x), R1.zwzw;
ADDR  R2.x, R6, -R2.z;
RSQR  R2.x, R2.x;
RCPR  R2.y, R2.x;
ADDR  R2.x, -R5.w, -R2.y;
MOVR  R1.zw, c[54].xyxy;
SLTRC HC.x, R6, R2.z;
MOVR  R1.zw(EQ.x), R3.xyxy;
SGERC HC.x, R6, R2.z;
MOVR  R2.z, R1.x;
ADDR  R2.y, -R5.w, R2;
MOVR  R1.zw(NE.x), R2.xyxy;
RSQR  R1.x, R6.y;
RCPR  R1.x, R1.x;
SGTR  H0.y, R1.x, R0.w;
SLTR  H0.x, R1, R6.w;
SEQX  H0.x, H0, c[53].y;
MULX  H0.z, H0.x, H0.y;
SLTR  H0.w, R1.z, c[54].z;
MULXC HC.x, H0.z, H0.w;
SEQX  H0.y, H0, c[53];
MOVR  R2.x, R1.w;
MOVR  R2.y, R1;
MOVR  R2.w, R1.z;
MOVR  R2.xy(NE.x), R2.zwzw;
SEQX  H0.w, H0, c[53].y;
MULXC HC.x, H0.z, H0.w;
MOVR  R2.xy(NE.x), c[53].yxzw;
MULX  H0.x, H0, H0.y;
SLTR  H0.z, R1, c[53].y;
MULXC HC.x, H0, H0.z;
MOVR  R1.x, c[53].y;
MOVR  R2.xy(NE.x), R1;
SEQX  H0.y, H0.z, c[53];
MOVR  R1.y, R1.z;
MULXC HC.x, H0, H0.y;
MOVR  R1.x, c[53].y;
MOVR  R2.xy(NE.x), R1;
MADR  R1.x, -c[15], c[15], R6.y;
ADDR  R1.z, R6.x, -R1.x;
RSQR  R1.z, R1.z;
MOVR  R1.y, c[53].w;
SLTRC HC.x, R6, R1;
MOVR  R1.y(EQ.x), R3.x;
SGERC HC.x, R6, R1;
RCPR  R1.z, R1.z;
ADDR  R1.y(NE.x), -R5.w, -R1.z;
MOVXC RC.x, R1.y;
TEX   R1.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R1.x, R1, -c[12].w;
MADR  R1.x, R1, c[51], R6.z;
RCPR  R1.z, R3.z;
MOVR  R1.y(LT.x), c[53].w;
MULR  R1.z, R1.x, R1;
MADR  R1.w, -R1.z, c[17].x, R1.y;
MOVR  R1.y, c[53].z;
MULR  R1.y, R1, c[12].w;
SGER  H0.x, R1, R1.y;
MULR  R1.z, R1, c[17].x;
MADR  R1.x, H0, R1.w, R1.z;
MINR  R1.x, R1, R2.y;
MINR  R3.x, R1, c[49];
MAXR  R6.z, R2.x, c[53].y;
MOVR  R2, c[55].xxxy;
SGTRC HC.x, R6.z, R3;
MOVR  R2(EQ.x), R4;
MOVR  R4, R2;
MOVR  R1.x, c[52];
SLTRC HC.x, c[36], R1;
MOVR  R1.xyz, c[14];
DP3R  R1.x, R1, c[21];
MOVR  R1.w, c[36].x;
MOVR  R1.w(NE.x), c[52].x;
MOVR  R2.x, c[15];
ADDR  R2.x, -R2, c[16];
SLERC HC.x, R6.z, R3;
RCPR  R1.y, R2.x;
ADDR  R0.w, R0, -c[15].x;
MULR  R1.y, R0.w, R1;
MADR  R1.x, -R1, c[52].y, c[52].y;
TEX   R2.zw, R1, texture[3], 2D;
MULR  R0.w, R2, c[34].x;
MADR  R1.xyz, R2.z, -c[32], -R0.w;
POWR  R2.x, c[52].z, R1.x;
POWR  R2.y, c[52].z, R1.y;
POWR  R2.z, c[52].z, R1.z;
TEX   R1.xyz, c[52].y, texture[2], 2D;
ADDR  R1.xyz, R1, c[22];
TEX   R0.w, c[52].y, texture[1], 2D;
MOVR  R6.w, R3.x;
MULR  R2.xyz, R2, c[20];
MULR  R1.xyz, R0.w, R1;
IF    NE.x;
ADDR  R3.xyz, R0, -c[13];
MULR  R4.xyz, R3.zxyw, c[21].yzxw;
MADR  R4.xyz, R3.yzxw, c[21].zxyw, -R4;
DP3R  R3.x, R3, c[21];
SLER  H0.x, R3, c[53].y;
DP3R  R0.w, R4, R4;
MULR  R7.xyz, R5.zxyw, c[21].yzxw;
MADR  R7.xyz, R5.yzxw, c[21].zxyw, -R7;
DP3R  R2.w, R4, R7;
DP3R  R4.x, R7, R7;
MADR  R0.w, -c[15].x, c[15].x, R0;
MULR  R4.z, R4.x, R0.w;
MULR  R4.y, R2.w, R2.w;
ADDR  R0.w, R4.y, -R4.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.y, -R2.w, R0.w;
ADDR  R0.w, -R2, -R0;
MOVR  R3.z, c[54].y;
MOVR  R3.x, c[54];
SGTR  H0.y, R4, R4.z;
MULX  H0.x, H0, c[19];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R4.x, R4.x;
MULR  R3.z(NE.x), R4.x, R3.y;
MULR  R3.x(NE), R0.w, R4;
MOVR  R3.y, R3.z;
MOVR  R11.xy, R3;
MADR  R3.xyz, R5, R3.x, R0;
ADDR  R3.xyz, R3, -c[13];
DP3R  R0.w, R3, c[21];
SGTR  H0.y, R0.w, c[53];
MULXC HC.x, H0, H0.y;
ADDR  R0.w, R6, -R6.z;
RCPR  R2.w, R1.w;
MULR  R2.w, R0, R2;
MINR  R2.w, R2, c[37].x;
MADR  R7.w, R2, c[52].y, R6.z;
DP3R  R0.w, R5, c[21];
MULR  R0.w, R0, c[35].x;
MADR  R7.xyz, R5, R7.w, R0;
MULR  R0.w, R0, c[52];
MADR  R0.x, c[35], c[35], R0.w;
ADDR  R0.y, R0.x, c[52].x;
MOVR  R0.x, c[52];
POWR  R0.y, R0.y, c[54].w;
ADDR  R0.x, R0, c[35];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MOVR  R11.xy(NE.x), c[54];
MULR  R6.xyz, R5, R2.w;
MULR  R5.w, R0.x, R0.y;
MOVR  R8.xyz, c[52].x;
MOVR  R9.xyz, c[53].y;
MOVR  R8.w, c[53].y;
MOVR  R9.w, c[53].y;
LOOP c[56];
SLTRC HC.x, R9.w, R1.w;
BRK   (EQ.x);
MOVR  R0.xyz, c[45];
MADR  R0.xyz, R7.xzyw, c[42].xxyw, R0;
ADDR  R0.zw, R0.xyxz, c[56].w;
MULR  R3.xy, R0.zwzw, c[57].x;
MULR  R0.zw, R3.xyxy, c[57].y;
MOVXC RC.xy, R3;
ADDR  R3.xyz, R7, -c[13];
DP3R  R0.x, R3, R3;
FRCR  R0.zw, |R0|;
MULR  R4.xy, R0.zwzw, c[57].x;
MOVR  R0.zw, R4.xyxy;
MOVR  R0.zw(LT.xyxy), -R4.xyxy;
MOVR  R3.x, c[38];
RSQR  R0.x, R0.x;
ADDR  R3.x, R3, c[15];
RCPR  R0.x, R0.x;
ADDR  R10.w, R0.x, -R3.x;
FLRR  R3.x, R0.w;
MADR  R0.x, R3, c[57].z, R0.z;
ADDR  R0.z, R0.w, -R3.x;
ADDR  R4.x, R10.w, c[38];
RCPR  R3.z, c[39].x;
MULR_SAT R4.w, R10, R3.z;
MULR  R10.x, R4.w, c[55].z;
ADDR  R0.x, R0, c[57].w;
MULR  R0.x, R0, c[58];
TEX   R0.xy, R0, texture[4], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.z, R0.y, R0;
SGER  H0.xy, R10.x, c[52].wxzw;
MOVR  R0.w, c[52].x;
MOVR  R4.y, c[52].x;
SGERC HC.x, R4, c[31].w;
MOVR  R4.y(EQ.x), R3.w;
SLTRC HC.x, R4, c[31].w;
ADDR  R0.x, R0, -c[52].y;
MOVR  R0.y, c[44].x;
MADR  R4.z, R0.x, c[52].w, R0.y;
MULR  R0.xyz, R7, c[18].x;
DP4R  R3.y, R0, c[10];
DP4R  R3.x, R0, c[8];
MADR  R0.xy, R3, c[52].y, c[52].y;
MULR  R3.x, R4.w, R4.w;
TEX   R0, R0, texture[5], 2D;
MULR  R3.x, R3, R3;
ADDR  R0, R0, c[40];
MULR  R3.x, R3, R3;
MULR  R3.x, R3, R3;
MULR  R0, R0, c[41];
MADR  R0, -R3.x, R0, R0;
ADDR  R3, R0.wzyz, -R0.zyxw;
MADR  R3.z, R10.x, R3, R0.x;
MADR  R3.z, -H0.y, R3, R3;
MADR  R3.y, R10.x, R3, -R3;
MADR  R3.z, R4, c[43].x, R3;
ADDR  R4.z, R0.y, R3.y;
MADR  R3.y, -H0.x, H0, H0;
MADR  R3.z, R3.y, R4, R3;
ADDR  R3.y, R10.x, -c[52].w;
MADR  R3.x, R3.y, R3, R0.z;
MADR  R3.x, H0, R3, R3.z;
MAXR  R3.z, R3.x, c[53].y;
ADDR  R4.zw, R0.xyxy, -R0.xyyz;
ADDR_SAT R3.xy, -R10.x, c[52].xwzw;
MULR  R4.zw, R3.xyxy, R4;
MADR  R0.xy, R4.wzzw, c[52].y, R0.zyzw;
ADDR_SAT R4.z, -R10.x, c[55];
MULR  R0.z, R3.w, R4;
MULR  R0.x, R3.y, R0;
MADR  R3.x, R3, R0.y, R0;
MADR  R0.w, R0.z, c[52].y, R0;
MOVR  R0.xyz, c[14];
DP3R  R0.x, R0, c[21];
MULR  R0.y, R10.x, c[55].w;
MAXR  R0.x, R0, c[58].y;
RCPR  R0.z, R0.x;
ADDR  R0.x, -R10.w, c[39];
MULR  R0.z, R0.x, R0;
MADR  R0.w, R4.z, R0, R3.x;
MULR  R3.w, R0, R0.z;
MADR  R0.y, R0, -c[48].x, R0;
ADDR  R0.x, R0.y, c[48];
MULR  R0.x, R0, c[47];
MULR  R11.zw, R0.x, R3;
MULR  R0.x, R11.w, -c[34];
POWR  R0.w, c[52].z, R0.x;
ADDR  R0.x, R7.w, R2.w;
RCPR  R0.y, R2.w;
ADDR  R0.x, R0, -R11;
ADDR  R0.z, -R7.w, R11.y;
MULR_SAT R0.x, R0, R0.y;
MULR_SAT R0.z, R0.y, R0;
MULR  R0.x, R0, R0.z;
MADR  R0.x, -R0, R0.w, R0.w;
MULR  R10.xyz, R0.x, R2;
MOVR  R0.w, c[52].x;
MOVR  R0.xyz, R7;
MOVR  R3.w, R4.y;
DP4R  R12.y, R0, c[5];
DP4R  R12.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[31];
ADDR  R3, -R0, c[30];
RCPR  R0.x, R3.y;
ADDR  R4, R4.x, -c[31];
MULR_SAT R0.x, R4.y, R0;
MOVR  R3.y, c[55].z;
MADR  R0.z, -R0.x, c[52].w, R3.y;
MULR  R0.y, R0.x, R0.x;
RCPR  R0.x, R3.x;
MULR_SAT R4.x, R4, R0;
MULR  R3.x, R0.y, R0.z;
TEX   R0, R12, texture[6], 2D;
MADR  R3.x, R0.y, R3, -R3;
MADR  R0.y, -R4.x, c[52].w, R3;
MULR  R4.x, R4, R4;
MULR  R0.y, R4.x, R0;
MADR  R0.x, R0, R0.y, -R0.y;
ADDR  R3.x, R3, c[52];
MADR  R0.x, R0, R3, R3;
RCPR  R0.y, R3.z;
RCPR  R3.x, R3.w;
MULR_SAT R3.z, R3.x, R4.w;
MULR_SAT R0.y, R0, R4.z;
MADR  R3.x, -R0.y, c[52].w, R3.y;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R3.x;
MADR  R3.x, -R3.z, c[52].w, R3.y;
MADR  R0.y, R0.z, R0, -R0;
MULR  R3.y, R3.z, R3.z;
MADR  R0.x, R0.y, R0, R0;
MULR  R3.x, R3.y, R3;
MADR  R0.y, R0.w, R3.x, -R3.x;
MADR  R3.w, R0.y, R0.x, R0.x;
ENDIF;
ADDR  R0.xyz, -R7, c[27];
DP3R  R0.w, R0, R0;
RSQR  R3.x, R0.w;
MULR  R0.xyz, R3.x, R0;
RCPR  R3.x, R3.x;
MOVR  R0.w, c[52].x;
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[35], R0.w;
RCPR  R3.z, R0.x;
MULR  R3.y, c[35].x, c[35].x;
MADR  R4.x, -R3.y, R3.z, R3.z;
MOVR  R0.xyz, c[27];
MULR  R3.z, R4.x, R3;
ADDR  R0.xyz, -R0, c[28];
DP3R  R4.x, R0, R0;
ADDR  R0.xyz, -R7, c[24];
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
MULR  R4.x, R4, R3.z;
DP3R  R4.y, R0, R0;
RSQR  R3.z, R4.y;
MULR  R0.xyz, R3.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[35], R0.w;
MULR  R3.x, R3, c[56].w;
MULR  R0.y, R3.x, R3.x;
RCPR  R0.y, R0.y;
MULR  R0.z, R4.x, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R3, R0.x, R0.x;
RCPR  R3.y, R3.z;
MULR  R3.x, R0.z, c[56].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[24];
ADDR  R0.xyz, -R0, c[25];
DP3R  R0.x, R0, R0;
MULR  R3.y, R3, c[56].w;
MULR  R0.y, R3, R3;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MINR  R0.y, R3.x, c[52].x;
MULR  R0.w, R0.x, c[56];
MULR  R3.xyz, R10, R3.w;
MINR  R0.w, R0, c[52].x;
MULR  R0.xyz, R0.y, c[29];
MADR  R0.xyz, R0.w, c[26], R0;
MOVR  R0.w, c[59].x;
MULR  R0.xyz, R0, c[58].z;
MADR  R0.xyz, R5.w, R3, R0;
MULR  R4.x, R0.w, c[34];
ADDR  R3.x, -R10.w, c[39];
MULR  R0.w, -R4.x, R3.x;
ADDR  R3.xyz, R1, c[23];
POWR  R0.w, c[52].z, R0.w;
MULR  R3.xyz, R4.x, R3;
MULR  R3.xyz, R3, R0.w;
MOVR  R0.w, c[33].x;
MULR  R0.w, R0, c[47].x;
MULR  R0.xyz, R0.w, R0;
MULR  R3.xyz, R3, c[50].x;
MADR  R0.xyz, R0, c[58].w, R3;
MULR  R0.xyz, R11.z, R0;
MULR  R0.xyz, R0, R2.w;
MADR  R9.xyz, R0, R8, R9;
MULR  R0.w, R11.z, -c[34].x;
MULR  R0.x, R2.w, R0.w;
POWR  R0.x, c[52].z, R0.x;
ADDR  R7.xyz, R7, R6;
MULR  R8.xyz, R8, R0.x;
ADDR  R7.w, R2, R7;
ADDR  R8.w, R11.z, R8;
ADDR  R9.w, R9, c[52].x;
ENDLOOP;
RCPR  R0.x, R1.w;
ADDR  R0.y, R6.w, -R7.w;
MULR  R0.x, R8.w, R0;
MINR  R0.y, R0, c[49].x;
MULR  R0.x, R0, -c[34];
MULR  R0.x, R0, R0.y;
POWR  R0.x, c[52].z, R0.x;
MULR  R0.xyz, R8, R0.x;
DP3R  R4.w, R0, c[59].yzww;
MULR  R4.xyz, R9, c[46];
ENDIF;
MOVR  oCol, R4;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 12 [_CameraData]
Matrix 0 [_Camera2World]
Vector 13 [_PlanetCenterKm]
Vector 14 [_PlanetNormal]
Float 15 [_PlanetRadiusKm]
Float 16 [_WorldUnit2Kilometer]
Float 17 [_Kilometer2WorldUnit]
Float 18 [_bComputePlanetShadow]
Vector 19 [_SunDirection]
Vector 20 [_AmbientNightSky]
Vector 21 [_NuajLightningPosition00]
Vector 22 [_NuajLightningPosition01]
Vector 23 [_NuajLightningColor0]
Vector 24 [_NuajLightningPosition10]
Vector 25 [_NuajLightningPosition11]
Vector 26 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 27 [_ShadowAltitudesMinKm]
Vector 28 [_ShadowAltitudesMaxKm]
SetTexture 3 [_TexShadowMap] 2D
Float 29 [_DensitySeaLevel_Mie]
Float 30 [_Sigma_Mie]
Float 31 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDownScaledZBuffer] 2D
SetTexture 1 [_NuajTexNoise3D0] 2D
Float 32 [_StepsCount]
Float 33 [_MaxStepSizeKm]
Float 34 [_FogAltitudeKm]
Vector 35 [_FogThicknessKm]
Vector 36 [_DensityOffset]
Vector 37 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 2 [_TexLayeredDensity] 2D
Vector 38 [_NoiseTiling]
Float 39 [_NoiseAmplitude]
Float 40 [_NoiseOffset]
Vector 41 [_NoisePosition]
Vector 42 [_FogColor]
Float 43 [_MieDensityFactor]
Float 44 [_DensityRatioBottom]
Float 45 [_FogMaxDistance]
Float 46 [_IsotropicSkyFactor]
Float 47 [_UseSceneZ]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c48, -1.00000000, 1.00000000, 0.00000000, 2.00000000
def c49, 0.99500000, 1000000.00000000, -1000000.00000000, -500000.00000000
def c50, 1.50000000, 0.50000000, 3.00000000, 0.33329999
defi i0, 255, 0, 1, 0
def c51, -2.00000000, 1000.00000000, 16.00000000, 0.06250000
def c52, 17.00000000, 0.25000000, 0.00367647, -0.50000000
def c53, 0.01000000, 2.71828198, 2.00000000, 3.00000000
def c54, 10.00000000, 0.60000002, 12.56637096, 0
def c55, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
mad r1.xy, v0, c48.w, c48.x
mul r1.xy, r1, c12
mov r1.z, c48.x
dp3 r1.w, r1, r1
rsq r1.w, r1.w
mul r2.xyz, r1.w, r1
mov r2.w, c48.z
dp4 r1.z, r2, c2
dp4 r1.y, r2, c1
dp4 r1.x, r2, c0
mov r2.w, c15.x
add r4.x, c34, r2.w
rcp r1.w, r1.w
mov r3.x, c0.w
mov r3.z, c2.w
mov r3.y, c1.w
mul r3.xyz, r3, c16.x
add r2.xyz, r3, -c13
dp3 r3.w, r2, r2
dp3 r4.z, r1, r2
mad r2.w, -r4.x, r4.x, r3
mad r2.z, r4, r4, -r2.w
rsq r2.x, r2.z
rcp r2.y, r2.x
cmp_pp r4.y, r2.z, c48, c48.z
add r2.x, -r4.z, -r2.y
cmp r2.zw, r2.z, r0.xyxy, c49.xyyz
add r2.y, -r4.z, r2
cmp r2.xy, -r4.y, r2.zwzw, r2
add r4.y, r4.x, c35.x
mad r2.w, -r4.y, r4.y, r3
mad r5.y, r4.z, r4.z, -r2.w
add r2.z, r2.x, c49.w
cmp r5.x, r2.z, c48.z, c48.y
abs_pp r2.z, r5.x
cmp_pp r4.w, -r2.z, c48.y, c48.z
rsq r2.z, r3.w
rcp r2.z, r2.z
add r2.w, r2.z, -r4.x
add r4.x, -r2.z, r4.y
cmp r5.w, r4.x, c48.z, c48.y
cmp r2.w, r2, c48.z, c48.y
abs_pp r2.z, r2.w
rsq r6.y, r5.y
cmp_pp r5.z, -r2, c48.y, c48
rcp r2.w, r6.y
add r2.z, -r4, -r2.w
mul_pp r6.x, r5.z, r5.w
mul_pp r6.y, r6.x, r5.x
cmp_pp r5.x, r5.y, c48.y, c48.z
cmp r4.xy, r5.y, r0, c49.yzzw
add r2.w, -r4.z, r2
cmp r4.xy, -r5.x, r4, r2.zwzw
mov r5.x, r4
mov r2.z, r2.y
abs_pp r2.y, r5.w
mul_pp r4.x, r6, r4.w
cmp_pp r2.y, -r2, c48, c48.z
mul_pp r4.w, r5.z, r2.y
mov r2.w, r4.y
mov r5.y, r2.x
cmp r2.zw, -r6.y, r2, r5.xyxy
cmp r5.x, r2, c48.z, c48.y
cmp r2.zw, -r4.x, r2, c48.xyzx
mul_pp r2.y, r4.w, r5.x
mov r4.x, c48.z
cmp r2.zw, -r2.y, r2, r4.xyxy
mad r2.y, -c15.x, c15.x, r3.w
mad r3.w, r4.z, r4.z, -r2.y
mov r2.y, r2.x
abs_pp r4.x, r5
cmp_pp r4.x, -r4, c48.y, c48.z
mul_pp r4.y, r4.w, r4.x
rsq r4.x, r3.w
mov r2.x, c48.z
cmp r2.zw, -r4.y, r2, r2.xyxy
cmp_pp r2.y, r3.w, c48, c48.z
rcp r4.x, r4.x
texldl r2.x, v0, s0
add r2.x, r2, -c12.w
mul r2.x, r2, c47
cmp r3.w, r3, r0.x, c49.y
add r4.x, -r4.z, -r4
cmp r2.y, -r2, r3.w, r4.x
add r2.x, r2, c12.w
cmp r3.w, r2.y, r2.y, c49.y
mul r2.y, r2.x, r1.w
mov r1.w, c12
mad r1.w, c49.x, -r1, r2.x
mul r2.x, r2.y, c16
mad r3.w, -r2.y, c16.x, r3
cmp r1.w, r1, c48.y, c48.z
mad r1.w, r1, r3, r2.x
min r1.w, r1, r2
min r1.w, r1, c45.x
max r2.z, r2, c48
add r2.x, -r1.w, r2.z
mov r2.w, r1
cmp r0, -r2.x, r0, c48.zzzy
cmp_pp r2.y, -r2.x, c48, c48.z
mov r2.x, c32
mov r1.w, c48.y
add r2.x, c48, r2
cmp r1.w, r2.x, c32.x, r1
if_gt r2.y, c48.z
add r0.xyz, r3, -c13
mul r4.xyz, r0.zxyw, c19.yzxw
mad r4.xyz, r0.yzxw, c19.zxyw, -r4
dp3 r0.w, r4, r4
dp3 r0.x, r0, c19
mul r5.xyz, r1.zxyw, c19.yzxw
mad r5.xyz, r1.yzxw, c19.zxyw, -r5
cmp r0.x, -r0, c48.y, c48.z
dp3 r2.x, r5, r5
mad r0.w, -c15.x, c15.x, r0
mul r2.y, r2.x, r0.w
dp3 r0.w, r4, r5
mad r2.y, r0.w, r0.w, -r2
rsq r3.w, r2.y
rcp r3.w, r3.w
add r4.x, -r0.w, -r3.w
rcp r4.y, r2.x
mul r0.z, r4.x, r4.y
cmp r0.y, -r2, c48.z, c48
mul_pp r0.x, r0, c18
mul_pp r2.y, r0.x, r0
cmp r2.x, -r2.y, c49.y, r0.z
mad r0.xyz, r1, r2.x, r3
add r0.xyz, r0, -c13
dp3 r0.x, r0, c19
add r0.y, -r0.w, r3.w
mul r0.y, r4, r0
cmp r0.x, -r0, c48.z, c48.y
mul_pp r0.x, r2.y, r0
cmp r2.y, -r2, c49.z, r0
dp3 r0.z, r1, c19
mul r0.y, r0.z, c31.x
cmp r7.xy, -r0.x, r2, c49.yzzw
mul r0.x, r0.y, c48.w
mad r0.x, c31, c31, r0
add r2.x, r0, c48.y
rcp r0.z, r1.w
add r0.y, r2.w, -r2.z
mul r0.y, r0, r0.z
min r3.w, r0.y, c33.x
pow r0, r2.x, c50.x
mad r5.w, r3, c50.y, r2.z
mov r0.y, c31.x
mov r0.z, r0.x
add r0.x, c48.y, r0.y
rcp r0.y, r0.z
mul r0.x, r0, r0
mad r3.xyz, r1, r5.w, r3
mul r4.w, r0.x, r0.y
mul r2.xyz, r1, r3.w
mov r4.xyz, c48.y
mov r5.xyz, c48.z
mov r6.w, c48.z
mov r8.w, c48.z
loop aL, i0
break_ge r8.w, r1.w
mul r0.xyz, r3.xzyw, c38.xxyw
add r0.xyz, r0, c41
add r0.zw, r0.xyxz, c51.y
mul r0.zw, r0, c51.z
mul r6.xy, r0.zwzw, c51.w
abs r6.xy, r6
frc r6.xy, r6
mul r6.xy, r6, c51.z
cmp r0.zw, r0, r6.xyxy, -r6.xyxy
frc r6.x, r0.w
add r0.x, -r6, r0.w
mad r0.x, r0, c52, r0.z
add r0.x, r0, c52.y
mov r0.w, c48.y
mov r0.z, c48
mul r0.x, r0, c52.z
texldl r0.xy, r0.xyzz, s1
add r0.y, r0, -r0.x
mad r0.x, r6, r0.y, r0
add r0.x, r0, c52.w
mul r0.x, r0, c48.w
add r6.z, r0.x, c40.x
mul r0.xyz, r3, c17.x
dp4 r6.y, r0, c10
dp4 r6.x, r0, c8
add r0.xyz, r3, -c13
dp3 r0.z, r0, r0
add r6.xy, r6, c48.y
mul r0.xy, r6, c50.y
rsq r0.z, r0.z
mov r0.w, c15.x
rcp r0.z, r0.z
add r0.w, c34.x, r0
add r9.y, r0.z, -r0.w
rcp r6.x, c35.x
mul_sat r6.x, r9.y, r6
mul r6.y, r6.x, r6.x
mov r0.z, c48
texldl r0, r0.xyzz, s2
mul r6.y, r6, r6
mul r6.y, r6, r6
mad r7.z, -r6.y, r6.y, c48.y
mul r6.y, r6.x, c50.z
add r0, r0, c36
mul r0, r0, c37
mul r0, r0, r7.z
add r6.x, r6.y, c48
cmp r7.z, r6.x, c48.y, c48
add r7.w, r0.y, -r0.x
mad r7.w, r6.y, r7, r0.x
add r6.x, -r7.z, c48.y
mul r7.w, r6.x, r7
mad r8.y, r6.z, c39.x, r7.w
add r6.x, r6.y, c51
cmp r6.x, r6, c48.y, c48.z
add r6.z, -r6.x, c48.y
mul r6.z, r7, r6
add r8.x, r0.z, -r0.y
add r7.w, r6.y, c48.x
mad r7.w, r7, r8.x, r0.y
mad r7.w, r6.z, r7, r8.y
add r7.z, r0.w, -r0
add r6.z, r6.y, c51.x
mad r6.z, r6, r7, r0
mad r6.x, r6, r6.z, r7.w
add r6.z, r0.y, -r0
add_sat r7.z, -r6.y, c48.w
mul r7.w, r7.z, r6.z
mad r7.w, r7, c50.y, r0.z
add r6.z, r0.x, -r0.y
add_sat r0.x, -r6.y, c48.y
mul r6.z, r0.x, r6
mad r6.z, r6, c50.y, r0.y
mul r7.z, r7, r7.w
mad r6.z, r0.x, r6, r7
add_sat r0.y, -r6, c50.z
add r0.z, r0, -r0.w
mul r0.z, r0.y, r0
mad r0.x, r0.z, c50.y, r0.w
mad r0.w, r0.y, r0.x, r6.z
mov r0.xyz, c19
dp3 r0.y, c14, r0
max r0.y, r0, c53.x
rcp r0.z, r0.y
mov r6.z, c44.x
add r6.z, c48.y, -r6
mul r0.x, r6.y, r6.z
mul r0.x, r0, c50.w
add r0.y, -r9, c35.x
mul r0.y, r0, r0.z
add r0.x, r0, c44
mul r6.y, r0.w, r0
max r6.x, r6, c48.z
mul r0.x, r0, c43
mul r7.zw, r0.x, r6.xyxy
mul r6.x, r7.w, -c30
pow r0, c53.y, r6.x
add r0.y, r5.w, r3.w
add r7.w, r9.y, c34.x
add r8.z, r7.w, -c28.w
rcp r0.z, r3.w
add r0.y, r0, -r7.x
add r0.w, -r5, r7.y
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r0.y, -r0, r0.w, c48
mul r0.x, r0, r0.y
mul r6.xyz, r0.x, v2
mov r0.xyz, r3
mov r0.w, c48.y
dp4 r8.y, r0, c5
dp4 r8.x, r0, c4
cmp_pp r0.x, r8.z, c48.z, c48.y
cmp r9.x, r8.z, c48.y, r9
if_gt r0.x, c48.z
mov r0.xy, r8
mov r0.w, c27.x
add r8.x, -c28, r0.w
rcp r8.y, r8.x
add r8.x, r7.w, -c28
mul_sat r8.x, r8, r8.y
mul r8.y, r8.x, r8.x
mov r0.z, c48
texldl r0, r0.xyzz, s3
add r8.z, r0.x, c48.x
mad r8.x, -r8, c53.z, c53.w
mul r8.x, r8.y, r8
mov r0.x, c27.y
add r8.y, -c28, r0.x
mad r0.x, r8, r8.z, c48.y
rcp r8.y, r8.y
add r8.x, r7.w, -c28.y
mul_sat r8.x, r8, r8.y
add r8.z, r0.y, c48.x
mad r8.y, -r8.x, c53.z, c53.w
mul r0.y, r8.x, r8.x
mul r8.x, r0.y, r8.y
mad r8.x, r8, r8.z, c48.y
mov r0.y, c27.z
mul r0.x, r0, r8
add r0.y, -c28.z, r0
rcp r8.x, r0.y
add r0.y, r7.w, -c28.z
mul_sat r0.y, r0, r8.x
add r8.y, r0.z, c48.x
mad r8.x, -r0.y, c53.z, c53.w
mul r0.z, r0.y, r0.y
mul r0.z, r0, r8.x
mov r0.y, c27.w
add r8.x, -c28.w, r0.y
mad r0.y, r0.z, r8, c48
add r0.z, r7.w, -c28.w
rcp r8.x, r8.x
mul_sat r0.z, r0, r8.x
add r7.w, r0, c48.x
mad r0.w, -r0.z, c53.z, c53
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r7.w, c48.y
mul r0.x, r0, r0.y
mul r9.x, r0, r0.z
endif
add r0.xyz, -r3, c24
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r1, r0
mul r0.x, r0, c31
add r0.y, r0.x, c48
mul r0.x, -c31, c31
rcp r8.x, r0.y
add r7.w, r0.x, c48.y
mul r8.y, r7.w, r8.x
mov r0.xyz, c25
mul r9.z, r8.y, r8.x
add r8.xyz, -c24, r0
dp3 r8.y, r8, r8
add r0.xyz, -r3, c21
dp3 r8.x, r0, r0
rsq r8.x, r8.x
mul r0.xyz, r8.x, r0
dp3 r0.x, r0, r1
rcp r0.w, r0.w
mul r0.y, r0.w, c51
rsq r8.y, r8.y
rcp r8.y, r8.y
mul r0.x, r0, c31
mul r0.y, r0, r0
add r0.x, r0, c48.y
rcp r8.x, r8.x
rcp r0.x, r0.x
mul r8.y, r8, r9.z
rcp r0.y, r0.y
mul r0.z, r8.y, r0.y
mul r0.y, r7.w, r0.x
mul r7.w, r0.z, c51.y
mul r0.w, r0.y, r0.x
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.x, r0, r0
mul r8.x, r8, c51.y
mul r0.y, r8.x, r8.x
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c51.y
min r0.y, r7.w, c48
add r8.x, -r9.y, c35
min r0.w, r0, c48.y
mul r0.xyz, r0.y, c26
mad r0.xyz, r0.w, c23, r0
mov r0.w, c30.x
mul r7.w, c54.y, r0
mul r9.y, -r7.w, r8.x
mul r8.xyz, r0, c54.x
pow r0, c53.y, r9.y
mul r6.xyz, r6, r9.x
mad r6.xyz, r4.w, r6, r8
mov r0.w, r0.x
add r8.xyz, v1, c20
mul r0.xyz, r7.w, r8
mul r0.xyz, r0, r0.w
mov r0.w, c43.x
mul r0.w, c29.x, r0
mul r6.xyz, r0.w, r6
mul r0.w, r7.z, -c30.x
mul r0.xyz, r0, c46.x
mad r0.xyz, r6, c54.z, r0
mul r0.xyz, r7.z, r0
mul r6.xyz, r0, r3.w
mul r7.w, r3, r0
pow r0, c53.y, r7.w
mad r5.xyz, r6, r4, r5
add r3.xyz, r3, r2
mul r4.xyz, r4, r0.x
add r5.w, r3, r5
add r6.w, r7.z, r6
add r8.w, r8, c48.y
endloop
rcp r0.y, r1.w
add r0.x, r2.w, -r5.w
mul r0.y, r6.w, r0
min r0.x, r0, c45
mul r0.y, r0, -c30.x
mul r1.x, r0.y, r0
pow r0, c53.y, r1.x
mul r0.xyz, r4, r0.x
dp3 r0.w, r0, c55
mul r0.xyz, r5, c42
endif
mov oC0, r0

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 computes environment lighting (this is simply the fog rendered into a small map)
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
Float 16 [_FogAltitudeKm]
Vector 17 [_FogThicknessKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c18, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
add r0.x, -r0, c18.z
mov r0.y, c9.x
mov r0.w, c10.x
add r0.y, c16.x, r0
add r0.w, -c9.x, r0
add r0.y, r0, c17.x
mul r0.x, r0, c18.y
rcp r0.w, r0.w
add r0.y, r0, -c9.x
mul r0.y, r0, r0.w
mov r0.z, c18.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c18.w, r1.x
mov r1.x, r0
pow r0, c18.w, r1.z
mov r1.z, r0
pow r2, c18.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c18.yyzx, s1
mov r1.zw, c18.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c18.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c18.x
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
Vector 13 [_PlanetNormal]
Vector 14 [_PlanetTangent]
Vector 15 [_PlanetBiTangent]
Float 16 [_PlanetRadiusKm]
Float 17 [_WorldUnit2Kilometer]
Float 18 [_Kilometer2WorldUnit]
Float 19 [_bComputePlanetShadow]
Vector 20 [_SunDirection]
Vector 21 [_AmbientNightSky]
Vector 22 [_EnvironmentAngles]
Vector 23 [_NuajLightningPosition00]
Vector 24 [_NuajLightningPosition01]
Vector 25 [_NuajLightningColor0]
Vector 26 [_NuajLightningPosition10]
Vector 27 [_NuajLightningPosition11]
Vector 28 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 29 [_ShadowAltitudesMinKm]
Vector 30 [_ShadowAltitudesMaxKm]
SetTexture 2 [_TexShadowMap] 2D
Float 31 [_DensitySeaLevel_Mie]
Float 32 [_Sigma_Mie]
Float 33 [_MiePhaseAnisotropy]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 34 [_StepsCount]
Float 35 [_MaxStepSizeKm]
Float 36 [_FogAltitudeKm]
Vector 37 [_FogThicknessKm]
Vector 38 [_DensityOffset]
Vector 39 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 40 [_NoiseTiling]
Float 41 [_NoiseAmplitude]
Float 42 [_NoiseOffset]
Vector 43 [_NoisePosition]
Vector 44 [_FogColor]
Float 45 [_MieDensityFactor]
Float 46 [_DensityRatioBottom]
Float 47 [_FogMaxDistance]
Float 48 [_IsotropicSkyFactor]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[56] = { program.local[0..48],
		{ 0, 1, 1000000, -1000000 },
		{ 2, 1.5, 0.5, 3 },
		{ 255, 0, 1, 0.33329999 },
		{ 1000, 16, 0.0625, 17 },
		{ 0.25, 0.0036764706, 0.0099999998, 2.718282 },
		{ 10, 12.566371, 0.60000002 },
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
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MADR  R2.xy, fragment.texcoord[0], c[22].zwzw, c[22];
COSR  R0.x, R2.y;
MOVR  R4.x, c[36];
MULR  R0.xyz, R0.x, c[13];
SINR  R0.w, R2.y;
SINR  R1.x, R2.x;
MULR  R1.x, R0.w, R1;
MADR  R1.xyz, R1.x, c[14], R0;
COSR  R2.w, R2.x;
MULR  R0.w, R0, R2;
MOVR  R0.y, c[2].w;
MOVR  R0.x, c[0].w;
MULR  R0.xz, R0.xyyw, c[17].x;
MOVR  R0.y, c[49].x;
ADDR  R2.xyz, R0, -c[12];
MADR  R1.xyz, R0.w, c[15], R1;
DP3R  R0.w, R1, R2;
DP3R  R2.y, R2, R2;
ADDR  R4.x, R4, c[16];
ADDR  R2.x, R4, c[37];
MADR  R2.z, -R2.x, R2.x, R2.y;
MULR  R2.w, R0, R0;
SGER  H0.z, R2.w, R2;
ADDR  R4.y, R2.w, -R2.z;
SLTRC HC.x, R2.w, R2.z;
MOVR  R2.x, c[49];
MADR  R2.z, -R4.x, R4.x, R2.y;
RSQR  R4.y, R4.y;
RCPR  R4.y, R4.y;
MOVR  R2.x(EQ), R1.w;
SLTR  H0.x, -R0.w, -R4.y;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[49].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R2.y, c[49].x;
MOVR  R2.x(NE), c[49];
SLTR  H0.z, -R0.w, R4.y;
MULXC HC.x, H0.y, H0.z;
SGER  H0.z, R2.w, R2;
ADDR  R2.x(NE), -R0.w, R4.y;
MOVX  H0.x(NE), c[49];
MULXC HC.x, H0.y, H0;
ADDR  R2.x(NE), -R0.w, -R4.y;
SLTRC HC.x, R2.w, R2.z;
MOVR  R2.y(EQ.x), R1.w;
ADDR  R1.w, R2, -R2.z;
RSQR  R1.w, R1.w;
RCPR  R1.w, R1.w;
SLTR  H0.x, -R0.w, -R1.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[49].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R2.y(NE.x), c[49].x;
SLTR  H0.z, -R0.w, R1.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R2.y(NE.x), -R0.w, R1.w;
MOVX  H0.x(NE), c[49];
MULXC HC.x, H0.y, H0;
ADDR  R2.y(NE.x), -R0.w, -R1.w;
MINR  R0.w, R2.y, R2.x;
MAXR  R2.z, R0.w, c[49].x;
MAXR  R0.w, R2.y, R2.x;
SGTRC HC.x, R2.z, R0.w;
MOVR  oCol, c[49].xxxy;
MOVR  oCol(EQ.x), R3;
SLERC HC.x, R2.z, R0.w;
MOVR  R2.w, R0;
IF    NE.x;
ADDR  R3.xyz, R0, -c[12];
MULR  R4.xyz, R3.zxyw, c[20].yzxw;
MADR  R4.xyz, R3.yzxw, c[20].zxyw, -R4;
DP3R  R3.x, R3, c[20];
DP3R  R0.w, R4, R4;
SLER  H0.x, R3, c[49];
MULR  R5.xyz, R1.zxyw, c[20].yzxw;
MADR  R5.xyz, R1.yzxw, c[20].zxyw, -R5;
DP3R  R1.w, R4, R5;
DP3R  R2.x, R5, R5;
MADR  R0.w, -c[16].x, c[16].x, R0;
MULR  R4.x, R2, R0.w;
MULR  R2.y, R1.w, R1.w;
RCPR  R3.x, R2.x;
ADDR  R0.w, R2.y, -R4.x;
SGTR  H0.y, R2, R4.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.y, -R1.w, R0.w;
ADDR  R0.w, -R1, -R0;
MULX  H0.x, H0, c[19];
MULX  H0.x, H0, H0.y;
MOVR  R2.x, c[49].z;
MOVXC RC.x, H0;
MOVR  R2.y, c[49].w;
MULR  R2.x(NE), R0.w, R3;
MULR  R2.y(NE.x), R3.x, R3;
MADR  R3.xyz, R1, R2.x, R0;
ADDR  R3.xyz, R3, -c[12];
DP3R  R0.w, R3, c[20];
SGTR  H0.y, R0.w, c[49].x;
ADDR  R0.w, R2, -R2.z;
RCPR  R1.w, c[34].x;
MULR  R1.w, R0, R1;
MINR  R1.w, R1, c[35].x;
MADR  R6.w, R1, c[50].z, R2.z;
MOVR  R9.xy, R2;
MULXC HC.x, H0, H0.y;
DP3R  R0.w, R1, c[20];
MULR  R0.w, R0, c[33].x;
MADR  R5.xyz, R1, R6.w, R0;
MULR  R0.w, R0, c[50].x;
MADR  R0.x, c[33], c[33], R0.w;
ADDR  R0.y, R0.x, c[49];
MOVR  R0.x, c[49].y;
POWR  R0.y, R0.y, c[50].y;
ADDR  R0.x, R0, c[33];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MOVR  R9.xy(NE.x), c[49].zwzw;
MULR  R2.xyz, R1, R1.w;
MULR  R5.w, R0.x, R0.y;
MOVR  R6.xyz, c[49].y;
MOVR  R7.xyz, c[49].x;
MOVR  R7.w, c[49].x;
MOVR  R8.w, c[49].x;
LOOP c[51];
SLTRC HC.x, R8.w, c[34];
BRK   (EQ.x);
MOVR  R0.xyz, c[43];
MADR  R0.xyz, R5.xzyw, c[40].xxyw, R0;
ADDR  R0.zw, R0.xyxz, c[52].x;
MULR  R3.xy, R0.zwzw, c[52].y;
MULR  R0.zw, R3.xyxy, c[52].z;
MOVXC RC.xy, R3;
ADDR  R3.xyz, R5, -c[12];
DP3R  R0.x, R3, R3;
FRCR  R0.zw, |R0|;
MULR  R4.xy, R0.zwzw, c[52].y;
MOVR  R0.zw, R4.xyxy;
MOVR  R0.zw(LT.xyxy), -R4.xyxy;
MOVR  R3.x, c[36];
RSQR  R0.x, R0.x;
ADDR  R3.x, R3, c[16];
RCPR  R0.x, R0.x;
ADDR  R10.x, R0, -R3;
FLRR  R3.x, R0.w;
MADR  R0.x, R3, c[52].w, R0.z;
ADDR  R0.z, R0.w, -R3.x;
ADDR  R4.x, R10, c[36];
RCPR  R3.z, c[37].x;
MULR_SAT R4.w, R10.x, R3.z;
MULR  R8.x, R4.w, c[50].w;
ADDR  R0.x, R0, c[53];
MULR  R0.x, R0, c[53].y;
TEX   R0.xy, R0, texture[0], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.z, R0.y, R0;
MOVR  R0.w, c[49].y;
SGER  H0.y, R8.x, c[49];
SGER  H0.x, R8, c[50];
MOVR  R4.y, c[49];
SGERC HC.x, R4, c[30].w;
MOVR  R4.y(EQ.x), R3.w;
SLTRC HC.x, R4, c[30].w;
ADDR  R0.x, R0, -c[50].z;
MOVR  R0.y, c[42].x;
MADR  R4.z, R0.x, c[50].x, R0.y;
MULR  R0.xyz, R5, c[18].x;
DP4R  R3.y, R0, c[10];
DP4R  R3.x, R0, c[8];
MADR  R0.xy, R3, c[50].z, c[50].z;
MULR  R3.x, R4.w, R4.w;
TEX   R0, R0, texture[1], 2D;
MULR  R3.x, R3, R3;
ADDR  R0, R0, c[38];
MULR  R3.x, R3, R3;
MULR  R3.x, R3, R3;
MULR  R0, R0, c[39];
MADR  R0, -R3.x, R0, R0;
ADDR  R3, R0.wzyz, -R0.zyxw;
MADR  R3.z, R8.x, R3, R0.x;
MADR  R3.z, -H0.y, R3, R3;
MADR  R3.y, R8.x, R3, -R3;
MADR  R3.z, R4, c[41].x, R3;
ADDR  R4.z, R0.y, R3.y;
MADR  R3.y, -H0.x, H0, H0;
MADR  R3.z, R3.y, R4, R3;
ADDR  R4.zw, R0.xyxy, -R0.xyyz;
ADDR_SAT R0.x, -R8, c[49].y;
ADDR  R3.y, R8.x, -c[50].x;
MADR  R3.x, R3.y, R3, R0.z;
MADR  R3.x, H0, R3, R3.z;
MAXR  R3.z, R3.x, c[49].x;
ADDR_SAT R3.xy, -R8.x, c[50].wxzw;
MULR  R4.w, R3.y, R4;
MULR  R4.z, R0.x, R4;
MADR  R0.z, R4.w, c[50], R0;
MULR  R0.z, R3.y, R0;
MULR  R3.y, R3.w, R3.x;
MADR  R0.y, R4.z, c[50].z, R0;
MADR  R3.w, R0.x, R0.y, R0.z;
MOVR  R0.xyz, c[13];
DP3R  R0.x, R0, c[20];
MULR  R0.y, R8.x, c[51].w;
MAXR  R0.x, R0, c[53].z;
RCPR  R0.z, R0.x;
ADDR  R0.x, -R10, c[37];
MADR  R0.w, R3.y, c[50].z, R0;
MADR  R0.w, R3.x, R0, R3;
MULR  R0.z, R0.x, R0;
MULR  R3.w, R0, R0.z;
MADR  R0.y, R0, -c[46].x, R0;
ADDR  R0.x, R0.y, c[46];
MULR  R0.x, R0, c[45];
MULR  R10.zw, R0.x, R3;
MULR  R0.x, R10.w, -c[32];
POWR  R0.w, c[53].w, R0.x;
ADDR  R0.x, R6.w, R1.w;
RCPR  R0.y, R1.w;
ADDR  R0.x, R0, -R9;
ADDR  R0.z, -R6.w, R9.y;
MULR_SAT R0.x, R0, R0.y;
MULR_SAT R0.z, R0.y, R0;
MULR  R0.x, R0, R0.z;
MADR  R0.x, -R0, R0.w, R0.w;
MULR  R8.xyz, R0.x, fragment.texcoord[2];
MOVR  R0.w, c[49].y;
MOVR  R0.xyz, R5;
MOVR  R3.w, R4.y;
DP4R  R9.w, R0, c[5];
DP4R  R9.z, R0, c[4];
IF    NE.x;
MOVR  R0, c[30];
ADDR  R3, -R0, c[29];
ADDR  R4, R4.x, -c[30];
RCPR  R0.x, R3.y;
MULR_SAT R0.x, R4.y, R0;
MULR  R0.y, R0.x, R0.x;
MADR  R0.z, -R0.x, c[50].x, c[50].w;
RCPR  R0.x, R3.x;
MULR_SAT R3.y, R4.x, R0.x;
MULR  R3.x, R0.y, R0.z;
TEX   R0, R9.zwzw, texture[2], 2D;
MADR  R3.x, R0.y, R3, -R3;
MADR  R0.y, -R3, c[50].x, c[50].w;
MULR  R3.y, R3, R3;
MULR  R0.y, R3, R0;
MADR  R0.x, R0, R0.y, -R0.y;
ADDR  R3.x, R3, c[49].y;
MADR  R0.x, R0, R3, R3;
RCPR  R3.x, R3.w;
RCPR  R0.y, R3.z;
MULR_SAT R3.y, R3.x, R4.w;
MULR_SAT R0.y, R0, R4.z;
MADR  R3.x, -R0.y, c[50], c[50].w;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R3.x;
MADR  R3.x, -R3.y, c[50], c[50].w;
MADR  R0.y, R0.z, R0, -R0;
MULR  R3.y, R3, R3;
MADR  R0.x, R0.y, R0, R0;
MULR  R3.x, R3.y, R3;
MADR  R0.y, R0.w, R3.x, -R3.x;
MADR  R3.w, R0.y, R0.x, R0.x;
ENDIF;
ADDR  R0.xyz, -R5, c[26];
DP3R  R0.w, R0, R0;
RSQR  R3.x, R0.w;
MULR  R0.xyz, R3.x, R0;
RCPR  R3.x, R3.x;
MOVR  R0.w, c[49].y;
DP3R  R0.x, R1, R0;
MADR  R0.x, R0, c[33], R0.w;
RCPR  R3.z, R0.x;
MULR  R3.y, c[33].x, c[33].x;
MADR  R4.x, -R3.y, R3.z, R3.z;
MOVR  R0.xyz, c[26];
MULR  R3.z, R4.x, R3;
ADDR  R0.xyz, -R0, c[27];
DP3R  R4.x, R0, R0;
ADDR  R0.xyz, -R5, c[23];
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
MULR  R4.x, R4, R3.z;
DP3R  R4.y, R0, R0;
RSQR  R3.z, R4.y;
MULR  R0.xyz, R3.z, R0;
DP3R  R0.x, R0, R1;
MADR  R0.x, R0, c[33], R0.w;
MULR  R3.x, R3, c[52];
MULR  R0.y, R3.x, R3.x;
RCPR  R0.y, R0.y;
MULR  R0.z, R4.x, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R3, R0.x, R0.x;
RCPR  R3.y, R3.z;
MULR  R3.x, R0.z, c[52];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[23];
ADDR  R0.xyz, -R0, c[24];
DP3R  R0.x, R0, R0;
MULR  R3.y, R3, c[52].x;
MULR  R0.y, R3, R3;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MINR  R0.y, R3.x, c[49];
MULR  R0.w, R0.x, c[52].x;
MULR  R3.xyz, R8, R3.w;
MINR  R0.w, R0, c[49].y;
MULR  R0.xyz, R0.y, c[28];
MADR  R0.xyz, R0.w, c[25], R0;
MOVR  R0.w, c[54].z;
MULR  R0.xyz, R0, c[54].x;
MADR  R0.xyz, R5.w, R3, R0;
MULR  R4.x, R0.w, c[32];
ADDR  R3.x, -R10, c[37];
MULR  R0.w, -R4.x, R3.x;
ADDR  R3.xyz, fragment.texcoord[1], c[21];
POWR  R0.w, c[53].w, R0.w;
MULR  R3.xyz, R4.x, R3;
MULR  R3.xyz, R3, R0.w;
MOVR  R0.w, c[31].x;
MULR  R0.w, R0, c[45].x;
MULR  R0.xyz, R0.w, R0;
MULR  R3.xyz, R3, c[48].x;
MADR  R0.xyz, R0, c[54].y, R3;
MULR  R0.xyz, R10.z, R0;
MULR  R0.xyz, R0, R1.w;
MADR  R7.xyz, R0, R6, R7;
MULR  R0.w, R10.z, -c[32].x;
MULR  R0.x, R1.w, R0.w;
POWR  R0.x, c[53].w, R0.x;
ADDR  R5.xyz, R5, R2;
MULR  R6.xyz, R6, R0.x;
ADDR  R6.w, R1, R6;
ADDR  R7.w, R10.z, R7;
ADDR  R8.w, R8, c[49].y;
ENDLOOP;
RCPR  R0.x, c[34].x;
ADDR  R0.y, R2.w, -R6.w;
MULR  R0.x, R7.w, R0;
MINR  R0.y, R0, c[47].x;
MULR  R0.x, R0, -c[32];
MULR  R0.x, R0, R0.y;
POWR  R0.x, c[53].w, R0.x;
MULR  R0.xyz, R6, R0.x;
DP3R  oCol.w, R0, c[55];
MULR  oCol.xyz, R7, c[44];
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 12 [_PlanetCenterKm]
Vector 13 [_PlanetNormal]
Vector 14 [_PlanetTangent]
Vector 15 [_PlanetBiTangent]
Float 16 [_PlanetRadiusKm]
Float 17 [_WorldUnit2Kilometer]
Float 18 [_Kilometer2WorldUnit]
Float 19 [_bComputePlanetShadow]
Vector 20 [_SunDirection]
Vector 21 [_AmbientNightSky]
Vector 22 [_EnvironmentAngles]
Vector 23 [_NuajLightningPosition00]
Vector 24 [_NuajLightningPosition01]
Vector 25 [_NuajLightningColor0]
Vector 26 [_NuajLightningPosition10]
Vector 27 [_NuajLightningPosition11]
Vector 28 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 29 [_ShadowAltitudesMinKm]
Vector 30 [_ShadowAltitudesMaxKm]
SetTexture 2 [_TexShadowMap] 2D
Float 31 [_DensitySeaLevel_Mie]
Float 32 [_Sigma_Mie]
Float 33 [_MiePhaseAnisotropy]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 34 [_StepsCount]
Float 35 [_MaxStepSizeKm]
Float 36 [_FogAltitudeKm]
Vector 37 [_FogThicknessKm]
Vector 38 [_DensityOffset]
Vector 39 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 40 [_NoiseTiling]
Float 41 [_NoiseAmplitude]
Float 42 [_NoiseOffset]
Vector 43 [_NoisePosition]
Vector 44 [_FogColor]
Float 45 [_MieDensityFactor]
Float 46 [_DensityRatioBottom]
Float 47 [_FogMaxDistance]
Float 48 [_IsotropicSkyFactor]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c49, 0.00000000, 0.15915491, 0.50000000, 1.00000000
def c50, 6.28318501, -3.14159298, 1000000.00000000, -1000000.00000000
def c51, 2.00000000, 1.50000000, 3.00000000, 0.33329999
defi i0, 255, 0, 1, 0
def c52, -2.00000000, -1.00000000, 1000.00000000, 16.00000000
def c53, 0.06250000, 17.00000000, 0.25000000, 0.00367647
def c54, -0.50000000, 0.01000000, 2.71828198, 10.00000000
def c55, 0.60000002, 12.56637096, 0, 0
def c56, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xy
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
mad r1.xy, v0, c22.zwzw, c22
mad r1.z, r1.x, c49.y, c49
mad r1.y, r1, c49, c49.z
frc r1.x, r1.y
frc r1.y, r1.z
mad r1.x, r1, c50, c50.y
sincos r2.xy, r1.x
mad r3.x, r1.y, c50, c50.y
sincos r1.xy, r3.x
mul r3.xyz, r2.x, c13
mul r1.y, r2, r1
mul r1.x, r2.y, r1
mad r3.xyz, r1.y, c14, r3
mad r1.xyz, r1.x, c15, r3
mov r1.w, c16.x
add r2.w, c36.x, r1
add r1.w, r2, c37.x
mov r2.y, c2.w
mov r2.x, c0.w
mul r3.xz, r2.xyyw, c17.x
mov r3.y, c49.x
add r2.xyz, r3, -c12
dp3 r3.w, r2, r2
mad r4.x, -r1.w, r1.w, r3.w
dp3 r1.w, r1, r2
mad r2.y, r1.w, r1.w, -r4.x
rsq r2.x, r2.y
rcp r2.z, r2.x
add r4.x, -r1.w, r2.z
cmp_pp r2.x, r2.y, c49.w, c49
add r5.x, -r1.w, -r2.z
cmp r4.y, r4.x, c49.x, c49.w
mul_pp r4.y, r2.x, r4
cmp_pp r4.z, -r4.y, r2.x, c49.x
mul_pp r4.w, r2.x, r4.z
mad r2.x, -r2.w, r2.w, r3.w
cmp r2.z, r5.x, c49.x, c49.w
mad r2.x, r1.w, r1.w, -r2
cmp r2.y, r2, r0.x, c49.x
mul_pp r5.y, r4.w, r2.z
cmp r2.z, -r4.y, r2.y, c49.x
cmp r4.y, -r5, r2.z, r4.x
rsq r2.y, r2.x
rcp r2.z, r2.y
add r2.w, -r1, r2.z
cmp_pp r2.y, -r5, r4.z, c49.x
mul_pp r4.x, r4.w, r2.y
cmp r4.z, -r4.x, r4.y, r5.x
cmp_pp r2.y, r2.x, c49.w, c49.x
cmp r3.w, r2, c49.x, c49
mul_pp r3.w, r2.y, r3
cmp_pp r4.x, -r3.w, r2.y, c49
add r2.z, -r1.w, -r2
mul_pp r1.w, r2.y, r4.x
cmp r4.y, r2.x, r0.x, c49.x
cmp r2.y, r2.z, c49.x, c49.w
mul_pp r2.x, r1.w, r2.y
cmp_pp r2.y, -r2.x, r4.x, c49.x
cmp r3.w, -r3, r4.y, c49.x
cmp r2.x, -r2, r3.w, r2.w
mul_pp r1.w, r1, r2.y
cmp r1.w, -r1, r2.x, r2.z
min r2.x, r1.w, r4.z
max r1.w, r1, r4.z
max r2.z, r2.x, c49.x
add r2.x, r2.z, -r1.w
cmp oC0, -r2.x, r0, c49.xxxw
cmp_pp r0.x, -r2, c49.w, c49
mov r2.w, r1
if_gt r0.x, c49.x
add r0.xyz, r3, -c12
mul r4.xyz, r0.zxyw, c20.yzxw
mad r4.xyz, r0.yzxw, c20.zxyw, -r4
dp3 r0.w, r4, r4
dp3 r0.x, r0, c20
mul r5.xyz, r1.zxyw, c20.yzxw
mad r5.xyz, r1.yzxw, c20.zxyw, -r5
cmp r0.x, -r0, c49.w, c49
dp3 r1.w, r5, r5
mad r0.w, -c16.x, c16.x, r0
mul r2.x, r1.w, r0.w
dp3 r0.w, r4, r5
mad r2.x, r0.w, r0.w, -r2
rsq r2.y, r2.x
rcp r2.y, r2.y
add r3.w, -r0, -r2.y
rcp r4.x, r1.w
mul r0.z, r3.w, r4.x
cmp r0.y, -r2.x, c49.x, c49.w
mul_pp r0.x, r0, c19
mul_pp r1.w, r0.x, r0.y
cmp r2.x, -r1.w, c50.z, r0.z
mad r0.xyz, r1, r2.x, r3
add r0.xyz, r0, -c12
dp3 r0.x, r0, c20
add r0.y, -r0.w, r2
mul r0.y, r4.x, r0
cmp r0.x, -r0, c49, c49.w
cmp r2.y, -r1.w, c50.w, r0
mul_pp r0.x, r1.w, r0
dp3 r0.z, r1, c20
mul r0.y, r0.z, c33.x
cmp r7.xy, -r0.x, r2, c50.zwzw
mul r0.x, r0.y, c51
mad r0.x, c33, c33, r0
add r2.x, r0, c49.w
rcp r0.z, c34.x
add r0.y, r2.w, -r2.z
mul r0.y, r0, r0.z
min r1.w, r0.y, c35.x
pow r0, r2.x, c51.y
mad r4.w, r1, c49.z, r2.z
mov r0.y, c33.x
mov r0.z, r0.x
add r0.x, c49.w, r0.y
rcp r0.y, r0.z
mul r0.x, r0, r0
mad r3.xyz, r1, r4.w, r3
mul r3.w, r0.x, r0.y
mul r2.xyz, r1, r1.w
mov r4.xyz, c49.w
mov r5.xyz, c49.x
mov r5.w, c49.x
mov r6.w, c49.x
loop aL, i0
break_ge r6.w, c34.x
mul r0.xyz, r3.xzyw, c40.xxyw
add r0.xyz, r0, c43
add r0.zw, r0.xyxz, c52.z
mul r0.zw, r0, c52.w
mul r6.xy, r0.zwzw, c53.x
abs r6.xy, r6
frc r6.xy, r6
mul r6.xy, r6, c52.w
cmp r0.zw, r0, r6.xyxy, -r6.xyxy
frc r6.x, r0.w
add r0.x, -r6, r0.w
mad r0.x, r0, c53.y, r0.z
add r0.x, r0, c53.z
mov r0.w, c49
mov r0.z, c49.x
mul r0.x, r0, c53.w
texldl r0.xy, r0.xyzz, s0
add r0.y, r0, -r0.x
mad r0.x, r6, r0.y, r0
add r0.x, r0, c54
mul r0.x, r0, c51
add r6.z, r0.x, c42.x
mul r0.xyz, r3, c18.x
dp4 r6.y, r0, c10
dp4 r6.x, r0, c8
add r0.xyz, r3, -c12
dp3 r0.z, r0, r0
add r6.xy, r6, c49.w
mul r0.xy, r6, c49.z
rsq r0.z, r0.z
mov r0.w, c16.x
rcp r0.z, r0.z
add r0.w, c36.x, r0
add r9.x, r0.z, -r0.w
rcp r6.x, c37.x
mul_sat r6.x, r9, r6
mul r6.y, r6.x, r6.x
mov r0.z, c49.x
texldl r0, r0.xyzz, s1
mul r6.y, r6, r6
mul r6.y, r6, r6
mad r7.z, -r6.y, r6.y, c49.w
mul r6.y, r6.x, c51.z
add r6.x, r6.y, c52.y
add r0, r0, c38
mul r0, r0, c39
mul r0, r0, r7.z
add r7.z, r0.y, -r0.x
mad r7.w, r6.y, r7.z, r0.x
cmp r6.x, r6, c49.w, c49
add r7.z, -r6.x, c49.w
mul r7.w, r7.z, r7
mad r8.y, r6.z, c41.x, r7.w
add r7.z, r6.y, c52.x
cmp r6.z, r7, c49.w, c49.x
add r7.z, -r6, c49.w
mul r6.x, r6, r7.z
add r8.x, r0.z, -r0.y
add r7.w, r6.y, c52.y
mad r7.w, r7, r8.x, r0.y
mad r7.w, r6.x, r7, r8.y
add r7.z, r0.w, -r0
add r6.x, r6.y, c52
mad r6.x, r6, r7.z, r0.z
mad r6.x, r6.z, r6, r7.w
add r6.z, r0.y, -r0
add_sat r7.z, -r6.y, c51.x
mul r7.w, r7.z, r6.z
mad r7.w, r7, c49.z, r0.z
add r6.z, r0.x, -r0.y
add_sat r0.x, -r6.y, c49.w
mul r6.z, r0.x, r6
mad r6.z, r6, c49, r0.y
mul r7.z, r7, r7.w
mad r6.z, r0.x, r6, r7
add_sat r0.y, -r6, c51.z
add r0.z, r0, -r0.w
mul r0.z, r0.y, r0
mad r0.x, r0.z, c49.z, r0.w
mad r0.w, r0.y, r0.x, r6.z
mov r0.xyz, c20
dp3 r0.y, c13, r0
max r0.y, r0, c54
rcp r0.z, r0.y
mov r6.z, c46.x
add r6.z, c49.w, -r6
mul r0.x, r6.y, r6.z
mul r0.x, r0, c51.w
add r0.y, -r9.x, c37.x
mul r0.y, r0, r0.z
add r0.x, r0, c46
mul r6.y, r0.w, r0
max r6.x, r6, c49
mul r0.x, r0, c45
mul r7.zw, r0.x, r6.xyxy
mul r6.x, r7.w, -c32
pow r0, c54.z, r6.x
add r0.y, r4.w, r1.w
add r7.w, r9.x, c36.x
add r8.z, r7.w, -c30.w
rcp r0.z, r1.w
add r0.y, r0, -r7.x
add r0.w, -r4, r7.y
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r0.y, -r0, r0.w, c49.w
mul r0.x, r0, r0.y
mul r6.xyz, r0.x, v2
mov r0.xyz, r3
mov r0.w, c49
dp4 r8.y, r0, c5
dp4 r8.x, r0, c4
cmp_pp r0.x, r8.z, c49, c49.w
cmp r8.w, r8.z, c49, r8
if_gt r0.x, c49.x
mov r0.xy, r8
mov r0.w, c29.x
add r8.x, -c30, r0.w
rcp r8.y, r8.x
add r8.x, r7.w, -c30
mul_sat r8.x, r8, r8.y
mul r8.y, r8.x, r8.x
mov r0.z, c49.x
texldl r0, r0.xyzz, s2
add r8.z, r0.x, c52.y
mad r8.x, -r8, c51, c51.z
mul r8.x, r8.y, r8
mov r0.x, c29.y
add r8.y, -c30, r0.x
mad r0.x, r8, r8.z, c49.w
rcp r8.y, r8.y
add r8.x, r7.w, -c30.y
mul_sat r8.x, r8, r8.y
add r8.z, r0.y, c52.y
mad r8.y, -r8.x, c51.x, c51.z
mul r0.y, r8.x, r8.x
mul r8.x, r0.y, r8.y
mad r8.x, r8, r8.z, c49.w
mov r0.y, c29.z
mul r0.x, r0, r8
add r0.y, -c30.z, r0
rcp r8.x, r0.y
add r0.y, r7.w, -c30.z
mul_sat r0.y, r0, r8.x
add r8.y, r0.z, c52
mad r8.x, -r0.y, c51, c51.z
mul r0.z, r0.y, r0.y
mul r0.z, r0, r8.x
mov r0.y, c29.w
add r8.x, -c30.w, r0.y
mad r0.y, r0.z, r8, c49.w
add r0.z, r7.w, -c30.w
rcp r8.x, r8.x
mul_sat r0.z, r0, r8.x
add r7.w, r0, c52.y
mad r0.w, -r0.z, c51.x, c51.z
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r7.w, c49.w
mul r0.x, r0, r0.y
mul r8.w, r0.x, r0.z
endif
add r0.xyz, -r3, c26
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r1, r0
mul r0.x, r0, c33
add r0.y, r0.x, c49.w
mul r0.x, -c33, c33
rcp r8.x, r0.y
add r7.w, r0.x, c49
mul r8.y, r7.w, r8.x
mov r0.xyz, c27
mul r9.y, r8, r8.x
add r8.xyz, -c26, r0
dp3 r8.y, r8, r8
add r0.xyz, -r3, c23
dp3 r8.x, r0, r0
rsq r8.x, r8.x
mul r0.xyz, r8.x, r0
dp3 r0.x, r0, r1
rcp r0.w, r0.w
mul r0.y, r0.w, c52.z
rsq r8.y, r8.y
rcp r8.y, r8.y
mul r0.x, r0, c33
mul r0.y, r0, r0
add r0.x, r0, c49.w
rcp r8.x, r8.x
rcp r0.x, r0.x
mul r8.y, r8, r9
rcp r0.y, r0.y
mul r0.z, r8.y, r0.y
mul r0.y, r7.w, r0.x
mul r7.w, r0.z, c52.z
mul r0.w, r0.y, r0.x
mov r0.xyz, c24
add r0.xyz, -c23, r0
dp3 r0.x, r0, r0
mul r8.x, r8, c52.z
mul r0.y, r8.x, r8.x
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c52.z
min r0.y, r7.w, c49.w
add r8.x, -r9, c37
min r0.w, r0, c49
mul r0.xyz, r0.y, c28
mad r0.xyz, r0.w, c25, r0
mov r0.w, c32.x
mul r7.w, c55.x, r0
mul r9.x, -r7.w, r8
mul r8.xyz, r0, c54.w
pow r0, c54.z, r9.x
mul r6.xyz, r6, r8.w
mad r6.xyz, r3.w, r6, r8
mov r0.w, r0.x
add r8.xyz, v1, c21
mul r0.xyz, r7.w, r8
mul r0.xyz, r0, r0.w
mov r0.w, c45.x
mul r0.w, c31.x, r0
mul r6.xyz, r0.w, r6
mul r0.w, r7.z, -c32.x
mul r0.xyz, r0, c48.x
mad r0.xyz, r6, c55.y, r0
mul r0.xyz, r7.z, r0
mul r6.xyz, r0, r1.w
mul r7.w, r1, r0
pow r0, c54.z, r7.w
mad r5.xyz, r6, r4, r5
add r3.xyz, r3, r2
mul r4.xyz, r4, r0.x
add r4.w, r1, r4
add r5.w, r7.z, r5
add r6.w, r6, c49
endloop
rcp r0.y, c34.x
add r0.x, r2.w, -r4.w
mul r0.y, r5.w, r0
min r0.x, r0, c47
mul r0.y, r0, -c32.x
mul r1.x, r0.y, r0
pow r0, c54.z, r1.x
mul r0.xyz, r4, r0.x
dp3 oC0.w, r0, c56
mul oC0.xyz, r5, c44
endif

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #6 computes environment lighting in the Sun's direction (this is simply the fog rendered into a 1x1 map)
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
Float 16 [_FogAltitudeKm]
Vector 17 [_FogThicknessKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c18, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
add r0.x, -r0, c18.z
mov r0.y, c9.x
mov r0.w, c10.x
add r0.y, c16.x, r0
add r0.w, -c9.x, r0
add r0.y, r0, c17.x
mul r0.x, r0, c18.y
rcp r0.w, r0.w
add r0.y, r0, -c9.x
mul r0.y, r0, r0.w
mov r0.z, c18.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c18.w, r1.x
mov r1.x, r0
pow r0, c18.w, r1.z
mov r1.z, r0
pow r2, c18.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c18.yyzx, s1
mov r1.zw, c18.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c18.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c18.x
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
Vector 13 [_PlanetNormal]
Float 14 [_PlanetRadiusKm]
Float 15 [_WorldUnit2Kilometer]
Float 16 [_Kilometer2WorldUnit]
Float 17 [_bComputePlanetShadow]
Vector 18 [_SunDirection]
Vector 19 [_AmbientNightSky]
Vector 20 [_NuajLightningPosition00]
Vector 21 [_NuajLightningPosition01]
Vector 22 [_NuajLightningColor0]
Vector 23 [_NuajLightningPosition10]
Vector 24 [_NuajLightningPosition11]
Vector 25 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 26 [_ShadowAltitudesMinKm]
Vector 27 [_ShadowAltitudesMaxKm]
SetTexture 2 [_TexShadowMap] 2D
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 31 [_StepsCount]
Float 32 [_MaxStepSizeKm]
Float 33 [_FogAltitudeKm]
Vector 34 [_FogThicknessKm]
Vector 35 [_DensityOffset]
Vector 36 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 37 [_NoiseTiling]
Float 38 [_NoiseAmplitude]
Float 39 [_NoiseOffset]
Vector 40 [_NoisePosition]
Vector 41 [_FogColor]
Float 42 [_MieDensityFactor]
Float 43 [_DensityRatioBottom]
Float 44 [_FogMaxDistance]
Float 45 [_IsotropicSkyFactor]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[53] = { program.local[0..45],
		{ 0, 1, 1000000, -1000000 },
		{ 2, 1.5, 0.5, 3 },
		{ 255, 0, 1, 0.33329999 },
		{ 1000, 16, 0.0625, 17 },
		{ 0.25, 0.0036764706, 0.0099999998, 2.718282 },
		{ 10, 12.566371, 0.60000002 },
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
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R3.x, c[33];
ADDR  R3.x, R3, c[14];
MOVR  R0.y, c[2].w;
MOVR  R0.x, c[0].w;
MULR  R0.xz, R0.xyyw, c[15].x;
MOVR  R0.y, c[46].x;
ADDR  R1.xyz, R0, -c[12];
DP3R  R0.w, R1, c[18];
DP3R  R1.y, R1, R1;
ADDR  R1.x, R3, c[34];
MADR  R1.z, -R1.x, R1.x, R1.y;
MULR  R1.w, R0, R0;
SGER  H0.z, R1.w, R1;
ADDR  R3.y, R1.w, -R1.z;
SLTRC HC.x, R1.w, R1.z;
MADR  R1.z, -R3.x, R3.x, R1.y;
MOVR  R1.x, c[46];
ADDR  R3.x, R1.w, -R1.z;
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
RSQR  R3.x, R3.x;
MOVR  R1.x(EQ), R2;
SLTR  H0.x, -R0.w, -R3.y;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[46].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.y, c[46].x;
MOVR  R1.x(NE), c[46];
SLTR  H0.z, -R0.w, R3.y;
MULXC HC.x, H0.y, H0.z;
SGER  H0.z, R1.w, R1;
ADDR  R1.x(NE), -R0.w, R3.y;
MOVX  H0.x(NE), c[46];
MULXC HC.x, H0.y, H0;
ADDR  R1.x(NE), -R0.w, -R3.y;
SLTRC HC.x, R1.w, R1.z;
RCPR  R3.x, R3.x;
MOVR  R1.y(EQ.x), R2.x;
SLTR  H0.x, -R0.w, -R3;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[46].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.y(NE.x), c[46].x;
SLTR  H0.z, -R0.w, R3.x;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.y(NE.x), -R0.w, R3.x;
MOVX  H0.x(NE), c[46];
MULXC HC.x, H0.y, H0;
ADDR  R1.y(NE.x), -R0.w, -R3.x;
MINR  R0.w, R1.y, R1.x;
MAXR  R1.z, R0.w, c[46].x;
MAXR  R0.w, R1.y, R1.x;
SGTRC HC.x, R1.z, R0.w;
MOVR  oCol, c[46].xxxy;
MOVR  oCol(EQ.x), R2;
SLERC HC.x, R1.z, R0.w;
MOVR  R1.w, R0;
IF    NE.x;
ADDR  R2.xyz, R0, -c[12];
MULR  R3.xyz, R2.zxyw, c[18].yzxw;
MADR  R3.xyz, R2.yzxw, c[18].zxyw, -R3;
DP3R  R2.x, R2, c[18];
SLER  H0.x, R2, c[46];
DP3R  R0.w, R3, R3;
MULR  R4.xyz, c[18].zxyw, c[18].yzxw;
MADR  R4.xyz, c[18].yzxw, c[18].zxyw, -R4;
DP3R  R1.y, R3, R4;
DP3R  R1.x, R4, R4;
MADR  R0.w, -c[14].x, c[14].x, R0;
MULR  R3.x, R1, R0.w;
MULR  R2.w, R1.y, R1.y;
RCPR  R2.z, R1.x;
ADDR  R0.w, R2, -R3.x;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R2.y, -R1, R0.w;
MOVR  R1.x, c[46].z;
SGTR  H0.y, R2.w, R3.x;
MULX  H0.x, H0, c[17];
MULX  H0.x, H0, H0.y;
MOVR  R2.x, c[46].w;
MOVXC RC.x, H0;
ADDR  R0.w, -R1.y, -R0;
MULR  R2.x(NE), R2.z, R2.y;
MULR  R1.x(NE), R0.w, R2.z;
MOVR  R1.y, R2.x;
MADR  R2.xyz, R1.x, c[18], R0;
MOVR  R8.xy, R1;
ADDR  R2.xyz, R2, -c[12];
DP3R  R0.w, R2, c[18];
SGTR  H0.y, R0.w, c[46].x;
MULXC HC.x, H0, H0.y;
RCPR  R1.x, c[31].x;
ADDR  R0.w, R1, -R1.z;
MULR  R0.w, R0, R1.x;
MINR  R2.w, R0, c[32].x;
MADR  R6.w, R2, c[47].z, R1.z;
MADR  R2.xyz, R6.w, c[18], R0;
DP3R  R0.w, c[18], c[18];
MULR  R0.x, R0.w, c[30];
MULR  R0.x, R0, c[47];
MADR  R0.x, c[30], c[30], R0;
ADDR  R0.y, R0.x, c[46];
MOVR  R0.x, c[46].y;
POWR  R0.y, R0.y, c[47].y;
ADDR  R0.x, R0, c[30];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MOVR  R8.xy(NE.x), c[46].zwzw;
MULR  R1.xyz, R2.w, c[18];
MOVR  R5.xyz, c[46].y;
MOVR  R6.xyz, c[46].x;
MULR  R5.w, R0.x, R0.y;
MOVR  R7.w, c[46].x;
MOVR  R9.x, c[46];
LOOP c[48];
SLTRC HC.x, R9, c[31];
BRK   (EQ.x);
MOVR  R0.xyz, c[40];
MADR  R0.xyz, R2.xzyw, c[37].xxyw, R0;
ADDR  R0.zw, R0.xyxz, c[49].x;
MULR  R3.xy, R0.zwzw, c[49].y;
MULR  R0.zw, R3.xyxy, c[49].z;
MOVXC RC.xy, R3;
ADDR  R3.xyz, R2, -c[12];
DP3R  R0.x, R3, R3;
FRCR  R0.zw, |R0|;
MULR  R4.xy, R0.zwzw, c[49].y;
MOVR  R0.zw, R4.xyxy;
MOVR  R0.zw(LT.xyxy), -R4.xyxy;
MOVR  R3.x, c[33];
RSQR  R0.x, R0.x;
ADDR  R3.x, R3, c[14];
RCPR  R0.x, R0.x;
ADDR  R9.y, R0.x, -R3.x;
FLRR  R3.x, R0.w;
MADR  R0.x, R3, c[49].w, R0.z;
ADDR  R0.z, R0.w, -R3.x;
ADDR  R4.x, R9.y, c[33];
RCPR  R3.z, c[34].x;
MULR_SAT R4.w, R9.y, R3.z;
MULR  R7.x, R4.w, c[47].w;
ADDR  R0.x, R0, c[50];
MULR  R0.x, R0, c[50].y;
TEX   R0.xy, R0, texture[0], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.z, R0.y, R0;
MOVR  R0.w, c[46].y;
SGER  H0.y, R7.x, c[46];
SGER  H0.x, R7, c[47];
MOVR  R4.y, c[46];
SGERC HC.x, R4, c[27].w;
MOVR  R4.y(EQ.x), R3.w;
SLTRC HC.x, R4, c[27].w;
ADDR  R0.x, R0, -c[47].z;
MOVR  R0.y, c[39].x;
MADR  R4.z, R0.x, c[47].x, R0.y;
MULR  R0.xyz, R2, c[16].x;
DP4R  R3.y, R0, c[10];
DP4R  R3.x, R0, c[8];
MADR  R0.xy, R3, c[47].z, c[47].z;
MULR  R3.x, R4.w, R4.w;
TEX   R0, R0, texture[1], 2D;
MULR  R3.x, R3, R3;
ADDR  R0, R0, c[35];
MULR  R3.x, R3, R3;
MULR  R3.x, R3, R3;
MULR  R0, R0, c[36];
MADR  R0, -R3.x, R0, R0;
ADDR  R3, R0.wzyz, -R0.zyxw;
MADR  R3.z, R7.x, R3, R0.x;
MADR  R3.z, -H0.y, R3, R3;
MADR  R3.y, R7.x, R3, -R3;
MADR  R3.z, R4, c[38].x, R3;
ADDR  R4.z, R0.y, R3.y;
MADR  R3.y, -H0.x, H0, H0;
MADR  R3.z, R3.y, R4, R3;
ADDR  R4.zw, R0.xyxy, -R0.xyyz;
ADDR_SAT R0.x, -R7, c[46].y;
ADDR  R3.y, R7.x, -c[47].x;
MADR  R3.x, R3.y, R3, R0.z;
MADR  R3.x, H0, R3, R3.z;
MAXR  R3.z, R3.x, c[46].x;
ADDR_SAT R3.xy, -R7.x, c[47].wxzw;
MULR  R4.w, R3.y, R4;
MULR  R4.z, R0.x, R4;
MADR  R0.z, R4.w, c[47], R0;
MULR  R0.z, R3.y, R0;
MULR  R3.y, R3.w, R3.x;
MADR  R0.y, R4.z, c[47].z, R0;
MADR  R3.w, R0.x, R0.y, R0.z;
MOVR  R0.xyz, c[13];
DP3R  R0.x, R0, c[18];
MULR  R0.y, R7.x, c[48].w;
MAXR  R0.x, R0, c[50].z;
RCPR  R0.z, R0.x;
ADDR  R0.x, -R9.y, c[34];
MADR  R0.w, R3.y, c[47].z, R0;
MADR  R0.w, R3.x, R0, R3;
MULR  R0.z, R0.x, R0;
MULR  R3.w, R0, R0.z;
MADR  R0.y, R0, -c[43].x, R0;
ADDR  R0.x, R0.y, c[43];
MULR  R0.x, R0, c[42];
MULR  R9.zw, R0.x, R3;
MULR  R0.x, R9.w, -c[29];
POWR  R0.w, c[50].w, R0.x;
ADDR  R0.x, R6.w, R2.w;
RCPR  R0.y, R2.w;
ADDR  R0.x, R0, -R8;
ADDR  R0.z, -R6.w, R8.y;
MULR_SAT R0.x, R0, R0.y;
MULR_SAT R0.z, R0.y, R0;
MULR  R0.x, R0, R0.z;
MADR  R0.x, -R0, R0.w, R0.w;
MULR  R7.xyz, R0.x, fragment.texcoord[2];
MOVR  R0.w, c[46].y;
MOVR  R0.xyz, R2;
MOVR  R3.w, R4.y;
DP4R  R8.w, R0, c[5];
DP4R  R8.z, R0, c[4];
IF    NE.x;
MOVR  R0, c[27];
ADDR  R3, -R0, c[26];
ADDR  R4, R4.x, -c[27];
RCPR  R0.x, R3.y;
MULR_SAT R0.x, R4.y, R0;
MULR  R0.y, R0.x, R0.x;
MADR  R0.z, -R0.x, c[47].x, c[47].w;
RCPR  R0.x, R3.x;
MULR_SAT R3.y, R4.x, R0.x;
MULR  R3.x, R0.y, R0.z;
TEX   R0, R8.zwzw, texture[2], 2D;
MADR  R3.x, R0.y, R3, -R3;
MADR  R0.y, -R3, c[47].x, c[47].w;
MULR  R3.y, R3, R3;
MULR  R0.y, R3, R0;
MADR  R0.x, R0, R0.y, -R0.y;
ADDR  R3.x, R3, c[46].y;
MADR  R0.x, R0, R3, R3;
RCPR  R3.x, R3.w;
RCPR  R0.y, R3.z;
MULR_SAT R3.y, R3.x, R4.w;
MULR_SAT R0.y, R0, R4.z;
MADR  R3.x, -R0.y, c[47], c[47].w;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R3.x;
MADR  R3.x, -R3.y, c[47], c[47].w;
MADR  R0.y, R0.z, R0, -R0;
MULR  R3.y, R3, R3;
MADR  R0.x, R0.y, R0, R0;
MULR  R3.x, R3.y, R3;
MADR  R0.y, R0.w, R3.x, -R3.x;
MADR  R3.w, R0.y, R0.x, R0.x;
ENDIF;
ADDR  R0.xyz, -R2, c[23];
DP3R  R0.w, R0, R0;
RSQR  R3.x, R0.w;
MULR  R0.xyz, R3.x, R0;
RCPR  R3.x, R3.x;
MOVR  R0.w, c[46].y;
DP3R  R0.x, R0, c[18];
MADR  R0.x, R0, c[30], R0.w;
RCPR  R3.z, R0.x;
MULR  R3.y, c[30].x, c[30].x;
MADR  R4.x, -R3.y, R3.z, R3.z;
MOVR  R0.xyz, c[23];
MULR  R3.z, R4.x, R3;
ADDR  R0.xyz, -R0, c[24];
DP3R  R4.x, R0, R0;
ADDR  R0.xyz, -R2, c[20];
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
MULR  R4.x, R4, R3.z;
DP3R  R4.y, R0, R0;
RSQR  R3.z, R4.y;
MULR  R0.xyz, R3.z, R0;
DP3R  R0.x, R0, c[18];
MADR  R0.x, R0, c[30], R0.w;
MULR  R3.x, R3, c[49];
MULR  R0.y, R3.x, R3.x;
RCPR  R0.y, R0.y;
MULR  R0.z, R4.x, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R3, R0.x, R0.x;
RCPR  R3.y, R3.z;
MULR  R3.x, R0.z, c[49];
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[20];
ADDR  R0.xyz, -R0, c[21];
DP3R  R0.x, R0, R0;
MULR  R3.y, R3, c[49].x;
MULR  R0.y, R3, R3;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MINR  R0.y, R3.x, c[46];
MULR  R0.w, R0.x, c[49].x;
MULR  R3.xyz, R7, R3.w;
MINR  R0.w, R0, c[46].y;
MULR  R0.xyz, R0.y, c[25];
MADR  R0.xyz, R0.w, c[22], R0;
MOVR  R0.w, c[51].z;
MULR  R0.xyz, R0, c[51].x;
MADR  R0.xyz, R5.w, R3, R0;
MULR  R4.x, R0.w, c[29];
ADDR  R3.x, -R9.y, c[34];
MULR  R0.w, -R4.x, R3.x;
ADDR  R3.xyz, fragment.texcoord[1], c[19];
POWR  R0.w, c[50].w, R0.w;
MULR  R3.xyz, R4.x, R3;
MULR  R3.xyz, R3, R0.w;
MOVR  R0.w, c[28].x;
MULR  R0.w, R0, c[42].x;
MULR  R0.xyz, R0.w, R0;
MULR  R3.xyz, R3, c[45].x;
MADR  R0.xyz, R0, c[51].y, R3;
MULR  R0.xyz, R9.z, R0;
MULR  R0.xyz, R0, R2.w;
MADR  R6.xyz, R0, R5, R6;
MULR  R0.w, R9.z, -c[29].x;
MULR  R0.x, R2.w, R0.w;
POWR  R0.x, c[50].w, R0.x;
ADDR  R2.xyz, R2, R1;
MULR  R5.xyz, R5, R0.x;
ADDR  R6.w, R2, R6;
ADDR  R7.w, R9.z, R7;
ADDR  R9.x, R9, c[46].y;
ENDLOOP;
RCPR  R0.x, c[31].x;
ADDR  R0.y, R1.w, -R6.w;
MULR  R0.x, R7.w, R0;
MINR  R0.y, R0, c[44].x;
MULR  R0.x, R0, -c[29];
MULR  R0.x, R0, R0.y;
POWR  R0.x, c[50].w, R0.x;
MULR  R0.xyz, R5, R0.x;
DP3R  oCol.w, R0, c[52];
MULR  oCol.xyz, R6, c[41];
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 12 [_PlanetCenterKm]
Vector 13 [_PlanetNormal]
Float 14 [_PlanetRadiusKm]
Float 15 [_WorldUnit2Kilometer]
Float 16 [_Kilometer2WorldUnit]
Float 17 [_bComputePlanetShadow]
Vector 18 [_SunDirection]
Vector 19 [_AmbientNightSky]
Vector 20 [_NuajLightningPosition00]
Vector 21 [_NuajLightningPosition01]
Vector 22 [_NuajLightningColor0]
Vector 23 [_NuajLightningPosition10]
Vector 24 [_NuajLightningPosition11]
Vector 25 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 26 [_ShadowAltitudesMinKm]
Vector 27 [_ShadowAltitudesMaxKm]
SetTexture 2 [_TexShadowMap] 2D
Float 28 [_DensitySeaLevel_Mie]
Float 29 [_Sigma_Mie]
Float 30 [_MiePhaseAnisotropy]
SetTexture 0 [_NuajTexNoise3D0] 2D
Float 31 [_StepsCount]
Float 32 [_MaxStepSizeKm]
Float 33 [_FogAltitudeKm]
Vector 34 [_FogThicknessKm]
Vector 35 [_DensityOffset]
Vector 36 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 1 [_TexLayeredDensity] 2D
Vector 37 [_NoiseTiling]
Float 38 [_NoiseAmplitude]
Float 39 [_NoiseOffset]
Vector 40 [_NoisePosition]
Vector 41 [_FogColor]
Float 42 [_MieDensityFactor]
Float 43 [_DensityRatioBottom]
Float 44 [_FogMaxDistance]
Float 45 [_IsotropicSkyFactor]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c46, 0.00000000, 1.00000000, 1000000.00000000, -1000000.00000000
def c47, 2.00000000, 1.50000000, 0.50000000, 3.00000000
defi i0, 255, 0, 1, 0
def c48, 0.33329999, -2.00000000, -1.00000000, 1000.00000000
def c49, 16.00000000, 0.06250000, 17.00000000, 0.25000000
def c50, 0.00367647, -0.50000000, 0.01000000, 2.71828198
def c51, 10.00000000, 0.60000002, 12.56637096, 0
def c52, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord1 v0.xyz
dcl_texcoord2 v1.xyz
mov r1.w, c14.x
add r1.w, c33.x, r1
mov r0.y, c2.w
mov r0.x, c0.w
mul r0.xz, r0.xyyw, c15.x
mov r0.y, c46.x
add r1.xyz, r0, -c12
dp3 r3.x, r1, r1
add r3.y, r1.w, c34.x
dp3 r1.x, r1, c18
mad r3.y, -r3, r3, r3.x
mad r3.y, r1.x, r1.x, -r3
rsq r1.y, r3.y
rcp r1.z, r1.y
add r3.z, -r1.x, r1
add r4.y, -r1.x, -r1.z
cmp_pp r1.y, r3, c46, c46.x
cmp r3.w, r3.z, c46.x, c46.y
mul_pp r3.w, r1.y, r3
cmp_pp r1.z, -r3.w, r1.y, c46.x
mul_pp r4.x, r1.y, r1.z
mad r1.y, -r1.w, r1.w, r3.x
cmp r4.z, r4.y, c46.x, c46.y
mul_pp r4.z, r4.x, r4
cmp_pp r1.z, -r4, r1, c46.x
mad r1.y, r1.x, r1.x, -r1
mul_pp r4.x, r4, r1.z
rsq r1.z, r1.y
cmp r3.x, r3.y, r0.w, c46
rcp r1.w, r1.z
cmp r1.z, -r3.w, r3.x, c46.x
add r3.x, -r1, r1.w
cmp r3.z, -r4, r1, r3
cmp_pp r1.z, r1.y, c46.y, c46.x
cmp r3.y, r3.x, c46.x, c46
add r1.w, -r1.x, -r1
cmp r1.y, r1, r0.w, c46.x
mul_pp r3.y, r1.z, r3
cmp r3.w, -r4.x, r3.z, r4.y
cmp_pp r3.z, -r3.y, r1, c46.x
mul_pp r1.x, r1.z, r3.z
cmp r1.z, r1.w, c46.x, c46.y
mul_pp r0.w, r1.x, r1.z
cmp r1.z, -r3.y, r1.y, c46.x
cmp r1.z, -r0.w, r1, r3.x
cmp_pp r1.y, -r0.w, r3.z, c46.x
mul_pp r0.w, r1.x, r1.y
cmp r0.w, -r0, r1.z, r1
min r1.x, r0.w, r3.w
max r0.w, r0, r3
max r1.z, r1.x, c46.x
add r1.x, r1.z, -r0.w
cmp oC0, -r1.x, r2, c46.xxxy
cmp_pp r1.x, -r1, c46.y, c46
mov r1.w, r0
if_gt r1.x, c46.x
add r2.xyz, r0, -c12
mul r3.xyz, r2.zxyw, c18.yzxw
mad r3.xyz, r2.yzxw, c18.zxyw, -r3
dp3 r0.w, r3, r3
mul r4.xyz, c18.zxyw, c18.yzxw
mad r4.xyz, c18.yzxw, c18.zxyw, -r4
mad r1.x, -c14, c14, r0.w
dp3 r0.w, r4, r4
dp3 r1.y, r3, r4
mul r1.x, r0.w, r1
mad r2.w, r1.y, r1.y, -r1.x
rsq r1.x, r2.w
rcp r3.y, r1.x
dp3 r1.x, r2, c18
add r3.x, -r1.y, -r3.y
cmp r2.x, -r2.w, c46, c46.y
rcp r0.w, r0.w
cmp r1.x, -r1, c46.y, c46
dp3 r2.w, c18, c18
mul r2.y, r3.x, r0.w
add r1.y, -r1, r3
mul_pp r1.x, r1, c17
mul_pp r3.x, r1, r2
cmp r1.x, -r3, c46.z, r2.y
mul r0.w, r0, r1.y
mad r2.xyz, r1.x, c18, r0
add r2.xyz, r2, -c12
dp3 r2.x, r2, c18
mul r2.w, r2, c30.x
mul r2.y, r2.w, c47.x
cmp r2.x, -r2, c46, c46.y
mad r2.y, c30.x, c30.x, r2
mul_pp r3.z, r3.x, r2.x
cmp r1.y, -r3.x, c46.w, r0.w
cmp r7.xy, -r3.z, r1, c46.zwzw
add r3.w, r2.y, c46.y
pow r2, r3.w, c47.y
mov r0.w, r2.x
rcp r1.x, r0.w
add r0.w, r1, -r1.z
rcp r1.y, c31.x
mul r1.y, r0.w, r1
min r2.w, r1.y, c32.x
mad r4.w, r2, c47.z, r1.z
mov r0.w, c30.x
add r0.w, c46.y, r0
mul r0.w, r0, r0
mul r3.w, r0, r1.x
mad r2.xyz, r4.w, c18, r0
mul r1.xyz, r2.w, c18
mov r3.xyz, c46.y
mov r4.xyz, c46.x
mov r5.w, c46.x
mov r6.w, c46.x
loop aL, i0
break_ge r6.w, c31.x
mul r0.xyz, r2.xzyw, c37.xxyw
add r0.xyz, r0, c40
add r0.zw, r0.xyxz, c48.w
mul r0.zw, r0, c49.x
mul r5.xy, r0.zwzw, c49.y
abs r5.xy, r5
frc r5.xy, r5
mul r5.xy, r5, c49.x
cmp r0.zw, r0, r5.xyxy, -r5.xyxy
frc r5.x, r0.w
add r0.x, -r5, r0.w
mad r0.x, r0, c49.z, r0.z
add r0.x, r0, c49.w
mov r0.w, c46.y
mov r0.z, c46.x
mul r0.x, r0, c50
texldl r0.xy, r0.xyzz, s0
add r0.y, r0, -r0.x
mad r0.x, r5, r0.y, r0
add r0.x, r0, c50.y
mul r0.x, r0, c47
add r5.z, r0.x, c39.x
mul r0.xyz, r2, c16.x
dp4 r5.y, r0, c10
dp4 r5.x, r0, c8
add r0.xyz, r2, -c12
dp3 r0.z, r0, r0
add r5.xy, r5, c46.y
mul r0.xy, r5, c47.z
rsq r0.z, r0.z
mov r0.w, c14.x
rcp r0.z, r0.z
add r0.w, c33.x, r0
add r8.y, r0.z, -r0.w
rcp r5.x, c34.x
mul_sat r5.x, r8.y, r5
mul r5.y, r5.x, r5.x
mov r0.z, c46.x
texldl r0, r0.xyzz, s1
mul r5.y, r5, r5
mul r5.y, r5, r5
mad r6.x, -r5.y, r5.y, c46.y
mul r5.y, r5.x, c47.w
add r0, r0, c35
mul r0, r0, c36
mul r0, r0, r6.x
add r5.x, r5.y, c48.z
cmp r6.x, r5, c46.y, c46
add r6.y, r0, -r0.x
mad r6.y, r5, r6, r0.x
add r5.x, -r6, c46.y
mul r6.y, r5.x, r6
mad r7.z, r5, c38.x, r6.y
add r5.x, r5.y, c48.y
cmp r5.x, r5, c46.y, c46
add r5.z, -r5.x, c46.y
mul r5.z, r6.x, r5
add r6.z, r0, -r0.y
add r6.y, r5, c48.z
mad r6.y, r6, r6.z, r0
mad r6.y, r5.z, r6, r7.z
add r6.x, r0.w, -r0.z
add r5.z, r5.y, c48.y
mad r5.z, r5, r6.x, r0
mad r5.x, r5, r5.z, r6.y
add r5.z, r0.y, -r0
add_sat r6.x, -r5.y, c47
mul r6.y, r6.x, r5.z
mad r6.y, r6, c47.z, r0.z
add r5.z, r0.x, -r0.y
add_sat r0.x, -r5.y, c46.y
mul r5.z, r0.x, r5
mad r5.z, r5, c47, r0.y
mul r6.x, r6, r6.y
mad r5.z, r0.x, r5, r6.x
add_sat r0.y, -r5, c47.w
add r0.z, r0, -r0.w
mul r0.z, r0.y, r0
mad r0.x, r0.z, c47.z, r0.w
mad r0.w, r0.y, r0.x, r5.z
mov r0.xyz, c18
dp3 r0.y, c13, r0
max r0.y, r0, c50.z
rcp r0.z, r0.y
mov r5.z, c43.x
add r5.z, c46.y, -r5
mul r0.x, r5.y, r5.z
mul r0.x, r0, c48
add r0.y, -r8, c34.x
mul r0.y, r0, r0.z
add r0.x, r0, c43
mul r5.y, r0.w, r0
max r5.x, r5, c46
mul r0.x, r0, c42
mul r7.zw, r0.x, r5.xyxy
mul r5.x, r7.w, -c29
pow r0, c50.w, r5.x
add r0.y, r4.w, r2.w
add r6.z, r8.y, c33.x
add r7.w, r6.z, -c27
rcp r0.z, r2.w
add r0.y, r0, -r7.x
add r0.w, -r4, r7.y
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r0.y, -r0, r0.w, c46
mul r0.x, r0, r0.y
mul r5.xyz, r0.x, v1
mov r0.xyz, r2
mov r0.w, c46.y
dp4 r6.y, r0, c5
dp4 r6.x, r0, c4
cmp_pp r0.x, r7.w, c46, c46.y
cmp r8.x, r7.w, c46.y, r8
if_gt r0.x, c46.x
mov r0.xy, r6
mov r0.w, c26.x
add r6.x, -c27, r0.w
rcp r6.y, r6.x
mov r0.z, c46.x
texldl r0, r0.xyzz, s2
add r7.w, r0.x, c48.z
add r6.x, r6.z, -c27
mul_sat r6.x, r6, r6.y
mul r6.y, r6.x, r6.x
mad r6.x, -r6, c47, c47.w
mul r6.x, r6.y, r6
mov r0.x, c26.y
add r6.y, -c27, r0.x
mad r0.x, r6, r7.w, c46.y
rcp r6.y, r6.y
add r6.x, r6.z, -c27.y
mul_sat r6.x, r6, r6.y
add r7.w, r0.y, c48.z
mad r6.y, -r6.x, c47.x, c47.w
mul r0.y, r6.x, r6.x
mul r6.x, r0.y, r6.y
mad r6.x, r6, r7.w, c46.y
mov r0.y, c26.z
mul r0.x, r0, r6
add r0.y, -c27.z, r0
rcp r6.x, r0.y
add r0.y, r6.z, -c27.z
mul_sat r0.y, r0, r6.x
add r6.y, r0.z, c48.z
mad r6.x, -r0.y, c47, c47.w
mul r0.z, r0.y, r0.y
mul r0.z, r0, r6.x
mov r0.y, c26.w
add r6.x, -c27.w, r0.y
mad r0.y, r0.z, r6, c46
rcp r6.x, r6.x
add r0.z, r6, -c27.w
mul_sat r0.z, r0, r6.x
add r6.x, r0.w, c48.z
mad r0.w, -r0.z, c47.x, c47
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r6.x, c46.y
mul r0.x, r0, r0.y
mul r8.x, r0, r0.z
endif
add r0.xyz, -r2, c23
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r0, c18
mul r0.x, r0, c30
add r0.y, r0.x, c46
mul r0.x, -c30, c30
rcp r6.x, r0.y
add r7.w, r0.x, c46.y
mul r6.y, r7.w, r6.x
mov r0.xyz, c24
mul r8.z, r6.y, r6.x
add r6.xyz, -c23, r0
dp3 r6.y, r6, r6
add r0.xyz, -r2, c20
dp3 r6.x, r0, r0
rsq r6.x, r6.x
mul r0.xyz, r6.x, r0
dp3 r0.x, r0, c18
rcp r0.w, r0.w
mul r0.y, r0.w, c48.w
rsq r6.y, r6.y
rcp r6.y, r6.y
mul r0.x, r0, c30
mul r0.y, r0, r0
add r0.x, r0, c46.y
rcp r6.x, r6.x
rcp r0.x, r0.x
mul r6.y, r6, r8.z
rcp r0.y, r0.y
mul r0.z, r6.y, r0.y
mul r0.y, r7.w, r0.x
mul r6.y, r0.z, c48.w
mul r0.w, r0.y, r0.x
mov r0.xyz, c21
add r0.xyz, -c20, r0
dp3 r0.x, r0, r0
mul r6.x, r6, c48.w
mul r0.y, r6.x, r6.x
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c48
min r0.y, r6, c46
add r6.x, -r8.y, c34
min r0.w, r0, c46.y
mul r0.xyz, r0.y, c25
mad r0.xyz, r0.w, c22, r0
mov r0.w, c29.x
mul r7.w, c51.y, r0
mul r8.y, -r7.w, r6.x
mul r6.xyz, r0, c51.x
pow r0, c50.w, r8.y
mul r5.xyz, r5, r8.x
mad r5.xyz, r3.w, r5, r6
mov r0.w, r0.x
add r6.xyz, v0, c19
mul r0.xyz, r7.w, r6
mul r0.xyz, r0, r0.w
mov r0.w, c42.x
mul r0.w, c28.x, r0
mul r5.xyz, r0.w, r5
mul r0.w, r7.z, -c29.x
mul r0.xyz, r0, c45.x
mad r0.xyz, r5, c51.z, r0
mul r0.xyz, r7.z, r0
mul r5.xyz, r0, r2.w
mul r6.x, r2.w, r0.w
pow r0, c50.w, r6.x
mad r4.xyz, r5, r3, r4
add r2.xyz, r2, r1
mul r3.xyz, r3, r0.x
add r4.w, r2, r4
add r5.w, r7.z, r5
add r6.w, r6, c46.y
endloop
rcp r0.y, c31.x
add r0.x, r1.w, -r4.w
mul r0.y, r5.w, r0
min r0.x, r0, c44
mul r0.y, r0, -c29.x
mul r1.x, r0.y, r0
pow r0, c50.w, r1.x
mul r0.xyz, r3, r0.x
dp3 oC0.w, r0, c52
mul oC0.xyz, r4, c41
endif

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #7 mixes the lowest layer's density texture with our fog layered-density
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
Float 16 [_FogAltitudeKm]
Vector 17 [_FogThicknessKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c18, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
add r0.x, -r0, c18.z
mov r0.y, c9.x
mov r0.w, c10.x
add r0.y, c16.x, r0
add r0.w, -c9.x, r0
add r0.y, r0, c17.x
mul r0.x, r0, c18.y
rcp r0.w, r0.w
add r0.y, r0, -c9.x
mul r0.y, r0, r0.w
mov r0.z, c18.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c18.w, r1.x
mov r1.x, r0
pow r0, c18.w, r1.z
mov r1.z, r0
pow r2, c18.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c18.yyzx, s1
mov r1.zw, c18.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c18.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c18.x
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
Float 8 [_WorldUnit2Kilometer]
Float 9 [_Kilometer2WorldUnit]
Vector 10 [_NuajLocalCoverageOffset]
Vector 11 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 0 [_NuajLocalCoverageTransform]
Float 12 [_FogLayerIndex]
Vector 13 [_DensityOffset]
Vector 14 [_DensityFactor]
Matrix 4 [_Density2World]
SetTexture 1 [_MainTex] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[16] = { program.local[0..14],
		{ 0, 1, 2, 0.5 } };
TEMP R0;
TEMP R1;
TEMP R2;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R2.xyz, c[15];
SEQR  H0.xyz, c[12].x, R2;
SEQX  H1.xyz, H0, c[15].x;
MOVR  R1.yw, c[15].xxzy;
MADR  R1.xz, fragment.texcoord[0].xyyw, c[15].z, -c[15].y;
DP4R  R0.z, R1, c[6];
DP4R  R0.x, R1, c[4];
DP4R  R0.y, R1, c[5];
MULR  R0.xyz, R0, c[8].x;
MULR  R1.xyz, R0, c[9].x;
MOVR  R1.w, c[15].y;
DP4R  R0.x, R1, c[0];
DP4R  R0.y, R1, c[2];
MADR  R0.xy, R0, c[15].w, c[15].w;
MOVR  R1, c[10];
TEX   R0, R0, texture[0], 2D;
MADR  R0, R0, c[11], R1;
MULXC HC.x, H1, H0.y;
MOVR  R0.x(NE), R0.y;
MULX  H0.x, H1, H1.y;
MULXC HC.x, H0, H0.z;
MOVR  R0.x(NE), R0.z;
MULXC HC.x, H0, H1.z;
MOVR  R0.x(NE), R0.w;
MULR  R1, R0.x, c[14];
TEX   R0, fragment.texcoord[0], texture[1], 2D;
ADDR  R0, R0, c[13];
MULR  oCol, R1, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 8 [_WorldUnit2Kilometer]
Float 9 [_Kilometer2WorldUnit]
Vector 10 [_NuajLocalCoverageOffset]
Vector 11 [_NuajLocalCoverageFactor]
SetTexture 0 [_NuajLocalCoverageTexture] 2D
Matrix 0 [_NuajLocalCoverageTransform]
Float 12 [_FogLayerIndex]
Vector 13 [_DensityOffset]
Vector 14 [_DensityFactor]
Matrix 4 [_Density2World]
SetTexture 1 [_MainTex] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
def c15, 1.00000000, 0.00000000, -1.00000000, -2.00000000
def c16, 2.00000000, -1.00000000, 0.50000000, 0
dcl_texcoord0 v0.xyzw
mov r1.yw, c15.xyzx
mad r1.xz, v0.xyyw, c16.x, c16.y
dp4 r0.z, r1, c6
dp4 r0.x, r1, c4
dp4 r0.y, r1, c5
mul r0.xyz, r0, c8.x
mul r1.xyz, r0, c9.x
mov r1.w, c15.x
dp4 r0.x, r1, c0
dp4 r0.y, r1, c2
mov r1.x, c12
add r1.z, c15, r1.x
abs r1.y, c12.x
cmp r1.x, -r1.y, c15, c15.y
abs_pp r1.y, r1.x
abs r1.z, r1
cmp r1.x, -r1.z, c15, c15.y
cmp_pp r1.y, -r1, c15.x, c15
add r0.xy, r0, c15.x
mov r1.z, c12.x
mul_pp r1.w, r1.y, r1.x
add r1.z, c15.w, r1
mov r0.z, c15.y
mul r0.xy, r0, c16.z
texldl r0, r0.xyzz, s0
mul r0, r0, c11
add r0, r0, c10
cmp r0.y, -r1.w, r0.x, r0
abs_pp r0.x, r1
abs r1.x, r1.z
cmp_pp r0.x, -r0, c15, c15.y
mul_pp r0.x, r1.y, r0
cmp r1.x, -r1, c15, c15.y
mul_pp r1.y, r0.x, r1.x
cmp r0.y, -r1, r0, r0.z
abs_pp r1.x, r1
cmp_pp r0.z, -r1.x, c15.x, c15.y
mul_pp r0.x, r0, r0.z
texldl r1, v0, s1
cmp r0.x, -r0, r0.y, r0.w
add r1, r1, c13
mul r0, r0.x, c14
mul oC0, r0, r1

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #8 Upscales the rendering using ACCURATE technique
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
Float 16 [_FogAltitudeKm]
Vector 17 [_FogThicknessKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c18, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
add r0.x, -r0, c18.z
mov r0.y, c9.x
mov r0.w, c10.x
add r0.y, c16.x, r0
add r0.w, -c9.x, r0
add r0.y, r0, c17.x
mul r0.x, r0, c18.y
rcp r0.w, r0.w
add r0.y, r0, -c9.x
mul r0.y, r0, r0.w
mov r0.z, c18.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c18.w, r1.x
mov r1.x, r0
pow r0, c18.w, r1.z
mov r1.z, r0
pow r2, c18.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c18.yyzx, s1
mov r1.zw, c18.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c18.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c18.x
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
Vector 12 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 13 [_PlanetCenterKm]
Vector 14 [_PlanetNormal]
Float 15 [_PlanetRadiusKm]
Float 16 [_PlanetAtmosphereRadiusKm]
Float 17 [_WorldUnit2Kilometer]
Float 18 [_Kilometer2WorldUnit]
Float 19 [_bComputePlanetShadow]
Vector 20 [_SunColor]
Vector 21 [_SunDirection]
SetTexture 3 [_TexAmbientSky] 2D
Vector 22 [_SoftAmbientSky]
Vector 23 [_AmbientNightSky]
SetTexture 2 [_TexShadowEnvMapSky] 2D
Vector 24 [_NuajLightningPosition00]
Vector 25 [_NuajLightningPosition01]
Vector 26 [_NuajLightningColor0]
Vector 27 [_NuajLightningPosition10]
Vector 28 [_NuajLightningPosition11]
Vector 29 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 30 [_ShadowAltitudesMinKm]
Vector 31 [_ShadowAltitudesMaxKm]
SetTexture 7 [_TexShadowMap] 2D
Vector 32 [_Sigma_Rayleigh]
Float 33 [_DensitySeaLevel_Mie]
Float 34 [_Sigma_Mie]
Float 35 [_MiePhaseAnisotropy]
SetTexture 4 [_TexDensity] 2D
SetTexture 1 [_TexDownScaledZBuffer] 2D
SetTexture 5 [_NuajTexNoise3D0] 2D
Float 36 [_StepsCount]
Float 37 [_MaxStepSizeKm]
Float 38 [_FogAltitudeKm]
Vector 39 [_FogThicknessKm]
Vector 40 [_DensityOffset]
Vector 41 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 6 [_TexLayeredDensity] 2D
Vector 42 [_NoiseTiling]
Float 43 [_NoiseAmplitude]
Float 44 [_NoiseOffset]
Vector 45 [_NoisePosition]
Vector 46 [_FogColor]
Float 47 [_MieDensityFactor]
Float 48 [_DensityRatioBottom]
Float 49 [_FogMaxDistance]
Float 50 [_IsotropicSkyFactor]
SetTexture 8 [_MainTex] 2D
Float 51 [_ZBufferDiscrepancyThreshold]
Float 52 [_ShowZBufferDiscrepancies]
Vector 53 [_dUV]
Vector 54 [_InvdUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[63] = { program.local[0..54],
		{ 1, 0.5, 2.718282, 2 },
		{ -1, 0, 0.995, 1000000 },
		{ 1000000, -1000000, 500000, 1.5 },
		{ 0, 1, 3, 0.33329999 },
		{ 255, 0, 1, 1000 },
		{ 16, 0.0625, 17, 0.25 },
		{ 0.0036764706, 0.0099999998, 10, 12.566371 },
		{ 0.60000002, 0.21259999, 0.71520001, 0.0722 } };
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
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
ADDR  R1.zw, fragment.texcoord[0].xyxy, c[53].xyxz;
ADDR  R0.xy, R1.zwzw, c[53].zyzw;
ADDR  R1.xy, R0, -c[53].xzzw;
ADDR  R0.zw, R1.xyxy, -c[53].xyzy;
TEX   R0.x, R0, texture[1], 2D;
TEX   R1.x, R1, texture[1], 2D;
ADDR  R0.y, R1.x, -R0.x;
TEX   R1.x, fragment.texcoord[0], texture[1], 2D;
TEX   R2.x, R1.zwzw, texture[1], 2D;
MULR  R2.zw, R0, c[54].xyxy;
FRCR  R1.zw, R2;
ADDR  R1.y, R2.x, -R1.x;
MADR  R0.x, R1.z, R0.y, R0;
MADR  R0.y, R1.z, R1, R1.x;
ADDR  R1.y, R0.x, -R0;
ADDR  R1.x, c[12].w, -c[12].z;
RCPR  R1.x, R1.x;
MULR  R1.x, R1, c[12].w;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R0.x, R1, -R0;
RCPR  R0.x, R0.x;
MULR  R1.x, R1, c[12].z;
MADR  R0.y, R1.w, R1, R0;
MULR  R2.w, R1.x, R0.x;
ADDR  R0.x, R2.w, -R0.y;
SGTRC HC.x, |R0|, c[51];
IF    NE.x;
MULR  R1.xy, R0.zwzw, c[12];
MOVR  R0.xy, c[12];
MADR  R0.xy, R1, c[55].w, -R0;
MOVR  R0.z, c[56].x;
DP3R  R0.w, R0, R0;
RSQR  R3.z, R0.w;
MULR  R1.xyz, R3.z, R0;
MOVR  R1.w, c[56].y;
MOVR  R0.w, c[38].x;
ADDR  R6.y, R0.w, c[15].x;
DP4R  R5.z, R1, c[2];
DP4R  R5.y, R1, c[1];
DP4R  R5.x, R1, c[0];
MOVR  R1.xy, c[57];
ADDR  R0.w, R6.y, c[39].x;
MOVR  R0.x, c[0].w;
MOVR  R0.z, c[2].w;
MOVR  R0.y, c[1].w;
MULR  R0.xyz, R0, c[17].x;
ADDR  R2.xyz, R0, -c[13];
DP3R  R5.w, R5, R2;
DP3R  R2.z, R2, R2;
MULR  R6.x, R5.w, R5.w;
MADR  R2.x, -R0.w, R0.w, R2.z;
SLTRC HC.x, R6, R2;
MOVR  R1.xy(EQ.x), R3;
ADDR  R1.z, R6.x, -R2.x;
RSQR  R1.z, R1.z;
RCPR  R1.w, R1.z;
ADDR  R1.z, -R5.w, -R1.w;
MADR  R6.z, -R6.y, R6.y, R2;
SGERC HC.x, R6, R2;
ADDR  R1.w, -R5, R1;
MOVR  R1.xy(NE.x), R1.zwzw;
ADDR  R2.x, R6, -R6.z;
RSQR  R2.x, R2.x;
RCPR  R2.y, R2.x;
ADDR  R2.x, -R5.w, -R2.y;
MOVR  R1.zw, c[57].xyxy;
SLTRC HC.x, R6, R6.z;
MOVR  R1.zw(EQ.x), R3.xyxy;
MOVR  R3.y, R1;
SGERC HC.x, R6, R6.z;
ADDR  R2.y, -R5.w, R2;
MOVR  R1.zw(NE.x), R2.xyxy;
MOVR  R3.x, R1.w;
MOVR  R2.x, R1;
RSQR  R1.x, R2.z;
RCPR  R1.x, R1.x;
SGTR  H0.y, R1.x, R0.w;
SLTR  H0.x, R1, R6.y;
SEQX  H0.x, H0, c[56].y;
MULX  H0.z, H0.x, H0.y;
SLTR  H0.w, R1.z, c[57].z;
MULXC HC.x, H0.z, H0.w;
MOVR  R2.y, R1.z;
SEQX  H0.y, H0, c[56];
MOVR  R3.xy(NE.x), R2;
SEQX  H0.w, H0, c[56].y;
MULXC HC.x, H0.z, H0.w;
MOVR  R3.xy(NE.x), c[56].yxzw;
MULX  H0.x, H0, H0.y;
SLTR  H0.z, R1, c[56].y;
MULXC HC.x, H0, H0.z;
MOVR  R1.x, c[56].y;
MOVR  R3.xy(NE.x), R1;
SEQX  H0.y, H0.z, c[56];
MOVR  R1.y, R1.z;
MULXC HC.x, H0, H0.y;
MOVR  R1.x, c[56].y;
MOVR  R3.xy(NE.x), R1;
MADR  R1.y, -c[15].x, c[15].x, R2.z;
ADDR  R1.z, R6.x, -R1.y;
RSQR  R1.z, R1.z;
MOVR  R1.x, c[56].w;
SLTRC HC.x, R6, R1.y;
MOVR  R1.x(EQ), R3.w;
SGERC HC.x, R6, R1.y;
RCPR  R1.z, R1.z;
ADDR  R1.x(NE), -R5.w, -R1.z;
MOVXC RC.x, R1;
RCPR  R1.y, R3.z;
MOVR  R1.x(LT), c[56].w;
MULR  R1.y, R2.w, R1;
MADR  R1.z, -R1.y, c[17].x, R1.x;
MOVR  R1.x, c[56].z;
MULR  R1.x, R1, c[12].w;
SGER  H0.x, R2.w, R1;
MULR  R1.y, R1, c[17].x;
MADR  R1.x, H0, R1.z, R1.y;
MOVR  R2, c[58].xxxy;
MAXR  R6.z, R3.x, c[56].y;
MINR  R1.x, R1, R3.y;
MINR  R3.x, R1, c[49];
SGTRC HC.x, R6.z, R3;
MOVR  R2(EQ.x), R4;
MOVR  R4, R2;
MOVR  R1.x, c[55];
SLTRC HC.x, c[36], R1;
MOVR  R1.xyz, c[14];
DP3R  R1.x, R1, c[21];
MOVR  R1.w, c[36].x;
MOVR  R1.w(NE.x), c[55].x;
MOVR  R2.x, c[15];
ADDR  R2.x, -R2, c[16];
SLERC HC.x, R6.z, R3;
RCPR  R1.y, R2.x;
ADDR  R0.w, R0, -c[15].x;
MULR  R1.y, R0.w, R1;
MADR  R1.x, -R1, c[55].y, c[55].y;
TEX   R2.zw, R1, texture[4], 2D;
MULR  R0.w, R2, c[34].x;
MADR  R1.xyz, R2.z, -c[32], -R0.w;
POWR  R2.x, c[55].z, R1.x;
POWR  R2.y, c[55].z, R1.y;
POWR  R2.z, c[55].z, R1.z;
TEX   R1.xyz, c[55].y, texture[3], 2D;
ADDR  R1.xyz, R1, c[22];
TEX   R0.w, c[55].y, texture[2], 2D;
MOVR  R6.w, R3.x;
MULR  R2.xyz, R2, c[20];
MULR  R1.xyz, R0.w, R1;
IF    NE.x;
ADDR  R3.xyz, R0, -c[13];
MULR  R4.xyz, R3.zxyw, c[21].yzxw;
MADR  R4.xyz, R3.yzxw, c[21].zxyw, -R4;
DP3R  R3.x, R3, c[21];
SLER  H0.x, R3, c[56].y;
DP3R  R0.w, R4, R4;
MULR  R7.xyz, R5.zxyw, c[21].yzxw;
MADR  R7.xyz, R5.yzxw, c[21].zxyw, -R7;
DP3R  R2.w, R4, R7;
DP3R  R4.x, R7, R7;
MADR  R0.w, -c[15].x, c[15].x, R0;
MULR  R4.z, R4.x, R0.w;
MULR  R4.y, R2.w, R2.w;
ADDR  R0.w, R4.y, -R4.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R3.y, -R2.w, R0.w;
ADDR  R0.w, -R2, -R0;
MOVR  R3.z, c[57].y;
MOVR  R3.x, c[57];
SGTR  H0.y, R4, R4.z;
MULX  H0.x, H0, c[19];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R4.x, R4.x;
MULR  R3.z(NE.x), R4.x, R3.y;
MULR  R3.x(NE), R0.w, R4;
MOVR  R3.y, R3.z;
MOVR  R11.xy, R3;
MADR  R3.xyz, R5, R3.x, R0;
ADDR  R3.xyz, R3, -c[13];
DP3R  R0.w, R3, c[21];
SGTR  H0.y, R0.w, c[56];
MULXC HC.x, H0, H0.y;
ADDR  R0.w, R6, -R6.z;
RCPR  R2.w, R1.w;
MULR  R2.w, R0, R2;
MINR  R2.w, R2, c[37].x;
MADR  R7.w, R2, c[55].y, R6.z;
DP3R  R0.w, R5, c[21];
MULR  R0.w, R0, c[35].x;
MADR  R7.xyz, R5, R7.w, R0;
MULR  R0.w, R0, c[55];
MADR  R0.x, c[35], c[35], R0.w;
ADDR  R0.y, R0.x, c[55].x;
MOVR  R0.x, c[55];
POWR  R0.y, R0.y, c[57].w;
ADDR  R0.x, R0, c[35];
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0;
MOVR  R11.xy(NE.x), c[57];
MULR  R6.xyz, R5, R2.w;
MULR  R5.w, R0.x, R0.y;
MOVR  R8.xyz, c[55].x;
MOVR  R9.xyz, c[56].y;
MOVR  R8.w, c[56].y;
MOVR  R9.w, c[56].y;
LOOP c[59];
SLTRC HC.x, R9.w, R1.w;
BRK   (EQ.x);
MOVR  R0.xyz, c[45];
MADR  R0.xyz, R7.xzyw, c[42].xxyw, R0;
ADDR  R0.zw, R0.xyxz, c[59].w;
MULR  R3.xy, R0.zwzw, c[60].x;
MULR  R0.zw, R3.xyxy, c[60].y;
MOVXC RC.xy, R3;
ADDR  R3.xyz, R7, -c[13];
DP3R  R0.x, R3, R3;
FRCR  R0.zw, |R0|;
MULR  R4.xy, R0.zwzw, c[60].x;
MOVR  R0.zw, R4.xyxy;
MOVR  R0.zw(LT.xyxy), -R4.xyxy;
MOVR  R3.x, c[38];
RSQR  R0.x, R0.x;
ADDR  R3.x, R3, c[15];
RCPR  R0.x, R0.x;
ADDR  R10.w, R0.x, -R3.x;
FLRR  R3.x, R0.w;
MADR  R0.x, R3, c[60].z, R0.z;
ADDR  R0.z, R0.w, -R3.x;
ADDR  R4.x, R10.w, c[38];
RCPR  R3.z, c[39].x;
MULR_SAT R4.w, R10, R3.z;
MULR  R10.x, R4.w, c[58].z;
ADDR  R0.x, R0, c[60].w;
MULR  R0.x, R0, c[61];
TEX   R0.xy, R0, texture[5], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.z, R0.y, R0;
SGER  H0.xy, R10.x, c[55].wxzw;
MOVR  R0.w, c[55].x;
MOVR  R4.y, c[55].x;
SGERC HC.x, R4, c[31].w;
MOVR  R4.y(EQ.x), R3.w;
SLTRC HC.x, R4, c[31].w;
ADDR  R0.x, R0, -c[55].y;
MOVR  R0.y, c[44].x;
MADR  R4.z, R0.x, c[55].w, R0.y;
MULR  R0.xyz, R7, c[18].x;
DP4R  R3.y, R0, c[10];
DP4R  R3.x, R0, c[8];
MADR  R0.xy, R3, c[55].y, c[55].y;
MULR  R3.x, R4.w, R4.w;
TEX   R0, R0, texture[6], 2D;
MULR  R3.x, R3, R3;
ADDR  R0, R0, c[40];
MULR  R3.x, R3, R3;
MULR  R3.x, R3, R3;
MULR  R0, R0, c[41];
MADR  R0, -R3.x, R0, R0;
ADDR  R3, R0.wzyz, -R0.zyxw;
MADR  R3.z, R10.x, R3, R0.x;
MADR  R3.z, -H0.y, R3, R3;
MADR  R3.y, R10.x, R3, -R3;
MADR  R3.z, R4, c[43].x, R3;
ADDR  R4.z, R0.y, R3.y;
MADR  R3.y, -H0.x, H0, H0;
MADR  R3.z, R3.y, R4, R3;
ADDR  R3.y, R10.x, -c[55].w;
MADR  R3.x, R3.y, R3, R0.z;
MADR  R3.x, H0, R3, R3.z;
MAXR  R3.z, R3.x, c[56].y;
ADDR  R4.zw, R0.xyxy, -R0.xyyz;
ADDR_SAT R3.xy, -R10.x, c[55].xwzw;
MULR  R4.zw, R3.xyxy, R4;
MADR  R0.xy, R4.wzzw, c[55].y, R0.zyzw;
ADDR_SAT R4.z, -R10.x, c[58];
MULR  R0.z, R3.w, R4;
MULR  R0.x, R3.y, R0;
MADR  R3.x, R3, R0.y, R0;
MADR  R0.w, R0.z, c[55].y, R0;
MOVR  R0.xyz, c[14];
DP3R  R0.x, R0, c[21];
MULR  R0.y, R10.x, c[58].w;
MAXR  R0.x, R0, c[61].y;
RCPR  R0.z, R0.x;
ADDR  R0.x, -R10.w, c[39];
MULR  R0.z, R0.x, R0;
MADR  R0.w, R4.z, R0, R3.x;
MULR  R3.w, R0, R0.z;
MADR  R0.y, R0, -c[48].x, R0;
ADDR  R0.x, R0.y, c[48];
MULR  R0.x, R0, c[47];
MULR  R11.zw, R0.x, R3;
MULR  R0.x, R11.w, -c[34];
POWR  R0.w, c[55].z, R0.x;
ADDR  R0.x, R7.w, R2.w;
RCPR  R0.y, R2.w;
ADDR  R0.x, R0, -R11;
ADDR  R0.z, -R7.w, R11.y;
MULR_SAT R0.x, R0, R0.y;
MULR_SAT R0.z, R0.y, R0;
MULR  R0.x, R0, R0.z;
MADR  R0.x, -R0, R0.w, R0.w;
MULR  R10.xyz, R0.x, R2;
MOVR  R0.w, c[55].x;
MOVR  R0.xyz, R7;
MOVR  R3.w, R4.y;
DP4R  R12.y, R0, c[5];
DP4R  R12.x, R0, c[4];
IF    NE.x;
MOVR  R0, c[31];
ADDR  R3, -R0, c[30];
RCPR  R0.x, R3.y;
ADDR  R4, R4.x, -c[31];
MULR_SAT R0.x, R4.y, R0;
MOVR  R3.y, c[58].z;
MADR  R0.z, -R0.x, c[55].w, R3.y;
MULR  R0.y, R0.x, R0.x;
RCPR  R0.x, R3.x;
MULR_SAT R4.x, R4, R0;
MULR  R3.x, R0.y, R0.z;
TEX   R0, R12, texture[7], 2D;
MADR  R3.x, R0.y, R3, -R3;
MADR  R0.y, -R4.x, c[55].w, R3;
MULR  R4.x, R4, R4;
MULR  R0.y, R4.x, R0;
MADR  R0.x, R0, R0.y, -R0.y;
ADDR  R3.x, R3, c[55];
MADR  R0.x, R0, R3, R3;
RCPR  R0.y, R3.z;
RCPR  R3.x, R3.w;
MULR_SAT R3.z, R3.x, R4.w;
MULR_SAT R0.y, R0, R4.z;
MADR  R3.x, -R0.y, c[55].w, R3.y;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R3.x;
MADR  R3.x, -R3.z, c[55].w, R3.y;
MADR  R0.y, R0.z, R0, -R0;
MULR  R3.y, R3.z, R3.z;
MADR  R0.x, R0.y, R0, R0;
MULR  R3.x, R3.y, R3;
MADR  R0.y, R0.w, R3.x, -R3.x;
MADR  R3.w, R0.y, R0.x, R0.x;
ENDIF;
ADDR  R0.xyz, -R7, c[27];
DP3R  R0.w, R0, R0;
RSQR  R3.x, R0.w;
MULR  R0.xyz, R3.x, R0;
RCPR  R3.x, R3.x;
MOVR  R0.w, c[55].x;
DP3R  R0.x, R5, R0;
MADR  R0.x, R0, c[35], R0.w;
RCPR  R3.z, R0.x;
MULR  R3.y, c[35].x, c[35].x;
MADR  R4.x, -R3.y, R3.z, R3.z;
MOVR  R0.xyz, c[27];
MULR  R3.z, R4.x, R3;
ADDR  R0.xyz, -R0, c[28];
DP3R  R4.x, R0, R0;
ADDR  R0.xyz, -R7, c[24];
RSQR  R4.x, R4.x;
RCPR  R4.x, R4.x;
MULR  R4.x, R4, R3.z;
DP3R  R4.y, R0, R0;
RSQR  R3.z, R4.y;
MULR  R0.xyz, R3.z, R0;
DP3R  R0.x, R0, R5;
MADR  R0.x, R0, c[35], R0.w;
MULR  R3.x, R3, c[59].w;
MULR  R0.y, R3.x, R3.x;
RCPR  R0.y, R0.y;
MULR  R0.z, R4.x, R0.y;
RCPR  R0.x, R0.x;
MADR  R0.y, -R3, R0.x, R0.x;
RCPR  R3.y, R3.z;
MULR  R3.x, R0.z, c[59].w;
MULR  R0.w, R0.y, R0.x;
MOVR  R0.xyz, c[24];
ADDR  R0.xyz, -R0, c[25];
DP3R  R0.x, R0, R0;
MULR  R3.y, R3, c[59].w;
MULR  R0.y, R3, R3;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R0.x, R0, R0.w;
RCPR  R0.y, R0.y;
MULR  R0.x, R0, R0.y;
MINR  R0.y, R3.x, c[55].x;
MULR  R0.w, R0.x, c[59];
MULR  R3.xyz, R10, R3.w;
MINR  R0.w, R0, c[55].x;
MULR  R0.xyz, R0.y, c[29];
MADR  R0.xyz, R0.w, c[26], R0;
MOVR  R0.w, c[62].x;
MULR  R0.xyz, R0, c[61].z;
MADR  R0.xyz, R5.w, R3, R0;
MULR  R4.x, R0.w, c[34];
ADDR  R3.x, -R10.w, c[39];
MULR  R0.w, -R4.x, R3.x;
ADDR  R3.xyz, R1, c[23];
POWR  R0.w, c[55].z, R0.w;
MULR  R3.xyz, R4.x, R3;
MULR  R3.xyz, R3, R0.w;
MOVR  R0.w, c[33].x;
MULR  R0.w, R0, c[47].x;
MULR  R0.xyz, R0.w, R0;
MULR  R3.xyz, R3, c[50].x;
MADR  R0.xyz, R0, c[61].w, R3;
MULR  R0.xyz, R11.z, R0;
MULR  R0.xyz, R0, R2.w;
MADR  R9.xyz, R0, R8, R9;
MULR  R0.w, R11.z, -c[34].x;
MULR  R0.x, R2.w, R0.w;
POWR  R0.x, c[55].z, R0.x;
ADDR  R7.xyz, R7, R6;
MULR  R8.xyz, R8, R0.x;
ADDR  R7.w, R2, R7;
ADDR  R8.w, R11.z, R8;
ADDR  R9.w, R9, c[55].x;
ENDLOOP;
RCPR  R0.x, R1.w;
ADDR  R0.y, R6.w, -R7.w;
MULR  R0.x, R8.w, R0;
MINR  R0.y, R0, c[49].x;
MULR  R0.x, R0, -c[34];
MULR  R0.x, R0, R0.y;
POWR  R0.x, c[55].z, R0.x;
MULR  R0.xyz, R8, R0.x;
DP3R  R4.w, R0, c[62].yzww;
MULR  R4.xyz, R9, c[46];
ENDIF;
ADDR  R0, -R4, c[58].xyxx;
MADR  R0, R0, c[52].x, R4;
ELSE;
TEX   R0, R0.zwzw, texture[8], 2D;
ENDIF;
MOVR  oCol, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 12 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 13 [_PlanetCenterKm]
Vector 14 [_PlanetNormal]
Float 15 [_PlanetRadiusKm]
Float 16 [_WorldUnit2Kilometer]
Float 17 [_Kilometer2WorldUnit]
Float 18 [_bComputePlanetShadow]
Vector 19 [_SunDirection]
Vector 20 [_AmbientNightSky]
Vector 21 [_NuajLightningPosition00]
Vector 22 [_NuajLightningPosition01]
Vector 23 [_NuajLightningColor0]
Vector 24 [_NuajLightningPosition10]
Vector 25 [_NuajLightningPosition11]
Vector 26 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 27 [_ShadowAltitudesMinKm]
Vector 28 [_ShadowAltitudesMaxKm]
SetTexture 4 [_TexShadowMap] 2D
Float 29 [_DensitySeaLevel_Mie]
Float 30 [_Sigma_Mie]
Float 31 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDownScaledZBuffer] 2D
SetTexture 2 [_NuajTexNoise3D0] 2D
Float 32 [_StepsCount]
Float 33 [_MaxStepSizeKm]
Float 34 [_FogAltitudeKm]
Vector 35 [_FogThicknessKm]
Vector 36 [_DensityOffset]
Vector 37 [_DensityFactor]
Matrix 8 [_World2Density]
SetTexture 3 [_TexLayeredDensity] 2D
Vector 38 [_NoiseTiling]
Float 39 [_NoiseAmplitude]
Float 40 [_NoiseOffset]
Vector 41 [_NoisePosition]
Vector 42 [_FogColor]
Float 43 [_MieDensityFactor]
Float 44 [_DensityRatioBottom]
Float 45 [_FogMaxDistance]
Float 46 [_IsotropicSkyFactor]
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
def c51, -1.00000000, 1.00000000, 0.00000000, 2.00000000
def c52, 0.99500000, 1000000.00000000, -1000000.00000000, -500000.00000000
def c53, 1.50000000, 0.50000000, 3.00000000, 0.33329999
defi i0, 255, 0, 1, 0
def c54, -2.00000000, 1000.00000000, 16.00000000, 0.06250000
def c55, 17.00000000, 0.25000000, 0.00367647, -0.50000000
def c56, 0.01000000, 2.71828198, 2.00000000, 3.00000000
def c57, 10.00000000, 0.60000002, 12.56637096, 0
def c58, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
add r2.xy, v0, c49.xzzw
add r0.xy, r2, c49.zyzw
mov r2.z, v0.w
add r4.xy, r0, -c49.xzzw
mov r4.z, v0.w
texldl r1.x, r4.xyzz, s1
mov r0.z, v0.w
texldl r0.x, r0.xyzz, s1
add r0.y, r1.x, -r0.x
add r4.xy, r4, -c49.zyzw
mul r0.zw, r4.xyxy, c50.xyxy
frc r0.zw, r0
mad r0.y, r0.z, r0, r0.x
texldl r1.x, v0, s1
texldl r2.x, r2.xyzz, s1
add r1.y, r2.x, -r1.x
mad r0.z, r0, r1.y, r1.x
add r1.x, r0.y, -r0.z
add r0.x, c12.w, -c12.z
rcp r0.y, r0.x
mul r0.y, r0, c12.w
texldl r0.x, v0, s0
add r0.x, r0.y, -r0
mad r0.w, r0, r1.x, r0.z
rcp r0.z, r0.x
mul r0.x, r0.y, c12.z
mul r2.w, r0.x, r0.z
add r0.x, r2.w, -r0.w
abs r0.x, r0
mov r4.z, v0.w
if_gt r0.x, c47.x
mad r0.xy, r4, c51.w, c51.x
mov r0.z, c51.x
mul r0.xy, r0, c12
dp3 r0.w, r0, r0
rsq r4.w, r0.w
mov r0.w, c51.z
mul r0.xyz, r4.w, r0
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r4.xyz, r2, c16.x
add r0.xyz, r4, -c13
mov r0.w, c15.x
dp3 r2.z, r0, r0
add r2.x, c34, r0.w
dp3 r5.z, r1, r0
mad r0.w, -r2.x, r2.x, r2.z
mad r0.z, r5, r5, -r0.w
rsq r0.x, r0.z
rcp r0.y, r0.x
cmp_pp r2.y, r0.z, c51, c51.z
add r0.x, -r5.z, -r0.y
cmp r0.zw, r0.z, r3.xyxy, c52.xyyz
add r0.y, -r5.z, r0
cmp r0.xy, -r2.y, r0.zwzw, r0
add r2.y, r2.x, c35.x
mad r0.w, -r2.y, r2.y, r2.z
mad r5.y, r5.z, r5.z, -r0.w
add r0.z, r0.x, c52.w
cmp r5.x, r0.z, c51.z, c51.y
abs_pp r0.z, r5.x
cmp_pp r5.w, -r0.z, c51.y, c51.z
rsq r0.z, r2.z
rcp r0.z, r0.z
add r0.w, r0.z, -r2.x
add r2.x, -r0.z, r2.y
cmp r6.y, r2.x, c51.z, c51
cmp r0.w, r0, c51.z, c51.y
abs_pp r0.z, r0.w
rsq r6.w, r5.y
cmp_pp r6.x, -r0.z, c51.y, c51.z
rcp r0.w, r6.w
add r0.z, -r5, -r0.w
mul_pp r6.z, r6.x, r6.y
mul_pp r6.w, r6.z, r5.x
cmp_pp r5.x, r5.y, c51.y, c51.z
cmp r2.xy, r5.y, r3, c52.yzzw
add r0.w, -r5.z, r0
cmp r2.xy, -r5.x, r2, r0.zwzw
mov r5.x, r2
mov r0.z, r0.y
abs_pp r0.y, r6
mov r5.y, r0.x
mov r0.w, r2.y
cmp r0.zw, -r6.w, r0, r5.xyxy
mul_pp r2.x, r6.z, r5.w
cmp r0.zw, -r2.x, r0, c51.xyzx
cmp_pp r0.y, -r0, c51, c51.z
cmp r5.y, r0.x, c51.z, c51
mul_pp r5.x, r6, r0.y
mul_pp r0.y, r5.x, r5
mov r2.x, c51.z
cmp r0.zw, -r0.y, r0, r2.xyxy
abs_pp r2.x, r5.y
mad r0.y, -c15.x, c15.x, r2.z
cmp_pp r2.y, -r2.x, c51, c51.z
mad r2.x, r5.z, r5.z, -r0.y
mul_pp r2.z, r5.x, r2.y
mov r0.y, r0.x
rsq r2.y, r2.x
rcp r2.y, r2.y
mov r0.x, c51.z
cmp r0.xy, -r2.z, r0.zwzw, r0
cmp_pp r0.z, r2.x, c51.y, c51
cmp r0.w, r2.x, r1, c52.y
add r2.y, -r5.z, -r2
cmp r0.w, -r0.z, r0, r2.y
rcp r0.z, r4.w
cmp r1.w, r0, r0, c52.y
mul r0.w, r2, r0.z
mad r1.w, -r0, c16.x, r1
mov r0.z, c12.w
mad r0.z, c52.x, -r0, r2.w
max r2.z, r0.x, c51
mul r0.w, r0, c16.x
cmp r0.z, r0, c51.y, c51
mad r0.z, r0, r1.w, r0.w
min r0.y, r0.z, r0
min r0.x, r0.y, c45
add r0.y, -r0.x, r2.z
mov r2.w, r0.x
cmp_pp r0.z, -r0.y, c51.y, c51
cmp r3, -r0.y, r3, c51.zzzy
mov r0.y, c32.x
mov r0.x, c51.y
add r0.y, c51.x, r0
cmp r1.w, r0.y, c32.x, r0.x
if_gt r0.z, c51.z
add r0.xyz, r4, -c13
mul r3.xyz, r0.zxyw, c19.yzxw
mad r3.xyz, r0.yzxw, c19.zxyw, -r3
dp3 r0.w, r3, r3
dp3 r0.x, r0, c19
mul r5.xyz, r1.zxyw, c19.yzxw
mad r5.xyz, r1.yzxw, c19.zxyw, -r5
cmp r0.x, -r0, c51.y, c51.z
dp3 r2.x, r5, r5
mad r0.w, -c15.x, c15.x, r0
mul r2.y, r2.x, r0.w
dp3 r0.w, r3, r5
mad r2.y, r0.w, r0.w, -r2
rsq r3.x, r2.y
rcp r3.x, r3.x
rcp r3.z, r2.x
add r3.y, -r0.w, -r3.x
mul r0.z, r3.y, r3
cmp r0.y, -r2, c51.z, c51
mul_pp r0.x, r0, c18
mul_pp r2.y, r0.x, r0
cmp r2.x, -r2.y, c52.y, r0.z
mad r0.xyz, r1, r2.x, r4
add r0.xyz, r0, -c13
dp3 r0.x, r0, c19
add r0.y, -r0.w, r3.x
cmp r0.x, -r0, c51.z, c51.y
mul_pp r0.x, r2.y, r0
mul r0.y, r3.z, r0
cmp r2.y, -r2, c52.z, r0
dp3 r0.z, r1, c19
mul r0.y, r0.z, c31.x
cmp r7.xy, -r0.x, r2, c52.yzzw
mul r0.x, r0.y, c51.w
mad r0.x, c31, c31, r0
add r2.x, r0, c51.y
rcp r0.z, r1.w
add r0.y, r2.w, -r2.z
mul r0.y, r0, r0.z
min r3.w, r0.y, c33.x
pow r0, r2.x, c53.x
mad r5.w, r3, c53.y, r2.z
mad r3.xyz, r1, r5.w, r4
mov r0.y, c31.x
mov r0.z, r0.x
add r0.x, c51.y, r0.y
rcp r0.y, r0.z
mul r0.x, r0, r0
mul r4.w, r0.x, r0.y
mul r2.xyz, r1, r3.w
mov r4.xyz, c51.y
mov r5.xyz, c51.z
mov r6.w, c51.z
mov r8.w, c51.z
loop aL, i0
break_ge r8.w, r1.w
mul r0.xyz, r3.xzyw, c38.xxyw
add r0.xyz, r0, c41
add r0.zw, r0.xyxz, c54.y
mul r0.zw, r0, c54.z
mul r6.xy, r0.zwzw, c54.w
abs r6.xy, r6
frc r6.xy, r6
mul r6.xy, r6, c54.z
cmp r0.zw, r0, r6.xyxy, -r6.xyxy
frc r6.x, r0.w
add r0.x, -r6, r0.w
mad r0.x, r0, c55, r0.z
add r0.x, r0, c55.y
mov r0.w, c51.y
mov r0.z, c51
mul r0.x, r0, c55.z
texldl r0.xy, r0.xyzz, s2
add r0.y, r0, -r0.x
mad r0.x, r6, r0.y, r0
add r0.x, r0, c55.w
mul r0.x, r0, c51.w
add r6.z, r0.x, c40.x
mul r0.xyz, r3, c17.x
dp4 r6.y, r0, c10
dp4 r6.x, r0, c8
add r0.xyz, r3, -c13
dp3 r0.z, r0, r0
add r6.xy, r6, c51.y
mul r0.xy, r6, c53.y
rsq r0.z, r0.z
mov r0.w, c15.x
rcp r0.z, r0.z
add r0.w, c34.x, r0
add r9.y, r0.z, -r0.w
rcp r6.x, c35.x
mul_sat r6.x, r9.y, r6
mul r6.y, r6.x, r6.x
mov r0.z, c51
texldl r0, r0.xyzz, s3
mul r6.y, r6, r6
mul r6.y, r6, r6
mad r7.z, -r6.y, r6.y, c51.y
mul r6.y, r6.x, c53.z
add r0, r0, c36
mul r0, r0, c37
mul r0, r0, r7.z
add r6.x, r6.y, c51
cmp r7.z, r6.x, c51.y, c51
add r7.w, r0.y, -r0.x
mad r7.w, r6.y, r7, r0.x
add r6.x, -r7.z, c51.y
mul r7.w, r6.x, r7
mad r8.y, r6.z, c39.x, r7.w
add r6.x, r6.y, c54
cmp r6.x, r6, c51.y, c51.z
add r6.z, -r6.x, c51.y
mul r6.z, r7, r6
add r8.x, r0.z, -r0.y
add r7.w, r6.y, c51.x
mad r7.w, r7, r8.x, r0.y
mad r7.w, r6.z, r7, r8.y
add r7.z, r0.w, -r0
add r6.z, r6.y, c54.x
mad r6.z, r6, r7, r0
mad r6.x, r6, r6.z, r7.w
add r6.z, r0.y, -r0
add_sat r7.z, -r6.y, c51.w
mul r7.w, r7.z, r6.z
mad r7.w, r7, c53.y, r0.z
add r6.z, r0.x, -r0.y
add_sat r0.x, -r6.y, c51.y
mul r6.z, r0.x, r6
mad r6.z, r6, c53.y, r0.y
mul r7.z, r7, r7.w
mad r6.z, r0.x, r6, r7
add_sat r0.y, -r6, c53.z
add r0.z, r0, -r0.w
mul r0.z, r0.y, r0
mad r0.x, r0.z, c53.y, r0.w
mad r0.w, r0.y, r0.x, r6.z
mov r0.xyz, c19
dp3 r0.y, c14, r0
max r0.y, r0, c56.x
rcp r0.z, r0.y
mov r6.z, c44.x
add r6.z, c51.y, -r6
mul r0.x, r6.y, r6.z
mul r0.x, r0, c53.w
add r0.y, -r9, c35.x
mul r0.y, r0, r0.z
add r0.x, r0, c44
mul r6.y, r0.w, r0
max r6.x, r6, c51.z
mul r0.x, r0, c43
mul r7.zw, r0.x, r6.xyxy
mul r6.x, r7.w, -c30
pow r0, c56.y, r6.x
add r0.y, r5.w, r3.w
add r7.w, r9.y, c34.x
add r8.z, r7.w, -c28.w
rcp r0.z, r3.w
add r0.y, r0, -r7.x
add r0.w, -r5, r7.y
mul_sat r0.w, r0.z, r0
mul_sat r0.y, r0, r0.z
mad r0.y, -r0, r0.w, c51
mul r0.x, r0, r0.y
mul r6.xyz, r0.x, v2
mov r0.xyz, r3
mov r0.w, c51.y
dp4 r8.y, r0, c5
dp4 r8.x, r0, c4
cmp_pp r0.x, r8.z, c51.z, c51.y
cmp r9.x, r8.z, c51.y, r9
if_gt r0.x, c51.z
mov r0.xy, r8
mov r0.w, c27.x
add r8.x, -c28, r0.w
rcp r8.y, r8.x
add r8.x, r7.w, -c28
mul_sat r8.x, r8, r8.y
mul r8.y, r8.x, r8.x
mov r0.z, c51
texldl r0, r0.xyzz, s4
add r8.z, r0.x, c51.x
mad r8.x, -r8, c56.z, c56.w
mul r8.x, r8.y, r8
mov r0.x, c27.y
add r8.y, -c28, r0.x
mad r0.x, r8, r8.z, c51.y
rcp r8.y, r8.y
add r8.x, r7.w, -c28.y
mul_sat r8.x, r8, r8.y
add r8.z, r0.y, c51.x
mad r8.y, -r8.x, c56.z, c56.w
mul r0.y, r8.x, r8.x
mul r8.x, r0.y, r8.y
mad r8.x, r8, r8.z, c51.y
mov r0.y, c27.z
mul r0.x, r0, r8
add r0.y, -c28.z, r0
rcp r8.x, r0.y
add r0.y, r7.w, -c28.z
mul_sat r0.y, r0, r8.x
add r8.y, r0.z, c51.x
mad r8.x, -r0.y, c56.z, c56.w
mul r0.z, r0.y, r0.y
mul r0.z, r0, r8.x
mov r0.y, c27.w
add r8.x, -c28.w, r0.y
mad r0.y, r0.z, r8, c51
add r0.z, r7.w, -c28.w
rcp r8.x, r8.x
mul_sat r0.z, r0, r8.x
add r7.w, r0, c51.x
mad r0.w, -r0.z, c56.z, c56
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r7.w, c51.y
mul r0.x, r0, r0.y
mul r9.x, r0, r0.z
endif
add r0.xyz, -r3, c24
dp3 r0.w, r0, r0
rsq r0.w, r0.w
mul r0.xyz, r0.w, r0
dp3 r0.x, r1, r0
mul r0.x, r0, c31
add r0.y, r0.x, c51
mul r0.x, -c31, c31
rcp r8.x, r0.y
add r7.w, r0.x, c51.y
mul r8.y, r7.w, r8.x
mov r0.xyz, c25
mul r9.z, r8.y, r8.x
add r8.xyz, -c24, r0
dp3 r8.y, r8, r8
add r0.xyz, -r3, c21
dp3 r8.x, r0, r0
rsq r8.x, r8.x
mul r0.xyz, r8.x, r0
dp3 r0.x, r0, r1
rcp r0.w, r0.w
mul r0.y, r0.w, c54
rsq r8.y, r8.y
rcp r8.y, r8.y
mul r0.x, r0, c31
mul r0.y, r0, r0
add r0.x, r0, c51.y
rcp r8.x, r8.x
rcp r0.x, r0.x
mul r8.y, r8, r9.z
rcp r0.y, r0.y
mul r0.z, r8.y, r0.y
mul r0.y, r7.w, r0.x
mul r7.w, r0.z, c54.y
mul r0.w, r0.y, r0.x
mov r0.xyz, c22
add r0.xyz, -c21, r0
dp3 r0.x, r0, r0
mul r8.x, r8, c54.y
mul r0.y, r8.x, r8.x
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r0.w
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.w, r0.x, c54.y
min r0.y, r7.w, c51
add r8.x, -r9.y, c35
min r0.w, r0, c51.y
mul r0.xyz, r0.y, c26
mad r0.xyz, r0.w, c23, r0
mov r0.w, c30.x
mul r7.w, c57.y, r0
mul r9.y, -r7.w, r8.x
mul r8.xyz, r0, c57.x
pow r0, c56.y, r9.y
mul r6.xyz, r6, r9.x
mad r6.xyz, r4.w, r6, r8
mov r0.w, r0.x
add r8.xyz, v1, c20
mul r0.xyz, r7.w, r8
mul r0.xyz, r0, r0.w
mov r0.w, c43.x
mul r0.w, c29.x, r0
mul r6.xyz, r0.w, r6
mul r0.w, r7.z, -c30.x
mul r0.xyz, r0, c46.x
mad r0.xyz, r6, c57.z, r0
mul r0.xyz, r7.z, r0
mul r6.xyz, r0, r3.w
mul r7.w, r3, r0
pow r0, c56.y, r7.w
mad r5.xyz, r6, r4, r5
add r3.xyz, r3, r2
mul r4.xyz, r4, r0.x
add r5.w, r3, r5
add r6.w, r7.z, r6
add r8.w, r8, c51.y
endloop
rcp r0.y, r1.w
add r0.x, r2.w, -r5.w
mul r0.y, r6.w, r0
min r0.x, r0, c45
mul r0.y, r0, -c30.x
mul r1.x, r0.y, r0
pow r0, c56.y, r1.x
mul r0.xyz, r4, r0.x
dp3 r3.w, r0, c58
mul r3.xyz, r5, c42
endif
add r0, -r3, c51.zyzz
mad r0, r0, c48.x, r3
else
texldl r0, r4.xyzz, s5
endif
mov oC0, r0

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #9 Upscales the rendering using the SMART technique
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
Float 16 [_FogAltitudeKm]
Vector 17 [_FogThicknessKm]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
def c18, 0.00000000, 0.50000000, 1.00000000, 2.71828198
dcl_position0 v0
dcl_texcoord0 v1
dcl_2d s0
dcl_2d s1
dcl_2d s2
mov r0.xyz, c12
dp3 r0.x, c8, r0
add r0.x, -r0, c18.z
mov r0.y, c9.x
mov r0.w, c10.x
add r0.y, c16.x, r0
add r0.w, -c9.x, r0
add r0.y, r0, c17.x
mul r0.x, r0, c18.y
rcp r0.w, r0.w
add r0.y, r0, -c9.x
mul r0.y, r0, r0.w
mov r0.z, c18.x
texldl r0.zw, r0.xyzz, s2
mul r0.x, r0.w, c15
mad r1.xyz, r0.z, -c14, -r0.x
pow r0, c18.w, r1.x
mov r1.x, r0
pow r0, c18.w, r1.z
mov r1.z, r0
pow r2, c18.w, r1.y
mov r1.y, r2
mul o3.xyz, r1, c11
texldl r0.xyz, c18.yyzx, s1
mov r1.zw, c18.x
mov r1.xy, v1
add r0.xyz, r0, c13
texldl r0.w, c18.yyzx, s0
dp4 o1.x, r1, c4
dp4 o1.y, r1, c5
mul o2.xyz, r0.w, r0
mov o1.zw, c18.x
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
Float 8 [_FogAltitudeKm]
Vector 9 [_FogThicknessKm]
SetTexture 1 [_MainTex] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[13] = { program.local[0..9],
		{ 0, 2, -1, 500000 },
		{ 1000000, -1000000, 0.995 },
		{ 0, 1 } };
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
MOVR  R3.xyz, c[5];
MULR  R2.xy, fragment.texcoord[0], c[4];
MOVR  R1.xy, c[4];
MADR  R1.xy, R2, c[10].y, -R1;
MOVR  R1.z, c[10];
DP3R  R1.w, R1, R1;
RSQR  R2.w, R1.w;
MULR  R1.xyz, R2.w, R1;
MOVR  R1.w, c[10].x;
MOVR  R2.x, c[0].w;
MOVR  R2.y, c[1].w;
MOVR  R2.z, c[2].w;
MADR  R2.xyz, R2, c[7].x, -R3;
DP4R  R3.z, R1, c[2];
DP4R  R3.x, R1, c[0];
DP4R  R3.y, R1, c[1];
DP3R  R3.w, R2, R3;
MOVR  R1.x, c[8];
ADDR  R3.z, R1.x, c[6].x;
DP3R  R2.z, R2, R2;
ADDR  R4.y, R3.z, c[9].x;
MULR  R4.x, R3.w, R3.w;
MADR  R2.x, -R4.y, R4.y, R2.z;
ADDR  R1.z, R4.x, -R2.x;
RSQR  R1.z, R1.z;
RCPR  R1.w, R1.z;
ADDR  R1.z, -R3.w, -R1.w;
MOVR  R1.xy, c[11];
SLTRC HC.x, R4, R2;
MOVR  R1.xy(EQ.x), R0;
MADR  R3.x, -R3.z, R3.z, R2.z;
SGERC HC.x, R4, R2;
ADDR  R1.w, -R3, R1;
MOVR  R1.xy(NE.x), R1.zwzw;
ADDR  R2.x, R4, -R3;
RSQR  R2.x, R2.x;
RCPR  R2.y, R2.x;
ADDR  R2.x, -R3.w, -R2.y;
MOVR  R1.zw, c[11].xyxy;
SLTRC HC.x, R4, R3;
MOVR  R1.zw(EQ.x), R0.xyxy;
MOVR  R3.y, R1;
SGERC HC.x, R4, R3;
ADDR  R2.y, -R3.w, R2;
MOVR  R1.zw(NE.x), R2.xyxy;
SLTR  H0.zw, R1.z, c[10].xyxw;
MOVR  R2.x, R1;
RSQR  R1.x, R2.z;
RCPR  R1.x, R1.x;
SLTR  H0.x, R1, R3.z;
SGTR  H0.y, R1.x, R4;
SEQX  H0.x, H0, c[10];
MULX  H1.z, H0.x, H0.y;
SEQX  H0.y, H0, c[10].x;
MOVR  R3.x, R1.w;
MULX  H0.x, H0, H0.y;
MOVR  R2.y, R1.z;
MULXC HC.x, H0.w, H1.z;
MOVR  R3.xy(NE.x), R2;
SEQX  H1.xy, H0.zwzw, c[10].x;
MULXC HC.x, H1.y, H1.z;
MOVR  R3.xy(NE.x), c[10].xzzw;
MULXC HC.x, H0, H0.z;
MOVR  R1.x, c[10];
MOVR  R3.xy(NE.x), R1;
MOVR  R1.y, R1.z;
MULXC HC.x, H0, H1;
MOVR  R1.x, c[10];
MOVR  R3.xy(NE.x), R1;
MADR  R1.y, -c[6].x, c[6].x, R2.z;
ADDR  R1.z, R4.x, -R1.y;
RSQR  R1.z, R1.z;
MOVR  R1.x, c[11];
SLTRC HC.x, R4, R1.y;
MOVR  R1.x(EQ), R0;
SGERC HC.x, R4, R1.y;
RCPR  R1.z, R1.z;
ADDR  R1.x(NE), -R3.w, -R1.z;
MOVXC RC.x, R1;
ADDR  R1.z, c[4].w, -c[4];
RCPR  R1.z, R1.z;
MOVR  R1.x(LT), c[11];
MAXR  R1.y, R3.x, c[10].x;
TEX   R2.x, fragment.texcoord[0], texture[0], 2D;
MULR  R1.z, R1, c[4].w;
ADDR  R1.w, R1.z, -R2.x;
RCPR  R2.x, R2.w;
RCPR  R1.w, R1.w;
MULR  R1.z, R1, c[4];
MULR  R1.z, R1, R1.w;
MULR  R1.w, R1.z, R2.x;
MADR  R2.x, -R1.w, c[7], R1;
MOVR  R1.x, c[11].z;
MULR  R1.x, R1, c[4].w;
MULR  R1.w, R1, c[7].x;
SGER  H0.x, R1.z, R1;
MADR  R1.x, H0, R2, R1.w;
MINR  R1.x, R3.y, R1;
SGTRC HC.x, R1.y, R1;
MOVR  oCol, c[12].xxxy;
MOVR  oCol(EQ.x), R0;
SLERC HC.x, R1.y, R1;
IF    NE.x;
TEX   oCol, fragment.texcoord[0], texture[1], 2D;
ENDIF;
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
Float 8 [_FogAltitudeKm]
Vector 9 [_FogThicknessKm]
SetTexture 1 [_MainTex] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
def c10, 0.00000000, 1.00000000, 2.00000000, -1.00000000
def c11, 1000000.00000000, -1000000.00000000, -500000.00000000, 0.99500000
dcl_texcoord0 v0.xyzw
mad r1.xy, v0, c10.z, c10.w
mov r1.z, c10.w
mul r1.xy, r1, c4
dp3 r1.w, r1, r1
rsq r2.w, r1.w
mul r1.xyz, r2.w, r1
mov r1.w, c10.x
dp4 r3.z, r1, c2
dp4 r3.y, r1, c1
dp4 r3.x, r1, c0
rcp r2.w, r2.w
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c7.x
add r1.xyz, r2, -c5
dp3 r1.w, r1, r1
mov r2.x, c6
add r2.z, c8.x, r2.x
dp3 r1.z, r1, r3
mad r2.x, -r2.z, r2.z, r1.w
mad r2.x, r1.z, r1.z, -r2
rsq r1.x, r2.x
rcp r1.y, r1.x
add r1.x, -r1.z, -r1.y
cmp_pp r3.x, r2, c10.y, c10
cmp r2.xy, r2.x, r0, c11
add r1.y, -r1.z, r1
cmp r1.xy, -r3.x, r2, r1
add r3.z, r2, c9.x
mad r3.x, -r3.z, r3.z, r1.w
add r2.x, r1, c11.z
cmp r2.x, r2, c10, c10.y
abs_pp r2.y, r2.x
cmp_pp r4.z, -r2.y, c10.y, c10.x
rsq r2.y, r1.w
rcp r3.y, r2.y
add r2.z, r3.y, -r2
mad r3.x, r1.z, r1.z, -r3
add r3.y, -r3, r3.z
rsq r2.y, r3.x
cmp r2.z, r2, c10.x, c10.y
abs_pp r2.z, r2
cmp r4.x, r3.y, c10, c10.y
cmp_pp r2.z, -r2, c10.y, c10.x
mul_pp r4.y, r2.z, r4.x
cmp_pp r3.z, r3.x, c10.y, c10.x
cmp r3.xy, r3.x, r0, c11
rcp r2.y, r2.y
mul_pp r4.w, r4.y, r2.x
add r2.x, -r1.z, -r2.y
add r2.y, -r1.z, r2
cmp r3.xy, -r3.z, r3, r2
mov r3.z, r3.x
mov r2.x, r1.y
abs_pp r1.y, r4.x
cmp_pp r1.y, -r1, c10, c10.x
mul_pp r1.y, r2.z, r1
mov r3.w, r1.x
mov r2.y, r3
cmp r2.xy, -r4.w, r2, r3.zwzw
cmp r3.z, r1.x, c10.x, c10.y
mul_pp r3.x, r4.y, r4.z
cmp r2.xy, -r3.x, r2, c10.xwzw
mul_pp r2.z, r1.y, r3
mov r3.x, c10
cmp r2.xy, -r2.z, r2, r3
mad r2.z, -c6.x, c6.x, r1.w
mad r2.z, r1, r1, -r2
rsq r3.x, r2.z
abs_pp r1.w, r3.z
cmp_pp r1.w, -r1, c10.y, c10.x
mul_pp r1.w, r1.y, r1
mov r1.y, r1.x
rcp r3.x, r3.x
add r3.x, -r1.z, -r3
cmp_pp r1.x, r2.z, c10.y, c10
cmp r1.z, r2, r0.x, c11.x
cmp r1.z, -r1.x, r1, r3.x
add r1.x, c4.w, -c4.z
cmp r3.x, r1.z, r1.z, c11
rcp r1.z, r1.x
mul r1.z, r1, c4.w
texldl r1.x, v0, s0
add r1.x, r1.z, -r1
rcp r2.z, r1.x
mul r1.x, r1.z, c4.z
mul r1.z, r1.x, r2
mul r2.z, r1, r2.w
mov r1.x, c4.w
mad r1.x, c11.w, -r1, r1.z
cmp r1.x, r1, c10.y, c10
mad r2.w, -r2.z, c7.x, r3.x
mul r1.z, r2, c7.x
mad r1.z, r1.x, r2.w, r1
mov r1.x, c10
cmp r1.xy, -r1.w, r2, r1
min r1.y, r1, r1.z
max r1.x, r1, c10
add r1.x, r1, -r1.y
cmp_pp r1.y, -r1.x, c10, c10.x
cmp oC0, -r1.x, r0, c10.xxxy
if_gt r1.y, c10.x
texldl oC0, v0, s1
endif

"
}

}

		}
	}
	Fallback off
}
