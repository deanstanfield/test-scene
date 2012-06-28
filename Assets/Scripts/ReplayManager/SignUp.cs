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
	public int ObjectType = 2;
	
	void Start()
	{
		ReplayManager.SignupTo(ObjectType, gameObject);	
	}
}