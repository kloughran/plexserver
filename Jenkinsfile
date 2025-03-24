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
				sh 'docker run -d --name plex --env "NVIDIA_VISIBLE_DEVICES=all" --env "NVIDIA_DRIVER_CAPABILITIES=compute,video,utility" --device /dev/dri/card2:/dev/dri/card2 --device /dev/dri/renderD129:/dev/dri/renderD129 --network=host --restart unless-stopped -v /media/container-storage/plex/plex-config:/config -v /media/container-storage/plex/temp:/transcode -v /media/plexmedia:/data plexinc/pms-docker'
			}
		}
	}
}