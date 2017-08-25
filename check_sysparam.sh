#!/usr/bin/env bash
export version=1.0 # версия скрипта
# Автор: В.С. Патрушев 
# v.patryshev@vniias.ru
# Описание: Скрипт проверки конфигурации и установленных приложений для CentOS 7

mem_total=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
swap_total=`cat /proc/meminfo | grep SwapTotal | awk '{print $2}'`
hdd_total=`df | awk '(NR == 2)' | awk '{print $2}'`
hdd_free=`df | awk '(NR == 2)' | awk '{print $4}'`
interface=`ip addr | grep BROADCAST | grep LOWER_UP | awk '{ print $2 }' | sed s/://`
IP=$(/sbin/ip a | grep "inet" | grep 10 | awk '{print $2}'|cut -f 1 -d / -s)
let "mem_mb=$mem_total / 1024"
let "swap_mb=$swap_total / 1024"
let "hdd_total_mb=$hdd_total / 1024"
let "hdd_free_mb=$hdd_free / 1024"

if [[ -n "$(hostname) | grep kbsh.oao.rzd" ]]; then
	NTP="ntp.kbsh.oao.rzd"
	NTP2="ntp1.kbsh.oao.rzd"
elif [[ -n "$(hostname) | grep esrr.oao.rzd" ]]; then
	NTP="rzd-rdc-02.oao.rzd"
	NTP2="esrr-dc-03.esrr.oao.rzd"
elif [[ -n "$(hostname) | grep svrw.oao.rzd" ]]; then
	NTP="svrw-ntp-01.svrw.oao.rzd"
	NTP2="svrw-ntp-02.svrw.oao.rzd"
elif [[ -n "$(hostname) | grep krw.oao.rzd" ]]; then
	NTP="time.krw.rzd"
	NTP2="krw-dc-01.krw.oao.rzd"
elif [[ -n "$(hostname) | grep msk.oao.rzd" ]]; then
	NTP="10.35.48.210"
	NTP2="10.35.48.211"
elif [[ -n "$(hostname) | grep orw.oao.rzd" ]]; then
	NTP="10.35.48.210"
	NTP2="10.35.48.211"
else
	NTP=""
	NTP=""
fi

function ui_style() {
  local user_text=$1;   # User input text (string)
  local user_styles=$2; # Text color/styles, separated by spaces (string)
  declare -A styles;
  styles['white']='\033[0;37m';  # Белый
  styles['red']='\033[0;31m';    # Красный
  styles['green']='\033[0;32m';  # Зеленый
  styles['yellow']='\033[0;33m'; # Жёлтый
  styles['blue']='\033[0;34m';   # Синий
  styles['gray']='\033[1;30m';   # Серый
  styles['bold']='\033[1m';      # Жирный
  styles['underline']='\033[4m'; # Подчеркивание
  styles['reverse']='\033[7m';   # Закраска фона
  styles['none']='\033[0m';      # Сброс настроек текста
  local text_styles='';
  for style in $user_styles; do
    if [[ ! -z "$style" ]] && [[ ! -z "${styles[$style]}" ]]; then
      text_styles="$text_styles${styles[$style]}";
    fi;
  done;
  
  [ ! -z "$text_styles" ] && {
    echo -e "$text_styles$user_text${styles[none]}";
  } || {
    echo -e "$1";
  };
}

function system_application_exists() {
  local app_name=$1; 
  command -v "$app_name" >/dev/null 2>&1 && return 0 || return 1;
}

function system_grep_exists() {
  local grep_name=$1;
  local file_name=$2;
  grep "$grep_name" "$file_name" >/dev/null 2>&1 && return 0 || return 1;
}

function system_check_exists() {
  local fd_name=$1;
  [ -e "$fd_name" ] >/dev/null 2>&1 && return 0 || return 1;
}

function determine_service_tool() {
  local SERVICE=$1;
  systemctl status "$SERVICE" | grep dead >/dev/null 2>&1&& return 0 || return 1;
}

function active_service() {
  local SERVICE=$1;
  systemctl status "$SERVICE" | grep running >/dev/null 2>&1&& return 0 || return 1;
}

function diff_service_tool() {
  local diff_name1=$1;
  local diff_name2=$2;
  diff "$diff_name1" "$diff_name2" >/dev/null 2>&1&& return 0 || return 1;
}

