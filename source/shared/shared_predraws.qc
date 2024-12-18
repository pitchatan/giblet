float() predraw_player_ragdoll =
{

// float(float skel, entity ent, float modelindex, float retainfrac, float firstbone, float lastbone, optional float addfrac) skel_build = #264; /* Part of FTE_CSQC_SKELETONOBJECTS

if(cvar("cg_dummy_rigid"))
{
	self.movetype = MOVETYPE_WALK;
	self.animater = 0;
	self.movetype = MOVETYPE_FLY;
	makevectors(self.angles);
	traceline(self.origin, self.origin+[0,0,-700], TRUE, self);
	self.origin_z = trace_endpos_z + 20; // + sin(time*4)*20;
	//dummy.origin_z = dummy.origin_z + sin(time*4)*15*frametime + 1*frametime;

	self.velocity = v_forward*620;
}
	if(!self.skeletonindex)
	{
		self.skeletonindex = skel_create(self.modelindex);
		skel_build(self.skeletonindex, self, self.modelindex, 0, 0, 0, 1);
	}

	if(!self.rag)
	{
		self.rag = skel_create(self.modelindex);
		skel_build(self.rag, self, self.modelindex, 0, 0, 0, 1);

	}
		/*
		self.frame = 3;
		self.frame2 = 3;
		self.frame1time += frametime;
		self.frame2time += frametime;
		*/

		if(self.frame1time > frameduration(self.modelindex,self.frame))
		{
				self.frame1time = 0;
		}

		if(self.frame2time > frameduration(self.modelindex,self.frame2))
		{
				self.frame2time = 0;
		}

		skel_build(self.skeletonindex, self, self.modelindex, 0, 0, 0, 1);
		skel_build(self.rag, self, self.modelindex, 0, 0, 0, 1);


		skel_ragupdate(self,"doll models/test.iqm.doll",self.rag);
		if(!cvar("cg_dummy_rigid"))
		skel_ragupdate(self,strcat("animate ",ftos(0)),self.rag);


	self.animater -= frametime;
	self.animater = bound(0,self.animater,1);


	if(!outlines)
	{
	self.glowmod = [0,0,0];

	self.scale = 1;




	// self.animater = 1;


	}
	else
	{


		self.glowmod = [2,0,0];
	}
	self.alpha = 1;

//void(float skeldst, float skelsrc, float startbone, float entbone) skel_copybones = #274; 
/* Part of FTE_CSQC_SKELETONOBJECTS
		Copy bone data from one skeleton directly into another. */

		// skel_copybones(self.skeletonindex,self.rag,0,skel_get_numbones(self.skeletonindex));


	self.animater2 += frametime;


	if(self.animater2 > 14)
	{

	}

	if(self.animater2 > 225)
	{
		skel_delete(self.skeletonindex);
		skel_delete(self.rag);

		remove(self);
	}

	return FALSE;
};
