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


 
PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
BUCKET = "school_data_lake_data-warehousing-proj"
GOOGLE_CONN_ID = "google_cloud_default"
STAGING_DATASET = "staging_school"

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

def Postgres_To_GCS1():
    print("Current working directory:", os.getcwd())
    for table in ['course', 'country', 'department']:
        gcs_hook = GoogleCloudStorageHook(GOOGLE_CONN_ID)
        pg_hook = PostgresHook.get_hook("postgres_docker_conn")
        conn = pg_hook.get_conn()
        cursor = conn.cursor()
        cursor.execute("select * from " + table)
        result = cursor.fetchall()
        with open(table +'.csv', 'w') as fp:
            a = csv.writer(fp, quoting = csv.QUOTE_MINIMAL, delimiter = ',')
            a.writerow([i[0] for i in cursor.description])
            a.writerows(result)
        logging.info("Uploading to bucket, " + table + ".csv")
        gcs_hook.upload(bucket_name=BUCKET, object_name=table + ".csv", filename=table + ".csv")



with DAG(
    dag_id ="ingest_to_gcs_to_bq",
    description='Incrementally load data from PostgreSQL to GCS bucket',
    default_args=default_args,
    schedule_interval="@daily",
    start_date= datetime(2023,11,27),
    max_active_runs=3,  # The maximum number of active DAG runs allowed for the DAG
    max_active_tasks = 3 , # The total number of tasks that can run at the same time for a given DAG run.
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

    postgresToGCS1 = PythonOperator(
    task_id="PostgresToGCS1",
    python_callable=Postgres_To_GCS1,
    )

    for csv_file in ['course.csv', 'country.csv', 'department.csv']:
        table_name = 'STG_'+str((csv_file.split(".csv")[0]).upper())
        print(table_name)
        load_dataset_to_gcs = GCSToBigQueryOperator(
            
            task_id = str((csv_file.split(".csv")[0]))+'_load_dataset_to_bq',
            bucket = BUCKET,
            source_objects = [csv_file],
            # destination_project_dataset_table = f'{PROJECT_ID}.{STAGING_DATASET}.{table_name}',
            destination_project_dataset_table =  f'data-warehousing-proj.staging_school.{table_name}',
            write_disposition='WRITE_TRUNCATE',
            create_disposition='CREATE_NEVER',
            source_format = 'csv',
            allow_quoted_newlines = 'true',
            skip_leading_rows = 1,
         
        )

  
start_task >> postgresToGCS1 >> load_dataset_to_gcs >> end_task