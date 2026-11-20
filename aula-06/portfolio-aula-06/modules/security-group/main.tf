# modules/security-group/main.tf
# Módulo genérico de Security Group — funciona para API, RDS, bastion, ALB, etc.

resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.environment}-${var.name}"
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.name}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ─── REGRAS DE INGRESS (for_each na lista) ────────────────────────────────────
# Criamos cada regra como recurso separado para melhor granularidade.
# Usar aws_security_group_rule evita recriar o SG inteiro ao mudar uma regra.

resource "aws_security_group_rule" "ingress" {
  for_each = {
    for idx, rule in var.ingress_rules :
    "${rule.description}-${rule.port}" => rule
  }

  type              = "ingress"
  security_group_id = aws_security_group.this.id
  description       = each.value.description
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol

  # Usa cidr_blocks se informado, senão usa source_security_group_id
  cidr_blocks              = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null
  source_security_group_id = each.value.source_sg_id != "" ? each.value.source_sg_id : null
}

# ─── EGRESS PADRÃO — todo tráfego de saída permitido ─────────────────────────

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.this.id
  description       = "All outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
