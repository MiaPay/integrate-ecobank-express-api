# frozen_string_literal: true

redis_url = Rails.application.credentials.dig(Rails.env.to_sym, :redis, :redis_url)
redis_namespace = "#{Rails.application.class.module_parent.name.underscore}_#{Rails.env}"

Redis::Objects.redis = Redis::Namespace.new(redis_namespace, redis: Redis.new(url: redis_url))
