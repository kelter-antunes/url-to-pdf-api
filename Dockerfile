FROM node:slim

# We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
RUN apt-get update && apt-get install gnupg wget -y && \
  wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  apt-get update && \
  apt-get install google-chrome-stable -y --no-install-recommends && \
  rm -rf /var/lib/apt/lists/* \
    && groupadd -r pptruser && useradd -rm -g pptruser -G audio,video pptruser


USER pptruser

WORKDIR /home/pptruser

# copy package.json into the new directory
COPY package.json /home/pptruser

# install the dependencies
RUN npm install

# copy all other files into the app directory
COPY . /home/pptruser

# Configure environment variables
ENV HOST 0.0.0.0
ENV PORT 9005
ENV NODE_ENV production
ENV ALLOW_HTTP true
ENV DEBUG_MODE false


# We don't need the standalone Chromium
ENV BROWSER_EXECUTABLE_PATH '/usr/bin/google-chrome'


# open port 9005
EXPOSE 9005

# run the server
CMD node ./src/index.js
#CMD [ "npm", "start"]