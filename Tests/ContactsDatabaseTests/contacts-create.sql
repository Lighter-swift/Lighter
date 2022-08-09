/**
 * ZeeQL test schema
 *
 * Copyright © 2017 ZeeZide GmbH. All rights reserved.
 */
 
CREATE TABLE person (
  person_id INTEGER PRIMARY KEY NOT NULL,
  
  firstname VARCHAR NULL,
  lastname  VARCHAR NOT NULL
);

CREATE TABLE address (
  address_id INTEGER PRIMARY KEY NOT NULL,
  
  street  VARCHAR NULL,
  city    VARCHAR NULL,
  state   VARCHAR NULL,
  country VARCHAR NULL,
  
  person_id INTEGER,
  FOREIGN KEY(person_id) REFERENCES person(person_id) 
       ON DELETE CASCADE
       DEFERRABLE
);
