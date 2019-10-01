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
# Feature: Terminal_Inbound_Receiving.feature
#
# Functional Area: Terminal Receiving
# Related SOP/WI: ??.??-??
#
# Author: Tryon Solutions
# Cycle Version: 2.0
# JDA WMS Version: 2018.1
#
# Description: This feature is Standard LPN  Receiving
#
# Usage Instructions:
# Volume runs require MRs in the sytem AND checked into rec_locs
# The CSV must contain a volume column set to 1
#
# Regression runs require parts and enough config to deposit inventory into the receive stage location
#
# Processing will handle standard LPN flow for blind receipts, over receipts, multi-client,
# multi-wh, lot tracking, aging, qa directed
#
# Putaway Method defaults to Undirected If I verify variable is not specified in Feature or CSV
#
# Processing ends with the deposit into the rec_loc
#
############################################################
Feature: Receiving

Background: Receiving
Given I import scenarios from "Features_Bradshaw_WMD1\Environment.feature"
Given I import scenarios from "Features\Utilities\Terminal_Utilities.feature"
Given I import scenarios from "Features\Utilities\Receiving_Utilities.feature"
Given I import scenarios from "Features\Utilities\Workflow_Utilities.feature"
Then I execute scenario "Receiving - Local Data Override"
Then I execute scenario "Set Up Environment"
Then I execute scenario "Receiving - Local Data"
Then I execute scenario "Export Environment Variables"
And I "assume this Feature will only be used for vehicle types configured to hold a single load"
And I "assume there is an existing LOTNUM in the system for the item being received"
And I "assume the system is configured for the Putaway Method chosen"

After Scenario: Receiving
If I verify variable "volume" is assigned
And I verify number $volume is equal to 1
    Then I "wont clean up in the Feature"
Else I execute cleanup script for MOCA dataset "Datasets\Receiving"
EndIf

################################################
# MAIN RECEIVING SCENARIO
################################################
Scenario: Receiving
Then I execute scenario "Terminal Login"
If I verify variable "volume" is assigned
And I verify number $volume is equal to 1
    Then I execute scenario "Terminal Wait For Start"
    Then I assign "0" to variable "DONE"
EndIf
And I execute scenario "Terminal LPN Receiving Menu"
And I wait $small ms
If I verify variable "volume" is assigned
And I verify number $volume is equal to 1
    While I verify number $DONE is equal to 0
        Then I "am going to get data for this run"
        And I "pass in wh_id as the only parameter to this script"
        And I execute moca script "Features\Utilities\MSQL_Files\get_receiving_invoices.msql"
        If I assign row 0 column "invnum" to variable "invnum"
        And I assign row 0 column "trknum" to variable "trknum"
        And I assign row 0 column "prtnum" to variable "prtnum"
        And I assign row 0 column "lotnum" to variable "lotnum"
        And I assign row 0 column "rec_loc" to variable "rec_loc"
        And I assign row 0 column "rec_loc" to variable "dep_loc"
        And I verify MOCA status is 0
            Then I "create a lock on the invoice record"
            Then I assign $invnum to MOCA environment variable "uc_cyc_invnum"
            And I execute moca script "Features\Utilities\MSQL_Files\insert_receiving_lock.msql"
            If I verify MOCA status is 0
                Then I execute scenario "Receiving Detail"
                Then I "clear the lock"
                And I execute moca script "Features\Utilities\MSQL_Files\delete_receiving_lock.msql"
            Else I echo "We should continue looking because we selected 1 but the policy already existed"
                And I wait $cursor_wait ms
                And I execute scenario "ReEnter Terminal Screen"
            EndIf
        Else I echo "We have no more rows left to process for this RF"
            And I echo "Lets wait for more"
            And I wait $cursor_wait ms
            And I execute scenario "ReEnter Terminal Screen"
        EndIf
        Then I "check if the test has been ended"
        And I execute scenario "Complete Test Policy Exit Check"
    EndWhile
Else I execute MOCA dataset "Datasets\Receiving"
    And I assign $trlr_num to variable "trknum"
    And I execute scenario "Receiving Detail"
    And I press keys F1 in terminal 2 times with $delay_long ms delay
    And I execute scenario "Terminal Logout"
EndIf

################################################
# START OF FEATURE VARIABLE SETUP SCENARIOS
################################################
@wip
Scenario: Receiving - Local Data
# TRLR_NUM - This will be used as the trailer number when receiving by Trailer. If not, this will be the Receive Truck and Invoice Number
# This number can be a fabrication.
# REQUIRED - TRUE
Given I assign value "TSTRK01" to unassigned variable "trlr_num"
And I assign $trlr_num to MOCA environment variable "uc_cyc_trlr_num"

