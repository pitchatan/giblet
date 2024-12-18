
void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.

	self.solid = SOLID_BSPTRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
	self.flags (+) FL_FINDABLE_NONSOLID;
	setsize(self,self.mins,self.maxs);

	#ifdef SSQC
	self.SendEntity = 0;
	self.SendFlags = 0;
	#endif
};


void(entity target,float force) door_check =
{
				if(trace_ent.classname == "func_door1")
				{
					float infront = is_infront(target,trace_ent.angles);
					if(infront > 0)
					{
						trace_ent.spawnflags = DOOR_OPEN_IN;
						trace_ent.speed += force;
					}
					else
					{
						trace_ent.spawnflags = DOOR_OPEN_OUT;
						trace_ent.speed += force;
					}			
				}

};




void(entity target,vector surfnorm) PMove_Rebound =
{

	// surfnorm = surface normal.
	// target = the entity we want to affect
	// .velocity = current velocity vector of the entity

	float v;
	v = target.velocity*surfnorm;
	target.velocity = target.velocity - surfnorm*(v);

}



void(entity target, float frametimer) CollissionTest =
{
    vector dest, saved_plane_normal, svel = target.velocity;
    float movetime = frametimer, attempts = 3, stepped, flag = 0;
    entity touched = __NULL__;

    // Iterate up to 3 attempts or until all movement is resolved
    while (movetime > 0 && attempts--)
    {
        // Calculate destination based on current velocity and time
        dest = target.origin + target.velocity * movetime;

        // Perform trace to destination
        tracebox(target.origin, pmove_mins, pmove_maxs, dest, flag, target);
        target.origin = trace_endpos;

        // Handle collision with an entity
        if (trace_ent.touch)
            touched = trace_ent;

        // Check if the trace hit something
        if (trace_fraction < 1)
        {
            // Save the normal of the plane we collided with
            saved_plane_normal = trace_plane_normal;

            // Reduce the remaining movement time
            movetime *= (1 - trace_fraction);

            // Attempt to step up if collision occurred
            vector step_dest = target.origin;
            step_dest_z += stepheight;
            tracebox(target.origin, pmove_mins, pmove_maxs, step_dest, flag, target);
            stepped = trace_endpos_z - target.origin_z;

            // Handle entity touch on step-up
            if (trace_ent.touch)
                touched = trace_ent;

            // Move forward from the step-up position
            dest = trace_endpos + target.velocity * movetime;
            dest_z = trace_endpos_z;

            tracebox(trace_endpos, pmove_mins, pmove_maxs, dest, flag, target);

            if (trace_ent.touch)
                touched = trace_ent;

            // If movement succeeded, finalize step and move down
            if (trace_fraction > 0)
            {
                movetime *= (1 - trace_fraction);

                if (trace_fraction < 1)
                    PMove_Rebound(target, trace_plane_normal);

                // Move down after stepping
                dest = trace_endpos;
                dest_z -= stepped + 1;  // Account for stepping height and slight clearance
                tracebox(trace_endpos, pmove_mins, pmove_maxs, dest, flag, target);

                if (trace_ent.touch)
                    touched = trace_ent;

                if (trace_fraction < 1)
                    PMove_Rebound(target, trace_plane_normal);

                target.origin = trace_endpos;
                continue;
            }
            else
            {
                // Stepping failed, perform rebound
                PMove_Rebound(target, saved_plane_normal);
            }
        }
        else
        {
            // No collision, exit loop
            break;
        }
    }
    // Check for Door interaction
	traceline(target.origin+target.view_ofs,target.origin+target.view_ofs+normalize(target.velocity)*30,0,target);

	if(trace_fraction < 1)
	{
		if(vlen(target.velocity) > 380)
			door_check(target,vlen((self.velocity*40)*frametimer));
		else
			door_check(target,vlen((self.velocity*10)*frametimer));
	}


    // Check for trigger interactions
    tracebox(target.origin+[0,0,60], pmove_mins, pmove_maxs, target.origin + (svel * frametimer), MOVE_TRIGGERS, target);
    if (trace_fraction < 1)
    {
        target.last_touch = (trace_ent.touch) ? trace_ent : world;

					if(trace_ent.classname == "func_door1")
					{
						//print("hitting a door!");
					}
				

    }
    else
    {
        target.last_touch = world;
    }

			//	traceline(target.origin+target.view_ofs, target.origin+target.view_ofs+target.velocity, TRUE, target);
			//	print("CHECKING FOR DOORS\n");


    // Handle trigger touch logic
    if (target.last_touch != world)
    {
        entity selfb = self;
        other = target;
        self = target.last_touch;
        target.last_touch.touch();
        self = selfb;

        touched = world;

#ifdef CSQC
        // Uncomment if needed: setviewprop(VF_CL_VIEWANGLES, target.angles);
#endif
    }

    // Set movement type to none to stop further processing
    target.movetype = MOVETYPE_NONE;
};





