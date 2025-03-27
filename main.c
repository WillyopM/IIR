#include <stdio.h>
#include <stdlib.h>

#define count 1000
#define epsilon 0.0001

int main() {
    double d = 0.99;
    double a = d;
    double b = 1.0 - d;
    double yn = 0.0;
    double yn_m1 = 0;
    double xn = 10.0;
    

    // Open a file for writing
    FILE *file = fopen("output.csv", "w");
    if (file == NULL) {
        perror("Error opening file");
        return 1;
    }

    // Write CSV header
    fprintf(file, "Iteration,yn\n");
    
    for (int i = 0; i < count; i++)
    {
        yn = b * xn + a * yn_m1;
        yn_m1 = yn;
        fprintf(file, "%d,%f\n", i, yn); // Write iteration and yn to the file
    }

    fclose(file); // Close the file
    printf("Data written to output.csv\n");

    return 0;
}