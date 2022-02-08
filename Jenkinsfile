pipeline {
    agent any

    stages {

        stage ('Maven Build') {
            steps {
                withMaven(maven: 'maven') {
                    sh 'mvn clean'
                    sh 'mvn test'
                    sh 'mvn package'
                }
            }
        }

        stage ('Docker Login') {
            steps {
                sh 'docker login -u=${DOCKER_USERNAME} -p=${DOCKER_PASSWORD}'
            }
        }

        stage ('Build Docker Image') {
            steps {
                sh 'docker build -t mhmmderen/weather-api:1.0.0 .'
            }
        }

        stage ('Image Push to Dockerhub') {
            steps {
                sh 'docker push mhmmderen/weather-api:1.0.0'
            }
        }

    }
}