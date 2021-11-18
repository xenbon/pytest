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
                    try { sh 'yes | docker image prune' }
                    catch (Exception e) { echo "no dangling images deleted" }
                    try { sh 'yes | docker image prune -a' }
                    catch (Exception e) { echo "no images w containers deleted" }
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

        stage('unit/sel test') {
            parallel {
                stage('Deploy') {
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
                    }
                }
                stage('Headless Browser Test') {
                    agent {
                        docker { image 'theimg:latest' }
                    }
                    steps {
                        sh 'nohup flask run & sleep 1'
                        sh 'pytest -s -rA --junitxml=test-report.xml'
                        // input message: 'Finished using the web site? (Click "Proceed" to continue)'
                        
                        script {
                            try {sh 'pkill -f flask'}
                            catch (Exception e) {echo "no process to kill"}

                            try {sh 'yes | docker stop thecon'}
                            catch (Exception e) {echo "no container to stop"}

                            try {sh 'yes | docker rm thecon'}
                            catch (Exception e) {echo "no container to remove"}
                        }
                    }
                    post {
                        always {
                            junit testResults: 'test-report.xml'
                        }
                    }
                }
            }
        }

        stage('warnings') {
            agent {
                docker { image 'theimg:latest' }
            }
            steps {
                sh 'nohup flask run & sleep 1'
                sh 'pytest -s -rA --junitxml=warn-report.xml'

            }
            post {
                always {
                    junit testResults: 'warn-report.xml'
                }
            }
            recordIssues enabledForFailure: true, tools: [mavenConsole(), java(), javaDoc()]
            recordIssues enabledForFailure: true, tool: checkStyle()
            recordIssues enabledForFailure: true, tool: spotBugs()
            recordIssues enabledForFailure: true, tool: cpd(pattern: '**/target/cpd.xml')
            recordIssues enabledForFailure: true, tool: pmdParser(pattern: '**/target/pmd.xml')
        }
    }
}
