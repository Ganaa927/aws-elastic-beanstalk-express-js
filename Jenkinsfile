pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ori0927'
        IMAGE_NAME = 'project2'   
        DOCKER_HOST = 'tcp://docker:2376'
        DOCKER_TLS_VERIFY = '1'
        DOCKER_CERT_PATH = '/certs/client'
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds'
        SNYK_TOKEN = credentials('snyk-api-token') 
        SEVERITY_THRESHOLD = 'high'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Node 16 Build') {
            steps {
                script {
                    docker.image('node:16').inside('-u root:root') {
                        sh 'npm install --save'
                        sh 'npm test'
                    }
                }
            }
        }
        stage('Vulnerability Scan') {
            steps {
                script {
                    docker.image('node:16').inside('-u root:root') {
                    //Integrate a dependency vulnerability scanner
                        sh 'npm install -g snyk'
                    // Authenticate Snyk using Jenkins credential
                        sh "snyk auth ${SNYK_TOKEN}"
                    //The pipeline must fail if High/Critical issues are detected.
                        sh "snyk test --severity-threshold=${SEVERITY_THRESHOLD}"
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
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
