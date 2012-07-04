// DynamicRecord.cs
// Description
// Dean Stanfield & Kyle Hatch

using UnityEngine;
using System.Collections;
using System.Runtime.Serialization;
using System;
using System.Xml;
using System.Xml.Serialization;

public class DynamicRecord : IRecordable
{    
	//*******************************//
	// Private Member Data           //
	//*******************************//
  
    public string animationName = "";
    public int animationFrameNumber = 0;
    public int frameNumber = 0;
	public Vector3 position = Vector3.zero;
	public Quaternion rotation = Quaternion.identity;
	
	//*******************************//
	// Private Methods               //
	//*******************************//

    public override void Deserialise(IRecordable snapShot)
    {
		//Has the object disappeared?
        if (!gameObject)
        {
            Debug.LogWarning("Couldnt Find Game Object: " + snapShot.objectName);
            //find the gameObject using name
            gameObject = GameObject.Find(snapShot.objectName);
			
			//Is the object still null?
			if(!gameObject)
			{
				Debug.LogWarning("Game object is not present in scene... Attempting to create the object");
				gameObject = GameObject.Instantiate(Resources.Load("Prefabs/Cube") as GameObject, Vector3.zero, Quaternion.identity) as GameObject;
				gameObject.name = snapShot.objectName;
			}
        }
        DynamicRecord data = (DynamicRecord)snapShot;
       // Debug.Log("Object " + name + " Position(" + data.positionX.ToString() + ", " + data.positionY.ToString() + ", " + data.positionZ + ")");
        gameObject.transform.position = data.position;
    }
	
}
