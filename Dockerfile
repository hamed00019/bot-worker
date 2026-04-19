# استفاده از ایمیج سبک پایتون
FROM python:3.10-slim

# تنظیم دایرکتوری کاری داخل کانتینر
WORKDIR /app

# کپی کردن فایل نیازمندی‌ها و نصب آن‌ها
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# کپی کردن فایل اصلی ورکر
COPY worker.py .

# اجرای اسکریپت
CMD ["python", "-u", "worker.py"]