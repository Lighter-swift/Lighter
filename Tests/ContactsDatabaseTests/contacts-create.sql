/**
 * ZeeQL test schema
 *
 * Copyright © 2017-2024 ZeeZide GmbH. All rights reserved.
 */
 
CREATE TABLE person (
  person_id INTEGER PRIMARY KEY NOT NULL,
  
  firstname VARCHAR NULL,
  lastname  VARCHAR NOT NULL
);

CREATE TABLE address (
  address_id INTEGER PRIMARY KEY NOT NULL,
  
  street    VARCHAR NULL,
  city      VARCHAR NULL DEFAULT 'Magdeburg',
  state     VARCHAR NULL,
  country   VARCHAR NULL,

  age       INTEGER DEFAULT NULL,
  answer    INTEGER DEFAULT 42,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  
  person_id INTEGER,
  FOREIGN KEY(person_id) REFERENCES person(person_id)
       ON DELETE CASCADE
       DEFERRABLE
);
