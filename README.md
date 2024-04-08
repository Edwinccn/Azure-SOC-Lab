# Azure - Building a Honeynet and SOC using Cloud Capabilities

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/1995a0d9-06be-43c7-ad60-656ba28af8d1)



## Introduction

In this project, I used Microsoft Azure to build a Honeynet and Security Operations Center (SOC). I then simulated an attack on the resources within my environment, and exposed the VMs for 12 hours. Security metrics such as number of Windows Event Logs or number of Linux Syslogs were measured. After analyzing, containing, and eradicating the security incidents generated from my Cloud based SIEM, and recovering the environment, I further hardened the environment. The system is monitored for another 12 hours and measured again to validate the effectiveness of the improvements.

<b>Purpose of my Lab is as follows:</b>

<li>To explore Cloud Vendor capabilities with Azure: 
<br>Azure Sentinel, Log Analytics Workspace, Microsoft Defender for Cloud, Azure AD (currently Entra ID)</li>
<li>To build and simulate a SOC with SIEM and Threat Intelligence capabilities and use it for Security Incident Responses according to NIST 800-61</li>
<li>To build a honeynet and examine live attack attempts and traffic</li>
<br>

You can find within my respository, the scripts I created to simulate the attacks, the Alerts (KQL and JSON) to detect particular attacks, and the JSON file to display the World Map displaying the geolocation of the cities where the attacks are coming from.


## SOC Overview

The main components of my Azure based SOC are as follows:
<li> <b>Log Analytics Workspace (LAW):</b> Ingest logs from resources such as VMs, Key Vaults, Activity Logs and store them for analysis using Kusto Query Language (KQL)</li>
<br>
<li><b>Microsoft Sentinel:</b> This will be the SIEM which monitors and periodically queries LAW to generate alerts based on security events. Same instances of the alerts within the same period are grouped into Incidents. At the moment, the alerts available are meant to detect events from my planned Attack Vector (see Attack Simulation below). Two maps are also created to visualize geographically the IP addresses responsible for the security events 
<br>
<br>
-<i>Alerts:</i> https://github.com/Edwinccn/Azure-SOC-Lab/tree/main/Sentinel_AnalyticsRules
<br>
-<i>World Map:</i> https://github.com/Edwinccn/Azure-SOC-Lab/tree/main/Sentinel_Maps
</li>
<br>
<li><b>Microsoft Defender for Cloud:</b> Further analyzes logs from LAW and environment to provide Threat Intelligence to the Incidents generated from Sentinel. It also analyzes the environment and provides recommendations to further improve the overall security posture / score as according Compliance plans selected (ie.NIST 800-63) </li>
<br>
In essence: 
<br>
LAW stores logs --> Defender enhances analysis on logs --> Sentinel creates incidents from events found in logs

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/be0a46f1-a739-4705-b16c-29a48bd2ac0b)


## Honeynet Overview

The Honeynet is the environment where the simulated attack will take place, eventually making it exposed 

There are 2 VMs within the same Virtual Network and Subnet - one Windows and Linux. They both have Network Security Groups (NSGs) enabled, allowing only certain IP addresses to pass. <br>
Microsoft Monitoring Agent (MMA) have been enabled for both of them so that Security Logs can be sent and ingested by LAW.
As I wanted to have an easier time simulating bruce force attempts for detection from my SOC, I had modified the Account Lockout Threshold policy within my Windows VM to never lock the accounts, and modified #MaxAuthTries in the sshd_config file within my Linux VM to allow for a large number of invalid signin attempts.
<br>
Within the Azure environment, a Key Vault with a Secret was setup containing the password to access the local Windows VM admin account. Tenant Level logging is enabled for view all the Sign in events from Azure AD user accounts (currently renamed Entra ID). Subscription / Resource Group Level logging is enabled to view Activity Logs, which allows me to view Control-Plane events, such as CRUD operations on resources (e.g. deleting a VM or modifying a NSG rule). Finally, Resource level logging is enabled to view Data Plane events such as captured VM security event logs (e.g. turning off Windows Firewall), or events related accessing the Key Vault secrets.

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/be5d945f-707b-491b-9f36-7d81ae998815)


## Attack Simulation

The purpose of the attack simulation is to test the effectiveness of the Incidents generated from Sentinel in detecting security events, especially when paired with Microsoft Defender for Cloud. Obviously, a large factor comes from how well designed the Alerts I created are in the first place. However, other factors are also important - such as the complexity of the KQLs required in order to detect simple events, the speed at which logs are ingested into LAW and sent to Sentinel, and whether Sentinel can provide insightful analysis and recommendations.
<br>
The Attack Vector is as follows: <br>
<ol>
  <li>Sign in to Attack VM (created in seperate Virtual Network and region). Use Attack VM for subsequent steps.</li>
  <li>Attempt unsuccessful signins on Windows VM for 10 times to simulate Brute Force attempts</li>
  <li>Brute force into Azure AD Global Admin account, and successfully sign on 6th attempt</li>
  <li>Change Inbound rules for Windows and Linux NSGs. Allow traffic from ANY source on ANY ports via ANY protocols </li>
  <li>Go to Azure Key Vault and read the Secret containg Windows VM local admin password</li>
  <li>Access Windows VM local admin account using password from compromised Secret</li>
  <li>Within Windows VM, turn off Windows Microsoft Defender</li>
  <li>Within Windows VM, create fake Malware with EICAR files</li>
  <li>Exit Windows VM</li>
  <li>Brute force Linux VM. Suceed signing on 11th attempt</li>
</ol>
To faciliate with the attack, I had created Powershell scripts to turn off the Windows Defender Firewall (executed within Windows VM), to generate fake malware EICAR files (executed within Windows VM), to fail SSH login to Linx VM admin account (executed within Attack VM). <br>
You may find the Attack Scripts at: https://github.com/Edwinccn/Azure-SOC-Lab/tree/main/Attack%20Scripts 


## Exposing to Live Traffic
s

## Security Incident Response (NIST 800-61)
s

## Hardening
s

## Before and After
s

## Conclusion
s



