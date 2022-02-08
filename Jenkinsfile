pipeline {
    agent {
        kubernetes {
            defaultContainer 'jnlp'
            yamlFile 'build.yaml'
        }
    }


    stages {

        stage ('Maven Build') {
            steps {
                container('maven') {
                    sh 'mvn clean'
                    sh 'mvn test'
                    sh 'mvn package'
                }
            }
        }


        stage ('Build Docker Image') {
            steps {
                 container('docker') {
                    sh "docker build -t mhmmderen/weather-api:1.0.0 ."
                }
            }

        }

        stage ('Image Push to Dockerhub') {
            steps {
                sh 'docker push mhmmderen/weather-api:1.0.0'
            }
        }

    }
}