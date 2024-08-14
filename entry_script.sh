#!/bin/bash

sudo yum update -y

sudo yum install -y docker

sudo systemctl start docker

sudo usermod -aG docker $USER

sudo chmod +x docker_pull_script.sh

sudo ./docker_pull_script.sh



# #!/bin/bash

# # Update the package list
# sudo apt-get update -y

# # Install necessary packages
# sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# # Add Docker’s official GPG key
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# # Add the Docker APT repository
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# # Update the package list again to include Docker's packages
# sudo apt-get update -y

# # Install Docker
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# # Start Docker service
# sudo systemctl start docker

# # Enable Docker to start at boot
# sudo systemctl enable docker

# # Verify Docker installation
# sudo docker --version
