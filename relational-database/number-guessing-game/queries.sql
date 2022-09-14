DROP DATABASE IF EXISTS number_guess;

CREATE DATABASE number_guess WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';

\c number_guess;

CREATE TABLE users(
  user_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE games(
  game_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(user_id),
  guesses INT NOT NULL
);