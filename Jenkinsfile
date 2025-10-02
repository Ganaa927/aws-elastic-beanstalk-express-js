pipeline {
    agent {
        docker {
            image 'node:16'
            args '-u root:root -v /certs/client:/certs/client:ro -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKER_REGISTRY = 'ori0927'     
        IMAGE_NAME = 'project2'            
        SNYK_TOKEN = credentials('snyk-api-token') 
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        SEVERITY_THRESHOLD = 'high'
    }

    options {
        skipDefaultCheckout()
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Vulnerability Scan') {
            steps {
                sh 'npm install -g snyk'
                sh "snyk auth ${SNYK_TOKEN}"
                sh "snyk test --severity-threshold=${SEVERITY_THRESHOLD}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh 'docker system prune -f || true'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
