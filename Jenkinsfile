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
                    sh "docker build -t ${ECR_REGISTRY}/${IMAGE_NAME}:${RELEASE_TAG} ."
                }
            }
        }

        stage('Unit tests') {
            steps {
                script {
                    sh '''
                    chmod +x ./tests/e2e_tests.sh
                    chmod +x ./tests/unit_tests.sh
                    ./tests/unit_tests.sh
                    '''
                }
            }
        }

        stage('E2E Tests') {
            steps {
                script {
                    sh '''
                    docker compose up -d
                    sleep 10
                    ./tests/e2e_tests.sh
                     docker compose down
                    '''
                }
            }
        }
        stage('Version') {
            steps {
                script {
                    sshagent(['gitlab-ssh-key']) {
                    def last_digit = 0
                    echo "Fetching tags from git"
                    sh """git fetch --tags"""
                    def git_tags= sh(script: "git tag -l --sort=-v:refname", returnStdout: true).trim()
                    echo "Git tags=${git_tags}"
                    if(git_tags != "") {
                        last_version = git_tags.tokenize("\n")[0]
                        last_version = last_version.tokenize("-")[0]
                        last_version = last_version.tokenize(".")
                        last_digit = last_version[2].toInteger()
                        last_digit += 1
                        RELEASE_TAG="${last_version[0]}.${last_version[1]}.${last_digit}"
                    }
                }
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
                        def version = "${RELEASE_TAG}"
                        version = version.replaceAll('^v', '')
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
//