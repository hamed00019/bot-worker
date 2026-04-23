# ==========================================
# بخش پایه (همیشه ثابت است)
# ==========================================
FROM docker.arvancloud.ir/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tehran

RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirror.arvancloud.ir/ubuntu/|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirror.arvancloud.ir/ubuntu/|g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    ca-certificates tzdata curl wget openssl \
    iputils-ping iproute2 netcat-openbsd dnsutils mtr-tiny iperf3 \
    tcpdump nmap socat traceroute jq \
    hping3 proxychains4 stunnel4 iptables nftables \
    autossh sshpass haproxy dropbear fail2ban speedtest-cli \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ==========================================
# بلوک ۱: ابزارهای تخصصی تانلینگ (آفلاین)
# (اگر نیازی ندارید می‌توانید این خطوط را کامنت کنید)
# ==========================================
# COPY backhaul /usr/local/bin/backhaul
# COPY websocat /usr/local/bin/websocat
# COPY chisel /usr/local/bin/chisel
# COPY wstunnel /usr/local/bin/wstunnel
# COPY rathole /usr/local/bin/rathole
# COPY xray /usr/local/bin/xray
# COPY sing-box /usr/local/bin/sing-box
# COPY hysteria /usr/local/bin/hysteria
# COPY udp2raw /usr/local/bin/udp2raw
# COPY shadow-tls /usr/local/bin/shadow-tls
# RUN chmod +x /usr/local/bin/* 2>/dev/null || true


# ==========================================
# بلوک ۲: تولید ترافیک فیک (Fake Traffic)
# (برای فعال‌سازی، خطوط زیر را از کامنت خارج کنید)
# ==========================================
# RUN apt-get update && apt-get install -y cron && rm -rf /var/lib/apt/lists/* \
#     && echo "0 * * * * root wget -qO /dev/null http://mirror.arvancloud.ir/ubuntu/ls-lR.gz > /dev/null 2>&1" > /etc/cron.d/fake-traffic \
#     && chmod 0644 /etc/cron.d/fake-traffic \
#     && crontab /etc/cron.d/fake-traffic


# ==========================================
# بلوک ۳: نصب GOST و اسکریپت استارت آن
# (برای فعال‌سازی، خطوط زیر را از کامنت خارج کنید)
# ==========================================
# COPY gost /usr/local/bin/gost
# RUN chmod +x /usr/local/bin/gost
# COPY start.sh /app/start.sh
# RUN chmod +x /app/start.sh
# EXPOSE 8443


# ==========================================
# بلوک ۴: نصب پنل 3x-ui
# (برای فعال‌سازی، خطوط زیر را از کامنت خارج کنید)
# ==========================================
# COPY x-ui-linux-amd64.tar.gz /tmp/
# RUN mkdir -p /usr/local/x-ui \
#     && mkdir -p /etc/x-ui \
#     && tar zxvf /tmp/x-ui-linux-amd64.tar.gz -C /usr/local/x-ui --strip-components=1 \
#     && chmod +x /usr/local/x-ui/x-ui \
#     && chmod +x /usr/local/x-ui/bin/xray-linux-amd64 \
#     && rm /tmp/x-ui-linux-amd64.tar.gz
# EXPOSE 2053


# ==========================================
# بلوک ۵: ورکر پایتون
# (برای فعال‌سازی، خطوط زیر را از کامنت خارج کنید)
# ==========================================
COPY worker.py /app/worker.py


# ==========================================
# دستور استارت هوشمند (Smart Entrypoint)
# این دستور به صورت خودکار چک می‌کند کدام برنامه‌ها نصب شده‌اند و همان‌ها را اجرا می‌کند
# ==========================================
CMD ["sh", "-c", "\
    service cron start 2>/dev/null || true; \
    if [ -f '/app/start.sh' ]; then /app/start.sh & fi; \
    if [ -f '/usr/local/x-ui/x-ui' ]; then \
        cd /usr/local/x-ui/ && \
        if [ ! -f '/etc/x-ui/x-ui.db' ]; then ./x-ui setting -username hamed -password 43117700 -port 2053; fi && \
        ./x-ui & \
    fi; \
    if [ -f '/app/worker.py' ]; then cd /app && python3 -u worker.py & fi; \
    wait -n || tail -f /dev/null \
"]
