#!/bin/bash

echo -e "\033[1;32;4m-- Etape 1/6: Déinition et Configuration du projet GCP --\033[0m"

# Définition du projet GCP
export GCP_PROJECT="pure-anthem-393513"  # Remplacez par le nom de votre projet

# Configuration du projet GCP
echo "Configuration du projet GCP : $GCP_PROJECT"
gcloud config set project $GCP_PROJECT

# Vérification de la configuration
echo "Vérification de la configuration du projet GCP :"
gcloud config list

# Message de confirmation
echo "Le projet GCP a été configuré avec succès : $GCP_PROJECT"

gcloud services enable compute.googleapis.com --project=$GCP_PROJECT
gcloud services enable cloudresourcemanager.googleapis.com --project=$GCP_PROJECT
gcloud services enable iam.googleapis.com --project=$GCP_PROJECT

# --------------------------------------------------------------------

echo -e "\033[1;32;4m-- Etape 2/6: Vérification de Terrafrom et Installation si nécessaire --\033[0m"

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
echo -e "\033[1;32;4m-- Etape 3/6: Génération de l'inventaire avec les adresse IP --\033[0m"

# Génération de l'inventaire avec les adresses IP
    cd ./ansible
    rm -f inventory.ini
    cd ..
    ./creation-inventory.sh >ansible/inventory.ini

# --------------------------------------------------------------------
echo -e "\033[1;32;4m-- Etape 4/6: Vérification de Ansible et Installation si nécessaire --\033[0m"

# Vérification et installation d'Ansible
if ! command -v ansible &> /dev/null; then
    echo "Ansible n'est pas installé. Installation en cours..."
    # Commande d'installation d'Ansible, ajustez-la en fonction de votre système d'exploitation
    # Exemple pour Debian 12:
    sudo apt update
    sudo apt install -y ansible
fi

# Vérification de la présence des fichiers Ansible
if [ ! -d "ansible" ] || [ ! -f "ansible/roles/wordpress/tasks/main.yml" ] || [ ! -f "ansible/roles/database/tasks/main.yml" ]|| [ ! -f "ansible/playbook.yml" ]|| [ ! -f "ansible/vars.yml" ]|| [ ! -f "ansible/inventory.ini" ]; then
    echo "Certains fichiers Ansible sont manquants. Clonage du référentiel..."
    git clone https://github.com/JoffreyBENA/TP1-VM_WORDPRESS.git
    cd TP1-VM_WORDPRESS/ansible
else
    cd ansible
fi

# --------------------------------------------------------------------

echo -e "\033[1;32;4m-- Etape 5/6: Déploiement avec Ansible --\033[0m"

# Déploiement avec Ansible
echo "Déploiement avec Ansible..."
ansible-playbook -i inventory.ini -b playbook.yml -v
cd ..

# --------------------------------------------------------------------
echo -e "\033[1;32;4m-- Etape 6/6: Vérification fonctionnement application --\033[0m"

# Vérification fonctionnement application

cd terraform
wordpress_ip=$(terraform output $wordpress_vm_public_ip | sed 's/"//g')

curl_output=$(curl -s $wordpress_ip/wordpress)

echo $wordpress_ip
echo $curl_output
if echo "$curl_output" | grep -o "html"; then
    echo "L'application WordPress est fonctionnelle."

    # Récupération du titre de la page WordPress pour l'élément visuel
    title=$(echo "$curl_output" | grep -o "<title>[^<]*" | sed -e 's/<title>//')
    echo "Titre de la page WordPress : $title"
else
    echo "L'application WordPress ne semble pas fonctionner correctement."
fi
