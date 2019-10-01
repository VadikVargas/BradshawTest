############################################################
# Copyright 2018, Tryon Solutions, Inc.
# All rights reserved.  Proprietary and confidential.
#
# This file is subject to the license terms found at 
# https://www.cycleautomation.com/end-user-license-agreement/
#
# The methods and techniques described herein are considered
# confidential and/or trade secrets. 
# No part of this file may be copied, modified, propagated,
# or distributed except as authorized by the license.
############################################################ 
# 
# Feature: Environment.feature
# 
# Functional Area: System, connection and variable default set up
# Related SOP/WI: ??.??-??
# 
# Author: Tryon Solutions
# Cycle Version: 2.0
# JDA WMS Version: 2018.1
# 
# Description: This feature stores system, connection and variable default set up
# 
# Usage Instructions: Call these sceanrios in project Background: features
# 
# Values can be overwritten by individuals by assigning before calling Set Up
# 
############################################################ 
Feature: Environment Feature

Scenario: Set Up Environment
Given I assign value "SYM001" to unassigned variable "devcod"
And I assign value $devcod to unassigned variable "start_loc"
And I assign value "CYCLE" to unassigned variable "username"
And I assign value "Cycle" to unassigned variable "password"
And I assign value "VOICE PIN" to unassigned variable "voice_user_pin"
And I assign value "WMD1" to unassigned variable "wh_id"
And I assign value "HAND" to unassigned variable "vehtyp"
And I assign value "1" to unassigned variable "voice_vehtyp"
And I assign value "Hand-held, correct?" to unassigned variable "voice_vehtyp_confirm"
And I assign value "WH_ID" to unassigned variable "src_wh_id"
And I assign value "CLIENT_ID" to unassigned variable "client_id"
And I assign value "Chrome" to unassigned variable "browser"
And I assign value "xPath://input[@placeholder='Search']" to unassigned variable "JDA_Search"
And I assign value "VOICE_HOST" to unassigned variable "voice_shell_host"
And I assign value "ssh" to unassigned variable "voice_shell_protocol"
And I assign value "VOICE_USER" to unassigned variable "voice_shell_usr"
And I assign value "VOICE_PASS" to unassigned variable "voice_shell_pwd"
And I assign value "http://192.168.2.30:7000/service" to unassigned variable "server"
And I assign value "192.168.2.30:7023" to unassigned variable "rfserver"
And I assign value "http://brrcwm01:7080/rp/login" to unassigned variable "web_ui"
And I assign value "JDA_CLIENT_UI_PATH" to unassigned variable "ui_path"
#need MOCA here before any queries or MOCA steps start
Then I connect to MOCA at $server logged in as $username with password $password
Given I assign "[select to_char(sysdate,'mmddhhmii') || ltrim(to_char(cntgrp.nextval,'000000009')) tranid from dual]" to variable "tran_id_mcmd"

# Assign multiplier to wait times for slow or unresponsive networks
And I assign value 1 to unassigned variable "wait_multiplier"

## Conversion Waits
If I verify variable "small_wait" is assigned
    Then I convert string variable "small_wait" to DOUBLE variable "small_wait"
    And I assign contents of variable "small_wait" to "small"
    And I multiply variable "small_wait" by $wait_multiplier
Else I assign value 1000 to unassigned variable "small"
EndIf
And I multiply variable "small" by $wait_multiplier
If I verify variable "medium_wait" is assigned
    Then I convert string variable "medium_wait" to DOUBLE variable "medium_wait"
    And I assign contents of variable "medium_wait" to "medium"
    And I multiply variable "medium_wait" by $wait_multiplier
Else I assign value 15000 to unassigned variable "medium"
EndIf
And I multiply variable "medium" by $wait_multiplier
If I verify variable "large_wait" is assigned
    Then I convert string variable "large_wait" to DOUBLE variable "large_wait"
    And I assign contents of variable "large_wait" to "large"
    And I multiply variable "large_wait" by $wait_multiplier
Else I assign value 30000 to unassigned variable "large"
EndIf
And I multiply variable "large" by $wait_multiplier

