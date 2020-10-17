class ApplicationController < ActionController::Base
  def update
    redis.set('app', Time.now)
    result = { app: redis.get('app') }
    render(json: result)
  end

  private

  def redis
    @@redis ||= begin
      host = ENV.fetch('REDIS_HOST', 'localhost')
      port = ENV.fetch('REDIS_PORT', 6379).to_i
      db = ENV.fetch('REDIS_DB', 1).to_i
      Redis.new(host: host, port: port, db: db)
    end
  end
end
