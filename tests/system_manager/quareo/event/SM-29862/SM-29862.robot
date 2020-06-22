*** Settings ***
Resource    ../../../../../resources/icons_constants.robot
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/SimulatorApi.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py  
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/history/circuit_history/CircuitHistoryPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/quareo_simulator/QuareoDevicePage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/synchronization/SynchronizationPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/quareo_unmanaged_connections/QuareoUnmanagedConnectionsPage${PLATFORM}.py    

Default Tags    Quareo Event
Force Tags    SM-29862

*** Variables ***
${FLOOR_NAME}    Floor 01
${RACK_NAME}    Rack 01
${ROOM_NAME}    Room 01
${PANEL_NAME}    Panel 01
${POSITION_RACK_NAME}    1:1 Rack 01
${RACK_GROUPS}    Rack Groups
${RACK_GROUPS_NAME}    Rack Group 01
${DEVICE_01}    Device 01
${DEVICE_02}    Device 02
${MODULE_01}    Module 01
${EVENT_DESCRIPTION}    Unscheduled Patching Change to Critical Circuit
${UNKNOWN_EQUITMENT}    Unknown equipment
${SWITCH_01}    Switch 01
${MODULE_01_PASS-THROUGH}    Module 01 (Pass-Through)
${SERVER_01}    Server 01
${TEMPLATE}    Template
${EVENT_ADDED_DETAIL}    The following connection was added and affects a critical circuit:
${EVENT_REMOVED_DETAIL}    The following connection was removed and affects a critical circuit:
${EVENT_PORT_01}    Port 1:
${EVENT_PORT_02}    Port 2/Device:
${EVENT_CP}    Critical ports in the circuit:
${DEVICE_PORT_01}    01
${DEVICE_PORT_02}    02

*** Test Cases ***
SM-29862_01_02_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit:
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29862_01
    ...    AND    Set Test Variable    ${ip_address_01}    1.1.1.1
    ...    AND    Set Test Variable    ${ip_address_02}    2.2.2.2
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    [Tags]    Sanity
    
    # Panel (RJ-45, Critical) -> cabled to -> Quareo Q2000 24 port (Critical, Rear Static Port) -> patched to -> Unknown equipment
	# _Add devices in Simulator with un-populate data:
	# Device 01: Q2000 1U (without populating data)
	# Devuce 02: Q2000 2U (without populating data)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${Q2000}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${Q2000}    capacityUs=2
	${moduleID_02} =    Get Quareo Module Information    ${ip_address_02}    1
	${simulator}    Get Current Tab Alias  

    # 1. Enable Middleware config
	# 2. Launch and log in SM Web
	# 3. Add Rack 001 under Room 01 (Single/Multiple/Rack group) or under Cable Vaut
	# 4. Add and sync these devices successfully in Rack 001
    # 5. Add Panel RJ-45 into Rack 001
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    zoneMode=${RACK_GROUPS}
	Add Rack Group    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_GROUPS_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${Q2000} 24 Port    ${DEVICE_01}    ${ip_address_01}
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window

    # 6. Set critical for Device 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01    critical=${True}   
    
    # 7. Create cabling from Panel 01/01 to Device 01/01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    portsTo=01
    Close Cabling Window
    
    # 8. Set critical for Panel 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01    critical=${True}   
    Close Current Tab
    
    # 9. In Simulator, set unmanaged for Device 01/Module 01/01
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1
    
    # 10. Observe the Panel 01/01, Device 01/01 on the content table
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    #loading tree don't enough wait time
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    
	# 11. Select Panel 01/01, Device 01/01 then go to Event Log for Object, and observe the result
	# 12. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
      
    # 13. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    
    # 14. Select Event generated and click on "Locate" button and observer the result
    # 15. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
    
    # 16. Open Priority Event Log window and observe
    Open Events Window    Priority Event Log    
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    
    # 17. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        

    # 18. In Simulator, unset unmanaged for Device 01/Module 01/01
    Switch Window    ${simulator}    
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1    portStatus=${Port Status Empty}
    
    ## 10. Observe the Panel 01/01, Device 01/01 on the content table
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    
	## 11. Select Panel 01/01, Device 01/01 then go to Event Log for Object, and observe the result
	## 12. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
      
    ## 13. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    
    ## 14. Select Event generated and click on "Locate" button and observer the result
    ## 15. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
   
    ## 16. Open Priority Event Log window and observe
    Open Events Window    Priority Event Log    
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    
    ## 17. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
    Close Event Log

    # Panel (RJ-45, Critical) -> cabled to -> Quareo Q2000 24 port (Critical, Rear Static Port) -> patched to -> Unknown equipment
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    1
   
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01    critical=${False}
    Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${Q2000} 48 Port    ${DEVICE_02}    ${ip_address_02}
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}       
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    Remove Cabling By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}

    # 6. Open Quareo Unmanaged Connections
    Open Unmanaged Quareo Connections Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    
    # 7. Create patching from Device 01/01 to Device 02/01
    Create Quareo Unmanaged Connections    Unassigned Quareo ports    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}    portsTo=01
    Close Quareo Unmanaged Window

    # 8. Observe the Device 01/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    
    # 9. Select Device 01/01 then go to Event Log for Object, and observe the result
    # 10. Close Event Log for Object window
    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
 
    # 11. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    
    # 12. Select Event generated and click on "Locate" button and observer the result
    # 13. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}  
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
    
    # 14. Open Priority Event Log window and observe
    Open Events Window    Priority Event Log    
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
 
	# 15. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
	Close Event Log
	
	# 16. Remove patching between Device 01/01 and Device 02/01 on Quareo Unmanaged Connections
	Open Unmanaged Quareo Connections Window
	Create Quareo Unmanaged Connections    Assigned Quareo ports    typeConnect=Disconnect    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}    portsTo=01
	Close Quareo Unmanaged Window
	
	# 17. Repeat from step 8 to step 15 and observe
	
    ## 8. Observe the Device 01/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    
    ## 9. Select Device 01/01 then go to Event Log for Object, and observe the result
    ## 10. Close Event Log for Object window
    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    ${EVENT_DESCRIPTION}    position=2    delimiter=->
    Close Event Log
 
    ## 11. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    ${EVENT_DESCRIPTION}    position=2    delimiter=->
    
    ## 12. Select Event generated and click on "Locate" button and observer the result
    ## 13. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION} 
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
    
    ## 14. Open Priority Event Log window and observe
    Open Events Window    Priority Event Log    
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/01
    ...    ${EVENT_DESCRIPTION}    position=2    delimiter=->
    
	## 15. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
    Close Event Log
    
