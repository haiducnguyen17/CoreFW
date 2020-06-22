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
Library    ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/system_manager/AdmLoggingOptionsPage${PLATFORM}.py               

Force Tags    SM-29926
Default Tags    Quareo Event

*** Variables ***
${BUILDING_NAME}    29926_QHDEP
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 Rack 001
${DEVICE_01}    QHDEP Chassis 01
${DEVICE_02}    QHDEP Chassis 02
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
${MODULE_01_PASS-THROUGH}    Module 01 (Pass-Through)    
${MODULE_01_MPO24-HD}    Module 01 (MPO24-HD)    
${MODULE_01_2MPO124-ABBA}    Module 01 (2xMPO12-AB/BA)

*** Test Cases ***
SM-29926_11_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of QHDEP device with Module Type is "F12LCDuplex-R12LCDuplex"
    [Setup]    Run Keywords    Open Simulator Quareo Page      
    ...    AND    Set Test Variable    ${ip_address_01}    10.10.10.11
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}
 
    [Teardown]    Run Keywords    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Close Browser
    
    [Tags]    Sanity

    ${floor_name}    Set Variable    TC11
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
     
    # 1. On Quareo Simulator, add a Q2000 Device (24 or 48 ports; e.g. 10.10.10.1)
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F12LCDuplex-R12LCDuplex}    
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias
	  
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}      
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
    
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Never"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Never    trackButtonPresses=${TRUE}
    
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}	   
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/03
    Edit Port On Content Table    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}    staticFront=${True}   
	
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${cableIds}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    11111111    
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
    ${cableIds}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    22222222
	${heads}    Set Variable    @{cableIds}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}
	
    # _Create unmanaged connection for Device 01/04 and Device 01/r03
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r03        

    # _Create managed connecion from Device 01/r01 to Device 01/r02
    ${cableIds}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    33333333
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r01     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r02     @{tails}[0]    portStatus=${Port Status Managed}
	
    # 10. On SM Select Device 01 and observe ports on contents pane
    # Device 01/ 01,02,04 are marked priority
    # Device 01/03 is not marked due to user set static on this port (unmoniter)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    
    # 11. Go to Event Log then observe result
    # There is no event "Plug Inserted in Quareo Port" is displayed
    Open Events Window    Event Log    ${tree_node_device}
    Check Event Not Exist On Event Log Table    ${EVENT_NAME_1}
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO
    Clear Event On Event Log    All
    Close Event Log
    
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connections (managed and unmanaged)
    Switch Window    ${simulator}
    
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r03     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r01     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r02     portStatus=Empty   
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    # There is no port is marked priority
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    
    # 15. Go to Event Log then observe result
    # There is no event "Plug Removed from Quareo Port" is displayed
    Open Events Window    Event Log    ${tree_node_device}
    Check Event Not Exist On Event Log Table    ${EVENT_NAME_2}
    
