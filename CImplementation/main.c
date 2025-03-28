#include <stdio.h>
#include <stdlib.h>

#define COUNT 1000
#define D 0.99

int main() {
    double yn = 0.0;
    double yn_m1 = 0.0;
    double xn = 10.0;
    double delta, mul;

    // Open a file for writing
    FILE *file = fopen("output.csv", "w");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Write CSV header
    fprintf(file, "Iteration,yn\n");

    for (int i = 0; i < COUNT; i++) {
        delta = (yn_m1 - xn);
        mul = D * delta;
        yn = xn + mul;
        yn_m1 = yn;

        fprintf(file, "%d,%f\n", i, yn);
    }

    fclose(file);
    printf("Data written to output.csv\n");

    return 0;
}
