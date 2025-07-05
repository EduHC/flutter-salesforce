

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

ALTER TABLE product RENAME TO product_old;

CREATE TABLE product (
  id INTEGER PRIMARY KEY,
  description TEXT NOT NULL,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  img TEXT NOT NULL,
  rating REAL NOT NULL
);

INSERT INTO product (id, description, name, price, img, rating)
SELECT id, description, name, price, img, rating
FROM product_old;

DROP TABLE product_old;
DROP TABLE IF EXISTS category;

COMMIT;
PRAGMA foreign_keys = ON;