SM-29926_12_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of QHDEP device with Module Type is "F12LCDuplex-R1MPO24-HD"
    [Setup]    Run Keywords    Open Simulator Quareo Page
    ...    AND    Set Test Variable    ${ip_address_01}    10.10.10.12
    ...    AND    Set Test Variable    ${ip_address_02}    10.10.10.13
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}   
    
    [Teardown]    Run Keywords    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC12
    ${r01}    Set Variable    r01%2d12
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    ${tree_node_device_2}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
     
    # 1. On Quareo Simulator, add a QHDEP Device 01, 02 with Module Type is "F12LCDuplex-R1MPO24-HD"(e.g. 10.10.10.12 and 10.10.10.13)
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F12LCDuplex-R1MPO24-HD}
	Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F12LCDuplex-R1MPO24-HD}        
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${moduleID_02} =    Get Quareo Module Information    ${ip_address_02}    1
    ${simulator}    Get Current Tab Alias
	  
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Never"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=${TRUE}
    
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}	
    
    # 6. Go to Site manager , Add Quareo Device 01, 02 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME} 
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_02}    ${ip_address_02}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    Synchronize By Context Menu On Site Tree    ${tree_node_device_2}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 02/01 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_MPO24-HD}    patchTo=${tree_node_device_2}/${MODULE_01_MPO24-HD}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_01}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/02
    Edit Port On Content Table    ${tree_node_device}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_02}    staticFront=${True}   
	
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 02/01
    Switch Window    ${simulator}
	${cableIds}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    11111111    
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_01}     @{tails}[0]    portStatus=${Port Status Managed}
	
    # _Create managed connection for Device 01/02
    ${cableIds}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoA    22222222
	${heads}    Set Variable    @{cableIds}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     @{heads}[0]    portStatus=${Port Status Managed}
	
    # _Create unmanaged connection for Device 02/02 
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_02}     

    # _Create managed connecion from Device 01/r01 to Device 02/r01
    ${cableIds}    Generate Cable Template    H1MPO24-T1MPO24-STRAIGHT    33333333
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${r01}     @{tails}[0]    portStatus=${Port Status Managed}
	
    # 10. On SM Select Device 02 and observe ports on contents pane
 
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    
            # Device 02/02 is marked priority
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_2}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_02}
            # Device 01/01, Device 02/01 are not marked due to these are scheduled connection
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_2}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_01}
            # Device 01/02 is not marked due to user set static on this port (unmoniter)
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_02}
            # Device 01/ r01, Device 02/r01 is not marked due to these are rear ports
            
    # 11. Select Device 02/02 Go to Event Log for Object then observe result
        # _Event "Plug Inserted in Quareo Port" is displayed for Device 02/02
        # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Event Log for Object    ${tree_node_device_2}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_02}
    Check Event Exist On Event Log Table    ${EVENT_NAME_1}
    Locate Event On Event Log    ${EVENT_NAME_1}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_02}
    
    # 12. Remove patching from Device 01/01 to Device 02/01 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_MPO24-HD}    patchTo=${tree_node_device_2}/${MODULE_01_MPO24-HD}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_01}    typeConnect=Disconnect    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_01}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${DEVICE_PORT_02}     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${r01}     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_02}    ${moduleID_02}    ${r01}     portStatus=Empty
    
    # 14. On SM Select Device 01, 02 and observe ports on contents pane
        # Device 02/02 is marked priority
        # Device 01/01, Device 02/01 are not marked due to these are scheduled connection
        # Device 01/02 is not marked due to user set static on this port (unmoniter)
        # Device 01/ r01, Device 02/r01 is not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device_2}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device_2}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_MPO24-HD}    ${DEVICE_PORT_02}

    # 15. Go to Priority Event Log then observe result
        # _Event "Plug Removed from Quareo Port"  is displayed for Device 02/02
        # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Priority Event Log    ${tree_node_device_2}
    Check Event Exist On Event Log Table    ${EVENT_NAME_2}
    Locate Event On Event Log    ${EVENT_NAME_2}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_02}
    
