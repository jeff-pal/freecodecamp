#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ $1 ]]
then
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    CONDITIONS="e.symbol = '$1' OR e.name = '$1'"
  else
    CONDITIONS="e.atomic_number = $1"
  fi
  ELEMENT_INFO=$($PSQL "
    SELECT
      e.atomic_number,
      e.symbol,
      e.name,
      t.type,
      p.atomic_mass,
      p.melting_point_celsius,
      p.boiling_point_celsius
    FROM elements e
    JOIN properties p
      ON e.atomic_number = p.atomic_number
    JOIN types t
      ON p.type_id = t.type_id
    WHERE $CONDITIONS
    LIMIT 1
  ")
  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT_INFO" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
else
  echo "Please provide an element as an argument."
  # AVAILABLE_ELEMENTS=$($PSQL "SELECT * FROM elements")
  # echo "ATOMIC_NUMBER   SYMBOL   NAME"
  # echo "$AVAILABLE_ELEMENTS" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
  # do
  #   echo "$ATOMIC_NUMBER $SYMBOL $NAME"
  # done
  exit
fi