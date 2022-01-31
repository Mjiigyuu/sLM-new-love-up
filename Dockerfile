FROM breakdowns/mega-sdk-python:latest
# FROM anasty17/mltb-oracle:latest

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app
RUN apt-get -qq update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -qq install -y tzdata aria2 git python3 python3-pip \
    locales python3-lxml \
    curl pv jq ffmpeg streamlink rclone \
    wget mediainfo git zip unzip \
    p7zip-full p7zip-rar \
    libcrypto++-dev libssl-dev \
    libc-ares-dev libcurl4-openssl-dev \
    libsqlite3-dev libsodium-dev && \
    curl -L https://github.com/jaskaranSM/megasdkrest/releases/download/v0.1/megasdkrest -o /usr/local/bin/megasdkrest && \
    chmod +x /usr/local/bin/megasdkrest

#gdrive setupz
RUN wget -P /tmp https://dl.google.com/go/go1.17.1.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf /tmp/go1.17.1.linux-amd64.tar.gz
RUN rm /tmp/go1.17.1.linux-amd64.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN go get github.com/Jitendra7007/gdrive
RUN aria2c "https://jitu-mirror.jkdrive.workers.dev/0:///google.zip" && unzip google.zip
# add mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list' && apt update && apt install -y mkvtoolnix

# add mega cmd
RUN apt-get update && apt-get install libpcrecpp0v5 libcrypto++6 -y && \
curl https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megacmd-Debian_9.0_amd64.deb --output megacmd.deb && \
echo path-include /usr/share/doc/megacmd/* > /etc/dpkg/dpkg.cfg.d/docker && \
apt install ./megacmd.deb

#Link Parsers By yusuf
RUN echo "KGdkcml2ZSB1cGxvYWQgIiQxIikgMj4gL2Rldi9udWxsIHwgZ3JlcCAtb1AgJyg/PD1VcGxvYWRlZC4pW2EtekEtWl8wLTktXSsnID4gZztnZHJpdmUgc2hhcmUgJChjYXQgZykgPi9kZXYvbnVsbCAyPiYxO2VjaG8gImh0dHBzOi8vZHJpdmUuZ29vZ2xlLmNvbS9maWxlL2QvJChjYXQgZykiCg==" | base64 -d > /usr/local/bin/gup && \
chmod +x /usr/local/bin/gup && \
wget -O /usr/bin/gdtot "https://tgstreamerbot.akuotoko.repl.co/1673806755639796/gdtot" && \
chmod +x /usr/bin/gdtot && \
wget -O /usr/bin/gp "https://tgstreamerbot.akuotoko.repl.co/1660131579769332/gp" && \
chmod +x /usr/bin/gp
RUN echo "IyEvdXNyL2Jpbi9lbnYgYmFzaAppZiBbWyAiJCoiIF1dCnRoZW4KcHl0aG9uMyAtYyAiZXhlYyhc\nImltcG9ydCBzeXMsc3VicHJvY2VzcyxyZVxuZj1yZS5maW5kYWxsKHInaHR0cHM/Oi4qZ2R0b3Qu\nKlxTKycsJ1xcXFxuJy5qb2luKHN5cy5hcmd2WzE6XSksZmxhZ3M9cmUuTSlcbmZvciBpIGluIGY6\nc3VicHJvY2Vzcy5ydW4oWydnZHRvdCcsICclcycgJWldKVwiKSIgIiQqIgplbHNlCmVjaG8gImJh\nZCByZXEiCmZpCg==" | base64 -d > /usr/bin/gd;chmod +x /usr/bin/gd
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY extract /usr/local/bin
COPY pextract /usr/local/bin
RUN chmod +x /usr/local/bin/extract && chmod +x /usr/local/bin/pextract
COPY . .
COPY .netrc /root/.netrc
RUN chmod 600 /usr/src/app/.netrc
RUN chmod +x aria.sh

CMD ["bash","start.sh"]
