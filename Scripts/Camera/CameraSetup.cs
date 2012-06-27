using UnityEngine;
using System.Collections;
using System.IO;

public class CameraSetup : MonoBehaviour 
{
	GameObject m_ProjectionCam, m_TopDownCam, m_GUICam;
	Vector2 m_Resolution;
	static Vector2 m_MainResolution = /*new Vector2((1280*4), 960); // 5120 * 960  ||*/ new Vector2((1280*5), 960); //6400 x 960
	static Vector2 m_SingleResolution = new Vector2(1280, 960);
	
	Rect m_GUIGroupRect;
	
	WebCamTexture webcamTexture;
	Rect m_WebRect;
	
	bool m_bEnableGUI = true;
	bool m_bMulitpleMonitors = true;
	bool m_bShowScreenSelect = false;
	int m_iMonitorSelected;
	string m_sCurrent, m_sOld;
	int m_iSelectedItemIndex;
	
	Matrix4x4 m_OrginalMatrix;
		
	//list
	GUIContent[] comboBoxList;
    private ComboBox comboBoxControl = new ComboBox();
    private GUIStyle listStyle = new GUIStyle();
	
	//TextBox
    ////private TouchKeyboard m_TouchKeyboard =  new TouchKeyboard();
    //string[] m_TextBoxStrings;
    //int m_iFocusOn;
    //bool m_bFocusChange;
	
	void Awake()
	{
		m_ProjectionCam = GameObject.Find("Projection Camera");
		m_TopDownCam  = GameObject.Find("Top Down Camera");
		m_GUICam  = GameObject.Find("GUI Camera");

		m_Resolution = 	m_MainResolution;	 
		
		//Setup the cameras depending on settings
		SetupCameras();
		
		Screen.SetResolution((int)m_Resolution.x, (int)m_Resolution.y, true);
		Screen.fullScreen = true;
		m_GUIGroupRect = new Rect((Screen.width * m_GUICam.camera.rect.x), 0, 1280, 960);
		
		//webcam
		webcamTexture = new WebCamTexture();   
		webcamTexture.requestedWidth = (int)(Screen.width / 4) / 3; 
		webcamTexture.requestedHeight = (int)(Screen.height / 1.333333) / 3; 
        //webcamTexture.Play();
		
		m_WebRect = new Rect();
	
		m_WebRect.x = Screen.width * m_TopDownCam.camera.rect.x;
		m_WebRect.y = Screen.height - ((Screen.height / 1.333333f) / 3);
		m_WebRect.width = (Screen.width *  m_TopDownCam.camera.rect.width) / 3;
		m_WebRect.height = (Screen.height / 1.333333f) / 3;
	}
	
	void Start () 
	{
		comboBoxList = new GUIContent[4];
		comboBoxList[0] = new GUIContent("Full");
		comboBoxList[1] = new GUIContent("GUI");
		comboBoxList[2] = new GUIContent("Top Down");
		comboBoxList[3] = new GUIContent("Propertion");
		
		m_sCurrent = comboBoxList[m_iSelectedItemIndex].text;
		
		listStyle.normal.textColor = Color.white;
		listStyle.onHover.background =
		listStyle.hover.background = new Texture2D(2, 2);      
		listStyle.padding.left = listStyle.padding.right = listStyle.padding.top = listStyle.padding.bottom = 4;
	
		//for first time
		m_sOld = m_sCurrent;
		
		//setup textbox string (make one more than you need for string)
        //m_TextBoxStrings = new string[4];
	}
	
	void OnGUI()
    {		
		//Webcam
	//	GUI.DrawTexture(m_WebRect, webcamTexture);
		
		//Monitors
		SetupMonitorGUI();

		
		if(m_bEnableGUI)
		{
			GUI.matrix = Matrix4x4.TRS(new Vector3(0, 0, 0), Quaternion.identity, 
                                   new Vector3(m_SingleResolution.x / m_Resolution.x, 
                                               m_SingleResolution.y / m_Resolution.y, 1));
			
			//Main GUI		
			GUI.BeginGroup(m_GUIGroupRect);
	
            ////Test
            //if(CustomTextBox.TextBox(new Rect(0, 250, 200, 30), m_TextBoxStrings[1]))
            //{
            //    Debug.Log("Focus on 1");
            //    m_iFocusOn = 1;
            //    m_bFocusChange = true;
            //}
			
            //if(CustomTextBox.TextBox(new Rect(0, 350, 200, 30), m_TextBoxStrings[2]))
            //{
            //    Debug.Log("Focus on 2");
            //    m_iFocusOn = 2;
            //    m_bFocusChange = true;
            //}
			
            //if(CustomTextBox.TextBox(new Rect(0, 450, 200, 30), m_TextBoxStrings[3]))
            //{
            //    Debug.Log("Focus on 3");
            //    m_iFocusOn = 3;
            //    m_bFocusChange = true;
            //}
			
			//keyboard 	
			/*if(m_bFocusChange)
			{
				m_TextBoxStrings[0] = m_TextBoxStrings[m_iFocusOn];
				m_TouchKeyboard.SetTemp(m_TextBoxStrings[0]);
				m_bFocusChange = false;
			}
			
			//m_TextBoxStrings[m_iFocusOn] = m_TouchKeyboard.SetupKeyboard(m_TextBoxStrings[0], new Vector2(0,0));
			
			//Debug.Log(m_TextBoxStrings[0]);*/
			
			GUI.EndGroup();
		}
    }
	
