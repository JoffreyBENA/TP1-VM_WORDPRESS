#!/bin/bash

# Vérification et installation de Terraform
if ! command -v terraform &> /dev/null; then
    echo "Terraform n'est pas installé. Installation en cours..."
    # Commande d'installation de Terraform, ajustez-la en fonction de votre système d'exploitation
    # Exemple pour Debian 12:
    sudo apt-get update
    sudo apt-get install terraform
    exit 0
fi

# Vérification de la présence des fichiers Terraform
if [ ! -f "terraform/vpc/variables.tf" ] || [ ! -f "terraform/vpc/main.tf" ] || [ ! -f "terraform/wordpress_vm/variables.tf" ] || [ ! -f "terraform/wordpress_vm/main.tf" ] || [ ! -f "terraform/db_vm/variables.tf" ] || [ ! -f "terraform/db_vm/main.tf" ] || [ ! -f "terraform/firewall/variables.tf" ] || [ ! -f "terraform/firewall/main.tf" ]; then
    echo "Certains fichiers Terraform sont manquants. Clonage du référentiel..."
    git clone https://github.com/JoffreyBENA/TP1-VM_WORDPRESS.git
    cd TP1-VM_WORDPRESS/terraform
else
    cd terraform
fi

# Initialisation de Terraform si c'est la première exécution
if [ ! -d ".terraform" ]; then
    echo "Initialisation de Terraform..."
    terraform init
fi

# Création des machines avec Terraform
echo "Création des machines avec Terraform..."
terraform apply -auto-approve
cd ..

# --------------------------------------------------------------------

# Vérification et installation d'Ansible
if ! command -v ansible &> /dev/null; then
    echo "Ansible n'est pas installé. Installation en cours..."
    # Commande d'installation d'Ansible, ajustez-la en fonction de votre système d'exploitation
    # Exemple pour Debian 12:
    sudo apt update
    sudo apt install -y ansible
    exit 1
fi

# Vérification de la présence des fichiers Ansible
if [ ! -f "ansible/vars.yml" ] || [ ! -f "ansible/playbook.yml" ]; then
    echo "Certains fichiers Ansible sont manquants. Clonage du référentiel..."
    git clone https://github.com/JoffreyBENA/TP1-VM_WORDPRESS.git
    cd TP1-VM_WORDPRESS/ansible
else
    cd ansible
fi

# --------------------------------------------------------------------

# Récupération des adresses IP des VMs depuis les sorties Terraform
db_vm_private_ip=$(terraform output db_vm_private_ip)
wordpress_vm_public_ip=$(terraform output wordpress_vm_public_ip)

# Chemin vers le fichier hosts (inventaire Ansible)
hosts_file="./inventory/hosts"

# Création du fichier hosts pour Ansible
echo "Création du fichier hosts pour Ansible..."
echo "[all]" > $hosts_file
echo "wordpress_machine ansible_host=${wordpress_vm_public_ip}" >> $hosts_file
echo "database_machine ansible_host=${db_vm_private_ip}" >> $hosts_file

echo "Le fichier d'inventaire Ansible a été créé : $hosts_file"

# --------------------------------------------------------------------

# Vérification et création de clé SSH pour WordPress VM
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Création d'une clé SSH pour la machine WordPress..."
    ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
fi

# Copie de la clé publique sur la machine WordPress
echo "Copie de la clé publique sur la machine WordPress..."
ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "root@$wordpress_vm_public_ip"

# Vérification et création de clé SSH pour Database VM
if [ ! -f "$HOME/.ssh/id_rsa_db" ]; then
    echo "Création d'une clé SSH pour la machine Database..."
    ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa_db"
fi

# Copie de la clé publique sur la machine Database
echo "Copie de la clé publique sur la machine Database..."
ssh-copy-id -i "$HOME/.ssh/id_rsa_db.pub" "root@$db_vm_private_ip"

# --------------------------------------------------------------------

# Déploiement avec Ansible
echo "Déploiement avec Ansible..."
ansible-playbook playbook.yml -i inventory/hosts

# Vérification de l'application
echo "Vérification de l'application..."
curl_output=$(curl -s "https://${wordpress_vm_public_ip}" | grep "WordPress")  # Remplacez "installation" par le texte attendu dans la page
if [[ "$curl_output" != *"WordPress"* ]]; then
    echo "L'application WordPress n'est pas fonctionnelle."
else
    echo "L'application WordPress est fonctionnelle."
fi
