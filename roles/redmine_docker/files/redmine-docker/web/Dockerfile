FROM nginx:1.15.11

ENV TZ Asia/Tokyo
RUN apt-get update \
 && apt-get install -y tzdata \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && echo ${TZ} > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

COPY default.conf /etc/nginx/conf.d/default.conf
