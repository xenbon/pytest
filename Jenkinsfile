// pipeline {
//     agent none
//     environment {
//         // CI set to true to allow it to run in "non-watch" (i.e. non-interactive) mode
//         CI = 'true'
// //         HOST_IP = "${HOST_IP}"
// //         HOST_PORT = "${HOST_PORT}"
//     }
//     stages {
//         stage('Integration UI Test') {
// 			parallel {
// 				stage('Deploy') {
// 					steps {
//                         sh 'pip install --upgrade pip'
//                         sh 'pip install -r requirements.txt'
//                         sh 'apt-get update && apt-get install -y apt-transport-https'
//                         sh 'sbase install geckodriver'
//                         sh 'apt-get install firefox-esr -y'
//                         sh 'export PATH=$PATH:/usr/local/lib/python3.9/site-packages/seleniumbase/drivers'
                        
//                         script {
//                         try {sh 'yes | docker stop thecon'}
//                         catch (Exception e) {echo "no container to stop"}

//                         try {sh 'yes | docker rm thecon'}
//                         catch (Exception e) {echo "no container to remove"}
//                         }
// 						sh """docker run -it -u root -d --rm -p 80:80 --name thecon \
//                         -v /var/run/docker.sock:/var/run/docker.sock \
//                         -v "$HOME":/home \
//                         -e VIRTUAL_PORT=80 \
//                         python:3.9"""

//                         // sh 'sleep 1'

//                         // sh 'docker exec thecon ls -lha'
//                         // sh 'docker exec thecon python3 app.py'

//                         sh 'nohup flask run &'
//                         sh 'pytest -s -rA --junitxml=logs/report.xml'
//                         input message: 'Finished using the web site? (Click "Proceed" to continue)'
//                         sh 'pkill -f flask'
// 					}
// 				}
// 				stage('Headless Browser Test') {
// 					steps {
//                         // sh 'pytest -s -rA --junitxml=logs/report.xml'
//                         // sh 'pkill -f flask'
//                         sh 'echo "hello" '
// 					}
// 					// post {
//                     //     always {
//                     //         junit testResults: 'logs/report.xml'
//                     //     }
//                     // }
// 				}
// 			}
// 		}

        
//         // stage('Deliver') {
//         //     steps {
//         //         // build brand new bagatea-container with bagatea-image
//         //         sh """docker run -u root -d --name 3x03-con \
//         //         -v /var/run/docker.sock:/var/run/docker.sock \
//         //         -v "$HOME":/home \
//         //         -p 5000:5000 \
//         //         3x03-img"""
//         //     }
//         // }
//     }

// }


// pipeline {
//     agent {
//         docker {
//             image 'python:3.9'
//         }
//     }
//     environment {
//         // CI set to true to allow it to run in "non-watch" (i.e. non-interactive) mode
//         CI = 'true'
// //         HOST_IP = "${HOST_IP}"
// //         HOST_PORT = "${HOST_PORT}"
//     }
//     stages {
//         stage('Build') { 
//             steps {
//                 sh 'pip install --upgrade pip'
//                 sh 'pip install -r requirements.txt'
//                 sh 'apt-get update && apt-get install -y apt-transport-https'
//                 sh 'sbase install geckodriver'
//                 sh 'apt-get install firefox-esr -y'
//                 sh 'export PATH=$PATH:/usr/local/lib/python3.9/site-packages/seleniumbase/drivers'
//             }
//         }

//         stage('Integration UI Test') {
// 			parallel {
// 				stage('Deploy') {
// 					steps {
//                         script {
//                         try {sh 'yes | docker stop thecon'}
//                         catch (Exception e) {echo "no container to stop"}

//                         try {sh 'yes | docker rm thecon'}
//                         catch (Exception e) {echo "no container to remove"}
//                         }
// 						sh """docker run -it -u root -d --rm -p 80:80 --name thecon \
//                         -v /var/run/docker.sock:/var/run/docker.sock \
//                         -v "$HOME":/home \
//                         -e VIRTUAL_PORT=80 \
//                         python:3.9"""

//                         sh 'sleep 1'

//                         sh 'docker exec thecon ls -lha'
//                         sh 'docker exec thecon python3 app.py'

//                         sh 'nohup flask run &'
//                         sh 'pytest -s -rA --junitxml=logs/report.xml'
//                         input message: 'Finished using the web site? (Click "Proceed" to continue)'
//                         sh 'pkill -f flask'
// 					}
// 				}
// 				stage('Headless Browser Test') {
// 					steps {
//                         // sh 'pytest -s -rA --junitxml=logs/report.xml'
//                         // sh 'pkill -f flask'
//                         sh 'echo "hello" '
// 					}
// 					// post {
//                     //     always {
//                     //         junit testResults: 'logs/report.xml'
//                     //     }
//                     // }
// 				}
// 			}
// 		}

        
//         // stage('Deliver') {
//         //     steps {
//         //         // build brand new bagatea-container with bagatea-image
//         //         sh """docker run -u root -d --name 3x03-con \
//         //         -v /var/run/docker.sock:/var/run/docker.sock \
//         //         -v "$HOME":/home \
//         //         -p 5000:5000 \
//         //         3x03-img"""
//         //     }
//         // }
//     }

// }

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
                sh 'docker build -t 3x03-img:latest .'
            }
        }
    
        stage('Test') {
            agent {
                docker {
                    image '3x03-img:latest'
                }
            }
            steps {
                script {
                    try {
                        // stop bagatea-container
                        sh 'yes | docker stop 3x03-con'
                    }
                    catch (Exception e) {
                        echo "no container to stop"
                    }

                    try {
                        // delete bagatea-container
                        sh 'yes | docker rm 3x03-con'
                    }
                    catch (Exception e) {
                        echo "no container to remove"
                    }
                }

                sh """docker run -it -u root -d --rm -p 5000:5000 --name thecon \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v "$HOME":/home \
                -e VIRTUAL_PORT=5000 \
                python:3.9"""

                sh 'nohup flask run &'
                sh 'pytest -s -rA --junitxml=logs/report.xml'
                input message: 'Finished using the web site? (Click "Proceed" to continue)'
                sh 'pkill -f flask'
            }
            post {
                always {
                    junit testResults: 'logs/report.xml'
                }
            }
        }
        
        stage('Deliver') {
            steps {
                script {
                    try {
                        // stop bagatea-container
                        sh 'yes | docker stop 3x03-con'
                    }
                    catch (Exception e) {
                        echo "no container to stop"
                    }

                    try {
                        // delete bagatea-container
                        sh 'yes | docker rm 3x03-con'
                    }
                    catch (Exception e) {
                        echo "no container to remove"
                    }
                }
                
                // build brand new bagatea-container with bagatea-image
                sh """docker run -u root -d --name 3x03-con \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v "$HOME":/home \
                -p 5000:5000 \
                3x03-img"""
            }
        }
    }
    
}
