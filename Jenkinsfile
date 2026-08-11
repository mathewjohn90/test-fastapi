```groovy
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "YOUR-DOCKERHUB-USERNAME/fastapi-app"
        GIT_REPO_NAME = "YOUR-GITHUB-REPO"
        GIT_USER_NAME = "YOUR-GITHUB-USERNAME"
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/YOUR-GITHUB-USERNAME/YOUR-GITHUB-REPO.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'

                    def dockerImage = docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}")

                    docker.withRegistry(
                        'https://index.docker.io/v1/',
                        'docker-cred'
                    ) {
                        dockerImage.push()
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Update Deployment File') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'github',
                        variable: 'GITHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        git config user.email "your-email@example.com"
                        git config user.name "${GIT_USER_NAME}"

                        sed -i "s|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g" k8s/deployment.yaml

                        git add k8s/deployment.yaml

                        git commit -m "Update FastAPI image tag to ${BUILD_NUMBER} [skip ci]" || echo "No changes to commit"

                        git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME}.git HEAD:main
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```
