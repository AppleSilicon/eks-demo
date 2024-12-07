# main.tf
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "eks-demo" {
  metadata {
    name = "eks-demo"
  }
}

resource "kubernetes_deployment" "http_server" {
  metadata {
    name      = "http-server"
    namespace = "eks-demo"
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
          image = "653418259700.dkr.ecr.ap-east-1.amazonaws.com/demo/ecr:latest"

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
    namespace = "eks-demo"
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