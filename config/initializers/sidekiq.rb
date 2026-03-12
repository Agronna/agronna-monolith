# frozen_string_literal: true

# Configuração do Sidekiq para uso futuro (jobs em background).
#
# Uso:
#   1. Redis rodando (ex.: redis-server ou Docker).
#   2. Opcional: REDIS_URL (padrão redis://localhost:6379/0), REDIS_NAMESPACE (padrão agronna:sidekiq).
#   3. Rodar o processo: bundle exec sidekiq -C config/sidekiq.yml
#   4. Para usar Active Job com Sidekiq: config.active_job.queue_adapter = :sidekiq
#
# redis-namespace: prefixo das chaves no Redis (evita conflito com outros apps no mesmo Redis).

require "sidekiq"

redis_url      = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
redis_namespace = ENV.fetch("REDIS_NAMESPACE", "agronna:sidekiq")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: redis_namespace }

  # sidekiq-cron: jobs agendados (config/sidekiq_cron.yml)
  require "sidekiq/cron"
  schedule_file = Rails.root.join("config", "sidekiq_cron.yml")
  if schedule_file.exist?
    cron_hash = YAML.load_file(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(cron_hash.is_a?(Hash) ? cron_hash : {})
  end

  # sidekiq-history: carrega automaticamente via gem (histórico de jobs na Web UI).
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: redis_namespace }
end
