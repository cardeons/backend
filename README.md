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

<!-- //sudo apt install redis-server -->
<!-- - redis-server --daemonize yes -->
<!-- || -->
<!-- - bundle exec sidekiq --environment development -->

We are using foreman to start redis/sidekiq and puma in one shell:

gem install foreman

- foreman start -p 3000


Happy Coding😘

Reset DB: rails db:reset


*For Testing*
<!-- - bundle exec sidekiq --environment test -->
- rspec 

## Backend: 

https://cardeons-develop.herokuapp.com/

## Frontend: 

https://cardeons-develop.netlify.app/
