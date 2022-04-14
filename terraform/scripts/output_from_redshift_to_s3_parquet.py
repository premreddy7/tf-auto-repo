import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job


import boto3
from datetime import date

bucketname = 'ospr-coin-dev'
s3 = boto3.resource('s3')
raw_data = s3.Bucket(bucketname)
source = "latest_record"
##target = "archive/"+str(date.today())

for obj in raw_data.objects.filter(Prefix=source):
    source_filename = (obj.key).split('/')[-1]
#    copy_source = {
#        'Bucket': bucketname,
#        'Key': obj.key
#    }
#    target_filename = "{}/{}".format(target, source_filename)
#    s3.meta.client.copy(copy_source, bucketname, target_filename)
    # Uncomment the line below if you wish the delete the original source file
    s3.Object(bucketname,obj.key).delete()
   
   
## @params: [TempDir, JOB_NAME]
args = getResolvedOptions(sys.argv, ['TempDir','JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "ospr_redshift", table_name = "coinrsdb_incorta_schema_ofm_incorta", redshift_tmp_dir = TempDir, transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "ospr_redshift", table_name = "coinrsdb_incorta_schema_ofm_incorta", redshift_tmp_dir = args["TempDir"], transformation_ctx = "datasource0")
## @type: ApplyMapping
## @args: [mapping = [("last_updated_date_time", "timestamp", "last_updated_date_time", "timestamp"), ("obligationamount", "double", "obligationamount", "double"), ("project", "string", "project", "string"), ("period_name", "string", "period_name", "string"), ("source", "string", "source", "string"), ("releaseyear", "string", "releaseyear", "string"), ("expiration_date", "timestamp", "expiration_date", "timestamp"), ("modnum", "string", "modnum", "string"), ("paymentamount", "double", "paymentamount", "double"), ("bap", "string", "bap", "string"), ("tasendyear", "int", "tasendyear", "int"), ("popenddate", "string", "popenddate", "string"), ("project_owner_code", "string", "project_owner_code", "string"), ("funding_source", "string", "funding_source", "string"), ("contracting_officer_representative", "string", "contracting_officer_representative", "string"), ("invoicenumber", "string", "invoicenumber", "string"), ("fundvalue", "string", "fundvalue", "string"), ("invoice_received_date", "timestamp", "invoice_received_date", "timestamp"), ("tas", "string", "tas", "string"), ("contract_officer", "string", "contract_officer", "string"), ("created_by", "string", "created_by", "string"), ("data_source", "string", "data_source", "string"), ("cancellation_date", "timestamp", "cancellation_date", "timestamp"), ("period_year", "int", "period_year", "int"), ("bfy", "string", "bfy", "string"), ("contracttype", "string", "contracttype", "string"), ("unexpendedamount", "double", "unexpendedamount", "double"), ("additional_info", "string", "additional_info", "string"), ("contractnumber", "string", "contractnumber", "string"), ("ponumber", "string", "ponumber", "string"), ("int_key", "string", "int_key", "string"), ("vendorname", "string", "vendorname", "string"), ("supplier_number", "string", "supplier_number", "string"), ("transactiondate", "timestamp", "transactiondate", "timestamp"), ("invpaidstatus", "string", "invpaidstatus", "string"), ("payment_terms", "string", "payment_terms", "string"), ("transactiontype", "string", "transactiontype", "string"), ("invoiceamount", "double", "invoiceamount", "double"), ("tascancelyear", "string", "tascancelyear", "string"), ("can", "string", "can", "string"), ("vendorsitecode", "string", "vendorsitecode", "string"), ("oc", "string", "oc", "string"), ("latest_flag", "string", "latest_flag", "string"), ("payment_sch_number", "string", "payment_sch_number", "string"), ("reconflag", "string", "reconflag", "string"), ("admincontrol", "string", "admincontrol", "string"), ("award_date", "string", "award_date", "string"), ("optionyear", "string", "optionyear", "string"), ("ipp_invoice_flag", "string", "ipp_invoice_flag", "string"), ("clin", "string", "clin", "string"), ("period_num", "long", "period_num", "long"), ("orgcode", "string", "orgcode", "string"), ("requisitionnumber", "string", "requisitionnumber", "string"), ("inippflag", "string", "inippflag", "string"), ("clin_description", "string", "clin_description", "string"), ("transaction_number", "string", "transaction_number", "string"), ("contract_specialist", "string", "contract_specialist", "string"), ("sns", "string", "sns", "string"), ("documentnumber", "string", "documentnumber", "string"), ("created_date", "timestamp", "created_date", "timestamp"), ("invoicedate", "timestamp", "invoicedate", "timestamp"), ("popstartdate", "string", "popstartdate", "string")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("last_updated_date_time", "timestamp", "last_updated_date_time", "timestamp"), ("obligationamount", "double", "obligationamount", "double"), ("project", "string", "project", "string"), ("period_name", "string", "period_name", "string"), ("source", "string", "source", "string"), ("releaseyear", "string", "releaseyear", "string"), ("expiration_date", "timestamp", "expiration_date", "timestamp"), ("modnum", "string", "modnum", "string"), ("paymentamount", "double", "paymentamount", "double"), ("bap", "string", "bap", "string"), ("tasendyear", "int", "tasendyear", "int"), ("popenddate", "string", "popenddate", "string"), ("project_owner_code", "string", "project_owner_code", "string"), ("funding_source", "string", "funding_source", "string"), ("contracting_officer_representative", "string", "contracting_officer_representative", "string"), ("invoicenumber", "string", "invoicenumber", "string"), ("fundvalue", "string", "fundvalue", "string"), ("invoice_received_date", "timestamp", "invoice_received_date", "timestamp"), ("tas", "string", "tas", "string"), ("contract_officer", "string", "contract_officer", "string"), ("created_by", "string", "created_by", "string"), ("data_source", "string", "data_source", "string"), ("cancellation_date", "timestamp", "cancellation_date", "timestamp"), ("period_year", "int", "period_year", "int"), ("bfy", "string", "bfy", "string"), ("contracttype", "string", "contracttype", "string"), ("unexpendedamount", "double", "unexpendedamount", "double"), ("additional_info", "string", "additional_info", "string"), ("contractnumber", "string", "contractnumber", "string"), ("ponumber", "string", "ponumber", "string"), ("int_key", "string", "int_key", "string"), ("vendorname", "string", "vendorname", "string"), ("supplier_number", "string", "supplier_number", "string"), ("transactiondate", "timestamp", "transactiondate", "timestamp"), ("invpaidstatus", "string", "invpaidstatus", "string"), ("payment_terms", "string", "payment_terms", "string"), ("transactiontype", "string", "transactiontype", "string"), ("invoiceamount", "double", "invoiceamount", "double"), ("tascancelyear", "string", "tascancelyear", "string"), ("can", "string", "can", "string"), ("vendorsitecode", "string", "vendorsitecode", "string"), ("oc", "string", "oc", "string"), ("latest_flag", "string", "latest_flag", "string"), ("payment_sch_number", "string", "payment_sch_number", "string"), ("reconflag", "string", "reconflag", "string"), ("admincontrol", "string", "admincontrol", "string"), ("award_date", "string", "award_date", "string"), ("optionyear", "string", "optionyear", "string"), ("ipp_invoice_flag", "string", "ipp_invoice_flag", "string"), ("clin", "string", "clin", "string"), ("period_num", "long", "period_num", "long"), ("orgcode", "string", "orgcode", "string"), ("requisitionnumber", "string", "requisitionnumber", "string"), ("inippflag", "string", "inippflag", "string"), ("clin_description", "string", "clin_description", "string"), ("transaction_number", "string", "transaction_number", "string"), ("contract_specialist", "string", "contract_specialist", "string"), ("sns", "string", "sns", "string"), ("documentnumber", "string", "documentnumber", "string"), ("created_date", "timestamp", "created_date", "timestamp"), ("invoicedate", "timestamp", "invoicedate", "timestamp"), ("popstartdate", "string", "popstartdate", "string")], transformation_ctx = "applymapping1")

seceltfield1 = Filter.apply(frame = applymapping1, f = lambda x: x["latest_flag"] in ["Y"], transformation_ctx = "seceltfield1")

## @type: ResolveChoice
## @args: [choice = "make_struct", transformation_ctx = "resolvechoice2"]
## @return: resolvechoice2
## @inputs: [frame = applymapping1]
resolvechoice2 = ResolveChoice.apply(frame = seceltfield1, choice = "make_struct", transformation_ctx = "resolvechoice2")
## @type: DropNullFields
## @args: [transformation_ctx = "dropnullfields3"]
## @return: dropnullfields3
## @inputs: [frame = resolvechoice2]
dropnullfields3 = DropNullFields.apply(frame = resolvechoice2, transformation_ctx = "dropnullfields3")
## @type: DataSink
## @args: [connection_type = "s3", connection_options = {"path": "s3://ospr-coin-dev/latest_record"}, format = "parquet", transformation_ctx = "datasink4"]
## @return: datasink4
## @inputs: [frame = dropnullfields3]
##datasink4 = glueContext.write_dynamic_frame.from_options(frame = dropnullfields3, connection_type = "s3", connection_options = {"path": "s3://ospr-coin-dev/latest_record"}, format = "parquet", transformation_ctx = "datasink4")
datasink4 = glueContext.getSink(path = "s3://ospr-coin-dev/latest_record/", connection_type = "s3", updateBehavior = "UPDATE_IN_DATABASE", partitionKeys = [], enableUpdateCatalog = True, transformation_ctx = "datasink4")
datasink4.setCatalogInfo(catalogDatabase = "s3_incorta",catalogTableName = "latest_record")
datasink4.setFormat("glueparquet")
datasink4.writeFrame(dropnullfields3)
job.commit()

