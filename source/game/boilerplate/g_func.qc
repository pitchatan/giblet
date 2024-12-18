void() func_rotating =
{

	#ifdef SSQC
		self.movetype = MOVETYPE_PUSH;
		self.solid = SOLID_BSP;
		setmodel(self,self.model);
		setorigin(self, self.origin);
		setmodel(self, self.model);

		print("rotating\n");
	#endif
}


void() func_door1 =
{
	#ifdef SSQC
	self.spawnflags = DOOR_CLOSED;
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.avelocity = [0,0,20];
	self.think = think_func_rotating;
	self.nextthink = self.ltime + 1/60;
	
	setmodel(self,self.model);
	self.angles = self.angles;
	setsize(self,self.mins,self.maxs);
	setorigin(self,self.origin);
	#endif

};


void() func_static =
{
	//InitTrigger();
	setmodel (self, self.model);	// set size and link into world
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
//	self.flags (+) FL_FINDABLE_NONSOLID;
	setsize(self,self.mins,self.maxs);
	setorigin(self,self.origin);
}