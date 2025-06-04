# Contexto do Projeto: Aplicativo da Semana da Computação

O objetivo é desenvolver um aplicativo móvel em Flutter para melhorar a experiência dos participantes da Semana da Computação do DECSI, com funcionalidades como:

- Check-in nas atividades
- Consulta à programação completa
- Agenda personalizada
- Envio de perguntas aos palestrantes

## Passo 1: Planejamento do Gerenciamento do Escopo (Processo 5.1 PMBOK)

### Como garantir que o escopo seja bem gerenciado?
- Realizar reuniões regulares com os stakeholders para revisão do escopo
- Utilizar técnicas de coleta de requisitos (entrevistas, questionários) para entender necessidades reais
- Definir claramente as entregas e exclusões no escopo
- Criar uma Linha de Base do Escopo (Declaração do Escopo + EAP)
- Estabelecer um processo formal de controle de mudanças no escopo

### Principais desafios:
- Mudança constante de requisitos durante o desenvolvimento ("escopo inchado")
- Limitações de tempo e recursos humanos
- Dificuldade em obter feedback rápido dos stakeholders

### Como evitar o "escopo inchado"?
- Validar constantemente os requisitos com os stakeholders
- Não aceitar novas funcionalidades fora da linha de base sem análise de impacto
- Usar uma matriz de rastreabilidade dos requisitos
- Manter comunicação clara e frequente com todos os envolvidos

### Elementos do Plano de Gerenciamento do Escopo:

| Elemento | Abordagem |
|----------|-----------|
| Determinação de Requisitos | Entrevistas, workshops e questionários com alunos, organizadores e palestrantes |
| Definição do Escopo | Declaração detalhada com entregas, exclusões, premissas e restrições |
| Criação da EAP | Decomposição hierárquica das entregas em pacotes de trabalho |
| Validação das Entregas | Testes com usuários finais e revisões com stakeholders |
| Controle de Mudanças | Comitê de mudança com análise de impacto técnico e temporal |

## Passo 2: Coleta de Requisitos (Processo 5.2 PMBOK)

### Stakeholders principais:
- Alunos
- Palestrantes
- Organizadores do evento
- Professores

### Requisitos detalhados por categoria:

#### Funcionalidades Gerais
- Interface amigável e responsiva
- Login único (ou sem login)
- Suporte offline parcial
- Notificações push

#### Programação Completa
- Visualização por dia e horário
- Filtro por tipo de atividade (palestra, oficina, etc.)
- Localização dos eventos (mapa ou sala)

#### Check-in
- QR Code para check-in presencial
- Registro automático de presença
- Histórico de atividades participadas

#### Agenda Personalizada
- Marcar interesses
- Sincronização com agenda pessoal (ex: Google Calendar)
- Lembretes antes do início da atividade

#### Q&A em Tempo Real
- Enviar perguntas durante palestras
- Sistema de votação para destacar perguntas mais relevantes
- Exibição pública das perguntas (via projeção ou tela secundária)

#### Informações Adicionais
- Perfil do usuário (nome, curso, foto)
- Informações sobre palestrantes (currículo, foto, tema)
- Feedback pós-evento (avaliação das palestras)
- Mapa do campus com localização das salas
- Notícias e avisos do evento

#### Para Organizadores
- Dashboard com estatísticas de participação
- Relatórios de check-in
- Cadastro de palestras e palestrantes
- Monitoramento de perguntas

## Passo 3: Definição Detalhada do Escopo (Processo 5.3 PMBOK)

### Declaração do Escopo do Projeto

#### Descrição do Escopo do Projeto e do Produto
O projeto tem como objetivo desenvolver um aplicativo móvel em Flutter que centralize informações e interações da Semana da Computação do DECSI. O app permitirá ao usuário visualizar a programação, montar uma agenda personalizada, realizar check-in nas atividades e enviar perguntas aos palestrantes durante as palestras.

#### Entregas Principais
- Aplicativo funcional para Android
- Documentação técnica do sistema
- Manual do usuário final
- Manual do organizador (para uso do painel administrativo)
- Relatório final de funcionamento e uso do app no evento

#### Exclusões do Escopo
- Versão iOS do aplicativo
- Integração com redes sociais
- Chat entre participantes
- Sistema de pagamento ou inscrição online
- Sistema completo de certificação digital

#### Premissas
- O cronograma do evento será fornecido e não sofrerá grandes alterações
- A conexão Wi-Fi estará disponível nos locais do evento
- Os palestrantes estarão disponíveis para testes do sistema de perguntas
- A equipe possui conhecimento básico em Flutter e metodologias ágeis

#### Restrições
- Prazo: App deve ser concluído até uma semana antes do evento
- Orçamento: Simulado com recursos limitados (sem custos externos significativos)
- Recursos humanos: Equipe reduzida (~4-6 pessoas)

## Passo 4: Estrutura Analítica do Projeto (EAP) Inicial (Processo 5.4 PMBOK)

### Estrutura Hierárquica do Trabalho

1. Gerenciamento do Projeto
   1.1 Planejamento inicial
   1.2 Coordenação da equipe
   1.3 Controle de mudanças
   1.4 Relatórios de progresso

2. Análise e Coleta de Requisitos
   2.1 Entrevistas com stakeholders
   2.2 Workshop de brainstorming
   2.3 Elaboração da documentação de requisitos

3. Design do Aplicativo
   3.1 Prototipagem da interface
   3.2 Modelagem de banco de dados
   3.3 Arquitetura do sistema

4. Desenvolvimento do Aplicativo
   4.1 Tela de programação
   4.2 Sistema de check-in
   4.3 Montagem de agenda personalizada
   4.4 Sistema de perguntas e respostas
   4.5 Perfil do usuário
   4.6 Painel do organizador

5. Testes e Validação
   5.1 Teste unitário
   5.2 Teste de usabilidade
   5.3 Validação com stakeholders
   5.4 Correção de bugs

6. Implantação
   6.1 Publicação na Play Store
   6.2 Treinamento dos organizadores
   6.3 Divulgação do aplicativo

7. Encerramento
   7.1 Avaliação do projeto
   7.2 Levantamento de lições aprendidas
   7.3 Documentação final

## Conclusão

Este exercício possibilitou simular os processos iniciais do gerenciamento do escopo segundo o PMBOK:
- Definiu-se como planejar e controlar o escopo
- Coletaram-se requisitos detalhados com base nas necessidades dos stakeholders
- Formalizou-se a Declaração do Escopo do Projeto
- E estruturou-se a EAP, que servirá como base para planejar, executar e controlar o trabalho