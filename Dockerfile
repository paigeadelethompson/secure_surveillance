FROM arm64v8/debian:stable

ENV DEBIAN_FRONTEND noninteractive

RUN apt -y autoremove

RUN rm -rf /var/lib/apt/lists/*

RUN apt -y update

RUN apt -y install systemd

RUN systemctl enable systemd-networkd

# RUN apt -y install cockpit/stable cockpit-389-ds/stable cockpit-bridge/stable cockpit-doc/stable cockpit-machines/stable cockpit-networkmanager/stable cockpit-packagekit/stable cockpit-podman/stable cockpit-sosreport/stable cockpit-storaged/stable cockpit-system/stable cockpit-tests/stable cockpit-ws/stable

RUN apt -y install docker.io ffmpeg svt-av1 libaom-dev kmod

RUN systemctl enable docker

# RUN systemctl enable cockpit.socket

RUN apt -y install avahi-daemon/stable

RUN apt -y install locales

RUN apt -y install wpasupplicant

RUN apt -y install hostapd iw tcpdump socat

RUN apt -y install aptitude ca-certificates fake-hwclock gnupg man-db manpages net-tools ntp usb-modeswitch ssh sudo wget xz-utils

RUN mkdir /home/pi

RUN groupadd spi

RUN groupadd i2c

RUN groupadd gpio

RUN groupadd -g 5000 pi

RUN useradd -u 4000 -g pi -s /bin/bash -d /home/pi -G sudo,video,adm,dialout,cdrom,audio,plugdev,games,users,input,netdev,spi,i2c,gpio pi

RUN chown pi:pi /home/pi

ADD profile /home/pi/.profile

RUN apt -y install openssh-server

RUN systemctl enable ssh

ENV WANT_32BIT=1 

ENV WANT_64BIT=1 

ENV WANT_PI4=1

RUN cd /usr/local/bin && wget https://raw.githubusercontent.com/raspberrypi/rpi-update/master/rpi-update

ADD sources.list /etc/apt

RUN apt update

RUN mkdir -p /lib/modules

RUN chmod +x /usr/local/bin/rpi-update

RUN apt -y install curl binutils cmake git build-essential

RUN echo y | /usr/local/bin/rpi-update

RUN echo 'dwc_otg.lpm_enable=0 console=tty1 root=LABEL=ROOT rootfstype=btrfs elevator=deadline fsck.repair=yes rootwait net.ifnames=0' > /boot/cmdline.txt

RUN echo $'ngpu_mem=16\narm_64bit=1\ndtoverlay=vc4-fkms-v3d' > /boot/config.txt

RUN cd /tmp

RUN git clone https://github.com/raspberrypi/userland /usr/src/userland

RUN cd /usr/src/userland ; ./buildme --aarch64

RUN dpkg --add-architecture armhf

RUN dpkg --add-architecture armel

RUN apt -y update

RUN apt -y install libc6:armhf libc6:armel

RUN apt -y install motion

RUN usermod -G pi motion

RUN echo '/opt/vc/lib' > /etc/ld.so.conf.d/00-vmcs.conf

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/vc/bin"' > /etc/sudoers.d/opt-path

ADD 99-com.rules /etc/udev/rules.d/99-com.rules

RUN systemctl enable motion

RUN apt -y autoremove

RUN rm -rf /var/lib/apt/lists/*

