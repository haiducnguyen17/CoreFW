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
Library   ../../../../../py_sources/logigear/page_objects/quareo_simulator/QuareoDevicePage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/quareo_simulator/CableTemplatesPage${PLATFORM}.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/quareo_unmanaged_connections/QuareoUnmanagedConnectionsPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/synchronization/SynchronizationPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmOptionalEventSettingsPage${PLATFORM}.py   
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmPriorityEventSettingsPage${PLATFORM}.py  
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py     

Force Tags    SM-29926
Default Tags    Quareo Event

*** Variables ***
${BUILDING_NAME}    Q4000
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 ${RACK_NAME}
${EVENT_INSERT}    Plug Inserted in Quareo Port 
${EVENT_REMOVE}    Plug Removed from Quareo Port
${EVENT_INSERT_DETAILS}    A patch cord plug was inserted in the following Quareo port:
${EVENT_REMOVE_DETAILS}    A patch cord plug was removed from the following Quareo port:
${TEMPLATE}    Template
${RESTORE_FILE_NAME}    SM-29926
${QUAREO_TYPE}    Q4000 1U Chassis
${DEVICE_NAME}    Device 1
${DEVICE_PORT_01}    01
${DEVICE_PORT_02}    02
${DEVICE_PORT_03}    03
${DEVICE_PORT_04}    04
${DELIMITER}    ->

*** Test Cases ***
SM-29926_02_Verify that SM will not generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F12MPO08-R4MPO24-Straight"
    [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.2
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC2
    ${r01}    Set Variable    r01%2D03
    ${r02}    Set Variable    r04%2D06
    ${r03}    Set Variable    r10%2D12
    ${module_1}    Set Variable    Module 01 (4xMPO24)
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_NAME}

    # 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F12MPO08-R4MPO24-Straight" (e.g. 10.10.10.2)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F12MPO08-R4MPO24-Straight
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
	${simulator}    Get Current Tab Alias
	
    # 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
	Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}
    
	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Never"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Never    trackButtonPresses=True
    
	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    
	Create Work Order    
	
	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}/${module_1}    name=${DEVICE_PORT_03}    staticFront=${True}
	
	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    11111111
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    11111112
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}
	
    # _Create unmanaged connection for Device 01/04 and Device 01/r03
    Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    
	
	# _Create managed connecion from Device 01/R01 to Device 01/r02
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    11111113
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}
    
	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
	
	# 11. Go to Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Not Exist On Event Log Table    ${EVENT_INSERT}
	Close Event Log
	
	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect
	Create Work Order
	
	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    portStatus=${Port Status Empty}
	
	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
	
	# 15. Go to Priority Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Not Exist On Event Log Table    ${EVENT_REMOVE}
	Close Event Log
	
SM-29926_03_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F16MPO12-R16MPO12"
    [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.3
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC3
    ${r01}    Set Variable    r01
    ${r02}    Set Variable    r02
    ${r03}    Set Variable    r03
    ${module_1}    Set Variable    Module 01 (Pass-Through)
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_NAME}
    
    
    # 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F16MPO12-R16MPO12" (e.g. 10.10.10.3)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F16MPO12-R16MPO12
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
	${simulator}    Get Current Tab Alias
	
	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}
    
	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=True

	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window
    
	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    
	Create Work Order
	
	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}/${module_1}    name=03    staticFront=${True}
	
	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    22222221
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    22222222
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}
	
	# _Create unmanaged connection for Device 01/04 and Device 01/r03
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    
	
	# _Create managed connecion from Device 01/r01 to Device 01/r02
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    11111113
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}
	
	# 11. Select Device 01/04 Go to Event Log for Object then observe result
	Open Events Window    ${Event Log for Object}    treeNode=${tree_node_device}/${module_1}    objectName=${DEVICE_PORT_04}
	Check Event Exist On Event Log Table    ${EVENT_INSERT}
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    delimiter=->
	Close Event Log
	
	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect
	Create Work Order
	
	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    portStatus=${Port Status Empty}
	
	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}
	
	# 15. Go to Priority Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    delimiter=->
	
	# 16. Clear all priority event and observe the result
	Clear Event On Event Log    clearType=All
	Check Event Not Exist On Event Log Table    ${EVENT_REMOVE}
    Close Event Log
	
