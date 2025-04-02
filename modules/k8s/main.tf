#
# Deployment
#
resource "kubernetes_deployment_v1" "deployment_nginx" {
  metadata {
    name = "deployment-nginx"
  }

  spec {
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
        // list of gcp provided containers: https://console.cloud.google.com/artifacts/docker/google-containers/us/gcr.io
        container {
          image = "nginx:latest"
          name  = "nginx-container"

          port {
            container_port = 80
            name           = "container-nginx"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }
}

#
# K8S service / loadbalancer
#

# deploy an external loadbalancer (with public ip) in this case
# can be an internal (with private ip only) if to be used only inside vpc resources

resource "kubernetes_service_v1" "service-nginx" {
  metadata {
    name = "service-nginx"
    annotations = {
      #"networking.gke.io/load-balancer-type" = "Internal" # Remove to create an external loadbalancer
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.deployment_nginx.spec[0].selector[0].match_labels.app
    }

    # we don't have dual stack, i.e. ipv4 + ipv6, in this case
    #ip_family_policy = "RequireDualStack"

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.deployment_nginx.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "LoadBalancer"
  }
}


#
# Add Pod Autoscalling
#
resource "kubernetes_horizontal_pod_autoscaler_v2" "nginx_hpa" {
  metadata {
    name = "nginx-hpa"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.deployment_nginx.metadata[0].name
    }

    min_replicas = 2  # Minimum number of pods
    max_replicas = 4  # Maximum number of pods

    metric {
      type = "Resource"
      resource {
        name  = "cpu"
        target {
          type               = "Utilization"
          average_utilization = 50 # Target CPU usage (percentage)
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name  = "memory"
        target {
          type               = "Utilization"
          average_utilization = 70 # Target Memory usage (percentage)
        }
      }
    }
  }
}
