/// <summary>
///	Name: PlaybackManager.cs
/// Author: Kyle Hatch
/// Date Created: 19/06/2012
/// Date Edited: 19/06/2012 by Kyle Hatch
/// 
/// Description: Replays the scene
/// </summary>

using UnityEngine;
using System.Collections;
using System.Collections.Generic;


public class PlaybackManager
{
	static int m_iCurrentFrame;
	static int m_iTotalFrames;
	
	public static void Init()
	{
		m_iCurrentFrame = 0;
		m_iTotalFrames = TimeLine.GetFrameCount();
		ReplayManager.TrimWatchLists(/*SceneManager.GetListOfObjects()*/);
	}
	
	public static int GetTotalFrames()
	{
		return m_iTotalFrames;
	}
	
	public static void setTotalFrames(int iTotalFrames)
	{
		m_iTotalFrames = iTotalFrames;
	}
	
	public static int GetCurrentFrame()
	{
		
		return m_iCurrentFrame;
	}
	
	public static void SetCurrentFrame(int iCurrentFrame)
	{
		m_iCurrentFrame	= iCurrentFrame;
	}
}