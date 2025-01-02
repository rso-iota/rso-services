provider "digitalocean" {
  token = var.do_token
}


resource "digitalocean_project" "rso-project" {
  description = "Racunalniske storitve v oblaku: Jan, Matej, Ziga"
  environment = null
  is_default  = false
  name        = var.project_name
  purpose     = "Class project / Educational purposes"
  resources = [
    digitalocean_kubernetes_cluster.k8s.urn
  ]
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  auto_upgrade                     = false
  cluster_subnet                   = "10.244.0.0/16"
  destroy_all_associated_resources = null
  ha                               = false
  name                             = "k8s-rso"
  region                           = "fra1"
  registry_integration             = null
  service_subnet                   = "10.245.0.0/16"
  surge_upgrade                    = true
  tags = []
  version                          = "latest"
  vpc_uuid                         = "cd611c13-093b-4cf1-a121-428a628a5ed1"
  maintenance_policy {
    day        = "any"
    start_time = "23:00"
  }
  node_pool {
    auto_scale = false
    labels = {}
    max_nodes  = 5
    min_nodes  = 1
    name       = "pool-main"
    node_count = 3
    size       = "s-2vcpu-4gb"
    tags = []
  }
}