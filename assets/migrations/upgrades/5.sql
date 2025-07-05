PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

ALTER TABLE product RENAME TO product_old;

CREATE TABLE product (
  id INTEGER PRIMARY KEY,
  description TEXT NOT NULL,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  img TEXT NOT NULL,
  rating REAL NOT NULL,
  categoryId INTEGER,
  FOREIGN KEY(categoryId) REFERENCES category(id)
);

INSERT INTO product (id, description, name, price, img, rating, categoryId)
SELECT id, description, name, price, img, rating, NULL
FROM product_old;

DROP TABLE product_old;

COMMIT;
PRAGMA foreign_keys = ON;
