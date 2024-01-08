import os
import logging
import csv

from airflow import DAG
from datetime import timedelta, datetime
from airflow.operators.dummy import DummyOperator
from airflow.hooks.postgres_hook import PostgresHook
from airflow.contrib.hooks.gcs_hook import GoogleCloudStorageHook 
from airflow.operators.python_operator import PythonOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.operators.gcs import GCSListObjectsOperator
from airflow.models import Variable
from io import BytesIO
 
PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
BUCKET = "school_data_lake_data-warehousing-proj"
GOOGLE_CONN_ID = "google_cloud_default"
STAGING_DATASET = "staging_school"
tables = ['course', 'country', 'department']



default_args = {
    "email" : ["franklinmutwiri41@gmail.com"],
    "email_on_failure" :True,
    "email_on_retry" : True,
    "email_on_success " : True,
    "retries" : 2,
    "retry_delay" : timedelta(minutes=0.5),
    "depends_on_past" : True,
    "wait_for_downstream" : True
}



def Postgres_To_GCS_Bucket(table, BUCKET, last_execution_date=None, **kwargs ):

    pg_hook = PostgresHook.get_hook("postgres_docker_conn")
    chunk_size = 10 
    
    
    offset = 0
    while True:

        # INCREMENTAL LOAD
        if last_execution_date:
            query = f"SELECT * FROM {table}  where create_dtm   >  '{last_execution_date}'   OR updated_dtm >  '{last_execution_date}' LIMIT {chunk_size} OFFSET {offset} ;"

        # FULL LOAD
        else: 
            query = f"SELECT * FROM {table} LIMIT {chunk_size} OFFSET {offset} "
        
        data = pg_hook.get_pandas_df(query)

        gcs_hook = GoogleCloudStorageHook(GOOGLE_CONN_ID)
        gcs_path = f'data/{table}.parquet'


        if data.empty:
            break
        else:
             # delete file first before uploading a new one
            try:
                gcs_hook.delete(bucket_name=BUCKET, object_name=gcs_path)
            except:
                pass

            

        # Convert DataFrame to Parquet format
            parquet_buffer = BytesIO()
            data.to_parquet(parquet_buffer, index=False)

            gcs_hook.upload( bucket_name=BUCKET, object_name=gcs_path, data=parquet_buffer.getvalue(),  mime_type='application/octet-stream')

            offset += chunk_size

            # Store the current execution date as the last execution date
            Variable.set(f'last_execution_date_{table}', datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'))


def get_last_execution_date(table):
    return Variable.get(f"last_execution_date_{table}", default_var=None)


def generate_files(**kwargs):
    

    gcs_list_task = GCSListObjectsOperator(
        
        task_id='list_parquet_files',
        bucket=BUCKET,
        prefix='data/',
        delimiter='.parquet',
        provide_context=True
    )
  
    parquet_files = gcs_list_task.execute(context=kwargs)
    
    # Push only the list of parquet files to XCom
    parquet_files = gcs_list_task.get_result()

    print("return obj")
    print(gcs_list_task)

    return parquet_files




with DAG(
    dag_id ="ingest_from_postgres_to_GCS_bucket",
    description='Historical and incremental load data from PostgreSQL to GCS bucket',
    default_args=default_args,
    schedule_interval="@daily",
    start_date= datetime(2024,1,5),
    max_active_runs=3,  # The maximum number of active DAG runs allowed for the DAG
    max_active_tasks = 2 , # The total number of tasks that can run at the same time for a given DAG run.
    catchup = True

)as dag:
    

    # Dummy start task
    start_task = DummyOperator(
        task_id='start',
        dag=dag,
    )

    # Dummy end task
    end_task = DummyOperator(
        task_id='end',
        dag=dag,    
    )

    for table in tables:
        postgresToGCSBucket = PythonOperator(
            task_id=f"copy_{table}_Postgres_To_GCS",
            python_callable=Postgres_To_GCS_Bucket,
            # provide_context=True,
            op_args = [table, BUCKET, get_last_execution_date(table) ],
            dag=dag
        )

    
    generate_files_task  = PythonOperator(
        task_id = "generate_files",
        python_callable = generate_files,
        provide_context = True,
        dag=dag

    )




    # for table in tables:
    #     table_name = f'STG_{table.upper()}'
    #     print(table_name)
    #     load_dataset_to_gcs = GCSToBigQueryOperator(   
    #         task_id = f"{table}_load_dataset_to_bq",
    #         bucket = BUCKET,
    #         source_objects = [f"data/{table}.parquet"],
    #         destination_project_dataset_table =  f'data-warehousing-proj.staging_school.{table_name}',
    #         write_disposition='WRITE_TRUNCATE',
    #         create_disposition='CREATE_NEVER',
    #         source_format = 'parquet',
    #         allow_quoted_newlines = 'true',
    #         skip_leading_rows = 1,
    #     )

start_task >> postgresToGCSBucket >>generate_files_task >>  end_task
