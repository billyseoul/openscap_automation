# openscap_automation
# Ansible Infrastructure Deployment

This Terraform configuration file is used to deploy Ansible infrastructure in AWS. 
It'll create a VPC, subnet, security group, and AMI instances for the control and worker nodes.

# Ansible Playbook for OpenScap

The playbook should do the following:
- Update the current repo
- Install OpenScap
- Run scans with the openscap-scanner module
- Generate a report of current vulnerabilities and save it to an .XML file
- Apply STIGs to critical vulnerabilities for STIG compliance
- Restart firewalld service
