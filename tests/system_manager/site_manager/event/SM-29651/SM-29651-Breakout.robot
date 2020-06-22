*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/AdministrationPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py    

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
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${FP_NAME}    Faceplate 01
${CP_NAME}    Consolidation Point 01
${CARD_NAME}    Card 01
${GBIC_SLOT_1}    GBIC Slot 01
${GBIC_SLOT_49}    GBIC Slot 49
${SPLICE_NAME}    Splice Enclosure 01
${SPLICE_TRAY_NAME}    Tray 01

${IP_ADD}    10.50.1.6    
${EVENT}    Critical Circuit Restored
${EVENT_CIRCUIT_DOWN}    Critical Circuit Down
${EVENT_LINK_UP}    Managed Port Status Changed--Link Up
${ORIGIN_HARNESS_SYNC_LOCA}    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\SyncSwitch 10.50.1.6.txt
${ORIGIN_HARNESS_DD_LOCA}    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\DiscDevicesSwitch 10.50.1.6.txt
${EDITED_HARNESS_SYNC_LOCA}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.50.1.6.txt
${EDITED_HARNESS_DD_LOCA}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\DiscDevicesSwitch 10.50.1.6.txt

*** Test Cases ***
SM-29651-10_Verify that Critical Circuit Restored event must be generated in MPO24-12xLC circuit: MNE in room -> panel -> CP
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM_29651_10
    ...    AND    Set Test Variable    ${floor_name}    Floor 01
    ...    AND    Set Test Variable    ${room_name}    Room 01
    ...    AND    Set Test Variable    ${rack_name}    Rack 001
    ...    AND    Set Test Variable    ${ip_address}    10.5.6.198
    ...    AND    Set Test Variable    ${origin_harness_sync_loca}    ${DIR_PRECONDITION_SNMP}\\Original\\MPO24 with Device\\SyncSwitch 10.5.6.198.txt
    ...    AND    Set Test Variable    ${edit_harness_sync_loca}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.5.6.198.txt
    ...    AND    Set Test Variable    ${tree_node_room}    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}
    ...    AND    Set Test Variable    ${tree_node_rack}    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}/1:1 ${rack_name}
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building    name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    

    [Teardown]    Run Keywords    Delete Building    name=${building_name}
    ...    AND    Close Browser

    Copy File    ${origin_harness_sync_loca}    ${TEST_DATA_PATH}
    
    # * On SM:
    # 2. Add Building 01/Floor 01/Room 01/Rack 001
    Add Floor    ${SITE_NODE}/${building_name}    ${floor_name}
    Add Room    ${SITE_NODE}/${building_name}/${floor_name}    ${room_name}
    Add Rack    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}    ${rack_name}
    
    # 3. Add to Room 01:
    # _LC CP 01
    # _MNE 01 in pre-condition
    Add Managed Switch    ${tree_node_room}    ${SWITCH_NAME}    ${ip_address}    IPv4    ${False} 
    Add Consolidation Point    ${tree_node_room}    ${CP_NAME}    portType=LC    
   
    # 4. Add to Rack 001:
    # _Generic Panel LC 01
    # _Generic Panel LC 02
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=LC    quantity=2

    # 5. Sync MNE successfully
    Synchronize Managed Switch    ${tree_node_room}    ${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}
    
    # 6. Set critical port for MNE 01/${GBIC_SLOT_49}/01
    Edit Port On Content Table    ${tree_node_room}/${SWITCH_NAME}/${GBIC_SLOT_49}    01    critical=${True}        

    # 7. Create a circuit:
    # MNE 01/${GBIC_SLOT_49}/01 -> cabled (MPO24-12xLC) -> Panel 01/01 -> patched to -> Panel 02/01 -> cabled to -> CP   
    Open Cabling Window    ${tree_node_room}
    Create Cabling    Connect    ${tree_node_room}/${SWITCH_NAME}/${GBIC_SLOT_49}/01    ${tree_node_rack}/${PANEL_NAME_1}    ${MPO24}    Mpo24_12xLC    portsTo=01
    Close Cabling Window
    
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_2}    portsFrom=01    portsTo=01    createWo=${False}
    
    Open Cabling Window    ${tree_node_room}
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_NAME_2}/01    ${tree_node_room}/${CP_NAME}    ${MPO24}    portsTo=01
    Close Cabling Window
    
    # 8. On the harness file, change Link Status for Switch Port 01 from Up to Down
    Copy File    ${edit_harness_sync_loca}    ${TEST_DATA_PATH}
    
    # 9. Re-sync the switch and observe priority event
    Synchronize Managed Switch    ${tree_node_room}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}
    
    # Critical Circuit Down event is generated
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_CIRCUIT_DOWN}
    Close Event Log    
    
    # 10. On the harness file, change Link Status for Switch Port 01 from Down to Up
    Copy File    ${origin_harness_sync_loca}    ${TEST_DATA_PATH}
    
    # 11. Re-sync the switch
    Synchronize Managed Switch    ${tree_node_room}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}

    # 12. Observe priority event
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT}
    Check Event Not Exist On Event Log Table    ${EVENT_CIRCUIT_DOWN}
    Check Event Not Exist On Event Log Table    ${EVENT_LINK_UP}
    Check Event Details On Event Log    The circuit containing the following managed port has been restored:;01;${GBIC_SLOT_49};${SWITCH_NAME};${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME};Critical ports in the circuit:;${tree_node_room}/${SWITCH_NAME}/${GBIC_SLOT_49}/01;The circuit was down for the following period:;From:;To:     ${EVENT}    delimiter=;
    
    # 13. Click Locate icon in Priority Event window and observe
    # MNE 01/GBIC Slot 01/01 is selected in Content pane
    Locate Event On Event Log    ${EVENT}
    Close Event Log
    Check Tree Node Selected On Site Manager    ${tree_node_room}/${SWITCH_NAME}/${GBIC_SLOT_49}    
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01
    
