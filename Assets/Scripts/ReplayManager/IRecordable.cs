// Recordable.cs
// Description
// Dean Stanfield & Kyle Hatch

using UnityEngine;
using System.Collections;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System;

public class IRecordable 
{	
	public string objectName;
	
	public GameObject gameObject;
	
	public virtual void Init(GameObject go) { }
	
    public virtual void Serialise() { }

    public virtual void Deserialise(IRecordable snapShot) { }
}
