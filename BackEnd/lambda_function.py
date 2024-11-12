# import boto3
# import pymysql
# import os

# # S3 and RDS clients
# s3_client = boto3.client('s3')
# rds_host = os.environ['DB_ARN']
# db_username = os.environ['DB_USER']
# db_password = os.environ['DB_PASSWORD']
# db_name = "your_database_name"

# # Connect to Aurora (MySQL)
# def connect_to_aurora():
#     try:
#         connection = pymysql.connect(
#             host=rds_host,
#             user=db_username,
#             password=db_password,
#             db=db_name,
#             connect_timeout=5
#         )
#         return connection
#     except Exception as e:
#         print(f"Error connecting to Aurora: {e}")
#         return None

# # Lambda function handler
# def lambda_handler(event, context):
#     # Get data from S3
#     bucket_name = os.environ['S3_BUCKET_NAME']
#     file_key = "path/to/your/file.txt"  # Adjust as needed
#     try:
#         s3_response = s3_client.get_object(Bucket=bucket_name, Key=file_key)
#         file_content = s3_response['Body'].read().decode('utf-8')
#         print(f"File content from S3: {file_content}")
#     except Exception as e:
#         print(f"Error reading file from S3: {e}")
    
#     # Interact with Aurora database
#     connection = connect_to_aurora()
#     if connection:
#         try:
#             with connection.cursor() as cursor:
#                 cursor.execute("SELECT * FROM your_table LIMIT 10;")
#                 results = cursor.fetchall()
#                 for row in results:
#                     print(f"Row: {row}")
#             connection.commit()
#         except Exception as e:
#             print(f"Error interacting with Aurora: {e}")
#         finally:
#             connection.close()

#     return {
#         'statusCode': 200,
#         'body': 'Lambda executed successfully!'
#     }



import json
def function_one(event, context):
    response_body = {
        "message": "Success",
        "data": "Your data goes here"
    }

    # Return a properly formatted response
    return {
        "statusCode": 200,
        "body": json.dumps(response_body),
        "headers": {
            "Content-Type": "application/json"
        }
    }
def function_two(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('This is Function 2')
    }

def lambda_handler(event, context):
    path = event['path']  # Get the path from the incoming request
    print(path)
    # Route to the correct function based on the path
    if path == "/function1":
        return function_one(event, context)
    elif path == "/function2":
        return function_two(event, context)
    else:
        return {
            'statusCode': 404,
            'body': json.dumps('Not Found')
        }
