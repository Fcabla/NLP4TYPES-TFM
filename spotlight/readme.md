https://github.com/dbpedia-spotlight/dbpedia-spotlight/wiki/Run-from-a-JAR

Download the jar:
wget http://downloads.dbpedia-spotlight.org/spotlight/dbpedia-spotlight-1.0.0.jar
https://sourceforge.net/projects/dbpedia-spotlight/files/spotlight/dbpedia-spotlight-0.7.1.jar/download

Download the model:
wget http://downloads.dbpedia-spotlight.org/2016-04/en/model/en.tar.gz
https://sourceforge.net/projects/dbpedia-spotlight/files/2016-10/en/model/en.tar.gz/download

tar xzf en.tar.gz

java -jar dbpedia-spotlight-1.0.0.jar path/to/model/folder/en_2+2 http://localhost:2222/rest