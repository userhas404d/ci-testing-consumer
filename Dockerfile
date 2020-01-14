FROM maximumoverdrive/ci-testing:latest

WORKDIR /ci-harness
ENTRYPOINT ["make"]