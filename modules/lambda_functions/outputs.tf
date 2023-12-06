output "daily_coffee_name" {
  description = "Daily coffee lambda name"
  value       = aws_lambda_function.daily_coffee.function_name
}

output "daily_coffee_arn" {
  description = "Daily coffee lambda invoke arn"
  value       = aws_lambda_function.daily_coffee.invoke_arn
}
