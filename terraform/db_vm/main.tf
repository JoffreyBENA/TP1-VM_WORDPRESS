resource "google_compute_instance" "db_vm" {
    name         = var.db_vm
    machine_type = var.type
    zone         = var.zone
    tags         = ["db-vm","ansible"]

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