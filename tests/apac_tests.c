// change this header inclusion as per need
#include "../include/apac.h"

/*
     ----------------------------- UNIT TESTS -----------------------------
*/

int test_apn_add_n() {
    apn_seg_t a[3] = {1, 2, 3};
    apn_seg_t b[3] = {4, 5, 6};
    apn_seg_t res[3];

    apn_add_n(res, a, b, 3);

    apn_seg_t expected[3] = {5, 7, 9};

    for (size_t i = 0; i < 3; i++) {
        if (res[i] != expected[i]) {
            fprintf(stderr, "Test failed at index %zu: got %u, expected %u\n",
                    i, (unsigned int)res[i], (unsigned int)expected[i]);
            return 1;
        }
    }

    printf("apn_add_n test passed!\n");
    return 0;
}


int main() {
    apacGetCPUSpec();
    if (test_apn_add_n()) {
	return 1;
    }

    printf("All tests passed!\n");
    return 0;
}
