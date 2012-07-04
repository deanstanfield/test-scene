// This shader upscales the downscaled sky that is not interpolable because of color packing
//
Shader "Hidden/Nuaj/AerialPerspective_BuildDensity"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
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
# cgc version 3.0.0016, build date Feb 11 2011
# command line args: -profile vp40 -IC:\Program Files (x86)\Unity\Editor\Data\CGIncludes -DUNITY_MATRIX_MVP=glstate.matrix.mvp -DUNITY_MATRIX_TEXTURE0=glstate.matrix.texture[0] -DUNITY_MATRIX_P=glstate.matrix.projection -DTARGET_MAC=1 -fastmath -glslWerror -strict
# source file: C:\UNITY\Project\Qlaud\Assets\Nuaj\Resources\Shaders\Sky\SkyUpScale.cg
#vendor NVIDIA Corporation
#version 3.0.0.16
#profile vp40
#program VS
#semantic glstate : state
#semantic _Time
#semantic _SinTime
#semantic _CosTime
#semantic _ProjectionParams
#semantic _ScreenParams
#semantic unity_Scale
#semantic _WorldSpaceCameraPos
#semantic _WorldSpaceLightPos0
#semantic _Object2World
#semantic _World2Object
#semantic _LightPositionRange
#semantic unity_4LightPosX0
#semantic unity_4LightPosY0
#semantic unity_4LightPosZ0
#semantic unity_4LightAtten0
#semantic unity_LightColor
#semantic unity_LightPosition
#semantic unity_LightAtten
#semantic unity_LightColor0
#semantic unity_LightColor1
#semantic unity_LightColor2
#semantic unity_LightColor3
#semantic unity_SHAr
#semantic unity_SHAg
#semantic unity_SHAb
#semantic unity_SHBr
#semantic unity_SHBg
#semantic unity_SHBb
#semantic unity_SHC
#semantic _ZBufferParams
#semantic unity_LightShadowBias
#semantic _CameraData
#semantic _Camera2World
#semantic _World2Camera
#semantic _CameraDepthTexture
#semantic _MainTex
#semantic _dUV
#semantic _TargetdUV
#var float4 glstate.material.ambient : state.material.ambient :  : -1 : 0
#var float4 glstate.material.diffuse : state.material.diffuse :  : -1 : 0
#var float4 glstate.material.specular : state.material.specular :  : -1 : 0
#var float4 glstate.material.emission : state.material.emission :  : -1 : 0
#var float4 glstate.material.shininess : state.material.shininess :  : -1 : 0
#var float4 glstate.material.front.ambient : state.material.front.ambient :  : -1 : 0
#var float4 glstate.material.front.diffuse : state.material.front.diffuse :  : -1 : 0
#var float4 glstate.material.front.specular : state.material.front.specular :  : -1 : 0
#var float4 glstate.material.front.emission : state.material.front.emission :  : -1 : 0
#var float4 glstate.material.front.shininess : state.material.front.shininess :  : -1 : 0
#var float4 glstate.material.back.ambient : state.material.back.ambient :  : -1 : 0
#var float4 glstate.material.back.diffuse : state.material.back.diffuse :  : -1 : 0
#var float4 glstate.material.back.specular : state.material.back.specular :  : -1 : 0
#var float4 glstate.material.back.emission : state.material.back.emission :  : -1 : 0
#var float4 glstate.material.back.shininess : state.material.back.shininess :  : -1 : 0
#var float4 glstate.light[0].ambient : state.light[0].ambient :  : -1 : 0
#var float4 glstate.light[0].diffuse : state.light[0].diffuse :  : -1 : 0
#var float4 glstate.light[0].specular : state.light[0].specular :  : -1 : 0
#var float4 glstate.light[0].position : state.light[0].position :  : -1 : 0
#var float4 glstate.light[0].attenuation : state.light[0].attenuation :  : -1 : 0
#var float4 glstate.light[0].spot.direction : state.light[0].spot.direction :  : -1 : 0
#var float4 glstate.light[0].half : state.light[0].half :  : -1 : 0
#var float4 glstate.light[1].ambient : state.light[1].ambient :  : -1 : 0
#var float4 glstate.light[1].diffuse : state.light[1].diffuse :  : -1 : 0
#var float4 glstate.light[1].specular : state.light[1].specular :  : -1 : 0
#var float4 glstate.light[1].position : state.light[1].position :  : -1 : 0
#var float4 glstate.light[1].attenuation : state.light[1].attenuation :  : -1 : 0
#var float4 glstate.light[1].spot.direction : state.light[1].spot.direction :  : -1 : 0
#var float4 glstate.light[1].half : state.light[1].half :  : -1 : 0
#var float4 glstate.light[2].ambient : state.light[2].ambient :  : -1 : 0
#var float4 glstate.light[2].diffuse : state.light[2].diffuse :  : -1 : 0
#var float4 glstate.light[2].specular : state.light[2].specular :  : -1 : 0
#var float4 glstate.light[2].position : state.light[2].position :  : -1 : 0
#var float4 glstate.light[2].attenuation : state.light[2].attenuation :  : -1 : 0
#var float4 glstate.light[2].spot.direction : state.light[2].spot.direction :  : -1 : 0
#var float4 glstate.light[2].half : state.light[2].half :  : -1 : 0
#var float4 glstate.light[3].ambient : state.light[3].ambient :  : -1 : 0
#var float4 glstate.light[3].diffuse : state.light[3].diffuse :  : -1 : 0
#var float4 glstate.light[3].specular : state.light[3].specular :  : -1 : 0
#var float4 glstate.light[3].position : state.light[3].position :  : -1 : 0
#var float4 glstate.light[3].attenuation : state.light[3].attenuation :  : -1 : 0
#var float4 glstate.light[3].spot.direction : state.light[3].spot.direction :  : -1 : 0
#var float4 glstate.light[3].half : state.light[3].half :  : -1 : 0
#var float4 glstate.light[4].ambient : state.light[4].ambient :  : -1 : 0
#var float4 glstate.light[4].diffuse : state.light[4].diffuse :  : -1 : 0
#var float4 glstate.light[4].specular : state.light[4].specular :  : -1 : 0
#var float4 glstate.light[4].position : state.light[4].position :  : -1 : 0
#var float4 glstate.light[4].attenuation : state.light[4].attenuation :  : -1 : 0
#var float4 glstate.light[4].spot.direction : state.light[4].spot.direction :  : -1 : 0
#var float4 glstate.light[4].half : state.light[4].half :  : -1 : 0
#var float4 glstate.light[5].ambient : state.light[5].ambient :  : -1 : 0
#var float4 glstate.light[5].diffuse : state.light[5].diffuse :  : -1 : 0
#var float4 glstate.light[5].specular : state.light[5].specular :  : -1 : 0
#var float4 glstate.light[5].position : state.light[5].position :  : -1 : 0
#var float4 glstate.light[5].attenuation : state.light[5].attenuation :  : -1 : 0
#var float4 glstate.light[5].spot.direction : state.light[5].spot.direction :  : -1 : 0
#var float4 glstate.light[5].half : state.light[5].half :  : -1 : 0
#var float4 glstate.light[6].ambient : state.light[6].ambient :  : -1 : 0
#var float4 glstate.light[6].diffuse : state.light[6].diffuse :  : -1 : 0
#var float4 glstate.light[6].specular : state.light[6].specular :  : -1 : 0
#var float4 glstate.light[6].position : state.light[6].position :  : -1 : 0
#var float4 glstate.light[6].attenuation : state.light[6].attenuation :  : -1 : 0
#var float4 glstate.light[6].spot.direction : state.light[6].spot.direction :  : -1 : 0
#var float4 glstate.light[6].half : state.light[6].half :  : -1 : 0
#var float4 glstate.light[7].ambient : state.light[7].ambient :  : -1 : 0
#var float4 glstate.light[7].diffuse : state.light[7].diffuse :  : -1 : 0
#var float4 glstate.light[7].specular : state.light[7].specular :  : -1 : 0
#var float4 glstate.light[7].position : state.light[7].position :  : -1 : 0
#var float4 glstate.light[7].attenuation : state.light[7].attenuation :  : -1 : 0
#var float4 glstate.light[7].spot.direction : state.light[7].spot.direction :  : -1 : 0
#var float4 glstate.light[7].half : state.light[7].half :  : -1 : 0
#var float4 glstate.lightmodel.ambient : state.lightmodel.ambient :  : -1 : 0
#var float4 glstate.lightmodel.scenecolor : state.lightmodel.scenecolor :  : -1 : 0
#var float4 glstate.lightmodel.front.scenecolor : state.lightmodel.front.scenecolor :  : -1 : 0
#var float4 glstate.lightmodel.back.scenecolor : state.lightmodel.back.scenecolor :  : -1 : 0
#var float4 glstate.lightprod[0].ambient : state.lightprod[0].ambient :  : -1 : 0
#var float4 glstate.lightprod[0].diffuse : state.lightprod[0].diffuse :  : -1 : 0
#var float4 glstate.lightprod[0].specular : state.lightprod[0].specular :  : -1 : 0
#var float4 glstate.lightprod[0].front.ambient : state.lightprod[0].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[0].front.diffuse : state.lightprod[0].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[0].front.specular : state.lightprod[0].front.specular :  : -1 : 0
#var float4 glstate.lightprod[0].back.ambient : state.lightprod[0].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[0].back.diffuse : state.lightprod[0].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[0].back.specular : state.lightprod[0].back.specular :  : -1 : 0
#var float4 glstate.lightprod[1].ambient : state.lightprod[1].ambient :  : -1 : 0
#var float4 glstate.lightprod[1].diffuse : state.lightprod[1].diffuse :  : -1 : 0
#var float4 glstate.lightprod[1].specular : state.lightprod[1].specular :  : -1 : 0
#var float4 glstate.lightprod[1].front.ambient : state.lightprod[1].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[1].front.diffuse : state.lightprod[1].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[1].front.specular : state.lightprod[1].front.specular :  : -1 : 0
#var float4 glstate.lightprod[1].back.ambient : state.lightprod[1].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[1].back.diffuse : state.lightprod[1].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[1].back.specular : state.lightprod[1].back.specular :  : -1 : 0
#var float4 glstate.lightprod[2].ambient : state.lightprod[2].ambient :  : -1 : 0
#var float4 glstate.lightprod[2].diffuse : state.lightprod[2].diffuse :  : -1 : 0
#var float4 glstate.lightprod[2].specular : state.lightprod[2].specular :  : -1 : 0
#var float4 glstate.lightprod[2].front.ambient : state.lightprod[2].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[2].front.diffuse : state.lightprod[2].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[2].front.specular : state.lightprod[2].front.specular :  : -1 : 0
#var float4 glstate.lightprod[2].back.ambient : state.lightprod[2].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[2].back.diffuse : state.lightprod[2].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[2].back.specular : state.lightprod[2].back.specular :  : -1 : 0
#var float4 glstate.lightprod[3].ambient : state.lightprod[3].ambient :  : -1 : 0
#var float4 glstate.lightprod[3].diffuse : state.lightprod[3].diffuse :  : -1 : 0
#var float4 glstate.lightprod[3].specular : state.lightprod[3].specular :  : -1 : 0
#var float4 glstate.lightprod[3].front.ambient : state.lightprod[3].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[3].front.diffuse : state.lightprod[3].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[3].front.specular : state.lightprod[3].front.specular :  : -1 : 0
#var float4 glstate.lightprod[3].back.ambient : state.lightprod[3].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[3].back.diffuse : state.lightprod[3].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[3].back.specular : state.lightprod[3].back.specular :  : -1 : 0
#var float4 glstate.lightprod[4].ambient : state.lightprod[4].ambient :  : -1 : 0
#var float4 glstate.lightprod[4].diffuse : state.lightprod[4].diffuse :  : -1 : 0
#var float4 glstate.lightprod[4].specular : state.lightprod[4].specular :  : -1 : 0
#var float4 glstate.lightprod[4].front.ambient : state.lightprod[4].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[4].front.diffuse : state.lightprod[4].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[4].front.specular : state.lightprod[4].front.specular :  : -1 : 0
#var float4 glstate.lightprod[4].back.ambient : state.lightprod[4].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[4].back.diffuse : state.lightprod[4].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[4].back.specular : state.lightprod[4].back.specular :  : -1 : 0
#var float4 glstate.lightprod[5].ambient : state.lightprod[5].ambient :  : -1 : 0
#var float4 glstate.lightprod[5].diffuse : state.lightprod[5].diffuse :  : -1 : 0
#var float4 glstate.lightprod[5].specular : state.lightprod[5].specular :  : -1 : 0
#var float4 glstate.lightprod[5].front.ambient : state.lightprod[5].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[5].front.diffuse : state.lightprod[5].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[5].front.specular : state.lightprod[5].front.specular :  : -1 : 0
#var float4 glstate.lightprod[5].back.ambient : state.lightprod[5].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[5].back.diffuse : state.lightprod[5].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[5].back.specular : state.lightprod[5].back.specular :  : -1 : 0
#var float4 glstate.lightprod[6].ambient : state.lightprod[6].ambient :  : -1 : 0
#var float4 glstate.lightprod[6].diffuse : state.lightprod[6].diffuse :  : -1 : 0
#var float4 glstate.lightprod[6].specular : state.lightprod[6].specular :  : -1 : 0
#var float4 glstate.lightprod[6].front.ambient : state.lightprod[6].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[6].front.diffuse : state.lightprod[6].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[6].front.specular : state.lightprod[6].front.specular :  : -1 : 0
#var float4 glstate.lightprod[6].back.ambient : state.lightprod[6].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[6].back.diffuse : state.lightprod[6].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[6].back.specular : state.lightprod[6].back.specular :  : -1 : 0
#var float4 glstate.lightprod[7].ambient : state.lightprod[7].ambient :  : -1 : 0
#var float4 glstate.lightprod[7].diffuse : state.lightprod[7].diffuse :  : -1 : 0
#var float4 glstate.lightprod[7].specular : state.lightprod[7].specular :  : -1 : 0
#var float4 glstate.lightprod[7].front.ambient : state.lightprod[7].front.ambient :  : -1 : 0
#var float4 glstate.lightprod[7].front.diffuse : state.lightprod[7].front.diffuse :  : -1 : 0
#var float4 glstate.lightprod[7].front.specular : state.lightprod[7].front.specular :  : -1 : 0
#var float4 glstate.lightprod[7].back.ambient : state.lightprod[7].back.ambient :  : -1 : 0
#var float4 glstate.lightprod[7].back.diffuse : state.lightprod[7].back.diffuse :  : -1 : 0
#var float4 glstate.lightprod[7].back.specular : state.lightprod[7].back.specular :  : -1 : 0
#var float4 glstate.texgen[0].eye.s : state.texgen[0].eye.s :  : -1 : 0
#var float4 glstate.texgen[0].eye.t : state.texgen[0].eye.t :  : -1 : 0
#var float4 glstate.texgen[0].eye.r : state.texgen[0].eye.r :  : -1 : 0
#var float4 glstate.texgen[0].eye.q : state.texgen[0].eye.q :  : -1 : 0
#var float4 glstate.texgen[0].object.s : state.texgen[0].object.s :  : -1 : 0
#var float4 glstate.texgen[0].object.t : state.texgen[0].object.t :  : -1 : 0
#var float4 glstate.texgen[0].object.r : state.texgen[0].object.r :  : -1 : 0
#var float4 glstate.texgen[0].object.q : state.texgen[0].object.q :  : -1 : 0
#var float4 glstate.texgen[1].eye.s : state.texgen[1].eye.s :  : -1 : 0
#var float4 glstate.texgen[1].eye.t : state.texgen[1].eye.t :  : -1 : 0
#var float4 glstate.texgen[1].eye.r : state.texgen[1].eye.r :  : -1 : 0
#var float4 glstate.texgen[1].eye.q : state.texgen[1].eye.q :  : -1 : 0
#var float4 glstate.texgen[1].object.s : state.texgen[1].object.s :  : -1 : 0
#var float4 glstate.texgen[1].object.t : state.texgen[1].object.t :  : -1 : 0
#var float4 glstate.texgen[1].object.r : state.texgen[1].object.r :  : -1 : 0
#var float4 glstate.texgen[1].object.q : state.texgen[1].object.q :  : -1 : 0
#var float4 glstate.texgen[2].eye.s : state.texgen[2].eye.s :  : -1 : 0
#var float4 glstate.texgen[2].eye.t : state.texgen[2].eye.t :  : -1 : 0
#var float4 glstate.texgen[2].eye.r : state.texgen[2].eye.r :  : -1 : 0
#var float4 glstate.texgen[2].eye.q : state.texgen[2].eye.q :  : -1 : 0
#var float4 glstate.texgen[2].object.s : state.texgen[2].object.s :  : -1 : 0
#var float4 glstate.texgen[2].object.t : state.texgen[2].object.t :  : -1 : 0
#var float4 glstate.texgen[2].object.r : state.texgen[2].object.r :  : -1 : 0
#var float4 glstate.texgen[2].object.q : state.texgen[2].object.q :  : -1 : 0
#var float4 glstate.texgen[3].eye.s : state.texgen[3].eye.s :  : -1 : 0
#var float4 glstate.texgen[3].eye.t : state.texgen[3].eye.t :  : -1 : 0
#var float4 glstate.texgen[3].eye.r : state.texgen[3].eye.r :  : -1 : 0
#var float4 glstate.texgen[3].eye.q : state.texgen[3].eye.q :  : -1 : 0
#var float4 glstate.texgen[3].object.s : state.texgen[3].object.s :  : -1 : 0
#var float4 glstate.texgen[3].object.t : state.texgen[3].object.t :  : -1 : 0
#var float4 glstate.texgen[3].object.r : state.texgen[3].object.r :  : -1 : 0
#var float4 glstate.texgen[3].object.q : state.texgen[3].object.q :  : -1 : 0
#var float4 glstate.texgen[4].eye.s : state.texgen[4].eye.s :  : -1 : 0
#var float4 glstate.texgen[4].eye.t : state.texgen[4].eye.t :  : -1 : 0
#var float4 glstate.texgen[4].eye.r : state.texgen[4].eye.r :  : -1 : 0
#var float4 glstate.texgen[4].eye.q : state.texgen[4].eye.q :  : -1 : 0
#var float4 glstate.texgen[4].object.s : state.texgen[4].object.s :  : -1 : 0
#var float4 glstate.texgen[4].object.t : state.texgen[4].object.t :  : -1 : 0
#var float4 glstate.texgen[4].object.r : state.texgen[4].object.r :  : -1 : 0
#var float4 glstate.texgen[4].object.q : state.texgen[4].object.q :  : -1 : 0
#var float4 glstate.texgen[5].eye.s : state.texgen[5].eye.s :  : -1 : 0
#var float4 glstate.texgen[5].eye.t : state.texgen[5].eye.t :  : -1 : 0
#var float4 glstate.texgen[5].eye.r : state.texgen[5].eye.r :  : -1 : 0
#var float4 glstate.texgen[5].eye.q : state.texgen[5].eye.q :  : -1 : 0
#var float4 glstate.texgen[5].object.s : state.texgen[5].object.s :  : -1 : 0
#var float4 glstate.texgen[5].object.t : state.texgen[5].object.t :  : -1 : 0
#var float4 glstate.texgen[5].object.r : state.texgen[5].object.r :  : -1 : 0
#var float4 glstate.texgen[5].object.q : state.texgen[5].object.q :  : -1 : 0
#var float4 glstate.texgen[6].eye.s : state.texgen[6].eye.s :  : -1 : 0
#var float4 glstate.texgen[6].eye.t : state.texgen[6].eye.t :  : -1 : 0
#var float4 glstate.texgen[6].eye.r : state.texgen[6].eye.r :  : -1 : 0
#var float4 glstate.texgen[6].eye.q : state.texgen[6].eye.q :  : -1 : 0
#var float4 glstate.texgen[6].object.s : state.texgen[6].object.s :  : -1 : 0
#var float4 glstate.texgen[6].object.t : state.texgen[6].object.t :  : -1 : 0
#var float4 glstate.texgen[6].object.r : state.texgen[6].object.r :  : -1 : 0
#var float4 glstate.texgen[6].object.q : state.texgen[6].object.q :  : -1 : 0
#var float4 glstate.texgen[7].eye.s : state.texgen[7].eye.s :  : -1 : 0
#var float4 glstate.texgen[7].eye.t : state.texgen[7].eye.t :  : -1 : 0
#var float4 glstate.texgen[7].eye.r : state.texgen[7].eye.r :  : -1 : 0
#var float4 glstate.texgen[7].eye.q : state.texgen[7].eye.q :  : -1 : 0
#var float4 glstate.texgen[7].object.s : state.texgen[7].object.s :  : -1 : 0
#var float4 glstate.texgen[7].object.t : state.texgen[7].object.t :  : -1 : 0
#var float4 glstate.texgen[7].object.r : state.texgen[7].object.r :  : -1 : 0
#var float4 glstate.texgen[7].object.q : state.texgen[7].object.q :  : -1 : 0
#var float4 glstate.fog.color : state.fog.color :  : -1 : 0
#var float4 glstate.fog.params : state.fog.params :  : -1 : 0
#var float4 glstate.clip[0].plane : state.clip[0].plane :  : -1 : 0
#var float4 glstate.clip[1].plane : state.clip[1].plane :  : -1 : 0
#var float4 glstate.clip[2].plane : state.clip[2].plane :  : -1 : 0
#var float4 glstate.clip[3].plane : state.clip[3].plane :  : -1 : 0
#var float4 glstate.clip[4].plane : state.clip[4].plane :  : -1 : 0
#var float4 glstate.clip[5].plane : state.clip[5].plane :  : -1 : 0
#var float4 glstate.clip[6].plane : state.clip[6].plane :  : -1 : 0
#var float4 glstate.clip[7].plane : state.clip[7].plane :  : -1 : 0
#var float glstate.point.size : state.point.size :  : -1 : 0
#var float glstate.point.attenuation : state.point.attenuation :  : -1 : 0
#var float4x4 glstate.matrix.modelview[0] : state.matrix.modelview[0] : , 4 : -1 : 0
#var float4x4 glstate.matrix.modelview[1] : state.matrix.modelview[1] : , 4 : -1 : 0
#var float4x4 glstate.matrix.modelview[2] : state.matrix.modelview[2] : , 4 : -1 : 0
#var float4x4 glstate.matrix.modelview[3] : state.matrix.modelview[3] : , 4 : -1 : 0
#var float4x4 glstate.matrix.modelview[4] : state.matrix.modelview[4] : , 4 : -1 : 0
#var float4x4 glstate.matrix.modelview[5] : state.matrix.modelview[5] : , 4 : -1 : 0
#var float4x4 glstate.matrix.modelview[6] : state.matrix.modelview[6] : , 4 : -1 : 0
#var float4x4 glstate.matrix.modelview[7] : state.matrix.modelview[7] : , 4 : -1 : 0
#var float4x4 glstate.matrix.projection : state.matrix.projection : , 4 : -1 : 0
#var float4x4 glstate.matrix.mvp : state.matrix.mvp : c[0], 4 : -1 : 1
#var float4x4 glstate.matrix.texture[0] : state.matrix.texture[0] : c[4], 4 : -1 : 1
#var float4x4 glstate.matrix.texture[1] : state.matrix.texture[1] : , 4 : -1 : 0
#var float4x4 glstate.matrix.texture[2] : state.matrix.texture[2] : , 4 : -1 : 0
#var float4x4 glstate.matrix.texture[3] : state.matrix.texture[3] : , 4 : -1 : 0
#var float4x4 glstate.matrix.texture[4] : state.matrix.texture[4] : , 4 : -1 : 0
#var float4x4 glstate.matrix.texture[5] : state.matrix.texture[5] : , 4 : -1 : 0
#var float4x4 glstate.matrix.texture[6] : state.matrix.texture[6] : , 4 : -1 : 0
#var float4x4 glstate.matrix.texture[7] : state.matrix.texture[7] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[0] : state.matrix.palette[0] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[1] : state.matrix.palette[1] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[2] : state.matrix.palette[2] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[3] : state.matrix.palette[3] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[4] : state.matrix.palette[4] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[5] : state.matrix.palette[5] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[6] : state.matrix.palette[6] : , 4 : -1 : 0
#var float4x4 glstate.matrix.palette[7] : state.matrix.palette[7] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[0] : state.matrix.program[0] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[1] : state.matrix.program[1] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[2] : state.matrix.program[2] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[3] : state.matrix.program[3] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[4] : state.matrix.program[4] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[5] : state.matrix.program[5] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[6] : state.matrix.program[6] : , 4 : -1 : 0
#var float4x4 glstate.matrix.program[7] : state.matrix.program[7] : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[0] : state.matrix.modelview[0].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[1] : state.matrix.modelview[1].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[2] : state.matrix.modelview[2].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[3] : state.matrix.modelview[3].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[4] : state.matrix.modelview[4].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[5] : state.matrix.modelview[5].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[6] : state.matrix.modelview[6].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.modelview[7] : state.matrix.modelview[7].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.projection : state.matrix.projection.inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.mvp : state.matrix.mvp.inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[0] : state.matrix.texture[0].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[1] : state.matrix.texture[1].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[2] : state.matrix.texture[2].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[3] : state.matrix.texture[3].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[4] : state.matrix.texture[4].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[5] : state.matrix.texture[5].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[6] : state.matrix.texture[6].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.texture[7] : state.matrix.texture[7].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[0] : state.matrix.palette[0].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[1] : state.matrix.palette[1].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[2] : state.matrix.palette[2].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[3] : state.matrix.palette[3].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[4] : state.matrix.palette[4].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[5] : state.matrix.palette[5].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[6] : state.matrix.palette[6].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.palette[7] : state.matrix.palette[7].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[0] : state.matrix.program[0].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[1] : state.matrix.program[1].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[2] : state.matrix.program[2].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[3] : state.matrix.program[3].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[4] : state.matrix.program[4].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[5] : state.matrix.program[5].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[6] : state.matrix.program[6].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.inverse.program[7] : state.matrix.program[7].inverse : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[0] : state.matrix.modelview[0].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[1] : state.matrix.modelview[1].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[2] : state.matrix.modelview[2].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[3] : state.matrix.modelview[3].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[4] : state.matrix.modelview[4].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[5] : state.matrix.modelview[5].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[6] : state.matrix.modelview[6].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.modelview[7] : state.matrix.modelview[7].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.projection : state.matrix.projection.transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.mvp : state.matrix.mvp.transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[0] : state.matrix.texture[0].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[1] : state.matrix.texture[1].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[2] : state.matrix.texture[2].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[3] : state.matrix.texture[3].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[4] : state.matrix.texture[4].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[5] : state.matrix.texture[5].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[6] : state.matrix.texture[6].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.texture[7] : state.matrix.texture[7].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[0] : state.matrix.palette[0].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[1] : state.matrix.palette[1].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[2] : state.matrix.palette[2].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[3] : state.matrix.palette[3].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[4] : state.matrix.palette[4].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[5] : state.matrix.palette[5].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[6] : state.matrix.palette[6].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.palette[7] : state.matrix.palette[7].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[0] : state.matrix.program[0].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[1] : state.matrix.program[1].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[2] : state.matrix.program[2].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[3] : state.matrix.program[3].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[4] : state.matrix.program[4].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[5] : state.matrix.program[5].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[6] : state.matrix.program[6].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.transpose.program[7] : state.matrix.program[7].transpose : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[0] : state.matrix.modelview[0].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[1] : state.matrix.modelview[1].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[2] : state.matrix.modelview[2].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[3] : state.matrix.modelview[3].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[4] : state.matrix.modelview[4].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[5] : state.matrix.modelview[5].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[6] : state.matrix.modelview[6].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.modelview[7] : state.matrix.modelview[7].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.projection : state.matrix.projection.invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.mvp : state.matrix.mvp.invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[0] : state.matrix.texture[0].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[1] : state.matrix.texture[1].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[2] : state.matrix.texture[2].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[3] : state.matrix.texture[3].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[4] : state.matrix.texture[4].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[5] : state.matrix.texture[5].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[6] : state.matrix.texture[6].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.texture[7] : state.matrix.texture[7].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[0] : state.matrix.palette[0].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[1] : state.matrix.palette[1].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[2] : state.matrix.palette[2].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[3] : state.matrix.palette[3].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[4] : state.matrix.palette[4].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[5] : state.matrix.palette[5].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[6] : state.matrix.palette[6].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.palette[7] : state.matrix.palette[7].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[0] : state.matrix.program[0].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[1] : state.matrix.program[1].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[2] : state.matrix.program[2].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[3] : state.matrix.program[3].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[4] : state.matrix.program[4].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[5] : state.matrix.program[5].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[6] : state.matrix.program[6].invtrans : , 4 : -1 : 0
#var float4x4 glstate.matrix.invtrans.program[7] : state.matrix.program[7].invtrans : , 4 : -1 : 0
#var float4 _In.vertex : $vin.POSITION : POSITION : 0 : 1
#var float2 _In.texcoord : $vin.TEXCOORD0 : TEXCOORD0 : 0 : 1
#var float4 _Time :  :  : -1 : 0
#var float4 _SinTime :  :  : -1 : 0
#var float4 _CosTime :  :  : -1 : 0
#var float4 _ProjectionParams :  :  : -1 : 0
#var float4 _ScreenParams :  :  : -1 : 0
#var float4 unity_Scale :  :  : -1 : 0
#var float3 _WorldSpaceCameraPos :  :  : -1 : 0
#var float4 _WorldSpaceLightPos0 :  :  : -1 : 0
#var float4x4 _Object2World :  : , 4 : -1 : 0
#var float4x4 _World2Object :  : , 4 : -1 : 0
#var float4 _LightPositionRange :  :  : -1 : 0
#var float4 unity_4LightPosX0 :  :  : -1 : 0
#var float4 unity_4LightPosY0 :  :  : -1 : 0
#var float4 unity_4LightPosZ0 :  :  : -1 : 0
#var float4 unity_4LightAtten0 :  :  : -1 : 0
#var float4 unity_LightColor[0] :  :  : -1 : 0
#var float4 unity_LightColor[1] :  :  : -1 : 0
#var float4 unity_LightColor[2] :  :  : -1 : 0
#var float4 unity_LightColor[3] :  :  : -1 : 0
#var float4 unity_LightPosition[0] :  :  : -1 : 0
#var float4 unity_LightPosition[1] :  :  : -1 : 0
#var float4 unity_LightPosition[2] :  :  : -1 : 0
#var float4 unity_LightPosition[3] :  :  : -1 : 0
#var float4 unity_LightAtten[0] :  :  : -1 : 0
#var float4 unity_LightAtten[1] :  :  : -1 : 0
#var float4 unity_LightAtten[2] :  :  : -1 : 0
#var float4 unity_LightAtten[3] :  :  : -1 : 0
#var float3 unity_LightColor0 :  :  : -1 : 0
#var float3 unity_LightColor1 :  :  : -1 : 0
#var float3 unity_LightColor2 :  :  : -1 : 0
#var float3 unity_LightColor3 :  :  : -1 : 0
#var float4 unity_SHAr :  :  : -1 : 0
#var float4 unity_SHAg :  :  : -1 : 0
#var float4 unity_SHAb :  :  : -1 : 0
#var float4 unity_SHBr :  :  : -1 : 0
#var float4 unity_SHBg :  :  : -1 : 0
#var float4 unity_SHBb :  :  : -1 : 0
#var float4 unity_SHC :  :  : -1 : 0
#var float4 _ZBufferParams :  :  : -1 : 0
#var float4 unity_LightShadowBias :  :  : -1 : 0
#var float4 _CameraData :  :  : -1 : 0
#var float4x4 _Camera2World :  : , 4 : -1 : 0
#var float4x4 _World2Camera :  : , 4 : -1 : 0
#var sampler2D _CameraDepthTexture :  :  : -1 : 0
#var sampler2D _MainTex :  :  : -1 : 0
#var float4 _dUV :  :  : -1 : 0
#var float4 _TargetdUV :  :  : -1 : 0
#var float4 VS.Position : $vout.POSITION : HPOS : -1 : 1
#var float4 VS.UV : $vout.TEXCOORD0 : TEX0 : -1 : 1
#const c[8] = 0
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
# 9 instructions, 1 R-regs

