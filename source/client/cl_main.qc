entity currentplayer;			// you... in this case set in CSQC_Ent_Update
.vector oldvelocity; 			// last received velocity
.vector oldorigin; 			// last received origin
.vector oldangles; 			// last received angles... currently not networked
.float oldflags; 			// last receieved pmove_flags
.float oldflags2; 			// last received entity flags
.float spawnflags; 			// spawnflags, used for CSQC map parsing.. see more below at  parsenewmapentity  & SpawnEntities
.float attack_time,attack_timeold;	// CSQC side attack_time and the last received attack_time
.float view_ofs_old;
.vector hook_originold; 		// last received hook_origin
.int hook_heldold; 			// last received hook_hold
.float frame1timeold; 			// last received frame1time

entity ragdoll;

vector angle_offset;
float angle_offset_remove;

float stamina_time;
float stamina_old;
float buffer_length;
vector smoothstep_origin;
vector input_angles_abs;
.int frame_last;
.float frame_duration_last;
int autocvar_cg_hud_debug;
vector autocvar_cg_gun_pos;

int player_zoom;
int player_zoom_fov;
float player_zoom_sens;

float autocvar_cg_zoom_fov;
float autocvar_cg_zoom_sensitivity;
float step;



/* locals that contain predicted_ values  to be used inside of CSQC_UpdateView */
vector predicted_velocity;
vector predicted_origin;
vector predicted_hookorigin;
vector predicted_hookheld;
float predicted_attack_time;
float predicted_vtime1;
float predicted_stamina;
float predicted_flags;
int predicted_ammo_nails;
int predicted_ammo_cells;
int predicted_ammo_rockets;
int predicted_ammo_shells;
int predicted_ammo;
int predicted_weapon;
int predicted_currentweapon;
int predicted_weapon;
int predicted_mantle;
vector predicted_mantle_target;



float() predraw_player =
{
	
	if(outlines)
	{
		float line_dist = vlen(self.origin + predicted_origin);
		line_dist = 100/line_dist;

		if(self.classname == "player")
		{
			self.glowmod = [1*(1-line_dist),1,0]*cos(time*8);
		}
		else
		{
			self.glowmod = [256,71,188]*0.001;	
			self.glowmod *= bound(0.6,2 * cos(time*2),2);
		}
		self.fatness = 0;
		// self.glowmod = [1,1,0];
	}
	else
	{
		self.glowmod = [0,0,0]; 
		self.fatness = 0;
	}

	self.effects (+) EF_NODRAW;

	self.aimassist = TRUE;

	if(self.buffer_count < 10)
	return FALSE;

	if(self != currentplayer)
	{
	setorigin(self,InterpolateBuffer(self,buffer_length-0.05));





	if(self.frame != self.frame_last)
	{
		self.frame2 = self.frame_last;
		self.frame2time = self.frame_duration_last;
		print("setting new frame\n");
		self.lerpfrac = 1;
	}

	if(self.lerpfrac)
	{
		self.lerpfrac -= frametime*4;
		self.lerpfrac = bound(0,self.lerpfrac,1);
	}


	self.frame_last = self.frame;
	self.frame_duration_last = self.frame1time;


		if(self.colormod)
		{
			if(self.colormod_x > 1)
			{
				self.colormod_x -= 15*frametime;
				if(self.colormod_x < 1)
				{
					self.colormod_x = 1;
					self.colormod = 0;
				}
			}
			
		}
	}

	if(self.damage_taker & DAMAGE_DEAD)
	{

		self.animater += frametime;

		if(self.animater > 6)
		{
			self.animater = 0;
			self.damage_taker = 0;
		}

	
	return TRUE;
	}
	else
		return FALSE;

};



/*
	CSQC_UpdateView
		All things related to rendering a scene..
		If renderscene() isn't called nothing will be rendered.. subsequently clearscene()  will ... clear the scene -_-

		You can set various things like resolution and such via the setproperty function..  related values can be found via searching/grep   VF_ 

*/
float screen_bounce;
float bounce_amplitude;     // Initial amplitude of the bounce
float bounce_frequency;    // Frequency of the bounce oscillation
float bounce_damping;     // Damping factor to reduce bounce amplitude over time
float bounce_phase;         // Current phase of the sine wave
float bounce_amount;




float sway_timer;

vector angle_last;
vector viewweapon_angle_offset;

reverbinfo_t standard;
vector offset2;
void(float apilevel, string enginename, float engineversion) CSQC_init =
{
/*
typedef struct {
	float flDensity;
	float flDiffusion;
	float flGain;
	float flGainHF;
	float flGainLF;
	float flDecayTime;
	float flDecayHFRatio;
	float flDecayLFRatio;
	float flReflectionsGain;
	float flReflectionsDelay;
	vector flReflectionsPan;
	float flLateReverbGain;
	float flLateReverbDelay;
	vector flLateReverbPan;
	float flEchoTime;
	float flEchoDepth;
	float flModulationTime;
	float flModulationDepth;
	float flAirAbsorptionGainHF;
	float flHFReference;
	float flLFReference;
	float flRoomRolloffFactor;
	int   iDecayHFLimit;
} reverbinfo_t;
*/



print("init csqc\n");
//void(float reverbslot, reverbinfo_t *reverbinfo, int sizeofreverinfo_t) setup_reverb;

};

float reverb_setup;



float() predraw_weapon =
{
	if(predicted_weapon == 1)
	{
		setmodel(self,"models/pistol1.iqm");
		self.owner.frame = 1;
	}
	else	if(predicted_weapon == 4)
	{
		setmodel(self,"models/rocket1.iqm");
		self.owner.frame = 0;
	}
	else	if(predicted_weapon == 5)
	{
		setmodel(self,"models/sniper1.iqm");
		self.owner.frame = 2;
	}
	else
	{
		setmodel(self,"models/rifle1.iqm");
		self.owner.frame = 0;
	}

	if(outlines)
		self.glowmod = [0.01,0.01,0.01];
	else
		self.glowmod = [0,0,0];
	// render_face(self.origin,self.angles,25,25,"muzzleflash");

	self.renderflags (+) RF_VIEWMODEL;
	self.origin = self.owner.origin;
	self.angles = self.owner.angles;
};

