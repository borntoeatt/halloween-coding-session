pipeline {
  agent any

  parameters {
    string(name: 'TEST_ROLES', defaultValue: 'nextcloud,grafana', description: 'Comma-separated container roles')
  }

  environment {
    PROXMOX_TOKEN = credentials('proxmox-token')
  }

  stages {
    stage('Deploy Test Containers') {
      steps {
        withCredentials([
          sshUserPrivateKey(credentialsId: 'SSH_PRIVATE', keyFileVariable: 'SSH_KEY_FILE', usernameVariable: 'SSH_USER')
        ]) {
          sh '''
            chmod +x proxmox-pipeline-test/scripts/deploy.sh
            export SSH_KEY_FILE=${SSH_KEY_FILE}
            export SSH_USER=${SSH_USER}
            ./proxmox-pipeline-test/scripts/deploy.sh ${TEST_ROLES}
          '''
        }
      }
    }
  }
}
