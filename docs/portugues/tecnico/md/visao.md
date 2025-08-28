# CompuDECSI - Visão do Projeto

**Aplicativo da Semana da Computação**

## 1. Introdução

Este documento descreve a visão geral para o projeto do Aplicativo da Semana da Computação. O objetivo é desenvolver uma solução móvel centralizada para otimizar a experiência dos participantes e a gestão do evento anual de computação do DECSI.

O projeto inicial se concentrará em entregar as funcionalidades mais críticas para o sucesso do evento em um prazo limitado. A visão de longo prazo, no entanto, é transformar o aplicativo em uma ferramenta indispensável que automatiza processos complexos, como a emissão de certificados, integrando-se aos sistemas da universidade.

O aplicativo será desenvolvido inicialmente para a plataforma Android utilizando a tecnologia Flutter.

## 2. Problema

Atualmente, a organização da Semana da Computação enfrenta desafios que impactam a experiência de alunos, palestrantes e organizadores:

### Desorganização da Informação
A programação do evento, os locais das atividades e os avisos importantes são comunicados por diversos canais, dificultando o acesso centralizado e em tempo real.

### Baixo Engajamento
A interação entre participantes e palestrantes é limitada, como no envio de perguntas durante as palestras, que muitas vezes é feito de forma improvisada.

### Gestão Manual de Participação
O processo de check-in em cada atividade é manual, gerando filas e dificultando a coleta de dados de presença para os organizadores.

### Processo Futuro de Certificação
A emissão e entrega de certificados de participação é um processo manual e trabalhoso que ocorre após o evento. A falta de automação consome tempo e está sujeita a erros.

## 3. Público-Alvo e Stakeholders

O aplicativo se destina a todos os envolvidos na Semana da Computação, com foco principal nos seguintes grupos:

### Alunos (Público Principal)
Participantes do evento que buscam uma forma fácil de acessar a programação, montar suas agendas e interagir com as atividades.

### Organizadores do Evento
Equipe responsável pelo planejamento e execução do evento, que necessita de ferramentas para gerenciar a participação e comunicar-se com os presentes.

### Palestrantes
Apresentadores que se beneficiarão de um canal direto para receber perguntas do público.

### Professores e Coordenadores (DECSI)
Interessados no sucesso geral do evento e na modernização das suas ferramentas de gestão.

## 4. Visão do Produto

Para os participantes da Semana da Computação que desejam uma experiência mais organizada e interativa, o **Aplicativo da Semana da Computação** é um assistente de evento móvel que centraliza todas as informações importantes, desde a programação completa até uma agenda personalizada.

Diferente de métodos tradicionais como panfletos e grupos de mensagens, nosso produto oferece:
- Check-in através de um código gerado automaticamente na criação de um evento
- Sistema de perguntas e respostas em tempo real
- Painel de controle para os organizadores

Nossa visão de longo prazo é automatizar o ciclo de participação no evento, culminando na emissão automática de certificados através da integração segura com o banco de dados da universidade, eliminando a necessidade de processos manuais pós-evento.

## 5. Escopo e Funcionalidades

O desenvolvimento será dividido em uma versão inicial (MVP) com funcionalidades essenciais, seguida por versões futuras que expandirão as capacidades do aplicativo.

### 5.1. Escopo Inicial (MVP)

O foco é entregar um aplicativo funcional para a próxima Semana da Computação. As entregas principais incluem:

#### Aplicativo Android Funcional
- **Módulo de Programação do Evento**: Consulta à programação completa com filtros por tipo de atividade
- **Agenda Personalizada**: Permite ao usuário marcar as atividades de seu interesse e receber lembretes
- **Sistema de Check-in**: Check-in rápido em atividades usando código único para registro de presença
- **Q&A em Tempo Real**: Envio e votação de perguntas para os palestrantes durante as apresentações
- **Painel do Organizador**: Dashboard com estatísticas de participação e monitoramento das atividades
- **Informações Gerais**: Área com perfil de palestrantes

#### Explicitamente fora do escopo inicial:
- Versão para iOS
- Sistema de chat entre participantes
- Inscrições ou pagamentos online
- Sistema completo de certificação digital

### 5.2. Visão de Escopo Futuro

Após a validação do MVP, o projeto evoluirá para incluir:

- **Integração com o Banco de Dados da Universidade**: Para validar informações dos alunos e automatizar processos
- **Emissão Automatizada de Certificados**: Geração e entrega de certificados digitais com base no histórico de check-ins do usuário
- **Versão para iOS**: Expansão da plataforma para atender usuários de iPhone
- **Integração com Redes Sociais**: Para compartilhamento e maior engajamento

## 6. Restrições e Premissas

### 6.1. Restrições

- **Prazo**: O aplicativo deve estar concluído e publicado uma semana antes do fim do semestre letivo
- **Orçamento**: O projeto opera com um orçamento simulado e limitado, sem grandes custos externos
- **Recursos Humanos**: A equipe é reduzida, composta por 5 membros

### 6.2. Premissas

- A programação do evento será fornecida com antecedência e não sofrerá grandes alterações
- Haverá conexão Wi-Fi estável e disponível nos locais do evento
- A equipe possui conhecimento básico em Flutter para o desenvolvimento
- Haverá disponibilidade dos palestrantes e organizadores para testes e feedback

