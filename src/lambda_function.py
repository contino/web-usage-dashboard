import boto3
from requests_aws4auth import AWS4Auth
from es_manager import EsDataLoader
from mappings import web_logs
import os

region = os.environ['REGION']
host = os.environ['ES_HOST']
index = os.environ['ES_INDEX']
index_type = os.environ['ES_INDEX_TYPE']
aws_service = os.environ['AWS_SERVICE']

credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, aws_service, session_token=credentials.token)
s3 = boto3.client('s3')


# Lambda execution starts here
def lambda_handler(event, context):
    for record in event['Records']:
        # Get the bucket name and key for the new file
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        # Get, read, and split the file into lines
        print("Attempting to read logs from: s3://" + bucket + "/" + key)
        obj = s3.get_object(Bucket=bucket, Key=key)
        body = obj['Body'].read()
        data = body.splitlines()

        # Load logs to ElasticSearch cluster
        es_dataloader = EsDataLoader(region, host, aws_service, index, index_type, awsauth)
        es_dataloader.create_index(index_name=index, mapping=web_logs)
        es_dataloader.populate_index(data=data)
