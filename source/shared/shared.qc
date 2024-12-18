
		#include	"shared_math.qc"
		#include	"shared_physics.qc"
		#include	"shared_physics_projectiles.qc"
		#include	"shared_buffer.qc"
		#include	"shared_collision.qc"
		#include	"shared_entity_touch.qc"
		#include	"shared_entity_thinks.qc"
		#include	"shared_entity.qc"
		#include	"shared_functions.qc"

		#ifdef CSQC
			#include	"shared_predraws.qc"
		#endif


















void(entity target,float input_butt, vector input_move,float input_tl, int parton) do_physics =
{



		/*
		We do a check to see if we are onground via a tracebox..  this should generally not have to be done, but as we are running the engines built in physics and CSQC being wonky like that.. here we are :)
		*/
	if(parton)
	{
		if(target.jump_timer > 0)
			target.jump_timer -= input_tl;
	
		if(target.jump_timer < 0)
			target.jump_timer = 0;

		if(target.step_timer > 0)
			target.step_timer -= input_tl;
	
		if(target.step_timer < 0)
			target.step_timer = 0;
	}



	if((target.flags & FL_ONGROUND) && input_move_z < 0)
	{
		SlideEntity(self,input_timelength);	// slide our shit down slopes yo
	}

	if((target.flags & FL_ONGROUND) && parton)
	{
		float velo = vlen([target.velocity_x,target.velocity_y]);
		if(!target.step_timer && (target.flags & FL_ONGROUND) && velo > 0)
		{
			sound(target,CHAN_BODY,"sounds/concrete_footsteps_1",0.2,ATTN_NORM,random(90,110));
			target.step_timer =  bound(0,1/(2.5 * velo/240),1);  //bound(0.1,(1/3)*(250/velo),1.5);
		}


		if(!target.jump_timer && input_move_z > 0)
		{
			sound(target,CHAN_VOICE,"sounds/jump1.ogg",1,ATTN_NORM,random(90,110));
			target.jump_timer = 1/4;
		}
	}

	Pmove_Run(target,input_butt,input_move,input_tl);



	do_weapons(target, input_butt, parton);		// run our weapons/hook code..	

	if(parton)
	input_call_impulse(target,input_impulse);


			#ifdef SSQC
			network_send_clientstats();
			#endif
};












