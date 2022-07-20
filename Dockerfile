FROM oraclelinux:8.4

USER root
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm &&\
    dnf -qy module disable postgresql &&\
    dnf install -y postgresql14-server sudo &&\
    mkdir /postgresql &&\
    chown postgres. /postgresql  &&\
    /usr/bin/ssh-keygen -A  &&\
    echo 'postgres     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&\
    echo 'root     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&\
    echo "postgres:postgres" | chpasswd

USER postgres
RUN /usr/pgsql-14/bin/initdb --encoding="UTF8" --locale="en_US.UTF-8" --pgdata=/postgresql --auth=ident &&\
    /usr/pgsql-14/bin/pg_ctl -D /postgresql start &&\
    psql -c "\conninfo" &&\
    psql -c "\l" &&\
    /usr/pgsql-14/bin/pg_ctl -D /postgresql stop -mf


USER root
COPY services_handler.sh /services_handler.sh
RUN chmod +x /services_handler.sh   
# Entrypoint przed
ENTRYPOINT ["/services_handler.sh"]


# docker image build -t  twoservices .
# docker run -it -d -p 5022:22 -p 5432:5432 --name twoservices twoservices:latest


# SSH
# rm -f /root/.ssh/known_hosts
# ssh postgres@localhost -p 5022
# password:postgres
# ps -ef
# psql
# \l

# DB
# docker exec  twoservices sudo -u postgres psql -c "\l"

# To debug use second terminal and
# docker attach twoservices
# To gracefully shut down database with undo all opened transactions
# docker stop twoservices -t 100







