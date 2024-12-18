void() push_touch =
{
	
	entity finder = find(world,targetname,self.target);
#ifdef SSQC
	print(self.classname);
	print(" [VS] ");
	print(other.classname);
	print("\n");
#endif

	if(finder)
	{
	// trailparticles(particleeffectnum("t.smoke2"),self,(self.absmin+self.absmax)*0.5,finder.origin);
	float he = vlen(other.origin - finder.origin);
	other.velocity_z = 0;
	
	other.velocity = normalize(other.velocity)*100;
	other.velocity += trigger_push_calculatevelocity(other.origin,finder,he,other);
	#ifdef SSQC	
	sound(self,CHAN_BODY,"sounds/jumppad2.ogg",1,ATTN_NORM,random(90,110));
	#endif
	}	
};
