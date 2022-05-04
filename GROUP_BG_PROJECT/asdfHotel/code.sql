********************************************************************************
                                      7
********************************************************************************

SELECT receive_services.NFC_id, services.service_description,receive_services.charge_time,service_charge.cost
FROM receive_services, service_charge,services
WHERE receive_services.service_id = service_charge.service_id
AND receive_services.charge_time = service_charge.charge_time
AND services.service_id = service_charge.service_id
AND services.service_id = 1
AND strftime('%Y',service_charge.charge_time) = strftime('%Y','2021-06-15')
AND strftime('%m',service_charge.charge_time) = strftime('%m','2021-06-15')
AND strftime('%d',service_charge.charge_time) = strftime('%d','2021-06-15')
AND service_charge.cost <= 50


********************************************************************************
                                      8
********************************************************************************

CREATE VIEW sales_category AS
SELECT DISTINCT s.service_description, SUM(sc.cost)
FROM services AS s, service_charge AS sc
WHERE s.service_id=sc.service_id
GROUP BY  s.service_description

CREATE VIEW customer_data AS
SELECT DISTINCT  customer.*,customer_phone.phone,customer_email.email
FROM customer
LEFT JOIN customer_phone
ON customer.NFC_id = customer_phone.NFC_id
LEFT JOIN customer_email
ON  customer.NFC_id = customer_email.NFC_id


*** Results of DISTINCT queries are not updateable (page 125 silberschatz)


********************************************************************************
                                      9
********************************************************************************

SELECT p.place_name, v.entry_time, v.exit_time, v.NFC_id
FROM place AS p
INNER JOIN visit AS v
ON p.place_id=v.place_id
WHERE v.NFC_id = 3

********************************************************************************
                                      10
********************************************************************************

SELECT  customer.NFC_id, customer.first_name, customer.last_name
FROM customer
NATURAL JOIN(
SELECT DISTINCT v2.NFC_id
FROM visit as v1, visit as v2
WHERE v1.place_id = v2.place_id
AND strftime('%Y',v1.entry_time) = strftime('%Y',v2.entry_time)
AND strftime('%m',v1.entry_time) = strftime('%m',v2.entry_time)
AND strftime('%H',v2.entry_time) BETWEEN strftime('%H',v1.entry_time) AND strftime('%H',v1.exit_time,"+1 hours")
AND v1.NFC_id = 3 AND v1.NFC_id <> v2.NFC_id
)



********************************************************************************
                                      11
********************************************************************************

********   Question 11(a)   *******

WITH age_group1(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year BETWEEN 2021-40 AND 2021-20)

SELECT place_name, place_position, COUNT(place_name) AS total_visits
FROM visit, place, age_group1
WHERE visit.place_id = place.place_id AND age_group1.val1 = visit.NFC_id
GROUP BY place_name, place_position
ORDER BY COUNT(place_name) DESC
LIMIT 10

WITH age_group2(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year BETWEEN 2021-60 AND 2021-41)

SELECT place_name, place_position, COUNT(place_name) AS total_visits
FROM visit, place, age_group2
WHERE visit.place_id = place.place_id AND age_group2.val1 = visit.NFC_id
GROUP BY place_name
ORDER BY COUNT(place_name) DESC
LIMIT 10

WITH age_group3(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year >= 2021-61)

SELECT place_name, place_position, COUNT(place_name) AS total_visits
FROM visit, place, age_group3
WHERE visit.place_id = place.place_id AND age_group3.val1 = visit.NFC_id
GROUP BY place_name
ORDER BY COUNT(place_name) DESC
LIMIT 10


********   Question 11(b)   *******

WITH age_group1(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year BETWEEN 2021-40 AND 2021-20)

SELECT service_description, COUNT(service_description) AS total_uses
FROM receive_services, services, age_group1
WHERE receive_services.service_id = services.service_id AND age_group1.val1 = receive_services.NFC_id
GROUP BY service_description
ORDER BY COUNT(service_description) DESC

WITH age_group2(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year BETWEEN 2021-60 AND 2021-41)

SELECT service_description, COUNT(service_description) AS total_uses
FROM receive_services, services, age_group2
WHERE receive_services.service_id = services.service_id AND age_group2.val1 = receive_services.NFC_id
GROUP BY service_description
ORDER BY COUNT(service_description) DESC

WITH age_group3(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year <= 2021-61)

SELECT service_description, COUNT(service_description) AS total_uses
FROM receive_services, services, age_group3
WHERE receive_services.service_id = services.service_id AND age_group3.val1 = receive_services.NFC_id
GROUP BY service_description
ORDER BY COUNT(service_description) DESC


 ********   Question 11(c)   *******

 WITH age_group1(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year BETWEEN 2021-40 AND 2021-20),
helpy(val2, val3) AS
	(SELECT DISTINCT NFC_id, service_id
	FROM receive_services)

SELECT service_description, COUNT(service_description) as total_choices
FROM services, helpy, age_group1
WHERE age_group1.val1 = helpy.val2 AND helpy.val3 = services.service_id
GROUP BY service_description
ORDER BY COUNT(service_description) DESC

WITH age_group2(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year BETWEEN 2021-60 AND 2021-41),
helpy(val2, val3) AS
	(SELECT DISTINCT NFC_id, service_id
	FROM receive_services)

SELECT service_description, COUNT(service_description) as total_choices
FROM services, helpy, age_group2
WHERE age_group2.val1 = helpy.val2 AND helpy.val3 = services.service_id
GROUP BY service_description
ORDER BY COUNT(service_description) DESC

WITH age_group3(val1) AS
	(SELECT NFC_id
	FROM customer
	WHERE birth_year <= 2021-61),
helpy(val2, val3) AS
	(SELECT DISTINCT NFC_id, service_id
	FROM receive_services)

SELECT service_description, COUNT(service_description) as total_choices
FROM services, helpy, age_group3
WHERE age_group3.val1 = helpy.val2 AND helpy.val3 = services.service_id
GROUP BY service_description
ORDER BY COUNT(service_description) DESC


















**************************************INDICES***********************************

CREATE INDEX charge_time_idx ON service_charge(charge_time)
CREATE INDEX cost_idx ON service_charge(cost)
CREATE INDEX entry_time_idx ON visit(entry_time)
