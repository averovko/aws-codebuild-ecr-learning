data "aws_caller_identity" "current" { }

provider "aws" {
    profile = "agilevision"
    region = "us-east-1"
}

resource "aws_iam_role" "codebuild-nanoramic-odoo-service-role" {
  name = "codebuild-nanoramic-odoo-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild-nanoramic-odoo-role-policy" {
  name = "codebuild-nanoramic-odoo-role-policy"
  role = "${aws_iam_role.codebuild-nanoramic-odoo-service-role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_ecr_repository" "nanoramic-odoo" {
  name = "nanoramic-odoo"
}

resource "aws_codebuild_project" "nanoramic-odoo-base" {
  name          = "nanoramic-odoo-base"
  description   = "nanoramic-odoo-base docker image with odoo"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-nanoramic-odoo-service-role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.nanoramic-odoo.name}"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "base"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/averovko/aws-codebuild-ecr-learning.git"
    git_clone_depth = 1
    buildspec       = "build/buildspec-base.yml"
  }
}

resource "aws_codebuild_project" "nanoramic-odoo-enterprise" {
  name          = "nanoramic-odoo-enterprise"
  description   = "nanoramic-odoo-enterprise docker image with odoo"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-nanoramic-odoo-service-role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.nanoramic-odoo.name}"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "enterprise"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/averovko/aws-codebuild-ecr-learning.git"
    git_clone_depth = 1
    buildspec       = "build/buildspec-enterprise.yml"
  }
}

resource "aws_codebuild_project" "nanoramic-odoo-production" {
  name          = "nanoramic-odoo-production"
  description   = "nanoramic-odoo-production docker image with odoo"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-nanoramic-odoo-service-role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.nanoramic-odoo.name}"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "production"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/averovko/aws-codebuild-ecr-learning.git"
    git_clone_depth = 1
    buildspec       = "build/buildspec-production.yml"
  }
}
resource "aws_codebuild_webhook" "nanoramic-odoo-production-push-master-webhook" {
  project_name = "${aws_codebuild_project.nanoramic-odoo-production.name}"
  branch_filter = "master"
}

resource "aws_codebuild_project" "nanoramic-odoo-dev" {
  name          = "nanoramic-odoo-dev"
  description   = "nanoramic-odoo-dev docker image with odoo"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-nanoramic-odoo-service-role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.nanoramic-odoo.name}"
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "dev"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/averovko/aws-codebuild-ecr-learning.git"
    git_clone_depth = 1
    buildspec       = "build/buildspec-development.yml"
  }
}
resource "aws_codebuild_webhook" "nanoramic-odoo-dev-push-master-webhook" {
  project_name = "${aws_codebuild_project.nanoramic-odoo-dev.name}"
  branch_filter = "^(?!master).*$"
}