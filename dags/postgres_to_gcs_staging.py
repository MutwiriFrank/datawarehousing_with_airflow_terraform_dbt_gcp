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

        logging.info("Uploading to bucket, " + table )

        if data.empty:
            break

        # Convert DataFrame to Parquet format
        parquet_buffer = BytesIO()
        data.to_parquet(parquet_buffer, index=False)

        date = kwargs['ds_nodash']
      

        gcs_hook = GoogleCloudStorageHook(GOOGLE_CONN_ID)
        gcs_path = f'data/{table}-{date}.parquet'

        #gcs
        gcs_hook.upload( bucket_name=BUCKET, object_name=gcs_path, data=parquet_buffer.getvalue(),  mime_type='application/octet-stream')

        offset += chunk_size

        # Store the current execution date as the last execution date
        Variable.set(f'last_execution_date_{table}', datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'))


def get_last_execution_date(table):
    return Variable.get(f"last_execution_date_{table}", default_var=None)


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
            op_args = [table, BUCKET, get_last_execution_date(table) ]
        )

    # for csv_file in ['course.csv', 'country.csv', 'department.csv']:
    #     table_name = 'STG_'+str((csv_file.split(".csv")[0]).upper())
    #     print(table_name)
    #     load_dataset_to_gcs = GCSToBigQueryOperator(
            
    #         task_id = str((csv_file.split(".csv")[0]))+'_load_dataset_to_bq',
    #         bucket = BUCKET,
    #         source_objects = [csv_file],
    #         # destination_project_dataset_table = f'{PROJECT_ID}.{STAGING_DATASET}.{table_name}',
    #         destination_project_dataset_table =  f'data-warehousing-proj.staging_school.{table_name}',
    #         write_disposition='WRITE_TRUNCATE',
    #         create_disposition='CREATE_NEVER',
    #         source_format = 'csv',
    #         allow_quoted_newlines = 'true',
    #         skip_leading_rows = 1,
         
    #     )

  
# start_task >> postgresToGCSBucket >> load_dataset_to_gcs >> end_task
start_task >> postgresToGCSBucket >>  end_task