// Game.cs
// Description
// Mat Stevenson

using UnityEngine;
using System.Collections;

public class Game : MonoBehaviour 
{
	//*******************************//
	// Public Member Data            //
	//*******************************//
	
	
	//*******************************//
	// Private Member Data           //
	//*******************************//
	GameObject m_GUICamera, m_ProjectionCamera, m_TopDownCamera, m_DirectionalLight, m_Plane, m_Sphere;
	
	//*******************************//
	// Unity Methods                 //
	//*******************************//
	
	//Setup Scene
	void Awake()
	{
		//Load the window setup
		gameObject.AddComponent<LoadSetupXML>();	
	}
	
	// Use this for initialization
	void Start() 
	{
		//Setup the camera objects
		m_GUICamera = new GameObject();
		m_GUICamera.name = "GUI Camera";
		m_GUICamera.AddComponent<Camera>();
		m_GUICamera.transform.position = new Vector3(0, -2000, 0);
		m_GUICamera.camera.depth = 1;
		m_GUICamera.camera.backgroundColor = Color.black;
		m_GUICamera.transform.parent = gameObject.transform;
		
		m_ProjectionCamera = new GameObject();
		m_ProjectionCamera.name = "Projection Camera";
		m_ProjectionCamera.AddComponent<Camera>();
		m_ProjectionCamera.transform.position = new Vector3(0, 40, -50);
		m_ProjectionCamera.transform.Rotate(new Vector3(25,0,0));	
		m_ProjectionCamera.camera.depth = -1;
		m_ProjectionCamera.camera.backgroundColor = Color.blue;
		m_ProjectionCamera.transform.parent = gameObject.transform;
		
		m_TopDownCamera = new GameObject();
		m_TopDownCamera.name = "Top Down Camera";
		m_TopDownCamera.AddComponent<Camera>();
		m_TopDownCamera.transform.position = new Vector3(0, 100, 10);
		m_TopDownCamera.transform.Rotate(new Vector3(90,0,0));	
		m_TopDownCamera.camera.farClipPlane = 101;
		m_TopDownCamera.camera.depth = 0;
		m_TopDownCamera.camera.backgroundColor = Color.white;
		m_TopDownCamera.camera.orthographic = true;
		m_TopDownCamera.camera.orthographicSize = 100;
		m_TopDownCamera.transform.parent = gameObject.transform;
		
		//add light
		m_DirectionalLight = new GameObject();
		m_DirectionalLight.name = "Directional Light";
		m_DirectionalLight.AddComponent<Light>();
		m_DirectionalLight.GetComponent<Light>().type = LightType.Directional;
		m_DirectionalLight.GetComponent<Light>().intensity = 0.5f;
		m_DirectionalLight.transform.position = new Vector3(0, 10, 10);
		m_DirectionalLight.transform.Rotate(new Vector3(90,0,0));	
		
		//Add objects
		m_Plane = (GameObject)Instantiate(Resources.Load("Prefabs/plane"));
		m_Plane.name = "Plane";
		
		m_Sphere = (GameObject)Instantiate(Resources.Load("Prefabs/sphere OF DOOM!!!"));
		m_Sphere.transform.position = new Vector3(0, 5, 0);
		
		//Add camera script to create 5 screen setup
		gameObject.AddComponent<CameraSetup>();
		
		//Add GUI Manager
		gameObject.AddComponent<GUIManager>();
		
		Debug.Log("Setup");
	}
	
	// Update is called once per frame
	void Update() 
	{
		if(Input.GetKeyDown(KeyCode.Escape))
		{
			Application.Quit();
		}
	}
	
	//*******************************//
	// Private Methods               //
	//*******************************//
	
	
}
