void(entity target,int new_weapon) switch_weapon =
{
	new_weapon != target.weapon;
	if(new_weapon == 1)
	{
		target.wishweapon += switch_lower;
	}
};



void(entity target, float input_button, int parton) do_weapons =
{
	float flag_damage;
	/*
		input_buttons 1:  +attack
			Here is where we do our railgun shenanigans..
			Should generally be looking at target.currentweapon to determine what weapon is being used... so railgun only at the moment
	*/


	if(input_impulse >= 1 && input_impulse < 6)
	{
		float switcher;

		if(input_impulse == 1 && target.ammo_nails > 0)
			switcher = TRUE;
		else if(input_impulse == 2 && target.ammo_nails > 0 && (target.items & WEAPON_RIFLE))
			switcher = TRUE;
		else if(input_impulse == 3 && target.ammo_shells > 0 && (target.items & WEAPON_SHOTGUN))
			switcher = TRUE;
		else if(input_impulse == 4 && target.ammo_rockets > 0 && (target.items & WEAPON_ROCKETLAUNCHER))
			switcher = TRUE;
		else if(input_impulse == 5 && target.ammo_cells > 0 && (target.items & WEAPON_RAILGUN))
			switcher = TRUE;
		else if(input_impulse == 6 && target.ammo_cells > 0 && (target.items & WEAPON_RIFLE))
			switcher = TRUE;
		else
			switcher = FALSE;

		if(switcher)
			target.wishweapon = input_impulse;
	}

		#ifdef SSQC
		
		#endif

	float what = TRUE;


	if(what)
	{
		float timer;
		#ifdef CSQC
		timer = 0;
		#endif

		#ifdef SSQC
		timer = input_servertime-0.05;
		#endif


		float ammo;

		if(target.weapon == 1)
			ammo = target.ammo_nails;
		if(target.weapon == 2)
			ammo = target.ammo_nails;
		if(target.weapon == 3)
			ammo = target.ammo_shells;
		if(target.weapon == 4)
			ammo = target.ammo_rockets;
		if(target.weapon == 5)
			ammo = target.ammo_cells;
		if(target.weapon == 6)
			ammo = target.ammo_cells;


		if(!(input_button & 1))
		{

			if(target.pmove_flags & FL_SEMIFIRE)
			{
				target.pmove_flags = 0;
			}
		}

		if((input_button & 1) && target.attack_time == 0 && ammo > 0 && target.health > 0)
		{


			makevectors(input_angles);
			int damage;

			#ifdef CSQC
			vector view_org = viewweapon2.origin;
			vector weapon_origin = target.origin+target.view_ofs + (v_forward*view_org_y + v_right*view_org_x + v_up*view_org_z);
			#endif




			if(target.weapon == 1 && !(target.pmove_flags & FL_SEMIFIRE))
			{
				damage = 25;
				makevectors(input_angles+[randomize(timer,-1,1),randomize(timer-5,-1,1)]);
				tracelineb(target.origin+target.view_ofs,target.origin+target.view_ofs+v_forward*2000,MOVE_HITMODEL,target,timer);


				if(parton)
				{
				sound(target,CHAN_WEAPON,"sounds/pistol1.ogg",ATTN_NORM,1,random(98,102));
				#ifdef CSQC
					trailparticles(particleeffectnum("pitch.trace"),target,weapon_origin,trace_endpos);
					offset_x += 1;
				#endif
				}

				if(trace_ent.damage_taker && trace_ent.health)
				{ 
					#ifdef SSQC
						send_damage(target,trace_ent,damage); 
					#endif
					
				}
			target.pmove_flags (+) FL_SEMIFIRE;
			target.ammo_nails -= 1;
			target.attack_time = 1/8;
			}
			else if(target.weapon == 2)
			{
				damage = 14;
				tracelineb(target.origin+target.view_ofs,target.origin+target.view_ofs+v_forward*2000,MOVE_HITMODEL,target,timer);
				if(parton)
				{
				sound(target,CHAN_WEAPON,"sounds/pistol1.ogg",ATTN_NORM,1,random(98,102));
				#ifdef CSQC
					trailparticles(particleeffectnum("pitch.trace"),target,weapon_origin+v_forward*20,trace_endpos);
					offset_x += 0.5;
					offset_y += random(-0.5,0.5);
				#endif
				}
				
				if(trace_ent.classname == "zombie" && trace_ent.health)
				{ 
					#ifdef SSQC
						send_damage(target,trace_ent,damage); 
						trace_ent.health -= damage;
					#endif
					
				}
			target.ammo_nails -= 1;
			target.attack_time = 1/14;
			}
			else if(target.weapon == 4)
			{
				damage = 100;
				print("test\n");
				tracelineb(target.origin+target.view_ofs,target.origin+target.view_ofs+v_forward*2000,MOVE_HITMODEL,target,timer);
				float hitdist = bound(0,vlen(target.origin - trace_endpos),200);
				float hitdist_scale = (1-(hitdist/200));
				if(hitdist < 200)
				{
					print(ftos(hitdist));
					print("\n");
					print(ftos(hitdist_scale));
					print("\n");
					target.velocity += normalize(target.origin+[0,0,self.maxs_z/2]-trace_endpos)*600*hitdist_scale;
					target.health -= rint(50*hitdist_scale);
					target.health_timer = -2;
				}

					findradiusb(target,trace_endpos,timer,200);

				if(parton)
				{

					sound(target,CHAN_WEAPON,"sounds/pistol1.ogg",ATTN_NORM,1,random(98,102));
				#ifdef CSQC
					trailparticles(particleeffectnum("pitch.trace"),target,weapon_origin+v_forward*20,trace_endpos);

				#endif
				}
	

				if(trace_ent.classname == "zombie" && trace_ent.health)
				{ 
					#ifdef SSQC
						send_damage(target,trace_ent,damage); 
						trace_ent.health -= damage;
					#endif
					
				}
			target.ammo_rockets -= 1;
			target.attack_time = 1/1.2;
			}
			else if(target.weapon == 5 && !(target.pmove_flags & FL_SEMIFIRE))
			{
				damage = 100;
				print("test\n");
				tracelineb(target.origin+target.view_ofs,target.origin+target.view_ofs+v_forward*2000,MOVE_HITMODEL,target,timer);

				if(parton)
				{
				sound(target,CHAN_WEAPON,"sounds/pistol1.ogg",ATTN_NORM,1,random(98,102));
				#ifdef CSQC
					trailparticles(particleeffectnum("pitch.trace"),target,weapon_origin+v_forward*20,trace_endpos);
					pointparticles(particleeffectnum("pitch.muzzleflash"),weapon_origin+v_forward*20);
					offset_x += 1.5;
					offset_y += random(-1,1);
				#endif
				}
	

				if(trace_ent.classname == "zombie" && trace_ent.health)
				{ 
					#ifdef SSQC
						send_damage(target,trace_ent,damage); 
						trace_ent.health -= damage;
					#endif
					
				}
			target.pmove_flags (+) FL_SEMIFIRE;
			target.ammo_cells -= 1;
			target.attack_time = 1/3;
			}

		}	

	}




	if(self.wishweapon != self.weapon && self.attack_time == 0)
	{
		target.attack_time = lower_range_x;
	}


	if(target.attack_time > 0)
	{

		target.attack_time -= input_timelength;
		target.v_frame1time += input_timelength;

		if(target.attack_time < 0)
			target.attack_time = 0;

		#ifdef SSQC

		#endif


	}

	if(target.attack_time < 0)
	{

	if(target.attack_time < lower_range_x)
		target.attack_time = lower_range_x;


		if(target.attack_time >= lower_range_x && target.attack_time <= lower_range_y)
		{
			target.attack_time += input_timelength;

			if(target.attack_time >= lower_range_y)
			{
				target.attack_time = upper_range_x;
			}
		}
		else if(target.attack_time >= upper_range_x && target.attack_time <= upper_range_y)
		{
			target.attack_time += input_timelength;
			target.weapon = target.wishweapon;

			if(target.attack_time >= upper_range_y)
			{
				target.attack_time = 0;

			}
		}



		if(target.attack_time > 0)
			target.attack_time = 0;

	}

};
