using UnityEngine;
using System.Collections;

public class GUIManager : MonoBehaviour
{
	float m_fLocalResoultionWidth, m_fLocalResoultionHeight, m_fLocalGUIOffsetX, m_fLocalGUIOffsetY;

	Rect m_TestRect1, m_TestRect2, m_TestRect3, m_TestRect4, m_TestRect5;
	
	void Start()
	{
		m_fLocalResoultionWidth = gameObject.GetComponent<LoadSetupXML>().GetResoultionWidth();
		m_fLocalResoultionHeight = gameObject.GetComponent<LoadSetupXML>().GetResoultionHeight(); 
		m_fLocalGUIOffsetX = gameObject.GetComponent<LoadSetupXML>().GetGUIOffsetX();
		m_fLocalGUIOffsetY = gameObject.GetComponent<LoadSetupXML>().GetGUIOffsetY();
		
		m_TestRect1 = new Rect(0, 0, 500, 100);
		m_TestRect2 = new Rect(0, m_fLocalResoultionHeight - 100, 100, 100);
		m_TestRect3 = new Rect((m_fLocalResoultionWidth / 5) - 100, 0, 100, 100); 
		m_TestRect4 = new Rect((m_fLocalResoultionWidth / 5) - 100, m_fLocalResoultionHeight - 100, 100, 100);
		m_TestRect5 = new Rect(145, 200, 100, 100);
	}
	
	void OnGUI()
	{
		GUI.matrix = Matrix4x4.TRS(new Vector3(0, 0, 0), Quaternion.identity, new Vector3(1.0f, 1.0f, 1.0f)); //6079 SW
		
		/*GUI.matrix = Matrix4x4.Scale(new Vector3(6400.0f / m_fLocalResoultionWidth, 
		                                   960.0f / m_fLocalResoultionHeight, 1.0f));*/
		
		//Vector3 mouseInput = Input.mousePosition;
		
		string t = GUIUtility.ScreenToGUIPoint(Input.mousePosition).ToString();
		string s = Input.mousePosition.ToString();
		string w = "W: " + Screen.width + " H: " + Screen.height;
		string compile = "MI: " + s + "  STGP: " + t + " Screen: " + w;
		GUI.Label(m_TestRect1, compile);
		if(Input.GetMouseButtonDown(0))
			Debug.Log(compile);
		
		Debug.Log("W: " + Screen.width + " H: " + Screen.height);
		
		/*Vector2 screenPos = Event.current.mousePosition;
        //GUI.BeginGroup(new Rect(0, 0, 1280, 1024));
        Vector2 convertedGUIPos = GUIUtility.ScreenToGUIPoint(screenPos);
        //GUI.EndGroup();
		
		string compile = "Screen: " + screenPos + " GUI: " + convertedGUIPos;
        GUI.Label(m_TestRect1, compile);
		Debug.Log(compile);*/
		
		/*if(GUI.Button(m_TestRect1, "Button 1"))
		{
			Debug.Log("Button1 pressed");
		}*/
		if(GUI.Button(m_TestRect2, "Button 2"))
		{
			Debug.Log("Button2 pressed");
		}
		if(GUI.Button(m_TestRect3, "Button 3"))
		{
			Debug.Log("Button3 pressed");
		}
		if(GUI.Button(m_TestRect4, "Button 4"))
		{
			Debug.Log("Button4 pressed");
		}
		if(GUI.Button(m_TestRect5, "Button 5"))
		{
			Debug.Log("Button5 pressed");
		}
		
	}
}