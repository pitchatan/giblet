void() touch_bullet =
{

	if(self.classname == "bullet")
	{

		vector hitorg = self.origin;
		if(!self.touched)
		{

			if(other.classname == "player" || other.classname == "zombie")
			{
				
		
				#ifdef SSQC
				// send_damage(self.owner,self.owner,100);
				#endif

				#ifdef CSQC

				pointparticles(particleeffectnum("pitch.te_blood"),self.origin,normalize(self.velocity),10);
				#endif

				#ifdef CSQC

				#endif

			}
			else
			{

				pointparticles(particleeffectnum("pitch.smokegun"),self.origin,trace_plane_normal*-1,1);
			}

			self.touched = TRUE;

			self.solid = SOLID_NOT;
			#ifdef CSQC
			self.drawmask = 0;
			#endif
			self.velocity = [0,0,0];
			self.movetype = MOVETYPE_NONE;
		}

	#ifdef CSQC
	self.nextthink = time + 1;
	self.think = SUB_Remove;
	#endif

	#ifdef SSQC
	self.nextthink = time + 1;
	self.think = SUB_Remove;
	#endif
	}


}
