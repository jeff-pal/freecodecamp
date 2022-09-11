-- Fix properties
ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;
ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;
ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;

ALTER TABLE properties ADD CONSTRAINT elements_atomic_number_fkey FOREIGN KEY (atomic_number) REFERENCES elements (atomic_number);
ALTER TABLE properties ADD COLUMN type_id INT CONSTRAINT type_fkey REFERENCES types (type_id);

UPDATE properties SET type_id = 1 WHERE type = 'nonmetal';
UPDATE properties SET type_id = 2 WHERE type = 'metal';
UPDATE properties SET type_id = 3 WHERE type = 'metalloid';
ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;
ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;
UPDATE properties SET atomic_mass = atomic_mass::REAL;
INSERT INTO properties(atomic_number, type, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) 
  VALUES
    (9, 'nonmetal' , 18.998, -220, -188.1, 1),
    (10, 'nonmetal' , 20.18, -248.6, -246.1, 1);

DELETE FROM properties WHERE atomic_number = 1000;
ALTER TABLE properties DROP COLUMN type;


-- Fix elements
ALTER TABLE elements ADD UNIQUE(symbol);
ALTER TABLE elements ADD UNIQUE(name);
ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;
ALTER TABLE elements ALTER COLUMN name SET NOT NULL;
UPDATE elements SET symbol = INITCAP(symbol);
INSERT INTO elements(atomic_number, symbol, name) 
  VALUES 
    (9, 'F', 'Fluorine'),
    (10, 'Ne', 'Neon');
DELETE FROM elements WHERE atomic_number = 1000;


-- Set up types
CREATE TABLE types(
  type_id INT PRIMARY KEY,
  type VARCHAR NOT NULL
);

INSERT INTO TYPES(type_id, type) VALUES
  (1, 'nonmetal'),
  (2, 'metal'),
  (3, 'metalloid');

