"""
Script à rouler si une ou plusieurs des étapes de setup des ytables et stream ksqldb ont fail lors du spinup initial
"""
import time
import os
from openfactory.kafka import KSQLDBClient

ksql_client = KSQLDBClient("http://172.17.0.2:8088")

CURRENT_DIR = os.getcwd()
SQL_FILES = (["scripts/sql/all_openfactory.sql"])


def execute(query: str) -> None:
    try:
        ksql_client.statement_query(query + ";")
        time.sleep(0.5)
    except Exception as e:
        print(f"Error executing query: {query}\n{e}")

def load_queries() -> list[str]:
    queries = []
    for filename in SQL_FILES:
        try:
            with open(CURRENT_DIR+'/'+filename, "r") as f:
                queries += [q.strip() for q in f.read().split(";") if q.strip()]
        except Exception as e:
            print(f"Error opening file {filename}: {e}")

    return queries

try:
    for query in load_queries():
        print(query)
        execute(query)

    print("Streams setup successfull.")
except Exception as e:
    print(f"KSQL setup error: {e}")

