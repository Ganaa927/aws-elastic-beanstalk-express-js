pipeline {
    agent  {
        docker {
            image 'node:16'
        }
    }
    stages {
        stage('Installing Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        stage('Run unit tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Security in the Pipeline') {
              steps {
                  //Integrate a dependency vulnerability scanner
                  sh 'npm install -g snyk'
                  
                  // Authenticate Snyk using Jenkins credential
                  withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                      sh 'snyk auth $SNYK_TOKEN'
                  }
  
                  // The pipeline must fail if High/Critical issues are detected.
                  sh 'snyk test --severity-threshold=high'
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
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ori0927/project2:${BUILD_NUMBER}"
            }
        }
    }
    post {
            always {
                // enable the archive of build outputs and test reports
                archiveArtifacts artifacts: '**/build/**, **/test-reports/**', allowEmptyArchive: true
                echo 'Artifacts archived.'
            }
        }

}
}

