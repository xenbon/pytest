pipeline {
    agent any
    environment {
        // CI set to true to allow it to run in "non-watch" (i.e. non-interactive) mode
        CI = 'true'
        HOST_IP = "${HOST_IP}"
        HOST_PORT = "${HOST_PORT}"
        RECAPTCHA_PRIVATE_KEY = "${RECAPTCHA_PRIVATE_KEY}"
        RECAPTCHA_PUBLIC_KEY = "${RECAPTCHA_PUBLIC_KEY}"
        MAIL_USERNAME = "${MAIL_USERNAME}"
        MAIL_PASSWORD = "${MAIL_PASSWORD}"
        MAIL_PORT = "${MAIL_PORT}"
        MAIL_SERVER = "${MAIL_SERVER}"
        MAIL_USE_TLS = "${MAIL_USE_TLS}"
        PASSWORD_STRENGTH = "${PASSWORD_STRENGTH}"
        DEBUG = "${DEBUG}"
        SQLALCHEMY_DATABASE_URI = "${SQLALCHEMY_DATABASE_URI}"
        BCRYPT_WORK_FACTOR = "${BCRYPT_WORK_FACTOR}"
    }
    stages {
        stage('Build') { 
            steps {
                script {
                    // try {
                    //     sh 'yes | docker stop bagatea-container'
                    // }
                    // catch (Exception e) {
                    //     echo "no container to stop"
                    // }
                    // try {
                    //     sh 'yes | docker rmi -f bagatea-image'
                    // }
                    // catch (Exception e) {
                    //     echo "no bagatea-image deleted"
                    // }
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
                sh 'docker build -t bagatea-image:latest .'
            }
        }
    
        stage('Test') {
            parallel {
                stage('Test: OWASP DependencyCheck') {
                    agent { 
                        docker {
                            image 'bagatea-image:latest'
                        }
                    }
                    steps {
                        dependencyCheck additionalArguments: '--format HTML --format XML --suppression suppression.xml \
                        --enableExperimental --disableOssIndex --disableAssembly --log odc.log', odcInstallation: 'OWASP-DC'

                    }
                    post {
                        always {
                            dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                        }
                    }
                }
                stage('Test: Unit, Integration and UI Tests') {
                    agent {
                        docker {
                            image 'bagatea-image:latest'
                        }
                    }
                    steps {
                        sh 'rm -f bagatea/site.db'
                        sh 'nohup python3 app.py & pytest -s -rA --junitxml=logs/report.xml'
                        sh 'pkill -f app.py'
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
                    try {
                        // stop bagatea-container
                        sh 'yes | docker stop bagatea-container'
                    }
                    catch (Exception e) {
                        echo "no container to stop"
                    }

                    try {
                        // delete bagatea-container
                        sh 'yes | docker rm bagatea-container'
                    }
                    catch (Exception e) {
                        echo "no container to remove"
                    }
                }
                
                // build brand new bagatea-container with bagatea-image
                sh """docker run -u root -d --name bagatea-container \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v "$HOME":/home \
                -e HOST_IP -e HOST_PORT \
                -e VIRTUAL_HOST=bagatea.sitict.net -e VIRTUAL_PORT=5000 \
                -e RECAPTCHA_PRIVATE_KEY -e RECAPTCHA_PUBLIC_KEY \
                -e MAIL_USERNAME -e MAIL_PASSWORD -e MAIL_PORT \
                -e MAIL_SERVER -e MAIL_USE_TLS \
                -e PASSWORD_STRENGTH \
                -e DEBUG -e SQLALCHEMY_DATABASE_URI \
                -e BCRYPT_WORK_FACTOR \
                bagatea-image"""
            }
        }
    }
    
    post {
        always {
            discordSend description: "${msg}", 
            successful: currentBuild.resultIsBetterOrEqualTo('SUCCESS'),
            link: env.BUILD_URL, 
            result: currentBuild.currentResult, unstable: false, 
            title: "${JOB_NAME}: #${BUILD_NUMBER}",
            thumbnail: "https://chpic.su/_data/stickers/n/nanathecharmingcat/nanathecharmingcat_017.webp",
            webhookURL: "${DISCORD_WEBHOOK}"
        }
    }
}
