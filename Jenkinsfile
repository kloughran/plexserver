pipeline {
    agent any

    stages {
        stage('deploy') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'docker login --username $USERNAME --password $PASSWORD'
                }
                sh 'docker compose pull'
                sh 'docker compose up -d'
            }
        }
    }
}
