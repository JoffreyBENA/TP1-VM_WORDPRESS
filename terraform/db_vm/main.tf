resource "google_compute_instance" "db_vm" {
    name         = var.db_vm
    machine_type = var.type
    zone         = var.zone

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-12"
        }
    }

    network_interface {
        network     = var.network_self_link
        subnetwork  = var.subnet_self_link
    access_config {}
    }

    metadata_startup_script = <<SCRIPT
            #!/bin/bash
        apt-get update
        apt-get install -y ansible
        ansible-playbook ansible/roles/database/main.yml
    SCRIPT
    }
