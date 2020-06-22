*** Settings ***
Resource    ../../../../../resources/icons_constants.robot
Resource    ../../../../../resources/constants.robot

Library    ../../../../../py_sources/logigear/api/SimulatorApi.py
Library    ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library    ../../../../../py_sources/logigear/setup.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py  
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py 
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/history/circuit_history/CircuitHistoryPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/quareo_simulator/QuareoDevicePage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/synchronization/SynchronizationPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/quareo_unmanaged_connections/QuareoUnmanagedConnectionsPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_history/WorkOrderHistoryPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py   
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/system_manager/AdmFeatureOptionsPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/users/AdmSystemManagerUsersPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/api/SimulatorApi.py 
Library    ../../../../../py_sources/logigear/api/BuildingApi.py

Default Tags    Connectivity
Force Tags    SM-29804_SM-29805

*** Variables ***
${FLOOR_NAME}    Floor 01
${RACK_NAME}    Rack 01
${RACK_NAME_2}    Rack 02
${ROOM_NAME}    Room 01
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${POSITION_RACK_NAME}    1:1 Rack 01
${POSITION_RACK_NAME_2}    1:2 Rack 02
${DEVICE_01}    Device 01
${DEVICE_02}    Device 02
${MODULE_01}    Module 01
${SWITCH_01}    Switch 01
${MODULE_01_PASS-THROUGH}    Module 01 (Pass-Through)
${SERVER_01}    Server 01
${GBIC_SLOT}    GBIC Slot 01
${Patching 6x}    Patching 6x
${admin}    ${USERNAME}
${Patching}    Patching
${column_1}    Work Order,Summary,Technician,Status
${column_2}    Work Order,Summary,Technician,Status,Earliest Date,Latest Date
${column_3}    Work Order,Summary,Status
${CARD_01}    Card 01

