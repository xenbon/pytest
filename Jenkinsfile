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
                    try { sh 'yes | docker image prune -a' }
                    catch (Exception e) { echo "no unused images deleted" }
                    try { sh 'yes | docker container prune' }
                    catch (Exception e) { echo "no unused containers deleted" }
                }
                // ensure latest image is being build
                sh 'docker build -t theimg:latest .'
            }
        }
        
        stage('Test: OWASP DependencyCheck') {
            agent { 
                docker {
                    image 'theimg:latest'
                }
            }
            steps {
                dependencyCheck additionalArguments: '--format HTML --format XML', odcInstallation: 'OWASP-DC'
                // --suppression suppression.xml 
                // --enableExperimental --disableOssIndex --disableAssembly --log odc.log
            }
            post {
                always {
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                }
            }
        }

        stage('Unit/Selenium-UI Test') {
            agent {
                docker { image 'theimg:latest' }
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

                sh 'nohup python3 app.py & sleep 1'
                // sh 'echo $! > .pidfile'
                sh 'pytest -s -rA --junitxml=logs/report.xml'
                input message: 'Finished using the web site? (Click "Proceed" to continue)'
                sh 'pkill -f app.py'
                // sh 'kill $(cat .pidfile)'
            }
            post {
                always {
                    junit testResults: 'logs/report.xml'
                }
            }
        }
        
    }
}