void(entity target, float frametimer) CollissionTest1 =
{
	vector dest;
	vector saved_plane_normal;
	float stepped;
	float movetime;
	float attempts;
	entity touched;
	vector svel = target.velocity;
	float flag;
	flag = 0;
	// flag (+) MOVE_TRIGGERS;




	for (attempts = 3, movetime = frametimer; movetime>0 && attempts; attempts--)
	{
		dest = target.origin + target.velocity*movetime;
		tracebox(target.origin, target.mins, target.maxs, dest, flag, target);	//try going straight there


			target.origin = trace_endpos;

			if(trace_ent.touch)
			touched = trace_ent;

		target.origin = trace_endpos;


		if (trace_fraction < 1)
		{

			saved_plane_normal = trace_plane_normal;
			movetime -= movetime * trace_fraction;

			if (movetime)
			{
				//step up if we can
				trace_endpos = target.origin;
				trace_endpos_z += stepheight;
				tracebox(target.origin, target.mins, target.maxs, trace_endpos, flag, target);
				stepped = trace_endpos_z - target.origin_z;
			
			if(trace_ent.touch)
			touched = trace_ent;	


				dest = trace_endpos + target.velocity*movetime;
				dest_z = trace_endpos_z;

				//move forwards
				tracebox(trace_endpos, target.mins, target.maxs, dest, flag, target);
				
			if(trace_ent.touch)
			touched = trace_ent;

				//if we got anywhere, make this raised-step move count
				if (trace_fraction != 0)
				{
					
					movetime -= movetime * trace_fraction;
					// self.flags (+) FL_ONGROUND;
					
					if (trace_fraction < 1)
						PMove_Rebound(target,trace_plane_normal);
					
					
					//move down
					dest = trace_endpos;
					dest_z -= stepped+1;
					tracebox(trace_endpos, target.mins, target.maxs, dest, flag, target);

			if(trace_ent.touch)
			touched = trace_ent;
				
					if (trace_fraction < 1)
					{
							
						PMove_Rebound(target,trace_plane_normal);


					}
					
					target.origin = trace_endpos;


					if((self.flags & FL_ONGROUND))
					{
						//target.velocity_z += stepped;

					}

					
					movetime -= movetime * movetime;
					continue;
				}

			}
	

			
			//stepping failed, just bounce off
			PMove_Rebound(target,saved_plane_normal);


		}
		else
		{

			//break;
		}


		}



				
				tracebox(target.origin, target.mins, target.maxs, target.origin+(svel*frametimer), MOVE_TRIGGERS, target);

				
				if(trace_fraction < 1)
				{
					

					if(trace_ent.touch != __NULL__)
					{
						target.last_touch = trace_ent;
					}
					else
					{
						target.last_touch = world;
					}
				}
				else
				{
					target.last_touch = world;				
				}

				if(target.last_touch != world)
				{
							other = target;
							entity selfb = self;
								self = target.last_touch;
								target.last_touch.touch();
								self = selfb;

								touched = world;
					#ifdef CSQC
					// setviewprop(VF_CL_VIEWANGLES,target.angles);
					#endif

				}
			

				target.movetype = MOVETYPE_NONE;
}






