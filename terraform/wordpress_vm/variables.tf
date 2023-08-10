variable "wordpress_vm" {
    type        = string
    description = "Nom de la VM Wordpress"
    default     = "wordpress-vm"
}

variable "type" {
    type        = string
    description = "Type de la VM"
    default     = "e2-small"
}

variable "zone" {
    type        = string
    description = "Zone de la VM"
    default     = "europe-west9-a"
}

variable "network_self_link" {
    type        = string
    description = "Lien vers le réseau"
    default     = "https://www.googleapis.com/compute/v1/projects/pure-anthem-393513/global/networks/my-vpc-network"
}

variable "subnet_self_link" {
    type        = string
    description = "Lien vers le sous-réseau"
    default     = "https://www.googleapis.com/compute/v1/projects/pure-anthem-393513/regions/europe-west9/subnetworks/my-vpc-subnet"
}