void() physics_bullet =
{
	if(!self.lastrun)
		self.lastrun = time;

	float lasttime = time-self.lastrun;
	
	if(self.buffer_rollback)
		self.buffer_rollback += lasttime;
	
	if(self.velocity)
	{
		self.solid = SOLID_NOT;
		#ifdef SSQC
		tracelineb(self.origin, self.origin+(self.velocity*(time-self.lastrun)),MOVE_HITMODEL,self,self.buffer_rollback-0.05);
		#endif
		
		#ifdef CSQC
		tracelineb(self.origin, self.origin+(self.velocity*(time-self.lastrun)),MOVE_HITMODEL,self,0);
		#endif


		setorigin(self,trace_endpos);
		if(trace_fraction < 1)
		{
			other = trace_ent;
			self.touch();
			
			if(trace_ent != world)
			{

				#ifdef CSQC
				print("^1[");
				print(strcat("^2",ftos(trace_bone_id)));
				print("^1] ");
				print(strcat("^3",skel_get_bonename(trace_ent.modelindex,trace_bone_id)));
				print("\n");
				#endif

				#ifdef SSQC



				if(trace_ent.health > 0)
				{
					trace_ent.health -= 25;

					if(trace_ent.classname == "zombie")
					trace_ent.aggro = TRUE;

					if(trace_ent.health < 0)
					{
						trace_ent.health = 0;
						if(trace_ent.classname == "zombie")
						{
							trace_ent.frame1time = 0;
							trace_ent.frame = 3;
						}
					}
					

					// send_damage(self.owner,trace_ent,25);
				}

				#endif
			}
			/*
			#ifdef SSQC
			print("sv: ");
			#endif

			#ifdef CSQC
			print("cs: ");
			#endif

			print("hit ");
			print(other.classname);
			print("\n");
			*/
			
			
		}

		
		
	}
		self.lastrun = time;
	if(self.think)
	{
		if(time > self.nextthink)
		self.think();
	}

};
