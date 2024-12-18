void() misc_model =
{
	setmodel(self,self.model);
	self.angles = self.angles;
	setsize(self,self.mins,self.maxs);
	setorigin(self,self.origin);
	self.movetype = MOVETYPE_NONE;

}


void() advertisement =
{
//	InitTrigger();
	setmodel (self, self.model);	// set size and link into world
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
	self.flags (+) FL_FINDABLE_NONSOLID;
	setsize(self,self.mins,self.maxs);
	setorigin(self,self.origin);
}


void() misc_model2 =
{
	#ifdef SSQC
	self.solid = SOLID_BBOX;
	self.mass = 1;
	self.bouncefactor = 0.1;
	self.bouncestop = 0.1;
	setmodel(self,self.model);
	setorigin(self,self.origin + [0,0,20]);
	print("misc_model2 spawned\n");
	//self.glowmod = [0,22,0];
	#endif
};