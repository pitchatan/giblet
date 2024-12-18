


entity dummy;


	///////////////////////////////////
	//		ENUMS 		  //
	/////////////////////////////////

		enum flags {		// DAMAGE FLAGS
			DAMAGE_ALIVE,
			DAMAGE_DEAD
		};

		enumflags int 		// VECTOR FLAGS
		{
			VEC_X,
			VEC_Y,
			VEC_Z,
		};

		enumflags int		// VECTOR FLAGS2
		{
			VEC_ORIGIN,
			VEC_ANGLES,
			BIT_FLAGS,
			BIT_PMOVE_FLAGS
		};

		enum int			// WEAPON ENUMS
		{
			WEAPON_PISTOL,
			WEAPON_RIFLE,
			WEAPON_SHOTGUN,
			WEAPON_ROCKETLAUNCHER,
			WEAPON_RAILGUN
		};

		enumflags int 
		{
			DOOR_CLOSED,
			DOOR_OPENING,
			DOOR_OPEN,
			DOOR_OPEN_IN,
			DOOR_OPEN_OUT,
			DOOR_CLOSING
		};

	///////////////////////////////////
	//		PMOVES		  //
	/////////////////////////////////
		vector pmove_mins = [-12,-12,0];
		vector pmove_maxs = [12,12,70];

	///////////////////////////////////
	//		WEAPON		  //
	/////////////////////////////////
		vector lower_range = [-3,-2.5]*0.5; // lower range of weapon switch:   switch start
		vector upper_range = [-2,-1.5]*0.5;	// upper rannge of weapon switch:  switch end

	///////////////////////////////////
	//		STRUCTS		  //
	/////////////////////////////////
	#ifdef CSQC
		int dmg_plume_max = 50;
		/////////////////////////////////////
		struct 
		{
			vector origin;
			float scale;
			float alpha;
			float time;
			int damage;

		} dmg_plume[dmg_plume_max];

		/////////////////////////////////////
		struct {				
			vector origin;
			float damage;
		}	damage_plume[200];	// unused

		/////////////////////////////////////
		struct col4 	// vec4 equivellant
		{			
			float r;
			float g;
			float b;
			float a;
		};

	#endif


	///////////////////////////////////
	//		FUNCTIONS		  //
	/////////////////////////////////
	#ifdef CSQC		// CLIENT SIDE
		void(vector origin, int damage) dmg_plume_add;	// Adds a DAMAGE plume to our struct array
		void() dmg_plume_render;				// Renders our damage plume array
		void(vector org, vector pointangles,float height, float width,string texturename) render_face; // renders a face with a texture
		entity(float entnums) num_for_ent; 	// gets the client side entity based on entnum
	#endif
	///////////////////////////////
	#ifdef SSQC		// SERVER SIDE
		void(entity attacker, entity victim, float damage) send_damage;
		void(entity target) net_send_entity;
		float(entity target, vector sendflags) SV_SendEntityUpdate_Zombie;
		void() touch_item;
		//send
		void() network_send_clientstats;
	#endif

		void(entity target,float input_butt, vector input_move,float input_tl, int parton) do_physics;	// DO PHYSICS
		void(entity target, float input_button, int parton) do_weapons	// DO WEAPONS

		void(entity target,int new_weapon) switch_weapon;	// ACTIVATE WEAPONS SWITCH
		void(entity target,float force) door_check;		// COLLISION CHECK FOR SPECIFICALLY DOORS
		void(entity target,vector pos,float timer,float radius) findradiusb; // ROLLBACK RADIUS CHECK
		void(vector v1, vector v2, float flags, entity ent,float timer, optional float(entity victim) callback) tracelineb;	// ROLLBACK TRACELINE
		vector(vector vec, vector normal) VectorProjectOnPlane;
		void() think_func_rotating; 	// THINK DOOR rotate function
		void() think_zombie;		// THINK ZOMBIE......
		void() SUB_Remove;
		void() physics_bullet;		// PHYSICS: BULLET
		void(entity target, int bit) input_call_impulse;



		// PHYSICS
		void Accelerate(entity target,vector wishdir,float wishspeed,float accel,float frametimer);
		void ApplyFriction(float t, entity target,float frametimer);
		void AirMove(entity target,vector input_move,float frametimer);
		void AirControl(entity target, vector input_move, vector wishdir, float wishspeed,float frametimer);
		void GroundMove(entity target,vector input_move,float frametimer);
		void CollissionTest(entity target, float frametimer);
		void(entity target,vector surfnorm) PMove_Rebound;
		void(entity target, float buttons, vector input_move, float frametimer) Pmove_Run;
		void(entity target, float frametimer) PMove_Categorise;
		void(entity ent, float deltatime) SlideEntity;

	///////////////////////////////////
	//		ENTITY FUNCS	   //
	///////////////////////////////////

		// FUNC
		void() func_rotating;
		void() func_door1;
		void() func_static;

		// TARGET
		void() target_position;
		void() target_location;


		// INFO
		void() info_notnull;
		void() info_null;
		
		// MISC
		void() misc_model;		// MISC_MODEL POTENTIALLY BAKED INTO Q3BSP
		void() misc_model2;		// MISC_MODEL2 NON BAKED INTO Q3BSP

		// TRIGGERS
		void() trigger_teleport;

		// TOUCH
		void() push_touch;
	
		// PUSH
		void() trigger_push;
		void() target_push;

		// OTHER
		void() advertisement;

	///////////////////////////////////
	//		PREDRAWS		  //
	/////////////////////////////////
	#ifdef CSQC
			float() predraw_player_ragdoll;
			float() predraw_player_ragdoll;
			float() predraw_smoke;
			float() predraw_viewweapon;
			float() predraw_bullet;
	#endif

	///////////////////////////////////
	//		VARIABLES		  //
	/////////////////////////////////
	#ifdef CSQC
		int skeletons;				// SKELETON AMOUNT VAR
		int show_scores;				// BOOLEAN SHOW SCORES
		float zoom_amount;			// CLIENT zoom amount
		int outlines;				// RENDER BOOLEAN
		float savedservertime;			// clientside servertime save variable
	#endif
		float switch_lower = -200;		// higher switch
		float switch_higher = -100;		// lower switch
		float pmove_scale;
		float dmg_plume_amount;			// amount of damage plumes
		float view_crouch_offset = 32;	// target view height of CROUCH
		float view_offset = 45;			// target view height of STANDING

		int buffer_max = 100;
		int autocvar_g_debug_interp;

	// PHYSICS
		float moveSpeed = 360;  // Ground move speed
		float runAcceleration = 4;   // Ground accel
		float runDeacceleration = 120;   // Deacceleration that occurs when running on the ground
		float airAcceleration = 8;  // Air accel
		float crouchAcceleration = 1;
		float airDeacceleration = 0;    // Deacceleration experienced when opposite strafing
		float airControl = 0;  // How precise air control is
		float sideStrafeAcceleration = 0.2;   // How fast acceleration occurs to get up to sideStrafeSpeed when side strafing
		float sideStrafeSpeed = 320;    // What the max speed to generate when side strafing
		float jumpSpeed = 265;  // The speed at which the character's up axis gains when hitting jump
		float holdJumpToBhop = FALSE; // When enabled allows player to just hold jump button to keep on bhopping perfectly. Beware: smells like casual.
		float friction1 = 6; // walking/running friction
		float friction2 = 5; // crouching/sliding friction
		float playerFriction;
		float wishJump;
		float stepheight = 20;


	///////////////////////////////////
	//		DEFINITIONS		  //
	/////////////////////////////////
	int FL_SEMIFIRE = 2;


