pipeline {
    agent any

    stages {
        stage('Installing Dependencies') {
            steps {
                // Run npm in a Node container using 'docker run'
                sh 'docker run --rm -v $PWD:/app -w /app node:16 npm install --save'
            }
        }

        stage('Run unit tests') {
            steps {
                sh 'docker run --rm -v $PWD:/app -w /app node:16 npm test'
            }
        }

        stage('Security in the Pipeline') {
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

        stage('Push to Registry') {
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
    }
}
