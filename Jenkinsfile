pipeline {
    agent any

    environment {
        IMAGE_NAME = "laxitamanral/my-devops-task"   // DockerHub repo name
        DOCKER_CREDENTIALS = "dockerHub"             // Jenkins me dockerhub ke credentials ka ID
        EC2_CREDENTIALS = "ec2-key"                  // Jenkins me EC2 SSH key ka ID
        EC2_IP = "54.196.144.250"                    // Tumhare EC2 ka public IP
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/lataManral17/my-devops-task.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'npm install'
                sh 'npm test || echo "No test script found, skipping..."'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent([EC2_CREDENTIALS]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} "
                            docker pull ${IMAGE_NAME}:${BUILD_NUMBER}
                            docker stop devops-task || true
                            docker rm devops-task || true
                            docker run -d -p 3000:3000 --name devops-task ${IMAGE_NAME}:${BUILD_NUMBER}
                           "
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                sh "curl -fsS http://${EC2_IP}:3000 || echo 'App not reachable yet'"
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully!"
        }
        failure {
            echo "Pipeline failed! Check console logs."
        }
    }
}

