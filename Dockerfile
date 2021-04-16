FROM ruby:3.0.0

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client curl
WORKDIR /cardeons
RUN gem install bundler


COPY Gemfile /cardeons/Gemfile
COPY Gemfile.lock /cardeons/Gemfile.lock
RUN bundle install
COPY . /cardeons

RUN npm install -g yarn
RUN yarn install --check-files

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000


CMD ["rails", "server", "-b", "0.0.0.0"]