SM-29926_13_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of QHDEP device with Module Type is "F12LCDuplex-R2MPO12-Flipped"
    [Setup]    Run Keywords    Open Simulator Quareo Page
    ...    AND    Set Test Variable    ${ip_address_01}    10.10.10.14
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}     
    
    [Teardown]    Run Keywords    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable     TC13
    ${r01}    Set Variable    r01%2d06
    ${r02}    Set Variable    r07%2d12
    ${tree_node_device}    Set Variable    ${SITE_NODE}>${BUILDING_NAME}>${floor_name}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_01}
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
     
    # On Quareo Simulator, add a QHDEP Device with Module Type is "F12LCDuplex-R2MPO12-Flipped"(e.g. 10.10.10.14)
    
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F12LCDuplex-R2MPO12-Flipped}        
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
    ${simulator}    Get Current Tab Alias
	  
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=${TRUE}
    
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}	
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME} 
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}    delimiter=>
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_01}    delimiter=>
    Create Patching    patchFrom=${tree_node_device}>${MODULE_01_2MPO124-ABBA}    patchTo=${tree_node_device}>${MODULE_01_2MPO124-ABBA}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    delimiterTree=>    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # Set "Static (Front)" for Device 01/03
    Edit Port On Content Table    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_03}    staticFront=${True}    delimiterTree=>   
	
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${cableIds}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    11111111    
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
    # Create managed connection for Device 01/03
    ${cableIds}    Generate Cable Template    H1LCDuplex-T1LCDuplex-AtoB    22222222
	${heads}    Set Variable    @{cableIds}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}
	
    # Create unmanaged connection for Device 01/04
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     

    # _Create managed connecion from Device 01/r01 to Device 01/r02
    ${cableIds}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    33333333
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${r01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${r02}     @{tails}[0]    portStatus=${Port Status Managed}
	
    # 10. On SM Select Device 01 and observe ports on contents pane
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    
    # Device 01/ 01,02,04 are marked priority
    # Device 01/03 is not marked due to user set static on this port (unmoniter)
    # Device 01/ r01, r02 are not marked due to these are rear ports
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_01}    delimiter=>
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_02}    delimiter=>
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_04}    delimiter=>
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_03}    delimiter=>
            
    # 11. Select Device 01/04 Go to Event Log for Object then observe result
        # _Event "Plug Inserted in Quareo Port" is displayed
        # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Event Log for Object    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_04}    delimiter=>
    Check Event Exist On Event Log Table    ${EVENT_NAME_1}
    Locate Event On Event Log    ${EVENT_NAME_1}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
    # 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
    Open Events Window    Priority Event Log
    Clear Event On Event Log    All    
    Close Event Log

    Open Patching Window    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_01}    delimiter=>
    Create Patching    patchFrom=${tree_node_device}>${MODULE_01_2MPO124-ABBA}    patchTo=${tree_node_device}>${MODULE_01_2MPO124-ABBA}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    delimiterTree=>    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connection (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${r01}     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${r02}     portStatus=Empty
    
    # 14. On SM Select Device 01 and observe ports on contents pane
        # Device 01/ 01,02,04 are marked priority
        # Device 01/03 is not marked due to user set static on this port (unmoniter)
        # Device 01/ r01, r02, r03 is not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_01}    delimiter=>
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_02}    delimiter=>
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_04}    delimiter=>
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}>${MODULE_01_2MPO124-ABBA}    ${DEVICE_PORT_03}    delimiter=>

    # 15. Go to Priority Event Log then observe result
        # _3 Events "Plug Removed from Quareo Port"  are displayed
        # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_NAME_2}
    Locate Event On Event Log    ${EVENT_NAME_2}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
SM-29926_14_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of QHDEP device with Module Type is "F24LCSimplex-R24LCSimplex"
    [Setup]    Run Keywords    Open Simulator Quareo Page
    ...    AND    Set Test Variable    ${ip_address_01}    10.10.10.15
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}  
    
    [Teardown]    Run Keywords    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC14
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
     
    # 1. On Quareo Simulator, add a QHDEP Device with Module Type is "F24LCSimplex-R24LCSimplex"(e.g. 10.10.10.15)
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F24LCSimplex-R24LCSimplex}    
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias
	  
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}    
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
    
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Unscheduled"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Unscheduled    trackButtonPresses=${TRUE}
    
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}	
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/03
    Edit Port On Content Table    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}    staticFront=${True}   
	
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${cableIds}    Generate Cable Template    H1LCSimplex-T1LCSimplex    11111111    
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
    ${cableIds}    Generate Cable Template    H1LCSimplex-T1LCSimplex    22222222
	${heads}    Set Variable    @{cableIds}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}
	
    # _Create unmanaged connection for Device 01/04 and Device 01/r03
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r03        

    # _Create managed connecion from Device 01/r01 to Device 01/r02
    ${cableIds}    Generate Cable Template    H1LCSimplex-T1LCSimplex    33333333
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r01     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r02     @{tails}[0]    portStatus=${Port Status Managed}
	
    # 10. On SM Select Device 01 and observe ports on contents pane
        # Device 01/04 is marked priority
        # Device 01/01,02 are not marked due to these are scheduled connection
        # Device 01/03 is not marked due to user set static on this port (unmoniter)
        # Device 01/ r01, r02, r03 is not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    
    # 11. Select Device 01/04 Go to Event Log for Object then observe result
    # _Event "Plug Inserted in Quareo Port" is displayed for Device 01/04
    # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Event Log for Object    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Event Exist On Event Log Table    ${EVENT_NAME_1}
    Locate Event On Event Log    ${EVENT_NAME_1}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO 
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connections (managed and unmanaged)
    Switch Window    ${simulator}
    
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r03     portStatus=Empty
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r01     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r02     portStatus=Empty   
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    # Device 01/04 is marked priority
    # Device 01/01,02 are not marked due to these are scheduled connection
    # Device 01/03 is not marked due to user set static on this port (unmoniter)
    # Device 01/ r01, r02, r03 is not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    
    # 15. Go to Priority Event Log then observe result
    # _Event "Plug Removed from Quareo Port"  is displayed for Device 01/04
    # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Priority Event Log
    Check Event Exist On Event Log Table    ${EVENT_NAME_2}
    Locate Event On Event Log    ${EVENT_NAME_2}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
