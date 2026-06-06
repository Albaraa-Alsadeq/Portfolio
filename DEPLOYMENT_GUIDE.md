# دليل رفع المشروع على Hostinger VPS + Supabase

---

## الخطوة 1: إعداد Supabase (قاعدة البيانات)

1. اذهب إلى https://supabase.com وأنشئ حساباً مجانياً
2. اضغط "New Project" وأدخل:
   - Name: portfolio
   - Database Password: (احفظه جيداً)
   - Region: اختر الأقرب لجمهورك
3. انتظر ~2 دقيقة حتى يُنشأ المشروع
4. اذهب إلى: Project Settings > Database > Connection string > URI
5. انسخ الـ URI وستبدو هكذا:
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxxxxxxxxx.supabase.co:5432/postgres
   ```
6. استبدل [YOUR-PASSWORD] بكلمة المرور التي أدخلتها
7. احفظ هذا الـ URL، ستحتاجه لاحقاً

---

## الخطوة 2: إعداد Cloudinary (تخزين الصور)

1. اذهب إلى https://cloudinary.com وأنشئ حساباً مجانياً
2. من الـ Dashboard انسخ:
   - Cloud Name
   - API Key
   - API Secret
3. احفظ هذه القيم لاحقاً

---

## الخطوة 3: رفع الكود على GitHub

```bash
# على جهازك المحلي
cd DJANGO-Portfolio-master
git init
git add .
git commit -m "Initial commit - production ready"
git remote add origin https://github.com/YOUR_USERNAME/portfolio.git
git push -u origin main
```

---

## الخطوة 4: الاتصال بالـ VPS

```bash
# من جهازك المحلي (Windows: استخدم PowerShell أو PuTTY)
ssh root@YOUR_VPS_IP
```

---

## الخطوة 5: إعداد الـ VPS (Ubuntu 22.04)

```bash
# تحديث النظام
apt update && apt upgrade -y

# تثبيت المتطلبات
apt install -y python3 python3-pip python3-venv git nginx certbot python3-certbot-nginx

# إنشاء مستخدم للمشروع
adduser portfolio
usermod -aG sudo portfolio
usermod -aG www-data portfolio
su - portfolio
```

---

## الخطوة 6: رفع المشروع على الـ VPS

```bash
# داخل جلسة المستخدم portfolio
cd /home/portfolio
git clone https://github.com/YOUR_USERNAME/portfolio.git DJANGO-Portfolio-master
cd DJANGO-Portfolio-master

# إنشاء virtual environment
python3 -m venv /home/portfolio/venv
source /home/portfolio/venv/bin/activate

# تثبيت المكتبات
pip install -r requirements.txt
```

---

## الخطوة 7: إنشاء ملف .env على الـ VPS

```bash
# داخل مجلد المشروع
nano /home/portfolio/DJANGO-Portfolio-master/.env
```

الصق هذا المحتوى مع تعديل القيم:

```
SECRET_KEY=اكتب_مفتاح_عشوائي_طويل_هنا
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
CSRF_TRUSTED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@db.xxxx.supabase.co:5432/postgres

CLOUD_NAME=your-cloud-name
API_KEY=your-api-key
API_SECRET=your-api-secret

EMAIL_HOST_USER=your@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

لتوليد SECRET_KEY عشوائي:
```bash
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

---

## الخطوة 8: تشغيل Django

```bash
source /home/portfolio/venv/bin/activate
cd /home/portfolio/DJANGO-Portfolio-master

# تطبيق migrations على Supabase
python manage.py migrate

# جمع الملفات الثابتة
python manage.py collectstatic --no-input

# إنشاء مجلد للـ logs
mkdir -p /home/portfolio/logs

# إنشاء superuser للـ admin
python manage.py createsuperuser
```

---

## الخطوة 9: إعداد Gunicorn (كـ service)

```bash
# ارجع إلى root
exit

# انسخ ملف الـ service
cp /home/portfolio/DJANGO-Portfolio-master/deployment/gunicorn.service /etc/systemd/system/gunicorn.service

# تشغيل الخدمة
systemctl daemon-reload
systemctl enable gunicorn
systemctl start gunicorn

# تأكد أنه يعمل
systemctl status gunicorn
```

---

## الخطوة 10: إعداد Nginx

```bash
# انسخ config الخاص بنا
cp /home/portfolio/DJANGO-Portfolio-master/deployment/nginx.conf /etc/nginx/sites-available/portfolio

# عدّل اسم الـ domain في الملف
nano /etc/nginx/sites-available/portfolio
# غير yourdomain.com باسم الـ domain الحقيقي

# فعّل الـ site
ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# اختبر الـ config
nginx -t

# أعد تشغيل Nginx
systemctl restart nginx
```

---

## الخطوة 11: SSL مجاني مع Let's Encrypt

```bash
certbot --nginx -d yourdomain.com -d www.yourdomain.com
# اتبع التعليمات وأدخل بريدك الإلكتروني
# اختر option 2 لـ redirect HTTP إلى HTTPS
```

---

## الخطوة 12: ربط الـ Domain بالـ VPS (Hostinger)

1. اذهب إلى Hostinger Dashboard > Domains > DNS Zone Editor
2. عدّل Record من نوع A:
   - Host: @  →  Value: YOUR_VPS_IP
   - Host: www  →  Value: YOUR_VPS_IP
3. انتظر 5-30 دقيقة لانتشار الـ DNS

---

## التحديث في المستقبل

```bash
# بعد أي تعديل على الكود
ssh portfolio@YOUR_VPS_IP
cd /home/portfolio/DJANGO-Portfolio-master
git pull origin main
bash deployment/deploy.sh
```

---

## روابط مفيدة

- Supabase: https://supabase.com
- Cloudinary: https://cloudinary.com
- Hostinger VPS Panel: https://hpanel.hostinger.com
