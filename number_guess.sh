#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"
SECRET_NUMBER=$[ $RANDOM % 1000 + 1 ]
NUMBER_OF_GUESSES=0
echo $SECRET_NUMBER

GUESS_LOOP() {
  ((++NUMBER_OF_GUESSES))
  if ! [[ $1 =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
    GUESS_LOOP $GUESS
  else
    if [[ $1 -eq $SECRET_NUMBER ]]
    then
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      UPDATE_DATABASE
    else
      if [[ $1 -gt $SECRET_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        read GUESS
        GUESS_LOOP $GUESS
      else
        if [[ $1 -lt $SECRET_NUMBER ]]
        then
          echo -e "\nIt's higher than that, guess again:"
          read GUESS
          GUESS_LOOP $GUESS
        fi
      fi
    fi
  fi
}

UPDATE_DATABASE() {
  UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
  CURRENT_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  if [[ $NUMBER_OF_GUESSES -lt $CURRENT_BEST_GAME ]]
  then
    UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  fi
}

echo "Enter your username:"
read USERNAME
USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")

if [[ -z $USER ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  echo "$USER" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GUESS_LOOP $GUESS
