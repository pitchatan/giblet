#ifdef SSQC
	void() touch_item =
	{

		self.solid = SOLID_NOT;
		self.effects (+) EF_NODRAW;

		if(self.classname == "railgun")
		{
			if(other.classname == "player")
			{
				other.ammo_cells += 8;
				other.ammo_cells = bound(0,other.ammo_cells,20);
				other.items (+) WEAPON_RAILGUN;
				sound(self,CHAN_BODY,"sounds/weapon_pickup.ogg",1,ATTN_NORM,random(90,100));
			}
			self.nextthink = time + 10;
		}
		else if(self.classname == "rocketlauncher")
		{
			if(other.classname == "player")
			{
				other.ammo_rockets += 15;
				other.ammo_rockets = bound(0,other.ammo_rockets,30);
				other.items (+) WEAPON_ROCKETLAUNCHER;
				sound(self,CHAN_BODY,"sounds/weapon_pickup.ogg",1,ATTN_NORM,random(90,100));
			}
			self.nextthink = time + 10;
		}
		else if(self.classname == "rifle")
		{
			if(other.classname == "player")
			{
				other.ammo_nails += 25;
				other.ammo_nails = bound(0,other.ammo_nails,100);
				other.items (+) WEAPON_RIFLE;
				sound(self,CHAN_BODY,"sounds/weapon_pickup.ogg",1,ATTN_NORM,random(90,100));
			}
			self.nextthink = time + 5;
		}
		else if(self.classname == "shotgun")
		{
			if(other.classname == "player")
			{
				other.ammo_shells += 8;
				other.ammo_shells = bound(0,other.ammo_shells,15);
				other.items (+) WEAPON_SHOTGUN;
				sound(self,CHAN_BODY,"sounds/weapon_pickup.ogg",1,ATTN_NORM,random(90,100));
			}
			self.nextthink = time + 10;
		}

	}

#endif
