variable "subscription_id" {
  type = string
}
variable "resource_group_name" {
  type    = string
  default = "hmezouarRG"
}
variable "location" {
  type    = string
  default = "francecentral"
}
variable "vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}
variable "ssh_public_key" {
  type = string
}
variable "candidate_cidr" {
  description = "Only the candidate's public IPv4 /32 may access SSH permanently."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.candidate_cidr)) && endswith(var.candidate_cidr, "/32") && var.candidate_cidr != "0.0.0.0/32"
    error_message = "Provide the candidate's public IPv4 address followed by /32."
  }
}
