#################################################################################################
# This file describes the Load Balancer resources: ALB, ALB target group, ALB listener
#################################################################################################

#Defining the Application Load Balancer
resource "aws_alb" "booking_alb" {
  name                      = "booking"
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  security_groups           = [aws_security_group.alb_sg.id]
}

#Defining the target group and a health check on the application
resource "aws_lb_target_group" "booking_tg" {
  name                      = "booking-tg"
  port                      = var.container_port
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = aws_vpc.vpc.id
  health_check {
      path                  = "/actuator/health"
      protocol              = "HTTP"
      matcher               = "200"
      port                  = "traffic-port"
      healthy_threshold     = 2
      unhealthy_threshold   = 2
      timeout               = 10
      interval              = 30
  }
}

#Defines an HTTP Listener for the ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn         = aws_alb.booking_alb.arn
  port                      = "80"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.booking_tg.arn
  }
}
