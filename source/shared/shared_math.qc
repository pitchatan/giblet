float(vector input) magnitude = 
{
	return sqrt((input_x*input_x) + (input_y*input_y));	
}

float vDot(vector a, vector b) {
    return a_x * b_x + a_y * b_y + a_z * b_z;
}

float RadToDeg(float radians)
{
    return radians * (180 / M_PI);
}


float abs(float value)
{
    if (value < 0)
        return -value;
    return value;
}


// Function to return a scale factor between 0 and 1 based on two vectors
float vscale(vector vector1, vector vector2) {
    float mag1 = magnitude(vector1);
    float mag2 = magnitude(vector2);

    if (mag2 == 0.0f) {
        // Avoid division by zero; return 1 if the second vector is zero
        return 1.0f;
    }

    // Calculate the ratio of magnitudes, clamped between 0 and 1
    float scale = mag1 / mag2;

    // Clamp the scale between 0 and 1
    if (scale > 1.0f) {
        scale = 1.0f;
    } else if (scale < 0.0f) {
        scale = 0.0f;
    }

    return scale;
}

float vfrac(float x, float y, float max_value) {
    float magnitude;
    float fraction;

    // Calculate the magnitude of the vector
    magnitude = sqrt(x * x + y * y);

    // Prevent division by zero; if max_value is zero, return 1 as a default
    if (max_value == 0) {
        return 1.0;
    }

    // Calculate the fraction by dividing the magnitude by max_value
    fraction = magnitude / max_value;

    // Clamp the result between 0 and 1
    if (fraction > 1.0) {
        fraction = 1.0;
    } else if (fraction < 0.0) {
        fraction = 0.0;
    }

    return fraction;
}



vector solve_quadratic( float a, float b, float c) =
{
     vector v;
     float D;
     v = '0 0 0';
     if (a == 0)
     {
         if (b != 0)
         {
             v.x = v.y = -c / b;
             v.z = 1;
         }
         else
         {
             if (c == 0)
             {
                 // actually, every number solves the equation!
                 v.z = 1;
             }
         }
     }
     else
     {
         D = b * b - 4 * a * c;
         if (D >= 0)
         {
             D = sqrt(D);
             if (a > 0)  // put the smaller solution first
             {
                 v.x = ((-b) - D) / (2 * a);
                 v.y = ((-b) + D) / (2 * a);
             }
             else
             {
                 v.x = (-b + D) / (2 * a);
                 v.y = (-b - D) / (2 * a);
             }
             v.z = 1;
         }
         else
         {
             // complex solutions!
             D = sqrt(-D);
             v.x = -b / (2 * a);
             if (a > 0) v.y =  D / (2 * a);
             else v.y = -D / (2 * a);
             v.z = 0;
         }
     }
     return v;
}

 vector trigger_push_calculatevelocity(vector org, entity tgt, float ht, entity pushed_entity)
 {
	// pushed_entity.gravity = pushed_entity.velocity_z*10;
     float grav, sdist, zdist, vs, vz, jumpheight;
     vector sdir, torg;
   jumpheight = 360;
     torg = tgt.origin + (tgt.mins + tgt.maxs) * 0.5;
 
     grav = 320; //PHYS_GRAVITY(NULL);
     if(pushed_entity && pushed_entity.gravity)
         grav *= pushed_entity.gravity;
 
     zdist = torg.z - org.z;
     sdist = vlen(torg - org - zdist * '0 0 1');
     sdir = normalize(torg - org - zdist * '0 0 1');
 
     // how high do we need to push the player?
     jumpheight = fabs(ht);
     if(zdist > 0)
         jumpheight = jumpheight + zdist;
 
     /*
         STOP.
 
         You will not understand the following equations anyway...
         But here is what I did to get them.
 
         I used the functions
 
           s(t) = t * vs
           z(t) = t * vz - 1/2 grav t^2
 
         and solved for:
 
           s(ti) = sdist
           z(ti) = zdist
           max(z, ti) = jumpheight
 
         From these three equations, you will find the three parameters vs, vz
         and ti.
      */
 
     // push him so high...
     vz = sqrt(fabs(2 * grav * jumpheight)); // NOTE: sqrt(positive)!
 
     // we start with downwards velocity only if it's a downjump and the jump apex should be outside the jump!
     if(ht < 0)
         if(zdist < 0)
             vz = -vz;
 
     vector solution;
     solution = solve_quadratic(0.5 * grav, -vz, zdist); // equation "z(ti) = zdist"
     // ALWAYS solvable because jumpheight >= zdist
     if(!solution.z)
         solution_y = solution.x; // just in case it is not solvable due to roundoff errors, assume two equal solutions at their center (this is mainly for the usual case with ht == 0)
     if(zdist == 0)
         solution_x = solution.y; // solution_x is 0 in this case, so don't use it, but rather use solution_y (which will be sqrt(0.5 * jumpheight / grav), actually)
 
     float flighttime;
     if(zdist < 0)
     {
         // down-jump
         if(ht < 0)
         {
             // almost straight line type
             // jump apex is before the jump
             // we must take the larger one
             flighttime = solution.y;
         }
         else
         {
             // regular jump
             // jump apex is during the jump
             // we must take the larger one too
             flighttime = solution.y;
         }
     }
     else
     {
         // up-jump
         if(ht < 0)
         {
             // almost straight line type
             // jump apex is after the jump
             // we must take the smaller one
             flighttime = solution.x;
         }
         else
         {
             // regular jump
             // jump apex is during the jump
             // we must take the larger one
             flighttime = solution.y;
         }
     }
     vs = sdist / flighttime;
 
     // finally calculate the velocity
     return sdir * vs + '0 0 1' * vz;
 }

