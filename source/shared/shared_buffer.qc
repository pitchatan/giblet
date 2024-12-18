




#ifdef CSQC
int buffer_sequence_amount;
int buffer_count_max = 140;
struct 
{
	int seq;
}
buffer_sequence[buffer_count_max];


void(int seq) buffer_sequence_add =
{

	for(int x = buffer_count_max-1; x > 0; x--)
	{
		buffer_sequence[x].seq = buffer_sequence[x-1].seq;
	}
	buffer_sequence[0].seq = seq;
};

float(int seq) buffer_sequence_find =
{
	for(int x; x < buffer_count_max-1; x++)
	{
		if(buffer_sequence[x].seq == seq)
		{
			return TRUE;
		}
	}
}


#endif


vector InterpolateBuffer(entity target, float target_time, optional int ignore)
{
	local float i;
	vector last_origin;
	vector last_angles;
	float last_frame1time;
	int last_frame;


	if(target_time > 0 && target.buffer_count > 2)
	{
// Variables to store the closest indices on either side of the target_time
		int lower_index = 0;
		int upper_index = 0;

// Find the two closest times that either encapsulate or are nearest to the target_time
		for (i = 0; i < target.buffer_count - 1; i++)
		{
			if (target.buffer_time[i] <= target_time && target.buffer_time[i + 1] >= target_time)
			{
			// Found the two closest encapsulating times
			lower_index = i;
			upper_index = i + 1;
			break;
			}
		}

// If no exact encapsulating indices were found, find the closest two indices around the target_time
		if (lower_index == -1 || upper_index == -1)
		{
		print("finding threshold\n");
		float min_lower_diff = 999999;
		float min_upper_diff = 999999;
			for (i = 0; i < target.buffer_count; i++)
			{
				float time_diff = target.buffer_time[i] - target_time;

				if (time_diff <= 0 && fabs(time_diff) < min_lower_diff)
				{
  				min_lower_diff = fabs(time_diff);
				lower_index = i;
				}
				else if (time_diff > 0 && time_diff < min_upper_diff)
				{
				min_upper_diff = time_diff;
				upper_index = i;
				}
			}
		}


// Ensure we have valid indices to interpolate
		if (lower_index >= 0 && upper_index >= 0)
		{
		// Interpolation setup between the closest times
			vector from = target.buffer_angles[lower_index];
			vector to = target.buffer_angles[upper_index];

			// Calculate angular difference with wrap-around handling
			float angle_diff = to_x - from_x;
			if (angle_diff > 180) angle_diff -= 360;
			if (angle_diff < -180) angle_diff += 360;

			// Interpolation factor for the target time between the closest times
			float interp_factor = (target_time - target.buffer_time[lower_index]) / (target.buffer_time[upper_index] - target.buffer_time[lower_index]);
    
			// Interpolate values based on this factor
			float lower_time = target.buffer_frame1time[lower_index];
			float upper_time = target.buffer_frame1time[upper_index];
			float frame_duration = frameduration(target.modelindex,target.buffer_frame[lower_index]);
			target.frame1time = InterpolateFrameDuration(lower_time, upper_time,frame_duration,interp_factor);

			//target.frame1time = target.buffer_frame1time[lower_index] * (1 - interp_factor) + target.buffer_frame1time[upper_index] * interp_factor;
			target.angles_x = from_x + angle_diff * interp_factor;
			target.frame = target.buffer_frame[lower_index];
    
			if (!target.skeletonobject)
				target.skeletonobject = skel_create(target.modelindex);
    
			return target.buffer_origin[lower_index] * (1 - interp_factor) + target.buffer_origin[upper_index] * interp_factor;

		}
		self.old_interpfactor = interp_factor;
		self.old_index1 = lower_index;
		self.old_index2 = upper_index;

	}
	else
	{


		if(target.buffer_count > 0)
		{
			if(autocvar_g_debug_interp)
			{
			#ifdef CSQC
			print("CS: ");
			#endif

			#ifdef SSQC
			print("SV: ");
			#endif

			print("count: ");
			print(ftos(target.buffer_count));
				print(" no valid position\n");
			}
		target.angles = target.buffer_angles[target.buffer_count-1];
		target.frame = target.buffer_frame[target.buffer_count-1];
		target.frame1time = target.buffer_frame1time[target.buffer_count-1];

		if(target.buffer_origin[target.buffer_count-1] != [0,0,0])
		return target.buffer_last_origin;//return target.buffer_origin[target.buffer_count-1];  // Default return if no valid time found
		else
		return target.buffer_last_origin;  // Default return if no valid time found
		}
	}
	
	if(target.old_index1 > 0 && target.old_index2 > 0)
	{
		if(autocvar_g_debug_interp)
			print("returning something else\n");
	//return (target.buffer_origin[target.old_index1] * (1 - interp_factor) + target.buffer_origin[target.old_index2] * interp_factor);
	}

}



