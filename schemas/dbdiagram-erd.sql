CREATE TABLE "city" (
  "city_id" int PRIMARY KEY,
  "city_name" varchar(15),
  "population" bigint,
  "estimated_rent" float,
  "city_rank" int
);

CREATE TABLE "customers" (
  "customer_id" int PRIMARY KEY,
  "customer_name" varchar(25),
  "city_id" int
);

CREATE TABLE "products" (
  "product_id" int PRIMARY KEY,
  "product_name" varchar(35),
  "Price" float
);

CREATE TABLE "sales" (
  "sale_id" int PRIMARY KEY,
  "sale_date" date,
  "product_id" int,
  "customer_id" int,
  "total" float,
  "rating" int
);

ALTER TABLE "customers" ADD FOREIGN KEY ("city_id") REFERENCES "city" ("city_id");

ALTER TABLE "sales" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");

ALTER TABLE "sales" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");
