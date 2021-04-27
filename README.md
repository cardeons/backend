# Cardeons

## To do:
```sh
npm i
bundle i
```

## Database Setup:
```sh
sudo service postgresql start
sudo -u postgres  psql
CREATE DATABASE cardeons_backend_development;
CREATE DATABASE cardeons_backend_test;
rails db:migrate
```
We are using foreman to start redis/sidekiq and puma in one shell:
```sh
gem install foreman
```

You need to install redis before you can use the dev env:

```sh
sudo apt install redis-server 
foreman start -f Procfile.dev
```

## Deploying:

add master as remote
```sh
git remote add dokku ssh://dokku@projects.multimediatechnology.at:5412/cardeon
```

add develop as remote
```sh
git remote add dokku-develop ssh://dokku@projects.multimediatechnology.at:5412/cardeon-develop
```

Code gets pushed automatically as soon as you push to the master in the corresponding repo.

if in any case you need to push manually, use:

```sh
gem install dokku-cli
git push dokku --branch--:master --remote=dokku/--remote=dokku-develop
```

temp env variablen setzen:
```sh
dokku run rails db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1
```

**A private key is needed for deploying!**


Happy Coding😘

Reset DB: rails db:reset


## For Testing
```sh 
rspec -> runs all tests
```

## Backend: 

https://cardeon.projects.multimediatechnology.at/

## Frontend: 

https://cardeons-develop.netlify.app/