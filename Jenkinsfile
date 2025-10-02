pipeline {
    agent {
        docker {
            image 'node:16'                // Node 16 build agent
            args '-u root:root'            // Run as root so npm installs work
        }
    }

    environment {
        APP_NAME = "nodejs-sample-app"
        DOCKER_REGISTRY = "docker.io"
        DOCKER_IMAGE = "ori0927/${APP_NAME}:${BUILD_NUMBER}"
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

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Security Scan') {
            steps {
                // Example using Snyk CLI (must be installed in Jenkins or inside node:16)
                sh '''
                  npm install -g snyk
                  snyk auth ${SNYK_TOKEN}
                  snyk test --severity-threshold=high
                '''
            }
        }

        stage('Build Docker Image') {
            agent { docker { image 'docker:24-cli' args '-v /var/run/docker.sock:/var/run/docker.sock' } }
            steps {
                sh '''
                  docker build -t ${DOCKER_IMAGE} .
                '''
            }
        }

        stage('Push Docker Image') {
            when {
                expression { return env.DOCKERHUB_USER && env.DOCKERHUB_PASS }
            }
            steps {
                sh '''
                  echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                  docker push ${DOCKER_IMAGE}
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Build and security scan passed. Image pushed.'
        }
        failure {
            echo '❌ Build failed. Check logs for details.'
        }
    }
}
