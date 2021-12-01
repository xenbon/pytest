pipeline {
    agent any
    environment {
        // CI set to true to allow it to run in "non-watch" (i.e. non-interactive) mode
        CI = 'true'
//         HOST_IP = "${HOST_IP}".0
//         HOST_PORT = "${HOST_PORT}"
    }
    stages {
        stage('Build') { 
            agent {
                docker { image 'python:3.7.2' }
            }
            steps {
                script {
                    try {sh 'yes | docker stop apptest'}
                    catch (Exception e) {echo "no container to stop"}
                    try {sh 'yes | docker rm apptest'}
                    catch (Exception e) {echo "no container to remove"}        
                    try { sh 'yes | docker image prune' }
                    catch (Exception e) { echo "no dangling images deleted" }
                    try { sh 'yes | docker image prune -a' }
                    catch (Exception e) { echo "no images w containers deleted" }
                    try { sh 'yes | docker container prune' }
                    catch (Exception e) { echo "no unused containers deleted" }
                    // ensure latest image is being build
                    sh 'docker build -t theimg:latest .'
                }
            }
        }
        /* X06 OWASP Dependency Check */
        stage('OWASP-DC') {
            agent { 
                docker { image 'theimg:latest'}
            }
            steps {
                dependencyCheck additionalArguments: '--format HTML --format XML', odcInstallation: 'OWASP-DC'
                // --suppression suppression.xml  // suppress warnings xml 
                // --enableExperimental // to test on python files
                // --log odc.log // generate log file
            }
            post {
                always {
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                }
            }
        }
        /* X07 Selenium portion */
        stage('unit/sel test') {
            parallel {
                stage('Deploy') {
                    agent any
                    steps {
                        sh 'docker run -d -p 5000:5000 --name apptest --network testing theimg:latest'
                        input message: 'Finished using the web site? (Click "Proceed" to continue)'
                        script {
                            try {sh 'yes | docker stop apptest'}
                            catch (Exception e) {echo "no container to stop"}
                            try {sh 'yes | docker rm apptest'}
                            catch (Exception e) {echo "no container to remove"}  
                        }
                    }
                }
                stage('Headless Browser Test') {
                    agent {
                        docker {
                            image 'theimg:latest'
                            args '--name uitest --network testing'
                        }
                    }
                    steps {
                        sh 'pytest -rA --junitxml=logs/uireport.xml'	
                    }
                    post {
                        always {
                            junit testResults: 'logs/uireport.xml'
                            /* X08 Warnings Next Plugin */
                            recordIssues enabledForFailure: true, tool: codeAnalysis()	
                            recordIssues enabledForFailure: true, tool: codeChecker()
                        }
                    }
                }
            }
        }

        /* X09 SonarQube */ 
        stage('SonarQube') {
            agent {
                docker { image 'theimg:latest' }
            }
            steps {
                script {
                    def scannerHome = tool 'SonarQube';
                    withSonarQubeEnv('SonarQube') {
                        // rmb to change the "projectKey=your_project_name"
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=test -Dsonar.sources=."

                        // code not generating report. do not uncomment unless yknow what u doing
                        // sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=test -Dsonar.sources=. -Dsonar.report.export.path=logs/sonar-report.json"
                    }
                }
            }
            post {
                always {
                    recordIssues enabledForFailure: true, tool: sonarQube()	
                }
            }
        }
    }
}