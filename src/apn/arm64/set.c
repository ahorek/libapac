#include "../../../include/apac.h"

void set_asimd_4unroll(
	apn_seg_t* result,
	apn_size_t size,
	apn_seg_t val
)
{	apn_size_t counter = 0;

	while (counter < size)
	{
		result[counter] = val;
		counter++;
	}

	return;
}