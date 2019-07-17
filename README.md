# APPLICATION CHAT APP

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
```docker exec -it rails-chat-app_application_1 /bin/bash```
* Run   
```rspec```