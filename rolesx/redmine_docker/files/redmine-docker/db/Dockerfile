FROM postgres:11.2

ENV TZ Asia/Tokyo
RUN apt-get update \
 && apt-get install -y tzdata \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && echo ${TZ} > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata
