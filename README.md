# README

## haproxy - redis - app

``` shell
% docker-compose up -d

% docker-compose exec redis1 redis-cli info replication | grep role
role:master
% docker-compose exec redis2 redis-cli info replication | grep role
role:slave

% curl "http://localhost:3000/update"
{"redis":"2020-10-19 15:44:32 +0000"}

# Stop redis1 (master).
% docker-compose stop redis1

# Check that redis2 becomes the new master.
% docker-compose exec redis2 redis-cli info replication | grep role
role:master

% curl "http://localhost:3000/update"
{"redis":"2020-10-19 15:44:50 +0000"}

# Start redis1.
% docker-compose start redis1

# Check that redis1 become the slave.
% docker-compose exec redis1 redis-cli info replication | grep role
role:slave
% docker-compose exec redis2 redis-cli info replication | grep role
role:master

% curl "http://localhost:3000/update"
{"redis":"2020-10-19 15:45:27 +0000"}

# Stop redis2 (master).
% docker-compose stop redis2

# Check that redis1 become the new master.
% docker-compose exec redis1 redis-cli info replication | grep role
role:master

% curl "http://localhost:3000/update"
{"redis":"2020-10-19 15:45:51 +0000"}
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
  server redis1 redis1:6379 check inter 4s on-marked-down shutdown-sessions
  server redis2 redis2:6379 check inter 4s on-marked-down shutdown-sessions
```

- We should check that the role of a Redis server is master.
- We should add "on-marked-down shutdown-sessions". (However, the failover was successful without this option. Why...?)