SM-29862_03_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit: Switch (LC Duplex) -> cabled to -> Quareo QHDEP F24LCDuplex-R24LCDuplex (Critical, Static Port, Unmanaged) -> patched to -> Unknown equipment
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29862_03
    ...    AND    Set Test Variable    ${ip_address_01}    3.3.3.3
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser
    
	# _Add devices in Simulator with un-populate data:
	# Device 01: QHDEP F12LCDuplex-R12LCDuplex (without populating data)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F12LCDuplex-R12LCDuplex}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias 
	 
    # 1. Enable Middleware config
	# 2. Launch and log in SM Web
	# 3. Add Rack 001 under Room 01 (Single/Multiple/Rack group) or under Cable Vaut
	# 4. Add and sync these devices successfully in Rack 001
	# 5. Add LC Switch 01 into Rack 001
	Open New Tab    ${URL}
    ${site_manager}    Get Current Tab Alias
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    zoneMode=${RACK_GROUPS}
	Add Rack Group    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_GROUPS_NAME}    
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${SWITCH_01}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    01    portType=LC       
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window

	# 6. Set Static (Rear) in Device 01/01
	Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}   

	# 7. Create cabling from Switch 01/01 to Device 01/01
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01
    Close Cabling Window
    
	# 8. Set critical for Device 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    critical=${True}   
    Close Current Tab

	# 9. In Simulator,  set unmanaged for Device 01/Module 01/01
	Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1   
    
	# 10. Observe the Device 01/01 on the content table
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01

	# 11. Select Device 01/01 then go to Event Log for Object, and observe the result
	# 12. Close Event Log for Object window
    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	# 13. Open Event Log window and observe the result
	Open Events Window
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 14. Select Event generated and click on "Locate" button and observer the result
	# 15. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION} 
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
 	
	# 16. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log    
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
   
	# 17. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
    Close Event Log
    Close Current Tab
    	
	# 18. In Simulator, unset unmanaged for Device 01/Module 01/01
	Switch Window    ${simulator}    
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1    portStatus=${Port Status Empty}
    
	# 19. Repeat from step 10 to step 17 and observe
    ## 10. Observe the Device 01/01 on the content table
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}   
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01

	## 11. Select Device 01/01 then go to Event Log for Object, and observe the result
	## 12. Close Event Log for Object window
    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	## 13. Open Event Log window and observe the result
	Open Events Window
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	## 14. Select Event generated and click on "Locate" button and observer the result
	## 15. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
	
	## 16. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log    
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    
	## 17. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
    Close Event Log
 
SM-29862_04_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit:Switch (LC Duplex) -> patched to ->Panel (LC Duplex) -> cabled to -> Quareo QHDEP Device 1 ->unmanaged connect to -> QNG4 Device 2
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29862_04
    ...    AND    Set Test Variable    ${ip_address_01}    4.4.4.4
    ...    AND    Set Test Variable    ${ip_address_02}    4.4.4.5
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    # Switch (LC Duplex) -> patched to ->Panel (LC Duplex) -> cabled to -> Quareo QHDEP Device 1 ->unmanaged connect to -> QNG4 Device 2
    # _Add devices in Simulator with un-populate data:
    # Device 01: QHDEP F12LCDuplex-R12LCDuplex (without populating data and set unmanaged for some port)
    # Device 02: QNG4 F12LCDuplex-R12LCDuplex (without populating data and set unmanaged for some port)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F12LCDuplex-R12LCDuplex}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1
	Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F12LCDuplex-R12LCDuplex}
	${moduleID_02} =    Get Quareo Module Information    ${ip_address_02}    1
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    1
	${simulator}    Get Current Tab Alias  
	
	# 1. Enable Middleware config
	# 2. Launch and log in SM Web
	# 3. Add Rack 001 under Room 01 (Single/Multiple/Rack group) or under Cable Vaut
	# 4. Add and sync these devices successfully in Rack 001
	# 5. Add LC Switch 01 into Rack 001
    Open New Tab    ${URL}
    ${site_manager}    Get Current Tab Alias
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    zoneMode=${RACK_GROUPS}
	Add Rack Group    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_GROUPS_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_02}    ${ip_address_02}
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${SWITCH_01}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    01    portType=LC       
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=LC
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    
    # 6. Set Static (Rear) in Device 01/01, Device 02/01
	Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}   
	Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}   

	# 7. Create cabling from Panel 01/01 to Device 01/01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01
    Close Cabling Window
    
    # 8. Create patching from Panel` 01/01 to Switch 01/01 without any work order
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01    portsTo=01    createWo=${False}    clickNext=${True}
   
	# 9. Set critical for Device 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    critical=${True}   
    
    # 10. Create patching from Device 01/01 to Device 02/01 on Quareo Unmanaged Connections
    Open Unmanaged Quareo Connections Window
    Create Quareo Unmanaged Connections    Unassigned Quareo ports    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=01
    Close Quareo Unmanaged Window

	# 11. Observe the Device 01/01, Device 02/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01

	# 12. Select Device 01/01, Device 02/01 then go to Event Log for Object, and observe the result
	# 13. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
    
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	# 14. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 15. Select Event generated and click on "Locate" button and observer the result
	# 16. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
	
	# 17. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log
	Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 18. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
    Close Event Log

	# 19. Remove patching between Panel 01/01 to Switch 01/01 without any work order
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01    portsTo=01    typeConnect=Disconnect    createWo=${False}    clickNext=${True}
    
	# 20. Repeat from step 10 to step 17 and observe
	# 11. Observe the Device 01/01, Panel 01/01, Switch 01/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}   01

	## 12. Select Device 01/01, Panel 01/01, Switch 01/01 then go to Event Log for Object, and observe the result
	## 13. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SWITCH_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
    
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SWITCH_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}   01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SWITCH_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	## 14. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SWITCH_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	## 15. Select Event generated and click on "Locate" button and observer the result
	## 16. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
	
	## 17. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SWITCH_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
    
