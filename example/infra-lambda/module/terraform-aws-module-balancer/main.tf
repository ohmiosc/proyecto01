resource "aws_lb" "default" {
  
  count = var.enabled ? 1 : 0
  
  load_balancer_type = "application"

  # El nombre de tu ALB debe ser unico dentro del grupo de ALB y NLB en la región donde se despliega,
  # el nombre puede tener un máximo de 32 caracteres, puede contener solo caracteres alfanuméricos y guiones,
  # no debe empezar ni terminar con un guión, y no debe empezar con "internal-"
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-getting-started.html#configure-load-balancer
  name = var.name

  # Si esta variable es True, el ALB que se creará será internal-facing, de lo contrario, será internet-facing.
  internal = var.internal

  # Una lista de los ID's de security groups para asignar al ALB.
  # Las reglas para el security group asociado con el security group de tu balanceador de carga
  # debe permitir trafico en ambas direcciones (salientes y entrantes) y en ambos listener (80 y 443) y en el health check
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#load-balancer-security-groups
  security_groups = ["${aws_security_group.default.id}"]
  
  # Lista de ID's de las subnets sobre la cuál trabajará el ALB
  subnets = var.subnets

  # El tiempo en segundos que una conexión es permitida a estar ociosa.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#connection-idle-timeout
  idle_timeout = var.idle_timeout

  # Para prevenir que el ALB sea eliminado acidentalment, puede habilitar la protección de eliminación.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#deletion-protection
  enable_deletion_protection = var.enable_deletion_protection

  # Con una conexión HTTP/2 puedes enviar hasta 128 requests en paralelo- 
  # El ALB convierte estos requests en requests individuales HTTP/1.1
  # y los distribuye a través de targets healthy en el target group.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-configuration
  enable_http2 = var.enable_http2

  # El tipo de direcciones IP's usadas por las subnets en tu balanceador. Los posibles valores son ipv4 o dualstack.
  # Si se indica dualstack, se debe especificar las subnets con un bloque CIDR IPv6 asociado.
  # Note que los balanceadores de carga interna deben usar ipv4.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#ip-address-type
  ip_address_type = var.ip_address_type

  # ALB provee logs de acceso que capturan información detallada acerca de los requests enviados a tu balanceador
  # Incluso si el access_log_enabled está como falso, necesitas especificar el bucket s3 válido para access_logs_bucket.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enabled
  }

  # Tags para asignar al recurso.
  tags = var.tags

}


resource "aws_lb_target_group" "default" {
  count = var.enabled ? 1 : 0

  name   = "${var.name}-default"
  vpc_id = var.vpc_id

  # Puerto sobre el cual, el target group escuchará los requests
  # Este puerto es usado a menos que se especifique una sobre-escritura
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
  port = var.target_group_port

  # Protocolo a usar para enrutar el tráfico a los targets
  # Para ALB, los protocolos aceptados son HTTP y HTTPS
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
  protocol = var.target_group_protocol

  # Tipo de target que tendrá el target group.
  # Los posibles valores son "instancia" (especificando el ID de la instancia), o "ip" indicando la IP 
  # No se puede especificar dos tipos de targets.
  # Si el tipo de target es IP, debes especificar una IP de las subnets de la VPC que indicaste para el target Group. 
  # 
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-type
  target_type = var.target_type

  # Cantidad de tiempo a esperar antes de deregistrar un target.
  # Eñ rango va desde 0–3600 segundos.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-group-attributes
  deregistration_delay = var.deregistration_delay

  # El período de tiempo, en segundos, durante el cual el balancer envía
  # a un target recién registrado una parte del tráfico que aumenta linealmente en el target group
  # Eñ rango va desde 30–900 segundos (15 minutes).
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#target-group-attributes
  slow_start = var.slow_start

  # El balanceador de aplicaciones envía periódicamente requests a sus targets registrados para probar su estado.
  # Estos tests son llamados health checks.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html
  health_check {
    # Ruta destino sobre la cuál se ejecutarán las comprobaciones de estado.
    # Se debe especificar un URI válido (protocol://hostname/path?query).
    path = var.health_check_path

    # La cantidad de comprobaciones de estado exitosos y consecutivos requeridos antes de considerar que un target no-saludable  es saludable.
    # Eñ rango va desde 2–10.
    healthy_threshold = var.health_check_healthy_threshold

    # Cantidad de comprobaciones de estados fallidos y consecutivos requeridos antes de considerar
    # un targe healthy en unhealthy.
    # Eñ rango va desde 2–10.
    unhealthy_threshold = var.health_check_unhealthy_threshold

  
    # Cantidad de tiempo, en segundos, durante el cual una "no respuesta" del target significa una comprobación fallida
    # Eñ rango va desde 2–60 segundos.
    timeout = var.health_check_timeout

    # Cantidad de tiempo aproximada, en segundos entre cada comprobación de un target individual
    # Eñ rango va desde 5–300 segundos.
    interval = var.health_check_interval

    # El código HTTP a usar cuando una comprobación de estado es exitosa
    matcher = var.health_check_matcher

    # Puerto que usa el balancer cuando hace comprobaciones de estado.
    port = var.health_check_port

    # Protocolo que usa el balanceador cuando ejecuta pruebas de comprobación.
    # Los protocolos prosibles son HTTP y HTTPS.
    protocol = var.health_check_protocol
  }

  # Tags para asignar al recurso.
  tags = var.tags

  # Validar la existencia del load balancer creado
  depends_on = ["aws_lb.default"]
}



