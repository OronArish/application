def RELEASE_TAG='1.0.0'

pipeline {
    agent any
    environment {
        ECR_REGISTRY = '644435390668.dkr.ecr.ap-south-1.amazonaws.com'
        IMAGE_NAME = 'oron-portfolio-app'
        REGION = 'ap-south-1'
        GITOPS_REPO = 'git@gitlab.com:orondevops1/gitops-config.git'
    }
    triggers {
        gitlab(triggerOnPush: true, triggerOnMergeRequest: false, branchFilterName: 'All')
    }

    stages {
        stage('Build Image') {
            steps {
                script {
                    echo "Building Docker image with tag: latest"
                    sh "docker build -t ${ECR_REGISTRY}/${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Unit tests') {
            steps {
                script {
                    sh '''
                    chmod +x ./tests/e2e_tests.sh
                    chmod +x ./tests/unit_tests.sh
                    docker compose up -d --build
                    docker network create test-network || true 
                    docker network connect test-network ubuntu-jenkins-1 || true  
                    docker network connect test-network nginx-container || true 
                    '''
                    def output = sh(script: './tests/unit_tests.sh', returnStdout: true).trim()
                    echo "Unit Test Output: ${output}"
                }
            }
        }

        stage('E2E Tests') {
            steps {
                script {
                    def output = sh(script: './tests/e2e_tests.sh', returnStdout: true).trim()
                    echo "e2e tests Output: ${output}"
                    sh '''
                    docker network disconnect test-network ubuntu-jenkins-1
                    docker network disconnect test-network nginx-container
                    docker network rm test-network
                    docker compose down
                    '''
                }
            }
        }

        stage('Version') {
            steps {
                script {
                    sshagent(['gitlab-ssh-key']) {
                        echo "Fetching tags from git"
                        sh 'git fetch --tags'
                        def git_tags = sh(script: "git tag -l --sort=-v:refname", returnStdout: true).trim()
                        echo "Git tags: ${git_tags}"
                        if (git_tags) {
                            def last_version = git_tags.tokenize("\n")[0]
                            last_version = last_version.tokenize("-")[0]
                            def last_version_parts = last_version.tokenize(".")
                            def last_digit = last_version_parts[2].toInteger() + 1
                            RELEASE_TAG = "${last_version_parts[0]}.${last_version_parts[1]}.${last_digit}"
                            echo "New release tag: ${RELEASE_TAG}"
                        } else {
                            echo "No existing tags found, using default tag: ${RELEASE_TAG}"
                        }
                    }
                }
            }
        }

        stage('Tag Image with New Tag') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "Tagging Docker image with new tag: ${RELEASE_TAG}"
                    sh "docker tag ${ECR_REGISTRY}/${IMAGE_NAME}:latest ${ECR_REGISTRY}/${IMAGE_NAME}:${RELEASE_TAG}"
                }
            }
        }

        stage('Tag') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sshagent(['gitlab-ssh-key']) {
                        sh "git config --global user.email 'jenkins@example.com'"
                        sh "git config --global user.name 'Jenkins'"
                        def version = "${RELEASE_TAG}".replaceAll('^v', '')
                        echo "Creating new git tag: ${version}"
                        sh "git tag -a ${version} -m 'New release'"
                        sh "git push origin ${version}"
                    }
                }
            }
        }

        stage('Publish to ECR') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'ee8c78f8-da06-49da-9325-41e865e3b53b']]) {
                        sh "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY"
                        echo "Pushing Docker image with tag: ${RELEASE_TAG} to ECR"
                        sh "docker push $ECR_REGISTRY/$IMAGE_NAME:${RELEASE_TAG}"
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sshagent(['gitlab-ssh-key']) {
                        if (!fileExists('gitops-repo')) {
                            sh "git clone ${GITOPS_REPO} gitops-repo"
                        } else {
                            echo "Directory 'gitops-repo' already exists. Skipping cloning."
                        }
                        sh """
                        cd gitops-repo
                        cd infra/carapp
                        sed -i 's|tag: .*|tag: ${RELEASE_TAG}|g' values.yaml
                        sed -i 's|version: .*|version: ${RELEASE_TAG}|g' Chart.yaml
                        git add .
                        git commit -m "Update image tag and chart version to ${RELEASE_TAG}"
                        git push
                        """
                    }
                }
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
            sh 'docker compose down || true'
            cleanWs()
        }
    }
}
