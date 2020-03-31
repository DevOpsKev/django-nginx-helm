## Quickstart

This project contains helm charts to run a near-production grade Django instance. It includes a postgres backend database and Nginx server to mimic a production environment.

# Prerequisites
To run this project locally, you'll need:

Kubectl (`brew install kubectl` on OSX, or here: https://kubernetes.io/docs/tasks/tools/install-kubectl/)
Helm (`brew install helm` on OSX, or here: https://helm.sh/docs/intro/install/)
Virtualbox (https://www.virtualbox.org/wiki/Downloads)
Minikube (`brew install minikube` on OSX, or here: https://kubernetes.io/docs/tasks/tools/install-minikube/)

Kubernetes is a container orchestration system, you can read about it here: https://kubernetes.io/
Kubectl is command line tool to interact with kubernetes clusters, you can read about it here: https://kubernetes.io/docs/reference/kubectl/overview/
Helm is a package manager for kubernetes. You can read about it here: https://helm.sh/
Virtualbox is a local virtualization tool that allows you to run machine images -- it will be the host for the minikube instance. You can read about it here: https://www.virtualbox.org/
Minikube is a local development version of kubernetes. It runs a full cluster locally. You can read about it here: https://kubernetes.io/docs/setup/learning-environment/minikube/

# Setting up your local environment
Once you have this repo downloaded locally, there are a couple steps to configure your environment. First, make a folder for your development "values" file:
`mkdir ./kubernetes/env-values`
Then add the following to a file called `values-development.yaml` inside that folder, replacing the folder name for where your code lives:
`
global:
  environment: development
  baseFolder: /<path_to_project>/webapp
django:
  webDebug: "True"
`
This file will hold any local configuration, is specific to each developer, and isn't part of version control. It allows us to put sensitive credentials and custom configuration for each developer.

# Running Django
Now you can boot up Django, using a "Makefile" which has easy to remember commands. You can check out the actual commands in the Makefile in the root of the repo.

Run this command to start up minikube. Note: your local machine should have 16G+ of RAM, if not you may need to adjust values in the Makefile.
`make minikube`

Run this command to build and run Django on your minikube cluster:
`make upgrade`

Check on the status of your pods, using this command:
`make pods`

Once the pods are in "RUNNING" state, use this to open a web browser:
`make web`
Sometimes it takes a couple minutes to get everything up and running, so be patient and try again in a couple minutes if it's not working.

Thats it! You have a robust version of Django running locally. You can add "/admin" to the end of the URL and log in using admin:admin to check out Django admin, which shows all your database models.

# Connecting to Postgres
If you want to forward the postgres DB to your local, so you can connect using a SQL Client, run `make pg` which will open a tunnel. You can access the db using host=localhost, port=5432, user=postgresql, pass=postgresql

# Troubleshooting
The main pod will restart a few times while it waits for the Postgres DB to start up... It is normal to have 3 or 4 restarts.

The Kubernetes deployment has 4 or 5 different containers. You can check the logs for each by running `make logs container=<container_name>` to see what failed.

init-containers (Initializes the database and webapp)
1. migrate # Applies database models to the DB
2. init-project # Sets up admin user if not present
3. collectstatic # Only if Values.django.webDebug="False", puts static files into nginx container

application conatiners (Runs the actual app + nginx to serve content)
1. django
2. nginx



## Adding new "apps" to Django
A Django project consists of a number of different "apps" that isolates different parts of the project. To start a new app, make sure everything is running locally, and first ssh into the django pod:

`make shell`

Once you're inside the pod, you can use manage.py to start a new app:

`python manage.py startapp {appname}`

This will create a new folder with the app under "webapp" on your local machine + in the container. You can create views, urls, etc as described in the Django Tutorials.

## Applying migrations
Once you make changes to a model for a given app, you need to rerun the "upgrade" command which will automatically apply migrations:

`make upgrade`

Check the logs from the migration container to see if there were any errors:

`make logs container=migrate`

## Serving static content
If you set Values.django.webDebug="False", it will serve static content from Django -- this is automatically collected during one of the init-containers, so you just need to run `make upgrade` after static changes to see them in the site.

## Changing the project name
<todo>

## Deploying to production
<todo>
