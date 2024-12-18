void(entity attacker, entity victim, float damage) send_damage =
{
		float flag;

		victim.health -= damage;
		if(victim.health < 0)
		{
			flag (+) DAMAGE_DEAD;
			victim.health = 0;
		}
		msg_entity = attacker;
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, 125);
		WriteEntity(MSG_MULTICAST,victim);
		WriteFloat(MSG_MULTICAST,damage);
		WriteByte(MSG_MULTICAST,flag);
		multicast('0 0 0',MULTICAST_ONE);
};


void() network_send_clientstats =
{
			clientstat(32,EV_INTEGER,wishweapon);
			clientstat(33,EV_INTEGER,mantle);
			clientstat(35,EV_FLOAT,attack_time);
			clientstat(36,EV_FLOAT,v_frame1time);
			clientstat(37,EV_FLOAT,mantle_target_x);
			clientstat(38,EV_FLOAT,mantle_target_y);
			clientstat(39,EV_FLOAT,mantle_target_z);
			clientstat(40,EV_FLOAT,view_ofs_z);
			clientstat(41,EV_FLOAT,stamina);

};