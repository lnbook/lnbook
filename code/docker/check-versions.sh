#!/bin/bash

# a small script to help sanity check the versions of the different node implementations
dockerfiles=$(find . -name 'Dockerfile')
# print location of dockerfiles
echo $dockerfiles
# print variables
awk '/ENV/ && /VER|COMMIT/' $dockerfiles