SM-29926_04_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCDuplex-R24LCDuplex"
     [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.4
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC4
    ${r01}    Set Variable    r01
    ${r02}    Set Variable    r02
    ${r03}    Set Variable    r03
    ${module_1}    Set Variable    Module 01 (Pass-Through)
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_NAME}
    
    # 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F24LCDuplex-R24LCDuplex"  (e.g. 10.10.10.4)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R24LCDuplex
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
    ${simulator}    Get Current Tab Alias
    
	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}

	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=True

	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window

	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    
	Create Work Order

	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}/${module_1}    name=${DEVICE_PORT_03}    staticFront=${True}
	
	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    333333331
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}

	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    333333332
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}

	# _Create unmanaged connection for Device 01/04 and Device 01/r03
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    

	# _Create managed connecion from Device 01/r01 to Device 01/r02
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    333333333
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}

	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}

	# 11. Go to Priority Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=1
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=2
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=3    delimiter=->
	Locate Event On Event Log    ${EVENT_INSERT}    position=1
	Close Event Log
	Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=${DEVICE_PORT_04}

	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect
	Create Work Order

	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    portStatus=${Port Status Empty}

	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}

	# 15. Go to Pririty Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=1
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=2
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=3    delimiter=->
	
	# 16. Clear all priority event and observe the result
	Clear Event On Event Log    clearType=All
	Check Event Not Exist On Event Log Table    ${EVENT_REMOVE}
    Close Event Log

SM-29926_05_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCDuplex-R2MPO24-Flipped"
     [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.5
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC5
    ${r01}    Set Variable    r01%2D12
    ${r02}    Set Variable    r13%2D24
    ${module_1}    Set Variable    Module 01 (2xMPO24-AB/BA)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_NAME}

    # 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F24LCDuplex-R2MPO24-Flipped" (e.g. 10.10.10.5)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R2MPO24-Flipped
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
    ${simulator}    Get Current Tab Alias

	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}

    Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}

	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=True

	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}    ${DELIMITER}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window

	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    treeNode=${tree_node_device}${DELIMITER}${module_1}    objectName=${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}  
	Create Work Order

	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}${DELIMITER}${module_1}    name=${DEVICE_PORT_03}    staticFront=${True}    delimiterTree=${DELIMITER}
	
	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    55555551
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    55555552
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}

	# _Create unmanaged connection for Device 01/04
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
	# _Create managed connecion from Device 01/r01 to Device 01/r02
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    55555553
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}

	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}
	
	# 11. Go to Priority Event Log for Object then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=1
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=2
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=3    delimiter=->
	Locate Event On Event Log    ${EVENT_INSERT}    position=1
	Close Event Log
	Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=${DEVICE_PORT_04}
	
	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect    delimiterTree=${DELIMITER}
	Create Work Order

	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}

	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}

	# 15. Go to Priority Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=1
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=2
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=3    delimiter=->

	# 16. Clear all events log and observe the result
	Clear Event On Event Log    clearType=All
    Close Event Log
	
SM-29926_06_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCDuplex-R2MPO24-HD"	
    [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.6
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC6
    ${r01}    Set Variable    r01%2D12
    ${r02}    Set Variable    r13%2D24
    ${module_1}    Set Variable    Module 01 (2xMPO24-HD)
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_NAME}
    
	# 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F24LCDuplex-R2MPO24-HD" (e.g. 10.10.10.6)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R2MPO24-HD
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
	${simulator}    Get Current Tab Alias

	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}

	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=True

	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window

	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    
	Create Work Order

	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}/${module_1}    name=${DEVICE_PORT_03}    staticFront=${True}
	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    66666661
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
    
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    66666662
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}

	# _Create unmanaged connection for Device 01/04
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
	# _Create managed connecion from Device 01/r01 to Device 01/r02
	${cableId}    Generate Cable Template    H1MPO24-T1MPO24-STRAIGHT    66666663
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}

	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}

	# 11. Select Device 01/04 Go to Event Log for Object then observe result
	Open Events Window    ${Event Log for Object}    treeNode=${tree_node_device}/${module_1}    objectName=${DEVICE_PORT_04}
	Check Event Exist On Event Log Table    ${EVENT_INSERT}
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    delimiter=->
	Close Event Log

	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect
	Create Work Order

	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}

	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}

	# 15. Go to Priority Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    delimiter=->
    Close Event Log

