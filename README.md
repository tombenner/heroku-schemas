Heroku Schemas
==============
Run many apps on a single database

Description
-----------

Heroku Schemas lets you run multiple Heroku apps on top of a single Heroku Postgres database. A Postgres database can have multiple "schemas" (basically Postgres's word for database "namespaces"), and Heroku Schemas simply makes each app use its own schema within a single, shared database.

For example, if you have five apps with small levels of traffic, instead of using five databases, you can now just use one database to serve all of them.

Installation
------------

Install the plugin:

```sh
heroku plugins:install git://github.com/tombenner/heroku-schemas.git
```

Usage
-----

To make an app use a schema named `my_schema` in the database of an app called `my-other-app`:

```sh
cd path/to/my-app
heroku schemas:use my-other-app:my_schema
```

This copies the app's database into the new schema and makes the app use it. You can then remove the original database from your plan.

Heroku Schemas also lets you see what database/schema the current app is using (`show`) and drop schemas (`drop`).

Commands
--------

### Use

Make the app in the current directory use a new database/schema. If the app has an existing database, it is copied to the target database/schema. 

The following command makes my-app use the schema `my_schema` in the default database of my-other-app:

```sh
heroku schemas:use my-other-app:my_schema
```

If my-other-app has more than one database, you can specify which database the schema should be in: 
```sh
heroku schemas:use my-other-app:HEROKU_POSTGRESQL_BLUE_URL:my_schema
```

("`BLUE`"" in `HEROKU_POSTGRESQL_BLUE_URL` should be replaced with the color name in the database's name.)

### Show

Show which database/schema is currently being used by the app.

```sh
heroku schemas:show
=> my-other-app:HEROKU_POSTGRESQL_BLUE_URL:my_schema
```

### Drop

Drop (delete) the schema that is currently being used by the app. This is irreversible, so please be sure that you're dropping the intended schema.

```sh
heroku schemas:drop
=> Dropped schema my-other-app:HEROKU_POSTGRESQL_BLUE_URL:my_schema
```

Tests
-----

The feature tests create and manipulate two Heroku apps; to run them, you'll need to:

```sh
cp features/support/config.example.yml features/support/config.yml
```

And then edit config.yml to include your Heroku API key and a prefix for the app names (choose something unique to avoid naming conflicts with other people who are running these tests).

Notes
-----

A shared database may not be wise for significant, production apps, but it may be worthwhile if you have multiple small apps or apps that are in development.

Heroku Schemas is for educational purposes. The author assumes no liability for anything that happens to your data or your Heroku account while using Heroku Schemas.

License
-------

Heroku Schemas is released under the MIT License. Please see the MIT-LICENSE file for details.
