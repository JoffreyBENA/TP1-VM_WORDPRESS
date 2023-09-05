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

# Génération de l'inventaire avec les adresses IP
    cd ./ansible
    rm -f inventory.ini
    cd ..
    ./creation-inventory.sh >ansible/inventory.ini

# --------------------------------------------------------------------

# # Création des clés SSH

# # export user=joffreym2igcp

# # Vérifier si une clé SSH est présente sur la VM, sinon en créer une
# if [ ! -f ~/.ssh/id_rsa ]; then
#     ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -C "$user"
# fi

# # Lire le contenu du fichier dans une variable
# contenu=$(cat ~/.ssh/id_rsa.pub)

# # Exporter la variable d'environnement
# export VARIABLE_CONTENU="$contenu"

# # Afficher le contenu exporté
# echo "$user:$VARIABLE_CONTENU" > ssh_keys

# # --------------------------------------------------------------------

# # Récupère la liste des noms et des zones d'instance à l'aide de gcloud
# instances_info=$(gcloud compute instances list --project $GCP_PROJECT --format="csv(NAME,ZONE)")

# # Vérifie si des instances sont trouvées
# if [ -z "$instances_info" ]; then
#     echo "Aucune instance trouvée dans le projet $GCP_PROJECT."
# else
#     echo "Liste des noms et des zones d'instance dans le projet $GCP_PROJECT :"
#     echo "$instances_info"

#     # Séparateur par défaut en bash (utilisé pour les boucles)
#     IFS=$'\n'

#     # Boucle pour traiter chaque nom d'instance et sa zone
#     for instance_info in $instances_info; do
#     # Ignorer la ligne "name,zone"
#     if [[ "$instance_info" != "name,zone" ]]; then
#         # Découpe la ligne en nom et zone en utilisant des guillemets pour éviter les problèmes d'encodage
#         IFS=',' read -r instance_name instance_zone <<< "$instance_info"

#         echo "Traitement de l'instance : $instance_name (zone : $instance_zone)"

#         # Exécute la commande gcloud avec le nom d'instance et la zone actuels
#         gcloud compute instances add-metadata "$instance_name" --zone "$instance_zone" --metadata-from-file ssh-keys=ssh_keys

#         # Vérifie le code de sortie de la commande gcloud
#         if [ $? -eq 0 ]; then
#             echo "Clé SSH ajoutée à l'instance $instance_name (zone : $instance_zone) avec succès."
#         else
#             echo "Une erreur s'est produite lors de l'ajout de la clé SSH à l'instance $instance_name (zone : $instance_zone)."
#         fi
#     fi
# done
# fi


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
if [ ! -d "ansible" ] || [ ! -f "ansible/roles/wordpress/tasks/main.yml" ] || [ ! -f "ansible/roles/database/tasks/main.yml" ]|| [ ! -f "ansible/playbook.yml" ]|| [ ! -f "ansible/vars.yml" ]|| [ ! -f "ansible/inventory.ini" ]; then
    echo "Certains fichiers Ansible sont manquants. Clonage du référentiel..."
    git clone https://github.com/JoffreyBENA/TP1-VM_WORDPRESS.git
    cd TP1-VM_WORDPRESS/ansible
else
    cd ansible
fi

# --------------------------------------------------------------------

# cd .. 

# # Vérification et création de clé SSH pour WordPress VM
# if [ ! -f "$HOME/.ssh/id_rsa" ]; then
#     echo "Création d'une clé SSH pour la machine WordPress..."
#     ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
# fi

# # Copie de la clé publique sur la machine WordPress
# echo "Copie de la clé publique sur la machine WordPress..."
# ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "joffreym2igcp@$wordpress_vm_public_ip"

# # Copie de la clé publique sur la machine Database
# echo "Copie de la clé publique sur la machine Database..."
# ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "joffreym2igcp@$db_vm_private_ip"

# cd ansible

# --------------------------------------------------------------------

# Déploiement avec Ansible
echo "Déploiement avec Ansible..."
cd ansible
ansible-playbook -i inventory.ini -b playbook.yml
cd ..

# --------------------------------------------------------------------

echo -e "\033[1;35m- Etape 7/7: Vérification fonctionnement application\033[0m"

cd terraform
wordpress_ip=$(terraform output wordpress_instance_ip | sed 's/"//g')
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
