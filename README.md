# ☁️ Cloud Resume Challenge - AWS & Terraform

¡Hola! Soy **Ángel Moreno**, y este es mi despliegue del [Cloud Resume Challenge](https://cloudresumechallenge.dev/). 
El objetivo de este proyecto es construir un currículum alojado en la nube utilizando servicios serverless de AWS, aprovisionado 100% como código (IaC) y desplegado mediante CI/CD.

## 🚀 Arquitectura y Tecnologías
* **Frontend**: HTML/CSS/JS estático alojado en un bucket de **Amazon S3**.
* **CDN & HTTPS**: Distribuido a nivel global usando **Amazon CloudFront**.
* **Backend Serverless**: API construida con **AWS Lambda** (Python) + Lambda Function URLs.
* **Base de Datos**: Contador de visitas persistente en **Amazon DynamoDB**.
* **Infraestructura como Código (IaC)**: Todo aprovisionado con **Terraform** (con gestión de estado remota en S3 + DynamoDB State Lock).
* **CI/CD**: Pipeline automatizado con **GitHub Actions** usando autenticación **OIDC** (cero credenciales estáticas).

## 💡 Retos superados
* **Gestión de Estado**: Implementación de un backend remoto con bloqueo para evitar corrupción del estado.
* **Seguridad IAM**: Aplicación de OIDC para evitar guardar secretos estáticos en GitHub, configurando políticas de Mínimo Privilegio.
* **CORS**: Resolución de problemas de comunicación entre el frontend (CloudFront) y la API (Lambda).

## 🛠️ Cómo desplegar
1. Clonar el repositorio.
2. Configurar el OIDC Provider en AWS IAM.
3. Ejecutar de forma local por primera vez:
   ```bash
   terraform init
   terraform apply
