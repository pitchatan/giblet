.float delta_time;


.entity spectator_target;
.vector input_movevalues_saved;


/* 
	SV_SendEntityUpdate
		here is our SendEntity float function...
		Where you call what should be sent to the client..

		Generally the engine does this for you.
*/


float(entity target, vector sendflags) SV_SendEntityUpdate =
{
		WriteByte(MSG_ENTITY, 8);        //write some entity type header/identifier
		float isdelta,isdelta2,isdelta3,isdelta4,isdelta5;			// stores if it should be a delta packet or not...  defined via sendflags_x bitmask
		isdelta = 0;		// meh

		if(sendflags_x == 1)		// 1 = being delta... generally unnused currently as it's way to buggy
			isdelta = TRUE;
		else if(sendflags_x == 2)	// 2 = absolute positions.. 
			isdelta = FALSE;

		vector org;
		vector vel;
		vector angl;

		org = self.origin;
		vel = self.velocity;
		angl = self.angles;


		if(self.oldflags != self.flags)
			isdelta (+) BIT_FLAGS;

		if(self.oldpmove_flags != self.pmove_flags)
			isdelta (+) BIT_PMOVE_FLAGS;

		// ORIGIN
			if(self.origin_x != self.oldorigin_x)
				isdelta2 (+) VEC_X;

			if(self.origin_y != self.oldorigin_y)
				isdelta2 (+) VEC_Y;

			if(self.origin_z != self.oldorigin_z)
				isdelta2 (+) VEC_Z;

		// VELOCITY
			if(self.velocity_x != self.oldvelocity_x)
				isdelta3 (+) VEC_X;

			if(self.velocity_y != self.oldvelocity_y)
				isdelta3 (+) VEC_Y;

			if(self.velocity_z != self.oldvelocity_z)
				isdelta3 (+) VEC_Z;

		// ANGLES
			if(self.angles_x != self.oldangles_x)
				isdelta4 (+) VEC_X;

			if(self.angles_y != self.oldangles_y)
				isdelta4 (+) VEC_Y;

		if(sendflags_z)
		{
			isdelta2 (+) VEC_X;
			isdelta2 (+) VEC_Y;
			isdelta2 (+) VEC_Z;

			isdelta3 (+) VEC_X;
			isdelta3 (+) VEC_Y;
			isdelta3 (+) VEC_Z;

			isdelta4 (+) VEC_X;
			isdelta4 (+) VEC_Y;

			self.spawn_new = 0;

		}

		if(sendflags_x == 1)
		{
			isdelta4 = 0;
		}


		WriteByte(MSG_ENTITY, isdelta);


		WriteByte(MSG_ENTITY, self.pmove_flags);
		WriteByte(MSG_ENTITY, self.flags);

		// ORIGIN
		WriteByte(MSG_ENTITY, isdelta2);
			if(isdelta2 & VEC_X)
				WriteCoord(MSG_ENTITY, org_x);
			if(isdelta2 & VEC_Y)
				WriteCoord(MSG_ENTITY, org_y);
			if(isdelta2 & VEC_Z)
				WriteCoord(MSG_ENTITY, org_z);

		// VELOCITY
		WriteByte(MSG_ENTITY,isdelta3);
			if(isdelta3 & VEC_X)
				WriteCoord(MSG_ENTITY, vel_x);
			if(isdelta3 & VEC_Y)
				WriteCoord(MSG_ENTITY, vel_y);
			if(isdelta3 & VEC_Z)
				WriteCoord(MSG_ENTITY, vel_z);		

		// angles
		WriteByte(MSG_ENTITY,isdelta4);
			if(isdelta4 & VEC_X)
				WriteAngle(MSG_ENTITY, angl_x);
			if(isdelta4 & VEC_Y)
				WriteAngle(MSG_ENTITY, angl_y);


		WriteByte(MSG_ENTITY,self.frame);
		WriteFloat(MSG_ENTITY,self.frame1time);
		WriteFloat(MSG_ENTITY,time);

	return TRUE;
};


