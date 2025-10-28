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

    if (apn_cmp(res, expected, 3) == 0) {
        printf("apn_add_n test passed!\n");
        return 0;
    } else {
        printf("apn_add_n test failed!\n");
        return 1;
    }
}


int main() {
    apacGetCPUSpec();
    if (test_apn_add_n()) {
	    return 1;
    }

    printf("All tests passed!\n");
    return 0;
}