## Terminal Waits
Given I assign 10000 to variable "cursor_wait"
Then I convert string variable "cursor_wait" to DOUBLE variable "cursor_wait"
And I multiply variable "cursor_wait" by $wait_multiplier
Given I assign 5000 to variable "screen_wait"
Then I convert string variable "screen_wait" to DOUBLE variable "screen_wait"
And I multiply variable "screen_wait" by $wait_multiplier
Given I assign 50000 to variable "long_wait"
Then I convert string variable "long_wait" to DOUBLE variable "long_wait"
And I multiply variable "long_wait" by $wait_multiplier

## Standard Wait Time Values (intended time is in ms)
Then I assign value 60 to unassigned variable "logon_wait"
And I convert string variable "logon_wait" to DOUBLE variable "logon_wait"
And I multiply variable "long_wait" by $wait_multiplier
Then I assign value 50 to unassigned variable "delay_v_short"
And I convert string variable "delay_v_short" to DOUBLE variable "delay_v_short"
And I multiply variable "delay_v_short" by $wait_multiplier
Then I assign value 100 to unassigned variable "delay_short"
And I convert string variable "delay_short" to DOUBLE variable "delay_short"
And I multiply variable "delay_short" by $wait_multiplier
Then I assign value 300 to unassigned variable "delay_med"
And I convert string variable "delay_med" to DOUBLE variable "delay_med"
And I multiply variable "delay_med" by $wait_multiplier
Then I assign value 500 to unassigned variable "delay_long"
And I convert string variable "delay_long" to DOUBLE variable "delay_long"
And I multiply variable "delay_long" by $wait_multiplier
Then I assign value 1000 to unassigned variable "delay_v_long"
And I convert string variable "delay_v_long" to DOUBLE variable "delay_v_long"
And I multiply variable "delay_v_long" by $wait_multiplier
Then I assign value 60 to unassigned variable "wait_ex_short"
And I convert string variable "wait_ex_short" to DOUBLE variable "wait_ex_short"
And I multiply variable "wait_ex_short" by $wait_multiplier
Then I assign value 500 to unassigned variable "wait_v_short"
And I convert string variable "wait_v_short" to DOUBLE variable "wait_v_short"
And I multiply variable "wait_v_short" by $wait_multiplier
Then I assign value 1000 to unassigned variable "wait_short"
And I convert string variable "wait_short" to DOUBLE variable "wait_short"
And I multiply variable "wait_short" by $wait_multiplier
Then I assign value 2000 to unassigned variable "wait_med"
And I convert string variable "wait_med" to DOUBLE variable "wait_med"
And I multiply variable "wait_med" by $wait_multiplier
Then I assign value 3000 to unassigned variable "wait_long"
And I convert string variable "wait_long" to DOUBLE variable "wait_long"
And I multiply variable "wait_long" by $wait_multiplier
Then I assign value 5000 to unassigned variable "wait_v_long"
And I convert string variable "wait_v_long" to DOUBLE variable "wait_v_long"
And I multiply variable "wait_v_long" by $wait_multiplier
Then I assign value 10000 to unassigned variable "wait_ex_long"
And I convert string variable "wait_ex_long" to DOUBLE variable "wait_ex_long"
And I multiply variable "wait_ex_long" by $wait_multiplier

Scenario: Export Environment Variables
Given I assign $devcod to MOCA environment variable "uc_cyc_devcod"
And I assign $wh_id to MOCA environment variable "uc_cyc_wh_id"
And I assign $src_wh_id to MOCA environment variable "uc_cyc_src_wh_id"
And I assign $username to MOCA environment variable "uc_cyc_username"
And I assign $vehtyp to MOCA environment variable "uc_cyc_vehtyp"
And I assign $start_loc to MOCA environment variable "uc_cyc_start_loc"
And I assign $client_id to MOCA environment variable "uc_cyc_client_id"
And I assign $rfserver to MOCA environment variable "uc_cyc_rfserver"
And I assign $server to MOCA environment variable "uc_cyc_server"