	void Update()
	{
		if(Input.GetKeyDown(KeyCode.F1))
		{
			m_bShowScreenSelect = !m_bShowScreenSelect;
		}
	}
	
	void SetupMonitorGUI()
	{		
		m_sOld = m_sCurrent;
		
		m_iSelectedItemIndex = comboBoxControl.GetSelectedItemIndex();
		
		//setup monitor selection
		if(m_bShowScreenSelect)
		{			
        	m_iSelectedItemIndex = comboBoxControl.List( new Rect(0, 0, 100, 20), 
													comboBoxList[m_iSelectedItemIndex].text, comboBoxList, listStyle );
		}
		
		if(comboBoxList[m_iSelectedItemIndex].text == "Full") 
		{
			m_bMulitpleMonitors = true;
			m_sCurrent = comboBoxList[m_iSelectedItemIndex].text;
		}
		else
		{
			m_bMulitpleMonitors = false;
			m_sCurrent = comboBoxList[m_iSelectedItemIndex].text;
			if (comboBoxList[m_iSelectedItemIndex].text == "GUI") m_iMonitorSelected = 0;
			else if (comboBoxList[m_iSelectedItemIndex].text == "Top Down") m_iMonitorSelected = 1;
			else if (comboBoxList[m_iSelectedItemIndex].text == "Propertion") m_iMonitorSelected = 2;
			
		}
			
		if(m_sOld != m_sCurrent)
			SetupCameras();
		
	}
	
	void SetupCameras()
	{
		Debug.Log ("here");
		if(m_bMulitpleMonitors)
		{
			//2 Screens 4 monitors
			/*m_GUICam.camera.rect = new Rect(0.0f, 0, 0.25f, 1);
			m_TopDownCam.camera.rect = new Rect(0.25f, 0, 0.25f, 1);
			m_ProjectionCam.camera.rect = new Rect(0.5f, 0, 0.5f, 1);*/	
			
			//3 screens 5 monitors
			m_GUICam.camera.rect = new Rect(0.0f, 0, 0.2f, 1);		
			m_TopDownCam.camera.rect = new Rect(0.2f, 0, 0.2f, 1);
			m_ProjectionCam.camera.rect = new Rect(0.4f, 0, 0.6f, 1);		
			
			//3 screens on 4 monitors
			/*m_GUICam.camera.rect = new Rect(0, 0, 0.125f, 1);		
			m_TopDownCam.camera.rect = new Rect(0.125f, 0, 0.125f, 1);
			m_ProjectionCam.camera.rect = new Rect(0.25f, 0, 0.75f, 1);*/
			
			m_Resolution = m_MainResolution;
			
			m_bEnableGUI = true;	
								
		}
		else
		{
			//Just GUI Screen
			if(m_iMonitorSelected == 0)
			{
				m_bEnableGUI = true;
				m_GUICam.camera.rect = new Rect(0, 0, 1, 1);				
				m_TopDownCam.camera.rect = new Rect(0, 0, 0, 0);
				m_ProjectionCam.camera.rect = new Rect(0, 0, 0, 0);
			}
			//Just Top Screen
			else if(m_iMonitorSelected == 1)
			{
				m_bEnableGUI = false;
				m_GUICam.camera.rect = new Rect(0, 0, 0, 0);				
				m_TopDownCam.camera.rect = new Rect(0, 0, 1, 1);
				m_ProjectionCam.camera.rect = new Rect(0, 0, 0, 0);
			}
			//Just Projection Screen
			else if(m_iMonitorSelected == 2)
			{
				m_bEnableGUI = false;
				m_GUICam.camera.rect = new Rect(0, 0, 0, 0);				
				m_TopDownCam.camera.rect = new Rect(0, 0, 0, 0);
				m_ProjectionCam.camera.rect = new Rect(0, 0, 1, 1);
			}
			
			m_Resolution = m_SingleResolution;
		}
		
		//updare webcam, same code, just needs recalling
		m_WebRect.x = Screen.width * m_TopDownCam.camera.rect.x;
		m_WebRect.y = Screen.height - ((Screen.height / 1.333333f) / 3);
		m_WebRect.width = (Screen.width *  m_TopDownCam.camera.rect.width) / 3;
		m_WebRect.height = (Screen.height / 1.333333f) / 3;
		
		//turn off camera option
		m_bShowScreenSelect = false;
		
		//Reset Resolution
		Screen.SetResolution((int)m_Resolution.x, (int)m_Resolution.y, true);
	}	
}
