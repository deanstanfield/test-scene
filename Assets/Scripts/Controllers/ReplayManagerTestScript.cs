using UnityEngine;
using System.Collections;

public class ReplayManagerTestScript : MonoBehaviour 
{
	GameObject m_Cube1, m_Cube2, m_Goober1, m_DirectionalLight;
	
	// Use this for initialization
	void Awake () 
	{
		m_Cube1 = (GameObject)Instantiate(Resources.Load("Prefabs/Cube"));		
		m_Cube1.name = "Cube1 Playable Dynamic";
		
		m_Cube2 = (GameObject)Instantiate(Resources.Load("Prefabs/Cube"));
		m_Cube2.name = "Cube2  Playable Dynamic";	
		m_Cube2.transform.position = new Vector3(5, 0, 0);	
		
		m_Goober1 = (GameObject)Instantiate(Resources.Load("Prefabs/Goober"));
		m_Goober1.name = "Goober Static Animate";	
		m_Goober1.transform.position = new Vector3(-5, 0, 0);
		
		m_DirectionalLight = new GameObject();
		m_DirectionalLight.name = "Directional Light";
		m_DirectionalLight.AddComponent<Light>();
		m_DirectionalLight.GetComponent<Light>().type = LightType.Directional;
		m_DirectionalLight.GetComponent<Light>().intensity = 0.5f;
		m_DirectionalLight.transform.position = new Vector3(0, 10, 10);
		m_DirectionalLight.transform.Rotate(new Vector3(90,0,0));	
		
		gameObject.AddComponent<SceneManager>();
	}
}