float V_springterp(float current, float target, float speedo, float stiffness, float damping, float deltaTime)
{
    float displacement = target - current;
    float springForce = displacement * stiffness;
    float dampingForce = (speedo) * damping;
    float force = springForce - dampingForce;
    speedo += force * deltaTime;
    return current + (speedo) * deltaTime;
}

float getpercentage(float min, float max, float current)
{
    if (max == min)
        return 0; // Avoid division by zero

    return ((current - min) / (max - min)) * 100;
}

float getfraction(float min, float max, float current)
{
    if (max == min)
        return 0; // Avoid division by zero

    return (current - min) / (max - min);
}


vector VectorToZero(vector v, float delta)
{
    // X axis
    if (v_x > 0)
        v_x = max(0, v_x - delta);  // Reduce positive x towards 0
    else if (v_x < 0)
        v_x = min(0, v_x + delta);  // Increase negative x towards 0 (reduce magnitude)

    // Y axis
    if (v_y > 0)
        v_y = max(0, v_y - delta);  // Reduce positive y towards 0
    else if (v_y < 0)
        v_y = min(0, v_y + delta);  // Increase negative y towards 0 (reduce magnitude)

    // Z axis
    if (v_z > 0)
        v_z = max(0, v_z - delta);  // Reduce positive z towards 0
    else if (v_z < 0)
        v_z = min(0, v_z + delta);  // Increase negative z towards 0 (reduce magnitude)

	return v;
}


vector VectorDiff(vector v1, vector v2)
{
    vector result;

    result_x = v1_x - v2_x;  // Difference in x components
    result_y = v1_y - v2_y;  // Difference in y components
    result_z = v1_z - v2_z;  // Difference in z components

    return result;  // Return the resulting vector
}


float(float angle) smoothsin =
{
    // Get the sine of the input angle and remap it from [-1, 1] to [0, 1]
    float sin_value = (sin(angle) + 1) * 0.5;

    // Apply a smoothing function for even speed; using a quadratic (parabolic) easing
    float smooth_fraction = sin_value * sin_value * (3 - 2 * sin_value);

    return smooth_fraction;
};

float(float angle) smoothcos =
{
    // Get the sine of the input angle and remap it from [-1, 1] to [0, 1]
    float sin_value = (cos(angle) + 1) * 0.5;

    // Apply a smoothing function for even speed; using a quadratic (parabolic) easing
    float smooth_fraction = sin_value * sin_value * (3 - 2 * sin_value);

    return smooth_fraction;
};


float(float a, float b) angle_diff_signed =
{
	float diff = (a - b + 180) % 360 - 180;
	if (diff < -180) diff += 360;
	if (diff > 180) diff += 360;
	return diff;
}

