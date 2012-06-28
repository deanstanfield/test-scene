/// <summary>
///	Name: TimeLine.cs
/// Author: Kyle Hatch
/// Date Created: 18/06/2012
/// Date Edited: 19/06/2012 by Kyle Hatch
/// 
/// Description: Holds the timeline data
/// </summary>

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public static class TimeLine
{
	static bool m_bActiveSession;		//is the session active
	static bool m_bStreamingSession;	//replay recording
	static bool m_bEventOccured;		//has a button been pressed
	static int m_iFrameCount;			//Current frame count, not active when session isn't
	
	static List<float> m_CheckpointTimes 
					= new List<float>();//List of checkpoint
	static float m_fTime;				//actual time
	
	//Copy of List of Objects
	//static Dictionary<int, GameObject> m_ListOfObjects;
	
	public static void Init()
	{
		m_bActiveSession = true;
		m_bStreamingSession = true;
		m_fTime = 0;
		m_bEventOccured = true;
		m_CheckpointTimes.Clear();
		
		//m_ListOfObjects = SceneManager.GetListOfObjects();//ListOfObjects;
		ReplayManager.Init(/*m_ListOfObjects*/); //copy hashtable into replaymanager
		
	}
	
	public static void ManualLateUpdate()
	{
		if(!m_bActiveSession)
			return;
				
		if(m_bEventOccured)	
		{
			ReplayManager.SaveState();
			m_bEventOccured = false;
		}
	}
	
	public static void ManualFixedUpdate()
	{
		if(m_bStreamingSession && m_bActiveSession)
		{ 
			//recording
			ReplayManager.FixedUpdate(/*m_ListOfObjects*/); 
			m_iFrameCount++;
			m_fTime = Time.deltaTime;
		}
		else if(!m_bStreamingSession && m_bActiveSession) 
		{
			//playback
			ReplayManager.ReplayPlayableDynamic(/*m_ListOfObjects*/);
		}
	}
	
	public static bool GetActiveSession()
	{
		return m_bActiveSession;
	}
	
	public static void SetActiveSession(bool bActiveSession)
	{
		m_bActiveSession = bActiveSession;
	}
	
	public static bool GetStreamingSession()
	{
		return m_bStreamingSession;
	}
	
	public static void SetStreamingSession(bool bStreamingSession)
	{
		m_bStreamingSession = bStreamingSession;
	}
		
	public static int GetFrameCount()
	{
		return m_iFrameCount;
	}
	
	public static float GetTime()
	{
		return m_fTime;
	}
	
	public static bool GetEventOccured()
	{
		return m_bEventOccured;
	}
	
	public static void SetEventOccured(bool bEventOccured)
	{
		m_bEventOccured = bEventOccured;
	}
}
		