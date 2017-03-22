#!/bin/sh

# Define your environment here. Here we have PRD, QAS and DEV
ENVIRONMENT=DEV
DATA=$(echo "`date +%Y%m%d`_$ENVIRONMENT")

# Define here the path of your EXPORT_DOMAIN directory
DIRRHEVEXPORT=/rhevexports/129e217c-218b-491c-8cdb-aef8b596391a

# Define here the destination path where the VMs' files will be moved to.
DIRBKPVMS=/rhevexports/backups_vms/$ENVIRONMENT

# Define here the detination path and file for the backup control file.
LOGOUTPUT=/usr/local/bin/oVirtBackup-master/logs/controle_backup_VMs_RHEV_$DATA.txt

cd $DIRRHEVEXPORT
if [ $? = "0" ]
then
  echo "EXPORT_DOMAIN Directory $DIRRHEVEXPORT found."
else
  echo "ERROR - EXPORT_DOMAIN Directory $DIRRHEVEXPORT does not exist."
  exit 1
fi

echo '' >> $LOGOUTPUT
echo '-----------------------------------------------------------------------------------------------------' >> $LOGOUTPUT
echo '' >> $LOGOUTPUT

for OVFFILE in $(find $DIRRHEVEXPORT -type f -name *.ovf)
do
  # Here we get the VM friendly name from OVF file
  VMNAME=$(cat $OVFFILE | sed -e 's/ovf:/\n/g' | sed -e 's/></\n/g' | grep '^Name>' | cut -d">" -f2 | cut -d"<" -f1)
  # Catalog file with VM's information, like OVF and disk files to be used in case of restore
  VMCATALOG=catalogo_$VMNAME.info
  echo "Name: $VMNAME" >> $LOGOUTPUT
  echo "Name: $VMNAME" >> $VMCATALOG
  echo "OVF File: $OVFFILE" >> $LOGOUTPUT
  echo "OVF File: $OVFFILE" >> $VMCATALOG
  cat $OVFFILE | sed -e 's/></\n/g' | grep -i "ovf:fileRef=" | cut -d' ' -f7,13 | sed -e 's/ovf://g' | sed -e 's/\"//g' | sed -e 's/fileRef/Disco/g'  | sed -e 's/disk-alias/Disco_Alias/g' >> $LOGOUTPUT
  cat $OVFFILE | sed -e 's/></\n/g' | grep -i "ovf:fileRef=" | cut -d' ' -f7,13 | sed -e 's/ovf://g' | sed -e 's/\"//g' | sed -e 's/fileRef/Disco/g'  | sed -e 's/disk-alias/Disco_Alias/g' >> $VMCATALOG

  # Create the directory with the VM friendly name
  mkdir $DIRBKPVMS/$VMNAME
  if [ $? = "0" ]
  then
    echo "VM directory $VMNAME created with success."
  else
    echo "ERROR to create the VM directory name $VMNAME"
    exit 1
  fi

  # Move the catalog file where the information like OVF and disks are, to the final directory destination
  mv $VMCATALOG $DIRBKPVMS/$VMNAME/

  if [ $? = "0" ]
  then
    echo "VM Catalog file from VM $VMNAME moved with success."
  else
    echo "ERROR to move the VM $VMNAME catalog file"
    exit 1
  fi

  # Copy the VM OVF file to the VM destination directory
  cp -p $OVFFILE $DIRBKPVMS/$VMNAME/
  if [ $? = "0" ]
  then
    echo "VM OVF File $VMNAME copied with success."
  else
    echo "ERROR to copy the $VMNAME OVF file."
    exit 1
  fi

  # Find the disk files and the metas to move them to the VM backup directory
  for DISKS in $(cat $OVFFILE | sed -e 's/></\n/g' | grep -i "ovf:fileRef=" | cut -d' ' -f7,13 | sed -e 's/ovf://g' | sed -e 's/\"//g' | awk '{print $1}' | sed -e 's/fileRef=//g' | awk -F"/" '{print $2}')
  do
    for DISKFILE in $(find $DIRRHEVEXPORT -type f -name $DISKS*)
    do
      mv $DISKFILE $DIRBKPVMS/$VMNAME/
      if [ $? = "0" ]
      then
        echo "Disk file $DISKFILE moved to VM backup directory."
      else
        echo "ERROR to move the disk file $DISKFILE to VM backup directory."
        exit 1
      fi
    done
  done

  echo '' >> $LOGOUTPUT
  echo '-----------------------------------------------------------------------------------------------------' >> $LOGOUTPUT
  echo '' >> $LOGOUTPUT
done

# Clean the remaining files and directories from /rhevexports filesystem
rm -rf $DIRRHEVEXPORT/images/* $DIRRHEVEXPORT/master/vms/*
if [ $? = "0" ]
then
  echo "Clean up performed with success."
else
  echo "ERROR trying to perform the clean up."
  exit 1
fi
