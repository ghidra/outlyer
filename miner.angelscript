﻿#include "pawn.angelscript"
#include "body.angelscript"

class miner : pawn
{

	body@ m_minee;//whom we are mining. Leaving m_target free, incase we want to have miners be able to attack later

	miner(const string &in entityName, const vector2 pos, body@ minee, const uint uid, const float speed = 1.0f){
		super(entityName,pos);
		@m_minee = minee;
		m_spd = speed;
		m_pos = pos;
		m_uid = uid;
	}

	void update(){
		pawn::update();
		//const vector2 screen_middle(GetScreenSize() * 0.5f);
		
		//I want to rotate around the planet
		const vector2 offset = get_position()-m_minee.get_position();//vector from center of planet to satelliete
		const vector2 trans = m_minee.get_position()-vector2();//get the means to put it back
		const matrix4x4 rotation = rotateZ(m_spd_ups);

		const vector2 rotated = multiply(offset,rotation);//rotate from center
		const vector2 translated = rotated+trans;

		const vector2 direction = translated-get_position();

		m_entity.AddToPositionXY(direction);


		//now i need to suck away the planets resources

		const float a_rp = m_minee.get_rp();//available resource points
		m_minee.set_rp(a_rp-m_spd_ups);//take some resources based on speed

		m_rp = a_rp-m_minee.get_rp();//this gives me the amount that we took from the body, so that the character to absorbe it
		
		//DrawText(vector2(0,80), "offset x:"+offset.x+"/y:"+offset.y, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
		//DrawText(vector2(0,100), "trans x:"+trans.x+"/y:"+trans.y, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
		//DrawText(vector2(0,120), "direction:"+direction.x+"/y:"+direction.y, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
			

	}
}
