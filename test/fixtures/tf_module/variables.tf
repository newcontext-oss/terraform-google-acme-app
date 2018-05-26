variable "engineer_cidrs" {
  description = "CIDR blocks to allow into the servers"
  type        = "list"
}

variable "gcloud_project" {
  description = "The Google Cloud project in which to create resource."
  type        = "string"
}

variable "gcloud_region" {
  description = "The Google Cloud region in which to create resource."
  type        = "string"
}

variable "google_application_credentials" {
  description = "A JSON file which describes the account credentials."
  type        = "string"
}
