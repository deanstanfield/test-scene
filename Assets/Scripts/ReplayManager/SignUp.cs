/// <summary>
///	Name: SignUp.cs
/// Author: Kyle Hatch
/// Date Created: 18/06/2012
/// Date Edited: 19/06/2012 by Kyle Hatch
/// 
/// Description: Controls the replay information, reads and saves the data here
/// </summary>
 
using UnityEngine;
using System.Collections;

public class SignUp : MonoBehaviour
{
	[HideInInspector]
	public enum ObjectType { Static, Dynamic, PlayableDynamic, StaticHazard, DynamicHazard};
	
	public ObjectType objectType = ObjectType.Static;

    public IRecordable myRecorder;
	Vector3 lastPosition = Vector3.zero;

    void Start()
    {
        myRecorder = new DynamicRecord();
    }
	
    void FixedUpdate()
    {
		if(ReplayManager.SessionActive && ReplayManager.StreamingIn)
		{
			if(lastPosition != transform.position)
			{
				DynamicRecord dr = new DynamicRecord();
				
				dr.objectName = gameObject.name;
				dr.gameObject = gameObject;
		        dr.frameNumber = TimeLine.GetFrameCount();
		        dr.animationName = "HELLO";
		        dr.animationFrameNumber = 0;
				dr.position = gameObject.transform.position;
				dr.rotation = gameObject.transform.rotation;
				
				ReplayManager.SaveState(dr);
				
				//Update last position
				lastPosition = transform.position;
			}
		}
    }
}