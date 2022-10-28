#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$[ $RANDOM % 1000 + 1 ]
