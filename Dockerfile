# استفاده از ایمیج سبک پایتون
FROM python:3.10-slim

# تنظیم دایرکتوری کاری داخل کانتینر
WORKDIR /app

# کپی کردن فایل اصلی ورکر
COPY worker.py .

# اجرای اسکریپت
CMD ["python", "-u", "worker.py"]
