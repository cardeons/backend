# Cardeons

To do:

- npm i

- bundle i

- create databases

  -sudo service postgresql start
  
  -sudo -u postgres  psql
  
  -CREATE DATABASE cardeons_backend_development;
  
  -CREATE DATABASE cardeons_backend_test;

- rails db:migrate

We are using foreman to start redis/sidekiq and puma in one shell:

- gem install foreman




// you need to install redis before you can use the dev env
// sudo apt install redis-server 
- foreman start -f Procfile.dev


  runs these commands :
//- redis-server --daemonize yes
//- bundle exec sidekiq --environment development
//- rails s -p 3000

deploy:

- git remote add dokku ssh://dokku@projects.multimediatechnology.at:5412/cardeon

- gem install dokku-cli

- git push dokku develop:master

temp env variablen setzen:

- dokku run rails db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1

Für das deployen braucht man einen private key




Happy Coding😘

Reset DB: rails db:reset


*For Testing*
<!-- - bundle exec sidekiq --environment test -->
- rspec 

## Backend: 

https://cardeons-develop.herokuapp.com/

## Frontend: 

https://cardeons-develop.netlify.app/
