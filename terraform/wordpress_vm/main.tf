resource "google_compute_instance" "wordpress_vm" {
    name         = var.wordpress_vm
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
        ansible-playbook ansible/roles/wordpress/main.yml
    SCRIPT
}
