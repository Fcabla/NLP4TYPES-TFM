docker rm /dbpedia-spotlight.en
docker run -itd --restart unless-stopped --name dbpedia-spotlight.en -p 2222:80 dbpedia/dbpedia-spotlight spotlight.sh en