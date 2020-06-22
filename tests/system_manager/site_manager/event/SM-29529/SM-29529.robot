*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/snmp/AdmManagedPortOptionsPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py    

Default Tags    Event
Force Tags    SM-29529

*** Variables ***
${BUILDING_NAME}    Bulk_SM29529
${FLOOR_NAME}    Floor 01 
${ROOM_NAME}    Room 01
${RACK_1_NAME}    Rack 001
${RACK_2_NAME}    Rack 002    
${RACK_3_NAME}    Rack 003
${EVENT_1}    Managed Port Status Changed--Link Down
${EVENT_2}    Critical Circuit Down
${IP_ADDRESS}    10.50.1.6
${PANEL_NAME_1}        Panel 01
${PANEL_NAME_2}    Panel 02
${FACEPLATE_NAME}    Faceplate 01
${SWITCH_NAME}    Switch 01
${DD_IN_ROOM_NAME}    Device 01
${DD_IN_RACK_NAME}    Server 01
${ORIGIN_HARNESS_SYNC_LOCA}    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29529\\SyncSwitch 10.50.1.6.txt
${ORIGIN_HARNESS_DD_LOCA}    ${DIR_PRECONDITION_SNMP}\\Original\\SM_29529\\DiscDevicesSwitch 10.50.1.6.txt
${EDITED_HARNESS_SYNC_LOCA}    ${DIR_PRECONDITION_SNMP}\\Edit\\SM_29529\\SyncSwitch 10.50.1.6.txt
${TREE_NODE_RACK_1}    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:1 ${RACK_1_NAME}    
${TREE_NODE_RACK_2}    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:2 ${RACK_2_NAME}
${TREE_NODE_RACK_3}    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}/1:3 ${RACK_3_NAME}
${TREE_NODE_ROOM}    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}/${ROOM_NAME}

*** Test Cases ***
(SM-29529-01) Verify that SM will remove "Non-Critical Port Threshold (minutes) *" and "Critical Port Threshold (minutes) *" from the "Managed Port Options" page in Administration.
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    
    [Teardown]    Run Keyword    Close Browser

    # Step 1: Go to Administration > Priority Event Settings
    # Step 2: Observe the event in event list
    Select Main Menu    Administration/SNMP    Managed Port Options   
    Check Label Not Exist On Managed Port Options    Non-Critical Port Threshold (minutes) *
    Check Label Not Exist On Managed Port Options    Critical Port Threshold (minutes) *
    
