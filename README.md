# Enable Hyper-V power adapter in MaaS

There are two parts to the process:

  * enable WinRM on the hypervisor
  * patch MaaS to enable the new adapter

To enable WinRM over SSL on the hypervisor, simply download SetupWinRMAccessSelfSigned.ps1 and execute:

```powershel
powershell.exe -ExecutionPolicy RemoteSigned SetupWinRMAccessSelfSigned.ps1
```

Please note that this script will:

  * Download Visual C++ redistreibutable package and install it
  * Download and install OpenSSL
  * generate a self signed certificate
  * Enable WinRM service with SSL support

After WinRM is enabled on the hypervisor, simply clone this repo on your MaaS node and run:

```bash
sudo install-adapter.sh
```

This patch will work for version 1.7.1+bzr3341 of MaaS. Do not expect this to work for later versions. However, the change is small and you should be able to easily adapt to any new changes ;).

To check if the power adapter works, enlist one Hyper-V VM in your MaaS, edit the node, and set the Hyper-V power adapter with the apropriate auth values. Clicking the "Check power state" button in the node view should tell you immediately if it works or not.

