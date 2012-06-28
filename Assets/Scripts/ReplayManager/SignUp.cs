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
	
	void Start()
	{
		ReplayManager.SignupTo(objectType, gameObject);	
	}
}