*** Test Cases ***
SM-29804_SM-29805_01_Verify that the user cannot patch Quareo port with new MPO12-6xLC assembly
    [Teardown]    Run Keywords     Close Browser
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Building     ${building_name}
    
    ${ip_address_01}    Set Variable     1.1.1.1
    ${ip_address_02}    Set Variable     2.2.2.2
    ${building_name}    Set Variable    BD_SM29804_01
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}

	# * On Simulator:
	# _Enable middlware config
	# _Add Q4000 device 01 F16MPO12-R16MPO12 with un-populate data 
	# _Add Q4000 device 02 F24LCDuplex-R24LC Duplex
	Open Simulator Quareo Page
	Add Simulator Quareo Device    ${ip_address_01}    deviceType=${Q4000}    modules=${F16MPO12-R16MPO12}
	Add Simulator Quareo Device    ${ip_address_02}    deviceType=${Q4000}    modules=${F24LCDuplex-R24LCDuplex}
	${simulator}    Get Current Tab Alias 	
	
	# # * On SM:
	# # 3. Add Quareo devices in pre-condition to Rack 001 and sync successfully
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${building_name}
    # ${buildingID}=    Add New Building    ${building_name}
    # Reload Page
	Create Object    buildingName=${building_name}   floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Quareo    ${tree_node_rack}    ${Q4000 1U Chassis}    ${DEVICE_01}    ${ip_address_01}
    Add Quareo    ${tree_node_rack}    ${Q4000 1U Chassis}    ${DEVICE_02}    ${ip_address_02}
    Synchronize By Context Menu On Site Tree    ${tree_node_rack}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    Synchronize By Context Menu On Site Tree    ${tree_node_rack}/${DEVICE_02}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window    
    
	# 4. Add LC Generic Panel 01 to Rack 001
	Add Generic Panel    ${tree_node_rack}    name=${PANEL_NAME_1}   portType=${LC}

	# 5. Select Q4000 01/Module 01/01 and open Patching window
    Open Patching Window    ${tree_node_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    ${01}

	# 6. Select Panel 01/01 in To pane
    Click Tree Node Patching    To    ${tree_node_rack}/${PANEL_NAME_1}/${01}    	

	# 7. Observe new connection assembly
	# * Step 7: The new connection assembly (MPO12-6xLC) is disabled
	Check Mpo Connection Type State On Patching Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
	
	# 8. Close Patching window
    Close Patching Window	

	# 9. Set Static (Front) for ports:
	# _Q4000 01/Module 01/01
	# _Q4000 02/Module 01/01 
	Edit Port On Content Table    ${tree_node_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    name=${01}    staticFront=${True}
	Edit Port On Content Table    ${tree_node_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}    name=${01}    staticFront=${True}

	# 10. Select Q4000 01/Module 01/01 and open Patching window
    Open Patching Window    ${tree_node_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    ${01}
	
	# 11. Select Panel 01/01 in To pane
    Click Tree Node Patching    To    ${tree_node_rack}/${PANEL_NAME_1}/${01}    	
	
	# 12. Observe new connection assembly
	Check Mpo Connection Type State On Patching Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
	
	# 13. Close Patching window
	Close Patching Window

	# 14. Select Q4000 01/Module 01/01 and open Patching window
    Open Patching Window    ${tree_node_rack}/${DEVICE_01}/${MODULE_01_PASS-THROUGH}    ${01}

	# 15. Select Q4000 02/Module 01/01 in To pane
    Click Tree Node Patching    To    ${tree_node_rack}/${DEVICE_02}/${MODULE_01_PASS-THROUGH}/${01}
	
	# 16. Observe new connection assembly
	Check Mpo Connection Type State On Patching Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    Close Patching Window

SM-29804_SM-29805_02_Verify that user can create/remove patch MPO12-6xLC from Panel port to Panel port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29804_02
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Select Main Menu    ${Administration}/${Users}
    ...    AND    Edit User Information     ${USERNAME}    ${True}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Building     ${building_name}
    
    [Teardown]    Run Keywords     Select Main Menu    ${Administration}/${Users}
    ...    AND    Edit User Information    ${USERNAME}    ${False}
    ...    AND    Close Browser
    ...    AND    Delete Building     ${building_name}

    [Tags]    Sanity

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${task_name_list}    Create List    Task1    Task2    Task3    Task4    Task5    Task6
    ${create_wo_task_name_list}    Create List    Task 1    Task 2    Task 3    Task 4    Task 5    Task 6
    ${position_list}    Create List     1    2    3    4    5    6
    ${tree_node_rack_task_list}    Set Variable    ${SITE_NODE} / ${building_name} / ${FLOOR_NAME} / ${ROOM_NAME} / ${POSITION_RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM29804_02
    ${task_1}    Set Variable    Task 1
    ${task_2}    Set Variable    Task 2
    ${task_3}    Set Variable    Task 3
    ${task_4}    Set Variable    Task 4
    ${task_5}    Set Variable    Task 5
    ${task_6}    Set Variable    Task 6
    
    # * On SM:
	# 3. Add MPO Panel 01 and LC Panel 02 with Alpha/Beta Module to Rack 001
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=${MPO}	
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_2}    ${Module 1A},True,${LC 12 Port},${Beta}
    
	# 4. Open Patching window
	Open Patching Window    

	# 5. Select MPO12 and MPO24 Connection Type tab and observe connection icon
	# Step 5: There should be MPO12-6xLC ULL Assembly icon in MPO12 Connection tab
    # _The new image of the new MPO12 to 6xLC fiber assembly should be shown on Patching window
    Check Mpo Connection Type State On Patching Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
	
	# 6. Select Panel 01/01 at Patch From pane
	Click Tree Node Patching    From    ${tree_node_rack}/${PANEL_NAME_1}/${01}

	# 7. Select MPO12-6xLC EB icon and observe the pairs on the Patching window
	# Step 7: Pairs number should be started from Pair 1,Pair 2, Pair 3, Pair 4, Pair 5, Pair 6.
	Check Mpo Connection Type Information On Patching Window    ${MPO12}    ${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}

	# 8. Patch from Panel 01/01 (MPO12-6xLC) to Panel 02/01->06
	# 9. Click on Connect button
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Beta})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${False} 

    # 10. Observe the Circuit Trace and Task List tabs
    Select View Tab On Patching    ${Circuit Trace}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
	\    Check Trace Object On Patching    indexObject=1    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=None    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=None    
	...    objectType=${TRACE_360_INSTAPATCH_FIBER_SHELF}    informationDevice=${port_list}[${i}]->${Module 1A} (${Beta})->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Tab On Patching    ${Task List}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Check Task List Information On Patching Window    position=${position_list}[${i}]    name=${task_name_list}[${i}]    taskType=${Add Patch}    treeFrom=${tree_node_rack_task_list} / ${PANEL_NAME_1} / ${01} / ${pair_list_1}[${i}]
	...    connectionType=${Connect}    treeTo=${tree_node_rack_task_list} / ${PANEL_NAME_2} / ${Module 1A} (${Beta}) / ${port_list}[${i}]
    
	# 11. Click on Check Mark button and observe
    # 12. Continue to create work order until done
	Save Patching Window
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Check Task List Information On Create Wo Window    position=${position_list}[${i}]    name=${create_wo_task_name_list}[${i}]    taskType=${Add Patch}    treeFrom=${tree_node_rack}/${PANEL_NAME_1}/${01}/${pair_list_1}[${i}]
	...    connectionType=${Connect}    treeTo=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Beta})/${port_list}[${i}]
	Create Work Order    woName=${tc_wo_name}	summary=${Patching 6x}	priority=${High}	
	...    technician=${admin}    scheduling=${Immediate}
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}
	Select Object On Content Table    ${01}
	Wait For Work Order Icon On Content Table    ${01}
	# 13. Open WO window and expand WO observe
	# Step 13: The status of WO should be On-Hold.
    # _The correct information of patching with the new assembly should be shown in Work Order Queue window.
    Open Work Order Queue Window
    Check Wo Information On Wo Queue    ${column_1}    ${tc_wo_name},${Patching 6x},${admin},${Immediate}
    ...    priority=${High}    scheduling=${Immediate}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Check Task List Information On Work Order Queue Window    position=${position_list}[${i}]    name=${create_wo_task_name_list}[${i}]    taskType=${Add Patch}    treeFrom=${tree_node_rack}/${PANEL_NAME_1}/${01}/${pair_list_1}[${i}]
	...    connectionType=${Connect}    treeTo=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Beta})/${port_list}[${i}]
    Close Work Order Queue

	# 14. Open WO History window and observe
    Open Work Order History Window
    ${headers}    Set Variable    Work Order,Task,Type,Username
    ${values_list}    Create List
    ...    ${tc_wo_name},${task_1},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_2},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_3},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_4},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_5},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_6},${Add Patch},${admin}
    
    ${rows_list}    Create List    1    2    3    4    5    6
    
    Expand Wo In Wo History    ${tc_wo_name}    ${Immediate}
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Wo History Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
    Close Wo History Window

	# 15. Open WO Queue window and complete the WO above
	Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue   
	 
    # Step 15: WO should be completed.
 	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
	:FOR    ${i}     IN RANGE    0    len(${pair_list_1})
 	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]
	\    Check Total Trace On Site Manager    2
	\    Check Trace Object On Site Manager    indexObject=1    mpoType=${12}    objectPosition=1 [${A1}]     objectPath=${tree_node_rack}/${PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Beta})/${port_list}[${i}]    
	...    objectType=${TRACE_360_INSTAPATCH_FIBER_SHELF}    informationDevice=${port_list}[${i}]->${Module 1A} (${Beta})->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window     

	# 16. Open Patching window, create Remove Patching WO between Panel 01/01 (MPO12-6xLC) to Panel 02/01->06
	Open Patching Window
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Beta})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${False}
    
	# 17. Observe the Circuit Trace and Task List tabs
    Select View Tab On Patching    ${Circuit Trace}
	Check Trace Object On Patching    indexObject=1    mpoType=    objectPosition=1   objectPath=None    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Tab On Patching    ${Task List}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Check Task List Information On Patching Window    position=${position_list}[${i}]    name=${task_name_list}[${i}]    taskType=${Remove Patch}    treeFrom=${tree_node_rack_task_list} / ${PANEL_NAME_1} / ${01} / ${pair_list_1}[${i}]
	...    connectionType=Disconnect    treeTo=${tree_node_rack_task_list} / ${PANEL_NAME_2} / ${Module 1A} (${Beta}) / ${port_list}[${i}]
    Save Patching Window
    Create Work Order    woName=${tc_wo_name}
    Wait For Work Order Icon On Content Table    ${01}
    
	# 18. Open WO Queue window
	# 19. Complete this WO and observe
    Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}
	Close Work Order Queue

	# Step 19: WO should be completed.
	Open Trace Window    ${tree_node_rack}/${PANEL_NAME_1}    ${01}
    Check Trace Object On Site Manager    indexObject=1    mpoType=    objectPosition=1   objectPath=None    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
