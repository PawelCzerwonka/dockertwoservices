FROM oraclelinux:8.4
#FROM oraclelinux:8-slim

USER root
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm &&\
    dnf -qy module disable postgresql &&\
    dnf install -y postgresql14-server  &&\
    echo 'postgres     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
    
    #systemctl enable postgresql-14 &&\
    #systemctl start postgresql-14 &&\
RUN dnf -y install sudo
RUN mkdir /postgresql &&\
    chown postgres. /postgresql
USER postgres
RUN tail -1 /etc/passwd
RUN /usr/pgsql-14/bin/initdb --encoding="UTF8" --locale="en_US.UTF-8" --pgdata=/postgresql --auth=ident
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
RUN echo $CACHEFROMTHISLINEOFF
# RUN yes '' | ssh-keygen -t rsa -N ''
RUN /usr/pgsql-14/bin/pg_ctl -D /postgresql start &&\
    psql -c "\conninfo" &&\
    psql -c "\l" &&\
    /usr/pgsql-14/bin/pg_ctl -D /postgresql stop -mf


USER root
RUN /usr/bin/ssh-keygen -A
RUN echo 'root     ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY services_handler.sh /services_handler.sh
RUN chmod +x /services_handler.sh
ENTRYPOINT ["/services_handler.sh"]

#docker image build -t  pytanie .
#docker run -it -p 5022:22 -p 5432:5432 --name pytanie pytanie:latest
#docker stop pytanie -t 100
