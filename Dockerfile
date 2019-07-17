FROM ruby:2.6.3

RUN apt-get update -qq && apt-get install -y nodejs

WORKDIR /chat_app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 3000

## Add the wait script to the image
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.5.1/wait /wait
RUN chmod +x /wait