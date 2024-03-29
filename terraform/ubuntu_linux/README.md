# Prerequisites:
* You have Internet access
* You possess an Azure subscription
* You possess the ability to install applications on the Information System (IS) being used.
* You possess the requisite permissions and access in your Azure tenant/subscription to create resources. 
* You have access to PowerShell 5.X or greater. <br />


# Instructions
0. [Works Cited:](https://www.youtube.com/watch?v=V53AHWun17s) A really helpful tutorial and great primer!

1. Login to your Azure Subscription via
[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

 
*** If required to login via Azure US Government Cloud *** <br />
    `az cloud set --name AzureUSGovernment`

```code
az login
```

2. Install Terraform
```code
https://developer.hashicorp.com/terraform/downloads
```


3. Download Github Repository
```code
git clone https://github.com/dcodev1702/azure_iac.git
```

4. Modify Terraform variables as required

* Modify terraform.tfvars  <br />
  - change the value for 'end_user' variable <br />
  - If necessary, change the 'ssh_key_name' variable value to the ssh key name you want to use for the creation of your Linux VM.
  - Use the same name that you provided in step 3 (above) when you created your ssh key. <br />
    ![image](https://github.com/dcodev1702/azure_iac/assets/32214072/fcc2f39d-68a5-41f7-a51a-f6af0026a596)




```code    
terraform fmt
```

5. Initialize Terraform (Azure -> Linux VM)
```code
terraform init
```

6. Verify Terraform Plan is compliant with sanity checks
```code
terraform plan
```

7. Provision and deploy Azure resources and Ubuntu 22.04 VM
```code
terraform apply -auto-approve
```

8. SSH into your newly provisioned Linux VM
```code
ssh -i ssh/secops-linux-tf.pem dcodev@<VM-PUBLIC-IP>
```

9. Connect VSCode via SSH

Select 'Connect to Host' (via SSH [~/.ssh/config])

![EA3FEB3B-1B2D-4CCB-BF19-97DF9452D4E3](https://user-images.githubusercontent.com/32214072/233232097-a908be86-eaad-4bcc-9879-6d3364b4b73f.jpeg)


Select the Linux VM provisioned in Azure -> 20.124.181.98 <br />
This entry was dynamically created through either windows_ssh_vscode.tpl or linux_ssh_vscode.tpl.

![3A6EEF48-BE37-43C6-93B9-7DACC0E6FCB2](https://user-images.githubusercontent.com/32214072/233232706-930d7fbb-7659-46de-9a10-f3e36bac5984.jpeg)


You are now connected to your Linux VM in Azure and can begin to use your newly provisioned resource.

![2792E2CE-3265-4424-A16B-CAC7D6D0FD85](https://user-images.githubusercontent.com/32214072/233232959-86daf19a-796f-4451-b788-212144beb4c7.jpeg)


11. Remove Resource Group, Ubuntu 22.04 VM & associated resources
```code
terraform apply -destroy -auto-approve
```
