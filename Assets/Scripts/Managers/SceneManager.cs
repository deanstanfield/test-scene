/// <summary>
///	Name: SceneManager.cs
/// Author: Kyle Hatch
/// Date Created: 18/06/2012
/// Date Edited: 19/06/2012 by Kyle Hatch
/// 
/// Description: Creates the scene, updates events.
/// </summary>

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class SceneManager : MonoBehaviour
{
	List<GameObject> m_MoveableObjects;
	static Dictionary<int, GameObject> m_ListOfObjects = new Dictionary<int, GameObject>();

	//Playback
	bool m_bPlayback;
	bool m_ShowRealTimeLine;
	
	//GUI Timeline Notches
	static ArrayList m_Notches = new ArrayList();
	
	void Start()
	{
		//Setup Objects and add to list
		string[] sArrayOfTags = new string[5];
		sArrayOfTags[0] = "StaticObj";
		sArrayOfTags[1] = "DynamicObj";
		sArrayOfTags[2] = "PlayableDynamic";
		sArrayOfTags[3] = "StaticHazard";
		sArrayOfTags[4] = "DynamicHazard";
		
		m_MoveableObjects = FindGameObjectsWithTags(sArrayOfTags);
		for(int i = 0; i < m_MoveableObjects.Count; i++)
		{
			m_ListOfObjects.Add(i, m_MoveableObjects[i]);	
			
			//Add control classes
			if(m_MoveableObjects[i].tag == "PlayableDynamic")
			{				
				m_MoveableObjects[i].AddComponent<CubeControl_Test>(); //added controller
				m_MoveableObjects[i].GetComponent<CubeControl_Test>().SetPosition(m_MoveableObjects[i].transform.position);
			}
			else if(m_MoveableObjects[i].tag == "StaticObj")
			{
				m_MoveableObjects[i].AddComponent<GooberScript_Test>(); 
			}
		}
		
		//setup Timeline
		TimeLine.Init(); 
	}
	
	void FixedUpdate()
	{
		TimeLine.ManualFixedUpdate();
	}
	
	void LateUpdate()
	{
		TimeLine.ManualLateUpdate();	
		
		if(TimeLine.GetActiveSession() && !TimeLine.GetStreamingSession() && !m_bPlayback)
		{		
			m_bPlayback = true;
		}		
		else if(m_bPlayback)
		{
			//if current frame goes past end, set to end...else count up.
			//Total frames is X, array will need to count to x-1.
			if(PlaybackManager.GetCurrentFrame() >= PlaybackManager.GetTotalFrames() -1)
			{
				PlaybackManager.SetCurrentFrame(PlaybackManager.GetTotalFrames() - 1);
				//m_bPlayback = false;
			}
			else
				PlaybackManager.SetCurrentFrame(PlaybackManager.GetCurrentFrame() + 1);
		}
		else if(TimeLine.GetActiveSession() && TimeLine.GetStreamingSession())
		{
			PlaybackManager.setTotalFrames(TimeLine.GetFrameCount());
		}
	}
	
	void Update()
	{
		
	}
	
	void OnGUI()
	{
		if(GUI.Button(new Rect(0, 0, 100, 50), "Stop"))
		{
			TimeLine.SetActiveSession(false);
			TimeLine.SetStreamingSession(false);
		}
		
		if(GUI.Button(new Rect(0, 60, 100, 50), "Replay"))
		{
			//Setup playback manager 
			PlaybackManager.Init();
			m_ShowRealTimeLine = true;
			TimeLine.SetActiveSession(true);
			TimeLine.SetStreamingSession(false);
		}
			
		//if(m_ShowRealTimeLine)
		//{
			float[] notch = m_Notches.ToArray(typeof(float)) as float[];
			PlaybackManager.SetCurrentFrame((int)GUIHelp.GUITimeline(new Rect(110, 25, Screen.width - 120, 30), PlaybackManager.GetCurrentFrame(), 0.0f, PlaybackManager.GetTotalFrames(), notch));
		/*}
		else
		{
			PlaybackManager.SetCurrentFrame((int)GUI.HorizontalSlider(new Rect(110, 25, Screen.width - 120, 30), PlaybackManager.GetCurrentFrame(), 0.0f, PlaybackManager.GetTotalFrames()));
		}*/
	}
	
	/*void UpdateGameObjects(Dictionary<int, GameObject> table)
	{
		m_ListOfObjects = table;
	}*/
	
	public static Dictionary<int, GameObject> GetListOfObjects()
	{
		return m_ListOfObjects;	
	}
	
	public static ArrayList GetTimeNotch()
	{
		return m_Notches;
	}
	
	
	//function that takes an array of tags and adds them all to one list
	List<GameObject> FindGameObjectsWithTags (string[] tags) 
	{
    	List<GameObject> combinedList = new List<GameObject>();
    	for (int i = 0; i < tags.Length; i++) 
		{
      		GameObject[] taggedObjects = GameObject.FindGameObjectsWithTag(tags[i]);
       		combinedList.AddRange(taggedObjects);
    	}
    	return combinedList;
	}
	
	
}