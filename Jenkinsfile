pipeline{
    agent none

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
                    pwd
                    ls
                    cd vtt-extractor2
                    sonar-scanner \
                      -Dsonar.projectKey=vtt-extractor2 \
                      -Dsonar.projectName=vtt-extractor2 \
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