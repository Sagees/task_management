#!/bin/bash

python3 run_train.py --use_model transformer --data_dir ../data/trace102.csv --saved_model_dir ../weights/102

python3 run_train.py --use_model transformer --data_dir ../data/trace103.csv --saved_model_dir ../weights/103

python3 run_train.py --use_model transformer --data_dir ../data/trace104.csv --saved_model_dir ../weights/104