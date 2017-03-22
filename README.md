# rhev-backup-restore-vms
A way, developed to perform a backup and restore from virtual machines servers running on RedHat Enterprise Virtualization.

To develop these scripts, we used the RHEV 4.0 version.

The backup process from VMs running on RHEV was developed considering basicaly three steps:

  1- Run the oVirtBackup-master script;
  2- Run the catalog script;
  3- Run the backup tool do backup the files in the backup_vms directory.
  
The restore process consist in three steps:
  
  1- Restore the VM directory from the specific day to the backup_vms directory.
  2- Run the restore-vm.sh script to send the files to the correct places.
  3- Import the VM from EXPORT_DOMAIN storage tab.
  
  
  The files will be placed to download in a few days. We are in process to translate the scripts.
