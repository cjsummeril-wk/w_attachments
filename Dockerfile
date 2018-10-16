FROM drydock-prod.workiva.net/workiva/smithy-runner-generator:355624 as build

# Build Environment Vars
ARG BUILD_ID
ARG BUILD_NUMBER
ARG BUILD_URL
ARG GIT_COMMIT
ARG GIT_BRANCH
ARG GIT_TAG
ARG GIT_COMMIT_RANGE
ARG GIT_HEAD_URL
ARG GIT_MERGE_HEAD
ARG GIT_MERGE_BRANCH
WORKDIR /build/
ADD . /build/
ENV CODECOV_TOKEN='f2da64f7-7b5c-47f3-8aa0-ed58f961f772'
RUN echo "Starting the script sections" && \
		pub get && \
		pub run dart_dev format --check && \
		pub run dart_dev analyze && \
		pub run abide && \
		pub run dependency_validator -i abide,collection,coverage,dart_style,dartdoc,http,sass,semver_audit && \
		pub run semver_audit report --repo Workiva/w_attachments_client && \
		xvfb-run -s '-screen 0 1024x768x24' pub run dart_dev test && \
		xvfb-run -s '-screen 0 1024x768x24' pub run dart_dev coverage --no-html && \
		tar czvf w_attachments_client.pub.tgz LICENSE README.md pubspec.yaml lib/ && \
		./tool/codecov.sh && \
		echo "Script sections completed"
ARG BUILD_ARTIFACTS_BUILD=/build/coverage/coverage.lcov
ARG BUILD_ARTIFACTS_PUB=/build/w_attachments_client.pub.tgz
FROM scratch