vector offset;

	///////////////////////////////////
	//		FIELDS		  //
	/////////////////////////////////
	#ifdef CSQC
		.float ammo_cells;	// CELLS
		.float ammo_nails;	// NAILS
		.float ammo_rockets;	// ROCKETS
		.float ammo_shells;	// SHELLS
		.float weapon;		// CURRENT WEAPON
		.int aimassist;		// AIMASSIST BOOLEAN
		.float animater;		// RAGDOLL BLEND FRAC
		.float animater2;		// RAGDOLL BOOLEAN
		.float rag;			// RAGDOLL SKELETONINDEX
		.int currentweapon;	// CURRENT WEAPON
		.float items;		// ITEM FLAGS
		.float items2;		// ITEM2 FLAGS
		.float spawnflags;	// CLIENT SIDE SPAWNFLAGS
		.float staminaold;	// PREDICTION STAMINA
		.float spawn_timer;	//
		.float spawn_offset;	//
		.float health;
		.string target;
		float health_target;
		float armor_target;
	#endif

	#ifdef SSQC
		.float respawn_timer;
	#endif

		.float skeletonobject;	// SKELETON INDEX
		.float stamina;		// PLAYER STAMINA
		.int wishweapon;		// WEAPON YOU WANT TO SWITCH TO
		.int aggro;			
		.float last_timer;
		.float buffer_rollback;
		.vector mantle_target_old;
		.int mantle_old;
		.vector angles_max,angles_min,angles_target;
		.float speed;
		.int spawn_new;
		.float antilagged;
		.int damage_taker;
		.vector view_ofS;
		.entity last_touch;
		.float spawn_dead;
		.vector prev_origin;
		.float lastrun;
		.float attack_time; // attack timer..
		.float zombie_search;
		.float zombie_trace_time;
		.entity goalentity;
		.float voice_time;
		.int touched;
		.float health_timer;
		.float step_timer;

		.vector oldorigin;
		.vector oldvelocity;
		.vector oldangles;

		.float oldpmove_flags;
		.float oldflags;
		.float justspawned;

		.float v_frame;
		.float v_frame1time;
		.float v_frame1timeold;
		.float attack_timeold;
		.vector view_ofs;
		.vector brushorigin;

		.vector hook_origin;
		.int hook_held;

		// BUFFER
		.vector buffer_origin[buffer_max];
		.vector buffer_angles[buffer_max];
		.vector buffer_velocity[buffer_max];
		.int buffer_frame[buffer_max];
		.float buffer_frame1time[buffer_max];
		.float buffer_time[buffer_max];

		.int old_index1;
		.int old_index2;
		.float old_interpfactor;

		.int buffer_count;

		.vector buffer_last_origin;

		.string targetname;
		.float isclient;
		.string name;
		.vector view_ofs;

		.float seq;
		.int wishweapon;

		.float jump_timer;
		.int mantle;
		.vector mantle_target;


	///////////////////////////////////
	//		ENTITIES		  //
	/////////////////////////////////
	#ifdef CSQC
		vector recoil;		// CLIENT SIDE RECOIL VECTOR
	#endif

	///////////////////////////////////
	//		ENTITIES		  //
	/////////////////////////////////
	#ifdef CSQC
		entity viewweapon;			// the players viewmodel.. currently set and spawned in CSQC_UpdateView
		entity viewweapon2;
	#endif