#!/usr/bin/env groovy

@Library('global-pipeline-libraries') _

pipeline {

    agent {
        label 'ec2'
    }

    options {
        skipDefaultCheckout true
        timeout(time: 10, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
    }

    // allow retesting upon github comment
    triggers {
        issueCommentTrigger('.*test this please.*')
    }

    environment {
        PRODUCT = 'acceleration'
        APP = 'pre-commit-hooks'
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm: [
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                        extensions: [[$class: 'CloneOption', noTags: false, reference: '', shallow: false]],
                        userRemoteConfigs: scm.userRemoteConfigs
                ]
            }
        }

        // Ensure pre-commit succeeds across the repository before proceeding.
        stage('pre-commit') {
            agent {
                docker {
                    image "docker.werally.in/build-utilities/pre-commit:1.17.0"
                    reuseNode true
                    label "ec2"
                    args "--network host -v /etc/passwd:/etc/passwd:ro"
                }
            }
            environment {
                HOME = "${env.WORKSPACE}"
            }
            steps {
                sshagent(credentials: ['github-ssh-key']) {
                    sh '/usr/local/bin/pre-commit run -a'
                }
            }
        }
    }
}
