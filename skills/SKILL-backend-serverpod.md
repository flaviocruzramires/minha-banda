---
name: backend-serverpod
description: Convenções para criar ou alterar modelos, endpoints e migrations no backend Serverpod do Minha Banda. Carregar junto com minha-banda-contexto sempre que a tarefa envolver lib/src/ do server.
---

# Backend Serverpod — Minha Banda

## Fluxo padrão para uma nova entidade
1. Criar `lib/src/models/<entidade>.yaml` com os campos (ver padrão em `docs/03-MODELO-DADOS.md`).
2. Rodar `serverpod generate`.
3. Rodar `serverpod create-migration` e **revisar o SQL gerado a mão** antes de aplicar — nunca aplicar migration sem ler o que ela faz em produção.
4. Criar o `Endpoint` correspondente em `lib/src/endpoints/`, um por domínio (ex. `EventoEndpoint`, não um endpoint genérico "CRUD").
5. Toda leitura/escrita que envolve `bandaId` ou `localId` começa validando o vínculo do usuário autenticado (`session.authenticated`) antes de tocar no banco.
6. Escrever teste de integração do endpoint (feliz + não autorizado + não encontrado) antes de considerar a tarefa concluída.

## Padrões de endpoint
```dart
class EventoEndpoint extends Endpoint {
  Future<Evento> criar(Session session, EventoInput input) async {
    final userId = (await session.authenticated)!.userId;
    await _validarAdminDaBanda(session, userId, input.bandaId);
    final conflitos = await ConflitoService.detectar(session, input);
    final evento = await Evento.db.insertRow(session, Evento(...));
    if (conflitos.isNotEmpty) {
      // devolvido junto da resposta, não bloqueia a criação
    }
    return evento;
  }
}
```

## Regras específicas do domínio
- **Nunca** um endpoint de repertório, agenda ou setlist deve ser acessível por um `ResponsavelLocal` que não seja também `Membership` daquela banda — são visões estritamente separadas (ver tabela de papéis em `docs/02-FEATURES.md`).
- Endpoints de leitura de agenda pessoal (`AgendaEndpoint.minhaAgenda`) sempre cruzam **todos** os `Membership`s ativos do usuário, nunca apenas uma banda — é o requisito 6 do projeto.
- Uploads (cifra em PDF, foto de banda, logo de local) vão para o storage configurado (Cloudflare R2), nunca como blob direto no Postgres, salvo cifras muito pequenas em texto puro.

## Testes
- Um arquivo de teste por endpoint em `test/integration/`.
- Sempre testar o caso de autorização negada (usuário sem vínculo tentando acessar dado de outra banda) — é o bug mais caro de deixar passar nesse tipo de app.

## Performance
- Toda query de listagem paginada (mesmo que a lista pareça pequena hoje — repertório de banda cover fácil passa de 150 músicas).
- Índices conforme `docs/03-MODELO-DADOS.md` seção 4 — não adicionar índice "por via das dúvidas", seguir o que está documentado e medir antes de adicionar mais.
