locals {
  product_fqn = replace("${var.domain}-${var.name}", "_", "-")
}