SM-29862_05_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit:
    ###Server (LC Duplex) -> patched to -> Panel (LC Duplex) -> cabled to -> QHDEP Device 1 ->unmanaged connect to -> QNG4 Device 2
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29862_05
    ...    AND    Set Test Variable    ${ip_address_01}    5.5.5.5
    ...    AND    Set Test Variable    ${ip_address_02}    5.5.5.6
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    # Switch (LC Duplex) -> patched to ->Panel (LC Duplex) -> cabled to -> Quareo QHDEP Device 1 ->unmanaged connect to -> QNG4 Device 2
    # _Add devices in Simulator with un-populate data:
    # Device 01: QHDEP F12LCDuplex-R12LCDuplex (without populating data and set unmanaged for some port)
    # Device 02: QNG4 F12LCDuplex-R12LCDuplex (without populating data and set unmanaged for some port)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F12LCDuplex-R12LCDuplex}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F12LCDuplex-R12LCDuplex}
	${moduleID_02} =    Get Quareo Module Information    ${ip_address_02}    1
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    1
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1
	${simulator}    Get Current Tab Alias  
	
	# 1. Enable Middleware config
	# 2. Launch and log in SM Web
	# 3. Add Rack 001 under Room 01 (Single/Multiple/Rack group) or under Cable Vaut
	# 4. Add and sync these devices successfully in Rack 001
	# 5. Add LC Switch 01 into Rack 001
    Open New Tab    ${URL}
    ${site_manager}    Get Current Tab Alias
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Delete Building     name=${building_name}
	 ${buildingID}=    Add New Building    ${building_name}
    Reload Page
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    zoneMode=${RACK_GROUPS}
	Add Rack Group    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_GROUPS_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_02}    ${ip_address_02}
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${SERVER_01}
    Add Device In Rack Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    01    portType=LC
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=LC
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    
    # 6. Set Static (Rear) in Device 01/01, Device 02/01
	Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}   
	Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}   

	# 7. Create cabling from Panel 01/01 to Device 01/01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01
    Close Cabling Window
 
    # 8. Create patching from Panel 01/01 to Server 01//01 without any work order
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}     01
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01    portsTo=01    createWo=${False}    clickNext=${True}
    
	# 9. Set critical for Device 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    critical=${True}   

    # 10. Create patching from Device 01/01 to Device 02/01 on Quareo Unmanaged Connections
    Open Unmanaged Quareo Connections Window
    Create Quareo Unmanaged Connections    Unassigned Quareo ports    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=01
    Close Quareo Unmanaged Window

	# 11. Observe the Device 01/01, Device 02/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01

	# 12. Select Device 01/01, Device 02/01 then go to Event Log for Object, and observe the result
	# 13. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
    
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	# 14. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 15. Select Event generated and click on "Locate" button and observer the result
	# 16. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
	
	# 17. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log
	Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 18. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
    Close Event Log

	# 19. Remove patching between Panel 01/01 to Server 01/01 without any work order
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}     01
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01    portsTo=01    typeConnect=Disconnect    createWo=${False}    clickNext=${True}
    
    # 20. Repeat from step 10 to step 17 and observe
	## 11. Observe the Device 01/01, Panel 01/01, Server 01/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}   01

	## 12. Select Device 01/01, Panel 01/01, Server 01/01 then go to Event Log for Object, and observe the result
	## 13. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SERVER_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
    
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SERVER_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}   01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SERVER_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	## 14. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SERVER_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	## 15. Select Event generated and click on "Locate" button and observer the result
	## 16. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    
	
	## 17. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${SERVER_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
    
