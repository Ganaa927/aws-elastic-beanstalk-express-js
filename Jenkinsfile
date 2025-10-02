pipeline {
    agent {
        docker { image 'node:latest' }
    }
    stages {
        stage('Verify Docker Integration') {
            steps {
                sh 'node --version'
            }
        }
    }
}
