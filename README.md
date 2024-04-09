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

Rather than using Virtual Box on my local machine to simulate this, I chose Azure as I wanted to multiple VMs to run continuously for 12+ hours multiple times, and also to explore the features provided in Azure.
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
<br>
As I wanted to have an easier time simulating bruce force attempts for detection from my SOC: 
<li>I had modified the Account Lockout Threshold policy within my Windows VM to never lock the accounts</li>
<li>I modified MaxAuthTries in /etc/ssh/sshd_config file within my Linux VM to allow for a large number of invalid signin attempts.</li>
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
<br>
<i>Attack Scripts:</i> https://github.com/Edwinccn/Azure-SOC-Lab/tree/main/Attack%20Scripts 
<br>
After step 4 where I exposed both VMs by making their NSGs insecure, the VMs were vulnerable to Live attacks externally.
<br>

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/38d42b9b-6e54-4c2e-bf32-8a8e0dcde910)


## Exposing to Live Traffic

With the NSGs made ineffective, and Windows firewall turned off, both my Windows and Linux VMs were more vulnerable to attacks. During the 12 hours, I saw a spike in the number of Alerts detecting Brute Force attempts to both my VMs from various IP addresses all over the world. No other type of Alerts that I created were found during this time.

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/f4609c30-3f4a-457e-8437-7ee15439feda)

<br>
A quick ping test on Linux VM revaled that it was indeed open, whereas previously it could not be found with the NSG filtering out IP addresses for inbound traffic. A further Nmap test showed that SSH (port 22) was wide open as intended.

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/681522ff-dad3-480c-85e0-12f6e9d77bf7)



## Security Incident Response (NIST 800-61)

I used the Incident Handling Process inspired by NIST 800-61 to handle the Incidents, which involved using Incident Response Playbooks that I prepared ahead of time to tackle each type of Incident that came up. 
<br>
This involves: (1.) Incident Categorization and Priorization; (2.) Initial Response and Triage; (3.) Containment and Mitigation; (4.) Eradication and Recovery; (5.) Lessons Learned

Obviously, the situation presented is not realistic for a SOC as there is an intended 12+ hour delay, whereas the expectation for the SOC is a much shorter SLA and an urgency to contain the situation asap. However, this was still good practice to apply the procedures.
<br>
First, it is crucial to look at the bigger picture instead of focusing on each Incident one by one. This is to determine the scope and to have more information as some of the Incidents may be related. Although Sentinel has Severity Level defined, they are not as helpful in prioritizing Incidents with the same Severity Level (e.g. Azure AD Breach vs Windows Firewall Tampering both had High Severity, but the AD breach should take precedence in my situation).
<br> Sentinel's redeeming point is that it was able to analyze the Entities involve, and paint a timeline of all the incidents generated by the Attacker IP (my Attack VM). This allowed me to summarize the Attack Vector, determine the scope and priorize as part of Step 1, and aid in the subsquent responses including Containment.

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/8077aea5-5649-44b1-9212-bd9077751a37)

Microsoft Defender for Cloud was also able to send an email to my account notifying me of its findings in what it identied as a dictionary attack, which is what I tried to simulate.

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/1204b68c-e540-4b5c-816c-035d7ab6ec68)



<b>Steps Taken for Initial Response (handled as one big Incident):</b>
<ol>
  <li>Analysis: This was done using Sentinel and Threat Intelligence from Defender for Cloud (see above). The Attacker IP (my Attack VM) was focused on. Subsequent brute force attempts were performed by other IP addresses </li>
  <li>Triage: If there was a bigger team with different SMEs, they will be alerted if the Incident concerns their areas (ie. Infrastructure team who looks after the VMs, AD Platform team, application owners if applications were affected, management, etc.) </li>
</ol>

<b>Steps Taken for Containment / Mitigation (handled as one big Incident):</b>
<ol>
  <li>Revoked all sessions for compromised global admin account using Azure AD, disabled account, and reset password</li>
  <li>Turned off VMs to preserve state (for forensic evidence gathering)</li>
  <li>Isolated the VMs by adjusting NSGs to only only the investigator's IP address. An alternative approach was to put the VMs in another Virtual Network dedicated to containment, but this needed to be prepared ahead of time</li>
  <li>Reset passwords for the local admin accounts for both VMs</li>
  <li>In Windows VM, turned back on Windows Firewall</li>
  <li>In Windows VM, Windows Security had already Quarantined all the EICAR files. Another scan was ran to verify there was no more traces of malware.</li>
  <li>Disable Key Vault secret - although this was a High Severity alert, this was done last as the local Windows admin account password was already reset earlier</li>
</ol>

<b>Steps Taken for Recovery and Post Incident(handled as one big Incident):</b>
<ol>
  <li>Monitored for any further signs of breaches</li>
  <li>Returned the VM NSGs back to previous states, including ACLs of acceptable IP Addresses</li>
  <li>Key Vault re-enabled and updated with password</li>
  <li>Compromised secondary admin account in Azure AD will need further review and redesign</li>
