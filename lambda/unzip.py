from __future__ import print_function

import urllib
import zipfile
import boto3
import io
import mimetypes
import magic

print('Loading function')

s3 = boto3.client('s3')
bucket = 'my-bucket'

def lambda_handler(event, context):
    key = 'website.zip'
    try:
        obj = s3.get_object(Bucket=bucket, Key=key)
        mime = magic.Magic(mime=True)
        putObjects = []
        with io.BytesIO(obj["Body"].read()) as tf:
            # rewind the file
            tf.seek(0)

            # Read the file as a zipfile and process the members
            with zipfile.ZipFile(tf, mode='r') as zipf:
                for file in zipf.infolist():
                    fileName = file.filename
                    contentType = mimetypes.guess_type(fileName)[0]
                    if contentType == 'None':
                        contentType = mime.from_buffer(zipf.read(file))
                    putFile = s3.put_object(Bucket=bucket, Key=fileName, Body=zipf.read(file), ContentType=contentType)
                    putObjects.append(putFile)
                    print(putFile)


        # Delete zip file after unzip
        if len(putObjects) > 0:
            deletedObj = s3.delete_object(Bucket=bucket, Key=key)
            print('deleted file:')
            print(deletedObj)

    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e