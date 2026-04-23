FROM lyy0709/grok-share-server:dev
WORKDIR /app
COPY config.yaml /app/config.yaml
EXPOSE 8001
CMD ["./main"]