SM-29862_06-07_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit:
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29862_06
    ...    AND    Set Test Variable    ${ip_address_01}    6.6.6.6
    ...    AND    Set Test Variable    ${ip_address_02}    7.7.7.7
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    ### LC Switch ->Patched to ->Panel (LC Simplex) -> cabled to -> Quareo QHDEP F24LCSimplex-R24LCSimplex (Critical, Static Port, Unmanaged) -> patched to -> Unknown equipment
	# _Add devices in Simulator with un-populate data:
	# Device 01: QHDEP  F24LCSimplex-R24LCSimplex
	# Device 02: QNG4 F24LCSimplex-R24LCSimplex
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F24LCSimplex-R24LCSimplex}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F24LCSimplex-R24LCSimplex}
	${moduleID_02} =    Get Quareo Module Information    ${ip_address_02}    1
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    1
	${simulator}    Get Current Tab Alias
	
	# # 4. Add and sync these devices successfully in Rack 001
	# # 5. Add LC Simplex Panel 01, Switch 01 into Rack 001
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Delete Building     name=${building_name}
	${buildingID}=    Add New Building    ${building_name}
    Reload Page
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    zoneMode=${RACK_GROUPS}
	Add Rack Group    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_GROUPS_NAME}
	Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
	Add Quareo    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_02}    ${ip_address_02}
	Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=LC Simplex
	Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${SWITCH_01}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    01    portType=LC
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 6. Set Static (Rear) in Device 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}

	# 7. Create cabling from Panel 01/01 to Device 01/01
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01
    Close Cabling Window

	# 8. Create Patching from Switch 01//01 B to panel 01/01 without creating WO
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    01
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}/${01}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01 B    portsTo=01    createWo=${False}    clickNext=${True}

	# 9. Set critical for Device 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    critical=${True}
    Close Current Tab
    
    # 10. Simulator,  set unmanaged for Device 01/Module 01/01
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1 
	
	# 11. Observe the Device 01/01 on the content table
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01

	# 12. Select Device 01/01 then go to Event Log for Object, and observe the resul
	# 13. Close Event Log for Object window
    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	# 14. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 15. Select Event generated and click on "Locate" button and observer the result
	# 16. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01
	
	# 17. Open Priority Event Log window and observe
    Open Events Window    Priority Event Log
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 18. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}
    Close Event Log
    Close Current Tab
    
	# 19. In Simulator, unset unmanaged for Device 01/Module 01/01
	Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1    portStatus=${Port Status Empty}

	# 20. Repeat from step 11 to step 18 and observe
	# 11. Observe the Device 01/01 on the content table
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01

	## 12. Select Device 01/01 then go to Event Log for Object, and observe the resul
	## 13. Close Event Log for Object window
    Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	## 14. Open Event Log window and observe the result
    Open Events Window
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
	
	## 15. Select Event generated and click on "Locate" button and observer the result
	## 16. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01
	
	## 17. Open Priority Event Log window and observe
    Open Events Window    Priority Event Log
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${DEVICE_01}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->${UNKNOWN_EQUITMENT}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	## 18. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}
    Close Event Log

    ### LC Server -> Patched to  -> Panel (LC Simplex, Critical) -> cabled to ->  Quareo QHDEP F24LCSimplex-R24LCSimplex (Critical, Static Port, Unmanaged) -> patched to -> Quareo QNG4 F24LCSimplex-R24LCSimplex (Static Port, Unmanaged)
	Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    1

	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}    01
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SWITCH_01}/01    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01 B    portsTo=01    typeConnect=Disconnect    createWo=${False}    clickNext=${True}
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    
    # 5. Add LC Simplex Panel , Server 01 into Rack 001
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}    ${SERVER_01}
    Add Device In Rack Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    01    portType=LC Simplex

    # 6. Set Static(Rear) in Device 01/01, Device 02/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01    staticRear=${True}
	
	# 7. Create cabling from Panel 01/01 to Device 01/01
	# 8. Set critical for Device 01/01, Server 01/01
    Edit Port On Content Table    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    01    critical=${True}
	
    # 9. Create patching from:
	# _Server 01/01 A to Panel 01/01
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    01
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01    portsTo=01    createWo=${False}    clickNext=${True}

	# _Device 01/01 to Device 02/01 on Quareo Unmanaged Connections
    Open Unmanaged Quareo Connections Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Create Quareo Unmanaged Connections    Unassigned Quareo ports    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=01
    Close Quareo Unmanaged Window
	
	# 10. Observe the Device 01/01, Device 02/01 , Server 01/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    01
	
	# 11. Select Panel 01/01, Device 01/01, Device 02/01 then go to Event Log for Object, and observe the result
	# 12. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
    
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
	
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log

	# 13. Open Event Log window and observe the result
	Open Events Window
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->

	# 14. Select Event generated and click on "Locate" button and observer the result
	# 15. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01

	# 16. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log
    Check Event Details On Event Log    ${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
	
	# 17. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}
    Close Event Log

	# 18. Remove patching from Device 01/01 and Device 02/01 on Quareo Unmanaged Connections
    Open Unmanaged Quareo Connections Window
    Create Quareo Unmanaged Connections    Assigned Quareo ports    typeConnect=Disconnect    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=01
    Close Quareo Unmanaged Window
    
	# 19. Repeat from step 10 to step 17 and observe
	## 10. Observe the Device 01/01, Device 02/01 , Server 01/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    01
	
	## 11. Select Server 01/01, Device 01/01, Device 02/01 then go to Event Log for Object, and observe the result
	## 12. Close Event Log for Object window
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=2    delimiter=->
    Close Event Log
    
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=1    delimiter=->
    Close Event Log
	
	Open Events Window    Event Log for Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    01
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=2    delimiter=->
    Close Event Log

	## 13. Open Event Log window and observe the result
	Open Events Window
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=2    delimiter=->

	## 14. Select Event generated and click on "Locate" button and observer the result
	## 15. Close Event Log
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    01    

	## 16. Open Priority Event Log window and observe
	Open Events Window    Priority Event Log
    Check Event Details On Event Log    ${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${RACK_GROUPS_NAME}->${EVENT_CP}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${RACK_GROUPS_NAME}/${POSITION_RACK_NAME}/${SERVER_01}/01
    ...    ${EVENT_DESCRIPTION}    position=2    delimiter=->
	
	## 17. Clear All Event and observe
    Clear Event On Event Log    All    ${EVENT_DESCRIPTION}        
    Close Event Log

SM-29862_08_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_29862_08
    ...    AND    Set Test Variable    ${Q4000_device_01_ip}    10.10.10.8
    ...    AND    Delete Simulator    ${Q4000_device_01_ip}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${Q4000_device_01_ip}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser

    ${mpo12_card_01}    Set Variable    Card 01
    ${location_to_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    
    # Create Data in Simulator:
    # _The "Enabled" QUAREO function is set to "${True}" in the QUAREO config file.
    # _Add devices in Simulator with un-populate data:
    # Device 01: Q4000 F16MPO12-R16MPO12 (without populating data and set unmanaged for some port)
    # Device 02: QHDEP F8MPO12-R8MPO12 (without populating data and set unmanaged for some port)

    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${Q4000_device_01_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F16MPO12-R16MPO12
	${moduleID_01} =    Get Quareo Module Information    ${Q4000_device_01_ip}    1
	${simulator}    Get Current Tab Alias  
    
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    # 4. Add and sync these devices successfully in Rack 001
	# 5. Add MPO Panel 01, MPO12 Server 01 into Rack 001
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${location_to_rack}    ${SWITCH_01}
    Add Network Equipment Component    ${location_to_rack}/${SWITCH_01}    componentType=Network Equipment Card    name=${mpo12_card_01}    portType=MPO12   
    Add Quareo    ${location_to_rack}    quareoType=Q4000 1U Chassis    name=${DEVICE_01}    ipAddress=${Q4000_device_01_ip}
    Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_01} 
    Wait Until Device Synchronize Successfully      ${Q4000_device_01_ip}
    Close Quareo Synchronize Window
    
    # 6. Set Static (Rear) in Device 01/01
    Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    staticRear=${True}
		
	# 7. Create cabling from Switch 01/01 to Device 01/01
	Open Cabling Window     ${location_to_rack}/${SWITCH_01}/${mpo12_card_01}    01
	Create Cabling    cableFrom=${location_to_rack}/${SWITCH_01}/${mpo12_card_01}/01    cableTo=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01
	Close Cabling Window
	
	# 8. Set critical for Device 01/01
	Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    critical=${True}
	Close Current Tab
	
	# 9. In Simulator,  set unmanaged for Device 01/Module 01/01
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${Q4000_device_01_ip}    ${moduleID_01}    1  
    
   	# 10. Observe the Device 01/01 on the content table
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD} 
	Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
	
	# 11. Select Device 01/01 then go to Event Log for Object, and observe the result
	# 12. Close Event Log for Object window
	Open Events Window    eventType=Event Log for Object    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log    
	
	# 13. Open Event Log window and observe the result
    # 14. Select Event generated and click on "Locate" button and observer the result
    # 15. Close Event Log 
	Open Events Window
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Locate Event On Event Log    ${EVENT_DESCRIPTION}
	Close Event Log
	Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=01    
	
	# 16. Open Priority Event Log window and observe
    # 17. Clear All Event and observe
	Open Events Window    eventType=Priority Event Log    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01    
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}    
	Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}    
	Close Event Log
	Close Current Tab

	# 18. In Simulator, unset unmanaged for Device 01/Module 01/01
	Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${Q4000_device_01_ip}    ${moduleID_01}    1    portStatus=${Port Status Empty}
    
	# 19. Repeat from step 11 to step 18 and observe
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    
	Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
	
	Open Events Window    eventType=Event Log for Object    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log    
	
	Open Events Window
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log
	
	Open Events Window    eventType=Priority Event Log    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01    
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log

