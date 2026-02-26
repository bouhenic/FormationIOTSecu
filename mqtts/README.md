# TP – Sécurisation d’une connexion MQTT (MQTTS)

## 🎯 Objectif du TP
Mettre en place une connexion **MQTT sécurisée (MQTTS)** entre un client et un broker en utilisant TLS et une authentification par mot de passe.

## 🧱 Architecture
- Broker MQTT : 192.168.100.10
- Client MQTT : 192.168.100.11
- Port MQTTS : 8883

## 🚀 Déploiement des machines virtuelles

```bash
git clone https://github.com/bouhenic/FormationIOTSecu
cd FormationIOTSecu/mqtts
vagrant up --provider=libvirt
vagrant status
```

## 🔐 Connexion aux VMs

```bash
vagrant ssh mosquitto-broker
```

```bash
vagrant ssh mosquitto-client
```

## 🔏 Création des certificats (sur le broker)

```bash
openssl req -new -x509 -days 1826 -extensions v3_ca -keyout ca.key -out ca.crt
openssl genrsa -out server.key 2048
openssl req -out server.csr -key server.key -new
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 360
```

## ⚙️ Configuration Mosquitto (broker)

```bash
sudo nano /etc/mosquitto/mosquitto.conf
```

Ajouter :
```conf
listener 8883
cafile /home/vagrant/ca.crt
certfile /home/vagrant/server.crt
keyfile /home/vagrant/server.key
```

```bash
sudo systemctl restart mosquitto
sudo systemctl status mosquitto
```

## 📄 Copie du certificat CA sur le client

```bash
cat /home/vagrant/ca.crt
nano /home/vagrant/ca.crt
```

## 🧪 Test MQTTS

```bash
mosquitto_sub -h 192.168.100.10 -p 8883 --cafile /home/vagrant/ca.crt -t your/topic
```

```bash
mosquitto_pub -h 192.168.100.10 -p 8883 --cafile /home/vagrant/ca.crt -t your/topic -m "Hello world"
```

## 🔑 Authentification par mot de passe

```bash
sudo nano /etc/mosquitto/mosquitto.conf
```

Ajouter :
```conf
allow_anonymous false
password_file /mosquitto_passwd
```

```bash
sudo mosquitto_passwd -c /mosquitto_passwd userclient
sudo mosquitto_passwd /mosquitto_passwd userbroker
sudo systemctl restart mosquitto
```

## 🧪 Test avec authentification

```bash
mosquitto_sub -h 192.168.100.10 -p 8883 --cafile /home/vagrant/ca.crt -u userbroker -P MOT_DE_PASSE -t your/topic
```

```bash
mosquitto_pub -h 192.168.100.10 -p 8883 --cafile /home/vagrant/ca.crt -u userclient -P MOT_DE_PASSE -t your/topic -m "Hello world"
```

