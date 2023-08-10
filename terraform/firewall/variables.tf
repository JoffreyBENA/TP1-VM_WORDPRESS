variable "firewall_source" {
    description = "IP source pour le firewall"
    default     = ["0.0.0.0/0"]
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