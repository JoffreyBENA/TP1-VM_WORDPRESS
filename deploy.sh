#!/bin/bash

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

# Création des clés SSH

export USER=joffreym2igcp

# Vérifier si une clé SSH est présente sur la VM, sinon en créer une
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -C "$USER"
fi

# Lire le contenu du fichier dans une variable
contenu=$(cat ~/.ssh/id_rsa.pub)

# Exporter la variable d'environnement
export VARIABLE_CONTENU="$contenu"

# Afficher le contenu exporté
echo "$USER:$VARIABLE_CONTENU" > ssh_keys

# --------------------------------------------------------------------

# Récupère la liste des noms et des zones d'instance à l'aide de gcloud
instances_info=$(gcloud compute instances list --project $GCP_PROJECT --format="csv(NAME,ZONE)")

# Vérifie si des instances sont trouvées
if [ -z "$instances_info" ]; then
    echo "Aucune instance trouvée dans le projet $GCP_PROJECT."
else
    echo "Liste des noms et des zones d'instance dans le projet $GCP_PROJECT :"
    echo "$instances_info"

    # Séparateur par défaut en bash (utilisé pour les boucles)
    IFS=$'\n'

    # Boucle pour traiter chaque nom d'instance et sa zone
    for instance_info in $instances_info; do
    # Ignorer la ligne "name,zone"
    if [[ "$instance_info" != "name,zone" ]]; then
        # Découpe la ligne en nom et zone en utilisant des guillemets pour éviter les problèmes d'encodage
        IFS=',' read -r instance_name instance_zone <<< "$instance_info"

        echo "Traitement de l'instance : $instance_name (zone : $instance_zone)"

        # Exécute la commande gcloud avec le nom d'instance et la zone actuels
        gcloud compute instances add-metadata "$instance_name" --zone "$instance_zone" --metadata-from-file ssh-keys=ssh_keys

        # Vérifie le code de sortie de la commande gcloud
        if [ $? -eq 0 ]; then
            echo "Clé SSH ajoutée à l'instance $instance_name (zone : $instance_zone) avec succès."
        else
            echo "Une erreur s'est produite lors de l'ajout de la clé SSH à l'instance $instance_name (zone : $instance_zone)."
        fi
    fi
done
fi


# --------------------------------------------------------------------

# Vérification et installation d'Ansible
if ! command -v ansible &> /dev/null; then
    echo "Ansible n'est pas installé. Installation en cours..."
    # Commande d'installation d'Ansible, ajustez-la en fonction de votre système d'exploitation
    # Exemple pour Debian 12:
    sudo apt update
    sudo apt install -y ansible
fi

# Vérification de la présence des fichiers Ansible
if [ ! -d "ansible" ] || [ ! -f "ansible/roles/wordpress/main.yml" ] || [ ! -f "ansible/roles/database/main.yml" ]|| [ ! -f "ansible/playbook.yml" ]|| [ ! -f "ansible/vars.yml" ]|| [ ! -f "ansible/gcp_compute.yml" ]|| [ ! -f "ansible/ansible.cfg" ]; then
    echo "Certains fichiers Ansible sont manquants. Clonage du référentiel..."
    git clone https://github.com/JoffreyBENA/TP1-VM_WORDPRESS.git
    cd TP1-VM_WORDPRESS/ansible
else
    cd ansible
fi

# --------------------------------------------------------------------

# # Récupération des adresses IP des VMs depuis les sorties Terraform
# wordpress_vm_public_ip=$(terraform output wordpress_vm_public_ip)
# db_vm_private_ip=$(terraform output db_vm_private_ip)

# # Chemin vers le fichier hosts (inventaire Ansible)
# hosts_file="./inventory/hosts"

# # Création du fichier d'inventaire dynamique "hosts" pour Ansible
# echo "Création du fichier hosts pour Ansible..."

# echo "[wordpress_vm]" >> $hosts_file
# echo $wordpress_vm_public_ip >> $hosts_file
# echo "[db_vm]" >> $hosts_file
# echo $db_vm_private_ip >> $hosts_file

# echo "Le fichier d'inventaire Ansible a été créé : $hosts_file"

# echo "wordpress_machine ansible_host=${wordpress_vm_public_ip}" >> $hosts_file
# echo "database_machine ansible_host=${db_vm_private_ip}" >> $hosts_file

# --------------------------------------------------------------------

# # Vérification et création de clé SSH pour WordPress VM
# if [ ! -f "$HOME/.ssh/id_rsa" ]; then
#     echo "Création d'une clé SSH pour la machine WordPress..."
#     ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
# fi

# # Copie de la clé publique sur la machine WordPress
# echo "Copie de la clé publique sur la machine WordPress..."
# ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "root@$wordpress_vm_public_ip"

# # Vérification et création de clé SSH pour Database VM
# if [ ! -f "$HOME/.ssh/id_rsa_db" ]; then
#     echo "Création d'une clé SSH pour la machine Database..."
#     ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa_db"
# fi

# # Copie de la clé publique sur la machine Database
# echo "Copie de la clé publique sur la machine Database..."
# ssh-copy-id -i "$HOME/.ssh/id_rsa_db.pub" "root@$db_vm_private_ip"

# --------------------------------------------------------------------

# Déploiement avec Ansible
echo "Déploiement avec Ansible..."
ansible-playbook playbook.yml -i ./gcp_compute.yml -vvv
cd ..

# --------------------------------------------------------------------

# Utilisation des variables du projet
ZONE="europe-west9-a"
WORDPRESS_INSTANCE="wordpress-vm"

# Récupère l'adresse IP publique de l'instance WordPress
wordpress_ip=$(gcloud compute instances describe $WORDPRESS_INSTANCE --zone $ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# URL de votre site WordPress
wp_domain="monsite.com"  # Remplacez par le nom de domaine de votre site
url_to_check="http://$wordpress_ip/wordpress"

# Effectuer une requête GET à l'URL spécifiée et stocker le code de statut dans une variable
status_code=$(curl -s -o /dev/null -w "%{http_code}" $url_to_check)

if [ $status_code -eq 200 ] || [ $status_code -eq 301 ] || [ $status_code -eq 302 ]; then
    echo "L'application WordPress est fonctionnelle. Code : $status_code"
else
    echo "L'application WordPress n'est pas fonctionnelle. Code : $status_code"
fi