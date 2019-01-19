FROM node:8

WORKDIR /app
COPY . /app

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' >> /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-client-10

VOLUME [ "/data/backup" ]

RUN npm install

CMD bash migrate_to_sequelize.sh