FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine318

# set version label
ARG BUILD_DATE
ARG VERSION
ARG LIBREOFFICE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=LibreOffice

RUN \
  echo "**** install packages ****" && \
  if [ -z ${LIBREOFFICE_VERSION+x} ]; then \
    LIBREOFFICE_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:libreoffice$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
  echo @edge http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
  apk add --no-cache --allow-untrusted \
    libreoffice==${LIBREOFFICE_VERSION} \
    libreoffice-lang-zh_cn ttf-dejavu fontconfig font-adobe-100dpi wqy-zenhei@edge \
    openjdk8-jre \
    st \
    thunar \
    tint2 && \
  rm -rf /var/cache/apk/* && mkfontscale && mkfontdir && fc-cache && \
  echo "**** openbox tweaks ****" && \
  sed -i \
    's/NLMC/NLIMC/g' \
    /etc/xdg/openbox/rc.xml && \
  sed -i 's|</applications>|  <application title="LibreOffice" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
  sed -i \
    '/Icon=/c Icon=xterm-color_48x48' \
    /usr/share/applications/st.desktop && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
