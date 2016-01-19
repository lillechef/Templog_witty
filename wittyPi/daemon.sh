#!/bin/bash
# file: daemon.sh
#
# This script should be auto started, to support WittyPi hardware
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

# get current directory
cur_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# utilities
. "$cur_dir/utilities.sh"

log 'Witty Pi daemon (v2.14) is started.'

# halt by GPIO-8 (wiringPi pin 24)
halt_pin=24

# LED on GPIO-17 (wiringPi pin 0)
led_pin=0

# if RTC presents
has_rtc=is_rtc_connected

if $has_rtc ; then
  # disable square wave and enable alarm B
  i2c_write 0x01 0x68 0x0E 0x07

  # clear alarm flags
  byte_F=$(i2c_read 0x01 0x68 0x0F)
  byte_F=$(($byte_F&0xFC))
  i2c_write 0x01 0x68 0x0F $byte_F
else
  log 'Witty Pi is not connected, skipping I2C communications...'
fi

# delay until GPIO pin state gets stable
counter=0
while [ $counter -lt 10 ]; do
  if [ $(gpio read $halt_pin) == '1' ] ; then
    counter=$(($counter+1))
  else
    counter=0
  fi
  sleep 1
done

# wait for GPIO-8 (wiringPi pin 24) falling, or alarm B
log 'Pending for incoming shutdown command...'
gpio wfi $halt_pin falling
log 'Shutdown command is received...'

# light the white LED
gpio mode $led_pin out
gpio write $led_pin 1

# restore GPIO-4
gpio mode $halt_pin in
gpio mode $halt_pin up

if $has_rtc ; then
  # clear alarm flags
  byte_F=$(i2c_read 0x01 0x68 0x0F)
  byte_F=$(($byte_F&0xFC))
  i2c_write 0x01 0x68 0x0F $byte_F

  # only enable alarm A
  i2c_write 0x01 0x68 0x0E 0x05
fi

log 'Halting all processes and then shutdown Raspberry Pi...'

# halt everything and shutdown
shutdown -h now
