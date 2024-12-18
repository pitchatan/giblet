void(entity target, int bit) input_call_impulse =
{
	#ifdef SSQC
		
	if(input_impulse == 100)
	{

		dummy = spawnclient();
		dummy.solid = SOLID_SLIDEBOX;
		dummy.movetype = MOVETYPE_WALK;
		dummy.health = 100;
		dummy.armorvalue = 100;
		dummy.classname = "player";
		dummy.angles = target.angles;
		makevectors([0,input_angles_y,0]);
		traceline(target.origin, target.origin-[0,0,50] + v_forward*500,0,target);
		dummy.frame = rint(random(0,3));
		vector norm = vectoangles(trace_plane_normal);
		dummy.angles = [0,input_angles_y,0];
		dummy.health = 100;
		setorigin(dummy,trace_endpos);
		dummy.damage_taker = TRUE;
		
	}

	if(input_impulse == 101)
	{

		dummy = spawn();
		dummy.solid = SOLID_BBOX;
		dummy.movetype = MOVETYPE_NONE;
		dummy.health = 100;
		dummy.armorvalue = 100;
		dummy.classname = "zombie";
		dummy.antilagged = TRUE;

		makevectors(input_angles);
		traceline(target.origin, target.origin+target.view_ofs + v_forward*500,0,target);
		dummy.frame = 0;
		vector norm = vectoangles(trace_plane_normal);
		dummy.angles = [0,input_angles_y,0];
		dummy.health = 100;
		setmodel(dummy,"models/zombie.iqm");
		setsize(dummy,[-25,-25,0],[25,25,60]);
		dummy.damage_taker = TRUE;

		//setsize(dummy,dummy.mins,dummy.maxs);r
		setorigin(dummy,trace_endpos);
		dummy.nextthink = time + 1/60;
		dummy.think = think_zombie;
		
	}
	#endif

	#ifdef CSQC
	if((input_impulse == 92 || input_impulse == 93))
	{	
		
		dummy = spawn();
		dummy.model = "models/test.iqm";
		dummy.origin = target.origin;
		dummy.drawmask = 1;
			if(input_impulse == 92)
				dummy.predraw = predraw_player_ragdoll;
		setmodel(dummy,dummy.model);
		setsize(dummy,[-50,-50,-50],[50,50,50]);
		setorigin(dummy,target.origin+[0,0,0]);
		dummy.velocity = target.velocity*10;
		dummy.movetype = MOVETYPE_WALK;
		dummy.animater = 1;
		print("spawned a starfish yo\n");

	}
	#endif

};