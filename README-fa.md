# A-Box | ابزار یک‌مرحله‌ای Linux Network Gateway

[English](README.md) | [简体中文](README-zh.md) | [Русский](README-ru.md) | [فارسی](README-fa.md)

<img width="1254" alt="بنر پروژه A-Box" src="https://github.com/user-attachments/assets/d45171b6-17f2-45da-9c60-e6b8b64301c1" />

**A-Box** یک ابزار خودکار یکپارچه برای سرورهای Linux است. این ابزار نصب سرویس‌های پروکسی، بهینه‌سازی سیستم، مدیریت ترافیک، کنترل دسترسی، بررسی سلامت سرویس، خروجی گرفتن از تنظیمات کلاینت، تست کیفیت شبکه و رابط تعاملی ترمینال چینی/انگلیسی را در یک اسکریپت مستقل Bash جمع می‌کند.

**قدردانی:** از پروژه‌های Xray-core، sing-box، Hysteria و پروژه‌های متن‌باز مرتبط برای الهام فنی و پشتیبانی اکوسیستم سپاس‌گزاریم. A-Box یک ابزار مستقل برای خودکارسازی و orchestration است.

[![Version](https://img.shields.io/badge/Version-2026.05.04-success.svg?style=flat-square)](https://github.com/alariclin/a-box/releases)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/alariclin/a-box?style=flat-square&color=yellow)](https://github.com/alariclin/a-box/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/alariclin/a-box?style=flat-square&color=orange)](https://github.com/alariclin/a-box/network/members)

---

## انطباق و سلب مسئولیت

این پروژه فقط برای **تست معماری شبکه، پژوهش امنیت سایبری و محافظت قانونی از حریم خصوصی در محیط‌های کاملاً مجاز** طراحی شده است.

1. **رعایت قانون:** استفاده از این پروژه برای فعالیت‌هایی که قوانین کشور یا منطقه شما را نقض کند ممنوع است.
2. **مسئولیت کاربر:** مسئولیت کامل پیامدهای حقوقی، عملیاتی و امنیتی ناشی از استفاده نادرست یا سوءاستفاده بر عهده کاربر است.
3. **هدف فنی:** فناوری‌های مسیریابی و رمزنگاری برای افزایش امنیت و حریم خصوصی انتقال داده طراحی شده‌اند. استفاده برای حمله غیرقانونی، دسترسی غیرمجاز یا آسیب به زیرساخت شبکه ممنوع است.
4. **پذیرش شرایط:** دانلود، کپی یا اجرای اسکریپت به معنی مطالعه، درک و پذیرش این شرایط است.

---

## شروع سریع

### مسیر جهانی

```bash
curl -fsSL https://raw.githubusercontent.com/alariclin/a-box/main/install.sh | sudo bash
```

### مسیر آینه

```bash
curl -fsSL https://ghp.ci/https://raw.githubusercontent.com/alariclin/a-box/main/install.sh | sudo bash
```

### انتخاب زبان رابط

```bash
curl -fsSL https://raw.githubusercontent.com/alariclin/a-box/main/install.sh > A-Box.sh
sudo bash A-Box.sh --lang zh
sudo bash A-Box.sh --lang en
```

### خودآزمایی، وضعیت و راهنما

```bash
sudo bash A-Box.sh --self-test
sudo bash A-Box.sh --status
sudo bash A-Box.sh --help
```

### ورود سریع پس از نصب

پس از اجرای اول، منو را هر زمان می‌توانید با دستور زیر باز کنید:

```bash
sb
```

---

## قابلیت‌های اصلی

| بخش | توضیح |
| :--- | :--- |
| نصب یک‌مرحله‌ای | نصب وابستگی‌ها، آماده‌سازی محیط، راه‌اندازی سرویس‌ها و مدیریت Xray-core، sing-box و Hysteria 2 رسمی. |
| مجموعه پروتکل‌ها | VLESS-Vision-Reality، VLESS-XHTTP-Reality، Shadowsocks-2022، Hysteria 2. |
| پورت‌های استاندارد | Vision `443/TCP`، XHTTP `8443/TCP`، HY2 `443/UDP`، SS-2022 `2053/TCP+UDP`؛ پورت‌های سفارشی پیش از نصب بررسی می‌شوند. |
| سیاست SNI | SNI پیش‌فرض REALITY برابر `www.microsoft.com` است. SNIهای مشابه Apple/iCloud روی پورت‌های غیر 443 هشدار و تأیید دوباره می‌گیرند. برای production بهتر است از ابزار داخلی SNI preference استفاده شود. |
| SNI Radar داخلی | کتابخانه محلی کاندیداها، حالت کامل و mini-host؛ بدون وابستگی به اسکریپت‌های قدیمی راه دور. امتیازدهی بر اساس HTTPS/TLS، TLS 1.3، ALPN، SAN، ASN/topology و نمایش پیشرفت. |
| خروجی XHTTP | پارامترهای XHTTP شامل `/xhttp`، `stream-one`، HTTP/2 host و `smux: false` را برای کلاینت‌های سازگار مثل Mihomo خروجی می‌دهد. |
| حالت‌های Hysteria 2 | ACME HTTP-01، Cloudflare DNS-01، گواهی خودامضا با pinning، masquerade اختیاری، port hopping اختیاری و Salamander obfuscation اختیاری. |
| جعبه ابزار | Benchmark، بررسی کیفیت IP/استریم/مسیر، SNI preference کامل، SNI preference مخصوص سرور کوچک، Cloudflare WARP manager و 2G Swap. |
| نگهداری | BBR/FQ، TCP KeepAlive، Fail2Ban، logrotate، health probe، به‌روزرسانی Geo، محدودیت ماهانه ترافیک، SS-2022 whitelist و `--status`. |
| فرمت‌های خروجی | URI، QR در ترمینال، Clash/Mihomo YAML، قالب outbound برای sing-box و JSON برای v2rayN/v2rayNG. |
| نصب ایمن | نصب جدید سرویس‌های مدیریت‌شده را متوقف می‌کند، قوانین firewall مربوط به A-Box را پاک می‌کند، تداخل پورت را بررسی می‌کند و حذف کامل/بازنشانی محیط را ارائه می‌دهد. |

---

## منوی کامل

| منو | عملکرد | کاربرد |
| :--- | :--- | :--- |
| `1` | Xray VLESS-Vision-Reality | مسیر اصلی TCP REALITY + Vision. |
| `2` | Xray VLESS-XHTTP-Reality | مسیر XHTTP over REALITY پرسرعت برای کلاینت‌های دسکتاپ سازگار. |
| `3` | Xray Shadowsocks-2022 | ورودی TCP/UDP relay یا landing؛ استفاده از whitelist توصیه می‌شود. |
| `4` | Official Hysteria 2 (Apernet) | مسیر UDP/QUIC/H3 برای موبایل یا شبکه‌های ناپایدار. |
| `5` | Xray + Official HY2 all-in-one | Vision + XHTTP + HY2 + SS-2022. |
| `6` | sing-box VLESS-Vision-Reality | نصب Vision با مصرف حافظه کمتر. |
| `7` | sing-box Shadowsocks-2022 | نصب SS-2022 با مصرف حافظه کمتر. |
| `8` | sing-box VLESS + SS-2022 | ترکیب سبک دو پروتکل. |
| `9` | sing-box Hysteria 2 | اجرای HY2 با sing-box. |
| `10` | sing-box all-in-one | Vision + HY2 + SS-2022؛ XHTTP عمداً حذف شده است. |
| `11` | Toolbox | Benchmark، IP check، SNI preference، WARP، Swap. |
| `12` | VPS one-click optimization | BBR/FQ، محدودیت فایل، KeepAlive، Fail2Ban، health probe. |
| `13` | Display all node parameters | نمایش لینک‌ها، QR، YAML، JSON و قالب‌های outbound. |
| `14` | Manual | راهنمای کامل ترمینال. |
| `15` | OTA, Geo & core upgrade | به‌روزرسانی اسکریپت، داده Xray Geo یا core بدون ریست پارامترهای node. |
| `16` | Clean uninstall | حذف سرویس‌های مدیریت‌شده، تنظیمات، firewall rules و میانبر اختیاری `sb`. |
| `17` | Delete nodes & reinitialize environment | پاک‌سازی پردازش‌های باقی‌مانده، قوانین قدیمی و تنظیمات/سرویس‌های خراب. |
| `18` | Monthly traffic limit | محدودیت ماهانه بر اساس vnStat؛ پس از رسیدن به سهمیه سرویس‌ها متوقف می‌شوند. |
| `19` | SS-2022 whitelist manager | افزودن/حذف frontend IP/CIDR و DROP برای منابع غیر whitelist. |
| `20` | Language settings | تغییر رابط Chinese/English و ذخیره در `/etc/ddr/.lang`. |
| `0` | Exit | خروج از منوی تعاملی. |

---

## جزئیات Toolbox

| زیرمنو | عملکرد | توضیح |
| :--- | :--- | :--- |
| `1` | System benchmark | اجرای `bench.sh` برای تست سخت‌افزار و سرعت دانلود. |
| `2` | IP quality and route test | اجرای Check.Place برای کیفیت IP، unlock استریم و route test. |
| `3` | Local SNI preference | اجرای کتابخانه کامل داخلی SNI با concurrency بالاتر و بررسی عمیق‌تر. |
| `4` | Mini-host local SNI preference | همان کتابخانه کاندیداها با concurrency و عمق بررسی کمتر برای سرورهای ضعیف. |
| `5` | Cloudflare WARP manager | مدیریت WARP برای egress IP masking و سناریوهای streaming unlock. |
| `6` | 2G Swap allocation | ایجاد `/swapfile` برای کاهش خطر OOM روی VPS کم‌حافظه. |

---

## ترکیب‌های پیشنهادی

| سناریو | پیشنهاد |
| :--- | :--- |
| نصب متعادل production | منوی `5`: Xray + Official HY2 all-in-one. |
| نصب سبک برای حافظه کم | منوی `10`: sing-box all-in-one. |
| مسیر اصلی TCP | منوی `1`: Xray VLESS-Vision-Reality (`443/TCP`). |
| مسیر پشتیبان پرسرعت دسکتاپ | منوی `2`: Xray VLESS-XHTTP-Reality (`8443/TCP`). |
| موبایل یا شبکه ناپایدار | منوی `4`: Official Hysteria 2 (`443/UDP`). |
| node برای relay/landing | منوی `3`: Xray SS-2022 (`2053/TCP+UDP`) + whitelist. |

---

## نکات انتخاب SNI

- SNI preference را روی VPS اجرا کنید، نه لپ‌تاپ محلی؛ کیفیت REALITY target بیشتر به مسیر VPS -> target وابسته است.
- کاندیداهای دارای `tls13=1`، `san=1`، ALPN معتبر و رابطه ASN/topology منطقی را ترجیح دهید.
- وقتی targetهای معمولی `200` مثل وب/داکیومنت/استاتیک موجود است، API-only، rate-limited یا targetهای ناپایدار را در اولویت نگذارید.
- از IP خام به عنوان SNI استفاده نکنید.
- SNI مشابه Apple/iCloud روی پورت‌های غیر 443 توسط اسکریپت هشدار داده می‌شود.

---

## نیازمندی‌های سیستم

| مورد | نیازمندی |
| :--- | :--- |
| سیستم‌عامل | Debian 10+، Ubuntu 20.04+، CentOS/RHEL/Rocky/AlmaLinux 8+، Alpine Linux. |
| Init system | systemd یا OpenRC. |
| CPU | amd64/x86_64، arm64/aarch64. |
| دسترسی | root یا sudo. |
| شبکه | دسترسی به مخازن بسته سیستم و GitHub Releases. |
| وابستگی‌ها | Bash، curl، jq، openssl، iptables، vnStat و موارد دیگر؛ موارد ناقص خودکار نصب می‌شوند. |

---

## FAQ

### اسکریپت می‌گوید interactive TTY در دسترس نیست.
آن را در ترمینال تعاملی اجرا کنید. اگر pipeline کار نکرد، اسکریپت را دانلود کنید و `sudo bash A-Box.sh` را اجرا کنید.

### نصب به دلیل اشغال بودن پورت شکست خورد.
اسکریپت پورت‌هایی را که توسط پردازش‌های غیر A-Box اشغال شده‌اند بررسی می‌کند. پورت را دستی آزاد کنید یا پورت دیگری انتخاب کنید.

### درخواست گواهی ACME شکست خورد.
برای HTTP-01 مطمئن شوید `80/TCP` از اینترنت قابل دسترسی است و اشغال نیست. برای Cloudflare DNS-01 مطمئن شوید API Token مجوز ویرایش DNS zone را دارد.

### چگونه بهترین SNI را انتخاب کنم؟
از Toolbox منوی `3` یا `4` استفاده کنید. TLS 1.3، SAN match، ALPN معتبر و رابطه منطقی ASN/topology با VPS را ترجیح دهید.

### چرا سرویس‌ها پس از رسیدن به محدودیت ترافیک متوقف شدند؟
منوی `18` می‌تواند محدودیت ماهانه vnStat را فعال کند. محدودیت را تغییر/غیرفعال کنید و سپس سرویس‌ها را دوباره راه‌اندازی کنید.

---

## بازخورد و مشارکت

- [GitHub Issues](https://github.com/alariclin/a-box/issues)
- Pull Request پذیرفته می‌شود.

---

## مجوز

این پروژه تحت مجوز [Apache License 2.0](LICENSE) منتشر شده است.
