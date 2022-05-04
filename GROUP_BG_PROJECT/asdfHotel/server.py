import os
from flask import Flask,render_template,request
import sqlite3

app = Flask(__name__)
app.config["DEBUG"] = True


def shutdown_server():
    func = request.environ.get("werkzeug.server.shutdown")
    if func is None:
        raise RuntimeError("Not running with the Werkzeug Server")
    func()

@app.route("/")
def homepage():
    return render_template("home.html")

@app.route("/search")
def search():
    return render_template("index.html")

@app.route("/search_result", methods = ["GET", "POST"])
def search_result():
    my_data = request.get_json(force = True)

    service = (
        " and services.service_id = {}".format(my_data.get("service"))
        if (my_data.get("service") != "")
        else ""
    )

    charge_time = (
        """ and strftime('%Y',service_charge.charge_time) = strftime('%Y','{0}') and strftime('%m',service_charge.charge_time) = strftime('%m','{0}')
            and strftime('%d',service_charge.charge_time) = strftime('%d','{0}')""".format(my_data.get("charge_time"))
            if (my_data.get("charge_time") != "")
            else ""
    )

    cost = (
        " and service_charge.cost <= {}".format(my_data.get("cost"))
        if (my_data.get("cost") != "")
        else ""
    )

    everything = """select receive_services.NFC_id, services.service_description,receive_services.charge_time,service_charge.cost
                    from receive_services, service_charge,services
                    where receive_services.service_id = service_charge.service_id
                    and receive_services.charge_time = service_charge.charge_time
                    and services.service_id = service_charge.service_id
                    """
    con = sqlite3.connect("HotelFinal.db") #TODO
    cur = con.cursor()
    my_query = (
        everything
        + service
        + charge_time
        + cost
        +" limit 1000"
    )
    print(my_query)
    cur.execute(my_query)
    results = cur.fetchall()
    return render_template("spcResults.html", theResults = results)

@app.route("/sales_category", methods = ["GET","POST"])
def sales_category():
    con = sqlite3.connect("HotelFinal.db") #TODO
    cur = con.cursor()
    my_query = "select * from sales_category"
    print(my_query)
    cur.execute(my_query)
    results  = cur.fetchall()
    return render_template("SalesPerCategory.html", results = results)

@app.route("/customer_data", methods = ["GET", "POST"])
def customer_data():
    con = sqlite3.connect("HotelFinal.db") # TODO
    cur = con.cursor()
    my_query = "select * from customer_data"
    print(my_query)
    cur.execute(my_query)
    results = cur.fetchall()
    return render_template("CustomerInfo.html", results = results)

@app.route("/customers")
def customers():
    return render_template("theCustomers.html")

@app.route("/customers_result", methods = ["GET", "POST"])
def customers_result():
    my_data = request.get_json(force = True)
    true_data = my_data["nfc_id"]
    con = sqlite3.connect('HotelFinal.db') ## TODO
    cur = con.cursor()

    my_query_1 = """select p.place_name, v.entry_time, v.exit_time, v.NFC_id
    from place as p
    inner join visit as v
    on p.place_id=v.place_id
    where v.NFC_id = {}""".format(true_data)
    print(my_query_1)
    cur.execute(my_query_1)
    results1 = cur.fetchall()

    my_query_2 = """select  customer.NFC_id, customer.first_name, customer.last_name
                  from customer
                  natural join(
                  select distinct v2.NFC_id
                  from visit as v1, visit as v2
                  where v1.place_id = v2.place_id
                  and strftime('%Y',v1.entry_time) = strftime('%Y',v2.entry_time)
				  and strftime('%m',v1.entry_time) = strftime('%m',v2.entry_time)
				  and strftime('%H',v2.entry_time) between strftime('%H',v1.entry_time) and strftime('%H',v1.exit_time,"+1 hours")
                  and v1.NFC_id = {} and v1.NFC_id <> v2.NFC_id
                  )
              """.format(true_data)
    print(my_query_2)
    cur.execute(my_query_2)
    results2 = cur.fetchall()
    return render_template("customers_result.html", results1 = results1, results2 = results2)

