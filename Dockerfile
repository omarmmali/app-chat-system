FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y nodejs

WORKDIR /chat_app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE $APPLICATION_PORT
EXPOSE $DEBUGGING_PORT

## Add the wait script to the image
COPY wait.sh /wait.sh
RUN chmod +x /wait.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
