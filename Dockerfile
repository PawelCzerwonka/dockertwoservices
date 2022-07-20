FROM oraclelinux:8.4

USER root
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm &&\
    dnf -qy module disable postgresql &&\
    dnf install -y postgresql14-server sudo &&\
    mkdir /postgresql &&\
    chown postgres. /postgresql  &&\
    /usr/bin/ssh-keygen -A  &&\
    echo 'postgres     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers &&\
    echo 'root     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER postgres
RUN /usr/pgsql-14/bin/initdb --encoding="UTF8" --locale="en_US.UTF-8" --pgdata=/postgresql --auth=ident &&\
    /usr/pgsql-14/bin/pg_ctl -D /postgresql start &&\
    psql -c "\conninfo" &&\
    psql -c "\l" &&\
    /usr/pgsql-14/bin/pg_ctl -D /postgresql stop -mf


USER root
COPY services_handler.sh /services_handler.sh
RUN chmod +x /services_handler.sh   
ENTRYPOINT ["/services_handler.sh"]


# docker image build -t  twoservices .
# docker run -it -p 5022:22 -p 5432:5432 --name twoservices twoservices:latest
# docker stop twoservices -t 100
# To reactivate bash after exit command
# docker kill --signal="SIGUSR1" container_name
# docker attach container_name
# To gracefully shut down database with undo all opened transactions
# docker stop twoservices -t 100
