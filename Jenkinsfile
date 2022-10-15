pipeline {
    agent any 
	
	stages {
		stage('remove old') { 
			steps {
				sh 'docker stop plex || true'
				sh 'docker rm plex || true'
			}
		}
		stage('update') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
				  sh 'docker login --username $USERNAME --password $PASSWORD'
				}
				sh 'docker pull plexinc/pms-docker'
			}
		}
		stage('deploy') {
			steps {
				sh 'docker run -d --name plex --network=host --restart unless-stopped -v /media/container-storage/plex/plex-config:/config -v /media/container-storage/plex/temp:/transcode -v /media/plexmedia:/data plexinc/pms-docker'
			}
		}
	}
}