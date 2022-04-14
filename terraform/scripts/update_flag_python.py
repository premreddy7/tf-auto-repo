import pg

#connect to redshift database
def get_connection(host):
    rs_conn_string = "host=%s port=%s dbname=%s user=%s password=%s" % (
        host, '5439', 'coinrsdb', 'incorta_usr', 'Inc0rt@2021')

    rs_conn = pg.connect(dbname=rs_conn_string)
    rs = rs_conn.query("set statement_timeout = 1200000")
   
    return rs_conn

#to test sql update query in redshift
def query(con):
    ##statement = "update incorta_schema.ofm_incorta SET latest_flag = 'N' where int_key in (select int_key from incorta_schema.ofm_incorta where date(created_date) = date(current_timestamp) ) and date(created_date) <> (select max(date(created_date)) from incorta_schema.ofm_incorta);"
    statement = "update incorta_schema.ofm_incorta SET latest_flag = 'N' where int_key in (select int_key from incorta_schema.ofm_incorta where date(created_date) = (select max(date(created_date)) from incorta_schema.ofm_incorta)) and date(created_date) <> (select max(date(created_date)) from incorta_schema.ofm_incorta);"

    res = con.query(statement)
   
    return res
   
con1 = get_connection('ospr-coin-rs-cluster.cuauolstpliy.us-gov-west-1.redshift.amazonaws.com')
res = query(con1)

