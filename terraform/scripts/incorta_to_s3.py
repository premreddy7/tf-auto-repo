import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext,DynamicFrame
from awsglue.job import Job
from pyspark.sql.functions import *
import time
import datetime
import re

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "incorta_postgresql_crawler_db", table_name = "hbi_ebs_ebs_ops_data_analytics_ops_da_mv", transformation_ctx = "datasource0")

applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("vendor_name", "string", "vendor_name", "string"), ("invoice_source", "string", "invoice_source", "string"), ("tas_canc_year", "string", "tas_canc_year", "string"), ("award_to_number", "string", "award_to_number", "string"), ("tas", "string", "tas", "string"), ("additional_info", "string", "additional_info", "string"), ("transaction_number", "string", "transaction_number", "string"), ("period_num", "long", "period_num", "long"), ("tas_end_year", "long", "tas_end_year", "long"), ("period_name", "string", "period_name", "string"), ("invoice_date", "timestamp", "invoice_date", "timestamp"), ("bfy", "string", "bfy", "string"), ("s_ns", "string", "s_ns", "string"), ("project_owner_code", "string", "project_owner_code", "string"), ("clin_description", "string", "clin_description", "string"), ("supplier_number", "string", "supplier_number", "string"), ("ipp_invoice_flag", "string", "ipp_invoice_flag", "string"), ("project", "string", "project", "string"), ("period_year", "long", "period_year", "long"), ("mod_number", "string", "mod_number", "string"), ("project_org_code", "string", "project_org_code", "string"), ("pop_end_date", "string", "pop_end_date", "string"), ("release_year", "string", "release_year", "string"), ("invoice_paid_status", "string", "invoice_paid_status", "string"), ("integration_id", "string", "integration_id", "string"), ("contract_type", "string", "contract_type", "string"), ("can", "string", "can", "string"), ("po_number", "string", "po_number", "string"), ("expiration_date", "timestamp", "expiration_date", "timestamp"), ("recon_flag", "string", "recon_flag", "string"), ("payment_amount", "double", "payment_amount", "double"), ("last_updated_date_time", "timestamp", "last_updated_date_time", "timestamp"),("admincontrol", "string", "admincontrol", "string"), ("document_number", "string", "document_number", "string"), ("invoice_received_date", "timestamp", "invoice_received_date", "timestamp"), ("cancellation_date", "timestamp", "cancellation_date", "timestamp"), ("award_date", "string", "award_date", "string"), ("contract_officer", "string", "contract_officer", "string"), ("contracting_officer_representative", "string", "contracting_officer_representative", "string"), ("clin", "string", "clin", "string"), ("oc", "string", "oc", "string"), ("payment_terms", "string", "payment_terms", "string"), ("pop_start_date", "string", "pop_start_date", "string"), ("payment_sch_number", "string", "payment_sch_number", "string"), ("unexpended_amount", "double", "unexpended_amount", "double"), ("fund_value", "string", "fund_value", "string"), ("transaction_date", "date", "transaction_date", "date"), ("funding_source", "string", "funding_source", "string"), ("invoice_number", "string", "invoice_number", "string"), ("transaction_type", "string", "transaction_type", "string"), ("vendor_site_code", "string", "vendor_site_code", "string"), ("bap", "string", "bap", "string"), ("sent_to_ipp_flag", "string", "sent_to_ipp_flag", "string"), ("contract_specialist", "string", "contract_specialist", "string"), ("obligation_amount", "double", "obligation_amount", "double"), ("invoice_amount", "double", "invoice_amount", "double"), ("option_year", "string", "option_year", "string"), ("requisition_number_acn", "string", "requisition_number_acn", "string")], transformation_ctx = "applymapping1")

resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_struct", transformation_ctx = "resolvechoice2")

dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")

DataSource1 = glueContext.create_dynamic_frame.from_options(format_options = {"jsonPath":"","multiline":False}, connection_type = "s3", format = "json", connection_options = {"paths": ["s3://ospr-coin-dev/stored_date_value/"], "recurse":True}, transformation_ctx = "DataSource1")

datedf = DataSource1.toDF()
list = datedf.collect()
stored_date = list[0]["stored_date"]
print(type(stored_date))
print(stored_date)

from pyspark.sql import functions as F
from pyspark.sql.types import TimestampType
from pyspark.sql import SparkSession

df = dropnullfields3.toDF().where(F.col("last_updated_date_time")>=F.date_add((F.to_date(F.lit(stored_date)).cast(TimestampType())),1))
count = df.count()
print(count)

time_filter4 = DynamicFrame.fromDF(df, glue_ctx=glueContext, name="df")

datasink4 = glueContext.write_dynamic_frame.from_options(frame = time_filter4, connection_type = "s3", connection_options = {"path": "s3://ospr-coin-dev/incorta-raw-data"}, format = "parquet", transformation_ctx = "datasink4")

import boto3
from datetime import date

bucketname = 'ospr-coin-dev'

## move files to archive folder

s3 = boto3.resource('s3')
raw_data = s3.Bucket(bucketname)
source = "stored_date_value"
target = "Archive/stored_date/"+str(date.today())

for obj in raw_data.objects.filter(Prefix=source):
    source_filename = (obj.key).split('/')[-1]
    copy_source = {
        'Bucket': bucketname,
        'Key': obj.key
    }
    target_filename = "{}/{}".format(target, source_filename)
    s3.meta.client.copy(copy_source, bucketname, target_filename)
    # Uncomment the line below if you wish the delete the original source file
    s3.Object(bucketname,obj.key).delete()
   
job.commit()
