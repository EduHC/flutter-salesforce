CREATE TABLE
    IF NOT EXISTS customer (
        id INTEGER PRIMARY KEY ASC NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        cellphone TEXT,
        cpf TEXT,
        isActive INTEGER NOT NULL,
        type TEXT,
        gender TEXT,
        email TEXT,
        street TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        postcode TEXT,
        pictureUrl TEXT,

        CHECK (type IN ('pf', 'pj')),
        CHECK (gender IN ('male', 'female'))
    );

CREATE TABLE
    IF NOT EXISTS appConfiguration (
        id INTEGER PRIMARY KEY ASC NOT NULL,
        isActive BOOLEAN NOT NULL
    );

CREATE TABLE
    IF NOT EXISTS kafkaTopicOffset (
        id INTEGER PRIMARY KEY ASC NOT NULL,
        topicName VARCHAR(50) NOT NULL,
        partition INT NOT NULL,
        offset INT NOT NULL
    );

CREATE TABLE IF 
    NOT EXISTS product (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        img TEXT NOT NULL,
        rating REAL NOT NULL
    );


CREATE TABLE 
    IF NOT EXISTS sale (
        id INTEGER PRIMARY KEY ASC NOT NULL,
        customerId INTEGER NOT NULL,
        paid INTEGER NOT NULL,
        discount REAL NOT NULL,
        createdAt DATETIME NOT NULL,

        FOREIGN KEY (customerId) REFERENCES Customer(id)
    );


CREATE TABLE 
    IF NOT EXISTS saleProduct (
        id INTEGER PRIMARY KEY ASC NOT NULL,
        saleId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
      
        FOREIGN KEY (saleId) REFERENCES Sale(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES Product(id)
    );