void AddToSortedBuffer(entity target,float timer)
{
    local float current_time = timer;  // Store current time
if(timer > target.last_timer)
{
target.buffer_last_origin = target.origin;

    // If the buffer is full, we need to remove the oldest entry (smallest time)
    if (target.buffer_count >= buffer_max)
    {
        // Find the oldest entry (smallest time) and remove it
        local float oldest_index = 0;
        local float oldest_time = target.buffer_time[0];
        local float i;

        for (i = 1; i < target.buffer_count; i++)
        {
            if (target.buffer_time[i] < oldest_time)
            {
                oldest_time = target.buffer_time[i];
                oldest_index = i;
            }
        }

        // Shift entries after the oldest_index up to remove the oldest entry
        for (i = oldest_index; i < target.buffer_count - 1; i++)
        {
            target.buffer_origin[i] = target.buffer_origin[i + 1];
            target.buffer_angles[i] = target.buffer_angles[i + 1];
            target.buffer_velocity[i] = target.buffer_velocity[i + 1];
            target.buffer_frame[i] = target.buffer_frame[i + 1];
            target.buffer_frame1time[i] = target.buffer_frame1time[i + 1];
            target.buffer_time[i] = target.buffer_time[i + 1];
        }

        target.buffer_count--;  // Decrement the count after removing the oldest entry
    }

    // Find the correct position to insert the new entry based on time
    local float insert_index = target.buffer_count;
    local float j;

    for (j = 0; j < target.buffer_count; j++)
    {
        if (target.buffer_time[j] > current_time)
        {
            insert_index = j;
            break;
        }
    }

    // Shift all entries after insert_index down to make space for the new entry
    for (j = target.buffer_count; j > insert_index; j--)
    {
        target.buffer_origin[j] = target.buffer_origin[j - 1];
        target.buffer_angles[j] = target.buffer_angles[j - 1];
        target.buffer_velocity[j] = target.buffer_velocity[j - 1];
        target.buffer_frame[j] = target.buffer_frame[j - 1];
        target.buffer_frame1time[j] = target.buffer_frame1time[j - 1];
       target. buffer_time[j] = target.buffer_time[j - 1];
    }

    // Insert the player's current data at insert_index
    target.buffer_origin[insert_index] = target.origin;         // Store player's origin
    target.buffer_angles[insert_index] = target.angles;         // Store player's angles
    target.buffer_velocity[insert_index] = target.velocity;     // Store player's velocity
    target.buffer_frame[insert_index] = target.frame;           // Store animation frame
    target.buffer_frame1time[insert_index] = target.frame1time;   // Store frame time
    target.buffer_time[insert_index] = current_time;            // Store the current time

    target.buffer_count++;  // Increment the buffer count after adding the new entry

	target.last_timer = timer;
}
else
{
	#ifdef SSQC
	// print(target.classname);
	// print(" did not add to buffer!\n");
	#endif
}
}
