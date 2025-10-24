resource "helm_release" "ingress_nginx" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  # AWS-specific Load Balancer configuration (ALB/NLB)
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
  }
}

data "kubernetes_service" "ingress_nginx_service" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    name = "nginx-ingress-ingress-nginx-controller"
  }
}

output "ingress_nginx_service_external_ip" {
  value = data.kubernetes_service.ingress_nginx_service.status.0.load_balancer.0.ingress.0.hostname
}