SM-29651-09_Verify that Critical Circuit Restored event must be generated in MPO12-2xMPO24 circuit: MNE in rack -> generic panel
    [Setup]    Run Keywords    Set Test Variable    ${cable_vault_name}    SM_29651_09
    ...    AND    Set Test Variable    ${rack_name}    Rack 001
    ...    AND    Set Test Variable    ${ip_address}    10.5.6.198
    ...    AND    Set Test Variable    ${origin_harness_sync_loca}    ${DIR_PRECONDITION_SNMP}\\Original\\MPO24 with Device\\SyncSwitch 10.5.6.198.txt
    ...    AND    Set Test Variable    ${edit_harness_sync_loca}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.5.6.198.txt
    ...    AND    Set Test Variable    ${tree_node_rack}    ${SITE_NODE}/${cable_vault_name}/1:1 ${rack_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${cable_vault_name}

    [Teardown]    Run Keywords    Select Main Menu    ${Site Manager}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name}    
    ...    AND    Close Browser
    
    Copy File    ${origin_harness_sync_loca}    ${TEST_DATA_PATH}

    # * On SM:
    # 2. Add to Cable Vault 01/Rack 001
    # _MPO24 MNE 01 (e.g. 10.5.6.198) 
    # _MPO Generic Panel 01
    Add Cable Vault    ${SITE_NODE}    ${cable_vault_name}     
    Add Rack    ${SITE_NODE}/${cable_vault_name}    ${rack_name}     
    Add Managed Switch    ${tree_node_rack}    ${SWITCH_NAME}    ${ip_address}    IPv4    ${False}  
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=MPO   
   
    # 3. Sync Switch 01 successfully. Make sure Link Status for ${GBIC_SLOT_49}/ 01 is Up (Green)
    Synchronize Managed Switch    ${tree_node_rack}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_NAME}/${GBIC_SLOT_49}
    Check Switch Port Color On Content Table    01    green
    
    # 4. Set critical port for MNE 01/${GBIC_SLOT_49}/01
    Edit Port On Content Table    ${tree_node_rack}/${SWITCH_NAME}/${GBIC_SLOT_49}    01    critical=${True}        

    # 5. Create a circuit:
    # Generic Panel 01/01-02 ->  patched to (MPO12 x 2MPO24) -> Switch 01/ Card 05/ GBIC Slot 01/ 01
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${SWITCH_NAME}/${GBIC_SLOT_49}    mpoTab=${MPO12}    mpoType=Mpo12_2xMpo12    mpoBranches=B1,B2    portsFrom=01,02    portsTo=01    createWo=${False}
    
    # 6. On the harness file, change Link Status for Switch Port 01 from Up to Down
    Copy File    ${edit_harness_sync_loca}    ${TEST_DATA_PATH}
    
    # 7. Re-sync the switch
    # 8. Observe the result
    # Critical Circuit Down event is generated
    Synchronize Managed Switch    ${tree_node_rack}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}
    
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_CIRCUIT_DOWN}
    Close Event Log    
    
    # 9. On the harness file, change Link Status for Switch Port 01 from Down to Up
    Copy File    ${origin_harness_sync_loca}    ${TEST_DATA_PATH}
    
    # 10. Re-sync the switch
    Synchronize Managed Switch    ${tree_node_rack}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}

    # 11. Observe the result
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT}
    Check Event Not Exist On Event Log Table    ${EVENT_CIRCUIT_DOWN}
    Check Event Not Exist On Event Log Table    ${EVENT_LINK_UP}
    Check Event Details On Event Log    The circuit containing the following managed port has been restored:;01;${GBIC_SLOT_49};${SWITCH_NAME};${SITE_NODE},${cable_vault_name},1:1 ${RACK_NAME};Critical ports in the circuit:;${tree_node_rack}/${SWITCH_NAME}/${GBIC_SLOT_49}/01;The circuit was down for the following period:;From:;To:     ${EVENT}    delimiter=;
    Close Event Log
    
