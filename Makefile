all: docker-pull docker-push kube-create

docker-pull:
  	docker pull openlabs/docker-wkhtmltopdf-aas

docker-push:
	docker tag openlabs/docker-wkhtmltopdf-aas:latest us.gcr.io/[replace with project id]/pdf-service:v1
	gcloud docker push us.gcr.io/[replace with project id]/pdf-service:v1

kube-create:
	kubectl create -f ./service.yaml
	kubectl create -f ./rc.yaml
