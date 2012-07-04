// This shader simply clears a render texture with either a solid color or another texture...
//
Shader "Nuaj/ClearTexture"
{
	Properties
	{
		_ClearTexture( "Base (RGB)", 2D ) = "black" {}
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
Float 0 [_bUseSolidColor]
Float 1 [_bInvertTextureAlpha]
Vector 2 [_ClearColor]
SetTexture 0 [_ClearTexture] 2D

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[4] = { program.local[0..2],
		{ 0, 1 } };
TEMP R0;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVXC RC.x, c[0];
MOVX  H0.x, c[3];
MOVR  oCol, c[2];
MOVH  H0.x(EQ), c[3].y;
MOVR  oCol(EQ.x), R0;
MOVXC RC.x, H0;
IF    NE.x;
TEX   R0, fragment.texcoord[0], texture[0], 2D;
MOVR  oCol.xyz, R0;
ADDR  oCol.w, -R0, c[3].y;
MOVXC RC.x, c[1];
MOVR  oCol(EQ.x), R0;
ENDIF;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_bUseSolidColor]
Float 1 [_bInvertTextureAlpha]
Vector 2 [_ClearColor]
SetTexture 0 [_ClearTexture] 2D

"ps_3_0
dcl_2d s0
def c3, 1.00000000, 0.00000000, 0, 0
dcl_texcoord0 v0.xyzw
mov_pp r2.x, c0
mov r1, c2
cmp_pp r2.x, -r2, c3, c3.y
cmp oC0, -c0.x, r0, r1
if_gt r2.x, c3.y
texldl r0, v0, s0
mov r1.xyz, r0
add r1.w, -r0, c3.x
abs_pp r2.x, c1
cmp oC0, -r2.x, r0, r1
endif

"
}

}

		}

		// Specific scattering/extinction clear
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

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[1] = { { 0.99414063, 46.21875, 0.67041016, 0.49975586 } };
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVH  oCol, c[0];
END

"
}
SubProgram "d3d9 " {
Keywords { }

"ps_3_0
def c0, 0.99414063, 46.21875000, 0.67041016, 0.49975586
mov_pp oC0, c0

"
}

}

		}

		// Pipo
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
Float 0 [_ValueIndex]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[2] = { program.local[0],
		{ 0, 1, 2 } };
TEMP R0;
SHORT TEMP H0;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
MOVH  oCol, c[1].yxxy;
MOVXC RC.x, c[0];
MOVH  oCol(NE.x), H0;
MOVR  R0.xyz, c[1];
SEQR  H0.xyz, c[0].x, R0;
SEQX  H0.xw, H0.xyzy, c[1].x;
MULXC HC.x, H0, H0.y;
MOVH  oCol(NE.x), c[1].xyxy;
MULX  H0.x, H0, H0.w;
MULXC HC.x, H0, H0.z;
MOVH  oCol(NE.x), c[1].xxyy;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_ValueIndex]

"ps_3_0
def c1, 1.00000000, 0.00000000, -1.00000000, -2.00000000
abs r1.x, c0
cmp_pp r0, -r1.x, c1.xyyx, r0
mov r1.x, c0
add r1.z, c1, r1.x
abs r1.y, c0.x
cmp r1.x, -r1.y, c1, c1.y
abs r1.y, r1.z
cmp r1.z, -r1.y, c1.x, c1.y
abs_pp r1.x, r1
cmp_pp r1.x, -r1, c1, c1.y
mul_pp r1.w, r1.x, r1.z
mov r1.y, c0.x
cmp_pp r0, -r1.w, r0, c1.yxyx
add r1.w, c1, r1.y
abs_pp r1.y, r1.z
abs r1.z, r1.w
cmp_pp r1.y, -r1, c1.x, c1
cmp r1.z, -r1, c1.x, c1.y
mul_pp r1.x, r1, r1.y
mul_pp r1.x, r1, r1.z
cmp_pp oC0, -r1.x, r0, c1.yyxx

"
}

}

		}
	}
	Fallback off
}
