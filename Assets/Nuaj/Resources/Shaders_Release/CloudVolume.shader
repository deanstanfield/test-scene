// This shader renders layers of dense and thick volumetric clouds
//
Shader "Hidden/Nuaj/Volume"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownScaledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexDeepShadowMap0( "Base (RGB)", 2D ) = "white" {}
		_TexDeepShadowMap1( "Base (RGB)", 2D ) = "white" {}
		_TexDeepShadowMap2( "Base (RGB)", 2D ) = "white" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSky( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSun( "Base (RGB)", 2D ) = "white" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
		_TexScreenNoise( "Base (RGB)", 2D ) = "black" {}
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
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 4, 8 } };
TEMP R0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[1];
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[0], 2D;
MOVR  R0, R0.w;
ELSE;
MOVR  R0.x, c[1].y;
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[1], 2D;
MOVR  R0, R0.w;
ELSE;
TEX   R0.w, fragment.texcoord[0], texture[2], 2D;
MOVR  R0, R0.w;
ENDIF;
ENDIF;
MOVR  oCol, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c1, 4.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mov r0.x, c1
if_le c0.x, r0.x
texldl r0.w, v0, s0
mov r0, r0.w
else
mov r0.x, c1.y
if_le c0.x, r0.x
texldl r0.w, v0, s1
mov r0, r0.w
else
texldl r0.w, v0, s2
mov r0, r0.w
endif
endif
mov oC0, r0

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
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 4, 8 } };
TEMP R0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[1];
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[0], 2D;
MOVR  R0, R0.w;
ELSE;
MOVR  R0.x, c[1].y;
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[1], 2D;
MOVR  R0, R0.w;
ELSE;
TEX   R0.w, fragment.texcoord[0], texture[2], 2D;
MOVR  R0, R0.w;
ENDIF;
ENDIF;
MOVR  oCol, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c1, 4.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mov r0.x, c1
if_le c0.x, r0.x
texldl r0.w, v0, s0
mov r0, r0.w
else
mov r0.x, c1.y
if_le c0.x, r0.x
texldl r0.w, v0, s1
mov r0, r0.w
else
texldl r0.w, v0, s2
mov r0, r0.w
endif
endif
mov oC0, r0

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
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 4, 8 } };
TEMP R0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[1];
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[0], 2D;
MOVR  R0, R0.w;
ELSE;
MOVR  R0.x, c[1].y;
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[1], 2D;
MOVR  R0, R0.w;
ELSE;
TEX   R0.w, fragment.texcoord[0], texture[2], 2D;
MOVR  R0, R0.w;
ENDIF;
ENDIF;
MOVR  oCol, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c1, 4.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mov r0.x, c1
if_le c0.x, r0.x
texldl r0.w, v0, s0
mov r0, r0.w
else
mov r0.x, c1.y
if_le c0.x, r0.x
texldl r0.w, v0, s1
mov r0, r0.w
else
texldl r0.w, v0, s2
mov r0, r0.w
endif
endif
mov oC0, r0

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
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 4, 8 } };
TEMP R0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[1];
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[0], 2D;
MOVR  R0, R0.w;
ELSE;
MOVR  R0.x, c[1].y;
SLERC HC.x, c[0], R0;
IF    NE.x;
TEX   R0.w, fragment.texcoord[0], texture[1], 2D;
MOVR  R0, R0.w;
ELSE;
TEX   R0.w, fragment.texcoord[0], texture[2], 2D;
MOVR  R0, R0.w;
ENDIF;
ENDIF;
MOVR  oCol, R0;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_ShadowLayersCount]
SetTexture 0 [_TexDeepShadowMap0] 2D
SetTexture 1 [_TexDeepShadowMap1] 2D
SetTexture 2 [_TexDeepShadowMap2] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c1, 4.00000000, 8.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mov r0.x, c1
if_le c0.x, r0.x
texldl r0.w, v0, s0
mov r0, r0.w
else
mov r0.x, c1.y
if_le c0.x, r0.x
texldl r0.w, v0, s1
mov r0, r0.w
else
texldl r0.w, v0, s2
mov r0, r0.w
endif
endif
mov oC0, r0

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
Vector 17 [_CloudThicknessKm]
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
Vector 16 [_CameraData]
Matrix 0 [_Camera2World]
Vector 17 [_PlanetCenterKm]
Vector 18 [_PlanetNormal]
Float 19 [_PlanetRadiusKm]
Float 20 [_PlanetAtmosphereRadiusKm]
Float 21 [_WorldUnit2Kilometer]
Float 22 [_Kilometer2WorldUnit]
Float 23 [_bComputePlanetShadow]
Vector 24 [_SunColor]
Vector 25 [_SunColorFromGround]
Vector 26 [_SunDirection]
SetTexture 2 [_TexAmbientSky] 2D
Vector 27 [_SoftAmbientSky]
Vector 28 [_AmbientSkyFromGround]
Vector 29 [_AmbientNightSky]
SetTexture 1 [_TexShadowEnvMapSky] 2D
Vector 30 [_NuajLightningPosition00]
Vector 31 [_NuajLightningPosition01]
Vector 32 [_NuajLightningColor0]
Vector 33 [_NuajLightningPosition10]
Vector 34 [_NuajLightningPosition11]
Vector 35 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 36 [_NuajLocalCoverageOffset]
Vector 37 [_NuajLocalCoverageFactor]
SetTexture 5 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 38 [_NuajTerrainEmissiveOffset]
Vector 39 [_NuajTerrainEmissiveFactor]
SetTexture 4 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 40 [_NuajTerrainAlbedo]
Vector 41 [_Sigma_Rayleigh]
Float 42 [_Sigma_Mie]
Float 43 [_MiePhaseAnisotropy]
SetTexture 3 [_TexDensity] 2D
SetTexture 0 [_TexDownScaledZBuffer] 2D
SetTexture 6 [_NuajTexNoise3D0] 2D
Float 44 [_StepsCount]
Float 45 [_CloudAltitudeKm]
Vector 46 [_CloudThicknessKm]
Float 47 [_CloudLayerIndex]
Float 48 [_NoiseTiling]
Float 49 [_Coverage]
Float 50 [_CloudTraceLimiter]
Vector 51 [_HorizonBlend]
Vector 52 [_CloudPosition]
Float 53 [_FrequencyFactor]
Vector 54 [_AmplitudeFactor]
Vector 55 [_CloudColor]
Float 56 [_CloudSigma_t]
Float 57 [_CloudSigma_s]
Float 58 [_DirectionalFactor]
Float 59 [_IsotropicFactor]
Float 60 [_IsotropicDensity]
Vector 61 [_IsotropicScatteringFactors]
Float 62 [_PhaseAnisotropyStrongForward]
Float 63 [_PhaseWeightStrongForward]
Float 64 [_PhaseAnisotropyForward]
Float 65 [_PhaseWeightForward]
Float 66 [_PhaseAnisotropyBackward]
Float 67 [_PhaseWeightBackward]
Float 68 [_PhaseAnisotropySide]
Float 69 [_PhaseWeightSide]
Float 70 [_ShadowLayersCount]
SetTexture 9 [_TexDeepShadowMap0] 2D
SetTexture 8 [_TexDeepShadowMap1] 2D
SetTexture 7 [_TexDeepShadowMap2] 2D
Float 71 [_UseSceneZ]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[82] = { program.local[0..71],
		{ 0.5, 2.718282, 2, -1 },
		{ 0, 0.995, 1000000, -1000000 },
		{ 500000, 0, -1, 1 },
		{ 0.80000001, -0.2, -2.4999998, 3 },
		{ -0.97500002, 0.1, -10, 0.0125 },
		{ 1.4, 0.0625, 1000, 16 },
		{ 255, 0, 1, 17 },
		{ 0.25, 0.0036764706, -0.1875, 8 },
		{ 4, 10, 0.079577468 },
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
OUTPUT oCol = result.color;
MOVR  R3.xyz, c[16].xyww;
MULR  R0.xy, fragment.texcoord[0], c[16];
MADR  R0.xy, R0, c[72].z, -R3;
MOVR  R0.z, c[72].w;
DP3R  R0.w, R0, R0;
RSQR  R2.w, R0.w;
MULR  R0.xyz, R2.w, R0;
MOVR  R0.w, c[73].x;
DP4R  R4.z, R0, c[2];
DP4R  R4.y, R0, c[1];
DP4R  R4.x, R0, c[0];
MOVR  R0.x, c[45];
ADDR  R6.x, R0, c[19];
MOVR  R0.xy, c[73].zwzw;
MOVR  R2.x, c[0].w;
MOVR  R2.z, c[2].w;
MOVR  R2.y, c[1].w;
MULR  R5.xyz, R2, c[21].x;
ADDR  R2.xyz, R5, -c[17];
DP3R  R5.w, R2, R2;
DP3R  R3.w, R4, R2;
ADDR  R2.z, R6.x, c[46].x;
MULR  R4.w, R3, R3;
MADR  R2.x, -R2.z, R2.z, R5.w;
SLTRC HC.x, R4.w, R2;
MOVR  R0.xy(EQ.x), R1;
ADDR  R0.z, R4.w, -R2.x;
RSQR  R0.z, R0.z;
RCPR  R0.w, R0.z;
ADDR  R0.z, -R3.w, -R0.w;
MADR  R3.x, -R6, R6, R5.w;
SGERC HC.x, R4.w, R2;
ADDR  R0.w, -R3, R0;
MOVR  R0.xy(NE.x), R0.zwzw;
ADDR  R2.x, R4.w, -R3;
RSQR  R2.x, R2.x;
RCPR  R2.y, R2.x;
ADDR  R2.x, -R3.w, -R2.y;
MOVR  R0.zw, c[73];
SLTRC HC.x, R4.w, R3;
MOVR  R0.zw(EQ.x), R1.xyxy;
SGERC HC.x, R4.w, R3;
MOVR  R3.x, R0;
ADDR  R2.y, -R3.w, R2;
MOVR  R0.zw(NE.x), R2.xyxy;
RSQR  R0.x, R5.w;
RCPR  R0.x, R0.x;
SLTR  H0.x, R0, R6;
SGTR  H0.y, R0.x, R2.z;
SEQX  H0.x, H0, c[73];
MULX  H0.z, H0.x, H0.y;
SLTR  H0.w, R0.z, c[74].x;
MULXC HC.x, H0.z, H0.w;
SEQX  H0.y, H0, c[73].x;
MOVR  R2.x, R0.w;
MOVR  R2.y, R0;
MOVR  R3.y, R0.z;
MOVR  R2.xy(NE.x), R3;
SEQX  H0.w, H0, c[73].x;
MULXC HC.x, H0.z, H0.w;
MOVR  R2.xy(NE.x), c[74].yzzw;
MULX  H0.x, H0, H0.y;
SLTR  H0.z, R0, c[73].x;
MULXC HC.x, H0, H0.z;
MOVR  R0.x, c[73];
MOVR  R2.xy(NE.x), R0;
SEQX  H0.y, H0.z, c[73].x;
MOVR  R0.y, R0.z;
MULXC HC.x, H0, H0.y;
MOVR  R0.x, c[73];
MOVR  R2.xy(NE.x), R0;
MADR  R0.x, -c[19], c[19], R5.w;
ADDR  R0.z, R4.w, -R0.x;
RSQR  R0.z, R0.z;
MOVR  R0.y, c[73].z;
SLTRC HC.x, R4.w, R0;
MOVR  R0.y(EQ.x), R1.x;
SGERC HC.x, R4.w, R0;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3.w, -R0.z;
MOVXC RC.x, R0.y;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R0.x, R0, -c[16].w;
MADR  R0.x, R0, c[71], R3.z;
RCPR  R0.z, R2.w;
MOVR  R0.y(LT.x), c[73].z;
MULR  R0.z, R0.x, R0;
MADR  R0.w, -R0.z, c[21].x, R0.y;
MOVR  R0.y, c[73];
MULR  R0.y, R0, c[16].w;
MAXR  R12.z, R2.x, c[73].x;
SGER  H0.x, R0, R0.y;
MULR  R0.z, R0, c[21].x;
MADR  R0.x, H0, R0.w, R0.z;
MINR  R2.w, R0.x, R2.y;
MOVR  R0, c[74].yyyw;
SGTRC HC.x, R12.z, R2.w;
MOVR  R0(EQ.x), R1;
MOVR  R1, R0;
MOVR  R0.xyz, c[18];
DP3R  R0.x, R0, c[26];
MOVR  R0.w, c[19].x;
ADDR  R0.w, -R0, c[20].x;
SLERC HC.x, R12.z, R2.w;
ADDR  R0.z, R2, -c[19].x;
RCPR  R0.y, R0.w;
MULR  R0.y, R0.z, R0;
MADR  R0.x, -R0, c[72], c[72];
TEX   R0.zw, R0, texture[3], 2D;
MULR  R0.x, R0.w, c[42];
MADR  R0.xyz, R0.z, -c[41], -R0.x;
POWR  R2.x, c[72].y, R0.x;
POWR  R2.y, c[72].y, R0.y;
POWR  R2.z, c[72].y, R0.z;
TEX   R0.xyz, c[72].x, texture[2], 2D;
MULR  R3.xyz, R2, c[24];
ADDR  R0.xyz, R0, c[27];
TEX   R0.w, c[72].x, texture[1], 2D;
MOVR  R12.w, R2;
MULR  R2.xyz, R0.w, R0;
IF    NE.x;
ADDR  R0.xyz, R5, -c[17];
MULR  R1.xyz, R0.zxyw, c[26].yzxw;
MADR  R1.xyz, R0.yzxw, c[26].zxyw, -R1;
DP3R  R0.x, R0, c[26];
SLER  H0.x, R0, c[73];
DP3R  R0.w, R1, R1;
MULR  R6.xyz, R4.zxyw, c[26].yzxw;
MADR  R6.xyz, R4.yzxw, c[26].zxyw, -R6;
DP3R  R1.x, R1, R6;
DP3R  R1.y, R6, R6;
MADR  R0.w, -c[19].x, c[19].x, R0;
MULR  R1.w, R1.y, R0;
MULR  R1.z, R1.x, R1.x;
ADDR  R0.w, R1.z, -R1;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
MOVR  R3.w, c[74];
ADDR  R0.y, -R1.x, R0.w;
MOVR  R7.xy, c[75].wyzw;
MOVR  R6, c[36];
SGTR  H0.y, R1.z, R1.w;
MULX  H0.x, H0, c[23];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R1.y, R1.y;
MOVR  R0.z, c[73].w;
MULR  R0.z(NE.x), R1.y, R0.y;
ADDR  R0.y, -R1.x, -R0.w;
MOVR  R0.x, c[73].z;
MULR  R0.x(NE), R0.y, R1.y;
MOVR  R0.y, R0.z;
MOVR  R12.xy, R0;
MADR  R0.xyz, R4, R0.x, R5;
ADDR  R0.xyz, R0, -c[17];
DP3R  R0.x, R0, c[26];
SGTR  H0.y, R0.x, c[73].x;
MULXC HC.x, H0, H0.y;
ADDR  R0.x, -R7.y, c[49];
MULR_SAT R0.x, R0, c[75].z;
MADR  R0.y, -R0.x, c[72].z, R7.x;
MULR  R0.x, R0, R0;
MULR  R0.x, R0, R0.y;
MOVR  R0.w, c[74];
SEQR  H0.y, c[47].x, R3.w;
MOVR  R0.y, c[56].x;
MULR  R0.x, R0, c[56];
MADR  R0.x, R0, c[76], R0.y;
RCPR  R0.y, R0.x;
MADR  R0.x, R12.z, c[50], c[50];
MADR  R0.x, R0, R0.y, R12.z;
MINR  R4.w, R12, R0.x;
ADDR  R0.x, R12.z, R4.w;
MULR  R0.xyz, R4, R0.x;
MADR  R0.xyz, R0, c[72].x, R5;
MULR  R0.xyz, R0, c[22].x;
DP4R  R1.x, R0, c[8];
DP4R  R1.y, R0, c[10];
MADR  R1.xy, R1, c[72].x, c[72].x;
TEX   R1, R1, texture[5], 2D;
MADR  R1, R1, c[37], R6;
MOVR  R5.w, R1.x;
MOVR  R1.x, c[73];
SEQR  H0.x, c[47], R1;
MOVR  R1.x, c[72].z;
SEQR  H0.z, c[47].x, R1.x;
SEQX  H0.x, H0, c[73];
MOVR  R12.xy(NE.x), c[73].zwzw;
MULXC HC.x, H0, H0.y;
SEQX  H0.y, H0, c[73].x;
MULX  H0.x, H0, H0.y;
MOVR  R5.w(NE.x), R1.y;
MULXC HC.x, H0, H0.z;
MOVR  R5.w(NE.x), R1.z;
SEQX  H0.y, H0.z, c[73].x;
MULXC HC.x, H0, H0.y;
MOVR  R5.w(NE.x), R1;
MULR  R1.x, R5.w, c[51].z;
MULR  R1.y, R1.x, c[49].x;
MADR_SAT R1.x, R1.y, c[77], R1;
ADDR  R1.y, -R12.z, R4.w;
DP3R  R4.w, R4, c[26];
MADR  R6.x, -R4.w, c[64], R3.w;
MOVR  R2.w, c[44].x;
SLTRC HC.x, c[44], R3.w;
MOVR  R2.w(NE.x), c[74];
MULR  R7.w, R1.x, c[77].y;
ADDR  R1.x, R2.w, c[74].w;
RCPR  R1.x, R1.x;
MULR  R9.w, R1.y, R1.x;
DP4R  R1.x, R0, c[12];
DP4R  R1.y, R0, c[14];
MADR  R0.xy, R1, c[72].x, c[72].x;
TEX   R0, R0, texture[4], 2D;
MOVR  R1, c[38];
MADR  R1, R0, c[39], R1;
RCPR  R0.x, R6.x;
MULR  R0.y, c[64].x, c[64].x;
MADR  R0.z, -R0.y, R0.x, R0.x;
MULR  R0.y, -R4.w, -R4.w;
MADR  R0.y, -R0, c[75].x, R3.w;
MULR  R0.x, R0.z, R0;
MADR  R0.z, -R4.w, c[62].x, R3.w;
RSQR  R0.y, R0.y;
RCPR  R0.y, R0.y;
POWR  R0.y, R0.y, c[68].x;
RCPR  R0.z, R0.z;
MULR  R0.w, c[62].x, c[62].x;
MADR  R0.w, -R0, R0.z, R0.z;
MULR  R0.z, R0.w, R0;
MULR  R0.z, R0, c[63].x;
MOVR_SAT R0.y, R0;
MADR  R0.y, R0, c[69].x, R0.z;
MADR  R0.x, R0, c[65], R0.y;
DP3R  R0.z, R4, c[18];
ADDR  R0.y, |R0.z|, -c[76];
MADR  R0.z, -R4.w, c[66].x, R3.w;
RCPR  R0.w, R0.z;
MULR_SAT R0.y, R0, c[76].z;
MADR  R3.w, -R0.y, c[72].z, R7.x;
MULR  R0.z, c[66].x, c[66].x;
MADR  R0.z, -R0, R0.w, R0.w;
MULR  R0.z, R0, R0.w;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R3.w;
MULR  R0.w, R12.z, R0.y;
MADR  R4.w, R0.z, c[67].x, R0.x;
MOVR  R0.xyz, c[18];
DP3R  R0.y, R0, c[26];
MOVR  R0.x, c[46];
RCPR  R0.y, |R0.y|;
MULR  R0.x, R0, -c[56];
MULR_SAT R6.w, R0, c[76];
MULR  R0.w, R0.x, R0.y;
MOVR  R0.xyz, c[26];
MULR  R0.w, R0, c[77].z;
MULR  R10.w, R9, c[77].z;
RCPR  R11.w, R9.w;
MADR  R12.w, R9, c[72].x, R12.z;
DP3R  R3.w, R0, c[18];
POWR  R8.w, c[72].y, R0.w;
MOVR  R6.xyz, c[73].x;
MOVR  R7.xyz, c[74].w;
MOVR  R13.x, c[73];
LOOP c[78];
SLTRC HC.x, R13, R2.w;
BRK   (EQ.x);
MADR  R8.xyz, R12.w, R4, R5;
MULR  R0.xyz, R8.xzyw, c[48].x;
ADDR  R10.xy, R0, c[52];
MOVR  R10.z, R0;
MULR  R0.xyz, R10, c[53].x;
ADDR  R9.xy, R0, c[52].zwzw;
MOVR  R9.z, R0;
MULR  R0.xyz, R9, c[53].x;
ADDR  R0.xy, R0, c[52].zwzw;
MULR  R11.xyz, R0, c[53].x;
ADDR  R14.zw, R11.xyxy, c[52];
ADDR  R0.zw, R0.xyxz, c[77].z;
MOVR  R11.y, R11.z;
MOVR  R11.x, R14.z;
ADDR  R11.xy, R11, c[77].z;
MULR  R13.zw, R11.xyxy, c[77].w;
MULR  R11.xy, R13.zwzw, c[77].y;
MOVXC RC.xy, R13.zwzw;
MULR  R13.zw, R0, c[77].w;
FRCR  R11.xy, |R11|;
MULR  R14.xy, R11, c[77].w;
MOVR  R11.xy, R14;
MOVR  R11.xy(LT), -R14;
MULR  R0.zw, R13, c[77].y;
MOVXC RC.xy, R13.zwzw;
FRCR  R0.zw, |R0|;
MULR  R14.xy, R0.zwzw, c[77].w;
MOVR  R0.zw, R14.xyxy;
MOVR  R0.zw(LT.xyxy), -R14.xyxy;
ADDR  R13.zw, R10.xyxz, c[77].z;
MULR  R14.xy, R13.zwzw, c[77].w;
MULR  R13.zw, R14.xyxy, c[77].y;
MOVXC RC.xy, R14;
ADDR  R14.xy, R9.xzzw, c[77].z;
MULR  R9.xz, R14.xyyw, c[77].w;
MULR  R14.xy, R9.xzzw, c[77].y;
FRCR  R13.zw, |R13|;
MULR  R10.xz, R13.zyww, c[77].w;
MOVR  R13.zw, R10.xyxz;
MOVR  R13.zw(LT.xyxy), -R10.xyxz;
FRCR  R14.xy, |R14|;
MULR  R10.xz, R14.xyyw, c[77].w;
MOVR  R14.xy, R10.xzzw;
MOVXC RC.xy, R9.xzzw;
FLRR  R0.x, R13.w;
MADR  R9.x, R0, c[78].w, R13.z;
MOVR  R14.xy(LT), -R10.xzzw;
ADDR  R9.x, R9, c[79];
MULR  R10.x, R9, c[79].y;
TEX   R10.xy, R10, texture[6], 2D;
ADDR  R9.x, R10.y, -R10;
ADDR  R0.x, R13.w, -R0;
MADR  R9.z, R0.x, R9.x, R10.x;
FLRR  R0.x, R14.y;
MADR  R9.x, R0, c[78].w, R14;
ADDR  R9.x, R9, c[79];
MULR  R9.x, R9, c[79].y;
TEX   R9.xy, R9, texture[6], 2D;
ADDR  R9.y, R9, -R9.x;
ADDR  R0.x, R14.y, -R0;
MADR  R0.x, R0, R9.y, R9;
FLRR  R9.x, R0.w;
MADR  R9.y, R0.x, c[54].x, R9.z;
MADR  R0.x, R9, c[78].w, R0.z;
ADDR  R0.z, R0.w, -R9.x;
ADDR  R0.x, R0, c[79];
MULR  R0.x, R0, c[79].y;
TEX   R0.xy, R0, texture[6], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.z, R0.y, R0;
MULR  R0.z, c[54].x, c[54].x;
MADR  R9.x, R0.z, R0, R9.y;
FLRR  R0.w, R11.y;
MADR  R0.x, R0.w, c[78].w, R11;
ADDR  R0.x, R0, c[79];
ADDR  R0.w, R11.y, -R0;
MULR  R0.x, R0, c[79].y;
MOVR  R0.y, R14.w;
TEX   R0.xy, R0, texture[6], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.w, R0.y, R0;
MULR  R0.y, R0.z, c[54].x;
MADR  R0.x, R0.y, R0, R9;
ADDR  R9.xyz, R8, -c[17];
DP3R  R0.y, R9, R9;
MOVR  R0.z, c[45].x;
RSQR  R0.y, R0.y;
ADDR  R0.z, R0, c[19].x;
RCPR  R0.y, R0.y;
ADDR  R14.y, R0, -R0.z;
MULR_SAT R10.y, R14, c[46];
MADR  R13.y, -R10, c[70].x, c[70].x;
SGTRC HC.x, R13.y, c[79].w;
MULR  R0.z, R14.y, c[46].y;
MOVR  R0.y, c[74].w;
MADR  R0.y, R0.z, c[72].z, -R0;
MULR  R0.y, |R0|, |R0|;
MULR  R0.w, R0.y, R0.y;
MULR  R9.x, R0.w, R0.w;
MULR  R0.w, R9.x, R0;
MULR  R0.x, R0, c[54].y;
MOVR  R0.yz, c[60].x;
MADR  R0.xyz, -R0.w, R0, R0;
MOVR  R0.w, c[79].z;
MINR  R0.w, R0, c[49].x;
ADDR  R0.yz, R0, R0.w;
ADDR  R0.x, R0, c[49];
MULR_SAT R9.xyz, R5.w, R0;
MOVR  R0.w, c[74];
MOVR  R0.xyz, R8;
DP4R  R10.x, R0, c[4];
DP4R  R10.y, R0, c[5];
IF    NE.x;
TEX   R0, R10, texture[7], 2D;
ADDR  R13.y, R13, -c[79].w;
ELSE;
SGTRC HC.x, R13.y, c[80];
IF    NE.x;
TEX   R0, R10, texture[8], 2D;
ADDR  R13.y, R13, -c[80].x;
ELSE;
TEX   R0, R10, texture[9], 2D;
ENDIF;
ENDIF;
MOVR  R11.xyz, c[28];
ADDR  R11.xyz, R11, c[25];
MULR  R10.xyz, R1.w, c[40];
MULR  R10.xyz, R10, R11;
MADR  R11.xy, R6.w, -R9.yzzw, R9.yzzw;
ADDR  R9.y, R7.w, -R9.x;
MOVR_SAT R13.z, R3.w;
MULR  R10.xyz, R10, R13.z;
MADR  R10.xyz, R10, c[80].z, R1;
MULR  R13.zw, R11.xyxy, c[57].x;
MADR  R14.x, R6.w, R9.y, R9;
MULR  R9.x, -R13.w, R14.y;
MULR  R11.x, R9, c[77].z;
MULR  R14.zw, R14.x, R13;
MULR  R10.xyz, R10, c[61].y;
ADDR  R9.xyz, R2, c[29];
ADDR  R13.w, -R14.y, c[46].x;
MULR  R13.w, -R13.z, R13;
MULR  R13.w, R13, c[77].z;
MULR  R10.xyz, R14.w, R10;
POWR  R11.x, c[72].y, R11.x;
MULR  R11.xyz, R10, R11.x;
MULR  R9.xyz, R9, c[61].x;
MULR  R10.xyz, R14.z, R9;
ADDR  R9.xyz, -R8, c[30];
DP3R  R13.z, R9, R9;
RSQR  R13.z, R13.z;
MULR  R9.xyz, R13.z, R9;
POWR  R13.w, c[72].y, R13.w;
MADR  R10.xyz, R10, R13.w, R11;
MOVR  R11.x, c[74].w;
DP3R  R9.x, R9, R4;
MADR  R9.x, R9, c[43], R11;
RCPR  R11.z, R9.x;
MULR  R11.y, c[43].x, c[43].x;
MADR  R13.w, -R11.y, R11.z, R11.z;
MOVR  R9.xyz, c[30];
ADDR  R9.xyz, -R9, c[31];
DP3R  R9.y, R9, R9;
ADDR  R8.xyz, -R8, c[33];
DP3R  R9.x, R8, R8;
RSQR  R9.x, R9.x;
MULR  R8.xyz, R9.x, R8;
DP3R  R8.x, R4, R8;
MADR  R8.x, R8, c[43], R11;
RCPR  R8.x, R8.x;
RCPR  R9.z, R13.z;
MULR  R8.y, R9.z, c[77].z;
MADR  R8.z, -R11.y, R8.x, R8.x;
SGER  H0.z, R13.y, c[74].w;
RSQR  R9.y, R9.y;
MULR  R8.y, R8, R8;
RCPR  R9.x, R9.x;
MULR  R9.z, R8, R8.x;
RCPR  R8.y, R8.y;
MULR  R9.x, R9, c[77].z;
SGER  H0.y, R13, c[72].z;
SGER  H0.x, R13.y, c[75].w;
MULR  R10.xyz, R10, c[59].x;
MULR  R11.z, R13.w, R11;
RCPR  R9.y, R9.y;
MULR  R9.y, R9, R11.z;
MULR  R9.y, R9, R8;
MOVR  R8.xyz, c[33];
ADDR  R8.xyz, -R8, c[34];
DP3R  R8.x, R8, R8;
MULR  R8.y, R9.x, R9.x;
RSQR  R8.x, R8.x;
RCPR  R8.x, R8.x;
MULR  R8.x, R8, R9.z;
RCPR  R8.y, R8.y;
MULR  R8.x, R8, R8.y;
MULR  R8.y, R9, c[77].z;
MULR  R8.x, R8, c[77].z;
MADR  R9.x, -H0.y, H0.z, H0.z;
MULR  R9.xy, R0.zyzw, R9.x;
ADDR  R11.x, -H0.z, c[74].w;
MADR  R0.xy, R0.yxzw, R11.x, R9;
MADR  R9.x, -H0, H0.y, H0.y;
MADR  R9.xy, R0.wzzw, R9.x, R0;
MADR  R9.xy, H0.x, R0.w, R9;
MINR  R9.z, R8.y, c[74].w;
MINR  R8.x, R8, c[74].w;
MULR  R8.xyz, R8.x, c[35];
MADR  R0.xyz, R9.z, c[32], R8;
MULR  R8.xyz, R0, c[80].y;
ADDR  R0.y, -R12.w, R12;
ADDR  R12.w, R12, R9;
ADDR  R0.w, R12, -R12.x;
FRCR  R0.z, R13.y;
ADDR  R0.x, R9, -R9.y;
MADR_SAT R0.x, R0.z, R0, R9.y;
ADDR  R0.z, R8.w, -R0.x;
MULR_SAT R0.w, R0, R11;
MULR_SAT R0.y, R11.w, R0;
MULR  R0.y, R0.w, R0;
MADR  R0.w, R6, R0.z, R0.x;
MULR  R0.w, R0, c[58].x;
MADR  R0.xyz, -R0.y, R3, R3;
MULR  R0.xyz, R0.w, R0;
MADR  R0.xyz, R0, R4.w, R8;
MULR  R0.w, R14.x, c[57].x;
MULR  R8.xyz, R10, c[80].y;
MADR  R0.xyz, R0.w, R0, R8;
MULR  R0.xyz, R0, R10.w;
MULR  R0.w, R14.x, c[56].x;
MADR  R6.xyz, R0, R7, R6;
MULR  R0.w, R10, -R0;
POWR  R0.x, c[72].y, R0.w;
MULR  R7.xyz, R7, R0.x;
ADDR  R13.x, R13, c[74].w;
ENDLOOP;
ADDR  R2.x, c[51].y, -c[51];
MULR  R0.xyz, R6, c[55];
DP3R  R0.w, R7, c[81];
ADDR  R1, -R0, c[74].yyyw;
RCPR  R2.x, R2.x;
ADDR  R2.y, R12.z, -c[51].x;
MULR_SAT R2.x, R2.y, R2;
MADR  R1, R2.x, R1, R0;
ENDIF;
MOVR  oCol, R1;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Vector 16 [_CameraData]
Matrix 0 [_Camera2World]
Vector 17 [_PlanetCenterKm]
Vector 18 [_PlanetNormal]
Float 19 [_PlanetRadiusKm]
Float 20 [_WorldUnit2Kilometer]
Float 21 [_Kilometer2WorldUnit]
Float 22 [_bComputePlanetShadow]
Vector 23 [_SunColorFromGround]
Vector 24 [_SunDirection]
Vector 25 [_AmbientSkyFromGround]
Vector 26 [_AmbientNightSky]
Vector 27 [_NuajLightningPosition00]
Vector 28 [_NuajLightningPosition01]
Vector 29 [_NuajLightningColor0]
Vector 30 [_NuajLightningPosition10]
Vector 31 [_NuajLightningPosition11]
Vector 32 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 33 [_NuajLocalCoverageOffset]
Vector 34 [_NuajLocalCoverageFactor]
SetTexture 2 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 35 [_NuajTerrainEmissiveOffset]
Vector 36 [_NuajTerrainEmissiveFactor]
SetTexture 1 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 37 [_NuajTerrainAlbedo]
Float 38 [_MiePhaseAnisotropy]
SetTexture 0 [_TexDownScaledZBuffer] 2D
SetTexture 3 [_NuajTexNoise3D0] 2D
Float 39 [_StepsCount]
Float 40 [_CloudAltitudeKm]
Vector 41 [_CloudThicknessKm]
Float 42 [_CloudLayerIndex]
Float 43 [_NoiseTiling]
Float 44 [_Coverage]
Float 45 [_CloudTraceLimiter]
Vector 46 [_HorizonBlend]
Vector 47 [_CloudPosition]
Float 48 [_FrequencyFactor]
Vector 49 [_AmplitudeFactor]
Vector 50 [_CloudColor]
Float 51 [_CloudSigma_t]
Float 52 [_CloudSigma_s]
Float 53 [_DirectionalFactor]
Float 54 [_IsotropicFactor]
Float 55 [_IsotropicDensity]
Vector 56 [_IsotropicScatteringFactors]
Float 57 [_PhaseAnisotropyStrongForward]
Float 58 [_PhaseWeightStrongForward]
Float 59 [_PhaseAnisotropyForward]
Float 60 [_PhaseWeightForward]
Float 61 [_PhaseAnisotropyBackward]
Float 62 [_PhaseWeightBackward]
Float 63 [_PhaseAnisotropySide]
Float 64 [_PhaseWeightSide]
Float 65 [_ShadowLayersCount]
SetTexture 6 [_TexDeepShadowMap0] 2D
SetTexture 5 [_TexDeepShadowMap1] 2D
SetTexture 4 [_TexDeepShadowMap2] 2D
Float 66 [_UseSceneZ]

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
dcl_2d s6
def c67, 2.00000000, -1.00000000, 0.00000000, 0.99500000
def c68, 1.00000000, 0.00000000, 1000000.00000000, -1000000.00000000
def c69, -500000.00000000, 0.80000001, 1.00000000, 0.20000000
def c70, -2.49999976, 2.00000000, 3.00000000, 0.50000000
def c71, -0.97500002, 1.00000000, -2.00000000, -0.10000000
def c72, -10.00000000, 0.01250000, 1.39999998, 1.00000000
def c73, 0.06250000, 2.71828198, 1000.00000000, 16.00000000
defi i0, 255, 0, 1, 0
def c74, 17.00000000, 0.25000000, 0.00367647, -0.18750000
def c75, 8.00000000, -8.00000000, 4.00000000, -4.00000000
def c76, -3.00000000, 10.00000000, 0.07957747, 0
def c77, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
mov r2.y, c19.x
mad r0.xy, v0, c67.x, c67.y
add r2.z, c40.x, r2.y
mov r0.z, c67.y
mul r0.xy, r0, c16
dp3 r0.w, r0, r0
rsq r2.x, r0.w
mul r0.xyz, r2.x, r0
mov r0.w, c67.z
dp4 r3.z, r0, c2
dp4 r3.y, r0, c1
dp4 r3.x, r0, c0
mov r4.x, c0.w
mov r4.z, c2.w
mov r4.y, c1.w
mul r4.xyz, r4, c20.x
add r0.xyz, r4, -c17
dp3 r0.w, r0, r0
dp3 r2.y, r3, r0
mad r2.w, -r2.z, r2.z, r0
mad r0.z, r2.y, r2.y, -r2.w
rsq r0.x, r0.z
rcp r0.y, r0.x
add r0.x, -r2.y, -r0.y
cmp r5.xy, r0.z, r1, c68.zwzw
cmp_pp r2.w, r0.z, c68.x, c68.y
add r0.y, -r2, r0
cmp r0.xy, -r2.w, r5, r0
add r0.z, r0.x, c69.x
cmp r5.x, r0.z, c68.y, c68
abs_pp r0.z, r5.x
add r2.w, r2.z, c41.x
mad r3.w, -r2, r2, r0
mad r5.y, r2, r2, -r3.w
cmp_pp r6.x, -r0.z, c68, c68.y
rsq r0.z, r0.w
rcp r0.z, r0.z
add r2.w, -r0.z, r2
add r2.z, r0, -r2
cmp r2.z, r2, c68.y, c68.x
abs_pp r0.z, r2
cmp r3.w, r2, c68.y, c68.x
rsq r5.z, r5.y
rcp r2.w, r5.z
add r2.z, -r2.y, -r2.w
cmp_pp r0.z, -r0, c68.x, c68.y
mul_pp r4.w, r0.z, r3
mul_pp r6.y, r4.w, r5.x
cmp r5.zw, r5.y, r1.xyxy, c68
cmp_pp r5.x, r5.y, c68, c68.y
add r2.w, -r2.y, r2
cmp r2.zw, -r5.x, r5, r2
mov r5.z, r0.y
abs_pp r0.y, r3.w
mov r5.x, r2.z
cmp_pp r0.y, -r0, c68.x, c68
mul_pp r0.z, r0, r0.y
cmp r3.w, r0.x, c68.y, c68.x
mul_pp r0.y, r0.z, r3.w
mov r5.w, r2
mov r5.y, r0.x
mul_pp r2.z, r4.w, r6.x
cmp r5.xy, -r6.y, r5.zwzw, r5
cmp r5.xy, -r2.z, r5, c67.zyzw
mov r2.z, c67
cmp r5.xy, -r0.y, r5, r2.zwzw
mad r0.y, -c19.x, c19.x, r0.w
abs_pp r2.z, r3.w
cmp_pp r0.w, -r2.z, c68.x, c68.y
mad r2.z, r2.y, r2.y, -r0.y
mov r0.y, r0.x
mul_pp r0.w, r0.z, r0
rsq r0.z, r2.z
rcp r2.w, r0.z
mov r0.x, c67.z
cmp r0.zw, -r0.w, r5.xyxy, r0.xyxy
add r2.w, -r2.y, -r2
texldl r0.x, v0, s0
add r0.x, r0, -c16.w
cmp r2.y, r2.z, r1.x, c68.z
cmp_pp r0.y, r2.z, c68.x, c68
cmp r0.y, -r0, r2, r2.w
cmp r2.y, r0, r0, c68.z
mul r0.x, r0, c66
add r0.y, r0.x, c16.w
rcp r2.x, r2.x
mul r2.x, r0.y, r2
mov r0.x, c16.w
mad r0.x, c67.w, -r0, r0.y
mul r0.y, r2.x, c20.x
mad r2.y, -r2.x, c20.x, r2
cmp r0.x, r0, c68, c68.y
mad r0.x, r0, r2.y, r0.y
min r0.x, r0, r0.w
max r10.z, r0, c67
add r0.y, -r0.x, r10.z
cmp r1, -r0.y, r1, c68.yyyx
cmp_pp r0.y, -r0, c68.x, c68
mov r10.w, r0.x
if_gt r0.y, c67.z
add r0.xyz, r4, -c17
mul r1.xyz, r0.zxyw, c24.yzxw
mad r1.xyz, r0.yzxw, c24.zxyw, -r1
dp3 r0.x, r0, c24
dp3 r0.w, r1, r1
mul r2.xyz, r3.zxyw, c24.yzxw
mad r2.xyz, r3.yzxw, c24.zxyw, -r2
cmp r0.x, -r0, c68, c68.y
mov r0.z, c44.x
dp3 r1.w, r2, r2
mad r0.w, -c19.x, c19.x, r0
mul r2.w, r1, r0
dp3 r0.w, r1, r2
mad r1.x, r0.w, r0.w, -r2.w
rsq r1.y, r1.x
rcp r1.y, r1.y
add r3.w, -r0, r1.y
add r1.z, -r0.w, -r1.y
rcp r2.y, r1.w
mul r1.z, r1, r2.y
mul r2.y, r2, r3.w
mov r0.w, c68.x
cmp r0.y, -r1.x, c68, c68.x
mul_pp r0.x, r0, c22
mul_pp r2.z, r0.x, r0.y
add r0.z, c69.w, r0
mul_sat r0.x, r0.z, c70
mad r0.y, -r0.x, c70, c70.z
mul r0.x, r0, r0
mul r1.x, r0, r0.y
cmp r2.x, -r2.z, c68.z, r1.z
mad r0.xyz, r3, r2.x, r4
add r0.xyz, r0, -c17
dp3 r0.x, r0, c24
mad r1.x, r1, c71, c71.y
mul r1.z, r1.x, c51.x
cmp r0.x, -r0, c68.y, c68
add r1.x, r10.z, c68
mul_pp r2.w, r2.z, r0.x
cmp r2.y, -r2.z, c68.w, r2
mov r2.z, c42.x
add r5.x, c67.y, r2.z
abs r3.w, c42.x
cmp r2.z, -r3.w, c68.x, c68.y
abs r3.w, r5.x
cmp r5.x, -r3.w, c68, c68.y
abs_pp r2.z, r2
cmp_pp r3.w, -r2.z, c68.x, c68.y
mul_pp r5.y, r3.w, r5.x
rcp r1.z, r1.z
mul r1.x, r1, c45
mad r1.x, r1, r1.z, r10.z
min r4.w, r10, r1.x
add r0.y, r10.z, r4.w
mul r0.xyz, r3, r0.y
mad r0.xyz, r0, c70.w, r4
mul r0.xyz, r0, c21.x
dp4 r1.x, r0, c8
dp4 r1.y, r0, c10
add r1.xy, r1, c68.x
mov r2.z, c42.x
mov r1.z, c67
mul r1.xy, r1, c70.w
texldl r1, r1.xyzz, s2
mul r1, r1, c34
add r1, r1, c33
cmp r5.y, -r5, r1.x, r1
add r1.y, c71.z, r2.z
abs_pp r1.x, r5
abs r1.y, r1
cmp r1.y, -r1, c68.x, c68
cmp_pp r1.x, -r1, c68, c68.y
mul_pp r1.x, r3.w, r1
mul_pp r3.w, r1.x, r1.y
abs_pp r2.z, r1.y
cmp r1.z, -r3.w, r5.y, r1
cmp_pp r1.y, -r2.z, c68.x, c68
mul_pp r1.y, r1.x, r1
mov r1.x, c44
cmp r6.w, -r1.y, r1.z, r1
mad r1.y, r1.x, c72.z, c72.w
mul r1.x, r6.w, c46.z
mul_sat r1.x, r1, r1.y
mul r8.w, r1.x, c73.x
dp4 r1.x, r0, c12
dp4 r1.y, r0, c14
add r0.xy, r1, c68.x
dp3 r1.x, r3, c24
mul r0.w, -r1.x, -r1.x
mad r1.y, -r0.w, c69, c69.z
rsq r1.y, r1.y
cmp r10.xy, -r2.w, r2, c68.zwzw
mul r0.xy, r0, c70.w
mov r0.z, c67
texldl r0, r0.xyzz, s1
mul r0, r0, c36
rcp r1.y, r1.y
add r2, r0, c35
pow_sat r0, r1.y, c63.x
mul r0.y, -r1.x, c57.x
add r0.z, r0.y, c68.x
mov r0.w, r0.x
mul r0.y, -c57.x, c57.x
rcp r0.z, r0.z
add r0.y, r0, c68.x
mul r0.y, r0, r0.z
mul r0.y, r0, r0.z
mul r0.z, r0.y, c58.x
mul r0.x, -r1, c59
add r0.y, r0.x, c68.x
mad r0.z, r0.w, c64.x, r0
mul r0.x, -c59, c59
rcp r0.y, r0.y
add r0.x, r0, c68
mul r0.x, r0, r0.y
mul r0.y, r0.x, r0
mul r0.x, -r1, c61
mad r0.z, r0.y, c60.x, r0
add r0.y, r0.x, c68.x
mul r0.x, -c61, c61
rcp r0.y, r0.y
add r0.x, r0, c68
mul r0.x, r0, r0.y
mul r0.x, r0, r0.y
dp3 r0.w, r3, c18
abs r0.y, r0.w
add r0.w, r0.y, c71
mad r5.w, r0.x, c62.x, r0.z
mov r0.xyz, c24
dp3 r0.z, c18, r0
mul_sat r0.w, r0, c72.x
abs r0.z, r0
mul r0.x, r0.w, r0.w
mad r0.y, -r0.w, c70, c70.z
mul r0.y, r0.x, r0
mov r0.x, c51
mul r0.x, c41, -r0
rcp r0.z, r0.z
mul r0.z, r0.x, r0
mul r0.x, r10.z, r0.y
mul r1.x, r0.z, c73.z
mul_sat r7.w, r0.x, c72.y
pow r0, c73.y, r1.x
mov r0.z, c39.x
mov r0.y, c68.x
add r0.z, c67.y, r0
cmp r3.w, r0.z, c39.x, r0.y
add r0.y, r3.w, c68.x
rcp r0.z, r0.y
add r0.y, -r10.z, r4.w
mul r10.w, r0.y, r0.z
mov r9.w, r0.x
mov r0.xyz, c18
mul r11.x, r10.w, c73.z
rcp r11.y, r10.w
mad r11.z, r10.w, c70.w, r10
dp3 r4.w, c24, r0
mov r5.xyz, c67.z
mov r6.xyz, c68.x
mov r11.w, c67.z
loop aL, i0
break_ge r11.w, r3.w
mad r7.xyz, r11.z, r3, r4
mul r0.xyz, r7.xzyw, c43.x
add r8.xy, r0, c47
mov r8.z, r0
mul r0.xyz, r8, c48.x
add r1.xy, r0, c47.zwzw
mov r1.z, r0
mul r0.xyz, r1, c48.x
add r0.xy, r0, c47.zwzw
mul r9.xyz, r0, c48.x
add r9.xy, r9, c47.zwzw
mov r12.y, r9.z
mov r12.x, r9
add r0.zw, r0.xyxz, c73.z
mul r0.zw, r0, c73.w
add r12.xy, r12, c73.z
mul r12.xy, r12, c73.w
mul r12.zw, r12.xyxy, c73.x
abs r12.zw, r12
frc r12.zw, r12
mul r12.zw, r12, c73.w
cmp r12.xy, r12, r12.zwzw, -r12.zwzw
mul r13.xy, r0.zwzw, c73.x
frc r0.x, r12.y
abs r12.zw, r13.xyxy
add r1.w, -r0.x, r12.y
mad r1.w, r1, c74.x, r12.x
add r1.w, r1, c74.y
mul r9.x, r1.w, c74.z
mov r9.z, c67
frc r12.zw, r12
mul r12.zw, r12, c73.w
cmp r0.zw, r0, r12, -r12
frc r12.x, r0.w
add r0.w, -r12.x, r0
mad r0.w, r0, c74.x, r0.z
texldl r9.xy, r9.xyzz, s3
add r0.z, r9.y, -r9.x
mad r9.z, r0.x, r0, r9.x
add r0.w, r0, c74.y
add r1.zw, r1.xyxz, c73.z
mul r0.x, r0.w, c74.z
mov r0.z, c67
texldl r0.xy, r0.xyzz, s3
mul r0.zw, r1, c73.w
add r0.y, r0, -r0.x
mad r12.x, r12, r0.y, r0
mul r1.zw, r0, c73.x
abs r0.xy, r1.zwzw
add r1.zw, r8.xyxz, c73.z
mul r1.zw, r1, c73.w
frc r0.xy, r0
mul r0.xy, r0, c73.w
cmp r0.xy, r0.zwzw, r0, -r0
frc r1.x, r0.y
add r0.y, -r1.x, r0
mad r0.x, r0.y, c74, r0
mul r9.xy, r1.zwzw, c73.x
abs r0.zw, r9.xyxy
frc r0.zw, r0
mul r0.zw, r0, c73.w
cmp r1.zw, r1, r0, -r0
frc r0.w, r1
add r0.x, r0, c74.y
add r1.w, -r0, r1
mov r0.z, c67
mov r0.y, r1
mul r0.x, r0, c74.z
texldl r0.xy, r0.xyzz, s3
mad r0.z, r1.w, c74.x, r1
add r0.y, r0, -r0.x
mad r1.z, r1.x, r0.y, r0.x
add r0.z, r0, c74.y
mul r0.x, r0.z, c74.z
mov r0.y, r8
mov r0.z, c67
texldl r1.xy, r0.xyzz, s3
add r0.xyz, r7, -c17
dp3 r0.x, r0, r0
mov r0.y, c19.x
rsq r0.x, r0.x
add r1.y, r1, -r1.x
add r0.y, c40.x, r0
rcp r0.x, r0.x
add r13.x, r0, -r0.y
mad r0.x, r0.w, r1.y, r1
mad r0.y, r1.z, c49.x, r0.x
mul r0.x, c49, c49
mad r0.y, r0.x, r12.x, r0
mov r0.w, c44.x
mul r0.z, r13.x, c41.y
mad r0.z, r0, c67.x, c67.y
mul r0.x, r0, c49
mad r0.x, r0, r9.z, r0.y
abs r0.z, r0
mul r0.y, r0.z, r0.z
mul r0.y, r0, r0
mul_sat r1.w, r13.x, c41.y
add r1.w, -r1, c68.x
min r1.x, c74.w, r0.w
mul r0.z, r0.y, r0.y
mad r0.w, -r0.z, r0.y, c68.x
mul r0.x, r0, c49.y
mad r0.yz, r0.w, c55.x, r1.x
mad r0.x, r0, r0.w, c44
mul_sat r1.xyz, r6.w, r0
mov r0.xyz, r7
mov r0.w, c68.x
dp4 r8.x, r0, c4
dp4 r8.y, r0, c5
mul r12.x, r1.w, c65
mov r8.z, c67
if_gt r12.x, c75.x
texldl r0, r8.xyzz, s4
add r12.x, r12, c75.y
else
if_gt r12.x, c75.z
texldl r0, r8.xyzz, s5
add r12.x, r12, c75.w
else
texldl r0, r8.xyzz, s6
endif
endif
mad r12.zw, r7.w, -r1.xyyz, r1.xyyz
add r1.y, r8.w, -r1.x
mad r12.y, r7.w, r1, r1.x
add r1.xyz, -r7, c30
mov r9.xyz, c23
add r7.xyz, -r7, c27
mul r12.w, r12, c52.x
mul r13.z, r12, c52.x
add r9.xyz, c25, r9
mul r8.xyz, r2.w, c37
mul r8.xyz, r8, r9
mov_sat r1.w, r4
mul r8.xyz, r8, r1.w
mad r8.xyz, r8, c76.z, r2
mul r8.xyz, r8, c56.y
mul r1.w, r12.y, r12
mul r9.xyz, r1.w, r8
mul r8.x, r13, -r12.w
dp3 r1.w, r1, r1
rsq r12.w, r1.w
mul r13.y, r8.x, c73.z
mul r8.xyz, r12.w, r1
pow r1, c73.y, r13.y
dp3 r1.y, r3, r8
mov r1.z, r1.x
mul r1.y, r1, c38.x
add r1.x, r1.y, c68
rcp r13.y, r1.x
add r1.x, -r13, c41
mul r1.y, -r13.z, r1.x
mul r8.xyz, r9, r1.z
mul r1.x, -c38, c38
add r12.z, r1.x, c68.x
mul r9.x, r1.y, c73.z
pow r1, c73.y, r9.x
mul r13.x, r12.z, r13.y
add r9.xyz, v1, c26
mul r1.y, r12, r13.z
mul r9.xyz, r9, c56.x
mul r9.xyz, r1.y, r9
mad r8.xyz, r9, r1.x, r8
dp3 r9.x, r7, r7
mov r1.xyz, c31
add r1.xyz, -c30, r1
dp3 r1.x, r1, r1
rsq r9.x, r9.x
rsq r9.y, r1.x
mul r1.xyz, r9.x, r7
dp3 r1.x, r1, r3
rcp r7.y, r9.x
rcp r1.y, r12.w
mul r1.x, r1, c38
mul r1.y, r1, c73.z
mul r1.y, r1, r1
add r1.x, r1, c68
rcp r1.x, r1.x
rcp r1.z, r1.y
rcp r7.x, r9.y
mul r1.w, r13.x, r13.y
mul r1.w, r7.x, r1
mul r1.y, r12.z, r1.x
mul r1.w, r1, r1.z
mul r7.x, r1.y, r1
mov r1.xyz, c28
add r1.xyz, -c27, r1
dp3 r1.x, r1, r1
mul r7.y, r7, c73.z
mul r1.y, r7, r7
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r7
rcp r1.y, r1.y
mul r1.x, r1, r1.y
mul r1.y, r1.w, c73.z
mul r1.x, r1, c73.z
add r1.w, r12.x, c71.z
cmp r1.w, r1, c68.x, c68.y
min r7.x, r1, c68
min r1.y, r1, c68.x
mul r1.xyz, r1.y, c32
mad r1.xyz, r7.x, c29, r1
add r7.x, r12, c67.y
cmp r7.y, r7.x, c68.x, c68
add r7.z, -r1.w, c68.x
mul r7.z, r7.y, r7
mul r9.x, r0.z, r7.z
add r7.y, -r7, c68.x
add r7.x, r12, c76
mad r9.x, r0.y, r7.y, r9
mul r7.z, r0.y, r7
cmp r7.x, r7, c68, c68.y
mul r1.xyz, r1, c76.y
add r0.y, -r7.x, c68.x
mad r7.y, r0.x, r7, r7.z
mul r0.x, r1.w, r0.y
mad r0.y, r0.z, r0.x, r7
mad r0.x, r0.w, r0, r9
mad r0.y, r7.x, r0.w, r0
mad r0.x, r7, r0.w, r0
add r0.w, -r11.z, r10.y
add r0.z, r0.x, -r0.y
frc r0.x, r12
mad_sat r0.x, r0, r0.z, r0.y
add r11.z, r11, r10.w
add r0.z, r11, -r10.x
add r0.y, r9.w, -r0.x
mul_sat r0.w, r11.y, r0
mul_sat r0.z, r0, r11.y
mad r0.z, -r0, r0.w, c68.x
mad r0.w, r7, r0.y, r0.x
mul r0.w, r0, c53.x
mul r0.xyz, r0.z, v2
mul r0.xyz, r0.w, r0
mad r0.xyz, r0, r5.w, r1
mul r0.w, r12.y, c51.x
mul r1.w, r11.x, -r0
mul r1.xyz, r8, c54.x
mul r0.w, r12.y, c52.x
mul r1.xyz, r1, c76.y
mad r1.xyz, r0.w, r0, r1
pow r0, c73.y, r1.w
mul r1.xyz, r1, r11.x
mad r5.xyz, r1, r6, r5
mul r6.xyz, r6, r0.x
add r11.w, r11, c68.x
endloop
add r1.x, c46.y, -c46
rcp r1.y, r1.x
add r1.x, r10.z, -c46
mul r0.xyz, r5, c50
dp3 r0.w, r6, c77
add r2, -r0, c68.yyyx
mul_sat r1.x, r1, r1.y
mad r1, r1.x, r2, r0
endif
mov oC0, r1

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 computes environment lighting for the sky (this is simply the cloud rendered into a small map)
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
Vector 17 [_CloudThicknessKm]
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
Vector 20 [_SunColorFromGround]
Vector 21 [_SunDirection]
Vector 22 [_AmbientSkyFromGround]
Vector 23 [_AmbientNightSky]
Vector 24 [_EnvironmentAngles]
Vector 25 [_NuajLightningPosition00]
Vector 26 [_NuajLightningPosition01]
Vector 27 [_NuajLightningColor0]
Vector 28 [_NuajLightningPosition10]
Vector 29 [_NuajLightningPosition11]
Vector 30 [_NuajLightningColor1]
Vector 31 [_NuajLocalCoverageOffset]
Vector 32 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Vector 33 [_NuajTerrainEmissiveOffset]
Vector 34 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 8 [_NuajTerrainEmissiveTransform]
Vector 35 [_NuajTerrainAlbedo]
Vector 36 [_Sigma_Rayleigh]
Float 37 [_Sigma_Mie]
Float 38 [_MiePhaseAnisotropy]
SetTexture 2 [_NuajTexNoise3D0] 2D
Float 39 [_StepsCount]
Float 40 [_CloudAltitudeKm]
Vector 41 [_CloudThicknessKm]
Float 42 [_CloudLayerIndex]
Float 43 [_NoiseTiling]
Float 44 [_Coverage]
Vector 45 [_HorizonBlend]
Vector 46 [_CloudPosition]
Float 47 [_FrequencyFactor]
Vector 48 [_AmplitudeFactor]
Vector 49 [_CloudColor]
Float 50 [_CloudSigma_t]
Float 51 [_CloudSigma_s]
Float 52 [_DirectionalFactor]
Float 53 [_IsotropicFactor]
Float 54 [_IsotropicDensity]
Vector 55 [_IsotropicScatteringFactors]
Float 56 [_PhaseAnisotropyStrongForward]
Float 57 [_PhaseWeightStrongForward]
Float 58 [_PhaseAnisotropyForward]
Float 59 [_PhaseWeightForward]
Float 60 [_PhaseAnisotropyBackward]
Float 61 [_PhaseWeightBackward]
Float 62 [_PhaseAnisotropySide]
Float 63 [_PhaseWeightSide]
SetTexture 3 [_TexDeepShadowMap0] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[72] = { program.local[0..63],
		{ 0, 1, 1000000, -1000000 },
		{ 0.80000001, 0.5, 2, 0.1 },
		{ -10, 3, 0.0125, 1.4 },
		{ 0.0625, 2.718282, 1000, 16 },
		{ 255, 0, 1, 17 },
		{ 0.25, 0.0036764706, -0.1875, 4 },
		{ 10, 0.079577468, 0.12509382, 0.83333331 },
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
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MADR  R3.xy, fragment.texcoord[0], c[24].zwzw, c[24];
COSR  R0.x, R3.y;
MOVR  R4.x, c[40];
MULR  R0.xyz, R0.x, c[13];
SINR  R2.w, R3.y;
SINR  R2.x, R3.x;
MULR  R2.x, R2.w, R2;
MADR  R2.xyz, R2.x, c[14], R0;
COSR  R3.w, R3.x;
MULR  R2.w, R2, R3;
MOVR  R0.y, c[2].w;
MOVR  R0.x, c[0].w;
MULR  R0.xz, R0.xyyw, c[17].x;
MOVR  R0.y, c[64].x;
ADDR  R3.xyz, R0, -c[12];
MADR  R2.xyz, R2.w, c[15], R2;
DP3R  R2.w, R2, R3;
DP3R  R3.y, R3, R3;
ADDR  R4.x, R4, c[16];
ADDR  R3.x, R4, c[41];
MADR  R3.z, -R3.x, R3.x, R3.y;
MULR  R3.w, R2, R2;
SGER  H0.z, R3.w, R3;
ADDR  R4.y, R3.w, -R3.z;
SLTRC HC.x, R3.w, R3.z;
MOVR  R3.x, c[64];
MADR  R3.z, -R4.x, R4.x, R3.y;
RSQR  R4.y, R4.y;
RCPR  R4.y, R4.y;
MOVR  R3.x(EQ), R0.w;
SLTR  H0.x, -R2.w, -R4.y;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[64].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R3.y, c[64].x;
MOVR  R3.x(NE), c[64];
SLTR  H0.z, -R2.w, R4.y;
MULXC HC.x, H0.y, H0.z;
ADDR  R3.x(NE), -R2.w, R4.y;
MOVX  H0.x(NE), c[64];
MULXC HC.x, H0.y, H0;
SGER  H0.z, R3.w, R3;
ADDR  R3.x(NE), -R2.w, -R4.y;
SLTRC HC.x, R3.w, R3.z;
MOVR  R3.y(EQ.x), R0.w;
ADDR  R0.w, R3, -R3.z;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
SLTR  H0.x, -R2.w, -R0.w;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[64].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R3.y(NE.x), c[64].x;
SLTR  H0.z, -R2.w, R0.w;
MULXC HC.x, H0.y, H0.z;
ADDR  R3.y(NE.x), -R2.w, R0.w;
MOVX  H0.x(NE), c[64];
MULXC HC.x, H0.y, H0;
ADDR  R3.y(NE.x), -R2.w, -R0.w;
MINR  R0.w, R3.y, R3.x;
MAXR  R10.z, R0.w, c[64].x;
MAXR  R0.w, R3.y, R3.x;
SGTRC HC.x, R10.z, R0.w;
MOVR  oCol, c[64].xxxy;
MOVR  oCol(EQ.x), R1;
SLERC HC.x, R10.z, R0.w;
MOVR  R10.w, R0;
IF    NE.x;
ADDR  R1.xyz, R0, -c[12];
MULR  R3.xyz, R1.zxyw, c[21].yzxw;
MADR  R3.xyz, R1.yzxw, c[21].zxyw, -R3;
DP3R  R1.x, R1, c[21];
SLER  H0.x, R1, c[64];
DP3R  R0.w, R3, R3;
MULR  R4.xyz, R2.zxyw, c[21].yzxw;
MADR  R4.xyz, R2.yzxw, c[21].zxyw, -R4;
DP3R  R1.w, R3, R4;
DP3R  R2.w, R4, R4;
MADR  R0.w, -c[16].x, c[16].x, R0;
MULR  R3.y, R2.w, R0.w;
MULR  R3.x, R1.w, R1.w;
ADDR  R0.w, R3.x, -R3.y;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
ADDR  R1.y, -R1.w, R0.w;
ADDR  R0.w, -R1, -R0;
MOVR  R5.xy, c[64];
MOVR  R1.w, c[64].y;
SGTR  H0.y, R3.x, R3;
MULX  H0.x, H0, c[19];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R2.w, R2.w;
MOVR  R1.z, c[64].w;
MULR  R1.z(NE.x), R2.w, R1.y;
MOVR  R1.x, c[64].z;
MULR  R1.x(NE), R0.w, R2.w;
MOVR  R1.y, R1.z;
MOVR  R10.xy, R1;
MADR  R1.xyz, R2, R1.x, R0;
ADDR  R1.xyz, R1, -c[12];
DP3R  R0.w, R1, c[21];
SGTR  H0.y, R0.w, c[64].x;
MULXC HC.x, H0, H0.y;
SEQR  H0.xy, c[42].x, R5;
ADDR  R0.w, R10.z, R10;
MULR  R1.xyz, R2, R0.w;
MADR  R1.xyz, R1, c[65].y, R0;
MULR  R1.xyz, R1, c[18].x;
SEQX  H0.zw, H0.xyxy, c[64].x;
MOVR  R0.w, c[65].z;
SEQR  H0.x, c[42], R0.w;
MOVR  R10.xy(NE.x), c[64].zwzw;
MULXC HC.x, H0.z, H0.y;
DP4R  R3.x, R1, c[4];
DP4R  R3.y, R1, c[6];
MADR  R3.xy, R3, c[65].y, c[65].y;
MOVR  R4, c[31];
TEX   R3, R3, texture[1], 2D;
MADR  R3, R3, c[32], R4;
MOVR  R2.w, R3.x;
MOVR  R2.w(NE.x), R3.y;
MULX  H0.y, H0.z, H0.w;
MULXC HC.x, H0.y, H0;
MOVR  R4, c[33];
MOVR  R2.w(NE.x), R3.z;
SEQX  H0.x, H0, c[64];
MULXC HC.x, H0.y, H0;
MOVR  R2.w(NE.x), R3;
MULR  R3.x, R2.w, c[45].z;
MULR  R3.y, R3.x, c[44].x;
MADR_SAT R3.x, R3.y, c[66].w, R3;
ADDR  R3.y, R10.w, -R10.z;
MOVR  R0.w, c[39].x;
SLTRC HC.x, c[39], R5.y;
MOVR  R0.w(NE.x), c[64].y;
MULR  R3.w, R3.x, c[67].x;
ADDR  R3.x, R0.w, c[64].y;
RCPR  R3.x, R3.x;
MULR  R10.w, R3.y, R3.x;
DP4R  R3.x, R1, c[8];
DP4R  R3.y, R1, c[10];
MADR  R1.xy, R3, c[65].y, c[65].y;
DP3R  R3.x, R2, c[21];
MADR  R3.z, -R3.x, c[56].x, R5.y;
MULR  R3.y, -R3.x, -R3.x;
TEX   R1, R1, texture[0], 2D;
MADR  R1, R1, c[34], R4;
MADR  R3.y, -R3, c[65].x, R5;
RCPR  R3.z, R3.z;
MULR  R4.x, c[56], c[56];
MADR  R4.x, -R4, R3.z, R3.z;
MULR  R3.z, R4.x, R3;
MULR  R4.y, R3.z, c[57].x;
RSQR  R3.y, R3.y;
RCPR  R3.z, R3.y;
POWR  R4.x, R3.z, c[62].x;
MADR  R3.y, -R3.x, c[58].x, R5;
RCPR  R3.z, R3.y;
MULR  R3.y, c[58].x, c[58].x;
MADR  R3.y, -R3, R3.z, R3.z;
MULR  R3.y, R3, R3.z;
MADR  R3.z, -R3.x, c[60].x, R5.y;
MOVR_SAT R4.x, R4;
MADR  R4.x, R4, c[63], R4.y;
MADR  R3.y, R3, c[59].x, R4.x;
DP3R  R3.x, R2, c[13];
ADDR  R4.y, |R3.x|, -c[65].w;
RCPR  R3.z, R3.z;
MULR  R4.x, c[60], c[60];
MADR  R4.x, -R4, R3.z, R3.z;
MULR  R3.z, R4.x, R3;
MULR_SAT R4.y, R4, c[66].x;
MOVR  R3.x, c[66].y;
MADR  R3.x, -R4.y, c[65].z, R3;
MULR  R4.y, R4, R4;
MULR  R3.x, R4.y, R3;
MULR  R4.x, R10.z, R3;
MADR  R6.w, R3.z, c[61].x, R3.y;
MOVR  R3.xyz, c[13];
DP3R  R3.y, R3, c[21];
MOVR  R3.x, c[41];
RCPR  R3.y, |R3.y|;
MULR  R3.x, R3, -c[50];
MULR_SAT R8.w, R4.x, c[66].z;
MULR  R4.x, R3, R3.y;
MOVR  R3.xyz, c[21];
MULR  R4.x, R4, c[67].z;
DP3R  R4.w, R3, c[13];
POWR  R9.w, c[67].y, R4.x;
MULR  R11.x, R10.w, c[67].z;
RCPR  R11.y, R10.w;
MADR  R11.z, R10.w, c[65].y, R10;
MOVR  R3.xyz, c[64].x;
MOVR  R4.xyz, c[64].y;
MOVR  R11.w, c[64].x;
LOOP c[68];
SLTRC HC.x, R11.w, R0.w;
BRK   (EQ.x);
MADR  R8.xyz, R11.z, R2, R0;
MULR  R5.xyz, R8.xzyw, c[43].x;
ADDR  R7.xy, R5, c[46];
MOVR  R7.z, R5;
MULR  R5.xyz, R7, c[47].x;
ADDR  R6.xy, R5, c[46].zwzw;
MOVR  R6.z, R5;
MULR  R5.xyz, R6, c[47].x;
ADDR  R5.xy, R5, c[46].zwzw;
MULR  R9.xyz, R5, c[47].x;
ADDR  R13.xy, R9, c[46].zwzw;
MOVR  R9.y, R9.z;
MOVR  R9.x, R13;
ADDR  R9.xy, R9, c[67].z;
MULR  R12.xy, R9, c[67].w;
MULR  R9.xy, R12, c[67].x;
FRCR  R9.xy, |R9|;
MULR  R12.zw, R9.xyxy, c[67].w;
MOVR  R9.xy, R12.zwzw;
MOVXC RC.xy, R12;
ADDR  R5.zw, R5.xyxz, c[67].z;
MULR  R12.xy, R5.zwzw, c[67].w;
MOVR  R9.xy(LT), -R12.zwzw;
MULR  R5.zw, R12.xyxy, c[67].x;
FRCR  R5.zw, |R5|;
MULR  R12.zw, R5, c[67].w;
MOVR  R5.zw, R12;
MOVXC RC.xy, R12;
ADDR  R7.zw, R7.xyxz, c[67].z;
MULR  R12.xy, R7.zwzw, c[67].w;
MOVR  R5.zw(LT.xyxy), -R12;
MULR  R7.zw, R12.xyxy, c[67].x;
MOVXC RC.xy, R12;
FRCR  R7.zw, |R7|;
MULR  R12.zw, R7, c[67].w;
MOVR  R7.zw, R12;
MOVR  R7.zw(LT.xyxy), -R12;
ADDR  R12.xy, R6.xzzw, c[67].z;
MULR  R12.zw, R12.xyxy, c[67].w;
FLRR  R5.x, R7.w;
MADR  R6.x, R5, c[68].w, R7.z;
ADDR  R6.x, R6, c[69];
MULR  R7.x, R6, c[69].y;
TEX   R7.xy, R7, texture[2], 2D;
MULR  R12.xy, R12.zwzw, c[67].x;
FRCR  R12.xy, |R12|;
MULR  R13.zw, R12.xyxy, c[67].w;
MOVR  R12.xy, R13.zwzw;
MOVXC RC.xy, R12.zwzw;
MOVR  R12.xy(LT), -R13.zwzw;
ADDR  R6.x, R7.y, -R7;
ADDR  R5.x, R7.w, -R5;
MADR  R6.z, R5.x, R6.x, R7.x;
FLRR  R5.x, R12.y;
MADR  R6.x, R5, c[68].w, R12;
ADDR  R6.x, R6, c[69];
MULR  R6.x, R6, c[69].y;
TEX   R6.xy, R6, texture[2], 2D;
ADDR  R6.y, R6, -R6.x;
ADDR  R5.x, R12.y, -R5;
MADR  R5.x, R5, R6.y, R6;
FLRR  R6.x, R5.w;
MADR  R6.y, R5.x, c[48].x, R6.z;
MADR  R5.x, R6, c[68].w, R5.z;
ADDR  R5.z, R5.w, -R6.x;
ADDR  R5.x, R5, c[69];
MULR  R5.x, R5, c[69].y;
TEX   R5.xy, R5, texture[2], 2D;
ADDR  R5.y, R5, -R5.x;
MADR  R5.x, R5.z, R5.y, R5;
MULR  R5.z, c[48].x, c[48].x;
MADR  R6.x, R5.z, R5, R6.y;
FLRR  R5.w, R9.y;
MADR  R5.x, R5.w, c[68].w, R9;
ADDR  R5.w, R9.y, -R5;
ADDR  R5.x, R5, c[69];
MOVR  R9.y, c[64];
MOVR_SAT R9.z, R4.w;
MULR  R5.x, R5, c[69].y;
MOVR  R5.y, R13;
TEX   R5.xy, R5, texture[2], 2D;
ADDR  R5.y, R5, -R5.x;
MADR  R5.x, R5.w, R5.y, R5;
MULR  R5.y, R5.z, c[48].x;
MADR  R5.x, R5.y, R5, R6;
ADDR  R6.xyz, R8, -c[12];
DP3R  R5.y, R6, R6;
MOVR  R5.z, c[40].x;
RSQR  R5.y, R5.y;
ADDR  R5.z, R5, c[16].x;
RCPR  R5.y, R5.y;
ADDR  R5.w, R5.y, -R5.z;
MULR  R5.y, R5.w, c[41];
MADR  R5.y, R5, c[65].z, -R9;
MULR  R5.y, |R5|, |R5|;
MULR  R6.x, R5.y, R5.y;
MULR  R6.y, R6.x, R6.x;
MULR  R6.x, R6.y, R6;
MULR  R5.x, R5, c[48].y;
MOVR  R5.yz, c[54].x;
MADR  R5.xyz, -R6.x, R5, R5;
MOVR  R6.x, c[69].z;
MINR  R6.x, R6, c[44];
ADDR  R5.yz, R5, R6.x;
ADDR  R5.x, R5, c[44];
MULR_SAT R5.xyz, R2.w, R5;
ADDR  R6.x, R3.w, -R5;
MADR  R9.x, R8.w, R6, R5;
MADR  R5.xy, R8.w, -R5.yzzw, R5.yzzw;
MULR  R7.xy, R5, c[51].x;
MOVR  R6.xyz, c[22];
MULR  R7.zw, R9.x, R7.xyxy;
ADDR  R6.xyz, R6, c[20];
MULR  R5.xyz, R1.w, c[35];
MULR  R5.xyz, R5, R6;
MULR  R6.x, R5.w, -R7.y;
MULR  R5.xyz, R5, R9.z;
ADDR  R7.y, -R5.w, c[41].x;
MULR  R7.x, -R7, R7.y;
MADR  R5.xyz, R5, c[70].y, R1;
MULR  R5.xyz, R5, c[55].y;
MULR  R5.xyz, R7.w, R5;
MULR  R6.x, R6, c[67].z;
POWR  R6.x, c[67].y, R6.x;
MULR  R6.xyz, R5, R6.x;
ADDR  R5.xyz, fragment.texcoord[1], c[23];
MULR  R5.xyz, R5, c[55].x;
MULR  R7.x, R7, c[67].z;
MULR  R5.xyz, R7.z, R5;
POWR  R7.x, c[67].y, R7.x;
MADR  R5.xyz, R5, R7.x, R6;
MULR  R5.xyz, R5, c[53].x;
MULR  R6.xyz, R5, c[70].x;
MULR_SAT R5.x, R5.w, c[41].y;
MADR  R7.z, -R5.x, c[69].w, c[69].w;
SGER  H0.z, R7, c[64].y;
SGER  H0.y, R7.z, c[65].z;
SGER  H0.x, R7.z, c[66].y;
TEX   R5, fragment.texcoord[0], texture[3], 2D;
MADR  R7.x, -H0.y, H0.z, H0.z;
MULR  R7.xy, R5.zyzw, R7.x;
ADDR  R9.z, -H0, c[64].y;
MADR  R5.xy, R5.yxzw, R9.z, R7;
MADR  R7.x, -H0, H0.y, H0.y;
MADR  R7.xy, R5.wzzw, R7.x, R5;
MADR  R7.xy, H0.x, R5.w, R7;
ADDR  R5.xyz, -R8, c[25];
DP3R  R9.z, R5, R5;
ADDR  R5.w, R7.x, -R7.y;
RSQR  R7.x, R9.z;
MULR  R5.xyz, R7.x, R5;
DP3R  R5.x, R2, R5;
FRCR  R7.z, R7;
MADR_SAT R5.w, R7.z, R5, R7.y;
ADDR  R7.y, R9.w, -R5.w;
MADR  R5.y, R8.w, R7, R5.w;
MADR  R5.x, R5, c[38], R9.y;
RCPR  R7.x, R7.x;
RCPR  R7.z, R5.x;
MULR  R7.y, c[38].x, c[38].x;
MADR  R9.z, -R7.y, R7, R7;
MULR  R5.w, R5.y, c[52].x;
MOVR  R5.xyz, c[25];
MULR  R7.z, R9, R7;
ADDR  R5.xyz, -R5, c[26];
DP3R  R9.z, R5, R5;
ADDR  R5.xyz, -R8, c[28];
RSQR  R8.x, R9.z;
RCPR  R8.x, R8.x;
MULR  R8.x, R8, R7.z;
DP3R  R8.y, R5, R5;
RSQR  R7.z, R8.y;
MULR  R5.xyz, R7.z, R5;
DP3R  R5.x, R2, R5;
MULR  R7.x, R7, c[67].z;
MULR  R5.y, R7.x, R7.x;
MADR  R5.x, R5, c[38], R9.y;
RCPR  R5.x, R5.x;
MADR  R5.z, -R7.y, R5.x, R5.x;
RCPR  R5.y, R5.y;
MULR  R5.y, R8.x, R5;
MULR  R7.x, R5.y, c[67].z;
MULR  R7.y, R5.z, R5.x;
MOVR  R5.xyz, c[28];
ADDR  R5.xyz, -R5, c[29];
DP3R  R5.x, R5, R5;
RCPR  R7.z, R7.z;
MULR  R7.z, R7, c[67];
MULR  R5.y, R7.z, R7.z;
ADDR  R7.z, -R11, R10.y;
RSQR  R5.x, R5.x;
RCPR  R5.x, R5.x;
MULR  R5.x, R5, R7.y;
RCPR  R5.y, R5.y;
MULR  R5.x, R5, R5.y;
MULR  R5.x, R5, c[67].z;
MINR  R5.x, R5, c[64].y;
ADDR  R11.z, R11, R10.w;
ADDR  R7.y, R11.z, -R10.x;
MULR  R5.xyz, R5.x, c[30];
MULR_SAT R7.z, R11.y, R7;
MULR_SAT R7.y, R7, R11;
MULR  R8.x, R7.y, R7.z;
MINR  R7.x, R7, c[64].y;
MADR  R7.xyz, R7.x, c[27], R5;
MADR  R5.xyz, -R8.x, fragment.texcoord[2], fragment.texcoord[2];
MULR  R7.w, R9.x, c[51].x;
MULR  R7.xyz, R7, c[70].x;
MULR  R5.xyz, R5.w, R5;
MADR  R5.xyz, R5, R6.w, R7;
MADR  R5.xyz, R7.w, R5, R6;
MULR  R5.xyz, R5, R11.x;
MADR  R3.xyz, R5, R4, R3;
MULR  R5.x, R9, c[50];
MULR  R5.x, R11, -R5;
POWR  R5.x, c[67].y, R5.x;
MULR  R4.xyz, R4, R5.x;
ADDR  R11.w, R11, c[64].y;
ENDLOOP;
MADR  R1.xyz, R10.z, R2, R0;
ADDR  R0.xyz, R0, -c[12];
DP3R  R0.x, R0, R0;
ADDR  R1.xyz, R1, -c[12];
DP3R  R0.w, R1, R1;
MULR  R1.xyz, R3, c[49];
RSQR  R0.w, R0.w;
RCPR  R0.y, R0.w;
RSQR  R0.x, R0.x;
RCPR  R0.z, R0.x;
DP3R  R1.w, R4, c[71];
ADDR  R0.y, R0, -c[16].x;
MULR  R0.xy, R0.y, c[70].zwzw;
ADDR  R0.z, R0, -c[16].x;
MULR  R0.zw, R0.z, c[70];
POWR  R0.z, c[67].y, -R0.z;
POWR  R0.w, c[67].y, -R0.w;
POWR  R0.x, c[67].y, -R0.x;
POWR  R0.y, c[67].y, -R0.y;
ADDR  R0.xy, R0.zwzw, R0;
MULR  R0.xy, R0, c[65].y;
MULR  R0.w, R0.y, c[37].x;
MULR  R0.xyz, R0.x, c[36];
MADR  R0.xyz, R0, c[69].x, R0.w;
MULR  R0.xyz, R10.z, -R0;
ADDR  R0.w, c[45].y, -c[45].x;
ADDR  R2, -R1, c[64].xxxy;
RCPR  R0.w, R0.w;
ADDR  R3.x, R10.z, -c[45];
MULR_SAT R0.w, R3.x, R0;
MADR  R1, R0.w, R2, R1;
POWR  R0.x, c[67].y, R0.x;
POWR  R0.z, c[67].y, R0.z;
POWR  R0.y, c[67].y, R0.y;
MULR  oCol.xyz, R1, R0;
MOVR  oCol.w, R1;
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
Vector 20 [_SunColorFromGround]
Vector 21 [_SunDirection]
Vector 22 [_AmbientSkyFromGround]
Vector 23 [_AmbientNightSky]
Vector 24 [_EnvironmentAngles]
Vector 25 [_NuajLightningPosition00]
Vector 26 [_NuajLightningPosition01]
Vector 27 [_NuajLightningColor0]
Vector 28 [_NuajLightningPosition10]
Vector 29 [_NuajLightningPosition11]
Vector 30 [_NuajLightningColor1]
Vector 31 [_NuajLocalCoverageOffset]
Vector 32 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 4 [_NuajLocalCoverageTransform]
Vector 33 [_NuajTerrainEmissiveOffset]
Vector 34 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 8 [_NuajTerrainEmissiveTransform]
Vector 35 [_NuajTerrainAlbedo]
Vector 36 [_Sigma_Rayleigh]
Float 37 [_Sigma_Mie]
Float 38 [_MiePhaseAnisotropy]
SetTexture 2 [_NuajTexNoise3D0] 2D
Float 39 [_StepsCount]
Float 40 [_CloudAltitudeKm]
Vector 41 [_CloudThicknessKm]
Float 42 [_CloudLayerIndex]
Float 43 [_NoiseTiling]
Float 44 [_Coverage]
Vector 45 [_HorizonBlend]
Vector 46 [_CloudPosition]
Float 47 [_FrequencyFactor]
Vector 48 [_AmplitudeFactor]
Vector 49 [_CloudColor]
Float 50 [_CloudSigma_t]
Float 51 [_CloudSigma_s]
Float 52 [_DirectionalFactor]
Float 53 [_IsotropicFactor]
Float 54 [_IsotropicDensity]
Vector 55 [_IsotropicScatteringFactors]
Float 56 [_PhaseAnisotropyStrongForward]
Float 57 [_PhaseWeightStrongForward]
Float 58 [_PhaseAnisotropyForward]
Float 59 [_PhaseWeightForward]
Float 60 [_PhaseAnisotropyBackward]
Float 61 [_PhaseWeightBackward]
Float 62 [_PhaseAnisotropySide]
Float 63 [_PhaseWeightSide]
SetTexture 3 [_TexDeepShadowMap0] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c64, 0.00000000, 0.15915491, 0.50000000, 1.00000000
def c65, 6.28318501, -3.14159298, 1000000.00000000, -1000000.00000000
def c66, -1.00000000, 0.80000001, 1.00000000, -2.00000000
def c67, -0.10000000, -10.00000000, 2.00000000, 3.00000000
def c68, 0.01250000, 1.39999998, 1.00000000, 0.06250000
def c69, 2.71828198, 1000.00000000, 16.00000000, 17.00000000
defi i0, 255, 0, 1, 0
def c70, 0.25000000, 0.00367647, 2.00000000, -1.00000000
def c71, -0.18750000, 4.00000000, -3.00000000, 10.00000000
def c72, 0.07957747, 0.21259999, 0.71520001, 0.07220000
def c73, 0.12509382, 0.83333331, 0, 0
dcl_texcoord0 v0.xyzw
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
mad r0.xy, v0, c24.zwzw, c24
mad r0.z, r0.x, c64.y, c64
mad r0.y, r0, c64, c64.z
frc r0.x, r0.y
frc r0.y, r0.z
mad r0.x, r0, c65, c65.y
sincos r2.xy, r0.x
mad r3.x, r0.y, c65, c65.y
sincos r0.xy, r3.x
mov r0.w, c16.x
add r0.w, c40.x, r0
mul r0.y, r2, r0
mul r0.x, r2.y, r0
mul r3.xyz, r2.x, c13
mad r3.xyz, r0.y, c14, r3
mad r3.xyz, r0.x, c15, r3
mov r0.y, c2.w
mov r0.x, c0.w
add r3.w, r0, c41.x
mul r2.xz, r0.xyyw, c17.x
mov r2.y, c64.x
add r0.xyz, r2, -c12
dp3 r2.w, r0, r0
dp3 r0.x, r3, r0
mad r3.w, -r3, r3, r2
mad r0.z, r0.x, r0.x, -r3.w
rsq r0.y, r0.z
rcp r3.w, r0.y
add r4.x, -r0, r3.w
cmp_pp r0.y, r0.z, c64.w, c64.x
add r4.w, -r0.x, -r3
cmp r4.y, r4.x, c64.x, c64.w
mul_pp r4.y, r0, r4
cmp_pp r3.w, -r4.y, r0.y, c64.x
mul_pp r4.z, r0.y, r3.w
mad r0.y, -r0.w, r0.w, r2.w
cmp r0.z, r0, r1.x, c64.x
cmp r5.x, r4.w, c64, c64.w
mad r0.y, r0.x, r0.x, -r0
cmp r0.w, -r4.y, r0.z, c64.x
mul_pp r5.x, r4.z, r5
cmp r4.y, -r5.x, r0.w, r4.x
rsq r0.z, r0.y
rcp r0.w, r0.z
add r2.w, -r0.x, r0
cmp_pp r0.z, -r5.x, r3.w, c64.x
mul_pp r4.x, r4.z, r0.z
cmp r4.z, -r4.x, r4.y, r4.w
cmp_pp r0.z, r0.y, c64.w, c64.x
cmp r3.w, r2, c64.x, c64
mul_pp r3.w, r0.z, r3
cmp_pp r4.x, -r3.w, r0.z, c64
add r0.w, -r0.x, -r0
mul_pp r0.x, r0.z, r4
cmp r4.y, r0, r1.x, c64.x
cmp r0.z, r0.w, c64.x, c64.w
mul_pp r0.y, r0.x, r0.z
cmp_pp r0.z, -r0.y, r4.x, c64.x
cmp r3.w, -r3, r4.y, c64.x
cmp r0.y, -r0, r3.w, r2.w
mul_pp r0.x, r0, r0.z
cmp r0.x, -r0, r0.y, r0.w
min r0.y, r0.x, r4.z
max r0.x, r0, r4.z
max r10.z, r0.y, c64.x
add r0.y, r10.z, -r0.x
cmp oC0, -r0.y, r1, c64.xxxw
cmp_pp r0.y, -r0, c64.w, c64.x
mov r10.w, r0.x
if_gt r0.y, c64.x
add r0.xyz, r2, -c12
mul r1.xyz, r0.zxyw, c21.yzxw
mad r1.xyz, r0.yzxw, c21.zxyw, -r1
dp3 r0.w, r1, r1
dp3 r0.x, r0, c21
mul r4.xyz, r3.zxyw, c21.yzxw
mad r4.xyz, r3.yzxw, c21.zxyw, -r4
cmp r0.x, -r0, c64.w, c64
dp3 r1.w, r4, r4
mad r0.w, -c16.x, c16.x, r0
mul r2.w, r1, r0
dp3 r0.w, r1, r4
mad r1.x, r0.w, r0.w, -r2.w
rsq r1.y, r1.x
rcp r1.y, r1.y
add r1.z, -r0.w, -r1.y
rcp r1.w, r1.w
mul r0.z, r1, r1.w
cmp r0.y, -r1.x, c64.x, c64.w
mul_pp r0.x, r0, c19
mul_pp r2.w, r0.x, r0.y
cmp r4.x, -r2.w, c65.z, r0.z
mad r0.xyz, r3, r4.x, r2
add r0.xyz, r0, -c12
dp3 r0.x, r0, c21
cmp r0.x, -r0, c64, c64.w
mul_pp r3.w, r2, r0.x
add r0.x, -r0.w, r1.y
add r0.y, r10.z, r10.w
mul r4.y, r1.w, r0.x
cmp r4.y, -r2.w, c65.w, r4
mul r1.xyz, r3, r0.y
mad r0.xyz, r1, c64.z, r2
cmp r10.xy, -r3.w, r4, c65.zwzw
mov r2.w, c42.x
mul r0.xyz, r0, c18.x
mov r0.w, c64
dp4 r1.x, r0, c4
dp4 r1.y, r0, c6
add r1.xy, r1, c64.w
add r4.x, c66, r2.w
abs r3.w, c42.x
cmp r2.w, -r3, c64, c64.x
abs r3.w, r4.x
cmp r4.x, -r3.w, c64.w, c64
abs_pp r2.w, r2
cmp_pp r3.w, -r2, c64, c64.x
mul_pp r4.y, r3.w, r4.x
mov r2.w, c42.x
mov r1.z, c64.x
mul r1.xy, r1, c64.z
texldl r1, r1.xyzz, s1
mul r1, r1, c32
add r1, r1, c31
cmp r4.y, -r4, r1.x, r1
add r1.y, c66.w, r2.w
abs_pp r1.x, r4
abs r1.y, r1
cmp r1.y, -r1, c64.w, c64.x
cmp_pp r1.x, -r1, c64.w, c64
mul_pp r1.x, r3.w, r1
mul_pp r3.w, r1.x, r1.y
abs_pp r2.w, r1.y
cmp_pp r1.y, -r2.w, c64.w, c64.x
dp3 r2.w, r3, c21
mul_pp r1.x, r1, r1.y
cmp r1.z, -r3.w, r4.y, r1
cmp r4.w, -r1.x, r1.z, r1
mov r1.y, c44.x
mul r4.x, -r2.w, c56
mad r1.y, r1, c68, c68.z
mul r1.x, r4.w, c45.z
mul_sat r1.z, r1.x, r1.y
dp4 r1.x, r0, c8
dp4 r1.y, r0, c10
add r0.xy, r1, c64.w
mul r1.x, -r2.w, -r2.w
mad r1.x, -r1, c66.y, c66.z
rsq r1.x, r1.x
rcp r3.w, r1.x
mul r6.w, r1.z, c68
pow_sat r1, r3.w, c62.x
add r1.z, r4.x, c64.w
mul r1.y, -c56.x, c56.x
rcp r1.z, r1.z
add r1.y, r1, c64.w
mul r1.y, r1, r1.z
mul r1.y, r1, r1.z
mov r1.z, r1.x
mul r1.y, r1, c57.x
mad r1.w, r1.z, c63.x, r1.y
mul r1.x, -r2.w, c58
add r1.y, r1.x, c64.w
mul r1.x, -c58, c58
rcp r1.y, r1.y
add r1.x, r1, c64.w
mul r1.z, r1.x, r1.y
mul r1.z, r1, r1.y
mad r1.z, r1, c59.x, r1.w
mul r1.x, -r2.w, c60
add r1.y, r1.x, c64.w
mul r1.x, -c60, c60
dp3 r1.w, r3, c13
rcp r1.y, r1.y
add r1.x, r1, c64.w
mul r1.x, r1, r1.y
mul r1.x, r1, r1.y
mad r3.w, r1.x, c61.x, r1.z
mov r1.xyz, c21
dp3 r1.y, c13, r1
abs r1.z, r1.y
abs r1.w, r1
add r1.x, r1.w, c67
mov r1.y, c50.x
rcp r1.z, r1.z
mul r1.y, c41.x, -r1
mul r1.y, r1, r1.z
mul r4.x, r1.y, c69.y
mul_sat r1.x, r1, c67.y
mad r1.y, -r1.x, c67.z, c67.w
mul r1.x, r1, r1
mul r2.w, r1.x, r1.y
pow r1, c69.x, r4.x
mul r1.y, r10.z, r2.w
mul_sat r5.w, r1.y, c68.x
mov r1.z, c39.x
mov r1.y, c64.w
add r1.z, c66.x, r1
cmp r2.w, r1.z, c39.x, r1.y
add r1.w, r2, c64
rcp r4.x, r1.w
add r1.w, r10, -r10.z
mul r9.w, r1, r4.x
mov r7.w, r1.x
mov r1.xyz, c13
mul r0.xy, r0, c64.z
mov r0.z, c64.x
texldl r0, r0.xyzz, s0
mul r0, r0, c34
add r0, r0, c33
dp3 r8.w, c21, r1
mul r10.w, r9, c69.y
rcp r11.x, r9.w
mad r11.y, r9.w, c64.z, r10.z
mov r5.xyz, c64.x
mov r4.xyz, c64.w
mov r11.z, c64.x
loop aL, i0
break_ge r11.z, r2.w
mad r8.xyz, r11.y, r3, r2
mul r1.xyz, r8.xzyw, c43.x
add r7.xy, r1, c46
mov r7.z, r1
mul r1.xyz, r7, c47.x
add r6.xy, r1, c46.zwzw
mov r6.z, r1
mul r1.xyz, r6, c47.x
add r1.xy, r1, c46.zwzw
mul r9.xyz, r1, c47.x
add r9.xy, r9, c46.zwzw
add r1.zw, r1.xyxz, c69.y
mov r12.y, r9.z
mov r12.x, r9
mul r1.zw, r1, c69.z
add r12.xy, r12, c69.y
mul r12.xy, r12, c69.z
mul r12.zw, r12.xyxy, c68.w
abs r12.zw, r12
frc r12.zw, r12
mul r12.zw, r12, c69.z
cmp r12.xy, r12, r12.zwzw, -r12.zwzw
mul r9.xz, r1.zyww, c68.w
abs r12.zw, r9.xyxz
frc r1.x, r12.y
add r9.x, -r1, r12.y
mad r9.x, r9, c69.w, r12
frc r12.zw, r12
mul r12.zw, r12, c69.z
cmp r1.zw, r1, r12, -r12
frc r12.x, r1.w
add r1.w, -r12.x, r1
mad r1.w, r1, c69, r1.z
add r9.x, r9, c70
mov r9.z, c64.x
mul r9.x, r9, c70.y
texldl r9.xy, r9.xyzz, s2
add r1.z, r9.y, -r9.x
mad r11.w, r1.x, r1.z, r9.x
add r1.w, r1, c70.x
add r9.xy, r6.xzzw, c69.y
mul r1.x, r1.w, c70.y
mov r1.z, c64.x
texldl r1.xy, r1.xyzz, s2
mul r1.zw, r9.xyxy, c69.z
add r1.y, r1, -r1.x
mad r6.z, r12.x, r1.y, r1.x
mul r9.xy, r1.zwzw, c68.w
abs r1.xy, r9
add r9.xy, r7.xzzw, c69.y
mul r9.xy, r9, c69.z
frc r1.xy, r1
mul r1.xy, r1, c69.z
cmp r1.xy, r1.zwzw, r1, -r1
mul r12.xy, r9, c68.w
frc r6.x, r1.y
abs r1.zw, r12.xyxy
add r1.y, -r6.x, r1
mad r1.x, r1.y, c69.w, r1
frc r1.zw, r1
mul r1.zw, r1, c69.z
cmp r9.xy, r9, r1.zwzw, -r1.zwzw
frc r1.w, r9.y
add r1.x, r1, c70
add r7.x, -r1.w, r9.y
mov r1.z, c64.x
mov r1.y, r6
mul r1.x, r1, c70.y
texldl r1.xy, r1.xyzz, s2
mad r1.z, r7.x, c69.w, r9.x
add r1.y, r1, -r1.x
mad r7.x, r6, r1.y, r1
add r1.z, r1, c70.x
mul r1.x, r1.z, c70.y
mov r1.y, r7
mov r1.z, c64.x
texldl r6.xy, r1.xyzz, s2
add r1.xyz, r8, -c12
dp3 r1.x, r1, r1
mov r1.y, c16.x
rsq r1.x, r1.x
add r6.y, r6, -r6.x
add r1.y, c40.x, r1
rcp r1.x, r1.x
add r9.z, r1.x, -r1.y
mad r1.x, r1.w, r6.y, r6
mad r1.y, r7.x, c48.x, r1.x
mul r1.z, r9, c41.y
mul r1.x, c48, c48
mad r1.y, r1.x, r6.z, r1
mov r1.w, c44.x
mad r1.z, r1, c70, c70.w
mul r1.x, r1, c48
mad r1.x, r1, r11.w, r1.y
abs r1.z, r1
mul r1.y, r1.z, r1.z
mul r1.y, r1, r1
min r6.x, c71, r1.w
mul r1.z, r1.y, r1.y
mad r1.w, -r1.z, r1.y, c64
mad r1.yz, r1.w, c54.x, r6.x
mul r1.x, r1, c48.y
mad r1.x, r1, r1.w, c44
mul_sat r1.xyz, r4.w, r1
mad r9.xy, r5.w, -r1.yzzw, r1.yzzw
mov r6.xyz, c20
mul r1.z, r9.y, c51.x
add r1.y, r6.w, -r1.x
mad r9.y, r5.w, r1, r1.x
mul r1.x, r9.z, -r1.z
mul r7.x, r9.y, r1.z
mul r7.y, r1.x, c69
add r6.xyz, c22, r6
mul r1.xyz, r0.w, c35
mul r1.xyz, r1, r6
mov_sat r1.w, r8
mul r6.xyz, r1, r1.w
pow r1, c69.x, r7.y
mad r6.xyz, r6, c72.x, r0
mov r1.w, r1.x
mul r6.xyz, r6, c55.y
mul r1.xyz, r7.x, r6
mul r7.xyz, r1, r1.w
mul r1.x, r9, c51
add r1.y, -r9.z, c41.x
mul r1.y, -r1.x, r1
add r6.xyz, v1, c23
mul r9.x, r9.y, r1
mul r11.w, r1.y, c69.y
pow r1, c69.x, r11.w
mul r6.xyz, r6, c55.x
mul r6.xyz, r9.x, r6
mad r1.xyz, r6, r1.x, r7
mul r1.xyz, r1, c53.x
mul r6.xyz, r1, c71.w
mul r1.y, r9, c50.x
mul_sat r1.w, r9.z, c41.y
add r1.x, -r1.w, c64.w
mul r7.x, r1, c71.y
add r1.x, r7, c66.w
cmp r7.z, r1.x, c64.w, c64.x
add r1.x, r7, c66
mul r9.x, r10.w, -r1.y
add r7.y, r7.x, c71.z
add r1.y, -r7.z, c64.w
cmp r11.w, r1.x, c64, c64.x
mul r12.x, r11.w, r1.y
texldl r1, v0, s3
mul r9.z, r1.y, r12.x
add r11.w, -r11, c64
mul r12.y, r1.z, r12.x
cmp r7.y, r7, c64.w, c64.x
mad r1.x, r1, r11.w, r9.z
add r12.x, -r7.y, c64.w
mad r12.y, r1, r11.w, r12
mul r1.y, r7.z, r12.x
mad r7.z, r1.w, r1.y, r12.y
mad r9.z, r1, r1.y, r1.x
mad r7.z, r7.y, r1.w, r7
mad r7.y, r7, r1.w, r9.z
add r1.xyz, -r8, c25
dp3 r1.w, r1, r1
rsq r9.z, r1.w
mul r1.xyz, r9.z, r1
dp3 r1.y, r3, r1
mul r1.y, r1, c38.x
add r7.z, r7, -r7.y
frc r1.w, r7.x
mad_sat r1.w, r1, r7.z, r7.y
add r7.x, r7.w, -r1.w
mad r1.x, r5.w, r7, r1.w
mul r1.w, r1.x, c52.x
add r1.y, r1, c64.w
mul r1.x, -c38, c38
rcp r7.x, r1.y
add r11.w, r1.x, c64
mul r7.y, r11.w, r7.x
mul r12.x, r7.y, r7
mov r1.xyz, c26
add r1.xyz, -c25, r1
dp3 r1.x, r1, r1
add r7.xyz, -r8, c28
dp3 r1.y, r7, r7
rsq r1.x, r1.x
rcp r1.x, r1.x
rsq r8.x, r1.y
mul r8.y, r1.x, r12.x
mul r1.xyz, r8.x, r7
dp3 r1.y, r3, r1
rcp r7.x, r9.z
mul r1.x, r7, c69.y
rcp r7.z, r8.x
mul r1.y, r1, c38.x
mul r1.x, r1, r1
add r1.y, r1, c64.w
rcp r1.y, r1.y
mul r1.z, r11.w, r1.y
rcp r1.x, r1.x
mul r1.x, r8.y, r1
mul r7.x, r1, c69.y
mul r7.y, r1.z, r1
mov r1.xyz, c29
add r1.xyz, -c28, r1
dp3 r1.x, r1, r1
mul r7.z, r7, c69.y
mul r1.y, r7.z, r7.z
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r7.y
add r7.y, -r11, r10
rcp r1.y, r1.y
mul r1.x, r1, r1.y
mul r1.x, r1, c69.y
min r1.x, r1, c64.w
min r7.z, r7.x, c64.w
add r11.y, r11, r9.w
add r7.x, r11.y, -r10
mul r1.xyz, r1.x, c30
mul_sat r7.y, r11.x, r7
mul_sat r7.x, r7, r11
mad r8.x, -r7, r7.y, c64.w
mad r7.xyz, r7.z, c27, r1
mul r1.xyz, r8.x, v2
mul r1.xyz, r1.w, r1
mul r7.xyz, r7, c71.w
mad r1.xyz, r1, r3.w, r7
mul r9.y, r9, c51.x
mad r6.xyz, r9.y, r1, r6
pow r1, c69.x, r9.x
mul r6.xyz, r6, r10.w
mad r5.xyz, r6, r4, r5
mul r4.xyz, r4, r1.x
add r11.z, r11, c64.w
endloop
mad r0.xyz, r10.z, r3, r2
add r0.xyz, r0, -c12
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r0.x, r0.x
add r1.w, r0.x, -c16.x
mul r1.x, r1.w, c73
pow r0, c69.x, -r1.x
add r1.xyz, r2, -c12
mov r2.x, r0
dp3 r0.x, r1, r1
rsq r1.x, r0.x
mul r1.y, r1.w, c73
pow r0, c69.x, -r1.y
rcp r0.x, r1.x
add r0.x, r0, -c16
mov r2.y, r0
mul r0.y, r0.x, c73.x
pow r1, c69.x, -r0.y
mul r2.z, r0.x, c73.y
pow r0, c69.x, -r2.z
mov r0.x, r1
add r0.xy, r0, r2
mul r0.xy, r0, c64.z
mul r0.w, r0.y, c37.x
mul r0.xyz, r0.x, c36
mad r0.xyz, r0, c70.x, r0.w
mul r2.xyz, r10.z, -r0
pow r0, c69.x, r2.x
add r0.y, c45, -c45.x
rcp r0.z, r0.y
add r0.y, r10.z, -c45.x
mul r1.xyz, r5, c49
dp3 r1.w, r4, c72.yzww
add r3, -r1, c64.xxxw
mul_sat r0.y, r0, r0.z
mad r3, r0.y, r3, r1
mov r2.x, r0
pow r0, c69.x, r2.z
pow r1, c69.x, r2.y
mov r2.z, r0
mov r2.y, r1
mul oC0.xyz, r3, r2
mov oC0.w, r3
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
Vector 17 [_CloudThicknessKm]
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
Vector 16 [_PlanetCenterKm]
Vector 17 [_PlanetNormal]
Float 18 [_PlanetRadiusKm]
Float 19 [_WorldUnit2Kilometer]
Float 20 [_Kilometer2WorldUnit]
Float 21 [_bComputePlanetShadow]
Vector 22 [_SunColorFromGround]
Vector 23 [_SunDirection]
Vector 24 [_AmbientSkyFromGround]
Vector 25 [_AmbientNightSky]
Vector 26 [_NuajLightningPosition00]
Vector 27 [_NuajLightningPosition01]
Vector 28 [_NuajLightningColor0]
Vector 29 [_NuajLightningPosition10]
Vector 30 [_NuajLightningPosition11]
Vector 31 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 32 [_NuajLocalCoverageOffset]
Vector 33 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 34 [_NuajTerrainEmissiveOffset]
Vector 35 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 36 [_NuajTerrainAlbedo]
Vector 37 [_Sigma_Rayleigh]
Float 38 [_Sigma_Mie]
Float 39 [_MiePhaseAnisotropy]
SetTexture 2 [_NuajTexNoise3D0] 2D
Float 40 [_StepsCount]
Float 41 [_CloudAltitudeKm]
Vector 42 [_CloudThicknessKm]
Float 43 [_CloudLayerIndex]
Float 44 [_NoiseTiling]
Float 45 [_Coverage]
Vector 46 [_HorizonBlend]
Vector 47 [_CloudPosition]
Float 48 [_FrequencyFactor]
Vector 49 [_AmplitudeFactor]
Vector 50 [_CloudColor]
Float 51 [_CloudSigma_t]
Float 52 [_CloudSigma_s]
Float 53 [_DirectionalFactor]
Float 54 [_IsotropicFactor]
Float 55 [_IsotropicDensity]
Vector 56 [_IsotropicScatteringFactors]
Float 57 [_PhaseAnisotropyStrongForward]
Float 58 [_PhaseWeightStrongForward]
Float 59 [_PhaseAnisotropyForward]
Float 60 [_PhaseWeightForward]
Float 61 [_PhaseAnisotropyBackward]
Float 62 [_PhaseWeightBackward]
Float 63 [_PhaseAnisotropySide]
Float 64 [_PhaseWeightSide]
Float 65 [_ShadowLayersCount]
SetTexture 5 [_TexDeepShadowMap0] 2D
SetTexture 4 [_TexDeepShadowMap1] 2D
SetTexture 3 [_TexDeepShadowMap2] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[74] = { program.local[0..65],
		{ 0, 1, 1000000, -1000000 },
		{ 0.80000001, 0.5, 2, 0.1 },
		{ -10, 3, 0.0125, 1.4 },
		{ 0.0625, 2.718282, 1000, 16 },
		{ 255, 0, 1, 17 },
		{ 0.25, 0.0036764706, -0.1875, 8 },
		{ 4, 10, 0.079577468, 0.12509382 },
		{ 0.21259999, 0.71520001, 0.0722, 0.83333331 } };
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
MOVR  R3.x, c[41];
ADDR  R3.x, R3, c[18];
MOVR  R1.y, c[2].w;
MOVR  R1.x, c[0].w;
MULR  R2.xz, R1.xyyw, c[19].x;
MOVR  R2.y, c[66].x;
ADDR  R1.xyz, R2, -c[16];
DP3R  R1.w, R1, c[23];
DP3R  R1.y, R1, R1;
ADDR  R1.x, R3, c[42];
MADR  R1.z, -R1.x, R1.x, R1.y;
MULR  R2.w, R1, R1;
SGER  H0.z, R2.w, R1;
ADDR  R3.y, R2.w, -R1.z;
SLTRC HC.x, R2.w, R1.z;
MADR  R1.z, -R3.x, R3.x, R1.y;
MOVR  R1.x, c[66];
ADDR  R3.x, R2.w, -R1.z;
RSQR  R3.y, R3.y;
RCPR  R3.y, R3.y;
RSQR  R3.x, R3.x;
MOVR  R1.x(EQ), R0;
SLTR  H0.x, -R1.w, -R3.y;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[66].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.y, c[66].x;
MOVR  R1.x(NE), c[66];
SLTR  H0.z, -R1.w, R3.y;
MULXC HC.x, H0.y, H0.z;
SGER  H0.z, R2.w, R1;
ADDR  R1.x(NE), -R1.w, R3.y;
MOVX  H0.x(NE), c[66];
MULXC HC.x, H0.y, H0;
RCPR  R3.x, R3.x;
ADDR  R1.x(NE), -R1.w, -R3.y;
SLTRC HC.x, R2.w, R1.z;
MOVR  R1.y(EQ.x), R0.x;
SLTR  H0.x, -R1.w, -R3;
MULXC HC.x, H0.z, H0;
MOVX  H0.y, H0.z;
MOVX  H0.y(NE.x), c[66].x;
MOVX  H0.x, H0.y;
MULX  H0.y, H0.z, H0;
MOVR  R1.y(NE.x), c[66].x;
SLTR  H0.z, -R1.w, R3.x;
MULXC HC.x, H0.y, H0.z;
ADDR  R1.y(NE.x), -R1.w, R3.x;
MOVX  H0.x(NE), c[66];
MULXC HC.x, H0.y, H0;
ADDR  R1.y(NE.x), -R1.w, -R3.x;
MINR  R1.z, R1.y, R1.x;
MAXR  R1.x, R1.y, R1;
MAXR  R9.z, R1, c[66].x;
SGTRC HC.x, R9.z, R1;
MOVR  oCol, c[66].xxxy;
MOVR  oCol(EQ.x), R0;
SLERC HC.x, R9.z, R1;
MOVR  R9.w, R1.x;
IF    NE.x;
ADDR  R0.xyz, R2, -c[16];
MULR  R1.xyz, R0.zxyw, c[23].yzxw;
MADR  R1.xyz, R0.yzxw, c[23].zxyw, -R1;
DP3R  R0.x, R0, c[23];
SLER  H0.x, R0, c[66];
DP3R  R0.w, R1, R1;
MULR  R3.xyz, c[23].zxyw, c[23].yzxw;
MADR  R3.xyz, c[23].yzxw, c[23].zxyw, -R3;
DP3R  R1.x, R1, R3;
DP3R  R1.y, R3, R3;
MADR  R0.w, -c[18].x, c[18].x, R0;
MULR  R1.w, R1.y, R0;
MULR  R1.z, R1.x, R1.x;
ADDR  R0.w, R1.z, -R1;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
MOVR  R4.xy, c[66];
MOVR  R3, c[32];
ADDR  R0.y, -R1.x, R0.w;
SGTR  H0.y, R1.z, R1.w;
MULX  H0.x, H0, c[21];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R1.y, R1.y;
MOVR  R0.z, c[66].w;
MULR  R0.z(NE.x), R1.y, R0.y;
ADDR  R0.y, -R1.x, -R0.w;
MOVR  R0.x, c[66].z;
MULR  R0.x(NE), R0.y, R1.y;
MOVR  R0.y, R0.z;
MOVR  R9.xy, R0;
MADR  R0.xyz, R0.x, c[23], R2;
ADDR  R0.xyz, R0, -c[16];
DP3R  R0.x, R0, c[23];
SGTR  H0.y, R0.x, c[66].x;
MULXC HC.x, H0, H0.y;
SEQR  H0.xy, c[43].x, R4;
ADDR  R0.x, R9.z, R9.w;
MULR  R0.xyz, R0.x, c[23];
MADR  R0.xyz, R0, c[67].y, R2;
MOVR  R0.w, c[66].y;
MULR  R0.xyz, R0, c[20].x;
SEQX  H0.zw, H0.xyxy, c[66].x;
MOVR  R9.xy(NE.x), c[66].zwzw;
MULXC HC.x, H0.z, H0.y;
DP4R  R1.x, R0, c[8];
DP4R  R1.y, R0, c[10];
MADR  R1.xy, R1, c[67].y, c[67].y;
TEX   R1, R1, texture[1], 2D;
MADR  R1, R1, c[33], R3;
MOVR  R3.w, R1.x;
MOVR  R1.x, c[67].z;
MOVR  R3.w(NE.x), R1.y;
SEQR  H0.x, c[43], R1;
MULX  H0.y, H0.z, H0.w;
MULXC HC.x, H0.y, H0;
MOVR  R3.w(NE.x), R1.z;
SEQX  H0.x, H0, c[66];
MULXC HC.x, H0.y, H0;
MOVR  R3.w(NE.x), R1;
MULR  R1.x, R3.w, c[46].z;
MULR  R1.y, R1.x, c[45].x;
MADR_SAT R1.x, R1.y, c[68].w, R1;
ADDR  R1.y, R9.w, -R9.z;
MOVR  R2.w, c[40].x;
SLTRC HC.x, c[40], R4.y;
MOVR  R2.w(NE.x), c[66].y;
MULR  R4.w, R1.x, c[69].x;
ADDR  R1.x, R2.w, c[66].y;
RCPR  R1.x, R1.x;
MULR  R9.w, R1.y, R1.x;
DP4R  R1.y, R0, c[14];
DP4R  R1.x, R0, c[12];
MOVR  R0.xyz, c[17];
DP3R  R3.x, R0, c[23];
MADR  R1.xy, R1, c[67].y, c[67].y;
TEX   R0, R1, texture[0], 2D;
ADDR  R3.y, |R3.x|, -c[67].w;
MOVR  R1, c[34];
MADR  R1, R0, c[35], R1;
DP3R  R0.x, c[23], c[23];
MULR_SAT R3.y, R3, c[68].x;
MOVR  R0.y, c[68];
MADR  R0.w, -R0.x, c[59].x, R4.y;
MULR  R0.z, R3.y, R3.y;
MADR  R0.y, -R3, c[67].z, R0;
MULR  R0.y, R0.z, R0;
RCPR  R0.z, R0.w;
MADR  R3.y, -R0.x, c[57].x, R4;
MULR  R0.y, R9.z, R0;
MULR  R0.w, c[59].x, c[59].x;
MADR  R0.w, -R0, R0.z, R0.z;
MULR  R0.z, R0.w, R0;
MULR  R0.w, -R0.x, -R0.x;
MADR  R0.w, -R0, c[67].x, R4.y;
MADR  R0.x, -R0, c[61], R4.y;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
POWR  R0.w, R0.w, c[63].x;
MULR_SAT R7.w, R0.y, c[68].z;
RCPR  R0.y, |R3.x|;
RCPR  R3.y, R3.y;
MULR  R3.z, c[57].x, c[57].x;
MADR  R3.z, -R3, R3.y, R3.y;
MULR  R3.y, R3.z, R3;
MULR  R3.y, R3, c[58].x;
MOVR_SAT R0.w, R0;
MADR  R0.w, R0, c[64].x, R3.y;
RCPR  R3.y, R0.x;
MULR  R0.x, c[61], c[61];
MADR  R0.x, -R0, R3.y, R3.y;
MULR  R0.x, R0, R3.y;
MADR  R0.z, R0, c[60].x, R0.w;
MADR  R6.w, R0.x, c[62].x, R0.z;
MOVR  R0.x, c[42];
MULR  R0.x, R0, -c[51];
MULR  R0.w, R0.x, R0.y;
MOVR  R0.xyz, c[23];
MULR  R0.w, R0, c[69].z;
MULR  R10.x, R9.w, c[69].z;
RCPR  R10.y, R9.w;
MADR  R10.z, R9.w, c[67].y, R9;
DP3R  R5.w, R0, c[17];
POWR  R8.w, c[69].y, R0.w;
MOVR  R3.xyz, c[66].x;
MOVR  R4.xyz, c[66].y;
MOVR  R10.w, c[66].x;
LOOP c[70];
SLTRC HC.x, R10.w, R2.w;
BRK   (EQ.x);
MADR  R5.xyz, R10.z, c[23], R2;
MULR  R0.xyz, R5.xzyw, c[44].x;
ADDR  R7.xy, R0, c[47];
MOVR  R7.z, R0;
MULR  R0.xyz, R7, c[48].x;
ADDR  R6.xy, R0, c[47].zwzw;
MOVR  R6.z, R0;
MULR  R0.xyz, R6, c[48].x;
ADDR  R0.xy, R0, c[47].zwzw;
MULR  R8.xyz, R0, c[48].x;
ADDR  R12.xy, R8, c[47].zwzw;
ADDR  R0.zw, R0.xyxz, c[69].z;
MOVR  R8.x, R12;
MOVR  R8.y, R8.z;
ADDR  R8.xy, R8, c[69].z;
MULR  R11.xy, R8, c[69].w;
MULR  R8.xy, R11, c[69].x;
MOVXC RC.xy, R11;
MULR  R11.xy, R0.zwzw, c[69].w;
FRCR  R8.xy, |R8|;
MULR  R11.zw, R8.xyxy, c[69].w;
MOVR  R8.xy, R11.zwzw;
MOVR  R8.xy(LT), -R11.zwzw;
MULR  R0.zw, R11.xyxy, c[69].x;
MOVXC RC.xy, R11;
FRCR  R0.zw, |R0|;
MULR  R11.zw, R0, c[69].w;
MOVR  R0.zw, R11;
MOVR  R0.zw(LT.xyxy), -R11;
ADDR  R11.xy, R7.xzzw, c[69].z;
MULR  R11.zw, R11.xyxy, c[69].w;
MULR  R11.xy, R11.zwzw, c[69].x;
MOVXC RC.xy, R11.zwzw;
FRCR  R11.xy, |R11|;
MULR  R12.zw, R11.xyxy, c[69].w;
MOVR  R11.xy, R12.zwzw;
MOVR  R11.xy(LT), -R12.zwzw;
ADDR  R11.zw, R6.xyxz, c[69].z;
MULR  R12.zw, R11, c[69].w;
MULR  R11.zw, R12, c[69].x;
FRCR  R11.zw, |R11|;
MULR  R6.xz, R11.zyww, c[69].w;
MOVR  R11.zw, R6.xyxz;
MOVXC RC.xy, R12.zwzw;
MOVR  R11.zw(LT.xyxy), -R6.xyxz;
FLRR  R0.x, R11.y;
MADR  R6.x, R0, c[70].w, R11;
ADDR  R6.x, R6, c[71];
MULR  R7.x, R6, c[71].y;
TEX   R7.xy, R7, texture[2], 2D;
ADDR  R6.x, R7.y, -R7;
ADDR  R0.x, R11.y, -R0;
MADR  R6.z, R0.x, R6.x, R7.x;
FLRR  R0.x, R11.w;
MADR  R6.x, R0, c[70].w, R11.z;
ADDR  R6.x, R6, c[71];
MULR  R6.x, R6, c[71].y;
TEX   R6.xy, R6, texture[2], 2D;
ADDR  R6.y, R6, -R6.x;
ADDR  R0.x, R11.w, -R0;
MADR  R0.x, R0, R6.y, R6;
FLRR  R6.x, R0.w;
MADR  R6.y, R0.x, c[49].x, R6.z;
MADR  R0.x, R6, c[70].w, R0.z;
ADDR  R0.z, R0.w, -R6.x;
ADDR  R0.x, R0, c[71];
MULR  R0.x, R0, c[71].y;
TEX   R0.xy, R0, texture[2], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.z, R0.y, R0;
MULR  R0.z, c[49].x, c[49].x;
MADR  R6.x, R0.z, R0, R6.y;
FLRR  R0.w, R8.y;
MADR  R0.x, R0.w, c[70].w, R8;
ADDR  R0.x, R0, c[71];
MOVR  R0.y, R12;
MULR  R0.x, R0, c[71].y;
TEX   R0.xy, R0, texture[2], 2D;
ADDR  R0.y, R0, -R0.x;
ADDR  R0.w, R8.y, -R0;
MADR  R0.x, R0.w, R0.y, R0;
MULR  R0.y, R0.z, c[49].x;
MADR  R0.x, R0.y, R0, R6;
ADDR  R6.xyz, R5, -c[16];
DP3R  R0.y, R6, R6;
MOVR  R0.z, c[41].x;
RSQR  R0.y, R0.y;
ADDR  R0.z, R0, c[18].x;
RCPR  R0.y, R0.y;
ADDR  R12.y, R0, -R0.z;
MULR_SAT R7.y, R12, c[42];
MADR  R12.x, -R7.y, c[65], c[65];
SGTRC HC.x, R12, c[71].w;
MULR  R0.z, R12.y, c[42].y;
MOVR  R0.y, c[66];
MADR  R0.y, R0.z, c[67].z, -R0;
MULR  R0.y, |R0|, |R0|;
MULR  R0.w, R0.y, R0.y;
MULR  R6.x, R0.w, R0.w;
MULR  R0.w, R6.x, R0;
MULR  R0.x, R0, c[49].y;
MOVR  R0.yz, c[55].x;
MADR  R0.xyz, -R0.w, R0, R0;
MOVR  R0.w, c[71].z;
MINR  R0.w, R0, c[45].x;
ADDR  R0.yz, R0, R0.w;
ADDR  R0.x, R0, c[45];
MULR_SAT R6.xyz, R3.w, R0;
MOVR  R0.w, c[66].y;
MOVR  R0.xyz, R5;
DP4R  R7.x, R0, c[4];
DP4R  R7.y, R0, c[5];
IF    NE.x;
TEX   R0, R7, texture[3], 2D;
ADDR  R12.x, R12, -c[71].w;
ELSE;
SGTRC HC.x, R12, c[72];
IF    NE.x;
TEX   R0, R7, texture[4], 2D;
ADDR  R12.x, R12, -c[72];
ELSE;
TEX   R0, R7, texture[5], 2D;
ENDIF;
ENDIF;
MOVR  R8.xyz, c[24];
ADDR  R8.xyz, R8, c[22];
MULR  R7.xyz, R1.w, c[36];
MULR  R7.xyz, R7, R8;
MADR  R8.xy, R7.w, -R6.yzzw, R6.yzzw;
MOVR_SAT R11.x, R5.w;
MULR  R7.xyz, R7, R11.x;
MADR  R7.xyz, R7, c[72].z, R1;
MULR  R7.xyz, R7, c[56].y;
MULR  R11.zw, R8.xyxy, c[52].x;
ADDR  R6.y, R4.w, -R6.x;
MADR  R8.x, R7.w, R6.y, R6;
MULR  R6.x, -R11.w, R12.y;
MULR  R8.y, R6.x, c[69].z;
MULR  R11.xy, R8.x, R11.zwzw;
MULR  R6.xyz, R11.y, R7;
POWR  R7.y, c[69].y, R8.y;
SGER  H0.z, R12.x, c[66].y;
SGER  H0.y, R12.x, c[67].z;
MULR  R6.xyz, R6, R7.y;
MADR  R7.x, -H0.y, H0.z, H0.z;
MULR  R7.xy, R0.zyzw, R7.x;
ADDR  R7.z, -H0, c[66].y;
MADR  R0.xy, R0.yxzw, R7.z, R7;
SGER  H0.x, R12, c[68].y;
MADR  R7.x, -H0, H0.y, H0.y;
MADR  R7.xy, R0.wzzw, R7.x, R0;
MADR  R7.xy, H0.x, R0.w, R7;
ADDR  R0.w, R7.x, -R7.y;
FRCR  R7.x, R12;
MADR_SAT R0.w, R7.x, R0, R7.y;
ADDR  R7.x, R8.w, -R0.w;
MADR  R0.w, R7, R7.x, R0;
ADDR  R7.z, -R12.y, c[42].x;
ADDR  R0.xyz, fragment.texcoord[1], c[25];
MULR  R7.z, -R11, R7;
MULR  R0.xyz, R0, c[56].x;
MULR  R7.z, R7, c[69];
MOVR  R7.x, c[66].y;
POWR  R7.z, c[69].y, R7.z;
MULR  R0.xyz, R11.x, R0;
MADR  R0.xyz, R0, R7.z, R6;
ADDR  R6.xyz, -R5, c[26];
DP3R  R7.y, R6, R6;
RSQR  R7.y, R7.y;
MULR  R6.xyz, R7.y, R6;
DP3R  R6.x, R6, c[23];
MADR  R6.x, R6, c[39], R7;
RCPR  R8.y, R6.x;
MULR  R7.z, c[39].x, c[39].x;
MULR  R0.xyz, R0, c[54].x;
MOVR  R6.xyz, c[26];
ADDR  R6.xyz, -R6, c[27];
DP3R  R6.x, R6, R6;
RSQR  R6.y, R6.x;
ADDR  R5.xyz, -R5, c[29];
DP3R  R6.x, R5, R5;
RSQR  R6.x, R6.x;
MULR  R5.xyz, R6.x, R5;
DP3R  R5.x, R5, c[23];
MADR  R5.x, R5, c[39], R7;
RCPR  R5.x, R5.x;
MADR  R8.z, -R7, R8.y, R8.y;
RCPR  R6.z, R7.y;
MULR  R6.z, R6, c[69];
MULR  R5.y, R6.z, R6.z;
MADR  R5.z, -R7, R5.x, R5.x;
RCPR  R6.x, R6.x;
MULR  R6.z, R5, R5.x;
MULR  R0.w, R0, c[53].x;
MULR  R6.x, R6, c[69].z;
MULR  R8.y, R8.z, R8;
RCPR  R6.y, R6.y;
MULR  R6.y, R6, R8;
RCPR  R5.y, R5.y;
MULR  R5.y, R6, R5;
MULR  R6.y, R5, c[69].z;
MOVR  R5.xyz, c[29];
ADDR  R5.xyz, -R5, c[30];
DP3R  R5.x, R5, R5;
MULR  R5.y, R6.x, R6.x;
RSQR  R5.x, R5.x;
RCPR  R5.x, R5.x;
MULR  R5.x, R5, R6.z;
ADDR  R6.z, -R10, R9.y;
RCPR  R5.y, R5.y;
MULR  R5.x, R5, R5.y;
MULR  R5.x, R5, c[69].z;
MINR  R5.x, R5, c[66].y;
MINR  R6.x, R6.y, c[66].y;
ADDR  R10.z, R10, R9.w;
ADDR  R6.y, R10.z, -R9.x;
MULR  R5.xyz, R5.x, c[31];
MULR_SAT R6.z, R10.y, R6;
MULR_SAT R6.y, R6, R10;
MULR  R7.x, R6.y, R6.z;
MADR  R6.xyz, R6.x, c[28], R5;
MADR  R5.xyz, -R7.x, fragment.texcoord[2], fragment.texcoord[2];
MULR  R5.xyz, R0.w, R5;
MULR  R6.xyz, R6, c[72].y;
MULR  R0.w, R8.x, c[52].x;
MADR  R5.xyz, R5, R6.w, R6;
MULR  R0.xyz, R0, c[72].y;
MADR  R0.xyz, R0.w, R5, R0;
MULR  R0.xyz, R0, R10.x;
MULR  R0.w, R8.x, c[51].x;
MADR  R3.xyz, R0, R4, R3;
MULR  R0.w, R10.x, -R0;
POWR  R0.x, c[69].y, R0.w;
MULR  R4.xyz, R4, R0.x;
ADDR  R10.w, R10, c[66].y;
ENDLOOP;
MULR  R1.xyz, R3, c[50];
MADR  R0.xyz, R9.z, c[23], R2;
ADDR  R0.xyz, R0, -c[16];
DP3R  R0.x, R0, R0;
RSQR  R0.x, R0.x;
RCPR  R0.w, R0.x;
ADDR  R0.xyz, R2, -c[16];
DP3R  R0.y, R0, R0;
ADDR  R0.w, R0, -c[18].x;
MULR  R0.x, R0.w, c[72].w;
DP3R  R1.w, R4, c[73];
RSQR  R0.y, R0.y;
MULR  R0.z, R0.w, c[73].w;
RCPR  R0.y, R0.y;
ADDR  R0.w, R0.y, -c[18].x;
POWR  R0.y, c[69].y, -R0.z;
MULR  R0.z, R0.w, c[72].w;
MULR  R0.w, R0, c[73];
POWR  R0.z, c[69].y, -R0.z;
POWR  R0.w, c[69].y, -R0.w;
POWR  R0.x, c[69].y, -R0.x;
ADDR  R0.xy, R0.zwzw, R0;
MULR  R0.xy, R0, c[67].y;
MULR  R0.w, R0.y, c[38].x;
MULR  R0.xyz, R0.x, c[37];
MADR  R0.xyz, R0, c[71].x, R0.w;
MULR  R0.xyz, R9.z, -R0;
ADDR  R0.w, c[46].y, -c[46].x;
ADDR  R2, -R1, c[66].xxxy;
RCPR  R0.w, R0.w;
ADDR  R3.x, R9.z, -c[46];
MULR_SAT R0.w, R3.x, R0;
MADR  R1, R0.w, R2, R1;
POWR  R0.x, c[69].y, R0.x;
POWR  R0.z, c[69].y, R0.z;
POWR  R0.y, c[69].y, R0.y;
MULR  oCol.xyz, R1, R0;
MOVR  oCol.w, R1;
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
Vector 16 [_PlanetCenterKm]
Vector 17 [_PlanetNormal]
Float 18 [_PlanetRadiusKm]
Float 19 [_WorldUnit2Kilometer]
Float 20 [_Kilometer2WorldUnit]
Float 21 [_bComputePlanetShadow]
Vector 22 [_SunColorFromGround]
Vector 23 [_SunDirection]
Vector 24 [_AmbientSkyFromGround]
Vector 25 [_AmbientNightSky]
Vector 26 [_NuajLightningPosition00]
Vector 27 [_NuajLightningPosition01]
Vector 28 [_NuajLightningColor0]
Vector 29 [_NuajLightningPosition10]
Vector 30 [_NuajLightningPosition11]
Vector 31 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 32 [_NuajLocalCoverageOffset]
Vector 33 [_NuajLocalCoverageFactor]
SetTexture 1 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 34 [_NuajTerrainEmissiveOffset]
Vector 35 [_NuajTerrainEmissiveFactor]
SetTexture 0 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 36 [_NuajTerrainAlbedo]
Vector 37 [_Sigma_Rayleigh]
Float 38 [_Sigma_Mie]
Float 39 [_MiePhaseAnisotropy]
SetTexture 2 [_NuajTexNoise3D0] 2D
Float 40 [_StepsCount]
Float 41 [_CloudAltitudeKm]
Vector 42 [_CloudThicknessKm]
Float 43 [_CloudLayerIndex]
Float 44 [_NoiseTiling]
Float 45 [_Coverage]
Vector 46 [_HorizonBlend]
Vector 47 [_CloudPosition]
Float 48 [_FrequencyFactor]
Vector 49 [_AmplitudeFactor]
Vector 50 [_CloudColor]
Float 51 [_CloudSigma_t]
Float 52 [_CloudSigma_s]
Float 53 [_DirectionalFactor]
Float 54 [_IsotropicFactor]
Float 55 [_IsotropicDensity]
Vector 56 [_IsotropicScatteringFactors]
Float 57 [_PhaseAnisotropyStrongForward]
Float 58 [_PhaseWeightStrongForward]
Float 59 [_PhaseAnisotropyForward]
Float 60 [_PhaseWeightForward]
Float 61 [_PhaseAnisotropyBackward]
Float 62 [_PhaseWeightBackward]
Float 63 [_PhaseAnisotropySide]
Float 64 [_PhaseWeightSide]
Float 65 [_ShadowLayersCount]
SetTexture 5 [_TexDeepShadowMap0] 2D
SetTexture 4 [_TexDeepShadowMap1] 2D
SetTexture 3 [_TexDeepShadowMap2] 2D

"ps_3_0
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
dcl_2d s4
dcl_2d s5
def c66, 0.00000000, 1.00000000, 1000000.00000000, -1000000.00000000
def c67, -1.00000000, 0.80000001, 1.00000000, 0.50000000
def c68, -2.00000000, -0.10000000, -10.00000000, 0.01250000
def c69, 2.00000000, 3.00000000, 1.39999998, 1.00000000
def c70, 0.06250000, 2.71828198, 1000.00000000, 16.00000000
defi i0, 255, 0, 1, 0
def c71, 17.00000000, 0.25000000, 0.00367647, -0.18750000
def c72, 2.00000000, -1.00000000, 8.00000000, -8.00000000
def c73, 4.00000000, -4.00000000, -3.00000000, 10.00000000
def c74, 0.07957747, 0.21259999, 0.71520001, 0.07220000
def c75, 0.12509382, 0.83333331, 0, 0
dcl_texcoord1 v0.xyz
dcl_texcoord2 v1.xyz
mov r1.w, c18.x
add r1.w, c41.x, r1
mov r1.y, c2.w
mov r1.x, c0.w
add r3.x, r1.w, c42
mul r2.xz, r1.xyyw, c19.x
mov r2.y, c66.x
add r1.xyz, r2, -c16
dp3 r2.w, r1, r1
dp3 r1.x, r1, c23
mad r3.x, -r3, r3, r2.w
mad r3.x, r1, r1, -r3
rsq r1.y, r3.x
rcp r1.z, r1.y
add r3.y, -r1.x, r1.z
add r4.x, -r1, -r1.z
cmp_pp r1.y, r3.x, c66, c66.x
cmp r3.z, r3.y, c66.x, c66.y
mul_pp r3.z, r1.y, r3
cmp_pp r1.z, -r3, r1.y, c66.x
mul_pp r3.w, r1.y, r1.z
mad r1.y, -r1.w, r1.w, r2.w
cmp r4.y, r4.x, c66.x, c66
mul_pp r4.y, r3.w, r4
cmp_pp r1.z, -r4.y, r1, c66.x
mad r1.y, r1.x, r1.x, -r1
mul_pp r3.w, r3, r1.z
rsq r1.z, r1.y
cmp r2.w, r3.x, r0.x, c66.x
rcp r1.w, r1.z
cmp r1.z, -r3, r2.w, c66.x
add r2.w, -r1.x, r1
cmp r3.y, -r4, r1.z, r3
cmp_pp r1.z, r1.y, c66.y, c66.x
cmp r3.x, r2.w, c66, c66.y
mul_pp r3.x, r1.z, r3
cmp r3.w, -r3, r3.y, r4.x
cmp_pp r3.y, -r3.x, r1.z, c66.x
add r1.w, -r1.x, -r1
mul_pp r1.x, r1.z, r3.y
cmp r3.z, r1.y, r0.x, c66.x
cmp r1.z, r1.w, c66.x, c66.y
mul_pp r1.y, r1.x, r1.z
cmp_pp r1.z, -r1.y, r3.y, c66.x
cmp r3.x, -r3, r3.z, c66
cmp r1.y, -r1, r3.x, r2.w
mul_pp r1.x, r1, r1.z
cmp r1.x, -r1, r1.y, r1.w
min r1.y, r1.x, r3.w
max r1.x, r1, r3.w
max r9.z, r1.y, c66.x
add r1.y, r9.z, -r1.x
cmp oC0, -r1.y, r0, c66.xxxy
cmp_pp r0.x, -r1.y, c66.y, c66
mov r9.w, r1.x
if_gt r0.x, c66.x
add r3.xyz, r2, -c16
mul r0.xyz, r3.zxyw, c23.yzxw
mad r0.xyz, r3.yzxw, c23.zxyw, -r0
dp3 r0.w, r0, r0
dp3 r3.x, r3, c23
mul r1.xyz, c23.zxyw, c23.yzxw
mad r1.xyz, c23.yzxw, c23.zxyw, -r1
dp3 r2.w, r0, r1
dp3 r4.x, r1, r1
add r0.y, r9.z, r9.w
mad r0.w, -c18.x, c18.x, r0
mul r0.w, r4.x, r0
mad r4.z, r2.w, r2.w, -r0.w
rsq r0.x, r4.z
rcp r3.w, r0.x
mul r1.xyz, r0.y, c23
mad r0.xyz, r1, c67.w, r2
cmp r3.x, -r3, c66.y, c66
mul r0.xyz, r0, c20.x
mov r0.w, c66.y
dp4 r1.x, r0, c8
dp4 r1.y, r0, c10
add r1.xy, r1, c66.y
add r4.w, -r2, -r3
rcp r4.y, r4.x
mul r3.z, r4.w, r4.y
mov r4.w, c43.x
cmp r3.y, -r4.z, c66.x, c66
mul_pp r3.x, r3, c21
mul_pp r4.z, r3.x, r3.y
cmp r4.x, -r4.z, c66.z, r3.z
mad r3.xyz, r4.x, c23, r2
add r5.y, c67.x, r4.w
abs r5.x, c43
cmp r4.w, -r5.x, c66.y, c66.x
abs r5.x, r5.y
cmp r5.y, -r5.x, c66, c66.x
abs_pp r4.w, r4
cmp_pp r5.x, -r4.w, c66.y, c66
mul_pp r5.z, r5.x, r5.y
mov r4.w, c43.x
mov r1.z, c66.x
mul r1.xy, r1, c67.w
texldl r1, r1.xyzz, s1
mul r1, r1, c33
add r1, r1, c32
cmp r5.z, -r5, r1.x, r1.y
add r1.y, c68.x, r4.w
abs_pp r1.x, r5.y
abs r1.y, r1
cmp r1.y, -r1, c66, c66.x
cmp_pp r1.x, -r1, c66.y, c66
mul_pp r1.x, r5, r1
mul_pp r5.x, r1, r1.y
abs_pp r4.w, r1.y
cmp_pp r1.y, -r4.w, c66, c66.x
mul_pp r1.x, r1, r1.y
cmp r1.z, -r5.x, r5, r1
cmp r5.w, -r1.x, r1.z, r1
mov r1.y, c45.x
add r1.w, -r2, r3
mad r1.y, r1, c69.z, c69.w
mul r1.x, r5.w, c46.z
mul_sat r4.w, r1.x, r1.y
add r1.xyz, r3, -c16
dp3 r1.x, r1, c23
mul r1.y, r4, r1.w
cmp r4.y, -r4.z, c66.w, r1
cmp r1.x, -r1, c66, c66.y
mul_pp r1.x, r4.z, r1
cmp r9.xy, -r1.x, r4, c66.zwzw
dp4 r1.x, r0, c12
dp4 r1.y, r0, c14
add r0.xy, r1, c66.y
dp3 r1.x, c23, c23
mul r0.w, -r1.x, -r1.x
mad r1.y, -r0.w, c67, c67.z
rsq r1.y, r1.y
rcp r1.y, r1.y
mul r7.w, r4, c70.x
mul r0.xy, r0, c67.w
mov r0.z, c66.x
texldl r0, r0.xyzz, s0
mul r0, r0, c35
add r3, r0, c34
pow_sat r0, r1.y, c63.x
mul r0.y, -r1.x, c57.x
add r0.z, r0.y, c66.y
mov r0.w, r0.x
mul r0.y, -c57.x, c57.x
rcp r0.z, r0.z
add r0.y, r0, c66
mul r0.y, r0, r0.z
mul r0.y, r0, r0.z
mul r0.z, r0.y, c58.x
mul r0.x, -r1, c59
add r0.y, r0.x, c66
mad r0.z, r0.w, c64.x, r0
mul r0.x, -c59, c59
rcp r0.y, r0.y
add r0.x, r0, c66.y
mul r0.x, r0, r0.y
mul r0.x, r0, r0.y
mad r1.y, r0.x, c60.x, r0.z
mov r0.xyz, c23
dp3 r0.z, c17, r0
mul r0.w, -r1.x, c61.x
add r0.y, r0.w, c66
mul r0.x, -c61, c61
rcp r0.y, r0.y
add r0.x, r0, c66.y
mul r0.x, r0, r0.y
mul r0.x, r0, r0.y
mov r0.y, c51.x
abs r0.z, r0
mad r4.w, r0.x, c62.x, r1.y
add r0.x, r0.z, c68.y
rcp r0.z, r0.z
mul r0.y, c42.x, -r0
mul r0.y, r0, r0.z
mul_sat r0.x, r0, c68.z
mul r1.y, r0, c70.z
mad r0.y, -r0.x, c69.x, c69
mul r0.x, r0, r0
mul r1.x, r0, r0.y
pow r0, c70.y, r1.y
mul r0.y, r9.z, r1.x
mul_sat r6.w, r0.y, c68
mov r0.z, c40.x
mov r0.y, c66
add r0.z, c67.x, r0
cmp r2.w, r0.z, c40.x, r0.y
add r0.w, r2, c66.y
rcp r1.x, r0.w
add r0.w, r9, -r9.z
mul r10.x, r0.w, r1
mov r8.w, r0.x
mov r0.xyz, c17
dp3 r9.w, c23, r0
mul r10.y, r10.x, c70.z
rcp r10.z, r10.x
mad r10.w, r10.x, c67, r9.z
mov r4.xyz, c66.x
mov r5.xyz, c66.y
mov r11.x, c66
loop aL, i0
break_ge r11.x, r2.w
mad r6.xyz, r10.w, c23, r2
mul r0.xyz, r6.xzyw, c44.x
add r7.xy, r0, c47
mov r7.z, r0
mul r0.xyz, r7, c48.x
add r1.xy, r0, c47.zwzw
mov r1.z, r0
mul r0.xyz, r1, c48.x
add r0.xy, r0, c47.zwzw
mul r8.xyz, r0, c48.x
add r8.xy, r8, c47.zwzw
add r0.zw, r0.xyxz, c70.z
mov r11.w, r8.z
mov r11.z, r8.x
add r11.zw, r11, c70.z
mul r11.zw, r11, c70.w
mul r12.xy, r11.zwzw, c70.x
abs r8.xz, r12.xyyw
mul r0.zw, r0, c70.w
mul r12.xy, r0.zwzw, c70.x
frc r8.xz, r8
mul r8.xz, r8, c70.w
cmp r11.zw, r11, r8.xyxz, -r8.xyxz
frc r0.x, r11.w
add r1.w, -r0.x, r11
mad r1.w, r1, c71.x, r11.z
add r1.w, r1, c71.y
mul r8.x, r1.w, c71.z
mov r8.z, c66.x
abs r12.xy, r12
frc r12.xy, r12
mul r12.xy, r12, c70.w
cmp r0.zw, r0, r12.xyxy, -r12.xyxy
frc r11.y, r0.w
add r0.w, -r11.y, r0
mad r0.w, r0, c71.x, r0.z
texldl r8.xy, r8.xyzz, s2
add r0.z, r8.y, -r8.x
mad r8.z, r0.x, r0, r8.x
add r0.w, r0, c71.y
add r1.zw, r1.xyxz, c70.z
mul r0.x, r0.w, c71.z
mov r0.z, c66.x
texldl r0.xy, r0.xyzz, s2
mul r0.zw, r1, c70.w
add r0.y, r0, -r0.x
mul r1.zw, r0, c70.x
mad r11.y, r11, r0, r0.x
abs r0.xy, r1.zwzw
add r1.zw, r7.xyxz, c70.z
mul r1.zw, r1, c70.w
frc r0.xy, r0
mul r0.xy, r0, c70.w
cmp r0.xy, r0.zwzw, r0, -r0
frc r1.x, r0.y
add r0.y, -r1.x, r0
mad r0.x, r0.y, c71, r0
mul r8.xy, r1.zwzw, c70.x
abs r0.zw, r8.xyxy
frc r0.zw, r0
mul r0.zw, r0, c70.w
cmp r1.zw, r1, r0, -r0
frc r0.w, r1
add r0.x, r0, c71.y
add r1.w, -r0, r1
mov r0.z, c66.x
mov r0.y, r1
mul r0.x, r0, c71.z
texldl r0.xy, r0.xyzz, s2
mad r0.z, r1.w, c71.x, r1
add r0.y, r0, -r0.x
mad r1.z, r1.x, r0.y, r0.x
add r0.z, r0, c71.y
mul r0.x, r0.z, c71.z
mov r0.y, r7
mov r0.z, c66.x
texldl r1.xy, r0.xyzz, s2
add r0.xyz, r6, -c16
dp3 r0.x, r0, r0
mov r0.y, c18.x
rsq r0.x, r0.x
add r1.y, r1, -r1.x
add r0.y, c41.x, r0
rcp r0.x, r0.x
add r11.w, r0.x, -r0.y
mad r0.x, r0.w, r1.y, r1
mad r0.y, r1.z, c49.x, r0.x
mul r0.x, c49, c49
mad r0.y, r0.x, r11, r0
mov r0.w, c45.x
mul r0.z, r11.w, c42.y
mad r0.z, r0, c72.x, c72.y
mul r0.x, r0, c49
mad r0.x, r0, r8.z, r0.y
abs r0.z, r0
mul r0.y, r0.z, r0.z
mul r0.y, r0, r0
mul_sat r1.w, r11, c42.y
add r1.w, -r1, c66.y
min r1.x, c71.w, r0.w
mul r0.z, r0.y, r0.y
mad r0.w, -r0.z, r0.y, c66.y
mul r0.x, r0, c49.y
mad r0.yz, r0.w, c55.x, r1.x
mad r0.x, r0, r0.w, c45
mul_sat r1.xyz, r5.w, r0
mov r0.xyz, r6
mov r0.w, c66.y
dp4 r7.x, r0, c4
dp4 r7.y, r0, c5
mul r11.z, r1.w, c65.x
mov r7.z, c66.x
if_gt r11.z, c72.z
texldl r0, r7.xyzz, s3
add r11.z, r11, c72.w
else
if_gt r11.z, c73.x
texldl r0, r7.xyzz, s4
add r11.z, r11, c73.y
else
texldl r0, r7.xyzz, s5
endif
endif
mov r8.xyz, c22
add r8.xyz, c24, r8
mul r7.xyz, r3.w, c36
mul r7.xyz, r7, r8
mad r8.xy, r6.w, -r1.yzzw, r1.yzzw
mul r8.y, r8, c52.x
mul r1.z, r11.w, -r8.y
mov_sat r1.w, r9
mul r7.xyz, r7, r1.w
add r1.y, r7.w, -r1.x
mad r7.xyz, r7, c74.x, r3
mad r11.y, r6.w, r1, r1.x
mul r8.z, r1, c70
pow r1, c70.y, r8.z
mul r1.y, r11, r8
mul r7.xyz, r7, c56.y
mul r7.xyz, r1.y, r7
add r1.y, -r11.w, c42.x
mul r11.w, r8.x, c52.x
mul r1.y, -r11.w, r1
mul r7.xyz, r7, r1.x
mul r8.x, r1.y, c70.z
pow r1, c70.y, r8.x
add r8.xyz, v0, c25
mul r1.y, r11, r11.w
mul r8.xyz, r8, c56.x
mul r8.xyz, r1.y, r8
mad r1.xyz, r8, r1.x, r7
add r1.w, r11.z, c68.x
cmp r7.x, r1.w, c66.y, c66
add r1.w, r11.z, c67.x
cmp r7.z, r1.w, c66.y, c66.x
add r7.y, -r7.x, c66
mul r7.y, r7.z, r7
mul r8.x, r0.z, r7.y
add r7.z, -r7, c66.y
mul r7.y, r0, r7
add r1.w, r11.z, c73.z
mul r1.xyz, r1, c54.x
mad r0.x, r0, r7.z, r7.y
cmp r1.w, r1, c66.y, c66.x
mad r8.y, r0, r7.z, r8.x
add r8.x, -r1.w, c66.y
mul r0.y, r7.x, r8.x
mad r7.x, r0.w, r0.y, r8.y
mad r7.y, r0.z, r0, r0.x
add r0.xyz, -r6, c26
add r6.xyz, -r6, c29
mad r7.y, r1.w, r0.w, r7
mad r7.x, r1.w, r0.w, r7
dp3 r0.w, r0, r0
rsq r1.w, r0.w
mul r0.xyz, r1.w, r0
dp3 r0.y, r0, c23
mul r0.y, r0, c39.x
add r7.x, r7, -r7.y
frc r0.w, r11.z
mad_sat r0.w, r0, r7.x, r7.y
add r7.x, r8.w, -r0.w
mad r0.x, r6.w, r7, r0.w
mul r0.w, r0.x, c53.x
add r0.y, r0, c66
mul r0.x, -c39, c39
rcp r7.y, r0.y
add r7.x, r0, c66.y
mul r7.z, r7.x, r7.y
mov r0.xyz, c27
add r0.xyz, -c26, r0
dp3 r0.x, r0, r0
rsq r0.x, r0.x
dp3 r0.y, r6, r6
mul r7.y, r7.z, r7
rcp r0.x, r0.x
rsq r7.z, r0.y
mul r7.y, r0.x, r7
mul r0.xyz, r7.z, r6
dp3 r0.y, r0, c23
rcp r1.w, r1.w
mul r0.x, r1.w, c70.z
mul r0.y, r0, c39.x
mul r0.x, r0, r0
add r0.y, r0, c66
rcp r0.y, r0.y
mul r0.z, r7.x, r0.y
rcp r0.x, r0.x
mul r0.x, r7.y, r0
rcp r6.y, r7.z
mul r1.w, r0.x, c70.z
mul r6.x, r0.z, r0.y
mov r0.xyz, c30
add r0.xyz, -c29, r0
dp3 r0.x, r0, r0
mul r6.y, r6, c70.z
mul r0.y, r6, r6
rsq r0.x, r0.x
rcp r0.x, r0.x
mul r0.x, r0, r6
add r6.x, -r10.w, r9.y
rcp r0.y, r0.y
mul r0.x, r0, r0.y
mul r0.x, r0, c70.z
min r0.x, r0, c66.y
min r6.y, r1.w, c66
add r10.w, r10, r10.x
add r1.w, r10, -r9.x
mul r0.xyz, r0.x, c31
mul_sat r6.x, r10.z, r6
mul_sat r1.w, r1, r10.z
mad r1.w, -r1, r6.x, c66.y
mad r6.xyz, r6.y, c28, r0
mul r0.xyz, r1.w, v1
mul r0.xyz, r0.w, r0
mul r0.w, r11.y, c51.x
mul r1.w, r10.y, -r0
mul r6.xyz, r6, c73.w
mad r0.xyz, r0, r4.w, r6
mul r0.w, r11.y, c52.x
mul r1.xyz, r1, c73.w
mad r1.xyz, r0.w, r0, r1
pow r0, c70.y, r1.w
mul r1.xyz, r1, r10.y
mad r4.xyz, r1, r5, r4
mul r5.xyz, r5, r0.x
add r11.x, r11, c66.y
endloop
add r0.xyz, r2, -c16
mad r2.xyz, r9.z, c23, r2
dp3 r0.x, r0, r0
rsq r0.x, r0.x
rcp r0.x, r0.x
add r1.x, r0, -c18
mul r1.y, r1.x, c75.x
pow r0, c70.y, -r1.y
add r3.xyz, r2, -c16
mov r2.x, r0
dp3 r0.x, r3, r3
rsq r1.y, r0.x
mul r1.x, r1, c75.y
pow r0, c70.y, -r1.x
rcp r0.x, r1.y
add r0.x, r0, -c18
mov r2.y, r0
mul r1.x, r0, c75.y
mul r2.z, r0.x, c75.x
pow r0, c70.y, -r1.x
pow r1, c70.y, -r2.z
mov r0.x, r1
add r0.xy, r2, r0
mul r0.xy, r0, c67.w
mul r0.w, r0.y, c38.x
mul r0.xyz, r0.x, c37
mad r0.xyz, r0, c71.y, r0.w
mul r2.xyz, r9.z, -r0
pow r0, c70.y, r2.x
add r0.y, c46, -c46.x
rcp r0.z, r0.y
add r0.y, r9.z, -c46.x
mul r1.xyz, r4, c50
dp3 r1.w, r5, c74.yzww
add r3, -r1, c66.xxxy
mul_sat r0.y, r0, r0.z
mad r3, r0.y, r3, r1
mov r2.x, r0
pow r1, c70.y, r2.z
pow r0, c70.y, r2.y
mov r2.z, r1
mov r2.y, r0
mul oC0.xyz, r3, r2
mov oC0.w, r3
endif

"
}

}

		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #7 upscales cloud rendering to actual screen resolution using ACCURATE technique
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
Vector 17 [_CloudThicknessKm]
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
Vector 16 [_CameraData]
Matrix 0 [_Camera2World]
SetTexture 0 [_CameraDepthTexture] 2D
Vector 17 [_PlanetCenterKm]
Vector 18 [_PlanetNormal]
Float 19 [_PlanetRadiusKm]
Float 20 [_PlanetAtmosphereRadiusKm]
Float 21 [_WorldUnit2Kilometer]
Float 22 [_Kilometer2WorldUnit]
Float 23 [_bComputePlanetShadow]
Vector 24 [_SunColor]
Vector 25 [_SunColorFromGround]
Vector 26 [_SunDirection]
SetTexture 3 [_TexAmbientSky] 2D
Vector 27 [_SoftAmbientSky]
Vector 28 [_AmbientSkyFromGround]
Vector 29 [_AmbientNightSky]
SetTexture 2 [_TexShadowEnvMapSky] 2D
Vector 30 [_NuajLightningPosition00]
Vector 31 [_NuajLightningPosition01]
Vector 32 [_NuajLightningColor0]
Vector 33 [_NuajLightningPosition10]
Vector 34 [_NuajLightningPosition11]
Vector 35 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 36 [_NuajLocalCoverageOffset]
Vector 37 [_NuajLocalCoverageFactor]
SetTexture 6 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 38 [_NuajTerrainEmissiveOffset]
Vector 39 [_NuajTerrainEmissiveFactor]
SetTexture 5 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 40 [_NuajTerrainAlbedo]
Vector 41 [_Sigma_Rayleigh]
Float 42 [_Sigma_Mie]
Float 43 [_MiePhaseAnisotropy]
SetTexture 4 [_TexDensity] 2D
SetTexture 1 [_TexDownScaledZBuffer] 2D
SetTexture 7 [_NuajTexNoise3D0] 2D
Float 44 [_StepsCount]
Float 45 [_CloudAltitudeKm]
Vector 46 [_CloudThicknessKm]
Float 47 [_CloudLayerIndex]
Float 48 [_NoiseTiling]
Float 49 [_Coverage]
Float 50 [_CloudTraceLimiter]
Vector 51 [_HorizonBlend]
Vector 52 [_CloudPosition]
Float 53 [_FrequencyFactor]
Vector 54 [_AmplitudeFactor]
Vector 55 [_CloudColor]
Float 56 [_CloudSigma_t]
Float 57 [_CloudSigma_s]
Float 58 [_DirectionalFactor]
Float 59 [_IsotropicFactor]
Float 60 [_IsotropicDensity]
Vector 61 [_IsotropicScatteringFactors]
Float 62 [_PhaseAnisotropyStrongForward]
Float 63 [_PhaseWeightStrongForward]
Float 64 [_PhaseAnisotropyForward]
Float 65 [_PhaseWeightForward]
Float 66 [_PhaseAnisotropyBackward]
Float 67 [_PhaseWeightBackward]
Float 68 [_PhaseAnisotropySide]
Float 69 [_PhaseWeightSide]
Float 70 [_ShadowLayersCount]
SetTexture 10 [_TexDeepShadowMap0] 2D
SetTexture 9 [_TexDeepShadowMap1] 2D
SetTexture 8 [_TexDeepShadowMap2] 2D
SetTexture 11 [_MainTex] 2D
Float 71 [_ZBufferDiscrepancyThreshold]
Float 72 [_ShowZBufferDiscrepancies]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[83] = { program.local[0..72],
		{ 0.5, 2.718282, 2, -1 },
		{ 0, 0.995, 1000000, -1000000 },
		{ 500000, 0, -1, 1 },
		{ 0.80000001, -0.2, -2.4999998, 3 },
		{ -0.97500002, 0.1, -10, 0.0125 },
		{ 1.4, 0.0625, 1000, 16 },
		{ 255, 0, 1, 17 },
		{ 0.25, 0.0036764706, -0.1875, 8 },
		{ 4, 10, 0.079577468 },
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
OUTPUT oCol = result.color;
ADDR  R0.x, c[16].w, -c[16].z;
RCPR  R0.y, R0.x;
MULR  R0.y, R0, c[16].w;
TEX   R0.x, fragment.texcoord[0], texture[0], 2D;
ADDR  R0.x, R0.y, -R0;
RCPR  R0.z, R0.x;
MULR  R0.y, R0, c[16].z;
TEX   R0.x, fragment.texcoord[0], texture[1], 2D;
MULR  R2.w, R0.y, R0.z;
ADDR  R0.x, R2.w, -R0;
SGTRC HC.x, |R0|, c[71];
IF    NE.x;
MULR  R2.xy, fragment.texcoord[0], c[16];
MOVR  R0.xy, c[16];
MADR  R0.xy, R2, c[73].z, -R0;
MOVR  R0.z, c[73].w;
DP3R  R0.w, R0, R0;
RSQR  R3.x, R0.w;
MULR  R0.xyz, R3.x, R0;
MOVR  R0.w, c[74].x;
DP4R  R4.z, R0, c[2];
DP4R  R4.y, R0, c[1];
DP4R  R4.x, R0, c[0];
MOVR  R0.x, c[45];
ADDR  R6.x, R0, c[19];
MOVR  R0.xy, c[74].zwzw;
MOVR  R2.x, c[0].w;
MOVR  R2.z, c[2].w;
MOVR  R2.y, c[1].w;
MULR  R5.xyz, R2, c[21].x;
ADDR  R2.xyz, R5, -c[17];
DP3R  R3.y, R4, R2;
DP3R  R5.w, R2, R2;
ADDR  R2.z, R6.x, c[46].x;
MULR  R4.w, R3.y, R3.y;
MADR  R2.x, -R2.z, R2.z, R5.w;
SLTRC HC.x, R4.w, R2;
MOVR  R0.xy(EQ.x), R1;
ADDR  R0.z, R4.w, -R2.x;
RSQR  R0.z, R0.z;
RCPR  R0.w, R0.z;
ADDR  R0.z, -R3.y, -R0.w;
MADR  R3.z, -R6.x, R6.x, R5.w;
SGERC HC.x, R4.w, R2;
ADDR  R0.w, -R3.y, R0;
MOVR  R0.xy(NE.x), R0.zwzw;
ADDR  R2.x, R4.w, -R3.z;
RSQR  R2.x, R2.x;
RCPR  R2.y, R2.x;
ADDR  R2.x, -R3.y, -R2.y;
MOVR  R0.zw, c[74];
SLTRC HC.x, R4.w, R3.z;
MOVR  R0.zw(EQ.x), R1.xyxy;
MOVR  R3.w, R0.y;
ADDR  R2.y, -R3, R2;
SGERC HC.x, R4.w, R3.z;
MOVR  R0.zw(NE.x), R2.xyxy;
MOVR  R2.x, R0;
RSQR  R0.x, R5.w;
RCPR  R0.x, R0.x;
SLTR  H0.x, R0, R6;
SGTR  H0.y, R0.x, R2.z;
SEQX  H0.x, H0, c[74];
MULX  H0.z, H0.x, H0.y;
SLTR  H0.w, R0.z, c[75].x;
MULXC HC.x, H0.z, H0.w;
SEQX  H0.y, H0, c[74].x;
MOVR  R3.z, R0.w;
MOVR  R2.y, R0.z;
MOVR  R3.zw(NE.x), R2.xyxy;
SEQX  H0.w, H0, c[74].x;
MULXC HC.x, H0.z, H0.w;
MOVR  R3.zw(NE.x), c[75].xyyz;
MULX  H0.x, H0, H0.y;
SLTR  H0.z, R0, c[74].x;
MULXC HC.x, H0, H0.z;
MOVR  R0.x, c[74];
MOVR  R3.zw(NE.x), R0.xyxy;
SEQX  H0.y, H0.z, c[74].x;
MOVR  R0.y, R0.z;
MULXC HC.x, H0, H0.y;
MOVR  R0.x, c[74];
MOVR  R3.zw(NE.x), R0.xyxy;
MADR  R0.y, -c[19].x, c[19].x, R5.w;
ADDR  R0.z, R4.w, -R0.y;
RSQR  R0.z, R0.z;
MOVR  R0.x, c[74].z;
SLTRC HC.x, R4.w, R0.y;
MOVR  R0.x(EQ), R1;
SGERC HC.x, R4.w, R0.y;
RCPR  R0.z, R0.z;
ADDR  R0.x(NE), -R3.y, -R0.z;
MOVXC RC.x, R0;
RCPR  R0.y, R3.x;
MOVR  R0.x(LT), c[74].z;
MULR  R0.y, R2.w, R0;
MADR  R0.z, -R0.y, c[21].x, R0.x;
MOVR  R0.x, c[74].y;
MULR  R0.x, R0, c[16].w;
MAXR  R12.z, R3, c[74].x;
MULR  R0.y, R0, c[21].x;
SGER  H0.x, R2.w, R0;
MADR  R0.x, H0, R0.z, R0.y;
MINR  R2.w, R0.x, R3;
MOVR  R0, c[75].yyyw;
SGTRC HC.x, R12.z, R2.w;
MOVR  R0(EQ.x), R1;
MOVR  R1, R0;
MOVR  R0.xyz, c[18];
DP3R  R0.x, R0, c[26];
MOVR  R0.w, c[19].x;
ADDR  R0.w, -R0, c[20].x;
SLERC HC.x, R12.z, R2.w;
ADDR  R0.z, R2, -c[19].x;
RCPR  R0.y, R0.w;
MULR  R0.y, R0.z, R0;
MADR  R0.x, -R0, c[73], c[73];
TEX   R0.zw, R0, texture[4], 2D;
MULR  R0.x, R0.w, c[42];
MADR  R0.xyz, R0.z, -c[41], -R0.x;
POWR  R2.x, c[73].y, R0.x;
POWR  R2.y, c[73].y, R0.y;
POWR  R2.z, c[73].y, R0.z;
TEX   R0.xyz, c[73].x, texture[3], 2D;
MULR  R3.xyz, R2, c[24];
ADDR  R0.xyz, R0, c[27];
TEX   R0.w, c[73].x, texture[2], 2D;
MOVR  R12.w, R2;
MULR  R2.xyz, R0.w, R0;
IF    NE.x;
ADDR  R0.xyz, R5, -c[17];
MULR  R1.xyz, R0.zxyw, c[26].yzxw;
MADR  R1.xyz, R0.yzxw, c[26].zxyw, -R1;
DP3R  R0.x, R0, c[26];
SLER  H0.x, R0, c[74];
DP3R  R0.w, R1, R1;
MULR  R6.xyz, R4.zxyw, c[26].yzxw;
MADR  R6.xyz, R4.yzxw, c[26].zxyw, -R6;
DP3R  R1.x, R1, R6;
DP3R  R1.y, R6, R6;
MADR  R0.w, -c[19].x, c[19].x, R0;
MULR  R1.w, R1.y, R0;
MULR  R1.z, R1.x, R1.x;
ADDR  R0.w, R1.z, -R1;
RSQR  R0.w, R0.w;
RCPR  R0.w, R0.w;
MOVR  R3.w, c[75];
ADDR  R0.y, -R1.x, R0.w;
MOVR  R7.xy, c[76].wyzw;
MOVR  R6, c[36];
SGTR  H0.y, R1.z, R1.w;
MULX  H0.x, H0, c[23];
MULX  H0.x, H0, H0.y;
MOVXC RC.x, H0;
RCPR  R1.y, R1.y;
MOVR  R0.z, c[74].w;
MULR  R0.z(NE.x), R1.y, R0.y;
ADDR  R0.y, -R1.x, -R0.w;
MOVR  R0.x, c[74].z;
MULR  R0.x(NE), R0.y, R1.y;
MOVR  R0.y, R0.z;
MOVR  R12.xy, R0;
MADR  R0.xyz, R4, R0.x, R5;
ADDR  R0.xyz, R0, -c[17];
DP3R  R0.x, R0, c[26];
SGTR  H0.y, R0.x, c[74].x;
MULXC HC.x, H0, H0.y;
ADDR  R0.x, -R7.y, c[49];
MULR_SAT R0.x, R0, c[76].z;
MADR  R0.y, -R0.x, c[73].z, R7.x;
MULR  R0.x, R0, R0;
MULR  R0.x, R0, R0.y;
MOVR  R0.w, c[75];
SEQR  H0.y, c[47].x, R3.w;
MOVR  R0.y, c[56].x;
MULR  R0.x, R0, c[56];
MADR  R0.x, R0, c[77], R0.y;
RCPR  R0.y, R0.x;
MADR  R0.x, R12.z, c[50], c[50];
MADR  R0.x, R0, R0.y, R12.z;
MINR  R4.w, R12, R0.x;
ADDR  R0.x, R12.z, R4.w;
MULR  R0.xyz, R4, R0.x;
MADR  R0.xyz, R0, c[73].x, R5;
MULR  R0.xyz, R0, c[22].x;
DP4R  R1.x, R0, c[8];
DP4R  R1.y, R0, c[10];
MADR  R1.xy, R1, c[73].x, c[73].x;
TEX   R1, R1, texture[6], 2D;
MADR  R1, R1, c[37], R6;
MOVR  R5.w, R1.x;
MOVR  R1.x, c[74];
SEQR  H0.x, c[47], R1;
MOVR  R1.x, c[73].z;
SEQR  H0.z, c[47].x, R1.x;
SEQX  H0.x, H0, c[74];
MOVR  R12.xy(NE.x), c[74].zwzw;
MULXC HC.x, H0, H0.y;
SEQX  H0.y, H0, c[74].x;
MULX  H0.x, H0, H0.y;
MOVR  R5.w(NE.x), R1.y;
MULXC HC.x, H0, H0.z;
MOVR  R5.w(NE.x), R1.z;
SEQX  H0.y, H0.z, c[74].x;
MULXC HC.x, H0, H0.y;
MOVR  R5.w(NE.x), R1;
MULR  R1.x, R5.w, c[51].z;
MULR  R1.y, R1.x, c[49].x;
MADR_SAT R1.x, R1.y, c[78], R1;
ADDR  R1.y, -R12.z, R4.w;
DP3R  R4.w, R4, c[26];
MADR  R6.x, -R4.w, c[64], R3.w;
MOVR  R2.w, c[44].x;
SLTRC HC.x, c[44], R3.w;
MOVR  R2.w(NE.x), c[75];
MULR  R7.w, R1.x, c[78].y;
ADDR  R1.x, R2.w, c[75].w;
RCPR  R1.x, R1.x;
MULR  R9.w, R1.y, R1.x;
DP4R  R1.x, R0, c[12];
DP4R  R1.y, R0, c[14];
MADR  R0.xy, R1, c[73].x, c[73].x;
TEX   R0, R0, texture[5], 2D;
MOVR  R1, c[38];
MADR  R1, R0, c[39], R1;
RCPR  R0.x, R6.x;
MULR  R0.y, c[64].x, c[64].x;
MADR  R0.z, -R0.y, R0.x, R0.x;
MULR  R0.y, -R4.w, -R4.w;
MADR  R0.y, -R0, c[76].x, R3.w;
MULR  R0.x, R0.z, R0;
MADR  R0.z, -R4.w, c[62].x, R3.w;
RSQR  R0.y, R0.y;
RCPR  R0.y, R0.y;
POWR  R0.y, R0.y, c[68].x;
RCPR  R0.z, R0.z;
MULR  R0.w, c[62].x, c[62].x;
MADR  R0.w, -R0, R0.z, R0.z;
MULR  R0.z, R0.w, R0;
MULR  R0.z, R0, c[63].x;
MOVR_SAT R0.y, R0;
MADR  R0.y, R0, c[69].x, R0.z;
MADR  R0.x, R0, c[65], R0.y;
DP3R  R0.z, R4, c[18];
ADDR  R0.y, |R0.z|, -c[77];
MADR  R0.z, -R4.w, c[66].x, R3.w;
RCPR  R0.w, R0.z;
MULR_SAT R0.y, R0, c[77].z;
MADR  R3.w, -R0.y, c[73].z, R7.x;
MULR  R0.z, c[66].x, c[66].x;
MADR  R0.z, -R0, R0.w, R0.w;
MULR  R0.z, R0, R0.w;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R3.w;
MULR  R0.w, R12.z, R0.y;
MADR  R4.w, R0.z, c[67].x, R0.x;
MOVR  R0.xyz, c[18];
DP3R  R0.y, R0, c[26];
MOVR  R0.x, c[46];
RCPR  R0.y, |R0.y|;
MULR  R0.x, R0, -c[56];
MULR_SAT R6.w, R0, c[77];
MULR  R0.w, R0.x, R0.y;
MOVR  R0.xyz, c[26];
MULR  R0.w, R0, c[78].z;
MULR  R10.w, R9, c[78].z;
RCPR  R11.w, R9.w;
MADR  R12.w, R9, c[73].x, R12.z;
DP3R  R3.w, R0, c[18];
POWR  R8.w, c[73].y, R0.w;
MOVR  R6.xyz, c[74].x;
MOVR  R7.xyz, c[75].w;
MOVR  R13.x, c[74];
LOOP c[79];
SLTRC HC.x, R13, R2.w;
BRK   (EQ.x);
MADR  R8.xyz, R12.w, R4, R5;
MULR  R0.xyz, R8.xzyw, c[48].x;
ADDR  R10.xy, R0, c[52];
MOVR  R10.z, R0;
MULR  R0.xyz, R10, c[53].x;
ADDR  R9.xy, R0, c[52].zwzw;
MOVR  R9.z, R0;
MULR  R0.xyz, R9, c[53].x;
ADDR  R0.xy, R0, c[52].zwzw;
MULR  R11.xyz, R0, c[53].x;
ADDR  R14.zw, R11.xyxy, c[52];
ADDR  R0.zw, R0.xyxz, c[78].z;
MOVR  R11.y, R11.z;
MOVR  R11.x, R14.z;
ADDR  R11.xy, R11, c[78].z;
MULR  R13.zw, R11.xyxy, c[78].w;
MULR  R11.xy, R13.zwzw, c[78].y;
MOVXC RC.xy, R13.zwzw;
MULR  R13.zw, R0, c[78].w;
FRCR  R11.xy, |R11|;
MULR  R14.xy, R11, c[78].w;
MOVR  R11.xy, R14;
MOVR  R11.xy(LT), -R14;
MULR  R0.zw, R13, c[78].y;
MOVXC RC.xy, R13.zwzw;
FRCR  R0.zw, |R0|;
MULR  R14.xy, R0.zwzw, c[78].w;
MOVR  R0.zw, R14.xyxy;
MOVR  R0.zw(LT.xyxy), -R14.xyxy;
ADDR  R13.zw, R10.xyxz, c[78].z;
MULR  R14.xy, R13.zwzw, c[78].w;
MULR  R13.zw, R14.xyxy, c[78].y;
MOVXC RC.xy, R14;
ADDR  R14.xy, R9.xzzw, c[78].z;
MULR  R9.xz, R14.xyyw, c[78].w;
MULR  R14.xy, R9.xzzw, c[78].y;
FRCR  R13.zw, |R13|;
MULR  R10.xz, R13.zyww, c[78].w;
MOVR  R13.zw, R10.xyxz;
MOVR  R13.zw(LT.xyxy), -R10.xyxz;
FRCR  R14.xy, |R14|;
MULR  R10.xz, R14.xyyw, c[78].w;
MOVR  R14.xy, R10.xzzw;
MOVXC RC.xy, R9.xzzw;
FLRR  R0.x, R13.w;
MADR  R9.x, R0, c[79].w, R13.z;
MOVR  R14.xy(LT), -R10.xzzw;
ADDR  R9.x, R9, c[80];
MULR  R10.x, R9, c[80].y;
TEX   R10.xy, R10, texture[7], 2D;
ADDR  R9.x, R10.y, -R10;
ADDR  R0.x, R13.w, -R0;
MADR  R9.z, R0.x, R9.x, R10.x;
FLRR  R0.x, R14.y;
MADR  R9.x, R0, c[79].w, R14;
ADDR  R9.x, R9, c[80];
MULR  R9.x, R9, c[80].y;
TEX   R9.xy, R9, texture[7], 2D;
ADDR  R9.y, R9, -R9.x;
ADDR  R0.x, R14.y, -R0;
MADR  R0.x, R0, R9.y, R9;
FLRR  R9.x, R0.w;
MADR  R9.y, R0.x, c[54].x, R9.z;
MADR  R0.x, R9, c[79].w, R0.z;
ADDR  R0.z, R0.w, -R9.x;
ADDR  R0.x, R0, c[80];
MULR  R0.x, R0, c[80].y;
TEX   R0.xy, R0, texture[7], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.z, R0.y, R0;
MULR  R0.z, c[54].x, c[54].x;
MADR  R9.x, R0.z, R0, R9.y;
FLRR  R0.w, R11.y;
MADR  R0.x, R0.w, c[79].w, R11;
ADDR  R0.x, R0, c[80];
ADDR  R0.w, R11.y, -R0;
MULR  R0.x, R0, c[80].y;
MOVR  R0.y, R14.w;
TEX   R0.xy, R0, texture[7], 2D;
ADDR  R0.y, R0, -R0.x;
MADR  R0.x, R0.w, R0.y, R0;
MULR  R0.y, R0.z, c[54].x;
MADR  R0.x, R0.y, R0, R9;
ADDR  R9.xyz, R8, -c[17];
DP3R  R0.y, R9, R9;
MOVR  R0.z, c[45].x;
RSQR  R0.y, R0.y;
ADDR  R0.z, R0, c[19].x;
RCPR  R0.y, R0.y;
ADDR  R14.y, R0, -R0.z;
MULR_SAT R10.y, R14, c[46];
MADR  R13.y, -R10, c[70].x, c[70].x;
SGTRC HC.x, R13.y, c[80].w;
MULR  R0.z, R14.y, c[46].y;
MOVR  R0.y, c[75].w;
MADR  R0.y, R0.z, c[73].z, -R0;
MULR  R0.y, |R0|, |R0|;
MULR  R0.w, R0.y, R0.y;
MULR  R9.x, R0.w, R0.w;
MULR  R0.w, R9.x, R0;
MULR  R0.x, R0, c[54].y;
MOVR  R0.yz, c[60].x;
MADR  R0.xyz, -R0.w, R0, R0;
MOVR  R0.w, c[80].z;
MINR  R0.w, R0, c[49].x;
ADDR  R0.yz, R0, R0.w;
ADDR  R0.x, R0, c[49];
MULR_SAT R9.xyz, R5.w, R0;
MOVR  R0.w, c[75];
MOVR  R0.xyz, R8;
DP4R  R10.x, R0, c[4];
DP4R  R10.y, R0, c[5];
IF    NE.x;
TEX   R0, R10, texture[8], 2D;
ADDR  R13.y, R13, -c[80].w;
ELSE;
SGTRC HC.x, R13.y, c[81];
IF    NE.x;
TEX   R0, R10, texture[9], 2D;
ADDR  R13.y, R13, -c[81].x;
ELSE;
TEX   R0, R10, texture[10], 2D;
ENDIF;
ENDIF;
MOVR  R11.xyz, c[28];
ADDR  R11.xyz, R11, c[25];
MULR  R10.xyz, R1.w, c[40];
MULR  R10.xyz, R10, R11;
MADR  R11.xy, R6.w, -R9.yzzw, R9.yzzw;
ADDR  R9.y, R7.w, -R9.x;
MOVR_SAT R13.z, R3.w;
MULR  R10.xyz, R10, R13.z;
MADR  R10.xyz, R10, c[81].z, R1;
MULR  R13.zw, R11.xyxy, c[57].x;
MADR  R14.x, R6.w, R9.y, R9;
MULR  R9.x, -R13.w, R14.y;
MULR  R11.x, R9, c[78].z;
MULR  R14.zw, R14.x, R13;
MULR  R10.xyz, R10, c[61].y;
ADDR  R9.xyz, R2, c[29];
ADDR  R13.w, -R14.y, c[46].x;
MULR  R13.w, -R13.z, R13;
MULR  R13.w, R13, c[78].z;
MULR  R10.xyz, R14.w, R10;
POWR  R11.x, c[73].y, R11.x;
MULR  R11.xyz, R10, R11.x;
MULR  R9.xyz, R9, c[61].x;
MULR  R10.xyz, R14.z, R9;
ADDR  R9.xyz, -R8, c[30];
DP3R  R13.z, R9, R9;
RSQR  R13.z, R13.z;
MULR  R9.xyz, R13.z, R9;
POWR  R13.w, c[73].y, R13.w;
MADR  R10.xyz, R10, R13.w, R11;
MOVR  R11.x, c[75].w;
DP3R  R9.x, R9, R4;
MADR  R9.x, R9, c[43], R11;
RCPR  R11.z, R9.x;
MULR  R11.y, c[43].x, c[43].x;
MADR  R13.w, -R11.y, R11.z, R11.z;
MOVR  R9.xyz, c[30];
ADDR  R9.xyz, -R9, c[31];
DP3R  R9.y, R9, R9;
ADDR  R8.xyz, -R8, c[33];
DP3R  R9.x, R8, R8;
RSQR  R9.x, R9.x;
MULR  R8.xyz, R9.x, R8;
DP3R  R8.x, R4, R8;
MADR  R8.x, R8, c[43], R11;
RCPR  R8.x, R8.x;
RCPR  R9.z, R13.z;
MULR  R8.y, R9.z, c[78].z;
MADR  R8.z, -R11.y, R8.x, R8.x;
SGER  H0.z, R13.y, c[75].w;
RSQR  R9.y, R9.y;
MULR  R8.y, R8, R8;
RCPR  R9.x, R9.x;
MULR  R9.z, R8, R8.x;
RCPR  R8.y, R8.y;
MULR  R9.x, R9, c[78].z;
SGER  H0.y, R13, c[73].z;
SGER  H0.x, R13.y, c[76].w;
MULR  R10.xyz, R10, c[59].x;
MULR  R11.z, R13.w, R11;
RCPR  R9.y, R9.y;
MULR  R9.y, R9, R11.z;
MULR  R9.y, R9, R8;
MOVR  R8.xyz, c[33];
ADDR  R8.xyz, -R8, c[34];
DP3R  R8.x, R8, R8;
MULR  R8.y, R9.x, R9.x;
RSQR  R8.x, R8.x;
RCPR  R8.x, R8.x;
MULR  R8.x, R8, R9.z;
RCPR  R8.y, R8.y;
MULR  R8.x, R8, R8.y;
MULR  R8.y, R9, c[78].z;
MULR  R8.x, R8, c[78].z;
MADR  R9.x, -H0.y, H0.z, H0.z;
MULR  R9.xy, R0.zyzw, R9.x;
ADDR  R11.x, -H0.z, c[75].w;
MADR  R0.xy, R0.yxzw, R11.x, R9;
MADR  R9.x, -H0, H0.y, H0.y;
MADR  R9.xy, R0.wzzw, R9.x, R0;
MADR  R9.xy, H0.x, R0.w, R9;
MINR  R9.z, R8.y, c[75].w;
MINR  R8.x, R8, c[75].w;
MULR  R8.xyz, R8.x, c[35];
MADR  R0.xyz, R9.z, c[32], R8;
MULR  R8.xyz, R0, c[81].y;
ADDR  R0.y, -R12.w, R12;
ADDR  R12.w, R12, R9;
ADDR  R0.w, R12, -R12.x;
FRCR  R0.z, R13.y;
ADDR  R0.x, R9, -R9.y;
MADR_SAT R0.x, R0.z, R0, R9.y;
ADDR  R0.z, R8.w, -R0.x;
MULR_SAT R0.w, R0, R11;
MULR_SAT R0.y, R11.w, R0;
MULR  R0.y, R0.w, R0;
MADR  R0.w, R6, R0.z, R0.x;
MULR  R0.w, R0, c[58].x;
MADR  R0.xyz, -R0.y, R3, R3;
MULR  R0.xyz, R0.w, R0;
MADR  R0.xyz, R0, R4.w, R8;
MULR  R0.w, R14.x, c[57].x;
MULR  R8.xyz, R10, c[81].y;
MADR  R0.xyz, R0.w, R0, R8;
MULR  R0.xyz, R0, R10.w;
MULR  R0.w, R14.x, c[56].x;
MADR  R6.xyz, R0, R7, R6;
MULR  R0.w, R10, -R0;
POWR  R0.x, c[73].y, R0.w;
MULR  R7.xyz, R7, R0.x;
ADDR  R13.x, R13, c[75].w;
ENDLOOP;
ADDR  R2.x, c[51].y, -c[51];
MULR  R0.xyz, R6, c[55];
DP3R  R0.w, R7, c[82];
ADDR  R1, -R0, c[75].yyyw;
RCPR  R2.x, R2.x;
ADDR  R2.y, R12.z, -c[51].x;
MULR_SAT R2.x, R2.y, R2;
MADR  R1, R2.x, R1, R0;
ENDIF;
ADDR  R0, -R1, c[75].ywyy;
MADR  R0, R0, c[72].x, R1;
ELSE;
TEX   R0, fragment.texcoord[0], texture[11], 2D;
ENDIF;
MOVR  oCol, R0;
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
Float 19 [_PlanetRadiusKm]
Float 20 [_WorldUnit2Kilometer]
Float 21 [_Kilometer2WorldUnit]
Float 22 [_bComputePlanetShadow]
Vector 23 [_SunColorFromGround]
Vector 24 [_SunDirection]
Vector 25 [_AmbientSkyFromGround]
Vector 26 [_AmbientNightSky]
Vector 27 [_NuajLightningPosition00]
Vector 28 [_NuajLightningPosition01]
Vector 29 [_NuajLightningColor0]
Vector 30 [_NuajLightningPosition10]
Vector 31 [_NuajLightningPosition11]
Vector 32 [_NuajLightningColor1]
Matrix 4 [_NuajWorld2Shadow]
Vector 33 [_NuajLocalCoverageOffset]
Vector 34 [_NuajLocalCoverageFactor]
SetTexture 3 [_NuajLocalCoverageTexture] 2D
Matrix 8 [_NuajLocalCoverageTransform]
Vector 35 [_NuajTerrainEmissiveOffset]
Vector 36 [_NuajTerrainEmissiveFactor]
SetTexture 2 [_NuajTerrainEmissiveTexture] 2D
Matrix 12 [_NuajTerrainEmissiveTransform]
Vector 37 [_NuajTerrainAlbedo]
Float 38 [_MiePhaseAnisotropy]
SetTexture 1 [_TexDownScaledZBuffer] 2D
SetTexture 4 [_NuajTexNoise3D0] 2D
Float 39 [_StepsCount]
Float 40 [_CloudAltitudeKm]
Vector 41 [_CloudThicknessKm]
Float 42 [_CloudLayerIndex]
Float 43 [_NoiseTiling]
Float 44 [_Coverage]
Float 45 [_CloudTraceLimiter]
Vector 46 [_HorizonBlend]
Vector 47 [_CloudPosition]
Float 48 [_FrequencyFactor]
Vector 49 [_AmplitudeFactor]
Vector 50 [_CloudColor]
Float 51 [_CloudSigma_t]
Float 52 [_CloudSigma_s]
Float 53 [_DirectionalFactor]
Float 54 [_IsotropicFactor]
Float 55 [_IsotropicDensity]
Vector 56 [_IsotropicScatteringFactors]
Float 57 [_PhaseAnisotropyStrongForward]
Float 58 [_PhaseWeightStrongForward]
Float 59 [_PhaseAnisotropyForward]
Float 60 [_PhaseWeightForward]
Float 61 [_PhaseAnisotropyBackward]
Float 62 [_PhaseWeightBackward]
Float 63 [_PhaseAnisotropySide]
Float 64 [_PhaseWeightSide]
Float 65 [_ShadowLayersCount]
SetTexture 7 [_TexDeepShadowMap0] 2D
SetTexture 6 [_TexDeepShadowMap1] 2D
SetTexture 5 [_TexDeepShadowMap2] 2D
SetTexture 8 [_MainTex] 2D
Float 66 [_ZBufferDiscrepancyThreshold]
Float 67 [_ShowZBufferDiscrepancies]

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
def c68, 2.00000000, -1.00000000, 0.00000000, 0.99500000
def c69, 1.00000000, 0.00000000, 1000000.00000000, -1000000.00000000
def c70, -500000.00000000, 0.80000001, 1.00000000, 0.20000000
def c71, -2.49999976, 2.00000000, 3.00000000, 0.50000000
def c72, -0.97500002, 1.00000000, -2.00000000, -0.10000000
def c73, -10.00000000, 0.01250000, 1.39999998, 1.00000000
def c74, 0.06250000, 2.71828198, 1000.00000000, 16.00000000
defi i0, 255, 0, 1, 0
def c75, 17.00000000, 0.25000000, 0.00367647, -0.18750000
def c76, 8.00000000, -8.00000000, 4.00000000, -4.00000000
def c77, -3.00000000, 10.00000000, 0.07957747, 0
def c78, 0.21259999, 0.71520001, 0.07220000, 0
dcl_texcoord0 v0.xyzw
dcl_texcoord1 v1.xyz
dcl_texcoord2 v2.xyz
add r0.x, c16.w, -c16.z
rcp r0.y, r0.x
mul r0.y, r0, c16.w
texldl r0.x, v0, s0
add r0.x, r0.y, -r0
rcp r0.z, r0.x
mul r0.y, r0, c16.z
texldl r0.x, v0, s1
mul r2.x, r0.y, r0.z
add r0.x, r2, -r0
abs r0.x, r0
if_gt r0.x, c66.x
mov r2.z, c19.x
mad r0.xy, v0, c68.x, c68.y
add r2.w, c40.x, r2.z
mov r0.z, c68.y
mul r0.xy, r0, c16
dp3 r0.w, r0, r0
rsq r2.y, r0.w
mul r0.xyz, r2.y, r0
mov r0.w, c68.z
dp4 r3.z, r0, c2
dp4 r3.y, r0, c1
dp4 r3.x, r0, c0
mov r4.x, c0.w
mov r4.z, c2.w
mov r4.y, c1.w
mul r4.xyz, r4, c20.x
add r0.xyz, r4, -c17
dp3 r0.w, r0, r0
dp3 r0.z, r3, r0
mad r2.z, -r2.w, r2.w, r0.w
mad r2.z, r0, r0, -r2
rsq r0.x, r2.z
rcp r0.y, r0.x
add r0.x, -r0.z, -r0.y
cmp r5.xy, r2.z, r1, c69.zwzw
cmp_pp r3.w, r2.z, c69.x, c69.y
add r0.y, -r0.z, r0
cmp r0.xy, -r3.w, r5, r0
add r2.z, r0.x, c70.x
cmp r5.x, r2.z, c69.y, c69
abs_pp r2.z, r5.x
add r3.w, r2, c41.x
mad r4.w, -r3, r3, r0
mad r5.y, r0.z, r0.z, -r4.w
cmp_pp r6.y, -r2.z, c69.x, c69
rsq r2.z, r0.w
rcp r2.z, r2.z
add r3.w, -r2.z, r3
add r2.w, r2.z, -r2
cmp r2.w, r2, c69.y, c69.x
cmp r4.w, r3, c69.y, c69.x
abs_pp r2.z, r2.w
rsq r5.z, r5.y
cmp_pp r3.w, -r2.z, c69.x, c69.y
rcp r2.w, r5.z
mul_pp r6.x, r3.w, r4.w
add r2.z, -r0, -r2.w
mul_pp r6.z, r6.x, r5.x
cmp r5.zw, r5.y, r1.xyxy, c69
cmp_pp r5.x, r5.y, c69, c69.y
add r2.w, -r0.z, r2
cmp r2.zw, -r5.x, r5, r2
mov r5.z, r0.y
abs_pp r0.y, r4.w
mov r5.x, r2.z
cmp_pp r0.y, -r0, c69.x, c69
cmp r4.w, r0.x, c69.y, c69.x
mul_pp r3.w, r3, r0.y
mov r5.w, r2
mov r5.y, r0.x
mul_pp r2.z, r6.x, r6.y
cmp r5.xy, -r6.z, r5.zwzw, r5
cmp r5.xy, -r2.z, r5, c68.zyzw
mul_pp r0.y, r3.w, r4.w
mov r2.z, c68
cmp r5.xy, -r0.y, r5, r2.zwzw
mad r0.y, -c19.x, c19.x, r0.w
mad r0.w, r0.z, r0.z, -r0.y
mov r0.y, r0.x
abs_pp r2.z, r4.w
cmp_pp r2.z, -r2, c69.x, c69.y
mul_pp r2.w, r3, r2.z
rsq r2.z, r0.w
rcp r2.z, r2.z
add r2.z, -r0, -r2
cmp_pp r0.z, r0.w, c69.x, c69.y
cmp r0.w, r0, r1.x, c69.z
cmp r0.w, -r0.z, r0, r2.z
rcp r0.z, r2.y
cmp r2.y, r0.w, r0.w, c69.z
mul r0.w, r2.x, r0.z
mad r2.y, -r0.w, c20.x, r2
mov r0.x, c68.z
cmp r0.xy, -r2.w, r5, r0
mov r0.z, c16.w
mad r0.z, c68.w, -r0, r2.x
max r10.z, r0.x, c68
mul r0.w, r0, c20.x
cmp r0.z, r0, c69.x, c69.y
mad r0.z, r0, r2.y, r0.w
min r0.x, r0.z, r0.y
add r0.y, -r0.x, r10.z
cmp r1, -r0.y, r1, c69.yyyx
cmp_pp r0.y, -r0, c69.x, c69
mov r10.w, r0.x
if_gt r0.y, c68.z
add r0.xyz, r4, -c17
mul r1.xyz, r0.zxyw, c24.yzxw
mad r1.xyz, r0.yzxw, c24.zxyw, -r1
dp3 r0.x, r0, c24
dp3 r0.w, r1, r1
mul r2.xyz, r3.zxyw, c24.yzxw
mad r2.xyz, r3.yzxw, c24.zxyw, -r2
cmp r0.x, -r0, c69, c69.y
mov r0.z, c44.x
dp3 r1.w, r2, r2
mad r0.w, -c19.x, c19.x, r0
mul r2.w, r1, r0
dp3 r0.w, r1, r2
mad r1.x, r0.w, r0.w, -r2.w
rsq r1.y, r1.x
rcp r1.y, r1.y
add r3.w, -r0, r1.y
add r1.z, -r0.w, -r1.y
rcp r2.y, r1.w
mul r1.z, r1, r2.y
mul r2.y, r2, r3.w
mov r0.w, c69.x
cmp r0.y, -r1.x, c69, c69.x
mul_pp r0.x, r0, c22
mul_pp r2.z, r0.x, r0.y
add r0.z, c70.w, r0
mul_sat r0.x, r0.z, c71
mad r0.y, -r0.x, c71, c71.z
mul r0.x, r0, r0
mul r1.x, r0, r0.y
cmp r2.x, -r2.z, c69.z, r1.z
mad r0.xyz, r3, r2.x, r4
add r0.xyz, r0, -c17
dp3 r0.x, r0, c24
mad r1.x, r1, c72, c72.y
mul r1.z, r1.x, c51.x
cmp r0.x, -r0, c69.y, c69
add r1.x, r10.z, c69
mul_pp r2.w, r2.z, r0.x
cmp r2.y, -r2.z, c69.w, r2
mov r2.z, c42.x
add r5.x, c68.y, r2.z
abs r3.w, c42.x
cmp r2.z, -r3.w, c69.x, c69.y
abs r3.w, r5.x
cmp r5.x, -r3.w, c69, c69.y
abs_pp r2.z, r2
cmp_pp r3.w, -r2.z, c69.x, c69.y
mul_pp r5.y, r3.w, r5.x
rcp r1.z, r1.z
mul r1.x, r1, c45
mad r1.x, r1, r1.z, r10.z
min r4.w, r10, r1.x
add r0.y, r10.z, r4.w
mul r0.xyz, r3, r0.y
mad r0.xyz, r0, c71.w, r4
mul r0.xyz, r0, c21.x
dp4 r1.x, r0, c8
dp4 r1.y, r0, c10
add r1.xy, r1, c69.x
mov r2.z, c42.x
mov r1.z, c68
mul r1.xy, r1, c71.w
texldl r1, r1.xyzz, s3
mul r1, r1, c34
add r1, r1, c33
cmp r5.y, -r5, r1.x, r1
add r1.y, c72.z, r2.z
abs_pp r1.x, r5
abs r1.y, r1
cmp r1.y, -r1, c69.x, c69
cmp_pp r1.x, -r1, c69, c69.y
mul_pp r1.x, r3.w, r1
mul_pp r3.w, r1.x, r1.y
abs_pp r2.z, r1.y
cmp r1.z, -r3.w, r5.y, r1
cmp_pp r1.y, -r2.z, c69.x, c69
mul_pp r1.y, r1.x, r1
mov r1.x, c44
cmp r6.w, -r1.y, r1.z, r1
mad r1.y, r1.x, c73.z, c73.w
mul r1.x, r6.w, c46.z
mul_sat r1.x, r1, r1.y
mul r8.w, r1.x, c74.x
dp4 r1.x, r0, c12
dp4 r1.y, r0, c14
add r0.xy, r1, c69.x
dp3 r1.x, r3, c24
mul r0.w, -r1.x, -r1.x
mad r1.y, -r0.w, c70, c70.z
rsq r1.y, r1.y
cmp r10.xy, -r2.w, r2, c69.zwzw
mul r0.xy, r0, c71.w
mov r0.z, c68
texldl r0, r0.xyzz, s2
mul r0, r0, c36
rcp r1.y, r1.y
add r2, r0, c35
pow_sat r0, r1.y, c63.x
mul r0.y, -r1.x, c57.x
add r0.z, r0.y, c69.x
mov r0.w, r0.x
mul r0.y, -c57.x, c57.x
rcp r0.z, r0.z
add r0.y, r0, c69.x
mul r0.y, r0, r0.z
mul r0.y, r0, r0.z
mul r0.z, r0.y, c58.x
mul r0.x, -r1, c59
add r0.y, r0.x, c69.x
mad r0.z, r0.w, c64.x, r0
mul r0.x, -c59, c59
rcp r0.y, r0.y
add r0.x, r0, c69
mul r0.x, r0, r0.y
mul r0.y, r0.x, r0
mul r0.x, -r1, c61
mad r0.z, r0.y, c60.x, r0
add r0.y, r0.x, c69.x
mul r0.x, -c61, c61
rcp r0.y, r0.y
add r0.x, r0, c69
mul r0.x, r0, r0.y
mul r0.x, r0, r0.y
dp3 r0.w, r3, c18
abs r0.y, r0.w
add r0.w, r0.y, c72
mad r5.w, r0.x, c62.x, r0.z
mov r0.xyz, c24
dp3 r0.z, c18, r0
mul_sat r0.w, r0, c73.x
abs r0.z, r0
mul r0.x, r0.w, r0.w
mad r0.y, -r0.w, c71, c71.z
mul r0.y, r0.x, r0
mov r0.x, c51
mul r0.x, c41, -r0
rcp r0.z, r0.z
mul r0.z, r0.x, r0
mul r0.x, r10.z, r0.y
mul r1.x, r0.z, c74.z
mul_sat r7.w, r0.x, c73.y
pow r0, c74.y, r1.x
mov r0.z, c39.x
mov r0.y, c69.x
add r0.z, c68.y, r0
cmp r3.w, r0.z, c39.x, r0.y
add r0.y, r3.w, c69.x
rcp r0.z, r0.y
add r0.y, -r10.z, r4.w
mul r10.w, r0.y, r0.z
mov r9.w, r0.x
mov r0.xyz, c18
mul r11.x, r10.w, c74.z
rcp r11.y, r10.w
mad r11.z, r10.w, c71.w, r10
dp3 r4.w, c24, r0
mov r5.xyz, c68.z
mov r6.xyz, c69.x
mov r11.w, c68.z
loop aL, i0
break_ge r11.w, r3.w
mad r7.xyz, r11.z, r3, r4
mul r0.xyz, r7.xzyw, c43.x
add r8.xy, r0, c47
mov r8.z, r0
mul r0.xyz, r8, c48.x
add r1.xy, r0, c47.zwzw
mov r1.z, r0
mul r0.xyz, r1, c48.x
add r0.xy, r0, c47.zwzw
mul r9.xyz, r0, c48.x
add r9.xy, r9, c47.zwzw
mov r12.y, r9.z
mov r12.x, r9
add r0.zw, r0.xyxz, c74.z
mul r0.zw, r0, c74.w
add r12.xy, r12, c74.z
mul r12.xy, r12, c74.w
mul r12.zw, r12.xyxy, c74.x
abs r12.zw, r12
frc r12.zw, r12
mul r12.zw, r12, c74.w
cmp r12.xy, r12, r12.zwzw, -r12.zwzw
mul r13.xy, r0.zwzw, c74.x
frc r0.x, r12.y
abs r12.zw, r13.xyxy
add r1.w, -r0.x, r12.y
mad r1.w, r1, c75.x, r12.x
add r1.w, r1, c75.y
mul r9.x, r1.w, c75.z
mov r9.z, c68
frc r12.zw, r12
mul r12.zw, r12, c74.w
cmp r0.zw, r0, r12, -r12
frc r12.x, r0.w
add r0.w, -r12.x, r0
mad r0.w, r0, c75.x, r0.z
texldl r9.xy, r9.xyzz, s4
add r0.z, r9.y, -r9.x
mad r9.z, r0.x, r0, r9.x
add r0.w, r0, c75.y
add r1.zw, r1.xyxz, c74.z
mul r0.x, r0.w, c75.z
mov r0.z, c68
texldl r0.xy, r0.xyzz, s4
mul r0.zw, r1, c74.w
add r0.y, r0, -r0.x
mad r12.x, r12, r0.y, r0
mul r1.zw, r0, c74.x
abs r0.xy, r1.zwzw
add r1.zw, r8.xyxz, c74.z
mul r1.zw, r1, c74.w
frc r0.xy, r0
mul r0.xy, r0, c74.w
cmp r0.xy, r0.zwzw, r0, -r0
frc r1.x, r0.y
add r0.y, -r1.x, r0
mad r0.x, r0.y, c75, r0
mul r9.xy, r1.zwzw, c74.x
abs r0.zw, r9.xyxy
frc r0.zw, r0
mul r0.zw, r0, c74.w
cmp r1.zw, r1, r0, -r0
frc r0.w, r1
add r0.x, r0, c75.y
add r1.w, -r0, r1
mov r0.z, c68
mov r0.y, r1
mul r0.x, r0, c75.z
texldl r0.xy, r0.xyzz, s4
mad r0.z, r1.w, c75.x, r1
add r0.y, r0, -r0.x
mad r1.z, r1.x, r0.y, r0.x
add r0.z, r0, c75.y
mul r0.x, r0.z, c75.z
mov r0.y, r8
mov r0.z, c68
texldl r1.xy, r0.xyzz, s4
add r0.xyz, r7, -c17
dp3 r0.x, r0, r0
mov r0.y, c19.x
rsq r0.x, r0.x
add r1.y, r1, -r1.x
add r0.y, c40.x, r0
rcp r0.x, r0.x
add r13.x, r0, -r0.y
mad r0.x, r0.w, r1.y, r1
mad r0.y, r1.z, c49.x, r0.x
mul r0.x, c49, c49
mad r0.y, r0.x, r12.x, r0
mov r0.w, c44.x
mul r0.z, r13.x, c41.y
mad r0.z, r0, c68.x, c68.y
mul r0.x, r0, c49
mad r0.x, r0, r9.z, r0.y
abs r0.z, r0
mul r0.y, r0.z, r0.z
mul r0.y, r0, r0
mul_sat r1.w, r13.x, c41.y
add r1.w, -r1, c69.x
min r1.x, c75.w, r0.w
mul r0.z, r0.y, r0.y
mad r0.w, -r0.z, r0.y, c69.x
mul r0.x, r0, c49.y
mad r0.yz, r0.w, c55.x, r1.x
mad r0.x, r0, r0.w, c44
mul_sat r1.xyz, r6.w, r0
mov r0.xyz, r7
mov r0.w, c69.x
dp4 r8.x, r0, c4
dp4 r8.y, r0, c5
mul r12.x, r1.w, c65
mov r8.z, c68
if_gt r12.x, c76.x
texldl r0, r8.xyzz, s5
add r12.x, r12, c76.y
else
if_gt r12.x, c76.z
texldl r0, r8.xyzz, s6
add r12.x, r12, c76.w
else
texldl r0, r8.xyzz, s7
endif
endif
mad r12.zw, r7.w, -r1.xyyz, r1.xyyz
add r1.y, r8.w, -r1.x
mad r12.y, r7.w, r1, r1.x
add r1.xyz, -r7, c30
mov r9.xyz, c23
add r7.xyz, -r7, c27
mul r12.w, r12, c52.x
mul r13.z, r12, c52.x
add r9.xyz, c25, r9
mul r8.xyz, r2.w, c37
mul r8.xyz, r8, r9
mov_sat r1.w, r4
mul r8.xyz, r8, r1.w
mad r8.xyz, r8, c77.z, r2
mul r8.xyz, r8, c56.y
mul r1.w, r12.y, r12
mul r9.xyz, r1.w, r8
mul r8.x, r13, -r12.w
dp3 r1.w, r1, r1
rsq r12.w, r1.w
mul r13.y, r8.x, c74.z
mul r8.xyz, r12.w, r1
pow r1, c74.y, r13.y
dp3 r1.y, r3, r8
mov r1.z, r1.x
mul r1.y, r1, c38.x
add r1.x, r1.y, c69
rcp r13.y, r1.x
add r1.x, -r13, c41
mul r1.y, -r13.z, r1.x
mul r8.xyz, r9, r1.z
mul r1.x, -c38, c38
add r12.z, r1.x, c69.x
mul r9.x, r1.y, c74.z
pow r1, c74.y, r9.x
mul r13.x, r12.z, r13.y
add r9.xyz, v1, c26
mul r1.y, r12, r13.z
mul r9.xyz, r9, c56.x
mul r9.xyz, r1.y, r9
mad r8.xyz, r9, r1.x, r8
dp3 r9.x, r7, r7
mov r1.xyz, c31
add r1.xyz, -c30, r1
dp3 r1.x, r1, r1
rsq r9.x, r9.x
rsq r9.y, r1.x
mul r1.xyz, r9.x, r7
dp3 r1.x, r1, r3
rcp r7.y, r9.x
rcp r1.y, r12.w
mul r1.x, r1, c38
mul r1.y, r1, c74.z
mul r1.y, r1, r1
add r1.x, r1, c69
rcp r1.x, r1.x
rcp r1.z, r1.y
rcp r7.x, r9.y
mul r1.w, r13.x, r13.y
mul r1.w, r7.x, r1
mul r1.y, r12.z, r1.x
mul r1.w, r1, r1.z
mul r7.x, r1.y, r1
mov r1.xyz, c28
add r1.xyz, -c27, r1
dp3 r1.x, r1, r1
mul r7.y, r7, c74.z
mul r1.y, r7, r7
rsq r1.x, r1.x
rcp r1.x, r1.x
mul r1.x, r1, r7
rcp r1.y, r1.y
mul r1.x, r1, r1.y
mul r1.y, r1.w, c74.z
mul r1.x, r1, c74.z
add r1.w, r12.x, c72.z
cmp r1.w, r1, c69.x, c69.y
min r7.x, r1, c69
min r1.y, r1, c69.x
mul r1.xyz, r1.y, c32
mad r1.xyz, r7.x, c29, r1
add r7.x, r12, c68.y
cmp r7.y, r7.x, c69.x, c69
add r7.z, -r1.w, c69.x
mul r7.z, r7.y, r7
mul r9.x, r0.z, r7.z
add r7.y, -r7, c69.x
add r7.x, r12, c77
mad r9.x, r0.y, r7.y, r9
mul r7.z, r0.y, r7
cmp r7.x, r7, c69, c69.y
mul r1.xyz, r1, c77.y
add r0.y, -r7.x, c69.x
mad r7.y, r0.x, r7, r7.z
mul r0.x, r1.w, r0.y
mad r0.y, r0.z, r0.x, r7
mad r0.x, r0.w, r0, r9
mad r0.y, r7.x, r0.w, r0
mad r0.x, r7, r0.w, r0
add r0.w, -r11.z, r10.y
add r0.z, r0.x, -r0.y
frc r0.x, r12
mad_sat r0.x, r0, r0.z, r0.y
add r11.z, r11, r10.w
add r0.z, r11, -r10.x
add r0.y, r9.w, -r0.x
mul_sat r0.w, r11.y, r0
mul_sat r0.z, r0, r11.y
mad r0.z, -r0, r0.w, c69.x
mad r0.w, r7, r0.y, r0.x
mul r0.w, r0, c53.x
mul r0.xyz, r0.z, v2
mul r0.xyz, r0.w, r0
mad r0.xyz, r0, r5.w, r1
mul r0.w, r12.y, c51.x
mul r1.w, r11.x, -r0
mul r1.xyz, r8, c54.x
mul r0.w, r12.y, c52.x
mul r1.xyz, r1, c77.y
mad r1.xyz, r0.w, r0, r1
pow r0, c74.y, r1.w
mul r1.xyz, r1, r11.x
mad r5.xyz, r1, r6, r5
mul r6.xyz, r6, r0.x
add r11.w, r11, c69.x
endloop
add r1.x, c46.y, -c46
rcp r1.y, r1.x
add r1.x, r10.z, -c46
mul r0.xyz, r5, c50
dp3 r0.w, r6, c78
add r2, -r0, c69.yyyx
mul_sat r1.x, r1, r1.y
mad r1, r1.x, r2, r0
endif
add r0, -r1, c69.yxyy
mad r0, r0, c67.x, r1
else
texldl r0, v0, s8
endif
mov oC0, r0

"
}

}

		}


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #8 upscales cloud rendering to actual screen resolution using SMART technique
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
Vector 17 [_CloudThicknessKm]
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
Float 8 [_CloudAltitudeKm]
Vector 9 [_CloudThicknessKm]
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
Float 8 [_CloudAltitudeKm]
Vector 9 [_CloudThicknessKm]
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
