resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-deployer-key"
  public_key = var.deployment_key
} 