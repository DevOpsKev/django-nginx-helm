SHELL=/bin/sh

current_dir=$(shell pwd)
user=$(shell whoami)
current_context=$(shell kubectl config current-context)
container=django
component=my-nginx-deployment
namespace=webappdjango

help:  ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

minikube: ## Starts minikube
	minikube delete
	minikube start --memory 10240 --cpus 2 --kubernetes-version v1.14.7 --vm-driver=virtualbox

upgrade: ## Builds docker image inside minikube and deploys.
	eval $$(minikube docker-env) && docker build -t $(namespace) .
	- kubectl create namespace $(namespace)
	helm upgrade --install $(namespace) --values kubernetes/env-values/values-development.yaml kubernetes --namespace $(namespace)

delete: ## Deletes helm deployment
	helm delete $(namespace) -n $(namespace)

pods: ## Shows pods in this namespace
	kubectl get pods --namespace $(namespace)

logs: ## Show logs for a given container
	kubectl logs $(shell echo $(shell kubectl get pods --namespace $(namespace) | grep $(component)) | cut -d " " -f 1) --namespace $(namespace) --container=$(container) -f

web: ## Opens web site
	minikube service nginx-service -n $(namespace)

pg:
	kubectl port-forward svc/webappdjango-postgresql 5432:5432 -n $(namespace)

shell: ## Opens an interactive shell on a pod for a given component with parameters: component (cluster component name)
	kubectl exec -it $(shell echo $(shell kubectl get pods --namespace $(namespace) | grep $(component)) | cut -d " " -f 1) --namespace $(namespace) --container=$(container) bash