SM-29651-07_Verify that Critical Circuit Restored event must be generated in MPO12-6xLC circuit: MNE in room -> Generic Panel -> Generic Panel -> Splice
   [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM_29651_07
    ...    AND    Set Test Variable    ${floor_name}    Floor 01
    ...    AND    Set Test Variable    ${room_name}    Room 01
    ...    AND    Set Test Variable    ${rack_name}    Rack 001
    ...    AND    Set Test Variable    ${ip_address}    10.50.37.2
    ...    AND    Set Test Variable    ${origin_harness_sync_loca}    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29651\\SyncSwitch 10.50.37.2.txt
    ...    AND    Set Test Variable    ${edit_harness_sync_loca}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29651\\SyncSwitch 10.50.37.2.txt
    ...    AND    Set Test Variable    ${tree_node_room}    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}
    ...    AND    Set Test Variable    ${tree_node_rack}    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}/1:1 ${rack_name}
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Add New Building    name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD} 

    [Teardown]    Run Keywords    Delete Building    name=${building_name}
    ...    AND    Close Browser
    
    [Tags]    Sanity

    Copy File    ${origin_harness_sync_loca}    ${TEST_DATA_PATH}

    # * On SM:
    # 3. Add to Room 01: 
    # _LC MNE 01 (e.g. 10.50.37.2) 
    Add Floor    ${SITE_NODE}/${building_name}    ${floor_name}
    Add Room    ${SITE_NODE}/${building_name}/${floor_name}    ${room_name}
    Add Rack    ${SITE_NODE}/${building_name}/${floor_name}/${room_name}    ${rack_name}
    Add Managed Switch    ${tree_node_room}    ${SWITCH_NAME}    ${ip_address}    IPv4    ${False} 
    
    # 4. Add to Rack 001:
    #_LC Generic Panel 01
    # _MPO Generic Panel 02
    # _Fiber Splice
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=${LC}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${MPO}
    Add Splice Enclosure    ${tree_node_rack}    ${SPLICE_NAME}
    Add Splice Tray    ${tree_node_rack}/${SPLICE_NAME}    ${SPLICE_TRAY_NAME}    spliceType=Fiber       
    
    # 5. Sync MNE successfully
    Synchronize Managed Switch    ${tree_node_room}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}
    
    # 6. Set critical port for MNE 01/${GBIC_SLOT_49}/01
    Edit Port On Content Table    ${tree_node_room}/${SWITCH_NAME}/${CARD_NAME}/${GBIC_SLOT_1}    01    critical=${True}        

    # 7. Create a circuit:
    # Splice 01 In -> cabled to -> Generic Panel 01/01 -> patched to (MPO12-6xLC) -> Generic Panel 02/01 -> cabled to (MPO12-6xLC) -> Switch 01/ Card 01/ GBIC Slot 49/ 01  
    Open Cabling Window    ${tree_node_room}
    Create Cabling    Connect    ${tree_node_rack}/${SPLICE_NAME}/${SPLICE_TRAY_NAME}/01 In    ${tree_node_rack}/${PANEL_NAME_1}    portsTo=01
    Close Cabling Window
    
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_2}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_2}    patchTo=${tree_node_rack}/${PANEL_NAME_1}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=A1-2    portsFrom=01    portsTo=01    createWo=${False}
    
    Open Cabling Window    ${tree_node_room}
    Create Cabling    Connect    ${tree_node_rack}/${PANEL_NAME_2}/01    ${tree_node_room}/${SWITCH_NAME}/${CARD_NAME}/${GBIC_SLOT_1}    ${MPO12}    ${Mpo12_6xLC}    A1-2   portsTo=01
    Close Cabling Window

    # 8. On the harness file, change Link Status for Switch Port 01 from Up to Down
    Copy File    ${edit_harness_sync_loca}    ${TEST_DATA_PATH}
    
    # 9. Re-sync the switch and observe priority event
    # Critical Circuit Down event is generated
    Synchronize Managed Switch    ${tree_node_room}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}
    
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_CIRCUIT_DOWN}
    Close Event Log    
    
    # 10. On the harness file, change Link Status for Switch Port 01 from Down to Up
    Copy File    ${origin_harness_sync_loca}    ${TEST_DATA_PATH}
    
    # 11. Re-sync the switch
    Synchronize Managed Switch    ${tree_node_room}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${ip_address}

    # 12. Observe priority event
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT}
    Check Event Not Exist On Event Log Table    ${EVENT_CIRCUIT_DOWN}
    Check Event Not Exist On Event Log Table    ${EVENT_LINK_UP}
    Check Event Details On Event Log    The circuit containing the following managed port has been restored:;01;${GBIC_SLOT_1};${CARD_NAME};${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME},${SWITCH_NAME};Critical ports in the circuit:;${tree_node_room}/${SWITCH_NAME}/${CARD_NAME}/${GBIC_SLOT_1}/01;The circuit was down for the following period:;From:;To:     ${EVENT}    delimiter=;
    
    # 13. Click Locate icon in Priority Event window and observe
    # MNE 01/GBIC Slot 01/01 is selected in Content pane
    Locate Event On Event Log    ${EVENT}
    Close Event Log
    Check Tree Node Selected On Site Manager    ${tree_node_room}/${SWITCH_NAME}/${GBIC_SLOT_1}    
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01