---
title: "Installation und Konfiguration von HAProxy mit Keepalived"
permalink: /Linux/Tutorials/Installation-und-Konfiguration-von-HAProxy-mit-Keepalived
date: 2025-02-27
categories: [Linux, Tutorials]
tags: [Deutsch, Linux, Hochverfügbar,High-Availability ,Tutorial, keepalived]
image:
  path: /assets/img/posts/linux/tutorials/Installation-und-Konfiguration-von-HAProxy-mit-Keepalived/header.jpg
---

# Installation und Konfiguration von HAProxy mit Keepalived

In diesem Tutorial zeige ich dir, wie du HAProxy in Kombination mit Keepalived einrichtest, um eine hochverfügbare Load-Balancing-Lösung zu erstellen. 

## Voraussetzungen
- Zwei oder mehr Server mit Ubuntu/Debian (funktioniert auch auf CentOS/RHEL mit leichten Änderungen)
- Root-Zugriff oder ein Benutzer mit sudo-Rechten
- Grundkenntnisse in Linux und Netzwerkkonfiguration

## 1. Installation von HAProxy

Zunächst installieren wir HAProxy auf beiden (oder mehreren) Load-Balancer-Servern:

```bash
sudo apt update && sudo apt install haproxy -y
```

Falls du CentOS/RHEL verwendest:

```bash
sudo yum install haproxy -y
```

Nach der Installation überprüfen wir, ob HAProxy korrekt installiert wurde:

```bash
haproxy -v
```

## 2. Konfiguration von HAProxy

Die HAProxy-Konfigurationsdatei befindet sich unter `/etc/haproxy/haproxy.cfg`. Öffne die Datei mit einem Editor deiner Wahl:

```bash
sudo nano /etc/haproxy/haproxy.cfg
```

Hier ein Beispiel für eine Load-Balancer-Konfiguration:

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

Nach der Anpassung speichern und HAProxy neu starten:

```bash
sudo systemctl restart haproxy
sudo systemctl enable haproxy
```

## 3. Installation und Konfiguration von Keepalived

Keepalived sorgt für eine hochverfügbare Umgebung durch eine virtuelle IP-Adresse (VIP), die zwischen den HAProxy-Servern gewechselt wird.

### Installation von Keepalived

```bash
sudo apt install keepalived -y
```

Falls du CentOS/RHEL verwendest:

```bash
sudo yum install keepalived -y
```

### Konfiguration von Keepalived

Die Konfigurationsdatei befindet sich unter `/etc/keepalived/keepalived.conf`. Öffne sie mit einem Editor:

```bash
sudo nano /etc/keepalived/keepalived.conf
```

#### Primärer HAProxy-Server (MASTER)

```config
vrrp_instance VI_1 {
    state MASTER
    interface eth0  # Anpassung erforderlich
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass geheim
    }
    virtual_ipaddress {
        192.168.1.200/24
    }
}
```

#### Sekundärer HAProxy-Server (BACKUP)

```config
vrrp_instance VI_1 {
    state BACKUP
    interface eth0  # Anpassung erforderlich
    virtual_router_id 51
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass geheim
    }
    virtual_ipaddress {
        192.168.1.200/24
    }
}
```

### Keepalived starten

Nach der Konfiguration Keepalived neu starten und aktivieren:

```bash
sudo systemctl restart keepalived
sudo systemctl enable keepalived
```

## 4. Test der Hochverfügbarkeit

1. **Überprüfen der virtuellen IP-Adresse**
   
   Auf dem primären Server:
   ```bash
   ip a | grep 192.168.1.200
   ```
   Die virtuelle IP sollte sichtbar sein.

2. **Failover-Test**
   
   Stoppe Keepalived auf dem MASTER:
   ```bash
   sudo systemctl stop keepalived
   ```
   Überprüfe auf dem BACKUP-Server, ob die virtuelle IP-Adresse übernommen wurde:
   ```bash
   ip a | grep 192.168.1.200
   ```

Wenn die IP-Adresse erfolgreich gewechselt wird, funktioniert dein HA-Setup.

## Fazit

Mit HAProxy und Keepalived kannst du eine hochverfügbare Load-Balancing-Umgebung erstellen. HAProxy verteilt den Traffic auf die Backend-Server, während Keepalived für Failover sorgt. Diese Konfiguration stellt sicher, dass deine Dienste jederzeit erreichbar bleiben.

