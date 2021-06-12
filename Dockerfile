FROM ghcr.io/matsubara0507/ubuntu-for-haskell
ARG local_bin_path
RUN mkdir -p /root/.local/bin && mkdir -p /work
ENV PATH /root/.local/bin:$PATH
WORKDIR /work
COPY ${local_bin_path} /root/.local/bin