(Bulk-29529-02-05) Verify that the "Managed Port Status Changed--Link Down" event generated when SM detects a managed port is down
    [Setup]    Run Keywords    Delete Building    name=${BUILDING_NAME}
    ...    AND    Add New Building    name=${BUILDING_NAME}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}    
    
    [Teardown]    Run Keywords    Delete Building    name=${BUILDING_NAME}    
    ...    AND    Close Browser
     
    [Tags]    Sanity
    
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 1. Prepare a real Switch 01 (e.g. 192.168.171.237) or harness Switch with some ports are Up
    # 2. Add Buidling 01/Floor 01/ Room 01/Rack 001, Rack 002, Rack 003 (NDD)
    # 3. Add
    # _ 2 RJ-45 Panels to Rack 002
    # _ RJ-45 Facepate 01 to Room 01
    # _ RJ-45 Panel 01 to Rack 003
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${TREE_NODE_ROOM}    ${RACK_1_NAME}    zone=1    position=1    NDD=${True}
    Add Rack    ${TREE_NODE_ROOM}    ${RACK_2_NAME}    zone=1    position=2    NDD=${True}
    Add Rack    ${TREE_NODE_ROOM}    ${RACK_3_NAME}    zone=1    position=3    NDD=${True}
    Add Generic Panel    ${TREE_NODE_RACK_2}    ${PANEL_NAME_1}    quantity=2
    Add Generic Panel    ${TREE_NODE_RACK_3}    ${PANEL_NAME_1}        
    Add Faceplate    ${TREE_NODE_ROOM}    ${FACEPLATE_NAME}
    
    # 4. Add Switch 01 in Step 1 to Room 01 then sync it successfully
    Add Managed Switch    ${TREE_NODE_ROOM}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_ROOM}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
        
    # 5. Notice there are some Up ports
    # 6. Disconnect 1 Switch port:
    # _If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    
    # 7. Synchronize Switch again and Observe port status is changed
    # * Step 7: Port status changes to Down
    Synchronize Managed Switch    ${TREE_NODE_ROOM}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_ROOM}/${SWITCH_NAME}
    Wait For Port Color On Content Table    01    yellow        
    Check Switch Port Color On Content Table    01    yellow
     
    # 8. Observe event is generated in Event Log
    # * Step 8: "Managed Port Status Changed--Link Down" event is generated in Event Log with details
    Open Events Window    Event Log for Object    ${TREE_NODE_ROOM}
    Check Event Details On Event Log    eventDetails=The link for the following managed port is down:/01/${SWITCH_NAME}/${ROOM_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME}    	eventDescription=${EVENT_1}        
    Close Event Log
    Delete Tree Node On Site Manager    ${TREE_NODE_ROOM}/${SWITCH_NAME}
    
    # 9. Add Switch 01 in Step 1 to Rack 001 then sync it successfully
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Add Managed Switch    ${TREE_NODE_RACK_1}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_RACK_1}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    
    # 10. Disconnect 1 Switch port:
    # _If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}

    # 11. Synchronize Switch again and Observe port status is changed
    # Port status changes to Down
    Synchronize Managed Switch    ${TREE_NODE_RACK_1}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_RACK_1}/${SWITCH_NAME}
    Wait For Port Color On Content Table    01    yellow    
    Check Switch Port Color On Content Table    01    yellow
    
    # 12. Observe event is generated in Event Log
    # * "Managed Port Status Changed--Link Down" event is generated in Event Log
    # _Event details:
    # "The link for the following managed port is down:
    # [port]
    # [Switch name]
    # [Location]
    # [Location Link]"
    Open Events Window    Event Log for Object    ${TREE_NODE_RACK_1}
    Check Event Details On Event Log    eventDetails=The link for the following managed port is down:/01/${SWITCH_NAME}/1:1 ${RACK_1_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME}    	eventDescription=${EVENT_1}        
    Close Event Log
    Delete Tree Node On Site Manager    ${TREE_NODE_RACK_1}
    
    # 13. Add Switch 01 in Step 1 to Rack 002 then sync it successfully
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Add Managed Switch    ${TREE_NODE_RACK_2}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_RACK_2}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}

    # 14. Create Cabling from:
    # _ Panel 01/01 to Panel 02/01
    Open Cabling Window    ${TREE_NODE_RACK_2}/${PANEL_NAME_1}
    Create Cabling    cableFrom=${TREE_NODE_RACK_2}/${PANEL_NAME_1}/01    cableTo=${TREE_NODE_RACK_2}/${PANEL_NAME_2}    portsTo=01
    Close Cabling Window
    
    # 15. Create Patching from:
    # _ Switch 01/01 to Panel 01/ 01
    Open Patching Window    ${TREE_NODE_RACK_2}/${PANEL_NAME_2}
    Create Patching    patchFrom=${TREE_NODE_RACK_2}/${PANEL_NAME_2}    patchTo=${TREE_NODE_RACK_2}/${SWITCH_NAME}    portsFrom=01    portsTo=01    createWo=${False}    

    # 16. DD Switch 01 successfully with DD in Rack is generated
    Discover Managed Switch    ${TREE_NODE_RACK_2}/${SWITCH_NAME}
    Open Synchronize Status Window    
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_RACK_2}
    Wait For Object Exist On Content Table With Refresh    ${DD_IN_RACK_NAME}
    Check Object Exist On Content Table    objectName=${DD_IN_RACK_NAME} 
    
    # 17. Disconnect Switch port 01:
    # If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    
    # 18. Synchronize Switch again and Observe port status is changed
    # Port status changes to Down
    Synchronize Managed Switch    ${TREE_NODE_RACK_2}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_RACK_2}/${SWITCH_NAME}
    Wait For Port Color On Content Table    01    yellow    
    Check Switch Port Color On Content Table    01    yellow
    
    # 19. Observe event is generated in Event Log
    # * Step 10: "Managed Port Status Changed--Link Down" event is generated in Event Log
    # _Event details:
    # "The link for the following managed port is down:
    # [port]
    # [Switch name]
    # [Location]
    # [Location Link]"
    Open Events Window    Event Log for Object    ${TREE_NODE_RACK_2}
    Check Event Details On Event Log    eventDetails=The link for the following managed port is down:/01/${SWITCH_NAME}/1:2 ${RACK_2_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME}    	eventDescription=${EVENT_1}        
    Close Event Log
    Delete Tree Node On Site Manager    ${TREE_NODE_RACK_2}
    
    # 20. Add Switch 01 in Step 1 to Rack 003 then sync it successfully
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Add Managed Switch    ${TREE_NODE_RACK_3}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_RACK_3}/${SWITCH_NAME}  
    Open Synchronize Status Window  
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    
    # 21. Create Cabling from:
    # _ Panel 01/01 to Faceplate 01/01
    Open Cabling Window    ${TREE_NODE_RACK_3}/${PANEL_NAME_1}
    Create Cabling    cableFrom=${TREE_NODE_RACK_3}/${PANEL_NAME_1}/01    cableTo=${TREE_NODE_ROOM}/${FACEPLATE_NAME}    portsTo=01
    Close Cabling Window
    
    # 22. Create Patching from:
    # _ Switch 01/01 to Panel 01/ 01
    Open Patching Window    ${TREE_NODE_RACK_3}/${PANEL_NAME_1}
    Create Patching    patchFrom=${TREE_NODE_RACK_3}/${PANEL_NAME_1}    patchTo=${TREE_NODE_RACK_3}/${SWITCH_NAME}    portsFrom=01    portsTo=01    createWo=no

    # 23. DD Switch 01 successfully with DD in Room is generated
    Discover Managed Switch    ${TREE_NODE_RACK_3}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_ROOM}
    Wait For Object Exist On Content Table With Refresh    ${DD_IN_ROOM_NAME}
    Check Object Exist On Content Table    objectName=${DD_IN_ROOM_NAME}
    
    # 24. Disconnect Switch port 01:
    # _If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    
    # 25. Synchronize Switch again and Observe port status is changed
    # 26`. Observe event is generated in Event Log
    Synchronize Managed Switch    ${TREE_NODE_RACK_3}/${SWITCH_NAME}   
    Open Synchronize Status Window 
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Open Events Window    Event Log for Object    ${TREE_NODE_RACK_3}
    Check Event Details On Event Log    eventDetails=The link for the following managed port is down:/01/${SWITCH_NAME}/1:3 ${RACK_3_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME}    	eventDescription=${EVENT_1}        
    Close Event Log

