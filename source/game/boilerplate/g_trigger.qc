void() trigger_push =
{
	InitTrigger();
	//setorigin(self,self.origin+[0,0,3]);
	self.name = self.name;
	self.targetname = self.targetname;
	print(self.targetname);
	print(" : ");
	print(vtos(self.absmin - self.absmax));
	print(" spawned push\n");
	
	#ifdef CSQC
	//ambientsound(self.absmax-self.absmin,"assets/sounds/jumppad_ambient.ogg",1,ATTN_STATIC);
	#endif
	self.touch = push_touch;
	
};