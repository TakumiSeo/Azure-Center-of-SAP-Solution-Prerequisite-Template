sudo apt update

# install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# login to Azure with service principal
az login --service-principal -u 
# install pip3
sudo apt install python3-pip -y
# install Ansible 2.9.27
sudo pip3 install ansible-core==2.13.13

sudo ansible-galaxy collection install ansible.netcommon:==5.0.0 -p /opt/ansible/collections
sudo ansible-galaxy collection install ansible.posix:==1.5.1 -p /opt/ansible/collections
sudo ansible-galaxy collection install ansible.utils:==2.9.0 -p /opt/ansible/collections
sudo ansible-galaxy collection install ansible.windows:==1.13.0 -p /opt/ansible/collections
sudo ansible-galaxy collection install community.general:==6.4.0 -p /opt/ansible/collections
# Clone SAP automation repo

git clone https://github.com/Azure/SAP-automation-samples.git
git clone https://github.com/Azure/sap-automation.git
cd sap-automation/

# change the branch
git checkout main


# ACSS supports the following SAP versions only: S/4HANA 1909 SPS 03, S/4HANA 2020 SPS 03, S/4HANA 2021 ISS 00
# contaner Base Path is like <https://sapbits10.blob.core.windows.net/sapbits>

export bom_base_name="S41909SPS03_v0011ms"
export s_user=
export s_password=
export storage_account_access_key=
export sapbits_location_base_path=
export BOM_directory="/home/sapbitadmin/SAP-automation-samples/SAP"
export orchestration_ansible_user="sapbitadmin"
export playbook_path="/home/sapbitadmin/sap-automation/deploy/ansible/playbook_bom_downloader.yaml"
sudo ansible-playbook ${playbook_path} \
-e "bom_base_name=${bom_base_name}" \
-e "deployer_kv_name=dummy_value" \
-e "s_user=${s_user}" \
-e "s_password=${s_password}" \
-e "sapbits_access_key=${storage_account_access_key}" \
-e "sapbits_location_base_path=${sapbits_location_base_path}" \
-e "BOM_directory=${BOM_directory}" \
-e "orchestration_ansible_user=${orchestration_ansible_user}"