void(vector origin, int damage) dmg_plume_add 
{
	for(int x = dmg_plume_max-1; x > 0; x--)
	{
		dmg_plume[x].damage = dmg_plume[x-1].damage;
		dmg_plume[x].origin = dmg_plume[x-1].origin;
		dmg_plume[x].time = dmg_plume[x-1].time;
	}

	dmg_plume[0].damage = damage;
	dmg_plume[0].origin = origin + [0,0,50+random(20)];
	dmg_plume[0].time = cltime+3;
}; 