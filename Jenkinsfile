pipeline {
    agent any 
	
	stages {
		stage('remove old') { // for display purposes
			sh 'docker stop plex || true'
			sh 'docker rm plex || true'
		}
		stage('update') { // for display purposes
			withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
			  sh 'docker login --username $USERNAME --password $PASSWORD'
			}
			sh 'docker pull plexinc/pms-docker'
		}
		stage('deploy') { // for display purposes
			sh 'docker run -d --name plex --network=host --restart unless-stopped -v /media/container-storage/plex/plex-config:/config -v /media/container-storage/plex/temp:/transcode -v /media/plexmedia:/data plexinc/pms-docker'
		}
}