provider "alicloud" {
  access_key = "xx"
  secret_key = "xx"
  region     = "default"
}

variable "name" {
  default = "kubernetes-nginx"
}

data "alicloud_zones" default {
  available_resource_creation = "VSwitch"
}

data "alicloud_instance_types" "default" {
  availability_zone    = data.alicloud_zones.default.zones[0].id
  cpu_core_count       = 2
  memory_size          = 4
  kubernetes_node_role = "Worker"
}

resource "alicloud_vpc" "default" {
  name       = var.name
  cidr_block = "10.1.0.0/21"
}

resource "alicloud_vswitch" "default" {
  name              = var.name
  vpc_id            = alicloud_vpc.default.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = data.alicloud_zones.default.zones[0].id
}

resource "alicloud_log_project" "log" {
  name        = var.log_project_name
  description = "created by terraform for managedkubernetes cluster"
}

resource "alicloud_cs_managed_kubernetes" "default" {
  name_prefix               = var.name
  availability_zone         = data.alicloud_zones.default.zones[0].id
  vswitch_ids               = [alicloud_vswitch.default.id]
  new_nat_gateway           = true
  worker_instance_types     = [data.alicloud_instance_types.default.instance_types[0].id]
  worker_number             = 2
  password                  = "password"
  pod_cidr                  = "172.20.0.0/16"
  service_cidr              = "172.21.0.0/20"
  install_cloud_monitor     = true
  slb_internet_enabled      = true
  worker_disk_category      = "cloud_efficiency"
  worker_data_disk_category = "cloud_ssd"
  worker_data_disk_size     = 200
  kube_config               = "~/.kube/config"
  log_config {
    type    = "SLS"
    project = alicloud_log_project.log.name
  }
}             


#deploy nginx
provider "kubernetes" {
  # 配置 Kubernetes API 访问信息
  host                   = "xxx"
  token                  = "xxx"
  cluster_ca_certificate = "xxx"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}


resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          ports {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"  
  }
}

#health check
resource "null_resource" "deploy_nginx" {
  provisioner "local-exec" {
    command = "kubectl get pod --kubeconfig=~/.kube/config"
  }
}



output "nginx_welcome_page" {
  value = {
    url = "http://ip"
  }
}



#!/bin/bash
container_name="your_container_name"

log_file="container_stats.log"

while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    cpu_stats=$(docker stats --no-stream $container_name --format "{{.CPUPerc}}")

    mem_stats=$(docker stats --no-stream $container_name --format "{{.MemUsage}}")

    echo "$timestamp - CPU: $cpu_stats, Memory: $mem_stats" >> $log_file

    sleep 10
done

cat $file | tr -s '[:space:]' '\n' | sort | uniq -c | sort -nr
