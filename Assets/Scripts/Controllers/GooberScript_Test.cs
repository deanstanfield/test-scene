using UnityEngine;
using System.Collections;

public class GooberScript_Test : MonoBehaviour 
{
	//string[] m_sSaveAnimationName;
	//float m_fRandom = Random.Range(1.0f, 10.0f);
	//int m_Counter;
	
	//awake because it needs calling before TimeLine.Init() (ATM)
	void Awake()
	{
		Messenger.AddListener("animated", AnimateButton);
				
		/*foreach(AnimationState states in animation)
		{		
			m_sSaveAnimationName[m_Counter++] = states.name;
		}*/
	}
	
	void OnGUI()
	{
		Messenger.Broadcast("animated");
	}
	
	void AnimateButton()
	{
		if(GUI.Button(new Rect(0, Screen.height - 50, 100, 50), "Animate"))
		{
			foreach(AnimationState states in animation)
			{				
				Debug.Log (states.name);
			}
			animation.Play();
			TimeLine.SetEventOccured(true);
		}
	}
	
	/*public string[] GetAnimationName()
	{
		return m_sSaveAnimationName;
	}*/
	
	
	
}