﻿#include "pawn.angelscript"
#include "miner.angelscript"
#include "enemy.angelscript"
#include "body.angelscript"

class Character : pawn
{

	private miner@[] m_miners;//my array of miners
	private uint m_minerscount=0;//this counte the miners, so that I can give them a unique id, so when i go to delete them, i delete the right one
	private uint m_minersmax = 3;//at first you can only have 3 miners, maybe later you can have some more
	private float m_minercost = 3.0f;//the cost to pu down a miner

	//body@ m_targetbody;//the body that we are targeting
	enemy@ m_targetenemy;//the body that we are targeting

	private vector2 m_guipos;
	private vector2 m_guiactionspos;


	private progressbar@ m_mbar;//miners bar

	private float m_drag_distance = 0.0f;//this is to check how far we have dragged out our travel vector, so that if it is small, we can ignore it
	private float m_drag_distance_threshold = 100.0f;
	private bool m_moving = false;//set when I am manually setting a destination with a mouse drag out

	Character(const string &in entityName, const vector2 pos){
		super(entityName,pos);
		
		m_spd = 100.0f;

		m_hp = 100.0f;

		m_rp = 10.0f;
		m_rpmax = 50.0f;

		const vector2 ss = GetScreenSize();
		m_guipos = vector2( m_guimargin+(m_guibarsize.x/2), ss.y-m_guimargin );
		m_guiactionspos = vector2(m_guimargin,m_guimargin+100);//start the list of actions

		m_hbar.set_position(m_guipos+vector2((m_guibarwidth/2.0f)+m_guibarmargin,-(m_guibarwidth+(m_guibarmargin*2))));//default healt bar
		@m_rbar = progressbar("resources",m_rp,0.0f,m_rpmax,m_guipos+vector2(0.0f,-((m_guibarwidth/2.0f)+m_guibarmargin)),vector2(),m_guibarsize,m_guibardir,1,0,0);
		@m_mbar = progressbar("miners",m_minersmax-m_minerscount,0.0f,m_minersmax,m_guipos+vector2( (m_guibarwidth/2.0f)+m_guibarmargin,0.0f),vector2(),m_guibarsize,m_guibardir,1,0,0);

		//weapons
		//init_inventory();
		m_inventory.add_weapon( weapon("random.ent", get_position()) );//now we have a weapon in the inventory
		@m_weapon = m_inventory.get_weapon(0);//go ahead and equip the weapon just created
		m_weapon.set_bar_position( m_guipos+vector2( ((m_guibarwidth/2.0f)+m_guibarmargin)*2 ,-((m_guibarwidth/2.0f)+m_guibarmargin)) );
	}

