pipeline {
    agent any
    tools {
        maven "MAVEN3.9"
        jdk "JDK21"
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'   // AWS region
        S3_BUCKET = 'devops-project-001'    // S3 bucket in which artifact has to be uploaded
        ARTIFACT_PATH = '/var/lib/jenkins/workspace/pipeline-001/target/devops-v2-0.0.1-SNAPSHOT.war'   // path of the Artifact.
        imageName = "842675975596.dkr.ecr.ap-south-1.amazonaws.com/devopsimg"
        ECR_REPOSITORY = "842675975596.dkr.ecr.ap-south-1.amazonaws.com"
    }    

    stages {
        stage('Fetch code') {
            steps{
                git branch: 'master', url: 'https://github.com/Azharpasha1996/DevOps.git'
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

        stage('Sonar Code Analysis') {
            environment {
                scannerhome = tool 'sonar6.2'
            }
            steps {
                withSonarQubeEnv('sonarserver') {
                    sh '''${scannerhome}/bin/sonar-scanner -Dsonar.projectKey=devops \
                       -Dsonar.projectName=devops \
                       -Dsonar.projectVersion=1.0 \
                       -Dsonar.sources=src/ \
                       -Dsonar.java.binaries=target/test-classes/devops_v2/ \
                       -Dsonar.junit.reportsPath=target/surefire-reports/ \
                       -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                       -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''            
                }
            }
        }
        
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Upload to S3') {
            steps {
                // Use 'withCredentials' to inject AWS credentials securely
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'), 
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        // Upload the artifact to S3 bucket using the injected AWS credentials
                        sh """
                            aws s3 cp ${ARTIFACT_PATH} s3://${S3_BUCKET}/ --region ${AWS_DEFAULT_REGION}
                        """
                    }
                }
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
                            $(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})
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

    }

}