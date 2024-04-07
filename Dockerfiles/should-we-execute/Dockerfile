FROM alpine:latest

RUN apk --no-cache add jq git diffutils

COPY output-not-needed.md /output-not-needed.md
COPY output-see-previous-comment.md /output-see-previous-comment.md
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
