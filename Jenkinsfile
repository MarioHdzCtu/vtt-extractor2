pipeline{
    agent none

    triggers { pollSCM('H/1 * * * *')} // Poll this branch every 1 minute

    stages {
        stage('SonarQube SAST Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    args '-u root --entrypoint=""'
                    reuseNode true 
                }
            }
            steps {
                // Ensure 'SonarQube' exactly matches the name in your Jenkins System configuration
                withSonarQubeEnv('SonarQube') {
                    sh """
                    cd ${PROJECT_NAME}
                    sonar-scanner \
                      -Dsonar.projectKey=${PROJECT_NAME} \
                      -Dsonar.projectName=${PROJECT_NAME} \
                      -Dsonar.sources=. 
                    """
                }
            }
        }  
        stage('Quality Gate Check') {
            steps {
                // Prevent the pipeline from hanging forever if the webhook fails to arrive
                timeout(time: 15, unit: 'MINUTES') {
                    // This pauses the pipeline. abortPipeline: true means it fails the build if code quality is bad!
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}