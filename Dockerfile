FROM ruby:3.3.0-preview3

RUN apt-get update -qq && apt-get install -y nodejs npm

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs
RUN npm install -g yarn


RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# Install Ruby dependencies
RUN bundle install --jobs $(nproc) && \
  rm -rf /usr/local/bundle/cache/*.gem

COPY . /app

# Install Node.js dependencies
RUN yarn install --network-concurrency $(nproc) --network-timeout 600000 --frozen-lockfile && \
  yarn cache clean

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
