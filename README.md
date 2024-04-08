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


## SOC Components
The main components of my Azure based SOC are as follows:
<li> <b>Log Analytics Workspace (LAW):</b> Ingest logs from resources such as VMs, Key Vaults, Activity Logs and store them for analysis using Kusto Query Language (KQL)</li>
<br>
<li><b>Microsoft Sentinel:</b> This will be the SIEM which monitors and periodically queries LAW to generate alerts based on security events. Same instances of the alerts within the same period are grouped into Incidents. Two maps are also created to visualize geographically the IP addresses responsible for the security events </li>
<br>
<li><b>Microsoft Defender for Cloud:</b> Further analyzes logs from LAW and environment to provide Threat Intelligence to the Incidents generated from Sentinel. It also analyzes the environment and provides recommendations to further improve the overall security posture / score as according Compliance plans selected (ie.NIST 800-63) </li>
<br>

## Setup
There are two main parts to the setup - the Honeynet Environment and the SOC

Honeynet: 
<br>
There are 2 VMs within the same Virtual Network and Subnet - one Windows and Linux. They both have Network Security Groups (NSGs) enabled, allowing only certain IP addresses to access. <br>
Microsoft Monitoring Agent (MMA) have been enabled for both of them so that Security Logs can be sent and ingested by LAW.
As I wanted to have an easier time simulating bruce force attempts for detection from my SOC, I had modified the Account Lockout Threshold policy within my Windows VM to never lock the accounts, and modified #MaxAuthTries in the sshd_config file within my Linux VM to allow for a large number of invalid signin attempts.
<br>
Within the Azure environment

## Attack Simulation
s

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