void SetMovementDir(vector input)
{
	makevectors(input);
}

void Accelerate(entity target,vector wishdir,float wishspeed,float accel,float frametimer)
{

	float addspeed;
	float accelspeed;
	float currentspeed;

	currentspeed = dotproduct(target.velocity, wishdir);
	addspeed = wishspeed - currentspeed;

	if(addspeed <= 0)
		return;

	accelspeed = accel * frametimer * wishspeed;

	if(accelspeed > addspeed)
		accelspeed = addspeed;

	target.velocity_x += accelspeed * wishdir_x;
	target.velocity_y += accelspeed * wishdir_y;
}



void AirMove(entity target,vector input_move,float frametimer)
{
	vector wishdir;
	float wishvel = airAcceleration;
 	float accel;
	vector moveDirectionNorm;

	wishdir = input_move;

	makevectors(input_angles);
	wishdir = [input_move_x,input_move_y, 0];
	wishdir = (v_forward*input_move_x) + (v_right*input_move_y);




	float wishspeed = magnitude(wishdir);
	
		wishspeed *= 150;

	wishdir = normalize(wishdir);
	moveDirectionNorm = wishdir;

	// CPM: Aircontrol
	float wishspeed2 = wishspeed;

	//if(Vector3.Dot(playerVelocity, wishdir) < 0)
	if(dotproduct(target.velocity, wishdir) < 0)
		accel = airDeacceleration;
	else
		accel = airAcceleration;

	// If the player is ONLY strafing left or right

	if(input_move_x == 0 && input_move_y != 0)
	{
		if(wishspeed > sideStrafeSpeed)
			wishspeed = sideStrafeSpeed;
			
		accel = sideStrafeAcceleration;
	}
	else
	{
		if(wishspeed > sideStrafeSpeed)
			wishspeed = sideStrafeSpeed;
			
		accel = sideStrafeAcceleration;		
	}


		
	// !CPM: Aircontrol

	
	if(airControl)
	{
            
		wishspeed2 = wishspeed;
            if (vDot(target.velocity, wishdir) < 0)
            {
                accel = airDeacceleration;
            }
            else
            {
                accel = airAcceleration;
            }
	}
	
	// Apply gravity
	target.velocity_z -= 800 * frametimer;


	Accelerate(target,wishdir, wishspeed, accel,frametimer);
		ApplyFriction(40,target,frametimer);	

	if(airControl)
		AirControl(target,input_move,wishdir, 200,frametimer);


	// LEGACY MOVEMENT SEE BOTTOM

			if(target.stamina > 0)
			target.stamina = bound(0,target.stamina - (0.25*frametimer),1);

	if((target.pmove_flags & FL_FLY) && !(input_buttons & 2))
		target.pmove_flags (-) FL_FLY;

}



