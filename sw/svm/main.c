/************************************************************/
//      S U P P O R T   V E C T O R   M A C H I N E         //
//                                                          //
//  Desc: Eye state classification with a pretrained SVM    //
//                                                          //
/************************************************************/

/***********************  INCLUDES  *************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "param.h" 
#include "inputs_data.h"

/***********************  CONSTANTS  ************************/

#define N_FEATURES 27   // No of input features
#define N_SV 8477       // No of support vector
#define N_INPUTS 9745   // No of inputs

/***********************  FUNCTIONS  ************************/
// RBF Kernel function
double rbf_kernel(const double *x, const double *sv) {
    double sum_sq = 0.0;
    for (int i = 0; i < N_FEATURES; ++i) {
        double diff = x[i] - sv[i];
        sum_sq += diff * diff;
    }
    return exp(-mySVM_gamma * sum_sq);
}

// Gaussian SVM prediction
int predict_svm(const double *x) {
    double score = 0.0;
    for (int i = 0; i < N_SV; ++i) {
        score += mySVM_alpha[i] * rbf_kernel(x, mySVM_SVs[i]);
    }
    score += mySVM_bias;
    //printf("Final score: %.6f\n", score);
    return (score >= 0.0) ? 1 : 0;
}

/*************************  MAIN  ***************************/

int main() {
    FILE *out = fopen("output.txt", "w");
    if (!out) {
        perror("Error opening output file");
        return 1;
    }

    for (int i = 0; i < N_INPUTS; ++i) {
        int label = predict_svm(inputs[i]);
        fprintf(out, "%d\n", label);
    }

    fclose(out);
    return 0;
}
