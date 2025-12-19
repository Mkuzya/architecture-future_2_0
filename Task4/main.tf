terraform {
  required_version = ">= 1.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.95"
    }
  }
}

provider "yandex" {
  # Используем сервисный аккаунт, если указан, иначе OAuth токен
  service_account_key_file = var.service_account_key_file != "" ? var.service_account_key_file : null
  token                    = var.service_account_key_file == "" ? var.yandex_token : null
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

# Get Ubuntu 22.04 image
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
  folder_id = "standard-images"
}

# VPC
resource "yandex_vpc_network" "main" {
  name = "future-2-0-network"
}

# Public Subnet
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Private Subnet 1
resource "yandex_vpc_subnet" "private1" {
  name           = "private-subnet-1"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.private1.id
}

# Private Subnet 2
resource "yandex_vpc_subnet" "private2" {
  name           = "private-subnet-2"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.3.0/24"]
  route_table_id = yandex_vpc_route_table.private2.id
}

# Private Subnet 3
resource "yandex_vpc_subnet" "private3" {
  name           = "private-subnet-3"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.4.0/24"]
  route_table_id = yandex_vpc_route_table.private3.id
}

# Internet Gateway (автоматически создаётся при использовании NAT)
# NAT Gateway для приватных подсетей
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  
  lifecycle {
    ignore_changes = all  # Игнорируем все изменения, так как gateway уже создан и используется
  }
}

# Route table for private subnet 1
resource "yandex_vpc_route_table" "private1" {
  name       = "private-route-table-1"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Route table for private subnet 2
resource "yandex_vpc_route_table" "private2" {
  name       = "private-route-table-2"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Route table for private subnet 3
resource "yandex_vpc_route_table" "private3" {
  name       = "private-route-table-3"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# VM: Portal
resource "yandex_compute_instance" "portal" {
  name        = "portal-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# VM: API Gateway
resource "yandex_compute_instance" "api_gateway" {
  name        = "api-gateway-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# VM: ETL
resource "yandex_compute_instance" "etl" {
  name        = "etl-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private1.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# VM: Fintech
resource "yandex_compute_instance" "fintech" {
  name        = "fintech-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private1.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# VM: AI Services
resource "yandex_compute_instance" "ai" {
  name        = "ai-services-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 4  # Уменьшено с 8 до 4 для освобождения vCPU под Data Mart
    memory = 8  # Уменьшено с 16 до 8
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 100
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private2.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# VM: Data Mart
resource "yandex_compute_instance" "data_mart" {
  name        = "data-mart-vm-new"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2  # Минимум для standard-v2 (нельзя меньше)
    memory = 4  # Минимум из-за квот
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20  # Минимум
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data_mart_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private2.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# VM: Legacy DWH
resource "yandex_compute_instance" "legacy_dwh" {
  name        = "legacy-dwh-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2  # Уменьшено до минимума из-за квот на vCPU
    memory = 8  # Уменьшено до минимума из-за квот
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 30  # Уменьшено до минимума
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.legacy_dwh_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private3.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# VM: Event Bus
resource "yandex_compute_instance" "event_bus" {
  name        = "event-bus-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private3.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${path.module}/${var.ssh_public_key_path}")}"
  }
}

# Disk: Data Mart
resource "yandex_compute_disk" "data_mart_disk" {
  name = "data-mart-disk"
  type = "network-hdd"  # Изменено с network-ssd на network-hdd из-за квот
  zone = var.zone
  size = 20  # Уменьшено до минимума из-за квот на диски
}

# Disk: Legacy DWH
resource "yandex_compute_disk" "legacy_dwh_disk" {
  name = "legacy-dwh-disk"
  type = "network-hdd"  # Изменено с network-ssd на network-hdd из-за квот
  zone = var.zone
  size = 20  # Уменьшено до минимума из-за квот на диски
}

# Object Storage Bucket
# Bucket is private by default (no public access)
resource "yandex_storage_bucket" "object_storage" {
  bucket    = var.object_storage_bucket_name
  folder_id = var.folder_id
}

