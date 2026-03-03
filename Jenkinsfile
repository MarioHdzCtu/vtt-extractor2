pipeline{
    agent { label 'ubuntu-agent' }

    stages {
        stage('Dependency Security Scan') {
            agent {
                docker {
                    image 'python:3.13-slim'
                    // Ensure the container has the right permissions to see the workspace
                    args '-u root:root --entrypoint=""'
                    reuseNode true 
                }
            }
            environment {
                SAFETY_API_KEY = credentials('SafetyAPIKey')
            }
            steps {
                // This echo confirms we are actually INSIDE the step
                echo "Starting Safety Scan..." 
                sh """
                    set -x
                    # Check if uv is already there, otherwise install
                    pip install uv safety --quiet
                    # Export and scan
                    uv export --format requirements-txt > exported-requirements.txt
                    
                    # Use 'check' instead of 'scan' (check is the standard command for requirements files)
                    safety check --key \$SAFETY_API_KEY -r exported-requirements.txt --full-report
                """
            }
        }
        stage('Vulnerability Scan (Grype)') {
            // We use the node's shell instead of a Docker agent
            steps {
                script {
                    // This command runs the container once, performs the scan, and disappears
                    sh "docker run --rm -v ${WORKSPACE} -w /src anchore/grype:latest . --fail-on high"
                }
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