pipeline {
    agent {
        docker {
            image 'node:16'
            args '-u root:root'
        }
    }
    
    environment {
        DOCKER_HOST = 'tcp://dind:2376'
        DOCKER_TLS_VERIFY = '0'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                url: 'https://github.com/Ganaa927/aws-elastic-beanstalk-express-js.git'
            }
        }
         stage('Permissions') {
            steps {
                sh '''
                    echo "Fixing workspace permissions..."
                    sudo chown -R jenkins:jenkins $WORKSPACE
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }
        
        stage('Security Scan - OWASP Dependency Check') {
            steps {
                script {
                    // Install OWASP Dependency Check
                    sh 'wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.2.1/dependency-check-8.2.1-release.zip'
                    sh 'unzip dependency-check-8.2.1-release.zip'
                    
                    // Run dependency check
                    sh './dependency-check/bin/dependency-check.sh --project "Node.js App" --scan . --format HTML --format JSON --out ./reports'
                    
                    // Check for high/critical vulnerabilities
                    sh '''
                        if [ -f ./reports/dependency-check-report.json ]; then
                            HIGH_VULNS=$(jq '.dependencies[]?.vulnerabilities[]?.severity? | select(. == "HIGH" or . == "CRITICAL")' ./reports/dependency-check-report.json | wc -l)
                            if [ $HIGH_VULNS -gt 0 ]; then
                                echo "Found $HIGH_VULNS High/Critical vulnerabilities - failing pipeline"
                                exit 1
                            fi
                        fi
                    '''
                }
            }
            post {
                always {
                    // Archive dependency check reports
                    archiveArtifacts artifacts: 'reports/*', allowEmptyArchive: true
                    publishHTML target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'reports',
                        reportFiles: 'dependency-check-report.html',
                        reportName: 'Dependency Check Report'
                    ]
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using DinD service
                    sh 'docker build -t nodejs-app:${BUILD_ID} .'
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    // Tag and push to Docker Hub (optional - requires credentials)
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                        sh 'docker tag nodejs-app:${BUILD_ID} $DOCKER_USER/nodejs-app:${BUILD_ID}'
                        sh 'docker push $DOCKER_USER/nodejs-app:${BUILD_ID}'
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images
            sh 'docker system prune -f'
            
            // Archive build artifacts
            archiveArtifacts artifacts: '**/*.log, **/reports/**', allowEmptyArchive: true
        }
        success {
            emailext (
                subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The pipeline completed successfully. Check reports at: ${env.BUILD_URL}",
                to: "developer@example.com"
            )
        }
        failure {
            emailext (
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "The pipeline failed. Check logs at: ${env.BUILD_URL}",
                to: "developer@example.com"
            )
        }
    }
}