float(entity target, vector sendflags) SV_SendEntityUpdate_Zombie =
{
		WriteByte(MSG_ENTITY, 9);        //write some entity type header/identifier
		vector org;
		vector vel;

			org = self.origin;
			vel = self.velocity;

		WriteVector(MSG_ENTITY,org);
		WriteAngle(MSG_ENTITY, self.angles_x);
		WriteAngle(MSG_ENTITY, self.angles_y);
		WriteByte(MSG_ENTITY,self.frame);
		WriteFloat(MSG_ENTITY,self.frame1time);
		WriteFloat(MSG_ENTITY,time);

	return TRUE;
};


void() info_player_deathmatch = // define map entities like this, like you would normally do... 
{

};


/*
	find_spawn
		My dumb find spawn function..
		Currently doesn't check if something is blocking the spawn point so entities are in risk of getting stuck in geometry or other players.. is what is.
*/
void(entity target) find_spawn =
{
	if(target != world)
	{
	entity spawn_spots[100];
	entity spawns = findchain(classname,"info_player_deathmatch");
	float amount;
	while(spawns)
	{
		spawn_spots[amount] = spawns;
		amount++;

	spawns = spawns.chain;
	}
	

		entity here;
		here = spawn_spots[random(0,amount-1)];


	setorigin(target,here.origin);
	target.v_angle = here.angles;
	target.velocity = [0,0,0];
	}
	target.justspawned = TRUE;

}



void() PutClientInServer = // self explanatory...
{

	self.health = 100;
	self.weapon = 1;
	self.wishweapon = 1;
	self.armorvalue = 25;
	self.classname = "player";
	self.view_ofs = [0,0,40];
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_WALK;
	setmodel(self,"models/player.iqm");
	setsize(self,pmove_mins,pmove_maxs);
	setorigin(self,self.origin);
	find_spawn(self);
	self.items = 0;
	self.ammo_nails = 20;
	self.items (+) WEAPON_PISTOL;
	self.spawn_new = TRUE;
	self.damage_taker = TRUE;
/*
.float ammo_shells;
.float ammo_nails;
.float ammo_rockets;
.float ammo_cells;
*/
};

void() main = {};
void() worldspawn = {};
void() SetNewParms = {};
void() SetChangeParms = {};
void() StartFrame = {};

void() ClientKill = {};
void() ClientConnect = {

};
void() ClientDisconnect = {};
void() PlayerPreThink = {};
void() PlayerPostThink = {};





/*
	SV_RunClientCommand
		Where all your player physics and input_ values will be of use...
		If given a body will hijack any time the server receives an input packet from the client, thus killing physics if left without physics functions.

		Will in general hijack all physics being performed if the function is defined/called whatsoever..  in short, if you want this function but dont want or need custom physics... at the very least call runstandardplayerphysics(self).

*/

.float buffer_test;


void(entity target) net_send_entity =
{
	entity cast = findchain(classname,"player");
	while(cast)
	{
		if(cast == target)
		{
			setsendneeded(self,[1,2,cast.spawn_new],cast); // these are currently the same..  define the bitmask vectors the way you want, or if you even need to... in general the flag_x set to 1 will use deltas instead (they do not work properly.. so don't :P)
		}
		else
		{
			if(cast.spectator_target != target)
			{
				setsendneeded(self,[2,2,cast.spawn_new],cast);
			}
			else
			{
				setsendneeded(self,[2,0,cast.spawn_new],cast);
			}
		}

		cast = cast.chain;
	}

}

.float print_timer;


