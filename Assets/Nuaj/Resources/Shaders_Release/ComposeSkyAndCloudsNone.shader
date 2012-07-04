// This composes the previously computed downscaled sky buffer with cloud buffers
// It also computes more accurately the pixels that have too much discrepancy between the fullscale and downscaled versions
//
Shader "Hidden/Nuaj/ComposeSkyAndCloudsNone"
{
	Properties
	{
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
SetTexture 1 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[24] = { program.local[0..17],
		{ 0, 2, -1, -1000000 },
		{ 1, 0.995, 210, 128 },
		{ 0.0241188, 0.1228178, 0.84442663, 0.25 },
		{ 0.51413637, 0.32387859, 0.16036376, 15 },
		{ 0.26506799, 0.67023426, 0.064091571, 4 },
		{ 256, 400, 255, 0.0009765625 } };
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
MOVR  R2.xyz, c[5];
MOVR  R4.x, c[18].w;
MULR  R1.xy, fragment.texcoord[0], c[4];
MOVR  R0.xy, c[4];
MADR  R0.xy, R1, c[18].y, -R0;
MOVR  R0.z, c[18];
DP3R  R0.w, R0, R0;
MOVR  R1.x, c[0].w;
MOVR  R1.y, c[1].w;
MOVR  R1.z, c[2].w;
MADR  R1.xyz, R1, c[7].x, -R2;
RSQR  R2.x, R0.w;
MULR  R0.xyz, R2.x, R0;
MOVR  R0.w, c[18].x;
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
MOVR  R0.x, c[18].w;
MOVXC RC.z, R2;
MOVR  R0.x(EQ.z), R3;
RCPR  R0.y, R0.y;
ADDR  R0.x(NE.y), -R3.y, R0.y;
MOVR  R0.y, c[18].w;
MOVXC RC.y, R2;
MOVR  R0.y(EQ), R3.x;
RCPR  R0.z, R0.z;
ADDR  R0.y(NE.x), -R3, R0.z;
MOVR  R0.z, c[18].w;
MOVXC RC.z, R2.w;
MOVR  R0.z(EQ), R3.x;
RCPR  R0.w, R0.w;
ADDR  R0.z(NE.w), -R3.y, R0.w;
MOVR  R4.y, R0;
MOVR  R4.w, R0.z;
MOVR  R4.z, R0.x;
DP4R  R0.x, R4, c[9];
SGER  H0.x, c[18], R0;
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
DP4R  R1.x, R2, c[19].x;
DP4R  R1.y, R3, c[19].x;
DP4R  R1.z, R4, c[19].x;
DP4R  R1.w, R5, c[19].x;
DP4R  R0.x, R2, R2;
DP4R  R0.y, R3, R3;
DP4R  R0.w, R5, R5;
DP4R  R0.z, R4, R4;
MADR  R0, R1, R0, -R0;
ADDR  R0, R0, c[19].x;
MULR  R1.x, R0, R0.y;
MULR  R1.x, R1, R0.z;
MULR  R0.w, R1.x, R0;
DP4R  R1.x, R4, c[18].x;
DP4R  R1.y, R5, c[18].x;
MADR  R0.z, R0, R1.y, R1.x;
DP4R  R1.x, R3, c[18].x;
MADR  R0.y, R0, R0.z, R1.x;
ADDR  R1.x, c[4].w, -c[4].z;
RCPR  R1.y, R1.x;
DP4R  R0.z, R2, c[18].x;
TEX   R1.x, fragment.texcoord[0], texture[0], 2D;
MULR  R1.y, R1, c[4].w;
ADDR  R1.z, R1.y, -R1.x;
MOVR  R1.x, c[19].y;
RCPR  R1.z, R1.z;
MULR  R1.y, R1, c[4].z;
MULR  R1.x, R1, c[4].w;
MULR  R1.y, R1, R1.z;
SGTRC HC.x, R1.y, R1;
MADR  R0.xyz, R0.x, R0.y, R0.z;
IF    NE.x;
TEX   R1.xyz, fragment.texcoord[0], texture[1], 2D;
ELSE;
MOVR  R1.xyz, c[18].x;
ENDIF;
MADR  R0.xyz, R1, R0.w, R0;
MULR  R1.xyz, R0.y, c[22];
MADR  R1.xyz, R0.x, c[21], R1;
MADR  R0.xyz, R0.z, c[20], R1;
ADDR  R1.x, R0, R0.y;
ADDR  R0.z, R0, R1.x;
RCPR  R0.z, R0.z;
MULR  R1.zw, R0.xyxy, R0.z;
MULR  R0.x, R1.z, c[19].z;
MULR  R1.xyz, R0.w, c[22];
MADR  R1.xyz, R0.w, c[21], R1;
MADR  R1.xyz, R0.w, c[20], R1;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[19].z;
SGER  H0.x, R0, c[19].w;
MULH  H0.y, H0.x, c[19].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[20].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[21].w;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
ADDR  R0.z, R1, R0;
MULH  H0.y, H0, c[22].w;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.z, R0, c[19];
FLRR  R0.z, R0;
MULR  R1.x, R1.w, c[23].y;
FLRR  R1.x, R1;
MADH  H0.x, H0, c[18].y, H0.z;
MINR  R0.z, R0, c[19];
SGER  H0.z, R0, c[19].w;
ADDR  R0.x, R0, -H0.y;
MINR  R1.x, R1, c[23].z;
MADR  R0.x, R0, c[23], R1;
MULH  H0.y, H0.z, c[19].w;
ADDR  R1.x, R0.z, -H0.y;
MOVR  R0.z, c[19].x;
MADR  H0.y, R0.x, c[23].w, R0.z;
MULR  R0.x, R0.w, c[23].y;
MULR  R1.z, R1.x, c[20].w;
FLRR  R0.x, R0;
FLRR  H0.w, R1.z;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[22].w;
ADDR  R0.w, R1.x, -H0.x;
ADDH  H0.x, H0.w, -c[21].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.x, R0, c[23].z;
MADR  R0.x, R0.w, c[23], R0;
MADR  H0.z, R0.x, c[23].w, R0;
MADH  H0.x, H0.y, c[18].y, H0;
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
SetTexture 0 [_CameraDepthTexture] 2D
Vector 5 [_PlanetCenterKm]
Float 6 [_PlanetRadiusKm]
Float 7 [_WorldUnit2Kilometer]
Vector 8 [_ShadowAltitudesMinKm]
SetTexture 1 [_TexBackground] 2D
Vector 9 [_CaseSwizzle]
Vector 10 [_SwizzleExitUp0]
Vector 11 [_SwizzleExitUp1]
Vector 12 [_SwizzleExitUp2]
Vector 13 [_SwizzleExitUp3]
Vector 14 [_SwizzleEnterDown0]
Vector 15 [_SwizzleEnterDown1]
Vector 16 [_SwizzleEnterDown2]
Vector 17 [_SwizzleEnterDown3]

"ps_3_0
dcl_2d s0
dcl_2d s1
def c18, 2.00000000, -1.00000000, 0.00000000, 1.00000000
def c19, -1000000.00000000, 0.99500000, 210.00000000, -128.00000000
def c20, 0.26506799, 0.67023426, 0.06409157, 128.00000000
def c21, 0.51413637, 0.32387859, 0.16036376, 0.25000000
def c22, 0.02411880, 0.12281780, 0.84442663, -15.00000000
def c23, 4.00000000, 400.00000000, 255.00000000, 256.00000000
def c24, 0.00097656, 1.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mad r0.xy, v0, c18.x, c18.y
mov r4, c13
mov r3, c12
mov r0.z, c18.y
mul r0.xy, r0, c4
dp3 r0.w, r0, r0
rsq r1.x, r0.w
mul r0.xyz, r1.x, r0
mov r0.w, c18.z
dp4 r1.z, r0, c2
dp4 r1.y, r0, c1
dp4 r1.x, r0, c0
mov r0.z, c6.x
mov r0.w, c6.x
add r0.w, c8.y, r0
mov r2.x, c0.w
mov r2.z, c2.w
mov r2.y, c1.w
mul r2.xyz, r2, c7.x
add r2.xyz, r2, -c5
dp3 r0.x, r1, r2
dp3 r0.y, r2, r2
mad r1.x, -r0.w, r0.w, r0.y
mad r1.y, r0.x, r0.x, -r1.x
rsq r1.z, r1.y
add r0.z, c8.x, r0
mad r0.z, -r0, r0, r0.y
mad r0.z, r0.x, r0.x, -r0
rsq r0.w, r0.z
rcp r0.w, r0.w
add r1.x, -r0, r0.w
cmp_pp r0.w, r0.z, c18, c18.z
cmp r0.z, r0, r1.w, c19.x
cmp r2.x, -r0.w, r0.z, r1
rcp r1.z, r1.z
cmp r1.x, r1.y, r1.w, c19
add r1.z, -r0.x, r1
cmp_pp r0.w, r1.y, c18, c18.z
cmp r2.y, -r0.w, r1.x, r1.z
mov r0.z, c6.x
add r0.w, c8, r0.z
mad r0.w, -r0, r0, r0.y
mov r0.z, c6.x
add r0.z, c8, r0
mad r0.y, -r0.z, r0.z, r0
mad r0.w, r0.x, r0.x, -r0
rsq r0.z, r0.w
rcp r1.x, r0.z
mad r0.y, r0.x, r0.x, -r0
add r1.y, -r0.x, r1.x
cmp_pp r1.x, r0.w, c18.w, c18.z
cmp r0.w, r0, r1, c19.x
rsq r0.z, r0.y
rcp r0.z, r0.z
add r0.z, -r0.x, r0
cmp_pp r0.x, r0.y, c18.w, c18.z
cmp r0.y, r0, r1.w, c19.x
cmp r2.w, -r1.x, r0, r1.y
cmp r2.z, -r0.x, r0.y, r0
dp4 r0.x, r2, c9
mov r1, c10
mov r2, c11
cmp r0.z, -r0.x, c18.w, c18
add r1, -c14, r1
mad r1, r0.z, r1, c14
add r2, -c15, r2
mad r2, r0.z, r2, c15
add r4, -c17, r4
mad r4, r0.z, r4, c17
add r3, -c16, r3
mad r3, r0.z, r3, c16
dp4 r0.x, r1, c18.w
dp4 r0.y, r2, c18.w
dp4 r0.w, r4, c18.w
dp4 r0.z, r3, c18.w
add r5, r0, c18.y
dp4 r0.y, r2, r2
dp4 r2.z, r2, c18.z
dp4 r0.x, r1, r1
dp4 r0.z, r3, r3
dp4 r0.w, r4, r4
mad r0, r0, r5, c18.w
mul r5.x, r0, r0.y
mul r5.x, r5, r0.z
dp4 r2.y, r3, c18.z
dp4 r2.x, r4, c18.z
mad r0.z, r0, r2.x, r2.y
mad r0.y, r0, r0.z, r2.z
dp4 r0.z, r1, c18.z
add r1.x, c4.w, -c4.z
rcp r1.y, r1.x
texldl r1.x, v0, s0
mul r1.y, r1, c4.w
add r1.z, r1.y, -r1.x
mov r1.x, c4.w
mul r1.w, c19.y, r1.x
mad r0.xyz, r0.x, r0.y, r0.z
rcp r1.z, r1.z
mul r1.x, r1.y, c4.z
mul r1.x, r1, r1.z
mul r0.w, r5.x, r0
if_gt r1.x, r1.w
texldl r1.xyz, v0, s1
else
mov r1.xyz, c18.z
endif
mad r0.xyz, r1, r0.w, r0
mul r1.xyz, r0.y, c20
mad r1.xyz, r0.x, c21, r1
mad r0.xyz, r0.z, c22, r1
add r1.x, r0, r0.y
add r0.z, r0, r1.x
rcp r0.z, r0.z
mul r1.xy, r0, r0.z
mul r0.x, r1, c19.z
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.x, r0, c19.z
add r0.z, r0.x, c19.w
cmp r0.z, r0, c18.w, c18
mul_pp r1.x, r0.z, c20.w
add r0.x, r0, -r1
mul r1.x, r0, c21.w
mul r2.xyz, r0.w, c20
frc r1.z, r1.x
mad r2.xyz, r0.w, c21, r2
mad r2.xyz, r0.w, c22, r2
add r1.z, r1.x, -r1
add_pp r0.w, r1.z, c22
add r1.x, r2, r2.y
add r1.x, r2.z, r1
rcp r1.w, r1.x
exp_pp r0.w, r0.w
mad_pp r0.z, -r0, c18.x, c18.w
mul_pp r1.x, r0.z, r0.w
mul r0.zw, r2.xyxy, r1.w
mul r1.w, r0.z, c19.z
mul_pp r1.z, r1, c23.x
add r0.z, r0.x, -r1
mul r0.x, r1.y, c23.y
frc r1.y, r0.x
add r0.x, r0, -r1.y
min r1.y, r0.x, c23.z
mad r0.z, r0, c23.w, r1.y
frc r1.z, r1.w
add r1.z, r1.w, -r1
min r1.z, r1, c19
add r1.w, r1.z, c19
cmp r0.x, r1.w, c18.w, c18.z
mul_pp r1.y, r0.x, c20.w
mad r0.z, r0, c24.x, c24.y
mul_pp oC0.y, r1.x, r0.z
add r1.y, r1.z, -r1
mul r1.x, r0.w, c23.y
mul r0.z, r1.y, c21.w
frc r0.w, r0.z
add r0.z, r0, -r0.w
mul_pp r0.w, r0.z, c23.x
frc r1.z, r1.x
add r1.x, r1, -r1.z
add_pp r0.z, r0, c22.w
min r1.x, r1, c23.z
add r0.w, r1.y, -r0
mad r0.w, r0, c23, r1.x
mad r0.w, r0, c24.x, c24.y
exp_pp r0.z, r0.z
mad_pp r0.x, -r0, c18, c18.w
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[9] = { program.local[0..3],
		{ 0.0241188, 0.1228178, 0.84442663, 210 },
		{ 0.51413637, 0.32387859, 0.16036376, 128 },
		{ 0.26506799, 0.67023426, 0.064091571, 0.25 },
		{ 15, 2, 4, 256 },
		{ 400, 255, 0.0009765625, 1 } };
TEMP R0;
TEMP R1;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MULR  R1.xyz, R0.y, c[6];
MADR  R1.xyz, R0.x, c[5], R1;
MADR  R0.xyz, R0.z, c[4], R1;
ADDR  R1.x, R0, R0.y;
ADDR  R0.z, R0, R1.x;
RCPR  R0.z, R0.z;
MULR  R1.zw, R0.xyxy, R0.z;
MULR  R0.x, R1.z, c[4].w;
MULR  R1.xyz, R0.w, c[6];
MADR  R1.xyz, R0.w, c[5], R1;
MADR  R1.xyz, R0.w, c[4], R1;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[4].w;
SGER  H0.x, R0, c[5].w;
MULH  H0.y, H0.x, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[6].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[7].x;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
MULH  H0.y, H0, c[7].z;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.z, R0, c[4].w;
FLRR  R0.z, R0;
MULR  R1.x, R1.w, c[8];
FLRR  R1.x, R1;
MADH  H0.x, H0, c[7].y, H0.z;
MINR  R0.z, R0, c[4].w;
SGER  H0.z, R0, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[5].w;
MINR  R1.x, R1, c[8].y;
ADDR  R0.z, R0, -H0.y;
MADR  R0.x, R0, c[7].w, R1;
MADR  H0.y, R0.x, c[8].z, c[8].w;
MULR  R1.x, R0.z, c[6].w;
MULR  R0.x, R0.w, c[8];
FLRR  R0.x, R0;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[7].z;
ADDR  R0.z, R0, -H0.x;
ADDH  H0.x, H0.w, -c[7];
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.x, R0, c[8].y;
MADR  R0.x, R0.z, c[7].w, R0;
MADR  H0.z, R0.x, c[8], c[8].w;
MADH  H0.x, H0.y, c[7].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"ps_3_0
dcl_2d s0
def c4, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c5, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c6, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c7, 1.00000000, 0.00000000, 2.00000000, 0.25000000
def c8, -15.00000000, 4.00000000, 400.00000000, 255.00000000
def c9, 256.00000000, 0.00097656, 1.00000000, 0
dcl_texcoord0 v0.xyzw
texldl r0, v0, s0
mul r1.xyz, r0.y, c4
mad r1.xyz, r0.x, c5, r1
mad r0.xyz, r0.z, c6, r1
add r1.x, r0, r0.y
add r0.z, r0, r1.x
rcp r0.z, r0.z
mul r1.zw, r0.xyxy, r0.z
mul r0.x, r1.z, c4.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.z, r0.x, c4.w
add r0.x, r0.z, c5.w
cmp r0.x, r0, c7, c7.y
mul_pp r1.x, r0, c6.w
add r0.z, r0, -r1.x
mul r2.x, r0.z, c7.w
frc r2.y, r2.x
mul r1.xyz, r0.w, c4
mad r1.xyz, r0.w, c5, r1
mad r1.xyz, r0.w, c6, r1
add r2.x, r2, -r2.y
add r2.y, r1.x, r1
add_pp r0.w, r2.x, c8.x
add r1.z, r1, r2.y
rcp r1.z, r1.z
mul r2.zw, r1.xyxy, r1.z
mul r1.z, r2, c4.w
mul r1.x, r1.w, c8.z
exp_pp r0.w, r0.w
mad_pp r0.x, -r0, c7.z, c7
mul_pp r0.x, r0, r0.w
mul_pp r0.w, r2.x, c8.y
add r0.w, r0.z, -r0
frc r0.z, r1
add r0.z, r1, -r0
frc r1.z, r1.x
add r1.x, r1, -r1.z
min r1.z, r1.x, c8.w
mad r0.w, r0, c9.x, r1.z
min r0.z, r0, c4.w
add r1.w, r0.z, c5
cmp r1.x, r1.w, c7, c7.y
mul_pp r1.z, r1.x, c6.w
add r0.z, r0, -r1
mad r0.w, r0, c9.y, c9.z
mul_pp oC0.y, r0.x, r0.w
mul r0.x, r0.z, c7.w
frc r0.w, r0.x
add r0.x, r0, -r0.w
mul_pp r0.w, r0.x, c8.y
mul r1.z, r2.w, c8
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0, -r0.w
min r1.z, r1, c8.w
mad r0.z, r0, c9.x, r1
add_pp r0.x, r0, c8
mad r0.w, r0.z, c9.y, c9.z
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c7.z, c7
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[9] = { program.local[0..3],
		{ 0.0241188, 0.1228178, 0.84442663, 210 },
		{ 0.51413637, 0.32387859, 0.16036376, 128 },
		{ 0.26506799, 0.67023426, 0.064091571, 0.25 },
		{ 15, 2, 4, 256 },
		{ 400, 255, 0.0009765625, 1 } };
TEMP R0;
TEMP R1;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MULR  R1.xyz, R0.y, c[6];
MADR  R1.xyz, R0.x, c[5], R1;
MADR  R0.xyz, R0.z, c[4], R1;
ADDR  R1.x, R0, R0.y;
ADDR  R0.z, R0, R1.x;
RCPR  R0.z, R0.z;
MULR  R1.zw, R0.xyxy, R0.z;
MULR  R0.x, R1.z, c[4].w;
MULR  R1.xyz, R0.w, c[6];
MADR  R1.xyz, R0.w, c[5], R1;
MADR  R1.xyz, R0.w, c[4], R1;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[4].w;
SGER  H0.x, R0, c[5].w;
MULH  H0.y, H0.x, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[6].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[7].x;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
MULH  H0.y, H0, c[7].z;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.z, R0, c[4].w;
FLRR  R0.z, R0;
MULR  R1.x, R1.w, c[8];
FLRR  R1.x, R1;
MADH  H0.x, H0, c[7].y, H0.z;
MINR  R0.z, R0, c[4].w;
SGER  H0.z, R0, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[5].w;
MINR  R1.x, R1, c[8].y;
ADDR  R0.z, R0, -H0.y;
MADR  R0.x, R0, c[7].w, R1;
MADR  H0.y, R0.x, c[8].z, c[8].w;
MULR  R1.x, R0.z, c[6].w;
MULR  R0.x, R0.w, c[8];
FLRR  R0.x, R0;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[7].z;
ADDR  R0.z, R0, -H0.x;
ADDH  H0.x, H0.w, -c[7];
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.x, R0, c[8].y;
MADR  R0.x, R0.z, c[7].w, R0;
MADR  H0.z, R0.x, c[8], c[8].w;
MADH  H0.x, H0.y, c[7].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"ps_3_0
dcl_2d s0
def c4, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c5, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c6, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c7, 1.00000000, 0.00000000, 2.00000000, 0.25000000
def c8, -15.00000000, 4.00000000, 400.00000000, 255.00000000
def c9, 256.00000000, 0.00097656, 1.00000000, 0
dcl_texcoord0 v0.xyzw
texldl r0, v0, s0
mul r1.xyz, r0.y, c4
mad r1.xyz, r0.x, c5, r1
mad r0.xyz, r0.z, c6, r1
add r1.x, r0, r0.y
add r0.z, r0, r1.x
rcp r0.z, r0.z
mul r1.zw, r0.xyxy, r0.z
mul r0.x, r1.z, c4.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.z, r0.x, c4.w
add r0.x, r0.z, c5.w
cmp r0.x, r0, c7, c7.y
mul_pp r1.x, r0, c6.w
add r0.z, r0, -r1.x
mul r2.x, r0.z, c7.w
frc r2.y, r2.x
mul r1.xyz, r0.w, c4
mad r1.xyz, r0.w, c5, r1
mad r1.xyz, r0.w, c6, r1
add r2.x, r2, -r2.y
add r2.y, r1.x, r1
add_pp r0.w, r2.x, c8.x
add r1.z, r1, r2.y
rcp r1.z, r1.z
mul r2.zw, r1.xyxy, r1.z
mul r1.z, r2, c4.w
mul r1.x, r1.w, c8.z
exp_pp r0.w, r0.w
mad_pp r0.x, -r0, c7.z, c7
mul_pp r0.x, r0, r0.w
mul_pp r0.w, r2.x, c8.y
add r0.w, r0.z, -r0
frc r0.z, r1
add r0.z, r1, -r0
frc r1.z, r1.x
add r1.x, r1, -r1.z
min r1.z, r1.x, c8.w
mad r0.w, r0, c9.x, r1.z
min r0.z, r0, c4.w
add r1.w, r0.z, c5
cmp r1.x, r1.w, c7, c7.y
mul_pp r1.z, r1.x, c6.w
add r0.z, r0, -r1
mad r0.w, r0, c9.y, c9.z
mul_pp oC0.y, r0.x, r0.w
mul r0.x, r0.z, c7.w
frc r0.w, r0.x
add r0.x, r0, -r0.w
mul_pp r0.w, r0.x, c8.y
mul r1.z, r2.w, c8
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0, -r0.w
min r1.z, r1, c8.w
mad r0.z, r0, c9.x, r1
add_pp r0.x, r0, c8
mad r0.w, r0.z, c9.y, c9.z
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c7.z, c7
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[9] = { program.local[0..3],
		{ 0.0241188, 0.1228178, 0.84442663, 210 },
		{ 0.51413637, 0.32387859, 0.16036376, 128 },
		{ 0.26506799, 0.67023426, 0.064091571, 0.25 },
		{ 15, 2, 4, 256 },
		{ 400, 255, 0.0009765625, 1 } };
TEMP R0;
TEMP R1;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MULR  R1.xyz, R0.y, c[6];
MADR  R1.xyz, R0.x, c[5], R1;
MADR  R0.xyz, R0.z, c[4], R1;
ADDR  R1.x, R0, R0.y;
ADDR  R0.z, R0, R1.x;
RCPR  R0.z, R0.z;
MULR  R1.zw, R0.xyxy, R0.z;
MULR  R0.x, R1.z, c[4].w;
MULR  R1.xyz, R0.w, c[6];
MADR  R1.xyz, R0.w, c[5], R1;
MADR  R1.xyz, R0.w, c[4], R1;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[4].w;
SGER  H0.x, R0, c[5].w;
MULH  H0.y, H0.x, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[6].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[7].x;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
MULH  H0.y, H0, c[7].z;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.z, R0, c[4].w;
FLRR  R0.z, R0;
MULR  R1.x, R1.w, c[8];
FLRR  R1.x, R1;
MADH  H0.x, H0, c[7].y, H0.z;
MINR  R0.z, R0, c[4].w;
SGER  H0.z, R0, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[5].w;
MINR  R1.x, R1, c[8].y;
ADDR  R0.z, R0, -H0.y;
MADR  R0.x, R0, c[7].w, R1;
MADR  H0.y, R0.x, c[8].z, c[8].w;
MULR  R1.x, R0.z, c[6].w;
MULR  R0.x, R0.w, c[8];
FLRR  R0.x, R0;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[7].z;
ADDR  R0.z, R0, -H0.x;
ADDH  H0.x, H0.w, -c[7];
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.x, R0, c[8].y;
MADR  R0.x, R0.z, c[7].w, R0;
MADR  H0.z, R0.x, c[8], c[8].w;
MADH  H0.x, H0.y, c[7].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"ps_3_0
dcl_2d s0
def c4, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c5, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c6, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c7, 1.00000000, 0.00000000, 2.00000000, 0.25000000
def c8, -15.00000000, 4.00000000, 400.00000000, 255.00000000
def c9, 256.00000000, 0.00097656, 1.00000000, 0
dcl_texcoord0 v0.xyzw
texldl r0, v0, s0
mul r1.xyz, r0.y, c4
mad r1.xyz, r0.x, c5, r1
mad r0.xyz, r0.z, c6, r1
add r1.x, r0, r0.y
add r0.z, r0, r1.x
rcp r0.z, r0.z
mul r1.zw, r0.xyxy, r0.z
mul r0.x, r1.z, c4.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.z, r0.x, c4.w
add r0.x, r0.z, c5.w
cmp r0.x, r0, c7, c7.y
mul_pp r1.x, r0, c6.w
add r0.z, r0, -r1.x
mul r2.x, r0.z, c7.w
frc r2.y, r2.x
mul r1.xyz, r0.w, c4
mad r1.xyz, r0.w, c5, r1
mad r1.xyz, r0.w, c6, r1
add r2.x, r2, -r2.y
add r2.y, r1.x, r1
add_pp r0.w, r2.x, c8.x
add r1.z, r1, r2.y
rcp r1.z, r1.z
mul r2.zw, r1.xyxy, r1.z
mul r1.z, r2, c4.w
mul r1.x, r1.w, c8.z
exp_pp r0.w, r0.w
mad_pp r0.x, -r0, c7.z, c7
mul_pp r0.x, r0, r0.w
mul_pp r0.w, r2.x, c8.y
add r0.w, r0.z, -r0
frc r0.z, r1
add r0.z, r1, -r0
frc r1.z, r1.x
add r1.x, r1, -r1.z
min r1.z, r1.x, c8.w
mad r0.w, r0, c9.x, r1.z
min r0.z, r0, c4.w
add r1.w, r0.z, c5
cmp r1.x, r1.w, c7, c7.y
mul_pp r1.z, r1.x, c6.w
add r0.z, r0, -r1
mad r0.w, r0, c9.y, c9.z
mul_pp oC0.y, r0.x, r0.w
mul r0.x, r0.z, c7.w
frc r0.w, r0.x
add r0.x, r0, -r0.w
mul_pp r0.w, r0.x, c8.y
mul r1.z, r2.w, c8
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0, -r0.w
min r1.z, r1, c8.w
mad r0.z, r0, c9.x, r1
add_pp r0.x, r0, c8
mad r0.w, r0.z, c9.y, c9.z
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c7.z, c7
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r0.y
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
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[9] = { program.local[0..3],
		{ 0.0241188, 0.1228178, 0.84442663, 210 },
		{ 0.51413637, 0.32387859, 0.16036376, 128 },
		{ 0.26506799, 0.67023426, 0.064091571, 0.25 },
		{ 15, 2, 4, 256 },
		{ 400, 255, 0.0009765625, 1 } };
TEMP R0;
TEMP R1;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MULR  R1.xyz, R0.y, c[6];
MADR  R1.xyz, R0.x, c[5], R1;
MADR  R0.xyz, R0.z, c[4], R1;
ADDR  R1.x, R0, R0.y;
ADDR  R0.z, R0, R1.x;
RCPR  R0.z, R0.z;
MULR  R1.zw, R0.xyxy, R0.z;
MULR  R0.x, R1.z, c[4].w;
MULR  R1.xyz, R0.w, c[6];
MADR  R1.xyz, R0.w, c[5], R1;
MADR  R1.xyz, R0.w, c[4], R1;
FLRR  R0.x, R0;
MINR  R0.x, R0, c[4].w;
SGER  H0.x, R0, c[5].w;
MULH  H0.y, H0.x, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULR  R0.z, R0.x, c[6].w;
FLRR  H0.y, R0.z;
ADDH  H0.z, H0.y, -c[7].x;
EX2H  H0.z, H0.z;
MULH  H0.x, -H0, H0.z;
ADDR  R0.z, R1.x, R1.y;
MULH  H0.y, H0, c[7].z;
ADDR  R0.z, R1, R0;
RCPR  R0.z, R0.z;
MULR  R0.zw, R1.xyxy, R0.z;
MULR  R0.z, R0, c[4].w;
FLRR  R0.z, R0;
MULR  R1.x, R1.w, c[8];
FLRR  R1.x, R1;
MADH  H0.x, H0, c[7].y, H0.z;
MINR  R0.z, R0, c[4].w;
SGER  H0.z, R0, c[5].w;
ADDR  R0.x, R0, -H0.y;
MULH  H0.y, H0.z, c[5].w;
MINR  R1.x, R1, c[8].y;
ADDR  R0.z, R0, -H0.y;
MADR  R0.x, R0, c[7].w, R1;
MADR  H0.y, R0.x, c[8].z, c[8].w;
MULR  R1.x, R0.z, c[6].w;
MULR  R0.x, R0.w, c[8];
FLRR  R0.x, R0;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[7].z;
ADDR  R0.z, R0, -H0.x;
ADDH  H0.x, H0.w, -c[7];
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.x, R0, c[8].y;
MADR  R0.x, R0.z, c[7].w, R0;
MADR  H0.z, R0.x, c[8], c[8].w;
MADH  H0.x, H0.y, c[7].y, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R0.y;
MOVH  oCol.z, R1.y;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Matrix 0 [_Camera2World]
SetTexture 0 [_TexCloudLayer0] 2D

"ps_3_0
dcl_2d s0
def c4, 0.26506799, 0.67023426, 0.06409157, 210.00000000
def c5, 0.51413637, 0.32387859, 0.16036376, -128.00000000
def c6, 0.02411880, 0.12281780, 0.84442663, 128.00000000
def c7, 1.00000000, 0.00000000, 2.00000000, 0.25000000
def c8, -15.00000000, 4.00000000, 400.00000000, 255.00000000
def c9, 256.00000000, 0.00097656, 1.00000000, 0
dcl_texcoord0 v0.xyzw
texldl r0, v0, s0
mul r1.xyz, r0.y, c4
mad r1.xyz, r0.x, c5, r1
mad r0.xyz, r0.z, c6, r1
add r1.x, r0, r0.y
add r0.z, r0, r1.x
rcp r0.z, r0.z
mul r1.zw, r0.xyxy, r0.z
mul r0.x, r1.z, c4.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
min r0.z, r0.x, c4.w
add r0.x, r0.z, c5.w
cmp r0.x, r0, c7, c7.y
mul_pp r1.x, r0, c6.w
add r0.z, r0, -r1.x
mul r2.x, r0.z, c7.w
frc r2.y, r2.x
mul r1.xyz, r0.w, c4
mad r1.xyz, r0.w, c5, r1
mad r1.xyz, r0.w, c6, r1
add r2.x, r2, -r2.y
add r2.y, r1.x, r1
add_pp r0.w, r2.x, c8.x
add r1.z, r1, r2.y
rcp r1.z, r1.z
mul r2.zw, r1.xyxy, r1.z
mul r1.z, r2, c4.w
mul r1.x, r1.w, c8.z
exp_pp r0.w, r0.w
mad_pp r0.x, -r0, c7.z, c7
mul_pp r0.x, r0, r0.w
mul_pp r0.w, r2.x, c8.y
add r0.w, r0.z, -r0
frc r0.z, r1
add r0.z, r1, -r0
frc r1.z, r1.x
add r1.x, r1, -r1.z
min r1.z, r1.x, c8.w
mad r0.w, r0, c9.x, r1.z
min r0.z, r0, c4.w
add r1.w, r0.z, c5
cmp r1.x, r1.w, c7, c7.y
mul_pp r1.z, r1.x, c6.w
add r0.z, r0, -r1
mad r0.w, r0, c9.y, c9.z
mul_pp oC0.y, r0.x, r0.w
mul r0.x, r0.z, c7.w
frc r0.w, r0.x
add r0.x, r0, -r0.w
mul_pp r0.w, r0.x, c8.y
mul r1.z, r2.w, c8
frc r1.w, r1.z
add r1.z, r1, -r1.w
add r0.z, r0, -r0.w
min r1.z, r1, c8.w
mad r0.z, r0, c9.x, r1
add_pp r0.x, r0, c8
mad r0.w, r0.z, c9.y, c9.z
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c7.z, c7
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
