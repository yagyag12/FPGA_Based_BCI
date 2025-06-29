#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "treeSplits.h"

#define MAX_FEATURES 27
#define LINE_LENGTH 256


int classify(const double *features) {
    int node = 0;
    while (tree[node].left != -1 && tree[node].right != -1) {
        if (features[tree[node].feature_index] < tree[node].threshold) {
            node = tree[node].left;
        } else {
            node = tree[node].right;
        }
    }
    return tree[node].class_label;
}


void parse_features(FILE *in, FILE *out) {
    char line[LINE_LENGTH];
    double features[MAX_FEATURES];
    int feature_count = 0;

    while (fgets(line, sizeof(line), in)) {
        // End of one sample
        if (strstr(line, "----")) {
            if (feature_count == MAX_FEATURES) {
                int label = classify(features);
                fprintf(out, "%d\n", label);
            } else {
                fprintf(stderr, "Error: expected %d features, got %d\n", MAX_FEATURES, feature_count);
            }
            feature_count = 0;
            continue;
        }

        // Parse all integers from the line
        char *token = strtok(line, "=,:\n ");
        while (token != NULL) {
            char *endptr;
            long val = strtol(token, &endptr, 10);
            if (*endptr == '\0' && feature_count < MAX_FEATURES) {
                features[feature_count++] = (double)val;
            }
            token = strtok(NULL, "=,:\n ");
        }
    }

    // Handle last sample if no trailing dashes
    if (feature_count == MAX_FEATURES) {
        int label = classify(features);
        fprintf(out, "%d\n", label);
    }
}

int main() {
    FILE *in = fopen("C:\\Users\\user\\CLionProjects\\decisionTreeImp\\out_features_processed.txt", "r");
    FILE *out = fopen("output.txt", "w");
    if (!in || !out) {
        perror("File error");
        return 1;
    }

    parse_features(in, out);

    fclose(in);
    fclose(out);
    return 0;
}
