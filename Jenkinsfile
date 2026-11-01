pipeline {
    agent any

    stages {
        stage('deploy') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'echo "$PASSWORD" | docker login --username "$USERNAME" --password-stdin'
                }
                sh 'docker compose pull'
                sh 'docker stop plex || true'
                sh 'docker rm -f plex || true'
                sh 'docker compose up -d'
            }
        }
    }
}
