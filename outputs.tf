output "allow_ssh_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows SSH ingress."
  value       = "${google_compute_firewall.allow_ssh_ingress.name}"
}

output "allow_http_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows HTTP ingress."
  value       = "${google_compute_firewall.allow_http_ingress.name}"
}

output "allow_data_ingress_to_db_firewall_rule_name" {
  description = "The name of the firewall rule which allows data ingress to the database."
  value       = "${google_compute_firewall.allow_data_ingress_to_db.name}"
}

output "name" {
  description = "The name of the application compute instance."
  value       = "${google_compute_instance.app.name}"
}

output "external_ip" {
  value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "internal_ip" {
  value = "${google_compute_instance.app.network_interface.0.address}"
}