float health_target;
float armor_target;
.float armorvalue;
void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	registercommand("+zoom");
	registercommand("-zoom");
	smoothstep_origin = predicted_origin;
	currentplayer.health = getstati(0);
	currentplayer.armorvalue = getstati(STAT_ARMOR);





	if(!reverb_setup)
	{
	standard.flDensity = 4;
	standard.flDiffusion = 20;
	standard.flGain = 11.3;
	standard.flGainHF = 0.1;
	standard.flGainLF = 40;
	standard.flDecayTime = 3;
	standard.flDecayHFRatio = 1.38;
	standard.flDecayLFRatio = 1;
	standard.flReflectionsGain = 2.5;
	standard.flReflectionsDelay = 0.5;
	standard.flReflectionsPan = [0,0,0];
	standard.flLateReverbGain = 1.5;
	standard.flLateReverbDelay = 1.5;
	standard.flLateReverbPan = [0,0,0];
	standard.flEchoTime = 0.1;
	standard.flEchoDepth = 0.1;
	standard.flModulationTime = 1;
	standard.flModulationDepth = 4.2;
	standard.flAirAbsorptionGainHF = 2;
	standard.flHFReference = 15.5;
	standard.flLFReference = 15.5;
	standard.flRoomRolloffFactor = 1;
	standard.iDecayHFLimit = 20;

	setup_reverb(2,&standard,sizeof(standard));
	print("^1reverb setup\n");
	reverb_setup = TRUE;
	}
		vector screen_size = [vwidth,vheight];
		vector screen_center = [vwidth,vheight] / 2;		// center of screen... no need to do this several times a frame :)
		vector screen_center_top = [vwidth/2,0];
		vector screen_center_bottom = [vwidth/2,vheight];
		vector screen_size_real = screen_size;

    // Reset timer if it gets too high to prevent floating-point inaccuracies
		

	sway_timer += 2*frametime;
    if (sway_timer > 2 * M_PI) 
    {
        sway_timer -= 2 * M_PI;
    }
		

		/*
		Simple hack to get view models into CSQC without having to spawn them serverside or needing to network an entire entity
		*/
		if(!viewweapon)
		{
			viewweapon = spawn();
			viewweapon.drawmask = 1;
			viewweapon.renderflags = RF_VIEWMODEL;
			setmodel(viewweapon,"models/player_arms_full.iqm");
			viewweapon.owner = currentplayer;

			viewweapon2 = spawn();
			viewweapon2.drawmask = 1;
			viewweapon2.predraw = predraw_weapon;
			viewweapon2.owner = viewweapon;


		}
		else
		{
			//viewweapon.origin = [0,0,0];
		}


		clearscene();   // needs to be done at the start of every frame or you end up with a convoluted mess :P


		/*
		print(vtos(screen_size));
		print("\n");
		*/

		if(currentplayer) // if you have retreived yourself.. then perform prediction
		{
				input_angles = input_angles_abs;

				/*
				Set your prediction rollback values before running prediction.
				Needs to be set before every prediction loop or things will entirely desync.
				
				In this demo any fields ending or beginning with "old" are used for networked fields and thus are used for prediction rollback.
				*/
					


				// Prepare rollback
				currentplayer.origin = currentplayer.oldorigin;				
				currentplayer.velocity = currentplayer.oldvelocity;
				currentplayer.pmove_flags = currentplayer.oldflags;
				currentplayer.flags = currentplayer.oldflags2;
				currentplayer.v_frame1time = currentplayer.v_frame1timeold;
				currentplayer.attack_time = getstatf(35);
				currentplayer.hook_origin = currentplayer.hook_originold;
				currentplayer.hook_held = currentplayer.hook_heldold;
				currentplayer.view_ofs_z = getstatf(40);
				currentplayer.stamina = getstatf(41);
				currentplayer.weapon = getstatf(STAT_ACTIVEWEAPON);
				currentplayer.wishweapon = getstatf(32);
				currentplayer.ammo_cells = getstatf(STAT_CELLS);
				currentplayer.ammo_shells = getstatf(STAT_SHELLS);
				currentplayer.ammo_nails = getstatf(STAT_NAILS);
				currentplayer.ammo_rockets = getstatf(STAT_ROCKETS);
				currentplayer.items = getstatbits(STAT_ITEMS,0,23);
				currentplayer.items2 = getstatbits(STAT_ITEMS,23,9);
				currentplayer.mantle = getstati(33);
				currentplayer.mantle_target = [getstatf(37),getstatf(38),getstatf(39)];



			/*
			clientstat(32,EV_INTEGER,wishweapon);
			clientstat(33,EV_INTEGER,mantle);
			clientstat(35,EV_FLOAT,attack_time);
			clientstat(36,EV_FLOAT,v_frame1time);
			clientstat(37,EV_FLOAT,mantle_target_x);
			clientstat(38,EV_FLOAT,mantle_target_y);
			clientstat(39,EV_FLOAT,mantle_target_z);
			*/

				/* 
				Prediction starts here using a for loop.

				servercommandframe = the last confirmed input sequence number recieved from the server.
				clientcommandframe = the current client commandframe, i.e the predicted commandframe as it does not wait for the server..
				getinputstate(foo)  = sets input_foo values from the corresponding sequence number.

					some fairly important input_ values:
						input_timelength = essentially frametime but for input..  makes things overall deterministic as you have the same timelength values serverside as clientside (unless packetloss occurs).
						input_movevalues = fixed values..  x = forward, y = strafe,  z = up/down ... can for example be used for slide behavior if you check Z for a negative value  i.e   if(input_movevalues_z){ slide_on() } else { slide_off() }..   a good alternative to hacking cmd's.
						input_angles  = your view angles when input was processed..  the client/engine will decouple this somewhat as to not have your mouse input feel laggy.. nature of the beast,   e.g 60hz networked input vs   uncapped framerate mouse polling.
						input_impulse = essentially like self.impulse, can be used as a bitmask as well
						input_buttons = bitmask of buttons being pressed..  1 = +attack , 2 = +jump etc.. 16 = +use etc fteqw has a fair bit amount of buttons that can be used ("apropos +"  in console to get a list of them... will probably need some testing to get the appropriate bit for what is being pressed... prints are fairly useful for this)


				Prediction basics:
				1. Rollback to server values..
				2. loop between servercommandframe+1 till we hit clientcommandframe every frame and process all our physics and weapons in here to perform prediction..
				3. Rollback again, for safety.

				

				
					Should be mentioned that you can run these inside of a predraw call as well, but do not work as well when dealing with projectile prediction.
						.predraw field, takes  a float function that allows you to  change things before being rendered (i.e they are called before addentities() ).. usually you peform things like interpolation here.. but can also do per entity prediction if you want.

				*/

					float parton;  // a local float used to determine when the last input sequence was run... important for predicting things like particles and sounds or it will end up rendering/playing sounds several times a frame.
					parton = FALSE; // set to false..  cause im anal like that

				for ( int i = servercommandframe+1; i <= clientcommandframe; i++ )  // loop until i = clientcommandframe..   prediction baby
				{
				
				   float flSuccess = getinputstate( i ); // set input state based on sequence number i

				    if ( flSuccess == FALSE ) {	 // ignore if no input.. 
					continue;
				    }




				/*
					Partial frames are the worst..  
					stops the foor loop completely as input_timelength returning 0 will entirely break things... 
					should be mentioned that   0ping conditions and framerate being lower than input rate can cause partial frames entirely.. will happen with cl_yieldcpu set to 1 on a local server (i.e a listen server).
				*/
				    if (  input_timelength == 0 ) {
						break;
				    }


				


					if((i < clientcommandframe) || (clientcommandframe - servercommandframe) < 2)   // set parton to TRUE when you have reached the end of your loop.
					{
						if(!buffer_sequence_find(input_sequence))
						{
							parton = TRUE;
							buffer_sequence_add(input_sequence);
							//print("added to seq buffer\n");
						}
						else
						{
							//print("seq was found so now we ignore\n");
						parton = FALSE;
						}
					}
					else
					{
						parton = FALSE;
					}


					do_physics(currentplayer,input_buttons,input_movevalues,input_timelength,parton);  // function with physics and weapons that are shared between server and client.. as well as a parton parameter (same function is used server and clientside.. parton should always be TRUE on serverside as it is being run ONCE per frame).



					/*
					Setting some locals with  predicted values.. mostly for debugging purposes (prints etc)... can be used for other things inside CSQC_UpdateView.
					*/
					predicted_vtime1 = currentplayer.v_frame1time;
					predicted_origin = currentplayer.origin;
					predicted_velocity = currentplayer.velocity;
					predicted_hookorigin = currentplayer.hook_origin;
					predicted_hookheld = currentplayer.hook_held;
					predicted_attack_time = currentplayer.attack_time;
					predicted_stamina = currentplayer.stamina;
					predicted_weapon = currentplayer.weapon;
					predicted_ammo_nails = currentplayer.ammo_nails;
					predicted_ammo_cells = currentplayer.ammo_cells;
					predicted_ammo_rockets = currentplayer.ammo_rockets;
					predicted_ammo_shells = currentplayer.ammo_shells;
					predicted_flags = currentplayer.flags;
					predicted_currentweapon = currentplayer.weapon;
					predicted_mantle_target = currentplayer.mantle_target;
					predicted_mantle = currentplayer.mantle;


					// set view weapon origin/angles..  if you want to do view bobbing, weapon animation etc.. do your viewbobbing after these unless you want to do things in another way. :)
					viewweapon.origin = autocvar_cg_gun_pos*zoom_amount;
					viewweapon.angles = [0,0,0];
					viewweapon.frame1time = currentplayer.frame1time;
	
					vector w_offset;

					if(predicted_weapon == 1)
					w_offset = [-6,0.05,2.5];
					else if(predicted_weapon == 2)
					w_offset = [-4,0.05,2.5];
					else if(predicted_weapon == 5)
					w_offset = [-3,0.15,1];
					//setproperty(VF_MINDIST,-5);
					viewweapon.origin += w_offset*(1-zoom_amount);
					
					//viewweapon.frame = 1;  // sets frame to 1 based on the framegroup i made for the MDL model..    a far easier way of handling things than messing around with macros imho.
					//viewweapon.frame1time = currentplayer.v_frame1time;	// sets the frame1time  (i.e the amount of ms into the animation, also networked in our demo)    I personally do it this way as i usually do my own observer code mostly in CSQC where currentplayer will change to the relevant POV serverside.

					float vw_frac = bound(0,currentplayer.attack_time / 0.75,1); // lazy way of getting the fraction (0-1 fractional value) of the weapon animation.. generally you would use a fteqw builtin that will retreieve the animation length... but meh.


					if(currentplayer.attack_time >= lower_range_x && currentplayer.attack_time <= lower_range_y)
					{
						viewweapon.origin_z -= 20*getfraction(lower_range_x,lower_range_y,currentplayer.attack_time);
						viewweapon.angles_x -= 120*getfraction(lower_range_x,lower_range_y,currentplayer.attack_time);
						viewweapon.angles_y -= 120*getfraction(lower_range_x,lower_range_y,currentplayer.attack_time);

					}
					else if(currentplayer.attack_time >= upper_range_x && currentplayer.attack_time <= upper_range_y)
					{
						viewweapon.origin_z += -20 + 20*getfraction(upper_range_x,upper_range_y,currentplayer.attack_time);
						// viewweapon.angles_x += -20 + 20*getfraction(lower_range_x,lower_range_y,currentplayer.attack_time);

					}

				
					/*
					Just some simple and dirty weapon animation when firing..
					*/
					viewweapon.origin_x += cos((-5*vw_frac)*0.5);
					viewweapon.angles_x += V_springterp(0,-20,0,-1,-5,vw_frac);
					viewweapon.angles_x += (screen_bounce*-2)*(bounce_amount/1);
 //   10*vw_frac;			
					viewweapon.origin += [0,0,-2];
					viewweapon.origin_y += (1 - 1*getfraction(view_crouch_offset,view_offset,currentplayer.view_ofs_z))*0.2;

						viewweapon.origin_z -= (4*getfraction(view_crouch_offset,view_offset,currentplayer.view_ofs_z))*currentplayer.stamina*0.5;

					if(currentplayer.flags & FL_ONGROUND)
					{
					viewweapon.angles_y += -1*vw_frac;
					viewweapon.angles_z += cos(-10*vw_frac)*0.1;
					viewweapon.origin_x += -3*vw_frac;
					viewweapon.origin_x += V_springterp(0,-3,3,3,1,vw_frac);
					//float V_springterp(float current, float target, float speedo, float stiffness, float damping, float deltaTime)
					viewweapon.origin_z += -1*vw_frac;

					float maxspeedo = 200;
					float zoom_amount_limit = bound(0.2,zoom_amount,1);
					viewweapon.origin_x += (0.05*cos(time*5)*(magnitude(currentplayer.velocity) / maxspeedo))*(zoom_amount_limit);	
					viewweapon.origin_y += (0.2*cos(time*8)*(magnitude(currentplayer.velocity) / maxspeedo))*(zoom_amount_limit);				
					viewweapon.origin_z += (0.1*sin(time*15)*(magnitude(currentplayer.velocity) / maxspeedo))*(zoom_amount_limit);
					

					viewweapon.angles_z += (0.5*cos(time*5)*(magnitude(currentplayer.velocity) / maxspeedo))*(zoom_amount_limit);
					viewweapon.angles_x += (0.05*sin(time*8)*(magnitude(currentplayer.velocity) / maxspeedo))*(zoom_amount_limit);
					viewweapon.angles_y += (0.05*sin(time*25)*(magnitude(currentplayer.velocity) / maxspeedo))*(zoom_amount_limit);




					// if(currentplayer.flags & FL_ONGROUND)
						viewweapon.origin_z -= (screen_bounce*15)*(bounce_amount/1);

					}

					viewweapon.angles += viewweapon_angle_offset;
					viewweapon.origin += [cos(sway_timer*0.2 + M_PI/2)*0.01,0,cos(sway_timer + M_PI/2)*0.01];

					viewweapon.angles += [smoothsin(sway_timer + M_PI/2)*0.1,smoothcos(sway_timer + 5)*0.1,smoothsin((sway_timer*0.1 + M_PI/2))*0.5];

				//	setviewprop(VF_ANGLES,getviewprop(VF_CL_VIEWANGLES) + ([0,0,viewweapon_angle_offset_z*0.2])*getfraction(view_offset,view_crouch_offset,currentplayer.view_ofs_z));



				}
	//vector angle_diff = getproperty(VF_CL_VIEWANGLES) - angle_last;
	//float(float a, float b) angle_diff_signed =
	vector angle_diff = angle_diff_signed_v(getproperty(VF_CL_VIEWANGLES),angle_last);

	float velocity_dot;
	makevectors(getproperty(VF_CL_VIEWANGLES));
	vector bright = v_right;
	makevectors(vectoangles(predicted_velocity));
	velocity_dot = dotproduct(bright,v_forward);
	float crouch_scale =  getfraction(view_offset,view_crouch_offset,currentplayer.view_ofs_z);
	float velocity_dot_fraction = fabs(dotproduct(bright, predicted_velocity)/300);

	if(currentplayer.flags & FL_ONGROUND)
	{
		viewweapon_angle_offset_z += velocity_dot*frametime*40*(velocity_dot_fraction);
		viewweapon_angle_offset_z += (velocity_dot*frametime*30*(velocity_dot_fraction)) * crouch_scale;
	}
	else
	{
		viewweapon_angle_offset_z += velocity_dot*frametime*20*(velocity_dot_fraction);
	}


	if(angle_diff)
	{
		viewweapon_angle_offset += angle_diff*-0.055;
	//	viewweapon_angle_offset_z += angle_diff_y*-0.05;



	}
	else
	{

	}


		//viewweapon_angle_offset -= (viewweapon_angle_offset*frametime*4) + normalize(viewweapon_angle_offset)*frametime*22;
		viewweapon_angle_offset = VectorToZero(viewweapon_angle_offset,32*frametime);
		viewweapon_angle_offset_x = bound(-3,viewweapon_angle_offset_x,3);
		viewweapon_angle_offset_y = bound(-6,viewweapon_angle_offset_y,6);
		viewweapon_angle_offset_z = bound(-8,viewweapon_angle_offset_z,8);


	




 bounce_frequency = 10;    // Frequency of the bounce oscillation
 bounce_damping = 0.9;     // Damping factor to reduce bounce amplitude over time


if (!(currentplayer.flags & FL_ONGROUND) && !currentplayer.mantle) {
    // Airborne: reset bounce properties for next landing

    //bounce_amplitude = 0.1;
	
	if(bounce_phase > 0)
		bounce_phase -= bounce_phase*frametime;
	if(bounce_phase < 0)
		bounce_phase += bounce_phase*frametime;
	

  // bounce_phase = 0;
    // screen_bounce = 0;

	traceline(currentplayer.origin,currentplayer.origin - [0,0,2000],FALSE,currentplayer);
	if(vlen(currentplayer.origin - trace_endpos) > 20)
		bounce_amount += (2)*frametime;

	bounce_amount = bound(0,bounce_amount,2);


} else {
    // On ground: increase the phase and calculate bounce based on a damped sine wave

	if(bounce_amount)
    bounce_phase += (bounce_frequency)*frametime;

    // Apply a damped sine wave for the bounce effect
    screen_bounce = bounce_amount*0.05 * smoothcos(bounce_phase) + bounce_amount*frametime;

    // Gradually reduce the bounce amplitude over time to simulate settling
    bounce_amplitude *= bounce_damping;

   // bounce_amplitude = bound(-4,bounce_amplitude,0.1);
    
    // Stop the bounce if amplitude gets very small
    if (bounce_amplitude > 0.1) {
        screen_bounce = 0;
    }

	bounce_amount -= 3*frametime;
	bounce_amount = bound(0,bounce_amount,1);
	if(!bounce_amount)
		screen_bounce = 0;

}


				vector angler;
			

					// if(smoothstep_origin_z < predicted_origin_z)
					// (abs(predicted_origin_z - smoothstep_origin_z) / 0.1)

					if(predicted_flags & FL_ONGROUND)
					{
						if(step <= predicted_origin_z)
						{
							step += (predicted_origin_z - step) * (abs(predicted_origin_z - step) / 0.5) * frametime*2;

						}
						else
						{
							step = predicted_origin_z;
						}

					}
					else
							step = predicted_origin_z;				
				
	

				vector position = [predicted_origin_x,predicted_origin_y,step] + currentplayer.view_ofs + v_right*(0.5*sin(time*10)*(magnitude(currentplayer.velocity) / 200)) + v_up*(1*cos(time*15)*(magnitude(currentplayer.velocity) / 200)) + [0,0,-200*screen_bounce];
				

				setproperty(VF_ORIGIN,position); // sets the camera position.. do this before renderscene();


		//void(vector origin, vector forward, vector right, vector up, optional float reverbtype) SetListener
				makevectors(getproperty(VF_CL_VIEWANGLES));
				SetListener([currentplayer.origin_x,currentplayer.origin_y,step] + currentplayer.view_ofs,v_forward,v_right,v_up,2);
				float recoil_delta = 8;
				if(offset)
				{
					angler = getproperty(VF_CL_VIEWANGLES) - (offset2*-1);


					if(predicted_currentweapon == 5)
						recoil_delta *= 2 + (offset2_x*-1)*frametime;

					if(offset_x > offset2_x)
					{
						offset2_x += recoil_delta*frametime;	

					
						if(offset2_x > offset_x)
							offset2_x = offset_x;


					}
					else
					{
						offset_x -= recoil_delta*frametime*2;
						offset2_x -= recoil_delta*frametime*2;
					
						if(offset2_x < 0)
							offset2_x = 0;
						if(offset_x < 0)
							offset_x = 0;
					}

					if(offset_y > offset2_y)
					{
						offset2_y += recoil_delta*frametime;	

					
						if(offset2_y > offset_y)
							offset2_y = offset_y;


					}
					else
					{
						offset_y -= recoil_delta*frametime*2;
						offset2_y -= recoil_delta*frametime*2;
					
						if(offset2_y < 0)
							offset2_y = 0;
						if(offset_y < 0)
							offset_y = 0;
					}

		
						setproperty(VF_CL_VIEWANGLES,angler+(offset2*-1));
					
				}

				else
				{
		
				}

					if(angle_offset)
					{
		
					}

		if(infokey(currentplayer,INFOKEY_P_SPECTATOR) == "1")
		{
			setproperty(VF_CL_VIEWANGLES,currentplayer.angles); // sets the camera position.. do this before renderscene();
			setproperty(VF_ANGLES,currentplayer.angles); // sets the camera position.. do this before renderscene();
		}


				currentplayer.origin = currentplayer.oldorigin;
				currentplayer.velocity = currentplayer.oldvelocity;
				currentplayer.pmove_flags = currentplayer.oldflags;
				currentplayer.flags = currentplayer.oldflags2;
				currentplayer.v_frame1time = currentplayer.v_frame1timeold;
				currentplayer.attack_time = currentplayer.attack_timeold;
				currentplayer.hook_origin = currentplayer.hook_originold;
				currentplayer.hook_held = currentplayer.hook_heldold;
				currentplayer.view_ofs_z = currentplayer.view_ofs_old;
				currentplayer.stamina = currentplayer.staminaold;
				currentplayer.weapon = getstatf(STAT_ACTIVEWEAPON);
				currentplayer.wishweapon = getstatf(32);
				currentplayer.ammo_cells = getstatf(STAT_CELLS);
				currentplayer.ammo_shells = getstatf(STAT_SHELLS);
				currentplayer.ammo_nails = getstatf(STAT_NAILS);
				currentplayer.ammo_rockets = getstatf(STAT_ROCKETS);
				currentplayer.items = getstatbits(STAT_ITEMS,0,23);
				currentplayer.items2 = getstatbits(STAT_ITEMS,23,9);

		}
		else
		{
			if(infokey(currentplayer,INFOKEY_P_SPECTATOR) == "1")
			{
				setproperty(VF_CL_VIEWANGLES,currentplayer.angles); // sets the camera position.. do this before renderscene();
				setproperty(VF_ANGLES,currentplayer.angles); // sets the camera position.. do this before renderscene();
			}

		}




		/*
			Just a simple way of displaying the hook..
			calls a perframe particle beam between  the predicted player position and the hook_position..
		*/

		if(predicted_hookorigin)
		{
			trailparticles(particleeffectnum("pitch.trace"),world,predicted_origin,predicted_hookorigin);
			pointparticles(particleeffectnum("spikeset.gunshotsmoke"),predicted_hookorigin);
		}

		/*
		Silly sun thing as i can't be bothered compiling my maps yet
		*/
		// float(vector org, float radius, vector lightcolours, optional float style, optional string cubemapname, optional float pflags) dynamiclight_add
		vector sun_pos = [10000*cos(cltime*0.2),10000*sin(cltime*0.2),14000];
		// dynamiclight_add(sun_pos,20000,[1 + 1*cos(cltime*0.5),0.2 + 1*cos(cltime*0.5),1 + 1*cos(cltime*0.5)]);
		addentities(1 | 2);  // addentities uses a bitmask to push entities with corresponding .drawmask field to be rendered..


		/*
		Renders your scene...
		This has to be done before calling drawpic/drawstring
			drawpoly and similar have to be called before renderscene() though!
		*/
	
		makevectors(getproperty(VF_CL_VIEWANGLES));
		// float light = dynamiclight_add(predicted_origin+[0,0,30]+v_forward*160,500,[20,20,20]);


		traceline(currentplayer.origin+currentplayer.view_ofs,predicted_origin+currentplayer.view_ofs + v_forward*2000,FALSE,currentplayer);
		if(trace_ent.aimassist && trace_ent != currentplayer)
		{
		float speedo = vlen(predicted_velocity) / 380;


		float dist = bound(0,vlen(predicted_origin - trace_ent.origin) / 1500,1);
		speedo *= 1 - dist;

		vector oldangles = getproperty(VF_CL_VIEWANGLES);
		vector newangles = (vectoangles(trace_ent.origin - predicted_origin));
		float differ = angle_diff_signed(newangles_y,oldangles_y)*(2*(5*speedo)*frametime);
		differ += angle_diff_signed(newangles_y,oldangles_y)*1.2*frametime*dist;
		if(zoom_amount < 1 && zoom_amount > 0)
			differ *= 115;

		// newangles_y = angle_diff_signed(oldangles_y,newangles_y);
		setproperty(VF_CL_VIEWANGLES,oldangles + [0,differ,0]);
		}


			float min_zoom;
			if(predicted_weapon == 5)
			min_zoom = 40;
			else
			min_zoom = 80;

		if(player_zoom && predicted_attack_time >= 0)
		{


			zoom_amount = bound(0,zoom_amount-15*frametime,1);




			setproperty(VF_AFOV,InterpolateFloat(min_zoom,cvar("fov"),zoom_amount));

			setsensitivityscaler(min_zoom / cvar("fov"));
		}
		else if(!player_zoom || predicted_attack_time < 0)
		{


			zoom_amount = bound(0,zoom_amount+15*frametime,1);
			setproperty(VF_AFOV,InterpolateFloat(min_zoom,cvar("fov"),zoom_amount));
			//setproperty(VF_AFOV,zoom_amount);
			setsensitivityscaler(1);
		}
