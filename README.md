# Deploying Tendenci to Ubuntu/Debian Servers

This repo, aiming to ease the deployment process, consists of a set of scripts for deploying Tendenci to Ubuntu/Debian linux servers.

## 1. Deploying to Ubuntu Servers

**Step 1: Download the scripts to your server:**

	wget https://raw.github.com/tendenci/deploy_tendenci/master/ubuntu/server_setup.sh
	wget https://raw.github.com/tendenci/deploy_tendenci/master/ubuntu/create_tendenci_site.sh

**Step 2: Add the execute permission:**

	chmod +x server_setup.sh create_tendenci_site.sh

**Step 3: Run the scripts (should be run as root):**

	./server_setup.sh
	./create_tendenci_site.sh


## 2. Deploying to Debian Servers