	void update(){

		pawn::update();

		vector2 direction(0, 0);
		float dist = 0.0f;

		if(m_controller.has_actions()){//if our controller has actions to give us
			
			const string action = m_controller.get_action();//this gets the action we need to try and perform

			if(action == "harvest" || action == "collect miner"){
				
				//body@ target = m_controller.get_target_body();//since i only harvest bodies, I have to assume that I am trying to get a body object
				actor@ target = m_controller.get_target_actor();
				set_destination(target.get_position());

				if( m_destination_distance > length(target.get_size())*m_gscale ){
					m_moving=true;
					//move(m_destination_direction);
				}else{
					if(action == "harvest"){
						deposit_miner(cast<body>(target));
					}
					if(action == "collect miner"){
						collect_miner(cast<body>(target));
					}
					//now remove the action from the list
					m_controller.remove_action();
					m_moving=false;
				}
			}
		
		}else{//if we have no actions we are allowed to get directions
		//Determine if we are trying to drag out a direction for travel
		////////////
		//m_pressed = false;
		//const uint touchCount = m_input.GetMaxTouchCount();
		//for (uint t = 0; t < touchCount; t++)
		//{
			/*if (m_input.GetTouchState(t) == KS_HIT)
			{
				//if (isPointInButton(input.GetTouchPos(t)))
				if (m_mouseover)
				{
					m_pressed = true;
				}
			}*/
			vector2 lineend = m_mousepos;

			if (m_mouseover){
				if(m_input.GetLeftClickState()==KS_HIT && !m_pressed && !m_moving){
					m_pressed=true;
				}
			}
			if(m_input.GetLeftClickState()==KS_DOWN && m_pressed){
				//get travel cost information
				//also need to determine if we can even make it
				vector2 chpos = m_pos-m_camerapos;//the character position
				m_drag_distance = length(chpos-m_mousepos);//the distance dragged out

				m_travel_cost=(m_drag_distance*m_travel_cost_per_unit);

				if(m_travel_cost>m_rp){//if the cost of travel is more than we have resources, we need to adjust our line
					vector2 ndir = normalize(m_mousepos-chpos);
					float mdist = m_rp/m_travel_cost_per_unit;//max distance we can travel
					lineend = chpos+(ndir*mdist);
					DrawText( lineend+vector2(-12.0f,-4.0f) , "est. cost:", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
					DrawText( lineend+vector2(-12.0f,8.0f) , decimal(m_rp,10)+"", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
				}
				
				draw_line(chpos,lineend,m_white,m_white,1.0f);
				
				DrawText( m_mousepos+vector2(12.0f,-4.0f) , "est. cost:", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
				DrawText( m_mousepos+vector2(12.0f,8.0f) , decimal(m_travel_cost,10)+"", "Verdana14_shadow.fnt", ARGB(250,255,255,255));

				//m_scalefactor = (mousepos.x-m_scalestartpos)*m_scaledragmultiplier;//mp.x-m_scalestart;
				//m_scale = m_scaleprevious+m_scalefactor;
				//SetScaleFactor(m_scale);
			}
			if(m_input.GetLeftClickState()==KS_RELEASE && m_pressed){
				//set the destination
				if(m_drag_distance>m_drag_distance_threshold){
					//set_destination(m_relativemousepos);
					set_destination(lineend+m_camerapos);
					m_moving=true;
				}else{
					m_moving=false;
				}
				m_pressed=false;
			}

			//-------
			//now if we are flagged to m_moving, move it to the destination

			

		//}
		}
		if( m_destination_distance>0 && m_moving && m_rp>m_travel_cost_per_unit*m_spd_ups){
			move(m_destination_direction);
			//move(normalize(m_destination-m_pos));
			m_rp-=(m_travel_cost_per_unit*m_spd_ups);//remove the resources
			//float t = fit(m_destination_distance_init-m_destination_distance,0,m_destination_distance_init);
			//DrawText(vector2(0,280), "travelled:"+t+"", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
			//move(m_destination_direction);
		}else{
			m_moving=false;
			//m_rp = 0;//force resouce points to 0,so that we dont have negative values here
		}

		//need to update the weapons positions, so they dont hover in air and not move
		m_weapon.set_position(m_pos);

		/////////////
		//attack
		if(attack_ready()){
			//enemy@ target = m_attcontroller.get_target_enemy();
			actor@ target = m_attcontroller.get_target_actor();
			attack(target);
		}
		update_weapon();
		////////////


		//DrawText(vector2(0,280), "moving angle:"+m_movingangle+"", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
		////////////

		for (uint t=0; t<m_miners.length(); t++){
			m_miners[t].update();
 
			this.set_rp( m_rp+m_miners[t].get_rp() );
		}

		m_rbar.set_value(m_rp);
		m_rbar.update();
		DrawText( (m_rbar.get_centeroffset()*vector2(-1.0f,1.0f))+m_rbar.get_position()+vector2(-24.0f,7.0f), "r", "Verdana14_shadow.fnt", ARGB(250,255,255,255));

		m_mbar.set_value(m_minersmax-m_minerscount);
		m_mbar.update();
		DrawText( m_mbar.get_centeroffset()+m_mbar.get_position()+vector2(18.0f,7.0f), "m", "Verdana14_shadow.fnt", ARGB(250,255,255,255) );

		m_hbar.set_value(m_hp);
		m_hbar.update();
		DrawText( m_hbar.get_centeroffset()+m_hbar.get_position()+vector2(18.0f,7.0f), "hp", "Verdana14_shadow.fnt", ARGB(250,255,255,255));

		//////////////////////
		//print out any actions I might have queued up
		const string[] queact = m_controller.get_actions();
		const uint queactlen = queact.length();
		const string[] queattact = m_attcontroller.get_actions();
		const uint queattactlen = queattact.length();

		vector2 guiattactpos = vector2(m_guiactionspos.x, m_guiactionspos.y+((queactlen+1)*12)+6);//set the place to start the attack action list, make room for a bar inbetween
		if(queactlen==0){
			guiattactpos = m_guiactionspos;
		}
		
		if(queactlen>0){
			DrawText(m_guiactionspos, "actions:", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
			for(uint t=0; t<queactlen; t++){
				DrawText(vector2(m_guiactionspos.x,m_guiactionspos.y+(12*(t+1))), ""+queact[t], "Verdana14_shadow.fnt", ARGB(255,100,100,100));
			}
			const vector2 linepos = vector2(m_guiactionspos.x,m_guiactionspos.y+(12*(queactlen+1))+3);
			draw_line(linepos, vector2(linepos.x+10,linepos.y),m_grey,m_grey,1.0f);
		}

		if(queattactlen>0){
			DrawText(guiattactpos, "attacks:", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
			for(uint t=0; t<queattactlen; t++){
				DrawText(vector2(guiattactpos.x,guiattactpos.y+(12*(t+1))), ""+queattact[t], "Verdana14_shadow.fnt", ARGB(255,100,100,100));
			}
		}
		//////////////////////

		//DrawText(vector2(0,300), "actions:"+m_controller.print_actions()+"", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
		//DrawText(vector2(0,310), "attactions:"+m_attcontroller.print_actions()+"", "Verdana14_shadow.fnt", ARGB(250,255,255,255));



		/*ETHInput@ input = GetInputHandleuint t=0; t<m_miners.length(); t++();
		vector2 direction(0, 0);
		//float speed = UnitsPerSecond(m_spd);

		// find current move direction based on keyboard keys
		if (input.KeyDown(K_DOWN))
		{
			m_directionLine = 0;
			direction += (vector2(0, 1)*m_spd_ups);
			//direction += vector2(0, 1);
		}
		if (input.KeyDown(K_LEFT))
		{
			m_directionLine = 1;
			direction += (vector2(-1, 0)*m_spd_ups);
			//direction += vector2(-1, 0);
		}
		if (input.KeyDown(K_RIGHT))
		{
			m_directionLine = 2;
			direction += (vector2(1, 0)*m_spd_ups);
			//direction += vector2(1, 0);
		}
		if (input.KeyDown(K_UP))
		{
			m_directionLine = 3;
			direction += (vector2(0,-1)*m_spd_ups);
			//direction += vector2(0,-1);
		}

		// if there's movement, update animation
		move(direction);
		*/
	}
	//this function overrides the default pawn one, cause I Need to specifically check enimy objects
	//void check_weapon_projectiles(){//loop through the projectiles and find out if they have hit our target
	//	m_weapon.check_projectiles_hit_target(m_targetenemy);
	//}
	void deposit_miner(body@ target){//put a minor on the target
		if(target !is null){
			if(m_rp>m_minercost){
				vector2 target_pos = target.get_position();
				vector2 target_size = target.get_size()*0.75f;
				vector2 drop_dir = normalize(get_position()-target.get_position());
				vector2 drop_zone = target_pos+(drop_dir*(target_size*m_gscale));
				uint len = m_miners.length;
				if(len<m_minersmax){
					m_miners.insertLast( miner("random.ent", drop_zone, target, m_minerscount) );
					m_miners[len].set_scale(0.25f);
					m_miners[len].set_global_object(m_global);//give it the global object
					set_rp(get_rp()-m_minercost);
					target.add_miner(m_minerscount);
					m_minerscount+=1;
				}

			}else{
				//warn that you do not have enough funds
			}
		}
	}
	void collect_miner(body@ target){
		if(target !is null){
			uint remove_uid = target.subtract_miner();//m_miner+=1;
			uint remove_id;
			for(uint t=0; t<m_miners.length(); t++){
				uint candidate = m_miners[t].get_uid();
				if (candidate == remove_uid){
					remove_id = t;
				}
			}
			m_miners[remove_id].delete_entity();
			m_miners.removeAt(remove_id);
			set_rp(get_rp()+0.5f);//get a little resources back
			m_minerscount-=1;
		}
	}
	float get_minercost(){
		return m_minercost;
	}
	/*void set_targetbody(body@ target){
		@m_targetbody = target;
	}
	void set_targetenemy(enemy@ target){
		@m_targetenemy = target;
	}*/
}
