variable "project_id" {
    type        = string
    description = "ID du projet GCP"
    default     = "pure-anthem-393513"
}

variable "region" {
    type        = string
    description = "Région GCP"
    default     = "europe-west9"
}

variable "zone" {
    type        = string
    description = "Zone GCP"
    default     = "europe-west9-a"
}

variable "subnet_cidr" {
    type        = string
    description = "CIDR de la sous-réseau"
    default     = "10.0.0.0/24"
}

variable "firewall_source" {
    description = "IP source pour le firewall"
    default     = ["0.0.0.0/0"]
}