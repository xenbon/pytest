pipeline {
    agent {
        docker {
            image 'python:3.9'
            args '-p 5000:5000'
        }
    }
    environment {
        // CI set to true to allow it to run in "non-watch" (i.e. non-interactive) mode
        CI = 'true'
//         HOST_IP = "${HOST_IP}"
//         HOST_PORT = "${HOST_PORT}"
    }
    stages {
        stage('Build') { 
            steps {
                sh 'pip install --upgrade pip'
                sh 'pip install -r requirements.txt'
                sh 'apt-get install firefox-esr'
                sh 'apt-get install selenium'
                sh 'apt-get install seleniumbase'
                sh 'sbase install geckodriver'
                sh 'export PATH=$PATH:/usr/local/lib/python3.9/site-packages/seleniumbase/drivers'
            }
        }

        stage('Integration UI Test') {
			parallel {
				stage('Deploy') {
					steps {
						sh """docker run -u root -d --name 3x03-con \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v "$HOME":/home \
                        -p 5000:5000 \
                        python:3.9"""

                        sh 'pytest -s -rA --junitxml=logs/report.xml'
                        input message: 'Finished using the web site? (Click "Proceed" to continue)'
                        sh 'pkill -f flask'
					}
				}
				stage('Headless Browser Test') {
					agent {
						docker {
							image 'python:3.9'
                            args '-p 5000:5000'
						}
					}
					steps {
						sh 'nohup flask run &'
                        sh 'pytest -s -rA --junitxml=logs/report.xml'
                        sh 'pkill -f flask'
					}
					post {
                        always {
                            junit testResults: 'logs/report.xml'
                        }
                    }
				}
			}
		}

        
        // stage('Deliver') {
        //     steps {
        //         // build brand new bagatea-container with bagatea-image
        //         sh """docker run -u root -d --name 3x03-con \
        //         -v /var/run/docker.sock:/var/run/docker.sock \
        //         -v "$HOME":/home \
        //         -p 5000:5000 \
        //         3x03-img"""
        //     }
        // }
    }

}