</ol>

## Hardening

<b> Identity and Access Management</b>

The root cause of the major security incident stemmed from the secondary Azure admin account being compromised, and the account having too much privelege. Segregations of Duties and principles of Least Privigelge was not applied in my Honeynet environment.
To resolve this and to harden my environment, Multi-Factor Authentication needs to be implemented on all accounts, as well as Segreations of Duties meaning no one account can have too much permissions, and should only have the permissions required to perform its role.

For MFA, I will need to subscribe to Microsoft's Entra ID Governance plan to enable these options.
<br>
For Permissions management, I had removed the Global Administrator role from's its assignment as it had permissions to all aspects of Azure AD. I further removed Key Vault Administrator role permissions from the account assignment and assigned it to a seperate account dedicated to VM management. Finally, the account had Owner role assignnment to the Subscription / Resource Group of my lab, which allowed it to manage aspects of the resources within my lab including NSGs. I removed this permission as well. 

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/51d9f840-7ca9-4f85-853f-85eb46c1c4c2)

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/8c529d11-62f9-4add-b848-46a769d97d09)

<b> Key Vault </b>

The Key Vault itself was also compromised. By segregating duties to another user responsible for VM management, this will reduce Single Point of Failure. An alert was setup in Sentinel so that I will be notified everytime this particular account was signed in.

In addition, Microsoft Defender for Cloud was able to find additional vulnerabilities with my Key Vault setup. Although not related to the Security Incident, I found these recommendations useful. For example, it suggested that the Firewall should be enabled on Key Vault. Inspired by this, I setup a Private Endpoint on my Key Vault instance, and added a new NSG to the Subnet of my Virtual Network that contains my VMs, KeyVault, and Storage Account. The Private Endpoint was verified when I found that the FQDN associated with it had an internal IP address rather than a public one.

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/701b4ae0-7062-4629-9160-0d01645f4f87)

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/7219eb79-bc99-49a0-948a-35c34aab1b1d)

<b>Microsoft Defender Compliance Recommendations</b>
<br>
Finally, Microsoft Key Defender also has Compliance recommendation plans which I can select from various standards and use as baseline to measure the Security Posture of my environment, such as NIST SP 800-53 or ISO 27001. This is useful if your environment needs to comply with these standards as part of Regulatory Compliance. However, at the time writing, I was made aware that these recommendations take a significant amount of time (around 1-2 days) to appear in the Azure environment after being selected. This is perhaps due to the large amounts of scanning that it does on the environment to find which items have had their requirements met, and which have not.

## Security Metrics

Right after the attack and the VMs were exposed to the public, I documented the following security metrics to see the extent of logs gathered. Some of them were generated from my own Attack VM. A large portion of the attacks came from the Asia and North America region, although other regions were also involved such as Europe or Latin America. It is also interesting to see that there were more Windows security events than Linux, which is indicative that Windows is a more targeted platform!

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/3664eb64-e5f1-44b1-b77c-62bd5ee97cbb)

<b>Windows Failed Auth Signin Attempts - Geolocations of Attacker IPs</b>
![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/1b52b071-a035-482f-a89d-d6fa550271cf)

<b>Linux Failed Auth SSH Attempts - Geolocations of Attacker IPs</b>
![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/153a9661-9e6d-4978-9a22-0d15345598a9)

After resolving the incidents and securing the environment, I let the VMs run again for 12 hours and documented another instance of the security metrics

![image](https://github.com/Edwinccn/Azure-SOC-Lab/assets/162117956/0b66c0b0-9179-47a8-9751-fc38fef1f176)

No maps were generated as there were no Windows nor Linux Auth Signin Failures.
<br>
Note: the tables measure the number of Security Event and Syslogs where as the Maps are more specific in that they look for EventID 4625 (indicative of failed attempt to login to the machine) or Syslog auth failure with text "Failed password".

## Conclusion

The lab provided a valuable learning experience. I got to explore Azure Cloud, in particular, Log Analytics Workspace, Microsoft Defender for Cloud, and Microsoft Sentinel, which I used to build my SOC. These features provided invaluable insights into both a simulated attack allowing easier tracking of the attack vector, and also into live traffic attacks into my Honeynet.
<br>
Although there were many powerful features that can be utilized in Azure, these do come at a cost and requires a little experimentation and practice to get used to. There were a few instances where the performance were not up to expectation, such as the logs arriving into Log Analytics 5-10 minutes later, which allows for a slower response time from the SOC in the event of critical and time sensitive incidents. Fortunately, Azure does provide free credits when you sign up for a new user account to try.
<br>
All in all, this was fun and practical to setup! I recommend everyone to give this type of lab a try if they are interested in using Cloud to simulate a SOC and Honeynet.


