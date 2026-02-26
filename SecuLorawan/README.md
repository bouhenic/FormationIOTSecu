# TP – Sécurité LoRaWAN

## 🎯 Objectifs

Tester les mécanismes de sécurité LoRaWAN :
- Chiffrement par **AppSKey**
- Authentification par **NwkSKey**
- Protection contre le **replay** via le compteur de trames
- Observation d’attaques (MITM, sniffing, replay) et de leurs limites

---

## 🧱 Architecture

- Serveur LoRaWAN : **ChirpStack (Docker)**
- Passerelle LoRaWAN (Dragino / Raspberry)
- Device : **Arduino MKR WAN 1310**
- Réseau privé IP (UDP 1700)
- Poste attaquant : Ettercap + Wireshark (+ HackRF pour la partie 3)

---

## 🛠️ Partie 1 – Mise en place du réseau LoRaWAN

### 1️⃣ Déploiement de ChirpStack

```bash
git clone https://github.com/chirpstack/chirpstack-docker.git
cd chirpstack-docker
docker-compose up -d
```

Interface web :
```
http://IP_CHIRPSTACK:8080
```

Identifiants par défaut :
- user : `admin`
- password : `admin`

---

### 2️⃣ Configuration de la passerelle

- Accéder à l’interface de la gateway :  
  ```
  http://gatewayX.local
  ```
  Identifiants : `root / dragino`

- Onglet **LoRaWAN → Semtech UDP**
  - Server address : `IP_CHIRPSTACK`
  - Port : `1700`

---

### 3️⃣ Configuration ChirpStack

#### Ajouter la gateway
- Menu **Gateways → Add gateway**
- Renseigner :
  - Name
  - Gateway EUI (visible sur l’interface de la gateway)

---

### 4️⃣ Création de l’application et du device profile

- **Applications → Add application**
- **Device profiles → Add device profile**
  - Région : EU868
  - Activation : OTAA

---

### 5️⃣ Création du device

#### Récupération du DevEUI
Sur l’Arduino MKR WAN 1310 :

1. Ouvrir l’IDE Arduino  
2. Charger :
```
File → Examples → MKRWAN → FirstConfiguration
```
3. Téléverser et copier le **Device EUI**

---

#### Création du device dans ChirpStack

- **Applications → votre application → Add device**
- Renseigner :
  - Device name
  - Device profile
  - DevEUI
  - JoinEUI : `00 00 00 00 00 00 00 00`

Générer et copier l’**AppKey**

---

### 6️⃣ Connexion OTAA

Dans l’IDE Arduino :
- Sélectionner OTAA
- Renseigner :
  - AppEUI
  - AppKey

Vérifier :
- Onglet **LoRaWAN frames**
- Onglet **Events**

---

### 7️⃣ Envoi de données (Uplink)

Ouvrir :
```
LoraSendAndReceive.ino
```

Modifier `arduino_secrets.h` :
- AppEUI
- AppKey

Modifier la temporisation (ligne ~74) :
```cpp
delay(3000);
```

Envoyer un message et vérifier :
- Payload Base64
- Décodage : `Hello LoRa`

---

## 🧨 Partie 2 – Attaque Man-in-the-Middle

### Prérequis
- Connaitre **NwkSKey** et **AppSKey** du device
- Poste attaquant sur le même réseau IP

---

### 1️⃣ ARP Spoofing

```bash
ettercap -T -i eno1 -M arp:remote /IP_GATEWAY_LORA// /IP_CHIRPSTACK//
```

---

### 2️⃣ Sniff avec Wireshark

Filtre :
```
ip.src==IP_GATEWAY_LORA && udp.port==1700 && udp contains "rxpk"
```

- Envoyer un uplink depuis le device
- Copier le payload Base64 intercepté

Exemple :
```
gL4fiwCABgACX7apZ06+ok8wgw==
```

---

## 🔓 Partie 3 – Déchiffrement du payload

### 1️⃣ Accéder au décodeur LoRaWAN

```
https://lora-packet.vercel.app
```

### 2️⃣ Renseigner :
- Payload (Base64)
- AppSKey
- NwkSKey

Décodage attendu :
```
446577746F6E  →  Newton
```

---

## 📡 Partie 4 – Rejeu d’une trame LoRaWAN (SDR)

Matériel :
- HackRF One
- Universal Radio Hacker (URH)

Objectif :
- Enregistrer une trame LoRa
- Tenter de la rejouer
- Constater le refus dû au **frame counter**

---

## ✅ Conclusion

- Le payload LoRaWAN est chiffré de bout en bout
- Sans les clés, l’attaque est inutile
- Le compteur de trames empêche le replay
- La sécurité LoRaWAN repose sur :
  - Clés
  - Compteurs
  - Isolation réseau

---

## ⚠️ Cadre pédagogique

Ces manipulations sont réalisées **uniquement en environnement contrôlé et pédagogique**.