void CrouchMove(entity target,vector input_move,float frametimer)
{

	float zspeed;
	float speed;
	float dot;
	float k;
	vector wishdir;
	float wishvel = airAcceleration;
 	float accel;
	vector moveDirectionNorm;

	wishdir = input_move;


	makevectors(input_angles);


	float scal = getfraction(view_crouch_offset,view_offset,target.view_ofs_z);

	if(magnitude(target.velocity) > 150)
		wishdir = ((v_forward*input_move_x) + (v_right*input_move_y));
	else
		wishdir = (v_forward*input_move_x) + (v_right*input_move_y);

	if(magnitude(target.velocity) > 120)
	{
		ApplyFriction(0.001,target,frametimer);
		target.stamina = bound(0,target.stamina + (3*frametimer),1);
	}
	else
	{
		ApplyFriction(1,target,frametimer);	
		target.stamina = bound(0,target.stamina - (0.5*frametimer),1);
	}

	float wishspeed = magnitude(wishdir);
	
		wishspeed *= moveSpeed;

		wishdir = normalize(wishdir);
	moveDirectionNorm = wishdir;

	// CPM: Aircontrol
	float wishspeed2 = wishspeed;

	//if(Vector3.Dot(playerVelocity, wishdir) < 0)

	if(dotproduct(target.velocity, wishdir) < 0)
		accel = airDeacceleration;
	else
		accel = airAcceleration;

	// If the player is ONLY strafing left or right

		if(magnitude(target.velocity) >= 150)
		{
			wishspeed = 150;
		}
		else
		{
			wishspeed = 150;
			//ApplyFriction(0.4,target,frametimer);
		}



	
	// Apply gravity
	// target.velocity_z -= 800 * frametimer;

	if(scal)
	{
		Accelerate(target,wishdir, (1000*scal)*(1-target.stamina), accel,frametimer);
	}
	else
	{
		Accelerate(target,wishdir, wishspeed, accel,frametimer);
		ApplyFriction(0.5,target,frametimer);	
	}

	Accelerate(target,wishdir, wishspeed, accel,frametimer);

	// if(airControl)
		//AirControl(target,input_move,wishdir, wishspeed2,frametimer);



	// LEGACY MOVEMENT SEE BOTTOM

}

/**

 * Air control occurs when the player is in the air, it allows

 * players to move side to side much faster rather than being

 * 'sluggish' when it comes to cornering.

 */
vector moveDirectionNorm;

void AirControl(entity target, vector input_move, vector wishdir, float wishspeed,float frametimer)
{
	float zspeed;
	float speed;
	float dot;
	float k;
noref	int i;

	// Can't control movement if not moving forward or backward
	if(input_move_x == 0 || wishspeed < 0.001)
		return;



	zspeed = target.velocity_z;
	target.velocity_z = 0;

	/* Next two lines are equivalent to idTech's VectorNormalize() */
	speed = magnitude(target.velocity);
	target.velocity = normalize(target.velocity);


	dot = dotproduct(target.velocity, wishdir);
	k = 32;
	k *= (airControl * dot) * frametimer;



	// Change direction while slowing down
	if(dot > 0)
	{
		target.velocity_x = target.velocity_x * speed + wishdir_x * k;
		target.velocity_y = target.velocity_y * speed + wishdir_y * k;
		// target.velocity_z = target.velocity_z * speed + wishdir_z * k;
		target.velocity = normalize(target.velocity);
		moveDirectionNorm = target.velocity;
	}

	target.velocity_x *= speed;
	target.velocity_y *= speed;
	target.velocity_z = zspeed; // Note this line



}



/**

 * Called every frame when the engine detects that the player is on the ground

 */

void GroundMove(entity target,vector input_move,float frametimer)
{


	vector wishdir;	
noref	vector wishvel;
	//float wishJump;
	// Do not apply friction if the player is queueing up the next jump
		ApplyFriction(1.0,target,frametimer);
		

/*
	wishdir = Vector3(cmd.rightmove, 0, cmd.forwardmove);
	wishdir = transform.TransformDirection(wishdir);
*/
float xback = input_angles_x;
	input_angles_x = 0;

	makevectors(input_angles);
	input_angles_x = xback;
	
	wishdir = [input_move_x,input_move_y, 0];
	wishdir = (v_forward*input_move_x) + (v_right*input_move_y);
	wishdir = normalize(wishdir)*pmove_scale;


	float wishspeed = magnitude(wishdir);
	
	if(target.jump_timer > 0)
	{
	//	wishdir = wishdir*0.1;
		// input_move = input_move*0.1;
		//wishspeed *= 0.2;
	}	
	
	if(input_move_z < 0)
	{



		wishspeed *= -260;





	}
	else
	{

			
	}
		wishspeed *= moveSpeed;


	// Reset the gravity velocity
	target.velocity_z = 0;




	if((input_buttons & 2) && !(target.pmove_flags & FL_FLY))
	{
		
			wishJump = TRUE;
	}



	if(wishJump && !(target.pmove_flags & FL_FLY))
	{
		

		
		if(target.stamina < 0.8)
		{
			target.velocity_z = bound(0,240*bound(0.7,(1-target.stamina),1),200);
			target.stamina += 0.50;
			target.pmove_flags (+) FL_FLY;
		}


		wishJump = FALSE;

	}

		if(target.stamina > 0)
			target.stamina = bound(0,target.stamina - (1.5*frametimer),1);
	
	Accelerate(target,wishdir, wishspeed,runAcceleration,frametimer);

	if((target.pmove_flags & FL_FLY) && !(input_buttons & 2))
		target.pmove_flags (-) FL_FLY;
}

