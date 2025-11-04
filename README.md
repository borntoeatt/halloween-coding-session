📖 Project Overview
This project automates the provisioning of LXC containers on a Proxmox Virtual Environment using Terraform, orchestrated through a Jenkins pipeline. It was built during a hands-on debugging and infrastructure session focused on making deployments safe, repeatable, and production-ready.

🔧 What It Does
Uses Terraform to define and manage container infrastructure

Leverages Jenkins to run the pipeline automatically on code changes

Deploys two containers: testbox and nextcloud, cloned from a base template

Injects SSH keys for secure access

Ensures idempotency: containers are not recreated if they already exist

⚙️ Jenkins Setup
🧩 Jenkins Master
Dockerized on Raspberry Pi 5

🧱 Jenkins Workers
Hosted as Proxmox LXC containers

CPU: 2 cores

Memory: 512 MB

Utilization: ~60–70%

Suggested Architecture Diagram
<pre>
Code
+---------------------+
|   GitHub Repo       |
|(Terraform + Ansible)|
+---------------------+
          |
          v
+---------------------+
|     Jenkins Master  |
|   (Raspberry Pi 5)  |
+---------------------+
          |
          v
+---------------------+
| Jenkins Workers     |
| (Proxmox LXC: 2 CPU |
|  512MB RAM each)    |
+---------------------+
          |
          v
+---------------------+
| Proxmox VE          |
| Deploys Containers  |
| testbox + nextcloud |
+---------------------+
</pre>

## 💡 Get Started

Feel free to consume this and use it as a starting point to automate your CI/CD pipelines for your homelab ❤️
