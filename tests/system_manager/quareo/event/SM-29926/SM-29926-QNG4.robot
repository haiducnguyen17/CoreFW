*** Settings ***
Resource    ../../../../../resources/icons_constants.robot
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/SimulatorApi.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py  
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/history/circuit_history/CircuitHistoryPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/quareo_simulator/QuareoDevicePage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/quareo_simulator/CableTemplatesPage${PLATFORM}.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/quareo_unmanaged_connections/QuareoUnmanagedConnectionsPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/synchronization/SynchronizationPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmOptionalEventSettingsPage${PLATFORM}.py   
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmPriorityEventSettingsPage${PLATFORM}.py  
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py     
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/system_manager/AdmLoggingOptionsPage${PLATFORM}.py

Default Tags    Quareo Event
Force Tags    SM-29926
  
*** Variables ***
${BUILDING_NAME}    QNG4
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 Rack 001
${DEVICE_01}    QNG4 Chassis 01
${DEVICE_02}    QNG4 Chassis 02
${TEMPLATE}    Template
${EVENT_ADDED_DETAIL}    Plug Inserted in Quareo Port
${EVENT_REMOVED_DETAIL}    Plug Removed from Quareo Port
${EVENT_DESCRIPTION}    Unscheduled Patching Change to Critical Circuit
${EVENT_NAME_1}    Plug Inserted in Quareo Port
${EVENT_NAME_2}    Plug Removed from Quareo Port 
${EVENT_PORT_01}    Port 1:
${EVENT_PORT_02}    Port 2/Device:
${EVENT_CP}    Critical Ports:
${DEVICE_PORT_01}    01
${DEVICE_PORT_02}    02
${DEVICE_PORT_03}    03
${DEVICE_PORT_04}    04
${DEVICE_PORT_r01}    r01
${DEVICE_PORT_r02}    r02
${DEVICE_PORT_r03}    r03
${DELIMITER}    ->

*** Test Cases ***
SM-29926_17_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of QNG4 device with Module Type is "F12LCDuplex-R1MPO24-Flipped"

    [Setup]    Run Keywords    Set Test Variable    ${ip_address_01}    10.10.10.18
    ...    AND    Set Test Variable    ${ip_address_02}    10.10.10.19
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable     TC17
    ${device_module_01}    Set Variable    Module 01 (MPO24-AB/BA)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}
    ${tree_node_device_2}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_02}
    ${tree_node_device_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}${DELIMITER}${device_module_01}
    ${tree_node_device_2_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_02}${DELIMITER}${device_module_01}
    
    # 1. On Quareo Simulator, add a QNG4 Device 01, 02 with Module Type is "F12LCDuplex-R1MPO24-Flipped"(e.g. 10.10.10.18 , 10.10.10.19)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F12LCDuplex-R1MPO24-Flipped}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F12LCDuplex-R1MPO24-Flipped}
	${moduleID_02} =    Get Quareo Module Information    ${ip_address_02}    1
	${simulator}    Get Current Tab Alias  
	
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=${TRUE}
    
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}
    	
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_01}    ${ip_address_01}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_02}    ${ip_address_02}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    Synchronize By Context Menu On Site Tree    ${tree_node_device_2}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 02/01 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    ${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_2_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_01}    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}    
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/02
    Edit Port On Content Table    ${tree_node_device_module}    ${DEVICE_PORT_02}    staticFront=${True}    delimiterTree=${DELIMITER} 
    
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 02/01
    Switch Window    ${simulator}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    01000001
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_01}    @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/02
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    01000002
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    @{heads}[0]    portStatus=${Port Status Managed}
	
	# _Create unmanaged connection for Device 02/02
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_02}    
	
    # 10. On SM Select Device 02 and observe ports on contents pane
    # VP: Device 02/02 is marked priority
    # VP: Device 01/01, Device 02/01 are not marked due to these are scheduled connection
    # VP: Device 01/01 is not marked due to user set static on this port (unmoniter)
    # VP: Device 01/ r01, Device 02/r01 is not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    
    # 11. Select Device 02/02 Go to Event Log for Object then observe result
    # VP: _Event "Plug Inserted in Quareo Port" is displayed for Device 02/02
    Open Events Window    ${Event Log for Object}    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_2_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_01}    typeConnect=Disconnect    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # VP: Device 02/02 is marked priority
    # VP: Device 01/01, Device 02/01 are not marked due to these are scheduled connection
    # VP: Device 01/01 is not marked due to user set static on this port (unmoniter)
    # VP: Device 01/ r01, Device 02/r01 is not marked due to these are rear ports
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    
    # 15. Go to Event Log then observe result
    # VP: Event "Plug Removed from Quareo Port" is displayed for Device 02/02  
    Open Events Window    ${Event Log for Object}    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log
   
