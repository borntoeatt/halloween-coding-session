pipeline {
  agent any

  parameters {
    string(name: 'TEST_ROLES', defaultValue: 'nextcloud,grafana', description: 'Comma-separated container roles')
  }

  environment {
    PROXMOX_TOKEN = credentials('proxmox-token-test')
    SSH_KEY = credentials('ssh-key-test')
  }

  stages {
    stage('Deploy Test Containers') {
      steps {
        sh '''
          chmod +x scripts/deploy.sh
          ./scripts/deploy.sh ${TEST_ROLES}
        '''
      }
    }
  }
}
