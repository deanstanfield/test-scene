// This shader renders the toroidal shadow map into a light cookie useable by Unity
//
Shader "Hidden/Nuaj/RenderLightCookie"
{
	Properties
	{
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }

		Pass
		{
			Program "vp" {

SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [glstate_matrix_texture0]
Float 16 [_WorldUnit2Kilometer]
Matrix 8 [_NuajWorld2Shadow]
Float 17 [_CookieSize]
Matrix 12 [_Light2World]
"!!ARBvp1.0
OPTION NV_vertex_program3;
PARAM c[19] = { state.matrix.mvp.row[0..3],
		state.matrix.texture[0].row[0..3],
		program.local[8..17],
		{ 0, 0.5, 1 } };
TEMP R0;
TEMP R1;
TEMP RC, HC;
BB0:
MOV   R0.zw, c[18].x;
MOV   R0.xy, vertex.texcoord[0];
DP4   R1.x, R0, c[4];
DP4   R0.x, R0, c[5];
ADD   R0.w, -c[18].y, R1.x;
ADD   R1.x, -c[18].y, R0;
MOV   R0.x, c[12].y;
MOV   R0.y, c[13];
MOV   R0.z, c[14].y;
MUL   R1.xyz, R0, R1.x;
MOV   R0.x, c[12];
MOV   R0.y, c[13].x;
MOV   R0.z, c[14].x;
MAD   R1.xyz, R0, R0.w, R1;
MOV   R0.w, c[18].z;
MOV   R0.x, c[12].w;
MOV   R0.z, c[14].w;
MOV   R0.y, c[13].w;
MAD   R0.xyz, R1, c[17].x, R0;
MUL   R0.xyz, R0, c[16].x;
DP4   result.texcoord[0].y, R0, c[9];
DP4   result.texcoord[0].x, R0, c[8];
MOV   result.texcoord[0].zw, c[18].x;
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
Float 16 [_WorldUnit2Kilometer]
Matrix 8 [_NuajWorld2Shadow]
Float 17 [_CookieSize]
Matrix 12 [_Light2World]
"vs_3_0
dcl_position o0
dcl_texcoord0 o1
def c18, 0.00000000, -0.50000000, 1.00000000, 0
dcl_position0 v0
dcl_texcoord0 v1
mov r0.zw, c18.x
mov r0.xy, v1
dp4 r1.x, r0, c4
dp4 r0.x, r0, c5
add r0.w, r1.x, c18.y
add r1.x, r0, c18.y
mov r0.x, c12.y
mov r0.y, c13
mov r0.z, c14.y
mul r1.xyz, r0, r1.x
mov r0.x, c12
mov r0.y, c13.x
mov r0.z, c14.x
mad r1.xyz, r0, r0.w, r1
mov r0.w, c18.z
mov r0.x, c12.w
mov r0.z, c14.w
mov r0.y, c13.w
mad r0.xyz, r1, c17.x, r0
mul r0.xyz, r0, c16.x
dp4 o1.y, r0, c9
dp4 o1.x, r0, c8
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
Float 0 [_PlanetRadiusKm]
Vector 1 [_ShadowAltitudesMinKm]
Vector 2 [_ShadowAltitudesMaxKm]
SetTexture 0 [_TexShadowMap] 2D
Float 3 [_SampleRadiusKm]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[5] = { program.local[0..3],
		{ 1, 3, 2 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.y, c[0].x;
ADDR  R0.y, -R0, c[3].x;
MOVR  R0.z, c[4].x;
SGERC HC.x, R0.y, c[2].w;
MOVR  R0.z(EQ.x), R0.x;
SLTRC HC.x, R0.y, c[2].w;
MOVR  R0.x, R0.z;
IF    NE.x;
MOVR  R1, c[2];
ADDR  R1, -R1, c[1];
ADDR  R2, R0.y, -c[2];
RCPR  R0.x, R1.y;
MULR_SAT R0.x, R2.y, R0;
MULR  R0.y, R0.x, R0.x;
MADR  R0.z, -R0.x, c[4], c[4].y;
RCPR  R0.x, R1.x;
MULR_SAT R1.y, R2.x, R0.x;
MULR  R1.x, R0.y, R0.z;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MADR  R1.x, R0.y, R1, -R1;
MADR  R0.y, -R1, c[4].z, c[4];
MULR  R1.y, R1, R1;
MULR  R0.y, R1, R0;
MADR  R0.x, R0, R0.y, -R0.y;
ADDR  R1.x, R1, c[4];
MADR  R0.x, R0, R1, R1;
RCPR  R1.x, R1.w;
RCPR  R0.y, R1.z;
MULR_SAT R1.y, R1.x, R2.w;
MULR_SAT R0.y, R0, R2.z;
MADR  R1.x, -R0.y, c[4].z, c[4].y;
MULR  R0.y, R0, R0;
MULR  R0.y, R0, R1.x;
MADR  R1.x, -R1.y, c[4].z, c[4].y;
MADR  R0.y, R0.z, R0, -R0;
MULR  R1.y, R1, R1;
MADR  R0.x, R0.y, R0, R0;
MULR  R1.x, R1.y, R1;
MADR  R0.y, R0.w, R1.x, -R1.x;
MADR  R0.x, R0.y, R0, R0;
ENDIF;
MOVR  oCol, R0.x;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_PlanetRadiusKm]
Vector 1 [_ShadowAltitudesMinKm]
Vector 2 [_ShadowAltitudesMaxKm]
SetTexture 0 [_TexShadowMap] 2D
Float 3 [_SampleRadiusKm]

"ps_3_0
dcl_2d s0
def c4, 0.00000000, 1.00000000, 2.00000000, 3.00000000
def c5, -1.00000000, 0, 0, 0
dcl_texcoord0 v0.xy
mov r0.y, c3.x
add r1.x, -c0, r0.y
add r0.y, r1.x, -c2.w
cmp_pp r0.z, r0.y, c4.x, c4.y
cmp r0.x, r0.y, c4.y, r0
if_gt r0.z, c4.x
mov r0.w, c1.x
add r1.y, -c2.x, r0.w
rcp r1.z, r1.y
add r1.y, r1.x, -c2.x
mul_sat r1.z, r1.y, r1
mad r1.w, -r1.z, c4.z, c4
mov r0.xy, v0
mov r0.z, c4.x
texldl r0, r0.xyzz, s0
add r1.y, r0.x, c5.x
mul r0.x, r1.z, r1.z
mov r1.z, c1.y
mul r0.x, r0, r1.w
mad r0.x, r0, r1.y, c4.y
add r1.z, -c2.y, r1
rcp r1.z, r1.z
add r1.y, r1.x, -c2
mul_sat r1.y, r1, r1.z
mad r1.z, -r1.y, c4, c4.w
mul r1.y, r1, r1
mul r1.z, r1.y, r1
add r0.y, r0, c5.x
mad r0.y, r1.z, r0, c4
mul r0.x, r0, r0.y
mov r1.y, c1.z
add r1.y, -c2.z, r1
add r0.y, r1.x, -c2.z
rcp r1.y, r1.y
mul_sat r1.y, r0, r1
add r0.y, r0.z, c5.x
mul r1.z, r1.y, r1.y
mad r1.y, -r1, c4.z, c4.w
mul r1.y, r1.z, r1
mad r0.y, r1, r0, c4
mov r0.z, c1.w
add r0.z, -c2.w, r0
rcp r1.y, r0.z
add r0.z, r1.x, -c2.w
mul_sat r0.z, r0, r1.y
add r1.x, r0.w, c5
mad r0.w, -r0.z, c4.z, c4
mul r0.z, r0, r0
mul r0.z, r0, r0.w
mad r0.z, r0, r1.x, c4.y
mul r0.x, r0, r0.y
mul r0.x, r0, r0.z
endif
mov oC0, r0.x

"
}

}

		}
	}
	Fallback off
}
