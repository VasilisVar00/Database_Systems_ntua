CREATE TABLE "access" (
	"NFC_id"	INTEGER,
	"place_id"	INTEGER,
	"open_time"	INTEGER,
	"close_time"	INTEGER,
	FOREIGN KEY("place_id") REFERENCES "place"("place_id") ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY("NFC_id") REFERENCES "customer"("NFC_id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY("NFC_id","place_id")
)

CREATE TABLE "customer" (
	"NFC_id"	INTEGER NOT NULL UNIQUE,
	"first_name"	TEXT NOT NULL,
	"last_name"	TEXT NOT NULL,
	"birth_day"	INTEGER NOT NULL,
	" birth_month"	INTEGER NOT NULL,
	"birth_year"	INTEGER NOT NULL,
	"id_doc_number"	TEXT NOT NULL UNIQUE,
	"type_of_id"	TEXT NOT NULL,
	"issuing_auth"	TEXT NOT NULL,
	PRIMARY KEY("NFC_id" AUTOINCREMENT)
)

CREATE TABLE "customer_email" (
	"NFC_id"	INTEGER,
	"email"	NUMERIC CHECK("email" LIKE '%_@__%.__%') UNIQUE,
	FOREIGN KEY("NFC_id") REFERENCES "customer"("NFC_id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY("NFC_id","email")
)

CREATE TABLE "customer_phone" (
	"NFC_id"	INTEGER,
	"phone"	NUMERIC(10, 0) UNIQUE,
	PRIMARY KEY("NFC_id","phone"),
	FOREIGN KEY("NFC_id") REFERENCES "customer"("NFC_id") ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE "place" (
	"place_id"	INTEGER UNIQUE,
	"bed_num"	INTEGER NOT NULL,
	"place_name"	INTEGER NOT NULL,
	"place_position"	INTEGER NOT NULL,
	PRIMARY KEY("place_id" AUTOINCREMENT)
)

CREATE TABLE "provided_at" (
	"service_id"	INTEGER,
	"place_id"	INTEGER,
	PRIMARY KEY("place_id","service_id"),
	FOREIGN KEY("service_id") REFERENCES "services"("service_id") ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY("place_id") REFERENCES "place"("place_id") ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE "receive_services" (
	"NFC_id"	INTEGER,
	"service_id"	INTEGER,
	"charge_time"	TEXT,
	PRIMARY KEY("NFC_id","service_id","charge_time"),
	FOREIGN KEY("service_id") REFERENCES "services"("service_id") ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY("NFC_id") REFERENCES "customer"("NFC_id") ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY("charge_time") REFERENCES "service_charge"("charge_time")
)

CREATE TABLE "service_charge" (
	"service_id"	INTEGER,
	"charge_time"	INTEGER,
	"charge_description"	TEXT COLLATE UTF16CI,
	"cost"	INTEGER,
	PRIMARY KEY("service_id","charge_time"),
	FOREIGN KEY("service_id") REFERENCES "services"("service_id") ON DELETE NO ACTION ON UPDATE NO ACTION
)

CREATE TABLE "services" (
	"service_id"	INTEGER,
	"service_description"	TEXT NOT NULL UNIQUE,
	"service_type"	TEXT NOT NULL CHECK("service_type" IN ('no subscription', 'subscription')),
	PRIMARY KEY("service_id")
)

CREATE TABLE "subscribes" (
	"NFC_id"	INTEGER,
	"service_id"	INTEGER,
	"time_of_sub"	TEXT,
	PRIMARY KEY("NFC_id","service_id") ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY("NFC_id") REFERENCES "customer"("NFC_id") ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE TABLE "visit" (
	"NFC_id"	INTEGER,
	"place_id"	INTEGER,
	"entry_time"	TEXT,
	"exit_time"	TEXT NOT NULL,
	PRIMARY KEY("NFC_id","place_id","entry_time"),
	FOREIGN KEY("place_id") REFERENCES "place"("place_id") ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY("NFC_id") REFERENCES "customer"("NFC_id") ON DELETE CASCADE ON UPDATE CASCADE
)




CREATE TRIGGER foo  AFTER INSERT ON subscribes
BEGIN

INSERT INTO access (NFC_id,place_id,open_time,close_time)
SELECT NEW.NFC_id, provided_at.place_id, '8:00','17:00'
FROM provided_at
WHERE provided_at.service_id = NEW.service_id;
END;

CREATE TRIGGER foo2  AFTER DELETE ON subscribes
BEGIN
DELETE FROM access
WHERE place_id  in
(select access.place_id
from provided_at,access
where provided_at.place_id = access.place_id
and provided_at.service_id = OLD.service_id
and access.NFC_id = OLD.NFC_id
)
and NFC_id in
(select access.NFC_id
from provided_at,access
where provided_at.place_id = access.place_id
and provided_at.service_id = OLD.service_id
and access.NFC_id = OLD.NFC_id
);
END