SM-29862_09_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_29862_09
    ...    AND    Set Test Variable    ${Q4000_device_01_ip}    10.10.10.6
    ...    AND    Set Test Variable    ${QHDEP_device_02_ip}    10.10.10.7
    ...    AND    Delete Simulator    ${Q4000_device_01_ip}
    ...    AND    Delete Simulator    ${QHDEP_device_02_ip}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${Q4000_device_01_ip}
    ...    AND    Delete Simulator    ${QHDEP_device_02_ip}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    ${mpo12_card_01}    Set Variable    Card 01  
    ${location_to_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    
    # Create Data in Simulator:
    # _The "Enabled" QUAREO function is set to "${True}" in the QUAREO config file.
    # _Add devices in Simulator with un-populate data:
    # Device 01: Q4000 F16MPO12-R16MPO12 (without populating data and set unmanaged for some port)
    # Device 02: QHDEP F8MPO12-R8MPO12 (without populating data and set unmanaged for some port)

    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${Q4000_device_01_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F16MPO12-R16MPO12
	${moduleID_01} =    Get Quareo Module Information    ${Q4000_device_01_ip}    1
	Add Simulator Quareo Device    ${QHDEP_device_02_ip}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=F8MPO12-R8MPO12
	${moduleID_02} =    Get Quareo Module Information    ${QHDEP_device_02_ip}    1
	${simulator}    Get Current Tab Alias  
    Edit Quareo Simulator Port Properties    ${Q4000_device_01_ip}    ${moduleID_01}    1    
    Edit Quareo Simulator Port Properties    ${QHDEP_device_02_ip}    ${moduleID_02}    1
    
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Delete Building     name=${building_name}
    
    # 4. Add and sync these devices successfully in Rack 001
	# 5. Add MPO Panel 01, MPO12 Server 01 into Rack 001
	
	${buildingID}=    Add New Building    ${building_name}
    Reload Page
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Generic Panel    ${location_to_rack}	name=${PANEL_NAME}    portType=MPO
    Add Device In Rack    ${location_to_rack}    ${SERVER_01}
    Add Device In Rack Component    ${location_to_rack}/${SERVER_01}    componentType=Device in Rack Card    name=${mpo12_card_01}     portType=MPO12   
    Add Quareo    ${location_to_rack}    quareoType=Q4000 1U Chassis    name=${DEVICE_01}    ipAddress=${Q4000_device_01_ip}
    Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_01} 
    Wait Until Device Synchronize Successfully      ${Q4000_device_01_ip}
    Close Quareo Synchronize Window
    Add Quareo    ${location_to_rack}    quareoType=QHDEP Chassis    name=${DEVICE_02}    ipAddress=${QHDEP_device_02_ip}
    Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_02}
    Wait Until Device Synchronize Successfully      ${QHDEP_device_02_ip}
    Close Quareo Synchronize Window
    
    # 6. Set Static (Rear) in Device 01/01
    Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    staticRear=${True}
	
	# 7. Create patching from Server 01/01 to Panel 01/01 without any work order
	Open Patching Window     ${location_to_rack}/${PANEL_NAME}    01
	Create Patching    patchFrom=${location_to_rack}/${PANEL_NAME}    patchTo=${location_to_rack}/${SERVER_01}/${mpo12_card_01}    portsFrom=01    portsTo=01    createWo=${False}
	
	# 8. Create cabling from Panel 01/01 to Device 01/01
	Open Cabling Window     ${location_to_rack}/${PANEL_NAME}    01
	Create Cabling    cableFrom=${location_to_rack}/${PANEL_NAME}/01    cableTo=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01
	Close Cabling Window
	
	# 9. Set critical for Device 01/01
	Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    critical=${True}
	
	# 10. Create patching from Device 01/01 to Device 02/01 on Quareo Unmanaged Connections
	Open Unmanaged Quareo Connections Window    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
	Create Quareo Unmanaged Connections    filterType=Unassigned Quareo ports    cableFrom=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01    cableTo=${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=01     
	Close Quareo Unmanaged Window
	
	# 11. Observe the Panel 01/01, Device 01/01, Device 02/01 on the content table
	Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
	Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    objectName=01
	
	# 12. Select Device 01/01, Device 02/01 then go to Event Log for Object, and observe the result
	# 13. Close Event Log for Object window
	Open Events Window    eventType=Event Log for Object    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log    
	
	# 14. Open Event Log window and observe the result
	# 15. Select Event generated and click on "Locate" button and observer the result
	# 16. Close Event Log 	
	Open Events Window
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Locate Event On Event Log    ${EVENT_DESCRIPTION}    
	Close Event Log
	Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=01    
	
	# 17. Open Priority Event Log window and observe
	# 18. Clear All Event and observe
	Open Events Window    eventType=Priority Event Log    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01    
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}
	Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}        
	Close Event Log
	
	# 19. Remove patching between Panel 01/01 to Switch 01/01 without any work order
	Open Patching Window    treeNode=${location_to_rack}/${PANEL_NAME}    objectName=01
	Create Patching    patchFrom=${location_to_rack}/${PANEL_NAME}    patchTo=${location_to_rack}/${SERVER_01}/${mpo12_card_01}    portsFrom=01    portsTo=01    typeConnect=Disconnect    createWo=${False}
	
	# 20. Repeat from step 11 to step 18 and observe
	Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${PANEL_NAME}    objectName=01
	Check Priority Event Icon Object On Content Pane	${location_to_rack}/${SERVER_01}/${mpo12_card_01}    objectName=01
	
	Open Events Window    eventType=Event Log for Object    treeNode=${location_to_rack}/${SERVER_01}/${mpo12_card_01}    objectName=01
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}->${EVENT_PORT_02}->01->${mpo12_card_01}->${SERVER_01}->${location_to_rack}->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log
	
	Open Events Window    eventType=Event Log
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}->${EVENT_PORT_02}->01->${mpo12_card_01}->${SERVER_01}->${location_to_rack}->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log
	
	Open Events Window    eventType=Priority Event Log    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01    
	Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${PANEL_NAME}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}->${EVENT_PORT_02}->01->${mpo12_card_01}->${SERVER_01}->${location_to_rack}->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01   
	...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
	Close Event Log
	
