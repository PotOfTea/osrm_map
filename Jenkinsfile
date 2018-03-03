pipeline {
  agent any

  triggers {
          cron('H 16 * * 0')
  }
  environment {
    docker_tool = "${tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'}"
    registry = 'docker-registry.com'
  }

  options {
    buildDiscarder(logRotator(numToKeepStr:'5'))
  }

  stages {
    stage('build and unit-test') {
      steps {
          checkout scm
          sh "$dockerTool/bin/docker-compose build"
          echo "Running mock unit tests"
      }
    }

    stage('Publish image') {
      steps {
         withCredentials([[$class: 'UsernamePasswordMultiBinding',
                            credentialsId: 'DOCKER_HUB_CRED',
                            usernameVariable: 'DH_USER',
                            passwordVariable: 'DH_PASS']])
          {
             sh "docker_tool/bin/docker login -u ${DH_USER} -p ${DH_PASS} ${registry}"
          }


      }
    }

    stage('Deploy Test') {
      agent { label 'test-server' }
      steps {
        checkout scm
        sh "docker_tool/bin/docker-compose up"
      }
    }

    stage('Smoke tests') {
      agent { label 'test-server' }
      steps {
        echo "Running mock smoke tests"
      }
    }

    stage('Deploy to UAT') {
        agent { label 'uat-server' }
        steps {
            sh "$docker_tool/bin/docker-compose up"
        }
    }

    stage('Run end-to-end tests') {
      agent { label 'test-server' }
      steps {
        echo "Running mock end-to-end tests"
      }
    }

    stage('Promote Image to prod-ready') {
      agent any
      steps {
        echo "Running mock image tagging "
      }
    }

    stage('Wait for approval') {
      agent any
      steps {
        script {
            env.deploy = input message: 'User input required', ok: 'Deploy!'
        }
      }
    }

    stage('Deploy to prod') {
        agent { label 'prod-server' }
        steps {
            sh "$docker_tool/bin/docker-compose up"
        }
    }

    stage('Promote Image to prod-deployed') {
      agent any
      steps {
        echo "Running mock image tagging "
      }
    }
  }
}