/*
int player_zoom;
int player_zoom_fov;
float player_zoom_sens;

float autocvar_cg_zoom_fov;
float autocvar_cg_zoom_sensitivity;
*/		
		outlines = 0;
		col4 w_user1[3] = 
		{ 
				{ screen_size_real_x, screen_size_real_y, outlines, 1 }, 
				{ cltime, 0, 0.3*sin(cltime*-1), 1*sin(cltime*10) }, 
				{ 0, 1, 1, 1 } 
		};

		w_user1[0].b = 0;

		setproperty(VF_SIZE,[screen_size_real_x,screen_size_real_y]);
		setproperty(VF_USERDATA, &w_user1, sizeof(float) * 12i);
		setproperty(VF_RT_DESTCOLOUR,"worldspace", -IMGFMT_R8G8B8A8,screen_size_real);
		setproperty(VF_DRAWWORLD,1);
		renderscene();
		setproperty(VF_RT_DESTCOLOUR, (string)__NULL__);
		clearscene();


if(cvar("cg_post"))
{
		outlines = 1;
		col4 w_user1[3] = 
		{ 
				{ screen_size_real_x, screen_size_real_y, outlines, 1 }, 
				{ cltime, 0, 0.3*sin(cltime*-1), 1*sin(cltime*10) }, 
				{ 0, 1, 1, 1 } 
		};
		w_user1[0].b = 1;
		
		setproperty(VF_SIZE,[screen_size_real_x,screen_size_real_y]*cvar("cg_outlines_scale"));
		setproperty(VF_USERDATA, &w_user1, sizeof(float) * 12i);
		setproperty(VF_RT_DESTCOLOUR,"outlines", -IMGFMT_R8G8B8A8,screen_size_real*cvar("cg_outlines_scale"));
		setproperty(VF_DRAWWORLD,1);
		addentities(1|2);
		setproperty(VF_ORIGIN,position);
		renderscene();
		setproperty(VF_RT_DESTCOLOUR, (string)__NULL__);
		clearscene();
}

		//float(vector position, string pic, vector size, vector rgb, float alpha, optional float flag) drawpic
		drawpic([0,0],"crt",screen_size,[1,1,1],1);

		if(cvar("cg_post"))
		{
		drawpic([0,0],"outlines",screen_size,[1,1,1],1);
		drawpic([0,0],"bloom",screen_size,[1,1,1],1);
		}

		if(health_target < currentplayer.health)
		{
			health_target += 60*frametime;
			if(health_target > currentplayer.health)
			health_target = currentplayer.health;
		}
		else if(health_target > currentplayer.health)
		{
			health_target -= 60*frametime;	
			if(health_target < currentplayer.health)
			health_target = currentplayer.health;
		}

		if(armor_target < currentplayer.armorvalue)
		{
			armor_target += 60*frametime;
			if(armor_target > currentplayer.armorvalue)
			armor_target = currentplayer.armorvalue;
		}
		else if(armor_target > currentplayer.armorvalue)
		{
			armor_target -= 60*frametime;
			if(armor_target < currentplayer.armorvalue)
			armor_target = currentplayer.armorvalue;
		}

		health_target = bound(0,health_target,100);

		drawstring(screen_center_bottom - [250,50],strcat(ftos(currentplayer.attack_time)),[10,10],[1,1,1],1,0);
		drawstring(screen_center_bottom - [250,40],strcat(ftos(currentplayer.weapon)),[10,10],[1,1,1],1,0);
		drawfill(screen_center_bottom - [250,20],[100,10],[0.5,0.5,0.5],0.5);
		drawfill(screen_center_bottom - [250,20],[100*(health_target/100),10],[1,0,0],1);
		drawstring(screen_center_bottom - [250,20],strcat(ftos(rint(currentplayer.health))),[10,10],[1,1,1],1,0);
		drawstring(screen_center_bottom - [250,30],strcat(ftos(rint(health_target))),[10,10],[1,1,1],1,0);
		drawfill(screen_center_bottom - [250,10],[100*(armor_target/100),5],[0,0,1],1);
		drawstring(screen_center_bottom - [250,10],strcat(ftos(armor_target)),[5,5],[1,1,1],1,0);

		drawstring([0,0] + [10,10],strcat(vtos(screen_size_real)),[5,5],[1,1,1],1,0);

		float ammo;
		if(currentplayer.weapon == 1)
			ammo = predicted_ammo_nails;
		if(currentplayer.weapon == 2)
			ammo = predicted_ammo_nails;
		if(currentplayer.weapon == 3)
			ammo = predicted_ammo_shells;
		if(currentplayer.weapon == 4)
			ammo = predicted_ammo_rockets;
		if(currentplayer.weapon == 5)
			ammo = predicted_ammo_cells;

		drawstring(screen_center_bottom - [150,40],strcat(ftos(ammo)),[10,10],[1,1,1],1,0);

		// float(vector position, vector size, vector rgb, float alpha, optional float flag) drawfill
		predicted_attack_time = bound(0,predicted_attack_time,4);
		float max_size = 200;
		float attack_x;
		attack_x = max_size * (predicted_attack_time/1);

		if(predicted_hookheld && predicted_hookorigin)
		attack_x = max_size;

		float attack_y = 20;
		vector attack_org;
		attack_org = screen_center + [0,200,0] - [(attack_x/2),0,0];

		if(predicted_hookheld)
			drawfill(attack_org,[attack_x,attack_y,0],[1,1,1],1);
		else
			drawfill(attack_org,[attack_x,attack_y,0],[1,1,1],1 - (1 - (0,bound(0,currentplayer.attack_time/1,1))));

			attack_x = max_size * (1-predicted_stamina);
			attack_org = screen_center_bottom - [0,20] - [(attack_x/2),0,0];


		if(stamina_old != predicted_stamina)
		{
			stamina_old = predicted_stamina;
			stamina_time = time+1;
		}
			if(time < stamina_time)
				drawfill(attack_org-[0,0],[attack_x,10,0],[1,0,0],1-getfraction(stamina_time-1,stamina_time-0.8,time));

		/*
		Some simple crosshair nonsense..
		*/
		float crosshair_scale = 50;

		drawpic(screen_center - ([crosshair_scale,crosshair_scale]/2),"crosshair/1.png",[crosshair_scale,crosshair_scale],[1,1,1],1);
	
		dmg_plume_render(); 

		if(autocvar_cg_hud_debug)
		{


		drawstring([200,8,0],strcat("^2sv_minping for latency testing (", ftos(cvar("sv_minping")),"ms)"),[8,8],[1,1,1],1,0); // info yo
		/*
		Debug text showing the various predicted vs non predicted values.
		Can be useful to find prediction drifting or rounding errors..
		*/
		// drawstring([20,190,0],strcat(ftos(skeletons)),[10,10],[1,1,1],1,0);
		drawstring([20,180],strcat("^1zoomout: ^7",ftos(zoom_amount)),[10,10],[1,1,1],1,0);
		drawstring([20,190,0],strcat("^1recoil_subtract:^7",vtos(offset)),[10,10],[1,1,1],1,0);
		drawstring([20,200,0],strcat("^1recoil_offset:^7",vtos(offset2)),[10,10],[1,1,1],1,0);

		drawstring([20,210,0],strcat("^1bnc_phase:^7",ftos(bounce_phase)),[10,10],[1,1,1],1,0);
		drawstring([20,220,0],strcat("^1bnc_amp:^7",ftos(bounce_amplitude)),[10,10],[1,1,1],1,0);
		drawstring([20,230,0],strcat("^1bnc:^7",ftos(screen_bounce)),[10,10],[1,1,1],1,0);
		drawstring([20,240,0],strcat("^1amount:^7",ftos(bounce_amount)),[10,10],[1,1,1],1,0);
		drawstring([20,250,0],strcat("^1pvel:^7",ftos(rint(magnitude(predicted_velocity)))),[10,10],[1,1,1],1,0);
		drawstring([20,260,0],strcat("^1vel:^7",ftos(rint(magnitude(currentplayer.oldvelocity)))),[10,10],[1,1,1],1,0);

		drawstring([20,270,0],strcat("^1porg:^7",vtos(predicted_origin)),[10,10],[1,1,1],1,0);
		drawstring([20,280,0],strcat("^1org:^7",vtos(currentplayer.oldorigin)),[10,10],[1,1,1],1,0);
		drawstring([20,290,0],strcat("^1pvtime1:^7",ftos(predicted_vtime1)),[10,10],[1,1,1],1,0);
		drawstring([20,300,0],strcat("^1vtime1:^7",ftos(currentplayer.v_frame1time)),[10,10],[1,1,1],1,0);
		drawstring([20,310,0],strcat("^1lasttouch:^7",currentplayer.last_touch.classname),[10,10],[1,1,1],1,0);
		drawstring([20,320,0],strcat("^1adiff:^7",vtos(viewweapon_angle_offset)),[10,10],[1,1,1],1,0);


		drawstring([20,340,0],strcat("^1ping:^7", infokey(currentplayer,INFOKEY_P_PING)),[10,10],[1,1,1],1,0);				// displays ping.. retreived via infokey
		drawstring([20,350,0],strcat("^1pframes:^7", ftos(clientcommandframe - servercommandframe+1)),[10,10],[1,1,1],1,0); 		// displays how many input frames we are predicting ahead of the server.
		drawstring([20,360,0],strcat("^1porg diff:^7", ftos(vlen(currentplayer.oldorigin - predicted_origin))),[10,10],[1,1,1],1,0);	// just shows the length between the predicted and non predicted position... fairly useless :P
		drawstring([20,370,0],strcat("^1buffer_time:^7",ftos(buffer_length)),[10,10],[1,1,1],1,0);
		drawstring([20,380,0],strcat("^1time:^7",ftos(time)),[10,10],[1,1,1],1,0);






		vector proj = project(sun_pos);
		if(proj_z > 0)
		drawstring(project(sun_pos),strcat("^1SUN"),[10,10],[1,1,1],1,0);	// just shows the length between the predicted and non predicted position... fairly useless :P
		}


		angle_last = getproperty(VF_CL_VIEWANGLES);



		vector autocvar_cg_scoreboard_pos;
		vector scorepos = screen_center - [350/2,150];

		if(show_scores)
		{
			drawfill([scorepos_x+10,scorepos_y+5,0],[350,20],[0.1,0.1,0.1],1);
			float rows;
			rows = 1;
			drawstring([scorepos_x+25,scorepos_y+15*rows,0],"NAME",[10,10],[1,1,1],1,0);
			drawstring([scorepos_x+125,scorepos_y+15*rows,0],"PING",[10,10],[1,1,1],1,0);
			drawstring([scorepos_x+225,scorepos_y+15*rows,0],"KILLS",[10,10],[1,1,1],1,0);
			

			rows = 2;
			for(float y = 0; y < maxclients; y++)
			{
				drawstring([scorepos_x+25,scorepos_y+15*rows,0],getplayerkeyvalue(y,INFOKEY_P_NAME),[10,10],[1,1,1],1,0);
				drawstring([scorepos_x+125,scorepos_y+15*rows,0],getplayerkeyvalue(y,INFOKEY_P_PING),[10,10],[1,1,1],1,0);
				drawstring([scorepos_x+225,scorepos_y+15*rows,0],getplayerkeyvalue(y,INFOKEY_P_FRAGS),[10,10],[1,1,1],1,0);
				drawstring([scorepos_x+325,scorepos_y+15*rows,0],getplayerkeyvalue(y,INFOKEY_P_SPECTATOR),[10,10],[1,1,1],1,0);
				rows++;
			}
		}




		buffer_length += frametime;
};



