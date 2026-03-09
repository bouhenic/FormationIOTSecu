#!/bin/bash
# =============================================================================
# Script d'installation automatisée de libvirt / KVM / QEMU + Vagrant plugin
# BTS CIEL — Lycée Newton
# =============================================================================

set -e  # Arrêt immédiat si une commande échoue

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log()     { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Installation libvirt / KVM — BTS CIEL    ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# =============================================================================
# 0. Vérifications préalables
# =============================================================================
log "Vérification des prérequis..."

# Vérifier qu'on est bien sur Ubuntu/Debian
if ! command -v apt &>/dev/null; then
    error "Ce script nécessite apt (Ubuntu/Debian uniquement)"
fi

# Vérifier le support CPU pour la virtualisation
CPU_SUPPORT=$(egrep -c '(vmx|svm)' /proc/cpuinfo || true)
if [ "$CPU_SUPPORT" -eq 0 ]; then
    warn "Le CPU ne semble pas supporter la virtualisation matérielle (vmx/svm)."
    warn "Les VMs fonctionneront en émulation pure (performances dégradées)."
    read -p "Continuer quand même ? [o/N] " -n 1 -r; echo
    [[ $REPLY =~ ^[Oo]$ ]] || exit 0
else
    success "Support CPU virtualisation détecté ($CPU_SUPPORT cœurs compatibles)"
fi

# Vérifier que vagrant est installé
if ! command -v vagrant &>/dev/null; then
    warn "Vagrant n'est pas installé. Le plugin vagrant-libvirt sera ignoré."
    INSTALL_VAGRANT_PLUGIN=false
else
    VAGRANT_VERSION=$(vagrant --version)
    success "Vagrant détecté : $VAGRANT_VERSION"
    INSTALL_VAGRANT_PLUGIN=true
fi

echo ""

# =============================================================================
# 1. Mise à jour du système
# =============================================================================
log "Mise à jour des paquets..."
sudo apt update -y
success "Paquets à jour"
echo ""

# =============================================================================
# 2. Installation de libvirt / QEMU / KVM
# =============================================================================
log "Installation de libvirt, QEMU/KVM et des outils..."
sudo apt install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    libvirt-dev \
    bridge-utils \
    virtinst \
    virt-manager
success "libvirt, QEMU/KVM et outils installés"
echo ""

# =============================================================================
# 3. Ajout de l'utilisateur aux groupes
# =============================================================================
log "Ajout de l'utilisateur '$USER' aux groupes libvirt et kvm..."
sudo usermod -aG libvirt "$USER"
sudo usermod -aG kvm "$USER"
success "Utilisateur '$USER' ajouté aux groupes libvirt et kvm"
warn "Une reconnexion sera nécessaire pour que les droits soient effectifs"
echo ""

# =============================================================================
# 4. Activation du service libvirt
# =============================================================================
log "Activation du service libvirtd..."

# Détecter la bonne unité systemd selon la version Ubuntu
UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "0")
if systemctl list-unit-files | grep -q "^libvirtd.socket"; then
    sudo systemctl enable --now libvirtd.socket
    success "libvirtd.socket activé (Ubuntu 24.04+)"
elif systemctl list-unit-files | grep -q "^libvirtd.service"; then
    sudo systemctl enable --now libvirtd
    success "libvirtd.service activé"
else
    warn "Impossible de détecter l'unité systemd libvirt. Vérifier manuellement."
fi

echo ""
log "Statut du service :"
systemctl is-active libvirtd.socket 2>/dev/null || systemctl is-active libvirtd 2>/dev/null || true
echo ""

# =============================================================================
# 5. Configuration du pool de stockage
# =============================================================================
log "Configuration du pool de stockage 'default'..."

# Vérifier si le pool existe déjà
if sudo virsh pool-list --all | grep -q "default"; then
    warn "Le pool 'default' existe déjà"
    # S'assurer qu'il est actif et en autostart
    sudo virsh pool-start default 2>/dev/null || true
    sudo virsh pool-autostart default 2>/dev/null || true
else
    sudo mkdir -p /var/lib/libvirt/images
    sudo virsh pool-define-as default dir --target /var/lib/libvirt/images
    sudo virsh pool-build default
    sudo virsh pool-start default
    sudo virsh pool-autostart default
fi

success "Pool de stockage 'default' actif et configuré en autostart"
echo ""

# =============================================================================
# 6. Activation du réseau par défaut
# =============================================================================
log "Activation du réseau NAT 'default'..."

if sudo virsh net-list --all | grep -q "default"; then
    sudo virsh net-start default 2>/dev/null || true
    sudo virsh net-autostart default 2>/dev/null || true
    success "Réseau 'default' actif"
else
    warn "Réseau 'default' non trouvé — peut nécessiter une configuration manuelle"
fi
echo ""

# =============================================================================
# 7. Dépendances et plugin vagrant-libvirt
# =============================================================================
if [ "$INSTALL_VAGRANT_PLUGIN" = true ]; then
    log "Installation des dépendances pour vagrant-libvirt..."
    sudo apt install -y ruby-dev pkg-config build-essential libvirt-dev
    success "Dépendances Ruby/libvirt installées"
    echo ""

    log "Installation du plugin vagrant-libvirt..."
    if vagrant plugin list | grep -q "vagrant-libvirt"; then
        warn "Plugin vagrant-libvirt déjà installé"
    else
        vagrant plugin install vagrant-libvirt
        success "Plugin vagrant-libvirt installé"
    fi
    echo ""
fi

# =============================================================================
# 8. Configuration de l'environnement
# =============================================================================
log "Configuration de VAGRANT_DEFAULT_PROVIDER..."

SHELL_RC="$HOME/.bashrc"
if echo "$SHELL" | grep -q "zsh"; then
    SHELL_RC="$HOME/.zshrc"
fi

if grep -q "VAGRANT_DEFAULT_PROVIDER" "$SHELL_RC" 2>/dev/null; then
    warn "VAGRANT_DEFAULT_PROVIDER déjà défini dans $SHELL_RC"
else
    echo 'export VAGRANT_DEFAULT_PROVIDER=libvirt' >> "$SHELL_RC"
    success "VAGRANT_DEFAULT_PROVIDER=libvirt ajouté dans $SHELL_RC"
fi

export VAGRANT_DEFAULT_PROVIDER=libvirt
echo ""

# =============================================================================
# Résumé final
# =============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}  Installation terminée avec succès !       ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "  ${YELLOW}Actions à effectuer manuellement :${NC}"
echo -e "  1. Se déconnecter/reconnecter pour activer les groupes libvirt/kvm"
echo -e "     ou exécuter : ${GREEN}newgrp libvirt${NC} (session courante uniquement)"
echo -e "  2. Recharger le shell : ${GREEN}source $SHELL_RC${NC}"
echo ""
echo -e "  ${YELLOW}Vérification rapide après reconnexion :${NC}"
echo -e "  ${GREEN}virsh list --all${NC}           # doit répondre sans sudo"
echo -e "  ${GREEN}virsh pool-list --all${NC}      # doit afficher 'default active'"
echo -e "  ${GREEN}vagrant up --provider=libvirt${NC}"
echo ""
