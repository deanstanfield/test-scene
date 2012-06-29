using UnityEngine;
using System.Collections;

public class GUIHelp
{		
	static Texture2D[] m_Notch;
	static Rect[] m_NotchRect;
	static int m_iOldLenght;
	
	public static float GUITimeline(Rect position, float value, float leftValue, float rightValue, float[] notchPosY )
	{
		//set up texture once
		if(m_Notch == null || (m_iOldLenght != notchPosY.Length))
		{
			m_Notch = new Texture2D[notchPosY.Length];
			m_NotchRect = new Rect[notchPosY.Length];
			m_iOldLenght = notchPosY.Length;
		}
		
		for(int i = 0; i < notchPosY.Length; i++)
		{	
			if(!m_Notch[i])
				m_Notch[i] = (Texture2D)Resources.Load("GUITextures/TimelineNotch", typeof(Texture2D));
			
			//create array of rects for Notch to go.
			float normalX = (1.0f / rightValue) * notchPosY[i];
			float posX = (normalX * position.width) + position.x; //((notchPosY[i] * rightValue) * position.width) + position.x;
			m_NotchRect[i] = new Rect(posX, position.y - (m_Notch[i].height / 8), m_Notch[i].width, m_Notch[i].height);
			
			//Draw Notch
			if(m_Notch[i])
				GUI.DrawTexture(m_NotchRect[i], m_Notch[i]);
		}
			
		//Draw Bar and return
		return GUI.HorizontalSlider(position, value, leftValue, rightValue);
	}
	
	/*public static float HorizontalSlider (Rect position, float value, float leftValue, float rightValue)
	{
		return GUI.Slider (position, value, 0f, leftValue, rightValue, GUI.skin.horizontalSlider, GUI.skin.horizontalSliderThumb, true, GUIUtility.GetControlID (GUI.sliderHash, FocusType.Native, position));
	}*/
}


