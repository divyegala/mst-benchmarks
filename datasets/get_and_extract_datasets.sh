#!/bin/bash

if [ ! -f "datasets/${1}" ]; then
    if [ ! -f "datasets/${1}.gz" ]; then
        wget -P datasets/ "http://www.diag.uniroma1.it/challenge9/data/USA-road-d/${1}.gz"
    fi
    gunzip "datasets/${1}.gz"
fi