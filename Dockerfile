FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y --no-install-recommends cron \
  postgresql-client  \
  msmtp ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ADD crontab /etc/cron.d/simple-cron

ADD script.sh /script.sh
RUN chmod +x /script.sh

RUN chmod 0644 /etc/cron.d/simple-cron

RUN touch /var/log/cron.log

RUN echo "account default" > /etc/msmtprc \
  && echo "host \${SMTP_HOST}" >> /etc/msmtprc \
  && echo "port \${SMTP_PORT:-587}" >> /etc/msmtprc \
  && echo "from \${SMTP_USER}" >> /etc/msmtprc \
  && echo "auth on" >> /etc/msmtprc \
  && echo "user \${SMTP_USER}" >> /etc/msmtprc \
  && echo "password \${SMTP_PASS}" >> /etc/msmtprc \
  && echo "tls on" >> /etc/msmtprc \
  && echo "tls_starttls on" >> /etc/msmtprc \
  && echo "logfile /var/log/msmtp.log" >> /etc/msmtprc \
  && chmod 600 /etc/msmtprc

CMD cron && tail -f /var/log/cron.log