/*
	CSQC_InputEvent
		Will allow you to retreive key, mouse, joystick, touchscreen etc input and more or less do what you want with them.
*/
float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	return FALSE;
};



/*
	CSQC_ConsoleCommand
		console commands...   parses the CMD value called via console,bind or QC.
		Can be used to edit values before sending them to the server, or hijacking the CMD entirely to be used with something like fteqw's sendevent function.
*/
float(string cmd) CSQC_ConsoleCommand =
{
	print(cmd);
	print("\n");
	tokenize(cmd);

	cmd = argv(0);

	/*
float(string s) tokenize = #441; 
string(float n) argv = #442; 
	*/


	if(cmd == "+showscores")
	show_scores = TRUE;
	else if(cmd == "-showscores")
	show_scores = FALSE;

	if(cmd == "+zoom")
	{
		player_zoom = TRUE;
		print("zooming\n");
	}
	else if(cmd == "-zoom")
	{
		player_zoom = FALSE;
	}

	return FALSE;
}


/*
	CSQC_Ent_Remove
	What the CSQC will/should do when an entity is removed or culled serverside
*/
void() CSQC_Ent_Remove =
{
	if(self.classname == "zombie")
	{

		ragdoll = spawn();
		ragdoll.classname = "ragdoll";
		ragdoll.model = self.model;
		ragdoll.origin = self.origin;
		ragdoll.frame = self.frame;
		ragdoll.frame2 = self.frame2;
		ragdoll.frame1time = self.frame1time;
		ragdoll.frame2time = self.frame2time;
		ragdoll.lerpfrac = self.lerpfrac;
		ragdoll.angles = self.angles;
		ragdoll.model = self.model;
		ragdoll.scale = self.scale;
		setmodel(ragdoll,ragdoll.model);
		setsize(ragdoll,self.mins,self.maxs);
		setorigin(ragdoll,ragdoll.origin);
		ragdoll.drawmask = 1;
		ragdoll.predraw = predraw_player_ragdoll;

	skeletons--;
	}
	else if(self.classname == "player")
	{
	
	// spawn_ragdoll(self);
	skel_delete(self.rag);
	skel_delete(self.skeletonindex);

	}

	remove(self);

};


