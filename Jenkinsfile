pipeline {
  agent any

  parameters {
    string(name: 'TEST_ROLES', defaultValue: 'testbox,nextcloud,passgen',
           description: 'Comma-separated container roles to deploy')
  }

  environment {
    PROXMOX_TOKEN = credentials('proxmox-token')
    SSH_KEY       = credentials('ssh-key')
  }

  stages {

    stage('Deploy Test Containers') {
      steps {
        withCredentials([
          sshUserPrivateKey(credentialsId: 'SSH_PRIVATE',
                            keyFileVariable: 'SSH_KEY_FILE',
                            usernameVariable: 'SSH_USER')
        ]) {

          sh '''
            chmod +x proxmox-pipeline-test/scripts/deploy.sh

            export SSH_KEY_FILE=${SSH_KEY_FILE}
            export SSH_USER=${SSH_USER}
            export SSH_KEY="${SSH_KEY}"

            ###########################################
            # Convert TEST_ROLES into Terraform booleans
            ###########################################
            DEPLOY_TESTBOX=false
            DEPLOY_NEXTCLOUD=false
            DEPLOY_PASSGEN=false

            [[ "${TEST_ROLES}" == *"testbox"* ]]   && DEPLOY_TESTBOX=true
            [[ "${TEST_ROLES}" == *"nextcloud"* ]] && DEPLOY_NEXTCLOUD=true
            [[ "${TEST_ROLES}" == *"passgen"* ]]   && DEPLOY_PASSGEN=true

            echo "▶ Terraform variables:"
            echo "  testbox:   $DEPLOY_TESTBOX"
            echo "  nextcloud: $DEPLOY_NEXTCLOUD"
            echo "  passgen:   $DEPLOY_PASSGEN"

            ###########################################
            # Call deploy.sh with variables forwarded
            ###########################################
            ./proxmox-pipeline-test/scripts/deploy.sh \
              ${TEST_ROLES} \
              -var="deploy_testbox=${DEPLOY_TESTBOX}" \
              -var="deploy_nextcloud=${DEPLOY_NEXTCLOUD}" \
              -var="deploy_passgen=${DEPLOY_PASSGEN}"
          '''
        }
      }
    }

  }
}
