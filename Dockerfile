From ubuntu:21.04 

# setup the environment
ARG COMMIT_COMMENT
ENV COMMIT_COMMENT $COMMIT_COMMENT
ARG COMMIT_COMMENT_ARCH_FILES
ENV COMMIT_COMMENT_ARCH_FILES $COMMIT_COMMENT_ARCH_FILES
ARG OPENSSL_TAG
ENV OPENSSL_TAG $OPENSSL_TAG
ARG JTHREADS
ENV JTHREADS $JTHREADS
ARG DEBIAN_FRONTEND=noninteractive
ARG REPO
ENV REPO=$REPO
ARG USERNAME
ENV USER=$USERNAME
ARG EMAIL 
ENV EMAIL=$EMAIL

# add the requiremd additional tools/packages
RUN apt-get update -y
RUN apt-get install -y nasm build-essential git python3 vim
RUN echo "y" |cpan install Text:Template

# set info for the commits
RUN git config --global user.email "midawson@redhat.com"
RUN git config --global user.name "Michael Dawson"

# Update the openssl source
RUN git clone https://github.com/${REPO} node
WORKDIR "/node"
RUN git reset --hard 9d7895c567e8f38abfff35da1b6d6d6a0a06f9aa
RUN git remote add upstream https://github.com/nodejs/node.git
RUN git checkout -b openssl-update
RUN git fetch upstream
RUN git rebase upstream/master
WORKDIR "/"
RUN git clone https://github.com/quictls/openssl
WORKDIR "openssl"
RUN git checkout ${OPENSSL_TAG}+quic
WORKDIR "/node/deps/openssl"
RUN rm -rf openssl
RUN cp -R ../../../openssl openssl
RUN rm -rf openssl/.git* openssl/.travis*
RUN git add --all openssl
RUN git commit -m "$COMMIT_COMMENT"

# update the generated openssl files
WORKDIR "/node"
RUN make -C deps/openssl/config
RUN git add deps/openssl/config
RUN git add deps/openssl/openssl
RUN git commit -m "$COMMIT_COMMENT_ARCH_FILES"

# run the node.js test suite
RUN ./configure
RUN make -j${JTHREADS} test 2>&1 | tee testresults