vector() readvector =  // Shorthand function that will read 32bit (i think..) values when receiving your entities.    (you would generally have to call readcoord() etc one by one otherwise... i am too lazy for that.
{
	vector vec = [readcoord(),readcoord(),readcoord()];
	return vec;
};

vector() readvectorshort =	// Shorthand function that will read 16bit values when receioving your entities.
{
	vector vec = [readshort(),readshort(),readshort()];
	return vec;
};


/*
	CSQC_Ent_Update
		Setting SendEntity and SendFlags serverside will trigger CSQC_Ent_update in CSQC..  this will break interpolation.... other option to that is using fteqw's deltalisten functions but it's a bit more convoluted....  porting over fteqw's engine side interpolation to QC is on the to do list.
*/
void(float isnew) CSQC_Ent_Update = 
{
	float type = readbyte(); // check what the first bit is,  where we determine what packet is being sent.

	if(type == 8) // 8 = being a player packet...
	{
		
		if(isnew) // checks if the entity is new...   useful to avoid spamming setmodel, setsize etc..
		{
			self.solid = SOLID_BBOX;
			self.movetype = MOVETYPE_NONE;
			self.view_ofs = [0,0,40];
			self.drawmask = 1;
			self.classname = "player";

			/*
			As there is no way for CSQC to know automagically what entity is you when sending entities.
				player_localentnum = the serverside entnum of your serverside entity.. 
			*/
			if(self.entnum == player_localentnum)
			{
				currentplayer = self;	// sets the currentplayer... important when we are doing our prediction, or just knowing in general what entity is "you".
				currentplayer.renderflags (+) RF_EXTERNALMODEL; // will not render the model, but it will still cast shadows.
				currentplayer.hitcontentsmaski (-) CONTENTBIT_CORPSE;
			}
			else
			{
				self.predraw = predraw_player;
			}
		}

		float isdelta = readbyte();

		self.oldflags = readbyte(); // pmove_flags
		self.oldflags2 = readbyte(); // self.flags


		/*
		General practice is to set locals  before setting entity fields..
			In this case we are doing this because i was messing around with delta compression and need to know if it is a delta packet or not before setting fields.
		*/
		vector org;  // origin
			org = self.oldorigin;

		vector vel;
			vel = self.oldvelocity;

		vector angl;
			angl = self.oldangles;

		// ORIGIN
		float isdelta2 = readbyte();
			if(isdelta2 & VEC_X)
				org_x = readcoord();
			if(isdelta2 & VEC_Y)
				org_y = readcoord();
			if(isdelta2 & VEC_Z)
				org_z = readcoord();

		// VELOCITY
		float isdelta3 = readbyte();
			if(isdelta3 & VEC_X)
				vel_x = readcoord();
			if(isdelta3 & VEC_Y)
				vel_y = readcoord();
			if(isdelta3 & VEC_Z)
				vel_z = readcoord();

		// ANGLES
		float isdelta4 = readbyte();
			if(isdelta4 & VEC_X)
				angl_x = readangle();
			if(isdelta4 & VEC_Y)
				angl_y = readangle();
			if(isdelta4 & VEC_Z)
				angl_z = readangle();


		/* frame stuff */
		int fr = readbyte();
		float fr1time = readfloat();
		float timer = readfloat();


			self.oldorigin = org;
			self.oldvelocity = vel;
			self.frame = fr;
			self.frame1time = fr1time;
			self.oldangles = angl;
		

		setmodel(self,"models/player.iqm");
		setsize(self,pmove_mins,pmove_maxs);
		setorigin(self,org);  // sets the origin.. for when partial frames in our prediction are occurring.. just a safety thing and can be approached in other ways,
		self.angles = self.oldangles;
		self.velocity = self.velocity;

		if(isnew)
		{
			self.frame2 = self.frame;
		}
		AddToSortedBuffer(self,timer);

		//.int hitcontentsmaski
		//self.hitcontentsmaski = CONTENTBIT_BODY;
	}
	else if(type == 9)
	{
		//WriteVector(MSG_ENTITY,org);
		//WriteAngle(MSG_ENTITY, self.v_angle_x);
		//WriteAngle(MSG_ENTITY, self.v_angle_y);
		//WriteByte(MSG_ENTITY,self.frame);
		//WriteFloat(MSG_ENTITY,self.frame1time);
		//WriteFloat(MSG_ENTITY,time);
		if(isnew)
		{
			self.drawmask = 1;
			setmodel(self,"models/zombie.iqm");
			self.solid = SOLID_CORPSE;
			self.classname = "zombie";
			self.predraw = predraw_player;
			setsize(self,pmove_mins,pmove_maxs);
			setorigin(self,self.origin);
			skeletons++;
			
		}
		self.origin = readvector();
		self.angles = [readangle(),readangle(),0];
		self.frame = readbyte();
		self.frame1time = readfloat();
		float timer = readfloat();
		AddToSortedBuffer(self,timer);		

	}

}


