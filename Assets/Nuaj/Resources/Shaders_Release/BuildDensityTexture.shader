// We need to build the density texture via a shader since we must store floating point values and Unity doesn't allow it 
//
Shader "Hidden/Nuaj/AerialPerspective_BuildDensity"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
		_TexSourceScattering( "Base (RGB)", 2D ) = "black" {}
		_ZBuffer( "Base (RGB)", 2D ) = "black" {}
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
		// Pass #0 computes Scattering (RGB) and Extinction (A) in a single blow
		// The result is an extinction lacking a color component
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
Float 0 [_PlanetRadiusKm]
Float 1 [_PlanetAtmosphereRadiusKm]

"!!ARBfp1.0
OPTION NV_fragment_program2;
PARAM c[5] = { program.local[0..1],
		{ 2, 1, 2.718282, 0.83333331 },
		{ 0.12509382, 0, 0.03125, 0.5 },
		{ 32, 0, 1, 10000 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
MOVR  R0.x, c[0];
ADDR  R0.x, -R0, c[1];
MULR  R0.z, fragment.texcoord[0].y, R0.x;
ADDR  R1.x, R0.z, c[0];
MADR  R0.y, -fragment.texcoord[0].x, c[2].x, c[2];
MULR  R0.x, c[1], c[1];
MULR  R0.w, R0.y, R1.x;
MADR  R0.x, R1, R1, -R0;
MADR  R0.x, R0.w, R0.w, -R0;
RSQR  R0.x, R0.x;
RCPR  R1.y, R0.x;
ADDR  R1.w, R1.y, -R0;
MULR  R2.z, R1.w, c[3];
MADR  R0.x, -R0.y, R0.y, c[2].y;
RSQR  R0.x, R0.x;
RCPR  R0.x, R0.x;
MULR  R1.y, R0, R2.z;
MULR  R0.w, R0.x, R2.z;
MADR  R1.y, R1, c[3].w, R1.x;
MULR  R1.x, R0.w, c[3].w;
MULR  R0.w, -R0.z, c[2];
MULR  R0.z, -R0, c[3].x;
POWR  R0.w, c[2].z, R0.w;
POWR  R0.z, c[2].z, R0.z;
MOVR  R2.x, c[3].y;
MOVR  R2.y, c[3];
MOVR  R1.z, c[3].y;
LOOP c[4];
DP3R  R2.w, R1, R1;
RSQR  R2.w, R2.w;
RCPR  R2.w, R2.w;
ADDR  R2.w, R2, -c[0].x;
MAXR  R2.w, R2, c[3].y;
MULR  R3.x, -R2.w, c[3];
MULR  R2.w, -R2, c[2];
POWR  R3.x, c[2].z, R3.x;
POWR  R2.w, c[2].z, R2.w;
MADR  R1.xy, R2.z, R0, R1;
ADDR  R2.x, R2, R3;
ADDR  R2.y, R2, R2.w;
ENDLOOP;
MULR  R0.x, R1.w, R2.y;
MULR  R0.y, R1.w, R2.x;
MULR  R0.x, R0, c[3].z;
MULR  R0.y, R0, c[3].z;
MINR  oCol.w, R0.x, c[4];
MINR  oCol.z, R0.y, c[4].w;
MOVR  oCol.xy, R0.zwzw;
END

"
}
SubProgram "d3d9 " {
Keywords { }
Float 0 [_PlanetRadiusKm]
Float 1 [_PlanetAtmosphereRadiusKm]

"ps_3_0
def c2, 2.00000000, 1.00000000, 0.83333331, 2.71828198
def c3, 0.12509382, 0.00000000, 0.03125000, 0.50000000
defi i0, 32, 0, 1, 0
def c4, 10000.00000000, 0, 0, 0
dcl_texcoord0 v0.xy
mov r0.x, c1
add r0.x, -c0, r0
mul r1.x, v0.y, r0
mul r1.y, -r1.x, c2.z
pow r0, c2.w, r1.y
mul r1.y, -r1.x, c3.x
mov r3.w, r0.y
pow r0, c2.w, r1.y
mad r0.y, -v0.x, c2.x, c2
add r0.z, r1.x, c0.x
mul r0.w, c1.x, c1.x
mad r1.x, r0.z, r0.z, -r0.w
mul r0.w, r0.y, r0.z
mad r1.x, r0.w, r0.w, -r1
rsq r1.x, r1.x
rcp r1.x, r1.x
add r1.w, r1.x, -r0
mov r3.z, r0.x
mad r0.x, -r0.y, r0.y, c2.y
rsq r0.x, r0.x
mul r4.x, r1.w, c3.z
rcp r3.x, r0.x
mul r0.x, r0.y, r4
mul r0.w, r3.x, r4.x
mad r1.y, r0.x, c3.w, r0.z
mul r1.x, r0.w, c3.w
mov r3.y, r0
mov r4.y, c3
mov r4.z, c3.y
mov r1.z, c3.y
loop aL, i0
dp3 r0.x, r1, r1
rsq r0.x, r0.x
rcp r0.x, r0.x
add r0.x, r0, -c0
max r0.x, r0, c3.y
mul r0.y, -r0.x, c3.x
pow r2, c2.w, r0.y
mul r4.w, -r0.x, c2.z
pow r0, c2.w, r4.w
mov r0.y, r2.x
mad r1.xy, r4.x, r3, r1
add r4.y, r4, r0
add r4.z, r4, r0.x
endloop
mul r0.x, r1.w, r4.z
mul r0.y, r1.w, r4
mul r0.x, r0, c3.z
mul r0.y, r0, c3.z
min oC0.w, r0.x, c4.x
min oC0.z, r0.y, c4.x
mov oC0.xy, r3.zwzw

"
}

}

		}
	}
	Fallback off
}
