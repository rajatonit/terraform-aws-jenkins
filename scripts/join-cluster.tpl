#!/bin/bash

JENKINS_URL="${jenkins_url}"
JENKINS_USERNAME="${jenkins_username}"
JENKINS_PASSWORD="${jenkins_password}"

# Sleep until Jenkins master comes up
while [[ "$(curl -s -o /dev/null -w ''%%{http_code}'' $JENKINS_URL)" != "403" ]]
do
        sleep 5
done

TOKEN=$(curl -u $JENKINS_USERNAME:$JENKINS_PASSWORD ''$JENKINS_URL:8080'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
INSTANCE_NAME=$(curl -s 169.254.169.254/latest/meta-data/local-hostname)
INSTANCE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
JENKINS_CREDENTIALS_ID=$JENKINS_CREDENTIALS_ID

curl -v -u $JENKINS_USERNAME:$JENKINS_PASSWORD -H "$TOKEN" -d 'script=
import hudson.model.Node.Mode
import hudson.slaves.*
import jenkins.model.Jenkins
import hudson.plugins.sshslaves.SSHLauncher
import hudson.plugins.sshslaves.verifiers.*
SshHostKeyVerificationStrategy hostKeyVerificationStrategy = new NonVerifyingKeyVerificationStrategy()

DumbSlave dumb = new DumbSlave("'$INSTANCE_NAME'",
"'$INSTANCE_NAME'",
"/var/lib/jenkins_home",
"5",
Mode.NORMAL,
"slaves",
new SSHLauncher("'$INSTANCE_IP'", 22, SSHLauncher.lookupSystemCredentials("'$JENKINS_CREDENTIALS_ID'"), "", null, null, "", "", 60, 3, 15, hostKeyVerificationStrategy),
RetentionStrategy.INSTANCE)
Jenkins.instance.addNode(dumb)
' $JENKINS_URL/script


