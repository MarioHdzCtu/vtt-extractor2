pipeline{
    agent none

    triggers { pollSCM('H/1 * * * *')} // Poll this branch every 1 minute

    stages {
        stage("Secret Scanning") {
            agent {
                docker {
                    image 'trufflesecurity/trufflehog:latest'
                    label 'ubuntu-agent'
                    args '-u root --entrypoint=""'
                }
            }
            steps {
                sh 'trufflehog filesystem . --fail'
            }
        }   
    }
}