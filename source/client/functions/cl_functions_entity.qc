entity(float entnums) num_for_ent = 
{
	entity finder = findfloat(world,entnum,entnums);
	while(finder)
	{
		if(finder.entnum == entnums)
		return finder;
		finder = finder.chain;
	}
	return finder;
}