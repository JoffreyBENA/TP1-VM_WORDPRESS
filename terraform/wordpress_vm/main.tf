resource "google_compute_instance" "wordpress_vm" {
    name         = var.wordpress_vm
    machine_type = var.type
    zone         = var.zone
    tags         = ["wordpress-vm"]

    service_account {
        email  = var.service_account_email
        scopes = ["cloud-platform"]
    }

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-12"
        }
    }

    network_interface {
        network     = var.network_self_link
        subnetwork  = var.subnet_self_link
    access_config {
        }
    }
}