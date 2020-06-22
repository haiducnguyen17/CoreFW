*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/CampusApi.py    ${USERNAME}    ${PASSWORD}       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/AdministrationPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py      

Resource    ../../../../../resources/constants.robot

Default Tags    Event
Force Tags    SM-29651 

*** Variables ***
${CITY_NAME}    City 01
${CAMPUS_NAME}    Campus 01
${BUILDING_NAME}    Building 01
${FLOOR_NAME}    Floor 01 
${ROOM_NAME}    Room 01
${RACK_GROUP_NAME}    Rack Group 01
${RACK_NAME}    Rack 001
${SWITCH_NAME}    MNE 01
${PANEL_NAME}    Panel 01
${PANEL_NAME_2}    Panel 02
${FP_NAME}    Faceplate 01
${CARD_NAME}    Card 03
${MEDIA_CONVERTER_NAME}    Media Converter 01
${IP_ADD}    10.50.1.6 
${BLADE_ENCLOSURE_NAME}    Blade Enclosure 01
${BLADE_SERVER_NAME}    Blade Server 01   
${EVENT}    Critical Circuit Restored
${ORIGIN_HARNESS_SYNC_LOCA}    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\SyncSwitch 10.50.1.6.txt
${ORIGIN_HARNESS_DD_LOCA}    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\DiscDevicesSwitch 10.50.1.6.txt
${EDITED_HARNESS_SYNC_LOCA}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.50.1.6.txt
${EDITED_HARNESS_DD_LOCA}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\DiscDevicesSwitch 10.50.1.6.txt

*** Test Cases ***
SM-29651-03_Verify that Critical Circuit Restored event must be generated in LC circuit MNE in rack: Card port - generic panel - faceplate - DD
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${CITY_NAME}
    
    [Teardown]    Run Keyword    Close Browser
    
    [Tags]    SM-29651
    
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
# 3. Add Rack Group 01/ 1:1 Rack 001 to City 01/ Campus 01/ Building 01/ Floor 01/ Room 01 ("Rack Group" Zone Mode)
    Add City    ${SITE_NODE}    ${CITY_NAME}    
    Add Campus    ${SITE_NODE}/${CITY_NAME}     ${CAMPUS_NAME}    
    Add Building    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}     ${BUILDING_NAME}
    Add Floor    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}    Rack Groups
    Add Rack Group    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_GROUP_NAME}
    Add Rack    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}    ${RACK_NAME}    zone=New    position=1    NDD=${True}    waitForCreate=${False}
    Wait For Object Exist On Content Table    1:1 ${RACK_NAME}
    
# 4. Add to Rack 001:
    # _Generic Panel LC 01
    Add Generic Panel    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}    ${PANEL_NAME}    portType=LC
    # _MNE in pre-condition
    Add Managed Switch    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}    ${SWITCH_NAME}    ${IP_ADD}    IPv4    ${False}
    
# 5. Add LC Faceplate 01 to Room 01
    Add Faceplate    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    outletType=LC
    
# 6. Sync MNE successfully
    Synchronize Managed Switch    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADD}
    
# 7. Set critical port for:
    # _MNE 01/01
    # _Panel 01/01
    Edit Port On Content Table    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}/${CARD_NAME}    06    critical=${True}         
    Edit Port On Content Table    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    01    critical=${True}
    
