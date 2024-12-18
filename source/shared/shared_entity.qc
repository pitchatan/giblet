


#ifdef SSQC
	void() weapon_railgun =
	{
		self.angles_x = 90;
		setmodel(self,"models/sniper1.iqm");
		setsize(self,[-20,-20,-20],[20,20,20]);
		setorigin(self,self.origin);
		self.modelflags (+) MF_ROTATE;
		self.classname = "railgun";
		self.touch = touch_item;
		self.think = think_item;
		self.solid = SOLID_TRIGGER;
		self.flags (+) FL_FINDABLE_NONSOLID;
	}

	void() weapon_rocketlauncher =
	{
		self.angles_x = 90;
		setmodel(self,"models/rocket1.iqm");
		setsize(self,[-20,-20,-20],[20,20,20]);
		setorigin(self,self.origin);
		self.modelflags (+) MF_ROTATE;
		self.classname = "rocketlauncher";
		self.touch = touch_item;
		self.think = think_item;
		self.solid = SOLID_TRIGGER;
		self.flags (+) FL_FINDABLE_NONSOLID;
	}

	void() weapon_lightning =
	{
		self.angles_x = 90;
		setmodel(self,"models/rifle1.iqm");
		setsize(self,[-20,-20,-20],[20,20,20]);
		setorigin(self,self.origin);
		self.modelflags (+) MF_ROTATE;
		self.classname = "rifle";
		self.touch = touch_item;
		self.think = think_item;
		self.solid = SOLID_TRIGGER;
		self.flags (+) FL_FINDABLE_NONSOLID;
	}

	void() weapon_shotgun =
	{
		self.angles_x = 90;
		setmodel(self,"models/player.iqm");
		setsize(self,[-20,-20,-20],[20,20,20]);
		setorigin(self,self.origin);
		self.modelflags (+) MF_ROTATE;
		self.classname = "shotgun";
		self.touch = touch_item;
		self.think = think_item;
		self.solid = SOLID_TRIGGER;
		self.flags (+) FL_FINDABLE_NONSOLID;
	}
#endif