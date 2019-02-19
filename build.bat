@ECHO OFF 
docker-compose up --build -d
docker-compose run hwts cat /usr/src/app/css/site.min.css > site.min.css
PAUSE