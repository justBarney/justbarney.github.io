---
title: "Installation and Configuration of HAProxy with Keepalived"
permalink: /Linux/Tutorials/Installation-and-Configuration-of-HAProxy-with-Keepalived
date: 2025-02-27
categories: [Linux, Tutorials]
tags: [English, Linux, Hochverfügbar,High-Availability ,Tutorial, keepalived]
image:
  path: /assets/img/posts/linux/tutorials/Installation-und-Konfiguration-von-HAProxy-mit-Keepalived/header.jpg
---
# Installation and Configuration of HAProxy with Keepalived

In this tutorial, I will show you how to set up HAProxy in combination with Keepalived to create a highly available load-balancing solution.

## Prerequisites
- Two or more servers with Ubuntu/Debian (works on CentOS/RHEL with slight modifications)
- Root access or a user with sudo privileges
- Basic knowledge of Linux and network configuration

## 1. Installing HAProxy

First, install HAProxy on both (or multiple) load balancer servers:

```bash
sudo apt update && sudo apt install haproxy -y
```

For CentOS/RHEL:

```bash
sudo yum install haproxy -y
```

After installation, verify that HAProxy is correctly installed:

```bash
haproxy -v
```

## 2. Configuring HAProxy

The HAProxy configuration file is located at `/etc/haproxy/haproxy.cfg`. Open the file with an editor of your choice:

```bash
sudo nano /etc/haproxy/haproxy.cfg
```

Here is an example of a load balancer configuration:

```config
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    option httplog
    option dontlognull
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http_front
    bind *:80
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web1 192.168.1.101:80 check
    server web2 192.168.1.102:80 check
```

After making changes, save the file and restart HAProxy:

```bash
sudo systemctl restart haproxy
sudo systemctl enable haproxy
```

## 3. Installing and Configuring Keepalived

Keepalived ensures a high availability environment by managing a Virtual IP Address (VIP) that switches between HAProxy servers.

### Installing Keepalived

```bash
sudo apt install keepalived -y
```

For CentOS/RHEL:

```bash
sudo yum install keepalived -y
```

### Configuring Keepalived

The configuration file is located at `/etc/keepalived/keepalived.conf`. Open it with an editor:

```bash
sudo nano /etc/keepalived/keepalived.conf
```

#### Primary HAProxy Server (MASTER)

```config
vrrp_instance VI_1 {
    state MASTER
    interface eth0  # Adjust accordingly
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass secret
    }
    virtual_ipaddress {
        192.168.1.200/24
    }
}
```

#### Secondary HAProxy Server (BACKUP)

```config
vrrp_instance VI_1 {
    state BACKUP
    interface eth0  # Adjust accordingly
    virtual_router_id 51
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass secret
    }
    virtual_ipaddress {
        192.168.1.200/24
    }
}
```

### Starting Keepalived

After configuration, restart and enable Keepalived:

```bash
sudo systemctl restart keepalived
sudo systemctl enable keepalived
```

## 4. Testing High Availability

1. **Check the Virtual IP Address**
   
   On the primary server:
   ```bash
   ip a | grep 192.168.1.200
   ```
   The virtual IP should be visible.

2. **Failover Test**
   
   Stop Keepalived on the MASTER:
   ```bash
   sudo systemctl stop keepalived
   ```
   Check on the BACKUP server to see if the virtual IP address has been taken over:
   ```bash
   ip a | grep 192.168.1.200
   ```

If the IP address switches successfully, your HA setup is working correctly.

## Conclusion

With HAProxy and Keepalived, you can create a highly available load-balancing environment. HAProxy distributes traffic to backend servers, while Keepalived ensures failover protection. This setup guarantees that your services remain accessible at all times.