{
  installed="$(ui_style 'OK!' 'green')";
  not_installed="$(ui_style 'FAILED' 'red bold')";
  ##application
  curl_inst="$not_installed"    && { system_application_exists 'curl'  && curl_inst="$installed"; };
  wget_inst="$not_installed"    && { system_application_exists 'wget'  && wget_inst="$installed"; };
  sed_inst="$not_installed"    && { system_application_exists 'sed'  && sed_inst="$installed"; };
  awk_inst="$not_installed"    && { system_application_exists 'awk'  && awk_inst="$installed"; };
  htop_inst="$not_installed"    && { system_application_exists 'htop'  && htop_inst="$installed"; };
  iotop_inst="$not_installed"    && { system_application_exists 'iotop'  && iotop_inst="$installed"; };
  pbzip2_inst="$not_installed"    && { system_application_exists 'pbzip2'  && pbzip2_inst="$installed"; };
  pigz_inst="$not_installed"    && { system_application_exists 'pigz'  && pigz_inst="$installed"; };
  pssh_inst="$not_installed"    && { system_application_exists 'pssh'  && pssh_inst="$installed"; };
  tmux_inst="$not_installed"    && { system_application_exists 'tmux'  && tmux_inst="$installed"; };
  zab_inst="$not_installed"    && { system_application_exists 'zabbix_agentd'  && zab_inst="$installed"; };
  java_inst="$not_installed"    && { system_application_exists 'java'  && java_inst="$installed"; };
  jruby_inst="$not_installed"    && { system_application_exists 'jruby'  && jruby_inst="$installed"; };
  ftp_inst="$not_installed"    && { system_application_exists 'ftp'  && ftp_inst="$installed"; };
  scp_inst="$not_installed"    && { system_application_exists 'scp'  && scp_inst="$installed"; };
  mc_inst="$not_installed"    && { system_application_exists 'mc'  && mc_inst="$installed"; };
  ntp_inst="$not_installed"    && { system_application_exists 'ntpd'  && ntp_inst="$installed"; };
  chrony_inst="$not_installed"    && { system_application_exists 'chronyd'  && chrony_inst="$installed"; };
  #grep
  user_grep="$not_installed"    && { system_grep_exists 'rvec-adm' '/etc/passwd'  && user_grep="$installed"; };
  selinux_grep="$not_installed"    && { system_grep_exists 'SELINUX=disabled' '/etc/selinux/config'  && selinux_grep="$installed"; };
  limits_grep="$not_installed"    && { system_grep_exists '* soft stack 2048' '/etc/security/limits.conf' && system_grep_exists '* hard stack 2048' '/etc/security/limits.conf' && system_grep_exists '* soft nproc 65536' '/etc/security/limits.conf' && system_grep_exists '* hard nproc 65536' '/etc/security/limits.conf' && system_grep_exists '* soft nofile 1024000' '/etc/security/limits.conf' && system_grep_exists '* hard nofile 1024000' '/etc/security/limits.conf' && limits_grep="$installed"; };
  limitsd_grep="$not_installed"    && { system_grep_exists '#\*          soft    nproc     4096' '/etc/security/limits.d/20-nproc.conf'  && limitsd_grep="$installed"; };
  grub_grep="$not_installed"    && { system_grep_exists 'GRUB_TIMEOUT=2' '/etc/default/grub'  && grub_grep="$installed"; };
  zabbix_grep="$not_installed"    && { system_grep_exists 'Server=10.247.2.233' '/etc/zabbix/zabbix_agentd.conf' && system_grep_exists 'ServerActive=10.247.2.233' '/etc/zabbix/zabbix_agentd.conf' && zabbix_grep="$installed"; };
  ntp_grep="$not_installed"    && { system_grep_exists '$NTP' '/etc/ntp.conf' && system_grep_exists '$NTP2' '/etc/ntp.conf' && ntp_grep="$installed"; };
  chrony_grep="$not_installed"    && { system_grep_exists '$NTP' '/etc/chrony.conf' && system_grep_exists '$NTP2' '/etc/chrony.conf' && chrony_grep="$installed"; };
  #check
  ruby_dir_check="$not_installed"    && { system_check_exists '/opt/ruby_projects'  && ruby_dir_check="$installed"; };
  templ_dir_check="$not_installed"    && { system_check_exists '/opt/ruby_projects/templ'  && templ_dir_check="$installed"; };
  old_dir_check="$not_installed"    && { system_check_exists '/opt/ruby_projects/old'  && old_dir_check="$installed"; };
  jdk_sh_check="$not_installed"    && { system_check_exists '/etc/profile.d/jdk.sh'  && jdk_sh_check="$installed"; };
  jruby_sh_check="$not_installed"    && { system_check_exists '/etc/profile.d/jruby.sh'  && jruby_sh_check="$installed"; };
  #service
  firewall_inst="$not_installed"    && { determine_service_tool 'firewalld'  && firewall_inst="$installed"; };
  zoo_inst="$not_installed"    && { determine_service_tool 'zoo'  && zoo_inst="$installed"; };
  chronyd_inst="$not_installed"    && { active_service 'chronyd'  && chronyd_inst="$installed"; };
  ntpd_inst="$not_installed"    && { determine_service_tool 'ntpd'  && ntpd_inst="$installed"; };
  #diff
  bash_profile_diff="$not_installed"    && { diff_service_tool '/home/rvec-adm/.bash_profile' '/etc/skel/.bash_profile' && bash_profile_diff="$installed"; };
  bash_profile2_diff="$not_installed"    && { diff_service_tool '/root/.bash_profile' '/etc/skel/.bash_profile' && bash_profile2_diff="$installed"; };
echo -e "
$(ui_style 'Информация о системе:' 'yellow')
    $(ui_style 'Текущая дата:' 'yellow') `date +%Y-%m-%d`
    $(ui_style 'Текущее время:' 'yellow') `date +%H:%M`
    $(ui_style 'Имя хоста:' 'yellow') `hostname`
    $(ui_style 'ОС:' 'yellow') `cat /etc/redhat-release | awk {'print $1'}` $(cat /etc/redhat-release | awk '{ print $4 }' | cut -d . -f1,2)
    $(ui_style 'Разрядность ОС:' 'yellow') `arch`
    $(ui_style 'Версия ядра Linux:' 'yellow') `uname -r | sed -e "s/-/ /" | awk {'print $1'}`
    $(ui_style 'IP адрес:' 'yellow')  $IP
    $(ui_style 'RAM:' 'yellow') $mem_mb $(ui_style 'Mb' 'yellow')
    $(ui_style 'Swap:' 'yellow') $swap_mb $(ui_style 'Mb' 'yellow')
    $(ui_style 'HDD:' 'yellow') $hdd_total_mb $(ui_style 'Mb' 'yellow')
    $(ui_style 'Свободно:' 'yellow') $hdd_free_mb $(ui_style 'Mb' 'yellow')

$(ui_style 'Проверка системы на необходимые настройки:' 'yellow')
    $(ui_style 'пользователь rvec-adm' 'yellow')		($user_grep)
    $(ui_style 'SELINUX - выключен' 'yellow')			($selinux_grep)
    $(ui_style 'GRUB - сконфигурирован' 'yellow')		($grub_grep)
    $(ui_style 'firewall - выключен' 'yellow')			($firewall_inst)
    $(ui_style 'chronyd - работает' 'yellow')			($chronyd_inst)
    $(ui_style 'ntpd - выключен' 'yellow')			($ntpd_inst)
    $(ui_style 'chronyd - сконфигурирован' 'yellow')		($chrony_grep)
    $(ui_style 'ntpd - сконфигурирован' 'yellow')		($ntp_grep)
    $(ui_style 'Limits - сконфигурирован' 'yellow')		($limits_grep)
    $(ui_style 'Limits.d - сконфигурирован' 'yellow')		($limitsd_grep)
    $(ui_style 'директория ruby_projects' 'yellow')		($ruby_dir_check)
    $(ui_style 'директория templ' 'yellow')			($templ_dir_check)
    $(ui_style 'директория old' 'yellow')			($old_dir_check)
    $(ui_style 'jdk.sh' 'yellow')				($jdk_sh_check)
    $(ui_style 'jruby.sh' 'yellow')				($jruby_sh_check)
    $(ui_style 'zabbix - сконфигурирован' 'yellow')		($zabbix_grep)
    $(ui_style '.bash_profile rvec-adm = default' 'yellow')	($bash_profile_diff)
    $(ui_style '.bash_profile root = default' 'yellow')	($bash_profile2_diff)
	
$(ui_style 'Проверка системы на необходимое ПО:' 'yellow')	
    $(ui_style 'chrony' 'yellow')		($chrony_inst)
    $(ui_style 'ntp' 'yellow')			($ntp_inst)
    $(ui_style 'curl' 'yellow')		($curl_inst)
    $(ui_style 'wget' 'yellow')		($wget_inst)
    $(ui_style 'sed' 'yellow')			($sed_inst)
    $(ui_style 'awk' 'yellow')			($awk_inst)
    $(ui_style 'htop' 'yellow')		($htop_inst)
    $(ui_style 'iotop' 'yellow')		($iotop_inst)
    $(ui_style 'pbzip2' 'yellow')		($pbzip2_inst)
    $(ui_style 'pigz' 'yellow')		($pigz_inst)
    $(ui_style 'pssh' 'yellow')		($pssh_inst)
    $(ui_style 'tmux' 'yellow')		($tmux_inst)
    $(ui_style 'Zabbix_agentd' 'yellow')	($zab_inst)
    $(ui_style 'Java' 'yellow')		($java_inst)
    $(ui_style 'Jruby' 'yellow')		($jruby_inst)
    $(ui_style 'ZooKeeper' 'yellow')		($zoo_inst)
    $(ui_style 'FTP' 'yellow')			($ftp_inst)
    $(ui_style 'SCP' 'yellow')			($scp_inst)
    $(ui_style 'MC' 'yellow')			($mc_inst)
";
};