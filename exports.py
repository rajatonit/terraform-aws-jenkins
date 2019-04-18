
from botocore.vendored import requests
import os
import re
import time
import json
import boto3

ec2 = boto3.client('ec2', region_name='ca-central-1')
asg = boto3.client('autoscaling', region_name='ca-central-1')
sns = boto3.client('sns', region_name='ca-central-1')

def test(event, context): 
    try:
        snsMessage = json.loads(event['Records'][0]['Sns']['Message'])
        ec2Id = snsMessage['EC2InstanceId']
    except:
        print ("Not an SNS Record")
        return 'done'


    r = requests.get('http://'+os.environ['jenkinsUrl']+':8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)' , auth=(os.environ['username'], os.environ['password']))
    token = r.content.split(":")
    print(token)
    
    ec2InstanceInfo = ec2.describe_instances(InstanceIds=[ec2Id])
    ec2InstanceDnsName = ec2InstanceInfo['Reservations'][0]['Instances'][0]['PrivateDnsName']
    print(ec2InstanceDnsName)
    print(re.search(r'ip-([0-9]+(-)?)*', ec2InstanceDnsName).group())
    
    instanceIp = re.search(r'ip-([0-9]+(-)?)*', ec2InstanceDnsName).group()
    
    test = """
import hudson.FilePath
import hudson.model.Node
import hudson.model.Slave
import jenkins.model.Jenkins
import groovy.time.*
Jenkins jenkins = Jenkins.instance
def jenkinsNodes = jenkins.nodes
for (Node node in jenkinsNodes) {
    // Make sure slave is online
    if (!node.getComputer().isOffline()) {
         if (node.getComputer().countBusy() == 0 && node.getComputer().name.contains("$ip")){
                node.getComputer().setTemporarilyOffline(true,null);
                node.getComputer().doDoDelete();
                println "1"
         }else if (node.getComputer().name.contains("$ip")){
             println "0"
         }
    }else{
      if( node.getComputer().name.contains("$ip")){
         println "1"
      }
    }
}
"""

    test = test.replace("$ip",instanceIp, 3)

    payload= {"script": test}
    
    finalResult = 0
    counter = 0
    
    while(True):
        r = requests.post(url = "http://"+os.environ['jenkinsUrl']+":8080/scriptText", data=payload,  auth=(os.environ['username'], os.environ['password']), headers={"Jenkins-Crumb":token[1]})
        print (r.content)
        if(re.search(r'1', r.content)):
            finalResult = 1
            break
        else:
            finalResult = 0
            if(counter == 3):
                break
            counter +=1
            time.sleep(120) 
        
    if(finalResult == 1):
        response = asg.complete_lifecycle_action(
            AutoScalingGroupName=snsMessage['AutoScalingGroupName'],
            LifecycleActionResult='CONTINUE',
            LifecycleActionToken= snsMessage['LifecycleActionToken'],
            LifecycleHookName=snsMessage['LifecycleHookName'],
        )
        print (response)
        message = {"message": "Successfuly shutdown instance: " + instanceIp}
        response = sns.publish(
            TargetArn=event['Records'][0]['Sns']['TopicArn'],
            Message=json.dumps({'default': json.dumps(message)}),
            MessageStructure='json'
        )
        print (response)
    else:
        response = asg.complete_lifecycle_action(
            AutoScalingGroupName=snsMessage['AutoScalingGroupName'],
            LifecycleActionResult='ABANDON',
            LifecycleActionToken= snsMessage['LifecycleActionToken'],
            LifecycleHookName=snsMessage['LifecycleHookName'],
        )
        print (response)
        message = {"message": "Was not able to shutdown instance: " + instanceIp + " please check if starving thread process is running in jenkins"}
        response = sns.publish(
            TargetArn=event['Records'][0]['Sns']['TopicArn'],
            Message=json.dumps({'default': json.dumps(message)}),
            MessageStructure='json'
        )
        print (response)
        
    return "done"