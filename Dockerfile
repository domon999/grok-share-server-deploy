FROM lyy0709/grok-share-server:dev
WORKDIR /app
COPY config.yaml /app/config.yaml
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
EXPOSE 8001
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["./main"]
