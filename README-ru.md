# A-Box | Инструментарий Linux Network Gateway в один шаг

[English](README.md) | [简体中文](README-zh.md) | [Русский](README-ru.md) | [فارسی](README-fa.md)

<img width="1254" alt="Баннер проекта A-Box" src="https://github.com/user-attachments/assets/e6be0200-42f0-43f3-810f-fbfdf68e2357" />

**A-Box** — это единый автоматизированный инструментарий для Linux-серверов. Он объединяет развертывание прокси-сервисов, системную оптимизацию, управление трафиком, контроль доступа, проверки состояния, экспорт клиентских конфигураций, сетевые тесты и интерактивный терминальный интерфейс на китайском/английском языке в одном Bash-скрипте.

**Благодарности:** Спасибо Xray-core, sing-box, Hysteria и связанным open-source проектам за технические идеи и поддержку экосистемы. A-Box является независимым инструментом автоматизации.

[![Version](https://img.shields.io/badge/Version-2026.05.04-success.svg?style=flat-square)](https://github.com/alariclin/a-box/releases)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/alariclin/a-box?style=flat-square&color=yellow)](https://github.com/alariclin/a-box/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/alariclin/a-box?style=flat-square&color=orange)](https://github.com/alariclin/a-box/network/members)

---

## Соответствие требованиям и отказ от ответственности

Проект предназначен для **тестирования сетевой архитектуры, исследований в области кибербезопасности и легитимной защиты приватности только в авторизованных средах**.

1. **Соблюдение закона:** Запрещено использовать проект для действий, нарушающих законы или правила вашей страны или региона.
2. **Ответственность пользователя:** Пользователь самостоятельно несет ответственность за юридические, эксплуатационные и безопасностные последствия неправильного использования.
3. **Техническое назначение:** Используемые технологии маршрутизации и шифрования предназначены для повышения безопасности и приватности передачи данных. Запрещено применять инструмент для незаконных атак, несанкционированного доступа или вреда сетевой инфраструктуре.
4. **Принятие условий:** Загрузка, копирование или запуск скрипта означает, что вы прочитали, поняли и приняли эти условия.

---

## Быстрый старт

### Глобальный канал

```bash
curl -fsSL https://raw.githubusercontent.com/alariclin/a-box/main/install.sh | sudo bash
```

### Зеркальный канал

```bash
curl -fsSL https://ghp.ci/https://raw.githubusercontent.com/alariclin/a-box/main/install.sh | sudo bash
```

### Выбор языка интерфейса

```bash
curl -fsSL https://raw.githubusercontent.com/alariclin/a-box/main/install.sh > A-Box.sh
sudo bash A-Box.sh --lang zh
sudo bash A-Box.sh --lang en
```

### Самопроверка, статус и помощь

```bash
sudo bash A-Box.sh --self-test
sudo bash A-Box.sh --status
sudo bash A-Box.sh --help
```

### Быстрый вход после установки

После первого запуска меню можно открыть командой:

```bash
sb
```

---

## Основные возможности

| Модуль | Описание |
| :--- | :--- |
| Установка в один шаг | Установка зависимостей, инициализация среды, развертывание сервисов и управление Xray-core, sing-box и официальным Hysteria 2. |
| Набор протоколов | VLESS-Vision-Reality, VLESS-XHTTP-Reality, Shadowsocks-2022, Hysteria 2. |
| Стандартные порты | Vision `443/TCP`, XHTTP `8443/TCP`, HY2 `443/UDP`, SS-2022 `2053/TCP+UDP`; пользовательские порты проверяются перед развертыванием. |
| Политика SNI | REALITY SNI по умолчанию — `www.microsoft.com`. Apple/iCloud-подобный SNI на портах не 443 вызывает предупреждение и повторное подтверждение. Для production рекомендуется выбирать SNI через встроенный инструмент. |
| Встроенный SNI Radar | Локальная библиотека кандидатов, полный и mini-host режимы; без зависимости от старых удаленных SNI-скриптов. Оценка по HTTPS/TLS, TLS 1.3, ALPN, SAN, ASN/топологии и вывод прогресса. |
| Экспорт XHTTP | Экспортирует XHTTP параметры `/xhttp`, `stream-one`, HTTP/2 host и `smux: false` для совместимых клиентов, включая Mihomo. |
| Режимы Hysteria 2 | ACME HTTP-01, Cloudflare DNS-01, самоподписанный сертификат с pinning, опциональный masquerade, port hopping и Salamander obfuscation. |
| Инструменты | Benchmark, проверка IP/стриминга/маршрутов, полный SNI preference, mini-host SNI preference, Cloudflare WARP manager, 2G Swap. |
| Эксплуатация | BBR/FQ, TCP KeepAlive, Fail2Ban, logrotate, health probe, обновление Geo, месячный лимит трафика, SS-2022 whitelist, `--status`. |
| Экспорт | URI, QR в терминале, Clash/Mihomo YAML, шаблоны sing-box outbound, JSON для v2rayN/v2rayNG. |
| Безопасное переключение | Новое развертывание останавливает управляемые сервисы, очищает правила A-Box firewall, проверяет конфликты портов; есть полное удаление и сброс среды. |

---

## Полное меню

| Меню | Функция | Назначение |
| :--- | :--- | :--- |
| `1` | Xray VLESS-Vision-Reality | Основной TCP REALITY + Vision канал. |
| `2` | Xray VLESS-XHTTP-Reality | Высокопроизводительный XHTTP over REALITY для совместимых desktop-клиентов. |
| `3` | Xray Shadowsocks-2022 | TCP/UDP relay или landing inbound; рекомендуется whitelist. |
| `4` | Official Hysteria 2 (Apernet) | UDP/QUIC/H3 для мобильных или нестабильных сетей. |
| `5` | Xray + Official HY2 all-in-one | Vision + XHTTP + HY2 + SS-2022. |
| `6` | sing-box VLESS-Vision-Reality | Vision для малой памяти. |
| `7` | sing-box Shadowsocks-2022 | SS-2022 для малой памяти. |
| `8` | sing-box VLESS + SS-2022 | Легкая двухпротокольная конфигурация. |
| `9` | sing-box Hysteria 2 | HY2 на sing-box. |
| `10` | sing-box all-in-one | Vision + HY2 + SS-2022; XHTTP исключен по дизайну. |
| `11` | Toolbox | Benchmark, IP check, SNI preference, WARP, Swap. |
| `12` | VPS one-click optimization | BBR/FQ, лимиты файлов, KeepAlive, Fail2Ban, health probe. |
| `13` | Display all node parameters | Ссылки, QR, YAML, JSON и outbound-шаблоны. |
| `14` | Manual | Полная справка в терминале. |
| `15` | OTA, Geo & core upgrade | Обновление скрипта, Xray Geo или core без сброса параметров узла. |
| `16` | Clean uninstall | Удаление управляемых сервисов, конфигов, firewall rules и optional `sb`. |
| `17` | Delete nodes & reinitialize environment | Очистка orphan-процессов, старых правил и поврежденных конфигов/сервисов. |
| `18` | Monthly traffic limit | vnStat месячный лимит; сервисы останавливаются при достижении квоты. |
| `19` | SS-2022 whitelist manager | Add/remove frontend IP/CIDR и DROP для не-whitelisted источников. |
| `20` | Language settings | Переключение Chinese/English UI с сохранением в `/etc/ddr/.lang`. |
| `0` | Exit | Выход из меню. |

---

## Toolbox

| Подменю | Функция | Описание |
| :--- | :--- | :--- |
| `1` | System benchmark | Запускает `bench.sh` для теста железа и скорости загрузки. |
| `2` | IP quality and route test | Запускает Check.Place для IP quality, streaming unlock и route test. |
| `3` | Local SNI preference | Полная встроенная SNI-библиотека с повышенной concurrency и глубокой проверкой. |
| `4` | Mini-host local SNI preference | Та же библиотека кандидатов, но сниженная concurrency и глубина проверки для слабых серверов. |
| `5` | Cloudflare WARP manager | WARP manager для egress IP masking и streaming unlock сценариев. |
| `6` | 2G Swap allocation | Создает `/swapfile`, снижая риск OOM на малых VPS. |

---

## Рекомендуемые схемы

| Сценарий | Рекомендация |
| :--- | :--- |
| Сбалансированное deployment | Меню `5`: Xray + Official HY2 all-in-one. |
| Легкое deployment для малой памяти | Меню `10`: sing-box all-in-one. |
| Основной TCP-канал | Меню `1`: Xray VLESS-Vision-Reality (`443/TCP`). |
| Desktop high-throughput backup | Меню `2`: Xray VLESS-XHTTP-Reality (`8443/TCP`). |
| Мобильная или нестабильная сеть | Меню `4`: Official Hysteria 2 (`443/UDP`). |
| Relay/landing node | Меню `3`: Xray SS-2022 (`2053/TCP+UDP`) + whitelist. |

---

## Выбор SNI

- Запускайте SNI preference на VPS, а не на локальном компьютере: для REALITY важен путь VPS -> target.
- Предпочитайте кандидатов с `tls13=1`, `san=1`, корректным ALPN и разумной ASN/географической топологией.
- Если доступны нормальные `200` web/document/static-resource target, не выбирайте в приоритет API-only, rate-limited или нестабильные цели.
- Не используйте raw IP как SNI.
- Apple/iCloud-like SNI на не-443 портах явно предупреждается скриптом.

---

## Системные требования

| Пункт | Требование |
| :--- | :--- |
| ОС | Debian 10+, Ubuntu 20.04+, CentOS/RHEL/Rocky/AlmaLinux 8+, Alpine Linux. |
| Init system | systemd или OpenRC. |
| CPU | amd64/x86_64, arm64/aarch64. |
| Права | root или sudo. |
| Сеть | Доступ к системным репозиториям и GitHub Releases. |
| Зависимости | Bash, curl, jq, openssl, iptables, vnStat и другие; отсутствующие зависимости устанавливаются автоматически. |

---

## FAQ

### Скрипт сообщает, что interactive TTY недоступен.
Запустите из интерактивного терминала. Если pipeline не работает, скачайте скрипт и выполните `sudo bash A-Box.sh`.

### Развертывание не удалось из-за занятого порта.
Скрипт проверяет порты, занятые не-A-Box процессами. Освободите порт вручную или выберите другой порт.

### ACME certificate application failed.
Для HTTP-01 убедитесь, что `80/TCP` доступен извне и не занят. Для Cloudflare DNS-01 проверьте права API Token на редактирование DNS зоны.

### Как выбрать лучший SNI?
Используйте Toolbox меню `3` или `4`. Предпочитайте TLS 1.3, SAN match, valid ALPN и разумную ASN/topology связь с VPS.

### Почему сервисы остановились после достижения лимита трафика?
Меню `18` может включить месячный vnStat лимит. Измените или отключите лимит, затем перезапустите сервисы.

---

## Обратная связь и вклад

- [GitHub Issues](https://github.com/alariclin/a-box/issues)
- Pull requests приветствуются.

---

## Лицензия

Проект распространяется по лицензии [Apache License 2.0](LICENSE).