/**

 * Applies friction to the player, called in both the air and on the ground

 */
void ApplyFriction(float t, entity target,float frametimer)
{
	vector vec = target.velocity; // Equivalent to: VectorCopy();
noref	float vel;
	float speed;
	float newspeed;
	float control1;
	float drop;

	vec_z = 0.0;
	speed = magnitude(vec);
	drop = 0.0;

	/* Only if the player is on the ground then apply friction */
	if((target.flags) == (FL_ONGROUND))
	{
		control1 = speed < runDeacceleration ? runDeacceleration : speed;	
		drop = control1 * friction1 * frametimer * t;
	}


	newspeed = speed - drop;

	playerFriction = newspeed;

	if(newspeed < 0)
		newspeed = 0;

	if(speed > 0)
		newspeed /= speed;

	target.velocity_x *= newspeed;
	target.velocity_y *= newspeed;
	// target.velocity_z *= newspeed;
}

/**

 * Calculates wish acceleration based on player's cmd wishes

 */
void Accelerater(entity target,vector wishdir,float wishspeed,float accel,float frametimer)
{
	float addspeed;
	float accelspeed;
	float currentspeed;

	currentspeed = dotproduct(target.velocity, wishdir);

	addspeed = wishspeed - currentspeed;

	if(addspeed <= 0)
		return;
	//accelspeed = accel * frametimer * wishspeed;
	accelspeed = accel * wishspeed;

	if(accelspeed > addspeed)
		accelspeed = addspeed;

	target.velocity_x += accelspeed * wishdir_x;
	target.velocity_y += accelspeed * wishdir_y;
}


float GetSurfaceAngle(vector surfnorm)
{
/*
        vector normal = trace_plane_normal;
        float angle = -1 * (atan2(normal.z, sqrt(normal.x*normal.x + normal.y*normal.y)) * 180 / M_PI);
*/

        vector normal = surfnorm;
        float angle = RadToDeg(asin(dotproduct(normal, '0 0 1')));

        return angle;

}

float GetSurfaceAngle2(entity e)
{
    vector start = e.origin;
    vector end = start;
    end.z -= 80;  // trace to a point just below the entity

    //traceline(start, end, 0, e);
	tracebox(start, e.mins, e.maxs, end, FALSE, e);

    if (trace_fraction < 1)
    {
        vector normal = trace_plane_normal;
        float angle = RadToDeg(asin(dotproduct(normal, '0 0 1')));
        return angle;
    }

 //   return 0;  // no surface found
}


void(entity target, float frametimer) PMove_Categorise =
{	

	//if we're moving up, we're not on the ground

	if (target.velocity_z > 0)
	{
		target.flags (-) FL_ONGROUND;
				//print("velocity in air\n");
	}
	else
	{
		//don't know, maybe we are, maybe we're not
		tracebox(target.origin, target.mins, target.maxs, target.origin-'0 0 1', FALSE, target);

		if (trace_fraction == 1)
		{

				target.flags (-) FL_ONGROUND;
				//print(" in air\n");

		}
		else if (trace_fraction < 1)
		{
			target.flags (+) FL_ONGROUND;
		}
	}

};




