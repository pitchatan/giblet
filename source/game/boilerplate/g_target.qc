void() target_position =
{
	self.name = self.name;
	self.targetname = self.targetname;
	print(self.targetname);
	print("\n");
	setsize(self,[-20,-20,-20],[20,20,20]);
	self.solid = SOLID_NOT;
};

void() target_push =
{

};

void() target_location =
{

};