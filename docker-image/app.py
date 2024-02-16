from flask import Flask, render_template
from kubernetes import client, config
import psycopg2
import os

POSTGRES_USER = os.environ['POSTGRES_USER']
POSTGRES_PASSWORD = os.environ['POSTGRES_PASSWORD']
POSTGRES_HOST = os.environ['POSTGRES_HOST']

app = Flask(__name__)

db_config = {
    'dbname': 'postgres',
    'user': POSTGRES_USER,
    'password': POSTGRES_PASSWORD,
    'host': POSTGRES_HOST,
    'port': '5432',
}

def get_pod_info():
    config.load_incluster_config()
    v1 = client.CoreV1Api()

    pod_info = []
    pods = v1.list_pod_for_all_namespaces(watch=False).items

    for pod in pods:
        pod_name = pod.metadata.name
        pod_ip = pod.status.pod_ip
        containers = pod.spec.containers

        for container in containers:
            container_name = container.name
            container_port = container.ports[0].container_port if container.ports else None

            pod_info.append({
                'pod_name': pod_name,
                'pod_ip': pod_ip,
                'container_name': container_name,
                'container_port': container_port
            })

    return pod_info

def create_database():
    connection = psycopg2.connect(**db_config)
    connection.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    cursor = connection.cursor()
    connection.autocommit = True

    cursor.execute("SELECT 1 FROM pg_database WHERE datname = 'pod_info';")
    db_exists = cursor.fetchone()

    if not db_exists:
        cursor.execute("CREATE DATABASE pod_info;")
        cursor.execute("GRANT ALL PRIVILEGES ON DATABASE pod_info TO {}".format(POSTGRES_USER))

    cursor.close()
    connection.close()

def create_table():
    db_config['dbname'] = 'pod_info'

    connection = psycopg2.connect(**db_config)
    cursor = connection.cursor()    

    create_table_query = """    
        CREATE TABLE IF NOT EXISTS pod_info (
            pod_name varchar,
            pod_ip varchar,
            container_name varchar,
            container_port integer
        );
    """

    cursor.execute(create_table_query)

    connection.commit()
    cursor.close()
    connection.close()

def insert_into_postgres(pod_info):
    connection = psycopg2.connect(**db_config)
    cursor = connection.cursor()

    for info in pod_info:
        cursor.execute("""
            INSERT INTO pod_info (pod_name, pod_ip, container_name, container_port)
            VALUES (%s, %s, %s, %s)
        """, (info['pod_name'], info['pod_ip'], info['container_name'], info['container_port']))

    connection.commit()
    cursor.close()
    connection.close()

@app.route('/')
def index():
    pod_info = get_pod_info()
    insert_into_postgres(pod_info)

    connection = psycopg2.connect(**db_config)
    cursor = connection.cursor()

    cursor.execute("SELECT * FROM pod_info")
    rows = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('index.html', pod_info=rows)

if __name__ == '__main__':
    create_database()
    create_table()
    app.run(debug=True, host='0.0.0.0')