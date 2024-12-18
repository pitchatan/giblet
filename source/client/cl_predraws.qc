float() predraw_bullet = 
{

	pointparticles(particleeffectnum("pitch.bullet"),self.origin);


};

float() predraw_viewweapon =
{
	// void(vector org, vector pointangles,float height, float width,string texturename) render_face;
	#ifdef CSQC
	render_face(self.origin,self.angles,25,25,"muzzleflash");
	#endif

	return TRUE;
};


float() predraw_smoke
{

	if(self.spawn_dead)
		self.solid = SOLID_NOT;
	else
		self.solid = SOLID_NOT;

	float skala = 18;
	if(cltime > self.spawn_timer)
	{
			if(!self.spawn_offset)
			{
			
				self.spawn_offset = random(-1000,1000);
			}
			int rand = random(0,3);
			// void(float effectnum, vector origin, optional vector dir, optional float count)
			if(cvar("cg_smoke") == 1)
			{
				pointparticles(particleeffectnum("pitch.smoke"),self.origin);




				//				pointparticles(particleeffectnum("pitch.smoke"),self.origin+([sin(self.spawn_offset+cltime),sin(self.spawn_offset+cltime),cos(self.spawn_offset+cltime)]*skala));
			}

			self.spawn_dead = FALSE;
			self.spawn_timer = cltime + 0.4;


	}

	// pointparticles(particleeffectnum("pitch.rope"),self.origin+([sin(self.spawn_offset+cltime),sin(self.spawn_offset+cltime),cos(self.spawn_offset+cltime)]*skala));

	return TRUE;
}
