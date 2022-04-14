import boto3
from datetime import date

bucketname = 'ospr-coin-dev'

## move files to archive folder

s3 = boto3.resource('s3')
raw_data = s3.Bucket(bucketname)
source = "incorta-raw-data"
target = "Archive/"+str(date.today())

for obj in raw_data.objects.filter(Prefix=source):
    source_filename = (obj.key).split('/')[-1]
    copy_source = {
        'Bucket': bucketname,
        'Key': obj.key
    }
    target_filename = "{}/{}".format(target, source_filename)
    s3.meta.client.copy(copy_source, bucketname, target_filename)
    # Uncomment the line below if you wish the delete the original source file
    s3.Object(bucketname, obj.key).delete()
