output "allow_ssh_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows SSH ingress."
  value       = "${google_compute_firewall.app_tcp22_ingress.name}"
}

output "allow_http_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows HTTP ingress."
  value       = "${google_compute_firewall.app_tcp80_ingress.name}"
}

output "allow_data_ingress_to_db_firewall_rule_name" {
  description = "The name of the firewall rule which allows data ingress to the database."
  value       = "${google_compute_firewall.app_to_db_tcp28015_ingress.name}"
}

output "name" {
  description = "The name of the application compute instance."
  value       = "${google_compute_instance.app.name}"
}
