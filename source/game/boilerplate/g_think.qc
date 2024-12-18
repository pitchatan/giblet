void() think_func_rotating =
{
	#ifdef SSQC



	self.glowmod_x = bound(0,sin(time)*1,1);
	self.glowmod_y = bound(0,sin(time*2)*1,1);
	self.glowmod_z = bound(0,sin(time*-3)*1,1);



	float lasttime = self.ltime-self.lastrun;
	self.avelocity_x = 0;
	self.avelocity_z = 0;

	if(self.spawnflags == DOOR_CLOSED)
	{
		self.angles = self.angles_target;
		//self.avelocity = 0;
	}
	else
	{



		if(self.spawnflags == DOOR_OPEN_IN)
		{
				self.avelocity_y = 1;
				//print("open in!\n");
		}
		else if(self.spawnflags == DOOR_OPEN_OUT)
		{

				self.avelocity_y = -1;
				//print("open out!\n");
		}

		if(self.angles_y >= self.angles_target_y+90)
		{
			self.spawnflags = DOOR_OPEN_OUT;
			self.angles_y = self.angles_target_y+90-5;
			self.speed -= 250;
			if(self.speed < 0)
				self.speed = 0;
		}
		else if(self.angles_y <= self.angles_target_y-90)
		{
			self.spawnflags = DOOR_OPEN_IN;
			self.angles_y = self.angles_target_y-90+5;
			self.speed -= 250;
			if(self.speed < 0)
				self.speed = 0;
		}



		if(self.speed > 0)
		{
			self.speed = bound(0,self.speed - (200*lasttime),600);

			print("^2##########################################\n");
			print("^1lasttime: ");
			print(ftos(lasttime));
			print("\n");

			print("^1time: ");
			print(ftos(time));
			print("\n");

			print("^1ltime: ");
			print(ftos(self.ltime));
			print("\n");

			print("^1speed: ");
			print(ftos(self.speed));
			print("\n");
			print("^2##########################################\n\n");
		}
		else
		{
			// self.speed = 0;
			self.spawnflags = 0;
		}

		if(self.avelocity)
		{
			self.avelocity_y *= self.speed;
		}
	}

	setmodel(self,self.model);
	setorigin(self, self.origin);
	self.nextthink = self.ltime + 1/60;
		self.lastrun = self.ltime;
	#endif


}


