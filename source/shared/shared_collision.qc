void(entity target,vector pos,float timer,float radius) findradiusb =
{
	entity targets[500];
	vector targets_vadd[500];

	float targets_amount;

	entity search = findchainfloat(antilagged,TRUE);

	while(search)
	{
		if(search != target)
		{
				InterpolateBuffer(search, timer);
				float dist = vlen(pos - search.origin);

				if(dist <= radius)
				{
					float hitdist_scale = (1-(dist/200));

					targets[targets_amount] = search;
					targets_vadd[targets_amount] = normalize(search.origin+[0,0,search.maxs_z/2]-pos)*600*hitdist_scale;
					targets_amount++;
				}
		}

		search = search.chain;
	}


	if(targets_amount)
	{
		for(int x; x < targets_amount; x++)
		{
			InterpolateBuffer(targets[x],0);
			targets[x].velocity += targets_vadd[x];
		}
	}
};


void(vector v1, vector v2, float flags, entity ent,float timer, optional float(entity victim) callback) tracelineb =
{
	#ifdef CSQC
	timer = 0;
	#endif
				entity finder;

				if(timer)
				{
					finder = findchainfloat(antilagged,TRUE);
					while(finder)
					{
						if(finder != ent && finder != ent.owner && finder.buffer_count)
						setorigin(finder,InterpolateBuffer(finder,timer));


						
					finder = finder.chain;
					}
				}

				#ifdef SSQC

				//if(flags & MOVE_LAGGED)
				//	flags (-) MOVE_LAGGED;
				#endif

				traceline(v1,v2,flags,ent);

				if(timer)
				{
					finder = findchainfloat(antilagged,TRUE);
					while(finder)
					{
						if(finder != ent && finder != ent.owner && finder.buffer_count)
							setorigin(finder,InterpolateBuffer(finder,0));
				



						finder = finder.chain;
					}
				}
}
