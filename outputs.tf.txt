output "bms_server_public_ip" {
  description = "Public IP of the BMS / Jenkins / SonarQube server"
  value       = aws_instance.bms_server.public_ip
}

output "bms_server_private_ip" {
  description = "Private IP of the BMS server"
  value       = aws_instance.bms_server.private_ip
}

output "k8s_node1_public_ip" {
  description = "Public IP of Kubernetes worker node 1"
  value       = aws_instance.k8s_node1.public_ip
}

output "k8s_node1_private_ip" {
  description = "Private IP of Kubernetes worker node 1"
  value       = aws_instance.k8s_node1.private_ip
}

output "k8s_node2_public_ip" {
  description = "Public IP of Kubernetes worker node 2"
  value       = aws_instance.k8s_node2.public_ip
}

output "k8s_node2_private_ip" {
  description = "Private IP of Kubernetes worker node 2"
  value       = aws_instance.k8s_node2.private_ip
}

output "monitoring_server_public_ip" {
  description = "Public IP of the Monitoring server (Prometheus + Grafana)"
  value       = aws_instance.monitoring_server.public_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.bms_server.public_ip}:8080"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.bms_server.public_ip}:9000"
}

output "app_url" {
  description = "Book My Show application URL"
  value       = "http://${aws_instance.bms_server.public_ip}:3000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_instance.monitoring_server.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_instance.monitoring_server.public_ip}:3000"
}

output "ansible_inventory_hint" {
  description = "Paste these into /etc/ansible/hosts"
  value = <<-EOT
    [ansiblegroup]
    ${aws_instance.k8s_node1.private_ip}
    ${aws_instance.k8s_node2.private_ip}
  EOT
}
