FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir mysql-connector-python

COPY src/ /app/src/

CMD python3 /app/src/generate_data.py \
    --host $MYSQL_HOST \
    --user $MYSQL_USER \
    --password $MYSQL_PASSWORD \
    --database $MYSQL_DATABASE \
    --port $MYSQL_PORT

