# FormationIOTSecu

Supports de formation autour de la **sécurisation des communications IoT**, avec deux volets principaux :

- **LoRaWAN / LoRa** : contenu dans [`SecuLorawan/`](./SecuLorawan) :contentReference[oaicite:1]{index=1}  
- **MQTT sécurisé (MQTTS)** : contenu dans [`mqtts/`](./mqtts) :contentReference[oaicite:2]{index=2}  

> Objectif : comprendre les risques (écoute, usurpation, rejeu, mauvaise gestion des clés/certificats) et mettre en place des contre-mesures (chiffrement, authentification, bonnes pratiques d’implémentation et de déploiement).

---

## Table des matières

- [Organisation du dépôt](#organisation-du-dépôt)
- [Prérequis](#prérequis)
- [Parcours conseillé](#parcours-conseillé)
- [Démarrage rapide](#démarrage-rapide)
- [Règles / bonnes pratiques](#règles--bonnes-pratiques)
- [Licence](#licence)

---

## Organisation du dépôt

- `SecuLorawan/`  
  Ressources et/ou exercices liés à la sécurité LoRa/LoRaWAN (architecture, identités, clés, trames, pratiques de déploiement, etc.).

- `mqtts/`  
  Ressources et/ou exercices liés à MQTT sécurisé : TLS, certificats, authentification, configuration broker/client, tests.

- `README.md`  
  Présentation globale du dépôt.

---

## Prérequis

### Connaissances
- Bases réseau : IP, ports, DNS, TLS (certificat, CA, chaîne de confiance)
- Notions IoT : capteurs, communications, notion de “device identity”
- Notions sécurité : confidentialité / intégrité / authentification

### Outils (selon les ateliers)
- Un poste Linux/Windows/macOS
- Un client MQTT (ex : `mosquitto_pub` / `mosquitto_sub`)
- (Optionnel) Wireshark pour l’analyse de trames
- Un environnement de dev microcontrôleur si les exercices incluent du code embarqué (Arduino/PlatformIO/ESP-IDF, etc.)

> Chaque dossier de module peut préciser ses prérequis exacts (matériel, versions, commandes, captures attendues).

---

## Parcours conseillé

1. **MQTTS** (`mqtts/`)  
   - Comprendre pourquoi MQTT “en clair” est insuffisant
   - Mettre en place TLS côté broker et côté client
   - Vérifier et expliquer : certificat serveur, CA, validation hostname, erreurs courantes

2. **Sécurité LoRa/LoRaWAN** (`SecuLorawan/`)  
   - Comprendre les identités et les clés (conceptuellement)
   - Identifier ce qui protège (ou non) la confidentialité et l’intégrité
   - Étudier les mauvaises pratiques typiques (réutilisation de clés, fuites, etc.)

---

## Démarrage rapide

### 1) Explorer les supports
- Lire le module **MQTTS** : [`mqtts/`](./mqtts)
- Lire le module **LoRa/LoRaWAN** : [`SecuLorawan/`](./SecuLorawan)

### 2) Méthode “TP”
Pour chaque TP, l’objectif est d’obtenir :
- ✅ une configuration fonctionnelle
- ✅ une preuve (logs, captures Wireshark, commandes)
- ✅ une explication courte “pourquoi ça marche / pourquoi ça échoue”

---

## Règles / bonnes pratiques

- Ne jamais committer de secrets (mots de passe, tokens, clés privées, certificats privés).
- Utiliser des fichiers `.env` (non versionnés) ou un gestionnaire de secrets si nécessaire.
- Documenter les étapes reproductibles : commande → résultat attendu → explication.
- Préférer des identifiants/certificats **par étudiant** ou **par groupe** en contexte pédagogique.

---

## Licence

À définir.

> Si tu veux une licence simple : MIT (souple) ou CC BY-NC-SA (plus “pédagogique/ressources”).  
> Ajoute un fichier `LICENSE` à la racine.

---

## Auteur / Contexte

Dépôt de supports pour une formation IoT & sécurité (réseaux, TLS, LoRa/LoRaWAN, MQTT). :contentReference[oaicite:3]{index=3}