def make_dicts(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def query_db(filename, query):
    conn = sqlite3.connect(filename)
    conn.row_factory = make_dicts
    cur = conn.cursor()
    all_books = cur.execute(query).fetchall()
    return all_books

relation_a1 = query_db('HotelFinal.db', """
    WITH age_group1(val1) AS
	    (SELECT NFC_id
	    FROM customer
	    WHERE birth_year BETWEEN 2021-40 AND 2021-20)

    SELECT place_name AS place_name_1, place_position, COUNT(place_name) AS total_visits_1
    FROM visit, place, age_group1
    WHERE visit.place_id = place.place_id AND age_group1.val1 = visit.NFC_id
    GROUP BY place_name, place_position
    ORDER BY COUNT(place_name) DESC
    LIMIT 10
""")

relation_a2 = query_db('HotelFinal.db', """
    WITH age_group2(val1) AS
	    (SELECT NFC_id
	    FROM customer
	    WHERE birth_year BETWEEN 2021-60 AND 2021-41)

    SELECT place_name AS place_name_2, place_position, COUNT(place_name) AS total_visits_2
    FROM visit, place, age_group2
    WHERE visit.place_id = place.place_id AND age_group2.val1 = visit.NFC_id
    GROUP BY place_name
    ORDER BY COUNT(place_name) DESC
    LIMIT 10
""")

relation_a3 = query_db('HotelFinal.db', """
    WITH age_group3(val1) AS
        (SELECT NFC_id
        FROM customer
        WHERE birth_year >= 2021-61)

    SELECT place_name AS place_name_3, place_position, COUNT(place_name) AS total_visits_3
    FROM visit, place, age_group3
    WHERE visit.place_id = place.place_id AND age_group3.val1 = visit.NFC_id
    GROUP BY place_name
    ORDER BY COUNT(place_name) DESC
    LIMIT 10
""")

relation_b1 = query_db('HotelFinal.db', """
    WITH age_group1(val1) AS
        (SELECT NFC_id
        FROM customer
        WHERE birth_year BETWEEN 2021-40 AND 2021-20)

    SELECT service_description AS service_description_1, COUNT(service_description) AS total_uses_1
    FROM receive_services, services, age_group1
    WHERE receive_services.service_id = services.service_id AND age_group1.val1 = receive_services.NFC_id
    GROUP BY service_description
    ORDER BY COUNT(service_description) DESC
""")

relation_b2 = query_db('HotelFinal.db', """
    WITH age_group2(val1) AS
        (SELECT NFC_id
        FROM customer
        WHERE birth_year BETWEEN 2021-60 AND 2021-41)

    SELECT service_description AS service_description_2, COUNT(service_description) AS total_uses_2
    FROM receive_services, services, age_group2
    WHERE receive_services.service_id = services.service_id AND age_group2.val1 = receive_services.NFC_id
    GROUP BY service_description
    ORDER BY COUNT(service_description) DESC
""")

relation_b3 = query_db('HotelFinal.db', """
    WITH age_group3(val1) AS
        (SELECT NFC_id
        FROM customer
        WHERE birth_year <= 2021-61)

    SELECT service_description AS service_description_3, COUNT(service_description) AS total_uses_3
    FROM receive_services, services, age_group3
    WHERE receive_services.service_id = services.service_id AND age_group3.val1 = receive_services.NFC_id
    GROUP BY service_description
    ORDER BY COUNT(service_description) DESC
""")

relation_c1 = query_db('HotelFinal.db', """
    WITH age_group1(val1) AS
        (SELECT NFC_id
        FROM customer
        WHERE birth_year BETWEEN 2021-40 AND 2021-20),
    helpy(val2, val3) AS
        (SELECT DISTINCT NFC_id, service_id
        FROM receive_services)

    SELECT service_description AS sd_1, COUNT(service_description) as total_choices_1
    FROM services, helpy, age_group1
    WHERE age_group1.val1 = helpy.val2 AND helpy.val3 = services.service_id
    GROUP BY service_description
    ORDER BY COUNT(service_description) DESC
""")

relation_c2 = query_db('HotelFinal.db', """
    WITH age_group2(val1) AS
        (SELECT NFC_id
        FROM customer
        WHERE birth_year BETWEEN 2021-60 AND 2021-41),
    helpy(val2, val3) AS
        (SELECT DISTINCT NFC_id, service_id
        FROM receive_services)

    SELECT service_description AS sd_2, COUNT(service_description) as total_choices_2
    FROM services, helpy, age_group2
    WHERE age_group2.val1 = helpy.val2 AND helpy.val3 = services.service_id
    GROUP BY service_description
    ORDER BY COUNT(service_description) DESC
""")

relation_c3 = query_db('HotelFinal.db', """
    WITH age_group3(val1) AS
        (SELECT NFC_id
        FROM customer
        WHERE birth_year <= 2021-61),
    helpy(val2, val3) AS
        (SELECT DISTINCT NFC_id, service_id
        FROM receive_services)

    SELECT service_description AS sd_3, COUNT(service_description) as total_choices_3
    FROM services, helpy, age_group3
    WHERE age_group3.val1 = helpy.val2 AND helpy.val3 = services.service_id
    GROUP BY service_description
    ORDER BY COUNT(service_description) DESC
""")

def merge(l, l1, l2, l3):
    for i in range(len(l1)):
        helpy = dict()
        helpy = l1[i] | l2[i] | l3[i]
        l.append(helpy)

relation_a = list()
relation_b = list()
relation_c = list()

merge(relation_a, relation_a1, relation_a2, relation_a3)
merge(relation_b, relation_b1, relation_b2, relation_b3)
merge(relation_c, relation_c1, relation_c2, relation_c3)

@app.route('/info_per_age')
def info_per_age():
   return render_template('info_per_age.html', items1 = relation_a, items2 = relation_b, items3 = relation_c)

if __name__ == "__main__":
    app.run(host=os.getenv("IP", "0.0.0.0"), port=int(os.getenv("PORT",4217)), debug=True)
