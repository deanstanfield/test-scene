/// <summary>
///	Name: Control.cs
/// Author: Kyle Hatch
/// Date Created: 18/06/2012
/// Date Edited: 19/06/2012 by Kyle Hatch
/// 
/// Description: Controls the cube, message testing
/// </summary>
 
using UnityEngine;
using System.Collections;

public class CubeControl_Test : MonoBehaviour 
{
	float m_fSpeed;
	Vector3 m_Position;
	float r;
	
	// Use this for initialization
	void Start () 
	{
		r = Random.Range(-10, 10);
		m_fSpeed = 5.5f;	
		Messenger.AddListener<float>("move cube", MoveObject);
	}
	
	// Update is called once per frame
	void Update () 
	{
		if(ReplayManager.StreamingIn)
		{
			GetInput();
			Messenger.Broadcast<float>("move cube", m_fSpeed * Time.deltaTime);
			gameObject.transform.Rotate(new Vector3(1 * r, 0, 1 * r));
		}
		
		
	}
	
	void MoveObject(float vec_value)
	{
		//gameObject.transform.Rotate(new Vector3(vec_value, 0, vec_value));
		gameObject.transform.position = new Vector3(m_Position.x, m_Position.y, 0);
	}
	
	void GetInput()
	{		
		if(Input.GetKey(KeyCode.LeftArrow))
		{
			m_Position.x = m_Position.x - (m_fSpeed * Time.deltaTime);
		}
		if(Input.GetKey(KeyCode.RightArrow))
		{
			m_Position.x = m_Position.x + (m_fSpeed * Time.deltaTime);
		}
		if(Input.GetKey(KeyCode.UpArrow))
		{
			m_Position.y = m_Position.y + (m_fSpeed * Time.deltaTime);
		}
		if(Input.GetKey(KeyCode.DownArrow))
		{
			m_Position.y = m_Position.y - (m_fSpeed * Time.deltaTime);
		}
	}
	
	public void SetPosition(Vector3 Position)
	{
		m_Position = Position;
	}
}


	