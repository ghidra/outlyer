﻿#include "enemy.angelscript"
#include "enemy_factory.angelscript"

class enemy_boss : enemy
{
	
	private enemy_factory@ m_factory;
	private int m_spawnmax = 0;

	enemy_boss(const string &in entityName, const vector2 pos, actor @target, const string &in label = "unknown"){
		super(entityName,pos,target,label);
		
		//set_scale(4.0f);

		@m_factory = enemy_factory( m_target);
		//m_factory.spawn( enemy("random.ent", vector2(200.0f,200.0f),m_targetpawn) );
		//I NOW NEED A WAY TO TELL THE BOSS WHEN TO SPAWN ENEMIES
		
		//i need to add this fucker to the minimap somehow now

		/*m_spd = 1.0f;

		m_rp = 10.0f;
		m_rpmax = 50.0f;

		//init_inventory();
		m_inventory.add_weapon( weapon("random.ent", get_position()) );//now we have a weapon in the inventory
		@m_weapon = m_inventory.get_weapon(0);//go ahead and equip the weapon just created
		//m_weapon.set_destination(targetpawn.get_position());

		@m_targetpawn = targetpawn;
		//@m_atarget = m_targetpawn;//cast down
		//@m_targetbodies = targetbodies;

		//@m_rbar = progressbar("resources",m_rp,0.0f,m_rpmax,m_pos);
		//m_actionlocal="attack pawn";
		m_attacktype=0;
	
		for(uint t = 0; t < 11; t++){
			set_attack( "attack",m_targetpawn);
		}*/

	}

	void update(){
		enemy::update();

		if(m_factory.num_spawns() < m_spawnmax && m_global !is null){//if we can spawn a dude, i want to make sure that I have a global object just in case as well
			m_factory.spawn( enemy("enemy_0101.ent", vector2(200.0f,200.0f),m_target) );
		}

		m_factory.update();
		/*m_action="none";

		pawn::update();

		vector2 direction(0, 0);
		float dist = 0.0f;

		//attack
		//----------------------
		if(attack_ready()){
			pawn@ target = m_attcontroller.get_target_pawn();
			attack(target);
		}
		update_weapon();
		//------------------------
		//-----------------------


		m_hbar.set_value(m_hp);
		//m_hbar.set_position(m_pos);
		m_hbar.set_position(get_screen_position());

		//button drawing
		if(m_mouseover){//if the mouse if over us
			//first clear out the button array
			for(uint t = 0; t<m_buttons.length(); t++){
				m_buttons.removeLast();
			}
			//here we trigger the button menus, and set the button array to have them in it
			vector2 stack_start = vector2(0.0f,14.0f);//here to start the menu relative to the body
			
			if(m_mouseover){
   	 			//m_buttons.insertLast( Button( 'attack', get_relative_position()+(stack_start)) );
   	 			m_buttons.insertLast( Button( 'attack', get_screen_position()+(stack_start)) );
			}

			m_menu_bool = true;
			for (uint t=0; t<m_buttons.length(); t++){
	   	 		m_buttons[t].update();
			}

			m_hbar.update();

		}

		set_button_action();
		*/
	}

	void set_global_object(global@ g){
		enemy::set_global_object(g);
		m_factory.set_global_object(g);
	}
	//void set_targetbody(pawn@ target){
	//	@m_targetpawn = target;
	//}
}