SM-29926_07_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCDuplex-R2MPO24-Straight"
     [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.7
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser

    ${floor_name}    Set Variable    TC7
    ${r01}    Set Variable    r01%2D12
    ${r02}    Set Variable    r13%2D24
    ${module_1}    Set Variable    Module 01 (2xMPO24-AA/BB)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_NAME}

	# 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F24LCDuplex-R2MPO24-Straight" (e.g. 10.10.10.7)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R2MPO24-Straight
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
    ${simulator}    Get Current Tab Alias

	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}

	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=True

	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}    ${DELIMITER}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window

	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    treeNode=${tree_node_device}${DELIMITER}${module_1}    objectName=${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}  
	Create Work Order

	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}${DELIMITER}${module_1}    name=${DEVICE_PORT_03}    
	...    staticFront=${True}    delimiterTree=${DELIMITER}
	
	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    77777771
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    77777772
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}

	# _Create unmanaged connection for Device 01/04
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	# _Create managed connecion from Device 01/r01 to Device 01/r02
	${cableId}    Generate Cable Template    H1MPO24-T1MPO24-STRAIGHT    77777773
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}

	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}
	
	# 11. Go to Priority Event Log  then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=1
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=2
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=3    delimiter=->
	Locate Event On Event Log    ${EVENT_INSERT}    position=1
	Close Event Log
	Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=${DEVICE_PORT_04}

	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect    delimiterTree=${DELIMITER}
	Create Work Order

	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}

	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}

	# 15. Go to Priority Event Log then observe result    
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=1
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=2
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=3    delimiter=->
    Clear Event On Event Log    clearType=All
	Check Event Not Exist On Event Log Table    ${EVENT_REMOVE}
    Close Event Log

SM-29926_08_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCDuplex-R4MPO12-Flipped"
     [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.8
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC8
    ${r01}    Set Variable    r01%2D06
    ${r02}    Set Variable    r07%2D12
    ${r03}    Set Variable    r13%2D18
    ${module_1}    Set Variable    Module 01 (4xMPO12-AB/BA)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_NAME}

    # 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F24LCDuplex-R4MPO12-Flipped" (e.g. 10.10.10.8)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R4MPO12-Flipped
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
	${simulator}    Get Current Tab Alias
	
	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
	Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}
    
	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Never"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Never    trackButtonPresses=True

	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}    ${DELIMITER}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window

	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    treeNode=${tree_node_device}${DELIMITER}${module_1}    objectName=${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}  
	Create Work Order
	
	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}${DELIMITER}${module_1}    name=${DEVICE_PORT_03}    
	...    staticFront=${True}    delimiterTree=${DELIMITER}

	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    88888881
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}

	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    88888882
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}

	# _Create unmanaged connection for Device 01/04 and Device 01/r03
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    
	
	# _Create managed connecion from Device 01/R01 to Device 01/r02
	${cableId}    Generate Cable Template    H1MPO24-T1MPO24-FLIPPED    77777773
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}

	# 10. On SM Select Device 01 and observe ports on contents pane
		Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}

	# 11. Go to Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Not Exist On Event Log Table    ${EVENT_INSERT}
	Close Event Log

	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect    delimiterTree=${DELIMITER}
	Create Work Order

	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}
    Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r03}    portStatus=${Port Status Empty}

	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}

	# 15. Go to Event Log then observe result
    Open Events Window    ${Priority Event Log}
	Check Event Not Exist On Event Log Table    ${EVENT_REMOVE}
	Close Event Log

SM-29926_09_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCDuplex-R4MPO12-Flipped"	
     [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.9
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC9
    ${r01}    Set Variable    r01%2D06
    ${r02}    Set Variable    r07%2D12
    ${module_1}    Set Variable    Module 01 (4xMPO12-HD)
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_NAME}

    # 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F24LCDuplex-R4MPO12-HD" (e.g. 10.10.10.9)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R4MPO12-HD
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
	${simulator}    Get Current Tab Alias

	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. Check priority for 2 these event (if theys are not checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}
    Set Priority Event Checkbox    ${EVENT_REMOVE}

	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=True

	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window

	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    
	Create Work Order

	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}/${module_1}    name=${DEVICE_PORT_03}    staticFront=${True}
	
	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    99999991
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}

	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    99999992
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}

	# _Create unmanaged connection for Device 01/04
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
	# _Create managed connecion from Device 01/r01 to Device 01/r02
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    99999993
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}

	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}

	# 11. Select Device 01/04 Go to Event Log for Object then observe result
	Open Events Window    ${Event Log for Object}    treeNode=${tree_node_device}/${module_1}    objectName=${DEVICE_PORT_04}
	Check Event Exist On Event Log Table    ${EVENT_INSERT}
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    delimiter=->
	Close Event Log

	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${module_1}    patchTo=${tree_node_device}/${module_1}    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect
	Create Work Order

	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}

	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${module_1}    ${DEVICE_PORT_04}

	# 15. Go to Priority Event Log then observe result
	Open Events Window    ${Priority Event Log}
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    delimiter=->
	
	# 16. Clear all priority event and observe the result
	Clear Event On Event Log    clearType=All
	Check Event Not Exist On Event Log Table    ${EVENT_REMOVE}
	Close Event Log