"
}
SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Matrix 4 [glstate_matrix_texture0]
"vs_3_0
// cgc version 3.0.0016, build date Feb 11 2011
// command line args: -profile vs_3_0 -IC:\Program Files (x86)\Unity\Editor\Data\CGIncludes -DUNITY_MATRIX_MVP=glstate.matrix.mvp -DUNITY_MATRIX_TEXTURE0=glstate.matrix.texture[0] -DUNITY_MATRIX_P=glstate.matrix.projection -fastmath -glslWerror -strict
// source file: C:\UNITY\Project\Qlaud\Assets\Nuaj\Resources\Shaders\Sky\SkyUpScale.cg
//vendor NVIDIA Corporation
//version 3.0.0.16
//profile vs_3_0
//program VS
//semantic glstate : state
//semantic _Time
//semantic _SinTime
//semantic _CosTime
//semantic _ProjectionParams
//semantic _ScreenParams
//semantic unity_Scale
//semantic _WorldSpaceCameraPos
//semantic _WorldSpaceLightPos0
//semantic _Object2World
//semantic _World2Object
//semantic _LightPositionRange
//semantic unity_4LightPosX0
//semantic unity_4LightPosY0
//semantic unity_4LightPosZ0
//semantic unity_4LightAtten0
//semantic unity_LightColor
//semantic unity_LightPosition
//semantic unity_LightAtten
//semantic unity_LightColor0
//semantic unity_LightColor1
//semantic unity_LightColor2
//semantic unity_LightColor3
//semantic unity_SHAr
//semantic unity_SHAg
//semantic unity_SHAb
//semantic unity_SHBr
//semantic unity_SHBg
//semantic unity_SHBb
//semantic unity_SHC
//semantic _ZBufferParams
//semantic unity_LightShadowBias
//semantic _CameraData
//semantic _Camera2World
//semantic _World2Camera
//semantic _CameraDepthTexture
//semantic _MainTex
//semantic _dUV
//semantic _TargetdUV
//var float4 glstate.material.ambient : state.material.ambient :  : -1 : 0
//var float4 glstate.material.diffuse : state.material.diffuse :  : -1 : 0
//var float4 glstate.material.specular : state.material.specular :  : -1 : 0
//var float4 glstate.material.emission : state.material.emission :  : -1 : 0
//var float4 glstate.material.shininess : state.material.shininess :  : -1 : 0
//var float4 glstate.material.front.ambient : state.material.front.ambient :  : -1 : 0
//var float4 glstate.material.front.diffuse : state.material.front.diffuse :  : -1 : 0
//var float4 glstate.material.front.specular : state.material.front.specular :  : -1 : 0
//var float4 glstate.material.front.emission : state.material.front.emission :  : -1 : 0
//var float4 glstate.material.front.shininess : state.material.front.shininess :  : -1 : 0
//var float4 glstate.material.back.ambient : state.material.back.ambient :  : -1 : 0
//var float4 glstate.material.back.diffuse : state.material.back.diffuse :  : -1 : 0
//var float4 glstate.material.back.specular : state.material.back.specular :  : -1 : 0
//var float4 glstate.material.back.emission : state.material.back.emission :  : -1 : 0
//var float4 glstate.material.back.shininess : state.material.back.shininess :  : -1 : 0
//var float4 glstate.light[0].ambient : state.light[0].ambient :  : -1 : 0
//var float4 glstate.light[0].diffuse : state.light[0].diffuse :  : -1 : 0
//var float4 glstate.light[0].specular : state.light[0].specular :  : -1 : 0
//var float4 glstate.light[0].position : state.light[0].position :  : -1 : 0
//var float4 glstate.light[0].attenuation : state.light[0].attenuation :  : -1 : 0
//var float4 glstate.light[0].spot.direction : state.light[0].spot.direction :  : -1 : 0
//var float4 glstate.light[0].half : state.light[0].half :  : -1 : 0
//var float4 glstate.light[1].ambient : state.light[1].ambient :  : -1 : 0
//var float4 glstate.light[1].diffuse : state.light[1].diffuse :  : -1 : 0
//var float4 glstate.light[1].specular : state.light[1].specular :  : -1 : 0
//var float4 glstate.light[1].position : state.light[1].position :  : -1 : 0
//var float4 glstate.light[1].attenuation : state.light[1].attenuation :  : -1 : 0
//var float4 glstate.light[1].spot.direction : state.light[1].spot.direction :  : -1 : 0
//var float4 glstate.light[1].half : state.light[1].half :  : -1 : 0
//var float4 glstate.light[2].ambient : state.light[2].ambient :  : -1 : 0
//var float4 glstate.light[2].diffuse : state.light[2].diffuse :  : -1 : 0
//var float4 glstate.light[2].specular : state.light[2].specular :  : -1 : 0
//var float4 glstate.light[2].position : state.light[2].position :  : -1 : 0
//var float4 glstate.light[2].attenuation : state.light[2].attenuation :  : -1 : 0
//var float4 glstate.light[2].spot.direction : state.light[2].spot.direction :  : -1 : 0
//var float4 glstate.light[2].half : state.light[2].half :  : -1 : 0
//var float4 glstate.light[3].ambient : state.light[3].ambient :  : -1 : 0
//var float4 glstate.light[3].diffuse : state.light[3].diffuse :  : -1 : 0
//var float4 glstate.light[3].specular : state.light[3].specular :  : -1 : 0
//var float4 glstate.light[3].position : state.light[3].position :  : -1 : 0
//var float4 glstate.light[3].attenuation : state.light[3].attenuation :  : -1 : 0
//var float4 glstate.light[3].spot.direction : state.light[3].spot.direction :  : -1 : 0
//var float4 glstate.light[3].half : state.light[3].half :  : -1 : 0
//var float4 glstate.light[4].ambient : state.light[4].ambient :  : -1 : 0
//var float4 glstate.light[4].diffuse : state.light[4].diffuse :  : -1 : 0
//var float4 glstate.light[4].specular : state.light[4].specular :  : -1 : 0
//var float4 glstate.light[4].position : state.light[4].position :  : -1 : 0
//var float4 glstate.light[4].attenuation : state.light[4].attenuation :  : -1 : 0
//var float4 glstate.light[4].spot.direction : state.light[4].spot.direction :  : -1 : 0
//var float4 glstate.light[4].half : state.light[4].half :  : -1 : 0
//var float4 glstate.light[5].ambient : state.light[5].ambient :  : -1 : 0
//var float4 glstate.light[5].diffuse : state.light[5].diffuse :  : -1 : 0
//var float4 glstate.light[5].specular : state.light[5].specular :  : -1 : 0
//var float4 glstate.light[5].position : state.light[5].position :  : -1 : 0
//var float4 glstate.light[5].attenuation : state.light[5].attenuation :  : -1 : 0
//var float4 glstate.light[5].spot.direction : state.light[5].spot.direction :  : -1 : 0
//var float4 glstate.light[5].half : state.light[5].half :  : -1 : 0
//var float4 glstate.light[6].ambient : state.light[6].ambient :  : -1 : 0
//var float4 glstate.light[6].diffuse : state.light[6].diffuse :  : -1 : 0
//var float4 glstate.light[6].specular : state.light[6].specular :  : -1 : 0
//var float4 glstate.light[6].position : state.light[6].position :  : -1 : 0
//var float4 glstate.light[6].attenuation : state.light[6].attenuation :  : -1 : 0
//var float4 glstate.light[6].spot.direction : state.light[6].spot.direction :  : -1 : 0
//var float4 glstate.light[6].half : state.light[6].half :  : -1 : 0
//var float4 glstate.light[7].ambient : state.light[7].ambient :  : -1 : 0
//var float4 glstate.light[7].diffuse : state.light[7].diffuse :  : -1 : 0
//var float4 glstate.light[7].specular : state.light[7].specular :  : -1 : 0
//var float4 glstate.light[7].position : state.light[7].position :  : -1 : 0
//var float4 glstate.light[7].attenuation : state.light[7].attenuation :  : -1 : 0
//var float4 glstate.light[7].spot.direction : state.light[7].spot.direction :  : -1 : 0
//var float4 glstate.light[7].half : state.light[7].half :  : -1 : 0
//var float4 glstate.lightmodel.ambient : state.lightmodel.ambient :  : -1 : 0
//var float4 glstate.lightmodel.scenecolor : state.lightmodel.scenecolor :  : -1 : 0
//var float4 glstate.lightmodel.front.scenecolor : state.lightmodel.front.scenecolor :  : -1 : 0
//var float4 glstate.lightmodel.back.scenecolor : state.lightmodel.back.scenecolor :  : -1 : 0
//var float4 glstate.lightprod[0].ambient : state.lightprod[0].ambient :  : -1 : 0
//var float4 glstate.lightprod[0].diffuse : state.lightprod[0].diffuse :  : -1 : 0
//var float4 glstate.lightprod[0].specular : state.lightprod[0].specular :  : -1 : 0
//var float4 glstate.lightprod[0].front.ambient : state.lightprod[0].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[0].front.diffuse : state.lightprod[0].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[0].front.specular : state.lightprod[0].front.specular :  : -1 : 0
//var float4 glstate.lightprod[0].back.ambient : state.lightprod[0].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[0].back.diffuse : state.lightprod[0].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[0].back.specular : state.lightprod[0].back.specular :  : -1 : 0
//var float4 glstate.lightprod[1].ambient : state.lightprod[1].ambient :  : -1 : 0
//var float4 glstate.lightprod[1].diffuse : state.lightprod[1].diffuse :  : -1 : 0
//var float4 glstate.lightprod[1].specular : state.lightprod[1].specular :  : -1 : 0
//var float4 glstate.lightprod[1].front.ambient : state.lightprod[1].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[1].front.diffuse : state.lightprod[1].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[1].front.specular : state.lightprod[1].front.specular :  : -1 : 0
//var float4 glstate.lightprod[1].back.ambient : state.lightprod[1].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[1].back.diffuse : state.lightprod[1].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[1].back.specular : state.lightprod[1].back.specular :  : -1 : 0
//var float4 glstate.lightprod[2].ambient : state.lightprod[2].ambient :  : -1 : 0
//var float4 glstate.lightprod[2].diffuse : state.lightprod[2].diffuse :  : -1 : 0
//var float4 glstate.lightprod[2].specular : state.lightprod[2].specular :  : -1 : 0
//var float4 glstate.lightprod[2].front.ambient : state.lightprod[2].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[2].front.diffuse : state.lightprod[2].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[2].front.specular : state.lightprod[2].front.specular :  : -1 : 0
//var float4 glstate.lightprod[2].back.ambient : state.lightprod[2].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[2].back.diffuse : state.lightprod[2].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[2].back.specular : state.lightprod[2].back.specular :  : -1 : 0
//var float4 glstate.lightprod[3].ambient : state.lightprod[3].ambient :  : -1 : 0
//var float4 glstate.lightprod[3].diffuse : state.lightprod[3].diffuse :  : -1 : 0
//var float4 glstate.lightprod[3].specular : state.lightprod[3].specular :  : -1 : 0
//var float4 glstate.lightprod[3].front.ambient : state.lightprod[3].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[3].front.diffuse : state.lightprod[3].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[3].front.specular : state.lightprod[3].front.specular :  : -1 : 0
//var float4 glstate.lightprod[3].back.ambient : state.lightprod[3].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[3].back.diffuse : state.lightprod[3].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[3].back.specular : state.lightprod[3].back.specular :  : -1 : 0
//var float4 glstate.lightprod[4].ambient : state.lightprod[4].ambient :  : -1 : 0
//var float4 glstate.lightprod[4].diffuse : state.lightprod[4].diffuse :  : -1 : 0
//var float4 glstate.lightprod[4].specular : state.lightprod[4].specular :  : -1 : 0
//var float4 glstate.lightprod[4].front.ambient : state.lightprod[4].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[4].front.diffuse : state.lightprod[4].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[4].front.specular : state.lightprod[4].front.specular :  : -1 : 0
//var float4 glstate.lightprod[4].back.ambient : state.lightprod[4].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[4].back.diffuse : state.lightprod[4].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[4].back.specular : state.lightprod[4].back.specular :  : -1 : 0
//var float4 glstate.lightprod[5].ambient : state.lightprod[5].ambient :  : -1 : 0
//var float4 glstate.lightprod[5].diffuse : state.lightprod[5].diffuse :  : -1 : 0
//var float4 glstate.lightprod[5].specular : state.lightprod[5].specular :  : -1 : 0
//var float4 glstate.lightprod[5].front.ambient : state.lightprod[5].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[5].front.diffuse : state.lightprod[5].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[5].front.specular : state.lightprod[5].front.specular :  : -1 : 0
//var float4 glstate.lightprod[5].back.ambient : state.lightprod[5].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[5].back.diffuse : state.lightprod[5].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[5].back.specular : state.lightprod[5].back.specular :  : -1 : 0
//var float4 glstate.lightprod[6].ambient : state.lightprod[6].ambient :  : -1 : 0
//var float4 glstate.lightprod[6].diffuse : state.lightprod[6].diffuse :  : -1 : 0
//var float4 glstate.lightprod[6].specular : state.lightprod[6].specular :  : -1 : 0
//var float4 glstate.lightprod[6].front.ambient : state.lightprod[6].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[6].front.diffuse : state.lightprod[6].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[6].front.specular : state.lightprod[6].front.specular :  : -1 : 0
//var float4 glstate.lightprod[6].back.ambient : state.lightprod[6].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[6].back.diffuse : state.lightprod[6].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[6].back.specular : state.lightprod[6].back.specular :  : -1 : 0
//var float4 glstate.lightprod[7].ambient : state.lightprod[7].ambient :  : -1 : 0
//var float4 glstate.lightprod[7].diffuse : state.lightprod[7].diffuse :  : -1 : 0
//var float4 glstate.lightprod[7].specular : state.lightprod[7].specular :  : -1 : 0
//var float4 glstate.lightprod[7].front.ambient : state.lightprod[7].front.ambient :  : -1 : 0
//var float4 glstate.lightprod[7].front.diffuse : state.lightprod[7].front.diffuse :  : -1 : 0
//var float4 glstate.lightprod[7].front.specular : state.lightprod[7].front.specular :  : -1 : 0
//var float4 glstate.lightprod[7].back.ambient : state.lightprod[7].back.ambient :  : -1 : 0
//var float4 glstate.lightprod[7].back.diffuse : state.lightprod[7].back.diffuse :  : -1 : 0
//var float4 glstate.lightprod[7].back.specular : state.lightprod[7].back.specular :  : -1 : 0
//var float4 glstate.texgen[0].eye.s : state.texgen[0].eye.s :  : -1 : 0
//var float4 glstate.texgen[0].eye.t : state.texgen[0].eye.t :  : -1 : 0
//var float4 glstate.texgen[0].eye.r : state.texgen[0].eye.r :  : -1 : 0
//var float4 glstate.texgen[0].eye.q : state.texgen[0].eye.q :  : -1 : 0
//var float4 glstate.texgen[0].object.s : state.texgen[0].object.s :  : -1 : 0
//var float4 glstate.texgen[0].object.t : state.texgen[0].object.t :  : -1 : 0
//var float4 glstate.texgen[0].object.r : state.texgen[0].object.r :  : -1 : 0
//var float4 glstate.texgen[0].object.q : state.texgen[0].object.q :  : -1 : 0
//var float4 glstate.texgen[1].eye.s : state.texgen[1].eye.s :  : -1 : 0
//var float4 glstate.texgen[1].eye.t : state.texgen[1].eye.t :  : -1 : 0
//var float4 glstate.texgen[1].eye.r : state.texgen[1].eye.r :  : -1 : 0
//var float4 glstate.texgen[1].eye.q : state.texgen[1].eye.q :  : -1 : 0
//var float4 glstate.texgen[1].object.s : state.texgen[1].object.s :  : -1 : 0
//var float4 glstate.texgen[1].object.t : state.texgen[1].object.t :  : -1 : 0
//var float4 glstate.texgen[1].object.r : state.texgen[1].object.r :  : -1 : 0
//var float4 glstate.texgen[1].object.q : state.texgen[1].object.q :  : -1 : 0
//var float4 glstate.texgen[2].eye.s : state.texgen[2].eye.s :  : -1 : 0
//var float4 glstate.texgen[2].eye.t : state.texgen[2].eye.t :  : -1 : 0
//var float4 glstate.texgen[2].eye.r : state.texgen[2].eye.r :  : -1 : 0
//var float4 glstate.texgen[2].eye.q : state.texgen[2].eye.q :  : -1 : 0
//var float4 glstate.texgen[2].object.s : state.texgen[2].object.s :  : -1 : 0
//var float4 glstate.texgen[2].object.t : state.texgen[2].object.t :  : -1 : 0
//var float4 glstate.texgen[2].object.r : state.texgen[2].object.r :  : -1 : 0
//var float4 glstate.texgen[2].object.q : state.texgen[2].object.q :  : -1 : 0
//var float4 glstate.texgen[3].eye.s : state.texgen[3].eye.s :  : -1 : 0
//var float4 glstate.texgen[3].eye.t : state.texgen[3].eye.t :  : -1 : 0
//var float4 glstate.texgen[3].eye.r : state.texgen[3].eye.r :  : -1 : 0
//var float4 glstate.texgen[3].eye.q : state.texgen[3].eye.q :  : -1 : 0
//var float4 glstate.texgen[3].object.s : state.texgen[3].object.s :  : -1 : 0
//var float4 glstate.texgen[3].object.t : state.texgen[3].object.t :  : -1 : 0
//var float4 glstate.texgen[3].object.r : state.texgen[3].object.r :  : -1 : 0
//var float4 glstate.texgen[3].object.q : state.texgen[3].object.q :  : -1 : 0
//var float4 glstate.texgen[4].eye.s : state.texgen[4].eye.s :  : -1 : 0
//var float4 glstate.texgen[4].eye.t : state.texgen[4].eye.t :  : -1 : 0
//var float4 glstate.texgen[4].eye.r : state.texgen[4].eye.r :  : -1 : 0
//var float4 glstate.texgen[4].eye.q : state.texgen[4].eye.q :  : -1 : 0
//var float4 glstate.texgen[4].object.s : state.texgen[4].object.s :  : -1 : 0
//var float4 glstate.texgen[4].object.t : state.texgen[4].object.t :  : -1 : 0
//var float4 glstate.texgen[4].object.r : state.texgen[4].object.r :  : -1 : 0
//var float4 glstate.texgen[4].object.q : state.texgen[4].object.q :  : -1 : 0
//var float4 glstate.texgen[5].eye.s : state.texgen[5].eye.s :  : -1 : 0
//var float4 glstate.texgen[5].eye.t : state.texgen[5].eye.t :  : -1 : 0
//var float4 glstate.texgen[5].eye.r : state.texgen[5].eye.r :  : -1 : 0
//var float4 glstate.texgen[5].eye.q : state.texgen[5].eye.q :  : -1 : 0
//var float4 glstate.texgen[5].object.s : state.texgen[5].object.s :  : -1 : 0
//var float4 glstate.texgen[5].object.t : state.texgen[5].object.t :  : -1 : 0
//var float4 glstate.texgen[5].object.r : state.texgen[5].object.r :  : -1 : 0
//var float4 glstate.texgen[5].object.q : state.texgen[5].object.q :  : -1 : 0
//var float4 glstate.texgen[6].eye.s : state.texgen[6].eye.s :  : -1 : 0
//var float4 glstate.texgen[6].eye.t : state.texgen[6].eye.t :  : -1 : 0
//var float4 glstate.texgen[6].eye.r : state.texgen[6].eye.r :  : -1 : 0
//var float4 glstate.texgen[6].eye.q : state.texgen[6].eye.q :  : -1 : 0
//var float4 glstate.texgen[6].object.s : state.texgen[6].object.s :  : -1 : 0
//var float4 glstate.texgen[6].object.t : state.texgen[6].object.t :  : -1 : 0
//var float4 glstate.texgen[6].object.r : state.texgen[6].object.r :  : -1 : 0
//var float4 glstate.texgen[6].object.q : state.texgen[6].object.q :  : -1 : 0
//var float4 glstate.texgen[7].eye.s : state.texgen[7].eye.s :  : -1 : 0
//var float4 glstate.texgen[7].eye.t : state.texgen[7].eye.t :  : -1 : 0
//var float4 glstate.texgen[7].eye.r : state.texgen[7].eye.r :  : -1 : 0
//var float4 glstate.texgen[7].eye.q : state.texgen[7].eye.q :  : -1 : 0
//var float4 glstate.texgen[7].object.s : state.texgen[7].object.s :  : -1 : 0
//var float4 glstate.texgen[7].object.t : state.texgen[7].object.t :  : -1 : 0
//var float4 glstate.texgen[7].object.r : state.texgen[7].object.r :  : -1 : 0
//var float4 glstate.texgen[7].object.q : state.texgen[7].object.q :  : -1 : 0
//var float4 glstate.fog.color : state.fog.color :  : -1 : 0
//var float4 glstate.fog.params : state.fog.params :  : -1 : 0
//var float4 glstate.clip[0].plane : state.clip[0].plane :  : -1 : 0
//var float4 glstate.clip[1].plane : state.clip[1].plane :  : -1 : 0
//var float4 glstate.clip[2].plane : state.clip[2].plane :  : -1 : 0
//var float4 glstate.clip[3].plane : state.clip[3].plane :  : -1 : 0
//var float4 glstate.clip[4].plane : state.clip[4].plane :  : -1 : 0
//var float4 glstate.clip[5].plane : state.clip[5].plane :  : -1 : 0
//var float4 glstate.clip[6].plane : state.clip[6].plane :  : -1 : 0
//var float4 glstate.clip[7].plane : state.clip[7].plane :  : -1 : 0
//var float glstate.point.size : state.point.size :  : -1 : 0
//var float glstate.point.attenuation : state.point.attenuation :  : -1 : 0
//var float4x4 glstate.matrix.modelview[0] : state.matrix.modelview[0] : , 4 : -1 : 0
//var float4x4 glstate.matrix.modelview[1] : state.matrix.modelview[1] : , 4 : -1 : 0
//var float4x4 glstate.matrix.modelview[2] : state.matrix.modelview[2] : , 4 : -1 : 0
//var float4x4 glstate.matrix.modelview[3] : state.matrix.modelview[3] : , 4 : -1 : 0
//var float4x4 glstate.matrix.modelview[4] : state.matrix.modelview[4] : , 4 : -1 : 0
//var float4x4 glstate.matrix.modelview[5] : state.matrix.modelview[5] : , 4 : -1 : 0
//var float4x4 glstate.matrix.modelview[6] : state.matrix.modelview[6] : , 4 : -1 : 0
//var float4x4 glstate.matrix.modelview[7] : state.matrix.modelview[7] : , 4 : -1 : 0
//var float4x4 glstate.matrix.projection : state.matrix.projection : , 4 : -1 : 0
//var float4x4 glstate.matrix.mvp : state.matrix.mvp : c[0], 4 : -1 : 1
//var float4x4 glstate.matrix.texture[0] : state.matrix.texture[0] : c[4], 4 : -1 : 1
//var float4x4 glstate.matrix.texture[1] : state.matrix.texture[1] : , 4 : -1 : 0
//var float4x4 glstate.matrix.texture[2] : state.matrix.texture[2] : , 4 : -1 : 0
//var float4x4 glstate.matrix.texture[3] : state.matrix.texture[3] : , 4 : -1 : 0
//var float4x4 glstate.matrix.texture[4] : state.matrix.texture[4] : , 4 : -1 : 0
//var float4x4 glstate.matrix.texture[5] : state.matrix.texture[5] : , 4 : -1 : 0
//var float4x4 glstate.matrix.texture[6] : state.matrix.texture[6] : , 4 : -1 : 0
//var float4x4 glstate.matrix.texture[7] : state.matrix.texture[7] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[0] : state.matrix.palette[0] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[1] : state.matrix.palette[1] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[2] : state.matrix.palette[2] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[3] : state.matrix.palette[3] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[4] : state.matrix.palette[4] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[5] : state.matrix.palette[5] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[6] : state.matrix.palette[6] : , 4 : -1 : 0
//var float4x4 glstate.matrix.palette[7] : state.matrix.palette[7] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[0] : state.matrix.program[0] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[1] : state.matrix.program[1] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[2] : state.matrix.program[2] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[3] : state.matrix.program[3] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[4] : state.matrix.program[4] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[5] : state.matrix.program[5] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[6] : state.matrix.program[6] : , 4 : -1 : 0
//var float4x4 glstate.matrix.program[7] : state.matrix.program[7] : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[0] : state.matrix.modelview[0].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[1] : state.matrix.modelview[1].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[2] : state.matrix.modelview[2].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[3] : state.matrix.modelview[3].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[4] : state.matrix.modelview[4].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[5] : state.matrix.modelview[5].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[6] : state.matrix.modelview[6].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.modelview[7] : state.matrix.modelview[7].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.projection : state.matrix.projection.inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.mvp : state.matrix.mvp.inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[0] : state.matrix.texture[0].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[1] : state.matrix.texture[1].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[2] : state.matrix.texture[2].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[3] : state.matrix.texture[3].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[4] : state.matrix.texture[4].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[5] : state.matrix.texture[5].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[6] : state.matrix.texture[6].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.texture[7] : state.matrix.texture[7].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[0] : state.matrix.palette[0].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[1] : state.matrix.palette[1].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[2] : state.matrix.palette[2].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[3] : state.matrix.palette[3].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[4] : state.matrix.palette[4].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[5] : state.matrix.palette[5].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[6] : state.matrix.palette[6].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.palette[7] : state.matrix.palette[7].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[0] : state.matrix.program[0].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[1] : state.matrix.program[1].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[2] : state.matrix.program[2].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[3] : state.matrix.program[3].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[4] : state.matrix.program[4].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[5] : state.matrix.program[5].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[6] : state.matrix.program[6].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.inverse.program[7] : state.matrix.program[7].inverse : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[0] : state.matrix.modelview[0].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[1] : state.matrix.modelview[1].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[2] : state.matrix.modelview[2].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[3] : state.matrix.modelview[3].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[4] : state.matrix.modelview[4].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[5] : state.matrix.modelview[5].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[6] : state.matrix.modelview[6].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.modelview[7] : state.matrix.modelview[7].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.projection : state.matrix.projection.transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.mvp : state.matrix.mvp.transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[0] : state.matrix.texture[0].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[1] : state.matrix.texture[1].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[2] : state.matrix.texture[2].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[3] : state.matrix.texture[3].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[4] : state.matrix.texture[4].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[5] : state.matrix.texture[5].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[6] : state.matrix.texture[6].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.texture[7] : state.matrix.texture[7].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[0] : state.matrix.palette[0].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[1] : state.matrix.palette[1].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[2] : state.matrix.palette[2].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[3] : state.matrix.palette[3].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[4] : state.matrix.palette[4].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[5] : state.matrix.palette[5].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[6] : state.matrix.palette[6].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.palette[7] : state.matrix.palette[7].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[0] : state.matrix.program[0].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[1] : state.matrix.program[1].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[2] : state.matrix.program[2].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[3] : state.matrix.program[3].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[4] : state.matrix.program[4].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[5] : state.matrix.program[5].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[6] : state.matrix.program[6].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.transpose.program[7] : state.matrix.program[7].transpose : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[0] : state.matrix.modelview[0].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[1] : state.matrix.modelview[1].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[2] : state.matrix.modelview[2].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[3] : state.matrix.modelview[3].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[4] : state.matrix.modelview[4].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[5] : state.matrix.modelview[5].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[6] : state.matrix.modelview[6].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.modelview[7] : state.matrix.modelview[7].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.projection : state.matrix.projection.invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.mvp : state.matrix.mvp.invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[0] : state.matrix.texture[0].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[1] : state.matrix.texture[1].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[2] : state.matrix.texture[2].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[3] : state.matrix.texture[3].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[4] : state.matrix.texture[4].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[5] : state.matrix.texture[5].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[6] : state.matrix.texture[6].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.texture[7] : state.matrix.texture[7].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[0] : state.matrix.palette[0].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[1] : state.matrix.palette[1].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[2] : state.matrix.palette[2].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[3] : state.matrix.palette[3].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[4] : state.matrix.palette[4].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[5] : state.matrix.palette[5].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[6] : state.matrix.palette[6].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.palette[7] : state.matrix.palette[7].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[0] : state.matrix.program[0].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[1] : state.matrix.program[1].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[2] : state.matrix.program[2].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[3] : state.matrix.program[3].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[4] : state.matrix.program[4].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[5] : state.matrix.program[5].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[6] : state.matrix.program[6].invtrans : , 4 : -1 : 0
//var float4x4 glstate.matrix.invtrans.program[7] : state.matrix.program[7].invtrans : , 4 : -1 : 0
//var float4 _In.vertex : $vin.POSITION0 : ATTR0 : 0 : 1
//var float2 _In.texcoord : $vin.TEXCOORD0 : ATTR1 : 0 : 1
//var float4 _Time :  :  : -1 : 0
//var float4 _SinTime :  :  : -1 : 0
//var float4 _CosTime :  :  : -1 : 0
//var float4 _ProjectionParams :  :  : -1 : 0
//var float4 _ScreenParams :  :  : -1 : 0
//var float4 unity_Scale :  :  : -1 : 0
//var float3 _WorldSpaceCameraPos :  :  : -1 : 0
//var float4 _WorldSpaceLightPos0 :  :  : -1 : 0
//var float4x4 _Object2World :  : , 4 : -1 : 0
//var float4x4 _World2Object :  : , 4 : -1 : 0
//var float4 _LightPositionRange :  :  : -1 : 0
//var float4 unity_4LightPosX0 :  :  : -1 : 0
//var float4 unity_4LightPosY0 :  :  : -1 : 0
//var float4 unity_4LightPosZ0 :  :  : -1 : 0
//var float4 unity_4LightAtten0 :  :  : -1 : 0
//var float4 unity_LightColor[0] :  :  : -1 : 0
//var float4 unity_LightColor[1] :  :  : -1 : 0
//var float4 unity_LightColor[2] :  :  : -1 : 0
//var float4 unity_LightColor[3] :  :  : -1 : 0
//var float4 unity_LightPosition[0] :  :  : -1 : 0
//var float4 unity_LightPosition[1] :  :  : -1 : 0
//var float4 unity_LightPosition[2] :  :  : -1 : 0
//var float4 unity_LightPosition[3] :  :  : -1 : 0
//var float4 unity_LightAtten[0] :  :  : -1 : 0
//var float4 unity_LightAtten[1] :  :  : -1 : 0
//var float4 unity_LightAtten[2] :  :  : -1 : 0
//var float4 unity_LightAtten[3] :  :  : -1 : 0
//var float3 unity_LightColor0 :  :  : -1 : 0
//var float3 unity_LightColor1 :  :  : -1 : 0
//var float3 unity_LightColor2 :  :  : -1 : 0
//var float3 unity_LightColor3 :  :  : -1 : 0
//var float4 unity_SHAr :  :  : -1 : 0
//var float4 unity_SHAg :  :  : -1 : 0
//var float4 unity_SHAb :  :  : -1 : 0
//var float4 unity_SHBr :  :  : -1 : 0
//var float4 unity_SHBg :  :  : -1 : 0
//var float4 unity_SHBb :  :  : -1 : 0
//var float4 unity_SHC :  :  : -1 : 0
//var float4 _ZBufferParams :  :  : -1 : 0
//var float4 unity_LightShadowBias :  :  : -1 : 0
//var float4 _CameraData :  :  : -1 : 0
//var float4x4 _Camera2World :  : , 4 : -1 : 0
//var float4x4 _World2Camera :  : , 4 : -1 : 0
//var sampler2D _CameraDepthTexture :  :  : -1 : 0
//var sampler2D _MainTex :  :  : -1 : 0
//var float4 _dUV :  :  : -1 : 0
//var float4 _TargetdUV :  :  : -1 : 0
//var float4 VS.Position : $vout.POSITION : ATTR0 : -1 : 1
//var float4 VS.UV : $vout.TEXCOORD0 : ATTR1 : -1 : 1
//const c[8] = 0
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
Vector 0 [_dUV]

