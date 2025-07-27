# Deploy ASP.NET Sample com AWS ECS + Terraform

Este projeto faz deploy da aplicação de exemplo da Microsoft ASP.NET Core (`mcr.microsoft.com/dotnet/samples:aspnetapp`) usando:

- Amazon ECS Fargate
- Amazon ECR
- Application Load Balancer (ALB)
- GitHub Actions
- Terraform

---

## 🇵🇹 Instruções

### 1. Preparar as credenciais AWS

Exportar para o terminal:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=eu-west-1