SM-29926_18_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F12LCDuplex-R1MPO24-Straight"
    
    [Setup]    Run Keywords    Set Test Variable    ${ip_address_01}    10.10.10.20
    ...    AND    Set Test Variable    ${ip_address_02}    10.10.10.21
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable     TC18
    ${device_module_01}    Set Variable    Module 01 (MPO24-AA/BB)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}
    ${tree_node_device_2}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_02}
    ${tree_node_device_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}${DELIMITER}${device_module_01}
    ${tree_node_device_2_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_02}${DELIMITER}${device_module_01}
    
    # 1. On Quareo Simulator, add a QNG4 Device 01, 02 with Module Type is "F12LCDuplex-R1MPO24-Straight"(e.g. 10.10.10.18 , 10.10.10.19)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F12LCDuplex-R1MPO24-Straight}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F12LCDuplex-R1MPO24-Straight}
	${moduleID_02} =    Get Quareo Module Information    ${ip_address_02}    1
	${simulator}    Get Current Tab Alias  
	
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=${TRUE}
    
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME} 
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_01}    ${ip_address_01}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_02}    ${ip_address_02}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    Synchronize By Context Menu On Site Tree    ${tree_node_device_2}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 02/01 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    ${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_2_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_01}    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/02
    Edit Port On Content Table    ${tree_node_device_module}    ${DEVICE_PORT_02}    staticFront=${True}    delimiterTree=${DELIMITER} 
    
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 02/01
    Switch Window    ${simulator}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    02000001
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_01}    @{tails}[0]    portStatus=${Port Status Managed}
	# _Create managed connection for Device 01/02
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    02000002
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    @{heads}[0]    portStatus=${Port Status Managed}
	
	# _Create unmanaged connection for Device 02/02
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_02}    
	
    # 10. On SM Select Device 02 and observe ports on contents pane
    # VP: Device 02/02 is marked priority
    # VP: Device 01/01, Device 02/01 are not marked due to these are scheduled connection
    # VP: Device 01/01 is not marked due to user set static on this port (unmoniter)
    # VP: Device 01/ r01, Device 02/r01 is not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    
    # 11. Select Device 02/02 Go to Event Log for Object then observe result
    # VP: _Event "Plug Inserted in Quareo Port" is displayed for Device 02/02
    Open Events Window    ${Event Log for Object}    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_2_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_01}    typeConnect=Disconnect    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # VP: Device 02/02 is marked priority
    # VP: Device 01/01, Device 02/01 are not marked due to these are scheduled connection
    # VP: Device 01/01 is not marked due to user set static on this port (unmoniter)
    # VP: Device 01/ r01, Device 02/r01 is not marked due to these are rear ports
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_2_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    
    # 15. Go to Event Log then observe result
    # VP: Event "Plug Removed from Quareo Port" is displayed for Device 02/02  
    Open Events Window    ${Event Log for Object}    ${tree_node_device_2_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log
  
SM-29926_19_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F12LCDuplex-R2MPO12-Straight"
    
    [Setup]    Run Keywords    Set Test Variable    ${ip_address_01}    10.10.10.22
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable     TC19   
    ${device_module_01}    Set Variable    Module 01 (2xMPO12-AA/BB)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}
    ${tree_node_device_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}${DELIMITER}${device_module_01}
    
    # 1. On Quareo Simulator, add a QNG4 Device 01, 02 with Module Type is "F12LCDuplex-R1MPO24-Flipped"(e.g. 10.10.10.18 , 10.10.10.19)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F12LCDuplex-R2MPO12-Straight}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias  
	
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=${TRUE}
    
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_01}    ${ip_address_01}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/03
    Edit Port On Content Table    ${tree_node_device_module}    ${DEVICE_PORT_03}    staticFront=${True}    delimiterTree=${DELIMITER}
    
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    03000001
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    @{tails}[0]    portStatus=${Port Status Managed}
	# _Create managed connection for Device 01/02
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    03000002
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    @{heads}[0]    portStatus=${Port Status Managed}
	# _Create unmanaged connection for Device 02/02
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
    # 10. On SM Select Device 02 and observe ports on contents pane
    # VP: Device 01/ 01,02,04 are marked priority
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    # VP: Device 01/ r01, r02 are not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    
    # 11. Select Device 02/02 Go to Event Log for Object then observe result
    # VP: _Event "Plug Inserted in Quareo Port" is displayed for Device 02/02
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO   
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # VP: Device 02/02 is marked priority
    # VP: Device 01/01, Device 02/01 are not marked due to these are scheduled connection
    # VP: Device 01/01 is not marked due to user set static on this port (unmoniter)
    # VP: Device 01/ r01, Device 02/r01 is not marked due to these are rear ports
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    
    # 15. Go to Event Log then observe result
    # VP: Event "Plug Removed from Quareo Port" is displayed for Device 02/02     
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log

