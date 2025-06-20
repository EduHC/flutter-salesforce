CREATE TABLE 
  IF NOT EXISTS apiLog (
    id INTEGER PRIMARY KEY ASC NOT NULL,
    countRetry INTEGER NOT NULL DEFAULT 0,
    createdAt DATETIME,
    route TEXT NOT NULL,
    headers TEXT NOT NULL,
    status VARCHAR(100) NOT NULL,
    method VARCHAR(15) NOT NULL,
    sentToKafka BOOLEAN NOT NULL DEFAULT 0,
    finishedAt DATETIME,
    queryParams TEXT,
    requestBody TEXT,
    responseBody TEXT,
    responseCode INTEGER,
    requestDuration TEXT 
  );