SM-29804_SM-29805_03_Verify that the Patching connection and WO are removed after deleting object
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29804_03
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Select Main Menu    ${Administration}/${Users}
    ...    AND    Edit User Information    ${USERNAME}    ${True}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Building     ${building_name}  
    
    [Teardown]    Run Keywords     Select Main Menu    ${Administration}/${Users}
    ...    AND    Edit User Information    ${USERNAME}    ${False}
    ...    AND    Close Browser
    ...    AND    Delete Building     ${building_name}

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}
    ${task_name_list}    Create List    Task1    Task2    Task3    Task4    Task5    Task6
    ${create_wo_task_name_list}    Create List    Task 1    Task 2    Task 3    Task 4    Task 5    Task 6
    ${tree_node_rack_task_list}    Set Variable    ${SITE_NODE} / ${building_name} / ${FLOOR_NAME} / ${ROOM_NAME} / ${POSITION_RACK_NAME}
    ${tc_wo_name}    Set Variable    WO_SM29804_03
	
	# * On SM:
	# 3. Add MPO Panel 01 and LC Panel 02 with Pass-Through Module to Rack 001
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
	Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_1}    portType=${MPO}
	Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_2}    ${Module 1A},True,${LC 6 Port},,

	# 4. Open Patching window, add Patch from:
	# _Panel 01/01 (MPO12-6xLC) to Panel 02/01->03
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    ...    portsFrom=${01}    portsTo=${01},${02},${03}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    Wait For Work Order Icon On Content Table    ${01}
    
	# 5. On SM, delete Panel 01 OR Panel 02
	Delete Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}
	
	# 6. Observe Patching connection and WO
	Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}  
	Select Object On Content Table    ${01}  
	Wait For Property On Properties Pane    ${Port Status}    ${Available}
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOUncabledAvailable}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    ${1}  
	
    Open Work Order Queue Window
	Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
	Close Work Order Queue
	
	Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_2}    ${Module 1A},True,${LC 6 Port},,
	
	# 7. Create Patching connection between Panel 01/01 (MPO12-6xLC) to Panel 02/01->05
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    Wait For Work Order Icon On Content Table    ${01}
    	
	# 8. Complete this WO 
	Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}    
	Close Work Order Queue
	
	# 9. Create Remove Patching connection between Panel 01/01 (MPO12-6xLC) to Panel 02/01->05
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}    
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}    patchTo=${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5}
    ...    createWo=${True}    clickNext=${True}
    Create Work Order    ${tc_wo_name}
    Wait For Work Order Icon On Content Table    ${01}
    
	# 10. Delete Panel 01 or Panel 02
	Delete Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}

	# 11. Observe Patching connection and WO
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    Select Object On Content Table    ${01}  
	Wait For Property On Properties Pane    ${Port Status}    ${Available}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledAvailable}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}  

