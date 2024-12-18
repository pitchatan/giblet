void(entity target) spawn_ragdoll =
{
		dummy = spawn();
		dummy.model = "models/test.iqm";
		dummy.origin = target.origin;
	
		dummy.drawmask = 1;
		
				dummy.predraw = predraw_player_ragdoll;
		setmodel(dummy,dummy.model);
		setsize(dummy,[-50,-50,-50],[50,50,50]);
		setorigin(dummy,target.origin+[0,0,0]);
		dummy.velocity = target.velocity;
		dummy.movetype = MOVETYPE_WALK;
		dummy.animater = 1;
		dummy.frame1time = target.frame1time;
		dummy.frame2time = target.frame2time;
		dummy.lerpfrac = target.lerpfrac;
		dummy.angles = target.angles;
		target.damage_taker = DAMAGE_DEAD;
		print("spawned a ragdoll\n");
}