# Cheat Sheet: CI/CD Pipeline with Jenkins, Docker, and GitHub

This cheat sheet summarizes the key steps and commands to set up a Continuous Integration/Continuous Delivery (CI/CD) pipeline using Jenkins, Docker, and GitHub.

---

## Table of Contents

- [1. Prerequisites](#1-prerequisites)
- [2. Setting Up Git and GitHub](#2-setting-up-git-and-github)
- [3. Building and Testing the Sample Application](#3-building-and-testing-the-sample-application)
- [4. Setting Up Jenkins in a Docker Container](#4-setting-up-jenkins-in-a-docker-container)
- [5. Configuring Jenkins for the Pipeline](#5-configuring-jenkins-for-the-pipeline)
- [6. Creating Jenkins Jobs](#6-creating-jenkins-jobs)
  - [6.1. Build Job](#61-build-job)
  - [6.2. Test Job](#62-test-job)
- [7. Creating a Jenkins Pipeline with Jenkinsfile](#7-creating-a-jenkins-pipeline-with-jenkinsfile)
- [8. Automating Builds on Code Changes](#8-automating-builds-on-code-changes)
- [9. Useful Commands](#9-useful-commands)
- [10. Tips and Best Practices](#10-tips-and-best-practices)

---

## 1. Prerequisites

- **Docker** installed on your machine.
- **Git** installed and configured.
- A **GitHub** account.
- Basic knowledge of command-line operations.

---

## 2. Setting Up Git and GitHub

### Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Initialize Local Repository

```bash
git init
```

### Create GitHub Repository

- Go to GitHub and create a new repository named `cicd-sample-app`.

### Link Local Repository to GitHub

```bash
git remote add origin https://github.com/YourUsername/cicd-sample-app.git
```

### Push Initial Commit

```bash
git add .
git commit -m "Initial commit of sample application"
git push -u origin main
```

---

## 3. Building and Testing the Sample Application

### Make the Build Script Executable

```bash
chmod +x sample-app.sh
```

### Build and Run the Application

```bash
./sample-app.sh
```

### Verify the Application is Running

- Access the application at `http://localhost:5050/` or `http://<your-ip>:5050/` in a web browser.

### Stop and Remove the Running Container

```bash
docker stop samplerunning
docker rm samplerunning
```

---

## 4. Setting Up Jenkins in a Docker Container

### Pull the Jenkins Docker Image

```bash
docker pull jenkins/jenkins:lts
```

### Run the Jenkins Container

```bash
docker run -p 8080:8080 -u root \
  -v jenkins-data:/var/jenkins_home \
  -v $(which docker):/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$HOME":/home \
  --name jenkins_server jenkins/jenkins:lts
```

### Access Jenkins

- Navigate to `http://localhost:8080/` or `http://<your-ip>:8080/` in a web browser.

### Unlock Jenkins

- Retrieve the initial admin password from the Jenkins container logs or from `/var/jenkins_home/secrets/initialAdminPassword`.

### Install Suggested Plugins

- Proceed with the installation of suggested plugins during setup.

---

## 5. Configuring Jenkins for the Pipeline

### Install Necessary Plugins (if not installed)

- **Git Plugin**
- **Pipeline Plugin**

### Configure Jenkins Global Tools (if necessary)

- Ensure Jenkins has access to **Git** and **Docker**.

---

## 6. Creating Jenkins Jobs

### 6.1. Build Job

#### Create a New Freestyle Project

- **Job Name**: `BuildSampleApp`

#### Configure Source Code Management

- **Git Repository URL**: `https://github.com/YourUsername/cicd-sample-app.git`
- **Branch Specifier**: `*/main`

#### Add Build Step

- **Execute Shell**:

  ```bash
  cd cicd-sample-app
  bash ./sample-app.sh
  ```

#### Save and Build

- Click **Save** and then **Build Now** to run the build job.

### 6.2. Test Job

#### Create a New Freestyle Project

- **Job Name**: `TestSampleApp`

#### Configure Build Triggers

- **Build after other projects are built**
  - **Projects to watch**: `BuildSampleApp`

#### Add Build Step

- **Execute Shell**:

  ```bash
  RESPONSE=$(curl -s http://<APP_IP>:5050/)
  echo "$RESPONSE" | grep "You are calling me from <JENKINS_IP>"
  ```

- Replace `<APP_IP>` and `<JENKINS_IP>` with actual IP addresses.

#### Save and Build

- Click **Save** and then **Build Now** to test the job.

---

## 7. Creating a Jenkins Pipeline with Jenkinsfile

### Add a `Jenkinsfile` to Your Repository

Create a file named `Jenkinsfile` in the root of your repository with the following content:

```
  node {
    stage('Preparation') {
        catchError(buildResult: 'SUCCESS') {
            sh 'docker stop samplerunning || true'
            sh 'docker rm samplerunning || true'
        }
    }
    stage('Build') {
        build 'BuildSampleApp'
    }
    stage('Test') {
        build 'TestTSampleApp'
    }
}
```

### Commit and Push Changes

```bash
git add Jenkinsfile
git commit -m "Add Jenkinsfile for pipeline"
git push
```

### Create a New Pipeline Job in Jenkins

- **Job Name**: `SampleAppPipelineWithJenkinsfile`

### Configure the Pipeline

- **Pipeline script from SCM**
  - **SCM**: Git
  - **Repository URL**: `https://github.com/YourUsername/cicd-sample-app.git`
  - **Branches to build**: `*/main`
  - **Script Path**: `Jenkinsfile`

### Save and Build

- Click **Save** and then **Build Now** to run the pipeline.

---

## 8. Automating Builds on Code Changes

### Make a Change to the Application

- Modify a file, e.g., change the background color in `static/style.css`.

### Commit and Push Changes

```bash
git add static/style.css
git commit -m "Change background color"
git push
```

### Trigger the Pipeline

- Configure Jenkins to poll SCM or set up webhooks for automatic builds.

---

## 9. Useful Commands

### Git Commands

- **Initialize Repository**: `git init`
- **Add Files**: `git add .`
- **Commit Changes**: `git commit -m "message"`
- **Push to Remote**: `git push -u origin main`
- **Check Remote URL**: `git remote -v`

### Docker Commands

- **Build Image**: `docker build -t sampleapp .`
- **Run Container**: `docker run -d -p 5050:80 --name samplerunning sampleapp`
- **Stop Container**: `docker stop samplerunning`
- **Remove Container**: `docker rm samplerunning`
- **List Containers**: `docker ps -a`

### Jenkins Commands (within Pipeline)

- **Clean Workspace**: `cleanWs()`

---

This cheat sheet provides a concise overview of setting up a CI/CD pipeline using Jenkins, Docker, and GitHub. It covers the essential commands and configurations to build, test, and deploy a sample application. Use this as a quick reference guide during your lab assignment.

---