SM-29804_SM-29805_04_Verify that user can create/remove patch MPO12-6xLC ULL Assembly from MPO InstaPatch port to Switch Port
### Note: work order which is assigned to a Technician Group and set Immediate
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29804_04
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Select Main Menu    ${Administration}/${Users}
    ...    AND    Edit User Information    ${USERNAME}    ${True}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Building     ${building_name}
    
    [Teardown]    Run Keywords     Select Main Menu    ${Administration}/${Users}
    ...    AND    Edit User Information    ${USERNAME}    ${False}
    ...    AND    Close Browser
    ...    AND    Delete Building     ${building_name}
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${tc_wo_name}    Set Variable    WO_SM29804_04
    ${trace_module1a}    Set Variable    ..le 1A (Pass-Through)
    ${position_list}    Create List     1    2    3    4    5    6
    ${task_1}    Set Variable    Task 1
    ${task_2}    Set Variable    Task 2
    ${task_3}    Set Variable    Task 3
    ${task_4}    Set Variable    Task 4
    ${task_5}    Set Variable    Task 5
    ${task_6}    Set Variable    Task 6 
    ${Patching 6x_update}    Set Variable    ${Patching 6x} Update  
    ${date_1}    Set Variable    2020-01-01    
    ${date_2}    Set Variable    2020-01-02

	# * On SM:
	# 3. Add to Rack 001:
	# _InstaPatch MPO Panel 01
	# _LC Switch/GBIC Slot 01
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_01}    
    Add Network Equipment Component    ${tree_node_rack}/${SWITCH_01}    componentType=${Network Equipment GBIC Slot}    name=${GBIC_SLOT}    portType=${LC}    totalPorts=6
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_1}    ${Module 1A},True,${MPO 2 Port},,
    
	# 4. Create a patching from Panel 01/Module 01/01 to Switch/GBIC Slot/1-1,..,6-6
	# _Work Order: WO 01
	# _Work Type: Patching
	# _Summary : Test
	# _Priority: Normal
	# _Scheduling: Immediate
	# _Technician: test
	# _Earliest Date: YYYY-MM-DD
	# _Latest Date: YYYY-MM-DD
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack}/${SWITCH_01}/${GBIC_SLOT}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${False}

	# 5. Observe port icons, port status, circuit in Patching window
	# * Step 5:
	# _Port icons:
	  # + Panel 01/Module 1A/01: patched icon
	  # + Switch/GBIC Slot/01-06: patched icon
	  # + Panel 01/Module 1A/01 icon shows as MPO 12 icon
	Check Icon Object On Patching Tree    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${PortMPOUncabledInUseScheduled}    
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
    \    Check Icon Object On Patching Tree    To    ${tree_node_rack}/${SWITCH_01}/${GBIC_SLOT}/${port_list}[${i}]    ${PortFDUncabledInUseScheduled}

    Check Icon Mpo Port Type On Patching Window    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${12}    
	# _Port status for ports: Available
	Check Port Status On Patching Window    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${Available}
    
	# _Circuit:
	  # + Tab 1-1: Panel 01/Module 1A/12 1 [A1] -> patched to (with schedule icon) -> Switch/GBIC Slot 01/1 [1-1] -> connected to -> service box
	  # + Tab 2-2: Panel 01/Module 1A/12 1 [A1] -> patched to (with schedule icon) -> Switch/GBIC Slot 01/2 [2-2] -> connected to -> service box
	  # ...
	  # + Tab 6-6: Panel 01/Module 1A/12 1 [A1] -> patched to (with schedule icon) -> Switch/GBIC Slot 01/6 [6-6] -> connected to -> service box	
    Select View Tab On Patching    ${Circuit Trace}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
	\    Check Trace Object On Patching    indexObject=1    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=None    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${trace_module1a}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=None    
	...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${port_list}[${i}]->${GBIC_SLOT}->${SWITCH_01}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_ASSIGN}
	\    Check Trace Object On Patching    indexObject=3    mpoType=None    objectPosition=     objectPath=None
    ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}
    Save Patching Window
    
	Create Work Order    woName=${tc_wo_name}	summary=${Patching 6x}	priority=${Normal}	
	...    technician=${admin}    scheduling=${Immediate}
	Wait For Work Order Icon On Content Table    ${01}   

	# 6. Open "Work Orders" menu then select Work Order Queue option
	Open Work Order Queue Window
    Check Wo Information On Wo Queue    ${column_1}    ${tc_wo_name},${Patching 6x},${admin},${Immediate}
    ...    priority=${Normal}    scheduling=${Immediate}
    Close Work Order Queue

	# 7. Select Panel 01/Module 01/01 and select Work Orders for Object
	Open Work Order For Object Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}

	# 8. Observe the information
    Check Wo Information On Wo Queue    ${column_1}    ${tc_wo_name},${Patching 6x},${admin},${Immediate}
    ...    priority=${Normal}    scheduling=${Immediate}
    Check Work Order Priority Color    ${tc_wo_name}    ${YELLOW}
    Close Work Order Queue    

	# 9. Select Work Order History and observe
	Open Work Order History Window
    ${headers}    Set Variable    Work Order,Task,Type,Username
    ${values_list}    Create List
    ...    ${tc_wo_name},${task_1},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_2},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_3},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_4},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_5},${Add Patch},${admin}
    ...    ${tc_wo_name},${task_6},${Add Patch},${admin}
    
    ${rows_list}    Create List    1    2    3    4    5    6
    
    Expand Wo In Wo History    ${tc_wo_name}    ${Immediate}
    :FOR    ${i}    IN RANGE    0    len(${values_list})    	         
	\   Check Wo History Data Line    ${rows_list}[${i}]    ${headers}    ${values_list}[${i}]
	Close Wo History Window
	
	# 10. Edit WO 01 and observe
	# 11. Edit some info and save:
	# _Summary: Test_Edit WO
	# _Priority: High
	# _Scheduling: Scheduled
	# _Technician: blank
	# _Earliest Date: today
	# _Latest Date: tommorrow
	Open Work Order Queue Window
	Click Edit Button On Wo Queue Window    ${tc_wo_name}
	Check Elements Are Disabled On Edit Wo Information    woName=${True}    workType=${True}    createdBy=${True}    dateCreated=${True}    expectedDate=${True}        
    Edit Work Order    summary=${Patching 6x_update}    priority=${High}    technician=${EMPTY}    scheduling=${Scheduled}    earliestDate=${date_1}    latestDate=${date_2}
	
	# 12. Observe WO above after updating
	Check Work Order Priority Color    ${tc_wo_name}    ${RED}
    Check Wo Information On Wo Queue    columns=${column_2}    values=${tc_wo_name},${Patching 6x_update},${EMPTY},${Scheduled},${date_1},${date_2}
    ...    priority=${High}    scheduling=${Scheduled}    	
	# 13. Complete WO above and observe the result
	Complete Work Order    ${tc_wo_name}    
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
    Close Work Order Queue
    
	# 14. Remove patch connection from Panel 01/Module 01/01 to Switch/GBIC Slot/1-1,2-2 with:
	# _Work Order: WO 02
	# _Work Type: Patching
	# _Summary : Test 02
	# _Priority: Low
	# _Scheduling: Scheduled
	# _Technician: test
	# _Earliest Date: YYYY-MM-DD
	# _Latest Date: YYYY-MM-DD
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack}/${SWITCH_01}/${GBIC_SLOT}
    ...    portsFrom=${01}    portsTo=${01},${02}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2}
    ...    createWo=${True}    clickNext=${True}
	
	Create Work Order    woName=${tc_wo_name}	summary=${Patching 6x}	priority=${Low}	
	...    technician=${admin}    scheduling=${Scheduled}
	Wait For Work Order Icon On Content Table    ${01}
	
	# 15. Observe WO 02 in Work Order Queue
	Open Work Order Queue Window
    Check Wo Information On Wo Queue    columns=${column_1}    values=${tc_wo_name},${Patching 6x},${admin},${Scheduled}
    ...    priority=${Low}    scheduling=${Scheduled}
    Check Work Order Priority Color    ${tc_wo_name}    ${WHITE}
	
	# 16. Delete WO 02 and observe	
	Delete Wo On Wo Queue Window    ${tc_wo_name}
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
    Close Work Order Queue

