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

Force Tags    SM-29926
Default Tags    Quareo Event

*** Variables ***
${BUILDING_NAME}    Q2000
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 Rack 001
${DEVICE_01}    Q2000 24 Port 01
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
${Quareo Discovery Folder}    Quareo Discovery Folder

*** Test Cases ***
SM-29926_01_Verify that SM will generate event "Plug Inserted in Quareo Port" and "Plug Removed from Quareo Port" if user plugs or unplugs quareo port of Q2000 device
    [Setup]    Run Keywords     Set Test Variable    ${ip_address_01}    10.10.10.1
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building    ${BUILDING_NAME}
    ...    AND    Add New Building   ${BUILDING_NAME}
    
    [Teardown]    Run Keywords     Delete Simulator    ${ip_address_01}
    ...    AND    Delete Building     ${BUILDING_NAME}
    ...    AND    Close Browser
    
    ${floor_name}    Set Variable    TC1
    ${tree_node_device}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    
    # 1. On Quareo Simulator, add a Q2000 Device (24 or 48 ports; e.g. 10.10.10.1)
    Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${Q2000}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${simulator}    Get Current Tab Alias  
    # # 2. On SM, go to Administration -> Priority for Event Setting
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
    # 6. Go to Site manager , Add Quareo Device 01 with IP in Step 1 into Rack 001 and sync it successfully
    Select Main Menu    Site Manager
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Add Floor    ${SITE_NODE}/${BUILDING_NAME}    ${floor_name}
    Add Room    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}    ${RACK_NAME}
	Wait For Object Exist On Content Table    ${POSITION_RACK_NAME} 
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${Q2000} 24 Port    ${DEVICE_01}    ${ip_address_01}
    Synchronize By Context Menu On Site Tree    ${tree_node_device}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    # 7. Create patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}    patchTo=${tree_node_device}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    createWo=yes   clickNext=yes
    Create Work Order
    # 8. Set "Static" for Device 01/03
    Edit Port On Content Table    ${tree_node_device}    ${DEVICE_PORT_03}    static=${True}   
    # 9. On simulator:
    # _Add managed connection between Device 01/01 and Device 01/02
    Switch Window    ${simulator}
	${moduleID_01} =    Get Quareo Module Information    ${ip_address_01}    1
	${cableId}    Generate Cable Template    H1RJ45-T1RJ45    01000001
	${heads}    Set Variable    @{cableId}[0]
	${tails}    Set Variable    @{cableId}[1]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_01}    @{heads}[0]    portStatus=${Port Status Managed}
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_02}    @{tails}[0]    portStatus=${Port Status Managed}
	# _Create managed connection for Device 01/03
	${cableId}    Generate Cable Template    H1RJ45-T1RJ45    01000002
	${heads}    Set Variable    @{cableId}[0]
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_03}    @{heads}[0]    portStatus=${Port Status Managed}
	# _Create unmanaged connection for Device 01/04
	Edit Quareo Simulator Port Properties    ${ip_address_01}    ${moduleID_01}    ${DEVICE_PORT_04}
    # 10. On SM Select Device 01 and observe ports on contents pane
    # VP: Device 01/ 01,02,04 are marked priority
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}    ${DEVICE_PORT_02}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}    ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}    ${DEVICE_PORT_03}
    # 11. Select port 01, 02, 04 and go to Event Log for Object then observe result
    # VP: Event "Plug Inserted in Quareo Port" is displayed
    Open Events Window    Event Log for Object    ${tree_node_device}    ${DEVICE_PORT_01}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    Open Events Window    Event Log for Object    ${tree_node_device}    ${DEVICE_PORT_02}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    Open Events Window    Event Log for Object    ${tree_node_device}    ${DEVICE_PORT_04}
    Check Event Exist On Event Log Table    ${EVENT_ADDED_DETAIL}
    Clear Event On Event Log    All    ${EVENT_ADDED_DETAIL}        
    Close Event Log
    # 12. Clear all events then remove patching from Device 01/01 to Device 01/02 with creating WO
    Open Patching Window    ${tree_node_device}    ${DEVICE_PORT_01}
    Create Patching    patchFrom=${tree_node_device}    patchTo=${tree_node_device}
    ...    portsFrom=${DEVICE_PORT_01}    portsTo=${DEVICE_PORT_02}    typeConnect=Disconnect    createWo=yes   clickNext=yes
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
    # VP: Device 01/ 01,02,04 are marked priority
    # VP: Device 01/03 is not marked due to user set static on this port (unmoniter)
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}    ${DEVICE_PORT_01}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}     ${DEVICE_PORT_02}
    Check Priority Event Icon Object On Content Pane    ${tree_node_device}     ${DEVICE_PORT_04}
    Check Priority Event Icon Object Not Exist On Content Pane    ${tree_node_device}    ${DEVICE_PORT_03}
    # 15. Go to Event Log then observe result
    # VP: 3 Events "Plug Removed from Quareo Port"  are displayed
    Open Events Window    Event Log for Object    ${tree_node_device}    ${DEVICE_PORT_01}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}   
    Close Event Log 
    Open Events Window    Event Log for Object    ${tree_node_device}    ${DEVICE_PORT_02}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}   
    Close Event Log
    Open Events Window    Event Log for Object    ${tree_node_device}    ${DEVICE_PORT_04}
    Check Event Exist On Event Log Table    ${EVENT_REMOVED_DETAIL}   
    Close Event Log
    