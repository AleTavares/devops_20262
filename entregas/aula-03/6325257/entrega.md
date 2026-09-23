# Entrega — Aula 03: Terraform + IAM

**Aluno:** Luiza Carneiro Rolfsen
**RA:** 6325257
**Data:** 23/09/2026

## Repositório

- URL: https://github.com/luizarolfsen/unifaat-devops-portfolio

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com mínimo 3 custom policies
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias em todos os recursos
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

$ terraform plan -var="aluno=Luiza Carneiro Rolfsen" -var="ra=6325257"

Terraform will perform the following actions:

aws_iam_group.developers will be created
resource "aws_iam_group" "developers" {
name = "6325257-technova-developers" }
aws_iam_group.platform_eng will be created
resource "aws_iam_group" "platform_eng" {
name = "6325257-technova-platform-eng" }
aws_iam_user.juliana_dev will be created
resource "aws_iam_user" "juliana_dev" {
name = "6325257-juliana-dev"
tags = { "Aluno" = "Luiza Carneiro Rolfsen", "RA" = "6325257", ... } }
aws_iam_user.rafael_platform will be created
resource "aws_iam_user" "rafael_platform" {
name = "6325257-rafael-platform" }
aws_iam_user.lucas_intern will be created
resource "aws_iam_user" "lucas_intern" {
name = "6325257-lucas-intern" }
aws_iam_policy.s3_read will be created
resource "aws_iam_policy" "s3_read" {
name = "6325257-technova-s3-read" }
aws_iam_policy.ec2_s3_full will be created
resource "aws_iam_policy" "ec2_s3_full" {
name = "6325257-technova-ec2-s3-full" }
aws_iam_policy.deny_destructive will be created
resource "aws_iam_policy" "deny_destructive" {
name = "6325257-technova-deny-destructive" }
aws_iam_role.ec2_role will be created
resource "aws_iam_role" "ec2_role" {
name = "6325257-technova-ec2-role" }
aws_iam_instance_profile.ec2_profile will be created
resource "aws_iam_instance_profile" "ec2_profile" {
name = "6325257-technova-ec2-profile" }
Plan: 16 to add, 0 to change, 0 to destroy.