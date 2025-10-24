variable "cluster_issuer_email" {
  description = "Email address used for ACME registration"
}

variable "cluster_issuer_name" {
  description = "Cluster issuer name which kubernetes resources can use to request certificates"
}

resource "helm_release" "cert_manager" {
  depends_on       = [helm_release.ingress_nginx]
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.8.0"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubectl_manifest" "cluster_issuer" {
  depends_on      = [helm_release.cert_manager]
  validate_schema = false
  yaml_body       = templatefile("${path.module}/specs/cert-manager-issuer-values.yaml", {
    cluster_issuer_name  = var.cluster_issuer_name
    cluster_issuer_email = var.cluster_issuer_email
  })
}
