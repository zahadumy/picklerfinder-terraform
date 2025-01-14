#################################################################################################
# This file describes the Load Balancer resources: ALB, ALB target group, ALB listener
#################################################################################################

#Defining the Application Load Balancer
resource "aws_alb" "alb" {
  name                      = "pf-api"
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

resource "aws_lb_target_group" "ai-integration_tg" {
  name                      = "ai-integration-tg"
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

#Defines an HTTPS Listener for the ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:eu-central-1:590184119156:certificate/c52778ed-0f38-4f9c-8c88-5757c42b0837"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = 503
    }
  }
}

resource "aws_lb_listener_rule" "booking_listener_rule" {
  listener_arn = aws_lb_listener.listener.arn
  condition {
    path_pattern {
      values = ["/booking/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.booking_tg.arn
  }
}

resource "aws_lb_listener_rule" "ai-integration_listener_rule" {
  listener_arn = aws_lb_listener.listener.arn
  condition {
    path_pattern {
      values = ["/ai-integration/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai-integration_tg.arn
  }
}
