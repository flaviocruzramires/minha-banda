/// URL base da API. Troque por String.fromEnvironment ou flavor para produção.
///
/// Dev local:  http://10.0.2.2:8080  (Android emulador → localhost do host)
///             http://localhost:8080  (web / iOS simulator)
/// Produção:   https://api.minha-banda.com.br
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080',
);
