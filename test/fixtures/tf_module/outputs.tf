output "allow_ssh_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows SSH ingress."
  value       = "${module.app.allow_ssh_ingress_firewall_rule_name}"
}

output "allow_http_ingress_firewall_rule_name" {
  description = "The name of the firewall rule which allows HTTP ingress."
  value       = "${module.app.allow_http_ingress_firewall_rule_name}"
}

output "allow_data_ingress_to_db_firewall_rule_name" {
  description = "The name of the firewall rule which allows data ingress to the database."
  value       = "${module.app.allow_data_ingress_to_db_firewall_rule_name}"
}

output "app_name" {
  description = "The name of the application compute instance."
  value       = "${module.app.name}"
}

output "network_name" {
  description = "The name of the network in which resources are deployed."
  value       = "${module.network.name}"
}
