pipeline {
    agent any
    environment {
        // CI set to true to allow it to run in "non-watch" (i.e. non-interactive) mode
        CI = 'true'
//         HOST_IP = "${HOST_IP}"
//         HOST_PORT = "${HOST_PORT}"
    }
    stages {
        stage('Build') { 
            steps {
                script {
                    try {
                        // clean all unused images
                        sh 'yes | docker image prune -a'
                    }
                    catch (Exception e) {
                        echo "no unused images deleted"
                    }
                    try {
                        // clean all unused containers
                        sh 'yes | docker container prune'
                    }
                    catch (Exception e) {
                        echo "no unused containers deleted"
                    }
                }
                // ensure latest image is being build
                sh 'docker build -t theimg:latest .'
            }
        }

        stage('Integration UI Test') {
			parallel {
				stage('Test') {
                    agent {
                        docker {
                            image 'theimg:latest'
                        }
                    }
                    steps {
                        script {
                            try {sh 'yes | docker stop thecon'}
                            catch (Exception e) {echo "no container to stop"}

                            try {sh 'yes | docker rm thecon'}
                            catch (Exception e) {echo "no container to remove"}
                        }

                        sh """docker run -u root -d --rm -p 5000:5000 --name thecon \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v "$HOME":/home \
                        -e VIRTUAL_PORT=5000 \
                        theimg"""

                        sh 'nohup flask run'
                        input message: 'Finished using the web site? (Click "Proceed" to continue)'
                        sh 'pkill -f flask'
                    }
                    // post {
                    //     always {
                    //         junit testResults: 'logs/report.xml'
                    //     }
                    // }
                }
				stage('Headful Browser Test') {
					steps {
                        sh 'pytest -s -rA --junitxml=logs/report.xml'
                        // sh 'pkill -f flask'
                        sh 'echo "hello" '
					}
					post {
                        always {
                            junit testResults: 'logs/report.xml'
                        }
                    }
				}
			}
		}
    
        
        
        stage('Deliver') {
            steps {
                script {
                    try {sh 'yes | docker stop thecon'}
                    catch (Exception e) {echo "no container to stop"}

                    try {sh 'yes | docker rm thecon'}
                    catch (Exception e) {echo "no container to remove"}
                }
                
                // build brand new bagatea-container with bagatea-image
                sh """docker run -u root -d --rm -p 5000:5000 --name thecon \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v "$HOME":/home \
                -e VIRTUAL_PORT=5000 \
                theimg
            }
        }
    }
    
}
