#
# Create a loadbalancer using community module
#
module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 9.0"

  project           = var.project
  name              = "nginx-http-lb"
  target_tags       = ["nginx-server"]
  backends = {
    default = {
      port                            = 80
      protocol                        = "HTTP"
      port_name                       = "http"
      timeout_sec                     = 10
      enable_cdn                      = false


      health_check = {
        request_path        = "/"
        port                = 80
      }

      log_config = {
        enable = true
        sample_rate = 1.0
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = var.mig_nginx
        },
      ]

      iap_config = {
        enable               = false
      }
    }
  }
}