SM-29862_10_11_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_29862_10_11
    ...    AND    Set Test Variable    ${QHDEP_device_01_ip}    10.10.10.4
    ...    AND    Set Test Variable    ${QNG4_device_02_ip}    10.10.10.5
    ...    AND    Delete Simulator    ${QHDEP_device_01_ip}
    ...    AND    Delete Simulator    ${QNG4_device_02_ip}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${QHDEP_device_01_ip}
    ...    AND    Delete Simulator    ${QNG4_device_02_ip}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser

    # Create Data in Simulator:
    # _The "Enabled" QUAREO function is set to "${True}" in the QUAREO config file.
    # _Add devices in Simulator with un-populate data:
    # Device 01: QHDEP F8MPO24-R8MPO24  (without populating data)
    # Device 02: QNG4 F8MPO24-R8MPO24  (without populating data and set unmanaged for port 1)
    ${mpo24_card_01}    Set Variable    Card 01

    ${location_to_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${QHDEP_device_01_ip}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=F8MPO24-R8MPO24
	${moduleID_01} =    Get Quareo Module Information    ${QHDEP_device_01_ip}    1
	Add Simulator Quareo Device    ${QNG4_device_02_ip}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=F8MPO24-R8MPO24
	${moduleID_02} =    Get Quareo Module Information    ${QNG4_device_02_ip}    1
	${simulator}    Get Current Tab Alias
	Edit Quareo Simulator Port Properties    ${QNG4_device_02_ip}    ${moduleID_02}    1  
    
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    # On SM:
	# 4. Add and sync these devices successfully in Rack 001
	# 5. Add MPO Panel 01, Switch 01 into Rack 001
	# 6. Set Static(Rear) in Device 01/01
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${location_to_rack}    ${SWITCH_01}
    Add Network Equipment Component    ${location_to_rack}/${SWITCH_01}    componentType=Network Equipment Card    name=${mpo24_card_01}    portType=MPO24 
    Add Generic Panel    ${location_to_rack}	name=${PANEL_NAME}    portType=MPO
	Add Quareo    ${location_to_rack}    quareoType=QHDEP Chassis    name=${DEVICE_01}    ipAddress=${QHDEP_device_01_ip}
	Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_01}
	Wait Until Device Synchronize Successfully    ${QHDEP_device_01_ip}
	Close Quareo Synchronize Window
	Add Quareo    ${location_to_rack}    quareoType=QNG4 Chassis    name=${DEVICE_02}    ipAddress=${QNG4_device_02_ip}
	Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_02}
	Wait Until Device Synchronize Successfully    ${QNG4_device_02_ip}
	Close Quareo Synchronize Window
	Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    staticRear=${True}   
	
	# 7.Create patching from Switch 01/01 to Panel 01/01 and Create cabling from Panel 01/01 to Device 01/01
	Open Patching Window    ${location_to_rack}/${SWITCH_01}/${mpo24_card_01}    01
	Create Patching    patchFrom=${location_to_rack}/${SWITCH_01}/${mpo24_card_01}    patchTo=${location_to_rack}/${PANEL_NAME}    portsFrom=01    portsTo=01    createWo=${False}
	Open Cabling Window    ${location_to_rack}/${PANEL_NAME}    01
	Create Cabling     cableFrom=${location_to_rack}/${PANEL_NAME}/01    cableTo=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01         
	Close Cabling Window
	
	# 8. Set critical for Device 01/01, Panel 01/01
	Edit Port On Content Table    ${location_to_rack}/${PANEL_NAME}    name=01    critical=${True}
	Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    critical=${True}
	Close Current Tab
	
    # 9. In Simulator,  set unmanaged for Device 01/Module 01/01
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${QHDEP_device_01_ip}    ${moduleID_01}    1    
    
    # 10. Observe the Device 01/01 on the content table
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01

    # 11. Select Device 01/01 then go to Event Log for Object, and observe the result
    Open Events Window    eventType=Event Log for Object     treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE}->${building_name}->${FLOOR_NAME}->${ROOM_NAME}->${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
    Close Event Log
    
    # 9. Create patching from Device 01/01 to Device 02/01 on Quareo Unmanaged Connections
    Open Unmanaged Quareo Connections Window    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Create Quareo Unmanaged Connections    filterType=Unassigned Quareo ports	cableFrom=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01    cableTo=${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=01
    Close Quareo Unmanaged Window
    
    # 10. Observe the Panel 01/01, Device 01/01, Device 02/01 on the content table
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${PANEL_NAME}    01
   
    # 11. Select Panel 01/01, Device 01/01, Device 02/01 then go to Event Log, and observe the result
    Open Events Window    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_CP}->${location_to_rack}/${PANEL_NAME}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=01  
    
    # 16. Open Priority Event Log window and observe
    # 17. Clear All Event and observe
    Open Events Window    eventType=Priority Event Log     treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_CP}->${location_to_rack}/${PANEL_NAME}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
    Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}
    Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Close Event Log
    
    # 18. Remove patching between Device 01/01 and Device 02/01 on Quareo Unmanaged Connections
    # 19. Repeat from step 10 to step 17 and observe
    Open Unmanaged Quareo Connections Window    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Create Quareo Unmanaged Connections    filterType=Assigned Quareo ports    typeConnect=Disconnect    cableFrom=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01    cableTo=${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=01
    Close Quareo Unmanaged Window
    
    Open Events Window    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}    position=2
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_CP}->${location_to_rack}/${PANEL_NAME}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    eventDescription=${EVENT_DESCRIPTION}    position=2    delimiter=->
    Close Event Log
    Close Current Tab
    
    # 18. In Simulator, unset unmanaged for Device 01/Module 01/01
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${QHDEP_device_01_ip}    ${moduleID_01}    1    portStatus=${Port Status Empty}
    
    # 19. Repeat from step 10 to step 17 and observe
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Open Events Window    eventType=Event Log for Object     treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE}->${building_name}->${FLOOR_NAME}->${ROOM_NAME}->${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01
    ...    eventDescription=${EVENT_DESCRIPTION}         delimiter=->
    Close Event Log
    
SM-29862_12_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_29862_12
    ...    AND    Set Test Variable    ${Q4000_device_01_ip}    10.10.10.1
    ...    AND    Set Test Variable    ${Q4000_device_02_ip}    10.10.10.2
    ...    AND    Delete Simulator    ${Q4000_device_01_ip}
    ...    AND    Delete Simulator    ${Q4000_device_02_ip}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${Q4000_device_01_ip}
    ...    AND    Delete Simulator    ${Q4000_device_02_ip}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser
    
    ${LC_card_01}    Set Variable    Card 01
    ${location_to_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    
    # Create Data in Simulator:
    # _Add devices in Simulator with un-populate data and set unmanaged for some port
    # _Add Quareo Device (e.g Q4000 - F24LCDuplex-R24LCDuplex)
    
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${Q4000_device_01_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R24LCDuplex
	${moduleID_01} =    Get Quareo Module Information    ${Q4000_device_01_ip}    1
	Add Simulator Quareo Device    ${Q4000_device_02_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R24LCDuplex
	${moduleID_02} =    Get Quareo Module Information    ${Q4000_device_02_ip}    1
	${simulator}    Get Current Tab Alias  
    
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    # On SM:
    # 4. Add and sync these devices successfully in Rack 001
    # 5. Add a Switch Card LC into Rack 001
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${location_to_rack}    ${SWITCH_01}
    Add Network Equipment Component    ${location_to_rack}/${SWITCH_01}    componentType=Network Equipment Card    name=${LC_card_01}    portType=LC 
    
    #Add Quareo Device
    Add Quareo    ${location_to_rack}    quareoType=Q4000 1U Chassis    name=${DEVICE_01}    ipAddress=${Q4000_device_01_ip}
    Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${Q4000_device_01_ip}
    Close Quareo Synchronize Window
    Add Quareo    ${location_to_rack}    quareoType=Q4000 1U Chassis    name=${DEVICE_02}    ipAddress=${Q4000_device_02_ip}
    Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_02}
    Wait Until Device Synchronize Successfully    ${Q4000_device_02_ip}
    Close Quareo Synchronize Window
    
    # 6. Set Static (Front, Rear) for Quareo Device 01/ 01, Set Static (Rear) for Quareo Device 02/ 01
    Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01     staticRear=${True}    staticFront=${True}   
    Edit Port On Content Table    ${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    name=01     staticRear=${True}   
    
    # 7. Create patching from Switch 01/Card 01/ 01 to Quareo Device 01/ 01 on  without any work order
    Open Patching Window    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Create Patching    patchFrom=${location_to_rack}/${SWITCH_01}/${LC_card_01}    patchTo=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsFrom=01    portsTo=01    createWo=${False}
    
    # 8. Create cabling from Quareo Device 01/ 01 to  Quareo Device 02 /01
    Open Cabling Window    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Create Cabling    cableFrom=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/r01    cableTo=${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    portsTo=r01
    Close Cabling Window
    
    # 9. Set critical for Quareo Device 01/ 01
    Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    critical=${True}
    Close Current Tab
    
    # 10. In Simulator,  set unmanaged for Device 01/Module 01/02
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${Q4000_device_02_ip}    ${moduleID_02}    1
    
    # 11. Observe the Quareo Device 02/01 on the content table
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    01

    # 12. Select the Quareo Device 02/01 then go to Event Log for Object, and observe the result
    # 13. Close Event Log for Object window
    Open Events Window    eventType=Event Log for Object     treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01  
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01    
    ...    eventDescription=${EVENT_DESCRIPTION}     delimiter=->
    Close Event Log
    
    # 14. Open Event Log window and observe the result
    # 15. Select Event generated and click on "Locate" button and observer the result
    Open Events Window    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01  
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01    
    ...    eventDescription=${EVENT_DESCRIPTION}     delimiter=->
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=01
    
    # 17. Open Priority Event Log window and observe
    # 18. Clear All Event and observe
    Open Events Window    eventType=Priority Event Log     treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01  
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}    
    Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}    
    Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}        
    Close Event Log
    Close Current Tab
    
    # 19.  In Simulator,  unset unmanaged for Device 02//01
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${Q4000_device_02_ip}    ${moduleID_02}    1    portStatus=${Port Status Empty}
    
    # 20. Repeat from step 10 to step 17 and observe
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Open Events Window    eventType=Event Log for Object     treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01  
    Check Event Exist On Event Log Table    Unscheduled Patching Change to Critical Circuit
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01    
    ...    eventDescription=${EVENT_DESCRIPTION}     delimiter=->
    Close Event Log
    
    Open Events Window    eventType=Event Log  
    Check Event Exist On Event Log Table    Unscheduled Patching Change to Critical Circuit
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_02}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/01    
    ...    eventDescription=${EVENT_DESCRIPTION}     delimiter=->
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=01  
    
    Open Events Window    eventType=Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}       
    Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}    
    Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}    
    Close Event Log

