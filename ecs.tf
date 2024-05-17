##########################################################################################
# This file describes the ECS resources: ECS cluster, ECS task definition, ECS service
##########################################################################################

#ECS cluster
resource "aws_ecs_cluster" "development_ecs_cluster" {
    name                                = "development"
}

#The Task Definition used in conjunction with the ECS service
resource "aws_ecs_task_definition" "booking_td" {
    family                              = "booking-td"
    # container definitions describes the configurations for the task
    container_definitions               = jsonencode(
    [
    {
        "name"                          : "booking-container",
        "image"                         : "${aws_ecr_repository.booking_ecr.repository_url}:latest",
        "entryPoint"                    : []
        "essential"                     : true,
        "networkMode"                   : "awsvpc",
        "portMappings"                  : [
                                            {
                                                "containerPort" : var.container_port,
                                                "hostPort"      : var.container_port,
                                            }
                                          ]
        "healthCheck"                   : {
                                            "command"     : [ "CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1" ],
                                            "interval"    : 30,
                                            "timeout"     : 5,
                                            "startPeriod" : 180,
                                            "retries"     : 3
                                          }
    }
    ] 
    )
    #Fargate is used as opposed to EC2, so we do not need to manage the EC2 instances. Fargate is serverless
    requires_compatibilities            = ["FARGATE"]
    network_mode                        = "awsvpc"
    cpu                                 = "256"
    memory                              = "512"
    execution_role_arn                  = aws_iam_role.ecsTaskExecutionRole.arn
    task_role_arn                       = aws_iam_role.ecsTaskRole.arn
}

#The ECS service described. This resources allows you to manage tasks
resource "aws_ecs_service" "booking_service" {
    name                                = "booking-ecs-service"
    cluster                             = aws_ecs_cluster.development_ecs_cluster.arn
    task_definition                     = aws_ecs_task_definition.booking_td.arn
    launch_type                         = "FARGATE"
    scheduling_strategy                 = "REPLICA"
    desired_count                       = 1 # the number of tasks you wish to run
    health_check_grace_period_seconds   = 180

  network_configuration {
    subnets                             = [aws_subnet.private_subnet_1.id , aws_subnet.private_subnet_2.id]
    assign_public_ip                    = false
    security_groups                     = [aws_security_group.ecs_sg.id, aws_security_group.alb_sg.id]
  }

# This block registers the tasks to a target group of the loadbalancer.
  load_balancer {
    target_group_arn                    = aws_lb_target_group.booking_tg.arn
    container_name                      = "booking-container"
    container_port                      = var.container_port
  }
  depends_on                            = [aws_lb_listener.listener]
}
