pipeline{
    agent none

    stages {
                stage('Unit Tests & Coverage') {
            agent {
                docker {
                    image 'python:3.12-slim'
                    args '-u root --entrypoint=""'
                    reuseNode true 
                }
            }
            steps {
                sh """
                # Install uv
                pip install uv
                
                # Sync the environment (installs your app + pytest + pytest-cov)
                uv sync
                
                # Run the tests and generate the coverage.xml file
                uv run pytest --cov=. --cov-report=xml
                """
            }
        }
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