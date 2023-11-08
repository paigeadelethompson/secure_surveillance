FROM arm64v8/debian:stable

ENV DEBIAN_FRONTEND noninteractive

ENV WANT_32BIT=1

ENV WANT_64BIT=1

ENV WANT_PI4=1

ENV WANT_PI5=1

RUN apt -y autoremove

RUN rm -rf /var/lib/apt/lists/*

RUN rm /etc/apt/sources.list.d/debian.sources

ADD sources.list /etc/apt/sources.list.d/sources.list

ADD no_reccomends.conf /etc/apt/apt.conf.d/99no_reccomends

RUN dpkg --add-architecture armhf

RUN dpkg --add-architecture armel

RUN apt -y update

ADD packages.txt /tmp/packages.txt

RUN apt -y install $(cat /tmp/packages.txt | tr '\n' ' ')

ADD startup.txt /tmp/startup.txt

RUN cat /tmp/startup.txt | xargs -i systemctl enable {}

ADD sshd_config /etc/ssh/sshd_config.d/sshd_config

ADD sudoers /etc/sudoers.d

ADD fstab /etc/fstab

ADD issue.net /etc/issue.net

ADD 10-eth.network /etc/systemd/network

ADD 10-usb.network /etc/systemd/network

ADD 10-eth.network /etc/systemd/network

RUN mkdir /home/pi

RUN mkdir /home/pi/ssh

RUN groupadd spi

RUN groupadd i2c

RUN groupadd gpio

RUN groupadd -g 5000 pi

RUN useradd -u 4000 -g pi -s /bin/bash -d /home/pi -G sudo,video,adm,dialout,cdrom,audio,plugdev,games,users,input,netdev,spi,i2c,gpio pi

RUN chown pi:pi /home/pi

ADD profile /home/pi/.profile

RUN cd /usr/local/bin && wget https://raw.githubusercontent.com/raspberrypi/rpi-update/master/rpi-update

RUN mkdir -p /lib/modules

RUN chmod +x /usr/local/bin/rpi-update

RUN echo y | /usr/local/bin/rpi-update

ADD cmdline.txt /boot/cmdline.txt

ADD config.txt /boot/config.txt

RUN cd /tmp

RUN git clone https://github.com/raspberrypi/userland /usr/src/userland

RUN cd /usr/src/userland ; ./buildme --aarch64

RUN usermod -U pi

RUN passwd -d pi

RUN echo '/opt/vc/lib' > /etc/ld.so.conf.d/00-vmcs.conf

ADD 99-com.rules /etc/udev/rules.d/99-com.rules

RUN apt -y autoremove

RUN rm -rf /var/lib/apt/lists/*

# Distribution specific additions

RUN usermod -G pi motion

RUN rm -rf /etc/motion

RUN mkdir /etc/motion

ADD motion.conf /etc/motion

RUN chown -R motion:motion /etc/motion