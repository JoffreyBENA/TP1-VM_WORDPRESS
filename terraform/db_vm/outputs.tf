output "db_vm_name" {
    description = "Nom de la machine virtuelle de base de données créée."
    value       = google_compute_instance.db_vm.name
}

output "db_vm_self_link" {
    description = "Lien vers la machine virtuelle de base de données créée."
    value       = google_compute_instance.db_vm.self_link
}

output "db_vm_private_ip" {
    description = "Adresse IP privée de la machine virtuelle de base de données."
    value = google_compute_instance.db_vm.network_interface[0].network_ip
}