/*
	CSQC_Parse_Event 
		Here we process CGAME packets,  generally any time you send a non entity packet this is where you process them.
		In this case we are using cgame packets to send over attack_time, weapon frame values  etc...
*/

void() CSQC_Parse_Event =
{
	float type = readbyte(); // check what the first bit is,  where we determine what packet is being sent.
	entity target;
	if(type == 9)  // 9 = weapon attack_time,  frame1time of the weapon
	{
		float ftime = readfloat(); // frame1time
		float atime = readfloat(); // attack_time

		if(currentplayer)
		{
			currentplayer.v_frame1timeold = ftime;
			currentplayer.attack_timeold = atime;
		}
	
	}
	else if(type == 10) // 10 = hook...
	{

	}
	else if(type == 23)
	{

		self.mantle_target_old = readvector();
		self.mantle_old = readbyte();

		print("mantle received\n");
	}
	else if(type == 125)
	{
		target = num_for_ent(readentitynum());
		float dmg = readfloat();
		float flag = readbyte();

		if(target != world)
		{
			print("^1TARGET: ");
			print(ftos(target.entnum));
			print("\n");
			target.colormod_x = 8;
			target.colormod_y = 1;
			target.colormod_z = 1;
		}


		if(flag & DAMAGE_DEAD)
			spawn_ragdoll(target);

		localsound("sounds/hit.ogg");

			//void(vector origin, int damage) dmg_plume_add 

		dmg_plume_add(target.origin,dmg);
	}

}

