# Cloud Resume Challenge - Ángel Moreno

Este es mi primer proyecto completo del Cloud Resume Challenge. Lo he montado desde cero mientras estoy aprendiendo DevOps y Terraform.

### 🌐 Web en vivo
- **Página**: https://d39d0oxdds4ymu.cloudfront.net  
  (actualiza la página varias veces y verás cómo sube el contador de visitas)

### 🛠️ Qué usé
- Terraform (todo el despliegue)
- S3 + CloudFront (web estática + HTTPS rápido)
- Lambda + DynamoDB (el contador de visitas)
- Python en la Lambda

Todo se despliega con un solo `terraform apply`.

### Cómo probarlo tú mismo
```bash
terraform init
terraform apply -auto-approve
