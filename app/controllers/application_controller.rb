class ApplicationController < ActionController::Base
  def update
    result = {
      redis: update_redis,
      # db: update_db
    }

    render(json: result)
  end

  private

  def update_db
    health = Health.find_or_create_by(name: 'app')
    health.touch
    health.updated_at
  end

  def update_redis
    redis.set('app', Time.now)
    redis.get('app')
  end

  def redis
    @@redis ||= begin
      Rails.logger.info('new Redis connection')
      host = ENV.fetch('REDIS_HOST', 'localhost')
      port = ENV.fetch('REDIS_PORT', 6379).to_i
      db = ENV.fetch('REDIS_DB', 1).to_i
      Redis.new(host: host, port: port, db: db)
    end
  end
end