# 8. Create a circuit:
    # MNE 01/01 - patched to - Panel 01/01 - cabled to - Faceplate 01/01
    Open Patching Window    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}/${CARD_NAME}
    Create Patching    patchFrom=${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}/${CARD_NAME}    patchTo=${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    portsFrom=06    portsTo=01    createWo=${False}
    
    Open Cabling Window    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}
    Create Cabling    cableFrom=${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}/01    cableTo=${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=01
    Close Cabling Window
    
# 9. DD MNE 01
    Discover Managed Switch    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${IP_ADD}
    
# 10. On the harness file, remove device and change Link Status for Switch Port 01 from Up to Down    
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${EDITED_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
# 11. Re-sync and DD Switch 01
    Synchronize Managed Switch    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${IP_ADD}
    
# 12. On the harness file, re-add device and change Link Status for Switch Port 01 from Down to Up
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
# 13. Re-sync and DD switch 01

    Synchronize Managed Switch    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${IP_ADD}
    
# 14. Observe priority event log
    # _Critical Circuit Restored event is raised
    # _Managed Port Status Changed - Link Up event should not be raised
    # _Content should be:
    # The Managed Port in a critical circuit has changed its status to Link Up:
    # Managed Port: managed port name
    # Network Equipment: MNE name
    # Location: location of MNE
    # Critical Port/s in the Circuit: show location of 1st 2nd 3rd critical port...
    # The link was down/disabled for the following period:
    # From: date/time
    # To: date/time
    Open Events Window    Priority Event Log    ${SITE_NODE}/${CITY_NAME}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUP_NAME}/1:1 ${RACK_NAME}/${SWITCH_NAME}/${CARD_NAME}
    Check Event Exist On Event Log Table    ${EVENT}
    Check Event Not Exist On Event Log Table    Managed Port Status Changed--Link Up
    Close Event Log  
    
SM-29651-04_Verify that Critical Circuit Restored event must be generated in LC circuit: MNE in room (Card/GBIC Slot/port) -> generic panel -> generic panel -> faceplate -> DD
    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\SyncSwitch 10.50.37.2.txt
    ${TC_ORIGIN_HARNESS_DD_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\DiscDevicesSwitch 10.50.37.2.txt
    ${TC_EDITED_HARNESS_SYNC_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.50.37.2.txt
    ${TC_EDITED_HARNESS_DD_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\DiscDevicesSwitch 10.50.37.2.txt
    ${TC_IP_ADD}    Set Variable    10.50.37.2
    ${TC_CARD_NAME}    Set Variable    Card 01
    ${TC_GBIC_SLOT_NAME}    Set Variable    GBIC Slot 01 

    [Setup]    Run Keywords    Delete Campus    name=${CAMPUS_NAME}
    ...    AND    Add New Campus    ${CAMPUS_NAME}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keyword    Close Browser
    Copy File    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 3. Add Campus 01/Building 01/Floor 01/Room 01/Rack 001
    Add Building    ${SITE_NODE}/${CAMPUS_NAME}     ${BUILDING_NAME}
    Add Floor    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    NDD=${True}          

    # 4. Add to Room 01:
        # _MNE 01 in pre-condition
    Add Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${SWITCH_NAME}    ${TC_IP_ADD}    IPv4    ${False}    

        # _LC Faceplate 01
    Add Faceplate    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    outletType=LC
    
    # 5. Add to Rack 001:
        # _Generic Panel LC 01
    Add Generic Panel    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}    ${PANEL_NAME}    portType=LC
        
        # _Generic Panel LC 02
    Add Generic Panel    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}    ${PANEL_NAME_2}    portType=LC
        
    # 6. Sync MNE successfully
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 7. Set critical port for:
        # _Panel 02/01
    Edit Port On Content Table    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME_2}    01    critical=${True}          

        # _Switch/Card 01/GBIC Slot 49/01
    Edit Port On Content Table    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}    01    critical=${True}     

    # 8. Create a circuit:
        # MNE 01/01 -> cabled to -> Generic Panel 01/01 -> patched to -> Panel 02/01 -> cabled to -> Faceplate 01/01
    Open Cabling Window    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Create Cabling    cableFrom=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}/01    cableTo=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    portsTo=01
    Close Cabling Window
    
    Open Patching Window    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}
    Create Patching    patchFrom=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME_2}    portsFrom=01    portsTo=01    createWo=${False}

    # 9. Sync and DD MNE 01
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 10. On the harness file, remove device and change Link Status for Switch Port 01 from Up to Down
    Copy File    ${TC_EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_EDITED_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
        
    # 11. Re-sync and DD Switch 01
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 12. On the harness file, re-add device and change Link Status for Switch Port 01 from Down to Up
    Copy File    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 13. Re-sync and DD switch 01
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 14. Observe priority event log
        # _Critical Circuit Down event is cleared
        # _Critical Circuit Restored event is raised
        # _Managed Port Status Changed -- Link Up event should not be raised
    # _Content should be:
        # The Managed Port in a critical circuit has changed its status to Link Up:
        # Managed Port: <managed port name>
        # Network Equipment: <MNE name>
        # Location: <location of MNE>
        # Critical Port/s in the Circuit: <show location of 1st, 2nd, 3rd critical port,...>
        # The link was down/disabled for the following period:
        # From: date/time
        # To: date/time
    Open Events Window    Priority Event Log
    Check Event Not Exist On Event Log Table    Critical Circuit Down 
    Check Event Not Exist On Event Log Table    Managed Port Status Changed--Link Up  
    Check Event Details On Event Log    eventDetails=The circuit containing the following managed port has been restored:_01_${TC_GBIC_SLOT_NAME}_${TC_CARD_NAME}_${SITE_NODE},${CAMPUS_NAME},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME},${SWITCH_NAME}_Critical ports in the circuit:_${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME_2}/01_${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}/01_The circuit was down for the following period:_From:_To:    	eventDescription=Critical Circuit Restored    delimiter=_
    Close Event Log
    
