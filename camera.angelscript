﻿#include "actor.angelscript"
#include "pawn.angelscript"
#include "enemy.angelscript"
#include "body.angelscript"

class camera
{

	//the camera is a default object. All I am doing in this class is giving is a target and speed to keep it in focus.
	//just basic camera movement control.

	//private body@ m_target_body;//variables to hold the target of the actions
	//private enemy@ m_target_enemy;
	//private pawn@ m_target_pawn;
	private actor@ m_target_actor;

	//private string m_target_type;

	private bool m_track_target = true;

	//scene scale information
	private float m_scale = 1.0f;

	private bool m_scalepressed = false;
	private float m_scalestartpos;//this will be set based on where the press was started, x or y, to begin the scalling
	private float m_scalefactor = 0.0f;//the amount to add to the scale
	private float m_scaledragmultiplier = 0.001;//the amount to multiply the drag by to add to the scale
	private float m_scaleprevious;//this hold the previous scale value, so we dont get a weird pop everytime we try this

	camera(){

	}

	void update(){

		//-------------------------------
		//-------------------------------
		//scale to simulate zooming in and out

		//this only uses the mouse currently, and no use of touch commands
		ETHInput@ input = GetInputHandle();
		const vector2 mousepos = input.GetCursorPos();

		//const uint touchCount = input.GetMaxTouchCount();
		//for (uint t = 0; t < touchCount; t++)
		//{
			//const vector2 mp = input.GetTouchPos(t); 
			//if (input.GetTouchState(t) == KS_HIT)
			if(input.GetRightClickState()==KS_HIT && !m_scalepressed)
			{
				m_scalestartpos = mousepos.x;//mp.x;
				m_scaleprevious = m_scale;
				m_scalepressed=true;
				//temp = "hit";
			}
			if(input.GetRightClickState()==KS_DOWN && m_scalepressed){
				m_scalefactor = (mousepos.x-m_scalestartpos)*m_scaledragmultiplier;//mp.x-m_scalestart;
				m_scale = m_scaleprevious+m_scalefactor;
				SetScaleFactor(m_scale);
			}
			if(input.GetRightClickState()==KS_RELEASE && m_scalepressed){
				m_scalepressed=false;
			}
		//}
		//-------------------------------
		//-------------------------------

		//now track the target
		if(m_track_target){
			const vector2 target = m_target_actor.get_position();
			const vector2 screenMiddle(GetScreenSize() * 0.5f);
			set_position(target-screenMiddle);
		}
	}

	void set_position(const vector2 pos){
		SetCameraPos(pos);
	}
	//-------
	void set_track_target(const bool b){
		m_track_target=b;
	}
	bool get_track_target(){
		return m_track_target;
	}
	//-------
	void set_target(actor@ target){
		@m_target_actor = target;
		//m_target_type = "actor";
		//update();
	}
	/*void set_target(pawn@ target){
		@m_target_pawn = target;
		m_target_type = "pawn";
	}
	void set_target(body@ target){
		@m_target_body = target;
		m_target_type = "body";
	}
	void set_target(enemy@ target){
		@m_target_enemy = target;
		m_target_type = "enemy";
	}*/
}