# INVNUM - This will be used as the Invoice Number when receiving by Trailer. If receiving by PO - this will not be used.
# This number can be a fabrication.
# REQUIRED - TRUE
Given I assign value "TSINV001" to unassigned variable "inv_num"
And I assign $inv_num to MOCA environment variable "uc_cyc_invnum"

# YARD_LOC - If receiving by Trailer, this is where your Trailer needs to be checked in
# This needs to be a valid and open dock door in your system
# REQUIRED - TRUE
Given I assign value "RDCK-002" to unassigned variable "yard_loc"
And I assign $yard_loc to MOCA environment variable "uc_cyc_yard_loc"

# INVTYP - This need to be a valid Invoice Type, that is assigned in your system
# REQUIRED - TRUE
Given I assign value "P" to unassigned variable "invtyp"
And I assign $invtyp to MOCA environment variable "uc_cyc_invtyp"

# PRTNUM - This needs to be a valid part number that is assigned in your system
# The part will use the default client_id assigned in Environment.feature. If you need a separate prt_client_id please define one below
# as a local data override.
# REQUIRED - TRUE
Given I assign value "SOAP-10" to unassigned variable "prtnum"
And I assign $prtnum to MOCA environment variable "uc_cyc_prtnum"

# LOTNUM - Lotnum to add to the receiving line when creating the invoice and to be used for receiving if the item is lot tracked
# REQUIRED - TRUE
Given I assign value "LOT001" to unassigned variable "lotnum"
And I assign $lotnum to MOCA environment variable "uc_cyc_lotnum"

# RCVSTS - Receiving status created on the Invoice Line being loaded
# This needs to be a valid invoice type in your system
# REQUIRED - TRUE
Given I assign value "A" to unassigned variable "rcvsts"
And I assign $rcvsts to MOCA environment variable "uc_cyc_rcvsts"

# AP_STS - Aging profile status
# This needs to be a valid status in the system
# REQUIRED - TRUE for parts with aging profiles
Given I assign value "A" to unassigned variable "ap_sts"
And I assign $ap_sts to MOCA environment variable "uc_cyc_ap_sts"

# QA_STS - QA status
# This needs to be a valid status in the system
# REQUIRED - TRUE for parts with QA status directed processing
# DEFAULT: NULL
Given I assign value "" to unassigned variable "qa_sts"
And I assign $qa_sts to MOCA environment variable "uc_cyc_qa_sts"

# EXPQTY - This can be a fabrication, but assumes simple, standard LPN receiving
# DEFAULT - Default Value is 1
# REQUIRED - TRUE
Given I assign value "50" to unassigned variable "expqty"
And I assign $expqty to MOCA environment variable "uc_cyc_expqty"

# SUPNUM - This needs to be a valid supplier, assigned in your system
# REQUIRED - TRUE
Given I assign value "DEFSUP" to unassigned variable "supnum"
And I assign $supnum to MOCA environment variable "uc_cyc_supnum"

# When using staging Putaway, this is the receiving staging lane we'll use
# This must exist in your system and be a validate receiving staging location
# REQUIRED - TRUE
Given I assign value "RCVSTG-002" to unassigned variable "rec_loc"
Given I assign value $rec_loc to unassigned variable "dep_loc"
And I assign $rec_loc to MOCA environment variable "uc_cyc_rec_loc"

# RCVQTY - quantity to receive for terminal input
# DEFAULT: 1
Given I assign value "1" to unassigned variable "rcv_qty"

# PUTAWAY_METHOD
# Terminal Option for putaway 1) Directed 2) Sorted 3) Undirected
# DEFAULT: 3
# REQUIRED - TRUE
Given I assign value "3" to unassigned variable "putaway_method"

# ASN_FLG
# Flag for asn recipts
# DEFAULT: 0
# REQUIRED - TRUE
Given I assign value 0 to unassigned variable "asn_flg"

# VALIDATE_LOC
# Location to be validated for Directed putaway
# REQUIRED - TRUE - ONLY if validating locations for directed putaway
# DEFAULT: NULL
Given I assign "" to variable "validate_loc"

# ACTCOD
# Activity code
# REQUIRED- TRUE
Given I assign value "INVRCV" to unassigned variable "actcod"

Given I assign 1500 to variable "small"

@wip
Scenario: Receiving - Local Data Override
################################################
# END OF FEATURE VARIABLE SETUP SCENARIOS
################################################