# Cuando creas un listener, defines acciones para la regla default, la regla por default no puede tener condiciones.
# Si no se cumplen condiciones para otras reglas, se aplica la regla por default.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-rules
#
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_lb_listener" "https" {
  count = local.enable_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.default[count.index].arn
  port              = var.https_port
  protocol          = "HTTPS"

  # Puedes escoger la politica de seguridad que será usada para conexiones de front-end.
  # Se recomienda la política ELBSecurityPolicy-2016-08 para uso general.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
  ssl_policy = var.ssl_policy

  # Cuando creas un listener HTTPS, debes especificar un certificado SSL
  # Si quieres agregar más certificados, entonces usa el recurso aws_lb_listener_certificate.
  # https://www.terraform.io/docs/providers/aws/r/lb_listener_certificate.html
  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.default[count.index].arn
    type = "forward"
    }
  }


resource "aws_lb_listener" "http" {
  count = local.enable_http_listener ? 1 : 0

  load_balancer_arn = aws_lb.default[count.index].arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.default[count.index].arn
    type = "forward"
    }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  count = local.enable_redirect_http_to_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.default[count.index].arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    # You can use redirect actions to redirect client requests from one URL to another.
    # You can configure redirects as either temporary (HTTP 302) or permanent (HTTP 301) based on your needs.
    # https://www.terraform.io/docs/providers/aws/r/lb_listener.html#redirect-action
    type = "redirect"

    redirect {
      port        = var.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


# Each rule has a priority. Rules are evaluated in priority order, from the lowest value to the highest value.
# The default rule is evaluated last. You can change the priority of a nondefault rule at any time.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#listener-rule-priority
#
# The priority for the rule between 1 and 50000.
# Leaving it unset will automatically set the rule with next available priority after currently existing highest rule.
# A listener can't have multiple rules with the same priority.
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
resource "aws_lb_listener_rule" "https" {
  count = local.enable_https_listener ? 1 : 0

  listener_arn = aws_lb_listener.https[count.index].arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[count.index].arn
  }

  condition {
    path_pattern {
    values = var.listener_rule_condition_values
    }
  }

  # Changing the priority causes forces new resource, then network outage may occur.
  # So, specify resources are created before destroyed.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "http" {
  count = local.enable_http_listener ? 1 : 0

  listener_arn = aws_lb_listener.http[count.index].arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[count.index].arn
  }

  condition {
    path_pattern {
    values = var.listener_rule_condition_values
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# NOTE on Security Groups and Security Group Rules:
# At this time you cannot use a Security Group with in-line rules in conjunction with any Security Group Rule resources.
# Doing so will cause a conflict of rule settings and will overwrite rules.
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "default" {
  

  name   = local.security_group_name
  vpc_id = var.vpc_id

  tags = merge(tomap({"Name" = local.security_group_name}), var.tags)
}

locals {
  security_group_name = "${var.name}"
}

# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "ingress_https" {
  count = local.enable_https_listener ? 1 : 0

  type              = "ingress"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "ingress_http" {
  count = var.enabled && var.enable_http_listener ? 1 : 0

  type              = "ingress"
  from_port         = var.http_port
  to_port           = var.http_port
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "egress" {
  count = var.enabled ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

locals {
  enable_https_listener                  = var.enabled && var.enable_https_listener
  enable_http_listener                   = var.enabled && var.enable_http_listener && !(var.enable_https_listener && var.enable_redirect_http_to_https_listener)
  enable_redirect_http_to_https_listener = var.enabled && var.enable_http_listener && (var.enable_https_listener && var.enable_redirect_http_to_https_listener)
}




















