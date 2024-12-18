void() dmg_plume_render 
{
	for(int x; x < dmg_plume_max-1; x++)
	{
		if(dmg_plume[x].damage && cltime < dmg_plume[x].time)
		{


		dmg_plume[x].origin.z += 25*frametime;
		dmg_plume[x].origin.x += sin(cltime*3)*25*frametime;
		dmg_plume[x].origin.y += sin(cltime*3)*25*frametime;

		float size = 15;
		vector pos = project(dmg_plume[x].origin);
		float dist = vlen(getproperty(VF_ORIGIN) - dmg_plume[x].origin);
		dist =  1 -  bound(0.2,dist/600,1);
		size = bound(5,size*dist,size);
		float alphas = 1 - bound(0.01,cltime / (dmg_plume[x].time),2);
		string damage = itos(dmg_plume[x].damage);
		float width = stringwidth(damage,0,size)/2;

		if(pos_z > 0)
			drawstring(pos-[width,size/2],damage,[size,size],[1,1,1],alphas,0);
		}
	}
};


void(vector org, vector pointangles,float height, float width,string texturename) render_face =
{

			float renderflag;
			renderflag = 0;

		
			renderflag (+) 2;
			renderflag (+) 1024;
			renderflag (+) EF_NODEPTHTEST;

			makevectors(pointangles);


			vector pos = org + [0,0,0] + v_forward*0 - v_right*width/2 - v_up*height/2;
			vector offset = v_forward;



			R_BeginPolygon(texturename, renderflag);
			R_PolygonVertex(pos, '1 1', getlight(pos)/255, 1);
			R_PolygonVertex(pos+v_right*width, '0 1', getlight(pos+v_right*width)/255, 1);
			R_PolygonVertex(pos+v_right*width + v_up*height, '0 0', getlight(pos+v_right*width + v_up*height)/255, 1);
			R_PolygonVertex(pos+v_up*height, '1 0', getlight(pos+v_up*height)/255, 1);
			R_EndPolygon();
}