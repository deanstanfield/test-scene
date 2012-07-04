// ReplayManager.cs
// Description
// Dean Stanfield & Kyle Hatch

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

public static class ReplayManager 
{	
	#region Recording properties    
	//Dictionary of all recorded states that have been recorded
	static Dictionary<string, IRecordable[]> m_DictOfRecords = new Dictionary<string, IRecordable[]>();
	
	//Max number of save states for each frame
    static int m_iMaxRecordedPerFrame = 150;
	//List of recorded save states. This is added to the Dictionay of All objects at the end of each frame.
    static IRecordable[] m_ObjectsUpdatedThisFrame = new IRecordable[m_iMaxRecordedPerFrame];
	
	//Counter for how many objects have requested to create save states this frame
	static int m_iAddedThisFrame = 0;
    #endregion
	
	#region ReplayManager Properties
    static bool isStreaming = false;				//Is the replay manager streaming data in? (i.e Recording) If isStreaming is false the player is playing back a recording
    static bool sessionActive = false;				//Is the replay manager active?
	#endregion
	
	#region Getters and Setters
	/// <summary>
	/// Gets or sets a value indicating whether this <see cref="ReplayManager"/> Is the ReplayManager currently active.
	/// </summary>
	/// <value>
	/// <c>true</c> if session active; otherwise, <c>false</c>.
	/// </value>
    public static bool SessionActive
    {
        get { return sessionActive; }
        set { sessionActive = value; }
    }
	
	/// <summary>
	/// Gets or sets a value indicating whether this <see cref="ReplayManager"/> Is the ReplayManager currently streaming in recorded data
	/// </summary>
	/// <value>
	/// <c>true</c> if true the ReplayManager is recording; otherwise, the replay manager is replaying a recording <c>false</c>.
	/// </value>
    public static bool StreamingIn
    {
        get { return isStreaming; }
        set { isStreaming = value; }
    }
	#endregion
	
	#region Saving states
	/// <summary>
	/// Saves the state of a given object using the IRecordable class
	/// </summary>
	/// <param name='dataStruct'>
	/// The overrided IRecordable with the current stored data for this object
	/// </param>
    public static void SaveState(IRecordable dataStruct)
    {	
		//Safety just incase this is called while not recording
		if(!SessionActive || !isStreaming)
			return;
		
		//Stop multiple adds of item... check if this frame exists
		if (!IsInFrame(dataStruct)) //Check if this dataStruct exists in this frame (The saved object has already been saved)
		{
            m_ObjectsUpdatedThisFrame[m_iAddedThisFrame] = dataStruct;
            m_iAddedThisFrame++;
		}
    }
	
	/// <summary>
    /// Check to see if this Data is in the current frame already
    /// Stops duplicate entries, returns true is data is already in the list
    /// </summary>
    /// <param name="dataStruct"></param>
    /// <returns></returns>
    private static bool IsInFrame(IRecordable dataStruct)
    {
        for (int i = 0; i < m_iAddedThisFrame; i++)
        {
            if (m_ObjectsUpdatedThisFrame[i] == dataStruct)
                return true;
        }
        return false;
    }
	
	/// <summary>
    /// This should be called once each fixed Update
    /// This method takes all the events fired this frame and stores them against the timeline
    /// </summary>
    /// <param name="snapShot"></param>
    public static void FixedUpdate()
    {
		//Safety just incase this is called while not recording
		if(!SessionActive || !isStreaming)
			return;
		
        //Add to Dictionary all structures in the objects updated this frame list
		if(m_iAddedThisFrame > 0)
		{
			m_DictOfRecords.Add(TimeLine.GetFrameCount().ToString(), m_ObjectsUpdatedThisFrame);
			m_ObjectsUpdatedThisFrame = new IRecordable[m_iMaxRecordedPerFrame];
		}
		
        //Clear list
        m_iAddedThisFrame = 0;
    }
	#endregion
	
    /// <summary>
    /// This should be called once each fixed update
    /// This method streams the playback data to the correct game objects in the scene
    /// </summary>
    public static void StreamRecording()
    {
    	int currentFrame = PlaybackManager.GetCurrentFrame();
		
		//Check to see if this frame is in the Dictionary... if not return as there is no data to stream
		if(!m_DictOfRecords.ContainsKey(currentFrame.ToString()))
			return;
		
        IRecordable[] updatedThisFrame = new IRecordable[m_DictOfRecords[currentFrame.ToString()].Length];
        updatedThisFrame = m_DictOfRecords[currentFrame.ToString()];
		//Debug.Log("Num frame: " + currentFrame.ToString());
			
        //Foreach value in list... get gameobject and call its Restore state method passing over its structure of data
        for(int i = 0; i < updatedThisFrame.Length; i++)
        {
            if (updatedThisFrame[i] == null)
                Debug.Log("Object " + updatedThisFrame[i].objectName + " is null");
            updatedThisFrame[i].Deserialise(updatedThisFrame[i]);
        }
    }
	
	/// <summary>
	/// Trims the watch lists. Optimisation
	/// </summary>
    public static void TrimWatchLists()
    {
        List<string> keys = new List<string>(m_DictOfRecords.Keys);
        
        foreach (string k in keys)
        {
            int count = 0;
            IRecordable[] original;     //The original values
            IRecordable[] trim;         //The trimmed list
			
            //Count the array until we hit a null
            if (m_DictOfRecords.TryGetValue(k, out original))
            {
                //There is data inside this index
                for (int i = 0; i < original.Length; i++)
                {
                    if(original[i] != null)
                        count++;
                    else
                        break;
                }
                //Create a 'trimmed' list of the exact size
                trim = new IRecordable[count];

                //copy the data into the the trimed list
                Array.Copy(original, 0, trim, 0, count);

                //Copy trimmed list back into the dictionary
                m_DictOfRecords[k] = trim;
            }

        }
    }
	
}
