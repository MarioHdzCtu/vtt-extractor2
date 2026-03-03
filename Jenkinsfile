pipeline{
    agent none

    stages {
        stage('Dependency Security Scan') {
            environment {
                SAFETY_API_KEY = credentials('safety-api-key')
            }
            agent {
                docker {
                    image 'python:3.13-slim'
                    args '-u root --entrypoint=""'
                    reuseNode true 
                }
            }
            steps {
                sh """
                # Install uv and safety
                pip install uv safety
                
                # Export the completely resolved, locked dependencies into a format Safety understands
                uv export --format requirements-txt > exported-requirements.txt
                
                # Run the scan. If vulnerabilities are found, this returns a non-zero exit code
                # and Jenkins will immediately turn the stage red and fail the pipeline.
                safety scan --key \$SAFETY_API_KEY -r exported-requirements.txt --full-report --non-interactive
                """
            }
        }
        stage('Vulnerability Scan (Grype)') {
            agent {
                docker {
                    // Using the official Grype image
                    image 'anchore/grype:latest'
                    // We run as root to ensure it can read all files in the workspace
                    args '-u root --entrypoint=""'
                    reuseNode true 
                }
            }
            steps {
                sh """
                # Scan the current directory (the root of your repo)
                # --fail-on high: This tells Jenkins to BREAK the build if 
                # any High or Critical vulnerabilities are found.
                grype . --fail-on high
                """
            }
        }
        stage('Unit Tests & Coverage') {
            agent {
                docker {
                    image 'python:3.13-slim'
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
                      -Dsonar.sources=. \
                      -Dsonar.python.coverage.reportPaths=coverage.xml
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