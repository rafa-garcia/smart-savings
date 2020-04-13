# Smart Savings REST API

## What this is

A service for storing and analyzing a user's financial habits.

The app is live on [Heroku](https://smartsavings.herokuapp.com/api).

## Running the app

Copy the file `.env.example` as `.env` and edit it to match your environment settings.

### From Docker

Requires:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://github.com/docker/compose).

Run `docker-compose up` from the root of the project.

This will spin up an app server, a postgres service and seed the database with dummy data.

The entry point of the service is available on http://localhost:3000/api

### From a standard local setup

Requires:
- [Ruby v2.6](https://www.ruby-lang.org/en/)
- [PostgreSQL](https://www.postgresql.org/)

From the root directory of the project, run:

```bash
$ bundle install
$ bundle exec rake db:setup
$ bundle exec rake db:seed
$ bundle exec rake server
```
The service should now be available on `http://localhost:3000/api`

## Running the tests

Run `bundle exec rake` from the root of the project.

## Introspection

The app is bundled with a task for stepping inside its environment.

Run `bundle exec rake console` from the root directory.

## API documentation

To print out all available endpoints, run the task 'bundle exec rake routes'

```bash
$ bundle exec rake routes
     GET        /api/movies
     POST       /api/movies
     GET        /api/reservations
     POST       /api/reservations
     GET        /api/swagger_doc
     GET        /api/swagger_doc/:name
```

The API's entry point (`/api`) will show the app's endpoints.

The API documentation is available on `http://localhost:3000/api/swagger_doc` once the service is running, or live on [Heroku](https://smartsavings.herokuapp.com/api/swagger_doc).

To explore the API, paste the document on [Swagger Editor](https://editor.swagger.io).