SM-29804_SM-29805_05_Verify that user can create/remove patch MPO12-6xLC ULL Assembly from MPO InstaPatch port to Server Port
### Note:work order is set On-Hold
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29804_05
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Building     ${building_name}  
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${port_list}    Create List    ${01}    ${02}    ${03}
    ${tc_wo_name}    Set Variable    WO_SM29804_05

	# On SM:
	# 3. Add to Rack 001:
	# _InstaPatch MPO Panel 01
	# _LC Server 01
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_1}    ${Module 1A},True,${MPO 2 Port},,
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SERVER_01}
    Add Device In Rack Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_01}    ${01}    portType=${LC}    quantity=6    
	
	# 4. Create a patching job from Panel 01/Module 01/01 to Server/1-1,2-2,3-3
	# _Work Order: WO 01
	# _Work Type: Patching
	# _Summary : Test
	# _Priority: Normal
	# _Scheduling: On-Hold
    Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack}/${SERVER_01}
    ...    portsFrom=${01}    portsTo=${01},${02},${03}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3}
    ...    createWo=${True}    clickNext=${True}
    
    Create Work Order    woName=${tc_wo_name}	summary=${Patching 6x}    priority=${Normal}	
	...    scheduling=${Immediate}    onHold=${True}
	Wait For Work Order Icon On Content Table    ${01}
	
	# 5. Observe Work Order icon
	Wait For Property On Properties Pane    ${Port Status}    ${In Use - Pending}    
    Check Work Orders On Hold Icon On Site Manager    ${RED}

	# 6. Open Work Order On Hold and observe
	Open Work On Hold Window
    Check Wo Information On Wo Queue    ${column_3}    ${tc_wo_name},${Patching 6x},${On Hold}
    ...    priority=${Normal}    scheduling=${Immediate}
    
	# 7. Complete WO above in Work Order on Hold window and observe
	# * Step 7:
	# _Work Order icon shows in black color
	Complete Work Order    ${tc_wo_name}
    Close Work Order Queue
    Click Tree Node On Site Manager    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})
    Select Object On Content Table    ${01} 
    Wait For Property On Properties Pane    ${Port Status}    ${In Use}  
      
    Check Work Orders On Hold Icon On Site Manager    ${BLACK}
    
 	# _WO is no longer in Work Order Queue and Work Order on Hold   
    Open Work Order Queue Window    
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
    Close Work Order Queue
    Open Work On Hold Window
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
    Close Work Order Queue
 
    # _Ports are in connection (In Use)
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use} - 3/6    1
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}  

	# 8. Remove patch connection for WO above without creating work order
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack}/${SERVER_01}
    ...    portsFrom=${01}    portsTo=${01},${02},${03}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3}
    ...    createWo=${False}    clickNext=${True}

	# 9. Observe the result
    Open Work Order Queue Window    
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
    Close Work Order Queue
    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SERVER_01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1}  
    
