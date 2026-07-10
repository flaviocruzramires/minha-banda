---
name: teleprompter
description: Regras de UX e implementação da experiência de teleprompter ao vivo. Carregar ao trabalhar na tela de performance/palco.
---

# Teleprompter — Minha Banda

## Prioridade de UX
Esta é a tela usada **durante o show**, sob pressão, com luz ruim e sem tempo de ler manual. Toda decisão de design aqui prioriza legibilidade e controle simples acima de qualquer outra coisa (inclusive acima de consistência visual com o resto do app, se necessário).

## Comportamento obrigatório
- `wakelock` ativo enquanto a tela estiver aberta.
- Fonte mínima configurável, mas o padrão inicial já deve ser grande (pensar em "legível a um braço de distância, celular em um suporte de partitura").
- Scroll automático com velocidade ajustável por gesto simples (dois dedos verticalmente, ou botões grandes +/-), sempre com play/pause acessível com o polegar.
- Navegação entre músicas do setlist sem sair da tela cheia (swipe lateral ou botões próximo/anterior).
- Cache local obrigatório: ao abrir o evento, todo o conteúdo do setlist (letra/cifra) já é baixado e persistido localmente antes do show — teleprompter **não pode depender de rede** no momento do uso.

## Modo cifra
- Alternância simples entre letra pura e letra+cifra sobreposta.
- Cifra nunca deve cortar palavra ou quebrar de forma que perca o sincronismo com a letra.

## Fase 2 — modo sincronizado
- Um dispositivo "líder" controla o scroll, os demais (backing vocals) seguem via Serverpod Stream.
- Não implementar antes do modo solo estar validado com uso real — é fácil superengenhar isso antes de saber se alguém vai usar.

## Erros a evitar
- Nunca mostrar qualquer elemento de navegação padrão do app (bottom bar, app bar) durante o uso — é tela imersiva de verdade.
- Nunca depender de conexão para carregar a próxima música do setlist.