SM-29862_13_Verify that "Unscheduled Patching Change to Critical Circuit" event is generated when the connection was removed/added and affects a critical circuit
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_29862_13
    ...    AND    Set Test Variable    ${QNG4_device_01_ip}    10.10.10.3
    ...    AND    Delete Simulator    ${QNG4_device_01_ip}
    ...    AND    Delete Building    ${building_name}
    ...    AND    Add New Building    ${building_name}
    
    [Teardown]    Run Keywords     Delete Simulator    ${QNG4_device_01_ip}
    ...    AND    Delete Building     ${building_name}
    ...    AND    Close Browser

    ${panel_01}    Set Variable    Panel 01
    ${panel_02}    Set Variable    Panel 02
    ${mpo12_card_01}    Set Variable    Card 01
    ${location_to_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    # Create Data in Simulator:
    # _Add devices in Simulator with un-populate data and set unmanaged for some port
    # _Add Quareo Device MPO12 (e.g QNG4 - F8MPO12-R8MPO12)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${QNG4_device_01_ip}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=F8MPO12-R8MPO12
	${moduleID_01} =    Get Quareo Module Information    ${QNG4_device_01_ip}    1
	${simulator}    Get Current Tab Alias  
	
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
	# 4. Add and sync these devices successfully in Rack 001, Set Static (Front) (Rear) for Quareo Device / 01, Set Static (Rear) for Quareo Device / 02
	# 5. Add a Switch Card MPO, Generic Panel MPO, Generic Panel 02 MPO into Rack 001
	Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${location_to_rack}    ${SWITCH_01}
    Add Network Equipment Component    ${location_to_rack}/${SWITCH_01}    componentType=Network Equipment Card    name=${mpo12_card_01}    portType=MPO12
	Add Generic Panel    treeNode=${location_to_rack}    name=Panel 01    portType=MPO    quantity=2
	Add Quareo    ${location_to_rack}    quareoType=QNG4 Chassis    name=${DEVICE_01}    ipAddress=${QNG4_device_01_ip}
	Synchronize By Context Menu On Site Tree    ${location_to_rack}/${DEVICE_01}
	Wait Until Device Synchronize Successfully    ${QNG4_device_01_ip}
	Close Quareo Synchronize Window
	Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01    staticRear=${True}	staticFront=${True}    
	Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=02    staticRear=${True}    
	
	# 6. Create patching from Switch / 01 to Panel 01 / 01 without any work order, and create cabling from Panel 01 / 01 to Quareo Device / 01
	# 7. Create patching from Quareo Device / 01 to Panel 02 / 01 on  without any work order, and create cabling from Panel 02 / 01 to Quareo Device / 02
	Open Patching Window    ${location_to_rack}/${SWITCH_01}/${mpo12_card_01}    01
	Create Patching    patchFrom=${location_to_rack}/${SWITCH_01}/${mpo12_card_01}    patchTo=${location_to_rack}/${panel_01}    portsFrom=01    portsTo=01    createWo=${False}    clickNext=${True}
	Open Patching Window    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
	Create Patching    patchFrom=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    patchTo=${location_to_rack}/${panel_02}    portsFrom=01    portsTo=01    createWo=${False}    clickNext=${True}
	
	Open Cabling Window    ${location_to_rack}/${panel_01}    01
	Create Cabling    cableFrom=${location_to_rack}/${panel_01}/01    cableTo=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r01
	Create Cabling    cableFrom=${location_to_rack}/${panel_02}/01    cableTo=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    portsTo=r02
	Close Cabling Window
	
    # 8. Set critical for Quareo Device / 02, Panel 02 / 01
    Edit Port On Content Table    ${location_to_rack}/${panel_02}    name=01    critical=${True}
    Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=02     critical=${True}
    Close Current Tab
       
    # 9. In Simulator,  set unmanaged for Device 01/Module 01/02
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${QNG4_device_01_ip}    ${moduleID_01}    2
    
    # 10. Observe the Quareo Device /01, 02, Panel 02 / 01 on the content table
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    02
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${panel_02}    01
    
    # 11. Select the Quareo Device /01, 02, Panel 02 / 01 then go to Event Log for Object, and observe the result
    # 12. Close Event Log for Object window
    Open Events Window    eventType=Event Log for Object    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=02   
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->02->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${panel_02}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/02
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Close Event Log
    
    # 13. Open Event Log window and observe the result
    # 14. Select Event generated and click on "Locate" button and observer the result
    # 15. Close Event Log 
    Open Events Window   
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->02->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${panel_02}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/02
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Locate Event On Event Log    ${EVENT_DESCRIPTION}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=02    
    
    # 16. Open Priority Event Log window and observe
    # 17. Clear All Event and observe
    Open Events Window    eventType=Priority Event Log    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01   
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_ADDED_DETAIL}->${EVENT_PORT_01}->02->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->Unknown equipment->${EVENT_CP}->${location_to_rack}/${panel_02}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/02
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}
    Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}       
    Close Event Log
    
    # 18. Remove patching from Quareo Device /01 and Panel 02 /01 without any work order
    Open Patching Window     ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Create Patching    patchFrom=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    patchTo=${location_to_rack}/${panel_02}    portsFrom=01    portsTo=01    typeConnect=Disconnect    createWo=${False}
    
    # 19. Repeat from step 10 to step 17 and observe for Quareo Device / 01 & Panel 02 / 01
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    02
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${panel_02}    01
    
    Open Events Window    eventType=Event Log for Object    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01   
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${panel_02}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME}->${EVENT_CP}->${location_to_rack}/${panel_02}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/02
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Close Event Log
    
    Open Events Window
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${panel_02}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME}->${EVENT_CP}->${location_to_rack}/${panel_02}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/02
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=01    
    
    Open Events Window    eventType=Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${MODULE_01_PASS-THROUGH}->${DEVICE_01}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME},${POSITION_RACK_NAME}->${EVENT_PORT_02}->01->${panel_02}->${POSITION_RACK_NAME}->${SITE_NODE},${building_name},${FLOOR_NAME},${ROOM_NAME}->${EVENT_CP}->${location_to_rack}/${panel_02}/01->${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}/02
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}
    Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}    
    Close Event Log    
    
    # 20. Set critical for Device 01/01 then Remove patching from Switch / 01 to Panel 01 / 01 without any work order
    Edit Port On Content Table    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=01     critical=${True}
    Open Patching Window    ${location_to_rack}/${SWITCH_01}/${mpo12_card_01}    01
    Create Patching    patchFrom=${location_to_rack}/${SWITCH_01}/${mpo12_card_01}    patchTo=${location_to_rack}/${panel_01}    portsFrom=01    portsTo=01    typeConnect=Disconnect    createWo=${False}
    
    # 21. Repeat from step 10 to step 17 and observe 
    Check Priority Event Icon Object On Content Pane    ${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    01
    
    Open Events Window    eventType=Event Log for Object    treeNode=${location_to_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    objectName=01   
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${mpo12_card_01}->${SWITCH_01}->${location_to_rack}->${EVENT_PORT_02}->01->${panel_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Close Event Log
    
    Open Events Window
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${mpo12_card_01}->${SWITCH_01}->${location_to_rack}->${EVENT_PORT_02}->01->${panel_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Locate Event On Event Log    ${EVENT_DESCRIPTION}    
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=01
    
    Open Events Window    eventType=Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Check Event Details On Event Log    eventDetails=${EVENT_REMOVED_DETAIL}->${EVENT_PORT_01}->01->${mpo12_card_01}->${SWITCH_01}->${location_to_rack}->${EVENT_PORT_02}->01->${panel_01}->${POSITION_RACK_NAME}->${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ...    eventDescription=${EVENT_DESCRIPTION}    delimiter=->
    Clear Event On Event Log    clearType=All    eventDescription=${EVENT_DESCRIPTION}
    Check Event Not Exist On Event Log Table    ${EVENT_DESCRIPTION}
    Close Event Log 
