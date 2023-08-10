provider "google" {
    credentials = file("../credentials.json")
    project     = var.project_id
    region      = var.region
    zone        = var.zone
    scopes      = [ "https://www.googleapis.com/auth/cloud-platform" ]
}

module "vpc" {
    source      = "./vpc"
    subnet_cidr = var.subnet_cidr
}

module "firewall" {
    depends_on          = [ module.vpc ]
    source              = "./firewall"
    network_self_link   = module.vpc.network_self_link
    firewall_source     = var.firewall_source
}

module "wordpress_vm" {
    depends_on          = [ module.vpc ]
    source              = "./wordpress_vm"
    subnet_self_link    = module.vpc.subnet_self_link
}

module "db_vm" {
    depends_on          = [ module.vpc ]
    source              = "./db_vm"
    subnet_self_link    = module.vpc.subnet_self_link
}
