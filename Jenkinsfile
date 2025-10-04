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
                echo '===== Stage: Checkout ====='
                checkout scm
                echo 'Checkout completed successfully.'
            }
        }

        stage('Node 16 Build') {
            steps {
                echo '===== Stage: Node 16 Build ====='
                script {
                    docker.image('node:16').inside('-u root:root') {
                        echo 'Installing npm dependencies...'
                        sh 'npm install --save'
                        echo 'Dependencies installed.'
                        
                        echo 'Running unit tests...'
                        sh 'npm test || true' 
                        echo 'Unit tests completed.'
                    }
                }
            }
        }

        stage('Vulnerability Scan') {
            steps {
                echo '===== Stage: Vulnerability Scan ====='
                script {
                    docker.image('node:16').inside('-u root:root') {
                        echo 'Installing Snyk CLI...'
                        sh 'npm install -g snyk'
                        echo 'Snyk CLI installed.'
                        
                        echo 'Authenticating with Snyk...'
                        withEnv(["SNYK_TOKEN=${SNYK_TOKEN}"]) {
                            sh 'snyk auth $SNYK_TOKEN'
                        }


                        echo 'Running Snyk vulnerability scan...'
                        sh '''
                        snyk test --severity-threshold=high --json > snyk-report.json
                        SNYK_EXIT_CODE=$?
                        if [ $SNYK_EXIT_CODE -ne 0 ]; then
                          echo "Snyk found HIGH/CRITICAL vulnerabilities!"
                          exit 1
                        else
                          echo "No HIGH/CRITICAL vulnerabilities found."
                        fi
                        '''
                        echo 'Snyk scan completed.'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Stage: Build Docker Image'
                sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ."
                echo "Docker image ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest built successfully."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo '===== Stage: Push Docker Image ====='
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    echo 'Logging in to Docker registry...'
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    echo 'Login successful.'

                    echo 'Pushing Docker image...'
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    echo 'Docker image pushed successfully.'
                }
            }
        }
    }

    post {
        always {
            echo '=====Post: Cleanup and Archiving ====='
            sh 'docker system prune -f || true'
            echo 'Docker cleanup done.'

            echo 'Archiving build artifacts and Snyk report...'
            archiveArtifacts artifacts: '**/build/**, **/test-reports/**, snyk-report.json', allowEmptyArchive: true
            echo 'Artifacts archived.'
        }
        success {
            echo '===== Pipeline completed successfully! ====='
        }
        failure {
            echo '=====Pipeline failed! Check logs above for details ====='
        }
    }
}
