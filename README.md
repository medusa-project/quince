# Quince

Quince is a work-in-progress experimental rebuild of the Ruby on Rails web application component
of [Illinois Data Bank](https://databank.illinois.edu/),
which is a public access repository
for research data from the University of Illinois
at Urbana-Champaign.

This is a getting-started guide for developers.

# Quick Links

* [SCARS Wiki](https://wiki.illinois.edu/wiki/display/scrs/Illinois+Data+Bank)
* [JIRA Project](https://bugs.library.illinois.edu/projects/IDB)

# Prerequisites

* Administrator access to the production Illinois Data Bank instance (in order to export data
  to import into your development instance)
* PostgreSQL >= 9.x
* S3 buckets ([MinIO Server](https://min.io/download) will work in
  development & test)
* Solr 6
    * You can install and configure this yourself, but it will be easier to run
      a sunspot image server container in Docker.  TODO: add link
* Cantaloupe 5.0+
    * You can install and configure this yourself, but it will be easier to run
      an [image server container](https://github.com/medusa-project/dls-cantaloupe-docker)
      in Docker.
    * This will also require the
      [AWS Command Line Interface](https://aws.amazon.com/cli/) v1.x with the
      [awscli-login](https://github.com/techservicesillinois/awscli-login)
      plugin, which is needed to obtain credentials for Cantaloupe to access
      the relevant S3 buckets. (awscli-login requires v1.x of the CLI as of
      this writing, but that would be the only reason not to upgrade to v2.x.)
* [Databank Archive Extractor](https://github.com/medusa-project/databank-archive-extractor)
TODO: add details 

# Installation

## Install Quince
```sh
# Install rbenv
$ brew install rbenv
$ brew install ruby-build
$ brew install rbenv-gemset --HEAD
$ rbenv init
$ rbenv rehash

# Clone the repository
$ git clone https://github.com/medusa-project/qunice.git
$ cd quince

# Install Ruby into rbenv
$ rbenv install "$(< .ruby-version)"

# Install Bundler
$ gem install bundler

# Install application gems
$ bundle install
```

## Create the Solr core
Follow the directions within the
[Dockerfile](https://github.com/medusa-project/databank/blob/main/docker/sunspot/Dockerfile) in the project.

## Configure the application

```sh
$ cd config/credentials
$ cp template.yml development.yml
$ cp template.yml test.yml
```
Edit both as necessary. 

See the "Configuration" section later in this file for more information about
the configuration system.

## Create the database and load the schema

```
$ psql postgres
postgres=# CREATE ROLE quince WITH LOGIN PASSWORD '<password in quotes>';
postgres=# CREATE DATABASE databank OWNER databank;
postgres=# CREATE DATABASE databank_test OWNER databank;
postgres=# \q
$ bundle exec rails db:schema:load
```

# Load some data

## Import sample datasets
TODO: add instructions

# Updating

## Update the database schema

```sh
$ bin/rails db:migrate
```
# Tests

There are several dependent services:

* PostgreSQL
* Solr
* A working [Medusa Collection Registry](https://medusa.library.illinois.edu).
  There are a lot of tests that rely on fixture data within Medusa.
  Unfortunately, production Medusa data is not stable enough to test against
  and it's hard to tailor for specific tests that require specific types of
  content. So instead, all of the tests rely on a mock of Medusa called
  [Mockdusa](https://github.com/medusa-project/mockdusa).
* A Cantaloupe image server instance.
* A Databank Archiver Extractor instance.
* Two S3 buckets:
    1. One for draft datasets.
    2. One containing Medusa repository data. The content exposed by
         Mockdusa, above, should be available in this bucket.

Because getting all of this running locally can be a real hassle, there is also
a `docker-compose.yml` file that will spin up all of the required services and
run the tests within a containerized environment:

```sh
aws login
eval $(aws ecr get-login --region us-east-2 --no-include-email --profile default)
docker-compose pull && docker-compose up --build --exit-code-from quince
```

# Configuration

See the class documentation in `app/config/configuration.rb` for a detailed
explanation of how the configurarion system works. The short explanation is
that the `develop` and `test` environments rely on the unencrypted
`config/credentials/develop.yml` and `test.yml` files, respectively, while the
`demo` and `production` environments rely on the `demo.yml.enc` and
`production.yml.enc` files, which are Rails 6 encrypted credentials files.

# Authorization

In the production and demo environments, authorization uses LDAP. In
development and test, there is one "canned user" for each Illinois Data Bank user type:

* `depositor`: Can deposit a dataset.
* `nodeposit`: Can log in, cannot deposit a dataset. 
* `admin`: Curators and Library IT system administrators

Sign in with any of these using `[username]@example.org` as the password.

# Documentation

The `rake doc:generate` command invokes YARD to generate HTML documentation
for the code base.
