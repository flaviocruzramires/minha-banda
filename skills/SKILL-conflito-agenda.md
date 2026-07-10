---
name: conflito-agenda
description: Regras do motor de detecção de conflito de agenda entre bandas/integrantes. Carregar ao trabalhar em qualquer código de agenda, eventos ou disponibilidade.
---

# Motor de Conflito de Agenda

## Princípio
Conflito é **informação, não bloqueio**. O motor nunca impede salvar um evento — ele só garante que ninguém seja pego de surpresa.

## Algoritmo (referência para implementação)
1. Dado um `Evento` candidato (banda_id, data_hora_inicio, data_hora_fim, margem_deslocamento_minutos padrão 60):
2. Buscar `Membership`s ativos da `banda_id`.
3. Para cada `usuario_id` desses membros, buscar:
   - `Evento`s confirmados de **outras** bandas onde ele tem `Membership` ativo, com sobreposição de intervalo (considerando a margem).
   - `BloqueioAgenda` pessoais com sobreposição.
4. Retornar lista de `ConflitoDetectado { usuarioId, nomeUsuario, tipo (evento_outra_banda | bloqueio_pessoal), referenciaId, bandaOuMotivo }`.
5. O endpoint de criação/edição de evento sempre roda esse cálculo e devolve os conflitos junto da resposta — a decisão de UI é do front, mas o cálculo é sempre do servidor (nunca replicar essa lógica no app).

## Regras de visibilidade do conflito
- Um admin de banda vê que "Carlos tem conflito", mas só vê o **nome da banda conflitante** e horário — não o conteúdo do evento conflitante (setlist, notas internas) se ele não tiver vínculo com aquela banda.
- O próprio integrante em conflito vê o conflito completo em sua agenda pessoal.

## UX do conflito
- Selo visual (não modal bloqueante) no formulário de evento e no card do evento na lista.
- Texto direto: "Carlos também tem show marcado nesse horário com outra banda." — nunca esconder de qual banda por segurança, mas ver regra de visibilidade acima antes de decidir o que expor.
- Conflito pode ser marcado como "ciente" pelo admin (não removido, só reconhecido) para não ficar reaparecendo toda vez que ele abre o evento.
