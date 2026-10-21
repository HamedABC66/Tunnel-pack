
#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

pause() {
  printf "\nبرای بازگشت به منو Enter بزنید..."
  read -r _ || true
}

check_script() {
  local script="$1"

  if [ ! -f "$SCRIPTS_DIR/$script" ]; then
    printf "\nخطا: فایل پیدا نشد:\n%s\n" "$SCRIPTS_DIR/$script"
    return 1
  fi

  bash "$SCRIPTS_DIR/$script" "${@:2}"
}

while true; do
  clear 2>/dev/null || true

  cat <<'MENU'
========================================
              TUNNEL PACK
          ABC | Version 0.2.0-dev
========================================
       منوی بررسی و عیب‌یابی شبکه
========================================

  1) بررسی وضعیت سرور
  2) تست ارتباط با سرور مقابل
  3) بررسی آزمایشی MTU
  4) نکات ایمنی پروژه
  0) خروج

========================================
MENU

  printf "شماره گزینه را وارد کن: "
  read -r choice || exit 0

  case "$choice" in
    1)
      check_script preflight.sh
      pause
      ;;
    2)
      printf "IP یا نام دامنه سرور مقابل: "
      read -r host || continue

      printf "پورت TCP (پیش‌فرض 443): "
      read -r port || continue
      port="${port:-443}"

      check_script link-test.sh "$host" "$port"
      pause
      ;;
    3)
      printf "IP یا نام دامنه سرور مقصد: "
      read -r host || continue

      check_script mtu-test.sh "$host"
      pause
      ;;
    4)
      cat <<'NOTES'

نکات ایمنی Tunnel Pack
----------------------
- این نسخه فقط ابزارهای بررسی و عیب‌یابی را اجرا می‌کند.
- هیچ تانلی نصب نمی‌کند.
- تنظیمات SSH، فایروال، مسیریابی، کرنل و sysctl را تغییر نمی‌دهد.
- بسته بودن Ping لزوماً به معنی قطع بودن ارتباط نیست.
- نتیجه تست MTU ممکن است تحت تأثیر فیلترینگ ICMP قرار بگیرد.
- پیش از هر تغییر شبکه، از تنظیمات سرور نسخه پشتیبان تهیه کن.

NOTES
      pause
      ;;
    0)
      printf "\nخروج از Tunnel Pack.\n"
      exit 0
      ;;
    *)
      printf "\nگزینه نامعتبر است.\n"
      pause
      ;;
  esac
done

