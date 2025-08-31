pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    environment {
        AWS_REGION = 'ap-southeast-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'access'
                ]]) {
                    withEnv(["AWS_DEFAULT_REGION=${env.AWS_REGION}"]) {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([file(credentialsId: 'tfvarsfile', variable: 'TFVARS_FILE')]) {
                    sh '''
                    terraform plan -var-file=$TFVARS_FILE
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'access'],
                    file(credentialsId: 'tfvarsfile', variable: 'TFVARS_FILE')
                ]) {
                    withEnv(["AWS_DEFAULT_REGION=${env.AWS_REGION}"]) {
                        sh '''
                            terraform apply -auto-approve -var-file=$TFVARS_FILE
                        '''
                    }
                }
            }
        }
    }
}
