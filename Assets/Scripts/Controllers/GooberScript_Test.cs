using UnityEngine;
using System.Collections;

public class GooberScript_Test : MonoBehaviour 
{
	ArrayList m_SaveAnimationName = new ArrayList();
	string m_sCurrentAnimation;
	//float m_fRandom = Random.Range(1.0f, 10.0f);
	int m_Counter;
	
	//awake because it needs calling before TimeLine.Init() (ATM)
	void Awake()
	{
		Messenger.AddListener("animated", AnimateButton);
		
		foreach(AnimationState states in animation)
		{		
			m_SaveAnimationName.Add(states.name);
		}
		m_sCurrentAnimation = (string)m_SaveAnimationName[2];
	}
	
	void OnGUI()
	{
		Messenger.Broadcast("animated");
	}
	
	void AnimateButton()
	{
		if(GUI.Button(new Rect(0, Screen.height - 50, 100, 50), "Animate"))
		{
			animation.Play(m_sCurrentAnimation);
			TimeLine.SetEventOccured(true);
			SceneManager.GetTimeNotch().Add(TimeLine.GetFrameCount());
		}
	}
	
	public string GetAnimationName()
	{
		return m_sCurrentAnimation;
	}
}