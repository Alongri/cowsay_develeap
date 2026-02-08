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
                sh '''
                    docker build -t ${APP_NAME}:${BUILD_NUMBER} .
                    docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest
                    echo "Docker image built successfully"
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests on Docker container...'
                sh '''
                    # Start container in background
                    CONTAINER_ID=$(docker run -d -p 8080:8080 ${APP_NAME}:latest)
                    echo "Container started with ID: $CONTAINER_ID"
                    
                    # Wait for application to start
                    sleep 5
                    
                    # Test if application is responding
                    echo "Testing application endpoint..."
                    if curl -f http://localhost:8080 > /dev/null 2>&1; then
                        echo "✓ Application is responding successfully"
                    else
                        echo "ERROR: Application is not responding"
                        docker logs $CONTAINER_ID
                        docker stop $CONTAINER_ID
                        docker rm $CONTAINER_ID
                        exit 1
                    fi
                    
                    # Test with a custom text parameter
                    echo "Testing custom text endpoint..."
                    if curl -f http://localhost:8080/hello > /dev/null 2>&1; then
                        echo "✓ Custom text endpoint working"
                    else
                        echo "WARNING: Custom text endpoint test failed"
                    fi
                    
                    # Verify container is running properly
                    if docker ps | grep -q $CONTAINER_ID; then
                        echo "✓ Container is running"
                    else
                        echo "ERROR: Container stopped unexpectedly"
                        docker logs $CONTAINER_ID
                        exit 1
                    fi
                    
                    # Clean up
                    docker stop $CONTAINER_ID
                    docker rm $CONTAINER_ID
                    echo "All tests passed successfully"
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
            sh '''
                # Clean up any running containers
                docker ps -a | grep ${APP_NAME} | awk '{print $1}' | xargs -r docker rm -f || true
            '''
        }
    }
}

