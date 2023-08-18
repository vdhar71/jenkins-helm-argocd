pipeline {
    agent any
    environment {
        GIT_URL = 'https://github.com/vdhar71/jenkins-helm-argocd.git'
        registry = 'vdhar/gradle-petclinic'
        PATH='/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/opt/homebrew/bin:.:..'
        IMG_VER='2'
    }
    stages {
        stage('Trivy scan before checkout') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh 'docker login -u ${username} -p ${password}'
                    sh 'trivy repo $GIT_URL --scanners vuln,secret,config,license --dependency-tree'
                }
            }
        }
        stage('Git Checkout') {
            steps {
               checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/vdhar71/jenkins-helm-argocd.git']])
            }
        }
        stage('Trivy scan after checkout') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh 'docker login -u ${username} -p ${password}'
                    sh 'trivy fs . --scanners vuln,secret,config,license --dependency-tree'
                }
            }
        }
        stage('Build JAR using Gradle') {
            steps {
                sh './gradlew build'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t vdhar/gradle-petclinic:${IMG_VER}.${BUILD_NUMBER} .'
            }
        }
        stage('Trivy scan after image creation') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh 'docker login -u ${username} -p ${password}'
                    sh 'trivy image vdhar/gradle-petclinic:${IMG_VER}.${BUILD_NUMBER} --scanners vuln,secret,config,license --dependency-tree'
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh 'docker login -u ${username} -p ${password}'
                    sh 'docker push vdhar/gradle-petclinic:${IMG_VER}.${BUILD_NUMBER}'
                }
            }
        }
        stage('Helm deploy Kubernetes Cluster') {
            steps {
                script {
                    sh 'helm upgrade argocd helm-petclinic --install --namespace helm-petclinic --create-namespace --set image.tag=${IMG_VER}.${BUILD_NUMBER} '
                }
            }
        }
        stage('Trivy scan Kubernetes') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'password', usernameVariable: 'username')]) {
                    sh 'docker login -u ${username} -p ${password}'
                    sh 'trivy k8s --report summary cluster'
                }
            }
        }
    }
}
