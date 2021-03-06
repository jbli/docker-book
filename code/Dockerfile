FROM    ubuntu:14.04
MAINTAINER Meaglith Ma <genedna@gmail.com> (@genedna)

RUN echo "deb http://mirrors.aliyun.com/ubuntu trusty main universe" > /etc/apt/sources.list && echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted" >> /etc/apt/sources.list && echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted" >> /etc/apt/sources.list && echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted" >> /etc/apt/sources.list && echo "deb http://mirrors.aliyun.com/ubuntu/ trusty universe" >> /etc/apt/sources.list && echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty universe" >> /etc/apt/sources.list && echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-updates universe" >> /etc/apt/sources.list && echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates universe" >> /etc/apt/sources.list && echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted" >> /etc/apt/sources.list && echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted" >> /etc/apt/sources.list && echo "deb http://mirrors.aliyun.com/ubuntu/ trusty-security universe" >> /etc/apt/sources.list && echo "deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security universe" >> /etc/apt/sources.list

RUN     apt-get update && apt-get install -y \
        aufs-tools \
        automake \
        btrfs-tools \
        build-essential \
        curl \
        dpkg-sig \
        git \
        iptables \
        libapparmor-dev \
        libcap-dev \
        libsqlite3-dev \
        lxc=1.0* \
        mercurial \
        parallel \
        reprepro \
        ruby1.9.1 \
        ruby1.9.1-dev \
        s3cmd=1.1.0* \
        unzip \
        --no-install-recommends

RUN     git clone --no-checkout https://coding.net/genedna/lvm2.git /usr/local/lvm2 && cd /usr/local/lvm2 && git checkout -q v2_02_103

RUN     cd /usr/local/lvm2 && ./configure --enable-static_link && make device-mapper && make install_device-mapper

RUN     curl -sSL http://docker-cn.qiniudn.com/go1.3.1.src.tar.gz | tar -v -C /usr/local -xz
ENV     PATH    /usr/local/go/bin:$PATH
ENV     GOPATH  /go:/go/src/github.com/docker/docker/vendor
ENV PATH /go/bin:$PATH
RUN     cd /usr/local/go/src && ./make.bash --no-clean 2>&1

ENV     DOCKER_CROSSPLATFORMS   \
        linux/386 linux/arm \
        darwin/amd64 darwin/386 \
        freebsd/amd64 freebsd/386 freebsd/arm
ENV     GOARM   5
RUN     cd /usr/local/go/src && bash -xc 'for platform in $DOCKER_CROSSPLATFORMS; do GOOS=${platform%/*} GOARCH=${platform##*/} ./make.bash --no-clean 2>&1; done'

RUN     mkdir -p /go/src/github.com/gpmgo \
        && cd /go/src/github.com/gpmgo \
        && curl -o gopm.zip http://gopm.io/api/v1/download?pkgname=github.com/gpmgo/gopm\&revision=dev --location \
        && unzip gopm.zip \
        && mv $(ls | grep "gopm-") gopm \
        && rm gopm.zip \
        && cd gopm \
        && go install

#RUN     gopm bin -v code.google.com/p/go.tools/cmd/cover
RUN     gopm bin -v golang.org/x/tools/cmd/cover

#RUN gem sources --remove https://rubygems.org/ \
#  && gem sources -a https://ruby.taobao.org/ \
#  && gem install --no-rdoc --no-ri fpm --version 1.0.2
RUN gem install --no-rdoc --no-ri fpm --version 1.0.2


# Install man page generator
RUN     gopm bin -v -d /go/bin github.com/cpuguy83/go-md2man@tag:v1

# Get the "busybox" image source so we can build locally instead of pulling
#RUN    git clone -b buildroot-2014.02 https://github.com/jpetazzo/docker-busybox.git /docker-busybox
RUN     git clone -b buildroot-2014.02 https://github.com/jpetazzo/docker-busybox.git /docker-busybox

# Get the "cirros" image source so we can import it instead of fetching it during tests
RUN     curl -sSL -o /cirros.tar.gz https://github.com/ewindisch/docker-cirros/raw/1cded459668e8b9dbf4ef976c94c05add9bbd8e9/cirros-0.3.0-x86_64-lxc.tar.gz

# Setup s3cmd config
RUN     /bin/echo -e '[default]\naccess_key=$AWS_ACCESS_KEY\nsecret_key=$AWS_SECRET_KEY' > $HOME/.s3cfg

# Set user.email so crosbymichael's in-container merge commits go smoothly
RUN     git config --global user.email 'docker-dummy@example.com'

# Add an unprivileged user to be used for tests which need it
RUN groupadd -r docker
RUN useradd --create-home --gid docker unprivilegeduser

VOLUME  /var/lib/docker
WORKDIR /go/src/github.com/docker/docker
ENV     DOCKER_BUILDTAGS        apparmor selinux

# Wrap all commands in the "docker-in-docker" script to allow nested containers
ENTRYPOINT      ["hack/dind"]

# Upload docker source
COPY    .       /go/src/github.com/docker/docker

