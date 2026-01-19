#include "../../../include/apac.h"

int is_zero_asimd_4unroll(
    const apn_seg_t* op1,
    apn_size_t size
)
{
    apn_size_t counter = 0;

    while (counter < size)
    {
        if (op1[counter] != 0ULL)
            return 1;

        counter++;
    }

    return 0;
}