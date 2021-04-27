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
```


## RUN Dev Server:
```sh
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

if in any case you need to push manuallyuse:

```sh
gem install dokku-cli
git push dokku YOUR_BRANCH_TO_PUSH:master
git push dokku-develop YOUR_BRANCH_TO_PUSH:master
```

if in any case you need to run commands on dokku:
```sh
dokku run rails db:migrate
dokku run rails db:migrate --remote=dokku-develop
```


reset db/set temp env variables:
pls never do this on our production server
```sh
dokku run rails db:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1
```

env variablen setzen::
```sh
dokku config:set MY_ENV="myvalue" 
dokku config:set MY_ENV="myvalue" --remote=dokku-develop
```

**A private key is needed for deploying!**


Happy Coding😘👩‍💻


## For Testing
```sh 
rspec -> runs all tests
```

## Backend: 

https://cardeon.projects.multimediatechnology.at/
https://cardeon-develop.projects.multimediatechnology.at/

yes its cardeon not cardeons :(

## Frontend: 

https://cardeons.netlify.app/ 

https://cardeons-develop.netlify.app/
