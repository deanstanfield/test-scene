using UnityEngine;
using System.Collections;
using System.IO;

public class CameraSetup : MonoBehaviour
{
    GameObject m_ProjectionCam, m_TopDownCam, m_GUICam;
    
	WebCamTexture webcamTexture;
    Rect m_WebRect;
	
	//based on the system that the screen.width isn't 6400
	float m_fEditorValue;
	float m_fGUICamProWidth; // this doubles up as GUI width, Top Down start and width 
	float m_fProjCamProStart; //start position of Proj
	float m_fProjCamProWidth; //width position of Proj

    void Awake()
    {
        m_ProjectionCam = GameObject.Find("Projection Camera");
        m_TopDownCam = GameObject.Find("Top Down Camera");
        m_GUICam = GameObject.Find("GUI Camera");
        
		//3 screens 5 monitors
		if(Application.isEditor)
			m_fEditorValue = 6079;
		else
			m_fEditorValue = (float)Screen.width;
		
		m_fGUICamProWidth = 1280.0f / m_fEditorValue;
		m_fProjCamProStart = 2560.0f / m_fEditorValue;
		m_fProjCamProWidth = (m_fEditorValue - 2560) / m_fEditorValue;
		
        m_GUICam.camera.rect = new Rect(0.0f, 0, m_fGUICamProWidth, 1);
        m_TopDownCam.camera.rect = new Rect(m_fGUICamProWidth, 0, m_fGUICamProWidth, 1);
        m_ProjectionCam.camera.rect = new Rect(m_fProjCamProStart, 0, m_fProjCamProWidth, 1);

        //webcam
        webcamTexture = new WebCamTexture();
        webcamTexture.requestedWidth = (int)(Screen.width / 4) / 3;
        webcamTexture.requestedHeight = (int)(Screen.height / 1.333333) / 3;
        //webcamTexture.Play();

        m_WebRect = new Rect();

        m_WebRect.x = Screen.width * m_TopDownCam.camera.rect.x;
        m_WebRect.y = Screen.height - ((Screen.height / 1.333333f) / 3);
        m_WebRect.width = (Screen.width * m_TopDownCam.camera.rect.width) / 3;
        m_WebRect.height = (Screen.height / 1.333333f) / 3;
    }

    
}
