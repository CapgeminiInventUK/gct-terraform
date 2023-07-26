variable "environment" {
  type        = string
  description = "Defines the environment to be built"
  default     = "Dev"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "UK South"
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name where all resources will be held"
  default     = "GCT"
}
