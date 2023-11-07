resource aws_cloudwatch_dashboard my-dashboard {
    dashboard_name = "My-Dashboard"
    dashboard_body = file("${path.module}/dashboard-body.json",)
    }
