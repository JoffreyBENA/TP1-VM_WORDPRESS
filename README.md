# TP1-VM_WORDPRESS

Documentation du Déploiement Automatisé de Sites WordPress sur Google Cloud Platform

Description des fichiers fournis :

Ce dépôt contient les fichiers nécessaires pour automatiser le déploiement de sites WordPress sur Google Cloud Platform (GCP) en utilisant Terraform et Ansible.

    1- Dossier Terraform :

        - vpc/variables.tf : Définition des variables Terraform pour le réseau VPC.
        - vpc/main.tf : Configuration Terraform pour la création du VPC, du sous-réseau et des règles de pare-feu.
        - wordpress_vm/variables.tf : Définition des variables Terraform pour la machine WordPress.
        - wordpress_vm/main.tf : Configuration Terraform pour la création de la machine WordPress.
        - db_vm/variables.tf : Définition des variables Terraform pour la machine de base de données.
        - db_vm/main.tf : Configuration Terraform pour la création de la machine de base de données.

    2- Dossier Ansible :

        - playbook.yml : Playbook Ansible pour le déploiement des éléments requis sur les machines.
        - Dossier roles/wordpress : Contient les tâches et les modèles Ansible pour le déploiement de WordPress.
        - Dossier roles/database : Contient les tâches Ansible pour la configuration de la base de données.

    3- Script Bash :

        - deploy.sh : Script bash qui automatise le déploiement en vérifiant les prérequis, en lançant Terraform et Ansible, puis en effectuant une vérification de l'application.

    1- main.tf : Fichier principal de Terraform pour la création des ressources GCP (VM, réseau, pare-feu, etc.).

    2- variables.tf : Fichier de définition des variables Terraform.

    3- outputs.tf : Fichier de définition des sorties Terraform pour récupérer les informations des ressources créées.

    4- playbook.yml : Fichier Ansible pour déployer et configurer les applications WordPress et la base de données.

    5- roles/ : Répertoire contenant les rôles Ansible pour WordPress et la base de données.

    6- inventory/hosts : Fichier d'inventaire Ansible pour définir les machines cibles.

    7- deploy.sh : Script Bash pour exécuter les scripts Terraform et Ansible.

Prérequis :

Avant de procéder au déploiement automatisé, assurez-vous de disposer des éléments suivants :

    1- Compte Google Cloud Platform (GCP) : Vous devez avoir un compte GCP avec les droits nécessaires pour créer des ressources telles que des machines virtuelles (VM) et des réseaux VPC.

    2- Terraform : Assurez-vous que Terraform est installé sur votre machine de développement. Vous pouvez l'installer en suivant les instructions spécifiques à votre système d'exploitation.

    3- Ansible : Vérifiez que vous avez Ansible installé sur votre machine. Si ce n'est pas le cas, installez-le en suivant les instructions adaptées à votre système d'exploitation.

    4- Configuration de Google Cloud SDK : Assurez-vous que vous avez configuré Google Cloud SDK avec vos informations d'identification GCP. Cela vous permettra d'interagir avec votre projet GCP via la ligne de commande.

Schéma de présentation du déploiement :

Le déploiement automatisé des sites WordPress sur GCP avec Terraform et Ansible suit l'architecture suivante (voir le schéma dans le dossier TP1-VM_WORDPRESS/deployment-schema ):

    - L'architecture comprend deux machines virtuelles (VM) : une pour WordPress et une autre pour la base de données MySQL/MariaDB.
        - La machine WordPress est accessible publiquement et contient PHP, Apache et l'application WordPress.
        - La machine de base de données n'est pas accessible publiquement et contient MySQL/MariaDB avec un utilisateur spécifique pour WordPress.
    - Ainsi les visiteurs accèdent au site WordPress via un équilibrage de charge (load balancer) qui dirige les requêtes vers les machines virtuelles (VM) du serveur Web. Le serveur Web communique avec le serveur de base de données pour stocker et récupérer les données de WordPress.

Configuration des scripts pour chaque client :

Pour configurer le déploiement pour chaque client, vous devez effectuer les étapes suivantes :

    1- Modifier les fichiers Terraform dans le répertoire vpc pour spécifier le projet GCP et la région souhaités.

    2- Modifier les fichiers Terraform dans le répertoire wordpress_vm pour ajuster la taille de la VM et les autres paramètres selon les besoins du client.

    3- Modifier les fichiers Terraform dans le répertoire db_vm pour ajuster la taille de la VM et les autres paramètres selon les besoins du client.

    4- Dans le fichier playbook.yml, ajustez les tâches Ansible selon les spécifications du client, telles que l'installation de plugins WordPress, la personnalisation du thème, etc.

    5- Dans le fichier inventory/hosts, remplacez les adresses IP par les adresses IP réelles des machines cibles du client.

Une fois que vous avez effectué ces modifications pour chaque client, vous pouvez exécuter les scripts Terraform et Ansible pour déployer et configurer les sites WordPress sur GCP en utilisant la commande suivante :

    bash deploy.sh

Assurez-vous que les outils requis (Terraform, Ansible) sont installés et que vous disposez des autorisations nécessaires pour accéder à GCP et aux machines cibles.

Pour configurer les scripts pour chaque client, vous devez effectuer les étapes suivantes :

    1- Dossier Terraform :

        - Dans les fichiers vpc/variables.tf, wordpress_vm/variables.tf et db_vm/variables.tf, ajustez les variables selon les besoins spécifiques du client. Par exemple, vous pouvez modifier la région, la zone, etc.

    2- Dossier Ansible :

        - Dans le playbook playbook.yml, personnalisez les tâches selon les besoins du client. Par exemple, vous pouvez ajouter des rôles supplémentaires, des tâches de configuration spécifiques, etc.
        - Dans les dossiers roles/wordpress et roles/database, personnalisez les modèles et les tâches Ansible en fonction des exigences du client. Vous pouvez personnaliser les fichiers de configuration WordPress, les utilisateurs de base de données, etc.

    3- Script Bash :

        - Dans le script deploy.sh, personnalisez les commandes d'installation de Terraform et d'Ansible pour correspondre à votre système d'exploitation.
        - Dans le bloc "Vérification de l'application", remplacez la commande curl et le texte attendu par des vérifications spécifiques à l'application du client. Par exemple, vous pouvez vérifier la présence d'un élément personnalisé sur la page d'accueil du site.

En personnalisant les fichiers et les scripts pour chaque client, vous pouvez créer des configurations uniques pour chaque déploiement de site WordPress sur Google Cloud Platform.

N'oubliez pas de sauvegarder et versionner tous les fichiers de configuration et les scripts pour assurer une gestion efficace et reproductible des déploiements.

Cette documentation vous fournit les informations nécessaires pour utiliser les fichiers Terraform, Ansible et le script Bash afin de déployer automatiquement des sites WordPress dans des machines virtuelles sur Google Cloud Platform.
