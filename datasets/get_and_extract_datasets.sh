#!/bin/bash

wget -P datasets/ "http://www.diag.uniroma1.it/challenge9/data/USA-road-d/${1}.gz"
yes | gunzip "datasets/${1}.gz"