/*
	CSQC_Input_Frame
		Allows you edit MOST input_foo  values before they are sent to the server.
*/
void() CSQC_Input_Frame =
{

				/*
				if(input_servertime && input_sequence)
				{
				print("client SEQ[");
				print(ftos(input_sequence));
				print("] ");
				print("client TIME: ");
				print(ftos(servertime));
				print(" time: ");
				print(ftos(time));
				print(" svtime: ");
				print(ftos(input_servertime));
				print("\n");
				}
				*/	
				if(servertime > buffer_length)
				{
					buffer_length = servertime;
					// print("buffer_length update\n");
				}
				else
				{
					if(rint((buffer_length - servertime)*1000) > 17)
					{

						buffer_length = servertime;
					}
						//print(ftos(rint((buffer_length - servertime)*1000)));
						//print("ms\n");
				}
				
		savedservertime = servertime;
};


/*
	parsenewmapentity
		This is a nifty function Spike wrote a while ago that will parse the entities in the map itself.
		This is fairly useful as CSQC does not automatically spawn things like doors, jumppads etc (they will exist when playing, just not visible to CSQC).. so can be used for CSQC ONLY based singleplayer projects for instance.. or in our case it will be used for predicting jumppads and such.
			Keep in mind:
				various entity defintions/functions and functions like touch etc  need to be shared between csqc/ssqc for this to work.. so generally have a shared definitions and function file if you want to go down this route.
				The other way to do prediction for map based entities is to manually send various entities yourself.... this should generally be done for doors anyway, but mostly static entities work just fine by parsing them via CSQC.
*/

