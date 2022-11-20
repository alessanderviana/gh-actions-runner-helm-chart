FROM ubuntu:20.04 AS builder

WORKDIR builder

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y curl libdigest-sha-perl libicu-dev

RUN curl -o actions-runner-linux-arm64-2.299.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.299.1/actions-runner-linux-arm64-2.299.1.tar.gz
RUN echo "debe1cc9656963000a4fbdbb004f475ace5b84360ace2f7a191c1ccca6a16c00 *actions-runner-linux-arm64-2.299.1.tar.gz" | shasum -a 256 -c
RUN tar xzf ./actions-runner-linux-arm64-2.299.1.tar.gz \
	&& rm -f ./actions-runner-linux-arm64-2.299.1.tar.gz

FROM ubuntu:20.04

ENV RUNNER_ALLOW_RUNASROOT=1
ENV GITHUB_ACTIONS_RUNNER_TLS_NO_VERIFY=1

WORKDIR actions-runner

COPY --from=builder /builder ./

RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y libicu-dev libssl1.1 \
	&& apt-get clean

RUN ./config.sh --url ${PROJECT} --token ${TOKEN}

CMD "./run.sh"