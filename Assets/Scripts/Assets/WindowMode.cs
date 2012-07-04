using System;  
using System.Collections;  
using System.Runtime.InteropServices; 
using UnityEngine;
using System.Diagnostics;

public class WindowMode : MonoBehaviour 
{	
	public static int y = 0;
	public static Rect getY(Rect r){ if (Application.isEditor) return r; else return new Rect(r.x,r.y+WindowMode.y,r.width,r.height); }
	
	[DllImport("user32.dll")]
	static extern int SetWindowLong(int hwnd, int _nIndex, int dwNewLong);
	
	[DllImport("user32.dll")]  
	static extern bool SetWindowPos (int hWnd, int hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);  

	[DllImport("user32.dll")]  
	static extern bool SetWindowText (int hWnd, string text);  
		
	[DllImport("user32.dll")]
	static extern bool MoveWindow(int hwnd, int X, int Y, int w, int h, bool repaint);
	
	[DllImport("user32.dll")]
	static extern bool ShowWindow(int hWnd, int cmd);
	
	[DllImport("user32.dll")] 
	static extern int FindWindow(string className, string windowName);

    [DllImport("user32.dll")]
    private static extern bool GetWindowRect(int hWnd, ref Rect r);
	
	const int SW_SHOW = 5;
	const int SW_HIDE = 0;
	const int SW_FORCEMINIMIZE = 11;
	const uint SWP_SHOWWINDOW = 0x0040;  
	const int GWL_STYLE = -16;  
	const int WS_BORDER = 1;  
	
	public Rect screenPosition;
	public GUIStyle offsetGUIStyle;		
	public bool amEnabled = false;
	public bool testingMode = false;
    public bool m_titleBars = false;
	private int thisWindowhWnd = 0;
	
	public static void OpenWindowMode(Rect f, bool _titleBars = false)
	{
		GameObject c = GameObject.Find("Cameras");
		WindowMode w = c.AddComponent<WindowMode>();
		w.screenPosition = f;
        w.m_titleBars = _titleBars;
		w.init();
	}
	
	IEnumerator performWindowChange()
	{	
        Screen.SetResolution(1, 1, false);

		Screen.SetResolution((int)screenPosition.width,(int) screenPosition.height, false);
		
		yield return new WaitForSeconds(0.001f);
			
		//Logger.Log("setting to "+screenPosition.width+", "+screenPosition.height);

        int _borderMode = WS_BORDER;

        if ( !m_titleBars )
        {
            _borderMode = 0;
        }

        SetWindowLong( thisWindowhWnd, GWL_STYLE, _borderMode );
		UnityEngine.Debug.Log("BM: " + _borderMode);

		SetWindowPos (thisWindowhWnd, 0,(int)screenPosition.x,(int)screenPosition.y, (int)screenPosition.width,(int) screenPosition.height, SWP_SHOWWINDOW);
        
        // wait and try again...
       // yield return new WaitForSeconds( 2.0f );
      //  thisWindowhWnd = FindWindow( null, "SEPT Trial Folder" );
       // SetWindowLong( thisWindowhWnd, GWL_STYLE, _borderMode );
       // SetWindowPos( thisWindowhWnd, 0, (int) screenPosition.x, (int) screenPosition.y, (int) screenPosition.width, (int) screenPosition.height, SWP_SHOWWINDOW );
	}

	void init () 
	{			
		if (!Application.isEditor && !UnityEngine.Debug.isDebugBuild )
		{
			// immediately hide the window
			thisWindowhWnd = FindWindow(null, "SEPT Trial Folder");

		    Rect r = new Rect();
		    GetWindowRect(thisWindowhWnd, ref r);
            //Logger.Log("Current Window Position: "+r.ToString());

			StartCoroutine(performWindowChange());		
		}

	}
}
