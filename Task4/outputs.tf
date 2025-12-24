output "vpc_network_id" {
  description = "VPC Network ID"
  value       = yandex_vpc_network.main.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = yandex_vpc_subnet.public.id
}

output "private_subnet_1_id" {
  description = "Private Subnet 1 ID"
  value       = yandex_vpc_subnet.private1.id
}

output "private_subnet_2_id" {
  description = "Private Subnet 2 ID"
  value       = yandex_vpc_subnet.private2.id
}

output "private_subnet_3_id" {
  description = "Private Subnet 3 ID"
  value       = yandex_vpc_subnet.private3.id
}

output "portal_vm_external_ip" {
  description = "External IP of Portal VM"
  value       = yandex_compute_instance.portal.network_interface.0.nat_ip_address
}

output "api_gateway_vm_external_ip" {
  description = "External IP of API Gateway VM"
  value       = yandex_compute_instance.api_gateway.network_interface.0.nat_ip_address
}

output "etl_vm_internal_ip" {
  description = "Internal IP of ETL VM"
  value       = yandex_compute_instance.etl.network_interface.0.ip_address
}

output "fintech_vm_internal_ip" {
  description = "Internal IP of Fintech VM"
  value       = yandex_compute_instance.fintech.network_interface.0.ip_address
}

output "ai_vm_internal_ip" {
  description = "Internal IP of AI Services VM"
  value       = yandex_compute_instance.ai.network_interface.0.ip_address
}

output "data_mart_vm_internal_ip" {
  description = "Internal IP of Data Mart VM"
  value       = yandex_compute_instance.data_mart.network_interface.0.ip_address
}

output "legacy_dwh_vm_internal_ip" {
  description = "Internal IP of Legacy DWH VM"
  value       = yandex_compute_instance.legacy_dwh.network_interface.0.ip_address
}

output "event_bus_vm_internal_ip" {
  description = "Internal IP of Event Bus VM"
  value       = yandex_compute_instance.event_bus.network_interface.0.ip_address
}

output "object_storage_bucket_name" {
  description = "Object Storage Bucket Name"
  value       = yandex_storage_bucket.object_storage.bucket
}