void() think_zombie =
{

	if(self.health < 0)
		self.health = 0;

	float delta;
	self.movetype = MOVETYPE_NONE;
	if(!self.lastrun)
		self.lastrun = time;
	else
		delta = time - self.lastrun;


	if(self.lastrun)
	{
	float buttons = 0;
	//setsize(self,[-25,-25,0],[25,25,50]);
	//setmodel(self,self.model);
		if(time > self.zombie_search && self.health)
		{
			float closest;

			// entity(vector org, float rad, optional .entity chainfield) findradius 
			entity finder = findradius(self.origin,1000);

			while(finder)
			{
				if(finder.classname == "player")
				{
					if(!closest)
					{
					closest = vlen(self.origin - finder.origin);
					self.goalentity = finder;
					}

					
					if(closest > vlen(self.origin - finder.origin))
					self.goalentity = finder;
				}

				finder = finder.chain;
			}
			self.zombie_search = time + 1/3;
		}


		if(self.attack_time)
			self.attack_time -= delta;

		if(self.attack_time < 0)
			self.attack_time = 0;

		if(self.health)
		{
		self.angles_x = 0;
		self.angles_z = 0;
		
			vector target_angle = (vectoangles([self.origin_x,self.origin_y,self.origin_z] - [self.goalentity.origin_x,self.goalentity.origin_y,self.goalentity.origin_z]));
			float diff;
			
			diff = (angle_diff_signed(self.angles_y,target_angle_y));
			vector target_angle_vector = angle_diff_signed_v(self.angles,target_angle);

			if(self.aggro)
			self.angles_y += target_angle_vector_y*delta*0.2;
			else
			self.angles_y += target_angle_vector_y*delta*0.2;
		
		}


		self.angles_x = 0;
		self.angles_z = 0;

		vector move_value;
		vector move_angles = self.angles;

		if(self.goalentity)
		{
			if(vlen(self.origin - self.goalentity.origin) < 80)
			{
				move_value = [0,0,0];
			}
			else
			{
				if(self.aggro > 1)
					move_value = [300,0,0];
				else
					move_value = [200,0,0];
			}
		}

		if(self.attack_time)
			move_value = 0;

		if(!self.health)
		move_value = [0,0,0];

		float trace_test;

		if(time > self.zombie_trace_time && self.health)
		{
			makevectors(self.angles);
		
			traceline(self.origin,self.origin+[0,0,30]+v_forward*40,FALSE,self);

			if(trace_fraction < 1 && trace_ent)
			trace_test = TRUE;
		


			self.zombie_trace_time = time + 1/3;
		}

		if(trace_test)
		{
			if(random(0,100) > 50 && !self.attack_time)
			{
				sound(self,CHAN_VOICE,strcat("sounds/Zombie001_Attack_A_00",ftos(rint(random(1,3))),".ogg"),1,ATTN_NORM,random(90,110));

				self.attack_time = frameduration(self.modelindex,2);
				self.frame = 2;
				self.voice_time = time + 2;
			}

		}

		if(!self.spawn_dead && !self.health)
		{
			self.frame1time = 0;
			self.spawn_dead = TRUE;
		}

		input_angles = self.angles;


		input_impulse = 0;

		do_physics(self,0,move_value,delta,TRUE);
		input_buttons = 0;
		if(magnitude(self.velocity) > 1 && self.health)
		{
			if(self.aggro > 1)
				self.frame = 4;
			else
				self.frame = 1;
		}
		else if(magnitude(self.velocity) < 1)
		{
			if(self.health)
			{
				if(!self.attack_time)
					self.frame = 0;
				else
					self.frame = 2;
			}
			else
			{
				self.frame = 3;
			}
		}
		float walktime;
		if(self.frame == 1 || self.frame == 4)
		{
			walktime = (self.frame1time / frameduration(self.modelindex,self.frame));
			if((walktime > 0 && walktime < 0.01) || (walktime > 0.99 && walktime < 1) || (walktime > 0.50 && walktime < 0.51))
			{
				sound(self,CHAN_BODY,strcat("sounds/Footsteps_Zombie_concret_00",ftos(rint(random(1,4))),".ogg"),1,ATTN_NORM,random(90,110));

			}
		}

		if(self.frame == 3)
		{
			walktime = (self.frame1time / frameduration(self.modelindex,self.frame));
			if((walktime > 0.6) && (walktime < 0.61))
			{
				print(ftos(walktime));
				print("\n");
				sound(self,CHAN_BODY,strcat("sounds/Foley_BodyFall_00",ftos(rint(random(1,3))),".ogg"),1,ATTN_NORM,random(90,110));

			}
		}



		if(random(0,500) > 490 && self.health > 0)
		{
			if(time > self.voice_time)
			{
				sound(self,CHAN_VOICE,strcat("sounds/Zombie001_Idle_A_00",ftos(rint(random(1,3))),".ogg"),1,ATTN_NORM,random(90,110));
				self.voice_time = time + 3;
			}

			
		}


		self.frame1time += delta;

		if(self.frame1time >= frameduration(self.modelindex,self.frame))
		{
			if(self.health)
			{
				self.frame1time = 0;
			}
			else
				self.frame1time = frameduration(self.modelindex,self.frame);
		}

	#ifdef SSQC
	self.SendFlags = 0;
	#endif


	if(!self.health)
	{
		if(!self.alpha)
			self.alpha = 4;
		self.alpha -= delta;
		if(self.alpha <= 0)
			remove(self);


	}

		setorigin(self,self.origin);
		#ifdef SSQC
		self.SendFlags = 0;
		self.SendEntity = SV_SendEntityUpdate_Zombie;
		net_send_entity(self);
		AddToSortedBuffer(self,time);
		#endif
	
	}

	self.lastrun = time;
	self.nextthink = time + 1/60;
};

