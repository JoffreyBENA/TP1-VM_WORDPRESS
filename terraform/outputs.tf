output "wordpress_vm_public_ip" {
    value = module.wordpress_vm.wordpress_vm_public_ip
}

output "db_vm_private_ip" {
    value = module.db_vm.db_vm_private_ip
}

output "instance-user" {
    value = var.user
}