FROM ruby:3.1.2

ARG USER

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle update --bundler && \
    bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

RUN adduser --disabled-password --gecos "" ${USER} && \
    chown -R ${USER}:${USER} .
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
