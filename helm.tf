locals {
  ingress_nginx_values = <<EOT
controller:
  publishService:
    enabled: true
  replicaCount: 2
  service:
    type: LoadBalancer
installCRDs: true
EOT
}

resource "helm_release" "ingress_nginx" {
  depends_on = [module.eks]

  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.8.3"
  values = [
    local.ingress_nginx_values
  ]
}

resource "helm_release" "cert_manager" {
  depends_on = [helm_release.ingress_nginx]

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "doppler_kubernetes_operator" {
  name       = "doppler-kubernetes-operator"
  repository = "https://helm.doppler.com"
  chart      = "doppler-kubernetes-operator"
}

resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "email"  = var.cert_issuer_email
        "privateKeySecretRef" = {
          "name" = "letsencrypt"
        }
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

data "kubernetes_service" "nginx_ingress" {
  depends_on = [helm_release.ingress_nginx]

  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

output "nginx_load_balancer_ip" {
  value = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname
}

output "cert_issuer_name" {
  value = "letsencrypt"
}