float(float inhibitspawnflags, float first) parsenewmapentity =
{
	local string field, value;
	local entity nent;
	local string edata = "";

	while (1)
	{
		field = getentitytoken();
		if not (field)
			break;

		if (field == "}")
		{
			if (first)
				nent = world;	//yup, worldspawn, innit.
			else
				nent = spawn();
			parseentitydata(nent, strcat("{\n", edata, "}\n"));

			if (nent.spawnflags & inhibitspawnflags)
			{
				/*do nothing, just make sure the following blocks can't trigger*/
				//print("inhibit ", nent.classname, "\n");
			}
			else if (isfunction(nent.classname))
			{
				self = nent;
				callfunction(nent.classname);
				return TRUE;
			}
			else
			{
//				print("ignoring ", nent.classname, "\n");
			}

			if (nent)
				remove(nent);
			return TRUE;
		}

		value = getentitytoken();
		if not (value)
			break;

		edata = strcat(edata, field, " \"", value, "\"\n");
	}

	return FALSE;
};


/* spawns the parsed entities */
void() SpawnEntities =
{
	local string tok;
	local float inhibitspawnflags;
	float isfirst = TRUE;

	//reset the parser
	getentitytoken(__NULL__);

	/*if this wasn't purecsqc, you would want to use serverinfo instead for these, so that any teleporters match properly*/
	if (cvar("deathmatch"))
		inhibitspawnflags = 2048/*SPAWNFLAG_NOT_DEATHMATCH*/;
	else
	{
		//fte likes to default the string cvar to empty instead of 1
		tok = cvar_string("skill");
		if (tok == "")
			tok = "1";
		inhibitspawnflags = stof(tok);
		if (inhibitspawnflags < 0.5)
			inhibitspawnflags = 256/*SPAWNFLAG_NOT_EASY*/;
		else if (inhibitspawnflags > 1.5)
			inhibitspawnflags = 1024/*SPAWNFLAG_NOT_HARD*/;
		else
			inhibitspawnflags = 512/*SPAWNFLAG_NOT_MEDIUM*/;
	}

	while (1)
	{
		tok = getentitytoken();

		if (tok == "")
			break;

		if (tok != "{")
		{
			print("bad entity data\n");
			return;
		}
		
		if (!parsenewmapentity(inhibitspawnflags, isfirst))
		{
			print("bad entity data\n");
			return;
		}
		isfirst = FALSE;
	}
};


void() CSQC_WorldLoaded = /* called when the map is loaded */
{
	SpawnEntities(); /* parses and spawns entities from the maps entity lump */
};



/*
Will intercept sound packets...
This is useful in a number of ways.. but for prediction we are using this to omit any sounds being called the player.
This particularly useful when doing prediction to avoid having the serverside sound overriding the predicted sound..  also good for avoiding sounds being played several times over eachother :P
*/

float(float entnum, float channel, string soundname, float vol, float attenuation, vector pos, float pitchmod, float flags) CSQC_Event_Sound = 
{
	float playconfirm;
	playconfirm = FALSE;
	entity target;

	if(entnum != player_localentnum)
		target = edict_num(entnum);
	else
		target = currentplayer;

	if(target == currentplayer)
	{	
		if((clientcommandframe - servercommandframe) > 2)
			playconfirm = TRUE;
		else
			playconfirm = FALSE;
	}




	return playconfirm;
}

/* 
	CSQC_Parse_Print
		parses prints of all kinds.. 
		e.g If you ever want to do your own chat box, or a error/message box of any kind
*/
void(string printmsg, float printlvl) CSQC_Parse_Print =
{

};