variable "yandex_token" {
  description = "Yandex Cloud OAuth token (optional if using service account key)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "service_account_key_file" {
  description = "Path to service account key file (sa-key.json)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "Image ID for VMs"
  type        = string
  default     = "fd8vmcue7lajq17se8g8"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key (relative to module directory)"
  type        = string
  default     = "test_ssh_key.pub"
}

variable "object_storage_bucket_name" {
  description = "Name for object storage bucket"
  type        = string
  default     = "future-2-0-storage"
}