void(entity target, vector input_move, float frametimer) do_mantle
{
	if(!target.mantle && (input_buttons & 2))
	{
		makevectors([0,input_angles_y,0]);

		traceline(target.origin,target.origin+target.view_ofs+v_forward*32,FALSE,target);
		vector begin_pos = trace_endpos;

		if(trace_fraction < 1 && trace_ent == world)
		{

		#ifdef CSQC
			if(cvar("cg_debug_mantle"))
				pointparticles(particleeffectnum("pitch.dot"),trace_endpos);
		#endif

			traceline(trace_endpos+[0,0,70]+v_forward*10,trace_endpos,FALSE,target);
			vector end_pos = trace_endpos;

			if(trace_fraction < 1 && vlen(begin_pos - end_pos) <= 45)
			{
				float adder;
				trace_endpos_z += 1;

				tracebox([target.origin_x,target.origin_y,trace_endpos_z], target.mins,target.maxs, trace_endpos, FALSE, target);


				if(trace_fraction == 1)
				{

					#ifdef CSQC
						if(cvar("cg_debug_mantle"))
							pointparticles(particleeffectnum("pitch.greendot"),trace_endpos);
					#endif

					if(input_buttons & 2)
					{
						target.attack_time = lower_range_x;
						target.mantle = TRUE;
						target.mantle_target = trace_endpos+[0,0,1];
						target.velocity_z = 0;
					}
				}
				else
				{
					#ifdef CSQC
						if(cvar("cg_debug_mantle"))
							pointparticles(particleeffectnum("pitch.dot"),trace_endpos);
					#endif			
				}

			}

		}


	}
	else if(target.mantle && target.mantle_target)
	{
			target.velocity = [0,0,0];
		if(target.origin_z < target.mantle_target_z)
		{
			target.origin_z += 220*frametimer;


			target.origin += normalize(target.mantle_target - target.origin)*60*frametimer;
			if(target.origin_z > target.mantle_target_z)
				target.origin_z = target.mantle_target_z;

		}
		else if(target.origin_z == target.mantle_target_z)
		{

				target.velocity_z = 0;
			target.origin += normalize(target.mantle_target - target.origin)*60*frametimer;

			if(target.origin_z > target.mantle_target_z)
				target.origin_z = target.mantle_target_z;

				if(vlen(target.origin - target.mantle_target) < 10)
				{
					target.mantle = FALSE;
					target.mantle_target = [0,0,0];	
					print("removed mantle state\n");			
				}				

		}
		

		if(vlen(target.origin - target.mantle_target) > 155)
		{
					target.mantle = FALSE;
					target.mantle_target = [0,0,0];	
					print("removed mantle state\n");


		}

		#ifdef CSQC
		if(cvar("cg_debug_mantle"))
		{
			if(trace_fraction < 1)
				pointparticles(particleeffectnum("pitch.dot"),target.mantle_target);
			else
				pointparticles(particleeffectnum("pitch.greendot"),target.mantle_target);
		}
		#endif	
	}


};

