
using UnityEngine;
using System.Collections;
using System.IO;
using System.Xml;

public class LoadSetupXML : MonoBehaviour
{
	private string documentsPath = "/Configurations/";
    private string filename = "Setup.xml";
    StreamReader reader;

    XmlDocument xmlDoc;
	XmlNode m_FullScreen, m_ResolutionX, m_ResolutionY, 
			m_ResolutionWidth, m_ResolutionHeight, m_GUIOffsetX, m_GUIOffsetY;
	
	bool m_bFullScreen;
	float m_fResolutionX, m_fResolutionY, m_fResolutionWidth, m_fResolutionHeight, m_fGUIOffsetX, m_fGUIOffsetY;
	
	void Awake()
	{
        //Set path of file, then Read in the XML, finally set settings
        documentsPath = Application.dataPath + documentsPath + filename; 
		ReadXML();
		Settings();
	}
	
	 void ReadXML()
     {
		//load the file		
		reader = new StreamReader(documentsPath);
		
		//Create an XML Document and load it in.
		xmlDoc = new XmlDocument();
		xmlDoc.LoadXml(reader.ReadToEnd());
		
		//Check to see if xml loaded
		if (xmlDoc == null)
		Debug.Log("Failed load Variables DLL");
		
		//Load Nodes
		m_FullScreen = xmlDoc.SelectSingleNode("SEPT/Fullscreen");
		m_ResolutionX = xmlDoc.SelectSingleNode("SEPT/ResolutionX");
		m_ResolutionY = xmlDoc.SelectSingleNode("SEPT/ResolutionY");
		m_ResolutionWidth = xmlDoc.SelectSingleNode("SEPT/ResolutionWidth");
		m_ResolutionHeight = xmlDoc.SelectSingleNode("SEPT/ResolutionHeight");
		m_GUIOffsetX = xmlDoc.SelectSingleNode("SEPT/GUIOffsetX"); 
		m_GUIOffsetY = xmlDoc.SelectSingleNode("SEPT/GUIOffsetY");
		
		//Convert to format needed
		m_bFullScreen = bool.Parse(m_FullScreen.InnerXml);
		m_fResolutionX = float.Parse(m_ResolutionX.InnerXml);
		m_fResolutionY = float.Parse(m_ResolutionY.InnerXml);
		m_fResolutionWidth = float.Parse(m_ResolutionWidth.InnerXml);
		m_fResolutionHeight = float.Parse(m_ResolutionHeight.InnerXml);
		m_fGUIOffsetX = float.Parse(m_GUIOffsetX.InnerXml);
		m_fGUIOffsetY = float.Parse(m_GUIOffsetY.InnerXml);
		
		
		//Clear up xmldoc
		reader.Close();
		//xmlDoc = null;
	}
	
	void Settings()
	{
		//So it focuses right
		Application.runInBackground = true;
		
		string w = "W: " + Screen.width + " H: " + Screen.height;
		Debug.Log(w);
		
		Screen.SetResolution((int)m_fResolutionWidth, (int)m_fResolutionHeight, false);
		
		w = "W: " + Screen.width + " H: " + Screen.height;
		Debug.Log(w);
		
		//Remove title bars (default values if xml doesn't work
		if(m_fResolutionWidth == 0)
			m_fResolutionWidth = 6400;

		if(m_fResolutionHeight == 0)
			m_fResolutionHeight = 960;
		
		//Remove Title bars from Windows,
		WindowMode.OpenWindowMode(new Rect(m_fResolutionX, m_fResolutionY, /*m_fResolutionWidth*/ 6079, m_fResolutionHeight), m_bFullScreen);			
		Debug.Log(w);
		
		//Few things to force
		Screen.showCursor = true;
	}

	public float GetResoultionWidth()
	{
		return m_fResolutionWidth;
	}
	
	public float GetResoultionHeight()
	{
		return m_fResolutionHeight;
	}
	
	public float GetGUIOffsetX()
	{
		return m_fGUIOffsetX;
	}
	
	public float GetGUIOffsetY()
	{
		return m_fGUIOffsetY;
	}
}