(Bulk-29529-06-09) Verify that the "Critical Circuit Down" event generated when SM detects a managed port is down if this port is marked critical
    [Setup]    Run Keywords    Delete Building    name=${BUILDING_NAME}
    ...    AND    Add New Building    name=${BUILDING_NAME}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}     
    
    [Teardown]    Run Keywords    Delete Building    name=${BUILDING_NAME}    
    ...    AND    Close Browser
    
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Copy File    ${ORIGIN_HARNESS_DD_LOCA}    ${TEST_DATA_PATH}
    
    # 1. Prepare a real Switch 01 (e.g. 192.168.171.237) or harness Switch with some ports are Up
    # 2. Add Buidling 01/Floor 01/ Room 01/Rack 001, Rack 002, Rack 003 (NDD)
    # 3. Add
    # _ 2 RJ-45 Panels to Rack 002
    # _ RJ-45 Facepate 01 to Room 01
    # _  RJ-45 Panel 01 to Rack 003
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${TREE_NODE_ROOM}    ${RACK_1_NAME}    zone=1    position=1    NDD=${True}
    Add Rack    ${TREE_NODE_ROOM}    ${RACK_2_NAME}    zone=1    position=2    NDD=${True}
    Add Rack    ${TREE_NODE_ROOM}    ${RACK_3_NAME}    zone=1    position=3    NDD=${True}
    Add Generic Panel    ${TREE_NODE_RACK_2}    ${PANEL_NAME_1}    quantity=2
    Add Generic Panel    ${TREE_NODE_RACK_3}    ${PANEL_NAME_1}       
    Add Faceplate    ${TREE_NODE_ROOM}    ${FACEPLATE_NAME}
    
    # # 4. Add Switch 01 in Step 1 to Room 01 then sync it successfully
    Add Managed Switch    ${TREE_NODE_ROOM}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_ROOM}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Edit Port On Content Table    ${TREE_NODE_ROOM}/${SWITCH_NAME}    all    critical=${True}
        
    # 5. Notice there are some Up ports, then mark critical for this Up port
    # 6. Disconnect 1 Switch port:
    # _If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    
    # 7. Synchronize Switch again and Observe port status is changed
    # * Step 7: Port status changes to Down
    Synchronize Managed Switch    ${TREE_NODE_ROOM}/${SWITCH_NAME}   
    Open Synchronize Status Window 
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_ROOM}/${SWITCH_NAME}
    Wait For Port Color On Content Table    01    yellow    
    Check Switch Port Color On Content Table    01    yellow
     
    # 8. Observe event is generated in Event Log
    # * Step 8: "Managed Port Status Changed--Link Down" event is generated in Event Log with details
    Open Events Window    Event Log for Object    ${TREE_NODE_ROOM}
    Check Event Details On Event Log    eventDetails=The circuit containing the following managed port is down:/01/${SWITCH_NAME}/${ROOM_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME}    	eventDescription=${EVENT_2}        
    Close Event Log
    Delete Tree Node On Site Manager    ${TREE_NODE_ROOM}/${SWITCH_NAME}
    
    # 9. Add Switch 01 in Step 1 to Rack 001 then sync it successfully
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Add Managed Switch    ${TREE_NODE_RACK_1}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_RACK_1}/${SWITCH_NAME}   
    Open Synchronize Status Window 
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Wait For Object Exist On Content Table    01    
    Edit Port On Content Table    ${TREE_NODE_RACK_1}/${SWITCH_NAME}    01    critical=${True}
    Wait For Property On Properties Pane    Critical    Yes
    
    # 10. Disconnect 1 Switch port:
    # _If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}

    # 11. Synchronize Switch again and Observe port status is changed
    # Port status changes to Down
    Synchronize Managed Switch    ${TREE_NODE_RACK_1}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_RACK_1}/${SWITCH_NAME}
    Wait For Port Color On Content Table    01    yellow    
    Check Switch Port Color On Content Table    01    yellow
    
    # 12. Observe event is generated in Event Log
    # * "Managed Port Status Changed--Link Down" event is generated in Event Log
    # _Event details:
    # "The circuit containing the following managed port is down:
    # [port]
    # [Switch name]
    # [Location]
    # [Location Link]"
    Open Events Window    Event Log for Object    ${TREE_NODE_RACK_1}
    Check Event Details On Event Log    eventDetails=The circuit containing the following managed port is down:/01/${SWITCH_NAME}/1:1 ${RACK_1_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME}    	eventDescription=${EVENT_2}        
    Close Event Log
    Delete Tree Node On Site Manager    ${TREE_NODE_RACK_1}
    
    # 13. Add Switch 01 in Step 1 to Rack 002 then sync it successfully
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Add Managed Switch    ${TREE_NODE_RACK_2}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_RACK_2}/${SWITCH_NAME}  
    Open Synchronize Status Window  
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Wait For Object Exist On Content Table    01
    Edit Port On Content Table    ${TREE_NODE_RACK_2}/${SWITCH_NAME}    all    critical=${True}

    # 14. Create Cabling from:
    # _ Panel 01/01 to Panel 02/01
    Open Cabling Window    ${TREE_NODE_RACK_2}/${PANEL_NAME_1}
    Create Cabling    cableFrom=${TREE_NODE_RACK_2}/${PANEL_NAME_1}/01    cableTo=${TREE_NODE_RACK_2}/${PANEL_NAME_2}    portsTo=01
    Close Cabling Window
    
    # 15. Create Patching from:
    # _ Switch 01/01 to Panel 01/ 01
    Open Patching Window    ${TREE_NODE_RACK_2}/${PANEL_NAME_2}
    Create Patching    patchFrom=${TREE_NODE_RACK_2}/${PANEL_NAME_2}    patchTo=${TREE_NODE_RACK_2}/${SWITCH_NAME}    portsFrom=01    portsTo=01    createWo=no

    # 16. DD Switch 01 successfully with DD in Rack is generated
    Discover Managed Switch    ${TREE_NODE_RACK_2}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_RACK_2}
    Wait For Object Exist On Content Table With Refresh    ${DD_IN_RACK_NAME}
    Check Object Exist On Content Table    objectName=${DD_IN_RACK_NAME}
    
    # 17. Disconnect Switch port 01:
    # If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    
    # 18. Synchronize Switch again and Observe port status is changed
    # Port status changes to Down
    Synchronize Managed Switch    ${TREE_NODE_RACK_2}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_RACK_2}/${SWITCH_NAME}
    Wait For Port Color On Content Table    01    yellow    
    Check Switch Port Color On Content Table    01    yellow
    
    # 19. Observe event is generated in Event Log
    # * Step 10: "Managed Port Status Changed--Link Down" event is generated in Event Log
    # _Event details:
    # "The circuit containing the following managed port is down:
    # [port]
    # [Switch name]
    # [Location]
    # [Location Link]"
    Open Events Window    Event Log for Object    ${TREE_NODE_RACK_2}
    Check Event Details On Event Log    eventDetails=The circuit containing the following managed port is down:/01/${SWITCH_NAME}/1:2 ${RACK_2_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME}    eventDescription=${EVENT_2}    
    Close Event Log
    Delete Tree Node On Site Manager    ${TREE_NODE_RACK_2}
    
    # 20. Add Switch 01 in Step 1 to Rack 003 then sync it successfully
    Copy File    ${ORIGIN_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    Add Managed Switch    ${TREE_NODE_RACK_3}    ${SWITCH_NAME}    ${IP_ADDRESS}    IPv4    ${False}
    Synchronize Managed Switch    ${TREE_NODE_RACK_3}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Wait For Object Exist On Content Table    01
    Edit Port On Content Table    ${TREE_NODE_RACK_3}/${SWITCH_NAME}    all    critical=${True}
    
    # 21. Create Cabling from:
    # _ Panel 01/01 to Faceplate 01/01
    Open Cabling Window    ${TREE_NODE_RACK_3}/${PANEL_NAME_1}
    Create Cabling    cableFrom=${TREE_NODE_RACK_3}/${PANEL_NAME_1}/01    cableTo=${TREE_NODE_ROOM}/${FACEPLATE_NAME}    portsTo=01
    Close Cabling Window
    
    # 22. Create Patching from:
    # _ Switch 01/01 to Panel 01/ 01
    Open Patching Window    ${TREE_NODE_RACK_3}/${PANEL_NAME_1}
    Create Patching    patchFrom=${TREE_NODE_RACK_3}/${PANEL_NAME_1}    patchTo=${TREE_NODE_RACK_3}/${SWITCH_NAME}    portsFrom=01    portsTo=01    createWo=no

    # 23. DD Switch 01 successfully with DD in Room is generated
    Discover Managed Switch    ${TREE_NODE_RACK_3}/${SWITCH_NAME}    
    Open Synchronize Status Window
    Wait Until Discover Device Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Click Tree Node On Site Manager    ${TREE_NODE_ROOM}    
    Wait For Object Exist On Content Table With Refresh    ${DD_IN_ROOM_NAME}
    Check Object Exist On Content Table    objectName=${DD_IN_ROOM_NAME}
    
    # 24. Disconnect Switch port 01:
    # _If using real Switch: unplug 1 port out of Switch
    # _if using harness Switch: edit harness file to change port to Down
    Copy File    ${EDITED_HARNESS_SYNC_LOCA}    ${TEST_DATA_PATH}
    
    # 25. Synchronize Switch again and Observe port status is changed
    # 26`. Observe event is generated in Event Log
    Synchronize Managed Switch    ${TREE_NODE_RACK_3}/${SWITCH_NAME}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_NAME}    ${IP_ADDRESS}
    Open Events Window    Event Log for Object    ${TREE_NODE_RACK_3}
    Check Event Details On Event Log    eventDetails=The circuit containing the following managed port is down:/01/${SWITCH_NAME}/1:3 ${RACK_3_NAME}/${SITE_NODE},${BUILDING_NAME},${FLOOR_NAME},${ROOM_NAME}    eventDescription=${EVENT_2}
    Close Event Log
