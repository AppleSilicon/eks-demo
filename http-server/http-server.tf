# main.tf
provider "kubernetes" {
  config_path = "~/.kube/config"  # Adjust this path if necessary
}

resource "kubernetes_deployment" "http_server" {
  metadata {
    name      = "http-server"
    namespace = "default"  # Change to your desired namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "http-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "http-server"
        }
      }

      spec {
        container {
          name  = "http-server"
          image = "653418259700.dkr.ecr.ap-east-1.amazonaws.com/heals/ecr:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "http_server" {
  metadata {
    name      = "http-server"
    namespace = "default"  # Change to your desired namespace
  }

  spec {
    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 80
    }

    selector = {
      app = kubernetes_deployment.http_server.metadata[0].name
    }
  }
}