SM-29926_20_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCSimplex-R2MPO12"
    
    [Setup]    Run Keywords    Set Test Variable    ${ip_address_01}    10.10.10.23
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
        
    ${floor_name}    Set Variable     TC20
    ${device_module_01}    Set Variable    Module 01 (2xMPO12)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}
    ${tree_node_device_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}${DELIMITER}${device_module_01}
    
    # 1. On Quareo Simulator, add a QNG4 Device 01, 02 with Module Type is "F12LCDuplex-R1MPO24-Flipped"(e.g. 10.10.10.18 , 10.10.10.19)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F24LCSimplex-R2MPO12}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias  
	
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=${TRUE}
    
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_01}    ${ip_address_01}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    # 8. Set "Static (Front)" for Device 01/02
    Edit Port On Content Table    ${tree_node_device_module}    ${DEVICE_PORT_03}    staticFront=${True}    delimiterTree=${DELIMITER}
    
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${cableId}    Generate Cable Template    H1LCSimplex-T1LCSimplex    04000001
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    @{tails}[0]    portStatus=${Port Status Managed}
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCSimplex-T1LCSimplex    04000002
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    @{heads}[0]    portStatus=${Port Status Managed}
	# _Create unmanaged connection for Device 01/04
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
    # 10. On SM Select Device 02 and observe ports on contents pane
    # VP: Device 01/04 is marked priority
    # VP: Device 01/01,02 are not marked due to these are scheduled connection
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    # 11. Select Device 01/04 Go to Event Log for Object then observe result
    # VP: _Event "Plug Inserted in Quareo Port" is displayed for Device 01/04
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO   
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}

    # 14. On SM Select Device 01 and observe ports on contents pane
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # VP: Device 01/04 is marked priority
    # VP: Device 01/01,02 are not marked due to these are scheduled connection
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    
    # 15. Go to Event Log then observe result
    # VP: Event "Plug Removed from Quareo Port" is displayed for Device 01/04     
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log