SM-29804_SM-29805_06_Verify that user can create/remove patch MPO12-6xLC ULL Assembly from MPO InstaPatch port to MNE Port
### Note: Edit Work Order window of a work order on Managed Switch, the Inactivity Alert field is editable
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29804_06
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Building     ${building_name}  
    
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building     ${building_name}

    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${tc_wo_name_1}    Set Variable    WO_SM29804_06_1
    ${tc_wo_name_2}    Set Variable    WO_SM29804_06_2
    ${ip_address}    Set Variable    10.5.6.97

	# * On SM:
	# 3. Add to Rack 001:
	# _LC MNE 01 (10.5.6.97)  and sync successfully
	# _InstaPatch MPO Panel 01
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_1}    ${Module 1A},True,${MPO 2 Port},,
	Add Managed Switch    ${tree_node_rack}    ${SWITCH_01}    ${ip_address}     updateMneName=${False}   
    Synchronize Managed Switch    ${tree_node_rack}/${SWITCH_01}    
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${SWITCH_01}    ${ip_address}
    
	# 4. Create a patching job from Panel 01/Module 01/01 to Switch/Card 01/1-1,...,6-6
	# _Work Order: WO 01
	# _Work Type: Patching
	# _Summary : Test 01
	# _Priority: Normal
	# _Scheduling: Immediate
	# _Earliest Date: <current day>
	# _Latest Date: <current day>
	# _Inactivity Alert: <current day> (set on this check box)
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack}/${SWITCH_01}/${CARD_01}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${True}

    Create Work Order    woName=${tc_wo_name_1}	summary=${Patching 6x}    priority=${Normal}	
	...    scheduling=${Immediate}    inactivityAlert=${True}
	Wait For Work Order Icon On Content Table    ${01}
	
	# 5. Delete WO 01 and observe
	# * Step 5: 
	# _WO 01 is no longer in Work Order Queue
	Open Work Order Queue Window
	Delete Wo On Wo Queue Window    ${tc_wo_name_1}
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name_1}
    Close Work Order Queue
    Wait For Property On Properties Pane    ${Port Status}    ${Available}    
	
	# _Ports are in available status
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_01}/${CARD_01}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1} 	
	
	# 6. Create a patching job from Panel 01/Module 01/01 to Switch/Card 01/1-1,2-2,3-3,4-4:
	# _Work Order: WO 02
	# _Work Type: Patching
	# _Summary : Test 02
	# _Priority: Normal
	# _Scheduling: Scheduled
	# _Earliest Date: <current day>
	# _Latest Date: <current day>
	# _Inactivity Alert: <current day> (set on this check box)
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack}/${SWITCH_01}/${CARD_01}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4}
    ...    createWo=${True}    clickNext=${True}

    Create Work Order    woName=${tc_wo_name_2}    summary=${Patching 6x}    priority=${Normal}	
	...    scheduling=${Scheduled}    inactivityAlert=${True}	
    Wait For Work Order Icon On Content Table    ${01}
    
	# 7. Complete WO 02 and observe the result
	# * Step 7:
	# _WO 02 is no longer in Work Order Queue
	
	Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name_2}
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name_2}
    Close Work Order Queue
    Wait For Property On Properties Pane    ${Port Status}    ${In Use} - 4/6

    # _Ports are in In Use status
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use} - 4/6    1
    
    Click Tree Node On Site Manager    ${tree_node_rack}/${SWITCH_01}/${CARD_01}
    Select Object On Content Table    ${01}
    Wait For Property On Properties Pane    ${Port Status}    ${In Use}
	:FOR    ${i}     IN RANGE    0    3
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1} 	
  
	# 8. Observe Work Order History
	Open Work Order History Window
	Check Wo History Information    ${tc_wo_name_1}   Deleted
    Check Wo History Information    ${tc_wo_name_2}   Completed
	Close Wo History Window
	
