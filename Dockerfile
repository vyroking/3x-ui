FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    gettext \
    iproute2 \
    iptables \
    nginx \
    openssl \
    socat \
    sqlite \
    tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime

# Pinned 3x-ui release
RUN curl -fL https://github.com/mhsanaei/3x-ui/releases/download/v3.7.0/x-ui-linux-amd64.tar.gz \
    -o /tmp/x-ui.tar.gz \
    && tar -xzf /tmp/x-ui.tar.gz -C /usr/local/ \
    && rm -f /tmp/x-ui.tar.gz \
    && chmod +x /usr/local/x-ui/x-ui

RUN mkdir -p /etc/x-ui /var/log/x-ui /run/nginx

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
