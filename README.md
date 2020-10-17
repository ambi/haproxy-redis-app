# README

## haproxy - redis - app

``` shell
% docker-compose up -d

% curl "http://localhost:3000/update"
{"app":"2020-10-17 17:17:46 +0000"}

# redis1 -> redis2
% docker-compose stop redis1
Stopping haproxy-redis-app_redis1_1 ... done
% docker-compose exec redis2 redis-cli slaveof no one
OK

% curl "http://localhost:3000/update"
{"app":"2020-10-17 17:18:56 +0000"}

# redis2 -> redis1
% docker-compose start redis1
Starting redis1 ... done
% docker-compose exec redis2 redis-cli slaveof redis1 6379
OK

% curl "http://localhost:3000/update"
{"app":"2020-10-17 17:19:33 +0000"}
```

There are several important points in HAProxy configuration:

```
backend redis_backend
  option tcp-check
  tcp-check send PING\r\n
  tcp-check expect string +PONG
  tcp-check send INFO\ REPLICATION\r\n
  tcp-check expect string role:master
  tcp-check send QUIT\r\n
  tcp-check expect string +OK
  server redis1 redis1:6379 check inter 1s on-marked-up shutdown-backup-sessions
  server redis2 redis2:6379 check inter 1s backup
```

- We should check that the role of a Redis server is master.
- We should add "on-marked-up shutdown-backup-sessions" in the primary Redis server (when some backup servers exist).
  - See: https://stackoverflow.com/questions/17006135/haproxy-close-connections-to-backup-hosts-when-primary-comes-back
