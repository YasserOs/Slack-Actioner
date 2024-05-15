resource "aws_ecr_repository" "app_ecr_repo" {
  name = "nodejs-app-repo"
  force_delete = true
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "nodejs-fargate-cluster" # Name your cluster here
}



resource "aws_ecs_task_definition" "app_task" {
  family                   = "Nodejs-Hello-world" # Name your task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "Nodejs-Hello-world",
      "image": "${aws_ecr_repository.app_ecr_repo.repository_url}:TAG",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    },
    {
        "environment": [
          {
            "name": "NRIA_OVERRIDE_HOST_ROOT",
            "value": ""
          },
          {
            "name": "NRIA_IS_FORWARD_ONLY",
            "value": "true"
          },
          {
            "name": "FARGATE",
            "value": "true"
          },
          {
            "name": "NRIA_PASSTHROUGH_ENVIRONMENT",
            "value": "ECS_CONTAINER_METADATA_URI,ECS_CONTAINER_METADATA_URI_V4,FARGATE"
          },
          {
            "name": "NRIA_CUSTOM_ATTRIBUTES",
            "value": "{\"nrDeployMethod\":\"downloadPage\"}"
          }
        ],
        "secrets": [
          {
            "valueFrom": "/newrelic-infra/ecs/license-key",
            "name": "NRIA_LICENSE_KEY"
          }
        ],
        "cpu": 256,
        "memoryReservation": 512,
        "image": "newrelic/nri-ecs:1.11.0",
        "name": "newrelic-infra"
      }
    
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 1024         # Specify the memory the container requires
  cpu                      = 512         # Specify the CPU the container requires
  execution_role_arn       = "arn:aws:iam::851725329212:role/NewRelicECSIntegration-Ne-NewRelicECSTaskExecutionR-5BId26lIdMYO"
}


# main.tf
resource "aws_ecs_service" "app_service" {
  name            = "Nodejs-service"     # Name the service
  cluster         = "${aws_ecs_cluster.my_cluster.id}"   # Reference the created Cluster
  task_definition = "${aws_ecs_task_definition.app_task.arn}" # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Set up the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Reference the target group
    container_name   = "${aws_ecs_task_definition.app_task.family}"
    container_port   = 3000 # Specify the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
  }
}