SM-29651-05_Verify that Critical Circuit Restored event must be generated in MPO12-MPO12 circuit: MNE in Room -> Panel -> Blade Server
    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\SyncSwitch 10.5.4.11.txt
    ${TC_ORIGIN_HARNESS_DD_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\DiscDevicesSwitch 10.5.4.11.txt
    ${TC_EDITED_HARNESS_SYNC_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.5.4.11.txt
    ${TC_EDITED_HARNESS_DD_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\DiscDevicesSwitch 10.5.4.11.txt
    ${TC_IP_ADD}    Set Variable    10.5.4.11
    ${TC_CARD_NAME}    Set Variable    Card 05
    ${TC_GBIC_SLOT_NAME}    Set Variable    GBIC Slot 01
    ${TC_WO_NAME}    Set Variable    WO_29651_05

    [Setup]    Run Keywords    Delete Campus    name=${CAMPUS_NAME}
    ...    AND    Add New Campus    ${CAMPUS_NAME}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keyword    Close Browser
    
    Copy File    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 3.  Add to Room 01: _MPO12 MNE 01 (e.g. 10.5.4.11)
    Add Building    ${SITE_NODE}/${CAMPUS_NAME}     ${BUILDING_NAME}
    Add Floor    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    NDD=${True}
    Add Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${SWITCH_NAME}    ${TC_IP_ADD}    IPv4    ${False}
    
    # 4. Add to Rack 001:
        # _MPO Generic Panel 01
        # _MPO12 Blade Server 01
    Add Generic Panel    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}    ${PANEL_NAME}    portType=MPO
    Add Blade Enclosure    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}    ${BLADE_ENCLOSURE_NAME}
    Add Blade Server    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${BLADE_ENCLOSURE_NAME}    ${BLADE_SERVER_NAME}
    Add Blade Server Port    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${BLADE_ENCLOSURE_NAME}/${BLADE_SERVER_NAME}    01    MPO12    quantity=1
    
    # 5. Sync Switch 01 successfully. Make sure Link Status for Card 05/ GBIC Slot 01/ 01 is Up (Green)
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 6. Set Critical for:
        # _Card 05/ GBIC Slot 01/ 01
    Edit Port On Content Table    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}    01    critical=${True}
    
    # 7. Create circuit:
        # Switch 01/ Card 05/ GBIC Slot 01/ 01 (MPO12-MPO12) -> cabled to -> Panel 01/01 -> patched to (MPO12-MPO12) -> Server 01/01 and complete job
        # Cable from  to Panel 01/ 01
    Open Cabling Window    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Create Cabling    Connect    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}/01    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    MPO12    Mpo12_Mpo12        portsTo=01
    Close Cabling Window
    
    Open Patching Window    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}
    Create Patching    patchFrom=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${BLADE_ENCLOSURE_NAME}/${BLADE_SERVER_NAME}    portsFrom=01    portsTo=01    mpoTab=MPO12    mpoType=Mpo12_Mpo12    createWo=${true}   clickNext=yes
    
    Create Work Order    ${TC_WO_NAME}
    
    Open Events Window    Priority Event Log
    Clear Event On Event Log    All   
    Close Event Log    

    Open Work Order Queue Window
    Complete Work Order    ${TC_WO_NAME}
    Close Work Order Queue
    
    # 8. On the harness file, remove device and change Link Status for Switch Port 01 from Up to Down
    Copy File    ${TC_EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_EDITED_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 9. Re-sync and DD Switch 01
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    ${dateDownTime} =    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 10. Observe the result
    # Critical Circuit Down event is raised
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    Critical Circuit Down
    Close Event Log
    
    # 11. On the harness file, re-add device and change Link Status for Switch Port 01 from Down to Up
    Copy File    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 12. Re-sync and DD switch 01
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    ${dateUpTime} =    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 13. Observe priority event log
            # _Critical Circuit Down event is cleared
            # _Critical Circuit Restored event is raised
            # _Managed Port Status Changed -- Link Up event should not be raised
        # Content should be:
            # The Managed Port in a critical circuit has changed its status to Link Up:
            # Managed Port: <managed port name>
            # Network Equipment: <MNE name>
            # Location: <location of MNE>
            # Critical Port/s in the Circuit: <show location of 1st, 2nd, 3rd critical port,...>
            # The link was down/disabled for the following period:
            # From: date/time
            # To: date/time
    Open Events Window    Priority Event Log
    Check Event Not Exist On Event Log Table    Critical Circuit Down 
    Check Event Not Exist On Event Log Table    Managed Port Status Changed--Link Up  
    Check Event Details On Event Log    eventDetails=The circuit containing the following managed port has been restored:_01_${TC_GBIC_SLOT_NAME}_${TC_CARD_NAME}_${SITE_NODE},${CAMPUS_NAME},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME},${SWITCH_NAME}_Critical ports in the circuit:_${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}/01_The circuit was down for the following period:_From:_${dateDownTime}_To:_${dateUpTime}    	eventDescription=Critical Circuit Restored    delimiter=_
    Close Event Log
    
