#!/bin/bash
# Set the variables for your environment
aws configure set region ca-central-1

# Grab latest backup from S3
mkdir /tmp/jenkins_backup
mkdir /tmp/jenkins_backup/data
cd /tmp/jenkins_backup
KEY=`aws s3 ls s3://${data_s3_bucket_name}/backup --recursive | sort | tail -n 1 | awk '{print $4}'`
aws s3 cp s3://${data_s3_bucket_name}/$KEY ./latest-backup.tar.gz

# Extract backup to jenkins_home
tar -xf latest-backup.tar.gz -C /var/lib/jenkins/
chown -R jenkins-local:jenkins-local /var/lib/jenkins/

# Create backup script on new master
cat <<EOF | tee /tmp/jenkins_backup/jenkins-s3-backup.sh

tar -C /var/lib/jenkins -cvpzf "/tmp/jenkins_backup/data/jenkins_backup_$(date '+%Y-%m-%d-%H').tar.gz" .
aws s3 mv "/tmp/jenkins_backup/data/jenkins_backup_$(date '+%Y-%m-%d-%H').tar.gz" s3://${data_s3_bucket_name}/backup/ --storage-class STANDARD_IA

EOF

# Add scheduler for backup script
crontab -l | { cat; echo "0 11-23 * * * /bin/bash /tmp/jenkins_backup/jenkins-s3-backup.sh > /tmp/jenkins_backup/jenkins-s3-backup.log"; } | crontab -
