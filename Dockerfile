FROM alpine:3.20

ARG MATTERMOST_VERSION
ARG MATTERMOST_TARBALL_URL

ENV MM_HOME=/opt/mattermost

RUN test -n "$MATTERMOST_VERSION"
RUN test -n "$MATTERMOST_TARBALL_URL"

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    tar \
    tzdata && \
    addgroup -g 2000 mattermost && \
    adduser -D -u 2000 -G mattermost mattermost && \
    mkdir -p ${MM_HOME} /mattermost/config /mattermost/data /mattermost/logs /mattermost/plugins /mattermost/client/plugins /mattermost/bleve-indexes && \
    curl -fsSL "$MATTERMOST_TARBALL_URL" -o /tmp/mattermost.tgz && \
    tar -xzf /tmp/mattermost.tgz -C /opt && \
    rm -f /tmp/mattermost.tgz && \
    chown -R mattermost:mattermost ${MM_HOME} /mattermost

WORKDIR ${MM_HOME}

ENV PATH="${MM_HOME}/bin:${PATH}"
ENV MM_CONFIG=/mattermost/config/config.json

VOLUME ["/mattermost/config", "/mattermost/data", "/mattermost/logs", "/mattermost/plugins", "/mattermost/client/plugins", "/mattermost/bleve-indexes"]

EXPOSE 8065 8067

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
  CMD curl -fsS http://127.0.0.1:8065/api/v4/system/ping || exit 1

USER mattermost

ENTRYPOINT ["/opt/mattermost/bin/mattermost"]
