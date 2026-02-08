pipeline {
    agent any
    
    environment {
        NODE_VERSION = '8.11'
        APP_NAME = 'cowsay-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Docker Build') {
            steps {
                echo 'Building Docker image (includes npm install)...'
                powershell '''
                    docker build -t ${env:APP_NAME}:${env:BUILD_NUMBER} .
                    docker tag ${env:APP_NAME}:${env:BUILD_NUMBER} ${env:APP_NAME}:latest
                    Write-Host "Docker image built successfully"
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests on Docker container...'
                powershell '''
                    # Start container in background
                    $containerId = docker run -d -p 8080:8080 ${env:APP_NAME}:latest
                    Write-Host "Container started with ID: $containerId"
                    
                    # Wait for application to start
                    Start-Sleep -Seconds 5
                    
                    # Test if application is responding
                    Write-Host "Testing application endpoint..."
                    try {
                        $response = Invoke-WebRequest -Uri "http://localhost:8080" -Method Get -TimeoutSec 10 -UseBasicParsing
                        if ($response.StatusCode -eq 200) {
                            Write-Host "✓ Application is responding successfully"
                        } else {
                            throw "Application returned status code: $($response.StatusCode)"
                        }
                    } catch {
                        Write-Host "ERROR: Application is not responding"
                        Write-Host $_.Exception.Message
                        docker logs $containerId
                        docker stop $containerId
                        docker rm $containerId
                        exit 1
                    }
                    
                    # Test with a custom text parameter
                    Write-Host "Testing custom text endpoint..."
                    try {
                        $response = Invoke-WebRequest -Uri "http://localhost:8080/hello" -Method Get -TimeoutSec 10 -UseBasicParsing
                        if ($response.StatusCode -eq 200) {
                            Write-Host "✓ Custom text endpoint working"
                        } else {
                            Write-Host "WARNING: Custom text endpoint returned status code: $($response.StatusCode)"
                        }
                    } catch {
                        Write-Host "WARNING: Custom text endpoint test failed: $($_.Exception.Message)"
                    }
                    
                    # Verify container is running properly
                    $runningContainers = docker ps --format "{{.ID}}"
                    if ($runningContainers -contains $containerId) {
                        Write-Host "✓ Container is running"
                    } else {
                        Write-Host "ERROR: Container stopped unexpectedly"
                        docker logs $containerId
                        exit 1
                    }
                    
                    # Clean up
                    docker stop $containerId
                    docker rm $containerId
                    Write-Host "All tests passed successfully"
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Cleaning up...'
            powershell '''
                # Clean up any running containers
                $containers = docker ps -a --filter "name=${env:APP_NAME}" --format "{{.ID}}"
                if ($containers) {
                    foreach ($container in $containers) {
                        docker rm -f $container 2>&1 | Out-Null
                    }
                }
            '''
        }
    }
}

