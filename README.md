# APPLICATION CHAT APP

Rails application to handle application entities with chats and messages,   
handling concurrency and race conditions using optimistic locking,  
handling the possibility of multiple deployments using a message queue
(RabbitMQ) for all write operations, and sneakers for workers to perform
the queued jobs.

### Ruby version 2.6.3

## System dependencies
### Docker
* install [docker](https://docs.docker.com/install/)
### Docker-compose
* install [docker-compose](https://docs.docker.com/compose/install/)
## How to run
* Get source code   
```git clone https://github.com/omarmmali/app-chat-system.git && cd app-chat-system```
* Run   
```docker-compose up```
## How to run the test suite
* Go into the docker application container   
```docker exec -it example-container-name_1 /bin/bash```
* Run   
```rspec```