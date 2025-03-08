pipeline {
    agent any
    tools {
        maven "MAVEN3.9"
        jdk "JDK17"
    }

    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        imageName = "842675975596.dkr.ecr.ap-south-1.amazonaws.com/devopsimg"
        ECR_REPOSITORY = "842675975596.dkr.ecr.ap-south-1.amazonaws.com"
        cluster = "DevOps-01"
        service = "DevOpsappsvc"
    }    

    stages {
        stage('Fetch code') {
            steps{
                git branch: 'ECS-Deploy', url: 'https://github.com/Azharpasha1996/DevOps.git'
            }
        }

        stage('Build') {
            steps{
                sh 'mvn install -DskipTests'
            }
            post {
                success{
                    echo "Archiving artifact"
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Unit Test') {
            steps{
                sh 'mvn test'
            }
        }

        stage('Checkstyle Analysis') {
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }

        
        stage("Build App Image") {
            steps {

                script {
                    // Build the docker image.
                    sh """
                    docker build -t ${imageName}:${BUILD_NUMBER} .
                    """
                }

            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    // Login to ECR
                    withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                                     string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}
                        """
                    }
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    // Push the tagged Docker image to ECR
                    sh """
                        docker push ${imageName}:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Remove Container Images') {
            steps{
                sh 'docker rmi -f $(docker images -a -q)'
            }
        }

        stage('Deploy To ECS') {
            steps{
                script {
                    withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                                     string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment'
                        """
                    }    
                }
            }
        }                   

    }

}