SM-29926_21_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F6MPO08-R2MPO24-Straight"
    
    [Setup]    Run Keywords    Set Test Variable    ${ip_address_01}    10.10.10.24
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable     TC21
    ${device_module_01}    Set Variable    Module 01 (2xMPO24)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}
    ${tree_node_device_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}${DELIMITER}${device_module_01}
    
    # 1. On Quareo Simulator, add a QNG4 Device 01, 02 with Module Type is "F6MPO08-R2MPO24-Straight"(e.g. 10.10.10.24)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F6MPO08-R2MPO24-Straight}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias  
	
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=${TRUE}
    
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_01}    ${ip_address_01}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    # 8. Set "Static (Front)" for Device 01/02
    Edit Port On Content Table    ${tree_node_device_module}    ${DEVICE_PORT_03}    staticFront=${True}    delimiterTree=${DELIMITER}
    
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    05000001
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    @{tails}[0]    portStatus=${Port Status Managed}
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    05000002
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    @{heads}[0]    portStatus=${Port Status Managed}
	# _Create unmanaged connection for Device 01/04 
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
    # 10. On SM Select Device 02 and observe ports on contents pane
    # VP: Device 01/04 is marked priority
    # VP: Device 01/01,02 are not marked due to these are scheduled connection
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    # 11. Select Device 01/04 Go to Event Log for Object then observe result
    # VP: _Event "Plug Inserted in Quareo Port" is displayed for Device 01/04
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO   
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # VP: Device 01/04 is marked priority
    # VP: Device 01/01,02 are not marked due to these are scheduled connection
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    
    # 15. Go to Event Log then observe result
    # VP: Event "Plug Removed from Quareo Port" is displayed for Device 01/04     
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log

SM-29926_22_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F8MPO24-R8MPO24"
   [Setup]    Run Keywords    Set Test Variable    ${ip_address_01}    10.10.10.25
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable     TC22
    ${device_module_01}    Set Variable    Module 01 (Pass-Through)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}
    ${tree_node_device_module}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_01}${DELIMITER}${device_module_01}
    
    # 1. On Quareo Simulator, add a QNG4 Device 01, 02 with Module Type is "F8MPO24-R8MPO24"(e.g. 10.10.10.25)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QNG4}    modules=${F8MPO24-R8MPO24}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias  
	
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=${TRUE}
    
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QNG4} Chassis    ${DEVICE_01}    ${ip_address_01}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}    delimiter=${DELIMITER}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    # 8. Set "Static (Front)" for Device 01/02
    Edit Port On Content Table    ${tree_node_device_module}    ${DEVICE_PORT_03}    staticFront=${True}    delimiterTree=${DELIMITER}
    
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${cableId}    Generate Cable Template    H1MPO24-T1MPO24-STRAIGHT    06000001
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    @{tails}[0]    portStatus=${Port Status Managed}
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1MPO24-T1MPO24-STRAIGHT    06000002
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    @{heads}[0]    portStatus=${Port Status Managed}
	# _Create unmanaged connection for Device 01/04 
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
    # 10. On SM Select Device 02 and observe ports on contents pane
    # VP: Device 01/04 is marked priority
    # VP: Device 01/01,02 are not marked due to these are scheduled connection
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    # 11. Select Device 01/04 Go to Event Log for Object then observe result
    # VP: _Event "Plug Inserted in Quareo Port" is displayed for Device 01/04
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO   
    Open Patching Window    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device_module}    patchTo=${tree_node_device_module}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    delimiterTree=${DELIMITER}    createWo=${True}   clickNext=${True}
    Create Work Order
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    # VP: Device 01/04 is marked priority
    # VP: Device 01/01,02 are not marked due to these are scheduled connection
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_02}    delimiter=${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_module}    ${DEVICE_PORT_03}    delimiter=${DELIMITER}
    
    # 15. Go to Event Log then observe result
    # VP: Event "Plug Removed from Quareo Port" is displayed for Device 01/04     
    Open Events Window    ${Event Log for Object}    ${tree_node_device_module}    ${DEVICE_PORT_04}    delimiter=${DELIMITER}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_REMOVED_DETAIL}        
    Close Event Log
