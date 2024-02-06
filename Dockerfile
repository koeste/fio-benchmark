FROM alpine:3.19
WORKDIR /app
RUN apk add --no-cache bash jq bc fio figlet
COPY app/benchmark.sh .
COPY app/fio-settings.fio .
RUN chmod +x ./benchmark.sh
ENTRYPOINT ["./benchmark.sh"]