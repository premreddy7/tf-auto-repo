import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

def sparkSqlQuery(glueContext, query, mapping, transformation_ctx) -> DynamicFrame:
    for alias, frame in mapping.items():
        frame.toDF().createOrReplaceTempView(alias)
    result = spark.sql(query)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)

SqlQuery0 = '''
select max(date(last_updated_date_time)) as stored_date from myDataSource

'''

## @params: [TempDir, JOB_NAME]
args = getResolvedOptions(sys.argv, ['TempDir','JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "ospr_redshift", redshift_tmp_dir = TempDir, table_name = "coinrsdb_incorta_schema_ofm_incorta", transformation_ctx = "DataSource0"]
## @return: DataSource0
## @inputs: []
DataSource0 = glueContext.create_dynamic_frame.from_catalog(database = "ospr_redshift", redshift_tmp_dir = args["TempDir"], table_name = "coinrsdb_incorta_schema_ofm_incorta", transformation_ctx = "DataSource0")
## @type: SqlCode
## @args: [sqlAliases = {"myDataSource": DataSource0}, sqlName = SqlQuery0, transformation_ctx = "Transform0"]
## @return: Transform0
## @inputs: [dfc = DataSource0]
Transform0 = sparkSqlQuery(glueContext, query = SqlQuery0, mapping = {"myDataSource": DataSource0}, transformation_ctx = "Transform0")
## @type: DataSink
## @args: [connection_type = "s3", catalog_database_name = "s3_incorta", format = "json", connection_options = {"path": "s3://ospr-coin-dev/stored_date_value/", "partitionKeys": [], "enableUpdateCatalog":true, "updateBehavior":"UPDATE_IN_DATABASE"}, catalog_table_name = "stored_date_value", transformation_ctx = "DataSink0"]
## @return: DataSink0
## @inputs: [frame = Transform0]
DataSink0 = glueContext.getSink(path = "s3://ospr-coin-dev/stored_date_value/", connection_type = "s3", updateBehavior = "UPDATE_IN_DATABASE", partitionKeys = [], enableUpdateCatalog = True, transformation_ctx = "DataSink0")
DataSink0.setCatalogInfo(catalogDatabase = "s3_incorta",catalogTableName = "stored_date_value")
DataSink0.setFormat("json")
DataSink0.writeFrame(Transform0)

job.commit()

