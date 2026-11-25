# Entrega — Aula 12 (TF)

**Aluno:** Emar Cristian Silva Teruo Ito  
**RA:** 6325192  
**Data:** 25/11/2026

## Fork do projeto

- **URL:** https://github.com/iHawlKz7/implement_Moodle
- **Branch de desenvolvimento:** `feature/terraform-aws`
- **Commit de referência:** `e3b3ad4` — implementação inicial dos módulos Terraform de rede e banco de dados.

## O que foi feito nesta aula

Dei continuidade ao desafio Moodle Docker AWS, concentrando o trabalho na organização inicial da infraestrutura com Terraform. Estruturei os módulos de rede e banco de dados para manter separadas as responsabilidades de cada componente.

Na parte de rede, trabalhei na definição da VPC, das sub-redes públicas e privadas e das regras de acesso dos Security Groups. No módulo de banco de dados, organizei a configuração do PostgreSQL no RDS e as variáveis necessárias para conectar os serviços futuramente.

Também fiz verificações locais de formatação e validação desses módulos, sem realizar a implantação na AWS nesta etapa.

## Dificuldades encontradas

A principal dificuldade foi compreender como os módulos Terraform devem trocar informações, especialmente os IDs das sub-redes e dos Security Groups. Também precisei ajustar detalhes de nomenclatura dos recursos para manter a configuração compatível com as regras da AWS.

## Próximos passos

Continuar a configuração do módulo de computação (EC2) e integrar os componentes da infraestrutura, para depois preparar os testes de provisionamento no AWS Academy Learner Lab.
