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

echo -e "\033[1;32;4m-- Etape 2/7: Vérification de Terrafrom et Installation si nécessaire --\033[0m"

# Installation de Terraform s'il n'est pas installé
if ! command -v terraform &> /dev/null; then
    echo "Terraform n'est pas installé. Installation en cours..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
    sudo apt update
    sudo apt install terraform
    if [ $? -eq 0 ]; then
        echo -e "\033[33mTerraform a été installé avec succès.\033[0m"
    else
        echo -e "\033[31mL'installation de Terraform a échoué.\033[0m"
        exit 1
    fi
else
    echo -e "\033[31mTerraform est déjà installé.\033[0m"
fi

# Vérification de la présence des fichiers Terraform
if [ ! -f "terraform/vpc/variables.tf" ] || [ ! -f "terraform/vpc/main.tf" ] || [ ! -f "terraform/wordpress_vm/variables.tf" ] || [ ! -f "terraform/wordpress_vm/main.tf" ] || [ ! -f "terraform/db_vm/variables.tf" ] || [ ! -f "terraform/db_vm/main.tf" ] || [ ! -f "terraform/firewall/variables.tf" ] || [ ! -f "terraform/firewall/main.tf" ]; then
    echo -e "\033[33mCertains fichiers Terraform sont manquants. Clonage du référentiel...\033[0m"
    git clone https://github.com/JoffreyBENA/TP1-VM_WORDPRESS.git
    cd TP1-VM_WORDPRESS/terraform
else
    cd terraform
fi

# --------------------------------------------------------------------

echo -e "\033[1;32;4m-- Etape 3/7: Initialisation de Terrafrom et Vréation des machines --\033[0m"

# Initialisation de Terraform si c'est la première exécution
if [ ! -d ".terraform" ]; then
    echo -e "\033[33mInitialisation de Terraform...\033[0m"
    terraform init
fi

# Création des machines avec Terraform
echo -e "\033[33mCréation des machines avec Terraform...\033[0m"
terraform apply -auto-approve
cd ..

# --------------------------------------------------------------------
echo -e "\033[1;32;4m-- Etape 4/7: Génération de l'inventaire avec les adresse IP --\033[0m"

# Génération de l'inventaire avec les adresses IP
echo -e "\033[33mCréation du fichier 'inventory.ini'...\033[0m"
cd ./ansible
rm -f inventory.ini
cd ..
./creation-inventory.sh >ansible/inventory.ini

# --------------------------------------------------------------------
echo -e "\033[1;32;4m-- Etape 5/7: Vérification de Ansible et Installation si nécessaire --\033[0m"

# Vérification et installation d'Ansible
if ! command -v ansible &> /dev/null; then
    echo "Ansible n'est pas installé. Installation en cours..."
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

echo -e "\033[1;32;4m-- Etape 6/7: Déploiement avec Ansible --\033[0m"

# Déploiement avec Ansible
echo "Déploiement avec Ansible..."
ansible-playbook -i inventory.ini -b playbook.yml -v
cd ..

# --------------------------------------------------------------------

echo -e "\033[1;32;4m-- Etape 7/7: Vérification fonctionnement application --\033[0m"

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
