/// <summary>
///	Name: ReplayManager.cs
/// Author: Kyle Hatch
/// Date Created: 18/06/2012
/// Date Edited: 19/06/2012 by Kyle Hatch
/// 
/// Description: Controls the replay information, reads and saves the data here
/// </summary>
 
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

//Examples: Marshalls.
struct StaticDetails 
{
	public string m_sAnimationName;
	public float m_fAnimationFrameNumber;
}

//Examples: 
struct DynamicDetails 
{
	public string m_sAnimationName;
	public float m_fAnimationFrameNumber;
	public Vector3 m_Position;
	public Vector3 m_Scale;
	public Quaternion m_Rotation;
	public Vector3 m_Velocity;
	public Vector3 m_Direction;
}

//Examples: joystick controlled airplane
struct PlayableDynamicDetails 
{
	public string m_sAnimationName;
	public float m_fAnimationFrameNumber;
	public Vector3 m_Position;
	public Vector3 m_Scale;
	public Quaternion m_Rotation;
	public Vector3 m_Velocity;
	public Vector3 m_Direction;
	public int m_iFrame;
}

//Examples: Cones
struct StaticHazardDetails 
{
	public int m_iObjectID;
	public bool m_bAction;
	public int m_iFrame;
}

//Examples: Moving car
struct DynamicHazardDetails 
{
	public int m_iObjectID;
	public bool m_bIn;
	public bool m_bOut;
	public int m_iFrame;
}

public static class ReplayManager
{
//	static Dictionary<GameObject, StaticDetails[]> m_StaticWatchlist = new Dictionary<GameObject, StaticDetails[]>();
	//static Dictionary<GameObject,   DynamicDetails[]> m_DynamicWatchlist = new Dictionary<GameObject, DynamicDetails[]>();
	static Dictionary<GameObject, PlayableDynamicDetails[]> m_PlayableDynamicWatchlist = new Dictionary<GameObject, PlayableDynamicDetails[]>();
	//static Dictionary<GameObject, StaticHazardDetails[]> m_StaticHazardsWatchlist = new Dictionary<GameObject, StaticHazardDetails[]>();
	//static Dictionary<GameObject, DynamicHazardDetails[]> m_DynamicHazardsWatchlist = new Dictionary<GameObject, DynamicHazardDetails[]>();
	
	public static void SignupTo(int ObjectType, GameObject g)
	{
		switch(ObjectType)
		{
			case 2:
				PlayableDynamicDetails[] PDD = new PlayableDynamicDetails[65536]; //2 power 16
				PDD[0].m_sAnimationName = "Rotate";
				PDD[0].m_fAnimationFrameNumber = 0;
				PDD[0].m_Position = g.transform.position;
				PDD[0].m_Rotation = g.transform.rotation;
				PDD[0].m_Scale = g.transform.localScale;
				PDD[0].m_Direction = new Vector3(0,0,0);
				PDD[0].m_Velocity = new Vector3(0,0,0);
				PDD[0].m_iFrame = TimeLine.GetFrameCount();
				m_PlayableDynamicWatchlist.Add(g, PDD);
			break;
		}
	}
	
	public static void Init()
	{
		/*foreach(KeyValuePair<int, GameObject> go in SceneManager.GetListOfObjects())
		{
			//split up which items go into which list, later on we can check to see if
			//the gameobject is contained into the list.
			GameObject g = go.Value;
			/*if(g.tag == "StaticObj")
			{
//				StaticDetails[] SD = new StaticDetails[65536]; //2 power 16
//				SD[0].m_sAnimationName = g.GetComponent<GooberScript>().GetAnimationName();
//				SD[0].m_fAnimationFrameNumber = g.animation[SD[0].m_sAnimationName].length;
//				m_StaticWatchlist.Add(g, SD);
			}
			else if(g.tag == "DynamicObj")
			{
			}		
			else if(g.tag == "PlayableDynamic")
			{		
				PlayableDynamicDetails[] PDD = new PlayableDynamicDetails[65536]; //2 power 16
				PDD[0].m_sAnimationName = "Rotate";
				PDD[0].m_fAnimationFrameNumber = 0;
				PDD[0].m_Position = g.transform.position;
				PDD[0].m_Rotation = g.transform.rotation;
				PDD[0].m_Scale = g.transform.localScale;
				PDD[0].m_Direction = new Vector3(0,0,0);
				PDD[0].m_Velocity = new Vector3(0,0,0);
				PDD[0].m_iFrame = TimeLine.GetFrameCount();
				m_PlayableDynamicWatchlist.Add(g, PDD);
			}
			else if(g.tag == "StaticHazard")
			{
			}
			else if(g.tag == "DynamicHazard")
			{
			}
		}*/
	}
	
	//Only called on button presses
	public static void SaveState() 
	{
		/*foreach(KeyValuePair<int, GameObject> go in SceneManager.GetListOfObjects())
		{
			GameObject g = go.Value;
			if(g.tag == "StaticObj")
			{
				//array???
				//StaticDetails SD; //2 power 16
				//SD.m_sAnimationName = g.GetComponent<GooberScript_Test>().GetAnimationName();
				//SD.m_fAnimationFrameNumber = g.animation[SD.m_sAnimationName].length;
				//m_StaticWatchlist.Add(g, SD);
			}
		}*/
	}
	
	public static void FixedUpdate()
	{
		List<GameObject> keys = new List<GameObject>(m_PlayableDynamicWatchlist.Keys);
		foreach(GameObject key in keys)
		{
			PlayableDynamicDetails[] PDD;
			if(m_PlayableDynamicWatchlist.TryGetValue(key, out PDD)) 
			{
				int length = TimeLine.GetFrameCount();
				PDD[length].m_sAnimationName = "Rotate";
				PDD[length].m_fAnimationFrameNumber = 0;
				PDD[length].m_Position = key.transform.position;
				PDD[length].m_Rotation = key.transform.rotation;
				PDD[length].m_Scale = key.transform.localScale;
				PDD[length].m_Direction = new Vector3(0,0,0);
				PDD[length].m_Velocity = new Vector3(0,0,0);
				PDD[length].m_iFrame = TimeLine.GetFrameCount();
				m_PlayableDynamicWatchlist[key] = PDD;	
			}
		}
	}
	
	public static void ReplayPlayableDynamic()
	{	
		foreach(KeyValuePair<GameObject, PlayableDynamicDetails[]> go in m_PlayableDynamicWatchlist)
		{
			GameObject g = go.Key;
			PlayableDynamicDetails[] PDD = m_PlayableDynamicWatchlist[g];
			g.transform.position = PDD[PlaybackManager.GetCurrentFrame()].m_Position;
			g.transform.rotation = PDD[PlaybackManager.GetCurrentFrame()].m_Rotation;
			g.transform.localScale = PDD[PlaybackManager.GetCurrentFrame()].m_Scale;
}
	}
	
	public static void TrimWatchLists()
	{
		//Playable Dynamics
		List<GameObject> keys = new List<GameObject>(m_PlayableDynamicWatchlist.Keys);
		foreach(GameObject key in keys)
		{
			PlayableDynamicDetails[] OrginalPDDetails, TrimmedPDDetails;
			TrimmedPDDetails = new PlayableDynamicDetails[PlaybackManager.GetTotalFrames()];
			
			if(m_PlayableDynamicWatchlist.TryGetValue(key, out OrginalPDDetails)) 
			{
				Array.Copy(OrginalPDDetails, 0, TrimmedPDDetails, 0, PlaybackManager.GetTotalFrames());
				m_PlayableDynamicWatchlist[key] = TrimmedPDDetails;
			}
		}
	}
}