void() SV_RunClientCommand =
{

//float(optional float forcestate) physics_supported = #0:physics_supported; /*

		self.print_timer += input_timelength;

		if(self.print_timer > 1)
		{
			if(!physics_supported)
				physics_enable(self,TRUE);
			print(strcat("physics: ", ftos(physics_supported(TRUE)),"\n"));
			self.print_timer = 0;
		}
				/*
				if(input_servertime && input_sequence)
				{
				print("server SEQ[");
				print(ftos(input_sequence));
				print("] ");
				print("server TIME: ");
				print(ftos(input_servertime));
				print(" time: ");
				print(ftos(time));
				print("\n");
				}
				*/


	self.viewzoom = 20;
	
	self.oldorigin = self.origin;
	self.oldvelocity = self.velocity;
	self.oldangles = self.angles;

	self.oldflags = self.flags;
	self.oldpmove_flags = self.pmove_flags;
	
	self.hitcontentsmaski (-) CONTENTBIT_CORPSE;
	do_physics(self,input_buttons,input_movevalues,input_timelength,1); // perform physics, second parameter is parton.. which should be left to TRUE if serverside.

	self.SendFlags = 0; 	// send flags is used for normal entity updates.. we are not doing this here.

	self.SendEntity = SV_SendEntityUpdate;	// sets the entityupdate function to be used.. which contains all our entity writes etc..


	/*
	Here is where we go off the beaten path a bit......
	I have made it standard practice to use fteqw's setsendneeded function as the normal way of sending things has some drawbacks like sending everything TO EVERYONE..
	i.e  using setsendneeded allows you to customize what is being sent and to whom..
	examples:
		there is really no point in sending velocity to anyone outside of yourself if they are going to be interpolated anyway... 
		Or if you want a player to be invisible to others.. like say a spectator.
		Or in the case where i and others asked him to implement this function in the first place..  custom serverside culling.


		so setsendneeded allows you to do a find/findchain etc   and just loop between the clients you want to send to. (or just send directly to an entity)
		If you don't want to bother with this,  the SendEntity definition (as well as your sendentity function)  and change the flags parameter to float instead of vector (as setsendneeded depends on vectors for more bitmasks).
	*/


		if(self.flags & FL_ONGROUND)
		{
			float speedo = vlen(self.velocity);
			if(speedo <= 0)
			{
				self.frame = 1;
			}
			else if(speedo > 0 && input_movevalues)
			{
				if(input_movevalues_y < 0)
					self.frame = 3;
				else if(input_movevalues_y > 0)
					self.frame = 4;

				if(input_movevalues_x)
					self.frame = 2;

				if(!input_movevalues)
					self.frame = 1;
			}	
		}

		self.frame1time += input_timelength;

	self.movetype = MOVETYPE_WALK;
	self.solid = SOLID_BBOX;
	setmodel(self,"models/player.iqm");
	setsize(self,pmove_mins,pmove_maxs);
	setorigin(self,self.origin);
	self.input_movevalues_saved = input_movevalues;

	net_send_entity(self);

	AddToSortedBuffer(self,time);


	if(input_buttons & 1)
	{

	}
};


void(entity ent) SetViewPoint =  // Alter the Viewpoint Entity
{
 msg_entity = self;         // This message is to myself. 
 WriteByte(1, 5); // Network Protocol: Set Viewpoint Entity
 WriteEntity(1, ent);       // Write entity to clients.
};



void() SpectatorConnect =
{
	self.goalentity = self;
	self.classname = "player";

	entity finder = findchain(classname,"player");
	while(finder)
	{
		if(finder != self)
		{
			//SetViewPoint(finder);
			self.spectator_target = finder;
		}

		finder = finder.chain;
	}

};

void() SpectatorDisconnect =
{

};


void() SpectatorThink =
{
	if(self.spectator_target != world)
	{
	self.origin = self.spectator_target.origin;
	self.v_angle = self.spectator_target.v_angle;
	self.angles = self.spectator_target.v_angle;
	self.velocity = self.spectator_target.velocity;
	self.attack_time = self.spectator_target.attack_time;
	}
};

