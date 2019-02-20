@ECHO OFF
docker-compose up --build -d
docker-compose run hwts cat /var/www/css/site.min.css > css\site.min.css
PAUSE