SM-29804_SM-29805_07_Verify that SM allow Cross-Zone Patching for MPO12-6xLC ULL Assembly if the "Allow Cross-Zone Patching for non-iPatch Objects" option is checked
### Note: Edit Work Order window of a work order on Managed Switch, the Inactivity Alert field is editable
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29804_07
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Select Main Menu    ${Administration}/${System Manager}    ${Feature Options}
    ...    AND    Set Feature Options    ${True}
    ...    AND    Select Main Menu    ${Site Manager}
    ...    AND    Delete Building     ${building_name}

    [Teardown]    Run Keywords    Select Main Menu    ${Administration}/${System Manager}    ${Feature Options}
    ...    AND    Set Feature Options    ${False}
    ...    AND    Close Browser
    ...    AND    Delete Building     ${building_name}
    
    ${tree_node_rack}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}
    ${tree_node_rack_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME_2}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${tc_wo_name}    Set Variable    WO_SM29804_07
    ${trace_module1a}    Set Variable    ..le 1A (Pass-Through)
    ${position_list}    Create List     1    2    3    4    5    6
    ${pair_list_1}    Create List     ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
	# * On Administration:
	# _Go to "Feature Options" page under "System Manager" of Administration tab
	# _Make sure "Allow Cross-Zone Patching for non-iPatch Objects" checkbox is checked
	# * On SM:
	# 3. Add:
	# _1:1 Rack 001 and 2:1 Rack 001 to Room 01 (Multiple Zones)
	# _MPO InstaPatch Panel 01 to 1:1 Rack 001
	# _LC InstaPatch (Alpha) Panel 02 to 2:1 Rack 001
    Create Object    buildingName=${building_name}
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    ${Multiple Zones}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME_2}    position=2
    Add Systimax Fiber Equipment    ${tree_node_rack}    ${360 G2 Fiber Shelf (2U)}    ${PANEL_NAME_1}    ${Module 1A},True,${MPO 2 Port},,
    Add Systimax Fiber Equipment    ${tree_node_rack_2}    ${360 G2 Fiber Shelf (1U)}    ${PANEL_NAME_2}    ${Module 1A},True,${LC 6 Port},,
    	
	# 4. Create a patching job from Panel 01/Module 1A/01 to Panel 02/Module 1A/1-1,...,6-6
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${False}	
	# 5. Observe port icons, port status, circuit trace tab in Patching window
	# * Step 5:
	# _Port icons:
	  # + Panel 01/Module 1A/01: patched icon
	  # + Panel 02/Module 1A/01-06: patched icon
	  # + Panel 01/Module 1A/01 icon shows as MPO 12 icon
	Check Icon Object On Patching Tree    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${PortMPOUncabledInUseScheduled}    
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
    \    Check Icon Object On Patching Tree    To    ${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${port_list}[${i}]    ${PortFDUncabledInUseScheduled}

    Check Icon Mpo Port Type On Patching Window    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${12}    

	# _Port status for ports: Available
	Check Port Status On Patching Window    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${Available}
	Check Port Status On Patching Window    To    ${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    ${Available}

	# _Circuit:
	  # + Tab 1-1: Panel 01/Module 1A/12 1 [A1] -> patched to (with schedule icon) -> Panel 02/Module 1A/1 [1-1]
	  # + Tab 2-2: Panel 01/Module 1A/12 1 [A1] -> patched to (with schedule icon) -> Panel 02/Module 1A/2 [2-2]
	# ...
	  # + Tab 6-6: Panel 01/Module 1A/12 1 [A1] -> patched to (with schedule icon) -> Panel 02/Module 1A/6 [6-6]	
    Select View Tab On Patching    ${Circuit Trace}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
	\    Check Trace Object On Patching    indexObject=1    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=None    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${01}->${trace_module1a}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=None    
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list}[${i}]->${trace_module1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME_2}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    # 6. Complete job without creating WO
    Save Patching Window
	Create Work Order    woName=${tc_wo_name}
	Wait For Work Order Icon On Content Table    ${01}

	# 7. Observe Work Order Queue
	# * Step 7:
	# _WO is no longer in Work Order Queue
	# _Ports are in In Use (have connection)
	Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}    
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
    Close Work Order Queue
    Wait For Property On Properties Pane    ${Port Status}    ${In Use}

    # _Ports are in In Use status
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Click Tree Node On Site Manager    ${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    Select Object On Content Table    ${01}
    Wait For Property On Properties Pane    ${Port Status}    ${In Use}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1} 	
    	
	# 8. Select Panel 01/Module 1A/01 and open Patching window
	Open Patching Window    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    ${01}

	# 9. Observe port status, circuit trace tab in Patching window 
	# * Step 9:
	# _Port status for ports (From and To pane): In Use
	Check Port Status On Patching Window    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${In Use}
	Check Port Status On Patching Window    To    ${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    ${In Use}
		
    Select View Tab On Patching    ${Circuit Trace}
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})    	         
	\    Select View Trace Tab On Patching    ${pair_list_1}[${i}]
	\    Check Trace Object On Patching    indexObject=1    mpoType=${12}    objectPosition=1 [${A1}]   objectPath=None    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module1a}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    \    Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=${position_list}[${i}] [${pair_list_1}[${i}]]   objectPath=None    
	...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=${port_list}[${i}]->${trace_module1a}->${PANEL_NAME_2}->${POSITION_RACK_NAME_2}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# 10. Remove all patch connection between Panel 01 and Panel 02
    Create Patching    patchFrom=${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})    patchTo=${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    typeConnect=Disconnect    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    createWo=${True}    clickNext=${False}		

	# 11.  Observe port icons, port status, circuit trace tab in Patching window
	# * Step 11:
	# _Port icons:
	  # + Panel 01/Module 1A/01: available scheduled icon
	  # + Panel 02/Module 1A/01-06: available scheduled icon
	  # + Panel 01/Module 1A/01 icon shows as 12
	# _Port status for ports: In Use
	Check Icon Object On Patching Tree    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${PortMPOUncabledAvailableScheduled}    
    
    :FOR    ${i}     IN RANGE    0    len(${port_list})
    \    Check Icon Object On Patching Tree    To    ${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${port_list}[${i}]    ${PortFDUncabledAvailableScheduled}

    Check Icon Mpo Port Type On Patching Window    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${12}    

	# _Port status for ports: Available
	Check Port Status On Patching Window    From    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})/${01}    ${In Use}
	Check Port Status On Patching Window    To    ${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})/${01}    ${In Use}

	# _Circuit: Only Panel 1/Module 1A/01 shows
    Select View Tab On Patching    ${Circuit Trace}
    Check Trace Object On Patching    indexObject=1    mpoType=    objectPosition=1   objectPath=None    
	...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${trace_module1a}->${PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# 12. Complete to remove connection without creating WO
    Save Patching Window
	Create Work Order    woName=${tc_wo_name}
	Wait For Work Order Icon On Content Table    ${01}
	
	# 13. Observe Work Order Queue
	# * Step 13:
	# _WO is no longer in Work Order Queue
	# _Ports are in Available (no connection)
	Open Work Order Queue Window
	Complete Work Order    ${tc_wo_name}    
    Check Wo Not Exit On Wo Queue Window    ${tc_wo_name}
    Close Work Order Queue
    Wait For Property On Properties Pane    ${Port Status}    ${Available}
    
    # _Ports are in Available (no connection)
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}    1
    
    Click Tree Node On Site Manager    ${tree_node_rack_2}/${PANEL_NAME_2}/${Module 1A} (${Pass-Through})
    Select Object On Content Table    ${01}
    Wait For Property On Properties Pane    ${Port Status}    ${Available}
	:FOR    ${i}     IN RANGE    0    len(${port_list})
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}    ${i+1} 	
    