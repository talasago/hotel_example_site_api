FROM ruby:3.1.2

ENV TZ Asia/Tokyo

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /hotel_example_site_api
COPY Gemfile /hotel_example_site_api/Gemfile
COPY Gemfile.lock /hotel_example_site_api/Gemfile.lock
RUN bundle update --bundler && \
    bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
