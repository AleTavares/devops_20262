# Entrega — Aula 06: Terraform Modules

**Aluno:** Felipe Damasceno
**RA:** 6325128  
**Data:** 18/09/2026

## Repositório

- URL: https://github.com/FelipeDesda/unifaat-devops-portfolio

## Evidências

- [x] Módulo VPC com for_each para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável
- [x] Composição entre módulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência do terraform plan

 + create
  + resource "aws_instance" "this" {
  + resource "aws_security_group" "this" {
  + resource "aws_db_instance" "this" {
  + resource "aws_db_subnet_group" "this" {
  + resource "aws_security_group" "this" {
  + resource "aws_internet_gateway" "this" {
  + resource "aws_route_table" "public" {
  + resource "aws_route_table_association" "public" {
  + resource "aws_route_table_association" "public" {
  + resource "aws_subnet" "this" {
  + resource "aws_subnet" "this" {
  + resource "aws_subnet" "this" {
  + resource "aws_subnet" "this" {
  + resource "aws_vpc" "this" {
Plan: 14 to add, 0 to change, 0 to destroy.
Changes to Outputs:
  + api_instance_id   = (known after apply)
  + api_public_ip     = (known after apply)
  + database_endpoint = (known after apply)
  + vpc_id            = (known after apply)
