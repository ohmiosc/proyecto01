module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "3.5.0"
  name = "${var.product}-${var.environment_prefix}-ecs"

  container_insights = true

  #capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  #default_capacity_provider_strategy = [
  #  {
  #    capacity_provider = "FARGATE_SPOT"
  #  }
  #]

  tags = {
    ResourceType = "ecs"
  }
}