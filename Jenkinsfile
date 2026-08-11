
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "mathew9747/fastapi-app"
        GIT_REPO_NAME = "test-fastapi"
        GIT_USER_NAME = "mathewjohn90"
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Checkout') {
            steps {
                sh 'echo "checkout sucessfull"'
                  //  url: 'https://github.com/YOUR-GITHUB-USERNAME/YOUR-GITHUB-REPO.git'
            }
        }

        stage('SonarQube Analysis') {
      steps {
        script {
          def scannerHome = tool 'sonarscanner'
          withSonarQubeEnv('sonarqube') {
            sh """
              ${scannerHome}/bin/sonar-scanner \\
                -Dsonar.projectKey=flask-gitops-app \\
                -Dsonar.projectName='Flask GitOps App' \\
                -Dsonar.sources=app/ \\
                -Dsonar.language=py \\
                -Dsonar.python.version=3.11 \\
                -Dsonar.sourceEncoding=UTF-8
            """
          }
        }
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
                        git config user.email "mj442827@example.com"
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

