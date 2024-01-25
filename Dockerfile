ARG base_image=alpine
ARG base_tag=edge

FROM "${base_image}:${base_tag}" as runner

ENV LANG=C.UTF8

RUN apk add --no-cache \
    openssh \
    python3 \
    bash \
    dash \
    fish 
    # \
    # zsh \
    # ion-shell \
    # tcsh \
    # oksh \
    # loksh \
    # yash


# RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
#     elvish \
#     xonsh \
#     mrsh \
#     imrsh \
#     nsh \
#     nushell





# Do not hardcode important passwords into Dockerfiles (and do not
# set trivially guessable passwords), as I have done below!   
#
# Use secrets, or at least environment variables.
#  
# This Dockerfile is intended to define a local testing server, 
# remote connections to which are prevented by other means.
#
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    adduser -h /home/sh -s /bin/sh -D sh && \
    echo -n 'sh:sh' | chpasswd && \
    adduser -h /home/ash -s /bin/ash -D ash && \
    echo -n 'ash:ash' | chpasswd && \
    adduser -h /home/bash -s /bin/bash  -D bash && \
    echo -n 'bash:bash' | chpasswd && \
    adduser -h /home/dash -s /usr/bin/dash -D dash && \
    echo -n 'dash:dash' | chpasswd && \
    adduser -h /home/fish -s /usr/bin/fish -D fish && \
    echo -n 'fish:fish' | chpasswd 
    # && \
    # adduser -h /home/zsh -s /bin/zsh -D zsh && \
    # echo -n 'zsh:zsh' | chpasswd && \
    # adduser -h /home/ion-shell -s /usr/bin/ion -D ion-shell && \
    # echo -n 'ion-shell:ion-shell' | chpasswd && \
    # adduser -h /home/tcsh -s /bin/tcsh -D tcsh && \
    # echo -n 'tcsh:tcsh' | chpasswd && \
    # adduser -h /home/oksh -s /bin/oksh -D oksh && \
    # echo -n 'oksh:oksh' | chpasswd && \
    # adduser -h /home/loksh -s /bin/ksh -D loksh && \
    # echo -n 'loksh:loksh' | chpasswd && \
    # adduser -h /home/yash -s /usr/bin/yash -D yash && \
    # echo -n 'yash:yash' | chpasswd && \
    # adduser -h /home/elvish -s /usr/bin/elvish -D elvish && \
    # echo -n 'elvish:elvish' | chpasswd && \
    # adduser -h /home/xonsh -s /usr/bin/xonsh -D xonsh && \
    # echo -n 'xonsh:xonsh' | chpasswd && \
    # adduser -h /home/mrsh -s /usr/bin/mrsh -D mrsh && \
    # echo -n 'mrsh:mrsh' | chpasswd && \
    # adduser -h /home/imrsh -s /usr/bin/imrsh -D imrsh && \
    # echo -n 'imrsh:imrsh' | chpasswd && \
    # adduser -h /home/nsh -s /usr/bin/nsh -D nsh && \
    # echo -n 'nsh:nsh' | chpasswd && \
    # adduser -h /home/nushell -s /usr/bin/nu -D nushell && \
    # echo -n 'nushell:nushell' | chpasswd

RUN ssh-keygen -A

# Start SSH daemon to listen for log ins.
CMD ["/usr/sbin/sshd", "-D", "-e"]

EXPOSE 22