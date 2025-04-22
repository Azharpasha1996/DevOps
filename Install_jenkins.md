1. Copy the below code to install jenkins on the Ubuntu ec2
""" sh
#!/bin/bash
# Install openjdk 21 JRE
sudo apt update -y
sudo apt install openjdk-21-jre -y

# Download jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add jenkins repository to package manager resources
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package manager repositories
sudo apt-get update -y

# Install jenkins
sudo apt-get install jenkins -y

"""

2. Copy the below script to install docker on both jenkins and Sonarqube server

'''
#!/bin/bash

# Update package manager repositories
sudo apt-get update -y

# Install necessary dependencies
sudo apt-get install ca-certificates curl

# Create directory for docker GPG keys
sudo install -m 0755 -d /etc/apt/keyrings

# Download docker's GPG keys
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

#Ensure proper permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package manager repositories
sudo apt-get update -y

# install the latest version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


'''


3. Add the user jenkins to the docker group
'''
sudo usermod -aG docker jenkins
'''
'''
sudo usermod -aG docker ubuntu
'''

4. Run the command on the sonarqube server to run a docker container of sonarqube server

'''
docker run -d --name sonar -p 9000:9000 sonarqube:latest
'''
5. Install the below plugins in jenkins server

