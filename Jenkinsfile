pipeline {
  agent any

  options {
    skipDefaultCheckout(true)
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timestamps()
  }

  environment {
    APP_NAME    = "male-fashion"
    IMAGE_NAME  = "male-fashion"                 // dùng image local, KHÔNG đẩy registry
    IMAGE_TAG   = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    JAVA_HOME   = tool(name: 'jdk-17', type: 'jdk')        // Manage Jenkins > Tools
    MAVEN_HOME  = tool(name: 'maven-3', type: 'maven')     // Manage Jenkins > Tools
    PATH        = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
    COMPOSE_FILE = "/srv/apps/male-fashion/docker-compose.yml" // nơi Jenkins deploy trên VPS
  }

  triggers {
    // Có webhook rồi thì có thể bỏ, giữ làm dự phòng
    pollSCM('H/2 * * * *')
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build & Test') {
      steps {
        sh '''
          if [ -x ./mvnw ]; then MVN=./mvnw; else MVN=mvn; fi
          $MVN -B -DskipTests=false clean verify
        '''
      }
      post {
        always { junit 'target/surefire-reports/*.xml' }
      }
    }

    stage('Package JAR') {
      steps {
        sh '''
          if [ -x ./mvnw ]; then MVN=./mvnw; else MVN=mvn; fi
          $MVN -B -DskipTests package
          ls -lh target/*.jar
        '''
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
        """
      }
    }

    stage('Deploy to VPS') {
      when { anyOf { branch 'main'; branch 'master'; branch 'prod' } }
      steps {
        sh """
          sudo mkdir -p \$(dirname ${COMPOSE_FILE})

          # Tạo docker-compose nếu chưa có
          if [ ! -f ${COMPOSE_FILE} ]; then
            cat > ${COMPOSE_FILE} << 'EOF'
          services:
            app:
              image: REPLACE_IMAGE
              container_name: springboot-app
              restart: unless-stopped
              ports:
                - "80:8080"                # public 80 -> Spring Boot 8080
              environment:
                JAVA_TOOL_OPTIONS: "-XX:+UseContainerSupport -Xms256m -Xmx512m"
              healthcheck:
                test: ["CMD", "wget", "-qO-", "http://localhost:8080/actuator/health"]
                interval: 20s
                timeout: 5s
                retries: 5
          EOF
          fi

          # cập nhật image sang tag mới nhất
          sudo sed -i "s|image: .*|image: ${IMAGE_NAME}:latest|g" ${COMPOSE_FILE}

          # triển khai
          sudo docker compose -f ${COMPOSE_FILE} pull || true
          sudo docker compose -f ${COMPOSE_FILE} up -d --force-recreate

          # dọn ảnh treo
          sudo docker image prune -f || true
        """
      }
    }
  }

  post {
    success { echo "Deployed ${IMAGE_NAME}:${IMAGE_TAG}" }
    always  { sh 'docker ps --format "table {{.Names}}\\t{{.Image}}\\t{{.Ports}}" || true' }
  }
}