SM-29926_15_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of QHDEP device with Module Type is "F24LCSimplex_CMOD"
    [Setup]    Run Keywords    Open Simulator Quareo Page
    ...    AND    Set Test Variable    ${ip_address_01}    10.10.10.16
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}  
    
    [Teardown]    Run Keywords    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC15 
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
     
    # 1. On Quareo Simulator, add a QHDEF Device F24LCSimplex_CMOD (e.g. 10.10.10.16)
    
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F24LCSimplex_CMOD}    
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias
	  
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}   
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
    
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}
    Set Priority Event Checkbox    ${EVENT_NAME_2}
    
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=${TRUE}
    
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}	
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/03
    Edit Port On Content Table    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}    staticFront=${True}   
	
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${cableIds}    Generate Cable Template    H1LCSimplex-T1LCSimplex    11111111    
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
    ${cableIds}    Generate Cable Template    H1LCSimplex-T1LCSimplex    22222222
	${heads}    Set Variable    @{cableIds}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}
	
    # _Create unmanaged connection for Device 01/04
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     
	
    # 10. On SM Select Device 01 and observe ports on contents pane
    # Device 01/ 01,02,04 are marked priority
    # Device 01/03 is not marked due to user set static on this port (unmoniter)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    
    # 11. Select port 01, 02, 04 and go to Event Log for Object then observe result
    # _Event "Plug Inserted in Quareo Port" is displayed
    # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Event Log for Object    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Event Exist On Event Log Table    ${EVENT_NAME_1}
    Locate Event On Event Log    ${EVENT_NAME_1}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_01}
    
    Open Events Window    Event Log for Object    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Event Exist On Event Log Table    ${EVENT_NAME_1}
    Locate Event On Event Log    ${EVENT_NAME_1}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_02}
    
    Open Events Window    Event Log for Object    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Event Exist On Event Log Table    ${EVENT_NAME_1}
    Locate Event On Event Log    ${EVENT_NAME_1}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connections (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     portStatus=Empty 
    
    # 14. On SM Select Device 01 and observe ports on contents pane
    # Device 01/ 01,02,04 are marked priority
    # Device 01/03 is not marked due to user set static on this port (unmoniter)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    
    # 15. Go to Event Log then observe result
    # _3 Events "Plug Removed from Quareo Port"  are displayed
    # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Event Log    ${tree_node_device}/${MODULE_01_PASS-THROUGH}
    Check Event Exist On Event Log Table    ${EVENT_NAME_2}
    Locate Event On Event Log    ${EVENT_NAME_2}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
SM-29926_16_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of QHDEP device with Module Type is "F8MPO12-R8MPO12"
    [Setup]    Run Keywords    Open Simulator Quareo Page
    ...    AND    Set Test Variable    ${ip_address_01}    10.10.10.17
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building    ${BUILDING_NAME}   
    
    [Teardown]    Run Keywords    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC16
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    ${today}    Get Current Date Time    resultFormat=%Y-%m-%d
    ${tomorrow}    Add Time To Date Time    ${today}    1 day    result_format=%Y-%m-%d
     
    # 1. On Quareo Simulator, add a QHDEF Device F8MPO12-R8MPO12 (e.g. 10.10.10.17)
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${QHDEP}    modules=${F8MPO12-R8MPO12}    
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias
	  
    # 2. On SM, go to Administration -> Priority for Event Setting
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}    
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${QHDEP} Chassis    ${DEVICE_01}    ${ip_address_01}
    
    # 3. Check priority for 2 these event (if theys are not checked)
    Select Main Menu    Administration/Events    Priority Event Settings    
    Set Priority Event Checkbox    ${EVENT_NAME_1}    ${FALSE}
    Set Priority Event Checkbox    ${EVENT_NAME_2}    ${FALSE}
    
    # 4. Go to Administration -> Optional Event Settings
    # 5. Check on "Track Button Presses" with "Track Patch Plug Insertions and Removals" option is "Always"
    Select Main Menu    subItem=Optional Event Settings
    Set Optional Event Setting    Always    trackButtonPresses=${TRUE}
    
    Select Main Menu    subItem=Logging Options
    Clear Sm Logging Options    ${Event Log}    clearingMethod=Manual    clearEntries=Custom    selectedDate=${tomorrow}	
    
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 8. Set "Static (Front)" for Device 01/03
    Edit Port On Content Table    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}    staticFront=${True}   
	
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${cableIds}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    11111111    
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     @{tails}[0]    portStatus=${Port Status Managed}
	
	# _Create managed connection for Device 01/03
    ${cableIds}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    22222222
	${heads}    Set Variable    @{cableIds}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     @{heads}[0]    portStatus=${Port Status Managed}
	
    # _Create unmanaged connection for Device 01/04
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     
    
    # _Create managed connecion from Device 01/r01 to Device 01/r02
    ${cableIds}    Generate Cable Template    H1MPO12-T1MPO12-STRAIGHT    33333333
	${heads}    Set Variable    @{cableIds}[0]
	${tails}    Set Variable    @{cableIds}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r01     @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    r02     @{tails}[0]    portStatus=${Port Status Managed}
	
    # 10. On SM Select Device 01 and observe ports on contents pane
    # Device 01/ 01,02,04 are not marked priority
    # Device 01/03 is not marked due to user set static on this port (unmoniter)
    # Device 01/ r01, r02 are not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    
    # 11. Select Device 01/04 Go to Event Log for Object then observe result
    # _Event "Plug Inserted in Quareo Port" is displayed
    # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Event Log for Object    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Event Exist On Event Log Table    ${EVENT_NAME_1}
    Locate Event On Event Log    ${EVENT_NAME_1}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
    # 12. Remove patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}/${MODULE_01_PASS-THROUGH}    patchTo=${tree_node_device}/${MODULE_01_PASS-THROUGH}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    createWo=${True}   clickNext=${True}
    Create Work Order
    
    # 13. On Simulator, remove all connections (managed and unmanaged)
    Switch Window    ${simulator}
    Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}     portStatus=Empty
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}     portStatus=Empty 
    
    # 14.  On SM Select Device 01 and observe ports on contents pane
    # Device 01/ 01,02,04 are not marked priority
    # Device 01/03 is not marked due to user set static on this port (unmoniter)
    # Device 01/ r01, r02 are not marked due to these are rear ports
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}/${MODULE_01_PASS-THROUGH}    ${DEVICE_PORT_03}
    
    # 15. Go to Event Log and Priority Event Log then observe result
    # _3 Events "Plug Removed from Quareo Port"  are displayed only in Event Log not in Priority Event Log
    # _Locate button is enabled and locate to correct port when clicking it
    Open Events Window    Event Log    ${tree_node_device}/${MODULE_01_PASS-THROUGH}
    Check Event Exist On Event Log Table    ${EVENT_NAME_2}
    Check Number Of Event    ${EVENT_NAME_2}    expectedValue=3
    Locate Event On Event Log    ${EVENT_NAME_2}
    Close Event Log
    Check Table Row Map With Header Checkbox Selected On Content Table    Name    ${DEVICE_PORT_04}
    
    Open Events Window    Priority Event Log    ${tree_node_device}/${MODULE_01_PASS-THROUGH}
    Check Event Not Exist On Event Log Table    ${EVENT_NAME_2}
    Close Event Log