vector(vector a, vector b) angle_diff_signed_v =
{
    vector diff;

    // Calculate the difference for each axis
    diff_x = (a_x - b_x + 180) % 360 - 180;
    diff_y = (a_y - b_y + 180) % 360 - 180;
    diff_z = (a_z - b_z + 180) % 360 - 180;

    // Normalize to ensure differences fall within the -180 to 180 range
    if (diff_x < -180) diff_x += 360;
    if (diff_x > 180) diff_x -= 360;

    if (diff_y < -180) diff_y += 360;
    if (diff_y > 180) diff_y -= 360;

    if (diff_z < -180) diff_z += 360;
    if (diff_z > 180) diff_z -= 360;

    return diff;
};


float InterpolateFrameDuration(float start_time, float end_time, float frame_duration, float interp_factor)
{
    // Calculate the difference, using modular arithmetic to keep it within frame boundaries
    float time_diff = end_time - start_time;

    // If the difference is positive and larger than half the frame duration, it wraps backward
    if (time_diff > frame_duration / 2) {
        time_diff -= frame_duration;
    }
    // If the difference is negative and larger than half the frame duration, it wraps forward
    else if (time_diff < -frame_duration / 2) {
        time_diff += frame_duration;
    }

    // Apply interpolation factor to get the interpolated time within the correct wrap
    return start_time + time_diff * interp_factor;
}

vector() GetBrushCenter =
{
    return (self.absmin + self.absmax) * 0.5;
};


float InterpolateFloat(float start, float end, float interp_fraction) {
    // Ensure interp_fraction is clamped between 0 and 1
    if (interp_fraction < 0)
        interp_fraction = 0;
    else if (interp_fraction > 1)
        interp_fraction = 1;

    return start + (end - start) * interp_fraction;
}


float randomize(float seed, float min, float max) {
    float a = 1664525;      // Multiplier
    float c = 1013904223;   // Increment
    float m = 2147483647;   // Modulus (2^31 - 1)

    // Generate the next pseudo-random number
    seed = mod((a * seed + c), m);

    // Normalize to the 0.0 - 1.0 range
    float normalized = seed / m;

    // Scale to the desired range [min, max]
    return min + normalized * (max - min);
}


#ifdef SSQC // defines if this is for SSQC only.. will be ignored when compiling CSQC ...  other hand use #ifdef CSQC if you want CSQC only... 

void(float MSG, vector vec) WriteVector = // shorthand function,  will send 32bit values (check cl_main.qc for read values)
{
	WriteCoord(MSG,vec_x);
	WriteCoord(MSG,vec_y);
	WriteCoord(MSG,vec_z);
};

void(float MSG, vector vec) WriteVectorShort = // shorthand function,  will send 16bit values (check cl_main.qc for read values)
{
	
	WriteShort(MSG,vec_x);
	WriteShort(MSG,vec_y);
	WriteShort(MSG,vec_z);
};



#endif  // stop ifing......

float is_infront(entity target,vector direction)
{
    vector dir_to_target;
    vector forward;
    float dot;

    // Compute the forward vector from the player's angles
    makevectors(target.angles); // Populates v_forward, v_right, v_up
    forward = v_forward;

    // Compute the direction to the target
    dir_to_target = normalize(direction - normalize(target.origin));

    // Compute the dot product
    dot = vectoangles(dir_to_target) * forward;

    // If the dot product is positive, the target is in front
    return (dot > 0);
}


float Lerp( float a, float b, float t)
{
	return ( 1.0f - t ) * a + b * t;
};

float InvLerp( float a, float b , float v) 
{
	return ( v -a ) / (b - a);
};

float Remap (float iMin, float iMax, float oMin, float oMax, float v)
{
	float t = InvLerp ( iMin, iMax, v);
	return Lerp(oMin, oMax,t);

};


vector(vector vec, vector normal) VectorProjectOnPlane
{
    // Calculate the component of vec parallel to the plane
    float dot_product = dotproduct(vec, normal);
    vector parallel_component = normal * dot_product;

    // Subtract the parallel component from the original vector to get the projected vector
    return vec - parallel_component;
};