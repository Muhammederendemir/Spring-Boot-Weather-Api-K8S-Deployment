# Spring Boot Weather Api

> Spring Boot Weather Api

## Prerequisites

* Java 11
* Maven 3.3+
* Vagrant
* Docker

## Used Technologies

* Spring Boot 2.4.3
* Spring Boot Web
* Lombok
* Spring Boot Test
* Vagrant
* Ansible
* Kubernetes

## Docker Image Build and Push

```sh
mvn clean package
```

```sh
docker build -t mhmmderen/weather-api:1.0.0 .
```

```sh
docker push mhmmderen/weather-api:1.0.0
```


## Installation

With vagrant, we can edit the .env files for k8s cluster installation.

```sh
vagrant up
```

```sh
vagrant ssh k8s-m-1
```

```sh
cd deployment

kubectl apply -f namespace.yaml

kubectl apply -f .
```


## Weather Api 

> You can access the Weather Api from the following url.

http://Master-ip:32000/temperature?city=sivas

<img src="https://raw.githubusercontent.com/Muhammederendemir/Spring-Boot-Weather-Api-K8S-Deployment/master/images/temperature.png" alt="Spring Boot Weather Temperature Api" width="100%" height="100%"/> 
