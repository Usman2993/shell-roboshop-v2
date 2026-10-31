#!/bin/bash

app_name=cart

source ./common.sh

check_root

app_setup

nodejs_steup

systemd_setup

restart

total_time