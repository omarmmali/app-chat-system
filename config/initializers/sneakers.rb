require 'sneakers'

Sneakers.configure(connection: Bunny.new(hostname: "rabbitmq:5672"), durable: true, daemonize: true, prefetch: 1, threads: 1)

