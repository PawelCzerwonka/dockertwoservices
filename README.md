# dockertwoservices

# To create image (90MB) with name "twoservices"
docker image build -t  twoservices .

# To create container with name "twoservices"
docker rm -f twoservices
docker run -it -d -p 5022:22 -p 5432:5432 --name twoservices twoservices:latest

# To log into container
rm -f /root/.ssh/known_hosts
ssh postgres@localhost -p 5022
ps -ef
psql
\l
exit

# DB
docker exec  twoservices sudo -u postgres psql -c "\l"


# To attach and debug shutting down db
docker attach container_name
ctrl+p,ctrl+q to exit
# To gracefully shutdown database in the container
docker stop twoservices -t 100

# Start
docker start twoservices

# To log into container
rm -f /root/.ssh/known_hosts
ssh postgres@localhost -p 5022
ps -ef
psql
\l
exit

# DB
docker exec  twoservices sudo -u postgres psql -c "\l"

# To remove container
docker rm -f twoservices


