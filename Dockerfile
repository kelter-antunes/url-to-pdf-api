FROM node:latest

# Copy source-sans font 
# https://github.com/adobe-fonts/source-sans/releases/tag/3.046R
COPY ./source-sans-pro-3.006R/ /usr/share/fonts/

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
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
# open port 9005
EXPOSE 9005

# run the server
CMD node ./src/index.js
#CMD [ "npm", "start"]