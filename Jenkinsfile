pipeline {
    agent any

    environment {
        DOCKER_HOST = "tcp://dind:2375"
        DOCKER_TLS_VERIFY = "0"
    }

    stages {
        stage('Installing Dependencies') {
            steps {
                sh 'docker run --rm -v $PWD:/app -w /app node:16 npm install --save'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'docker run --rm -v $PWD:/app -w /app node:16 npm test'
            }
        }

        stage('Security Scan') {
            steps {
                sh 'docker run --rm -v $PWD:/app -w /app node:16 npm install -g snyk'
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh 'docker run --rm -v $PWD:/app -w /app node:16 snyk auth $SNYK_TOKEN'
                }
                sh 'docker run --rm -v $PWD:/app -w /app node:16 snyk test --severity-threshold=high'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ori0927/project2:${BUILD_NUMBER} .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push ori0927/project2:${BUILD_NUMBER}'
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/build/**, **/test-reports/**', allowEmptyArchive: true
            echo 'Artifacts archived.'
        }
        cleanup {
            // Clean up Docker images to save space
            sh 'docker system prune -f || true'
        }
    }
}