void(entity target, float buttons, vector input_move, float frametimer) Pmove_Run =
{
		#ifdef SSQC

		if(target.health <= 0 && target.classname == "player" )
		{

			target.respawn_timer += frametimer;
		}

		if(target.respawn_timer >= 3)
		{
			PutClientInServer();
			target.respawn_timer = 0;
		}

		if(target.health > 0 && target.health < 100 && target.classname == "player" )
		{
			target.health_timer += frametimer;
			
			if(target.health_timer >= 0.05)
			{
				target.health += 1;
				target.health_timer = 0;
			}
			
		}

		#endif
		
		if(target.health < 0)
			input_move = [0,0,0];

		float oldflags = target.flags;
		pmove_scale = vfrac(input_move_x,input_move_y,300);



		PMove_Categorise(target,frametimer);
		if(target.health <= 0)
		{
			//input_move = [0,0,0];
		}
	
		if((target.flags & FL_ONGROUND) && !target.mantle)
		{
			//GroundMove(target,input_move,frametimer);
			
			if(input_move_z >= 0)
				GroundMove(target,input_move,frametimer);
			else if(input_move_z < 0)
				CrouchMove(target,input_move,frametimer);
		
		}
		else if(!(target.flags & FL_ONGROUND) && !target.mantle)
		{
			AirMove(target,input_move,frametimer);
		}



		if(target.flags & FL_ONGROUND)
		{
			if(input_move_z < 0)
			{
				target.view_ofs = [0,0,bound(view_crouch_offset,target.view_ofs_z - 100*frametimer,view_offset)];
			}
			else
			{
				target.view_ofs = [0,0,bound(view_crouch_offset,target.view_ofs_z + 100*frametimer,view_offset)];
			}
		}
		else
		{
				target.view_ofs = [0,0,bound(view_crouch_offset,target.view_ofs_z + 10*frametimer,view_offset)];
		}

		do_mantle(target,input_move,frametimer);
		CollissionTest(target,frametimer);



		setorigin(target,target.origin);

		#ifdef SSQC
		// rollback_add(target,target.origin,input_angles,target.velocity,self.frame,self.frame1time,time);

		if(target.flags & FL_ONGROUND)
		{

		}
		#endif

};

void() misc_teleporter_dest =
{

};

void() tele_touch =
{
	entity finder = find(world,targetname,self.target);

	if(finder != world && other != world)
	{

		makevectors(finder.angles);
		setorigin(other,finder.origin+v_forward*40);
		other.velocity = v_forward*320;
		other.angles = finder.angles;
		#ifdef CSQC
		setproperty(VF_ANGLES,finder.angles);
		setproperty(VF_CL_VIEWANGLES,finder.angles);
		#endif

		#ifdef SSQC
		//sound(self,CHAN_AUTO,"sounds/teleporter.ogg",1,ATTN_NORM,random(90,110));
		pointsound(self.origin,"sounds/teleporter.ogg",1,ATTN_NORM);
	//	sound(finder,CHAN_AUTO,"sounds/teleporter.ogg",1,ATTN_NORM,random(90,110));
		pointsound(finder.origin,"sounds/teleporter.ogg",1,ATTN_NORM);
		#endif
	}


}


void() trigger_teleport =
{
	InitTrigger();
	self.name = self.name;
	self.targetname = self.targetname;
	print(self.targetname);
	print(" : ");
	print(vtos(self.absmin - self.absmax));
	print(" spawned teleporter\n");
	
	#ifdef CSQC
	//ambientsound(self.absmax-self.absmin,"assets/sounds/jumppad_ambient.ogg",1,ATTN_STATIC);
	#endif
	
	self.touch = tele_touch;
	
};


void SlideEntity(entity ent, float deltatime) 
{

	vector end,start,trace;

    if (ent.flags & FL_ONGROUND)
    {
        // Trace downward to find the slope
        start = ent.origin;
        end = start - '0 0 50'; // Adjust the trace length as needed
        //traceline(start, end, TRUE, ent);
	  // void(vector start, vector mins, vector maxs, vector end, float nomonsters, entity ent) tracebox
	tracebox(start,ent.mins,ent.maxs,end,0,ent);

        trace = trace_endpos;

		if(trace_ent == world)
		{
			//vector VectorProjectOnPlane(vector vec, vector normal


			vector vex = normalize(VectorProjectOnPlane(ent.origin - [0,0,100],trace_plane_normal));


 			float slope_angle = anglemod(90 - fabs(trace_plane_normal_z * 90));
			//print(ftos(slope_angle));
			//print("\n");

			if (slope_angle > 1 && slope_angle < 20)
			{
			ent.velocity += trace_plane_normal*6000*deltatime+[0,0,100]*deltatime;
			ent.velocity_z = 0;
			ent.origin_z = ent.origin_z + (ent.origin_z - trace_endpos_z);


			}
		}
	}


}

