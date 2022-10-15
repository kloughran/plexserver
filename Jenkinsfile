pipeline {
    agent any 
	
    stage('Deploy') { // for display purposes
        sh 'docker pull plexinc/pms-docker' //update to the latest version
        sh 'docker stop plex || true'
        sh 'docker rm plex || true'
        withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
          sh 'docker login --username $USERNAME --password $PASSWORD'
        }
        sh 'docker pull plexinc/pms-docker'
        sh 'docker run -d --name plex --network=host --restart unless-stopped -v /media/container-storage/plex/plex-config:/config -v /media/container-storage/plex/temp:/transcode -v /media/plexmedia:/data plexinc/pms-docker'
    }
}