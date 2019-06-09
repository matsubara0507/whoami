FROM matsubara0507/ubuntu-for-haskell
RUN mkdir -p /root/.local/bin && mkdir -p /root/work
ENV PATH /root/.local/bin:$PATH
WORKDIR /root/work
ADD .dump /root/.local/bin