"!!ARBfp1.0
OPTION NV_fragment_program2;
# cgc version 3.0.0016, build date Feb 11 2011
# command line args: -profile fp40 -IC:\Program Files (x86)\Unity\Editor\Data\CGIncludes -DUNITY_MATRIX_MVP=glstate.matrix.mvp -DUNITY_MATRIX_TEXTURE0=glstate.matrix.texture[0] -DUNITY_MATRIX_P=glstate.matrix.projection -DTARGET_MAC=1 -fastmath -glslWerror -strict
# source file: C:\UNITY\Project\Qlaud\Assets\Nuaj\Resources\Shaders\Sky\SkyUpScale.cg
#vendor NVIDIA Corporation
#version 3.0.0.16
#profile fp40
#program PS
#semantic _Time
#semantic _SinTime
#semantic _CosTime
#semantic _ProjectionParams
#semantic _ScreenParams
#semantic unity_Scale
#semantic _WorldSpaceCameraPos
#semantic _WorldSpaceLightPos0
#semantic _Object2World
#semantic _World2Object
#semantic _LightPositionRange
#semantic unity_4LightPosX0
#semantic unity_4LightPosY0
#semantic unity_4LightPosZ0
#semantic unity_4LightAtten0
#semantic unity_LightColor
#semantic unity_LightPosition
#semantic unity_LightAtten
#semantic unity_LightColor0
#semantic unity_LightColor1
#semantic unity_LightColor2
#semantic unity_LightColor3
#semantic unity_SHAr
#semantic unity_SHAg
#semantic unity_SHAb
#semantic unity_SHBr
#semantic unity_SHBg
#semantic unity_SHBb
#semantic unity_SHC
#semantic _ZBufferParams
#semantic unity_LightShadowBias
#semantic _CameraData
#semantic _Camera2World
#semantic _World2Camera
#semantic _CameraDepthTexture
#semantic _MainTex
#semantic _dUV
#semantic _TargetdUV
#var float4 _In.UV : $vin.TEXCOORD0 : TEX0 : 0 : 1
#var float4 _Time :  :  : -1 : 0
#var float4 _SinTime :  :  : -1 : 0
#var float4 _CosTime :  :  : -1 : 0
#var float4 _ProjectionParams :  :  : -1 : 0
#var float4 _ScreenParams :  :  : -1 : 0
#var float4 unity_Scale :  :  : -1 : 0
#var float3 _WorldSpaceCameraPos :  :  : -1 : 0
#var float4 _WorldSpaceLightPos0 :  :  : -1 : 0
#var float4x4 _Object2World :  : , 4 : -1 : 0
#var float4x4 _World2Object :  : , 4 : -1 : 0
#var float4 _LightPositionRange :  :  : -1 : 0
#var float4 unity_4LightPosX0 :  :  : -1 : 0
#var float4 unity_4LightPosY0 :  :  : -1 : 0
#var float4 unity_4LightPosZ0 :  :  : -1 : 0
#var float4 unity_4LightAtten0 :  :  : -1 : 0
#var float4 unity_LightColor[0] :  :  : -1 : 0
#var float4 unity_LightColor[1] :  :  : -1 : 0
#var float4 unity_LightColor[2] :  :  : -1 : 0
#var float4 unity_LightColor[3] :  :  : -1 : 0
#var float4 unity_LightPosition[0] :  :  : -1 : 0
#var float4 unity_LightPosition[1] :  :  : -1 : 0
#var float4 unity_LightPosition[2] :  :  : -1 : 0
#var float4 unity_LightPosition[3] :  :  : -1 : 0
#var float4 unity_LightAtten[0] :  :  : -1 : 0
#var float4 unity_LightAtten[1] :  :  : -1 : 0
#var float4 unity_LightAtten[2] :  :  : -1 : 0
#var float4 unity_LightAtten[3] :  :  : -1 : 0
#var float3 unity_LightColor0 :  :  : -1 : 0
#var float3 unity_LightColor1 :  :  : -1 : 0
#var float3 unity_LightColor2 :  :  : -1 : 0
#var float3 unity_LightColor3 :  :  : -1 : 0
#var float4 unity_SHAr :  :  : -1 : 0
#var float4 unity_SHAg :  :  : -1 : 0
#var float4 unity_SHAb :  :  : -1 : 0
#var float4 unity_SHBr :  :  : -1 : 0
#var float4 unity_SHBg :  :  : -1 : 0
#var float4 unity_SHBb :  :  : -1 : 0
#var float4 unity_SHC :  :  : -1 : 0
#var float4 _ZBufferParams :  :  : -1 : 0
#var float4 unity_LightShadowBias :  :  : -1 : 0
#var float4 _CameraData :  :  : -1 : 0
#var float4x4 _Camera2World :  : , 4 : -1 : 0
#var float4x4 _World2Camera :  : , 4 : -1 : 0
#var sampler2D _CameraDepthTexture :  :  : -1 : 0
#var sampler2D _MainTex :  : texunit 0 : -1 : 1
#var float4 _dUV :  : c[0] : -1 : 1
#var float4 _TargetdUV :  :  : -1 : 0
#var half4 PS : $vout.COLOR : COL : -1 : 1
#const c[1] = 0 1 128 15
#const c[2] = 4 1024 0.00390625 0.0047619049
#const c[3] = 0.63999999 0 210 0.25
#const c[4] = 0.075300001 -0.2543 1.1892 2
#const c[5] = 2.5651 -1.1665 -0.39860001 256
#const c[6] = -1.0217 1.9777 0.043900002 400
#const c[7] = 0.0241188 0.1228178 0.84442663 255
#const c[8] = 0.51413637 0.32387859 0.16036376 0.0009765625
#const c[9] = 0.26506799 0.67023426 0.064091571
PARAM c[10] = { program.local[0],
		{ 0, 1, 128, 15 },
		{ 4, 1024, 0.00390625, 0.0047619049 },
		{ 0.63999999, 0, 210, 0.25 },
		{ 0.075300001, -0.2543, 1.1892, 2 },
		{ 2.5651, -1.1665, -0.39860001, 256 },
		{ -1.0217, 1.9777, 0.043900002, 400 },
		{ 0.0241188, 0.1228178, 0.84442663, 255 },
		{ 0.51413637, 0.32387859, 0.16036376, 0.0009765625 },
		{ 0.26506799, 0.67023426, 0.064091571 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
TEMP R8;
SHORT TEMP H0;
SHORT TEMP H1;
TEMP RC;
TEMP HC;
SHORT OUTPUT oCol = result.color;
ADDR  R0.xy, fragment.texcoord[0], c[0].xzzw;
ADDR  R0.zw, R0.xyxy, c[0].xyzy;
TXD   R4, R0.zwzw, c[1].yxzw, c[1], texture[0], 2D;
ADDR  R8.xy, R0.zwzw, -c[0].xzzw;
TXD   R5, R8, c[1].yxzw, c[1], texture[0], 2D;
LG2H  H0.x, |R4.y|;
FLRH  H0.x, H0;
EX2H  H0.y, -H0.x;
MULH  H0.y, |R4|, H0;
MADH  H0.y, H0, c[2], -c[2];
MULR  R1.x, H0.y, c[2].z;
FRCR  R1.y, R1.x;
MULR  R1.z, R1.y, c[3].x;
ADDH  H0.x, H0, c[1].w;
MULH  H0.z, H0.x, c[2].x;
SGEH  H0.xy, c[1].x, R4.ywzw;
MADH  H0.x, H0, c[1].z, H0.z;
FLRR  R1.x, R1;
ADDR  R1.x, H0, R1;
MULR  R1.x, R1, c[2].w;
ADDR  R1.y, -R1.x, -R1.z;
LG2H  H0.x, |R5.y|;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R5.y|, H0;
ADDH  H0.x, H0, c[1].w;
MADR  R1.y, R1, R4.x, R4.x;
RCPR  R0.w, R1.z;
MULR  R0.z, R1.y, R0.w;
MULR  R1.x, R1, R4;
MULR  R0.w, R0, R1.x;
MULR  R1.xyz, R4.x, c[6];
MADR  R1.xyz, R0.w, c[5], R1;
MADR  R1.xyz, R0.z, c[4], R1;
MADH  H0.z, H0, c[2].y, -c[2].y;
MULR  R0.z, H0, c[2];
FRCR  R0.w, R0.z;
SGEH  H0.zw, c[1].x, R5.xyyw;
MULH  H0.x, H0, c[2];
MADH  H0.x, H0.z, c[1].z, H0;
FLRR  R0.z, R0;
ADDR  R1.w, H0.x, R0.z;
MULR  R0.z, R0.w, c[3].x;
MULR  R0.w, R1, c[2];
ADDR  R1.w, -R0, -R0.z;
MULR  R0.w, R0, R5.x;
MADR  R1.w, R1, R5.x, R5.x;
RCPR  R0.z, R0.z;
MULR  R1.w, R1, R0.z;
MAXR  R1.xyz, R1, c[1].x;
MULR  R2.xyz, R5.x, c[6];
MULR  R0.z, R0, R0.w;
MADR  R2.xyz, R0.z, c[5], R2;
TXD   R0, R0, c[1].yxzw, c[1], texture[0], 2D;
MADR  R2.xyz, R1.w, c[4], R2;
LG2H  H0.x, |R0.y|;
MAXR  R2.xyz, R2, c[1].x;
ADDR  R3.xyz, R1, -R2;
TXD   R1, fragment.texcoord[0], c[1].yxzw, c[1], texture[0], 2D;
FLRH  H0.x, H0;
EX2H  H0.z, -H0.x;
MULH  H0.z, |R0.y|, H0;
ADDH  H0.x, H0, c[1].w;
SGEH  H1.xy, c[1].x, R0.ywzw;
MADH  H0.z, H0, c[2].y, -c[2].y;
MULR  R0.y, H0.z, c[2].z;
LG2H  H0.z, |R1.y|;
FLRR  R2.w, R0.y;
FRCR  R0.y, R0;
MULH  H0.x, H0, c[2];
MADH  H0.x, H1, c[1].z, H0;
ADDR  R2.w, H0.x, R2;
FLRH  H0.z, H0;
EX2H  H0.x, -H0.z;
MULH  H0.x, |R1.y|, H0;
SGEH  H1.zw, c[1].x, R1.xyyw;
MULR  R4.y, R2.w, c[2].w;
MULR  R4.x, R0.y, c[3];
ADDR  R3.w, -R4.y, -R4.x;
MADH  H0.x, H0, c[2].y, -c[2].y;
MULR  R0.y, H0.x, c[2].z;
FRCR  R2.w, R0.y;
ADDH  H0.x, H0.z, c[1].w;
MULH  H0.x, H0, c[2];
MULR  R1.y, R2.w, c[3].x;
MADR  R3.w, R3, R0.x, R0.x;
MULR  R4.y, R4, R0.x;
RCPR  R4.x, R4.x;
MULR  R6.xyz, R0.x, c[6];
MULR  R0.x, R4, R4.y;
MADR  R6.xyz, R0.x, c[5], R6;
MULR  R0.x, R3.w, R4;
MADR  R6.xyz, R0.x, c[4], R6;
MADH  H0.x, H1.z, c[1].z, H0;
FLRR  R0.y, R0;
ADDR  R0.y, H0.x, R0;
MULR  R0.y, R0, c[2].w;
ADDR  R2.w, -R0.y, -R1.y;
MADR  R0.x, R2.w, R1, R1;
MULR  R2.w, R0.y, R1.x;
RCPR  R0.y, R1.y;
LG2H  H0.x, |R0.w|;
FLRH  H0.z, H0.x;
EX2H  H0.x, -H0.z;
MULH  H0.x, |R0.w|, H0;
MULR  R7.xyz, R1.x, c[6];
MULR  R1.x, R0.y, R2.w;
MULR  R0.x, R0, R0.y;
MADR  R7.xyz, R1.x, c[5], R7;
MADR  R7.xyz, R0.x, c[4], R7;
ADDH  H0.z, H0, c[1].w;
MULH  H0.z, H0, c[2].x;
ADDR  R1.xy, R8, -c[0].zyzw;
MADH  H1.x, H0, c[2].y, -c[2].y;
MAXR  R7.xyz, R7, c[1].x;
MAXR  R6.xyz, R6, c[1].x;
MADH  H0.z, H1.y, c[1], H0;
RCPR  R0.y, c[0].y;
RCPR  R0.x, c[0].x;
MULR  R0.xy, R1, R0;
FRCR  R0.xy, R0;
ADDR  R6.xyz, R6, -R7;
MADR  R6.xyz, R0.x, R6, R7;
MADR  R2.xyz, R0.x, R3, R2;
ADDR  R2.xyz, R2, -R6;
MADR  R2.xyz, R0.y, R2, R6;
MULR  R3.xyz, R2.y, c[9];
MADR  R3.xyz, R2.x, c[8], R3;
MADR  R2.xyz, R2.z, c[7], R3;
ADDR  R1.x, R2, R2.y;
ADDR  R1.x, R2.z, R1;
RCPR  R1.x, R1.x;
MULR  R2.zw, R2.xyxy, R1.x;
MULR  R1.x, R2.z, c[3].z;
FLRR  R1.x, R1;
MINR  R0.w, R1.x, c[3].z;
MULR  R1.x, H1, c[2].z;
FRCR  R1.y, R1.x;
FLRR  R1.x, R1;
ADDR  R1.x, H0.z, R1;
MULR  R2.x, R1.y, c[3];
MULR  R1.y, R1.x, c[2].w;
ADDR  R1.x, -R1.y, -R2;
LG2H  H0.z, |R1.w|;
FLRH  H0.z, H0;
EX2H  H1.x, -H0.z;
MULH  H1.x, |R1.w|, H1;
ADDH  H0.z, H0, c[1].w;
MULH  H0.z, H0, c[2].x;
MADR  R1.x, R0.z, R1, R0.z;
RCPR  R2.x, R2.x;
MULR  R1.y, R0.z, R1;
MULR  R1.x, R1, R2;
SGER  H0.x, R0.w, c[1].z;
MULR  R1.y, R2.x, R1;
MULR  R3.xyz, R0.z, c[6];
MADR  R3.xyz, R1.y, c[5], R3;
MADR  R3.xyz, R1.x, c[4], R3;
MADH  H1.x, H1, c[2].y, -c[2].y;
MULR  R0.z, H1.x, c[2];
FRCR  R1.x, R0.z;
MULR  R1.y, R1.x, c[3].x;
RCPR  R1.w, R1.y;
MADH  H0.z, H1.w, c[1], H0;
FLRR  R0.z, R0;
ADDR  R0.z, H0, R0;
MULR  R1.x, R0.z, c[2].w;
ADDR  R0.z, -R1.x, -R1.y;
MADR  R0.z, R1, R0, R1;
MULR  R2.x, R1.z, R1;
MULR  R0.z, R0, R1.w;
LG2H  H0.z, |R5.w|;
FLRH  H0.z, H0;
EX2H  H1.x, -H0.z;
MULH  H1.x, |R5.w|, H1;
ADDH  H0.z, H0, c[1].w;
MULH  H0.z, H0, c[2].x;
MADH  H0.w, H0, c[1].z, H0.z;
LG2H  H0.z, |R4.w|;
MULR  R1.w, R1, R2.x;
MULR  R1.xyz, R1.z, c[6];
MADR  R1.xyz, R1.w, c[5], R1;
MADR  R1.xyz, R0.z, c[4], R1;
MADH  H1.x, H1, c[2].y, -c[2].y;
MULR  R0.z, H1.x, c[2];
FLRR  R1.w, R0.z;
ADDR  R1.w, H0, R1;
MULR  R3.w, R1, c[2];
FLRH  H0.z, H0;
EX2H  H0.w, -H0.z;
FRCR  R0.z, R0;
MULR  R4.y, R0.z, c[3].x;
ADDR  R2.z, -R3.w, -R4.y;
MULR  R4.x, R5.z, R3.w;
MADR  R2.z, R5, R2, R5;
RCPR  R3.w, R4.y;
MULH  H0.w, |R4|, H0;
MADH  H0.w, H0, c[2].y, -c[2].y;
MULR  R0.z, H0.w, c[2];
FRCR  R1.w, R0.z;
ADDH  H0.z, H0, c[1].w;
MULH  H0.z, H0, c[2].x;
MADH  H0.y, H0, c[1].z, H0.z;
FLRR  R0.z, R0;
ADDR  R0.z, H0.y, R0;
MULH  H0.y, H0.x, c[1].z;
ADDR  R0.w, R0, -H0.y;
MULR  R1.w, R1, c[3].x;
MULR  R0.z, R0, c[2].w;
ADDR  R2.x, -R0.z, -R1.w;
MAXR  R1.xyz, R1, c[1].x;
MAXR  R3.xyz, R3, c[1].x;
ADDR  R3.xyz, R3, -R1;
MADR  R1.xyz, R0.x, R3, R1;
MULR  R4.x, R3.w, R4;
MULR  R5.xyz, R5.z, c[6];
MADR  R5.xyz, R4.x, c[5], R5;
MULR  R2.z, R2, R3.w;
MADR  R5.xyz, R2.z, c[4], R5;
MULR  R2.z, R4, R0;
RCPR  R0.z, R1.w;
MADR  R2.x, R4.z, R2, R4.z;
MULR  R1.w, R0.z, R2.z;
MULR  R4.xyz, R4.z, c[6];
MULR  R0.z, R2.x, R0;
MADR  R4.xyz, R1.w, c[5], R4;
MADR  R4.xyz, R0.z, c[4], R4;
MAXR  R5.xyz, R5, c[1].x;
MAXR  R4.xyz, R4, c[1].x;
ADDR  R4.xyz, R4, -R5;
MADR  R3.xyz, R0.x, R4, R5;
ADDR  R3.xyz, R3, -R1;
MADR  R0.xyz, R0.y, R3, R1;
MULR  R1.xyz, R0.y, c[9];
MULR  R0.y, R0.w, c[3].w;
FLRR  H0.y, R0;
ADDH  H0.z, H0.y, -c[1].w;
MADR  R1.xyz, R0.x, c[8], R1;
MADR  R0.xyz, R0.z, c[7], R1;
ADDR  R1.x, R0, R0.y;
EX2H  H0.z, H0.z;
ADDR  R0.z, R0, R1.x;
MULH  H0.x, -H0, H0.z;
RCPR  R0.z, R0.z;
MULR  R1.xy, R0, R0.z;
MULH  H0.y, H0, c[2].x;
ADDR  R0.z, R0.w, -H0.y;
MULR  R0.x, R1, c[3].z;
FLRR  R0.x, R0;
MULR  R0.w, R2, c[6];
FLRR  R0.w, R0;
MINR  R0.w, R0, c[7];
MADH  H0.x, H0, c[4].w, H0.z;
MINR  R0.x, R0, c[3].z;
SGER  H0.z, R0.x, c[1];
MADR  R0.z, R0, c[5].w, R0.w;
MULH  H0.y, H0.z, c[1].z;
ADDR  R0.w, R0.x, -H0.y;
MOVR  R0.x, c[1].y;
MADR  H0.y, R0.z, c[8].w, R0.x;
MULR  R1.x, R0.w, c[3].w;
MULR  R0.z, R1.y, c[6].w;
FLRR  R0.z, R0;
FLRR  H0.w, R1.x;
MULH  oCol.y, H0.x, H0;
MULH  H0.x, H0.w, c[2];
ADDR  R0.w, R0, -H0.x;
ADDH  H0.x, H0.w, -c[1].w;
EX2H  H0.x, H0.x;
MULH  H0.y, -H0.z, H0.x;
MINR  R0.z, R0, c[7].w;
MADR  R0.z, R0.w, c[5].w, R0;
MADR  H0.z, R0, c[8].w, R0.x;
MADH  H0.x, H0.y, c[4].w, H0;
MULH  oCol.w, H0.x, H0.z;
MOVH  oCol.x, R2.y;
MOVH  oCol.z, R0.y;
END
# 277 instructions, 9 R-regs, 2 H-regs

"
}
SubProgram "d3d9 " {
Keywords { }
SetTexture 0 [_MainTex] 2D
Vector 0 [_dUV]

"ps_3_0
// cgc version 3.0.0016, build date Feb 11 2011
// command line args: -profile ps_3_0 -IC:\Program Files (x86)\Unity\Editor\Data\CGIncludes -DUNITY_MATRIX_MVP=glstate.matrix.mvp -DUNITY_MATRIX_TEXTURE0=glstate.matrix.texture[0] -DUNITY_MATRIX_P=glstate.matrix.projection -fastmath -glslWerror -strict
// source file: C:\UNITY\Project\Qlaud\Assets\Nuaj\Resources\Shaders\Sky\SkyUpScale.cg
//vendor NVIDIA Corporation
//version 3.0.0.16
//profile ps_3_0
//program PS
//semantic _Time
//semantic _SinTime
//semantic _CosTime
//semantic _ProjectionParams
//semantic _ScreenParams
//semantic unity_Scale
//semantic _WorldSpaceCameraPos
//semantic _WorldSpaceLightPos0
//semantic _Object2World
//semantic _World2Object
//semantic _LightPositionRange
//semantic unity_4LightPosX0
//semantic unity_4LightPosY0
//semantic unity_4LightPosZ0
//semantic unity_4LightAtten0
//semantic unity_LightColor
//semantic unity_LightPosition
//semantic unity_LightAtten
//semantic unity_LightColor0
//semantic unity_LightColor1
//semantic unity_LightColor2
//semantic unity_LightColor3
//semantic unity_SHAr
//semantic unity_SHAg
//semantic unity_SHAb
//semantic unity_SHBr
//semantic unity_SHBg
//semantic unity_SHBb
//semantic unity_SHC
//semantic _ZBufferParams
//semantic unity_LightShadowBias
//semantic _CameraData
//semantic _Camera2World
//semantic _World2Camera
//semantic _CameraDepthTexture
//semantic _MainTex
//semantic _dUV
//semantic _TargetdUV
//var float4 _In.UV : $vin.TEXCOORD0 : ATTR0 : 0 : 1
//var float4 _Time :  :  : -1 : 0
//var float4 _SinTime :  :  : -1 : 0
//var float4 _CosTime :  :  : -1 : 0
//var float4 _ProjectionParams :  :  : -1 : 0
//var float4 _ScreenParams :  :  : -1 : 0
//var float4 unity_Scale :  :  : -1 : 0
//var float3 _WorldSpaceCameraPos :  :  : -1 : 0
//var float4 _WorldSpaceLightPos0 :  :  : -1 : 0
//var float4x4 _Object2World :  : , 4 : -1 : 0
//var float4x4 _World2Object :  : , 4 : -1 : 0
//var float4 _LightPositionRange :  :  : -1 : 0
//var float4 unity_4LightPosX0 :  :  : -1 : 0
//var float4 unity_4LightPosY0 :  :  : -1 : 0
//var float4 unity_4LightPosZ0 :  :  : -1 : 0
//var float4 unity_4LightAtten0 :  :  : -1 : 0
//var float4 unity_LightColor[0] :  :  : -1 : 0
//var float4 unity_LightColor[1] :  :  : -1 : 0
//var float4 unity_LightColor[2] :  :  : -1 : 0
//var float4 unity_LightColor[3] :  :  : -1 : 0
//var float4 unity_LightPosition[0] :  :  : -1 : 0
//var float4 unity_LightPosition[1] :  :  : -1 : 0
//var float4 unity_LightPosition[2] :  :  : -1 : 0
//var float4 unity_LightPosition[3] :  :  : -1 : 0
//var float4 unity_LightAtten[0] :  :  : -1 : 0
//var float4 unity_LightAtten[1] :  :  : -1 : 0
//var float4 unity_LightAtten[2] :  :  : -1 : 0
//var float4 unity_LightAtten[3] :  :  : -1 : 0
//var float3 unity_LightColor0 :  :  : -1 : 0
//var float3 unity_LightColor1 :  :  : -1 : 0
//var float3 unity_LightColor2 :  :  : -1 : 0
//var float3 unity_LightColor3 :  :  : -1 : 0
//var float4 unity_SHAr :  :  : -1 : 0
//var float4 unity_SHAg :  :  : -1 : 0
//var float4 unity_SHAb :  :  : -1 : 0
//var float4 unity_SHBr :  :  : -1 : 0
//var float4 unity_SHBg :  :  : -1 : 0
//var float4 unity_SHBb :  :  : -1 : 0
//var float4 unity_SHC :  :  : -1 : 0
//var float4 _ZBufferParams :  :  : -1 : 0
//var float4 unity_LightShadowBias :  :  : -1 : 0
//var float4 _CameraData :  :  : -1 : 0
//var float4x4 _Camera2World :  : , 4 : -1 : 0
//var float4x4 _World2Camera :  : , 4 : -1 : 0
//var sampler2D _CameraDepthTexture :  :  : -1 : 0
//var sampler2D _MainTex :  : texunit 0 : -1 : 1
//var float4 _dUV :  : c[0] : -1 : 1
//var float4 _TargetdUV :  :  : -1 : 0
//var float4 PS : $vout.COLOR : COL : -1 : 1
//const c[1] = 1 0 15 4
//const c[2] = 128 -1 1024 0.00390625
//const c[3] = 0.0047619049 0.63999999 210 -128
//const c[4] = -1.0217 1.9777 0.043900002 0.25
//const c[5] = 2.5651 -1.1665 -0.39860001 -15
//const c[6] = 0.075300001 -0.2543 1.1892 400
//const c[7] = 0.26506799 0.67023426 0.064091571 255
//const c[8] = 0.51413637 0.32387859 0.16036376 256
//const c[9] = 0.0241188 0.1228178 0.84442663
//const c[10] = 2 1 0.0009765625
dcl_2d s0
def c1, 1.00000000, 0.00000000, 15.00000000, 4.00000000
def c2, 128.00000000, -1.00000000, 1024.00000000, 0.00390625
def c3, 0.00476190, 0.63999999, 210.00000000, -128.00000000
def c4, -1.02170002, 1.97770000, 0.04390000, 0.25000000
def c5, 2.56509995, -1.16649997, -0.39860001, -15.00000000
def c6, 0.07530000, -0.25430000, 1.18920004, 400.00000000
def c7, 0.26506799, 0.67023426, 0.06409157, 255.00000000
def c8, 0.51413637, 0.32387859, 0.16036376, 256.00000000
def c9, 0.02411880, 0.12281780, 0.84442663, 0
def c10, 2.00000000, 1.00000000, 0.00097656, 0
dcl_texcoord0 v0.xyzw
add r0.xy, v0, c0.xzzw
add r1.xy, r0, c0.zyzw
mov r1.z, v0.w
texldl r5, r1.xyzz, s0
abs_pp r0.z, r5.y
log_pp r0.w, r0.z
frc_pp r1.z, r0.w
add_pp r0.w, r0, -r1.z
exp_pp r1.z, -r0.w
mad_pp r0.z, r0, r1, c2.y
mul_pp r0.z, r0, c2
mul r1.z, r0, c2.w
frc r1.w, r1.z
add_pp r0.z, r0.w, c1
mul_pp r0.w, r0.z, c1
cmp_pp r0.z, -r5.y, c1.x, c1.y
mad_pp r0.z, r0, c2.x, r0.w
add r1.z, r1, -r1.w
add r0.z, r0, r1
add r6.xy, r1, -c0.xzzw
mul r0.w, r1, c3.y
mul r1.z, r0, c3.x
add r0.z, -r1, -r0.w
mov r6.z, v0.w
texldl r4, r6.xyzz, s0
abs_pp r2.x, r4.y
log_pp r1.y, r2.x
add r0.z, r0, c1.x
mul r0.z, r0, r5.x
rcp r1.x, r0.w
mul r0.w, r0.z, r1.x
frc_pp r1.w, r1.y
add_pp r0.z, r1.y, -r1.w
mul r1.y, r1.z, r5.x
exp_pp r1.z, -r0.z
mad_pp r2.x, r2, r1.z, c2.y
mul r1.w, r1.x, r1.y
mul r1.xyz, r5.x, c4
mad r1.xyz, r1.w, c5, r1
mul_pp r2.x, r2, c2.z
mul r1.w, r2.x, c2
frc r2.x, r1.w
mad r1.xyz, r0.w, c6, r1
add_pp r0.z, r0, c1
mul_pp r0.w, r0.z, c1
cmp_pp r0.z, -r4.y, c1.x, c1.y
add r1.w, r1, -r2.x
mad_pp r0.z, r0, c2.x, r0.w
add r0.z, r0, r1.w
mul r0.w, r0.z, c3.x
mul r1.w, r2.x, c3.y
add r0.z, -r0.w, -r1.w
add r0.z, r0, c1.x
mul r0.z, r0, r4.x
rcp r1.w, r1.w
mul r2.w, r0.z, r1
mul r2.x, r0.w, r4
mul r3.x, r1.w, r2
mul r2.xyz, r4.x, c4
mad r2.xyz, r3.x, c5, r2
mad r2.xyz, r2.w, c6, r2
mov r0.z, v0.w
texldl r0, r0.xyzz, s0
abs_pp r1.w, r0.y
log_pp r3.y, r1.w
frc_pp r3.x, r3.y
add_pp r2.w, r3.y, -r3.x
exp_pp r3.w, -r2.w
mad_pp r3.w, r1, r3, c2.y
mul_pp r3.w, r3, c2.z
mul r3.w, r3, c2
frc r4.y, r3.w
add r4.x, r3.w, -r4.y
mul r4.y, r4, c3
max r1.xyz, r1, c1.y
max r2.xyz, r2, c1.y
add r3.xyz, r1, -r2
texldl r1, v0, s0
abs_pp r5.x, r1.y
log_pp r5.y, r5.x
frc_pp r6.z, r5.y
add_pp r3.w, r5.y, -r6.z
add_pp r5.y, r2.w, c1.z
exp_pp r2.w, -r3.w
add_pp r3.w, r3, c1.z
mad_pp r2.w, r5.x, r2, c2.y
mul_pp r5.y, r5, c1.w
cmp_pp r0.y, -r0, c1.x, c1
mad_pp r0.y, r0, c2.x, r5
add r0.y, r0, r4.x
mul r4.x, r0.y, c3
mul_pp r0.y, r2.w, c2.z
mul r5.x, r0.y, c2.w
frc r0.y, r5.x
add r2.w, -r4.x, -r4.y
add r5.x, r5, -r0.y
mul_pp r3.w, r3, c1
cmp_pp r1.y, -r1, c1.x, c1
mad_pp r1.y, r1, c2.x, r3.w
add r3.w, r1.y, r5.x
mul r1.y, r0, c3
mul r0.y, r3.w, c3.x
add r3.w, r2, c1.x
add r5.x, -r0.y, -r1.y
add r2.w, r5.x, c1.x
mul r5.x, r4, r0
mul r3.w, r3, r0.x
rcp r4.x, r4.y
mul r7.xyz, r0.x, c4
mul r0.x, r4, r5
mad r7.xyz, r0.x, c5, r7
mul r0.x, r3.w, r4
mad r7.xyz, r0.x, c6, r7
mul r0.x, r2.w, r1
mul r2.w, r0.y, r1.x
rcp r0.y, r1.y
mul r8.xyz, r1.x, c4
mul r1.x, r0.y, r2.w
mul r0.x, r0, r0.y
mad r8.xyz, r1.x, c5, r8
mad r8.xyz, r0.x, c6, r8
add r1.xy, r6, -c0.zyzw
max r8.xyz, r8, c1.y
max r7.xyz, r7, c1.y
rcp r0.y, c0.y
rcp r0.x, c0.x
mul r0.xy, r1, r0
frc r0.xy, r0
add r6.xyz, r7, -r8
mad r6.xyz, r0.x, r6, r8
mad r2.xyz, r0.x, r3, r2
add r2.xyz, r2, -r6
mad r2.xyz, r0.y, r2, r6
mul r3.xyz, r2.y, c7
mad r3.xyz, r2.x, c8, r3
mad r2.xyz, r2.z, c9, r3
abs_pp r3.x, r0.w
abs_pp r3.z, r1.w
add r1.x, r2, r2.y
add r1.x, r2.z, r1
rcp r1.x, r1.x
mul r2.zw, r2.xyxy, r1.x
log_pp r1.y, r3.x
frc_pp r2.x, r1.y
add_pp r3.y, r1, -r2.x
mul r1.x, r2.z, c3.z
frc r1.y, r1.x
add r1.x, r1, -r1.y
exp_pp r2.x, -r3.y
mad_pp r1.y, r3.x, r2.x, c2
min r2.x, r1, c3.z
add r1.x, r2, c3.w
cmp r2.z, r1.x, c1.x, c1.y
add_pp r1.x, r3.y, c1.z
mul_pp r1.y, r1, c2.z
mul r1.y, r1, c2.w
frc r3.x, r1.y
add r1.y, r1, -r3.x
log_pp r3.w, r3.z
mul_pp r1.x, r1, c1.w
cmp_pp r0.w, -r0, c1.x, c1.y
mad_pp r0.w, r0, c2.x, r1.x
mul r1.x, r3, c3.y
add r0.w, r0, r1.y
mul r3.x, r0.w, c3
add r1.y, -r3.x, -r1.x
rcp r3.y, r1.x
frc_pp r1.x, r3.w
add_pp r1.x, r3.w, -r1
mul r3.x, r0.z, r3
exp_pp r4.x, -r1.x
mul_pp r0.w, r2.z, c2.x
add r1.y, r1, c1.x
mul r1.y, r0.z, r1
mul r1.y, r1, r3
mul r3.w, r3.y, r3.x
mad_pp r4.x, r3.z, r4, c2.y
mul r3.xyz, r0.z, c4
mad r3.xyz, r3.w, c5, r3
mul_pp r0.z, r4.x, c2
mul r3.w, r0.z, c2
mad r3.xyz, r1.y, c6, r3
frc r1.y, r3.w
add_pp r0.z, r1.x, c1
mul_pp r1.x, r0.z, c1.w
cmp_pp r0.z, -r1.w, c1.x, c1.y
mad_pp r0.z, r0, c2.x, r1.x
add r3.w, r3, -r1.y
mul r1.x, r1.y, c3.y
add r0.z, r0, r3.w
mul r0.z, r0, c3.x
add r1.y, -r0.z, -r1.x
rcp r1.w, r1.x
add r1.y, r1, c1.x
mul r1.x, r1.z, r1.y
mul r3.w, r1.x, r1
mul r1.x, r1.z, r0.z
mul r4.y, r1.w, r1.x
abs_pp r0.z, r4.w
log_pp r1.w, r0.z
frc_pp r4.x, r1.w
add_pp r1.w, r1, -r4.x
mul r1.xyz, r1.z, c4
mad r1.xyz, r4.y, c5, r1
mad r1.xyz, r3.w, c6, r1
exp_pp r3.w, -r1.w
mad_pp r0.z, r0, r3.w, c2.y
mul_pp r0.z, r0, c2
mul r4.y, r0.z, c2.w
frc r3.w, r4.y
abs_pp r4.x, r5.w
log_pp r0.z, r4.x
frc_pp r5.x, r0.z
add_pp r0.z, r0, -r5.x
add_pp r5.x, r1.w, c1.z
exp_pp r1.w, -r0.z
mad_pp r1.w, r4.x, r1, c2.y
mul_pp r1.w, r1, c2.z
add r4.y, r4, -r3.w
mul r1.w, r1, c2
add r0.w, r2.x, -r0
max r1.xyz, r1, c1.y
max r3.xyz, r3, c1.y
add r3.xyz, r3, -r1
mad r1.xyz, r0.x, r3, r1
mul_pp r5.x, r5, c1.w
cmp_pp r4.w, -r4, c1.x, c1.y
mad_pp r4.w, r4, c2.x, r5.x
add r4.y, r4.w, r4
mul r4.x, r4.y, c3
mul r4.y, r3.w, c3
frc r3.w, r1
add r5.x, r1.w, -r3.w
add r4.w, -r4.x, -r4.y
add_pp r0.z, r0, c1
mul_pp r1.w, r0.z, c1
cmp_pp r0.z, -r5.w, c1.x, c1.y
mad_pp r0.z, r0, c2.x, r1.w
add r0.z, r0, r5.x
add r4.w, r4, c1.x
mul r1.w, r0.z, c3.x
mul r3.w, r3, c3.y
add r0.z, -r1.w, -r3.w
add r0.z, r0, c1.x
rcp r5.x, r4.y
mul r4.w, r4.z, r4
mul r5.y, r4.z, r4.x
mul r4.w, r4, r5.x
mul r5.y, r5.x, r5
mul r4.xyz, r4.z, c4
mad r4.xyz, r5.y, c5, r4
mad r4.xyz, r4.w, c6, r4
mul r4.w, r5.z, r1
rcp r1.w, r3.w
mul r0.z, r5, r0
max r4.xyz, r4, c1.y
mul r0.z, r0, r1.w
mul r5.xyz, r5.z, c4
mul r3.w, r1, r4
mad r5.xyz, r3.w, c5, r5
mad r5.xyz, r0.z, c6, r5
max r5.xyz, r5, c1.y
add r5.xyz, r5, -r4
mad r3.xyz, r0.x, r5, r4
add r3.xyz, r3, -r1
mad r3.xyz, r0.y, r3, r1
mul r0.x, r0.w, c4.w
mul r1.xyz, r3.y, c7
mad r4.xyz, r3.x, c8, r1
frc r0.y, r0.x
add r1.z, r0.x, -r0.y
mad r0.xyz, r3.z, c9, r4
add_pp r1.x, r1.z, c5.w
add r1.y, r0.x, r0
add r1.y, r0.z, r1
exp_pp r1.x, r1.x
mad_pp r0.z, -r2, c10.x, c10.y
mul_pp r0.z, r0, r1.x
rcp r1.y, r1.y
mul r1.xy, r0, r1.y
mul_pp r0.x, r1.z, c1.w
mul r1.x, r1, c3.z
add r0.x, r0.w, -r0
frc r1.z, r1.x
add r1.z, r1.x, -r1
mul r0.w, r2, c6
frc r1.x, r0.w
add r0.w, r0, -r1.x
min r1.z, r1, c3
add r1.x, r1.z, c3.w
min r0.w, r0, c7
mad r0.x, r0, c8.w, r0.w
cmp r1.x, r1, c1, c1.y
mad r0.x, r0, c10.z, c10.y
mul_pp r0.w, r1.x, c2.x
add r0.w, r1.z, -r0
mul_pp oC0.y, r0.z, r0.x
mul r0.x, r0.w, c4.w
frc r0.z, r0.x
add r0.x, r0, -r0.z
mul_pp r0.z, r0.x, c1.w
mul r1.y, r1, c6.w
frc r1.z, r1.y
add r1.y, r1, -r1.z
add r0.z, r0.w, -r0
min r1.y, r1, c7.w
mad r0.z, r0, c8.w, r1.y
add_pp r0.x, r0, c5.w
mad r0.w, r0.z, c10.z, c10.y
exp_pp r0.z, r0.x
mad_pp r0.x, -r1, c10, c10.y
mul_pp r0.x, r0, r0.z
mul_pp oC0.w, r0.x, r0
mov_pp oC0.x, r2.y
mov_pp oC0.z, r0.y

"
}

}

		}
	}
	Fallback off
}
