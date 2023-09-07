# TP1-VM_WORDPRESS

Documentation du Déploiement Automatisé d'un site WordPress sur Google Cloud Platform (GCP)

## Description des fichiers fournis :
```
.
├── README.md
├── README2.md
├── ansible
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yml
│   ├── roles
│   │   ├── database
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── wordpress
│   │       ├── handlers
│   │       │   └── main.yml
│   │       ├── tasks
│   │       │   └── main.yml
│   │       └── templates
│   │           └── wp-config.php.j2
│   └── vars.yml
├── creation-inventory.sh
├── credentials.json
├── deploy.sh
├── deployment-schema
│   └── deployment-wordpress-gcp.drawio.png
├── ssh_keys
├── terraform
│   ├── db_vm
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── firewall
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── service_account
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── variables.tf
│   ├── vpc
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── wordpress_vm
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── terraform-destroy.sh
├── terraform.tfstate
└── tp_1_VM_WORDPRESS.pdf
```

* README.md : Le fichier que vous lisez actuellement, qui contient la documentation du projet.

* ansible : Le répertoire contenant les fichiers et les rôles Ansible pour le déploiement de votre application.

* creation-inventory.sh : Un script pour générer un fichier d'inventaire Ansible à partir de votre infrastructure.

* credentials.json : Fichier de configuration contenant des informations d'identification pour se connecter a votre compte GCP

* deploy.sh : Un script pour déployer votre application en utilisant Terraform et Ansible.

* deployment-schema : Le répertoire contenant des schémas de déploiement.

* ssh_keys : clés SSH pour l'infrastructure.

* terraform : Le répertoire contenant les fichiers Terraform pour le déploiement de votre infrastructure.

* terraform-destroy.sh : Un script pour détruire l'infrastructure créée avec Terraform.

* tp_1_VM_WORDPRESS.pdf : Sujet du TP sous format PDF



Use the package manager [pip](https://pip.pypa.io/en/stable/) to install foobar.

Description des pré-requis
Pour exécuter ce projet avec succès, vous devez vous assurer de disposer des éléments suivants :

Une machine de développement avec Ansible installé.
Un compte sur la plateforme cloud (par exemple, Google Cloud Platform) avec les autorisations appropriées.
Les clés SSH nécessaires pour accéder à vos machines virtuelles.
Schéma de présentation du déploiement
Vous pouvez trouver des schémas de déploiement dans le répertoire "deployment-schema" du projet. Ces schémas vous aident à visualiser comment les différentes composantes du projet sont déployées et interconnectées.

Configuration des scripts pour chaque client
Le répertoire "ansible" contient les scripts Ansible pour le déploiement. Vous pouvez personnaliser ces scripts en fonction des besoins spécifiques de chaque client.
Le répertoire "terraform" contient les fichiers Terraform pour la création de l'infrastructure. Vous pouvez ajuster ces fichiers en fonction des exigences particulières de chaque client.
N'oubliez pas d'ajouter des détails spécifiques sur la manière de personnaliser les scripts et les configurations pour chaque client, le cas échéant.

C'est une structure de base pour votre documentation README.md. Vous pouvez l'éditer et l'ajuster en fonction des détails spécifiques de votre projet et des informations supplémentaires que vous souhaitez inclure.
