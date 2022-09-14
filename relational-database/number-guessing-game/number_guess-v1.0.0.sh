#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
GUESSES=0

function TRY_TO_GUESS() {
  if [[ $1 ]]
  then
    echo $1
  fi

  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    TRY_TO_GUESS "That is not an integer, guess again:"
  fi
}

function RESET_GAME() {
  GUESSES=0
  NEW_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, 0) RETURNING game_id")
  GAME_ID=$(echo $NEW_GAME_RESULT | sed 's/\([0-9]*\) .*/\1/')
}

function PLAY_GAME() {
  if [[ $1 ]]
  then
    TRY_TO_GUESS "$1"
  else
    TRY_TO_GUESS "Guess the secret number between 1 and 1000:"
  fi

  ((GUESSES+=1))

  UPDATE_GAME_RESULT=$($PSQL "UPDATE games SET guesses = guesses + 1 WHERE game_id = $GAME_ID")

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    exit
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    PLAY_GAME "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    PLAY_GAME "It's higher than that, guess again:"
  fi
}

function MAIN() {
  echo "Enter your username:"
  read USERNAME

  USER=$($PSQL "SELECT user_id, name FROM users WHERE name = '$USERNAME'")
  USER_ID=$(echo $USER | sed 's/\(.*\)|.*/\1/')
  USERNAME_FROM_DB=$(echo $USER | sed 's/.*|\(.*\)/\1/')

  if [[ -z $USERNAME_FROM_DB ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_AND_GUESSES=$($PSQL "SELECT MIN(guesses), COUNT(*) FROM games WHERE user_id = '$USER_ID' AND guesses > 0")
    GAMES=$(echo $GAMES_AND_GUESSES | sed 's/.*|\(.*\)/\1/')
    MIN_GUESSES=$(echo $GAMES_AND_GUESSES | sed 's/\(.*\)|.*/\1/')

    echo "Welcome back, $USERNAME_FROM_DB! You have played $GAMES games, and your best game took $MIN_GUESSES guesses."
  fi

  NEW_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, 0) RETURNING game_id")
  GAME_ID=$(echo $NEW_GAME_RESULT | sed 's/\([0-9]*\) .*/\1/')

  PLAY_GAME
}

MAIN