pipeline {
  agent any

  parameters {
    string(name: 'TEST_ROLES', defaultValue: 'nextcloud,grafana', description: 'Comma-separated container roles')
  }

  environment {
    PROXMOX_TOKEN = credentials('proxmox-token')
    SSH_KEY = credentials('ssh-key')
  }

  stages {
    stage('Deploy Test Containers') {
      steps {
        sh '''
          chmod +x proxmox-pipeline-test/scripts/deploy.sh
          ./proxmox-pipeline-test/scripts/deploy.sh ${TEST_ROLES}
        '''
      }
    }
  }
}