SM-29926_10_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q4000 device with Module Type is "F24LCDuplex-R4MPO12-Straight"
     [Setup]    Run Keywords     Set Test Variable    ${device_ip}    10.10.10.10
    ...    AND    Delete Simulator    ${device_ip}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${device_ip}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC10
    ${r01}    Set Variable    r01%2D06
    ${r02}    Set Variable    r07%2D12
    ${module_1}    Set Variable    Module 01 (4xMPO12-AA/BB)
    ${tree_node_device}    Set Variable    ${SITE_NODE}${DELIMITER}${BUILDING_NAME}${DELIMITER}${floor_name}${DELIMITER}${ROOM_NAME}${DELIMITER}${POSITION_RACK_NAME}${DELIMITER}${DEVICE_NAME}
 
	# 1. On Quareo Simulator, add a Q4000 Device with Module Type is "F24LCDuplex-R4MPO12-Straight" (e.g. 10.10.10.10)
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${device_ip}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=F24LCDuplex-R4MPO12-Straight
	${moduleID_01} =    Get Quareo Module Information    ${device_ip}    1
    ${simulator}    Get Current Tab Alias

	# 2. On SM, go to Administration -> Priority for Event Setting
	# 3. DO NOT Check priority for 2 these event (uncheck if they are checked)
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    Select Main Menu    Administration/Events    Priority Event Settings
    Set Priority Event Checkbox    ${EVENT_INSERT}    ${False}
    Set Priority Event Checkbox    ${EVENT_REMOVE}    ${False}
    
	# 4. Go to Administration -> Optional Event Settings
	# 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
	Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=True
    
	# 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
	Select Main Menu    Site Manager
	Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
	Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
	Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    
	...    quareoType=${QUAREO_TYPE}    name=${DEVICE_NAME}    ipAddress=${device_ip}
	Synchronize By Context Menu On Site Tree    ${tree_node_device}    ${DELIMITER}
    Wait Until Device Synchronize Successfully    ${device_ip}
    Close Quareo Synchronize Window

	# 7. Create patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    treeNode=${tree_node_device}${DELIMITER}${module_1}    objectName=${DEVICE_PORT_01}    delimiter=${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=${DELIMITER}  
	Create Work Order

	# 8. Set "Static (Front)" for Device 01/03
	Edit Port On Content Table    ${tree_node_device}${DELIMITER}${module_1}    name=${DEVICE_PORT_03}    
	...    staticFront=${True}    delimiterTree=${DELIMITER}

	# 9. On simulator:
	# _Add managed connection between Device 01/01 and Device 01/02
	Switch Window    ${simulator}
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    10101011
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}

	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    10101012
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}

	# _Create unmanaged connection for Device 01/04 and
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    
	
	# _Create managed connecion from Device 01/r01 to Device 01/r02
	${cableId}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    10101013
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# 10. On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}

	# 11. Select Device 01 Go to Event Log  then observe result
	Open Events Window
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=1
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=2
	Check Event Exist On Event Log Table    ${EVENT_INSERT}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_INSERT_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_INSERT}    position=3    delimiter=->
	Locate Event On Event Log    ${EVENT_INSERT}    position=1
	Close Event Log
	Check Table Row Map With Header Checkbox Selected On Content Table    headers=Name    values=${DEVICE_PORT_04}

	# 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
	Open Patching Window    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Create Patching    patchFrom=${tree_node_device}${DELIMITER}${module_1}    patchTo=${tree_node_device}${DELIMITER}${module_1}    
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}   typeConnect=Disconnect    delimiterTree=${DELIMITER}

	# 13. On Simulator, remove all connection (managed and unmanaged)
	Switch Window    ${simulator}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_02}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_03}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${DEVICE_PORT_04}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r01}    portStatus=${Port Status Empty}
	Edit Quareo Simulator Port Properties    ${device_ip}    ${moduleID_01}    ${r02}    portStatus=${Port Status Empty}

	# 14.  On SM Select Device 01 and observe ports on contents pane
	Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_01}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_02}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_03}    ${DELIMITER}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}${DELIMITER}${module_1}    ${DEVICE_PORT_04}    ${DELIMITER}

	# 15. Go to Event Log and Priority Event Log then observe result
	Open Events Window
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=1
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=2
	Check Event Exist On Event Log Table    ${EVENT_REMOVE}    position=3
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_04}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=1    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_02}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=2    delimiter=->
	Check Event Details On Event Log    eventDetails=${EVENT_REMOVE_DETAILS}->${DEVICE_PORT_01}->${DEVICE_NAME},${module_1}->${POSITION_RACK_NAME}->${SITE_NODE},${BUILDING_NAME},${floor_name},${ROOM_NAME}
	...    eventDescription=${EVENT_REMOVE}    position=3    delimiter=->
    Close Event Log
    
    Open Events Window    ${Priority Event Log}
    Check Event Not Exist On Event Log Table    ${EVENT_INSERT}
    Check Event Not Exist On Event Log Table    ${EVENT_REMOVE}
    Close Event Log