SM-29651-06_Verify that Critical Circuit Restored event must be generated in MPO12-4xLC circuit: MNE in Room -> Panel -> Media Converter
    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\SyncSwitch 10.5.4.11.txt
    ${TC_ORIGIN_HARNESS_DD_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\DiscDevicesSwitch 10.5.4.11.txt
    ${TC_EDITED_HARNESS_SYNC_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.5.4.11.txt
    ${TC_EDITED_HARNESS_DD_LOCA}    Set Variable    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\DiscDevicesSwitch 10.5.4.11.txt
    ${TC_IP_ADD}    Set Variable    10.5.4.11
    ${TC_CARD_NAME}    Set Variable    Card 05
    ${TC_GBIC_SLOT_NAME}    Set Variable    GBIC Slot 01

    [Setup]    Run Keywords    Delete Campus    name=${CAMPUS_NAME}
    ...    AND    Add New Campus    ${CAMPUS_NAME}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keyword    Close Browser
    
    Copy File    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 3.  Add to Room 01: _MPO12 MNE 01 (e.g. 10.5.4.11)
    Add Building    ${SITE_NODE}/${CAMPUS_NAME}     ${BUILDING_NAME}
    Add Floor    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}    NDD=${True}
    Add Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}    ${SWITCH_NAME}    ${TC_IP_ADD}    IPv4    ${False}
    
    # 4. Add to Rack 001:
        # _LC Generic Panel 01
     Add Generic Panel    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}    ${PANEL_NAME}    portType=LC
     
        # _LC Media Converter 01
     Add Media Converter    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}    ${MEDIA_CONVERTER_NAME}    fiberType=LC    totalPorts=1  

    # 5. Sync Switch 01 successfully. Make sure Link Status for Card 05/ GBIC Slot 01/ 01 is Up (Green)
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 6. Set Critical for:
        # _Card 05/ GBIC Slot 01/ 01
    Edit Port On Content Table    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}    01    critical=${True}
    
    # 7. Create circuit:
        # Switch 01/ Card 05/ GBIC Slot 01/ 01 -> cabled to (MPO12 x 4LC) -> Generic Panel 01/01 -> patched to -> Media Converter
    Open Cabling Window    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Create Cabling    Connect    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}/01    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    MPO12    Mpo12_4xLC    portsTo=01
    Close Cabling Window
    
    Open Patching Window    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}
    Create Patching    patchFrom=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_NAME}/${MEDIA_CONVERTER_NAME}    portsFrom=01    portsTo=01 Fiber    createWo=${False}
    
    # 8. On the harness file, change Link Status for Switch Port 01 from Up to Down
    Copy File    ${TC_EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_EDITED_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 9. Re-sync switch 01
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    # 10. Observe the result
        # Critical Circuit Down event is raised
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    Critical Circuit Down
    Close Event Log
    
    # 11. On the harness file, change Link Status for Switch Port 01 from Down to Up
    Copy File    ${TC_ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${TC_ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 12. Re-sync switch 01
    Synchronize Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
    Discover Managed Switch    ${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${TC_IP_ADD}
    
        # _Critical Circuit Down event is cleared
        # _Critical Circuit Restored event is raised
        # _Managed Port Status Changed -- Link Up event should not be raised
    # _Content should be:
        # The circuit containing the following managed port has been restored:
        # 01
        # GBIC Slot 01
        # Card 05
        # Site,Building 01,Floor 01,Room 01,Switch 01
        # Critical Ports in the Circuit:
        # Site/Building 01/Floor 01/Room 01/Switch 01/Card 05/GBIC Slot 01/01
        # The circuit was down for the following period:
        # From: date/time
        # To: date/time
    Open Events Window    Priority Event Log
    Check Event Not Exist On Event Log Table    Critical Circuit Down 
    Check Event Not Exist On Event Log Table    Managed Port Status Changed--Link Up  
    Check Event Details On Event Log    eventDetails=The circuit containing the following managed port has been restored:_01_${TC_GBIC_SLOT_NAME}_${TC_CARD_NAME}_${SITE_NODE},${CAMPUS_NAME},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME},${SWITCH_NAME}_Critical ports in the circuit:_${SITE_NODE}/${CAMPUS_NAME}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${TC_CARD_NAME}/${TC_GBIC_SLOT_NAME}/01_The circuit was down for the following period:_From:_To:    	eventDescription=Critical Circuit Restored    delimiter=_
    Close Event Log