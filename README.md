# Deploying Tendenci to Ubuntu/Debian Servers

This repo, aiming to ease the deployment process, consists of a set of scripts for deploying Tendenci to Ubuntu/Debian linux servers.

To deploy tendenci to your Ubuntu (12.04 or later) or Debian (7.1 or later) servers, follow the following steps (For Debian servers, make sure you have the `upstart` package installed before proceeding. `sudo dpkg --get-selections | grep upstart`).

**Step 1: Download the scripts to your server:**

	wget https://raw.github.com/tendenci/deploy_tendenci/master/ubuntu/server_setup.sh --no-check-certificate 
	wget https://raw.github.com/tendenci/deploy_tendenci/master/ubuntu/create_tendenci_site.sh --no-check-certificate 

**Step 2: Add the executable permission:**

	chmod +x server_setup.sh create_tendenci_site.sh

**Step 3: Run the scripts (should be run as root):**

	./server_setup.sh
	./create_tendenci_site.sh
